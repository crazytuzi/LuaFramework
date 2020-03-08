local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgSelectPet = Lplus.Extend(ECPanelBase, "DlgSelectPet")
local def = DlgSelectPet.define
local dlg
local fightMgr = Lplus.ForwardDeclare("FightMgr")
local FightUnit = Lplus.ForwardDeclare("FightUnit")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
local petMgr = require("Main.Pet.mgr.PetMgr")
def.field("table").petList = nil
def.field("table").selectedPet = nil
def.field("table").childList = nil
def.field("table").selectedChild = nil
def.const("table").SUMMON_TYPE = {PET = 1, CHILD = 2}
def.field("number").summon_type = 0
def.static("=>", DlgSelectPet).Instance = function()
  if dlg == nil then
    dlg = DlgSelectPet()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgSelectPet.OnCloseSecondLevelUI)
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_FIGHT_SELECT_PET, 1)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgSelectPet.OnCloseSecondLevelUI)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_BgPetInfo_") then
    local index = tonumber(string.sub(id, string.len("Img_BgPetInfo_") + 1))
    self:OnSelect(index)
  elseif id == "Btn_Confirm" then
    self:Summon()
  elseif id == "Toggle_Pet" then
    self.summon_type = DlgSelectPet.SUMMON_TYPE.PET
    self:ShowPetList()
  elseif id == "Toggle_Children" then
    self.summon_type = DlgSelectPet.SUMMON_TYPE.CHILD
    self:ShowChildList()
  elseif id == "Btn_Back" then
    if self.summon_type == DlgSelectPet.SUMMON_TYPE.PET then
      if self.selectedPet == nil then
        Toast(textRes.Fight[58])
        return
      else
        fightMgr.Instance():Summon(require("consts.mzm.gsp.fight.confbean.OperateType").OP_SUMMON_PET, self.selectedPet.id)
      end
    elseif self.summon_type == DlgSelectPet.SUMMON_TYPE.CHILD then
      if self.selectedChild == nil then
        Toast(textRes.Fight[57])
        return
      else
        fightMgr.Instance():Summon(require("consts.mzm.gsp.fight.confbean.OperateType").OP_SUMMON_CHILD, self.selectedChild.id)
      end
    end
    self:Hide()
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if self.m_panel:FindDirect("Img_Bg0/Toggle_Children"):GetComponent("UIToggle").isChecked then
    self.summon_type = DlgSelectPet.SUMMON_TYPE.CHILD
    self:ShowChildList()
  else
    self.summon_type = DlgSelectPet.SUMMON_TYPE.PET
    self:ShowPetList()
  end
  self.m_panel:FindDirect("Img_Bg0/Btn_Confirm"):SetActive(true)
  self.m_panel:FindDirect("Img_Bg0/Btn_Back"):SetActive(false)
