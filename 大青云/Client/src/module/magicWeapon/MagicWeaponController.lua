--[[
神兵: controller
2015年1月28日10:40:38
haohu
]]

_G.MagicWeaponController = { {}, {__index = IController } };
MagicWeaponController.name = "MagicWeaponController";

function MagicWeaponController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_MagicWeaponInfo, self, self.OnMagicWeaponInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_MagicWeaponProficiency, self, self.OnMagicWeaponProficiencyRsv );
	MsgManager:RegisterCallBack( MsgType.SC_MagicWeaponLevelUp, self, self.OnMagicWeaponLevelUp );
	MsgManager:RegisterCallBack( MsgType.SC_MagicWeaponChangeModel, self, self.OnMagicWeaponChangeModel );
end

function MagicWeaponController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function MagicWeaponController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end

--------------------------------resp-------------------------------------------
-- 收到神兵信息
function MagicWeaponController:OnMagicWeaponInfoRsv( msg )
	local mWeaponInfo = msg;
	MagicWeaponModel:SetInfo(mWeaponInfo);
end

-- 收到神兵熟练度
function MagicWeaponController:OnMagicWeaponProficiencyRsv( msg )
	MagicWeaponModel:SetProficiency( msg.proficiency );
end

-- 收到神兵升阶结果
function MagicWeaponController:OnMagicWeaponLevelUp( msg )
	local result = msg.result;
	if result == 0 then -- 0:成功
		MagicWeaponModel:SetBlessing( msg.blessing );
		return;
	end

	self:SetAutoLevelUp(false);
	if result == 4 then -- 4:熟练度不够
		FloatManager:AddCenter( StrConfig['magicWeapon020'] );
		return;
	end
	if result == 5 then -- 钱不足
		FloatManager:AddCenter( StrConfig['magicWeapon021'] );
		return;
	end
	if result == 6 then -- 道具数量不足
		FloatManager:AddCenter( StrConfig['magicWeapon022'] );
		return;
	end
end

-- 收到神兵模型切换
function MagicWeaponController:OnMagicWeaponChangeModel( msg )
	local level = msg.level
	if level < 0 then
		if level == -1 then -- 等阶不够
			FloatManager:AddCenter( StrConfig['magicWeapon015'] ) -- 正常情况不会发生，会被客户端拦
		else
			Debug( "change magic weapon model failed. level:" .. level )
		end
	elseif level > 0 then -- 成功
		MagicWeaponModel:SetModelLevel( level )
	end
end

-------------------------------req---------------------------------------------
-- 请求升阶神兵
-- @param auto: 是否自动升阶
function MagicWeaponController:ReqMagicWeaponLevelUp()
	local autoBuy = MagicWeaponModel.autoBuy
	if not autoBuy and not self:CheckLvlUpItemEnough() then
		FloatManager:AddNormal( StrConfig['magicWeapon034'] )
		self:SetAutoLevelUp(false)
		local itemID = MagicWeaponUtils:GetConsumeItem(MagicWeaponModel:GetLevel());
		UIQuickBuyConfirm:Open(UIMagicWeapon,itemID);
		return
	end
	if not self:CheckLvlUpMoneyEnough() then
		self:SetAutoLevelUp(false)
		FloatManager:AddNormal( StrConfig['magicWeapon035'] )
		return
	end
	local msg = ReqMagicWeaponLevelUpMsg:new();
	msg.autobuy = autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
end

function MagicWeaponController:CheckLvlUpItemEnough()
	local level = MagicWeaponModel:GetLevel()
	local _, _, isEnough = MagicWeaponUtils:GetConsumeItem(level)
	return isEnough
end

function MagicWeaponController:CheckLvlUpMoneyEnough()
	local playerInfo = MainPlayerModel.humanDetailInfo
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold
	local level = MagicWeaponModel:GetLevel()
	local moneyConsume = MagicWeaponUtils:GetConsumeMoney(level)
	return playerMoney >= moneyConsume
end

MagicWeaponController.isAutoLvlUp = false;
local timerKey;
function MagicWeaponController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	if auto then
		if timerKey ~= nil then return end;
		timerKey = TimerManager:RegisterTimer( function()
			self:ReqMagicWeaponLevelUp();
		end, 300, 0 );-- 自动升阶时间间隔300毫秒
	else
		if timerKey then
			TimerManager:UnRegisterTimer(timerKey);
			timerKey = nil;
		end
	end
	self.isAutoLvlUp = auto;
	UIMagicWeapon:SwitchAutoLvlUpState(auto);
end

function MagicWeaponController:ReqUseModel( modelLevel )
	local currentUseModelLevel = MagicWeaponModel:GetModelLevel()
	if modelLevel == currentUseModelLevel then return end
	local msg = ReqMagicWeaponChangeModelMsg:new()
	msg.level = modelLevel
	MsgManager:Send(msg)
end

----------------------------------------------------------------------------------------------------

function MagicWeaponController:CanLevelUp()
	local level = MagicWeaponModel:GetLevel()
	local lvlPrfcncy = MagicWeaponModel:GetLvlProficiency();
	return level < MagicWeaponConsts:GetMaxLevel() and lvlPrfcncy == MagicWeaponConsts.MaxLvlProficiency
end