--[[
邀请入帮提醒队列
]]

_G.RemindNewMailQueue = RemindQueue:new();

RemindNewMailQueue.mailNum = 0;

function RemindNewMailQueue:GetType()
	return RemindConsts.Type_NewMail;
end

--获取按钮上显示的数字
function RemindNewMailQueue:GetShowNum()
	return self.mailNum;
end

function RemindNewMailQueue:GetLibraryLink()
	return "RemindNewMail";
end

function RemindNewMailQueue:GetPos()
	return 2;
end

function RemindNewMailQueue:GetShowIndex()
	return 1;
end

function RemindNewMailQueue:GetBtnWidth()
	return 60;
end

function RemindNewMailQueue:AddData(data)
	self.mailNum = data.mailcount
	if self.mailNum <= 0 then
		self:HideButton()
		self.datalist = {}
		return
	end
	if #self.datalist <= 0 then 
		table.insert(self.datalist, data);
	else
		self:RefreshData();
	end
end

function RemindNewMailQueue:DoClick()
	if #self.datalist <= 0 then return; end
	local data = table.remove(self.datalist, 1);
	self:RefreshData();

	if not UIMail:IsShow() then
		UIMail:Show();
	else
		UIMail:Hide();
	end
end
