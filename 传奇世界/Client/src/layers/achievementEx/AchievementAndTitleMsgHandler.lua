local onRecvTitleData = function(buffer)
	log("onRecvTitleData")
end

local onRecvNewAchievement = function(buff)
	log("onRecvNewAchievement")
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then return end
	local t = g_msgHandlerInst:convertBufferToTable("AchieveGetNewAchieve", buff)
	local achieveId = t.achieveID
	local titleId = t.titleID
	dump(t.achieveID)
	dump(t.titleID)
	local achieveRecord = nil
	local titleRecord = nil

	if achieveId ~= 0 then
		achieveRecord = getConfigItemByKey("AchieveDB", "q_id", achieveId)
	end

	if titleId ~= 0 then
		titleRecord = getConfigItemByKey("TitleDB", "q_titleID", titleId)
	end

	if achieveRecord and achieveRecord.delay then
		startTimerAction(G_MAINSCENE, achieveRecord.delay, false, function()
			if achieveRecord then
				local layer = require("src/layers/achievementEx/AchievementAndTitleNoticeLayer").new(achieveRecord, titleRecord)
				--G_MAINSCENE:addChild(layer, 100)
				Manimation:transit(
				{
					ref = G_MAINSCENE,
					node = layer,
					curve = "-",
					sp = cc.p(display.cx, 0),
					ep = cc.p(display.cx, 50),
					zOrder = 250,
					--tag = 100+i,
					--swallow = true,
				})
			end
		 end)
	else
		if achieveRecord or titleRecord then
			local layer = require("src/layers/achievementEx/AchievementAndTitleNoticeLayer").new(achieveRecord, titleRecord)
			--G_MAINSCENE:addChild(layer, 100)
			Manimation:transit(
			{
				ref = G_MAINSCENE,
				node = layer,
				curve = "-",
				sp = cc.p(display.cx, 0),
				ep = cc.p(display.cx, 50),
				zOrder = 250,
				--tag = 100+i,
				--swallow = true,
			})
		end
	end
end

g_msgHandlerInst:registerMsgHandler(ACHIEVE_SC_LOADTITLE, onRecvTitleData)
g_msgHandlerInst:registerMsgHandler(ACHIEVE_SC_GETNEWACHIEVE, onRecvNewAchievement)
