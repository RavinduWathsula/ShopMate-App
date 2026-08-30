import cv2
import numpy as np

class OcrEngine:
    def __init__(self, use_mock=True):
        self.use_mock = use_mock
        if not self.use_mock:
            import easyocr
            self.reader = easyocr.Reader(['en'])

    def extract_text(self, cropped_image: np.ndarray) -> str:
        if self.use_mock:
            # Mock OCR return based on simple color or random logic 
            # to simulate reading 'Organic Bananas' or 'Milk'
            return 'Organic Bananas'
        else:
            result = self.reader.readtext(cropped_image)
            texts = [text for (bbox, text, prob) in result]
            return ' '.join(texts)
