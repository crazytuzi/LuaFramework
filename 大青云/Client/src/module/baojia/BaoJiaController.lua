--[[
宝甲: controller
2015年4月28日17:12:38
zhangshuhui
]]

_G.BaoJiaController = { {}, {__index = IController } };
BaoJiaController.name = "BaoJiaController";

function BaoJiaController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_BaoJiaInfo, self, self.OnBaoJiaInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_BaoJiaLevelUp, self, self.OnBaoJiaLevelUp );
end

function BaoJiaController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

--------------------------------resp-------------------------------------------
-- 收到宝甲信息
function BaoJiaController:OnBaoJiaInfoRsv( msg )
	--print('===================收到宝甲信息')
	--trace(msg)
	
	local mBaoJiaInfo = msg;
	BaoJiaModel:SetInfo(mBaoJiaInfo);
end

-- 收到宝甲升阶结果
function BaoJiaController:OnBaoJiaLevelUp( msg )
	--print('===================收到宝甲升阶结果')
	--trace(msg)
	
	local result = msg.result;
	if result == 0 then -- 0:成功
		BaoJiaModel:SetBlessing( msg.blessing );
		return;
	end

	self:SetAutoLevelUp(false);
	if result == 5 then -- 钱不足
		FloatManager:AddCenter( StrConfig['baojia021'] );
		return;
	end
	if result == 6 then -- 道具数量不足
		FloatManager:AddCenter( StrConfig['baojia022'] );
		return;
	end
end

-------------------------------req---------------------------------------------
-- 请求升阶宝甲
-- @param auto: 是否自动升阶
function BaoJiaController:ReqBaoJiaLevelUp()
	local msg = ReqBaoJiaLevelUpMsg:new();
	msg.autobuy = BaoJiaModel.autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
	
	--print('===================请求升阶宝甲')
	--trace(msg)
end

BaoJiaController.isAutoLvlUp = false;
local timerKey;
function BaoJiaController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	if auto then
		if timerKey ~= nil then return end;
		timerKey = TimerManager:RegisterTimer( function()
			self:ReqBaoJiaLevelUp();
		end, 300, 0 );-- 自动升阶时间间隔300毫秒
	else
		if timerKey then
			TimerManager:UnRegisterTimer(timerKey);
			timerKey = nil;
		end
	end
	self.isAutoLvlUp = auto;
	UIBaoJiaLvlUp:SwitchAutoLvlUpState(auto);
end