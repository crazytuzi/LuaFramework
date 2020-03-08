local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonPictureDisplayPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local def = CommonPictureDisplayPanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_picList = nil
def.field("number").m_selectedIndex = 0
def.field("function").m_onSetPicture = nil
def.field("number").m_scale = 1
def.field("number").m_minScale = 0.2
def.field("number").m_maxScale = 5
def.field("number").m_scaleSpeed = 0
def.field("dynamic").m_lastDis = nil
def.field("table").m_uiViewSize = nil
local instance
def.static("=>", CommonPictureDisplayPanel).Instance = function()
  if instance == nil then
    instance = CommonPictureDisplayPanel()
  end
  return instance
end
def.method("table", "number", "function").ShowPanel = function(self, picList, selectedIndex, onSetPicture)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  if type(picList) ~= "table" then
    error("picList expected")
  end
  if #picList == 0 then
    print("CommonPictureDisplayPanel: no picture to display!")
    return
  end
  self.m_picList = picList
  self.m_selectedIndex = require("Common.MathHelper").Clamp(selectedIndex, 1, #picList)
  self.m_onSetPicture = onSetPicture
  self:SetModal(true)
  self:SetDepth(GUIDEPTH.TOPMOST)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_DISPLAY_PICTURE_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:ResetPictureInfo()
  self.m_UIGOs = nil
  self.m_picList = nil
  self.m_selectedIndex = 0
  self.m_onSetPicture = nil
  self.m_lastDis = nil
  self.m_uiViewSize = nil
end
def.method().ResetPictureInfo = function(self)
  self.m_scale = 1
  self.m_scaleSpeed = 0
  if self.m_UIGOs and not _G.IsNil(self.m_UIGOs.Texture) then
    self.m_UIGOs.Texture.localPosition = Vector.Vector3.zero
    self.m_UIGOs.Texture.localScale = Vector.Vector3.one
    GUIUtils.SetTexture(self.m_UIGOs.Texture, nil)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Right" then
    self:ShowNextPicture()
  elseif id == "Btn_Left" then
    self:ShowPrevPicture()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Texture = self.m_panel:FindDirect("Texture")
  self.m_UIGOs.UITexture = self.m_UIGOs.Texture:GetComponent("UITexture")
  self.m_UIGOs.Btn_Right = self.m_panel:FindDirect("Btn_Right")
  self.m_UIGOs.Btn_Left = self.m_panel:FindDirect("Btn_Left")
  local GUIMan = require("GUI.ECGUIMan")
  local size = {}
  size.height = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  size.width = size.height / Screen.height * Screen.width
  size.halfHeight = size.height / 2
  size.halfWidth = size.width / 2
  self.m_uiViewSize = size
end
def.method().UpdateUI = function(self)
  self:UpdateSelectedPicture()
end
def.method().UpdateSelectedPicture = function(self)
  self:UpdateBtns()
  self:ResetPictureInfo()
  local pic = self.m_picList[self.m_selectedIndex]
  self:SetPicture(pic)
end
def.method("dynamic").SetPicture = function(self, pic)
  if self.m_onSetPicture then
    self.m_onSetPicture(self.m_UIGOs.Texture, pic)
  end
end
def.method("=>", "boolean").IsPictureReady = function(self)
  return self.m_UIGOs.UITexture.mainTexture ~= nil
end
def.method().UpdateBtns = function(self)
  local showLeftBtn = self.m_selectedIndex > 1
  local showRightBtn = self.m_selectedIndex < #self.m_picList
  GUIUtils.SetActive(self.m_UIGOs.Btn_Right, showRightBtn)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Left, showLeftBtn)
end
def.method().ShowNextPicture = function(self)
  if self.m_selectedIndex == #self.m_picList then
    return
  end
  self.m_selectedIndex = self.m_selectedIndex + 1
  self:UpdateSelectedPicture()
end
def.method().ShowPrevPicture = function(self)
  if self.m_selectedIndex == 1 then
    return
  end
  self.m_selectedIndex = self.m_selectedIndex - 1
  self:UpdateSelectedPicture()
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Btn_ZoomIn" or id == "Btn_ZoomOut" then
    if state == true then
      if id == "Btn_ZoomIn" then
        self.m_scaleSpeed = 1
      else
        self.m_scaleSpeed = -1
      end
    else
      self.m_scaleSpeed = 0
    end
  end
end
def.method("string").tick = function(self, id)
  if platform == _G.Platform.win then
    self:TickMouseScrollWheel()
  end
  local scale
  if self.m_scaleSpeed ~= 0 then
    if self.m_scaleSpeed > 0 and self.m_scale < self.m_maxScale then
      scale = self.m_scale + self.m_scaleSpeed * Time.deltaTime
    elseif self.m_scaleSpeed < 0 and self.m_scale > self.m_minScale then
      scale = self.m_scale + self.m_scaleSpeed * Time.deltaTime
    end
  end
  if scale then
    self:ScalePicture(scale)
  end
end
def.method().TickMouseScrollWheel = function(self)
  local dScroll = Input.GetAxis("Mouse ScrollWheel")
  local scale = self:CalcMouseScrollWheelScale(dScroll)
  if dScroll > 0 then
    self:ScalePicture(scale)
  elseif dScroll < 0 then
    self:ScalePicture(scale)
  end
end
def.method("number", "=>", "number").CalcMouseScrollWheelScale = function(self, dScroll)
  local scale = self.m_scale + dScroll / 3
  scale = MathHelper.Clamp(scale, self.m_minScale, self.m_maxScale)
  return scale
