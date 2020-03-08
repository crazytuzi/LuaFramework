local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SnapshotPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local Vector3 = Vector.Vector3
local GUIUtils = require("GUI.GUIUtils")
local GUIMan = require("GUI.ECGUIMan")
local def = SnapshotPanel.define
local SnapshotModule = require("Main.Snapshot.SnapshotModule")
local SnapshotUtils = require("Main.Snapshot.SnapshotUtils")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local ImageListType = {
  None = 0,
  TextFrameBG = 1,
  StickImage = 2,
  ImageFrame = 3
}
local ImageStyle = {
  Default = 0,
  Colorless = 1,
  Ancient = 2
}
local ImageStyleClass = {ColorCorrect = 1}
local ImageStyleDef = {
  [ImageStyle.Default] = {
    class = ImageStyleClass.ColorCorrect,
    LUTTexture = RESPATH.TEX_CC_STANDARD,
    intensity = 1
  },
  [ImageStyle.Colorless] = {
    class = ImageStyleClass.ColorCorrect,
    LUTTexture = RESPATH.TEX_CC_COLORLESS,
    intensity = 1
  },
  [ImageStyle.Ancient] = {
    class = ImageStyleClass.ColorCorrect,
    LUTTexture = RESPATH.TEX_CC_ANCIENT,
    intensity = 1
  }
}
local MAX_TEXT_FRAME_NUM = 3
local MAX_STICK_IMAGE_NUM = 1
def.field("table").m_UIGOs = nil
def.field("table").m_neededCaptures = nil
def.field("table").m_textColors = nil
def.field("table").m_textSizes = nil
def.field("table").m_textBGs = nil
def.field("table").m_stickImages = nil
def.field("table").m_imageFrames = nil
def.field("number").m_selImageListType = ImageListType.None
def.field("userdata").m_draggedObj = nil
def.field("table").m_dragStartOffset = nil
def.field("number").m_activeImageStyle = ImageStyle.Default
def.field("dynamic").m_curPicturePath = nil
def.field("string").m_lastMenuType = ""
def.field("string").m_curMenuType = ""
def.field("number").m_curTextColorIndex = 1
def.field("number").m_curTextSizeIndex = 1
def.field("number").m_curTextBGIndex = 1
def.field("number").m_curStickImageIndex = 1
def.field("number").m_curImageFrameIndex = 1
def.field("table").m_textFrameInfos = nil
def.field("boolean").m_firstOnShow = true
def.field("table").m_photoUsedParams = nil
local instance
def.static("=>", SnapshotPanel).Instance = function()
  if instance == nil then
    instance = SnapshotPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_TrigGC = true
  self.m_TryIncLoadSpeed = true
  self:CreatePanel(RESPATH.PREFAB_CAPTURE_THE_MOMENT_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:SendTLogToServer(_G.TLOGTYPE.SNAPSHOT_OPEN_PANEL, {})
  self:InitData()
  self:InitUI()
  self:UpdateUI()
  SnapshotModule.Instance():EnterCaptureMode(self)
  Event.RegisterEventWithContext(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostDestroy, self.OnPanel_PostDestroy, self)
  Event.RegisterEventWithContext(ModuleId.SNAPSHOT, gmodule.notifyId.Snapshot.FEATURE_OPEN_CHANGE, self.OnSnapshotFeatureOpenChange, self)
end
def.override().AfterCreate = function(self)
  self:ShowActionDlg(self.m_UIGOs.Btn_Action)
end
def.override("boolean").OnShow = function(self, s)
  if s then
    if not self.m_firstOnShow then
      self:DestroyPanel()
      return
    end
    self.m_firstOnShow = false
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostDestroy, self.OnPanel_PostDestroy)
  Event.UnregisterEvent(ModuleId.SNAPSHOT, gmodule.notifyId.Snapshot.FEATURE_OPEN_CHANGE, self.OnSnapshotFeatureOpenChange)
  SnapshotModule.Instance():LeaveCaptureMode(self)
  self.m_UIGOs = nil
  self.m_neededCaptures = nil
  self.m_textColors = nil
  self.m_textSizes = nil
  self.m_textBGs = nil
  self.m_stickImages = nil
  self.m_imageFrames = nil
  self.m_draggedObj = nil
  self.m_dragStartOffset = nil
  self.m_activeImageStyle = ImageStyle.Default
  self.m_curPicturePath = nil
  self.m_lastMenuType = ""
  self.m_curMenuType = ""
  self.m_curTextColorIndex = 1
  self.m_curTextSizeIndex = 1
  self.m_curTextBGIndex = 1
  self.m_curStickImageIndex = 1
  self.m_curImageFrameIndex = 1
  self.m_textFrameInfos = nil
  self.m_firstOnShow = true
  self.m_photoUsedParams = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:OnClickCloseBtn(obj)
  elseif id == "Btn_Camera" then
    self:Snapshot()
  elseif id == "Btn_CameraShare" then
    self:SnapshotShare()
  elseif id == "Btn_CameraAgain" then
    self:ClearSnapshotDatas()
  elseif id == "Btn_Hide" then
    self:ShowOperateUI(false)
  elseif id == "Btn_Back" then
    self:ShowOperateUI(true)
  elseif id == "Texture_Captured" then
    if self.m_UIGOs.Btn_Hide:get_activeSelf() == false then
      self:ShowOperateUI(true)
    end
  elseif id == "Btn_Action" then
    self:OnClickActionBtn(obj)
  elseif id == "Btn_Style" then
    self:OnClickStyleBtn(obj)
  elseif id == "Btn_Label" then
    self:OnClickLabelBtn(obj)
  elseif id == "Btn_Img" then
    self:OnClickStickImageBtn(obj)
  elseif id == "Btn_Frame" then
    self:OnClickFrameBtn(obj)
  elseif id == "Btn_Color" then
    self:OnClickTextColorBtn()
  elseif id == "Btn_Size" then
    self:OnClickTextSizeBtn()
  elseif id == "Btn_Underframe" then
    self:OnClickTextFrameBGBtn()
  elseif id == "Btn_Default" then
    self:SetImageStyle(ImageStyle.Default)
  elseif id == "Btn_BW" then
    self:SetImageStyle(ImageStyle.Colorless)
  elseif id == "Btn_Ancients" then
    self:SetImageStyle(ImageStyle.Ancient)
  elseif id == "Btn_Gameshare" then
    self:OnClickGameShareBtn()
  elseif id == "Btn_Socialshare" then
    self:OnClickSocialShareBtn()
  elseif id == "Btn_Add" and obj.parent.name == "Btn_Label" then
    self:CreateTextFrameBySelect()
  elseif id:find("^item_%d+") then
    local index = tonumber(id:split("_")[2])
    local parentName = obj.parent.name
    if parentName == "List_Color" then
      self:OnClickTextColorItem(obj, index)
    elseif parentName == "List_Size" then
      self:OnClickTextSizeItem(obj, index)
    elseif parentName == "List_Item" then
      self:OnClickImageListItem(obj, index)
    end
  end
end
def.method().InitData = function(self)
  self.m_neededCaptures = {}
  self.m_textFrameInfos = {}
end
def.method().ResetTextFrameToDefault = function(self)
  local textColors = self:GetTextColors()
  if textColors and textColors.defaultIndex then
    self.m_curTextColorIndex = textColors.defaultIndex
  end
  local textSizes = self:GetTextSizes()
  if textSizes and textSizes.defaultIndex then
    self.m_curTextSizeIndex = textSizes.defaultIndex
  end
  local textBGs = self:GetTextBackgrounds()
  if textBGs and textBGs.defaultIndex then
    self.m_curTextBGIndex = textBGs.defaultIndex
  end
end
def.method().ResetImageFrameToDefault = function(self)
  local imageFrames = self:GetImageFrames()
  if imageFrames and imageFrames.defaultIndex then
    self.m_curImageFrameIndex = imageFrames.defaultIndex
  end
