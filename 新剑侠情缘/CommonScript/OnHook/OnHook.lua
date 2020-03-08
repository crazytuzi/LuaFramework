Require("CommonScript/DrinkHouse/DrinkHouse.lua")
Require("CommonScript/House/HousePeachDef.lua");

OnHook.SAVE_ONHOOK_GROUP = 84;
OnHook.OffLine_Time = 1;						-- 玩家下线时间(但计算使用最后存库时间，这里离线时间仅用于区别开放挂机后的第一次计算 TODO)
OnHook.Exp_Time = 2;							-- 玩家目前可领取经验的时间
OnHook.OnHook_Time = 3;							-- 目前可挂机的时间
OnHook.BaiJuWan_Time = 4;						-- 可使用的白驹丸时间
OnHook.SpecialBaiJuWan_Time = 5;				-- 可使用的特效白驹丸时间

OnHook.SAVE_ONHOOK_LOGIN_GROUP = 98;
OnHook.Login_Time = 1 							-- 玩家登陆时间或最近一次在线托管时间

OnHook.SAVE_ONLINE_ONHOOK_GROUP = 99
OnHook.OnLine_OnHook_Time = 1; 					-- 玩家在线托管开始时间

OnHook.OnHookTimeReset_Hour = 4;				-- 重置时间 （时）

OnHook.OnHookTimePerDay = 24 * 60 * 60;			-- 每天可使用的挂机时间（秒）
OnHook.MaxExpTime = 48 * 60 * 60;				-- 最多可累积的可领取经验的时间（秒）

OnHook.nOpenLevel = 20;							-- 开放等级
OnHook.nDelayTime = 60;							-- 延迟挂机时间

OnHook.nBaseRate = 0.72;						-- 每分钟离线基准经验

OnHook.fFreeGetExpRate = 1;						-- 免费领取经验的倍率	 倍率越大，误差越大（这是因为在经验和时间转换的是否会取上或取下造成的误差）

OnHook.fPayGetExpRate = 1.67;					-- 付费白驹丸领取经验的倍率
OnHook.fSpecialPayGetExpRate = 2.5;				-- 付费特效领取经验的倍率

OnHook.szOpenDay = "OpenDay2D";					-- 开放时间轴

--与timeframe.tab中的时间设置一致
OnHook.nOpenDay = 2;							-- 开服第n天
OnHook.nOpenTime = 0;					    	-- hour = 1000 / 100 min = 1000 % 100

OnHook.OnHookType =
{
	Free = 1,
	Pay = 2,
	SpecialPay = 3;
}

OnHook.GetExpRate =
{
	[OnHook.OnHookType.Free] = OnHook.fFreeGetExpRate,
	[OnHook.OnHookType.Pay] = OnHook.fPayGetExpRate,
	[OnHook.OnHookType.SpecialPay] = OnHook.fSpecialPayGetExpRate,
}

OnHook.tbVipAddition = 							-- vip >=n级的加成,按vip等级从小到大配置
{
	{8,1.1},
	{12,1.2},
	{16,1.3},
}

OnHook.nBaiJuWanId = 1929;						-- 白驹丸道具ID
OnHook.nSpecialBaiJuWanId = 1930;				-- 特效白驹丸道具ID

OnHook.nSpecialBaiJuWanOpenVip = 6;				-- 特效白驹丸开放的VIP等级

OnHook.tbOnHook = {};

OnHook.nRequestOnlineOHInterval = 60 			-- 请求在线托管间隔

OnHook.nNoMoveBuffId = 1058

OnHook.nBaiJuWanLimitTime = 10000000 			-- 白驹丸使用上限时间
OnHook.nSpecialBaiJuWanLimitTime = 10000000 	-- 特效白驹丸使用上限时间

-- 强制开在线托管的地图
OnHook.tbForchMap = 
{
	[DrinkHouse.tbDef.NORMAL_MAP] = true;
	[House.tbPeach.FAIRYLAND_MAP_TEMPLATE_ID] = true;
}

function OnHook:CheckType(nGetType)
	for _,nType in pairs(OnHook.OnHookType) do
		if nType == tonumber(nGetType) then
			return true;
		end
	end
end

