local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemData = require("Main.Item.ItemData")
local WingsUtility = require("Main.Wings.WingsUtility")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsSkillPanel = Lplus.Extend(ECPanelBase, "WingsSkillPanel")
local def = WingsSkillPanel.define
def.field("table").uiNodes = nil
def.field("table").skillInfo = nil
def.field("table").phaseCfg = nil
def.field("number").curPhase = 0
def.field("number").selectedSkillId = 0
local instance
def.static("=>", WingsSkillPanel).Instance = function()
  if instance == nil then
    instance = WingsSkillPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_WING_SKILL_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBG = self.m_panel:FindDirect("Img_Bg")
  self.uiNodes.groupSkill = self.uiNodes.imgBG:FindDirect("Group_Skill")
  self.uiNodes.imgMainSkill = self.uiNodes.groupSkill:FindDirect("Img_MainIcon")
  self.uiNodes.imgSubSkill1 = self.uiNodes.groupSkill:FindDirect("Group_ViceSkill/Img_ViceIcon1")
  self.uiNodes.imgSubSkill2 = self.uiNodes.groupSkill:FindDirect("Group_ViceSkill/Img_ViceIcon2")
  self.uiNodes.grpNoSkill = self.uiNodes.groupSkill:FindDirect("Group_NoSkill")
  self.uiNodes.lblNoSkillDesc = self.uiNodes.groupSkill:FindDirect("Label_Tips2")
  self.uiNodes.lblSkillDesc = self.uiNodes.groupSkill:FindDirect("Label_Tips3")
  self.uiNodes.groupBottom = self.uiNodes.imgBG:FindDirect("Group_Bottom")
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RANDOM_SKILL_CHANGED, WingsSkillPanel.OnRandomSkillChanged)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, WingsSkillPanel.OnWingsPhaseUp)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsSkillPanel.OnBagInfoSyncronized)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RANDOM_SKILL_CHANGED, WingsSkillPanel.OnRandomSkillChanged)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, WingsSkillPanel.OnWingsPhaseUp)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsSkillPanel.OnBagInfoSyncronized)
  self:ClearUp()
end
def.method().ClearUp = function(self)
  self.selectedSkillId = 0
  self.curPhase = 0
  self.skillInfo = nil
  self.phaseCfg = nil
end
def.method().UpdateUI = function(self)
  self:UpdateSkillInfo()
  self:UpdateConsumeItemInfo()
end
def.method().SetNoSkillSelectedEffect = function(self)
  self.uiNodes.imgMainSkill:FindDirect("Img_Select"):SetActive(false)
  self.uiNodes.imgSubSkill1:FindDirect("Img_Select"):SetActive(false)
  self.uiNodes.imgSubSkill2:FindDirect("Img_Select"):SetActive(false)
  self.uiNodes.lblNoSkillDesc:SetActive(true)
  self.uiNodes.lblSkillDesc:SetActive(false)
end
def.method().UpdateSkillInfo = function(self)
  self:SetNoSkillSelectedEffect()
  self.skillInfo = WingsDataMgr.Instance():GetRandomSkillInfo()
  if not self.skillInfo then
    return
  end
  if self.skillInfo.mainSkillId ~= 0 and self.skillInfo.mainSkillCfg then
    self.uiNodes.imgMainSkill:SetActive(true)
    self.uiNodes.grpNoSkill:FindDirect("Label_NoMain"):SetActive(false)
    local uiTexture = self.uiNodes.imgMainSkill:FindDirect("Texture"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, self.skillInfo.mainSkillCfg.iconId)
    local uiLabel = self.uiNodes.imgMainSkill:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(self.skillInfo.mainSkillCfg.name)
  else
    self.uiNodes.imgMainSkill:SetActive(false)
    self.uiNodes.grpNoSkill:FindDirect("Label_NoMain"):SetActive(true)
  end
  if self.skillInfo.subSkills[1] then
    self.uiNodes.imgSubSkill1:SetActive(true)
    self.uiNodes.grpNoSkill:FindDirect("Label_NoSub1"):SetActive(false)
    local cfg = self.skillInfo.subSkills[1].Cfg
    if not cfg then
      return
    end
    local uiTexture = self.uiNodes.imgSubSkill1:FindDirect("Texture"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, cfg.iconId)
    local uiLabel = self.uiNodes.imgSubSkill1:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(cfg.name)
  else
    self.uiNodes.imgSubSkill1:SetActive(false)
    self.uiNodes.grpNoSkill:FindDirect("Label_NoSub1"):SetActive(true)
  end
  if self.skillInfo.subSkills[2] then
    self.uiNodes.imgSubSkill2:SetActive(true)
    self.uiNodes.grpNoSkill:FindDirect("Label_NoSub2"):SetActive(false)
    local cfg = self.skillInfo.subSkills[2].Cfg
    if not cfg then
      return
    end
    local uiTexture = self.uiNodes.imgSubSkill2:FindDirect("Texture"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, cfg.iconId)
    local uiLabel = self.uiNodes.imgSubSkill2:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(cfg.name)
  else
    self.uiNodes.imgSubSkill2:SetActive(false)
    self.uiNodes.grpNoSkill:FindDirect("Label_NoSub2"):SetActive(true)
  end