end
def.method().ResetStickImageToDefault = function(self)
  local stickImages = self:GetStickImages()
  if stickImages and stickImages.defaultIndex then
    self.m_curStickImageIndex = stickImages.defaultIndex
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_Btn = self.m_panel:FindDirect("Group_Btn")
  self.m_UIGOs.ScrollView_Menu = self.m_UIGOs.Group_Btn:FindDirect("Scroll View")
  self.m_UIGOs.Table_Menu = self.m_UIGOs.ScrollView_Menu:FindDirect("Table")
  self.m_UIGOs.UITable_Menu = self.m_UIGOs.Table_Menu:GetComponent("UITable")
  self:InitTableBtns()
  self.m_UIGOs.Btn_Camera = self.m_panel:FindDirect("Btn_Camera")
  self.m_UIGOs.Btn_CameraShare = self.m_panel:FindDirect("Btn_CameraShare")
  self.m_UIGOs.Btn_CameraAgain = self.m_panel:FindDirect("Btn_CameraAgain")
  self.m_UIGOs.Btn_Hide = self.m_panel:FindDirect("Btn_Hide")
  self.m_UIGOs.Btn_Back = self.m_panel:FindDirect("Btn_Back")
  self.m_UIGOs.Btn_Close = self.m_panel:FindDirect("Btn_Close")
  self.m_UIGOs.Camera_TipsCorner = self.m_panel:FindDirect("Camera_TipsCorner")
  self.m_UIGOs.Operation_LabelUnderframe = self.m_panel:FindDirect("Operation_LabelUnderframe")
  self.m_UIGOs.Operation_LabelColor = self.m_panel:FindDirect("Operation_LabelColor")
  self.m_UIGOs.Operation_LabelSize = self.m_panel:FindDirect("Operation_LabelSize")
  self.m_UIGOs.ImgBg_Label_Default = self.m_UIGOs.Operation_LabelUnderframe:FindDirect("Img_Bg")
  local Img_Select = self.m_UIGOs.Operation_LabelUnderframe:FindDirect("Img_Select")
  if Img_Select then
    local uiToggle = Img_Select:GetComponent("UIToggle")
    uiToggle:set_activeSprite(Img_Select:GetComponent("UIWidget"))
    uiToggle:set_optionCanBeNone(true)
  end
  self:InitInputTextUI(self.m_UIGOs.ImgBg_Label_Default, nil)
  self.m_UIGOs.Operation_Img = self.m_panel:FindDirect("Operation_Img")
  self.m_UIGOs.ScrollView_Img = self.m_UIGOs.Operation_Img:FindDirect("Scroll View")
  self.m_UIGOs.List_Img = self.m_UIGOs.ScrollView_Img:FindDirect("List_Item")
  self.m_UIGOs.Operation_Frame = self.m_panel:FindDirect("Operation_Frame")
  self.m_UIGOs.Operation_FrameImg = self.m_panel:FindDirect("Operation_FrameImg")
  self.m_UIGOs.Operation_BgImg = self.m_panel:FindDirect("Operation_BgImg")
  local TextureGO = self.m_UIGOs.Operation_BgImg:FindDirect("Texture")
  GUIUtils.AddBoxCollider(TextureGO)
  local Img_Select = self.m_UIGOs.Operation_BgImg:FindDirect("Img_Select")
  GUIUtils.SetActive(Img_Select, false)
  self.m_UIGOs.Group_Share = self.m_panel:FindDirect("Group_Share")
  self:InitForeverPanel()
  self:InitCapturedTextureComponent()
  self:InitGroupState()
  self:InitTextFrameGroup()
  self:InitStickImageGroup()
  self:InitUILists()
end
def.method("userdata", "userdata").InitInputTextUI = function(self, Img_Bg, originalImg_Bg)
  Img_Bg.name = "Img_BgLabel"
  local uiInput = Img_Bg:GetComponent("UIInput")
  if uiInput then
    uiInput:set_characterLimit(0)
    uiInput:set_defaultText(textRes.Snapshot[3])
  else
    warn(string.format("No UIInput Component found in text input frame!"))
  end
  local TextureGO = Img_Bg:FindDirect("Texture")
  local uiTexture = TextureGO:GetComponent("UITexture")
  local Label = Img_Bg:FindDirect("Texture/Label")
  local uiLabel
  if Label then
    uiLabel = Label:GetComponent("UILabel")
    local Overflow_ClampContent = 1
    uiLabel:set_overflowMethod(Overflow_ClampContent)
  else
    warn(string.format("No Label GameObject found in text input frame!"))
  end
  if originalImg_Bg then
    local originalUIInput = originalImg_Bg:GetComponent("UIInput")
    uiInput:set_value(originalUIInput:get_value())
    local originalTexture = originalImg_Bg:FindDirect("Texture")
    local originalUITexture = originalTexture:GetComponent("UITexture")
    uiTexture:set_depth(originalUITexture:get_depth())
    local originalUILabel = originalTexture:FindDirect("Label"):GetComponent("UILabel")
    uiLabel:set_depth(originalUILabel:get_depth())
    uiLabel:set_fontSize(originalUILabel:get_fontSize())
    uiLabel:set_textColor(originalUILabel:get_textColor())
    self:RecordLabelRelativeAnchor(Img_Bg)
    local originalLabelWidget = originalImg_Bg:GetComponent("UIWidget")
    local labelWidget = Img_Bg:GetComponent("UIWidget")
    labelWidget:set_depth(originalLabelWidget:get_depth())
    labelWidget:set_width(originalLabelWidget:get_width())
    labelWidget:set_height(originalLabelWidget:get_height())
    self:UpdateLabelRelativeAnchor(Img_Bg)
  else
    local textFrame = Img_Bg.parent
    local textSizes = self:GetTextSizes()
    if #textSizes > 0 then
      local defaultTextSize = textSizes.default
      uiLabel:set_fontSize(defaultTextSize)
      self:SetTextFrameInfo(textFrame, {textSize = defaultTextSize})
    end
    local textColors = self:GetTextColors()
    if #textColors > 0 then
      local defaultTextColor = textColors.default
      uiLabel:set_textColor(defaultTextColor)
      self:SetTextFrameInfo(textFrame, {textColor = defaultTextColor})
    end
    self:RecordLabelRelativeAnchor(Img_Bg)
  end
end
def.method().InitTableBtns = function(self)
  self.m_UIGOs.Btn_Action = self.m_UIGOs.Table_Menu:FindDirect("Btn_Action")
  self.m_UIGOs.Btn_Style = self.m_UIGOs.Table_Menu:FindDirect("Btn_Style")
  self.m_UIGOs.BtnGroup_Style = self.m_UIGOs.Table_Menu:FindDirect("BtnGroup_Style")
  self.m_UIGOs.Btn_Label = self.m_UIGOs.Table_Menu:FindDirect("Btn_Label")
  self.m_UIGOs.BtnGroup_Label = self.m_UIGOs.Table_Menu:FindDirect("BtnGroup_Label")
  self.m_UIGOs.Btn_Img = self.m_UIGOs.Table_Menu:FindDirect("Btn_Img")
  self.m_UIGOs.Btn_Frame = self.m_UIGOs.Table_Menu:FindDirect("Btn_Frame")
  self.m_UIGOs.Btn_Color = self.m_UIGOs.BtnGroup_Label:FindDirect("Btn_Color")
  self.m_UIGOs.Btn_Size = self.m_UIGOs.BtnGroup_Label:FindDirect("Btn_Size")
  self.m_UIGOs.Btn_Underframe = self.m_UIGOs.BtnGroup_Label:FindDirect("Btn_Underframe")
  local btns = {
    self.m_UIGOs.Btn_Color,
    self.m_UIGOs.Btn_Size,
    self.m_UIGOs.Btn_Underframe
  }
  for i, btn in ipairs(btns) do
    local uiToggle = btn:GetComponent("UIToggle")
    if uiToggle then
      uiToggle:set_optionCanBeNone(true)
    end
  end
  self.m_UIGOs.ToggleBtns = {
    self.m_UIGOs.Btn_Action,
    self.m_UIGOs.Btn_Style,
    self.m_UIGOs.Btn_Label,
    self.m_UIGOs.Btn_Img,
    self.m_UIGOs.Btn_Frame
  }
  for i, btn in ipairs(self.m_UIGOs.ToggleBtns) do
    local uiToggle = btn:GetComponent("UIToggle")
    if uiToggle then
      uiToggle:set_optionCanBeNone(true)
    end
  end
  local Btn_Default = self.m_UIGOs.BtnGroup_Style:FindDirect("Btn_Default")
  GUIUtils.Toggle(Btn_Default, true)
  local Btn_Cartoon = self.m_UIGOs.BtnGroup_Style:FindDirect("Btn_Cartoon")
  GUIUtils.SetActive(Btn_Cartoon, false)
end
def.method().InitForeverPanel = function(self)
  self.m_UIGOs.Panel_Forever = GameObject.GameObject("Panel_Forever")
  self.m_UIGOs.Panel_Forever.parent = self.m_panel
  self.m_UIGOs.Panel_Forever:set_layer(_G.ClientDef_Layer.UI_Forever)
  self.m_UIGOs.Panel_Forever.localScale = Vector.Vector3.one
  self.m_UIGOs.Panel_Forever.localPosition = Vector.Vector3.zero
  local foreverPanel = self.m_UIGOs.Panel_Forever:AddComponent("UIPanel")
  foreverPanel:set_depth(-1)
