# coding: utf-8
import re
import collections
import math

# ハフマン木のノード(葉または節点)を示すクラス
class Node:
  # コンストラクタ
  def __init__(self,char = None,occurrence_probability = None,up = None,down = None):
    self.char = char # ノードの持つ文字
    self.occurrence_probability = occurrence_probability # ノードの出現確率
    self.up = up
    self.down = down

# ハフマン木を示すクラス
class HuffmanTree:
  # コンストラクタ
  def __init__(self,input_string,collections_array):
    self.encode_dict = collections.OrderedDict() # 符号語を保持する辞書
    self.input_string = input_string # 入力文字列
    self.collections_array = collections_array # 文字と出現回数を保持する配列

  # 出現確率を計算するメソッド
  def compute_occurrence_probability(self):
    self.occurrence_probability_array = [ self.collections_array[i][1]/len(self.input_string) for i in range(len(self.collections_array)) ]

  # 符号化するメソッド
  def encode(self):
    nodes = [] # 探索していない葉を格納する配列
    temp = []

    # 出現確率の計算
    self.compute_occurrence_probability()

    # 葉の生成
    for i in range(len(self.collections_array)):
      nodes.append(Node(self.collections_array[i][0],self.occurrence_probability_array[i]))

    # 文字数が1の場合0を割り当てて終了
    if len(self.collections_array) == 1:
      self.encode_dict[nodes[0].char] = "0"
      return self.encode_dict

    # ノードの数が1になるまで繰り返し
    while len(nodes) > 1:
      # 出現確率の小さい方から2つ取り出して、節点を生成
      for i in range(2):
        element = nodes[-1]
        temp.append(element)
        nodes.remove(element)

      # 新しい節点を生成
      new_node = Node(char=None, occurrence_probability=temp[0].occurrence_probability + temp[1].occurrence_probability,up=temp[1],down=temp[0])
      # 探索していないノードの配列に格納
      nodes.append(new_node)
      temp = []

    # 符号語の割り当て
    self.allocate_codewords(nodes[0],"")
    
    # 符号語部分だけ取り出してreturn
    return list(map(lambda x: x[1], self.encode_dict.items()))


  # 符号語を割り当てるメソッド
  def allocate_codewords(self,node,code):

    # nodeがクラスNodeのオブジェクトでないときreturn
    if not isinstance(node, Node):
      return

    # 葉が文字を持っている(節点でない)場合、符号語を割り当ててreturn
    if node.char:
      self.encode_dict[node.char] = code
      return

    # 再帰呼び出し
    self.allocate_codewords(node.up, code+"0")
    self.allocate_codewords(node.down, code+"1")

if __name__ == "__main__":
  print("[ハフマン符号の構成プログラム]\n")
  print("<<入力する文字列は次の条件を満たしてください。>>")
  print("1.使用する文字が小文字のアルファベットのみ")
  print("2.文字列の長さが40文字以下")
  print("3.文字の種類が10種類以下\n")

  input_string = input("符号化したい文字列を入力\n>>")
  pattern = re.compile("[a-z]+") # 小文字のアルファベットの正規表現パターンを作成
  string_collections = collections.Counter(list(input_string)) # 文字の種類と出現回数を保持するオブジェクト

  # 入力文字列がパターンにマッチしない
  # 入力文字列の長さが40文字より大きい
  # 文字の種類が10より大きい
  # 上記のいずれかの条件を満たしたら再入力
  while((not pattern.fullmatch(input_string)) or len(input_string) > 40 or len(string_collections) > 10):
    if (not pattern.fullmatch(input_string)):
      print("[入力可能文字はアルファベットの小文字のみです。]\n")
    elif len(input_string) > 40:
      print("[文字数が40文字を超えています。]\n")
    else:
      print("[文字の種類が10種類を超えています。]\n")

    input_string = input("再入力\n>>")
    string_collections = collections.Counter(list(input_string))

  collections_array = string_collections.most_common() # 文字の種類と出現回数を出現回数順に並べられた配列に変換

  tree = HuffmanTree(input_string,collections_array) # ハフマン木をインスタンス生成
  codewords = tree.encode() # 入力文字列を符号化

  # 平均情報量(エントロピー)の計算
  entropy = -sum([ tree.occurrence_probability_array[i] * math.log2(tree.occurrence_probability_array[i]) for i in range (len(collections_array))]) # エントロピーの計算
  # 平均符号長の計算
  average_code_length = sum([ tree.occurrence_probability_array[i] * len(codewords[i]) for i in range (len(collections_array))]) # 平均符号長の計算
  # 符号語の効率の計算
  efficiency = entropy/average_code_length # 効率の計算

  # 結果の出力
  print("\n----------------------------------------------------")
  print("[入力した文字列]")
  print(input_string+"\n")
  print("[結果]")
  print("| 文字 | 文字数 | 出現確率 | ハフマン符号")

  for i in range(len(collections_array)):
    print("|  ",collections_array[i][0]," |   ",collections_array[i][1],"  | ","{:.5f}".format(tree.occurrence_probability_array[i]),"|",codewords[i])

  print("\nエントロピー H(A) :",entropy)
  print("平均符号長 L : ",average_code_length)
  print("効率 η : ",efficiency)
  print("----------------------------------------------------")
