local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetTeamUtils = require("Main.PetTeam.PetTeamUtils")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local PetTeamModule = require("Main.PetTeam.PetTeamModule")
local OverallPanel = Lplus.Extend(ECPanelBase, "OverallPanel")
local def = OverallPanel.define
local instance
def.static("=>", OverallPanel).Instance = function()
  if instance == nil then
    instance = OverallPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._petTeamInfo = nil
def.field("table")._formationLevelCfg = nil
def.static("table").ShowPanel = function(petTeamInfo)
  if not PetTeamModule.Instance():IsOpen(true) then
    if OverallPanel.Instance():IsShow() then
      OverallPanel.Instance():DestroyPanel()
    end
    return
  end
  if not OverallPanel.Instance():_InitData(petTeamInfo) then
    if OverallPanel.Instance():IsShow() then
      OverallPanel.Instance():DestroyPanel()
    end
    return
  end
  if OverallPanel.Instance():IsShow() then
    OverallPanel.Instance():UpdateUI()
    return
  end
  OverallPanel.Instance():CreatePanel(RESPATH.PREFAB_PETTEAM_OVERALL_PANEL, 1)
end
def.method("table", "=>", "boolean")._InitData = function(self, petTeamInfo)
  self._petTeamInfo = petTeamInfo
  if self._petTeamInfo then
    local formationLevel = PetTeamData.Instance():GetFormationLevel(petTeamInfo.formationId)
    self._formationLevelCfg = PetTeamData.Instance():GetLevelCfg(petTeamInfo.formationId, formationLevel)
    return true
  else
    return false
  end
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_Bg0/Img_Title/Label_Title")
  self._uiObjs.Scrollview = self.m_panel:FindDirect("Img_Bg0/Group_List/Scrollview")
  self._uiObjs.uiScrollView = self._uiObjs.Scrollview:GetComponent("UIScrollView")
  self._uiObjs.List = self._uiObjs.Scrollview:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.List:GetComponent("UIList")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self._uiObjs.uiScrollView:ResetPosition()
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:ShowTeamTitle()
  self:ShowPetList()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._uiObjs = nil
  self._petTeamInfo = nil
  self._formationLevelCfg = nil
end
def.method().ShowTeamTitle = function(self)
  GUIUtils.SetText(self._uiObjs.Label_Title, string.format(textRes.PetTeam.PET_TEAM_NAME, self._petTeamInfo.teamIdx))
end
def.method().ShowPetList = function(self)
  self:_ClearPetList()
  local posCount = constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM
  self._uiObjs.uiList.itemCount = posCount
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
  for pos = 1, posCount do
    self:ShowPetInfo(pos)
  end
end
def.method("number").ShowPetInfo = function(self, pos)
  local listItem = self._uiObjs.uiList.children[pos]
  if nil == listItem then
    warn("[ERROR][PetFightSkillPanel:ShowPetInfo] listItem nil at pos:", pos)
    return
  end
  local petId = self._petTeamInfo:GetPosPet(pos)
  local petInfo = petId and PetMgr.Instance():GetPet(petId)
  local Label_Null = listItem:FindDirect("Label_Null")
  local Group_Pet = listItem:FindDirect("Group_Pet")
  if petInfo then
    GUIUtils.SetActive(Label_Null, false)
    GUIUtils.SetActive(Group_Pet, true)
    local Label_Name = Group_Pet:FindDirect("Label_PetName")
    GUIUtils.SetText(Label_Name, petInfo.name)
    local Label_Lv = Group_Pet:FindDirect("Label_Level")
    GUIUtils.SetText(Label_Lv, petInfo.level)
    local Icon_Pet = Group_Pet:FindDirect("Img_BgIcon/Icon_Pet")
    GUIUtils.SetTexture(Icon_Pet, petInfo:GetHeadIconId())
    local Label_PetPointsNum = Group_Pet:FindDirect("Label_PetPointsNum")
    GUIUtils.SetText(Label_PetPointsNum, petInfo:GetYaoLi())
    local attrs = self._formationLevelCfg and self._formationLevelCfg.posAttrs[pos]
    local attrString = ""
    for idx = 1, 2 do
      local attrCfg = attrs and attrs[idx]
      local str = attrCfg and PetTeamUtils.GetAttrString(attrCfg)
      if str and "" ~= str then
        if attrString == "" or attrString == nil then
          attrString = str
        else
          attrString = attrString .. "\n" .. str
        end
      end
    end
    local Label_Att = Group_Pet:FindDirect("Label_Att01")
    GUIUtils.SetText(Label_Att, attrString)
    local Img_SkillIcon = Group_Pet:FindDirect("Img_SkillIcon")
    if PetTeamModule.Instance():IsPetSkillFeatrueOpen(false) then
      GUIUtils.SetActive(Img_SkillIcon, true)
      local Icon_Pet = Img_SkillIcon:FindDirect("Icon_Pet")
      local petSkillId = PetTeamData.Instance():GetPetSkill(petId)
      local petSkillCfg = PetTeamData.Instance():GetSkillCfg(petSkillId)
      local skillCfg = petSkillCfg and SkillUtility.GetSkillCfg(petSkillCfg.skillId)
      if skillCfg then
        GUIUtils.SetActive(Img_SkillIcon, true)
        GUIUtils.SetTexture(Icon_Pet, skillCfg.iconId)
      else
        GUIUtils.SetActive(Img_SkillIcon, false)
      end
    else
      GUIUtils.SetActive(Img_SkillIcon, false)
    end
  else
    GUIUtils.SetActive(Label_Null, true)
    GUIUtils.SetActive(Group_Pet, false)
  end
end
def.method()._ClearPetList = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiList) then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Img_SkillIcon" then
    self:OnSkillIconClicked(clickObj)
  elseif id == "Img_BgIcon" then
    self:OnPetClicked(clickObj)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method("userdata").OnSkillIconClicked = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  local parent = parent and parent.parent
  local id = parent and parent.name
  if id then
    local togglePrefix = "item_"
    local pos = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    local petId = self._petTeamInfo:GetPosPet(pos)
    local petSkillId = petId and PetTeamData.Instance():GetPetSkill(petId)
    if petSkillId > 0 then
      PetTeamUtils.ShowFightPetSkillTipEx(petSkillId, clickObj, 0, nil)
    else
      warn("[ERROR][OverallPanel:OnSkillIconClicked] petSkillId 0 at pos:", pos)
    end
  end
end
def.method("userdata").OnPetClicked = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  local parent = parent and parent.parent
  local id = parent and parent.name
  if id then
    local togglePrefix = "item_"
    local pos = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    local petId = self._petTeamInfo:GetPosPet(pos)
    local petInfo = PetMgr.Instance():GetPet(petId)
    if petInfo then
      require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(petInfo)
    else
      warn("[ERROR][OverallPanel:OnPetClicked] petInfo nil at pos:", pos)
    end
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
def.static("table", "table").OnSkillChange = function(params, context)
  warn("[OverallPanel:OnSkillChange] OnSkillChange.")
  local self = OverallPanel.Instance()
  if not self or self:IsShow() then
  end
end
OverallPanel.Commit()
return OverallPanel
