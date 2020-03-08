local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsSkillResetPanel = Lplus.Extend(ECPanelBase, "MountsSkillResetPanel")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsUtils = require("Main.Mounts.MountsUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local SkillUtility = require("Main.Skill.SkillUtility")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = MountsSkillResetPanel.define
local instance
def.field("table").uiObjs = nil
def.field("userdata").mountsId = nil
def.field("number").selectedSkillId = 0
def.field("boolean").hasEnoughMaterial = false
def.field("boolean").hasReplaceSkill = false
def.field("boolean").useYuanbao = false
def.field("number").needYuanbao = 0
def.field("number").needItemType = -1
def.field("number").needItemNum = 0
def.field("number").hasItemNum = 0
def.field("number").calItemId = 0
def.field("number").selectecSkillRank = 0
def.static("=>", MountsSkillResetPanel).Instance = function()
  if instance == nil then
    instance = MountsSkillResetPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, mountsId)
  if self.m_panel ~= nil or not MountsMgr.Instance():HasMounts(mountsId) then
    return
  end
  self.mountsId = mountsId
  self:CreatePanel(RESPATH.PREFAB_MOUNTS_SKILL_RESET, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:SelectMountsSkill(0)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsResetSkillSuccess, MountsSkillResetPanel.OnMountsResetSkillSuccess)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsReplaceSkillSuccess, MountsSkillResetPanel.OnMountsReplaceSkillSuccess)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MountsSkillResetPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsSkillResetPanel.OnMountsFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.selectedSkillId = 0
  self.hasEnoughMaterial = false
  self.hasReplaceSkill = false
  self.useYuanbao = false
  self.needYuanbao = 0
  self.needItemType = -1
  self.needItemNum = 0
  self.hasItemNum = 0
  self.calItemId = 0
  self.selectecSkillRank = 0
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsResetSkillSuccess, MountsSkillResetPanel.OnMountsResetSkillSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsReplaceSkillSuccess, MountsSkillResetPanel.OnMountsReplaceSkillSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MountsSkillResetPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsSkillResetPanel.OnMountsFunctionOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_SmallSelected = self.m_panel:FindDirect("Group_SmallSelected")
  GUIUtils.SetActive(self.uiObjs.Img_Bg:FindDirect("Gruop_Btn/Btn_SkillLib"), not GameUtil.IsEvaluation())
  GUIUtils.SetActive(self.uiObjs.Group_SmallSelected, false)
end
def.method().ShowAvailableSkills = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_SmallSelected, true)
  local skills = MountsMgr.Instance():GetMountsPassiveSkillIds(self.mountsId)
  local Img_Bg = self.uiObjs.Group_SmallSelected:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Scroll View")
  local List_Item = ScrollView:FindDirect("List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList:set_itemCount(#skills)
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local listItem = items[i]
    self:FillOptionSkillItem(listItem, skills[i])
  end
  uiList:Resize()
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_panel ~= nil and not self.m_panel.isnil then
        ScrollView:GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  end)
end
def.method("userdata", "number").FillOptionSkillItem = function(self, item, skillId)
  local Btn_Item = item:FindDirect("Btn_Item")
  local Label_Name = Btn_Item:FindDirect("Label_Name")
  local skillTag = Btn_Item:GetComponent("UILabel")
  if skillTag == nil then
    skillTag = Btn_Item:AddComponent("UILabel")
    skillTag:set_enabled(false)
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  if skillCfg == nil then
    skillTag.text = ""
    GUIUtils.SetText(Label_Name, textRes.Mounts[35])
  else
    skillTag.text = skillId
    GUIUtils.SetText(Label_Name, skillCfg.name)
  end
end
def.method("number").SelectMountsSkill = function(self, skillId)
  self.selectedSkillId = skillId
  self.hasEnoughMaterial = false
  self.hasReplaceSkill = false
  self.needYuanbao = 0
  self.needItemType = -1
  self:FindSelectedSkillRank()
  self:FillSelectedSkillInfo()
  self:FillReplaceSkillInfo()
  self:FillCostInfo()
  self:SetButtonStatus()
