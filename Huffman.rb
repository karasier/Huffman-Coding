# coding: utf-8
# Ruby 1.9以降なら正常に動作します(hashの順序による問題)
require 'active_support'

# ハフマン木のノード(葉または節点)を示すクラス
class Node
  def initialize(char = nil,occurrence_probability = nil,up = nil,down = nil)
    @char = char # ノードの持つ文字
    @occurrence_probability = occurrence_probability # ノードの出現確率
    @up = up
    @down = down
  end

  attr_accessor :char,:occurrence_probability,:up,:down
end

# ハフマン木を示すクラス
class HuffmanTree
  def initialize(input_string,string_array)
    @encode_dict = ActiveSupport::OrderedHash.new("") # 符号語を保持するハッシュ
    @input_string = input_string # 入力された文字列
    @string_array = string_array # 文字と出現回数を保持する配列
  end

  # 出現確率を計算するメソッド
  def compute_occurrence_probability
    @occurrence_probability_array = @string_array.map{ |item,times| times.to_f/@input_string.size.to_f}
  end

  # 符号化するメソッド
  def encode
    nodes = []
    temp = []

    # 出現確率を計算
    compute_occurrence_probability

    # 葉の生成
    @string_array.size.times do |i|
      nodes.push(Node.new(@string_array[i][0],@occurrence_probability_array[i]))
    end

    # 葉の数が1の場合0を割り当てて終了
    if nodes.size == 1 then
      @encode_dict[nodes[0].char] = "0"
      return @encode_dict
    end

    # 葉の数が1になるまで繰り返し
    while nodes.size > 1 do
      # 出現確率の小さい方から2つ取り出して、節点を生成
      2.times do |i|
        element = nodes[-1]
        temp.push(element)
        nodes.delete(element)
      end

      # 節点の生成
      new_node = Node.new(nil,temp[0].occurrence_probability + temp[1].occurrence_probability,temp[1],temp[0])
      nodes.append(new_node)
      temp = []
    end

    # 符号語の割り当て
    allocate_codewords(nodes[0],"")

    return @encode_dict.to_a.transpose[1]
  end

  # 符号語を割り当てるメソッド
  def allocate_codewords(node,codeword)

    # nodeがクラスNodeのオブジェクトでないときreturn
    unless node.instance_of?(Node) then
      return
    end

    # nodeが葉の場合(charがnilでない場合)符号語を割り当ててreturn
    if node.char then
      @encode_dict[node.char] = codeword
      return
    end

    # 再帰呼び出し
    allocate_codewords(node.up,codeword+"0")
    allocate_codewords(node.down,codeword+"1")
  end

  attr_reader :occurrence_probability_array
end

if __FILE__ == $0
  puts "[ハフマン符号の構成プログラム]"
  puts "\n<<入力する文字列は次の条件を満たしてください。>>"
  puts "1.使用する文字が小文字のアルファベットのみ"
  puts "2.文字列の長さが40文字以下"
  puts "3.文字の種類が10種類以下"

  input_string = ""

  while input_string == "" do
    print "\n符号化したい文字列を入力\n>>"
    input_string = gets.chomp
  end

  string_dict = input_string.split("").each_with_object(Hash.new(0)){ |char,hash| hash[char] += 1 } # 文字の出現回数をカウント
  string_array = string_dict.sort_by{|key,value| [-value,key]} # 文字の出現回数を降順で並び替えて配列に変換

  # 入力文字列がパターンにマッチしない
  # 入力文字列の長さが40文字より大きい
  # 文字の種類が10より大きい
  # 上記のいずれかの条件を満たしたら再入力
  while input_string =~ /[^a-z]+/ or input_string.size > 40 or string_array.size > 10 do
    if input_string =~ /[^a-z]+/ then
      puts "[入力可能文字はアルファベットの小文字のみです。]"
    elsif input_string.size > 40 then
      puts "[文字数が40文字を超えています。]"
    else
      puts "[文字の種類が10種類を超えています。]"
    end

    print "\n再入力\n>>"
    input_string = gets.chomp
    string_dict = input_string.split("").each_with_object(Hash.new(0)){ |char,hash| hash[char] += 1 } # 文字の出現回数をカウント
    string_array = string_dict.sort_by{|key,value| [-value,key]} # 文字の出現回数を降順で並び替えて配列に変換
  end

  # ハフマン木のインスタンス生成
  tree = HuffmanTree.new(input_string,string_array)

  # 符号化
  codewords = tree.encode()

  # 平均情報量(エントロピー)の計算
  entropy = - tree.occurrence_probability_array.each_with_object([]){ |occurrence_probability,array| array.append(occurrence_probability * Math.log2(occurrence_probability)) }.sum
  # 平均符号長の計算
  average_code_length = tree.occurrence_probability_array.each_with_object([]).with_index{ |(occurrence_probability,array),i| array.append(occurrence_probability * codewords[i].size) }.sum
  # 符号語の効率の計算
  efficiency = entropy/average_code_length

  # 結果の出力
  puts "\n----------------------------------------------------"
  puts "[入力した文字列]"
  puts input_string
  puts "\n[結果]"
  puts "| 文字 | 文字数 |  出現確率  | ハフマン符号"

  string_array.size.times do |i|
    puts "|  #{string_array[i][0]}   |    #{string_array[i][1]}   |  #{sprintf("%.6f",tree.occurrence_probability_array[i])}  | #{codewords[i]}"
  end

  puts "\nエントロピー H(A) : #{entropy}"
  puts "平均符号長 L : #{average_code_length}"
  puts "効率 η : #{efficiency}"
  puts "----------------------------------------------------"
end
