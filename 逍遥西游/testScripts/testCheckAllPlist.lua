local getStr = function()
end
function testCheckAllPlist(parentNode)
  local checkPath = "/Users/user/work/xiyou/Proj/xiyou/res/"
  local lfs = require("lfs")
  local allFramesName = {}
  local allFiles = {}
  local function check(path, index)
    local tabStr = "|---"
    for i = 1, index do
      tabStr = tabStr .. "-"
    end
    local iter, dir_obj = lfs.dir(path)
    while true do
      local dir = iter(dir_obj)
      if dir == nil then
        break
      end
      if dir ~= "." and dir ~= ".." then
        local kDir = string.lower(dir)
        if allFiles[kDir] then
          print("error:", dir)
        else
          allFiles[kDir] = 1
        end
        local curDir = path .. dir
        local mode = lfs.attributes(curDir, "mode")
        if mode == "directory" then
          check(curDir .. "/", index + 1)
        elseif mode == "file" and string.sub(curDir, -5, -1) == "plist" then
          local d = CCDictionary:createWithContentsOfFileThreadSafe(curDir)
          local framesDict = tolua.cast(d:objectForKey("frames"), "CCDictionary")
          if framesDict then
            local keysArray = framesDict:allKeys()
            for i = 0, keysArray:count() - 1 do
              local nameString = tolua.cast(keysArray:objectAtIndex(i), "CCString")
              if nameString then
                local nameStr = nameString:getCString()
                local kNameStr = string.lower(nameStr)
                if allFramesName[kNameStr] ~= nil then
                  print("error:", nameStr)
                  local l = allFramesName[kNameStr]
                  l[#l + 1] = curDir
                else
                  allFramesName[kNameStr] = {curDir}
                end
              end
            end
          end
        end
      end
    end
  end
  check(checkPath, 0)
  dump(allFramesName, "allFramesName")
end
