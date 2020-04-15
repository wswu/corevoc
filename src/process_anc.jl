using DataStructures
using StringEncodings
using PyCall
using ProgressMeter
using Unicode

spacy = pyimport("spacy")
nlp = spacy.load("en_core_web_sm", tagger=false, parser=false, ner=false, textcat=false)

# American National Corpus: LDC2005T35

function main()
    freq = Dict{String, Int}()
    prog = ProgressUnknown("files processed")
    filecount = 0

    done = false

    for i in ["1", "2"]
        for (rootpath, dirs, files) in walkdir("/export/corpora/LDC/LDC2005T35/data/written_$i")
            for fn in files
                if endswith(fn, ".txt")
                    path = "$rootpath/$fn"

                    text = read(path, String, enc"UTF-16")
                    for w in nlp(text)
                        word = w.text
                        if word ∉ keys(freq)
                            freq[word] = 0
                        end
                        freq[word] += 1
                    end

                    filecount += 1
                    ProgressMeter.update!(prog, filecount)
                end
            end
        end
    end

    for (word, count) in sort(collect(freq), by=x -> -x[2])
        println(word, '\t', count)
    end
end

main()