using ProgressMeter

function main()
    folder = "/export/c12/wwu/languagenet/data"

    counts = Dict{String,Int}()

    collapse = Dict(
        "1 sg" => "I",
        "1 pl" => "we",
        "1 pl inc" => "we",
        "we₁" => "we",
        "2 sg" => "you",
        "2 pl" => "you all",
        "3 sg" => "he",
        "3 pl" => "them",
    )

    @showprogress for fn in readdir(folder)
        if occursin("-eng", fn)
            lang = fn[1:3]

            has_translation = Set{String}()
            for line in eachline("$folder/$fn")
                arr = split(line, '\t')
                eng = get(collapse, arr[6], arr[6])

                if eng ∉ keys(counts)
                    counts[eng] = 0
                end
                if eng ∉ has_translation
                    push!(has_translation, eng)
                    counts[eng] += 1
                end
            end
        end
    end

    for (word, count) in sort(collect(counts), by = x->(-x[2], x[1]))
        println(word, '\t', count)
    end
end

main()
# function read_count_list(fn)
#     map(eachline(fn)) do line
#         word, count = split(line, '\t')
#         count = parse(Int, count)
#         word => count
#     end |> Dict
# end

# function collapse_counts()
#     counts = read_count_list(ARGS[1])
#     collapse = Dict(
#         "I" => "1 sg",
#         "you" => "2 sg",
#         "thou" => "2 sg",
#         "he" => "3 sg",
#         "she" => "3 sg",
#         "it" => "3 sg"
#     )
#     for word in keys(counts)
#         if word in keys(collapse)
#             counts[collapse[word]] += counts[word]
#             delete!(counts, word)
#         end
#     end

#     for (word, count) in sort(collect(counts), by=x -> (-x[2], x[1]))
#         println(word, '\t', count)
#     end
# end

# collapse_counts()