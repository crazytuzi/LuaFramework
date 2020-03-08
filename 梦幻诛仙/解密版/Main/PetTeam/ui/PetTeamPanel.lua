local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetTeamProtocols = require("Main.PetTeam.PetTeamProtocols")
local PetTeamUtils = require("Main.PetTeam.PetTeamUtils")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetTeamInfo = require("Main.PetTeam.data.PetTeamInfo")
local FormationPanel = require("Main.PetTeam.ui.FormationPanel")
local PetFightSkillPanel = require("Main.PetTeam.ui.PetFightSkillPanel")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetTeamModule = require("Main.PetTeam.PetTeamModule")
local PetTeamPanel = Lplus.Extend(ECPanelBase, "PetTeamPanel")
local def = PetTeamPanel.define
local instance
def.static("=>", PetTeamPanel).Instance = function()
  if instance == nil then
    instance = PetTeamPanel()
  end
  return instance
end
def.const("table").ShowState = {NORMAL = 0, EDIT = 1}
def.field("table")._uiObjs = nil
def.field("number")._curState = 0
def.field("table")._pet2ModelMap = nil
def.field("number")._curTeamIdx = 1
def.field("table")._curTeamInfo = nil
def.field("table")._curFormationCfg = nil
def.field("number")._selectedIdx = 0
def.field("boolean")._bExchanging = false
def.field("boolean")._bDirty = false
def.static().ShowPanel = function()
  if not PetTeamModule.Instance():IsOpen(true) then
    if PetTeamPanel.Instance():IsShow() then
      PetTeamPanel.Instance():DestroyPanel()
    end
    return
  end
  PetTeamPanel.Instance():CreatePanel(RESPATH.PREFAB_PETTEAM_MAIN_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
  self._pet2ModelMap = {}
  self:UpdateUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.TeamTabs = {}
  for i = 1, constant.CPetFightConsts.MAX_TEAM_NUMBER do
    self._uiObjs.TeamTabs[i] = self.m_panel:FindDirect("Img_Bg/Group_Title/Grid_Team/Btn_Team_" .. i)
  end
  self._uiObjs.Btn_EditTeam = self.m_panel:FindDirect("Img_Bg/Group_Edit/Btn_EditTeam")
  self._uiObjs.Btn_EditCancel = self.m_panel:FindDirect("Img_Bg/Group_Edit/Btn_EditCancel")
  self._uiObjs.Btn_EditSave = self.m_panel:FindDirect("Img_Bg/Group_Edit/Btn_EditSave")
  self._uiObjs.Btn_Change = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_Label/Btn_Change")
  self._uiObjs.Group_Btn = self.m_panel:FindDirect("Img_Bg/Group_Btn")
  self._uiObjs.Btn_ChangePos = self._uiObjs.Group_Btn:FindDirect("Btn_ChangePos")
  self._uiObjs.LabelExchange = self._uiObjs.Btn_ChangePos:FindDirect("Label")
  self._uiObjs.Btn_PetOff = self._uiObjs.Group_Btn:FindDirect("Btn_PetOff")
  self._uiObjs.Btn_PetSkill = self._uiObjs.Group_Btn:FindDirect("Btn_PetSkill")
  self._uiObjs.Btn_PetChange = self._uiObjs.Group_Btn:FindDirect("Btn_PetChange")
  self._uiObjs.Img_SetDefence = self.m_panel:FindDirect("Img_Bg/Img_SetDefence")
  self._uiObjs.Group_Front = self.m_panel:FindDirect("Img_Bg/Group_Front")
  self._uiObjs.Formation = {}
  for i = 1, constant.CPetFightConsts.MAX_POSITION_NUMBER do
    self._uiObjs.Formation[i] = self._uiObjs.Group_Front:FindDirect("Group_Site_" .. i)
  end
  self._uiObjs.Label_TeamPointNum = self.m_panel:FindDirect("Img_Bg/Group_TeamPoint/Label_TeamPointNum")
  self._uiObjs.LabelFormationName = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_Label/Label")
  self._uiObjs.Grid_Att = self.m_panel:FindDirect("Img_Bg/Group_Info/Grid_Att")
  self._uiObjs.FormationAttrs = {}
  for i = 1, constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM do
    self._uiObjs.FormationAttrs[i] = self._uiObjs.Grid_Att:FindDirect("Group_Att0" .. i)
  end
  self._uiObjs.Img_Red_Formation = self.m_panel:FindDirect("Img_Bg/Group_Title/Btn_FrontLevelUp/Img_Red")
  self._uiObjs.Btn_FriendFight = self.m_panel:FindDirect("Img_Bg/Group_Title/Btn_FriendFight")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  PetTeamModule.Instance():SetNewOpen(false, false)
  if show and self._pet2ModelMap then
    for key, uiModel in pairs(self._pet2ModelMap) do
      uiModel:Play("Stand_c")
    end
  else
  end
end
def.method().UpdateUI = function(self)
  self:UpdateFormationReddot()
  self:TrySelectTeam(self._curTeamIdx, true)
  self:UpdatePetTeamSkill()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._uiObjs = nil
  self._curState = 0
  if self._pet2ModelMap then
    for key, uiModel in pairs(self._pet2ModelMap) do
      uiModel:Destroy()
    end
    self._pet2ModelMap = nil
  end
  self._curTeamIdx = 1
  self._curTeamInfo = nil
  self._curFormationCfg = nil
  self._selectedIdx = 0
  self._bExchanging = false
  self:SetDirty(false)
end
def.method().UpdateFormationReddot = function(self)
  local bUpgrade = PetTeamData.Instance():CanAnyFormationUpgrade(true)
  GUIUtils.SetActive(self._uiObjs.Img_Red_Formation, bUpgrade)
end
def.method("number", "boolean").TrySelectTeam = function(self, teamIdx, bForce)
  if not bForce and teamIdx == self._curTeamIdx then
    return
  end
  self:SetDirty(false)
  self._curTeamIdx = teamIdx
  local petTeamInfo = PetTeamData.Instance():GetTeamInfo(self._curTeamIdx)
  if petTeamInfo then
    self._curTeamInfo = petTeamInfo:Clone()
  else
    self._curTeamInfo = PetTeamInfo.New(teamIdx, constant.CPetFightConsts.DEFAULT_FORMATION_ID, nil)
  end
  self:SetCurFormationCfg(self._curTeamInfo.formationId)
  self:UpdateTeamTab()
  self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
  PetTeamUtils.ShowTeam(self, self._curTeamInfo, self._uiObjs.Formation, self._uiObjs.Label_TeamPointNum, self._pet2ModelMap)
  self:UpdateFormationAttrs()
end
def.method("number").SetCurFormationCfg = function(self, formationId)
  self._curFormationCfg = PetTeamData.Instance():GetFormationCfg(formationId)
  if nil == self._curFormationCfg then
    warn(string.format("[ERROR][PetTeamPanel:SetCurFormationCfg] FormationCfg nil for id[%d].", formationId))
    self:DestroyPanel()
  end
end
def.method().UpdateTeamTab = function(self)
  for idx, tab in ipairs(self._uiObjs.TeamTabs) do
    GUIUtils.Toggle(tab, idx == self._curTeamIdx)
  end
end
def.method("number", "boolean").UpdateEditState = function(self, state, bForce)
  if not bForce and self._curState == state then
    return
  end
  self._curState = state
  local bEdit = self._curState == PetTeamPanel.ShowState.EDIT
  GUIUtils.SetActive(self._uiObjs.Btn_EditTeam, not bEdit)
  GUIUtils.SetActive(self._uiObjs.Btn_EditCancel, bEdit)
  GUIUtils.SetActive(self._uiObjs.Btn_EditSave, bEdit)
  GUIUtils.SetActive(self._uiObjs.Btn_Change, bEdit)
  GUIUtils.SetActive(self._uiObjs.Img_SetDefence, not bEdit)
  PetTeamUtils.ShowFormation(self._curFormationCfg, self._curTeamInfo, self._uiObjs.Formation, bEdit)
  self:UpdateDeployState(0, false)
  self:UpdateDefenseTeam()
end
def.method("function", "boolean", "=>", "boolean").CheckSave = function(self, cb, bCrossServerToast)
  if self._curState == PetTeamPanel.ShowState.EDIT and self:GetDirty() then
    if bCrossServerToast then
      if _G.CheckCrossServerAndToast() then
        return false
      end
    elseif _G.IsCrossingServer() then
      return false
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local confirmDlg = CommonConfirmDlg.ShowConfirmEx(textRes.PetTeam.SAVE_EDIT_CONFIRM_TITLE, textRes.PetTeam.SAVE_EDIT_CONFIRM_CONTENT, textRes.PetTeam.SAVE_EDIT_CONFIRM_YES, textRes.PetTeam.SAVE_EDIT_CONFIRM_NO, function(id, tag)
      local bSave = id == 1
      if bSave then
        self:TrySave()
      else
      end
      if cb then
        cb(bSave)
      end
    end, nil)
    confirmDlg:ShowCloseBtn()
    return true
  else
    return false
  end
end
def.method().TrySave = function(self)
  if self._curState == PetTeamPanel.ShowState.EDIT and self:GetDirty() then
    local origTeamInfo = PetTeamData.Instance():GetTeamInfo(self._curTeamInfo.teamIdx)
    PetTeamUtils.CheckSaveTeam(origTeamInfo, self._curTeamInfo)
  end
end
def.method("number", "boolean").UpdateDeployState = function(self, selectedIdx, bExchanging)
  local bEdit = self._curState == PetTeamPanel.ShowState.EDIT
  if bEdit then
    GUIUtils.SetActive(self._uiObjs.Group_Btn, true)
    self._selectedIdx = selectedIdx
    self._bExchanging = bExchanging
    if self._bExchanging then
      GUIUtils.SetActive(self._uiObjs.Btn_ChangePos, true)
      GUIUtils.SetText(self._uiObjs.LabelExchange, textRes.PetTeam.DEPLOY_EXCHANGE_CANCEL)
      GUIUtils.SetActive(self._uiObjs.Btn_PetOff, false)
      GUIUtils.SetActive(self._uiObjs.Btn_PetSkill, false)
      GUIUtils.SetActive(self._uiObjs.Btn_PetChange, false)
    else
      GUIUtils.SetActive(self._uiObjs.Btn_ChangePos, true)
      GUIUtils.SetText(self._uiObjs.LabelExchange, textRes.PetTeam.DEPLOY_EXCHANGE_ADJUST)
      local pos = self._curFormationCfg.idx2PosMap[self._selectedIdx]
      local petId = pos and self._curTeamInfo:GetPosPet(pos)
      GUIUtils.SetActive(self._uiObjs.Btn_PetOff, petId)
      GUIUtils.SetActive(self._uiObjs.Btn_PetSkill, petId and PetTeamModule.Instance():IsPetSkillFeatrueOpen(false))
      GUIUtils.SetActive(self._uiObjs.Btn_PetChange, petId)
    end
  else
    self._selectedIdx = 0
    self._bExchanging = false
    GUIUtils.SetActive(self._uiObjs.Group_Btn, false)
  end
  local pos = self._curFormationCfg.idx2PosMap[self._selectedIdx]
  local petId = pos and self._curTeamInfo:GetPosPet(pos)
  for idx, cell in ipairs(self._uiObjs.Formation) do
    if not _G.IsNil(cell) then
      local Img_Select = cell:FindDirect("Img_Select")
      local Img_Dest = cell:FindDirect("Label_Change")
      local Img_Src = cell:FindDirect("Img_Arrow")
      local pos = self._curFormationCfg.idx2PosMap[idx]
      if bEdit and pos and pos > 0 and pos <= constant.CPetFightConsts.MAX_POSITION_NUMBER then
        if bExchanging then
          GUIUtils.SetActive(Img_Select, true)
          if petId then
            if idx == self._selectedIdx then
              GUIUtils.SetActive(Img_Dest, false)
              GUIUtils.SetActive(Img_Src, true)
            else
              GUIUtils.SetActive(Img_Dest, true)
              GUIUtils.SetActive(Img_Src, false)
            end
          else
            GUIUtils.SetActive(Img_Dest, false)
            GUIUtils.SetActive(Img_Src, false)
          end
        elseif idx == self._selectedIdx then
          GUIUtils.SetActive(Img_Select, true)
          GUIUtils.SetActive(Img_Dest, false)
          GUIUtils.SetActive(Img_Src, petId)
        else
          GUIUtils.SetActive(Img_Select, false)
          GUIUtils.SetActive(Img_Dest, false)
          GUIUtils.SetActive(Img_Src, false)
        end
      end
    end
  end
end
def.method("boolean").SetDirty = function(self, value)
  self._bDirty = value
end
def.method("=>", "boolean").GetDirty = function(self)
  return self._bDirty
end
def.method("table", "function").ChoosePet = function(self, petTeamInfo, callback)
  local petList = PetMgr.Instance():GetPetList()
  local chooseList = {}
  if petList then
    for _, pet in pairs(petList) do
      if pet:IsBinded() and (nil == petTeamInfo or petTeamInfo:GetPetPos(pet.id) <= 0) then
        table.insert(chooseList, pet)
      end
    end
  end
  require("Main.Pet.ui.PetSelectPanel").Instance():ShowPanel(chooseList, textRes.PetTeam.DEPLOY_CHOOSE_PET, function(index, pet, userParams)
    if callback then
      callback(pet)
    end
  end, nil)
end
def.method().UpdateDefenseTeam = function(self)
  local curDefTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  for idx, tab in ipairs(self._uiObjs.TeamTabs) do
    local Img_Defence = tab:FindDirect("Img_Defence")
    GUIUtils.SetActive(Img_Defence, idx == curDefTeamIdx)
  end
  if self._curState == PetTeamPanel.ShowState.EDIT then
    GUIUtils.SetActive(self._uiObjs.Img_SetDefence, false)
  else
    GUIUtils.SetActive(self._uiObjs.Img_SetDefence, true)
    GUIUtils.Toggle(self._uiObjs.Img_SetDefence, self._curTeamIdx == curDefTeamIdx)
  end
end
def.method().UpdateFormationAttrs = function(self)
  local formationId = self._curTeamInfo and self._curTeamInfo.formationId or 0
  local formationLevel = PetTeamData.Instance():GetFormationLevel(formationId)
  PetTeamUtils.ShowFormationAttrs(formationId, formationLevel, self._uiObjs.LabelFormationName, self._uiObjs.FormationAttrs)
end
def.method().UpdatePetTeamSkill = function(self)
  local bSkillOpen = PetTeamModule.Instance():IsPetSkillFeatrueOpen(false)
  GUIUtils.SetActive(self._uiObjs.Btn_FriendFight, bSkillOpen)
  GUIUtils.SetActive(self._uiObjs.Btn_PetSkill, not self._bExchanging and bSkillOpen)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif string.find(id, "Btn_Team") then
    self:OnBtnTeamTab(id)
  elseif id == "Btn_EditTeam" then
    self:OnBtn_EditTeam()
  elseif id == "Btn_EditCancel" then
    self:OnBtn_EditCancel()
  elseif id == "Btn_EditSave" then
    self:OnBtn_EditSave()
  elseif string.find(id, "Group_Site") then
    self:OnBtnGroup_Site(id)
  elseif id == "Btn_Help" then
    self:OnBtn_Help()
  elseif id == "Btn_All" then
    self:OnBtn_All()
  elseif id == "Btn_FrontLevelUp" then
    self:OnBtnFormationUpgrade()
  elseif id == "Btn_FriendFight" then
    self:OnBtnSetSkill()
  elseif id == "Btn_ChangePos" then
    self:OnBtn_ExchangePos()
  elseif id == "Btn_PetOff" then
    self:OnBtn_PetOff()
  elseif id == "Btn_PetSkill" then
    self:OnBtn_PetSkill()
  elseif id == "Btn_PetChange" then
    self:OnBtn_ChangePet()
  elseif id == "Img_SetDefence" then
    self:OnImg_SetDefence()
  elseif id == "Btn_Change" then
    self:OnBtn_Change()
  elseif id == "Btn_PointsExchange" then
    self:OnBtn_PointsExchange()
  end
end
def.method().OnBtn_Close = function(self)
  local bConfirm = self:CheckSave(function(bSave)
    self:DestroyPanel()
  end, false)
  if not bConfirm then
    self:DestroyPanel()
  end
end
def.method("string").OnBtnTeamTab = function(self, id)
  local togglePrefix = "Btn_Team_"
  local teamIdx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  if teamIdx == self._curTeamIdx then
    return
  end
  local bConfirm = self:CheckSave(function(bSave)
    self:TrySelectTeam(teamIdx, false)
  end, false)
  if bConfirm then
    self:UpdateTeamTab()
  else
    self:TrySelectTeam(teamIdx, false)
  end
end
def.method().OnBtn_EditTeam = function(self)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  self:SetDirty(false)
  self:UpdateEditState(PetTeamPanel.ShowState.EDIT, true)
end
def.method().OnBtn_EditCancel = function(self)
  local bConfirm = self:CheckSave(function(bSave)
    if bSave then
      self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
    else
      self:TrySelectTeam(self._curTeamIdx, true)
    end
  end, false)
  if not bConfirm then
    self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
  end
end
def.method().OnBtn_EditSave = function(self)
  if _G.CheckCrossServerAndToast() then
    self:TrySelectTeam(self._curTeamIdx, true)
    return
  end
  self:TrySave()
  self:SetDirty(false)
  self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
end
def.method("string").OnBtnGroup_Site = function(self, id)
  local togglePrefix = "Group_Site_"
  local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local newPos = self._curFormationCfg.idx2PosMap[idx]
  if newPos and newPos > 0 and newPos <= constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM then
    if self._curState == PetTeamPanel.ShowState.EDIT then
      if self._bExchanging then
        if idx ~= self._selectedIdx then
          local oldPos = self._curFormationCfg.idx2PosMap[self._selectedIdx]
          local oldPetId = oldPos and self._curTeamInfo:GetPosPet(oldPos)
          if oldPetId then
            self._curTeamInfo:SetPosPet(newPos, oldPetId)
            self:SetDirty(true)
            Toast(textRes.PetTeam.DEPLOY_EXCHANGE_SUCCESS)
            PetTeamUtils.ShowTeam(self, self._curTeamInfo, self._uiObjs.Formation, self._uiObjs.Label_TeamPointNum, self._pet2ModelMap)
            PetTeamUtils.ShowFormation(self._curFormationCfg, self._curTeamInfo, self._uiObjs.Formation, true)
            self:UpdateDeployState(0, true)
          else
            self:UpdateDeployState(idx, true)
          end
        end
      else
        local petId = self._curTeamInfo:GetPosPet(newPos)
        if petId then
          self:UpdateDeployState(idx, false)
        else
          self:ChoosePet(self._curTeamInfo, function(petInfo)
            if petInfo then
              self._curTeamInfo:SetPosPet(newPos, petInfo.id)
              self:SetDirty(true)
              PetTeamUtils.ShowTeam(self, self._curTeamInfo, self._uiObjs.Formation, self._uiObjs.Label_TeamPointNum, self._pet2ModelMap)
              PetTeamUtils.ShowFormation(self._curFormationCfg, self._curTeamInfo, self._uiObjs.Formation, true)
              self:UpdateDeployState(idx, false)
            end
          end)
        end
      end
    else
      local petId = self._curTeamInfo:GetPosPet(newPos)
      local petInfo = PetMgr.Instance():GetPet(petId)
      if petInfo then
        require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(petInfo)
      end
    end
  else
    Toast(textRes.PetTeam.FORMATION_POS_INVALID)
  end
end
def.method().OnBtn_ExchangePos = function(self)
  if self._curState == PetTeamPanel.ShowState.EDIT then
    if self._bExchanging then
      Toast(textRes.PetTeam.DEPLOY_EXCHANGE_END)
    elseif self._curTeamInfo:GetPetCount() > 0 then
      Toast(textRes.PetTeam.DEPLOY_EXCHANGE_BEGIN)
    else
      Toast(textRes.PetTeam.DEPLOY_EXCHANGE_NO_PET)
      return
    end
    self:UpdateDeployState(0, not self._bExchanging)
  else
    self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
  end
end
def.method().OnBtn_PetOff = function(self)
  if self._curState == PetTeamPanel.ShowState.EDIT then
    local pos = self._curFormationCfg.idx2PosMap[self._selectedIdx]
    if self._curTeamInfo:CanPetOff(pos) then
      self._curTeamInfo:SetPosPet(pos, nil)
      self:SetDirty(true)
      PetTeamUtils.ShowTeam(self, self._curTeamInfo, self._uiObjs.Formation, self._uiObjs.Label_TeamPointNum, self._pet2ModelMap)
      PetTeamUtils.ShowFormation(self._curFormationCfg, self._curTeamInfo, self._uiObjs.Formation, true)
      self:UpdateDeployState(0, false)
    else
      Toast(textRes.PetTeam.DEPLOY_UNLOAD_LAST)
    end
  else
    self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
  end
end
def.method().OnBtn_PetSkill = function(self)
  if not PetTeamModule.Instance():IsPetSkillFeatrueOpen(true) then
    return
  end
  if self._curState == PetTeamPanel.ShowState.EDIT then
    local pos = self._curFormationCfg.idx2PosMap[self._selectedIdx]
    local petId = self._curTeamInfo:GetPosPet(pos)
    if petId then
      PetFightSkillPanel.ShowPanel(petId, nil)
    else
      self:UpdateDeployState(self._selectedIdx, self._bExchanging)
    end
  else
    self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
  end
end
def.method().OnBtn_ChangePet = function(self)
  if self._curState == PetTeamPanel.ShowState.EDIT then
    do
      local pos = self._curFormationCfg.idx2PosMap[self._selectedIdx]
      local petId = pos and self._curTeamInfo:GetPosPet(pos)
      if petId then
        self:ChoosePet(self._curTeamInfo, function(petInfo)
          if petInfo then
            self._curTeamInfo:SetPosPet(pos, petInfo.id)
            self:SetDirty(true)
            PetTeamUtils.ShowTeam(self, self._curTeamInfo, self._uiObjs.Formation, self._uiObjs.Label_TeamPointNum, self._pet2ModelMap)
            PetTeamUtils.ShowFormation(self._curFormationCfg, self._curTeamInfo, self._uiObjs.Formation, true)
            self:UpdateDeployState(self._selectedIdx, false)
          end
        end)
      else
        self:UpdateDeployState(self._selectedIdx, self._bExchanging)
      end
    end
  else
    self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
  end
end
def.method().OnImg_SetDefence = function(self)
  local curDefTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  local bToggle = self._uiObjs.Img_SetDefence:GetComponent("UIToggle").value
  if bToggle then
    if self._curTeamIdx ~= curDefTeamIdx then
      PetTeamProtocols.SendCPetFightSetDefenseTeamReq(self._curTeamIdx)
    end
  elseif self._curTeamIdx == curDefTeamIdx then
    GUIUtils.Toggle(self._uiObjs.Img_SetDefence, true)
  end
end
def.method().OnBtn_Change = function(self)
  if self._curState ~= PetTeamPanel.ShowState.EDIT then
    self:UpdateEditState(PetTeamPanel.ShowState.NORMAL, true)
    return
  end
  FormationPanel.ShowPanel(FormationPanel.ShowState.CHOOSE, self._curTeamInfo.formationId, function(newFormationId)
    if self._curTeamInfo.formationId ~= newFormationId then
      self._curTeamInfo:SetFormation(newFormationId)
      self:SetCurFormationCfg(newFormationId)
      self:SetDirty(true)
      PetTeamUtils.ShowTeam(self, self._curTeamInfo, self._uiObjs.Formation, self._uiObjs.Label_TeamPointNum, self._pet2ModelMap)
      PetTeamUtils.ShowFormation(self._curFormationCfg, self._curTeamInfo, self._uiObjs.Formation, true)
      self:UpdateFormationAttrs()
      self:UpdateDeployState(0, false)
    end
  end)
end
def.method().OnBtn_Help = function(self)
  GUIUtils.ShowHoverTip(constant.CPetFightConsts.TIP_ID, 0, 0)
end
def.method().OnBtn_All = function(self)
  local OverallPanel = require("Main.PetTeam.ui.OverallPanel")
  OverallPanel.ShowPanel(self._curTeamInfo)
end
def.method().OnBtnFormationUpgrade = function(self)
  FormationPanel.ShowPanel(FormationPanel.ShowState.UPGRADE, 0, nil)
end
def.method().OnBtnSetSkill = function(self)
  PetFightSkillPanel.ShowPanel(nil, nil)
end
def.method().OnBtn_PointsExchange = function(self)
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
    TokenType.PET_FIGHT_SCORE
  })
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_TEAM_INFO_CHANGE, PetTeamPanel.OnTeamInfoChange)
    eventFunc(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_DEF_TEAM_CHANGE, PetTeamPanel.OnDefTeamChange)
    eventFunc(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_FORMATION_CHANGE, PetTeamPanel.OnFormationChange)
    eventFunc(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetTeamPanel.OnFunctionOpenChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetTeamPanel.OnBagChange)
  end
