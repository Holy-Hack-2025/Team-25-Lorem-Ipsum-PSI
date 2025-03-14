from fastapi import FastAPI, Response
from fastapi.responses import StreamingResponse
from runware import Runware, IImageInference
from langchain_groq import ChatGroq
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers.pydantic import PydanticOutputParser
from pydantic import create_model as create_pydantic_model
from dotenv import load_dotenv
from os import environ
from base64 import b64decode
import json
from typing import List, Dict


load_dotenv()

small_model = ChatGroq(
    model_name=environ.get("SMALL_MODEL_NAME"),
    model_kwargs={"response_format": {"type": "json_object"}},
    temperature=0
)
large_model = ChatAnthropic(
    model_name=environ.get("LARGE_MODEL_NAME"),
    max_tokens_to_sample=8000,  # 8000 so that the model can do chain of thought
    temperature=0.2
)

runware = Runware(api_key=environ.get("RUNWARE_KEY"))

app = FastAPI()

LABOR_COST = (
    12  # EUR12 per hour, assuming the chef can make more than one dish in an hour
)


@app.get("/saus/imagine")
async def image(description: str):
    await runware.connect()

    parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model("ImagePrompt", prompt=(str, ...))
    )

    prompt = PromptTemplate.from_file(
        "prompts/text2image.md",
        input_variables=["description"],
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    chain = prompt | small_model | parser

    response = await chain.ainvoke({"description": description})

    description = IImageInference(
        response.prompt,
        negativePrompt="overexposed, underexposed, text, watermark, low quality, blurry, distorted proportions, unnatural colors, artificial lighting, harsh shadows, plastic-looking food, cluttered composition, dirty plate, unappealing presentation",
        model="runware:102@1",
        width=512,
        height=512,
        outputFormat="JPG",
        outputType="base64Data",
        seedImage="assets/plate.png",
        maskImage="assets/plate-mask.png",
        numberResults=1,
        strength=1,
        CFGScale=30,
    )

    images = await runware.imageInference(requestImage=description)

    return Response(
        content=b64decode(images[0].imageBase64Data), media_type="image/jpeg"
    )


@app.get("/saus/suggest")
async def suggestions(description: str):
    parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "Suggestions", suggestions=(list[str], ...)
        )
    )

    prompt = PromptTemplate.from_file(
        "prompts/suggestions.md",
        input_variables=["description"],
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    chain = prompt | small_model | parser

    response = await chain.ainvoke({"description": description})
    return {"suggestions": response.suggestions}


@app.get("/saus/ideate")
async def ideate(idea: str):
    parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "Description", description=(str, ...), title=(str, ...)
        )
    )

    prompt = PromptTemplate.from_file(
        "prompts/ideate.md",
        input_variables=["idea"],
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    chain = prompt | small_model | parser

    response = await chain.ainvoke({"idea": idea})
    return {"description": response.description, "title": response.title}


@app.get("/saus/modify")
async def modify(description: str, modification: str):
    parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "RefinedDescription",
            refined_description=(str, ...),
            refined_title=(str, ...),
        )
    )

    prompt = PromptTemplate.from_file(
        "prompts/ideate.md",
        input_variables=["idea"],
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    chain = prompt | small_model | parser

    response = await chain.ainvoke(
        {
            "idea": f"Their original dish: {description}\n\nModifications they asked for: {modification}"
        }
    )
    return {
        "description": response.refined_description,
        "title": response.refined_title,
    }


@app.get("/saus/craft/recipe")
async def craft_recipe(description: str):
    """
    Craft a step-by-step recipe from a description with ingredients,
    steps, time required, and servings.
    """
    recipe_parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "Recipe",
            ingredients=(list[str], ...),
            steps=(list[str], ...),
            minutes_required=(int, ...),
            number_of_servings=(int, ...),
        )
    )

    recipe_prompt = PromptTemplate.from_file(
        "prompts/generate-recipe.md",
        input_variables=["description"],
        partial_variables={
            "format_instructions": recipe_parser.get_format_instructions()
        },
    )

    recipe_chain = recipe_prompt | large_model | recipe_parser

    recipe_response = await recipe_chain.ainvoke({"description": description})

    return {
        "ingredients": recipe_response.ingredients,
        "steps": recipe_response.steps,
        "minutes_required": recipe_response.minutes_required,
        "number_of_servings": recipe_response.number_of_servings,
    }


@app.get("/saus/craft/nutrition")
async def estimate_nutrition(ingredients: str, number_of_servings: int):
    """
    Estimate nutrition facts for a given list of ingredients and number of servings.
    """
    nutrition_parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "NutritionFacts",
            ingredients=(dict[str, str], ...),
            total_calories=(float, ...),
            total_fat=(float, ...),
            total_protein=(float, ...),
            total_carbs=(float, ...),
            total_sugar=(float, ...),
        )
    )

    nutrition_prompt = PromptTemplate.from_file(
        "prompts/nutrition-estimate.md",
        input_variables=["ingredients"],
        partial_variables={
            "format_instructions": nutrition_parser.get_format_instructions()
        },
    )

    nutrition_chain = nutrition_prompt | large_model | nutrition_parser

    nutrition_response = await nutrition_chain.ainvoke(
        {
            "ingredients": ingredients,
            "servings": number_of_servings,
        }
    )

    return {
        "total_calories": nutrition_response.total_calories,
        "total_fat": nutrition_response.total_fat,
        "total_protein": nutrition_response.total_protein,
        "total_carbs": nutrition_response.total_carbs,
        "total_sugar": nutrition_response.total_sugar,
    }


@app.get("/saus/craft/cost")
async def estimate_costs(ingredients: str, number_of_servings: int, minutes_required: int):
    """
    Estimate costs for a given list of ingredients, number of servings, and time required.
    """
    cost_estimate_parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "CostEstimate",
            ingredients=(dict[str, str], ...),
            total_cost=(float, ...),
        )
    )

    cost_estimate_prompt = PromptTemplate.from_file(
        "prompts/cost-estimate.md",
        input_variables=["ingredients"],
        partial_variables={
            "format_instructions": cost_estimate_parser.get_format_instructions()
        },
    )

    cost_estimate_chain = cost_estimate_prompt | large_model | cost_estimate_parser

    cost_estimate_response = await cost_estimate_chain.ainvoke(
        {
            "ingredients": ingredients,
            "servings": number_of_servings,
        }
    )

    labor_cost = LABOR_COST * minutes_required / 60
    total_cost = cost_estimate_response.total_cost + labor_cost

    return {
        "total_ingredients_cost": cost_estimate_response.total_cost,
        "total_cost_labour": labor_cost,
        "total_cost": total_cost,
    }


# Keep the original streaming endpoint for backward compatibility
async def recipe_crafter(description: str):
    recipe_result = await craft_recipe(description)
    
    yield "event: recipe\ndata: " + json.dumps(recipe_result) + "\n\n"
    
    nutrition_result = await estimate_nutrition(
        recipe_result["ingredients"], 
        recipe_result["number_of_servings"]
    )
    
    yield "event: nutrition\ndata: " + json.dumps(nutrition_result) + "\n\n"
    
    cost_result = await estimate_costs(
        recipe_result["ingredients"],
        recipe_result["number_of_servings"],
        recipe_result["minutes_required"]
    )
    
    yield "event: cost\ndata: " + json.dumps(cost_result) + "\n\n"


@app.get("/saus/craft")
async def craft(description: str):
    return StreamingResponse(
        recipe_crafter(description), media_type="text/event-stream"
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=8000)