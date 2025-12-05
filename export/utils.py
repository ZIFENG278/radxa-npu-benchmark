import onnx
from onnxsim import simplify
import requests
import onnx
import os
from tqdm import tqdm

def sim_model(model_path, input_shapes=None):
    sim_model_path = model_path.split(".")[0] + "-sim.onnx"
    model = onnx.load(model_path)
    if input_shapes is not None:
        model_simp, check = simplify(
            model,
            overwrite_input_shapes=input_shapes
        )
    else:
        model_simp, check = simplify(model)
    onnx.save(model_simp, sim_model_path)

    print(f"[OK] Simplified model: {sim_model_path}")


def url_download(url, save_path, chunk_size=8192):
    headers = {"User-Agent": "Mozilla/5.0"}

    # 请求文件
    with requests.get(url, stream=True, headers=headers) as r:
        r.raise_for_status()

        # 获取文件总大小
        total_size = int(r.headers.get("Content-Length", 0))

        # 开始下载
        with open(save_path, "wb") as f, tqdm(
            total=total_size,
            unit='B',
            unit_scale=True,
            desc=os.path.basename(save_path),
            initial=0,
            ascii=True,         # 兼容更多终端
            miniters=1
        ) as pbar:
            for chunk in r.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)
                    pbar.update(len(chunk))

    print(f"[OK] Downloaded: {save_path}")