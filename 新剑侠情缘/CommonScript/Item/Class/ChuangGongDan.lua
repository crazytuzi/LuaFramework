local tbItem = Item:GetClass("ChuangGongDan");

local nChuangGongDanUseResetTime = 4 * 60 * 60    -- 传功丹每天使用次数的重置时间点

local nAddChuangGongTimes = 1 					 -- 使用之后增加的被传次数
local nAddChuangGongSendTimes = 1 				 -- 使用之后增加的传功次数

tbItem.nItemId = 2759

---------------上面策划配

function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return 
	end

	local bRet, szMsg = self:CheckUse(me)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end

	local nAddChuangGong = 0
	local nAddChuangGongSend = 0

	local _, _, nChuangGongDan = ChuangGong:GetDegree(me, "ChuangGong")
	local _, _, nChuangGongSendDan = ChuangGong:GetDegree(me, "ChuangGongSend")

	nAddChuangGong = nAddChuangGongTimes - nChuangGongDan
	nAddChuangGongSend = nAddChuangGongSendTimes - nChuangGongSendDan

	me.SetUserValue(ChuangGong.SAVE_GROUP, ChuangGong.KEY_USE_CHUANGGONGDAN_TIME, GetTime());
	
	szMsg = ""
	if nAddChuangGongSend > 0 then
		me.SetUserValue(ChuangGong.SAVE_GROUP, ChuangGong.KEY_EXTRA_CHUANGGONGSEND, nAddChuangGongSend + nChuangGongSendDan);
		szMsg = szMsg ..XT(string.format("增加了[FFFE0D]%d次[-]传功次数", nAddChuangGongSend))
	end
	if nAddChuangGong > 0 then
		me.SetUserValue(ChuangGong.SAVE_GROUP, ChuangGong.KEY_EXTRA_CHUANGGONG, nAddChuangGong + nChuangGongDan);
		if nAddChuangGongSend > 0 then
			szMsg = szMsg ..","
		end
		szMsg = szMsg ..XT(string.format("增加了[FFFE0D]%d次[-]被传功次数", nAddChuangGong))
	end

	me.CenterMsg(szMsg)
	Log("[ChuangGongDan] Use ", me.szName, me.dwID, nAddChuangGong, nAddChuangGongSend, nChuangGongDan, nChuangGongSendDan)
	return 1
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {szFirstName = "使用", fnFirst = "UseChuangGongDan"};
end

function tbItem:UseChuangGongDan(nItemId)
	local _, _, nChuangGongDan = ChuangGong:GetDegree(me, "ChuangGong")
	local _, _, nChuangGongSendDan = ChuangGong:GetDegree(me, "ChuangGongSend")

	local nAddChuangGong = nAddChuangGongTimes - nChuangGongDan
	local nAddChuangGongSend = nAddChuangGongSendTimes - nChuangGongSendDan

	local bTip = false
	local szMsgTip = ""

	if nChuangGongSendDan > 0 and nChuangGongDan <= 0 then
		bTip = true
		szMsgTip = string.format("[FFFE0D]传功丹所增加的传功次数已达上限[-]\n使用后增加[FFFE0D]%d次[-]被传功次数", nAddChuangGong)
	elseif nChuangGongDan > 0 and nChuangGongSendDan <= 0 then
		bTip = true
		szMsgTip = string.format("[FFFE0D]传功丹所增加的被传功次数已达上限[-]\n使用后增加[FFFE0D]%d次[-]传功次数", nAddChuangGongSend)
	end

	local fnUse = function (nItemId)
		RemoteServer.UseItem(nItemId);
	end

	if bTip then
		me.MsgBox(szMsgTip,
		{
			{"确定使用", fnUse, nItemId},
			{"暂不使用"},
		})
	else
		RemoteServer.UseItem(nItemId);
	end
end

function tbItem:CheckUse(pPlayer)
	local nUseTime = ChuangGong:ChuangGongDanUseTime(pPlayer)
	local bIsCross = Lib:IsDiffDay(nChuangGongDanUseResetTime, nUseTime)
	if not bIsCross then
		return false, XT("少侠今日服用过传功丹了（次日4:00可用）")
	end

	local _, _, nChuangGongDan = ChuangGong:GetDegree(pPlayer, "ChuangGong")
	local _, _, nChuangGongSendDan = ChuangGong:GetDegree(pPlayer, "ChuangGongSend")
	if nChuangGongDan >= nAddChuangGongTimes and nChuangGongSendDan >= nAddChuangGongSendTimes then
		return false, XT("传功丹所增加的传功、被传次数已达上限，请先消耗后再使用")
	end

	return true
end

function tbItem:GetChuangGongDanUseResetTime()
	return nChuangGongDanUseResetTime
end

