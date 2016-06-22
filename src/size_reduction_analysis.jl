"""
    mean_size_reduction(s::AbstractDataShrinker, datagen::Generator, numsamples::Int, sizeFn)

Take `numsamples` samples of data from the `datagen` generator, apply the shrinker and calculate
the average percentage of bytes the data is shrunk.
"""
function size_reductions(s::AbstractDataShrinker, datagen, 
    numsamples::Int = 1000, sizeFn = (d) -> length(string(d)))

    reductions = Array(Float64, numsamples)
    for i in 1:numsamples
        datum = DataGenerators.choose(datagen)
        origsize = length(string(datum))
        shrunkdatum = shrink(s, datum)
        shrunksize = length(string(shrunkdatum))
        reductions[i] = (origsize - shrunksize) / origsize
    end
    reductions
end