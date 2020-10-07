project open C:/Users/ntjes/workspaceSigasi/lab0/modelsim/lab0
vsim work.add_pipe_tb

add list /add_pipe_tb/*
radix unsigned
run -all

configure list -signalnamewidth 1
#configure list -signalcolumnspacing 10
configure list -width 1000
configure list -fixwidth 1000
configure list -delta collapse


write list add_pipe_tb.lst
quit -sim



project open C:/Users/ntjes/workspaceSigasi/lab0/modelsim/lab0
vsim work.datapath_tb

add list /datapath_tb/*
radix unsigned
run -all

configure list -signalnamewidth 1
#configure list -signalcolumnspacing 10
configure list -width 1000
configure list -fixwidth 1000
configure list -delta collapse


write list datapath_tb.lst
quit -sim



project open C:/Users/ntjes/workspaceSigasi/lab0/modelsim/lab0
vsim work.dec2to4_tb

add list /dec2to4_tb/*
radix unsigned
run -all

configure list -signalnamewidth 1
#configure list -signalcolumnspacing 10
configure list -width 1000
configure list -fixwidth 1000
configure list -delta collapse


write list dec2to4_tb.lst
quit -sim



project open C:/Users/ntjes/workspaceSigasi/lab0/modelsim/lab0
vsim work.enc4to2_tb

add list /enc4to2_tb/*
radix unsigned
run -all

configure list -signalnamewidth 1
#configure list -signalcolumnspacing 10
configure list -width 1000
configure list -fixwidth 1000
configure list -delta collapse


write list enc4to2_tb.lst
quit -sim



project open C:/Users/ntjes/workspaceSigasi/lab0/modelsim/lab0
vsim work.mult_pipe_tb

add list /mult_pipe_tb/*
radix unsigned
run -all

configure list -signalnamewidth 1
#configure list -signalcolumnspacing 10
configure list -width 1000
configure list -fixwidth 1000
configure list -delta collapse


write list mult_pipe_tb.lst
quit -sim



