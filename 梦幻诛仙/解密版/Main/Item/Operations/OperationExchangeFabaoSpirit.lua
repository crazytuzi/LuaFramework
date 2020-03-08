local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationExchangeFabaoSpirit = Lplus.Extend(OperationBase, "OperationExchangeFabaoSpirit")
local def = OperationExchangeFabaoSpirit.define
local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local TEX = textRes.FabaoSpirit
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if FabaoSpiritModule.IsFeatureOpen and source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FABAO_ARTIFACT_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not FabaoSpiritModule.CheckFeatureOpen() then
    Toast(textRes.FabaoSpirit[28])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local ownedLQInfo = FabaoSpiritModule.GetOwndLQInfoByItemId(item.id)
  if ownedLQInfo ~= nil then
    if ownedLQInfo.LQInfo.expire_time == 0 then
      local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(ownedLQInfo.LQInfo.class_id)
      if LQClsCfg == nil then
        return true
      end
      CommonConfirmDlg.ShowConfirm(TEX[22], TEX[23], function(select)
        if select == 1 then
          local FabaoSpiritNode = require("Main.FabaoSpirit.ui.FabaoSpiritNode")
          FabaoSpiritNode.SetSelectClsId(ownedLQInfo.LQInfo.class_id)
          local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
          FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoSpirit)
        end
      end, nil)
    else
      local duration = FabaoSpiritInterface.FormatLeftTime(ownedLQInfo.itemCfg.durationHour * 3600)
      local timeLeft = FabaoSpiritInterface.FormatLeftTime(ownedLQInfo.LQInfo.expire_time - _G.GetServerTime())
      local extendTime = {
        day = duration.day + timeLeft.day,
        hour = duration.hour + timeLeft.hour,
        min = duration.min + timeLeft.min,
        sec = duration.sec + timeLeft.sec
      }
      local strCurLeft = FabaoSpiritInterface.TimeToString(timeLeft)
      local strExtendedTime = FabaoSpiritInterface.TimeToString(extendTime)
      CommonConfirmDlg.ShowConfirm(TEX[22], TEX[24]:format(strCurLeft, strExtendedTime), function(select)
        if select == 1 then
          require("Main.FabaoSpirit.FabaoSpiritProtocols").SendUseItemReq(itemKey, 1)
        end
      end, nil)
    end
  else
    require("Main.FabaoSpirit.FabaoSpiritProtocols").SendUseItemReq(itemKey, 1)
  end
  return true
end
return OperationExchangeFabaoSpirit.Commit()
