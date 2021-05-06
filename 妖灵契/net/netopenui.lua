module(..., package.seeall)

--GS2C--

function GS2CLoadUI(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local type = pbdata.type --类型
	local tip = pbdata.tip --提示
	local time = pbdata.time --时间
	--todo
end

function GS2CPopTaskItem(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local taskid = pbdata.taskid --任务id
	--todo
	g_WindowTipCtrl:SetWindowCommitItem(sessionidx, taskid)
end

function GS2CShortWay(pbdata)
	local type = pbdata.type --1:金币,2:水晶,3:铜币,4:勋章,8:探索点,9:彩晶,10:体力
	--todo
	local idx = table.index({1,2,9,10}, type)
	if idx then
		g_WindowTipCtrl:ShowNoGoldTips(type)
	end
end

function GS2CConfirmUI(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local sContent = pbdata.sContent --弹框内容
	local sConfirm = pbdata.sConfirm --确认按钮内容
	local sCancle = pbdata.sCancle --取消按钮内容
	local time = pbdata.time --默认按钮时间,单位为秒
	local default = pbdata.default --默认按钮内容, 1-sConfirm 0-sCancle
	local uitype = pbdata.uitype --UI顯示類型 0普通，1组队邀请,2历练,3社交,4.协同比武
	local simplerole = pbdata.simplerole --玩家名片信息
	local forceconfirm = pbdata.forceconfirm --点击空白区域是否关闭当前对话框，0 是 1 否
	local confirmtype = pbdata.confirmtype --確認類型，具體用於區分系統，部分系統帶取消提示下拉選項
	local relation = pbdata.relation --邀请者和自己的关系
	local point = pbdata.point --协同比武分数
	--todo
	if g_HouseCtrl:IsInHouse() or CConvoyView:GetView() or CEqualArenaPrepareView:GetView() then
		return
	end
	local windowConfirmInfo = {
		msg				= sContent,
		okCallback		= function ()
			netother.C2GSCallback(sessionidx, 1)		--1代表同意
		end,
		cancelCallback  = function()
			netother.C2GSCallback(sessionidx, 0)
		end,
		thirdCallback	= function(msg, time)
			netother.C2GSCallback(sessionidx, 0, nil, msg, time)
		end,
		okStr			= sConfirm,
		cancelStr		= sCancle,
		countdown       = time,
		default         = default,
		uiType 			= pbdata.uitype,
		simpleRole      = pbdata.simplerole,
		forceConfirm   	= pbdata.forceconfirm,
		confirmtype 	= pbdata.confirmtype,
		relation		= pbdata.relation,
		point = point,
	}
	
	if not CGuideView:GetView() then
		if uitype == 1 or uitype == 4 then
			g_WindowTipCtrl:SetTeamInviteConfirm(windowConfirmInfo)
		elseif uitype == 2 then
			CDailyCultivateMainView:ShowView(function (oView)
				oView:SetContent(sessionidx)
			end)
		elseif uitype == 3 then
			if g_ChapterFuBenCtrl:IsInChapterFuBen() then
				netother.C2GSCallback(sessionidx, 0)
				return
			end
			g_WindowTipCtrl:SetTeamInviteConfirm(windowConfirmInfo)
		elseif uitype == 5 then
			windowConfirmInfo.title = "情侣关系解除申请"
			CExpressTipsView:ShowView(function (oView)
				oView:SetWindowConfirm(windowConfirmInfo)
			end)
		else
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end
	end
end

function GS2CShowOpenBtn(pbdata)
	local taskid = pbdata.taskid
	local sessionidx = pbdata.sessionidx
	--todo
	if g_DialogueCtrl:CheckLastOpenBtn(taskid) then
		local oTask = g_TaskCtrl:GetTaskById(taskid)
		if oTask then
			local taskType = oTask:GetValue("tasktype")
			if taskType == define.Task.TaskType.TASK_SLIP then
				CTaskSlipMoveView:ShowView(function (oView)
					oView:SetData(taskid, sessionidx)
				end)
			elseif taskType == define.Task.TaskType.TASK_PATROL then
				
			else
				g_WindowTipCtrl:SetWindowTaskProgress(taskid, sessionidx)
			end
		end
	end	
end

function GS2CSchedule(pbdata)
	local activepoint = pbdata.activepoint --活跃点
	local rewardidx = pbdata.rewardidx --已奖励活跃
	local schlist = pbdata.schlist --新加的日程状态列表
	local open_day = pbdata.open_day --开服天数
	--todo
	g_ScheduleCtrl:InitSchedule(activepoint, rewardidx, schlist, open_day)
end

function GS2CLoginSchedule(pbdata)
	local activepoint = pbdata.activepoint --活跃点
	local rewardidx = pbdata.rewardidx --已奖励活跃
	local day_task = pbdata.day_task
	--todo
	g_ScheduleCtrl:LoginScheduleReward(activepoint, rewardidx, day_task)
end

function GS2CRefreshSchedule(pbdata)
	local activepoint = pbdata.activepoint
	local schstate = pbdata.schstate
	--todo
	g_ScheduleCtrl:RefreshSchedule(activepoint, schstate)
end

function GS2COpenScheuleUI(pbdata)
	local scheduleid = pbdata.scheduleid
	--todo
	g_ScheduleCtrl:SetPopupSchedule(scheduleid)
end

function GS2CCloseScheuleUI(pbdata)
	local scheduleid = pbdata.scheduleid
	--todo
	g_ScheduleCtrl:SetPopupSchedule(scheduleid, true)
end

function GS2CGetScheduleReward(pbdata)
	local rewardidx = pbdata.rewardidx --每一位表示哪个将来被领取
	--todo
	g_ScheduleCtrl:SetRewardIdx(rewardidx)
end

function GS2COpenView(pbdata)
	local vid = pbdata.vid
	--todo
	g_OpenUICtrl:OpenUI(vid)
end

function GS2COpenShop(pbdata)
	local shop_id = pbdata.shop_id --商城id
	--todo
	g_NpcShopCtrl:OpenShop(shop_id)
end

function GS2CXunLuo(pbdata)
	local type = pbdata.type --1:开始,0:结束
	--todo
	g_MapCtrl:SetPatrol(type == 1, type == 1)
end

function GS2COpenCultivateUI(pbdata)
	--todo
	CSkillMainView:ShowView(function(oView)
		oView:ShowCultivatePart()
	end)
end

function GS2CCloseConfirmUI(pbdata)
	local sessionidx = pbdata.sessionidx
	--todo
	local oView = CItemTipsConfirmWindowView:GetView()
	if oView then
		oView:OnClose()
	end
end

function GS2CItemShortWay(pbdata)
	local item = pbdata.item --item_sid
	--todo
	CItemTipsSimpleInfoView:ShowView(function (oView)
		oView:SetInitBox(item, nil, {showQuickBuy = true})
		oView:ForceShowFindWayBox(true)
	end)
end

function GS2COpenLotteryUI(pbdata)
	local totaltimes = pbdata.totaltimes
	local lotteryitem = pbdata.lotteryitem
	--todo
end

function GS2CNewDay(pbdata)
	--todo
	g_ScheduleCtrl:UpdateDay()
	g_AttrCtrl:UpdateDay()
	g_OrgCtrl:UpdateDay()
	g_WelfareCtrl:UpdateDay()
end

function GS2CShowItem(pbdata)
	local item_list = pbdata.item_list
	--todo
	g_WindowTipCtrl:SetWindowAllItemRewardList(item_list)
end

function GS2CCloseWarResultUI(pbdata)
	--todo
	print("协议关闭战斗结算界面")
	CWarResultView:CloseView()
end

function GS2CHongBaoUI(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local sContent = pbdata.sContent --弹框内容
	--todo
	local windowConfirmInfo = {
		msg = "请选择要发放的频道",
		title = "发红包",
		cancelStr = "公会频道",
		okStr = "世界频道",
		noCancelCbTouchOut = true,
		okCallback		= function ()
			netother.C2GSCallback(sessionidx, 2)
		end,
		cancelCallback  = function()
			netother.C2GSCallback(sessionidx, 1)
		end,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function GS2CTeamEnterGameUI(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local msg = pbdata.msg --询问语
	local mem = pbdata.mem
	local stype = pbdata.stype --玩法描述　yjfuben-梦魇
	local timeout = pbdata.timeout
	--todo
	CTeamConfirmView:ShowView(function (oView)
		oView:SetData(msg, mem, stype, timeout)
		oView:SetSessionidx(sessionidx)
	end)
end

function GS2CUpdateTeamEnterGameUI(pbdata)
	local msg = pbdata.msg --询问语
	local mem = pbdata.mem
	local stype = pbdata.stype --玩法描述　yjfuben-梦魇
	--todo
	local oView = CTeamConfirmView:GetView()
	if oView then
		oView:UpdateData(msg, mem, stype, timeout)
	end
end

function GS2CTeamEnterGameUIClose(pbdata)
	--todo
	CTeamConfirmView:CloseView()
end


--C2GS--

function C2GSOpenScheduleUI()
	local t = {
	}
	g_NetCtrl:Send("openui", "C2GSOpenScheduleUI", t)
end

function C2GSScheduleReward(rewardidx)
	local t = {
		rewardidx = rewardidx,
	}
	g_NetCtrl:Send("openui", "C2GSScheduleReward", t)
end

function C2GSClickSchedule(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("openui", "C2GSClickSchedule", t)
end

function C2GSOpenInterface(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("openui", "C2GSOpenInterface", t)
end

function C2GSCloseInterface(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("openui", "C2GSCloseInterface", t)
end

function C2GSEditBattlCommand(idx, cmd)
	local t = {
		idx = idx,
		cmd = cmd,
	}
	g_NetCtrl:Send("openui", "C2GSEditBattlCommand", t)
end

