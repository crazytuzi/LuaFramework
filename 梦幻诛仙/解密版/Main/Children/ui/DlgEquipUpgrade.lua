local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgEquipUpgrade = Lplus.Extend(ECPanelBase, "DlgEquipUpgrade")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector3")
local CommonUseItem = require("GUI.CommonUseItem")
local def = DlgEquipUpgrade.define
local instance
def.field("userdata").childId = nil
def.field("table").uiObjs = nil
def.const("table").UPGRADE_TYPE = {UPGRADE = 1, PHASE = 2}
def.field("table").upgrade_type = nil
def.field("number").selectedIdx = 0
def.static("=>", DlgEquipUpgrade).Instance = function()
  if instance == nil then
    instance = DlgEquipUpgrade()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, childId)
  if self.m_panel ~= nil then
    return
  end
  self.childId = childId
  self:CreatePanel(RESPATH.PREFAB_CHILD_EQUIP_UPGRADE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.m_panel.localPosition = Vector.Vector3.zero
  self.uiObjs = {}
  self.uiObjs.group = self.m_panel:FindDirect("Img_Bg0/Group_Equip")
  self.uiObjs.items = {}
  for i = 1, 3 do
    self.uiObjs.items[i] = self.uiObjs.group:FindDirect("Item_Equip0" .. i)
  end
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, DlgEquipUpgrade.OnPropUpdated)
  self:ShowInfo(nil)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, DlgEquipUpgrade.OnPropUpdated)
  self.childId = nil
  self.uiObjs = nil
  self.upgrade_type = nil
  self.selectedIdx = 0