end
def.static("table", "table").OnTeamInfoChange = function(params, context)
  warn("[PetTeamPanel:OnTeamInfoChange] OnTeamInfoChange.")
  local self = PetTeamPanel.Instance()
  if self and self:IsShow() then
    local teamIdx = params.teamIdx
    if teamIdx == self._curTeamIdx then
      self:TrySelectTeam(self._curTeamIdx, true)
    end
  end
end
def.static("table", "table").OnDefTeamChange = function(params, context)
  warn("[PetTeamPanel:OnDefTeamChange] OnDefTeamChange.")
  local self = PetTeamPanel.Instance()
  if self and self:IsShow() then
    self:UpdateDefenseTeam()
  end
end
def.static("table", "table").OnFormationChange = function(params, context)
  warn("[PetTeamPanel:OnFormationChange] OnFormationChange.")
  local self = PetTeamPanel.Instance()
  if self and self:IsShow() then
    local formationId = params.formationId
    local curFormationId = self._curTeamInfo and self._curTeamInfo.formationId or 0
    if curFormationId > 0 and formationId == curFormationId then
      self:UpdateFormationAttrs()
    end
  end
end
def.static("table", "table").OnSkillChange = function(params, context)
  warn("[PetTeamPanel:OnSkillChange] OnSkillChange.")
  local self = PetTeamPanel.Instance()
  if not self or self:IsShow() then
  end
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  warn("[PetTeamPanel:OnFunctionOpenChange] OnFunctionOpenChange.")
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local self = PetTeamPanel.Instance()
  if self and self:IsShow() and param.feature == ModuleFunSwitchInfo.TYPE_PET_FIGHT_SKILL then
    self:UpdatePetTeamSkill()
  end
end
def.static("table", "table").OnBagChange = function(param, context)
  warn("[PetTeamPanel:OnBagChange] OnBagChange.")
  local self = PetTeamPanel.Instance()
  if self and self:IsShow() then
    self:UpdateFormationReddot()
  end
end
def.method("table").OnSPetFightSetPositionFail = function(self, p)
  if self:IsShow() then
    local teamIdx = p.team
    if teamIdx == self._curTeamIdx then
      self:TrySelectTeam(self._curTeamIdx, true)
    end
  end
end
def.method("table").OnSPetFightSetTeamFormationFail = function(self, p)
  if self:IsShow() then
    local teamIdx = p.team
    if teamIdx == self._curTeamIdx then
      self:TrySelectTeam(self._curTeamIdx, true)
    end
  end
end
def.method("table").OnSPetFightSetDefenseTeamFail = function(self, p)
  if self:IsShow() then
    local teamIdx = p.team
    if teamIdx == self._curTeamIdx then
      self:UpdateDefenseTeam()
    end
  end
end
PetTeamPanel.Commit()
return PetTeamPanel
