onmt_preprocess -train_src data/train.src -train_tgt data/train.tgt -valid_src data/dev.src -valid_tgt data/dev.tgt -save_data data/poly

CUDA_VISIBLE_DEVICES=`free-gpu` onmt_train -data data/poly -save_model models/poly --word_vec_size 500 --gpu_ranks 0 --log_file train.log --optim adam --learning_rate 0.001 --train_steps 200000 --early_stopping 3

onmt_translate -model models/poly_step_10000.pt -src data/test.src -output pred.txt -replace_unk -n_best 10 -verbose -log_file translate.log