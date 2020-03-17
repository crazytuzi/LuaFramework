--[[
升级提醒
lizhuangzhuang
2015年5月5日20:46:19
]]

_G.RemindLvlUpQueue = setmetatable({},{__index=RemindQueue});

RemindLvlUpQueue.isShow = false;
RemindLvlUpQueue.level = 0;
RemindLvlUpQueue.noTipsMap = {};

function RemindLvlUpQueue:GetType()
	return RemindConsts.Type_LvlUp;
end

function RemindLvlUpQueue:GetLibraryLink()
	return "RemindLvlUp";
end

function RemindLvlUpQueue:GetPos()
	return 2;
end

function RemindLvlUpQueue:GetShowIndex()
	return 9;
end

function RemindLvlUpQueue:GetBtnWidth()
	return 60;
end

function RemindLvlUpQueue:AddData(data)
	if self.noTipsMap[data] then
		return;
	end
	self.level = data;
	self.isShow = true;
end

function RemindLvlUpQueue:DoClick()
	self.isShow = false;
	local confirmFunc = function(selected)
		if selected then
			self.noTipsMap[self.level] = true;
		end
		FuncManager:OpenFunc(FuncConsts.Role);
	end
	local cancelFunc = function(selected)
		if selected then
			self.noTipsMap[self.level] = true;
		end
	end
	
	UIConfirmWithNoTip:Open(StrConfig['remind003'],confirmFunc,cancelFunc,StrConfig['remind005'],StrConfig['remind006'],StrConfig['remind007'],StrConfig['remind004']);
	self:RefreshData();
end

function RemindLvlUpQueue:GetIsShow()
	return self.isShow;
end