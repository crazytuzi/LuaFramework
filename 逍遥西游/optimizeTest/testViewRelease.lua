local g_Views = {}
local getName = function(obj)
  if obj then
    return obj.__cname
  end
end
function ViewRelease_CreateView(obj)
  local name = getName(obj)
  if name then
    if g_Views[name] == nil then
      g_Views[name] = 1
    else
      g_Views[name] = g_Views[name] + 1
    end
  end
end
function ViewRelease_ReleaseView(obj)
  local name = getName(obj)
  if name and g_Views[name] ~= nil then
    g_Views[name] = g_Views[name] - 1
    if g_Views[name] <= 0 then
      g_Views[name] = nil
    end
  end
end
function ViewRelease_Print()
  print("================================================")
  print("#ViewRelease_Print  ")
  for k, v in pairs(g_Views) do
    print(string.format("# [%s] = %s", k, tostring(v)))
  end
  print("================================================")
end
