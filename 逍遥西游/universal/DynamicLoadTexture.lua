local DynamicLoad = class("DynamicLoad")
function DynamicLoad:ctor()
  self.m_IsUpdate = false
  self.m_IdIns = 0
  self.m_Datas = {}
  self.m_NeedDelIds = {}
  scheduler.scheduleUpdateGlobal(handler(self, self.frameUpdate))
end
function DynamicLoad:frameUpdate(dt)
  if self.m_IsUpdate then
    while #self.m_Datas > 0 do
      local d = table.remove(self.m_Datas, 1)
      local id = d[1]
      if self.m_NeedDelIds[id] == nil then
        local path = d[2]
        local listener = d[3]
        local loadParam = d[4] or {}
        local texture = CCTextureCache:sharedTextureCache():textureForKey(path)
        if texture == nil then
          if loadParam.pixelFormat ~= nil then
            setDefaultAlphaPixelFormat(loadParam.pixelFormat)
          end
          texture = CCTextureCache:sharedTextureCache():addImage(path)
          if loadParam.pixelFormat ~= nil then
            resetDefaultAlphaPixelFormat()
          end
        end
        if listener then
          listener(path, texture, id)
        end
        break
      end
      self.m_NeedDelIds[id] = nil
    end
    if #self.m_Datas == 0 then
      self.m_IsUpdate = false
      self.m_NeedDelIds = {}
    end
  end
end
function DynamicLoad:addImageAsync(path, listener, loadParam, priority)
  self.m_IdIns = self.m_IdIns + 1
  if priority == nil then
    self.m_Datas[#self.m_Datas + 1] = {
      self.m_IdIns,
      path,
      listener,
      loadParam,
      0
    }
  else
    local insertIdx = #self.m_Datas + 1
    for i, d in ipairs(self.m_Datas) do
      if priority > d[5] then
        insertIdx = i
        break
      end
    end
    table.insert(self.m_Datas, insertIdx, {
      self.m_IdIns,
      path,
      listener,
      loadParam,
      priority
    })
  end
  self.m_IsUpdate = true
  return self.m_IdIns
end
function DynamicLoad:delAsync(id)
  self.m_NeedDelIds[id] = true
end
g_DynamicLoad = DynamicLoad.new()
function addDynamicLoadTexture(path, listener, loadParam, priority, isInsertToFront)
  loadParam = loadParam or {}
  if loadParam.notAsync == true then
    return g_DynamicLoad:addImageAsync(path, listener, loadParam, priority)
  else
    pixelFormat = loadParam.pixelFormat
    if pixelFormat == nil then
      pixelFormat = -1
    end
    display.addImageAsync(path, function()
      loadParam.notAsync = true
      addDynamicLoadTexture(path, listener, loadParam, priority)
    end, pixelFormat, isInsertToFront)
  end
end
function delDynamicLoadTexture(id)
  return g_DynamicLoad:delAsync(id)
end
function DynamicLoadTextureExtend(object)
  function object:dlt_init()
    self._dlt_ids = {}
  end
  function object:addImageAsync(path, listener, loadParam, priority)
    local id = addDynamicLoadTexture(path, function(textname, texture, id)
      self._dlt_ids[id] = nil
      if listener then
        listener(textname, texture, id)
      end
    end, loadParam, priority)
    self._dlt_ids[id] = 1
  end
  function object:clearAllImageAsnyc()
    for id, v in pairs(self._dlt_ids) do
      delDynamicLoadTexture(id)
    end
    self._dlt_ids = {}
  end
  object:dlt_init()
end
function DynamicLoadTextureTest()
  scheduler.performWithDelayGlobal(function()
    local scene = display.newScene()
    display.replaceScene(scene)
    local filePath = "xiyou/mapbg/pic_mapscenebg1001.pvr.ccz"
    for i = 1, 9 do
      if i ~= 2 then
        filePath = string.format("xiyou/mapbg/pic_mapscenebg100%d.pvr.ccz", i)
        addDynamicLoadTexture(filePath, function(textname, texture, id)
          print("textname, texture, id--:", textname, texture, id)
          if texture then
            local sprite = display.newSprite(texture)
            scene:addChild(sprite, i)
            local size = sprite:getContentSize()
            sprite:setPosition(size.width / 2 + i * 50, size.height / 2 + i * 30)
          end
        end)
      end
    end
  end, 3)
end
