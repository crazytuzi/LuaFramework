--HotUpdate.lua

HotUpdate = {}
package.loaded["system.hotUpdate.HotUpdate2"]=nil

--单人本
HotUpdate.updatecopydb = function()
	package.loaded["data.SingleCopyDB"] = nil
	package.loaded["data.TowerCopyDB"] = nil
	package.loaded["data.GuardCopyDB"] = nil
	g_copyMgr:parsePrototype()
end

--多人本
HotUpdate.updatemulticopy = function()
	package.loaded["data.MultiCopyDB"] = nil
	g_copyMgr:parseMultiProto()
end

--成就称号
HotUpdate.updateachieve = function()
	package.loaded["data.AchieveDB"]=nil
	package.loaded["data.TitleDB"]=nil
	package.loaded["data.AchieveAttrDB"]=nil
	g_achieveMgr:parseAchieveData()
end

--离线挂机
HotUpdate.updateoffhang = function()
	package.loaded["data.OffLineDB"]=nil
	g_offLineMgr:hotUpdateConfig()
end

--合成表
HotUpdate.updatecompound = function()
	CompoundServlet.getInstance():parseCompound()
end

--效果和礼包表
HotUpdate.updateeffect = function()
	package.loaded["data.EffectDB"]=nil
	package.loaded["data.GiftDB"]=nil
	__initConfig()
end

--任务表
HotUpdate.updateTask = function()
	g_taskMgr:parseTaskData()
end

--日常任务表
HotUpdate.updateDailyTask = function()
	g_taskMgr:parseDailyTaskData()
end

-- 悬赏任务20160106
HotUpdate.updateRewardTask = function()
	g_taskMgr:parseRewardTaskData()
end

--光翼表
HotUpdate.updateWing = function()
	g_wingMgr:parseWingData()
end

--坐骑表
HotUpdate.updateRide = function()
	g_rideMgr:parseRideData()
end

--重装使者表
HotUpdate.updateEnvoy = function()
	g_EnvoyMgr:parseEnvoyData()
end

--拼战奖励表
HotUpdate.updateCompetition = function()
	g_competitionMgr:parseCompetitionData()
end

--神秘商店表
HotUpdate.updateMystShop = function()
	g_mystShopMgr:loadMystConfig()
end

--竞技场每日奖励表
HotUpdate.updateSinpvpDay = function()
	--g_sinpvpMgr:rewardInit()
end

--商城表
HotUpdate.updateTradeMall = function()
	g_tradeMgr:hotUpdate()
end

--道具交易限价表
HotUpdate.updateTradeLimit = function()
	g_tradeMgr:hotUpdateLimit()
end

--世界Boss奖励表
HotUpdate.updateWorldBoss = function()
	g_WorldBossMgr:hotUpdate()
end

--寻宝表
HotUpdate.updateXunBao = function()
	--g_XunBaoMgr:loadItem()
end

--镖车
HotUpdate.updateDart = function()
	g_commonMgr:hotUpdate()
end

--GM白名单
HotUpdate.updateGmWhite = function()
	ShellSystem.getInstance():parseWhiteData()
end

function HotUpdateFun(hotstr)
	local method = HotUpdate[hotstr]
	if method then
		method()
	end
end
