from fastapi import FastAPI
from runware import Runware, IImageInference
import anthropic
import json
import os
from dotenv import load_dotenv

load_dotenv()

runware_key = os.environ.get("RUNWARE_KEY")
anthropic_key = os.environ.get("ANTHROPIC_KEY")

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key=anthropic_key,
)


app = FastAPI()


@app.get("/image")
async def image(dish_description: str):
    runware = Runware(api_key=runware_key)
    await runware.connect()

    # because the SDK does not support variables.
    message = client.messages.create(
        model="claude-3-5-haiku-latest",
        max_tokens=8192,
        temperature=1,
        system="You are a photography director working for a food delivery company on product photography. Your job is to make a very detailed visual description of a dish based on it's name and properties that the chef will use to make a dish visually appealing. Only describe what's on the plate, do not describe the environment or setting. Do not include anything except the description of the dish.",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "<examples>\n<example>\n<name>\nlasagna\n</name>\n<ideal_output>\nsquare layered lasagna with a few cherry tomatoes sprinkled on top\n</ideal_output>\n</example>\n</examples>\n\n"
                    },
                    {
                        "type": "text",
                        "text": "<name>\n" + dish_description + "\n</name>\n"
                    }
                ]
            }
        ]
    )

    print(message.content[0].text)

    description = IImageInference(
        message.content[0].text,
        model="runware:102@1",
        width=512,
        height=512,
        outputFormat="JPG",
        outputType="URL",
        seedImage="plate.png",
        maskImage="invert-mask.png",
        numberResults=1
    )

    images = await runware.imageInference(requestImage=description)

    return {"url": images[0].imageURL, "detailed_description": message.content[0].text}



@app.get("/suggestions")
def description(idea: str):
    message = client.messages.create(
        model="claude-3-7-sonnet-20250219",
        max_tokens=20000,
        temperature=1,
        system="You are a private chef. Your job is to come up with suggestions based on the ideas of your client. So for example if they ask for a cheesy pasta, you can suggest adding bacon to it or tomatoes. Output your suggestions as JSON. Only reply with three suggestions. Suggestions must be 2 words maximum.",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "<examples>\n<example>\n<idea>\ncheesy pasta\n</idea>\n<ideal_output>\n[\"bacon\", \"tomato sauce\", \"healthy\"]\n</ideal_output>\n</example>\n</examples>\n\n"
                    },
                    {
                        "type": "text",
                        "text": "<idea>\n" + idea + "\n</idea>\n"
                    }
                ]
            },
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "["
                    }
                ]
            }
        ]
    )

    return {"suggestions": json.loads("[" + message.content[0].text)}

@app.get("/description")
def description(idea: str):
    message = client.messages.create(
        model="claude-3-7-sonnet-20250219",
        max_tokens=20000,
        temperature=1,
        system="You are a private chef. Your job is to come up with a somewhat detailed dish description based on the ideas of your client. Do not use any formatting, and do not talk in first person, just describe the dish. The dishes should not be complicated.",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": idea
                    }
                ]
            }
        ]
    )

    return {"description": message.content[0].text}

@app.get("/make-modifications")
def make_modifications(description: str, modifications: str):
    message = client.messages.create(
        model="claude-3-7-sonnet-20250219",
        max_tokens=20000,
        temperature=1,
        system="You are a private chef. Your job is to come up with a somewhat detailed dish description based on the ideas of your client. Do not use any formatting, and do not talk in first person, just describe the dish. The dishes should not be complicated.",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Original dish created by you: " + description + "\n\nModifications requested by client: " + modifications
                    }
                ]
            }
        ]
    )

    return {"description": message.content[0].text}