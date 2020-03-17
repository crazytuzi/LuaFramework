--[[
好友推荐提醒
lizhuangzhuang
2015年5月5日19:42:23
]]

_G.RemindFRecommendQueue = setmetatable({},{__index=RemindQueue});

RemindFRecommendQueue.isShow = false;

function RemindFRecommendQueue:GetType()
	return RemindConsts.Type_FRecommend;
end

function RemindFRecommendQueue:GetLibraryLink()
	return "RemindFRecommend";
end

function RemindFRecommendQueue:GetPos()
	return 2;
end

function RemindFRecommendQueue:GetShowIndex()
	return 8;
end

function RemindFRecommendQueue:GetBtnWidth()
	return 60;
end

function RemindFRecommendQueue:AddData(data)
	self.isShow = true;
end

function RemindFRecommendQueue:DoClick()
	self.isShow = false;
	if not UIFriendRecommend:IsShow() then
		UIFriendRecommend:Show();
	end
	self:RefreshData();
end

function RemindFRecommendQueue:GetIsShow()
	return self.isShow;
end