function OnHook:IsHaveExpTime(pPlayer)
	local nExpTime = self:ExpTime(pPlayer);
	if nExpTime > 0 then
		local nHour,nMin = Lib:TransferSecond2NormalTime(nExpTime);
		if nHour * 60 + nMin > 0 then
			return true
		end
	end
end

function OnHook:GetVipAddition(pPlayer)
	local nVipLevel = pPlayer.GetVipLevel()
	local nVipAddition = 1
	for _,tbSetting in ipairs(OnHook.tbVipAddition) do
		local nVip = tbSetting[1]
		local nAddition = tbSetting[2]
		if nVipLevel >= nVip then
			nVipAddition = nAddition
		end
	end
	return nVipAddition
end

-- 离线时间换算经验，舍去秒数
function OnHook:ExpTime2Exp(nExpTime,nType,nRate,nVipAddition)
	local nHour,nMin = Lib:TransferSecond2NormalTime(nExpTime);
	return math.ceil((nHour * 60 + nMin) * self.nBaseRate * self.GetExpRate[nType] * nRate * nVipAddition);
end

function OnHook:Exp2ExpTime(nExp,nType,nRate,nVipAddition)
	return math.ceil(nExp / self.nBaseRate / self.GetExpRate[nType] / nRate / nVipAddition) * 60;				-- 返回多少秒
end

function OnHook:NowExp(pPlayer,nType,nExpTime)
	local nExpTime = nExpTime or self:ExpTime(pPlayer)
	local nRate = pPlayer.GetBaseAwardExp()
	local nVipAddition = OnHook:GetVipAddition(pPlayer)
	return self:ExpTime2Exp(nExpTime,nType,nRate,nVipAddition)
end

function OnHook:MaxOpenLevel()																	-- 目前开放等级
	 if MODULE_GAMESERVER then
	 	return GetMaxLevel();
	 end
	 if not MODULE_GAMESERVER and not MODULE_ZONESERVER then
		return self.nCurMaxLevel
	end
	return 1000;
end

function OnHook:LoadSetting()

	local szTabPath = "Setting/Player/PlayerLevel.tab";
	local szParamType = "ddd";
	local szKey = "Level";
	local tbParams = {"Level","ExpUpGrade", "BaseAwardExp"};
	local tbPlayerLevel = LoadTabFile(szTabPath, szParamType, szKey, tbParams);

	for nLevel,tbInfo in ipairs(tbPlayerLevel) do
		self.tbOnHook[nLevel] = {
			nLevel = nLevel,
			nExpUpGrade = tbInfo.ExpUpGrade,
			nBaseAwardExp = tbInfo.BaseAwardExp,
		}
	end
end

OnHook:LoadSetting();

function OnHook:IsOpen(pPlayer)
	return pPlayer.nLevel >= self.nOpenLevel and GetTimeFrameState(self.szOpenDay) == 1;
end

-- 判定是否跨天
function OnHook:IsCrossDay(pPlayer,nEndTime,nStartTime)						-- nEndTime是否跨nStartTime时间点的天（nStartTime不传则默认以上一次下线时间为基准）
	nEndTime = nEndTime or GetTime();
	return nEndTime >= self:CrossTime(pPlayer,nStartTime);
end

-- 以下线时间为基准，跨天的时间点
function OnHook:CrossTime(pPlayer,nStartTime)
	local nOffLineTime = nStartTime 														-- 最近一次存库时间
	local nOfflineZeroTime = Lib:GetTodayZeroHour(nOffLineTime);							-- 离线当天的0点
	local nOfflineHour,nOfflineMin,nOfflineSec = Lib:TransferSecond2NormalTime(nOffLineTime - nOfflineZeroTime);
	nOffLineTime = nOffLineTime - (nOfflineMin * 60) - nOfflineSec;							-- 先减去分秒数
	local nCrossHour = (24-(nOfflineHour - self.OnHookTimeReset_Hour)) % 24;				-- 算出跨天还要几个小时
	if nCrossHour == 0 then
		nCrossHour = 24
	end
	local nCrossTime = nOffLineTime + nCrossHour * 60 * 60;									-- 跨天的时间点
	return nCrossTime
end

