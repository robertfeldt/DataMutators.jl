function shrink(v)
  s = find_shrinker_for_type(typeof(v))
  s == nothing && error("No shrinker found for type $(typeof(v))")
  shrink(s, v)
end
