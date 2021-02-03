import os
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image as img
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras import backend as k
import numpy as np
import tensorflow as tf
from PIL import Image
from tensorflow.keras.applications.resnet50 import ResNet50,decode_predictions,preprocess_input
import io
from flask import Flask, request, jsonify

app = Flask(__name__)

#model = ResNet50(weights = 'imagenet')

model = load_model("model.h5")

def identifyImage(img_path):
   
    image = img.load_img(img_path,target_size=(224,224))
    x = img_to_array(image)
    x = np.expand_dims(x, axis=0)
    # images = np.vstack([x])
    x = preprocess_input(x)
    preds = model.predict(x)
    preds = decode_predictions(preds,top=1)
    print(preds)
    return  preds

@app.route('/predict', methods = ['POST'])
def predict():

    if request.method == 'POST':

        image_file = request.files['image']

        path = os.path.join(os.getcwd() + image_file.filename)

        image_file.save(path)

        classes = identifyImage(path)

        return jsonify({
            "status":"success",
            "prediction" : str(classes[0][0][1]),
            "confidence" : str(classes[0][0][2])
        })


if __name__ == '__main__':

    app.run(debug=True, host = '192.168.43.143',port = 8000)