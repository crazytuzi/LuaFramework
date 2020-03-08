local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local FabaoComposeTipPanel = require("Main.Fabao.ui.FabaoComposeTipPanel")
local OperationFabaoCompose = Lplus.Extend(OperationBase, "OperationFabaoCompose")
local def = OperationFabaoCompose.define
def.field("number").m_FabaoId = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if itemBase.itemType == ItemType.FABAO_ITEM then
    local fabaoBase = ItemUtils.GetFabaoItem(itemBase.itemid)
    if nil == fabaoBase then
      return false
    end
    if fabaoBase.canCompose then
      self.m_FabaoId = fabaoBase.id
      return true
    else
      return false
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8115]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if 0 == self.m_FabaoId then
    return false
  end
  local HeroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local FabaoOpenLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL")
  if HeroLevel < FabaoOpenLevel then
    Toast(textRes.Fabao[35]:format(FabaoOpenLevel))
    return false
  end
  local fabaoBase = ItemUtils.GetFabaoItem(self.m_FabaoId)
  local itemBase = ItemUtils.GetItemBase(self.m_FabaoId)
  if nil == fabaoBase or nil == itemBase then
    return false
  end
  local fabaoFragmentId = fabaoBase.fragmentId
  local needFragmentCount = fabaoBase.fragmentCount
  local desc = string.format(textRes.Fabao[76], itemBase.name)
  local title = textRes.Fabao[75]
  local function callback(yuanbao, tag)
    local p = require("netio.protocol.mzm.gsp.fabao.CFabaoComposeReq").new(self.m_FabaoId, yuanbao)
    gmodule.network.sendProtocol(p)
  end
  FabaoComposeTipPanel.Instance():ShowFabaoComposeTipPanel(title, desc, self.m_FabaoId, fabaoFragmentId, needFragmentCount, callback, nil)
  return true
end
OperationFabaoCompose.Commit()
return OperationFabaoCompose
