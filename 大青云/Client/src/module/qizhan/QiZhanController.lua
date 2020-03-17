--[[
骑战: controller

]]
_G.QiZhanController = setmetatable({},{__index=IController})
QiZhanController.name = "QiZhanController";

function QiZhanController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_QiZhanInfo, self, self.OnQiZhanInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_QiZhanLevelUp, self, self.OnQiZhanLevelUp );
	MsgManager:RegisterCallBack( MsgType.SC_ActiveQiZhanResult, self, self.OnActiveQiZhan );
	MsgManager:RegisterCallBack( MsgType.SC_ChangeQiZhanResult, self, self.OnChangeQiZhan );
end

function QiZhanController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function QiZhanController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end

--------------------------------resp-------------------------------------------
-- 收到骑战信息
function QiZhanController:OnQiZhanInfoRsv( msg )
	FTrace(msg, '收到骑战信息')
	local mWeaponInfo = msg;
	QiZhanModel:SetInfo(mWeaponInfo);
end

-- 收到骑战升阶结果
function QiZhanController:OnQiZhanLevelUp( msg )
	FTrace(msg, '收到骑战升阶结果')
	local result = msg.result;
	if result == 0 then -- 0:成功
		QiZhanModel:SetBlessing( msg.blessing );
		--升阶了
		if msg.blessing == 0 then
			self:SetAutoLevelUp(false);
		end
		
		if self.isAutoLvlUp then
			if self.timerKey then
				TimerManager:UnRegisterTimer(self.timerKey);
				self.timerKey = nil;
			end
			self.timerKey = TimerManager:RegisterTimer( function()
				if self.isAutoLvlUp then
					self:ReqQiZhanLevelUp();
				end
				if self.timerKey then
					TimerManager:UnRegisterTimer(self.timerKey);
					self.timerKey = nil;
				end
			end, 300, 1 );-- 自动升阶时间间隔300毫秒
		end
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

-- 激活骑战返回结果
function QiZhanController:OnActiveQiZhan( msg )
	FTrace(msg, '激活骑战返回结果')
	if msg.result == 0 then
	end
end

-- 切换骑战返回结果
function QiZhanController:OnChangeQiZhan( msg )
	FTrace(msg, '切换骑战返回结果')
	if msg.result == 0 then
		QiZhanModel:SetSelectLevel(msg.level);
	end
end

-------------------------------req---------------------------------------------
-- 请求升阶骑战
-- @param auto: 是否自动升阶
function QiZhanController:ReqQiZhanLevelUp()
	if not self:CheckLevelUp() then
		return 
	end

	local msg = ReqQiZhanLevelUpMsg:new();
	msg.autobuy = 1;--QiZhanModel.autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	FTrace(msg, '请求升阶骑战')
	MsgManager:Send(msg);
end

--请求切换骑战
function QiZhanController:ReqChangeQiZhanModel(modelLevel)
	local currentUseModelLevel = QiZhanModel:GetSelectLevel()
	if modelLevel == currentUseModelLevel then return end
	local msg = ReqChangeQiZhanMsg:new();
	msg.level = modelLevel
	MsgManager:Send(msg)
end

QiZhanController.isAutoLvlUp = false;
local timerKey;
function QiZhanController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	self.isAutoLvlUp = auto;
	UIQiZhanLvlUp:SwitchAutoLvlUpState(auto);
end

function QiZhanController:CheckLevelUp()
	if not QiZhanModel.autoBuy then
		if not self:CheckMoney() then
			FloatManager:AddNormal(StrConfig['wuhun37'])--金钱不足，无法进阶
			QiZhanController:SetAutoLevelUp(false);
			return false
		end
		
		if not self:CheckItem() then
			FloatManager:AddNormal( StrConfig["qizhan6"]);
			QiZhanController:SetAutoLevelUp(false);
			return false
		end
	else
		if QiZhanController:GetIsJinJieByMoney() == false then
			FloatManager:AddNormal( StrConfig["qizhan6"]);
			QiZhanController:SetAutoLevelUp(false);
			return false;
		end
	end
	
	if not self:CheckMoney() then
		FloatManager:AddNormal(StrConfig['wuhun37'])--金钱不足，无法进阶
		QiZhanController:SetAutoLevelUp(false);
		return false
	end
	return true
end

function QiZhanController:CheckMoney()
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return false end
	local moneyConsume = cfg.proce_money;
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local bBuy = moneyEnough and true or false;
	return bBuy
end

function QiZhanController:CheckItem()
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return false end
	local itemId, itemNum, isEnough = QiZhanUtils:GetConsumeItem(level);
	return isEnough;
end

--是否有足够元宝进阶
function QiZhanController:GetIsJinJieByMoney()
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then
		Error("cannot find config of QiZhan in t_ridewar.lua.  level:".. level);
		return;
	end
	local itemId = cfg.proce_consume[1]
	
	local intemNum = BagModel:GetItemNumInBag(itemId)
	
	local buymax = MallUtils:GetMoneyShopMaxNum(itemId)
	if buymax == nil then
		return false
	end
	
	-- 材料充足
	if buymax + intemNum >= cfg.proce_consume[2] then
		return true
	else
		return false
	end
end

-- 请求激活骑战
-- @param auto: 是否自动升阶
function QiZhanController:ReqActiveQiZhan(autoBuy)
	local msg = ReqActiveQiZhanMsg:new();
	msg.autobuy = autoBuy; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
end