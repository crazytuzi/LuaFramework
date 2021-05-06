module(..., package.seeall)

--GS2C--

function GS2CLoginTask(pbdata)
	local taskdata = pbdata.taskdata
	local shimen_status = pbdata.shimen_status
	--todo
	g_TaskCtrl:GS2CLoginTask(taskdata, shimen_status)
end

function GS2CAddTask(pbdata)
	local taskdata = pbdata.taskdata
	--todo
	g_TaskCtrl:GS2CAddTask(taskdata)
end

function GS2CDelTask(pbdata)
	local taskid = pbdata.taskid
	local done = pbdata.done
	--todo
	g_TaskCtrl:GS2CDelTask(taskid, done)
end

function GS2CDialog(pbdata)
	local sessionidx = pbdata.sessionidx --回调id,0不需要回调
	local dialog = pbdata.dialog --剧情对白列表
	local npc_name = pbdata.npc_name --当前npc名字
	local shape = pbdata.shape --当前npc外形
	local dialog_id = pbdata.dialog_id --劇情對白Id
	local npc_id = pbdata.npc_id
	local playboyinfo = pbdata.playboyinfo
	local rewards = pbdata.rewards --奖励id列表
	local task_big_type = pbdata.task_big_type
	local task_small_type = pbdata.task_small_type
	--todo
	--收到任务对话后，清除按钮标志
	g_DialogueCtrl:CacheTaskOpenBtn()
	g_DialogueCtrl:GS2CDialog(pbdata)
end

function GS2CRefreshTask(pbdata)
	local taskid = pbdata.taskid
	local target = pbdata.target --任务当前目标
	local name = pbdata.name --刷新名字
	local statusinfo = pbdata.statusinfo --刷新任务状态
	local accepttime = pbdata.accepttime
	local taskdata = pbdata.taskdata
	--todo
	g_TaskCtrl:GS2CRefreshTask(taskid, target, name, statusinfo, accepttime)
end

function GS2CRemoveTaskNpc(pbdata)
	local taskid = pbdata.taskid
	local npcid = pbdata.npcid
	local target = pbdata.target --任务目标
	--todo
	g_TaskCtrl:GS2CRemoveTaskNpc(npcid, taskid, target)
end

function GS2CRefreshTaskInfo(pbdata)
	local taskdata = pbdata.taskdata
	--todo
	g_TaskCtrl:GS2CRefreshTaskInfo(taskdata)
end

function GS2CContinueClickTask(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_TaskCtrl:CtrlGS2CContinueClickTask(taskid)
end

function GS2CSendTaskBarrage(pbdata)
	local barrage = pbdata.barrage
	local show_id = pbdata.show_id
	--todo
	g_TaskCtrl:CtrlGS2CSendTaskBarrage(barrage, show_id)
end

function GS2CRefreshPartnerTask(pbdata)
	local partnertask_progress = pbdata.partnertask_progress
	local refresh_id = pbdata.refresh_id --指定刷新某个伙伴的任务队列信息，则为1，全体刷新则为0，登陆的时候该字段发0
	--todo
	g_TaskCtrl:CtrlGS2CRefreshPartnerTask(partnertask_progress, refresh_id)
end

function GS2CAddAchieveTask(pbdata)
	local info = pbdata.info
	--todo
	g_TaskCtrl:CtrlGS2CAddAchieveTask(info)
end

function GS2CLoginAchieveTask(pbdata)
	local info = pbdata.info
	--todo
	printc("LoginAchieveTask")
	g_TaskCtrl:CtrlGS2CLoginAchieveTask(info)
end

function GS2CRefreshAchieveTask(pbdata)
	local info = pbdata.info
	--todo
	g_TaskCtrl:CtrlGS2CRefreshAchieveTask(info)
end

function GS2CDelAchieveTask(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_TaskCtrl:CtrlGS2CDelAchieveTask(taskid)
end

function GS2CStarPatrol(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_TaskCtrl:StartPatrolTask(taskid)
end

function GS2CUpdateShimenStatus(pbdata)
	local shimen_status = pbdata.shimen_status
	--todo
	g_TaskCtrl:CtrlGS2CUpdateShimenStatus(shimen_status)
end

function GS2CStartEscort(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_TaskCtrl:StartTraceNpc(taskid)
end

function GS2CFindTaskPath(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_TaskCtrl:CheckWalkingTask(true, taskid)
end

function GS2CRemoveTeamNpc(pbdata)
	local taskid = pbdata.taskid
	local npcid = pbdata.npcid
	local target = pbdata.target --任务目标
	--todo
	g_ActivityCtrl:CtrlGS2CRemoveTeamNpc(taskid, npcid, target)
end


--C2GS--

function C2GSClickTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSClickTask", t)
end

function C2GSTaskEvent(taskid, npcid)
	local t = {
		taskid = taskid,
		npcid = npcid,
	}
	g_NetCtrl:Send("task", "C2GSTaskEvent", t)
end

function C2GSCommitTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSCommitTask", t)
end

function C2GSAbandonTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSAbandonTask", t)
end

function C2GSAcceptTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSAcceptTask", t)
end

function C2GSTaskItemChange(change_info)
	local t = {
		change_info = change_info,
	}
	g_NetCtrl:Send("task", "C2GSTaskItemChange", t)
end

function C2GSClickTaskInScene(sceneid, taskid)
	local t = {
		sceneid = sceneid,
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSClickTaskInScene", t)
end

function C2GSGetTaskBarrage(showid)
	local t = {
		showid = showid,
	}
	g_NetCtrl:Send("task", "C2GSGetTaskBarrage", t)
end

function C2GSSetTaskBarrage(showid, msg)
	local t = {
		showid = showid,
		msg = msg,
	}
	g_NetCtrl:Send("task", "C2GSSetTaskBarrage", t)
end

function C2GSEnterShow(is_show, reenter_scene)
	local t = {
		is_show = is_show,
		reenter_scene = reenter_scene,
	}
	g_NetCtrl:Send("task", "C2GSEnterShow", t)
end

function C2GSSyncTraceInfo(taskid, cur_mapid, cur_posx, cur_posy)
	local t = {
		taskid = taskid,
		cur_mapid = cur_mapid,
		cur_posx = cur_posx,
		cur_posy = cur_posy,
	}
	g_NetCtrl:Send("task", "C2GSSyncTraceInfo", t)
end

function C2GSAcceptSideTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSAcceptSideTask", t)
end

function C2GSGetAchieveTaskReward(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSGetAchieveTaskReward", t)
end

function C2GSTriggerPatrolFight(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSTriggerPatrolFight", t)
end

function C2GSFinishAchieveTask(key, value)
	local t = {
		key = key,
		value = value,
	}
	g_NetCtrl:Send("task", "C2GSFinishAchieveTask", t)
end

function C2GSFinishShimenTask()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSFinishShimenTask", t)
end

function C2GSAcceptShimenTask()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSAcceptShimenTask", t)
end

