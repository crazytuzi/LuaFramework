
--[[
杀戮值Model
2015年1月23日16:50:26
haohu
]]

_G.classlist['KillValueModel'] = 'KillValueModel'
_G.KillValueModel = Module:new();
KillValueModel.objName = 'KillValueModel'

-----------------杀戮值---------------------------
KillValueModel.killValue = 0;

function KillValueModel:SetKillValue( value )
	self.killValue = value;
	self:sendNotification(NotifyConsts.KillValueChange);
end

function KillValueModel:GetKillValue()
	return self.killValue or 0;
end

-----------------杀戮历史记录---------------------------
-- { level = num } 记录了哪一档分别达成了多少次
KillValueModel.killHistory = {}

function KillValueModel:AddKillHistory( level, num )
	if not self.killHistory[level] then
		self.killHistory[level] = num;
	else
		self.killHistory[level] = self.killHistory[level] + num;
	end
	self:sendNotification( NotifyConsts.KillHistoryChange );
end

function KillValueModel:GetKillHistory()
	return self.killHistory;
end
