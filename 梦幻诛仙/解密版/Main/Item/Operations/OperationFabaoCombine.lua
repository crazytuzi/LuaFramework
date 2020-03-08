local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local OperationFabaoCombine = Lplus.Extend(OperationBase, "OperationFabaoCombine")
local def = OperationFabaoCombine.define
def.field("number").m_CurFabaoFragmentId = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.FabaoBag and itemBase.itemType == ItemType.FABAO_FRAG_ITEM then
    self.m_CurFabaoFragmentId = item.id
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8119]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if nil == itemInfo then
    return false
  end
  if self.m_CurFabaoFragmentId ~= itemInfo.id then
    return false
  end
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local roleLv = HeroProp.level
  local minLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL")
  if roleLv < minLevel then
    Toast(textRes.Fabao[35]:format(minLevel))
    return false
  end
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local composeFabaoId = FabaoUtils.GetFabaoFragmentComposeFabaoId(self.m_CurFabaoFragmentId)
  if 0 ~= composeFabaoId then
    local fabaoBase = ItemUtils.GetFabaoItem(composeFabaoId)
    local fabaoItemBase = ItemUtils.GetItemBase(composeFabaoId)
    if nil == fabaoBase or nil == fabaoItemBase then
      return false
    end
    local fragmentId = fabaoBase.fragmentId
    if fragmentId ~= self.m_CurFabaoFragmentId then
      warn("fragment id is not match ~~~~~~~~ ")
      return false
    end
    local desc = string.format(textRes.Fabao[76], fabaoItemBase.name)
    local title = textRes.Fabao[75]
    local function callback(yuanbao, tag)
      local p = require("netio.protocol.mzm.gsp.fabao.CFabaoComposeReq").new(composeFabaoId, yuanbao)
      gmodule.network.sendProtocol(p)
    end
    local FabaoComposeTipPanel = require("Main.Fabao.ui.FabaoComposeTipPanel")
    FabaoComposeTipPanel.Instance():ShowFabaoComposeTipPanel(title, desc, composeFabaoId, self.m_CurFabaoFragmentId, fabaoBase.fragmentCount, callback, nil)
  else
    warn("the faobao fragment is not have can composed fabao ~~~~~ ")
    return false
  end
  return true
end
OperationFabaoCombine.Commit()
return OperationFabaoCombine
