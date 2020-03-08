local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetTeamProtocols = require("Main.PetTeam.PetTeamProtocols")
local PetTeamUtils = require("Main.PetTeam.PetTeamUtils")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local Vector = require("Types.Vector3")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local PetFightSkillPanel = Lplus.Extend(ECPanelBase, "PetFightSkillPanel")
local def = PetFightSkillPanel.define
local instance
def.static("=>", PetFightSkillPanel).Instance = function()
  if instance == nil then
    instance = PetFightSkillPanel()
  end
  return instance
end
local MAX_PET_PER_PAGE = 5
local SKILL_TIPS_X = -306
local SKILL_TIPS_Y = 109
def.field("table")._uiObjs = nil
def.field("function")._callback = nil
def.field("table")._petList = nil
def.field("number")._selectedPetIdx = 1
def.field("table")._skillCfgList = nil
def.field("number")._selectedSkillIdx = 1
def.static("userdata", "function").ShowPanel = function(petId, callback)
  if not require("Main.PetTeam.PetTeamModule").Instance():IsPetSkillOpen(true) then
    if PetFightSkillPanel.Instance():IsShow() then
      PetFightSkillPanel.Instance():DestroyPanel()
    end
    return
  end
  PetFightSkillPanel.Instance():_InitData(petId, callback)
  if PetFightSkillPanel.Instance():IsShow() then
    PetFightSkillPanel.Instance():UpdateUI()
    return
  end
  PetFightSkillPanel.Instance():CreatePanel(RESPATH.PREFAB_PETTEAM_SKILL_PANEL, 2)
end
def.method("userdata", "function")._InitData = function(self, petId, callback)
  self._callback = callback
  local petList = PetMgr.Instance():GetPetList()
  self._petList = {}
  self._selectedPetIdx = 1
  if petList then
    for _, pet in pairs(petList) do
      if pet:IsBinded() then
        table.insert(self._petList, pet)
        if petId and Int64.eq(petId, pet.id) then
          self._selectedPetIdx = #self._petList
        end
      end
    end
  end
  local skillList = PetTeamData.Instance():GetSkillCfgs()
  self._skillCfgList = {}
  self._selectedSkillIdx = 1
  if skillList then
    for id, cfg in pairs(skillList) do
      table.insert(self._skillCfgList, cfg)
    end
    table.sort(self._skillCfgList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local bUnlockA = PetTeamData.Instance():GetSkillUnlock(a.id)
        local bUnlockB = PetTeamData.Instance():GetSkillUnlock(b.id)
        if bUnlockA == bUnlockB then
          return a.id < b.id
        else
          return bUnlockA
        end
      end
    end)
  end
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_PetList = self.m_panel:FindDirect("Img_Bg/Img_PetList/Group_Title/Label_PetList")
  self._uiObjs.Label_PetListNum = self.m_panel:FindDirect("Img_Bg/Img_PetList/Group_Title/Label_PetListNum")
  self._uiObjs.Scroll_ViewPet = self.m_panel:FindDirect("Img_Bg/Img_PetList/Group_List/Scroll View_PetList")
  self._uiObjs.uiScrollViewPet = self._uiObjs.Scroll_ViewPet:GetComponent("UIScrollView")
  self._uiObjs.List_PetList = self._uiObjs.Scroll_ViewPet:FindDirect("List_PetList")
  self._uiObjs.uiListPet = self._uiObjs.List_PetList:GetComponent("UIList")
  self._uiObjs.Group_SkillInfo = self.m_panel:FindDirect("Img_Bg/Group_Skill/Group_SkillInfo")
  self._uiObjs.Img_BgSkill = self._uiObjs.Group_SkillInfo:FindDirect("Img_BgSkill")
  self._uiObjs.Img_IconSkill = self._uiObjs.Img_BgSkill:FindDirect("Img_IconSkill")
  self._uiObjs.Label_Name = self._uiObjs.Group_SkillInfo:FindDirect("Label_Name")
  self._uiObjs.Label_Info = self._uiObjs.Group_SkillInfo:FindDirect("Label_Info")
  self._uiObjs.Label_SkillNull = self._uiObjs.Group_SkillInfo:FindDirect("Label_SkillNull")
  self._uiObjs.Scroll_ViewSkill = self.m_panel:FindDirect("Img_Bg/Group_Skill/Group_Skill/Scrollview")
  self._uiObjs.uiScrollViewSkill = self._uiObjs.Scroll_ViewSkill:GetComponent("UIScrollView")
  self._uiObjs.List_SkillList = self._uiObjs.Scroll_ViewSkill:FindDirect("List")
  self._uiObjs.uiListSkill = self._uiObjs.List_SkillList:GetComponent("UIList")
  self._uiObjs.Group_Points = self.m_panel:FindDirect("Img_Bg/Group_Points")
  self._uiObjs.Label_CostNum = self._uiObjs.Group_Points:FindDirect("Label_CostNum")
  self._uiObjs.Label_OwnNum = self._uiObjs.Group_Points:FindDirect("Label_OwnNum")
  self._uiObjs.Btn_Buy = self.m_panel:FindDirect("Img_Bg/Btn_Buy")
  self._uiObjs.Btn_Use = self.m_panel:FindDirect("Img_Bg/Btn_Use")
  self._uiObjs.LabelUse = self._uiObjs.Btn_Use:FindDirect("Label")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
    if self._selectedPetIdx > MAX_PET_PER_PAGE and self:GetPetCount() > 0 then
      GameUtil.AddGlobalLateTimer(0.01, true, function()
        if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiScrollViewPet) then
          local amountY = self._selectedPetIdx / self:GetPetCount()
          self._uiObjs.uiScrollViewPet:SetDragAmount(0, amountY, false)
        end
      end)
    else
      self._uiObjs.uiScrollViewPet:ResetPosition()
    end
  else
  end
