using DataMutators: shrink_until

function safeparsedt(s::String)
    try
        return DateTime(s,"yyyy-mm-dd")
    catch err
        return err
    end
end

# We want to find pairs of datums where one can be parsed while a mutated one cannot, i.e.
# we want to find "switches" (from true to false) in the following property:
canparsedt(s::String) = typeof(safeparsedt(s)) == DateTime

valid_starting_point = "2018-03-15"

datum, lenreduction, count, str, dtr, swtr = shrink_until(valid_starting_point, canparsedt; traceSwitches = true, numRetriesBeforeFail = 500)

# The swtr result has the "switch trace" which is array of triples (d1, d2, mutations)
# where d1 is datum before applying mutations to get d2. And d1 and d2 has different
# values for the property being searched.
@show swtr

# Note that the current search is not very intelligent so the triples found are going
# to be very constrained by the initial mutations that does not lead to any switches.
# This is probably why we don't see switches on the borders we know are there such as
# 2018-03-32 etc. We need to use DataMutators better with search to find these, other 
# borders.