end
def.method().FindSelectedSkillRank = function(self)
  self.selectecSkillRank = 0
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts ~= nil then
    local skillRankCfg = MountsUtils.GetMountsPassiveSkillCfg(mounts.mounts_cfg_id)
    if skillRankCfg ~= nil then
      for rank, skillList in pairs(skillRankCfg) do
        for i = 1, #skillList do
          if skillList[i].passiveSkillCfgId == self.selectedSkillId then
            self.selectecSkillRank = rank
            return
          end
        end
      end
    end
  end
end
def.method().FillSelectedSkillInfo = function(self)
  local skillCfg = SkillUtility.GetSkillCfg(self.selectedSkillId)
  local Group_Current = self.uiObjs.Img_Bg:FindDirect("Group_Current")
  local Label_SkillInfo = Group_Current:FindDirect("Label_SkillInfo")
  local Label_SkillName = Group_Current:FindDirect("Label_SkillName")
  local Img_SkillKuang = Group_Current:FindDirect("Img_SkillKuang")
  local Img_SkillIcon = Img_SkillKuang:FindDirect("Img_SkillIcon")
  local Btn_Add = Img_SkillKuang:FindDirect("Btn_Add")
  local Label_SkillJieshu = Group_Current:FindDirect("Label_SkillJieshu")
  if skillCfg == nil then
    GUIUtils.SetActive(Btn_Add, true)
    GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), 0)
    GUIUtils.SetText(Label_SkillName, textRes.Mounts[37])
    GUIUtils.SetText(Label_SkillInfo, textRes.Mounts[37])
    GUIUtils.SetText(Label_SkillJieshu, "")
    GUIUtils.SetItemCellSprite(Img_SkillKuang, ItemColor.WHITE)
  else
    GUIUtils.SetActive(Btn_Add, false)
    GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), skillCfg.iconId)
    GUIUtils.SetText(Label_SkillName, skillCfg.name)
    GUIUtils.SetText(Label_SkillInfo, skillCfg.description)
    GUIUtils.SetText(Label_SkillJieshu, string.format(textRes.Mounts[91], self.selectecSkillRank))
    local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
    if mounts ~= nil then
      local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgByMountsIdAndSkillId(mounts.mounts_cfg_id, self.selectedSkillId)
      if passiveSkillCfg ~= nil then
        GUIUtils.SetItemCellSprite(Img_SkillKuang, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
      else
        GUIUtils.SetItemCellSprite(Img_SkillKuang, ItemColor.WHITE)
      end
    else
      GUIUtils.SetItemCellSprite(Img_SkillKuang, ItemColor.WHITE)
    end
  end
end
def.method().FillReplaceSkillInfo = function(self)
  local Group_Result = self.uiObjs.Img_Bg:FindDirect("Group_Result")
  local Label_ResetTips = self.m_panel:FindDirect("Label_ResetTips")
  local skillInfo = MountsMgr.Instance():GetMountsPassiveSkillInfo(self.mountsId, self.selectedSkillId)
  if skillInfo == nil then
    self.hasReplaceSkill = false
    GUIUtils.SetActive(Group_Result, false)
    GUIUtils.SetActive(Label_ResetTips, true)
    return
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillInfo.refresh_passive_skill_cfg_id)
  local Label_SkillInfo = Group_Result:FindDirect("Label_SkillInfo")
  local Label_SkillName = Group_Result:FindDirect("Label_SkillName")
  local Img_SkillKuang = Group_Result:FindDirect("Img_SkillKuang")
  local Img_SkillIcon = Img_SkillKuang:FindDirect("Img_SkillIcon")
  local Label_SkillJieshu = Group_Result:FindDirect("Label_SkillJieshu")
  if skillCfg == nil then
    GUIUtils.SetActive(Group_Result, false)
    GUIUtils.SetActive(Label_ResetTips, true)
    GUIUtils.SetText(Label_SkillJieshu, "")
    self.hasReplaceSkill = false
    GUIUtils.SetItemCellSprite(Img_SkillKuang, ItemColor.WHITE)
  else
    GUIUtils.SetActive(Group_Result, true)
    GUIUtils.SetActive(Label_ResetTips, false)
    GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), skillCfg.iconId)
    GUIUtils.SetText(Label_SkillName, skillCfg.name)
    GUIUtils.SetText(Label_SkillInfo, skillCfg.description)
    GUIUtils.SetText(Label_SkillJieshu, string.format(textRes.Mounts[91], self.selectecSkillRank))
    self.hasReplaceSkill = true
    local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
    if mounts ~= nil then
      local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgByMountsIdAndSkillId(mounts.mounts_cfg_id, skillInfo.refresh_passive_skill_cfg_id)
      if passiveSkillCfg ~= nil then
        GUIUtils.SetItemCellSprite(Img_SkillKuang, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
      else
        GUIUtils.SetItemCellSprite(Img_SkillKuang, ItemColor.WHITE)
      end
    else
      GUIUtils.SetItemCellSprite(Img_SkillKuang, ItemColor.WHITE)
    end
  end
end
def.method().FillCostInfo = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  local skillRankIndex = MountsMgr.Instance():GetMountsPassiveSkillRankIndx(self.mountsId, self.selectedSkillId)
  local mountsSkillRanks = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mounts.mounts_cfg_id)
  local Img_Item = self.uiObjs.Img_Bg:FindDirect("Img_Item")
  local Label_ItemName = Img_Item:FindDirect("Label_ItemName")
  local Label_ItemNum = Img_Item:FindDirect("Label")
  local Texture_Item = Img_Item:FindDirect("Texture_Item")
  if skillRankIndex <= 0 or mountsSkillRanks[skillRankIndex] == nil or self.selectedSkillId == 0 or mountsSkillRanks == nil then
    GUIUtils.SetActive(Img_Item, false)
  else
    local refreshCfg = MountsUtils.GetMountsPassiveSkillRefreshCfgOfRank(mounts.mounts_cfg_id, mountsSkillRanks[skillRankIndex])
    if refreshCfg == nil then
      GUIUtils.SetActive(Img_Item, false)
    else
      GUIUtils.SetActive(Img_Item, true)
      self.hasEnoughMaterial = false
      local needItemType = refreshCfg.refreshCostItemType
      local needNum = refreshCfg.refreshCostItemNum
      local calItemId = refreshCfg.refreshCostItemId
      local needItemList = ItemUtils.GetItemTypeRefIdList(needItemType)
      if needItemList ~= nil then
        local itemBase = ItemUtils.GetItemBase(needItemList[1])
        if itemBase ~= nil then
          self.needItemType = needItemType
          GUIUtils.FillIcon(Texture_Item:GetComponent("UITexture"), itemBase.icon)
          local hasNum = 0
          local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, needItemType)
          for k, v in pairs(items) do
            hasNum = hasNum + v.number
          end
          self.needItemNum = needNum
          self.hasItemNum = hasNum
          self.calItemId = calItemId
          if needNum > hasNum then
            GUIUtils.SetText(Label_ItemNum, string.format("[ff0000]%d/%d[-]", hasNum, needNum))
            self.hasEnoughMaterial = false
          else
            GUIUtils.SetText(Label_ItemNum, string.format("%d/%d", hasNum, needNum))
            self.hasEnoughMaterial = true
          end
          GUIUtils.SetText(Label_ItemName, itemBase.name)
        end
      end
    end
  end