end
def.method().UpdateUI = function(self)
  self:ShowPetList()
  self:ShowSkillList()
  self:SelectPet(self._selectedPetIdx, true)
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearPetList()
  self:_ClearSkillList()
  self._uiObjs = nil
  self._petList = nil
  self._selectedPetIdx = 1
  self._skillCfgList = nil
  self._selectedSkillIdx = 1
end
def.method("=>", "number").GetPetCount = function(self)
  return self._petList and #self._petList or 0
end
def.method("number", "=>", "table").GetPetInfo = function(self, idx)
  return self._petList and self._petList[idx]
end
def.method().ShowPetList = function(self)
  self:_ClearPetList()
  local petCount = self:GetPetCount()
  GUIUtils.SetText(self._uiObjs.Label_PetListNum, petCount .. "/" .. petCount)
  if petCount > 0 then
    self._uiObjs.uiListPet.itemCount = petCount
    self._uiObjs.uiListPet:Resize()
    self._uiObjs.uiListPet:Reposition()
    for idx, petInfo in ipairs(self._petList) do
      self:ShowPetInfo(idx, petInfo)
    end
  else
  end
end
def.method("number", "table").ShowPetInfo = function(self, idx, petInfo)
  local listItem = self._uiObjs.uiListPet.children[idx]
  if nil == listItem then
    warn("[ERROR][PetFightSkillPanel:ShowPetInfo] listItem nil at idx:", idx)
    return
  end
  if nil == petInfo then
    warn("[ERROR][PetFightSkillPanel:ShowPetInfo] petInfo nil at idx:", idx)
    return
  end
  local Label_Name = listItem:FindDirect("Pet01/Label_PetName01")
  GUIUtils.SetText(Label_Name, petInfo.name)
  local Label_Lv = listItem:FindDirect("Pet01/Label_PetLv01")
  GUIUtils.SetText(Label_Lv, petInfo.level)
  local Icon_Pet = listItem:FindDirect("Pet01/Img_BgPetItem/Icon_Pet01")
  GUIUtils.SetTexture(Icon_Pet, petInfo:GetHeadIconId())
  self:UpdatePetInfo(idx, listItem, petInfo)
end
def.method("number", "userdata", "table").UpdatePetInfo = function(self, idx, listItem, petInfo)
  if nil == listItem then
    warn("[ERROR][PetFightSkillPanel:UpdatePetInfo] listItem nil at idx:", idx)
    return
  end
  if nil == petInfo then
    warn("[ERROR][PetFightSkillPanel:UpdatePetInfo] petInfo nil at idx:", idx)
    return
  end
  local Img_Skill = listItem:FindDirect("Pet01/Img_Skill")
  local skillId = PetTeamData.Instance():GetPetSkill(petInfo.id)
  GUIUtils.SetActive(Img_Skill, skillId > 0)