end
def.method().InitCapturedTextureComponent = function(self)
  local Texture_Captured = GameObject.GameObject("Texture_Captured")
  Texture_Captured:set_layer(_G.ClientDef_Layer.UI_Forever)
  Texture_Captured.parent = self.m_UIGOs.Panel_Forever
  Texture_Captured.localScale = Vector.Vector3.one
  Texture_Captured.localPosition = Vector.Vector3.zero
  local uiTexture = Texture_Captured:AddComponent("UITexture")
  local uiViewHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local uiViewWidth = uiViewHeight / Screen.height * Screen.width
  uiTexture:set_width(uiViewWidth + 2)
  uiTexture:set_height(uiViewHeight + 2)
  GUIUtils.AddBoxCollider(Texture_Captured)
  Texture_Captured:SetActive(false)
  self.m_UIGOs.Texture_Captured = Texture_Captured
  self.m_UIGOs.UITexture_Captured = uiTexture
end
def.method().InitGroupState = function(self)
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelUnderframe, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelColor, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelSize, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_Img, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_Frame, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_FrameImg, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_BgImg, false)
  GUIUtils.SetActive(self.m_UIGOs.Group_Share, false)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Hide, false)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Back, false)
end
def.method().InitTextFrameGroup = function(self)
  local go = GameObject.GameObject("TextFrameGroup")
  go.parent = self.m_panel
  go.localScale = Vector.Vector3.one
  go.localPosition = Vector.Vector3.zero
  self.m_UIGOs.Operation_LabelUnderframe.parent = go
  self.m_UIGOs.Operation_LabelUnderframe.name = "TextFrame_Template"
  self.m_UIGOs.TextFrameGroup = go
end
def.method().InitStickImageGroup = function(self)
  local go = GameObject.GameObject("StickImageGroup")
  go.parent = self.m_panel
  go.localScale = Vector.Vector3.one
  go.localPosition = Vector.Vector3.zero
  self.m_UIGOs.Operation_BgImg.parent = go
  self.m_UIGOs.Operation_BgImg.name = "StickImage_Template"
  self.m_UIGOs.StickImageGroup = go
end
def.method().InitUILists = function(self)
  local List_Img = self.m_UIGOs.List_Img
  local List_Color = self.m_UIGOs.Operation_LabelColor:FindDirect("Scroll View/List_Color")
  local List_Size = self.m_UIGOs.Operation_LabelSize:FindDirect("Scroll View/List_Size")
  for i, ListGO in ipairs({
    List_Img,
    List_Color,
    List_Size
  }) do
    local uiList = ListGO:GetComponent("UIList")
    local template = uiList:get_template()
    local uiToggle = template:GetComponent("UIToggle")
    if uiToggle then
      uiToggle:set_startsActive(false)
    end
  end
end
def.method().UpdateUI = function(self)
  self:UpdateBtns()
end
def.method("userdata").OnClickCloseBtn = function(self, obj)
  if obj.parent:IsEq(self.m_panel) then
    if self:HasCapturedTexture() then
      self:ClearSnapshotDatas()
    else
      self:DestroyPanel()
    end
  elseif obj.parent.name == "TextFrame" then
    self:DestroyTextFrame(obj.parent)
  elseif obj.parent.name == "StickImage" then
    self:DestroyStickImage(obj.parent)
  elseif obj.parent:IsEq(self.m_UIGOs.Group_Share) then
    self:HideShareGroup()
  end
end
def.method("=>", "boolean").HasCapturedTexture = function(self)
  if self.m_UIGOs.Texture_Captured == nil then
    return false
  end
  return self.m_UIGOs.Texture_Captured:get_activeSelf()
end
def.method("=>", "boolean").IsSharing = function(self)
  if self.m_UIGOs.Group_Share == nil then
    return false
  end
  return self.m_UIGOs.Group_Share:get_activeSelf()
end
def.method().Snapshot = function(self)
  self:SnapshotInner(function(filePath)
    self:OnCaptured(filePath)
  end, true)
  self:SendTLogToServer(_G.TLOGTYPE.SNAPSHOT_TAKE_PHTO, {})
end
def.method("string").OnCaptured = function(self, filePath)
  self.m_UIGOs.Texture_Captured:SetActive(true)
  GUIUtils.FillTextureFromLocalPath(self.m_UIGOs.Texture_Captured, filePath, function(uiTexture)
    local tex2d = uiTexture:get_mainTexture()
    if tex2d then
      tex2d:set_filterMode(FilterMode.Point)
    end
    self:UpdateBtns()
    self:CreateDefaultImageFrame()
  end)
end
def.method("function", "boolean").SnapshotInner = function(self, callback, isRaw)
  local neededCaptures = self:CalcNeededCaptureUIs()
  for i, v in ipairs(neededCaptures) do
    local uiWidget = v.go:GetComponent("UIWidget")
    if v.disableSelf then
      uiWidget:set_enabled(false)
    end
    v.go:set_layer(_G.ClientDef_Layer.UI_Forever)
    if v.parent then
      v.go.parent = self.m_UIGOs.Panel_Forever
    end
    uiWidget:ParentHasChanged()
  end
  SnapshotModule.Instance():CaptrueTheMomement({isRaw = isRaw}, function(ret, filePath)
    if not self:IsLoaded() then
      return
    end
    for i, v in ipairs(neededCaptures) do
      local uiWidget = v.go:GetComponent("UIWidget")
      if v.disableSelf then
        uiWidget:set_enabled(true)
      end
      v.go:set_layer(_G.ClientDef_Layer.UI)
      if v.parent then
        v.go.parent = v.parent
      end
      uiWidget:ParentHasChanged()
    end
    if ret == false then
      return
    end
    if callback then
      callback(filePath)
    end
  end)
end
def.method("=>", "table").CalcNeededCaptureUIs = function(self)
  local neededCaptures = {}
  local activeGO
  local function addToCaptures(relativePath, changeParent, disableSelf)
    local childGO = activeGO:FindDirect(relativePath)
    if childGO then
      table.insert(neededCaptures, {
        go = childGO,
        parent = changeParent and childGO.parent,
        disableSelf = disableSelf
      })
    end
  end
  local textFrames = self:GetAllTextFrames()
  for i, textFrame in ipairs(textFrames) do
    activeGO = textFrame
    if activeGO:get_activeSelf() then
      addToCaptures("Img_BgLabel", true, true)
      addToCaptures("Img_BgLabel/Texture")
      addToCaptures("Img_BgLabel/Texture/Label")
    end
  end
  local stickImages = self:GetAllStickImageGOs()
  for i, stickImage in ipairs(stickImages) do
    activeGO = stickImage
    if activeGO:get_activeSelf() then
      addToCaptures("Texture", true)
    end
  end
  activeGO = self.m_UIGOs.Operation_FrameImg
  if activeGO:get_activeSelf() then
    addToCaptures("Img_Frame", true)
  end
  return neededCaptures
end
def.method().UpdateBtns = function(self)
  local hasCapturedTexture = self:HasCapturedTexture()
  local isSharing = self:IsSharing()
  GUIUtils.SetActive(self.m_UIGOs.Btn_Camera, not hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Camera_TipsCorner, not hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_CameraShare, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_CameraAgain, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Action, not hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Style, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.BtnGroup_Style, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Label, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.BtnGroup_Label, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Img, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Frame, hasCapturedTexture and not isSharing)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Hide, hasCapturedTexture and not isSharing)
  self:SetMenuType("None")
end
def.method().ClearCapturedTexture = function(self)
  GUIUtils.SetTexture(self.m_UIGOs.Texture_Captured, 0)
  self.m_UIGOs.Texture_Captured:SetActive(false)
end
def.method().SnapshotShare = function(self)
  self:SnapshotInner(function(filePath)
    self.m_UIGOs.Group_Share:SetActive(true)
    self:GatherPhotoUsedParams()
    self:ClearSnapshotDatas()
    local Texture = self.m_UIGOs.Group_Share:FindDirect("Img_Bg/Texture")
    GUIUtils.FillTextureFromLocalPath(Texture, filePath, function(uiTexture)
      local uiVeiwHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
      local uiViewWidth = uiVeiwHeight / Screen.height * Screen.width
      local bgUIWidget = Texture.parent:GetComponent("UIWidget")
      bgUIWidget:set_width(uiViewWidth * 0.8)
      bgUIWidget:set_height(uiVeiwHeight * 0.8)
    end)
    local text = textRes.Snapshot[1]:format(filePath)
    PersonalHelper.SendOut(text)
    self.m_curPicturePath = filePath
  end, false)
