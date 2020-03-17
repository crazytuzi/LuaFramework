--[[
兵灵: controller

]]
_G.BingLingController = setmetatable({},{__index=IController})
BingLingController.name = "BingLingController";

function BingLingController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_BingLingInfo, self, self.OnBingLingInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_BingLingLevelUp, self, self.OnBingLingLevelUp );
end

function BingLingController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function BingLingController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end

--------------------------------resp-------------------------------------------
-- 收到兵灵信息
function BingLingController:OnBingLingInfoRsv( msg )
	print('=============收到兵灵信息')
	trace(msg)
	local list = {};
	for i,listvo in ipairs(msg.list) do
		local vo = {};
		vo.id = listvo.id;
		vo.progress = listvo.progress;
		table.push(list, vo);
	end
	BingLingModel:SetInfo(list);
end

-- 收到兵灵升阶结果
function BingLingController:OnBingLingLevelUp( msg )
	print('===============收到兵灵升阶结果')
	trace(msg)
	local result = msg.result;
	if result == 0 then -- 0:成功
		local vo = {};
		vo.id = msg.id;
		vo.progress = msg.progress;
		BingLingModel:UpdateBingLingVO(vo);
		--升阶了
		if msg.progress == 0 then
			self:SetAutoLevelUp(false);
		end
		
		if self.isAutoLvlUp then
			if self.timerKey then
				TimerManager:UnRegisterTimer(self.timerKey);
				self.timerKey = nil;
			end
			self.timerKey = TimerManager:RegisterTimer( function()
				if self.isAutoLvlUp then
					local curlevel = BingLingUtils:GetLevelByid(UIBingLing.currentid);
					self:ReqBingLingLevelUp(curlevel);
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

-------------------------------req---------------------------------------------
-- 请求升阶兵灵
-- @param auto: 是否自动升阶
function BingLingController:ReqBingLingLevelUp(level)
	if not self:CheckLevelUp(level) then
		return 
	end

	local msg = ReqBingLingLevelUpMsg:new();
	msg.id = level;
	MsgManager:Send(msg);
	
	print('====================请求升阶兵灵')
	trace(msg)
end

BingLingController.isAutoLvlUp = false;
local timerKey;
function BingLingController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	self.isAutoLvlUp = auto;
	UIBingLingLvlUp:SwitchAutoLvlUpState(auto);
end

function BingLingController:CheckLevelUp(level)
	if not BingLingModel.autoBuy then
		if not self:CheckMoney(level) then
			FloatManager:AddNormal(StrConfig['wuhun37'])--金钱不足，无法进阶
			BingLingController:SetAutoLevelUp(false);
			return false
		end
		
		if not self:CheckItem(level) then
			FloatManager:AddNormal( StrConfig["qizhan6"]);
			BingLingController:SetAutoLevelUp(false);
			return false
		end
	else
		if BingLingController:GetIsJinJieByMoney() == false then
			FloatManager:AddNormal( StrConfig["qizhan6"]);
			BingLingController:SetAutoLevelUp(false);
			return false;
		end
	end
	
	if not self:CheckMoney(level) then
		FloatManager:AddNormal(StrConfig['wuhun37'])--金钱不足，无法进阶
		BingLingController:SetAutoLevelUp(false);
		return false
	end
	return true
end

function BingLingController:CheckMoney(level)
	print('==================level=',level)
	local cfg = t_shenbingbingling[level];
	if not cfg then return false end
	if not cfg.money then
		return true;
	end
	local moneyConsume = cfg.money;
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local bBuy = moneyEnough and true or false;
	return bBuy
end

function BingLingController:CheckItem(level)
	local cfg = t_shenbingbingling[level];
	if not cfg then return false end
	local itemid = tonumber(cfg.levelItem[1]);
	local NbNum = BagModel:GetItemNumInBag(itemid);
	if NbNum < tonumber(cfg.levelItem[2]) then
		FloatManager:AddNormal( StrConfig["qizhan5"]);
		return false;
	end
	return true;
end

--是否有足够元宝进阶
function BingLingController:GetIsJinJieByMoney()
	local level = BingLingModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then
		Error("cannot find config of BingLing in t_ridewar.lua.  level:".. level);
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