end
def.static("table", "table").OnPropUpdated = function(p1, p2)
  instance:ShowInfo(p1)
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_Upgrade0") then
    local idx = tonumber(string.sub(id, #"Btn_Upgrade0" + 1, -1))
    self:DoUpgrade(idx)
  elseif string.find(id, "Img_BgEquip") then
    local idx = tonumber(string.sub(id, #"Img_BgEquip" + 1, -1))
    self:ShowEquipTip(idx)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("table").ShowInfo = function(self, target)
  local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  local equips = child_data:GetChildEquips()
  local equip_slots = require("Main.Children.ui.YouthSubPanel").EquipPosToType
  self.upgrade_type = {}
  for i = 1, #self.uiObjs.items do
    local item_panel = self.uiObjs.items[i]
    local equip = equips[i]
    item_panel:FindDirect("Img_Select0" .. i):SetActive(i == self.selectedIdx)
    local ui_texture = item_panel:FindDirect(string.format("Img_BgEquip0%d/Img_IconEquip0%d", i, i)):GetComponent("UITexture")
    if equip == nil then
      GUIUtils.FillIcon(ui_texture, 0)
      break
    end
    local phase = equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_STAGE]
    local level = equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
    local itemCfg = ChildrenUtils.GetChildEquipItem(equip.id)
    local itemBase = ItemUtils.GetItemBase(equip.id)
    GUIUtils.FillIcon(ui_texture, itemBase.icon)
    if target and equip.id == target[1] then
      local phase_cfg = ChildrenUtils.GetChildEquipPhaseCfg(1, phase)
      if target[2] == ItemXStoreType.CHILDREN_EQUIP_EXP then
        Toast(string.format(textRes.Children[3077], ItemTipsMgr.Color[phase_cfg.color], itemBase.name, tostring(target.exp_delta)))
      elseif target[2] == ItemXStoreType.CHILDREN_EQUIP_LEVEL then
        local exp_delta = target.exp_delta
        for lv = target.old_level, target.new_level - 1 do
          local delta_level_cfg = ChildrenUtils.GetChildEquipLevelCfg(itemCfg.levelTypeid, lv)
          if delta_level_cfg then
            exp_delta = exp_delta + delta_level_cfg.levelUpExp
          end
        end
        Toast(string.format(textRes.Children[3077], ItemTipsMgr.Color[phase_cfg.color], itemBase.name, tostring(exp_delta)))
        Toast(string.format(textRes.Children[3074], ItemTipsMgr.Color[phase_cfg.color], itemBase.name, tostring(level)))
      elseif target[2] == ItemXStoreType.CHILDREN_EQUIP_STAGE then
        Toast(string.format(textRes.Children[3075], ItemTipsMgr.Color[phase_cfg.color], itemBase.name, tostring(phase)))
      end
    end
    local level_cfg = ChildrenUtils.GetChildEquipLevelCfg(itemCfg.levelTypeid, level)
    if level_cfg == nil then
      return
    end
    item_panel:FindDirect(string.format("Group_EquipLabel0%d/Label_LevelNum0%d", i, i)):GetComponent("UILabel").text = level
    item_panel:FindDirect(string.format("Group_EquipLabel0%d/Label_QualityNum0%d", i, i)):GetComponent("UILabel").text = phase
    local slider = item_panel:FindDirect("Slider_Upgrade0" .. i)
    local exp = equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_EXP]
    local max_exp = level_cfg.levelUpExp
    slider:GetComponent("UISlider").value = exp / max_exp
    slider:FindDirect("Label_Slider0" .. i):GetComponent("UILabel").text = string.format("%d/%d", exp, max_exp)
    local need_phase_up = phase < level_cfg.phase_req
    self.upgrade_type[i] = DlgEquipUpgrade.UPGRADE_TYPE.UPGRADE
    if need_phase_up then
      self.upgrade_type[i] = DlgEquipUpgrade.UPGRADE_TYPE.PHASE
    end
    item_panel:FindDirect(string.format("Btn_Upgrade0%d/Label_Upgrade0%d", i, i)):SetActive(not need_phase_up)
    item_panel:FindDirect(string.format("Btn_Upgrade0%d/Label_Evolve0%d", i, i)):SetActive(need_phase_up)
  end
end
local CHILD_EQUIP_UPGRADE_POS = Vector.Vector3.new(-285, 0, 0)
local CHILD_EQUIP_UPGRADE_USEITEM_POS = Vector.Vector3.new(126, 0, 0)
def.method("number").DoUpgrade = function(self, idx)
  if CheckCrossServerAndToast() then
    return
  end
  self.selectedIdx = idx
  for i = 1, #self.uiObjs.items do
    self.uiObjs.items[i]:FindDirect("Img_Select0" .. i):SetActive(i == idx)
  end
  local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  local equips = child_data:GetChildEquips()
  local equip = equips[idx]
  if self.upgrade_type[idx] == DlgEquipUpgrade.UPGRADE_TYPE.UPGRADE then
    local level = equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
    local itemCfg = ChildrenUtils.GetChildEquipItem(equip.id)
    local level_cfg = ChildrenUtils.GetChildEquipLevelCfg(itemCfg.levelTypeid, level)
    if level_cfg == nil then
      return
    end
    self.m_panel.localPosition = CHILD_EQUIP_UPGRADE_POS
    CommonUseItem.Instance().initPos = CHILD_EQUIP_UPGRADE_USEITEM_POS
    CommonUseItem.ShowCommonUseByItemId(textRes.Children[3030], level_cfg.itemIds, function(itemCfgId, useAll)
      if self.upgrade_type[idx] == DlgEquipUpgrade.UPGRADE_TYPE.PHASE then
        Toast(textRes.Children[3054])
        return
      end
      local pro = require("netio.protocol.mzm.gsp.Children.CChildrenEquipLevelUpReq").new()
      pro.childrenid = self.childId
      pro.pos = require("Main.Children.ui.YouthSubPanel").EquipPosToType[idx]
      pro.item_cfg_id = itemCfgId
      pro.is_use_all = useAll and 1 or 0
      gmodule.network.sendProtocol(pro)
    end, function()
      if self.m_panel then
        self.m_panel.localPosition = Vector.Vector3.zero
        self.selectedIdx = 0
        for i = 1, #self.uiObjs.items do
          self.uiObjs.items[i]:FindDirect("Img_Select0" .. i):SetActive(false)
        end
      end
    end)
  elseif self.upgrade_type[idx] == DlgEquipUpgrade.UPGRADE_TYPE.PHASE then
    local phase = equip.extraMap[ItemXStoreType.CHILDREN_EQUIP_STAGE]
    local phase_cfg = ChildrenUtils.GetChildEquipPhaseCfg(1, phase)
    local max_phase = ChildrenUtils.GetChildEquipMaxPhase()
    if phase >= max_phase then
      Toast(textRes.Children[3039])
      return
    end
    local level_req = phase_cfg.needLevel
    local myLevel = child_data.info.level
    if level_req > myLevel then
      Toast(string.format(textRes.Wing[3040], needRoleLv, phase + 1))
      return
    end
    local needItemId = phase_cfg.mainItemid
    local needItemNum = phase_cfg.needItemNum
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume(textRes.Children[3041], string.format(textRes.Children[3042], phase + 1), needItemId, needItemNum, function(useYuanbao)
      if useYuanbao >= 0 then
        local pro = require("netio.protocol.mzm.gsp.Children.CChildrenEquipStageUpReq").new()
        pro.childrenid = self.childId
        if useYuanbao > 0 then
          pro.useYuanBao = pro.USE
        else
          pro.useYuanBao = pro.UNUSE
        end
        pro.useYuanBaoNum = useYuanbao
        pro.totalYuanBaoNum = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetAllYuanBao()
        pro.pos = require("Main.Children.ui.YouthSubPanel").EquipPosToType[idx]
        gmodule.network.sendProtocol(pro)
        if CommonUseItem.Instance():IsShow() then
          self.upgrade_type[idx] = DlgEquipUpgrade.UPGRADE_TYPE.UPGRADE
          self:DoUpgrade(idx)
        end
      end
    end)
  end
end
def.method("number").ShowEquipTip = function(self, idx)
  local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  local equips = child_data:GetChildEquips()
  local equip = equips and equips[idx]
  if equip == nil then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local sourceObj = self.uiObjs.items[idx]:FindDirect("Img_BgEquip0" .. idx)
  local tip = ItemTipsMgr.Instance():ShowTipsEx(equip, ItemModule.EQUIPBAG, 1, ItemTipsMgr.Source.ChildrenPanel, sourceObj, 1)
end
DlgEquipUpgrade.Commit()
return DlgEquipUpgrade
