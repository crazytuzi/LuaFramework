local gCurTipPanel
local function _ShowItemTip(item, showbtn, obj, istaskitem)
  if not item then
    return
  end
  showbtn = showbtn or false
  istaskitem = istaskitem or false
  local ECPanelItemTipEquipExterior = require("GUI.ECPanelItemTipEquipExterior")
  local ECPanelItemTipEquipUnderwear = require("GUI.ECPanelItemTipEquipUnderwear")
  local ECPanelItemTipEquipRide = require("GUI.ECPanelItemTipEquipRide")
  local ECPanelItemTipEquipWing = require("GUI.ECPanelItemTipEquipWing")
  local ECPanelItemTipCard = require("GUI.ECPanelItemTipCard")
  local ECPanelItemTipOtherItem = require("GUI.ECPanelItemTipOtherItem")
  local ECIvtrItems = require("Inventory.ECIvtrItems")
  local ElementData = require("Data.ElementData")
  local Exptypes = require("Data.Exptypes")
  local EQUIPTYPE_ENUM = require("Data.Expdef").EQUIPTYPE_ENUM
  if item.m_CID == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_EQUIP then
    local ess, dt = ElementData.getEssence(item.tid)
    local tip
    if ess and dt == Exptypes.DATA_TYPE.DT_EQUIPMENT_ESSENCE then
      local equip_type = ess.equip_type
      if equip_type == EQUIPTYPE_ENUM.EQUIPTYPE_WEAPON_AND_ARMOUR then
        tip = ECPanelItemTipEquipExterior.Instance()
      elseif equip_type == EQUIPTYPE_ENUM.EQUIPTYPE_INSIDE then
        tip = ECPanelItemTipEquipUnderwear.Instance()
      elseif equip_type == EQUIPTYPE_ENUM.EQUIPTYPE_HORSE then
        tip = ECPanelItemTipEquipRide.Instance()
      elseif equip_type == EQUIPTYPE_ENUM.EQUIPTYPE_WING then
        tip = ECPanelItemTipEquipWing.Instance()
      end
    end
    tip:PopupTip(item, showbtn, obj, istaskitem)
    gCurTipPanel = tip
  elseif item.m_CID == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_CARD then
    local tip = ECPanelItemTipCard.Instance()
    tip:PopupTip(item.tid, obj)
    gCurTipPanel = tip
  else
    local tip = ECPanelItemTipOtherItem.Instance()
    tip:PopupTip(item, showbtn, obj)
    gCurTipPanel = tip
  end
end
local function _ShowItemTipByTid(tid, showbtn, obj)
  if tid <= 0 then
    return
  end
  local ECItemTools = require("Inventory.ECItemTools")
  local item = ECItemTools.CreateItem(tid)
  _ShowItemTip(item, showbtn, obj)
end
local function _ShowAchievementTip(tid, obj)
  if not tid or tid <= 0 then
    return
  end
  local ECPanelAchievementTip = require("GUI.ECPanelAchievementTip")
  local tip = ECPanelAchievementTip.Instance()
  tip:PopupTip(tid, obj)
  gCurTipPanel = tip
end
local function _ShowGiftBag(tid, obj)
  if not tid or tid <= 0 then
    return
  end
  local ECPanelItemTipReward = require("GUI.ECPanelItemTipReward")
  local tip = ECPanelItemTipReward.Instance()
  tip:PopupTip(tid, obj)
  gCurTipPanel = tip
end
local function _MoneyTip(type, desc, obj)
  local ECPanelMoneyTip = require("GUI.ECPanelMoneyTip")
  local tip = ECPanelMoneyTip.Instance()
  tip:PopupTip(type, desc, obj)
  gCurTipPanel = tip
end
local _GotNewItem = function(item)
  local ECGotNewItemMgr = require("GUI.ECGotNewItemMgr")
  ECGotNewItemMgr.Instance():TryPopup(item)
end
local function _SimpleText(desc, obj)
  local ECPanelSimpleTextTip = require("GUI.ECPanelSimpleTextTip")
  local tip = ECPanelSimpleTextTip.Instance()
  tip:PopupTip(desc, obj)
  gCurTipPanel = tip
end
local function _PopupTipEx(_type)
  if _type == "full_item" then
    return function(item, showbtn, obj, istaskitem)
      if gCurTipPanel and gCurTipPanel:IsPopup(item, obj) then
        gCurTipPanel:DestroyPanel()
        gCurTipPanel = nil
      else
        _ShowItemTip(item, showbtn, obj, istaskitem)
      end
    end
  elseif _type == "simple_item" then
    return function(tid, showbtn, obj)
      if gCurTipPanel and gCurTipPanel:IsPopup(tid, obj) then
        gCurTipPanel:DestroyPanel()
        gCurTipPanel = nil
      else
        _ShowItemTipByTid(tid, showbtn, obj)
      end
    end
  elseif _type == "achievement" then
    return function(tid, obj)
      if gCurTipPanel and gCurTipPanel:IsPopup(tid, obj) then
        gCurTipPanel:DestroyPanel()
        gCurTipPanel = nil
      else
        _ShowAchievementTip(tid, obj)
      end
    end
  elseif _type == "reward" then
    return function(tid, obj)
      if gCurTipPanel and gCurTipPanel:IsPopup(tid, obj) then
        gCurTipPanel:DestroyPanel()
        gCurTipPanel = nil
      else
        _ShowGiftBag(tid, obj)
      end
    end
  elseif _type == "money" then
    return function(type, desc, obj)
      if gCurTipPanel and gCurTipPanel:IsPopup(desc, obj) then
        gCurTipPanel:DestroyPanel()
        gCurTipPanel = nil
      else
        _MoneyTip(type, desc, obj)
      end
    end
  elseif _type == "simple_text" then
    return function(desc, obj)
      if gCurTipPanel and gCurTipPanel:IsPopup(desc, obj) then
        gCurTipPanel:DestroyPanel()
        gCurTipPanel = nil
      else
        _SimpleText(desc, obj)
      end
    end
  end
end
local _TipCanNotUse = function(reason)
  local ErrorUse = require("Common.Use_Error")
  if ErrorUse[reason] then
    FlashTipMan.FlashTip(ErrorUse[reason])
  end
end
_G.ItemTipMan = {
  ShowItemTip = _PopupTipEx("full_item"),
  ShowItemTipByTid = _PopupTipEx("simple_item"),
  ShowAchievementTip = _PopupTipEx("achievement"),
  ShowGiftBag = _PopupTipEx("reward"),
  MoneyTip = _PopupTipEx("money"),
  GotNewItem = _GotNewItem,
  ShowSimpleText = _PopupTipEx("simple_text"),
  TipCanNotUse = _TipCanNotUse
}
return ItemTipMan
