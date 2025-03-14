from fastapi import FastAPI, Response
from runware import Runware, IImageInference
import anthropic
from groq import Groq
import json
import os
from dotenv import load_dotenv
import base64

load_dotenv()

runware_key = os.environ.get("RUNWARE_KEY")

groq = Groq()

app = FastAPI()


@app.get("/image")
async def image(dish_description: str):
    
    runware = Runware(api_key=runware_key)
    await runware.connect()

    print(dish_description)

    completion = groq.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {
                "role": "system",
                "content": """
You are an expert food photographer who specializes in hyperrealistic commercial food photography. Your job is to transform a simple food description into a detailed visual prompt that will generate photorealistic images of the dish.

For each dish described, create a prompt that includes:
1. The main ingredients and their appearance (texture, color, doneness)
2. The plating style and arrangement (layering, height, positioning)
3. The garnishes and finishing touches
4. The specific lighting setup (soft, directional, etc.)
5. The camera angle and perspective (overhead, 45-degree, macro, etc.)
6. The depth of field and focus points
7. Color palette and mood
8. Surface/plate details (material, color, shape)

Use specific, technical photography terminology when appropriate. Emphasize photorealism through details like natural imperfections, steam, moisture, or oil sheen. Focus exclusively on the dish itself - no table settings or backgrounds.

Format your prompt with these specific sections:
- SUBJECT: [clear description of the dish]
- COMPOSITION: [plating details and arrangement]
- LIGHTING: [specific lighting quality]
- TECHNICAL: [camera settings and perspective]
- DETAILS: [micro-details that sell realism]

Keep your total prompt under 100 words for optimal results."""
            },
            {
                "role": "user",
                "content": "<name>\n" + dish_description + "\n</name>\n"
            }
        ],
        temperature=1,
        max_completion_tokens=1024,
        top_p=1,
        stream=False,
        stop=None,
    )

    print(completion.choices[0].message.content)

    description = IImageInference(
        completion.choices[0].message.content,
        #dish_description,
        model="runware:102@1",
        width=512,
        height=512,
        outputFormat="JPG",
        outputType="base64Data",
        seedImage="plate-new.png", 
        maskImage="mask-new.png",
        numberResults=1
    )

    images = await runware.imageInference(requestImage=description)

    imagebase64 = images[0].imageBase64Data
    image = base64.b64decode(imagebase64)

    return Response(content=image, media_type="image/jpeg")


@app.get("/suggestions")
def description(idea: str):
    message = groq.chat.completions.create(
        model="llama-3.3-70b-versatile",
        max_completion_tokens=20000,
        temperature=1,
        messages=[
            {
                "role": "system",
                "content": "You are a private chef. Your job is to come up with suggestions based on the ideas of your client. So for example if they ask for a cheesy pasta, you can suggest adding bacon to it or tomatoes. Output your suggestions as JSON. Only reply with three suggestions. Suggestions must be 2 words maximum."
            },
            {
                "role": "user",
                "content": "<examples>\n<example>\n<idea>\ncheesy pasta\n</idea>\n<ideal_output>\n[\"bacon\", \"tomato sauce\", \"healthy\"]\n</ideal_output>\n</example>\n</examples>\n\n<idea>\n" + idea + "\n</idea>\n"
            }
        ]
    )

    return {"suggestions": json.loads(message.choices[0].message.content)}

@app.get("/description")
def description(idea: str):
    message = groq.chat.completions.create(
        model="llama-3.3-70b-versatile",
        max_completion_tokens=20000,
        temperature=1,
        messages=[
            {
                "role": "system",
                "content": "You are a private chef. Your job is to come up with a somewhat detailed dish description based on the ideas of your client. Do not use any formatting, and do not talk in first person, just describe the dish. The dishes should not be complicated."
            },
            {
                "role": "user",
                "content": idea
            }
        ]
    )

    return {"description": message.choices[0].message.content}

@app.get("/make-modifications")
def make_modifications(description: str, modifications: str):
    message = groq.chat.completions.create(
        model="llama-3.3-70b-versatile",
        max_completion_tokens=20000,
        temperature=1,
        messages=[
            {
                "role": "system",
                "content": "You are a private chef. Your job is to come up with a somewhat detailed dish description based on the ideas of your client. Do not use any formatting, and do not talk in first person, just describe the dish. The dishes should not be complicated."
            },
            {
                "role": "user",
                "content": "Original dish created by you: " + description + "\n\nModifications requested by client: " + modifications
            }
        ]
    )

    return {"description": message.choices[0].message.content}