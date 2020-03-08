local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemData = require("Main.Item.ItemData")
local WingsUtility = require("Main.Wings.WingsUtility")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsSkillResetPanel = Lplus.Extend(ECPanelBase, "WingsSkillResetPanel")
local def = WingsSkillResetPanel.define
def.field("number").curPhase = 0
def.field("table").skillTable = nil
def.field("table").phaseCfg = nil
def.field("table").uiTbl = nil
def.field("number").mainSkillNum = 0
def.field("number").subSkillNum = 0
def.field("number").toggleGroup = 0
def.field("table").resetSkillCfg = nil
local instance
def.static("=>", WingsSkillResetPanel).Instance = function()
  if instance == nil then
    instance = WingsSkillResetPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_WING_SKILL_RESET_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_SKILL_CHANGED, WingsSkillResetPanel.OnResetSkillChanged)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SKILL_REPLACED, WingsSkillResetPanel.OnSkillReplaced)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsSkillResetPanel.OnBagInfoSyncronized)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_SKILL_CHANGED, WingsSkillResetPanel.OnResetSkillChanged)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SKILL_REPLACED, WingsSkillResetPanel.OnSkillReplaced)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsSkillResetPanel.OnBagInfoSyncronized)
  self:ClearUp()
end
def.method().ClearUp = function(self)
  WingsDataMgr.Instance():ClearResetSkillInfo()
  self.curPhase = 0
  self.skillTable = nil
  self.phaseCfg = nil
end
def.method().InitUI = function(self)
  self.uiTbl = {}
  local Group_Left = self.m_panel:FindDirect("Img_Bg/Group_Left")
  local Group_Right = self.m_panel:FindDirect("Img_Bg/Group_Right")
  self.uiTbl.Grid_Fu = Group_Left:FindDirect("Scroll View/Grid_Fu")
  self.uiTbl.Grid_Zhu = Group_Left:FindDirect("Scroll View/Grid_Zhu")
  self.mainSkillNum = WingsDataMgr.WING_MAIN_SKILL_NUM
  self.subSkillNum = WingsDataMgr.WING_MAIN_SKILL_NUM * WingsDataMgr.WING_SUB_SKILL_NUM
  self.uiTbl.MainSkill = {}
  for i = 1, self.mainSkillNum do
    table.insert(self.uiTbl.MainSkill, self.uiTbl.Grid_Zhu:FindDirect("Zhu_" .. i))
  end
  self.uiTbl.SubSkill = {}
  for i = 1, self.subSkillNum do
    table.insert(self.uiTbl.SubSkill, self.uiTbl.Grid_Fu:FindDirect("Fu_" .. i))
  end
  self.toggleGroup = self.uiTbl.MainSkill[1]:FindDirect("Img_Toggle"):GetComponent("UIToggle"):get_group()
  self.uiTbl.Btn_Tujian = Group_Right:FindDirect("Btn_Tujian")
  self.uiTbl.Btn_Reset = Group_Right:FindDirect("Btn_Reset")
  self.uiTbl.Btn_Replace = Group_Right:FindDirect("Btn_Replace")
  self.uiTbl.Label_Tips = Group_Right:FindDirect("Label_TIps")
  self.uiTbl.Img_Item = Group_Right:FindDirect("Img_Item")
  self.uiTbl.Group_Reset = Group_Right:FindDirect("Group_SkillResult")
  self.uiTbl.ResetMain = Group_Right:FindDirect("Group_SkillResult/Reset_Zhu")
  self.uiTbl.ResetSub = Group_Right:FindDirect("Group_SkillResult/Reset_Fu")
end
def.method().UpdateUI = function(self)
  self:UpdateSkillUI()
  self:UpdateResetSkill()
  self:UpdateConsumeItems()
end
def.method().UpdateSkillUI = function(self)
  self.skillTable = WingsDataMgr.Instance():GetCurrentSkillTable()
  if not self.skillTable then
    return
  end
  self:UpdateMainSkillUI()
  self:UpdateSubSkillUI()
end
def.method().UpdateMainSkillUI = function(self)
  local mainSkillTable = self.skillTable.mainSkills
  for i = 1, self.mainSkillNum do
    local cell = self.uiTbl.MainSkill[i]
    self:FillSkillCell(cell, mainSkillTable[i], true)
  end
end
def.method().UpdateSubSkillUI = function(self)
  local subSkillTable = self.skillTable.subSkills
  for i = 1, self.subSkillNum do
    local cell = self.uiTbl.SubSkill[i]
    self:FillSkillCell(cell, subSkillTable[i], false)
  end
