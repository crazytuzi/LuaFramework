local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgTeamConfirm = Lplus.Extend(ECPanelBase, "DlgTeamConfirm")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgTeamConfirm.define
local _instance
def.field("table").id2role = nil
def.field("table").confirmIds = nil
def.field("table").roles = nil
def.field("string").title = ""
def.field("string").desc = ""
def.field("string").desc2 = ""
def.field("userdata").timeSlider = nil
def.field("userdata").timeLabel = nil
def.field("boolean").choiced = false
def.field("number").endTime = 0
def.field("number").waitTime = 0
def.field("table").defaultAgreeRoles = nil
def.static("=>", DlgTeamConfirm).Instance = function()
  if _instance == nil then
    _instance = DlgTeamConfirm()
  end
  return _instance
end
def.static("string", "string", "string", "table", "table", "number", "number", "table").ShowAsk = function(title, desc, desc2, roles, confirmIds, endTime, waitTime, defaultAgreeRoles)
  local dlg = DlgTeamConfirm.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.title = title
  dlg.desc = desc
  dlg.desc2 = desc2
  dlg.roles = roles
  dlg.confirmIds = confirmIds
  dlg.choiced = confirmIds[GetMyRoleID():tostring()] ~= nil
  dlg.endTime = endTime
  dlg.waitTime = waitTime
  dlg.defaultAgreeRoles = defaultAgreeRoles
  dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_ASK, 2)
  dlg:SetModal(true)
end
def.static().CloseAsk = function()
  local dlg = DlgTeamConfirm.Instance()
  dlg:DestroyPanel()
end
def.static().CloseWithToast = function()
  local self = DlgTeamConfirm.Instance()
  local names = {}
  if self.confirmIds and self.roles and self.defaultAgreeRoles then
    for k, v in pairs(self.roles) do
      if not self.confirmIds[v.roleid:tostring()] and not self.defaultAgreeRoles[v.roleid:tostring()] then
        table.insert(names, v.name)
      end
    end
  end
  if #names > 0 then
    Toast(string.format(textRes.activity[918], table.concat(names, textRes.Common.comma)))
  end
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:SetInfo()
  self:SetRoles()
  for k, v in pairs(self.confirmIds) do
    self:SetRoleReady(Int64.new(k))
  end
  self:SetSlider()
end
def.override().OnDestroy = function(self)
  self.timeSlider = nil
  self.timeLabel = nil
  self.id2role = nil
  self.roles = nil
  self.choiced = false
  self.defaultAgreeRoles = nil
  Timer:RemoveIrregularTimeListener(self.OnUpdate)
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
    local rate = time / self.waitTime
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
    local curTime = GetServerTime()
    local left = self.endTime - curTime
    if left < 0 then
      local sandFlow = self.m_panel:FindDirect("Img_Bg/Group_Slider/Img_SandFlow")
      sandFlow:SetActive(false)
      Timer:RemoveIrregularTimeListener(self.OnUpdate)
      DlgTeamConfirm.CloseWithToast()
    end
    self:SetSliderContent(left)
  end
end
def.method().SetSlider = function(self)
  self:SetSliderContent(self.waitTime)
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
      name:set_text(roleData.name)
      local head = role:FindDirect("Icon_Head")
      SetAvatarIcon(head, roleData.avatarId)
      local frame = role:FindDirect("Img_IconBg")
      SetAvatarFrameIcon(frame, roleData.avatarFrameid)
      local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(roleData.menpai)
      local occupationSprite = role:FindDirect("Img_School"):GetComponent("UISprite")
      occupationSprite:set_spriteName(occupationSpriteName)
      local genderSprite = role:FindDirect("Img_Sex"):GetComponent("UISprite")
      genderSprite:set_spriteName(GUIUtils.GetGenderSprite(roleData.gender))
      local ready = role:FindDirect("Img_Agree")
      ready:SetActive(false)
      self.id2role[roleData.roleid:tostring()] = role
    end
  end
end
def.method("userdata").SetRoleReady = function(self, roleId)
  if self.confirmIds == nil then
    return
  end
  self.confirmIds[roleId:tostring()] = true
  if self.m_panel and not self.m_panel.isnil then
    local role = self.id2role[roleId:tostring()]
    if role then
      role:FindDirect("Img_Agree"):SetActive(true)
    end
    if roleId == require("Main.Hero.HeroModule").Instance().roleId then
      self.m_panel:FindDirect("Img_Bg/Btn_Agree"):SetActive(false)
      self.m_panel:FindDirect("Img_Bg/Btn_Refuse"):SetActive(false)
    end
  end
  if self:CheckAllReady() then
    self:DestroyPanel()
  end
end
def.method("=>", "boolean").CheckAllReady = function(self)
  if self.roles then
    for k, v in ipairs(self.roles) do
      if not self.confirmIds[v.roleid:tostring()] then
        return false
      end
    end
    return true
  else
    return false
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Agree" then
    require("Main.Team.TeamModule").Instance():Reply(true)
    self:SetRoleReady(require("Main.Hero.HeroModule").Instance().roleId)
    self.choiced = true
  elseif id == "Btn_Refuse" then
    require("Main.Team.TeamModule").Instance():Reply(false)
    Timer:RemoveIrregularTimeListener(self.OnUpdate)
    DlgTeamConfirm.CloseAsk()
    self.choiced = true
  end
end
DlgTeamConfirm.Commit()
return DlgTeamConfirm
