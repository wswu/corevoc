using Formatting

function remove_names!(dict::AbstractDict)
    for word in keys(dict)
        if isuppercase(word[1]) && lowercase(word) ∉ keys(dict)
            delete!(dict, word)
        end
    end
end

function readdict(fn::String)
    return map(readlines(fn)) do line
        arr = split(line, '\t')
        arr[1] => parse(Int, arr[2])
    end |> Dict
end

"""
    readcountlist(fn; mincount = 0, entries = -1, deletenames = false) -> Dict{String, Int}

Reads a tab-delimited file, the first column is a word, the second column is a count.

Optional arguments:
- `mincount`: remove entries with less than this number of languages
- `entries`: maximum number of entries to return
- `deletenames`: whether or not to remove names from list
""" 
function readcountlist(fn::String; mincount = 0, entries = -1, deletenames = false)::Dict{String,Int}
    d = Dict()
    for line in eachline(fn)
        arr = split(line, '\t')
        word = arr[1]
        count = parse(Int, arr[2])
        d[word] = count
    end

    if deletenames
        remove_names!(d)
    end

    if mincount > 0
        for k in keys(d)
            if d[k] < mincount
                delete!(d, k)
            end
        end
    end

    if entries > -1
        sorted = sort(collect(d), by = x->-x[2])
        d = Dict(sorted[1:min(entries, length(d))])
    end

    return d
end

function readwordlist(fn::String)
    return map(readlines(fn)) do line
        strip.(split(line, '/'))
    end
end

function read_flat_wordlist(fn::String)
    words = []
    for line in eachline(fn)
        for word in split(line, '/')
            push!(words, strip(word))
        end
    end
    return words
end

function listdiff(core, other)
    in_core = []
    in_other = []
    in_both = []
    for coreword in core
        has = false
        for words in other  # [[word], [word, word], ...]
            if coreword ∈ words
                has = true
                push!(in_both, coreword)
                break
            end
        end
        if !has
            push!(in_core, coreword)
        end
    end

    for words in other
        has = false
        for word in words
            if word ∈ core
                has = true
                break
            end
        end
        if !has
            push!(in_other, replace(string(words), "SubString{String}" => ""))
        end
    end
    return (in_core, in_other, in_both)
end

function wordlist_coverage(core, wordlist)
    count = 0
    space = 0
    for words in wordlist  # [[word], [word, word], ...]
        has = false
        for word in words
            if word in core
                count += 1
                has = true
                break
            end
        end
    end
    return count
end

function list_coverage()
    core = map(readlines("lists/core")[1:3000]) do line
        split(line, '\t')[1]
    end

    w2i = Dict(e => i for (i, e) in enumerate(core))

    lists = [
        "Swadesh" => "lists/swadesh207",
        "Dogolpolsky" => "lists/dogolpolsky",
        "Leipzig-Jakarta" => "lists/leipzig-jakarta",
        "Ogden" => "lists/ogden-basic",
        "Dale-Chall" => "lists/dale-chall",
        "Oxford 3000" => "lists/oxford3000",
        "NGSL" => "lists/ngsl",
        "Chinese" => "lists/cmn",
        "Russian" => "lists/rus"
    ]

    coverage_table = []
    for (name, path) in lists
        other = readwordlist(path)
        count = wordlist_coverage(core, other)
        
        perc = round(Int, count * 100 / length(other))
        push!(coverage_table, (name, "$count/$(length(other))", perc))
        
        write_analysis("analysis/$name", name, w2i, core, other)
    end

    print_latex_table(coverage_table)

    # concat all lists and analyze again
    all_other = []
    for (name, fn) in lists
        list = readwordlist(fn)
        push!(all_other, list...)
    end

    write_analysis("analysis/all_other", "all_other", w2i, core, all_other)
end

