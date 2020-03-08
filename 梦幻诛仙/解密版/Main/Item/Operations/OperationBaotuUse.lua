local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationBaotuUse = Lplus.Extend(OperationBase, "OperationBaotuUse")
local def = OperationBaotuUse.define
def.field("table").quickItem = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.ITEMTYPE_BAOTU then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local TeamData = require("Main.Team.TeamData").Instance()
  if TeamData:HasTeam() and TeamData:GetStatus() ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
    local roleId = require("Main.Hero.HeroModule").Instance().roleId
    local isTeamLeader = TeamData:IsCaptain(roleId)
    if not isTeamLeader then
      Toast(textRes.Item[101])
      return false
    end
  end
  if self.quickItem then
    local WabaoModule = require("Main.Wabao.WabaoModule")
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    local mapId = self.quickItem.extraMap[ItemXStoreType.BAO_TU_MAPID]
    local x = self.quickItem.extraMap[ItemXStoreType.BAO_TU_X]
    local y = self.quickItem.extraMap[ItemXStoreType.BAO_TU_Y]
    local curMapId = require("Main.Map.Interface").GetCurMapId()
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    local pos = heroModule:GetPos()
    if mapId == curMapId and x == pos.x and y == pos.y then
      WabaoModule.Instance():Wabao(self.quickItem.uuid[1])
    else
      heroModule:MoveTo(mapId, x, y, 0, 0, MoveType.AUTO, nil)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = x, y = y})
      WabaoModule.Instance().isFinding = true
      WabaoModule.Instance().tarX = x
      WabaoModule.Instance().tarY = y
      WabaoModule.Instance().itemId = self.quickItem.id
      Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, WabaoModule._onArrive)
    end
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  if myLv < itemBase.useLevel then
    Toast(string.format(textRes.Item[8331], itemBase.useLevel))
    return false
  end
  Event.DispatchEvent(ModuleId.WABAO, gmodule.notifyId.Wabao.BAOTU_USE, {bagId = bagId, itemKey = itemKey})
  local ItemModule = require("Main.Item.ItemModule")
  ItemModule.Instance():CloseInventoryDlg()
  return true
end
OperationBaotuUse.Commit()
return OperationBaotuUse
