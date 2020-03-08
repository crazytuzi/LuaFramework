local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonCutPhotoPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local Rect = require("Types.Rect").Rect
local GUIUtils = require("GUI.GUIUtils")
local def = CommonCutPhotoPanel.define
local GUIMan = require("GUI.ECGUIMan")
local MathHelper = require("Common.MathHelper")
local DisplayType = {TakePhoto = 1, PickPhoto = 2}
def.const("table").DisplayType = DisplayType
local FinishStatus = {CANCEL = 0, OK = 1}
def.const("table").FinishStatus = FinishStatus
def.field("table").m_UIGOs = nil
def.field("number").m_displayType = 0
def.field("string").m_srcPhotoPath = ""
def.field("string").m_destPhotoPath = ""
def.field("function").m_onRePick = nil
def.field("function").m_onFinish = nil
def.field("number").m_photoScale = 1
def.field("table").m_clipSize = nil
def.field("number").m_cutLimit = 0
def.field("number").m_compressQuality = 0
def.field("number").m_maxScale = 10
def.field("number").m_minScale = 0.1
local instance
def.static("=>", CommonCutPhotoPanel).Instance = function()
  if instance == nil then
    instance = CommonCutPhotoPanel()
  end
  return instance
end
def.override("=>", "boolean").IsAliveInReconnect = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  return true
end
def.method("number", "string", "string", "function", "function", "table").ShowPanel = function(self, displayType, srcPhotoPath, destPhotoPath, onRePic, onFinish, exParams)
  if CUR_CODE_VERSION < _G.COS_EX_CODE_VERSION then
    warn(string.format("CommonCutPhotoPanel: current code version(%d) is too low", CUR_CODE_VERSION))
    return
  end
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_displayType = displayType
  self.m_srcPhotoPath = srcPhotoPath
  self.m_destPhotoPath = destPhotoPath
  self.m_onRePick = onRePic
  self.m_onFinish = onFinish
  local exParams = exParams or {}
  self.m_cutLimit = exParams.cutLimit or 0
  self.m_clipSize = exParams.clipSize
  self.m_compressQuality = exParams.compressQuality or 0
  self:SetDepth(GUIDEPTH.TOPMOST)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_CUT_PHOTO_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_srcPhotoPath = ""
  self.m_destPhotoPath = ""
  self.m_onRePick = nil
  self.m_onFinish = nil
  self.m_photoScale = 1
  self.m_clipSize = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_OK" then
    self:OnClickOkBtn()
  elseif id == "Btn_Close" then
    self:OnClickCancelBtn()
  elseif id == "Btn_Take" then
    self:OnClickTakeBtn()
  end
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Btn_Turn = self.m_panel:FindDirect("Btn_Turn")
  self.m_UIGOs.Btn_Take = self.m_panel:FindDirect("Btn_Take")
  self.m_UIGOs.Img_Gray = self.m_panel:FindDirect("Img_Gray")
  self.m_UIGOs.Img_Line = self.m_panel:FindDirect("Img_Line")
  self.m_UIGOs.Box_Preview = self.m_panel:FindDirect("Box_Preview")
  local visibleCenter = self:GetVisibleCenter()
  local Texture_Photo = GameObject.GameObject("Texture_Photo")
  Texture_Photo:SetLayer(ClientDef_Layer.UI)
  Texture_Photo.parent = self.m_panel
  Texture_Photo.localPosition = Vector.Vector3.zero
  Texture_Photo.localScale = Vector.Vector3.one
  local uiTexture = Texture_Photo:AddComponent("UITexture")
  uiTexture:set_depth(1)
  self.m_UIGOs.Texture_Photo = Texture_Photo
  self.m_UIGOs.UITexture_Photo = uiTexture
  uiTexture.gameObject.localPosition = visibleCenter
  local Texture_Back = GameObject.GameObject("Texture_Back")
  Texture_Back:SetLayer(ClientDef_Layer.UI)
  Texture_Back.parent = self.m_panel
  Texture_Back.localPosition = Vector.Vector3.zero
  Texture_Back.localScale = Vector.Vector3.one
  local uiTexture = Texture_Back:AddComponent("UITexture")
  uiTexture:set_depth(0)
  local visibleSize = self:GetVisibleAreaSize()
  uiTexture.width = visibleSize.width + 20
  uiTexture.height = visibleSize.height
  local tex2d = Texture2D.Texture2D(uiTexture.width, uiTexture.height, TextureFormat.RGB24, false)
  uiTexture.mainTexture = tex2d
  uiTexture.color = Color.black
  uiTexture.gameObject.localPosition = visibleCenter
  local Texture_GrayCover = GameObject.GameObject("Texture_GrayCover")
  Texture_GrayCover:SetLayer(ClientDef_Layer.UI)
  Texture_GrayCover.parent = self.m_panel
  Texture_GrayCover.localPosition = Vector.Vector3.zero
  Texture_GrayCover.localScale = Vector.Vector3.one
  local uiTexture = Texture_GrayCover:AddComponent("UITexture")
  uiTexture:set_depth(2)
  local visibleSize = self:GetVisibleAreaSize()
  uiTexture.width = visibleSize.width
  uiTexture.height = visibleSize.height
  local tex2d = Texture2D.Texture2D(uiTexture.width, uiTexture.height, TextureFormat.ARGB32, false)
  self.m_UIGOs.tex2d_gray = tex2d
  uiTexture.mainTexture = tex2d
  uiTexture.color = Color.gray
  uiTexture.alpha = 0.5
  uiTexture.gameObject.localPosition = visibleCenter
  GUIUtils.SetActive(self.m_UIGOs.Img_Gray, false)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Turn, false)
  GUIUtils.SetActive(self.m_UIGOs.Img_Line, false)
  self:InitClipSize()
  self:SetCutRect(visibleCenter.x, visibleCenter.y, self.m_clipSize.width, self.m_clipSize.height)
