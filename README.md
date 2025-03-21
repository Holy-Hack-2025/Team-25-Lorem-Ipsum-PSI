# Holy Hack - repo team Lorem Ipsum



# Saus Backend API

The Saus Backend is a FastAPI service that helps create and visualize food recipes using AI. It provides endpoints for generating food images, offering ingredient suggestions, ideating dishes, creating complete recipes, and estimating nutritional information and costs.

## Features

- Generate appetizing food images based on text descriptions
- Transform basic food ideas into detailed dish descriptions
- Create complete recipes with ingredients, steps, timing, and serving details
- Estimate nutritional information for recipes
- Calculate ingredient and labor costs for recipes
- Refine dish descriptions based on requested modifications
- Suggest complementary ingredients for food descriptions

## Tech Stack

- **FastAPI**: Web framework for building APIs
- **Langchain**: Framework for orchestrating AI model interactions
- **Groq**: AI model for generating small responses
- **Anthropic Claude**: AI model for generating complex responses and recipes
- **Runware**: Service for generating food images
- **Pydantic**: Data validation and parsing
- **Server-Sent Events**: For streaming combined recipe, nutrition, and cost data

## API Endpoints

### `/saus/imagine`

Generates food images based on text descriptions.

- **Method**: GET
- **Query Parameter**: `description` - Text description of the food
- **Returns**: JPEG image

### `/saus/suggest`

Offers ingredient suggestions for food descriptions.

- **Method**: GET
- **Query Parameter**: `description` - Text description of the food
- **Returns**: List of ingredient suggestions

### `/saus/ideate`

Transforms basic food ideas into detailed dish descriptions and titles.

- **Method**: GET
- **Query Parameter**: `idea` - Basic food idea
- **Returns**: Detailed description and title

### `/saus/modify`

Refines dish descriptions based on requested modifications.

- **Method**: GET
- **Query Parameters**: 
  - `description` - Original dish description
  - `modification` - Requested modification
- **Returns**: Refined description and title

### `/saus/craft/recipe`

Creates complete recipes with ingredients, steps, timing, and serving details.

- **Method**: GET
- **Query Parameter**: `description` - Dish description
- **Returns**: Recipe with ingredients, steps, time required, and servings

### `/saus/craft/nutrition`

Estimates nutritional information for recipes.

- **Method**: GET
- **Query Parameters**: 
  - `ingredients` - List of ingredients
  - `number_of_servings` - Number of servings
- **Returns**: Nutritional facts including calories, fat, protein, carbs, and sugar

### `/saus/craft/cost`

Calculates ingredient and labor costs for recipes.

- **Method**: GET
- **Query Parameters**: 
  - `ingredients` - List of ingredients
  - `number_of_servings` - Number of servings
  - `minutes_required` - Time required to prepare the recipe
- **Returns**: Cost breakdown including ingredients cost, labor cost, and total cost

### `/saus/craft`

Streaming endpoint that combines recipe, nutrition, and cost in one request.

- **Method**: GET
- **Query Parameter**: `description` - Dish description
- **Returns**: Server-sent events with recipe, nutrition, and cost data

## Setup and Installation

### Prerequisites

- Python 3.12+
- Poetry package manager

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```
SMALL_MODEL_NAME=<Groq model name>
LARGE_MODEL_NAME=<Anthropic Claude model name>
RUNWARE_KEY=<Runware API key>
```

### Installation

1. Clone the repository
2. Install dependencies with Poetry:

```bash
poetry install
```

### Running the Server

Start the server with:

```bash
poetry run uvicorn main:app --reload
```

The server will be available at http://localhost:8000

### Docker

You can also run the server using Docker:

```bash
docker build -t saus-backend .
docker run -p 8000:8000 -e SMALL_MODEL_NAME=<model> -e LARGE_MODEL_NAME=<model> -e RUNWARE_KEY=<key> saus-backend
```

## Example Usage

You can find example API requests in the `requests/` directory:

- `craft.http` - Examples for the combined recipe generation endpoint
- `ideate.http` - Examples for dish ideation
- `imagine.http` - Examples for food image generation
- `modify.http` - Examples for dish modification
- `nutrition.http` - Examples for nutritional estimation
- `recipe.http` - Examples for recipe generation
- `suggest.http` - Examples for ingredient suggestions


# Saus Frontend

A Flutter-based mobile application that uses AI to generate personalized meal ideas, recipes, nutrition facts, and delivery options based on your food preferences.

## Features

- **AI-Powered Meal Generation**: Describe what you want to eat in natural language, and the app will generate custom meal ideas
- **Complete Recipes**: Get detailed ingredients and step-by-step instructions for each meal
- **Nutrition Information**: View calories, carbs, protein, fat, and sugar content for each meal
- **Cost Estimates**: See approximate costs for ingredients and preparation
- **Meal Customization**: Modify generated meal ideas to match your preferences
- **Delivery Tracking**: Order your meal and track delivery on an interactive map

## Tech Stack

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Provider**: State management
- **go_router**: Navigation and routing
- **dio**: API communication
- **flutter_map**: Interactive maps for delivery tracking
- **slang**: Internationalization

## Getting Started

### Prerequisites

- Flutter SDK (version ^3.7.0)
- Dart SDK
- Android Studio or Xcode for device emulation

### Installation

1. Clone the repository
   ```
   git clone https://github.com/breitburg/holyhack.git
   cd holyhack/src/app
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run the app
   ```
   flutter run
   ```

## Project Structure

- `lib/models/`: Data models for meals, recipes, nutrition facts, and cost estimates
- `lib/providers/`: State management for kitchen features and AI services
- `lib/screens/`: UI screens for home, meal builder, recipe view, and delivery map
- `lib/widgets/`: Reusable UI components
- `lib/helpers/`: Utility functions and theming
- `lib/i18n/`: Internationalization resources