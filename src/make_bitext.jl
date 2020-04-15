using Combinatorics
using Random

function read_cognates(folder)
    data = []
    for fn in readdir(folder)
        for line in eachline("$folder/$fn")
            arr = split(line, '\t')
            eng = arr[1]
            words = map(arr[2:end]) do x
                word, lang = split(x, '/')
                (word = word, lang = lang)
            end
            for combo in combinations(words, 2)
                push!(data, (combo[1], combo[2]))
            end
        end
    end
    return data
end

splitchars(s) = join(replace(s, ' ' => '_'), ' ')

bitextpair(word1, word2) = 
    ("$(word1.lang) $(splitchars(word1.word)) $(word2.lang)",
    splitchars(word2.word))

function write_bitext(fn, data)
    fsrc = open("$fn.src", "w")
    ftgt = open("$fn.tgt", "w")

    for (word1, word2) in data
        src, tgt = bitextpair(word1, word2)
        println(fsrc, src)
        println(ftgt, tgt)

        src, tgt = bitextpair(word2, word1)
        println(fsrc, src)
        println(ftgt, tgt)
    end

    close(fsrc)
    close(ftgt)
end

function main()
    Random.seed!(12345)
    data = read_cognates(ARGS[1]) |> shuffle

    println(sizeof(data), ' ', length(data))

    s1 = round(Int, length(data) * 0.8)
    s2 = round(Int, length(data) * 0.9)

    train = data[1:s1]
    dev = data[s1 + 1:s2]
    test = data[s2 + 1:end]

    write_bitext("bitext/train", train)
    write_bitext("bitext/dev", dev)
    write_bitext("bitext/test", test)
end

main()
