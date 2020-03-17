--[[
运营活动-坐骑首日
2015年3月23日20:25:57
haohu
]]

_G.UIOperActBase = BaseUI:new("UIOperAct");

function UIOperActBase:new(name, id)
	local ui = BaseUI:new(name);
	for i, v in pairs(self) do
		if type(v) == "function" then
			ui[i] = v;
		end
	end
	ui.id = id;
	return ui;
end

function UIOperActBase:GetId()
	return self.id;
end

function UIOperActBase:GetOperAct()
	local id = self:GetId();
	return OperActModel:GetOperAct( id );
end

-- 领奖
function UIOperActBase:GetReward()
	local id = self:GetId();
	OperActController:ReqOperActGetReward(id);
end

-------------------------------消息处理--------------------------------------
function UIOperActBase:ListNotificationInterests()
	return {
		NotifyConsts.OperActActiveState,
		NotifyConsts.OperActObtainState,
		NotifyConsts.OperActTime,
		NotifyConsts.OperActRewardNum,
	}
end

function UIOperActBase:HandleNotification( name, body )
	if name == NotifyConsts.OperActActiveState then
		if body == self:GetId() then
			self:OnActActiveStateChange();
		end
	elseif name == NotifyConsts.OperActObtainState then
		if body == self:GetId() then
			self:OnObtainStateChange();
		end
	elseif name == NotifyConsts.OperActTime then
		if body == self:GetId() then
			self:OnUsedTimeChange();
		end
	elseif name == NotifyConsts.OperActRewardNum then
		if body == self:GetId() then
			self:OnRewardNumChange();
		end
	end
end

function UIOperActBase:OnActActiveStateChange()
	local operAct = self:GetOperAct();
	if not operAct:GetActive() then
		self:Hide();
	end
end

----------------------------------------------------------------------------------
function UIOperActBase:OnObtainStateChange()
	-- override in subclasses
end

function UIOperActBase:OnUsedTimeChange()
	-- override in subclasses
end

function UIOperActBase:OnRewardNumChange()
	-- override in subclasses
end

