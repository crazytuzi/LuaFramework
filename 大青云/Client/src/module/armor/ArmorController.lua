--[[
宝甲: controller
2015年1月28日10:40:38
haohu
]]

_G.ArmorController = { {}, {__index = IController } };
ArmorController.name = "ArmorController";

function ArmorController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_NewBaoJiaInfo, self, self.OnNewBaoJiaInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_NewBaoJiaProficiency, self, self.OnNewBaoJiaProficiencyRsv );
	MsgManager:RegisterCallBack( MsgType.SC_NewBaoJiaLevelUp, self, self.OnNewBaoJiaLevelUp );
	--MsgManager:RegisterCallBack( MsgType.SC_NewBaoJiaChangeModel, self, self.OnNewBaoJiaChangeModel );
end

function ArmorController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function ArmorController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end

--------------------------------resp-------------------------------------------
-- 收到宝甲信息
function ArmorController:OnNewBaoJiaInfoRsv( msg )
	local mWeaponInfo = msg;
	ArmorModel:SetInfo(mWeaponInfo);
end

-- 收到宝甲熟练度
function ArmorController:OnNewBaoJiaProficiencyRsv( msg )
	ArmorModel:SetProficiency( msg.proficiency );
end

-- 收到宝甲升阶结果
function ArmorController:OnNewBaoJiaLevelUp( msg )
	local result = msg.result;
	if result == 0 then -- 0:成功
		ArmorModel:SetBlessing( msg.blessing );
		return;
	end

	self:SetAutoLevelUp(false);
	if result == 4 then -- 4:熟练度不够
		FloatManager:AddCenter( StrConfig['armor020'] );
		return;
	end
	if result == 5 then -- 钱不足
		FloatManager:AddCenter( StrConfig['armor021'] );
		return;
	end
	if result == 6 then -- 道具数量不足
		FloatManager:AddCenter( StrConfig['armor022'] );
		return;
	end
end

-- 收到宝甲模型切换
function ArmorController:OnNewBaoJiaChangeModel( msg )
	local level = msg.level
	if level < 0 then
		if level == -1 then -- 等阶不够
			FloatManager:AddCenter( StrConfig['armor015'] ) -- 正常情况不会发生，会被客户端拦
		else
			Debug( "change magic weapon model failed. level:" .. level )
		end
	elseif level > 0 then -- 成功
		ArmorModel:SetModelLevel( level )
	end
end

-------------------------------req---------------------------------------------
-- 请求升阶宝甲
-- @param auto: 是否自动升阶
function ArmorController:ReqNewBaoJiaLevelUp()
	local autoBuy = ArmorModel.autoBuy
	if not autoBuy and not self:CheckLvlUpItemEnough() then
		FloatManager:AddNormal( StrConfig['armor034'] )
		self:SetAutoLevelUp(false)
		local itemID = ArmorUtils:GetConsumeItem(ArmorModel:GetLevel());
		UIQuickBuyConfirm:Open(UIArmor,itemID);
		return
	end
	if not self:CheckLvlUpMoneyEnough() then
		self:SetAutoLevelUp(false)
		FloatManager:AddNormal( StrConfig['armor035'] )
		return
	end
	local msg = ReqNewBaoJiaLevelUpMsg:new();
	msg.autobuy = autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
end

function ArmorController:CheckLvlUpItemEnough()
	local level = ArmorModel:GetLevel()
	local _, _, isEnough = ArmorUtils:GetConsumeItem(level)
	return isEnough
end

function ArmorController:CheckLvlUpMoneyEnough()
	local playerInfo = MainPlayerModel.humanDetailInfo
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold
	local level = ArmorModel:GetLevel()
	local moneyConsume = ArmorUtils:GetConsumeMoney(level)
	return playerMoney >= moneyConsume
end

ArmorController.isAutoLvlUp = false;
local timerKey;
function ArmorController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	if auto then
		if timerKey ~= nil then return end;
		timerKey = TimerManager:RegisterTimer( function()
			self:ReqNewBaoJiaLevelUp();
		end, 300, 0 );-- 自动升阶时间间隔300毫秒
	else
		if timerKey then
			TimerManager:UnRegisterTimer(timerKey);
			timerKey = nil;
		end
	end
	self.isAutoLvlUp = auto;
	UIArmor:SwitchAutoLvlUpState(auto);
end

function ArmorController:ReqUseModel( modelLevel )
	local currentUseModelLevel = ArmorModel:GetModelLevel()
	if modelLevel == currentUseModelLevel then return end
	local msg = ReqNewBaoJiaChangeModelMsg:new()
	msg.level = modelLevel
	MsgManager:Send(msg)
end

----------------------------------------------------------------------------------------------------

function ArmorController:CanLevelUp()
	local level = ArmorModel:GetLevel()
	local lvlPrfcncy = ArmorModel:GetLvlProficiency();
	return level < ArmorConsts:GetMaxLevel() and lvlPrfcncy == ArmorConsts.MaxLvlProficiency
end