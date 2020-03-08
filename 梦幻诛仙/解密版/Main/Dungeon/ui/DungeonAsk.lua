local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DungeonAsk = Lplus.Extend(ECPanelBase, "DungeonAsk")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = require("Main.Dungeon.DungeonModule")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local def = DungeonAsk.define
local _instance
def.field("number").WAITTIME = 30
def.field("table").roles = nil
def.field("table").id2role = nil
def.field("number").tickTimer = 0
def.field("string").title = ""
def.field("string").desc = ""
def.field("string").desc2 = ""
def.field("userdata").leaderId = nil
def.field("userdata").timeSlider = nil
def.field("userdata").timeLabel = nil
def.field("number").curTime = 0
def.field("boolean").choiced = false
def.field("number").type = 0
def.static("=>", DungeonAsk).Instance = function()
  if _instance == nil then
    _instance = DungeonAsk()
    _instance.WAITTIME = DungeonUtils.GetDungeonConst().ConfirmTime
  end
  return _instance
end
def.static("string", "string", "string", "table", "userdata", "number").ShowAsk = function(title, desc, desc2, roles, leaderId, type)
  local dlg = DungeonAsk.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.title = title
  dlg.desc = desc
  dlg.desc2 = desc2
  dlg.roles = roles
  dlg.leaderId = leaderId
  dlg.choiced = GetMyRoleID() == leaderId
  dlg.type = type
  dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_ASK, 1)
  dlg:SetModal(true)
end
def.static().CloseAsk = function()
  local dlg = DungeonAsk.Instance()
  dlg:DestroyPanel()
end
def.method("string").UpdateDesc2 = function(self, desc2)
  self.desc2 = desc2
  if self:IsShow() then
    self:SetInfo()
  end
end
def.override().OnCreate = function(self)
  self:Init()
end
def.override().OnDestroy = function(self)
  self.timeSlider = nil
  self.timeLabel = nil
  Timer:RemoveIrregularTimeListener(self.OnUpdate)
  self.type = 0
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
  titleLabel:set_text(self.title)
  descLabel:set_text(self.desc)
  desc2Label:set_text(self.desc2)
end
def.method("number").SetSliderContent = function(self, time)
  if self.m_panel and not self.m_panel.isnil then
    if self.timeSlider == nil then
      self.timeSlider = self.m_panel:FindDirect("Img_Bg/Group_Slider/Slider1"):GetComponent("UISlider")
    end
    if self.timeLabel == nil then
      self.timeLabel = self.m_panel:FindDirect("Img_Bg/Label_Time"):GetComponent("UILabel")
    end
    local rate = time / self.WAITTIME
    self.timeSlider:set_sliderValue(rate)
    if time > 10 then
      self.timeLabel:set_text(string.format(textRes.Dungeon[36], math.floor(time)))
    else
      self.timeLabel:set_text(string.format(textRes.Dungeon[37], math.floor(time)))
    end
  end
end
def.method("number").OnUpdate = function(self, dt)
  if self.m_panel then
    self.curTime = self.curTime - dt
    if self.curTime < 0 then
      self.curTime = 0
      local sandFlow = self.m_panel:FindDirect("Img_Bg/Group_Slider/Img_SandFlow")
      sandFlow:SetActive(false)
      Timer:RemoveIrregularTimeListener(self.OnUpdate)
      DungeonAsk.CloseAsk()
    end
    self:SetSliderContent(self.curTime)
  end
end
def.method().SetSlider = function(self)
  self.curTime = self.WAITTIME
  self:SetSliderContent(self.curTime)
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
  local sandFlow = self.m_panel:FindDirect("Img_Bg/Group_Slider/Img_SandFlow")
  sandFlow:SetActive(true)
end
def.method().SetRoles = function(self)
  self.id2role = {}
  local roleRoot = self.m_panel:FindDirect("Img_Bg/List_Member")
  for i = 1, 5 do
    local roleData = self.roles[i]
    local role = roleRoot:FindDirect(string.format("Member_%d", i))
    if roleData == nil then
      role:SetActive(false)
    else
      role:SetActive(true)
      local name = role:FindDirect("Label_PlayerName"):GetComponent("UILabel")
      name:set_text(roleData.roleName)
      local head = role:FindDirect("Icon_Head")
      SetAvatarIcon(head, roleData.avatarId)
      local frame = role:FindDirect("Img_IconBg")
      SetAvatarFrameIcon(frame, roleData.avatarFrameId)
      local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(roleData.occupation)
      local occupationSprite = role:FindDirect("Img_School"):GetComponent("UISprite")
      occupationSprite:set_spriteName(occupationSpriteName)
      local genderSprite = role:FindDirect("Img_Sex"):GetComponent("UISprite")
      genderSprite:set_spriteName(GUIUtils.GetGenderSprite(roleData.gender))
      local ready = role:FindDirect("Img_Agree")
      ready:SetActive(false)
      self.id2role[roleData.roleid:tostring()] = role
    end
  end
  self:SetRoleReady(self.leaderId)
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
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Agree" then
    DungeonModule.Instance().teamMgr:ConfirmDungeon(true)
    self:SetRoleReady(require("Main.Hero.HeroModule").Instance().roleId)
    self.choiced = true
  elseif id == "Btn_Refuse" then
    Timer:RemoveIrregularTimeListener(self.OnUpdate)
    DungeonModule.Instance().teamMgr:ConfirmDungeon(false)
    DungeonAsk.CloseAsk()
    self.choiced = true
  end
end
DungeonAsk.Commit()
return DungeonAsk
