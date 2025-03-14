import unittest
from unittest.mock import patch, MagicMock, AsyncMock
from fastapi.testclient import TestClient
from base64 import b64encode

# Import the app
from main import app


class TestSausAPI(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        
        # Sample test data
        self.sample_description = "A pasta dish with tomato sauce"
        self.sample_idea = "Spicy burger"
        self.sample_modification = "Make it vegetarian"
        self.sample_prompt = "Professional food photography of a delicious pasta dish with rich tomato sauce"
        self.sample_base64 = b64encode(b"mock_image_data").decode()

    @patch("main.small_model")
    def test_suggestions_endpoint(self, mock_small_model):
        # Configure the mock
        mock_chain_result = MagicMock()
        mock_chain_result.suggestions = ["Pasta Carbonara", "Spaghetti Bolognese", "Lasagna"]
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke = AsyncMock(
            return_value=mock_chain_result
        )

        # Call the endpoint
        response = self.client.get(f"/saus/suggest?description={self.sample_description}")
        
        # Verify the response
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("suggestions", data)
        self.assertEqual(len(data["suggestions"]), 3)
        self.assertEqual(data["suggestions"][0], "Pasta Carbonara")
        
        # Verify the mock was called with correct parameters
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke.assert_called_once()
        call_args = mock_small_model.__or__.return_value.__or__.return_value.ainvoke.call_args[0][0]
        self.assertEqual(call_args["description"], self.sample_description)

    @patch("main.small_model")
    def test_ideate_endpoint(self, mock_small_model):
        # Configure the mock
        mock_chain_result = MagicMock()
        mock_chain_result.description = "A juicy spicy burger with jalapeños and pepper jack cheese"
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke = AsyncMock(
            return_value=mock_chain_result
        )

        # Call the endpoint
        response = self.client.get(f"/saus/ideate?idea={self.sample_idea}")
        
        # Verify the response
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("description", data)
        self.assertTrue(len(data["description"]) > 0)
        
        # Verify the mock was called with correct parameters
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke.assert_called_once()
        call_args = mock_small_model.__or__.return_value.__or__.return_value.ainvoke.call_args[0][0]
        self.assertEqual(call_args["idea"], self.sample_idea)

    @patch("main.small_model")
    def test_modify_endpoint(self, mock_small_model):
        # Configure the mock
        mock_chain_result = MagicMock()
        mock_chain_result.refined_description = "A vegetarian pasta dish with tomato sauce and plant-based meatballs"
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke = AsyncMock(
            return_value=mock_chain_result
        )

        # Call the endpoint
        response = self.client.get(f"/saus/modify?description={self.sample_description}&modification={self.sample_modification}")
        
        # Verify the response
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("description", data)
        self.assertTrue(len(data["description"]) > 0)
        
        # Verify the mock was called with correct parameters
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke.assert_called_once()
        call_args = mock_small_model.__or__.return_value.__or__.return_value.ainvoke.call_args[0][0]
        self.assertIn(self.sample_description, call_args["idea"])
        self.assertIn(self.sample_modification, call_args["idea"])

    @patch("main.runware")
    @patch("main.small_model")
    def test_image_endpoint(self, mock_small_model, mock_runware):
        # Configure the mocks
        mock_chain_result = MagicMock()
        mock_chain_result.prompt = self.sample_prompt
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke = AsyncMock(
            return_value=mock_chain_result
        )
        
        mock_image_result = MagicMock()
        mock_image_result.imageBase64Data = self.sample_base64
        mock_runware.connect = AsyncMock()
        mock_runware.imageInference = AsyncMock(return_value=[mock_image_result])
        
        # Call the endpoint
        response = self.client.get(f"/saus/imagine?description={self.sample_description}")
        
        # Verify the response
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "image/jpeg")
        
        # Verify the mocks were called with correct parameters
        mock_runware.connect.assert_called_once()
        mock_small_model.__or__.return_value.__or__.return_value.ainvoke.assert_called_once()
        mock_runware.imageInference.assert_called_once()
        
        # Check that the iImageInference was created with the right parameters
        image_inference_call = mock_runware.imageInference.call_args[1]["requestImage"]
        self.assertEqual(image_inference_call.prompt, self.sample_prompt)
        self.assertEqual(image_inference_call.model, "runware:102@1")
        self.assertEqual(image_inference_call.width, 512)
        self.assertEqual(image_inference_call.height, 512)


if __name__ == "__main__":
    unittest.main()