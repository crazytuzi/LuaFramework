--[[
好友申请列表
lizhuangzhuang
2014年10月22日17:24:12 
]]

_G.RemindFriendApplyQueue = setmetatable({},{__index=RemindQueue});

function RemindFriendApplyQueue:GetType()
	return RemindConsts.Type_FriendApply;
end

function RemindFriendApplyQueue:GetLibraryLink()
	return "RemindFriendApply";
end

function RemindFriendApplyQueue:GetPos()
	return 2;
end

function RemindFriendApplyQueue:GetShowIndex()
	return 25;
end

function RemindFriendApplyQueue:GetBtnWidth()
	return 60;
end

function RemindFriendApplyQueue:AddData(data)
	for _, vo in pairs(self.datalist) do
		if vo.roleId == data.roleId then
			return;
		end
	end
	table.push(self.datalist,data);
end

function RemindFriendApplyQueue:DoClick()
	local pos;
	if self.button then
		pos = UIManager:PosLtoG(self.button,self:GetBtnWidth()/2,0);
	else
		pos = UIManager:GetMousePos();
	end
	UIFriendApply:Open(pos);
end