end
def.method().UpdateConsumeItemInfo = function(self)
  self.curPhase = WingsDataMgr.Instance():GetCurrentWingsPhase()
  self.phaseCfg = WingsUtility.GetPhaseCfg(self.curPhase)
  if not self.phaseCfg then
    return
  end
  local resetItemId = self.phaseCfg.skillResetItemId
  local resetItemNumNeed = self.phaseCfg.skillResetItemNum
  local ItemModule = require("Main.Item.ItemModule")
  local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
  local imgItem = self.uiNodes.groupBottom:FindDirect("Img_Item")
  local uiTexture = imgItem:FindDirect("Texture_Item"):GetComponent("UITexture")
  local uiLabelNum = imgItem:FindDirect("Label_Num"):GetComponent("UILabel")
  local uiLabelName = imgItem:FindDirect("Label_ItemName"):GetComponent("UILabel")
  local ItemUtils = require("Main.Item.ItemUtils")
  local resetItemBase = ItemUtils.GetItemBase(resetItemId)
  if not resetItemBase then
    return
  end
  GUIUtils.FillIcon(uiTexture, resetItemBase.icon)
  if resetItemNumNeed > resetItemNumInBag then
    uiLabelNum:set_color(Color.red)
  else
    uiLabelNum:set_color(Color.white)
  end
  uiLabelNum:set_text(string.format("%d/%d", resetItemNumInBag, resetItemNumNeed))
  uiLabelName:set_text(resetItemBase.name)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Img_MainIcon" then
    self:SetSkillDetail(true, id)
  elseif string.find(id, "Img_Vice") == 1 then
    self:SetSkillDetail(false, id)
  elseif id == "Btn_Confirm" then
    self:OnBtnUnderStandSkill()
  elseif id == "Btn_ReSet" then
    self:OnBtnRandomSkillClicked()
  elseif id == "Btn_Tips" then
    self:OnBtnTipsClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif id == "Texture_Item" then
    self:OnResetItemClicked()
  end
end
def.method().OnBtnTipsClicked = function(self)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(WingsDataMgr.WING_UNDERSTAND_TIP_ID)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.method().OnResetItemClicked = function(self)
  if not self.phaseCfg then
    return
  end
  local itemId = self.phaseCfg.skillResetItemId
  local sourceObj = self.uiNodes.groupBottom:FindDirect("Img_Item")
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:GetComponent("UISprite")
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method().OnBtnUnderStandSkill = function(self)
  if self.selectedSkillId == 0 then
    Toast(textRes.Wings[21])
    return
  end
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  local p = require("netio.protocol.mzm.gsp.wing.CUnderstandSkill").new(idx, self.selectedSkillId)
  gmodule.network.sendProtocol(p)
end
def.method().OnBtnRandomSkillClicked = function(self)
  if not self.phaseCfg then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local function toResetRandomSkill(extraParams)
    if self.m_panel and not self.m_panel.isnil then
      local isNeedYuanBao = false
      local yuanbaoNum = 0
      if extraParams and extraParams.isNeedYuanBao then
        isNeedYuanBao = extraParams.isNeedYuanBao
      end
      if extraParams and isNeedYuanBao and extraParams.yuanbao then
        yuanbaoNum = extraParams.yuanbao
      end
      local allYuanBao = ItemModule.Instance():GetAllYuanBao()
      if isNeedYuanBao and allYuanBao:lt(yuanbaoNum) then
        Toast(textRes.Common[15])
        return
      end
      local isUseYuanBao = 0
      if isNeedYuanBao then
        isUseYuanBao = 1
      end
      local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
      local p = require("netio.protocol.mzm.gsp.wing.CRandomSkill").new(idx, isUseYuanBao, allYuanBao, yuanbaoNum)
      gmodule.network.sendProtocol(p)
    end
  end
  local function callback(select)
    if select > 0 then
      toResetRandomSkill({isNeedYuanBao = true, yuanbao = select})
    else
      toResetRandomSkill({isNeedYuanBao = false, yuanbao = 0})
    end
  end
  local resetItemId = self.phaseCfg.skillResetItemId
  local resetItemNumNeed = self.phaseCfg.skillResetItemNum
  local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
  if resetItemNumNeed > resetItemNumInBag then
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume("", textRes.Wings[45], resetItemId, resetItemNumNeed, callback)
  else
    toResetRandomSkill({isNeedYuanBao = false, yuanbao = 0})
  end
end
def.method("boolean", "string").SetSkillDetail = function(self, isMain, id)
  self:SetNoSkillSelectedEffect()
  local cfg
  if isMain then
    cfg = self.skillInfo.mainSkillCfg
    self.selectedSkillId = self.skillInfo.mainSkillId
    self.uiNodes.imgMainSkill:FindDirect("Img_Select"):SetActive(true)
  else
    local subSkill
    if id == "Img_ViceIcon1" then
      subSkill = self.skillInfo.subSkills[1]
      self.uiNodes.imgSubSkill1:FindDirect("Img_Select"):SetActive(true)
    elseif id == "Img_ViceIcon2" then
      subSkill = self.skillInfo.subSkills[2]
      self.uiNodes.imgSubSkill2:FindDirect("Img_Select"):SetActive(true)
    end
    if not subSkill then
      return
    end
    cfg = subSkill.Cfg
    self.selectedSkillId = subSkill.Id
  end
  if not cfg then
    return
  end
  self.uiNodes.lblNoSkillDesc:SetActive(false)
  self.uiNodes.lblSkillDesc:SetActive(true)
  local uiLabelDesc = self.uiNodes.lblSkillDesc:GetComponent("UILabel")
  uiLabelDesc:set_text(cfg.description)
end
def.static("table", "table").OnRandomSkillChanged = function(params, context)
  instance:UpdateSkillInfo()
  instance.selectedSkillId = 0
end
def.static("table", "table").OnWingsPhaseUp = function(params, context)
  Toast(string.format(textRes.Wings[23], params.newphase))
  instance:DestroyPanel()
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  instance:UpdateConsumeItemInfo()
end
return WingsSkillPanel.Commit()
