local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationAccess = Lplus.Extend(OperationBase, "OperationAccess")
local def = OperationAccess.define
def.field("number").itemId = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Access then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8116]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local arrows = m_panel:FindDirect("Group_Btn")
  arrows:SetActive(false)
  local source = m_panel:FindDirect("Table_Tips")
  local pos = source:get_localPosition()
  source:set_localPosition(Vector.Vector3.new(-160, pos.y, 0))
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
  ItemAccessMgr.Instance():ShowSource(self.itemId, screenPos.x, screenPos.y - sprite:get_height() * 0.5, sprite:get_width(), sprite:get_height(), 0)
  return false
end
OperationAccess.Commit()
return OperationAccess