-- 以下线时间为基准，累积的经验时间 & 剩余可用的挂机时间
function OnHook:CalcPassExpAndOnHookTime(pPlayer,nEndTime,nLastSaveTime)
	local nPassExpTime = 0;
	local nRemainOnHookTime = 0;

	local nOffLineTime = nLastSaveTime														-- 最近一次存库时间
	local nOnHookTime = self:OnHookTime(pPlayer);											-- 下线之前可用的挂机时间
	local nExpTime = self:ExpTime(pPlayer);
	local bIsCross = self:IsCrossDay(pPlayer,nEndTime,nOffLineTime);
	if nExpTime >= self.MaxExpTime then														-- 超过可累计的离线时间
		nRemainOnHookTime = nOnHookTime
		if bIsCross then
			nRemainOnHookTime = self.OnHookTimePerDay;										-- 跨天更新
		end

		return nPassExpTime,nRemainOnHookTime;
	end
	if bIsCross then
		local nCrossTime = self:CrossTime(pPlayer,nOffLineTime);
		-- 跨天之前时间段的可领取经验的时间计算
		local nPassBeforeTime = nCrossTime - nOffLineTime;
		nPassExpTime = (nPassBeforeTime > nOnHookTime) and nOnHookTime or nPassBeforeTime;

		-- 跨天之后时间段的可领取经验的时间计算
		local nPassAfterTime = nEndTime - nCrossTime;

		local nDay = math.floor(nPassAfterTime / (24 * 60 * 60));																-- 以跨天为时间点，经过的天数
		nPassExpTime = nPassExpTime + nDay * self.OnHookTimePerDay;
		nPassAfterTime = nPassAfterTime % (24 * 60 * 60);																		-- 除去天数剩下的时间
		nPassExpTime = nPassExpTime + ((nPassAfterTime > self.OnHookTimePerDay) and self.OnHookTimePerDay or nPassAfterTime);
		nPassExpTime = nPassExpTime - self.nDelayTime 																			-- 减去延迟离线时间
		nPassAfterTime = self:DragOutSecond(nPassAfterTime);																	-- 忽略秒数
		--跨天剩余可用的挂机时间计算
		nRemainOnHookTime = (nPassAfterTime > self.OnHookTimePerDay) and 0 or (self.OnHookTimePerDay - nPassAfterTime);

		if nExpTime + nPassExpTime > self.MaxExpTime then
			local nOverTime = nExpTime + nPassExpTime - self.MaxExpTime
			nRemainOnHookTime = nRemainOnHookTime + nOverTime;																	-- 加上已经被算上的超过48的时间
			nRemainOnHookTime = nRemainOnHookTime > self.OnHookTimePerDay and self.OnHookTimePerDay or nRemainOnHookTime;		-- 剩余挂机时间不超过18小时
		end
	else
		-- 没跨天的可领取经验的时间 & 剩余可用的挂机时间计算
		local nPassTime = nEndTime - nOffLineTime - self.nDelayTime;															-- 减去延迟离线时间
		nPassTime = nPassTime < 0 and 0 or nPassTime;
		nPassTime = self:DragOutSecond(nPassTime);																				-- 忽略秒数
		nPassExpTime = (nPassTime > nOnHookTime) and nOnHookTime or nPassTime;
		nRemainOnHookTime = (nPassTime > nOnHookTime) and 0 or (nOnHookTime - nPassTime);

		if nExpTime + nPassExpTime > self.MaxExpTime then
			local nOverTime = nExpTime + nPassExpTime - self.MaxExpTime
			nRemainOnHookTime = nRemainOnHookTime + nOverTime;																	-- 加上已经被算上的超过48的时间
			nRemainOnHookTime = nRemainOnHookTime > self.OnHookTimePerDay and self.OnHookTimePerDay or nRemainOnHookTime
		end
	end
	nPassExpTime = self:DragOutSecond(nPassExpTime);
	return nPassExpTime,nRemainOnHookTime
end

function OnHook:DragOutSecond(nTime)
	local nHour,nMin = Lib:TransferSecond2NormalTime(nTime)
	return nHour * 60 * 60 + nMin * 60;
end