end
def.method().ShowPetList = function(self)
  self.selectedPet = nil
  local listPanel = self.m_panel:FindDirect("Img_Bg0/Scroll View/List")
  self.m_panel:FindDirect("Img_Bg0/Label_TipsNum"):GetComponent("UILabel").text = tostring(fightMgr.Instance().summonPetTimes)
  self.m_panel:FindDirect("Img_Bg0/Label_Tips1"):GetComponent("UILabel").text = textRes.Fight[54]
  local uiList = listPanel:GetComponent("UIList")
  local originalPetList = petMgr.Instance():GetPetList()
  self.petList = {}
  for k, pet in pairs(originalPetList) do
    table.insert(self.petList, pet)
  end
  local count = #self.petList
  if count == 0 then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = count
  uiList:Resize()
  local i = 1
  local curPet = fightMgr.Instance():GetMyPet()
  for k, pet in pairs(self.petList) do
    local petPanel = listPanel:FindDirect("Img_BgPetInfo_" .. i)
    petPanel:FindDirect("Label_PetName_" .. i):GetComponent("UILabel").text = pet.name
    petPanel:FindDirect("Label_Lv_" .. i):GetComponent("UILabel").text = pet.level .. textRes.Team[2]
    local cfg = pet:GetPetCfgData()
    local sp = petPanel:FindDirect("Img_BgHead_" .. i .. "/Img_IconHead_" .. i)
    local texture = sp:GetComponent("UITexture")
    if texture then
      local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(cfg.modelId)
      GUIUtils.FillIcon(texture, modelCfg.headerIconId)
      if table.indexof(fightMgr.Instance().summonedList, pet.id:tostring()) then
        GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Gray)
      else
        GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
      end
    end
    local isInFight = curPet and pet.id:eq(curPet.roleId)
    petPanel:FindDirect("Img_BgHead_" .. i .. "/Img_Sign_" .. i):SetActive(isInFight)
    local isSummoned = table.indexof(fightMgr.Instance().summonedList, pet.id:tostring())
    petPanel:FindDirect("Label_Aready_" .. i):SetActive(not isInFight and isSummoned)
    petPanel:FindDirect("Img_Select_" .. i):SetActive(false)
    i = i + 1
  end
  self.m_panel:FindDirect("Img_Bg0/Btn_Confirm"):SetActive(true)
  self.m_panel:FindDirect("Img_Bg0/Btn_Back"):SetActive(false)
  self:TouchGameObject(self.m_panel, self.m_parent)
  local scrollView = self.m_panel:FindDirect("Img_Bg0/Scroll View")
  scrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method().ShowChildList = function(self)
  self.selectedChild = nil
  local listPanel = self.m_panel:FindDirect("Img_Bg0/Scroll View/List")
  self.m_panel:FindDirect("Img_Bg0/Label_TipsNum"):GetComponent("UILabel").text = tostring(fightMgr.Instance().summonChildTimes)
  self.m_panel:FindDirect("Img_Bg0/Label_Tips1"):GetComponent("UILabel").text = textRes.Fight[55]
  local uiList = listPanel:GetComponent("UIList")
  self.childList = require("Main.Children.ChildrenDataMgr").Instance():GetFightChildren()
  local count = self.childList and #self.childList or 0
  if count == 0 then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = count
  uiList:Resize()
  local ChildrenUtils = require("Main.Children.ChildrenUtils")
  local i = 1
  local curPet = fightMgr.Instance():GetMyPet()
  for k, child in pairs(self.childList) do
    local petPanel = listPanel:FindDirect("Img_BgPetInfo_" .. i)
    petPanel:FindDirect("Label_PetName_" .. i):GetComponent("UILabel").text = child.name
    petPanel:FindDirect("Label_Lv_" .. i):GetComponent("UILabel").text = child.info.level .. textRes.Team[2]
    local sp = petPanel:FindDirect("Img_BgHead_" .. i .. "/Img_IconHead_" .. i)
    local texture = sp:GetComponent("UITexture")
    if texture then
      local child_model_cfgId = child:GetCurModelId()
      local child_model_cfg = ChildrenUtils.GetChildrenCfgById(child_model_cfgId)
      local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(child_model_cfg.modelId)
      GUIUtils.FillIcon(texture, modelCfg.headerIconId)
      if table.indexof(fightMgr.Instance().summonedChildList, child.id:tostring()) then
        GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Gray)
      else
        GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
      end
    end
    local isInFight = curPet and child.id:eq(curPet.roleId)
    petPanel:FindDirect("Img_BgHead_" .. i .. "/Img_Sign_" .. i):SetActive(isInFight)
    local isSummoned = table.indexof(fightMgr.Instance().summonedChildList, child.id:tostring())
    petPanel:FindDirect("Label_Aready_" .. i):SetActive(not isInFight and isSummoned)
    petPanel:FindDirect("Img_Select_" .. i):SetActive(false)
    i = i + 1
  end
  self.m_panel:FindDirect("Img_Bg0/Btn_Confirm"):SetActive(true)
  self.m_panel:FindDirect("Img_Bg0/Btn_Back"):SetActive(false)
  self:TouchGameObject(self.m_panel, self.m_parent)
  local scrollView = self.m_panel:FindDirect("Img_Bg0/Scroll View")
  scrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method().Summon = function(self)
  if self.summon_type == DlgSelectPet.SUMMON_TYPE.PET then
    if fightMgr.Instance().summonPetTimes <= 0 then
      Toast(textRes.Fight[20])
      return
    end
    if self.selectedPet == nil then
      Toast(textRes.Fight[19])
      return
    end
    if not self.selectedPet.isBinded then
      Toast(textRes.Fight[26])
      return
    end
    if table.indexof(fightMgr.Instance().summonedList, self.selectedPet.id:tostring()) then
      Toast(textRes.Fight[27])
      return
    end
    local state, result = petMgr.Instance():PetCanFighting(self.selectedPet.id)
    if result == petMgr.CResult.HERO_LEVEL_TOO_LOW then
      Toast(textRes.Pet[42])
    elseif result == petMgr.CResult.LIFE_TOO_SHORT then
      Toast(textRes.Pet[47])
    else
      fightMgr.Instance():Summon(require("consts.mzm.gsp.fight.confbean.OperateType").OP_SUMMON_PET, self.selectedPet.id)
      self:Hide()
    end
  else
    if 0 >= fightMgr.Instance().summonChildTimes then
      Toast(textRes.Fight[20])
      return
    end
    if self.selectedChild == nil then
      Toast(textRes.Fight[56])
      return
    end
    if table.indexof(fightMgr.Instance().summonedChildList, self.selectedChild.id:tostring()) then
      Toast(textRes.Fight[27])
      return
    end
    fightMgr.Instance():Summon(require("consts.mzm.gsp.fight.confbean.OperateType").OP_SUMMON_CHILD, self.selectedChild.id)
    self:Hide()
  end
