DataShrinkers.jl
================

In automated testing, once you have found a datum that produces a test failure you want to shrink it to its simplest possible form that still shows the failure. This way there is less for the human to look at and analyse in order to understand the cause of the failure. This Julia package implements external shrinking, i.e. it can shrink data without access to information about how the data was generated. This can be viewed as a sort of external shrinking, in contrast to internal shrinkers that utilize information from the generation process.

Although external shrinking typically requires you to write new code for the specific types you want to shrink the design of this library makes this almost trivially easy to do. The reason is that you can reuse existing shrinkers for the basic Julia types.

# Example

```
# Lets create a reverse function that fails when length of reversed list is less than 5 or contains other lists.
function buggyreverse(l)
  if length(l) < 5 || any(e->isa(e, Array), l)
    l
  else
    reverse(l)
  end
end

# Property being tested
prop(l) = buggyreverse(buggyreverse(l)) == l

# Lets say our auto testing tool has found the following datum that violates the spec
fd = [1,2,3,4]

# We can now shrink it like so
using ShrinkData
smaller = shrink(fd, prop)
```