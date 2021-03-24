# struct Char
#   private TO_S_CACHE = {} of self => String

#   # x3.64-x4.16 faster than the default implementation.
#   def to_s
#     TO_S_CACHE[self] ||= previous_def
#   end
# end
