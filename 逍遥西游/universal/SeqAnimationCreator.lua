local sharedFileUtils = CCFileUtils:sharedFileUtils()
g_AniRefCountDict = {}
local g_AniConfigPathPool = {}
local function ReleaseAniConfigPathOfPool()
  g_AniConfigPathPool = {}
end
local g_AniPool = {}
local function ReleaseAniPool()
  local cnt = 0
  for _, aniList in pairs(g_AniPool) do
    for _, ani in pairs(aniList) do
      cnt = cnt + 1
      ani:release()
    end
  end
  g_AniPool = {}
end
function ReleaseAniRelativePool()
  ReleaseAniConfigPathOfPool()
  ReleaseAniPool()
end
local function AddAniToPool(plistpath, ani)
  if g_AniPool[plistpath] == nil then
    g_AniPool[plistpath] = {}
  end
  local n = #g_AniPool[plistpath]
  g_AniPool[plistpath][n + 1] = ani
end
local function GetAniFromAniPool(plistpath)
  if g_AniPool[plistpath] == nil then
    return nil
  end
  local aniLen = #g_AniPool[plistpath]
  if aniLen <= 0 then
    return nil
  else
    local ani = table.remove(g_AniPool[plistpath], aniLen)
    return ani
  end
end
gamereset.registerResetFunc(function()
  ReleaseAniRelativePool()
end)
local function createSpriteForAni(spritePath, alphaPath)
  if alphaPath and sharedFileUtils:isFileExist(sharedFileUtils:fullPathForFilename(alphaPath)) then
    if string.byte(spritePath) == 35 then
      local frame = display.newSpriteFrame(string.sub(spritePath, 2))
      if frame then
        return NmgMergeSprite:createWithSpriteFrame(frame, alphaPath), true
      end
    end
    return NmgMergeSprite:create(spritePath, alphaPath), true
  end
  return display.newSprite(spritePath), false
end
local SeqAni = class("SeqAni", function()
  local node = display.newNode()
  return node
end)
function SeqAni:ctor(plistpath, times, cblistener, autoDestroy, retainToPool, frameRate, rgba4444Mode)
  self:setNodeEventEnabled(true)
  self.m_ActionList = {}
  self.m_Sprite = nil
  self.m_SpriteHadColorfulInter = false
  self.m_RetainToPool = retainToPool
  self.m_HasAddRefCnt = false
  self.m_HasSubRefCnt = false
  if rgba4444Mode == true then
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  end
  self:LoadAni(plistpath, times, cblistener, autoDestroy, frameRate)
  if rgba4444Mode == true then
    resetDefaultAlphaPixelFormat()
  end
  local funcs = {
    "setPosition",
    "getPosition",
    "setVisible",
    "isVisible",
    "setColor",
    "getColor",
    "getContentSize",
    "setContentSize",
    "getScale",
    "setScale",
    "setScaleX",
    "setScaleY",
    "setOpacity",
    "getOpacity",
    "setAnchorPoint",
    "getAnchorPoint",
    "getTextureRect",
    "runAction",
    "stopAction",
    "stopAllActions",
    "setRotation",
    "getRotation",
    "setFlipX",
    "setFlipY"
  }
  for i, f in ipairs(funcs) do
    self[f] = function(obj, ...)
      if self.m_Sprite ~= nil then
        local func = self.m_Sprite[f]
        if func then
          return func(self.m_Sprite, ...)
        end
      end
    end
  end
  if retainToPool then
    self.m_HasRetain = true
    self:retain()
  end
end
function SeqAni:getTheFileData(aniConfigPath)
  local temp = g_AniConfigPathPool[aniConfigPath]
  if temp ~= nil then
    return temp
  else
    local fData = CZHelperFunc:getFileData(aniConfigPath)
    if fData == nil then
      fData = -1
    end
    g_AniConfigPathPool[aniConfigPath] = fData
    return fData
  end
end
function SeqAni:getAniName(aniName)
  return self.m_FileName .. "_" .. aniName
