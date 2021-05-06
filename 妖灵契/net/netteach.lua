module(..., package.seeall)

--GS2C--

function GS2CTeachProgress(pbdata)
	local times = pbdata.times
	local reward_status = pbdata.reward_status
	--todo
	g_TeachCtrl:OnUpdateTeachProgress(times, reward_status)
end

function GS2CGuidanceInfo(pbdata)
	local guidanceinfo = pbdata.guidanceinfo
	--todo
	printc(">>>>>>>>>>>>>>>>>>>> GS2CGuidanceInfo ")
	g_GuideCtrl:LoginInit(guidanceinfo)
end


--C2GS--

function C2GSGetTaskReward(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("teach", "C2GSGetTaskReward", t)
end

function C2GSGetProgressReward(progress)
	local t = {
		progress = progress,
	}
	g_NetCtrl:Send("teach", "C2GSGetProgressReward", t)
end

function C2GSFinishGuidance(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("teach", "C2GSFinishGuidance", t)
end

function C2GSClearGuidance(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("teach", "C2GSClearGuidance", t)
end