end
def.method().UpdateAllPetInfo = function(self)
  local petCount = self:GetPetCount()
  if petCount > 0 then
    for idx, petInfo in ipairs(self._petList) do
      local listItem = self._uiObjs.uiListPet.children[idx]
      self:UpdatePetInfo(idx, listItem, petInfo)
    end
  end
end
def.method()._ClearPetList = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiListPet) then
    self._uiObjs.uiListPet.itemCount = 0
    self._uiObjs.uiListPet:Resize()
    self._uiObjs.uiListPet:Reposition()
  end
end
def.method("number", "boolean").SelectPet = function(self, idx, bForce)
  if not bForce and idx == self._selectedPetIdx then
    return
  end
  self._selectedPetIdx = idx
  if self._selectedPetIdx > 0 then
    local listItem = self._uiObjs.uiListPet.children[idx]
    if listItem then
      local petToggle = listItem:FindDirect("Pet01")
      GUIUtils.Toggle(petToggle, true)
    else
      warn("[ERROR][PetFightSkillPanel:SelectPet] listItem nil at idx:", idx)
    end
  end
  self:UpdateSelectedPetSkill()
  self:SelectSkill(self._selectedSkillIdx, true, false)
  self:UpdateAllSkillInfo()
end
def.method().UpdateSelectedPetSkill = function(self)
  local petInfo = self:GetPetInfo(self._selectedPetIdx)
  local petSkillId = petInfo and PetTeamData.Instance():GetPetSkill(petInfo.id) or 0
  if petSkillId > 0 then
    GUIUtils.SetActive(self._uiObjs.Img_BgSkill, true)
    GUIUtils.SetActive(self._uiObjs.Label_Name, true)
    GUIUtils.SetActive(self._uiObjs.Label_Info, true)
    GUIUtils.SetActive(self._uiObjs.Label_SkillNull, false)
    local petSkillCfg = PetTeamData.Instance():GetSkillCfg(petSkillId)
    local skillCfg = petSkillCfg and SkillUtility.GetSkillCfg(petSkillCfg.skillId)
    if nil == skillCfg then
      warn("[ERROR][PetFightSkillPanel:UpdateSelectedPetSkill] skillCfg nil for petSkillId:", petSkillId)
      return
    end
    GUIUtils.SetText(self._uiObjs.Label_Name, skillCfg.name)
    GUIUtils.SetTexture(self._uiObjs.Img_IconSkill, skillCfg.iconId)
    GUIUtils.SetText(self._uiObjs.Label_Info, skillCfg.description)
  else
    GUIUtils.SetActive(self._uiObjs.Img_BgSkill, false)
    GUIUtils.SetActive(self._uiObjs.Label_Name, false)
    GUIUtils.SetActive(self._uiObjs.Label_Info, false)
    GUIUtils.SetActive(self._uiObjs.Label_SkillNull, true)
  end
end
def.method("=>", "number").GetSkillCount = function(self)
  return self._skillCfgList and #self._skillCfgList or 0
end
def.method("number", "=>", "table").GetSkillCfg = function(self, idx)
  return self._skillCfgList and self._skillCfgList[idx]
end
def.method().ShowSkillList = function(self)
  self:_ClearSkillList()
  self._uiObjs.uiScrollViewSkill:ResetPosition()
  local skillCount = self:GetSkillCount()
  if skillCount > 0 then
    self._uiObjs.uiListSkill.itemCount = skillCount
    self._uiObjs.uiListSkill:Resize()
    self._uiObjs.uiListSkill:Reposition()
    for idx, petSkillCfg in ipairs(self._skillCfgList) do
      self:ShowSkillInfo(idx, petSkillCfg)
    end
  end
end
def.method("number", "table").ShowSkillInfo = function(self, idx, petSkillCfg)
  local listItem = self._uiObjs.uiListSkill.children[idx]
  if nil == listItem then
    warn("[ERROR][PetFightSkillPanel:ShowSkillInfo] listItem nil at idx:", idx)
    return
  end
  if nil == petSkillCfg then
    warn("[ERROR][PetFightSkillPanel:ShowSkillInfo] petSkillCfg nil at idx:", idx)
    return
  end
  local skillCfg = SkillUtility.GetSkillCfg(petSkillCfg.skillId)
  if nil == skillCfg then
    warn("[ERROR][PetFightSkillPanel:ShowSkillInfo] skillCfg nil for petSkillCfg.skillId:", petSkillCfg.skillId)
    return
  end
  local Label_Name = listItem:FindDirect("Label_Skill")
  GUIUtils.SetText(Label_Name, skillCfg.name)
  local Img_Icon = listItem:FindDirect("Img__BgIconGroup/Texture_IconGroup")
  GUIUtils.SetTexture(Img_Icon, skillCfg.iconId)
  self:UpdateSkillInfo(idx, listItem, petSkillCfg)