end
def.method().GatherPhotoUsedParams = function(self)
  local stickImages = self:GetStickImages()
  local stickImage = stickImages[self.m_curStickImageIndex]
  local stickImageId = stickImage and stickImage.id or 0
  local imageFrames = self:GetImageFrames()
  local imageFrame = imageFrames[self.m_curImageFrameIndex]
  local imageFrameId = imageFrame and imageFrame.id or 0
  local textFrameNum = self:GetTextFrameNum()
  self.m_photoUsedParams = {}
  table.insert(self.m_photoUsedParams, stickImageId)
  table.insert(self.m_photoUsedParams, imageFrameId)
  table.insert(self.m_photoUsedParams, textFrameNum)
end
def.method().ClearSnapshotDatas = function(self)
  self:ClearTextFrames()
  self:ClearStickImages()
  self:ClearImageFrame()
  self:ClearCapturedTexture()
  self:UnselectAllToggleBtns()
  self:UpdateBtns()
end
def.method().UnselectAllToggleBtns = function(self)
  if self.m_UIGOs.ToggleBtns == nil then
    return
  end
  for i, btn in ipairs(self.m_UIGOs.ToggleBtns) do
    GUIUtils.Toggle(btn, false)
  end
end
def.method().HideShareGroup = function(self)
  local Texture = self.m_UIGOs.Group_Share:FindDirect("Img_Bg/Texture")
  GUIUtils.SetTexture(Texture, 0)
  self.m_UIGOs.Group_Share:SetActive(false)
  self:UpdateBtns()
end
def.method("userdata").OnClickActionBtn = function(self, obj)
  local isChecked = GUIUtils.IsToggle(obj)
  if isChecked then
    self:ShowActionDlg(obj)
  end
end
def.method("userdata").ShowActionDlg = function(self, btn)
  local dlg = require("Main.Chat.ui.DlgAction").Instance()
  local baseGO = btn:FindDirect("Label_Action")
  GUIUtils.Toggle(btn, true)
  if baseGO then
    local position = baseGO.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = baseGO:GetComponent("UIWidget")
    local pos = {
      auto = true,
      prefer = 0,
      tipType = "y"
    }
    pos.sourceX = screenPos.x
    pos.sourceY = screenPos.y - widget.height / 2
    pos.sourceW = widget.width
    pos.sourceH = widget.height
    dlg:ShowDlgAtPos(pos)
  else
    dlg:ShowDlg()
  end
end
def.method("userdata").OnClickStyleBtn = function(self, obj)
  local isChecked = GUIUtils.IsToggle(obj)
  if isChecked then
    self:SetMenuType("ImageStyle")
  else
    self:SetMenuType("None")
  end
end
def.method("userdata").OnClickLabelBtn = function(self, obj)
  local isChecked = GUIUtils.IsToggle(obj)
  if isChecked then
    if self:GetTextFrameNum() == 0 then
      self:CreateDefaultTextFrame()
    end
    self:SetMenuType("TextFrame")
  else
    self:SetMenuType("None")
  end
end
def.method("userdata").OnClickStickImageBtn = function(self, obj)
  local isChecked = GUIUtils.IsToggle(obj)
  if isChecked then
    if self:GetStickImageNum() == 0 then
      self:CreateDefaultStickImage()
    end
    self:SetMenuType("StickImage")
    self.m_selImageListType = ImageListType.StickImage
    self:UpdateStickImageList()
  else
    self:SetMenuType("None")
  end
end
def.method("userdata").OnClickFrameBtn = function(self, obj)
  local isChecked = GUIUtils.IsToggle(obj)
  if isChecked then
    self:SetMenuType("ImageFrame")
    self.m_selImageListType = ImageListType.ImageFrame
    self:UpdateImageFrameList()
  else
    self:SetMenuType("None")
  end
end
def.method().OnClickTextColorBtn = function(self)
  self:SetMenuType("TextFrame_Color")
  self:UpdateTextColorList()
end
def.method().OnClickTextSizeBtn = function(self)
  self:SetMenuType("TextFrame_Size")
  self:UpdateTextSizeList()
end
def.method().OnClickTextFrameBGBtn = function(self)
  self:SetMenuType("TextFrame_BG")
  self.m_selImageListType = ImageListType.TextFrameBG
  self:UpdateTextFrameList()
end
def.method().OnClickGameShareBtn = function(self)
  local ret = SnapshotModule.Instance():ShareToSocialSpace(self.m_curPicturePath)
  if ret == false then
    return
  end
  local shareType = 0
  local photoUsedParams = self.m_photoUsedParams or {}
  self:SendTLogToServer(_G.TLOGTYPE.SNAPSHOT_SHARE, {
    shareType,
    unpack(photoUsedParams)
  })
end
def.method().OnClickSocialShareBtn = function(self)
  SnapshotModule.Instance():ShareToSocialNetwork(self.m_curPicturePath)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local shareType
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      shareType = 1
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      shareType = 2
    end
    if shareType then
      local photoUsedParams = self.m_photoUsedParams or {}
      self:SendTLogToServer(_G.TLOGTYPE.SNAPSHOT_SHARE, {
        shareType,
        unpack(photoUsedParams)
      })
    end
  end
end
def.method("string").SetMenuType = function(self, menuType)
  self.m_lastMenuType = self.m_curMenuType
  self.m_curMenuType = menuType
  self:UpdateMenuSubItems()
end
def.method().UpdateMenuSubItems = function(self)
  local menuType = self.m_curMenuType
  GUIUtils.SetActive(self.m_UIGOs.BtnGroup_Style, self:IsMenuOpened(menuType, "ImageStyle"))
  GUIUtils.SetActive(self.m_UIGOs.BtnGroup_Label, self:IsMenuOpened(menuType, "TextFrame"))
  local canShow = self:IsMenuOpened(menuType, "StickImage") or self:IsMenuOpened(menuType, "TextFrame_BG") or self:IsMenuOpened(menuType, "ImageFrame")
  GUIUtils.SetActive(self.m_UIGOs.Operation_Img, canShow)
  GUIUtils.SetActive(self.m_UIGOs.Operation_Frame, false)
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelColor, self:IsMenuOpened(menuType, ""))
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelSize, self:IsMenuOpened(menuType, ""))
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelColor, self:IsMenuOpened(menuType, "TextFrame_Color"))
  GUIUtils.SetActive(self.m_UIGOs.Operation_LabelSize, self:IsMenuOpened(menuType, "TextFrame_Size"))
  self.m_UIGOs.UITable_Menu:Reposition()
  self:UpdateTextFrameAddBtn()
  self:UpdateTextFrameSubMenu()
  self:UpdateSelectedTextFrame()
end
def.method().UpdateTextColorList = function(self)
  local colors = self:GetTextColors()
  local List_Color = self.m_UIGOs.Operation_LabelColor:FindDirect("Scroll View/List_Color")
  local uiList = List_Color:GetComponent("UIList")
  self:SetUIList(uiList, colors, self.SetTextColorListItem)
  self:UpdateTextColorToggle()
end
def.method().UpdateTextColorToggle = function(self)
  local List_Color = self.m_UIGOs.Operation_LabelColor:FindDirect("Scroll View/List_Color")
  local itemGO = List_Color:FindDirect("item_" .. self.m_curTextColorIndex)
  if itemGO then
    GUIUtils.Toggle(itemGO, true)
    self:DragToMakeVisible(List_Color.parent, itemGO)
  end
end
def.method().UpdateTextSizeList = function(self)
  local sizes = self:GetTextSizes()
  local List_Size = self.m_UIGOs.Operation_LabelSize:FindDirect("Scroll View/List_Size")
  local uiList = List_Size:GetComponent("UIList")
  self:SetUIList(uiList, sizes, self.SetTextSizeListItem)
  self:UpdateTextSizeToggle()
end
def.method().UpdateTextSizeToggle = function(self)
  local List_Size = self.m_UIGOs.Operation_LabelSize:FindDirect("Scroll View/List_Size")
  local itemGO = List_Size:FindDirect("item_" .. self.m_curTextSizeIndex)
  if itemGO then
    GUIUtils.Toggle(itemGO, true)
    self:DragToMakeVisible(List_Size.parent, itemGO)
  end
end
def.method().UpdateTextFrameList = function(self)
  local textBGs = self:GetTextBackgrounds()
  local List_Img = self.m_UIGOs.List_Img
  local uiList = List_Img:GetComponent("UIList")
  self:SetUIList(uiList, textBGs, self.SetTextFrameListItem)
  self:UpdateTextFrameToggle()