end
def.method().InitClipSize = function(self)
  if self.m_clipSize == nil then
    local visibleSize = self:GetVisibleAreaSize()
    local minEdge = math.min(visibleSize.width, visibleSize.height)
    self.m_clipSize = {}
    self.m_clipSize.width = minEdge - 100
    self.m_clipSize.height = self.m_clipSize.width
  end
end
def.method().UpdateUI = function(self)
  self:UpdateDisplayType()
  self:UpdatePhoto()
end
def.method().OnClickOkBtn = function(self)
  local finallyCutRect = self:GetFinallyCutRect()
  if finallyCutRect == nil then
    return
  end
  warn("finallyCutRect:", pretty(finallyCutRect))
  local uiTexture = self.m_UIGOs.UITexture_Photo
  local tex2d = uiTexture.mainTexture
  GameUtil.CreateDirectoryForFile(self.m_destPhotoPath)
  GameUtil.CropImageFromTexture(finallyCutRect.x, finallyCutRect.y, finallyCutRect.width, finallyCutRect.height, self.m_cutLimit, tex2d, self.m_destPhotoPath, self.m_compressQuality)
  self:Finish(FinishStatus.OK, self.m_destPhotoPath)
end
def.method().OnClickCancelBtn = function(self)
  self:Finish(FinishStatus.CANCEL, "")
end
def.method().OnClickTakeBtn = function(self)
  if self.m_onRePick then
    self.m_onRePick(self)
  end
end
def.method("string").ResetWithPhoto = function(self, photoPath)
  if not self:IsLoaded() then
    return
  end
  self.m_srcPhotoPath = photoPath
  self.m_photoScale = 1
  self:UpdatePhoto()
end
def.method("number", "string").Finish = function(self, status, outputPath)
  if self.m_onFinish then
    self.m_onFinish(status, outputPath)
    self.m_onFinish = nil
  end
  self:DestroyPanel()
end
def.method().UpdateDisplayType = function(self)
  local spriteName
  if self.m_displayType == DisplayType.TakePhoto then
    spriteName = "Img_Take"
  else
    spriteName = "Img_PhotoUp"
  end
  GUIUtils.SetSprite(self.m_UIGOs.Btn_Take, spriteName)