function OnHook:CheckCommond(pPlayer)

	if not self:IsOpen(pPlayer) then
		return false,"离线托管尚未开放";
	end

	local nExpTime = self:ExpTime(pPlayer);
	if nExpTime < 60 then													-- 离线时间按分钟换算经验,所以不能小于60秒
		return false,"没有可领取的离线经验"
	end


	-- if self:CheckIsMaxOpenLevel(pPlayer) then
	-- 	return false,"少侠已经达到当前等级上限";
	-- end

	return true
end

function OnHook:CheckIsMaxOpenLevel(pPlayer)
	local nHaveExp = pPlayer.GetExp();
	local nNextExp = self.tbOnHook[pPlayer.nLevel].nExpUpGrade;
	return pPlayer.nLevel >= self:MaxOpenLevel() and nHaveExp >= nNextExp
end

--暂废弃
function OnHook:UpdatePlayerLoginTime()
	me.nLastLoginTime = GetTime();											-- 服务器和客户端可能会有一两秒的延迟
	if MODULE_GAMESERVER then
		me.CallClientScript("OnHook:UpdatePlayerLoginTime");
	end
end

function OnHook:PayTips(pPlayer,nPayType)

	local szTip = "";
	local nExpTime = self:ExpTime(pPlayer);
	local nBaiJuWanTime = self:GetBaiJuWanTime(pPlayer,nPayType);
	if nExpTime > nBaiJuWanTime then
		local nExtraExpTime = nExpTime - nBaiJuWanTime;											-- 缺少的白驹丸时间

		local nPerBaiJuWanTime,nPerBaiJuWanPrice,nItemId = self:GetPerBaiJuWanInfo(nPayType);-- 每个白驹丸时间,价格

		local nHaveNum = pPlayer.GetItemCountInAllPos(nItemId);								-- 拥有的白驹丸数量
		local nNeedNum = math.ceil(nExtraExpTime / nPerBaiJuWanTime);							-- 需要的白驹丸数量
		local nUseNum = nHaveNum > nNeedNum and nNeedNum or nHaveNum;							-- 用掉的白驹丸数量
		local nLackNum = nNeedNum - nHaveNum; 													-- 还缺少的白驹丸数量

		szTip = szTip .."\n（";

		if nHaveNum > 0 then
			szTip = szTip ..string.format("已拥有[FFFE0D]%d个[-]%s",nHaveNum,Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex))
		end

		if nLackNum > 0 then																	-- 需要用元宝的情况
			if nHaveNum > 0 then
				szTip = szTip .."，";
			end
			local nNeedPay = nLackNum * nPerBaiJuWanPrice;
			 local _, szMoneyEmotion = Shop:GetMoneyName("Gold");
			 local szNeedBuy = string.format("需再购买[FFFE0D]%d个[-]",nLackNum)
			 if nHaveNum <= 0 then
			 	szNeedBuy = szNeedBuy .. Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
			 end
			 local szNeedPay = string.format("，花费[FFFE0D]%d[-]%s",nNeedPay,szMoneyEmotion);
			szTip = szTip ..szNeedBuy ..szNeedPay
		end

		szTip = szTip .."）";
	end

	return szTip;
end

function OnHook:CheckSpecialBaiJuWanIsOpen(pPlayer)
	 local nVipLevel = pPlayer.GetVipLevel();
	 return nVipLevel >= self.nSpecialBaiJuWanOpenVip or self:SpecialBaiJuWanTime(pPlayer) >= 60;
end

function OnHook:CheckSpecialPayType(pPlayer)
	return pPlayer.GetVipLevel() < self.nSpecialBaiJuWanOpenVip and self:SpecialBaiJuWanTime(pPlayer) >= 60
end

function OnHook:GetBaiJuWanTime(pPlayer,nPayType)
	if nPayType == OnHook.OnHookType.Pay then
		return self:BaiJuWanTime(pPlayer);
	elseif nPayType == OnHook.OnHookType.SpecialPay then
		return self:SpecialBaiJuWanTime(pPlayer);
	end
	return 0;
end

function OnHook:GetBaiJuWanSaveKey(nPayType)
	if nPayType == OnHook.OnHookType.Pay then
		return self.BaiJuWan_Time;
	elseif nPayType == OnHook.OnHookType.SpecialPay then
		return self.SpecialBaiJuWan_Time;
	end
