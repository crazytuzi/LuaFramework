--[[
死亡遗迹召集
lizhuangzhuang
2015年11月24日22:14:14
]]

_G.RemindSWYJQueue = RemindQueue:new();

--是否不再提醒
RemindSWYJQueue.isNoRemind = false;

RemindSWYJQueue.id = 0;

function RemindSWYJQueue:GetType()
	return RemindConsts.Type_SWYJ;
end

function RemindSWYJQueue:GetLibraryLink()
	return "RemindSWYJ";
end

function RemindSWYJQueue:GetPos()
	return 2;
end

function RemindSWYJQueue:GetShowIndex()
	return 30;
end

function RemindSWYJQueue:GetBtnWidth()
	return 70;
end

function RemindSWYJQueue:AddData(id)
	if self.isNoRemind then return; end
	self.id = id;
end

function RemindSWYJQueue:GetIsShow()
	return self.id > 0;
end

function RemindSWYJQueue:DoClick()
	UISWYJRemind:Show(self.id);
	self.id = 0;
	self:RefreshData();
end

function RemindSWYJQueue:DoRollOver()
	TipsManager:ShowBtnTips(StrConfig["activityswyj022"]);
end

function RemindSWYJQueue:DoRollOut()
	TipsManager:Hide();
end