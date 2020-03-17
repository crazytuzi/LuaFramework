--[[
法宝: controller
2015年1月28日10:40:38
haohu
]]

_G.LingQiController = { {}, { __index = IController } };
LingQiController.name = "LingQiController";

function LingQiController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_LingQiWeaponInfo, self, self.OnLingQiWeaponInfoRsv);
	MsgManager:RegisterCallBack(MsgType.SC_LingQiWeaponProficiency, self, self.OnLingQiWeaponProficiencyRsv);
	MsgManager:RegisterCallBack(MsgType.SC_LingQiWeaponLevelUp, self, self.OnLingQiWeaponLevelUp);
	MsgManager:RegisterCallBack(MsgType.SC_LingQiWeaponChangeModel, self, self.OnLingQiWeaponChangeModel);
end

function LingQiController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function LingQiController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end

-------------------------------- resp-------------------------------------------
-- 收到法宝信息
function LingQiController:OnLingQiWeaponInfoRsv(msg)
	local mWeaponInfo = msg;
	LingQiModel:SetInfo(mWeaponInfo);
end

-- 收到法宝熟练度
function LingQiController:OnLingQiWeaponProficiencyRsv(msg)
	LingQiModel:SetProficiency(msg.proficiency);
end

-- 收到法宝升阶结果
function LingQiController:OnLingQiWeaponLevelUp(msg)
	local result = msg.result;
	if result == 0 then -- 0:成功
	LingQiModel:SetBlessing(msg.blessing);
	return;
	end

	self:SetAutoLevelUp(false);
	if result == 4 then -- 4:熟练度不够
	FloatManager:AddCenter(StrConfig['lingQi020']);
	return;
	end
	if result == 5 then -- 钱不足
	FloatManager:AddCenter(StrConfig['lingQi021']);
	return;
	end
	if result == 6 then -- 道具数量不足
	FloatManager:AddCenter(StrConfig['lingQi022']);
	return;
	end
end

-- 收到法宝模型切换
function LingQiController:OnLingQiWeaponChangeModel(msg)
	local level = msg.level
	if level < 0 then
		if level == -1 then -- 等阶不够
		FloatManager:AddCenter(StrConfig['lingQi015']) -- 正常情况不会发生，会被客户端拦
		else
			Debug("change magic weapon model failed. level:" .. level)
		end
	elseif level > 0 then -- 成功
	LingQiModel:SetModelLevel(level)
	end
end

------------------------------- req---------------------------------------------
-- 请求升阶法宝
-- @param auto: 是否自动升阶
function LingQiController:ReqLingQiWeaponLevelUp()
	local autoBuy = LingQiModel.autoBuy
	if not autoBuy and not self:CheckLvlUpItemEnough() then
		FloatManager:AddNormal(StrConfig['lingQi034'])
		self:SetAutoLevelUp(false)
		local itemID = LingQiUtils:GetConsumeItem(LingQiModel:GetLevel());
		UIQuickBuyConfirm:Open(UILingQi, itemID);
		return
	end
	if not self:CheckLvlUpMoneyEnough() then
		self:SetAutoLevelUp(false)
		FloatManager:AddNormal(StrConfig['lingQi035'])
		return
	end
	local msg = ReqLingQiWeaponLevelUpMsg:new();
	msg.autobuy = autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
end

function LingQiController:CheckLvlUpItemEnough()
	local level = LingQiModel:GetLevel()
	local _, _, isEnough = LingQiUtils:GetConsumeItem(level)
	return isEnough
end

function LingQiController:CheckLvlUpMoneyEnough()
	local playerInfo = MainPlayerModel.humanDetailInfo
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold
	local level = LingQiModel:GetLevel()
	local moneyConsume = LingQiUtils:GetConsumeMoney(level)
	return playerMoney >= moneyConsume
end

LingQiController.isAutoLvlUp = false;
local timerKey;
function LingQiController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	if auto then
		if timerKey ~= nil then return end;
		timerKey = TimerManager:RegisterTimer(function()
			self:ReqLingQiWeaponLevelUp();
		end, 300, 0); -- 自动升阶时间间隔300毫秒
	else
		if timerKey then
			TimerManager:UnRegisterTimer(timerKey);
			timerKey = nil;
		end
	end
	self.isAutoLvlUp = auto;
	UILingQi:SwitchAutoLvlUpState(auto);
end

function LingQiController:ReqUseModel(modelLevel)
	local currentUseModelLevel = LingQiModel:GetModelLevel()
	if modelLevel == currentUseModelLevel then return end
	local msg = ReqLingQiWeaponChangeModelMsg:new()
	msg.level = modelLevel
	MsgManager:Send(msg)
end

----------------------------------------------------------------------------------------------------
function LingQiController:CanLevelUp()
	local level = LingQiModel:GetLevel()
	local lvlPrfcncy = LingQiModel:GetLvlProficiency();
	return level < LingQiConsts:GetMaxLevel() and lvlPrfcncy == LingQiConsts.MaxLvlProficiency
end