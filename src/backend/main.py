from fastapi import FastAPI, Response
from runware import Runware, IImageInference
from langchain_groq import ChatGroq
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers.pydantic import PydanticOutputParser
from pydantic import create_model as create_pydantic_model
from dotenv import load_dotenv
from os import environ
from base64 import b64decode


load_dotenv()

small_model = ChatGroq(model_name="llama-3.3-70b-versatile")
large_model = ChatAnthropic(model_name="claude-3-7-sonnet-latest")

runware = Runware(api_key=environ.get("RUNWARE_KEY"))

app = FastAPI()


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
        steps=10,
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
def description(idea: str):
    parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model("Description", description=(str, ...))
    )

    prompt = PromptTemplate.from_file(
        "prompts/ideate.md",
        input_variables=["idea"],
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    chain = prompt | small_model | parser

    response = chain.invoke({"idea": idea})
    return {"description": response.description}


@app.get("/saus/modify")
def description(description: str, modification: str):
    parser = PydanticOutputParser(
        pydantic_object=create_pydantic_model(
            "RefinedDescription", refined_description=(str, ...)
        )
    )

    prompt = PromptTemplate.from_file(
        "prompts/ideate.md",
        input_variables=["idea"],
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    chain = prompt | small_model | parser

    response = chain.invoke(
        {
            "idea": f"Their original dish: {description}\n\nModifications they asked for: {modification}"
        }
    )
    return {"description": response.refined_description}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=8000)
