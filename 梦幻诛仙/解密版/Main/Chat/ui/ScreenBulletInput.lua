local Lplus = require("Lplus")
warn("requirs:ScreenBulletInput", debug.traceback())
local ECPanelBase = require("GUI.ECPanelBase")
local ScreenBulletInput = Lplus.Extend(ECPanelBase, "ScreenBulletInput")
local DanmuInputViewCtrl = require("Main.Chat.ui.DanmuInputViewCtrl")
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local ScreenBullet = require("Main.Chat.ui.ScreenBullet")
local Vector = require("Types.Vector")
local def = ScreenBulletInput.define
local instance
def.field("table").inputViewCtrl = nil
def.field("boolean").emojiInit = false
def.field("number").emojiPage = 12
def.static("=>", ScreenBulletInput).Instance = function()
  if instance == nil then
    instance = ScreenBulletInput()
    instance.m_TrigGC = true
  end
  return instance
end
def.static().ShowScreenBulletInput = function(type, subType)
  local self = ScreenBulletInput.Instance()
  if not self:IsShow() then
    self:CreatePanel(RESPATH.PREFAB_DANMU_INPUT, 0)
  end
end
def.static().CloseScreenBulletInput = function()
  local self = ScreenBulletInput.Instance()
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  ChatInputDlg.Instance():Load()
  self.inputViewCtrl = DanmuInputViewCtrl()
  local inputNode = self.m_panel:FindDirect("Img_Input/Group_Input")
  self.inputViewCtrl:Init(self, inputNode, ScreenBulletInput.submitDelegate, ScreenBulletInput.voiceDelegate)
  local btnToggole = self.m_panel:FindDirect("Btn_DanMu"):GetComponent("UIToggle")
  btnToggole.value = true
  local selectToggle = self.m_panel:FindDirect("Img_Input/Toggle_Open"):GetComponent("UIToggle")
  selectToggle.value = true
  self:SetSwitchIcon(false)
  local emojiGO = self.m_panel:FindDirect("Img_Input/Group_Emoji")
  emojiGO:SetActive(false)
end
def.override().OnDestroy = function(self)
end
def.static("string", "=>", "boolean").submitDelegate = function(content)
  local ScreenBulletMgr = require("Main.Chat.ScreenBulletMgr")
  return ScreenBulletMgr.Instance():SendMapBullet(content)
end
def.static("table").voiceDelegate = function(speechMgr)
end
def.method("boolean").SetSwitchIcon = function(self, active)
  local switch = self.m_panel:FindDirect("Container/Img_Off")
  switch:SetActive(active)
end
def.method().ToggleEmoji = function(self)
  local emojiGO = self.m_panel:FindDirect("Img_Input/Group_Emoji")
  if emojiGO:get_activeInHierarchy() then
    emojiGO:SetActive(false)
    local pages = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01")
    while pages:get_childCount() > 1 do
      Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
    end
    local emojiGrid01 = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01")
    while emojiGrid01:get_childCount() > 1 do
      Object.DestroyImmediate(emojiGrid01:GetChild(emojiGrid01:get_childCount() - 1))
    end
  else
    self:SetEmoji()
  end
end
def.method().SetEmoji = function(self)
  if not ChatInputDlg.Instance().loaded then
    ChatInputDlg.Instance():Load()
    return
  end
  self.m_panel:FindDirect("Img_Input/Group_Emoji"):SetActive(true)
  local pages = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local emojiGrid01 = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01")
  while emojiGrid01:get_childCount() > 1 do
    Object.DestroyImmediate(emojiGrid01:GetChild(emojiGrid01:get_childCount() - 1))
  end
  emojiGrid01:GetChild(0):SetActive(false)
  local pageCount = math.ceil(ChatInputDlg.Instance().emojiCount / self.emojiPage)
  local emojiGroup = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01")
  local emojiPageTemplate = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01")
  for i = 2, pageCount do
    local emojiPage = Object.Instantiate(emojiPageTemplate)
    emojiPage.name = string.format("Page%02d", i)
    emojiPage.parent = emojiGroup
    emojiPage:set_localScale(Vector.Vector3.one)
  end
  emojiGroup:GetComponent("UIGrid"):Reposition()
  local emojiTemplate = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01/emoji")
  local curIndex = 1
  for k, v in ipairs(ChatInputDlg.Instance().emojis) do
    local emoji = Object.Instantiate(emojiTemplate)
    emoji.name = string.format("emoji_%s", v)
    local page = math.ceil(curIndex / self.emojiPage)
    emoji.parent = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", page))
    emoji:set_localScale(Vector.Vector3.one)
    local spriteAni = emoji:GetComponent("UISpriteAnimation")
    spriteAni:set_namePrefix(v)
    spriteAni:set_framesPerSecond(5)
    emoji:SetActive(true)
    curIndex = curIndex + 1
  end
  for i = 1, pageCount do
    local page = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:resetPoints(pageCount)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number").resetPoints = function(self, pageCount)
  local points = self.m_panel:FindDirect("Img_Input/Group_Emoji/Group_01/Img_Bg1/Grid_Pages")
  while points:get_childCount() > 1 do
    Object.DestroyImmediate(points:GetChild(points:get_childCount() - 1))
  end
  local pointtemplate = points:FindDirect("Img_Pages00")
  pointtemplate:SetActive(false)
  for i = 1, pageCount do
    local point = Object.Instantiate(pointtemplate)
    point.name = string.format("Img_Pages%02d", i)
    point.parent = points
    point:set_localScale(Vector.Vector3.one)
    point:SetActive(true)
    if i == 1 then
      point:GetComponent("UIToggle"):set_value(true)
    end
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if points and not points.isnil then
      points:GetComponent("UIGrid"):Reposition()
    end
  end)
end
def.method("string").onClick = function(self, id)
  if self.inputViewCtrl:onClick(id) then
  elseif string.sub(id, 1, 6) == "emoji_" then
    local emojiName = string.sub(id, 7)
    self.inputViewCtrl:AddInfoPack(string.format("#%s", emojiName), string.format("{e:%s}", emojiName))
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if self.inputViewCtrl:onSubmit(id, ctrl) then
  end
end
def.method("string").onLongPress = function(self, id)
  if self.inputViewCtrl:onLongPress(id) then
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if self.inputViewCtrl:onPress(id, state) then
  end
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  if self.inputViewCtrl:onDragOut(id, go) then
  end
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  if self.inputViewCtrl:onDragOver(id, go) then
  end
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if self.m_panel == nil or self.m_panel.isnil or type ~= 0 then
    return
  end
  local centerOnChild = scrollView:GetChild(0):GetComponent("UICenterOnChild")
  if centerOnChild then
    local conterObject = centerOnChild:get_centeredObject()
    local index = tonumber(string.sub(conterObject.name, -2, -1))
    local toggleObj = self.m_panel:FindDirect(string.format("Img_Input/Group_Emoji/Group_01/Img_Bg1/Grid_Pages/Img_Pages%02d", index))
    if toggleObj ~= nil then
      local pointToggle = toggleObj:GetComponent("UIToggle")
      if pointToggle ~= nil then
        pointToggle:set_value(true)
      end
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Toggle_Open" then
    if active then
      if not ScreenBullet.IsSetup() then
        ScreenBullet.Setup()
      end
      self:SetSwitchIcon(false)
    else
      if ScreenBullet.IsSetup() then
        ScreenBullet.Uninstall()
      end
      self:SetSwitchIcon(true)
    end
  end
end
ScreenBulletInput.Commit()
return ScreenBulletInput
