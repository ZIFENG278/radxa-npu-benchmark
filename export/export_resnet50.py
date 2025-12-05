import os.path
from utils import sim_model, url_download

model_url = "https://github.com/onnx/models/raw/refs/heads/main/validated/vision/classification/resnet/model/resnet50-v2-7.onnx"
save_path = "resnet50-v2-7.onnx"

def export_resnet50():
    if not os.path.exists(save_path):
        url_download(model_url, save_path)
    sim_model(save_path, input_shapes={"data": [1,3,224,224]})


if __name__ == '__main__':
    export_resnet50()