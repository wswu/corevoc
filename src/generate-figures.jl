using CSV
using Gadfly
using Cairo

th = Theme(default_color="black", panel_stroke="black", plot_padding=[2mm])
Gadfly.push_theme(th)

function coverage_plots()
    df = CSV.read("../lists/core")
    plot(x=1:10000, y=df.count[1:10000], Geom.line,
        Guide.xticks(ticks=[0:1000:10000;]),
        Guide.yticks(ticks=[0:400:2000;]),
        Guide.xlabel("Rank of Word"),
        Guide.ylabel("# of dictionaries")
    ) |> PDF("figures/coverage.pdf", 5inch, 3inch)

    plot(x=df.word[1:30], y=df.count[1:30], Geom.line,
        Guide.yticks(ticks=[1675:25:1825;]),
        Guide.xlabel("Top 30 Words"),
        Guide.ylabel("# of dictionaries")
    ) |> PDF("figures/top30.pdf", 5inch, 3inch)
end

function three_columns()
    words = map(eachline("../lists/core")) do line
        split(line, '\t')[1]
    end

    fout = open("figures/thelist.tex", "w")
    for i in 1:3:148
        println(fout, "$i. $(words[i]) & $(i+1). $(words[i+1]) & $(i+2). $(words[i+2]) \\\\")
    end
    close(fout)
end

coverage_plots()
three_columns()