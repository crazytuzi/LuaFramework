local self;
function _LuaPlayer.CallClientScript(...)
	self = self;
	KPlayer.CallClientScript(...);
end

function _LuaPlayer.Msg(szMsg, nSenderId)
	self = self;
	nSenderId = nSenderId or ChatMgr.SystemMsgType.Tip;
	ChatMgr:OnChannelMessage(ChatMgr.ChannelType.System, nSenderId, "", 0, 0, 0, szMsg);
end

function _LuaPlayer.BuyTimes(szType, nBuyMinCount)
	nBuyMinCount = nBuyMinCount or 5;
	local tbBuyInfo = DegreeCtrl:GetBuyCountInfo(szType)
	local nBuyDegree = DegreeCtrl:GetDegree(self, tbBuyInfo[1])
	if nBuyDegree <= 0 then
		--如果下个vip等级有可以增加的次数，则提示中屏幕提示一下
		local nNextVipLevel = DegreeCtrl:GetNextVipDegree(tbBuyInfo[1], self)
		if nNextVipLevel then
			local fnConfirm = function ()
				Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
			end;
			Ui:OpenWindow("MessageBox",
						  string.format("次数耗尽，[FFFE0D] 【剑侠尊享%d】 [-]可增加更多购买次数，还有[FFFE0D] 超多福利[-]，是否前往？", nNextVipLevel),
						 { {fnConfirm},{} },
						 {"前往", "取消"});

		else
			self.CenterMsg("今天次数已用完")
		end
		return
	end
	local nBuyCount = math.min(nBuyMinCount, nBuyDegree); --一次买5次
	local szBuyDegree, szMoneyType, nCost = DegreeCtrl:BuyCountCostPrice(self, szType, nBuyCount)
	local szMoneyName, szMoneyEmotion = Shop:GetMoneyName(szMoneyType)
	local szCostDesc =  nCost .. szMoneyName

	local fnConfirmBuy = function ()
		if self.GetMoney(szMoneyType) < nCost then
			self.CenterMsg(string.format("您不足%s", szCostDesc) )
			if szMoneyType == "Gold" then
				Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
			end
		end
		RemoteServer.BuyCount(szType, nBuyCount)
	end

	Ui:OpenWindow("MessageBox", string.format("次数不足，确定花费 [FFFFFF]%d[-] %s 购买%d次次数吗",  nCost, szMoneyEmotion, nBuyCount),
		{ {fnConfirmBuy}, {}  }, {"确定", "取消"})
end

function _LuaPlayer.DoChangeActionMode(nActMode)
	self.ChangeActionMode(nActMode);
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ACTION_MODE, nActMode);
end

function _LuaPlayer.BuyTimesSuccess(szMsg)
	self.CenterMsg(szMsg or "购买次数成功")
	UiNotify.OnNotify(UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS)
end


function _LuaPlayer.TrueChangeExp(nCurAddExp, bNotLevel)
	local nPlayerExp = self.GetExp();
    local nPlayerNextLevelExp = self.GetNextLevelExp();
    local nPlayerLevel = self.nLevel;
	local nChangeExp = nCurAddExp;
	local nNewExp = nPlayerExp + nChangeExp;
	local nMaxPlayerLevel = Player:GetPlayerMaxLeve(); --服务端不要用这个接口 频繁调用有性能问题 服务端有特殊的接口用
	if (nChangeExp > 0 and nPlayerLevel >= nMaxPlayerLevel and nNewExp >= nPlayerNextLevelExp) and not bNotLevel then
		if (nPlayerExp >= nPlayerNextLevelExp) then
			nChangeExp = nCurAddExp / 2;
		else
			local nExtResidue = nNewExp - nPlayerNextLevelExp;
			nChangeExp = nCurAddExp - nExtResidue + nExtResidue / 2;
		end

	end

	local nPlayerExpP = nChangeExp;
	nChangeExp = self.PlayerLevelExpP(nPlayerExpP);
	nChangeExp = math.floor(nChangeExp);
	return nChangeExp;
end

function _LuaPlayer.PlayerLevelExpP(nCurAddExp)
	local nPlayerExp = self.GetExp();
    local nPlayerNextLevelExp = self.GetNextLevelExp();
    if nPlayerExp >= nPlayerNextLevelExp or nCurAddExp <= 0 then
    	return nCurAddExp;
    end

    local tbLevelInfo = Npc:GetPlayerLevelAddExpP(); --服务端不要用这个接口 频繁调用有性能问题 服务端有特殊的接口用
    if not tbLevelInfo then
    	return nCurAddExp;
    end

	local nRetExp = 0;
	local nChangeExp = nCurAddExp;
	local nLevelExp = nPlayerExp;
	local nNextLevelExp = nPlayerNextLevelExp;
	local nPlayerLevel = self.nLevel;
	local nNewExp = 0;
	local bRetCode = true;
	while(bRetCode) do
		local nAddExpP = tbLevelInfo[nPlayerLevel] or 0;
		local nAddExp = math.floor(nChangeExp * nAddExpP / 100);
		nNewExp = nLevelExp + nAddExp;
		if (nNewExp <= nNextLevelExp) then
			nRetExp = nRetExp + nAddExp;
			bRetCode = false;
		else
			local nNeedExp = nNextLevelExp - nLevelExp;
			nRetExp = nRetExp + nNeedExp;
			local nTrueNeedExp =  math.floor(nNeedExp * 100 / nAddExpP);
			nLevelExp = 0;
			nPlayerLevel = nPlayerLevel + 1;
			nChangeExp = nChangeExp - nTrueNeedExp;

			local  tbNewPlayerSet = KPlayer.GetPlayerLevelSet(nPlayerLevel);
			if tbNewPlayerSet then
				nNextLevelExp = tbNewPlayerSet.nExpUpGrade;
				bRetCode = true;
			else
				nRetExp = nRetExp + nChangeExp;
				bRetCode = false;
			end

		end
	end

	nRetExp = math.floor(nRetExp);
	return nRetExp;
end

function _LuaPlayer.GetFightPower()
	local pNpc = self.GetNpc();
    if not pNpc then
        return 0;
    end
    return pNpc.GetFightPower()
end

function _LuaPlayer.IsInGuaJiMap()
	local nMapTemplateId = self.nMapTemplateId

	local szMapClass = Map:GetClassDesc(nMapTemplateId)

	return szMapClass=="fight" or ImperialTomb:IsTombMap(nMapTemplateId) or Map.tbCustomAutoFightRadius[nMapTemplateId]
end

function _LuaPlayer.SetPkMode(nMode, nCustom)
	nCustom = nCustom or 0;
	local pNpc = self.GetNpc();
	pNpc.SetPkMode(nMode, nCustom)
end
