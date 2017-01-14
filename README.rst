Declare
==========

此 Readme 由 reStructuredText extension 撰寫，為確保觀看品質，請到 https://github.com/zlsh80826/MIPS-CPU/tree/master 觀看

MIPS-CPU
==========

Risc instuctions implement

* Fully 4 stages pipeline
* Forwarding instead of memory stall
* Branch Prediction
* Synthesis with Memory
* Try Different Compile Flag that not influence correctness

Running RTL Simulation
-------------------------

到 processor_t.v 中第 12, 13 行修改 instruction, data 的 source，接著輸入 command

.. code-block:: bash
  
  make
  
即可正確跑出 RTL 的 simulation，唯需特別注意，因為 testbench 會先 line by line load instruction, data 到 Memory 中，所以驗證正確性請到
後面波形才會開始 Run

Synthesis
-----------

.. code-block:: bash

  design_vision -f syn_script.tcl

Running Synthesis Simulation
------------------------------

到 processor_t.v 中第 12, 13 行修改 instruction, data 的 source，接著輸入 command

.. code-block:: bash
  
  make syn
  
即可正確跑出 synthesis 的 simulation，唯需特別注意，因為 testbench 會先 line by line load instruction, data 到 合成的 Memory 中，所以驗證正確性請到
後面波形觀看，因為 load 完才會開始 Run

Generate Testcase
------------------

在 testcase 資料夾下面有兩個檔案 
* random_data.py
* random_instruction.py

可以產生 Random testcase 到 stdout, 如果要輸入到檔案要在自己 pipeline，並且必須使用 python2.6以上版本，ic54-58才有

Example:

.. code-block:: bash

  python2.6 random_data.py > random_data.dat