end
def.method().SetButtonStatus = function(self)
  local Gruop_Btn = self.uiObjs.Img_Bg:FindDirect("Gruop_Btn")
  local Btn_Wash = Gruop_Btn:FindDirect("Btn_Wash")
  local Btn_Replace = Gruop_Btn:FindDirect("Btn_Replace")
  local Group_Yuanbao = Btn_Wash:FindDirect("Group_Yuanbao")
  local Label_Wash = Btn_Wash:FindDirect("Label_Wash")
  local Label_Money = Group_Yuanbao:FindDirect("Label_Money")
  GUIUtils.SetActive(Btn_Replace, self.hasReplaceSkill)
  if not self.useYuanbao or self.hasEnoughMaterial then
    GUIUtils.SetActive(Label_Wash, true)
    GUIUtils.SetActive(Group_Yuanbao, false)
  else
    require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(self.calItemId, function(result)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      self.needYuanbao = result * (self.needItemNum - self.hasItemNum)
      GUIUtils.SetActive(Label_Wash, false)
      GUIUtils.SetActive(Group_Yuanbao, true)
      GUIUtils.SetText(Label_Money, self.needYuanbao)
    end)
  end
  local Img_Item = self.uiObjs.Img_Bg:FindDirect("Img_Item")
  local Btn_UseGold = Img_Item:FindDirect("Btn_UseGold")
  Btn_UseGold:GetComponent("UIToggle").value = self.useYuanbao
