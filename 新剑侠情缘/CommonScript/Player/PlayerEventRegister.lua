
PlayerEvent.tbGlobalEvent = PlayerEvent.tbGlobalEvent or {};

-- 注册特定玩家事件回调
function PlayerEvent:Register(pPlayer, szEvent, varCallBack, varSelfParam)
	pPlayer.tbPlayerEvent = pPlayer.tbPlayerEvent or {};
	local tbPlayerEvent	= pPlayer.tbPlayerEvent;
	local tbEvent	= tbPlayerEvent[szEvent];
	if (not tbEvent) then
		tbEvent	= {};
		tbPlayerEvent[szEvent]	= tbEvent;
	end;
	local nRegisterId	= #tbEvent + 1;
	tbEvent[nRegisterId]= {varCallBack, varSelfParam};
	return nRegisterId;
end;

-- 注销特定玩家事件回调
function PlayerEvent:UnRegister(pPlayer, szEvent, nRegisterId)
	local tbPlayerEvent	= pPlayer.tbPlayerEvent;
	if (not tbPlayerEvent) then
		return;
	end;
	local tbEvent	= tbPlayerEvent[szEvent];
	if (not tbEvent or not tbEvent[nRegisterId]) then
		return;
	end
	tbEvent[nRegisterId]	= nil;
	return 1;
end;

-- 注册全局玩家事件回调
function PlayerEvent:RegisterGlobal(szEvent, varCallBack, varSelfParam)
	local tbEvent	= self.tbGlobalEvent[szEvent];
	if (not tbEvent) then
		tbEvent	= {};
		self.tbGlobalEvent[szEvent]	= tbEvent;
	end;
	local nRegisterId	= #tbEvent + 1;
	tbEvent[nRegisterId]= {varCallBack, varSelfParam};
	return nRegisterId;
end;

-- 注销全局玩家事件回调
function PlayerEvent:UnRegisterGlobal(szEvent, nRegisterId)
	local tbEvent	= self.tbGlobalEvent[szEvent];
	if (not tbEvent or not tbEvent[nRegisterId]) then
		return;
	end;
	tbEvent[nRegisterId]	= nil;
	return 1;
end;

-- 被系统调用，某事件发生
function PlayerEvent:OnEvent(szEvent, ...)
	local arg = { ... };
	local nTiggerCount = 0;
	
	-- 先检查全局注册回调
	local nRet = self:_CallBack(self.tbGlobalEvent[szEvent], arg);
	if (nRet) then
		nTiggerCount = nTiggerCount + nRet;
	end
	
	-- 然后检查本玩家注册回调
	local tbPlayerEvent	= me.tbPlayerEvent;
	if (tbPlayerEvent) then
		nRet = self:_CallBack(tbPlayerEvent[szEvent], arg);
		if (nRet) then
			nTiggerCount = nTiggerCount + nRet;
		end
	end

	return nTiggerCount;
end

function PlayerEvent:_CallBack(tbEvent, tbArg)
	if (not tbEvent) then
		return 0;
	end
	local nTiggerCount = 0;
	--为了防止循环中出现新注册导致出错，采用Copy方式
	for nRegisterId, tbCallFunc in pairs(Lib:CopyTB1(tbEvent)) do
		if (tbEvent[nRegisterId]) then	-- 检测是否未被删除
			local varCallBack	= tbCallFunc[1];
			local varSelfParam	= tbCallFunc[2];
			local tbCallBack	= nil;
			if (varSelfParam) then
				tbCallBack	= {varCallBack, varSelfParam, unpack(tbArg)};
			else
				tbCallBack	= {varCallBack, unpack(tbArg)};
			end
			local bRet, nRet = Lib:CallBack(tbCallBack);
			if (bRet and type(nRet) == "number" and nRet == 1) then
				nTiggerCount = nTiggerCount + 1;
			end
		end
	end
	return nTiggerCount;
end