end
def.method().UpdateTextFrameToggle = function(self)
  local List_Img = self.m_UIGOs.List_Img
  local itemGO = List_Img:FindDirect("item_" .. self.m_curTextBGIndex)
  if itemGO then
    GUIUtils.Toggle(itemGO, true)
    self:DragToMakeVisible(self.m_UIGOs.ScrollView_Img, itemGO)
  end
end
def.method().UpdateStickImageList = function(self)
  local stickImages = self:GetStickImages()
  local List_Img = self.m_UIGOs.List_Img
  local uiList = List_Img:GetComponent("UIList")
  self:SetUIList(uiList, stickImages, self.SetStickImageListItem)
  self:UpdateStickImageToggle()
end
def.method().UpdateStickImageToggle = function(self)
  local List_Img = self.m_UIGOs.List_Img
  local itemGO = List_Img:FindDirect("item_" .. self.m_curStickImageIndex)
  if itemGO then
    GUIUtils.Toggle(itemGO, true)
    self:DragToMakeVisible(self.m_UIGOs.ScrollView_Img, itemGO)
  end
end
def.method().UpdateImageFrameList = function(self)
  local imageFrames = self:GetImageFrames()
  local List_Img = self.m_UIGOs.List_Img
  local uiList = List_Img:GetComponent("UIList")
  self:SetUIList(uiList, imageFrames, self.SetImageFrameListItem)
  if #imageFrames > 0 then
    local itemGO = List_Img:FindDirect("item_" .. self.m_curImageFrameIndex)
    if itemGO then
      GUIUtils.Toggle(itemGO, true)
      self:DragToMakeVisible(self.m_UIGOs.ScrollView_Img, itemGO)
    end
  end
end
def.method("userdata").ResetScrollView = function(self, go)
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if _G.IsNil(go) then
        return
      end
      local uiScrollView = go:GetComponent("UIScrollView")
      uiScrollView:ResetPosition()
    end)
  end)
end
def.method("userdata", "userdata").DragToMakeVisible = function(self, scrollViewGO, itemGO)
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if _G.IsNil(itemGO) then
        return
      end
      local uiScrollView = scrollViewGO:GetComponent("UIScrollView")
      uiScrollView:DragToMakeVisible(itemGO.transform, 40)
    end)
  end)
end
def.method("userdata", "table", "function").SetUIList = function(self, uiList, items, onFillItemGO)
  local itemCount = #items
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local itemGOs = uiList.children
  for i, itemGO in ipairs(itemGOs) do
    if onFillItemGO then
      onFillItemGO(self, itemGO, items[i])
    end
  end
end
def.method("userdata", "userdata").SetTextColorListItem = function(self, itemGO, color)
  local Img_Color = itemGO:FindDirect("Img_Color")
  local uiWidget = Img_Color:GetComponent("UIWidget")
  uiWidget:set_color(color)
end
def.method("userdata", "number").SetTextSizeListItem = function(self, itemGO, size)
  local Label_Size = itemGO:FindDirect("Label_Size")
  GUIUtils.SetText(Label_Size, size)
end
def.method("userdata", "table").SetTextFrameListItem = function(self, itemGO, frame)
  local Img_Icon = itemGO:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, frame.iconId)
end
def.method("userdata", "table").SetStickImageListItem = function(self, itemGO, stickImage)
  local Img_Icon = itemGO:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, stickImage.iconId)
end
def.method("userdata", "table").SetImageFrameListItem = function(self, itemGO, imageFrame)
  local Img_Icon = itemGO:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, imageFrame.iconId)
end
def.method("userdata", "number").OnClickTextColorItem = function(self, itemGO, index)
  self.m_curTextColorIndex = index
  local color = self.m_textColors[index]
  self:SetInputTextColor(color)
end
def.method("userdata", "number").OnClickTextSizeItem = function(self, itemGO, index)
  self.m_curTextSizeIndex = index
  local size = self.m_textSizes[index]
  self:SetInputTextSize(size)
end
def.method("userdata", "number").OnClickImageListItem = function(self, itemGO, index)
  GUIUtils.Toggle(itemGO, true)
  if self.m_selImageListType == ImageListType.TextFrameBG then
    self.m_curTextBGIndex = index
    local textBG = self.m_textBGs[index]
    if self:GetTextFrameNum() > 0 then
      self:SetSelectedTextFrameBG(textBG.resId)
    else
      self:CreateTextFrame(nil, textBG.resId)
    end
  elseif self.m_selImageListType == ImageListType.StickImage then
    self.m_curStickImageIndex = index
    local stickImage = self.m_stickImages[index]
    local resId = stickImage.resId
    if 0 < self:GetStickImageNum() then
      self:SetSelectedStickImage(resId)
    else
      self:CreateStickImage(resId)
    end
  elseif self.m_selImageListType == ImageListType.ImageFrame then
    self.m_curImageFrameIndex = index
    local imageFrame = self.m_imageFrames[index]
    self:SetImageFrame(imageFrame.resId)
  end
end
def.method("userdata", "number").CreateTextFrame = function(self, template, bgResId)
  template = template or self.m_UIGOs.Operation_LabelUnderframe
  local frameNum = self:GetTextFrameNum()
  if frameNum >= MAX_TEXT_FRAME_NUM then
    Toast(textRes.Snapshot[4]:format(MAX_TEXT_FRAME_NUM))
    return
  end
  local textFrame = GameObject.Instantiate(template)
  textFrame:SetActive(true)
  textFrame:set_name("TextFrame")
  GUIUtils.SetParentAndResetTransform(textFrame, self.m_UIGOs.TextFrameGroup)
  self:CopyTextFrameInfo(template, textFrame)
  self:InitTextFramePosition(textFrame)
  self:UpdateTextFrameAddBtn()
  self:SetTextFrameBG(textFrame, bgResId)
  self:SelectTextFrame(textFrame)
end
def.method().CreateTextFrameBySelect = function(self)
  local textBGs = self:GetTextBackgrounds()
  local textBG = textBGs[self.m_curTextBGIndex]
  if _G.IsNil(self.m_UIGOs.selectedTextFrame) then
    self:CreateTextFrame(nil, textBG.resId)
  else
    self:CreateTextFrame(self.m_UIGOs.selectedTextFrame, textBG.resId)
  end
end
def.method().CreateDefaultTextFrame = function(self)
  self:ResetTextFrameToDefault()
  local textBGs = self:GetTextBackgrounds()
  local textBG = textBGs[self.m_curTextBGIndex]
  self:CreateTextFrame(nil, textBG.resId)
end
def.method("userdata", "table").SetTextFrameInfo = function(self, textFrame, info)
  if textFrame == nil then
    return
  end
  local instanceId = textFrame:GetInstanceID()
  if info == nil then
    self.m_textFrameInfos[instanceId] = nil
    return
  end
  local textFrameInfo = self.m_textFrameInfos[instanceId] or {}
  if info.textSize then
    textFrameInfo.textSize = info.textSize
  end
  if info.textColor then
    textFrameInfo.textColor = info.textColor
  end
  if info.bgResId then
    textFrameInfo.bgResId = info.bgResId
  end
  self.m_textFrameInfos[instanceId] = textFrameInfo
end
def.method("userdata", "=>", "table").GetTextFrameInfo = function(self, textFrame)
  if textFrame == nil then
    return nil
  end
  local instanceId = textFrame:GetInstanceID()
  return self.m_textFrameInfos[instanceId]
end
def.method("userdata", "userdata").CopyTextFrameInfo = function(self, fromTextFrame, toTextFrame)
  local textFrameInfo = self:GetTextFrameInfo(fromTextFrame)
  if textFrameInfo == nil then
    return
  end
  self:SetTextFrameInfo(toTextFrame, textFrameInfo)
end
def.method("userdata").InitTextFramePosition = function(self, textFrame)
  local childCount = self.m_UIGOs.TextFrameGroup:get_childCount()
  if childCount - 2 < 0 then
    return
  end
  local lastTextFrame = self.m_UIGOs.TextFrameGroup:GetChild(childCount - 2)
  local lastPos = lastTextFrame.localPosition
  local nextPos = Vector3.new(lastPos.x + 40, lastPos.y + 40, 0)
  textFrame:set_localPosition(nextPos)
end
def.method("=>", "number").GetTextFrameNum = function(self)
  local childCount = self.m_UIGOs.TextFrameGroup:get_childCount()
  return childCount - 1
end
def.method("=>", "table").GetAllTextFrames = function(self)
  local childCount = self.m_UIGOs.TextFrameGroup:get_childCount()
  local textFrames = {}
  for i = 1, childCount - 1 do
    local textFrame = self.m_UIGOs.TextFrameGroup:GetChild(i)
    textFrames[i] = textFrame
  end
  return textFrames
