--[[
可领取等级奖励提示
zhangshuhui
2015年4月30日18:19:44
]]
_G.RemindLevelRewardQueue = setmetatable({},{__index=RemindQueue});

RemindLevelRewardQueue.isShow = false;
function RemindLevelRewardQueue:GetType()
	return RemindConsts.Type_LevelReward;
end;

function RemindLevelRewardQueue:GetLibraryLink()
	return "RemindLevelReward";
end;

function RemindLevelRewardQueue:GetPos()
	return 2;
end;

--是否显示
function RemindLevelRewardQueue:GetIsShow()
	return self.isShow;
end


function RemindLevelRewardQueue:GetShowIndex()
	return 6;
end;

function RemindLevelRewardQueue:GetBtnWidth()
	return 60;
end

function RemindLevelRewardQueue:AddData(data) --1 显示 0 关闭
	--按着自动挂机写的，有问题不要找我啊。。。。。。。。
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindLevelRewardQueue:DoClick()
	UIRegisterAward:SetPanelName("level")
	UIRegisterAward:Show();
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindLevelRewardQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["registerReward13"]));
end
--鼠标移出处理
function RemindLevelRewardQueue:DoRollOut()
	TipsManager:Hide();
end