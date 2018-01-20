function safe_find_mutator_for_type(t::Type; findshrinker = false)
    s = find_mutator_for_type(t; findshrinker = findshrinker)
    if s == nothing
        styp = findshrinker ? "shrinker" : "mutator"
        error("No $styp found for type $t")
    end
    s
end

safe_find_shrinker_for_type(t::Type) = safe_find_mutator_for_type(t; findshrinker = true)
safe_find_shrinker_for(v) = safe_find_shrinker_for_type(typeof(v))
safe_find_mutator_for(v) = safe_find_mutator_for_type(typeof(v))

function apply_mutators_until_change(datum; onlyshrinkers = false)
    t = typeof(datum)
    mutators = find_mutators_for_type(t; onlyshrinkers = onlyshrinkers)
    if mutators == nothing || length(mutators) == 0
        styp = onlyshrinkers ? "shrinker" : "mutator"
        error("No $styp found for type $t")
    end
    for m in shuffle(mutators)
        newdatum = mutate(m, datum)
        if newdatum != datum
            return newdatum
        end
    end
    return datum
end

shrink(d) = apply_mutators_until_change(d; onlyshrinkers = true)
mutate(d) = apply_mutators_until_change(d; onlyshrinkers = false)

function length_reduction(newdatum, origdatum)
    ln = length(string(newdatum))
    lo = length(string(origdatum))
    (lo - ln) / lo
end

"""
Shrink datum repeatedly until no shrinker succeeds without turning property.
"""
function shrink_until(datum, property::Function; 
    numRetriesBeforeFail = 50, 
    probReuseSuccessful = 0.9,
    traceShrinkers = false)

    d = deepcopy(datum)
    numtotalretries = numretries = 0
    latest_successful_shrinker = nothing
    trace = AbstractDataShrinker[] # Save the order of successful shrinkers
    while numretries < numRetriesBeforeFail
        try
            # Reuse last successful one with some probability
            if latest_successful_shrinker != nothing && rand() <= probReuseSuccessful
                newd = shrink(latest_successful_shrinker, d)
                #@show ("reuse", newd, d, latest_successful_shrinker)
            else
                latest_successful_shrinker = safe_find_shrinker_for(d)
                newd = shrink(latest_successful_shrinker, d)
                #@show ("new", newd, d, latest_successful_shrinker)
            end
            if property(newd) == true
                # We shrunk too far/much so property no longer violated. We need to back up.
                numretries += 1
                latest_successful_shrinker = nothing
            else
                lenreduction = length_reduction(newd, d)
                if lenreduction < 0.0 || newd == d # It grew or stayed the same
                    numretries += 1 # Lets try again unless too many retries
                    latest_successful_shrinker = nothing
                else
                    # The shrink was ok, property still violated. Reset num retries and use the new
                    # datum as the starting point for next try.
                    numtotalretries += numretries
                    numretries = 0
                    d = newd
                    if traceShrinkers && (length(trace) == 0 || trace[end] != latest_successful_shrinker)
                        push!(trace, latest_successful_shrinker)
                    end
                end
            end
        catch err
            numretries += 1
        end
    end
    if traceShrinkers
        @show trace
    end
    return d, length_reduction(d, datum), (numtotalretries + numretries), trace
end

shrink(datum, property; options...) = shrink_until(datum, property; options...)[1]