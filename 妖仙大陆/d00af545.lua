

























local remove = table.remove

return setmetatable({
  flush = function(t)
    for i=#t,1,-1 do t[i] = nil end
  end,
  get = function(t)
    return t[#t]
  end
}, {
  __call = function(t, zone)
    if zone then
      t[#t+1] = zone
    else
      return (assert(remove(t), "empty zone stack"))
    end
  end
})
