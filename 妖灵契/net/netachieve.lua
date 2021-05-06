module(..., package.seeall)

--GS2C--

function GS2CAchieveMain(pbdata)
	local directions = pbdata.directions --成就大类信息
	local cur_point = pbdata.cur_point --总成就当前进度
	local already_get = pbdata.already_get --已领取成就点数编号
	--todo
	g_AchieveCtrl:OpenAchieveMain(directions, cur_point, already_get)
end

function GS2CAchieveDirection(pbdata)
	local id = pbdata.id --成就大类id
	local belong = pbdata.belong --归属id
	local achlist = pbdata.achlist --成就详细信息
	--todo
	g_AchieveCtrl:OpenAchieveDirection(id, belong, achlist)
end

function GS2CAchieveRedDot(pbdata)
	local infolist = pbdata.infolist --红点信息列表
	--todo
	g_AchieveCtrl:SetAchieveRedDot(infolist)
end

function GS2CAchieveDone(pbdata)
	local id = pbdata.id --成就id
	local pop = pbdata.pop --是否弹出Tips
	--todo
	g_AchieveCtrl:AchieveDone(pbdata)
end

function GS2CAchieveDegree(pbdata)
	local info = pbdata.info --成就信息
	--todo
	g_AchieveCtrl:AchieveDegree(info)
end

function GS2CPictureDegree(pbdata)
	local info = pbdata.info
	--todo
	g_MapBookCtrl:UpdateWorldData(info)
end

function GS2CPictureRedDot(pbdata)
	--todo
	g_MapBookCtrl:UpdateWorldRedDot()
end

function GS2CPictureInfo(pbdata)
	local info = pbdata.info
	local ui_opened = pbdata.ui_opened --1为打开过，0为没打开过
	--todo
	g_MapBookCtrl:InitWorldData(info)
	g_MapBookCtrl:SetWorldOpen(ui_opened)
	CWorldMapBookView:ShowView()
end

function GS2CSevenDayMain(pbdata)
	local cur_point = pbdata.cur_point --总成就点
	local already_get = pbdata.already_get --已领取成就点数编号
	local end_time = pbdata.end_time --活动结束时间
	local server_day = pbdata.server_day --开服务天数
	--todo
	g_WelfareCtrl:OnReceiveSevenDayMain(cur_point, already_get, server_day)
end

function GS2CSevenDayDegree(pbdata)
	local info = pbdata.info --成就信息
	--todo
	g_WelfareCtrl:OnReceiveSevenDayDegree(info)
end

function GS2CSevenDayRedDot(pbdata)
	local days = pbdata.days --有红点天数
	--todo
	g_WelfareCtrl:OnReceiveSevenDayRedDot(days)
end

function GS2CSevenDayInfo(pbdata)
	local day = pbdata.day --打开某天成就
	local achlist = pbdata.achlist --当天成就信息
	--todo
	g_WelfareCtrl:OnReceiveSevenDayInfo(day, achlist)
end

function GS2CSevenDayBuy(pbdata)
	local already_buy = pbdata.already_buy --已购买成礼包天数
	--todo
	g_WelfareCtrl:OnReceiveSevenDayBuy(already_buy)
end


--C2GS--

function C2GSAchieveMain()
	local t = {
	}
	g_NetCtrl:Send("achieve", "C2GSAchieveMain", t)
end

function C2GSAchieveDirection(id, belong)
	local t = {
		id = id,
		belong = belong,
	}
	g_NetCtrl:Send("achieve", "C2GSAchieveDirection", t)
end

function C2GSAchieveReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("achieve", "C2GSAchieveReward", t)
end

function C2GSAchievePointReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("achieve", "C2GSAchievePointReward", t)
end

function C2GSPictureReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("achieve", "C2GSPictureReward", t)
end

function C2GSOpenPicture()
	local t = {
	}
	g_NetCtrl:Send("achieve", "C2GSOpenPicture", t)
end

function C2GSCloseMainUI()
	local t = {
	}
	g_NetCtrl:Send("achieve", "C2GSCloseMainUI", t)
end

function C2GSOpenSevenDayMain(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("achieve", "C2GSOpenSevenDayMain", t)
end

function C2GSOpenSevenDay(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("achieve", "C2GSOpenSevenDay", t)
end

function C2GSSevenDayReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("achieve", "C2GSSevenDayReward", t)
end

function C2GSSevenDayPointReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("achieve", "C2GSSevenDayPointReward", t)
end

function C2GSBuySevenDayGift(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("achieve", "C2GSBuySevenDayGift", t)
end

