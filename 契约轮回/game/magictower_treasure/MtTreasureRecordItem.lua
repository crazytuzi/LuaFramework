--
-- @Author: LaoY
-- @Date:   2018-12-21 15:16:48
--
MtTreasureRecordItem = MtTreasureRecordItem or class("MtTreasureRecordItem",BaseCloneItem)
local MtTreasureRecordItem = MtTreasureRecordItem

function MtTreasureRecordItem:ctor(obj,parent_node)
	MtTreasureRecordItem.super.Load(self)
end

function MtTreasureRecordItem:dctor()
end

function MtTreasureRecordItem:LoadCallBack()
	-- self.nodes = {
	-- 	"",
	-- }
	-- self:GetChildren(self.nodes)
	self.text_component = self.transform:GetComponent('Text')

	self:AddEvent()
end

function MtTreasureRecordItem:AddEvent()
end

function MtTreasureRecordItem:SetData(index,data)
	local item_cf = Config.db_item[data.item]
	local str = string.format("<color=#30d23b>[%s]</color>Sought treasure in the magic tower and gained <color=#%s>%s*%s</color>",data.name,ColorUtil.GetColor(item_cf.color),item_cf.name,data.num)
	self.text_component.text = str
end

function MtTreasureRecordItem:GetHeight()
	return self.text_component.preferredHeight
end