--[[
提醒Model
lizhuangzhuang
2014年10月22日19:44:06
]]

_G.RemindModel = Module:new();

RemindModel.queueList = {};

function RemindModel:GetQueue(type)
	return self.queueList[type];
end

function RemindModel:AddQueue(remindQueue)
	self.queueList[remindQueue:GetType()] = remindQueue;
end
