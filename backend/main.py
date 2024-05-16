from typing import List, Tuple
from pydantic import BaseModel
from pydantic_settings import BaseSettings
from fastapi import FastAPI

class Environment(BaseSettings):
    stage: str

env = Environment()

app = FastAPI(
    redoc_url="/api/redoc",
    docs_url="/api/docs",
    openapi_url="/api/docs/openapi.json"
)

@app.get("/api")
def read_root():
    return {"Hello": "mido"}

@app.get("/api/stage")
def get_stage():
    return {"stage": env.stage}

@app.get("/api/title")
def get_title():
    return {"title": "Edit Distance"}

class EditDistanceRequest(BaseModel):
    src: str
    dst: str

@app.post("/api/edit_distance")
def get_edit_distance(
    data: EditDistanceRequest,
):
    dist, arr = edit_dist(data.src, data.dst)
    return {"distance": dist, "arr": arr}

"""
src を dst に変換するための編集距離を計算するメソッド
src       : 編集対象文字列
dst       : 目標文字列
add     : src に一文字追加するコスト
remove  : src から一文字削除するコスト
replace : src を一文字置換するコスト
"""
def edit_dist(src, dst, add=1, remove=1, replace=2) -> Tuple[int, List[List[int]]]:
  len_a = len(src) + 1
  len_b = len(dst) + 1
  # 配列の初期化
  arr = [[-1 for col in range(len_a)] for row in range(len_b)]
  arr[0][0] = 0
  for row in range(1, len_b):
    arr[row][0] = arr[row - 1][0] + add
  for col in range(1, len_a):
    arr[0][col] = arr[0][col - 1] + remove
  # 編集距離の計算
  def go(row, col):
    if (arr[row][col] != -1):
      return arr[row][col]
    else:
      dist1 = go(row - 1, col) + add
      dist2 = go(row, col - 1) + remove
      dist3 = go(row - 1, col - 1)
      arr[row][col] = min(dist1, dist2, dist3) if (dst[row - 1] == src[col - 1]) else min(dist1, dist2, dist3 + replace)
      return arr[row][col]
  return (go(len_b - 1, len_a - 1), arr)