end

function OnHook:GetPerBaiJuWanInfo(nPayType)
	if nPayType == OnHook.OnHookType.Pay then
		return Item:GetClass("BaiJuWan").nAddTime,Item:GetClass("BaiJuWan").nPrice,self.nBaiJuWanId;
	elseif nPayType == OnHook.OnHookType.SpecialPay then
		return Item:GetClass("SpecialBaiJuWan").nAddTime,Item:GetClass("SpecialBaiJuWan").nPrice,self.nSpecialBaiJuWanId;
	end
end

function OnHook:CheckStartOnlineHook(pPlayer)
	if not self:IsOpen(pPlayer) then
		return false,"在线托管尚未开放";
	end

	if not Map:IsCityMap(pPlayer.nMapTemplateId) then
		return false,"仅在城市、新手村、家园和酒馆才可以托管"
	end

	if OnHook:OnHookTime(pPlayer) < 60 and not self:IsCrossDay(pPlayer,GetTime(),self:LoginTime(pPlayer)) then
		return false,"今日托管时间已用完"
	end

	if self:OnLineOnHookTime(pPlayer) > 0 then
		return false,"目前已经开启在线挂机"
	end

	return true
end

function OnHook:CheckEndOnlineHook(pPlayer)
	if not self:IsOpen(pPlayer) then
		return false,"离线托管尚未开放";
	end

	return true
end

function OnHook:IsOnLineOnHook(pPlayer)
	return self:OnLineOnHookTime(pPlayer) > 0
end

-- 是否是强制在线托管类型
function OnHook:IsOnLineOnHookForce(pPlayer)
	return self:IsOnLineOnHook(pPlayer) and self:CanStartForceOnLineOnHook(pPlayer)
end

-- 是否可以开强制在线托管类型
function OnHook:CanStartForceOnLineOnHook(pPlayer)
	return ((House:IsInNormalHouse(pPlayer) and (House:IsInOwnHouse(pPlayer) or House:IsInLivingRoom(pPlayer))) or OnHook.tbForchMap[pPlayer.nMapTemplateId])
end

-- 最近一次存库时间
function OnHook:LastSaveTime(pPlayer)
	local tbStayInfo = KPlayer.GetRoleStayInfo(pPlayer.dwID)
	return tbStayInfo and tbStayInfo.nLastOnlineTime or 0
end

-- 离线时间
function OnHook:LastOfflineTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.OffLine_Time);
end

--经验时间
function OnHook:ExpTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time);
end

-- 挂机时间
function OnHook:OnHookTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.OnHook_Time);
end

-- 白驹丸时间
function OnHook:BaiJuWanTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.BaiJuWan_Time);
end

-- 特效白驹丸时间
function OnHook:SpecialBaiJuWanTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.SpecialBaiJuWan_Time);
end

-- 玩家登陆时间
function OnHook:LoginTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONHOOK_LOGIN_GROUP, self.Login_Time);
end

-- 玩家在线托管开始时间
function OnHook:OnLineOnHookTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time);
end

function OnHook:GetOnHookTime(pPlayer)
	local nLoginTime = self:LoginTime(pPlayer)
	if nLoginTime and nLoginTime ~= 0 then

		local bIsCross = self:IsCrossDay(pPlayer,GetTime(),nLoginTime)
		if bIsCross then
			return self.OnHookTimePerDay;
		end
	end

	return self:OnHookTime(pPlayer);
end

function OnHook:CheckRequestOnlineOH(pPlayer)
	if pPlayer.nRequestStartOnlineOHTime and GetTime() < pPlayer.nRequestStartOnlineOHTime then
		local nInterval = pPlayer.nRequestStartOnlineOHTime - GetTime()
		local nSecond =  nInterval > 0 and nInterval or 0
		return false,string.format("托管操作太频繁了,请%d秒之后再尝试",nSecond)
	end

	return true
end

function OnHook:CheckIsShowSpecialTip(pPlayer)
	return pPlayer.GetVipLevel() >= self.nSpecialBaiJuWanOpenVip
end