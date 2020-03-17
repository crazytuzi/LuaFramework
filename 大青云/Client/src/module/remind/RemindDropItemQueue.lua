--[[
掉宝提醒
郝户
2015年3月21日17:21:37
]]

_G.RemindDropItemQueue = RemindQueue:new();

function RemindDropItemQueue:GetType()
	return RemindConsts.Type_DropItem;
end

function RemindDropItemQueue:GetLibraryLink()
	return "RemindDropItem";
end

function RemindDropItemQueue:GetPos()
	return 2;
end

function RemindDropItemQueue:GetShowIndex()
	return 5;
end

--数字
function RemindDropItemQueue:GetShowNum()
	return false;
end

function RemindDropItemQueue:GetBtnWidth()
	return 60;
end

function RemindDropItemQueue:AddData(data)
	table.push(self.datalist, data);
end

function RemindDropItemQueue:DoClick()
	self:ClearData();
	self:RefreshData();
	UIDropValueDetail:Show();
end