function accumulate_counts(filename)
    counts = Dict{AbstractString, Int}()
    for line in eachline(filename)
        arr = split(strip(line), "\t")
        word = arr[1]
        count = parse(Int, arr[3])
        if word ∉ keys(counts)
            counts[word] = 0
        end
        counts[word] += count
    end
    return counts
end

function main()
    in_file = ARGS[1]
    out_file = ARGS[2]

    counts = accumulate_counts(in_file)
    open(out_file, "w") do fout
        for (word, count) in collect(counts)
            println(fout, word, '\t', count)
        end
    end
end

main()

# usage: gng-accumulate.jl googlebooks-eng-all-1gram-20120701-a out/a