end
function SeqAni:LoadAni(plistpath, times, cblistener, autoDestroy, frameRate)
  if plistpath == nil then
    return
  end
  self.m_PlistPath = plistpath
  local pathinfo = io.pathinfo(plistpath)
  local fileName = pathinfo.basename
  self.m_FileName = fileName
  frameRate = frameRate or 10
  local alphaPath
  if string.sub(plistpath, -4, -1) == ".png" then
    alphaPath = string.sub(plistpath, 1, -5) .. "_color.plist"
  elseif string.sub(plistpath, -6, -1) == ".plist" then
    alphaPath = string.sub(plistpath, 1, -7) .. "_color.plist"
  end
  local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
  frameCache:addSpriteFramesWithFile(plistpath)
  self.m_LastSeqAction = nil
  self.m_ActionList = {}
  local aniConfigPath = pathinfo.dirname .. pathinfo.basename .. ".ani"
  local fData = self:getTheFileData(aniConfigPath)
  if fData ~= nil and fData ~= -1 then
    fData = string.split(fData, "\n")
    for i, line in ipairs(fData) do
      if #line > 1 then
        local aniInfo = string.split(line, " ")
        if #aniInfo >= 3 then
          aniInfo[1] = self:getAniName(aniInfo[1])
          self.m_ActionList[i] = aniInfo
        elseif #aniInfo == 2 and aniInfo[1] == "framerate" then
          frameRate = tonumber(aniInfo[2])
        end
      end
    end
    for i, aniInfo in pairs(self.m_ActionList) do
      local aniName = aniInfo[1]
      local temp = CCAnimationCache:sharedAnimationCache():animationByName(aniName)
      if temp == nil then
        local frameArray = CCArray:create()
        local jj = 2
        while aniInfo[jj] ~= nil and aniInfo[jj + 1] ~= nil do
          local step
          local startIdx = tonumber(aniInfo[jj])
          local endIdx = tonumber(aniInfo[jj + 1])
          if startIdx <= endIdx then
            step = 1
          else
            step = -1
          end
          for seqIdx = startIdx, endIdx, step do
            local name = string.format(self.m_FileName .. "_%05d.png", seqIdx)
            local frameTemp = frameCache:spriteFrameByName(name)
            if frameTemp == nil then
              break
            end
            frameArray:addObject(frameTemp)
            if self.m_Sprite == nil then
              self.m_Sprite, self.m_SpriteHadColorfulInter = createSpriteForAni(string.format("#" .. self.m_FileName .. "_%05d.png", seqIdx), alphaPath)
              self:addChild(self.m_Sprite)
            end
          end
          jj = jj + 2
        end
        local animation
        if string.find(aniName, "walk") ~= nil and string.find(aniName, "shape") ~= nil then
          animation = CCAnimation:createWithSpriteFrames(frameArray, 0.08333333333333333)
        else
          animation = CCAnimation:createWithSpriteFrames(frameArray, 1 / frameRate)
        end
        local animationCache = CCAnimationCache:sharedAnimationCache()
        animationCache:addAnimation(animation, aniName)
      end
    end
  end
  self.m_DefaultAniName = self.m_PlistPath
  local temp = CCAnimationCache:sharedAnimationCache():animationByName(self.m_DefaultAniName)
  if temp == nil then
    local frameArray = CCArray:create()
    local seqIdx = 1
    while true do
      local name = string.format(fileName .. "_%05d.png", seqIdx)
      local frameTemp = frameCache:spriteFrameByName(name)
      if frameTemp == nil then
        break
      end
      frameArray:addObject(frameTemp)
      if self.m_Sprite == nil then
        self.m_Sprite, self.m_SpriteHadColorfulInter = createSpriteForAni(string.format("#" .. self.m_FileName .. "_%05d.png", seqIdx), alphaPath)
        self:addChild(self.m_Sprite)
      end
      seqIdx = seqIdx + 1
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArray, 1 / frameRate)
    local animationCache = CCAnimationCache:sharedAnimationCache()
    animationCache:addAnimation(animation, self.m_DefaultAniName)
  end
  if self.m_Sprite == nil then
    if #self.m_ActionList > 0 then
      local firstPngIdx = self.m_ActionList[1][2]
      self.m_Sprite, self.m_SpriteHadColorfulInter = createSpriteForAni(string.format("#" .. self.m_FileName .. "_%05d.png", firstPngIdx), alphaPath)
    else
      self.m_Sprite, self.m_SpriteHadColorfulInter = createSpriteForAni(string.format("#" .. self.m_FileName .. "_%05d.png", 1), alphaPath)
    end
    self:addChild(self.m_Sprite)
  end
  self:playAniFirstIndex(times, cblistener, autoDestroy)
  self:AddRefCount()
  if self.m_SpriteHadColorfulInter then
    if self.m_Sprite ~= nil and self.m_Sprite then
      local glProgram = tolua.cast(self.m_Sprite:getShaderProgram(), "CCObject")
      if glProgram then
        local retainCount = glProgram:retainCount()
        print("---------->>> glProgram retain count:", retainCount)
        if retainCount > 1 then
          glProgram:release()
        end
      end
    else
      print("-------->> self.m_Sprite 对象已经删除")
    end
  end
