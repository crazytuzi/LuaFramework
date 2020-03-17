--[[
打宝活力值Model
2015年1月22日17:13:33
haohu
]]

_G.DropValueModel = Module:new();

--打宝活力值等级  0为关闭
DropValueModel.level = 0;

function DropValueModel:SetDropValueLevel(level)
	self.level = level;
	self:sendNotification( NotifyConsts.SetDropValueLevel );
end

function DropValueModel:GetDropValueLevel()
	return self.level;
end

DropValueModel.dropItems = {};

function DropValueModel:AddDropItems( items )
	for _, item in pairs(items) do
		table.push( self.dropItems, item );
	end
	self:sendNotification( NotifyConsts.DropItemRecord );
end

function DropValueModel:SetDropItems( items )
	self.dropItems = items;
	self:sendNotification( NotifyConsts.DropItemRecord );
end

function DropValueModel:GetDropItems()
	return self.dropItems;
end