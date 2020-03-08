Kin.NYSnowman = Kin.NYSnowman or {};

local NYSnowman = Kin.NYSnowman

NYSnowman.JOIN_LEVEL = 20

NYSnowman.tbSnowmanNpcPos = {5057,2841} 						-- 雪人位置

NYSnowman.tbSnowmanNpcId = {2121,2151,2152,2153,2154,2155,2156}	-- 不同等级雪人对应的NpcId

NYSnowman.tbSnowmanLevel = {999,2499,4499,6999,9999,14999,15000} 				-- 不同等级对应所需雪花数量(n&n以下的等级)

NYSnowman.tbColor = {"白","绿","蓝","紫","粉","橙","金"}

NYSnowman.nSnowHeadNpcId = 2120 								-- 雪堆NpcId

NYSnowman.tbSnowHead = {{4530,2846},{5595,2852},{4522,3411},{5565,3411},{4179,3663},{6033,3796}}

NYSnowman.nSnowflakeItemId = 3532								-- 雪花ItemId

NYSnowman.tbAnswerWrongBegin = 2                              -- 答错奖励数量配置
NYSnowman.tbAnswerWrongEnd   = 4

NYSnowman.tbAnswerRightBegin = 4                              -- 答对奖励数量配置
NYSnowman.tbAnswerRightEnd   = 6

NYSnowman.tbDayAward = {{"item", 3533, 1}}                   -- 每天领取的奖励

NYSnowman.nSnowFlakeExp = 20000       -- 每个雪花经验
NYSnowman.tbMakinkAward =  			-- 雪人等级阶段奖励
{
    [2] = {{"item", 3533, 1}},
    [3] = {{"item", 3533, 1}},
    [4] = {{"item", 3533, 2}},
    [5] = {{"item", 3533, 2}},
    [6] = {{"item", 3533, 3}},
    [7] = {{"item", 3533, 4}},
}

NYSnowman.nFireWorksSkill = 2315	

NYSnowman.nSnowmanDir = 16

NYSnowman.Process_Type = 
{
	MAKING = 1,
}

NYSnowman.nBoxOpenCount = 28 					-- 活动最多可开礼盒次数

NYSnowman.SAVE_ONHOOK_GROUP = 148
NYSnowman.Update_Time = 4
NYSnowman.Award_Count = 5


assert(#NYSnowman.tbSnowmanNpcId == #NYSnowman.tbSnowmanLevel,"[NYSnowman] Setting Error")

function NYSnowman:GetLevelBySnowflake(nSnowflake)
	nSnowflake = nSnowflake or 0
	local nSnowmanLevel = 1
	for nLevel,nCount in ipairs(self.tbSnowmanLevel) do
		nSnowmanLevel = nLevel
		if nCount >= nSnowflake then
			break
		end
	end
	return nSnowmanLevel,self.tbSnowmanNpcId[nSnowmanLevel]
end
	
function NYSnowman:IsRunning()
	return Activity:__IsActInProcessByType("NYSnowmanAct")
end

function NYSnowman:CheckLevel(pPlayer)
	return pPlayer.nLevel >= self.JOIN_LEVEL
end