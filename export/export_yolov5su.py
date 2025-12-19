import os.path

import onnx
from ultralytics import YOLO
from utils import sim_model

def cut_yolov5s():

    input_path = "yolov5su.onnx"
    output_path = "yolov5su-cut.onnx"
    output_path_postprocess = "yolov5su-postprocess.onnx"

    input_names = ["images"]
    output_names = ["/model.24/Concat_output_0", "/model.24/Concat_1_output_0", "/model.24/Concat_2_output_0"]
    onnx.utils.extract_model(input_path, output_path, input_names, output_names)

    input_names = ["/model.24/Concat_output_0", "/model.24/Concat_1_output_0", "/model.24/Concat_2_output_0"]

    onnx.utils.extract_model(
        input_path,
        output_path_postprocess,
        input_names=input_names,
        output_names=["output0"]
    )

def ultralytics_export(model_name):
    model = YOLO(model_name)  # load a pretrained model (recommended for training)
    model.export(format="onnx", opset=13, imgsz=640)


def export_benchmark_yolov5s():
    ultralytics_export("yolov5s.pt")
    cut_yolov5s()
    sim_model("yolov5su-cut.onnx")


if __name__ == '__main__':
    export_benchmark_yolov5s()

