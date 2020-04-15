counts = Dict{String,Int}()
for line in eachline(ARGS[1])
    arr = split(line, '\t')
    word = arr[1]
    count = parse(Int, arr[2])

    if occursin("_", word)
        continue
    end

    word = lowercase(word)

    if word ∉ keys(counts)
        counts[word] = 0
    end
    counts[word] += count
end

for (word, count) in sort(collect(counts), by = x->-x[2])
    println(word, '\t', count)
end

# usage: gng-clean.jl counts.100000 > gng.clean