end
def.method("userdata", "table", "boolean").FillSkillCell = function(self, cell, skillInfo, isMain)
  if not cell or not skillInfo then
    return
  end
  local toggle = cell:FindDirect("Img_Toggle")
  local texture = cell:FindDirect("Texture")
  local sprite = cell:FindDirect("Sprite")
  local label = cell:FindDirect("Label")
  if isMain then
    if skillInfo.id ~= 0 then
      texture:SetActive(true)
      GUIUtils.FillIcon(texture:GetComponent("UITexture"), skillInfo.cfg.iconId)
    else
      texture:SetActive(false)
      toggle:SetActive(false)
    end
  elseif skillInfo.id ~= 0 then
    texture:SetActive(true)
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), skillInfo.cfg.iconId)
  else
    texture:SetActive(false)
    cell:FindDirect("Container"):SetActive(false)
    toggle:SetActive(false)
  end
  sprite:SetActive(false)
  label:SetActive(false)
end
def.method().UpdateConsumeItems = function(self)
  self.curPhase = WingsDataMgr.Instance():GetCurrentWingsPhase()
  self.phaseCfg = WingsUtility.GetPhaseCfg(self.curPhase)
  if not self.phaseCfg then
    return
  end
  local resetItemId = self.phaseCfg.skillResetItemId
  local resetItemNumNeed = self.phaseCfg.skillResetItemNum
  local ItemModule = require("Main.Item.ItemModule")
  local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
  local uiTexture = self.uiTbl.Img_Item:FindDirect("Texture_Item"):GetComponent("UITexture")
  local uiLabelNum = self.uiTbl.Img_Item:FindDirect("Label_Num"):GetComponent("UILabel")
  local uiLabelName = self.uiTbl.Img_Item:FindDirect("Label_ItemName"):GetComponent("UILabel")
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
def.method().UpdateResetSkill = function(self)
  local resetSkillType = WingsDataMgr.Instance():GetResetSkillType()
  if resetSkillType == -1 then
    self.uiTbl.Label_Tips:SetActive(true)
    self.uiTbl.Group_Reset:SetActive(false)
    return
  else
    self.uiTbl.Label_Tips:SetActive(false)
    self.uiTbl.Group_Reset:SetActive(true)
  end
  local skillCfgs = WingsDataMgr.Instance():GetResetSkillCfg()
  self.resetSkillCfg = WingsDataMgr.Instance():GetResetSkillCfg()
  local textureMain = self.uiTbl.ResetMain:FindDirect("Texture")
  local mainCfg = skillCfgs.MainSkillCfg
  if mainCfg.id ~= 0 then
    textureMain:SetActive(true)
    GUIUtils.FillIcon(textureMain:GetComponent("UITexture"), mainCfg.cfg.iconId)
  else
    textureMain:SetActive(false)
  end
  for i = 1, WingsDataMgr.WING_SUB_SKILL_NUM do
    local textureSub = self.uiTbl.ResetSub:FindDirect("Reset_Fu_" .. i .. "/Texture")
    local subCfg = skillCfgs.SubSkillCfgs[i]
    if subCfg.id ~= 0 then
      textureSub:SetActive(true)
      GUIUtils.FillIcon(textureSub:GetComponent("UITexture"), subCfg.cfg.iconId)
    else
      textureSub:SetActive(false)
    end
  end
  local mainIndex, subIndex = WingsDataMgr.Instance():GetResetSkillIndex()
  if resetSkillType == 0 then
    local toggle = self.uiTbl.MainSkill[mainIndex]
    if toggle then
      toggle:FindDirect("Img_Toggle"):GetComponent("UIToggle"):set_value(true)
    else
    end
  else
    if resetSkillType == 1 then
      local index = (mainIndex - 1) * WingsDataMgr.WING_SUB_SKILL_NUM + subIndex
      local toggle = self.uiTbl.SubSkill[index]
      if toggle then
        toggle:FindDirect("Img_Toggle"):GetComponent("UIToggle"):set_value(true)
      end
    else
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Tujian" then
    require("Main.Wings.ui.WingsSkillGallery").Instance():ShowPanel()
  elseif id == "Texture_Item" then
    self:ShowItemTip()
  elseif id == "Btn_Reset" then
    self:ResetSkillReq()
  elseif id == "Btn_Replace" then
    self:ReplaceSkillReq()
  elseif string.find(id, "Zhu") or string.find(id, "Fu") then
    self:ShowSkillTip(id)
  elseif id == "Img_Toggle" then
    self:SelectSkill()
  end
