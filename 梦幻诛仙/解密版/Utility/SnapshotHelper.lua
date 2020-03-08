local Lplus = require("Lplus")
local snapshot = require("snapshot")
local SnapshotHelper = Lplus.Class()
do
  local def = SnapshotHelper.define
  local l_lastSnapshot
  local l_lastMemoryUsage = 0
  local currentMemoryUsage = function()
    return collectgarbage("count") * 1024
  end
  def.static().start = function()
    l_lastSnapshot = snapshot.snapshot()
    collectgarbage("collect")
    l_lastMemoryUsage = currentMemoryUsage()
  end
  def.static().diff = function()
    SnapshotHelper.diffInner(nil)
  end
  def.static().lessdiff = function()
    SnapshotHelper.diffInner(function(v)
      return not v:find("^Lplus.lua:")
    end)
  end
  def.static().leastdiff = function()
    SnapshotHelper.diffInner(function(v)
      return not not v:find("^%w+[\\/][%w+\\/%.]+:%d+")
    end)
  end
  def.static().all = function()
    l_lastSnapshot = nil
    l_lastMemoryUsage = 0
    collectgarbage("collect")
    local newMemoryUsage = currentMemoryUsage()
    SnapshotHelper.processSnapshot({}, 0, snapshot.snapshot(), newMemoryUsage, nil)
    collectgarbage("collect")
  end
  def.static("number", "string").bigtable = function(thredshold, subfix)
    local strBuilder = {}
    local strLen = 0
    local lenOver = false
    local infolist = snapshot.bigtable(thredshold)
    local desclist = {}
    for _, info in ipairs(infolist) do
      desclist[#desclist + 1] = ("%s: %s"):format(snapshot.tokeystring(info), tostring(info))
    end
    table.sort(desclist)
    local headerDesc = ("Count: %d\n"):format(#desclist)
    strBuilder[#strBuilder + 1] = headerDesc
    local fileName = ("bigtable%s.txt"):format(subfix)
    local fout = io.open(GameUtil.GetAssetsPath() .. "/" .. fileName, "w")
    fout:write(headerDesc)
    fout:write("----------start----------\n")
    for _, desc in ipairs(desclist) do
      local str = ("%s\n"):format(desc)
      fout:write(str)
      if strLen <= 4096 then
        strLen = strLen + #str
        strBuilder[#strBuilder + 1] = str
      else
        lenOver = true
      end
    end
    fout:write("----------end----------")
    fout:close()
    if lenOver then
      strBuilder[#strBuilder + 1] = ("... (see %s for full list)"):format(fileName)
    end
    warn(table.concat(strBuilder))
  end
  def.static("function").diffInner = function(pred)
    if l_lastSnapshot then
      collectgarbage("collect")
      local newMemoryUsage = currentMemoryUsage()
      SnapshotHelper.processSnapshot(l_lastSnapshot, l_lastMemoryUsage, snapshot.snapshot(), newMemoryUsage, pred)
    else
      warn("has not yet start")
    end
  end
  def.static("table", "number", "table", "number", "function").processSnapshot = function(oldSnapshot, oldMemoryUsage, newSnapshot, newMemoryUsage, pred)
    local strBuilder = {}
    local strLen = 0
    local lenOver = false
    local memoryDesc = ("Memory usage: %f M => %f M\n"):format(oldMemoryUsage / 1000000, newMemoryUsage / 1000000)
    strBuilder[#strBuilder + 1] = memoryDesc
    local fout = io.open(GameUtil.GetAssetsPath() .. "/snapshot.txt", "w")
    fout:write(memoryDesc)
    fout:write("----------start----------\n")
    for k, v in pairs(newSnapshot) do
      if oldSnapshot[k] == nil and (not pred or pred(tostring(v))) then
        local str = ("%s = %s\n"):format(tostring(k), tostring(v))
        fout:write(str)
        if strLen <= 4096 then
          strLen = strLen + #str
          strBuilder[#strBuilder + 1] = str
        else
          lenOver = true
        end
      end
    end
    fout:write("----------end----------")
    fout:close()
    if lenOver then
      strBuilder[#strBuilder + 1] = "... (see snapshot.txt for full list)"
    end
    warn(table.concat(strBuilder))
  end
end
return SnapshotHelper.Commit()
