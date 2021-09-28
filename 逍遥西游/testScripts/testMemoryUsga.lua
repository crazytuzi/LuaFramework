local allMem
function recordRequereMemoryUsage()
  allMem = {}
  local getCurMem = function()
    collectgarbage("collect")
    return collectgarbage("count")
  end
  local req_func = require
  function require(filepath)
    local mem = getCurMem()
    local ret = req_func(filepath)
    mem = getCurMem() - mem
    if mem > 100 then
      print("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t [require mem]", filepath, mem)
    else
      print("[require mem]", filepath, mem)
    end
    allMem[#allMem + 1] = {filepath, mem}
    return ret
  end
end
function printRequereMemoryUsage()
  if allMem then
    table.sort(allMem, function(obj1, obj2)
      return obj1[2] > obj2[2]
    end)
    print("--------->> 排序后")
    for i, v in ipairs(allMem) do
      print("\t\t ", v[1], v[2])
    end
  end
end
function testUpdateSucceed()
  release_flag = _Config_Release
  CCDirector:sharedDirector():purgeCachedData()
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFrames()
  CCTextureCache:sharedTextureCache():removeAllTextures()
  CCSpriteFrameCache:purgeSharedSpriteFrameCache()
  CCAnimationCache:purgeSharedAnimationCache()
  CCTextureCache:purgeSharedTextureCache()
  local resetLuaFileUnload = function(zipPath)
    local fileListArray = SYCommon:getFilesListFromZip(zipPath)
    if fileListArray then
      for i = 0, fileListArray:count() - 1 do
        local strObj = tolua.cast(fileListArray:objectAtIndex(i), "CCString")
        if strObj then
          local fileName = strObj:getCString()
          package.preload[fileName] = nil
          package.loaded[fileName] = nil
          print("****************** file reload:", fileName)
        end
      end
    else
      print("获取文件列表失败:", zipPath)
    end
  end
  resetLuaFileUnload("res/launcher.zip")
  resetLuaFileUnload("res/script.zip")
  SYCommon:LuaLoadChunksFromZIP("res/launcher.zip", nil)
  SYCommon:LuaLoadChunksFromZIP("res/script.zip", nil)
  _Config_Release = release_flag
  if _Config_Release then
    require("launcher")
  else
    require("main")
  end
end
