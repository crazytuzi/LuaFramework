--[[
玉佩: controller
2015年1月28日10:40:38
haohu
]]

_G.MingYuController = { {}, {__index = IController } };
MingYuController.name = "MingYuController";

function MingYuController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_MingYuWeaponInfo, self, self.OnMingYuWeaponInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_MingYuWeaponProficiency, self, self.OnMingYuWeaponProficiencyRsv );
	MsgManager:RegisterCallBack( MsgType.SC_MingYuWeaponLevelUp, self, self.OnMingYuWeaponLevelUp );
	MsgManager:RegisterCallBack( MsgType.SC_MingYuWeaponChangeModel, self, self.OnMingYuWeaponChangeModel );
end

function MingYuController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function MingYuController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end

--------------------------------resp-------------------------------------------
-- 收到玉佩信息
function MingYuController:OnMingYuWeaponInfoRsv( msg )
	local mWeaponInfo = msg;
	MingYuModel:SetInfo(mWeaponInfo);
end

-- 收到玉佩熟练度
function MingYuController:OnMingYuWeaponProficiencyRsv( msg )
	MingYuModel:SetProficiency( msg.proficiency );
end

-- 收到玉佩升阶结果
function MingYuController:OnMingYuWeaponLevelUp( msg )
	local result = msg.result;
	if result == 0 then -- 0:成功
		MingYuModel:SetBlessing( msg.blessing );
		return;
	end

	self:SetAutoLevelUp(false);
	if result == 4 then -- 4:熟练度不够
		FloatManager:AddCenter( StrConfig['mingYu020'] );
		return;
	end
	if result == 5 then -- 钱不足
		FloatManager:AddCenter( StrConfig['mingYu021'] );
		return;
	end
	if result == 6 then -- 道具数量不足
		FloatManager:AddCenter( StrConfig['mingYu022'] );
		return;
	end
end

-- 收到玉佩模型切换
function MingYuController:OnMingYuWeaponChangeModel( msg )
	local level = msg.level
	if level < 0 then
		if level == -1 then -- 等阶不够
			FloatManager:AddCenter( StrConfig['mingYu015'] ) -- 正常情况不会发生，会被客户端拦
		else
			Debug( "change magic weapon model failed. level:" .. level )
		end
	elseif level > 0 then -- 成功
		MingYuModel:SetModelLevel( level )
	end
end

-------------------------------req---------------------------------------------
-- 请求升阶玉佩
-- @param auto: 是否自动升阶
function MingYuController:ReqMingYuWeaponLevelUp()
	local autoBuy = MingYuModel.autoBuy
	if not autoBuy and not self:CheckLvlUpItemEnough() then
		FloatManager:AddNormal( StrConfig['mingYu034'] )
		self:SetAutoLevelUp(false)
		local itemID = MingYuUtils:GetConsumeItem(MingYuModel:GetLevel());
		UIQuickBuyConfirm:Open(UIMingYu,itemID);
		return
	end
	if not self:CheckLvlUpMoneyEnough() then
		self:SetAutoLevelUp(false)
		FloatManager:AddNormal( StrConfig['mingYu035'] )
		return
	end
	local msg = ReqMingYuWeaponLevelUpMsg:new();
	msg.autobuy = autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
end

function MingYuController:CheckLvlUpItemEnough()
	local level = MingYuModel:GetLevel()
	local _, _, isEnough = MingYuUtils:GetConsumeItem(level)
	return isEnough
end

function MingYuController:CheckLvlUpMoneyEnough()
	local playerInfo = MainPlayerModel.humanDetailInfo
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold
	local level = MingYuModel:GetLevel()
	local moneyConsume = MingYuUtils:GetConsumeMoney(level)
	return playerMoney >= moneyConsume
end

MingYuController.isAutoLvlUp = false;
local timerKey;
function MingYuController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	if auto then
		if timerKey ~= nil then return end;
		timerKey = TimerManager:RegisterTimer( function()
			self:ReqMingYuWeaponLevelUp();
		end, 300, 0 );-- 自动升阶时间间隔300毫秒
	else
		if timerKey then
			TimerManager:UnRegisterTimer(timerKey);
			timerKey = nil;
		end
	end
	self.isAutoLvlUp = auto;
	UIMingYu:SwitchAutoLvlUpState(auto);
end

function MingYuController:ReqUseModel( modelLevel )
	local currentUseModelLevel = MingYuModel:GetModelLevel()
	if modelLevel == currentUseModelLevel then return end
	local msg = ReqMingYuWeaponChangeModelMsg:new()
	msg.level = modelLevel
	MsgManager:Send(msg)
end

----------------------------------------------------------------------------------------------------

function MingYuController:CanLevelUp()
	local level = MingYuModel:GetLevel()
	local lvlPrfcncy = MingYuModel:GetLvlProficiency();
	return level < MingYuConsts:GetMaxLevel() and lvlPrfcncy == MingYuConsts.MaxLvlProficiency
end