end
def.method("userdata", "number").SetTextFrameBG = function(self, textFrame, resId)
  self:SetTextFrameInfo(textFrame, {bgResId = resId})
  if resId == 0 then
    self:ResetTextFrameBG(textFrame)
    return
  end
  local resPath = _G.GetIconPath(resId)
  if resPath == "" then
    return
  end
  GameUtil.AsyncLoad(resPath, function(asset)
    if not self:IsLoaded() then
      return
    end
    if asset == nil then
      return
    end
    local newImgBg = GameObject.Instantiate(asset)
    self:ReplaceTextFrameBG(textFrame, newImgBg)
  end)
end
def.method("number").SetSelectedTextFrameBG = function(self, resId)
  if _G.IsNil(self.m_UIGOs.selectedTextFrame) then
    Toast(textRes.Snapshot[6])
    return
  end
  self:SetTextFrameBG(self.m_UIGOs.selectedTextFrame, resId)
end
def.method("userdata").ResetTextFrameBG = function(self, textFrame)
  local newImgBg = GameObject.Instantiate(self.m_UIGOs.ImgBg_Label_Default)
  self:ReplaceTextFrameBG(textFrame, newImgBg)
end
def.method().ClearTextFrames = function(self)
  self.m_UIGOs.selectedTextFrame = nil
  local textFrames = self:GetAllTextFrames()
  for i, textFrame in ipairs(textFrames) do
    self:DestroyTextFrame(textFrame)
  end
end
def.method("userdata").DestroyTextFrame = function(self, textFrame)
  if self.m_UIGOs and self.m_UIGOs.selectedTextFrame and self.m_UIGOs.selectedTextFrame:IsEq(textFrame) then
    self:AutoSelectTextFrameExcept(textFrame)
  end
  self:SetTextFrameInfo(textFrame, nil)
  GameObject.DestroyImmediate(textFrame)
  self:UpdateTextFrameAddBtn()
end
def.method("userdata").AutoSelectTextFrameExcept = function(self, exceptTextFrame)
  local textFrames = self:GetAllTextFrames()
  local nextSelectTextFrame
  for i = #textFrames, 1, -1 do
    local textFrame = textFrames[i]
    if exceptTextFrame == nil or not textFrame:IsEq(exceptTextFrame) then
      nextSelectTextFrame = textFrame
      break
    end
  end
  self:SelectTextFrame(nextSelectTextFrame)
end
def.method("userdata", "userdata").ReplaceTextFrameBG = function(self, textFrame, newImgBg)
  local Img_BgLabel = textFrame:FindDirect("Img_BgLabel")
  if Img_BgLabel:IsEq(newImgBg) then
    return
  end
  GUIUtils.SetParentAndResetTransform(newImgBg, textFrame)
  local Btn_Close = textFrame:FindDirect("Btn_Close")
  local Btn_Translate = textFrame:FindDirect("Btn_Translate")
  local Btn_Drag = textFrame:FindDirect("Btn_Drag")
  local Btn_D1 = textFrame:FindDirect("Btn_D1")
  local Img_Select = textFrame:FindDirect("Img_Select")
  local function changeAnchor(go)
    local uiRect = go:GetComponent("UIRect")
    if uiRect then
      uiRect:SetAnchor_2(newImgBg)
    end
  end
  changeAnchor(Btn_Close)
  changeAnchor(Btn_Translate)
  changeAnchor(Btn_Drag)
  changeAnchor(Btn_D1)
  changeAnchor(Img_Select)
  self:InitInputTextUI(newImgBg, Img_BgLabel)
  Img_BgLabel.name = "_Img_BgLabel"
  GameObject.Destroy(Img_BgLabel)
end
def.method().UpdateTextFrameAddBtn = function(self)
  local isTextFrameMenuOpen = self:IsMenuOpened(self.m_curMenuType, "TextFrame")
  local Btn_Add = self.m_UIGOs.Btn_Label:FindDirect("Btn_Add")
  if not isTextFrameMenuOpen then
    Btn_Add:SetActive(false)
    return
  end
  local frameNum = self:GetTextFrameNum()
  local canShow = frameNum < MAX_TEXT_FRAME_NUM
  Btn_Add:SetActive(canShow)
end
def.method().UpdateTextFrameSubMenu = function(self)
  local isTextFrameMenuOpen = self:IsMenuOpened(self.m_curMenuType, "TextFrame")
  if not isTextFrameMenuOpen then
    return
  end
  GUIUtils.Toggle(self.m_UIGOs.Btn_Color, self:IsMenuOpened(self.m_curMenuType, "TextFrame_Color"))
  GUIUtils.Toggle(self.m_UIGOs.Btn_Size, self:IsMenuOpened(self.m_curMenuType, "TextFrame_Size"))
  GUIUtils.Toggle(self.m_UIGOs.Btn_Underframe, self:IsMenuOpened(self.m_curMenuType, "TextFrame_BG"))
end
def.method("userdata").SelectTextFrame = function(self, textFrame)
  local isTextFrameMenuOpen = self:IsMenuOpened(self.m_curMenuType, "TextFrame")
  if not isTextFrameMenuOpen then
    return
  end
  self.m_UIGOs.selectedTextFrame = textFrame
  if textFrame == nil then
    self:ResetTextFrameToDefault()
    self:UpdateTextSizeToggle()
    self:UpdateTextColorToggle()
    self:UpdateTextFrameToggle()
    return
  end
  local Img_Select = textFrame:FindDirect("Img_Select")
  local isSelected = true
  GUIUtils.Toggle(Img_Select, isSelected)
  local textFrameInfo = self:GetTextFrameInfo(textFrame)
  if textFrameInfo then
    local textSizes = self:GetTextSizes()
    local sizeIndex
    for index, textSize in pairs(textSizes) do
      if textSize == textFrameInfo.textSize then
        sizeIndex = index
        break
      end
    end
    if sizeIndex and sizeIndex ~= self.m_curTextSizeIndex then
      self.m_curTextSizeIndex = sizeIndex
      self:UpdateTextSizeToggle()
    end
    local textColors = self:GetTextColors()
    local colorIndex
    for index, textColor in pairs(textColors) do
      if textColor == textFrameInfo.textColor then
        colorIndex = index
        break
      end
    end
    if colorIndex and colorIndex ~= self.m_curTextColorIndex then
      self.m_curTextColorIndex = colorIndex
      self:UpdateTextColorToggle()
    end
    local textBGs = self:GetTextBackgrounds()
    local bgIndex
    for index, textBG in ipairs(textBGs) do
      if textBG.resId == textFrameInfo.bgResId then
        bgIndex = index
        break
      end
    end
    if bgIndex and bgIndex ~= self.m_curTextBGIndex then
      self.m_curTextBGIndex = bgIndex
      self:UpdateTextFrameToggle()
    end
  end
end
def.method("userdata").UnSelectTextFrame = function(self, textFrame)
  self.m_UIGOs.selectedTextFrame = nil
  if textFrame == nil then
    return
  end
  local Img_Select = textFrame:FindDirect("Img_Select")
  local isSelected = false
  GUIUtils.Toggle(Img_Select, isSelected)
end
def.method().UpdateSelectedTextFrame = function(self)
  local isTextFrameMenuOpen = self:IsMenuOpened(self.m_curMenuType, "TextFrame")
  if not isTextFrameMenuOpen then
    self:UnSelectTextFrame(self.m_UIGOs.selectedTextFrame)
    return
  end
  if _G.IsNil(self.m_UIGOs.selectedTextFrame) then
    self:AutoSelectTextFrameExcept(nil)
  end
end
def.method("number").SetInputTextSize = function(self, size)
  if _G.IsNil(self.m_UIGOs.selectedTextFrame) then
    Toast(textRes.Snapshot[6])
    return
  end
  local Img_BgLabel = self.m_UIGOs.selectedTextFrame:FindDirect("Img_BgLabel")
  local Label = Img_BgLabel:FindDirect("Texture/Label")
  local uiLabel = Label:GetComponent("UILabel")
  uiLabel:set_fontSize(size)
  self:SetTextFrameInfo(self.m_UIGOs.selectedTextFrame, {textSize = size})
end
def.method("userdata").SetInputTextColor = function(self, color)
  if _G.IsNil(self.m_UIGOs.selectedTextFrame) then
    Toast(textRes.Snapshot[6])
    return
  end
  local Img_BgLabel = self.m_UIGOs.selectedTextFrame:FindDirect("Img_BgLabel")
  local Label = Img_BgLabel:FindDirect("Texture/Label")
  local uiLabel = Label:GetComponent("UILabel")
  uiLabel:set_textColor(color)
  self:SetTextFrameInfo(self.m_UIGOs.selectedTextFrame, {textColor = color})