end
def.method().UpdatePhoto = function(self)
  GUIUtils.FillTextureFromLocalPath(self.m_UIGOs.Texture_Photo, self.m_srcPhotoPath, function(uiTexture)
    local mainTexture = uiTexture.mainTexture
    local texW, texH = mainTexture:get_width(), mainTexture:get_height()
    local visibleSize = self:GetVisibleAreaSize()
    local visibleAspectRatio = visibleSize.width / visibleSize.height
    local texAspectRatio = texW / texH
    if texAspectRatio >= 1 then
      local targetHeight = self.m_clipSize.height
      uiTexture.height = targetHeight
      uiTexture.width = uiTexture.height * texAspectRatio
    else
      local targetWidth = self.m_clipSize.width
      uiTexture.width = targetWidth
      uiTexture.height = uiTexture.width / texAspectRatio
    end
    local visibleCenter = self:GetVisibleCenter()
    uiTexture.gameObject.localPosition = visibleCenter
    uiTexture.gameObject.localScale = Vector.Vector3.one
  end)
end
def.method("number", "number", "number", "number").SetCutRect = function(self, x, y, w, h)
  if self.m_UIGOs.Cut_Rect == nil then
    self.m_UIGOs.Cut_Rect = self:CreateCutRect(x, y, w, h)
  else
    self:SetCutRectInfo(self.m_UIGOs.Cut_Rect, x, y, w, h)
  end
  local transparent = Color.Color(0, 0, 0, 0)
  local colors = {}
  for ww = 1, w do
    for hh = 1, h do
      table.insert(colors, transparent)
    end
  end
  local visibleCenter = self:GetVisibleCenter()
  local visibleSize = self:GetVisibleAreaSize()
  local startX = x - visibleCenter.x + visibleSize.width / 2 - w / 2
  local startY = y - visibleCenter.y + visibleSize.height / 2 - h / 2
  local tex2d = self.m_UIGOs.tex2d_gray
  tex2d:SetPixels(startX, startY, w, h, colors)
  tex2d:Apply()
end
def.method("number", "number", "number", "number", "=>", "userdata").CreateCutRect = function(self, x, y, w, h)
  local visibleCenter = self:GetVisibleCenter()
  local Cut_Rect = GameObject.GameObject("Cut_Rect")
  Cut_Rect:SetLayer(ClientDef_Layer.UI)
  Cut_Rect.parent = self.m_panel
  Cut_Rect.localScale = Vector.Vector3.one
  Cut_Rect.localPosition = Vector.Vector3.new(x, y, 0)
  local topLine = GameObject.Instantiate(self.m_UIGOs.Img_Line)
  topLine.name = "topLine"
  local bottomLine = GameObject.Instantiate(self.m_UIGOs.Img_Line)
  bottomLine.name = "bottomLine"
  local rightLine = GameObject.Instantiate(self.m_UIGOs.Img_Line)
  rightLine.name = "rightLine"
  local leftLine = GameObject.Instantiate(self.m_UIGOs.Img_Line)
  leftLine.name = "leftLine"
  local lines = {
    topLine,
    bottomLine,
    rightLine,
    leftLine
  }
  for i, line in ipairs(lines) do
    line:SetActive(true)
    line.parent = Cut_Rect
    line.localScale = Vector.Vector3.one
  end
  self:SetCutRectInfo(Cut_Rect, x, y, w, h)
  return Cut_Rect
end
def.method("userdata", "number", "number", "number", "number").SetCutRectInfo = function(self, Cut_Rect, x, y, w, h)
  local topLine = Cut_Rect:FindDirect("topLine")
  local bottomLine = Cut_Rect:FindDirect("bottomLine")
  local rightLine = Cut_Rect:FindDirect("rightLine")
  local leftLine = Cut_Rect:FindDirect("leftLine")
  topLine.localPosition = Vector.Vector3.new(0, h / 2, 0)
  bottomLine.localPosition = Vector.Vector3.new(0, -h / 2, 0)
  topLine:GetComponent("UIWidget").width = w
  topLine:GetComponent("UIWidget").height = 2
  bottomLine:GetComponent("UIWidget").width = w
  bottomLine:GetComponent("UIWidget").height = 2
  rightLine.localPosition = Vector.Vector3.new(w / 2, 0, 0)
  leftLine.localPosition = Vector.Vector3.new(-w / 2, 0, 0)
  rightLine:GetComponent("UIWidget").width = 2
  rightLine:GetComponent("UIWidget").height = h
  leftLine:GetComponent("UIWidget").width = 2
  leftLine:GetComponent("UIWidget").height = h
