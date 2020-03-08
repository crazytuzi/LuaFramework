local Lplus = require("Lplus")
local GameProfiler = Lplus.Class("GameProfiler")
local def = GameProfiler.define
local s_startTime = -1
local s_stopTime = -1
local s_started = false
def.static("string").dump = function(name)
  local t = s_stopTime - s_startTime
  if s_started then
    t = os.time() - s_startTime
  end
  if t <= 0 then
    warn("nothing to dump")
    return
  end
  local stat = profiler.stat()
  warn("profile stat:", stat)
  if stat ~= nil then
    local filename = GameUtil.GetAssetsPath() .. "/" .. name .. ".profile.csv"
    warn("profile file:", filename)
    local f = io.open(filename, "w")
    local title = string.format("id,call count,stat count,time(millisecond),t%%(stat time:%f)\n", t)
    f:write(title)
    for k, v in ipairs(stat) do
      local id = string.gsub(v[1], ",", " ")
      local s = string.format("%s,%d,%d,%f,%f\n", id, v[2], v[4], v[3], v[3] / t / 10)
      f:write(s)
    end
    f:close()
  end
end
def.static("number", "number", "number").start = function(call_time_threshold, high_state_threshold, stat_overhead_factor)
  if s_started then
    Debug.LogError("has started")
    return
  end
  s_startTime = os.time()
  s_started = true
  GameUtil.LuaProfilerStart()
  profiler.start(call_time_threshold, high_state_threshold, stat_overhead_factor)
end
def.static().stop = function()
  if not s_started then
    return
  end
  s_started = false
  s_stopTime = os.time()
  profiler.stop()
  GameUtil.LuaProfilerStop()
end
GameProfiler.Commit()
return GameProfiler
