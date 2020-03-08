local tbItem = Item:GetClass("NewYearJiangQuan");
tbItem.szNewYearOverdue = "2019-2-9-22-00-00"               -- 新年奖券过期时间
tbItem.nNewYearJianQuanItemId = 3689
tbItem.nUseLevel = 1
function tbItem:OnUse(it)
	if not ChouJiang.bOpen then
		me.CenterMsg("暂不开放抽奖", true)
		return
	end
	if not it.dwTemplateId then
		return 
	end
	
	if self:CheckOverdue() then
		me.CenterMsg("道具已经过期", true)
		return 1
	end

	if me.nLevel < self.nUseLevel then
		me.CenterMsg(string.format("%d级才可使用", self.nUseLevel), true)
		return
	end	

	local bInProcess = Activity:__IsActInProcessByType("ChouJiang")
	if not bInProcess then
		me.CenterMsg("活动已经结束", true)
		return
	end

	Activity:OnPlayerEvent(me, "Act_OnUseNewYearJiangQuan")
end

function tbItem:GetOverdueTime()
	local tbTime = Lib:SplitStr(self.szNewYearOverdue, "-")
	local year, month, day, hour, minute, second = unpack(tbTime)
	return os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second)})
end

function tbItem:CheckOverdue()
	local nNowTime = GetTime()
	local nOverdueTime = self:GetOverdueTime()
	return nNowTime >= nOverdueTime
end

function tbItem:GetTip()
	local szTips = ""
	local tbTime = Lib:SplitStr(self.szNewYearOverdue, "-")
	local year, month, day, hour = unpack(tbTime)
	local szOverdue = self:CheckOverdue() and "(已过期)" or ""
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang.tbActInfo.nStartTime)
	local tbTime = Lib:SplitStr(ChouJiang.szDayTime, ":")
	local szExeDate = ChouJiang.tbDayLotteryDate[nLastExeDay] and string.format("抽奖时间:%s%s时", ChouJiang.tbDayLotteryDate[nLastExeDay], tbTime[1] or "-") or ""
	szTips = szTips ..string.format("过期时间:%s月%s日%s时%s\n%s", month, day, hour, szOverdue, szExeDate)
	return szTips
end

function tbItem:GetIntrol()
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang.tbActInfo.nStartTime)
	local szExeDate = ChouJiang.tbDayLotteryDate[nLastExeDay] and string.format("%s",ChouJiang.tbDayLotteryDate[nLastExeDay]) or ""
	return string.format("使用后参与[FFFE0D]%s[-]抽奖，同时还将获得[FFFE0D]2月19日元宵抽大奖[-]的机会，点击[FFFE0D]预览[-]可以前去查看奖励内容。", szExeDate)
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local fnPreview = function ()
		Ui:OpenWindow("NewInformationPanel", ChouJiang.szOpenNewInfomationKey)
		Ui:CloseWindow("ItemTips")
    end
	return {szFirstName = "预览", fnFirst = fnPreview, szSecondName = "使用", fnSecond = "UseItem"};
end