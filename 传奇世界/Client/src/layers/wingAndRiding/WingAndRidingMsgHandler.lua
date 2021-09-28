local onRecvWingData = function(buffer)
	if G_WING_INFO and buffer then
		local t = g_msgHandlerInst:convertBufferToTable("WingLoadDataProtocol", buffer) 
		--dump(t)
		G_WING_INFO.id = t.curWingID
		G_WING_INFO.state = t.wingState
		G_WING_INFO.bless = t.promoteTime
		G_WING_INFO.skillCount = #t.skill
		G_WING_INFO.skillTab = {}	
		for i=1,4 do
			G_WING_INFO.skillTab[i] = {skillId=i, skillLevel=0, skillProgress=0}
		end
		for i,v in ipairs(t.skill) do
			local skillId = v.pos
			local skillLevel = v.level
			local skillProgress = v.strength
			G_WING_INFO.skillTab[skillId] = {skillId=skillId, skillLevel=skillLevel, skillProgress=skillProgress}
			--table.insert(G_WING_INFO.skillTab, {skillId=skillId, skillLevel=skillLevel, skillProgress=skillProgress}})
		end
		dump(G_WING_INFO)
	end
end

local onWingFirstActive = function(buffer)
	local t = g_msgHandlerInst:convertBufferToTable("WingFirstActiveProtocol", buffer) 
	G_WING_INFO.id = t.wingID
	G_WING_INFO.state = 0
	G_WING_INFO.bless = 0
	G_WING_INFO.skillTab = {}
	for i=1,4 do
		G_WING_INFO.skillTab[i] = {skillId=i, skillLevel=0, skillProgress=0}
	end
	G_WING_INFO.skillCount = 0
	if getConfigItemByKey("WingCfg", "q_ID", G_WING_INFO.id, "q_activeSkillPos") == 1 then
		G_WING_INFO.skillCount = 1
	end
	-- 光翼激活默认显示
	if G_WING_INFO.id then
		if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
			--g_msgHandlerInst:sendNetDataByFmtExEx(WING_CS_CHANG_STATE, "ic", G_ROLE_MAIN.obj_id, 1)
			local t = {}
			t.opType = 1
			g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_CHANG_STATE, "WingChangeStateProtocol", t)
		end
	end

	G_NFTRIGGER_NODE:unLockFunction(NF_WING)
	G_NFTRIGGER_NODE:updateData(false)
	
	--开启光翼的引导
	if G_TUTO_DATA then
		for k,v in pairs(G_TUTO_DATA) do
			if v.q_id == 140 then
				v.q_state = TUTO_STATE_OFF
			end
		end
	end

	-- local function addRoleEffect()
	-- 	if G_ROLE_MAIN and G_ROLE_MAIN.getTopNode then
	-- 		local effect = Effects:create(false)
	-- 		effect:playActionData("wing_get", 11, 1.1, 1)
	-- 	    G_ROLE_MAIN:getTopNode():addChild(effect)
	-- 	    effect:setAnchorPoint(cc.p(0.5, 0))
	-- 	    effect:setPosition(cc.p(0 , -110))
	-- 	    addEffectWithMode(effect, 1)
	-- 	end
	-- end

	-- addRoleEffect()
end

-- local onRidingFirstActive = function(buffer)
-- 	G_RIDING_INFO.id = buffer:popInt()
-- 	G_RIDING_INFO.state = 0
-- 	G_RIDING_INFO.bless = 0
-- 	G_RIDING_INFO.skillTab = {}
-- 	G_RIDING_INFO.skillCount = 1

-- 	--开启坐骑的引导
-- 	if G_TUTO_DATA then
-- 		for k,v in pairs(G_TUTO_DATA) do
-- 			if v.q_id == 14 then
-- 				v.q_state = TUTO_STATE_OFF
-- 			end
-- 		end
-- 	end
-- end

local onWinglearnSkill = function(buffer)
	local index = buffer:popChar()
	local skillId = buffer:popInt()
	local skillName = getConfigItemByKey("SkillCfg", "skillID", skillId, "name")
	if G_WING_INFO.skillTab[index] and G_WING_INFO.skillTab[index] > 0 then
		local oldSkillName = getConfigItemByKey("SkillCfg", "skillID", G_WING_INFO.skillTab[index], "name")
		MessageBox(string.format(game.getStrByKey("wr_skill_wing_cover_tip"), skillName, oldSkillName))
	else
		MessageBox(string.format(game.getStrByKey("wr_skill_wing_new_tip"), skillName))
	end
	G_WING_INFO.skillTab[index] = skillId

	if G_WING_LEFT_NODE and G_WING_LEFT_NODE.refresh then
		G_WING_LEFT_NODE:refresh()
	end
end

local onWingStateChange = function(buffer)
	local t = g_msgHandlerInst:convertBufferToTable("WingChangeStateRetProtocol", buffer) 
	local ret = t.opType
	G_WING_INFO.state = ret
end

local onRecvRidingData = function(buffer)
	local t = g_msgHandlerInst:convertBufferToTable("RideRetLoadDataProtocol", buffer)
	if G_RIDING_INFO and buffer then
		local num = t.num
		G_RIDING_INFO.id = {}
		for i,v in ipairs(t.rideIDs) do
			G_RIDING_INFO.id[i] = v
		end
	end
	G_RIDING_INFO.state = t.state
	--dump(G_RIDING_INFO)
end

