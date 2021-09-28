--TourTaskHelper.lua
--/*-----------------------------------------------------------------
 --* Module:  TourTaskHelper.lua
 --* Author:  goddard
 --* Modified: 2016年8月17日
 --* Purpose: 巡礼任务目标工厂
 -------------------------------------------------------------------*/

require ("system.marriage.tourtask.KillScarecrow")
require ("system.marriage.tourtask.CollectFlowersAir")
require ("system.marriage.tourtask.CollectWellWater")
require ("system.marriage.tourtask.CollectWolfBlood")
require ("system.marriage.tourtask.CollectHotFlowerFemale")
require ("system.marriage.tourtask.CollectHotFlowerMale")
require ("system.marriage.tourtask.CollectFlowersRock")

TourTaskHelper =
{
	[1]	= KillScarecrow,			--击杀稻草人
	[2] = CollectFlowersAir,		--采集飞舞之花
	[3] = CollectWellWater,			--采集井水
	[4] = CollectWolfBlood,			--击杀土狼
	[5] = CollectHotFlowerMale,		--浇灌炙热之花(男)
	[6] = CollectHotFlowerFemale,	--浇灌炙热之花(女)
	[7] = CollectFlowersRock,		--采集磐石之花
}

--构造任务目标的函数
function TourTaskHelper.createTarget(info, taskId, count, status)
	local config = g_marriageMgr:findTaskConfig(taskId)
	if TourTaskHelper[taskId] and config then
		return TourTaskHelper[taskId](info, count, config, status)
	end
end