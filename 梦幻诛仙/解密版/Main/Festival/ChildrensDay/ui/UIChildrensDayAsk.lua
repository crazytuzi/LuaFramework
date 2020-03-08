local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIChidrensDayAsk = Lplus.Extend(ECPanelBase, "UIChidrensDayAsk")
local GUIUtils = require("GUI.GUIUtils")
local def = UIChidrensDayAsk.define
local instance
def.field("number").WAITTIME = 30
def.field("table")._roles = nil
def.field("table").id2role = nil
def.field("table")._tblPanelCfg = nil
def.field("userdata")._leaderId = nil
def.field("number")._type = 0
def.field("userdata")._timeSlider = nil
def.field("userdata")._timeLabel = nil
def.field("function").funcAgree = nil
def.field("function").funcDisagree = nil
def.static("=>", UIChidrensDayAsk).Instance = function()
  if instance == nil then
    instance = UIChidrensDayAsk()
  end
  return instance
end
def.static("function").SetClickAgreeCallback = function(func)
  local self = UIChidrensDayAsk.Instance()
  self.funcAgree = func
end
def.static("function").SetClickDisagreeCallback = function(func)
  local self = UIChidrensDayAsk.Instance()
  self.funcDisagree = func
end
def.static("number").SetWaitTime = function(time)
  local self = UIChidrensDayAsk.Instance()
  self.WAITTIME = time
end
def.static("string", "string", "string", "table", "userdata", "number").ShowAsk = function(title, desc, desc2, roles, leaderId, type)
  local dlg = UIChidrensDayAsk.Instance()
  if dlg:IsLoaded() then
    dlg:DestroyPanel()
  end
  dlg._roles = roles
  dlg._leaderId = leaderId
  dlg._type = type
  dlg._tblPanelCfg = {}
  local cfg = dlg._tblPanelCfg
  cfg.title = title
  cfg.desc = desc
  cfg.desc2 = desc2
  cfg.choiced = _G.GetMyRoleID() == leaderId
  dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_ASK, 1)
  dlg:SetModal(true)
end
def.static().CloseAsk = function()
  local dlg = UIChidrensDayAsk.Instance()
  if dlg:IsLoaded() then
    dlg:DestroyPanel()
  end
end
def.method("string").UpdateDesc2 = function(self, desc2)
  self._tblPanelCfg.desc2 = desc2
  if self:IsLoaded() then
    self:SetInfo()
  end
end
def.override().OnCreate = function(self)
  self:Init()
end
def.override().OnDestroy = function(self)
  self._roles = nil
  self.id2role = nil
  self._tblPanelCfg = nil
  self._timeLabel = nil
  self._timeSlider = nil
  self.funcAgree = nil
  self.funcDisagree = nil
end
def.method().Init = function(self)
  self:SetInfo()
  self:SetBtnInit()
  self:SetSlider()
  self:SetRoles()
end
def.method().SetInfo = function(self)
  local titleLabel = self.m_panel:FindDirect("Img_Bg/Label_Title"):GetComponent("UILabel")
  local descLabel = self.m_panel:FindDirect("Img_Bg/Label_Content"):GetComponent("UILabel")
  local desc2Label = self.m_panel:FindDirect("Img_Bg/Label_PlayerName"):GetComponent("UILabel")
  local cfg = self._tblPanelCfg
  titleLabel:set_text(cfg.title)
  descLabel:set_text(cfg.desc)
  desc2Label:set_text(cfg.desc2)
end
def.method().SetBtnInit = function(self)
  local agree = self.m_panel:FindDirect("Img_Bg/Btn_Agree")
  local refure = self.m_panel:FindDirect("Img_Bg/Btn_Refuse")
  agree:SetActive(true)
  refure:SetActive(true)
end
def.method("userdata").SetRoleReady = function(self, roleId)
  if self.m_panel then
    local role = self.id2role[roleId:tostring()]
    role:FindDirect("Img_Agree"):SetActive(true)
    if roleId == require("Main.Hero.HeroModule").Instance().roleId then
      self.m_panel:FindDirect("Img_Bg/Btn_Agree"):SetActive(false)
      self.m_panel:FindDirect("Img_Bg/Btn_Refuse"):SetActive(false)
    end
    for i = 1, #self._roles do
      local roleData = self._roles[i]
      if roleData.roleid == roleId then
        roleData.bAccept = true
      end
    end
  end
