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
    traceShrinkers = false,
    traceDatums = false,
    traceSwitches = false)

    d = deepcopy(datum)
    orig_property_value = property(d)

    numtotalretries = numretries = 0
    latest_successful_shrinker = nothing
    strace = AbstractDataShrinker[] # Save the order of successful shrinkers

    dtrace = Any[] # Save the sequence of datums
    if traceDatums
        push!(dtrace, d)
    end

    swtrace = Any[] # Save all border values we encounter, i.e. where property switches value.

    while numretries < numRetriesBeforeFail
        try
            # Get a new shrunk/mutated datum. 
            # Reuse last successful one with some probability
            if latest_successful_shrinker != nothing && rand() <= probReuseSuccessful
                newd = shrink(latest_successful_shrinker, d)
                #@show ("reuse", newd, d, latest_successful_shrinker)
            else
                latest_successful_shrinker = safe_find_shrinker_for(d)
                newd = shrink(latest_successful_shrinker, d)
                #@show ("new", newd, d, latest_successful_shrinker)
            end

            if property(newd) != orig_property_value

                # We shrunk too far/much so property switched value. We need to back up.
                numretries += 1
                latest_successful_shrinker = nothing
                if traceSwitches
                    push!(swtrace, (d, newd))
                end

            else

                lenreduction = length_reduction(newd, d)
                if lenreduction < 0.0 || newd == d # It grew or stayed the same
                    numretries += 1 # Lets try again unless too many retries
                    latest_successful_shrinker = nothing
                else
                    # The shrink was ok, property still has same value. 
                    # Reset num retries and use the new
                    # datum as the starting point for next try.
                    numtotalretries += numretries
                    numretries = 0

                    if traceDatums
                        push!(dtrace, newd)
                    end

                    d = newd

                    if traceShrinkers && (length(strace) == 0 || strace[end] != latest_successful_shrinker)
                        push!(trace, latest_successful_shrinker)
                    end
                end
            end
        catch err
            numretries += 1
        end
    end
    return d, length_reduction(d, datum), (numtotalretries + numretries), strace, dtrace, swtrace
end

shrink(datum, property::Function; options...) = shrink_until(datum, property; options...)[1]