end
def.method("number").CreateStickImage = function(self, resId)
  if resId == 0 then
    return
  end
  local stickImageNum = self:GetStickImageNum()
  if stickImageNum >= MAX_STICK_IMAGE_NUM then
    Toast(textRes.Snapshot[5]:format(MAX_STICK_IMAGE_NUM))
    return
  end
  local stickImage = GameObject.Instantiate(self.m_UIGOs.Operation_BgImg)
  stickImage:SetActive(true)
  stickImage:set_name("StickImage")
  GUIUtils.SetParentAndResetTransform(stickImage, self.m_UIGOs.StickImageGroup)
  self:InitStickImagePosition(stickImage)
  self:SetStickImage(stickImage, resId)
  self:SelectStickImage(stickImage)
end
def.method().CreateDefaultStickImage = function(self)
  self:ResetStickImageToDefault()
  local index = self.m_curStickImageIndex
  local stickImage = self.m_stickImages[index]
  local resId = stickImage and stickImage.resId or 0
  self:CreateStickImage(resId)
end
def.method("=>", "number").GetStickImageNum = function(self)
  local childCount = self.m_UIGOs.StickImageGroup:get_childCount()
  return childCount - 1
end
def.method("=>", "table").GetAllStickImageGOs = function(self)
  local childCount = self.m_UIGOs.StickImageGroup:get_childCount()
  local stickImages = {}
  for i = 1, childCount - 1 do
    local stickImage = self.m_UIGOs.StickImageGroup:GetChild(i)
    stickImages[i] = stickImage
  end
  return stickImages
end
def.method("userdata").InitStickImagePosition = function(self, stickImage)
  local childCount = self.m_UIGOs.StickImageGroup:get_childCount()
  if childCount - 2 < 0 then
    return
  end
  local lastStickImage = self.m_UIGOs.StickImageGroup:GetChild(childCount - 2)
  local lastPos = lastStickImage.localPosition
  local nextPos = Vector3.new(lastPos.x + 20, lastPos.y + 20, 0)
  stickImage:set_localPosition(nextPos)
end
def.method("userdata", "number").SetStickImage = function(self, stickImage, resId)
  if resId == 0 then
    self:DestroyStickImage(stickImage)
    return
  end
  local Texture = stickImage:FindDirect("Texture")
  stickImage:SetActive(false)
  GUIUtils.SetTexture(Texture, resId, function(uiTexture)
    stickImage:SetActive(true)
    uiTexture:MakePixelPerfect()
  end)
end
def.method("number").SetSelectedStickImage = function(self, resId)
  if _G.IsNil(self.m_UIGOs.selectedStickImage) then
    return
  end
  self:SetStickImage(self.m_UIGOs.selectedStickImage, resId)
end
def.method("userdata").DestroyStickImage = function(self, stickImage)
  if self.m_UIGOs.selectedStickImage then
    self.m_UIGOs.selectedStickImage = nil
    self.m_curStickImageIndex = 1
    self:UpdateStickImageToggle()
  end
  GameObject.Destroy(stickImage)
end
def.method().ClearStickImages = function(self)
  self.m_UIGOs.selectedStickImage = nil
  self.m_curStickImageIndex = 1
  local stickImages = self:GetAllStickImageGOs()
  for i, stickImage in ipairs(stickImages) do
    self:DestroyStickImage(stickImage)
  end
end
def.method("userdata").SelectStickImage = function(self, stickImage)
  self.m_UIGOs.selectedStickImage = stickImage
end
def.method("number").SetImageStyle = function(self, imageStyle)
  self.m_activeImageStyle = imageStyle
  local styleDef = ImageStyleDef[imageStyle]
  if styleDef.class == ImageStyleClass.ColorCorrect then
    self:ApplyColorCorrect(self.m_UIGOs.UITexture_Captured, styleDef)
  end
end
def.method("number").SetImageFrame = function(self, resId)
  local hasSprite = resId ~= 0
  self.m_UIGOs.Operation_FrameImg:SetActive(hasSprite)
  if not hasSprite then
    return
  end
  local Img_Frame = self.m_UIGOs.Operation_FrameImg:FindDirect("Img_Frame")
  local uiSprite = Img_Frame:GetComponent("UISprite")
  GUIUtils.FillSprite(uiSprite, resId, nil)
  local uiWidget = uiSprite
  local uiVeiwHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local uiViewWidth = uiVeiwHeight / Screen.height * Screen.width
  uiWidget:set_width(uiViewWidth + 2)
  uiWidget:set_height(uiVeiwHeight + 2)
end
def.method().CreateDefaultImageFrame = function(self)
  self:ResetImageFrameToDefault()
  local index = self.m_curImageFrameIndex
  local imageFrame = self.m_imageFrames[index]
  local resId = imageFrame and imageFrame.resId or 0
  self:SetImageFrame(resId)
end
def.method().ClearImageFrame = function(self)
  self:SetImageFrame(0)
  self:ResetImageFrameToDefault()
end
def.method("string", "string", "=>", "boolean").IsMenuOpened = function(self, menuType, matchName)
  if menuType:find("^" .. matchName, 1, false) then
    return true
  else
    return false
  end
end
def.method("userdata", "boolean").onPressObj = function(self, obj, bPress)
  local id = obj.name
  if bPress then
    if id == "Img_BgLabel" then
      self:SelectTextFrame(obj.parent)
    elseif id == "Btn_Drag" and obj.parent.name == "TextFrame" then
      self:SelectTextFrame(obj.parent)
    elseif id == "Btn_Translate" and obj.parent.name == "TextFrame" then
      self:SelectTextFrame(obj.parent)
    elseif id == "Btn_D1" and obj.parent.name == "TextFrame" then
      self:SelectTextFrame(obj.parent)
    end
  end
end
def.method("string").onDragStart = function(self, id)
  self.m_draggedObj = UICamera.get_selectedObject()
  if id == "Btn_D1" then
    self.m_dragStartOffset = self.m_draggedObj.parent.position - UICamera.lastWorldPosition
  else
    self.m_dragStartOffset = self.m_draggedObj.position - UICamera.lastWorldPosition
  end
end
def.method("string").onDragEnd = function(self, id)
  self.m_draggedObj = nil
  self.m_dragStartOffset = nil
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if _G.IsNil(self.m_draggedObj) then
  end
  local obj = self.m_draggedObj
  if id == "Img_BgLabel" then
    self:FollowDrag(obj.parent, obj)
  elseif id == "Btn_Drag" and obj then
    if obj.parent.name == "TextFrame" then
      self:FollowRotate(obj.parent, obj, dx, dy)
    elseif obj.parent.name == "StickImage" then
      self:FollowRotate(obj.parent, obj, dx, dy)
    end
  elseif id == "Btn_D1" and obj and obj.parent.name == "TextFrame" then
    local Img_BgLabel = obj.parent:FindDirect("Img_BgLabel")
    self:FollowDrag(obj.parent, Img_BgLabel)
  elseif id == "Btn_D1" and obj and obj.parent.name == "StickImage" then
    local Texture = obj.parent:FindDirect("Texture")
    self:FollowDrag(obj.parent, Texture)
  elseif id == "Btn_Translate" then
    local operationGroup = obj.parent
    if operationGroup.name == "TextFrame" then
      local Img_BgLabel = operationGroup:FindDirect("Img_BgLabel")
      if Img_BgLabel then
        local uiWidget = Img_BgLabel:GetComponent("UIWidget")
        local Btn_Drag = obj
        local btnDir = Btn_Drag.localPosition - Img_BgLabel.localPosition
        local dragDir = Vector3.new(dx, dy, 0)
        local widgetTransform = Img_BgLabel.transform
        local xAxisT = widgetTransform:TransformDirection(Vector3.right)
        local yAxisT = widgetTransform:TransformDirection(Vector3.up)
        local dxT = dragDir:Dot(xAxisT) * (0 <= btnDir.x and 1 or -1)
        local dyT = dragDir:Dot(yAxisT) * (0 <= btnDir.y and 1 or -1)
        self:ChangeWidgetSize(uiWidget, dxT, dyT)
        self:UpdateLabelRelativeAnchor(Img_BgLabel)
      end
    end
  elseif id == "Texture" and obj and obj.parent.name == "StickImage" then
    self:FollowDrag(obj.parent, obj)
  end
end
def.method("userdata", "userdata").FollowDrag = function(self, transformGO, calcSizeGO)
  transformGO.position = UICamera.lastWorldPosition + self.m_dragStartOffset
  local pos = GUIUtils.CalcUIWidgetInScreenPos(calcSizeGO)
  transformGO.position = Vector.Vector3.new(pos.x, pos.y, 0)
