local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgUseItem = Lplus.Extend(ECPanelBase, "DlgUseItem")
local def = DlgUseItem.define
local dlg
local fightMgr = Lplus.ForwardDeclare("FightMgr")
local FightUnit = Lplus.ForwardDeclare("FightUnit")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local EC = require("Types.Vector")
def.field("number").selectedItemIdx = 0
def.static("=>", DlgUseItem).Instance = function()
  if dlg == nil then
    dlg = DlgUseItem()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgUseItem.OnCloseSecondLevelUI)
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_USE_ITEM_IN_FIGHT, 1)
end
def.override().OnDestroy = function(self)
  self.selectedItemIdx = 0
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgUseItem.OnCloseSecondLevelUI)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Item_") then
    self.selectedItemIdx = tonumber(string.sub(id, string.len("Item_") + 1))
    self:ShowItemTip(id)
  elseif id == "Btn_Confirm" then
    if fightMgr.Instance().useItemTimes <= 0 then
      Toast(textRes.Fight[23])
      return
    end
    if fightMgr.Instance().itemList == nil then
      self:Hide()
      return
    end
    if self.selectedItemIdx <= 0 or self.selectedItemIdx > #fightMgr.Instance().itemList then
      Toast(textRes.Fight[24])
      return
    end
    local itemInfo = fightMgr.Instance().itemList[self.selectedItemIdx]
    local itemId
    if itemInfo then
      itemId = itemInfo.id
    end
    if itemId == nil then
      Toast(textRes.Fight[25])
      return
    end
    local mylevel = require("Main.Hero.Interface").GetHeroProp().level
    if mylevel < itemInfo.useLevel then
      Toast(textRes.Fight[48])
      return
    end
    fightMgr.Instance():SetAction(require("consts.mzm.gsp.fight.confbean.OperateType").OP_ITEM, self.selectedItemIdx)
    require("Main.Fight.ui.DlgFight").Instance():ShowSelectSkill(itemInfo)
    self:Hide()
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.method("string").onLongPress = function(self, objName)
  if string.find(objName, "Item_") then
    self:ShowItemTip(objName)
  end
end
def.method("string").ShowItemTip = function(self, objName)
  local index = tonumber(string.sub(objName, string.len("Item_") + 1))
  local item = fightMgr.Instance().itemList and fightMgr.Instance().itemList[index]
  if item == nil then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local source = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowTips(item.info, 0, 0, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowItemList()
end
def.method().ShowItemList = function(self)
  local gridPanel = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Scroll View_Use/Grid_Use")
  if fightMgr.Instance().itemList == nil then
    fightMgr.Instance().itemList = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetInFightItem()
  end
  if fightMgr.Instance().itemList == nil then
    warn("[Fight](GetInFightItem) itemlist is nil")
    return
  end
  local count = #fightMgr.Instance().itemList
  local template = gridPanel:FindDirect("Item_001")
  template:SetActive(count > 0)
  local GUIUtils = require("GUI.GUIUtils")
  local i = 1
  for i = 1, count do
    local name = string.format("Item_%03d", i)
    local item = gridPanel:FindDirect(name)
    if item == nil then
      item = Object.Instantiate(template)
      item:set_name(name)
      item.parent = gridPanel
      item.localScale = EC.Vector3.one
    end
    if item then
      item:FindDirect("Label_Num"):GetComponent("UILabel").text = fightMgr.Instance().itemList[i].count
      local imgicon = item:FindDirect("Img_Icon")
      local uiTexture = imgicon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, fightMgr.Instance().itemList[i].icon)
    end
  end
  local uiGrid = gridPanel:GetComponent("UIGrid")
  uiGrid:Reposition()
  self.m_panel:FindDirect("Img_Bg0/Label_TipsNum"):GetComponent("UILabel").text = tostring(fightMgr.Instance().useItemTimes)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
DlgUseItem.Commit()
return DlgUseItem
