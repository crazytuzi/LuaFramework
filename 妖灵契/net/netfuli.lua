module(..., package.seeall)

--GS2C--

function GS2CFuliReddot(pbdata)
	local flag = pbdata.flag
	local cday = pbdata.cday
	--todo
	g_WelfareCtrl:OnReceiveSecondTest(flag, cday)
end

function GS2CHistoryCharge(pbdata)
	local degree = pbdata.degree
	local getlist = pbdata.getlist
	--todo
	g_WelfareCtrl:OnHistoryRecharge(degree, getlist)
end

function GS2CBackPartnerInfo(pbdata)
	local sid = pbdata.sid --当前返回
	local star = pbdata.star --星级
	local list = pbdata.list --可设置列表
	--todo
	g_WelfareCtrl:OnBackPartnerInfo(sid, list, star)
end

function GS2CSetBackResult(pbdata)
	--todo
	g_WelfareCtrl:OnEvent(define.Welfare.Event.OnSetBackPartner)
end

function GS2CFirstChargeUI(pbdata)
	local bOpen = pbdata.bOpen --false-关闭 true-打开
	local bReceive = pbdata.bReceive --false-不可领取 true-可领取
	--todo
	g_WelfareCtrl:SetFirstCharge(bOpen, bReceive)
end

function GS2CRefreshRewardBack(pbdata)
	local info = pbdata.info
	--todo
	g_WelfareCtrl:OnReceiveRefreshRewardBack(info)
end

function GS2CFuliPointUI(pbdata)
	local point = pbdata.point --福利积分
	local info = pbdata.info
	local version = pbdata.version
	local plan = pbdata.plan
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	--todo
	CLimitRewardView:UpdateCostPoint(point, info, version, plan, starttime, endtime)
end

function GS2CLuckDrawUI(pbdata)
	local cnt = pbdata.cnt --可抽奖次数
	local idxlist = pbdata.idxlist
	local cost = pbdata.cost
	--todo
	CLimitRewardView:UpdateDrawData(cnt, idxlist, cost)
end

function GS2CLuckDrawPos(pbdata)
	local pos = pbdata.pos
	local cnt = pbdata.cnt --可抽奖次数
	local cost = pbdata.cost
	--todo
	CLimitRewardView:UpdateDrawResult(pos, cnt, cost)
	g_WelfareCtrl:UpdateDrawCnt(cnt)
end

function GS2CCrazyHappyUI(pbdata)
	local bOpen = pbdata.bOpen --false-关闭 true-打开
	--todo
end

function GS2CFuliPoint(pbdata)
	local point = pbdata.point
	--todo
	g_WelfareCtrl:UpdateCostPoint(point)
end

function GS2CFuliTime(pbdata)
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	--todo
	g_WelfareCtrl:UpdateCostScoreTime(starttime, endtime)
end

function GS2CLuckDrawCnt(pbdata)
	local cnt = pbdata.cnt --可抽奖次数
	--todo
	g_WelfareCtrl:UpdateDrawCnt(cnt)
end

function GS2CChargeBackUI(pbdata)
	local rmb = pbdata.rmb
	local month = pbdata.month --月卡数量
	local zsk = pbdata.zsk --是否终身卡
	local fund = pbdata.fund --是否购买成长基金
	local gradegift = pbdata.gradegift --是否购买等级礼包
	local onermb = pbdata.onermb --是否购买一元礼包
	local special = pbdata.special --是否购买每日特权礼包
	--todo
	g_WelfareCtrl:UpdateRechargeWelfare(rmb, month, zsk, fund, gradegift, onermb, special)
end


--C2GS--

function C2GSChargeReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fuli", "C2GSChargeReward", t)
end

function C2GSSetBackPartner(sid, star)
	local t = {
		sid = sid,
		star = star,
	}
	g_NetCtrl:Send("fuli", "C2GSSetBackPartner", t)
end

function C2GSGetBackPartnerInfo()
	local t = {
	}
	g_NetCtrl:Send("fuli", "C2GSGetBackPartnerInfo", t)
end

function C2GSGetRewardBack(sid, vip)
	local t = {
		sid = sid,
		vip = vip,
	}
	g_NetCtrl:Send("fuli", "C2GSGetRewardBack", t)
end

function C2GSGetFuliPointInfo()
	local t = {
	}
	g_NetCtrl:Send("fuli", "C2GSGetFuliPointInfo", t)
end

function C2GSBuyFuliPointItem(id, amount, version)
	local t = {
		id = id,
		amount = amount,
		version = version,
	}
	g_NetCtrl:Send("fuli", "C2GSBuyFuliPointItem", t)
end

function C2GSGetLuckDrawInfo()
	local t = {
	}
	g_NetCtrl:Send("fuli", "C2GSGetLuckDrawInfo", t)
end

function C2GSStartLuckDraw(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("fuli", "C2GSStartLuckDraw", t)
end

function C2GSGiveLuckDraw()
	local t = {
	}
	g_NetCtrl:Send("fuli", "C2GSGiveLuckDraw", t)
end

function C2GSReceiveFirstCharge()
	local t = {
	}
	g_NetCtrl:Send("fuli", "C2GSReceiveFirstCharge", t)
end

function C2GSRedeemcode(code)
	local t = {
		code = code,
	}
	g_NetCtrl:Send("fuli", "C2GSRedeemcode", t)
end

function C2GSOpenChargeBackUI()
	local t = {
	}
	g_NetCtrl:Send("fuli", "C2GSOpenChargeBackUI", t)
end