end
def.method("userdata", "userdata", "number", "number").FollowRotate = function(self, targetGO, dragGO, dx, dy)
  local touchAxisDir = UICamera.lastWorldPosition - targetGO.position
  touchAxisDir:Normalize()
  local dragGODir = dragGO.localPosition
  dragGODir:Normalize()
  local rotateDegree = dragGODir:Angle(touchAxisDir)
  local crossDir = dragGODir:Cross(touchAxisDir)
  local rotateDir = crossDir.z >= 0 and 1 or -1
  targetGO.localRotation = Quaternion.Euler(Vector.Vector3.new(0, 0, rotateDir * rotateDegree))
end
def.method("userdata", "table").ApplyColorCorrect = function(self, uiTexture, styleDef)
  GameUtil.AsyncLoad(styleDef.LUTTexture, function(ass)
    if ass == nil then
      return
    end
    local tex2d = GUIUtils.ConvertTexture2DAssets(ass)
    if tex2d == nil then
      return
    end
    GameUtil.AsyncLoad(RESPATH.SHADER_COLOR_CORRECT, function(shader)
      if shader == nil then
        return
      end
      if not self:IsLoaded() then
        return
      end
      local newMat = Material.Material(shader)
      newMat:SetTexture("_LUT", tex2d)
      uiTexture:set_material(newMat)
    end)
  end)
end
def.method("userdata").RecordLabelRelativeAnchor = function(self, Img_BgLabel)
  local Label = Img_BgLabel:FindDirect("Texture/Label")
  local bgWidget = Img_BgLabel:GetComponent("UIWidget")
  local labelWidget = Label:GetComponent("UIWidget")
  local relativeX = Label.localPosition.x / bgWidget.width
  local relativeY = Label.localPosition.y / bgWidget.height
  local relativeW = labelWidget.width / bgWidget.width
  local relativeH = labelWidget.height / bgWidget.height
  local labelAnchor = {}
  labelAnchor.x = relativeX
  labelAnchor.y = relativeY
  labelAnchor.w = relativeW
  labelAnchor.h = relativeH
  local instanceId = Img_BgLabel:GetInstanceID()
  self.m_UIGOs.LabelAnchors = self.m_UIGOs.LabelAnchors or {}
  self.m_UIGOs.LabelAnchors[instanceId] = labelAnchor
end
def.method("userdata").UpdateLabelRelativeAnchor = function(self, Img_BgLabel)
  if self.m_UIGOs == nil then
    return
  end
  if self.m_UIGOs.LabelAnchors == nil then
    return
  end
  local instanceId = Img_BgLabel:GetInstanceID()
  local labelAnchor = self.m_UIGOs.LabelAnchors[instanceId]
  if labelAnchor == nil then
    return
  end
  local Label = Img_BgLabel:FindDirect("Texture/Label")
  local bgWidget = Img_BgLabel:GetComponent("UIWidget")
  local labelWidget = Label:GetComponent("UIWidget")
  Label.localPosition = Vector3.new(bgWidget.width * labelAnchor.x, bgWidget.height * labelAnchor.y, 0)
  labelWidget.width = bgWidget.width * labelAnchor.w
  labelWidget.height = bgWidget.height * labelAnchor.h
end
def.method("userdata").UnRecordLabelRelativeAnchor = function(self, Img_BgLabel)
  if self.m_UIGOs == nil then
    return
  end
  if self.m_UIGOs.LabelAnchors == nil then
    return
  end
  local instanceId = Img_BgLabel:GetInstanceID()
  self.m_UIGOs.LabelAnchors[instanceId] = nil
end
def.method("boolean").ShowOperateUI = function(self, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Group_Btn, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Btn_CameraShare, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Btn_CameraAgain, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Close, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Hide, isShow)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Back, not isShow)
  if isShow then
    self:SetMenuType(self.m_lastMenuType)
  else
    self:SetMenuType("None")
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if id == "Img_BgLabel" then
    local obj = UICamera.get_selectedObject()
    local uiInput = obj:GetComponent("UIInput")
    if uiInput then
      val = _G.TrimIllegalChar(val)
      local filteredVal = SensitiveWordsFilter.FilterContent(val, "*")
      uiInput:set_value(filteredVal)
    end
  end
end
def.method("userdata", "number", "number").LocalTranslate = function(self, go, dx, dy)
  go.localPosition = go.localPosition + Vector.Vector3.new(dx, dy, 0)
end
def.method("userdata", "number", "number").ChangeWidgetSize = function(self, uiWidget, dx, dy)
  local uiVeiwHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local uiViewWidth = uiVeiwHeight / Screen.height * Screen.width
  if dx < 0 or uiWidget.width < uiViewWidth * 2 / 3 then
    uiWidget.width = uiWidget.width + dx
  end
  if dy < 0 or uiWidget.height < uiVeiwHeight * 2 / 3 then
    uiWidget.height = uiWidget.height + dy
  end
end
def.method("=>", "table").GetTextColors = function(self)
  if self.m_textColors == nil then
    local colors = {}
    local colorCfgs = SnapshotUtils.GetAllFontColorCfgs()
    for i, colorCfg in ipairs(colorCfgs) do
      local colorId = colorCfg.fontColor
      colors[i] = _G.GetColorData(colorId)
      if i == 1 or colorCfg.isDefault then
        colors.default = colors[i]
        colors.defaultIndex = i
      end
    end
    self.m_textColors = colors
  end
  return self.m_textColors
end
def.method("=>", "table").GetTextSizes = function(self)
  if self.m_textSizes == nil then
    local sizes = {}
    local sizeCfgs = SnapshotUtils.GetAllFontSizeCfgs()
    for i, sizeCfg in ipairs(sizeCfgs) do
      sizes[i] = sizeCfg.fontSize
      if i == 1 or sizeCfg.isDefault then
        sizes.default = sizes[i]
        sizes.defaultIndex = i
      end
    end
    self.m_textSizes = sizes
  end
  return self.m_textSizes
end
def.method("=>", "table").GetTextBackgrounds = function(self)
  if self.m_textBGs == nil then
    local textBGs = {}
    local textBgCfgs = SnapshotUtils.GetAllTextBackgroundCfgs()
    for i, textBgCfg in ipairs(textBgCfgs) do
      local textBG = {}
      textBG.iconId = textBgCfg.iconId
      textBG.resId = textBgCfg.resId
      textBGs[i] = textBG
      if i == 1 or textBgCfg.isDefault then
        textBGs.default = textBG
        textBGs.defaultIndex = i
      end
    end
    self.m_textBGs = textBGs
  end
  return self.m_textBGs
end
def.method("=>", "table").GetStickImages = function(self)
  if self.m_stickImages == nil then
    local stickImages = {}
    local cfgs = SnapshotUtils.GetAllStickImageCfgs()
    for i, cfg in ipairs(cfgs) do
      local stickImage = {}
      stickImage.id = cfg.id
      stickImage.iconId = cfg.iconId
      stickImage.resId = cfg.resId
      stickImages[i] = stickImage
      if i == 1 or cfg.isDefault then
        stickImages.default = stickImage
        stickImages.defaultIndex = i
      end
    end
    self.m_stickImages = stickImages
  end
  return self.m_stickImages
end
def.method("=>", "table").GetImageFrames = function(self)
  if self.m_imageFrames == nil then
    local imageFrames = {}
    local cfgs = SnapshotUtils.GetAllImageFrameCfgs()
    for i, cfg in ipairs(cfgs) do
      local imageFrame = {}
      imageFrame.id = cfg.id
      imageFrame.iconId = cfg.iconId
      imageFrame.resId = cfg.resId
      imageFrames[i] = imageFrame
      if i == 1 or cfg.isDefault then
        imageFrames.default = imageFrame
        imageFrames.defaultIndex = i
      end
    end
    self.m_imageFrames = imageFrames
  end
  return self.m_imageFrames
end
def.method("=>", "table").GetImageStyles = function(self)
  local imageStyles = {
    {spriteName = ""}
  }
  return imageStyles
end
def.method("table").OnPanel_PostDestroy = function(self, params)
  local panel = params[2]
  local dlg = require("Main.Chat.ui.DlgAction").Instance()
  if panel ~= dlg then
    return
  end
  GUIUtils.Toggle(self.m_UIGOs.Btn_Action, false)
end
def.method("table").OnSnapshotFeatureOpenChange = function(self, params)
  if not SnapshotModule.Instance():IsFeatureOpen() then
    self:DestroyPanel()
  end
end
def.method("string", "table").SendTLogToServer = function(self, tlogType, params)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(tlogType, params)
end
return SnapshotPanel.Commit()