end
def.method("=>", "table").GetUIViewSize = function(self)
  local GUIMan = require("GUI.ECGUIMan")
  local size = {}
  size.height = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  size.width = size.height / Screen.height * Screen.width
  return size
end
def.method("=>", "table").GetVisibleAreaSize = function(self)
  local uiViewSize = self:GetUIViewSize()
  local Img_Bg = self.m_UIGOs.Img_Bg
  local size = {}
  size.height = uiViewSize.height
  size.width = uiViewSize.width - Img_Bg:GetComponent("UIWidget").width
  return size
end
def.method("=>", "table").GetVisibleCenter = function(self)
  local Img_Bg = self.m_UIGOs.Img_Bg
  local centerX = -Img_Bg:GetComponent("UIWidget").width / 2
  return Vector.Vector3.new(centerX, 0, 0)
end
def.method("number").ScalePhoto = function(self, s)
  if s > 0 then
    if self.m_photoScale < self.m_maxScale then
      self.m_photoScale = self.m_photoScale * 1.1
    end
  elseif s < 0 and self.m_photoScale > self.m_minScale then
    self.m_photoScale = self.m_photoScale * 0.9
  end
  self.m_UIGOs.Texture_Photo.localScale = Vector.Vector3.one * self.m_photoScale
end
local lastDis
def.method("string").onDragStart = function(self, id)
  if UICamera.get_dragCount() > 1 then
    lastDis = nil
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  local dragCount = UICamera.get_dragCount()
  if id == "Box_Preview" and dragCount == 1 and not lastDis then
    local lastPos = self.m_UIGOs.Texture_Photo.localPosition
    self.m_UIGOs.Texture_Photo.localPosition = Vector.Vector3.new(lastPos.x + dx, lastPos.y + dy, 0)
  elseif id == "Box_Preview" and dragCount > 1 then
    local touch0 = Input.GetTouch(0)
    local touch1 = Input.GetTouch(1)
    local touch0FingerId = touch0:get_fingerId()
    local touch1FingerId = touch1:get_fingerId()
    local nguiTouch0 = UICamera.GetTouch(touch0FingerId)
    local nguiTouch1 = UICamera.GetTouch(touch1FingerId)
    local curDiff = nguiTouch0.pos - nguiTouch1.pos
    local curDis = curDiff:get_Length()
    if lastDis then
      local deltaDis = curDis - lastDis
      if math.abs(deltaDis) > 0.2 then
        self:ScalePhoto(deltaDis)
      end
    end
    lastDis = curDis
  end
end
def.method("string").onDragEnd = function(self, id)
  if UICamera.get_dragCount() <= 1 then
    lastDis = nil
  end
end
def.method("string").tick = function(self)
  if platform ~= _G.Platform.win then
    return
  end
  local dScroll = Input.GetAxis("Mouse ScrollWheel")
  if dScroll > 0 then
    self:ScalePhoto(dScroll)
  elseif dScroll < 0 then
    self:ScalePhoto(dScroll)
  end
end
def.method("=>", "table").GetFinallyCutRect = function(self)
  local uiTexture = self.m_UIGOs.UITexture_Photo
  local mainTexture = uiTexture.mainTexture
  if mainTexture == nil then
    return nil
  end
  local widgetW = uiTexture.width
  local widgetH = uiTexture.height
  local scaledW, scaledH = widgetW * self.m_photoScale, widgetH * self.m_photoScale
  local widgetPosition = self.m_UIGOs.Texture_Photo.localPosition
  local visibleCenter = self:GetVisibleCenter()
  local startX = scaledW / 2 + visibleCenter.x - widgetPosition.x - self.m_clipSize.width / 2
  local startY = scaledH / 2 + visibleCenter.y - widgetPosition.y - self.m_clipSize.height / 2
  local texW, texH = mainTexture:get_width(), mainTexture:get_height()
  local texScale = scaledW / texW
  local clipScale = scaledW / texW
  local rect = {}
  rect.x = startX / texScale
  rect.y = startY / texScale
  rect.width = self.m_clipSize.width / texScale
  rect.height = self.m_clipSize.height / texScale
  rect.x = MathHelper.Clamp(rect.x, 0, texW)
  rect.y = MathHelper.Clamp(rect.y, 0, texH)
  return rect
end
return CommonCutPhotoPanel.Commit()
