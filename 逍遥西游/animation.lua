function createAnimationWithFullPath(pngPath, plistPath, jsonPath, aniName)
  CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(pngPath, plistPath, jsonPath)
  local ani = CCArmature:create(aniName)
  return ani
end
function createAnimation(path)
  local pngPath = path .. ".png"
  local plistPath = path .. ".plist"
  local jsonPath = path .. ".ExportJson"
  local aniName = string.sub(path, 1, -1)
  while true do
    local index = string.find(aniName, "/")
    if index == nil then
      break
    end
    aniName = string.sub(aniName, index + 1, -1)
  end
  return createAnimationWithFullPath(pngPath, plistPath, jsonPath, aniName)
end
local EventType_Start = 0
local EventType_Complete = 1
local EventType_LoopComplete = 2
function playAnimationWithIndex(animation, aniIndex, loop, callback)
  aniIndex = aniIndex or 0
  loop = loop or 0
  if loop < 0 then
    animation:getAnimation():playWithIndex(aniIndex, -1, -1, 1)
  elseif loop == 1 or loop == 0 then
    animation:getAnimation():playWithIndex(aniIndex, -1, -1, 0)
    animation:getAnimation():setMovementEventCallFunc(function(aniObj, eventType, movementId)
      if eventType == EventType_Complete and callback then
        callback(aniObj)
      end
    end)
  else
    animation:getAnimation():playWithIndex(aniIndex, -1, -1, 0)
    animation:getAnimation():setMovementEventCallFunc(function(aniObj, eventType, movementId)
      if eventType == EventType_Complete then
        playAnimationWithIndex(animation, aniIndex, loop - 1, callback)
      end
    end)
  end
end
function playAnimationWithName(animation, actName, loop, callback)
  assert(type(actName) == "string", "playAnimationWithName invalid params: actName is not type string")
  loop = loop or 0
  if loop < 0 then
    animation:getAnimation():play(actName, -1, -1, 1)
  elseif loop == 1 or loop == 0 then
    animation:getAnimation():play(actName, -1, -1, 0)
    animation:getAnimation():setMovementEventCallFunc(function(aniObj, eventType, movementId)
      if eventType == EventType_Complete and callback then
        callback(aniObj)
      end
    end)
  else
    animation:getAnimation():play(actName, -1, -1, 0)
    animation:getAnimation():setMovementEventCallFunc(function(aniObj, eventType, movementId)
      if eventType == EventType_Complete then
        playAnimationWithName(animation, actName, loop - 1, callback)
      end
    end)
  end
end
