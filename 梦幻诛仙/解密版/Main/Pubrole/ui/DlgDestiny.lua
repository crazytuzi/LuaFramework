local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local DlgDestiny = Lplus.Extend(ECPanelBase, "DlgDestiny")
local def = DlgDestiny.define
local dlg
def.field("number").count = -1
def.field("table").roleInfo = nil
def.static("table").ShowTip = function(roleInfo)
  DlgDestiny.Instance():ShowPanel(roleInfo)
end
def.static("=>", DlgDestiny).Instance = function()
  if dlg == nil then
    dlg = DlgDestiny()
  end
  return dlg
end
def.method("table").ShowPanel = function(self, roleInfo)
  self.roleInfo = roleInfo
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_DESTINY, 0)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.count = 30
  self:UpdateTime(0)
  self:UpdateInfo()
end
def.override().OnCreate = function(self)
  Timer:RegisterListener(DlgDestiny.UpdateTime, self)
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(DlgDestiny.UpdateTime)
end
def.method().UpdateInfo = function(self)
  if self.m_panel == nil or self.roleInfo == nil then
    return
  end
  self.m_panel:FindDirect("Img_Bg/Label_Propose"):GetComponent("UILabel").text = string.format(textRes.Friend[65], self.roleInfo.name)
  local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local myprop = require("Main.Hero.Interface").GetBasicHeroProp()
  if myprop.gender == self.roleInfo.gender then
    if myprop.gender == GenderEnum.MALE then
      self.m_panel:FindDirect("Img_Bg/Group_People/B-B"):SetActive(true)
      self.m_panel:FindDirect("Img_Bg/Group_People/G-G"):SetActive(false)
    elseif myprop.gender == GenderEnum.FEMALE then
      self.m_panel:FindDirect("Img_Bg/Group_People/B-B"):SetActive(false)
      self.m_panel:FindDirect("Img_Bg/Group_People/G-G"):SetActive(true)
    end
    self.m_panel:FindDirect("Img_Bg/Group_People/B-G"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Group_People/B-G"):SetActive(true)
    self.m_panel:FindDirect("Img_Bg/Group_People/B-B"):SetActive(false)
    self.m_panel:FindDirect("Img_Bg/Group_People/G-G"):SetActive(false)
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    require("Main.friend.FriendModule").Instance():CAddFriend(self.roleInfo.id)
    self:Hide()
  elseif id == "Btn_Cancel" then
    self:Hide()
  end
end
def.method("number").UpdateTime = function(self, tick)
  if self.count < 0 then
    return
  end
  self.count = self.count - tick
  if self.count >= 0 then
    self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_Cancel/Label"):GetComponent("UILabel").text = string.format(textRes.Marriage[1], self.count)
  else
    self:Hide()
  end
end
return DlgDestiny.Commit()