function write_analysis(fn, name, w2i, core, other)
    in_core, in_other = listdiff(core, other)
    open("analysis/$name", "w") do fout
        in_core, in_other, in_both = listdiff(core, other)

        println(fout, "in both: ", length(in_both))
        core_words = sort(in_both, by = x->w2i[x])
        core_words = map(core_words) do w
            "$w $(w2i[w])"
        end
        println(fout, join(core_words, ", "))
        println(fout)

        println(fout, "in core but not in $name: ", length(in_core))
        core_words = sort(in_core, by = x->w2i[x])
        core_words = map(core_words) do w
            "$w $(w2i[w])"
        end
        println(fout, join(core_words, ", "))
        println(fout)
        
        println(fout, "in $name but not in core: ", length(in_other))
        println(fout, join(sort(in_other), ", "))
        println(fout)

        capitalized = filter(x->isuppercase(x[1]), in_core)
        println(fout, "capitalized: ", length(capitalized))
        println(fout, join(sort(capitalized), ", "))
        println(fout)

        has_space = filter(x->occursin(' ', x), in_core)
        println(fout, "has space: ", length(has_space))
        println(fout, join(sort(has_space), ", "))
    end
end

function print_latex_table(arr)
    num_columns = length(arr[1])
    column_widths = [
        maximum(length(string(arr[r][c])) for r in 1:length(arr))
        for c in 1:num_columns]
    
    for row in arr
        widened = [fmt("$(column_widths[c])s", row[c]) for c in eachindex(row)]
        println(join(widened, " & "), " \\\\")
    end
end

function typetoken(dict)
    return (length(dict), sum(values(dict)))
end

function typecoverage(core, other::AbstractArray)
    c = 0
    other = Set(other)
    for word in core
        if word ∈ other
            c += 1
        end
    end
    return c / length(other)
end

function tokencoverage(core, other::AbstractDict)
    c = 0
    for word in core
        if word ∈ keys(other)
            c += other[word]
        end
    end
    return c / sum(values(other))
end

function corpus_coverage()
    corpora = [
        "Bible" => readcountlist("corpora/bible", mincount = 2, deletenames = true),
        "UDHR" => readcountlist("corpora/udhr", mincount = 2),
        "BNC" => readcountlist("corpora/bnc.clean", entries = 10000, deletenames = true),
        "ANC" => readcountlist("corpora/american-national-corpus", entries = 10000, deletenames = true),
        "GNG" => readcountlist("corpora/gng.clean", entries = 10000, deletenames = true)
    ]

    println("corpus\ttypes\ttokens")
    for (corpus, dict) in corpora
        types, tokens = typetoken(dict)
        println(corpus, '\t', types, '\t', tokens)
    end
    println()

    corelists = [
        ["core100" => keys(readcountlist("lists/core", entries = 100)),
        "swadesh" => read_flat_wordlist("lists/swadesh")],
        ["core8481" => keys(readcountlist("lists/core", entries = 8481)),
        "ngsl" => read_flat_wordlist("lists/ngsl")],
        ["core2995" => keys(readcountlist("lists/core", entries = 2995)),
        "oxford" => read_flat_wordlist("lists/oxford3000")]
    ]

    for (list1, list2) in corelists
        println(list1[1], ',', list2[1])
        for (corpus, dict) in corpora
            println(
                length(intersect(list1[2], keys(dict))), ' ',
                length(intersect(list2[2], keys(dict))), ' ',
                corpus, " & ",
                typecoverage(list1[2], collect(keys(dict))) |> pretty, " & ",
                tokencoverage(list1[2], dict) |> pretty, " & ",
                typecoverage(list2[2], collect(keys(dict))) |> pretty, " & ",
                tokencoverage(list2[2], dict) |> pretty, " \\\\")
        end
    end
end

pretty(x) = fmt(".3f", x)

function main()
    corpus_coverage()
    
    println()
    if !ispath("analysis")
        mkpath("analysis")
    end

    list_coverage()
end

main()