end
def.method("number").ScalePicture = function(self, scale)
  if not self:IsPictureReady() then
    return
  end
  local lastScale = self.m_scale
  local Texture = self.m_UIGOs.Texture
  Texture.localScale = Vector.Vector3.one * scale
  self.m_scale = scale
  local centerPos = self.m_UIGOs.Texture.localPosition
  local lastWidgetWidth = self.m_UIGOs.UITexture.width * lastScale
  local lastWidgetHeight = self.m_UIGOs.UITexture.height * lastScale
  local ratioX = centerPos.x / lastWidgetWidth
  local ratioY = centerPos.y / lastWidgetHeight
  local widgetWidth = self.m_UIGOs.UITexture.width * scale
  local widgetHeight = self.m_UIGOs.UITexture.height * scale
  local nextPosX = widgetWidth * ratioX
  local nextPosY = widgetHeight * ratioY
  self.m_UIGOs.Texture.localPosition = Vector.Vector3.new(nextPosX, nextPosY, 0)
end
def.method("string").onDragStart = function(self, id)
  if UICamera.get_dragCount() > 1 then
    self.m_lastDis = nil
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  local dragCount = UICamera.get_dragCount()
  if dragCount == 1 and not self.m_lastDis then
    self:MovePicture(dx, dy)
  elseif dragCount > 1 and _G.CUR_CODE_VERSION >= _G.COS_EX_CODE_VERSION then
    local touch0 = Input.GetTouch(0)
    local touch1 = Input.GetTouch(1)
    local touch0FingerId = touch0:get_fingerId()
    local touch1FingerId = touch1:get_fingerId()
    local nguiTouch0 = UICamera.GetTouch(touch0FingerId)
    local nguiTouch1 = UICamera.GetTouch(touch1FingerId)
    local curDiff = nguiTouch0.pos - nguiTouch1.pos
    local curDis = curDiff:get_Length()
    if self.m_lastDis then
      local deltaDis = curDis - self.m_lastDis
      local scale = self:CalcTouchGestureScale(deltaDis)
      self:ScalePicture(scale)
    end
    self.m_lastDis = curDis
  end
end
def.method("string").onDragEnd = function(self, id)
  if UICamera.get_dragCount() <= 1 then
    self.m_lastDis = nil
  end
end
def.method("number", "=>", "number").CalcTouchGestureScale = function(self, deltaDis)
  local scale = self.m_scale + deltaDis * Time.deltaTime / 3
  scale = MathHelper.Clamp(scale, self.m_minScale, self.m_maxScale)
  return scale
end
def.method("number", "number").MovePicture = function(self, dx, dy)
  if not self:IsPictureReady() then
    return
  end
  local centerPos = self.m_UIGOs.Texture.localPosition
  local widgetWidth = self.m_UIGOs.UITexture.width * self.m_scale
  local widgetHeight = self.m_UIGOs.UITexture.height * self.m_scale
  local halfWidth = widgetWidth / 2
  local halfHeight = widgetHeight / 2
  local mx, my = 0, 0
  if dx > 0 then
    local extendWidth = math.max(0, widgetWidth - self.m_uiViewSize.width)
    local rightBorderX = centerPos.x + halfWidth
    local maxX = self.m_uiViewSize.halfWidth + extendWidth
    if rightBorderX < maxX then
      local nextRightBorderX = rightBorderX + dx
      local nextRightBorderX = math.min(nextRightBorderX, maxX)
      mx = nextRightBorderX - rightBorderX
    end
  elseif dx < 0 then
    local extendWidth = math.max(0, widgetWidth - self.m_uiViewSize.width)
    local leftBorderX = centerPos.x - halfWidth
    local minX = -self.m_uiViewSize.halfWidth - extendWidth
    if leftBorderX > minX then
      local nextLeftBorderX = leftBorderX + dx
      local nextLeftBorderX = math.max(nextLeftBorderX, minX)
      mx = nextLeftBorderX - leftBorderX
    end
  end
  if dy > 0 then
    local extendHeight = math.max(0, widgetHeight - self.m_uiViewSize.height)
    local topBorderY = centerPos.y + halfHeight
    local maxY = self.m_uiViewSize.halfHeight + extendHeight
    if topBorderY < maxY then
      local nextTopBorderY = topBorderY + dy
      local nextTopBorderY = math.min(nextTopBorderY, maxY)
      my = nextTopBorderY - topBorderY
    end
  elseif dy < 0 then
    local extendHeight = math.max(0, widgetHeight - self.m_uiViewSize.height)
    local bottomBorderY = centerPos.y - halfHeight
    local minY = -self.m_uiViewSize.halfHeight - extendHeight
    if bottomBorderY > minY then
      local nextBottomBorderY = bottomBorderY + dy
      local nextBottomBorderY = math.max(nextBottomBorderY, minY)
      my = nextBottomBorderY - bottomBorderY
    end
  end
  local localPosition = centerPos + Vector.Vector3.new(mx, my, 0)
  self.m_UIGOs.Texture.localPosition = localPosition
end
def.static("userdata", "string").OnSetPictureFromLocalPath = function(Texture, localPath)
  GUIUtils.FillTextureFromLocalPath(Texture, localPath, function(uiTexture)
    if _G.IsNil(Texture) then
      return
    end
    local uiTexture = Texture:GetComponent("UITexture")
    uiTexture:MakePixelPerfect()
  end)
end
def.static("userdata", "number").OnSetPictureFromIconId = function(Texture, iconId)
  GUIUtils.SetTexture(Texture, iconId, function(uiTexture)
    if _G.IsNil(uiTexture) then
      return
    end
    uiTexture:MakePixelPerfect()
  end)
end
return CommonPictureDisplayPanel.Commit()