end
def.method("number").OnSelect = function(self, index)
  if self.summon_type == DlgSelectPet.SUMMON_TYPE.PET then
    if self.selectedPet and self.selectedPet == self.petList[index] then
      require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(self.selectedPet)
    end
    local listPanel = self.m_panel:FindDirect("Img_Bg0/Scroll View/List")
    local uiList = listPanel:GetComponent("UIList")
    for i = 1, uiList.itemCount do
      local petPanel = listPanel:FindDirect("Img_BgPetInfo_" .. i)
      petPanel:FindDirect("Img_Select_" .. i):SetActive(i == index)
    end
    self.selectedPet = self.petList[index]
    local fightPetId = fightMgr.Instance():GetCurrentPetId()
    local isCurrentPet = fightPetId ~= nil and self.selectedPet.id:eq(fightPetId)
    self.m_panel:FindDirect("Img_Bg0/Btn_Confirm"):SetActive(not isCurrentPet)
    self.m_panel:FindDirect("Img_Bg0/Btn_Back"):SetActive(isCurrentPet)
  elseif self.summon_type == DlgSelectPet.SUMMON_TYPE.CHILD then
    local listPanel = self.m_panel:FindDirect("Img_Bg0/Scroll View/List")
    local uiList = listPanel:GetComponent("UIList")
    for i = 1, uiList.itemCount do
      local petPanel = listPanel:FindDirect("Img_BgPetInfo_" .. i)
      petPanel:FindDirect("Img_Select_" .. i):SetActive(i == index)
    end
    self.selectedChild = self.childList[index]
    local fightPetId = fightMgr.Instance():GetCurrentPetId()
    local isCurrentPet = fightPetId ~= nil and self.selectedChild.id:eq(fightPetId)
    self.m_panel:FindDirect("Img_Bg0/Btn_Confirm"):SetActive(not isCurrentPet)
    self.m_panel:FindDirect("Img_Bg0/Btn_Back"):SetActive(isCurrentPet)
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
DlgSelectPet.Commit()
return DlgSelectPet
