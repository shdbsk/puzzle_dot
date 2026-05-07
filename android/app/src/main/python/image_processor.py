import cv2
import numpy as np
import json


def process_image(image_path: str) -> str:
    img = cv2.imread(image_path)
    if img is None:
        return json.dumps({"error": "Cannot read image"})

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (9, 9), 2)

    circles = cv2.HoughCircles(
        blurred,
        cv2.HOUGH_GRADIENT,
        dp=1,
        minDist=20,
        param1=50,
        param2=30,
        minRadius=5,
        maxRadius=50,
    )

    result = {"circles": []}
    if circles is not None:
        circles = np.uint16(np.around(circles))
        for c in circles[0, :]:
            result["circles"].append({
                "x": int(c[0]),
                "y": int(c[1]),
                "radius": int(c[2]),
            })

    return json.dumps(result)


def get_image_info(image_path: str) -> str:
    img = cv2.imread(image_path)
    if img is None:
        return json.dumps({"error": "Cannot read image"})

    h, w, c = img.shape
    return json.dumps({"width": w, "height": h, "channels": c})