end
def.method().ShowItemTip = function(self)
  if not self.phaseCfg then
    return
  end
  local itemId = self.phaseCfg.skillResetItemId
  local sourceObj = self.uiTbl.Img_Item
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:GetComponent("UISprite")
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method().ResetSkillReq = function(self)
  local activeToggle = UIToggle.GetActiveToggle(self.toggleGroup)
  if activeToggle == nil then
    Toast(textRes.Wings[38])
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local function toResetWingSkill(extraParams)
    if self.m_panel and not self.m_panel.isnil then
      local isNeedYuanBao = false
      local yuanbaoNum = 0
      if extraParams and extraParams.isNeedYuanBao then
        isNeedYuanBao = extraParams.isNeedYuanBao
      end
      if extraParams and extraParams.yuanbao and isNeedYuanBao then
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
      local toggleName = activeToggle.gameObject.parent.name
      if string.find(toggleName, "Zhu_") then
        local index = tonumber(string.sub(toggleName, 5))
        self:SendResetMainSkillReq(index, isUseYuanBao, yuanbaoNum, allYuanBao)
      elseif string.find(toggleName, "Fu_") then
        local subIndex = tonumber(string.sub(toggleName, 4))
        local mainIndex = math.floor((subIndex + 2) / 3)
        subIndex = subIndex - (mainIndex - 1) * WingsDataMgr.WING_SUB_SKILL_NUM
        self:SendResetSubSkillReq(mainIndex, subIndex, isUseYuanBao, yuanbaoNum, allYuanBao)
      end
    end
  end
  local function callback(select)
    if select > 0 then
      toResetWingSkill({isNeedYuanBao = true, yuanbao = select})
    else
      toResetWingSkill({isNeedYuanBao = false, yuanbao = 0})
    end
  end
  local resetItemId = self.phaseCfg.skillResetItemId
  local resetItemNumNeed = self.phaseCfg.skillResetItemNum
  local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
  if resetItemNumNeed > resetItemNumInBag then
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume("", textRes.Wings[46], resetItemId, resetItemNumNeed, callback)
  else
    toResetWingSkill({isNeedYuanBao = false, yuanbao = 0})
  end
end
def.method().ReplaceSkillReq = function(self)
  local resetSkillType = WingsDataMgr.Instance():GetResetSkillType()
  if resetSkillType == -1 then
    Toast(textRes.Wings[39])
    return
  end
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  local mainIndex, subIndex = WingsDataMgr.Instance():GetResetSkillIndex()
  if resetSkillType == 0 then
    local p = require("netio.protocol.mzm.gsp.wing.CReplaceMainSkill").new(idx, mainIndex)
    gmodule.network.sendProtocol(p)
    return
  end
  if resetSkillType == 1 then
    local p = require("netio.protocol.mzm.gsp.wing.CReplaceSubSkill").new(idx, mainIndex, subIndex)
    gmodule.network.sendProtocol(p)
    return
  end
end
def.method("string").ShowSkillTip = function(self, id)
  if not self.skillTable then
    return
  end
  local idx, cell, skillCfg
  if string.find(id, "Reset_") then
    if string.find(id, "Zhu") then
      skillCfg = self.resetSkillCfg.MainSkillCfg
      cell = self.uiTbl.ResetMain
    elseif string.find(id, "Fu") then
      idx = tonumber(string.sub(id, #"Reset_Fu_" + 1, -1))
      skillCfg = self.resetSkillCfg.SubSkillCfgs[idx]
      cell = self.uiTbl.ResetSub:FindDirect(id)
    end
  elseif string.find(id, "Zhu") then
    idx = tonumber(string.sub(id, 5))
    cell = self.uiTbl.Grid_Zhu:FindDirect(id)
    skillCfg = self.skillTable.mainSkills[idx]
  elseif string.find(id, "Fu") then
    idx = tonumber(string.sub(id, 4))
    cell = self.uiTbl.Grid_Fu:FindDirect(id)
    skillCfg = self.skillTable.subSkills[idx]
  end
  if not skillCfg or skillCfg.id == 0 or not skillCfg.cfg then
    return
  end
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillCfg.cfg.id, cell, 0)
end
def.method().SelectSkill = function(self)
  local resetSkillType = WingsDataMgr.Instance():GetResetSkillType()
  if resetSkillType == -1 then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", textRes.Wings[40], function(id, tag)
    if id == 1 then
      self:SendRemoveResetSkillReq()
    else
      self:UpdateResetSkill()
    end
  end, nil)
end
def.method("number", "number", "number", "userdata").SendResetMainSkillReq = function(self, index, isUseYuanBao, needYuanBaoNum, allYuanBao)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.CResetMainSkill").new(idx, index, isUseYuanBao, allYuanBao, needYuanBaoNum)
    gmodule.network.sendProtocol(p)
  end
end
def.method("number", "number", "number", "number", "userdata").SendResetSubSkillReq = function(self, mainIndex, subIndex, isUseYuanBao, needYuanBaoNum, allYuanBao)
  print("-----------SendResetSubSkillReq---------->", mainIndex, subIndex)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.CResetSubSkill").new(idx, mainIndex, subIndex, isUseYuanBao, allYuanBao, needYuanBaoNum)
    gmodule.network.sendProtocol(p)
  end
end
def.method().SendRemoveResetSkillReq = function(self)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.CRemoveResetSkill").new(idx)
    gmodule.network.sendProtocol(p)
  end
end
def.static("table", "table").OnResetSkillChanged = function(params, context)
  instance:UpdateResetSkill()
end
def.static("table", "table").OnSkillReplaced = function(params, context)
  instance:UpdateUI()
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  instance:UpdateConsumeItems()
end
return WingsSkillResetPanel.Commit()
