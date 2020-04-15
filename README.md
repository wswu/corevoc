# Multilingual Dictionary Based Construction of Core Vocabulary

This is the code for our paper *Multilingual Dictionary Based Construction of Core Vocabulary*.

- `lists/core` is the core list
- `computelist.jl` computes the list
- `computecoverage.jl` runs analyses
- `process_anc.jl` and `process_gng.sh` generates wordlists from various corpora
- `train.sh` trains a neural MT model to do cognate prediction

If you found this code useful, please consider citing

```
@inproceedings{wu2020corevoc,
  title = "Multilingual Dictionary Based Construction of Core Vocabulary",
  author = "Wu, Winston and Yarowsky, David",
  booktitle = "Proceedings of the Twelfth International Conference on Language Resources and Evaluation (LREC 2020)",
  address = "Marseilles, France",
  year = "2020",
}
```