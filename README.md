DataMutators.jl
===============

In automated testing, once you have found a datum that produces a test failure you want to shrink it to its simplest possible form that still shows the failure. This way there is less for the human to look at and analyse in order to understand the cause of the failure. This Julia package implements external shrinking, i.e. it can shrink data without access to information about how the data was generated. This is in contrast to internal shrinkers that utilize information from the generation process.

Although external shrinking typically requires you to write new code for the specific types you want to shrink the design of this library makes this almost trivially easy to do. The reason is that you can reuse existing shrinkers for the basic Julia types and we leverage Julia's powerful type system.

This package is currently in an initial state and will change in the coming weeks, leading up to an initial release in the summer of 2016. It was previously called simply DataShrinkers.jl but since successful shrinking may need to do intermediate mutations to also grow the data being modified we renamed it using the more general term "mutation" (i.e. any changes, including both shrinking and growing).

# Example

```
# Lets create a reverse function that fails when length of reversed list is less than 5.
buggyreverse(l) = (length(l) < 5) ? l : reverse(l)

# Property being tested
prop_last_is_first(l) = last(l) == first(buggyreverse(l))

# Lets say our auto testing tool has found the following datum that violates the spec
fd = [1,2,3,4]

# We can now shrink it like so
using DataMutators
smaller = shrink(fd, prop_last_is_first)

# Let's ensure they both have the same value for the property (i.e. false, a violation)
ensure_prop(prop, v1, v2) = (prop(v1) == false) && (prop(v1) == prop(v2))
ensure_prop(prop_last_is_first, fd, smaller)

# But this works also for other and more complex datums that violates the spec:
fd2 = ["longer", "strings", "than", "needed"]
smaller2 = shrink(fd2, prop_last_is_first)
ensure_prop(prop_last_is_first, fd2, smaller2)

fd3 = [0, 1.1, "than", "needed", [1, 2, "ab"]]
smaller3 = shrink(fd3, prop_last_is_first)
ensure_prop(prop_last_is_first, fd3, smaller3)
```