local onRindingStateChange = function(buffer)
	local t = g_msgHandlerInst:convertBufferToTable("RideChangeStateRetProtocol", buffer) 
	local ret = t.opType
	G_RIDING_INFO.state = ret > 0
	if G_ROLE_MAIN and ret > 0 then
		G_ROLE_MAIN:upOrDownRide_ex(G_ROLE_MAIN,ret,true,true)
	end
end

local onRidingRefreshData = function(buffer)
	local t = g_msgHandlerInst:convertBufferToTable("RideFreshRideRetProtocol", buffer) 
	if G_RIDING_INFO and buffer then
		local isFirstActive = t.isActive
		local num = t.num
		G_RIDING_INFO.id = {}
		for i,v in ipairs(t.rideIDs) do
			G_RIDING_INFO.id[i] = v
		end
		G_RIDING_INFO.state = t.state
		local newRideID = t.newRideID
		if newRideID and newRideID ~= 0 then
			--g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ici", G_ROLE_MAIN.obj_id, 1, newRideID)
			local t = {}
			t.opType = 1
			t.rideID = newRideID
			g_msgHandlerInst:sendNetDataByTableExEx(RIDE_CS_CHANG_STATE, "RideChangeStateProtocol", t)
		end

		if isFirstActive then
			--开启坐骑的引导
			if G_TUTO_DATA then
				for k,v in pairs(G_TUTO_DATA) do
					if v.q_id == 14 then
						v.q_state = TUTO_STATE_OFF
					end
				end
			end
		end

		if G_RIDE_RIGHT_NODE and G_RIDE_RIGHT_NODE.refresh then
			G_RIDE_RIGHT_NODE:refresh()
		end
		if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
			G_RIDE_LEFT_NODE:refresh(nil, G_RIDING_INFO.id)
		end
	end
end

local onWinglearnSkillRet = function(buffer)
	log("onWinglearnSkillRet 111111111111111111111111111")
	local t = g_msgHandlerInst:convertBufferToTable("WingLearnSkillRetProtocol", buffer)
	local skillId = t.pos
	local skillLevel = t.level
	local skillProgress = t.strength
	log("skillId = "..skillId)
	log("skillLevel = "..skillLevel)
	log("skillProgress = "..skillProgress)
	--dump(G_WING_INFO)
	local isLevelUp = (G_WING_INFO.skillTab[skillId] == nil) or (G_WING_INFO.skillTab[skillId].skillLevel < skillLevel)
	G_WING_INFO.skillTab[skillId] = {skillId=skillId, skillLevel=skillLevel, skillProgress=skillProgress}

	if G_WING_LEFT_NODE and G_WING_LEFT_NODE.refresh then
		log("refresh 1111111111111111111111111111")
		G_WING_LEFT_NODE:refresh()
	end
end

local onMountUse = function(buffer)
	log("onMountUse 111111111111111111111111111")
	local t = g_msgHandlerInst:convertBufferToTable("MountUseMountRetProtocol", buffer)
	G_RIDING_INFO.index = t.dwBagSlot
	dump(G_RIDING_INFO)

	if G_RIDE_RIGHT_NODE and G_RIDE_RIGHT_NODE.refresh then
		G_RIDE_RIGHT_NODE:refresh(G_RIDING_INFO.index)
	end

	if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
		G_RIDE_LEFT_NODE:refresh(G_RIDING_INFO.index)
	end
end

local onMountFree = function(buffer)
	log("onMountFree 11111111111111111111111111111111111111111111111111111")
	local t = g_msgHandlerInst:convertBufferToTable("ItemMountFreeRetProtocol", buffer)

	if G_RIDE_RIGHT_NODE and G_RIDE_RIGHT_NODE.refresh then
		G_RIDE_RIGHT_NODE:refresh(G_RIDING_INFO.index)
	end

	if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
		G_RIDE_LEFT_NODE:refresh(G_RIDING_INFO.index)
	end
end

local onSacrifice = function(buffer)
	log("onSacrifice 11111111111111111111111111111111111111111111111111111")
	local t = g_msgHandlerInst:convertBufferToTable("MountSacrificeBaseInfoRetProtocol", buffer)
	G_RIDING_INFO.isCanSacrifice = t.dwFlag
	G_RIDING_INFO.sacrificeTab = {}
	

	for i,v in ipairs(t.vecProperty) do
		table.insert(G_RIDING_INFO.sacrificeTab, {v.id, v.count})
	end
	dump(G_RIDING_INFO)
end

g_msgHandlerInst:registerMsgHandler(WING_SC_LOADDATA, onRecvWingData)
g_msgHandlerInst:registerMsgHandler(WING_SC_FIRST_ACTIVE, onWingFirstActive)
g_msgHandlerInst:registerMsgHandler(WING_SC_LEARN_SKILL, onWinglearnSkill)
g_msgHandlerInst:registerMsgHandler(WING_SC_CHANG_STATE_RET, onWingStateChange)
g_msgHandlerInst:registerMsgHandler(WING_SC_LEARN_SKILL_RET, onWinglearnSkillRet)

g_msgHandlerInst:registerMsgHandler(RIDE_SC_LOADDATA, onRecvRidingData)
g_msgHandlerInst:registerMsgHandler(RIDE_SC_CHANG_STATE_RET, onRindingStateChange)
g_msgHandlerInst:registerMsgHandler(RIDE_SC_FRESH_RIDE, onRidingRefreshData)

g_msgHandlerInst:registerMsgHandler(EMOUNT_SC_USE_MOUNT, onMountUse)
g_msgHandlerInst:registerMsgHandler(ITEM_SC_FREE, onMountFree)