end
def.method().ResetSkill = function(self)
  if self.selectedSkillId == 0 then
    Toast(textRes.Mounts[40])
    return
  end
  if self.hasEnoughMaterial or self.useYuanbao then
    local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanBaoNum, self.needYuanbao) then
      _G.GotoBuyYuanbao()
      return
    end
    MountsMgr.Instance():MountsRefreshPassiveSkill(self.mountsId, self.selectedSkillId, self.useYuanbao, self.needYuanbao)
  else
    self:ConfirmUseYuanbao()
  end
end
def.method().ReplaceSkill = function(self)
  if self.selectedSkillId == 0 then
    Toast(textRes.Mounts[40])
    return
  end
  if self.hasReplaceSkill then
    MountsMgr.Instance():MountsReplacePassiveSkill(self.mountsId, self.selectedSkillId)
  end
end
def.method().DisplayReplaceSkillEffect = function(self)
  local UITexiao = self.m_panel:FindDirect("UITexiao")
  GUIUtils.SetActive(UITexiao, false)
  GUIUtils.SetActive(UITexiao, true)
end
def.method().ClickUseYuanbao = function(self)
  local Img_Item = self.uiObjs.Img_Bg:FindDirect("Img_Item")
  local Btn_UseGold = Img_Item:FindDirect("Btn_UseGold")
  if not Btn_UseGold:GetComponent("UIToggle").value then
    self.useYuanbao = false
    self:SetButtonStatus()
    return
  end
  self:ConfirmUseYuanbao()
end
def.method().ConfirmUseYuanbao = function(self)
  if self.hasEnoughMaterial then
    self.useYuanbao = false
    self:SetButtonStatus()
    Toast(textRes.Mounts[42])
    return
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Mounts[39], function(result)
    self.useYuanbao = result == 1
    self:SetButtonStatus()
  end, nil)
end
def.method("userdata").ShowMaterialTips = function(self, source)
  if self.needItemType ~= -1 then
    local needItemList = ItemUtils.GetItemTypeRefIdList(self.needItemType)
    if needItemList ~= nil then
      local needItemId = needItemList[1]
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(needItemId, source.parent, 0, true)
    end
  end
end
def.method().ShowSkillLib = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts ~= nil then
    require("Main.Mounts.ui.MountsTujianPanel").Instance():ShowPanelWithsMountsIdAndRank(mounts.mounts_cfg_id, mounts.mounts_rank, self.selectecSkillRank)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  GUIUtils.SetActive(self.uiObjs.Group_SmallSelected, false)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_SkillKuang" then
    self:ShowAvailableSkills()
  elseif id == "Btn_Item" then
    local skillTag = clickObj:GetComponent("UILabel")
    if skillTag ~= nil then
      local skillId = tonumber(skillTag.text)
      if skillId ~= nil then
        self:SelectMountsSkill(skillId)
      end
    end
  elseif id == "Btn_Wash" then
    self:ResetSkill()
  elseif id == "Btn_Replace" then
    self:ReplaceSkill()
  elseif id == "Btn_UseGold" then
    self:ClickUseYuanbao()
  elseif id == "Texture_Item" then
    self:ShowMaterialTips(clickObj)
  elseif id == "Btn_SkillLib" then
    self:ShowSkillLib()
  end
end
def.static("table", "table").OnMountsResetSkillSuccess = function(params, context)
  local self = instance
  if self ~= nil then
    self:FillReplaceSkillInfo()
    self:FillCostInfo()
    self:SetButtonStatus()
  end
end
def.static("table", "table").OnMountsReplaceSkillSuccess = function(params, context)
  local self = instance
  if self ~= nil and params[1] ~= nil then
    self:DisplayReplaceSkillEffect()
    self:SelectMountsSkill(params[1])
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = instance
  if self ~= nil then
    self:FillCostInfo()
    self:SetButtonStatus()
  end
end
def.static("table", "table").OnMountsFunctionOpenChange = function(params, context)
  local self = instance
  if self ~= nil then
    local MountsModule = require("Main.Mounts.MountsModule")
    if not MountsModule.IsFunctionOpen() then
      self:DestroyPanel()
    end
  end
end
MountsSkillResetPanel.Commit()
return MountsSkillResetPanel
