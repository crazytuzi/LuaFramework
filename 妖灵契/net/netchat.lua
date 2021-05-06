module(..., package.seeall)

--GS2C--

function GS2CChat(pbdata)
	local cmd = pbdata.cmd
	local type = pbdata.type --1-world
	local role_info = pbdata.role_info --pid=0, 表示系统发
	--todo
	local dMsg = {
		channel = type,
		text = cmd,
	}
	if role_info.pid ~= 0 then
		dMsg.role_info = role_info
	end
	g_ChatCtrl:AddMsg(dMsg)
end

function GS2CSysChat(pbdata)
	local tag_type = pbdata.tag_type --0-公告，1-传闻，2-帮助
	local content = pbdata.content
	local horse_race = pbdata.horse_race --1-跑马，0-不跑
	local grade = pbdata.grade --可见等级,0为默认全部可见,否则为最低可见等级
	--todo
	local type2channel = {
		[0] = define.Channel.Bulletin,
		[1] = define.Channel.Rumour,
		[2] = define.Channel.Help,
	}
	-- horse_race = 1
	local dMsg = {
		channel = type2channel[tag_type],
		text = content,
		horse_race = horse_race, 
	}
	if g_AttrCtrl.grade < grade then
		return
	end
	g_ChatCtrl:AddMsg(dMsg)
end

function GS2CConsumeMsg(pbdata)
	local type = pbdata.type --消息-6
	local content = pbdata.content
	--todo
	local dMsg = {
		channel = define.Channel.Message,
		text = content,
	}
	g_ChatCtrl:AddMsg(dMsg)
end

function GS2CHongBaoInfo(pbdata)
	local shape = pbdata.shape --开启红包玩家shape
	local title = pbdata.title --红包标题
	local amount = pbdata.amount --红包总个数
	local remain_gold = pbdata.remain_gold --剩余金币
	local draw_list = pbdata.draw_list --领取信息
	local end_time = pbdata.end_time --到期时间
	--todo
	COrgRedBagView:ShowView(function (oView)
		oView:SetType("chat")
		oView:RefreshDetail(pbdata)
	end)
end

function GS2CPlayerHBInfo(pbdata)
	local idx = pbdata.idx
	local shape = pbdata.shape
	local pid = pbdata.pid
	local gold = pbdata.gold
	local title = pbdata.title
	--todo
	COrgRedBagView:ShowView(function (oView)
		oView:SetType("chat")
		oView:RefreshGet(pbdata)
	end)
end

function GS2CReportResult(pbdata)
	local bsuc = pbdata.bsuc
	--todo
	if bsuc then
		CReportView:CloseView()
	end
end


--C2GS--

function C2GSChat(cmd, type, extraargs)
	local t = {
		cmd = cmd,
		type = type,
		extraargs = extraargs,
	}
	g_NetCtrl:Send("chat", "C2GSChat", t)
end

function C2GSHongBaoOption(action, id)
	local t = {
		action = action,
		id = id,
	}
	g_NetCtrl:Send("chat", "C2GSHongBaoOption", t)
end

function C2GSReportPlayer(target, reason, other)
	local t = {
		target = target,
		reason = reason,
		other = other,
	}
	g_NetCtrl:Send("chat", "C2GSReportPlayer", t)
end