end
function SeqAni:playAniWithIndex(idx, times, cblistener, autoDestroy)
  if autoDestroy == nil then
    autoDestroy = false
  end
  local name = self.m_ActionList[idx]
  if name and name[1] then
    local aniName = name[1]
    return self:_playAniWithName(aniName, times, cblistener, autoDestroy)
  end
  return false
end
function SeqAni:playAniFirstIndex(times, cblistener, autoDestroy)
  if #self.m_ActionList > 0 then
    self:playAniWithIndex(1, times, cblistener, autoDestroy)
  else
    self:playAniFromStart(times, cblistener, autoDestroy)
  end
end
function SeqAni:playAniFromStart(times, cblistener, autoDestroy)
  times = times or 1
  if autoDestroy == nil then
    autoDestroy = true
  end
  if #self.m_ActionList == 0 then
    return self:_playAniWithName(self.m_DefaultAniName, times, cblistener, autoDestroy)
  else
    return self:playAniWithIndex(1, 1, function()
      self:OneAniPlayCompleted(1, times, cblistener, autoDestroy)
    end, false)
  end
end
function SeqAni:OneAniPlayCompleted(index, times, cblistener, autoDestroy)
  index = index + 1
  if index > #self.m_ActionList then
    if times < 0 then
      self:playAniWithIndex(1, 1, function()
        self:OneAniPlayCompleted(1, times, cblistener, autoDestroy)
      end, false)
    else
      times = times - 1
      if times > 0 then
        self:playAniWithIndex(1, 1, function()
          self:OneAniPlayCompleted(1, times, cblistener, autoDestroy)
        end, false)
      else
        if cblistener ~= nil then
          cblistener()
        end
        if autoDestroy then
          self:removeFromParent()
        end
      end
    end
  else
    self:playAniWithIndex(index, 1, function()
      self:OneAniPlayCompleted(index, times, cblistener, autoDestroy)
    end, false)
  end
end
function SeqAni:playAniWithName(aniName, times, cblistener, autoDestroy)
  local _aniName = self:getAniName(aniName)
  return self:_playAniWithName(_aniName, times, cblistener, autoDestroy)
end
function SeqAni:_playAniWithName(aniName, times, cblistener, autoDestroy)
  if self.m_Sprite == nil then
    return false
  end
  times = times or -1
  local animation = CCAnimationCache:sharedAnimationCache():animationByName(aniName)
  if animation == nil then
    print(string.format("error: animation(%s) == nil", aniName), self.m_PlistPath)
    return false
  end
  if times == -1 then
    animation:setLoops(100000000)
  else
    animation:setLoops(times)
  end
  local animate = CCAnimate:create(animation)
  if self.m_LastSeqAction ~= nil then
    self.m_Sprite:stopAction(self.m_LastSeqAction)
    self.m_LastSeqAction = nil
  end
  if times ~= -1 then
    if cblistener then
      self.m_LastSeqAction = transition.sequence({
        animate,
        CCCallFunc:create(cblistener),
        CCCallFunc:create(function()
          self:onAniPlayComplete(autoDestroy)
        end)
      })
    else
      self.m_LastSeqAction = transition.sequence({
        animate,
        CCCallFunc:create(function()
          self:onAniPlayComplete(autoDestroy)
        end)
      })
    end
  else
    self.m_LastSeqAction = animate
  end
  self.m_Sprite:runAction(self.m_LastSeqAction)
  return true
