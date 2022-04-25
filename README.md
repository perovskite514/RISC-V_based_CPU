# RISC-V_based_CPU
  2021年度 CPU実験3班コア係

# ISA
  RISC-Vを基にUARTに関する独自の命令を加えている。opcodeは4bitに削減しており、
  レジスタは整数・浮動小数点数共用の汎用レジスタを64個扱えるようにしている。

# Core
  シンプルな5段のパイプライン構成でブートローダーを用いてプログラムをロードする。
  
  回路図は以下のようになっている。
![スクリーンショット (945)](https://user-images.githubusercontent.com/64414574/165100859-d173bc50-776a-4159-93af-fe623d9fbb1e.png)

