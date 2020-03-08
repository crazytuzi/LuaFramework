local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPetsFightStastic = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIPetsFightStastic
local def = Cls.define
local instance
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._uiGOs = nil
def.field("table")._lFightInfo = nil
def.field("table")._rFightInfo = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = self._uiGOs or {}
  local uiGOs = self._uiGOs
  uiGOs.lUIList = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Info/Scrollview/List")
  uiGOs.lLblRoleName = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Label/Label_Title")
  uiGOs.rUIList = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Info/Scrollview/List")
  uiGOs.rLblRoleName = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Label/Label_Title")
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  self._lFightInfo = nil
  self._rFightInfo = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:initUI()
  end
end
def.method().initUI = function(self)
  self._uiGOs.maxDamage = self:getMaxDamage()
  local txtConst = textRes.Pet.PetsArena
  GUIUtils.SetText(self._uiGOs.lLblRoleName, txtConst[31]:format(self._uiGOs.passiveName))
  GUIUtils.SetText(self._uiGOs.rLblRoleName, txtConst[32]:format(self._uiGOs.activeName))
  self:UpdateLeftFightInfos()
  self:UpdateRightFightInfos()
end
def.method("=>", "number").getMaxDamage = function(self)
  local maxDamage = 0
  for i = 1, #self._lFightInfo do
    local damage = self._lFightInfo[i].damage
    if maxDamage < damage then
      maxDamage = damage
    end
  end
  for i = 1, #self._rFightInfo do
    local damage = self._rFightInfo[i].damage
    if maxDamage < damage then
      maxDamage = damage
    end
  end
  return maxDamage
end
def.method().UpdateLeftFightInfos = function(self)
  self:updateFightInfos(self._lFightInfo, self._uiGOs.lUIList)
end
def.method().UpdateRightFightInfos = function(self)
  self:updateFightInfos(self._rFightInfo, self._uiGOs.rUIList)
end
def.method("table", "userdata").updateFightInfos = function(self, fightInfos, uiList)
  fightInfos = fightInfos or {}
  table.sort(fightInfos, function(a, b)
    if a.position < b.position then
      return true
    else
      return false
    end
  end)
  local countList = #fightInfos
  local ctrlUIList = GUIUtils.InitUIList(uiList, countList)
  for i = 1, countList do
    self:fillPetFightInfo(ctrlUIList[i], fightInfos[i], i)
  end
end
def.method("userdata", "table", "number").fillPetFightInfo = function(self, ctrl, fightInfo, idx)
  local lblPetName = ctrl:FindDirect("Label_" .. idx)
  local headRoot = ctrl:FindDirect("Img_BgCharacter_" .. idx)
  local imgAvatar = headRoot:FindDirect("Icon_Head_" .. idx)
  local imgAvatarFrame = headRoot:FindDirect("Icon_BgHead_" .. idx)
  local slider = ctrl:FindDirect("Slider_" .. idx)
  local comUISlider = slider:GetComponent("UISlider")
  local lblDamage = slider:FindDirect("Label_Num_" .. idx)
  GUIUtils.SetText(lblPetName, _G.GetStringFromOcts(fightInfo.name))
  local modelId = 0
  if fightInfo.pet_cfgid == 0 then
    local monsterCfg = require("Main.Pet.Interface").GetMonsterCfg(fightInfo.monster_cfgid)
    modelId = monsterCfg.monsterModelId
  else
    local PetUtility = require("Main.Pet.PetUtility")
    local petCfg = PetUtility.Instance():GetPetCfg(fightInfo.pet_cfgid)
    modelId = petCfg and petCfg.modelId or 0
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local headIcon = record:GetIntValue("headerIconId")
  GUIUtils.SetTexture(imgAvatar, headIcon)
  comUISlider.value = fightInfo.damage / self._uiGOs.maxDamage
  GUIUtils.SetText(lblDamage, fightInfo.damage)
end
def.method("table", "table").ShowPanel = function(self, lFightInfo, rFightInfo)
  if self:IsShow() then
    return
  end
  self._uiGOs = {}
  self._lFightInfo = lFightInfo[1]
  self._uiGOs.passiveName = _G.GetStringFromOcts(lFightInfo[2])
  self._rFightInfo = rFightInfo[1]
  self._uiGOs.activeName = _G.GetStringFromOcts(rFightInfo[2])
  self:CreatePanel(RESPATH.PREFAB_FIGHT_STASTIC, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  end
end
return Cls.Commit()