end
function SeqAni:onAniPlayComplete(autoDestroy)
  if not autoDestroy then
    return
  end
  self:removeFromParent()
end
function SeqAni:stopAnimation()
  self.m_Sprite:stopAllActions()
  self.m_Sprite:setVisible(false)
end
function SeqAni:pauseAnimation()
  self.m_Sprite:pauseSchedulerAndActions()
end
function SeqAni:resumeAnimation()
  self.m_Sprite:resumeSchedulerAndActions()
end
function SeqAni:removeFromParent()
  local p = self:getParent()
  if p then
    if p.removeNode ~= nil then
      p:removeNode(self)
    else
      p:removeChild(self)
    end
  end
end
function SeqAni:removeFromParentAndCleanup(para)
  local p = self:getParent()
  if p then
    if p.removeNode ~= nil then
      p:removeNode(self)
    else
      p:removeChild(self, para)
    end
  end
end
function SeqAni:AddRefCount()
  if self.m_PlistPath == nil then
    return
  end
  if self.m_HasAddRefCnt == true then
    return
  end
  if g_AniRefCountDict[self.m_PlistPath] == nil then
    g_AniRefCountDict[self.m_PlistPath] = 1
  else
    g_AniRefCountDict[self.m_PlistPath] = g_AniRefCountDict[self.m_PlistPath] + 1
  end
  self.m_HasAddRefCnt = true
end
function SeqAni:ClearRefCount()
  if self.m_PlistPath == nil then
    return -1
  end
  if self.m_HasSubRefCnt == true then
    return -1
  end
  if g_AniRefCountDict[self.m_PlistPath] ~= nil then
    g_AniRefCountDict[self.m_PlistPath] = g_AniRefCountDict[self.m_PlistPath] - 1
  end
  self.m_HasSubRefCnt = true
  return g_AniRefCountDict[self.m_PlistPath]
end
function SeqAni:onCleanup()
  self.m_Sprite = nil
  if self.m_RetainToPool == true then
    self:stopAnimation()
    AddAniToPool(self.m_PlistPath, self)
  else
    if self.m_HasRetain == true then
      self:release()
    end
    if not self.m_HasSubRefCnt and self:ClearRefCount() == 0 then
      local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
      frameCache:removeSpriteFramesFromFile(self.m_PlistPath)
      local animationCache = CCAnimationCache:sharedAnimationCache()
      for i, aniInfo in pairs(self.m_ActionList) do
        local aniName = aniInfo[1]
        animationCache:removeAnimationByName(aniName)
      end
      animationCache:removeAnimationByName(self.m_DefaultAniName)
      self.m_ActionList = {}
    else
    end
  end
end
function SeqAni:getSprite()
  return self.m_Sprite
end
function SeqAni:setEnalbeColorful(isEnabled)
  if self.m_Sprite and self.m_SpriteHadColorfulInter and self.m_Sprite.setEnalbeColorful then
    self.m_Sprite:setEnalbeColorful(isEnabled)
    return true
  end
  return false
end
function SeqAni:setColorful(iPart, color4)
  if self.m_Sprite and self.m_SpriteHadColorfulInter and self.m_Sprite.setColorful then
    return self.m_Sprite:setColorful(iPart, color4)
  end
  return false
end
function CreateSeqAnimation(plistpath, times, cblistener, autoDestroy, retainToPool, frameRate, rgba4444Mode)
  retainToPool = false
  local ani = GetAniFromAniPool(plistpath)
  if ani == nil or ani:getParent() ~= nil then
    return SeqAni.new(plistpath, times, cblistener, autoDestroy, retainToPool, frameRate, rgba4444Mode)
  else
    ani:setVisible(true)
    ani:setOpacity(255)
    ani:setScale(1)
    ani:setColor(ccc3(255, 255, 255))
    ani:setAnchorPoint(ccp(0.5, 0.5))
    ani:playAniFirstIndex(times, cblistener, autoDestroy)
    return ani
  end
end