end
def.method("number", "userdata", "table").UpdateSkillInfo = function(self, idx, listItem, petSkillCfg)
  if nil == listItem then
    warn("[ERROR][PetFightSkillPanel:UpdateSkillInfo] listItem nil at idx:", idx)
    return
  end
  if nil == petSkillCfg then
    warn("[ERROR][Sk*illPanel:UpdateSkillInfo] petSkillCfg nil at idx:", idx)
    return
  end
  local skillPetId = PetTeamData.Instance():GetSkillPet(petSkillCfg.id)
  local petInfo = self:GetPetInfo(self._selectedPetIdx)
  local Img_Use = listItem:FindDirect("Img_Use")
  GUIUtils.SetActive(Img_Use, skillPetId and petInfo and Int64.eq(petInfo.id, skillPetId))
end
def.method().UpdateAllSkillInfo = function(self)
  local skillCount = self:GetSkillCount()
  if skillCount > 0 then
    for idx, petSkillCfg in ipairs(self._skillCfgList) do
      local listItem = self._uiObjs.uiListSkill.children[idx]
      self:UpdateSkillInfo(idx, listItem, petSkillCfg)
    end
  end
end
def.method()._ClearSkillList = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiListSkill) then
    self._uiObjs.uiListSkill.itemCount = 0
    self._uiObjs.uiListSkill:Resize()
    self._uiObjs.uiListSkill:Reposition()
  end
end
def.method("number", "boolean", "boolean").SelectSkill = function(self, idx, bForce, bTip)
  if bTip then
    local petSkillCfg = self:GetSkillCfg(idx)
    if nil == petSkillCfg then
      warn("[ERROR][PetFightSkillPanel:SelectSkill] petSkillCfg nil at idx:", idx)
    else
      PetTeamUtils.ShowFightPetSkillTip(petSkillCfg.id, {x = SKILL_TIPS_X, y = SKILL_TIPS_Y}, 0, nil)
    end
  end
  if not bForce and idx == self._selectedSkillIdx then
    return
  end
  self._selectedSkillIdx = idx
  local listItem = self._uiObjs.uiListSkill.children[idx]
  if nil == listItem then
    warn("[ERROR][PetFightSkillPanel:SelectSkill] listItem nil at idx:", idx)
    return
  end
  GUIUtils.Toggle(listItem, true)
  self:UpdateSelectedSkill()
end
def.method().UpdateSelectedSkill = function(self)
  local petSkillCfg = self:GetSkillCfg(self._selectedSkillIdx)
  if nil == petSkillCfg then
    warn("[ERROR][PetFightSkillPanel:UpdateSelectedSkill] petSkillCfg nil at idx:", self._selectedSkillIdx)
    return
  end
  local bUnlock = PetTeamData.Instance():GetSkillUnlock(petSkillCfg.id)
  if bUnlock then
    GUIUtils.SetActive(self._uiObjs.Group_Points, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Buy, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Use, true)
    local petInfo = self:GetPetInfo(self._selectedPetIdx)
    local petSkillId = petInfo and PetTeamData.Instance():GetPetSkill(petInfo.id) or 0
    if petSkillId == petSkillCfg.id then
      GUIUtils.SetText(self._uiObjs.LabelUse, textRes.PetTeam.SKILL_UNUSE)
    else
      GUIUtils.SetText(self._uiObjs.LabelUse, textRes.PetTeam.SKILL_USE)
    end
  else
    GUIUtils.SetActive(self._uiObjs.Group_Points, true)
    GUIUtils.SetActive(self._uiObjs.Btn_Buy, true)
    GUIUtils.SetActive(self._uiObjs.Btn_Use, false)
    GUIUtils.SetText(self._uiObjs.Label_CostNum, petSkillCfg.unlockScore)
    local credit = PetTeamData.Instance():GetPetSkillCredit()
    GUIUtils.SetText(self._uiObjs.Label_OwnNum, Int64.tostring(credit))
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif string.find(id, "item") then
    self:OnSkillItemClicked(id)
  elseif id == "Pet01" then
    self:OnPetItemClicked(clickObj)
  elseif id == "Btn_Use" then
    self:OnBtn_UseClicked()
  elseif id == "Btn_Buy" then
    self:OnBtn_BuyClicked()
  end
