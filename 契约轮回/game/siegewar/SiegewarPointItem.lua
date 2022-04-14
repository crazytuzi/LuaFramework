SiegewarPointItem = SiegewarPointItem or class("SiegewarPointItem",BaseCloneItem)
local SiegewarPointItem = SiegewarPointItem

function SiegewarPointItem:ctor(obj,parent_node,layer)
	SiegewarPointItem.super.Load(self)
end

function SiegewarPointItem:dctor()
end

function SiegewarPointItem:LoadCallBack()
	self.nodes = {
		"point",
	}
	self:GetChildren(self.nodes)
	self.point = GetText(self.point)
	self:AddEvent()
end

function SiegewarPointItem:AddEvent()
end

--data:p_siegewar_score
function SiegewarPointItem:SetData(data)
	if self.is_loaded then
		if data.type == 3 then
			self.point.text = string.format("S%s: %s", RoleInfoModel:GetInstance():GetServerName(data.id), data.score)
		else
			self.point.text = string.format("%s：%s", data.name, data.score)
		end
	end
end