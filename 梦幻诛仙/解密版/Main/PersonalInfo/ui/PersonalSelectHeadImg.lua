local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PersonalSelectHeadImg = Lplus.Extend(ECPanelBase, "PersonalSelectHeadImg")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local personalInfoInterface = PersonalInfoInterface.Instance()
local def = PersonalSelectHeadImg.define
local instance
def.field("userdata").roleId = nil
def.field("number").imgId = 0
def.field("table").curImgList = nil
def.field("function").endCallback = nil
def.static("=>", PersonalSelectHeadImg).Instance = function()
  if instance == nil then
    instance = PersonalSelectHeadImg()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
end
def.method("userdata", "function").ShowPanel = function(self, roleId, endCallback)
  if self:IsShow() then
    return
  end
  self.roleId = roleId
  self.endCallback = endCallback
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SELECT_ICON_PANEL, 2)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setHeadImgList()
  else
  end
end
def.method().setHeadImgList = function(self)
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local info = personalInfo.info
  local imgCfgList = PersonalInfoInterface.GetHeadImgCfgList()
  local Group_PresetIcon = self.m_panel:FindDirect("Img_Bg0/Group_PresetIcon")
  self.curImgList = imgCfgList
  for i, v in ipairs(imgCfgList) do
    local Img_Preset = Group_PresetIcon:FindDirect("Img_Preset_" .. i)
    if Img_Preset then
      local Img_PreIcon = Img_Preset:FindDirect("Img_PreIcon_" .. i)
      local icon_texture = Img_PreIcon:GetComponent("UITexture")
      GUIUtils.FillIcon(icon_texture, v.imageId)
      local Img_Selected = Img_Preset:FindDirect("Img_Selected")
      local img_toggle = Img_Preset:GetComponent("UIToggle")
      if v.id == info.headImage then
        img_toggle.value = true
      else
        img_toggle.value = false
      end
    end
  end
  local Img_SocialIcon = self.m_panel:FindDirect("Img_Bg0/Img_SocialIcon")
  local qqIcon = Img_SocialIcon:FindDirect("Img_SocialIcon")
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  local myRoleId = heroProp.id
  local icon_texture = qqIcon:GetComponent("UITexture")
  local img_toggle = Img_SocialIcon:GetComponent("UIToggle")
  local url = personalInfoInterface:getHeadImgUrl(myRoleId)
  if url ~= "" and url ~= "local" then
    Img_SocialIcon:SetActive(true)
    GUIUtils.FillTextureFromURL(icon_texture, url, function(tex2d)
    end)
    if info.headImage == -1 then
      img_toggle.value = true
    else
      img_toggle.value = false
    end
  else
    Img_SocialIcon:SetActive(false)
  end
end
def.method().Hide = function(self)
  self.curImgList = nil
  self.roleId = nil
  self.endCallback = nil
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Cancel" then
    self:Hide()
  elseif id == "Btn_Save" then
    if self.endCallback then
      self.endCallback(self.imgId)
      self.endCallback = nil
    end
    self:Hide()
  elseif strs[1] == "Img" and strs[2] == "Preset" then
    local idx = tonumber(strs[3])
    self.imgId = self.curImgList[idx].id
    warn("------select imag:", self.imgId)
  elseif id == "Img_SocialIcon" then
    self.imgId = -1
    warn("------select imag:", self.imgId)
  end
end
return PersonalSelectHeadImg.Commit()