end
def.method().OnBtn_Close = function(self)
  if self._callback then
    self._callback()
  end
  self:DestroyPanel()
end
def.method("string").OnSkillItemClicked = function(self, id)
  local togglePrefix = "item_"
  local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  self:SelectSkill(idx, false, true)
end
def.method("userdata").OnPetItemClicked = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  local id = parent and parent.name
  if id then
    local togglePrefix = "item_"
    local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    self:SelectPet(idx, false)
  end
end
def.method().OnBtn_UseClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local petSkillCfg = self:GetSkillCfg(self._selectedSkillIdx)
  if nil == petSkillCfg then
    warn("[ERROR][PetFightSkillPanel:OnBtn_UseClicked] petSkillCfg nil at idx:", self._selectedSkillIdx)
    return
  end
  local bUnlock = PetTeamData.Instance():GetSkillUnlock(petSkillCfg.id)
  if bUnlock then
    do
      local petInfo = self:GetPetInfo(self._selectedPetIdx)
      if petInfo then
        local petSkillId = PetTeamData.Instance():GetPetSkill(petInfo.id)
        if petSkillId == petSkillCfg.id then
          PetTeamProtocols.SendCPetFightSetSkillReq(petInfo.id, 0)
        else
          local petId = PetTeamData.Instance():GetSkillPet(petSkillCfg.id)
          if petId then
            local replacePetInfo = PetMgr.Instance():GetPet(petId)
            local content = string.format(textRes.PetTeam.SKILL_USE_CONFIRM_CONTENT, replacePetInfo and replacePetInfo.name or "")
            require("GUI.CommonConfirmDlg").ShowConfirm(textRes.PetTeam.SKILL_USE_CONFIRM_TITLE, content, function(id, tag)
              if id == 1 then
                PetTeamProtocols.SendCPetFightSetSkillReq(petInfo.id, petSkillCfg.id)
              end
            end, nil)
          else
            PetTeamProtocols.SendCPetFightSetSkillReq(petInfo.id, petSkillCfg.id)
          end
        end
      else
        warn("[ERROR][PetFightSkillPanel:OnBtn_UseClicked] petInfo nil for self._selectedPetIdx:", self._selectedPetIdx)
      end
    end
  else
    warn("[ERROR][PetFightSkillPanel:OnBtn_UseClicked] petSkill still locked:", petSkillCfg.id)
    self:UpdateSelectedSkill()
  end
end
def.method().OnBtn_BuyClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local petSkillCfg = self:GetSkillCfg(self._selectedSkillIdx)
  if nil == petSkillCfg then
    warn("[ERROR][PetFightSkillPanel:OnBtn_BuyClicked] petSkillCfg nil at self._selectedSkillIdx:", self._selectedSkillIdx)
    return
  end
  local credit = PetTeamData.Instance():GetPetSkillCredit()
  if Int64.lt(credit, petSkillCfg.unlockScore) then
    Toast(textRes.PetTeam.SKILL_UNLOCK_LACK_CREDIT)
  else
    PetTeamProtocols.SendCPetFightUnlockSkillReq(petSkillCfg.id)
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
    eventFunc(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_SKILL_CHANGE, PetFightSkillPanel.OnSkillChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, PetFightSkillPanel.OnCreditChange)
  end
end
def.static("table", "table").OnSkillChange = function(params, context)
  local petSkillId = params.skillId
  warn("[PetFightSkillPanel:OnSkillChange] OnSkillChange, petSkillId:", petSkillId)
  local self = PetFightSkillPanel.Instance()
  if self and self:IsShow() then
    self:UpdateAllPetInfo()
    self:UpdateSelectedPetSkill()
    self:UpdateAllSkillInfo()
    self:UpdateSelectedSkill()
  end
end
def.static("table", "table").OnCreditChange = function(params, context)
  warn("[PetFightSkillPanel:OnCreditChange] OnCreditChange.")
  local self = PetFightSkillPanel.Instance()
  if self and self:IsShow() then
    self:UpdateSelectedSkill()
  end
end
PetFightSkillPanel.Commit()
return PetFightSkillPanel