end
def.method("string").ToastUnacceptList = function(self, str)
  for i = 1, #self._roles do
    local roleInfo = self._roles[i]
    if not roleInfo.bAccept then
      Toast(str:format(roleInfo.roleName))
    end
  end
end
def.method().SetRoles = function(self)
  self.id2role = {}
  local roleRoot = self.m_panel:FindDirect("Img_Bg/List_Member")
  for i = 1, 5 do
    local roleData = self._roles[i]
    local role = roleRoot:FindDirect(string.format("Member_%d", i))
    if roleData == nil then
      role:SetActive(false)
    else
      role:SetActive(true)
      local name = role:FindDirect("Label_PlayerName"):GetComponent("UILabel")
      name:set_text(roleData.roleName)
      local head = role:FindDirect("Icon_Head")
      local imgFrame = role:FindDirect("Img_IconBg")
      if _G.SetAvatarIcon == nil then
        GUIUtils.SetSprite(head, GUIUtils.GetHeadSpriteName(roleData.occupation, roleData.gender))
      else
        _G.SetAvatarIcon(head, roleData.avatarId)
        _G.SetAvatarFrameIcon(imgFrame, roleData.avatarFrameId)
      end
      local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(roleData.occupation)
      local occupationSprite = role:FindDirect("Img_School"):GetComponent("UISprite")
      occupationSprite:set_spriteName(occupationSpriteName)
      local genderSprite = role:FindDirect("Img_Sex"):GetComponent("UISprite")
      genderSprite:set_spriteName(GUIUtils.GetGenderSprite(roleData.gender))
      local ready = role:FindDirect("Img_Agree")
      ready:SetActive(false)
      self.id2role[roleData.roleid:tostring()] = role
      roleData.bAccept = false
    end
  end
  self:SetRoleReady(self._leaderId)
end
def.method("number").SetSliderContent = function(self, time)
  if self.m_panel and not self.m_panel.isnil then
    if self._timeSlider == nil then
      self._timeSlider = self.m_panel:FindDirect("Img_Bg/Group_Slider/Slider1"):GetComponent("UISlider")
    end
    if self._timeLabel == nil then
      self._timeLabel = self.m_panel:FindDirect("Img_Bg/Label_Time"):GetComponent("UILabel")
    end
    local rate = time / self.WAITTIME
    self._timeSlider:set_sliderValue(rate)
    if time > 10 then
      self._timeLabel:set_text(string.format(textRes.Festival.ChildrensDay[8], math.floor(time)))
    else
      self._timeLabel:set_text(string.format(textRes.Festival.ChildrensDay[9], math.floor(time)))
    end
  end
end
def.method().SetSlider = function(self)
  local cfg = self._tblPanelCfg
  cfg.curTime = self.WAITTIME
  self:SetSliderContent(cfg.curTime)
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
  local sandFlow = self.m_panel:FindDirect("Img_Bg/Group_Slider/Img_SandFlow")
  sandFlow:SetActive(true)
end
def.method("number").OnUpdate = function(self, dt)
  if self.m_panel then
    local cfg = self._tblPanelCfg
    cfg.curTime = cfg.curTime - dt
    if cfg.curTime < 0 then
      cfg.curTime = 0
      local sandFlow = self.m_panel:FindDirect("Img_Bg/Group_Slider/Img_SandFlow")
      sandFlow:SetActive(false)
      Timer:RemoveIrregularTimeListener(self.OnUpdate)
      self:ToastUnacceptList(textRes.Festival.ChildrensDay[21])
      UIChidrensDayAsk.CloseAsk()
    end
    self:SetSliderContent(cfg.curTime)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Agree" then
    if self.funcAgree then
      self.funcAgree()
    end
  elseif id == "Btn_Refuse" and self.funcDisagree then
    self.funcDisagree()
  end
end
return UIChidrensDayAsk.Commit()
