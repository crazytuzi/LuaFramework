local TutoTrigger = class("TutoTrigger", function() return cc.Node:create() end)

require("src/layers/tuto/TutoDefine")
require("src/layers/tuto/TutoFunction")

TutoTrigger.protoId = nil

function TutoTrigger:ctor()
	log("TutoTrigger:ctor")

	--self.tutoCfgTab = getConfigItemByKey("TutoCfg")
	--self:checkCfgData()

	self.showNodeList = {}
	self.touchNodeList = {}

	-- self.isSendCheck = false

	-- self.checkAction = startTimerAction(self, 0.25, true, function() 
	-- 		--log("self.checkAction")
	-- 		if G_ROLE_MAIN and G_ROLE_MAIN.obj_id and self.isSendCheck == false then
	-- 			g_msgHandlerInst:sendNetDataByFmtExEx(GAMECONFIG_CS_GETGUARD, "i", G_ROLE_MAIN.obj_id)
	-- 			self.isSendCheck = true
	-- 			if self.checkAction then
	-- 				self:stopAction(self.checkAction)
	-- 				self.checkAction = nil
	-- 			end
	-- 		end
	-- 	end)

	local function eventCallback(eventType)
		log("eventCallback event = "..eventType)
        if eventType == "enter" then
        elseif eventType == "exit" then
        end
    end
    self:registerScriptHandler(eventCallback)
    --print(debug.traceback())

    local checkInMain = function()
    	local level = MRoleStruct:getAttr(ROLE_LEVEL) or 0
		if level == 1 and getLocalRecord("storyExTuto") ~= true then
			return
		end

		--log("TutoTrigger:checkInMain")
		-- dump(G_MAINSCENE.map_layer)
		-- dump(G_MAINSCENE.map_layer.isfb or G_MAINSCENE.map_layer.isJjc)
		-- dump(G_MAINSCENE.mapId and G_MAINSCENE.mapId == 1000)
		--副本中不启动教程
		if G_MAINSCENE and 
			G_MAINSCENE.map_layer and (G_MAINSCENE.map_layer.isfb or G_MAINSCENE.map_layer.isJjc or G_MAINSCENE.map_layer.is3v3 or G_MAINSCENE:isStoryMap(G_MAINSCENE.mapId) ) then
			return
		end
		-- dump(G_TUTO_DATA)
		for k,v in pairs(G_TUTO_DATA) do
			-- log("TutoTrigger:checkInMain 2 q_id = "..v.q_id)
			-- print("player job ",MRoleStruct:getAttr(ROLE_SCHOOL))
			if v.q_state == TUTO_STATE_OFF then
				--log("TutoTrigger:checkInMain 3 q_id = "..v.q_id)
				-- if self:checkCondition(v.q_conditions, v.q_id) == true then
				-- 	--log("TutoTrigger:checkInMain 4 q_id = "..v.q_id)
				-- 	-- print("tutoID===================",v.q_id)
				-- 	if v.callFunc then
				-- 		v.callFunc()
				-- 		tutoSetState(v, TUTO_STATE_FINISH)
				-- 		break
				-- 	end

				-- 	if self:isCanTriggerNew(q_id) then
				-- 		--log("TutoTrigger:checkInMain 5 q_id = "..v.q_id)
				-- 		v.q_state = TUTO_STATE_ON
				-- 		if v.q_delay then
				-- 			startTimerAction(self, v.q_delay, false, function() self:trigger(v, v.q_controls[1].showNode == SHOW_MAIN) end)
				-- 		else
				-- 			self:trigger(v, v.q_controls[1].showNode == SHOW_MAIN)
				-- 		end
				-- 		break
				-- 	end
				-- end
				if self:checkTuto(v) then
					break
				end

			end
		end
	end

	startTimerAction(self, 0.3, true, checkInMain)
end

function TutoTrigger:checkTuto(v)
	if self:checkCondition(v.q_conditions, v.q_id) == true then
		if v.callFunc then
			v.callFunc()
			tutoSetState(v, TUTO_STATE_FINISH)
			return true
		end

		if self:isCanTriggerNew(q_id) then
			--log("TutoTrigger:checkInMain 5 q_id = "..v.q_id)
			v.q_state = TUTO_STATE_ON
			if v.q_delay then
				startTimerAction(self, v.q_delay, false, function() self:trigger(v, v.q_controls[1].showNode == SHOW_MAIN) end)
			else
				self:trigger(v, v.q_controls[1].showNode == SHOW_MAIN)
			end
			return true
		end
	end
	return false
end

function TutoTrigger:checkCfgData()
	--log("TutoTrigger:checkCfgData 1111111111111111111111")
	local function isFinishMainStep(record)
		if record.q_controls then
			local mainStep
			for i,v in ipairs(record.q_controls) do
				if v.mainStep and v.mainStep == true then
					mainStep = i
				end
			end
			local step = record.q_step
			if setp and mainStep then
				if step > mainStep then
					return true
				end
			end
		end

		return false
	end

	local function setFinish(record)
		--log("setFinish 1111111111111111111111111111")
		tutoSetState(record, TUTO_STATE_FINISH)
	end

	local function reset(record)
		--log("reset 111111111111111111111111111111111111")
		record.q_step = 1
		record.q_state = TUTO_STATE_OFF
	end

	--dump(self.tutoCfgTab)
	--重新检查新手引导数据
	for k,v in pairs(G_TUTO_DATA) do
		local record = v
		--log("test 1 k="..tostring(k))
		--log("test 1 q_state="..tostring(record.q_state))
		if record.q_state == TUTO_STATE_ON then
		-- 	--log("test 2")
		-- 	if record.q_step == 1 then
		-- 		reset(record)
		-- 	else
				if isFinishMainStep(record) then
					setFinish(record)
				else
					reset(record)
				end
		-- 	end
		end
	end
end

function TutoTrigger:isCanTriggerNew(id)
	for k,v in pairs(G_TUTO_DATA) do
		if q_id == 804 or q_id == 802 or q_id == 403 then
			return true
		end

		-- if v.q_state == TUTO_STATE_ON and v.q_type == TUTO_TYPE_COMPULSIVE and v.q_id ~= id  then
		-- 	log("TutoTrigger:isCanTriggerNew is false id = "..v.q_id)
		-- 	return false
		-- end

		if self.tutoLayer ~= nil then
			--log("TutoTrigger:isCanTriggerNew is false id = "..v.q_id)
			return false
		end
	end

	return true
end

function TutoTrigger:setShowNode(node, tag)
	log("TutoTrigger:setShowNode tag = "..tag)
	self.showNodeList[tag] = node
	self.nowShowNodeTag = tag

	--主界面不check
	if tag ~= 2000 then
		self:check()
	end
end

function TutoTrigger:setShowNodeEx(tag)
	log("TutoTrigger:setShowNodeEx tag = "..tag)
	if self.showNodeList[tag] then
		self:setShowNode(self.showNodeList[tag], tag)
	end
end

function TutoTrigger:setTouchNode(node, tag)
	if node and tag then
		-- print("TutoTrigger:setTouchNode tag = ",tag)
		self.touchNodeList[tag] = node
	else
		-- print("TutoTrigger:setTouchNode error ",tag)
		log("param error!!!!!!")
		dump(node)
		dump(tag)
	end
end

function TutoTrigger:getTouchNode(tag)
	return self.touchNodeList[tag]
end

function TutoTrigger:check()
	log("TutoTrigger:check")
	for k,v in pairs(G_TUTO_DATA) do
		local tutoInfo = v
		if v.q_state == TUTO_STATE_ON then
			for i,v in pairs(tutoInfo.q_controls) do	
				if i == tutoInfo.q_step and (i~=1 or tutoInfo.q_id == 20) then 
					print("tutoInfo.q_step = "..tostring(tutoInfo.q_step))
					print("self.nowShowNodeTag = "..tostring(self.nowShowNodeTag))
					print("v.showNode = "..tostring(v.showNode))
					if self.nowShowNodeTag == v.showNode or v.showNode == SHOW_MAIN then
						self:trigger(tutoInfo)
						break
					end
				end
			end
		end
	end
end

function TutoTrigger:checkTutoStateByID( id )
	-- body
	for i,v in pairs(G_TUTO_DATA) do	
		if v.q_id == id and v.q_state == TUTO_STATE_FINISH then
			return true
		end
	end
	return false
end

function TutoTrigger:checkDelay(delayTime)
	log("checkDelay")
	startTimerAction(self, delayTime, false, function() self:check() end)
	self:addDelayProtect(delayTime)
end

function TutoTrigger:addDelayProtect(delayTime)
	--防止delaycheck期间玩家操作导致引导中断
	local layer = cc.Layer:create()
	local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    		log("tuto Delay Protect")
       		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)
    getRunScene():addChild(layer, 300)

    startTimerAction(self, delayTime, false, function() removeFromParent(layer) end)
end

function TutoTrigger:checkCondition(condition, id)
	--log("TutoTrigger:checkCondition")
	local MPackManager = require "src/layers/bag/PackManager"
	local MPackStruct = require "src/layers/bag/PackStruct"
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local dress = MPackManager:getPack(MPackStruct.eDress)
	local result = true
	for k,v in pairs(condition) do
		--已经有条件不满足 没必要继续
		if result == false then
			break
		end

		if k == "item" then
			local record = v
			local itemRet = nil
			for k,v in pairs(record) do
				local ret
				if bag:countByProtoId(v.id) < v.num then
					ret = false
				else
					ret = true
					TutoTrigger.protoId = v.id
				end

				if itemRet == nil then
					itemRet = ret
				elseif v.tag == "|" then
					itemRet = itemRet or ret
				elseif v.tag == "&" then
					itemRet = itemRet and ret
				end
			end
			result = result and itemRet
		elseif k == "lv" then
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local lv = MRoleStruct:getAttr(ROLE_LEVEL)
			-- log("lv = "..lv)
			-- log("v = "..v)
			if lv ~= v then
				result = false
				--log("TutoTrigger:checkCondition lv false")
			end
		elseif k == "school" then
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local school = MRoleStruct:getAttr(ROLE_SCHOOL)
			-- log("school = "..school)
			-- log("v = "..v)
			if school ~= v then
				result = false
				--log("TutoTrigger:checkCondition school false")
			end
		elseif k == "battle" then
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local battle = MRoleStruct:getAttr(PLAYER_BATTLE)
			-- log("battle = "..battle)
			-- log("v = "..v)
			if battle < v then
				result = false
				--log("TutoTrigger:checkCondition battle false")
			end
		elseif k == "task" then 
			result = false
			local task = -1
			local taskState = 1
			if DATA_Mission and DATA_Mission:getLastTaskData() then
				task = DATA_Mission:getLastTaskData().q_taskid
				taskState = DATA_Mission:getLastTaskData().finished
			end
			--log("######################task = "..task)
			--log("######################taskState = "..taskState)
			-- print("task========================",task)
			-- print("taskstate==============",taskState)
			if v == 10038 or v==10069 then
				if taskState == 3 and v == task then
					result = true
				end
			elseif v== 10121 then
				if taskState == 2 and v == task then
					result = true
				end
			else
				if task == v and taskState> -1 then
					result = true
				end
			end
		-- elseif k =="tutoId" then
		-- 	 result = self:checkTutoStateByID(v)
		elseif k == "func" then
			result = false
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE.isFuncOn and G_NFTRIGGER_NODE:isFuncOn(v) == true then
				result = true
			end
		elseif k == "map" then
			if (G_MAINSCENE and G_MAINSCENE.mapId and G_MAINSCENE.mapId == v) ~= true then
				result = false
			end
		elseif k == "jifen" then
			if G_jifen < v then
				result = false
			end
		elseif k == "skill" then
			result = false
			local skillId = v
			--dump(G_ROLE_MAIN.skills)
			if G_ROLE_MAIN and G_ROLE_MAIN.skills then
				for i,v in ipairs(G_ROLE_MAIN.skills) do
					if v[1] == skillId then
						result = true
						break
					end
				end
			end
		elseif k == "vip" then
			result = false
			if G_VIP_INFO and G_VIP_INFO.vipLevel and v == G_VIP_INFO.vipLevel then
				result = true
			end
		elseif k == "jb" then
			result = false
			if G_ROLE_MAIN and G_ROLE_MAIN.currGold and G_ROLE_MAIN.currGold >= v then
				result = true
			end
		elseif k == "dress" then
			result = false
			if self:checkIsDress(v) then
				result = true
			end
		elseif k =="node" then --检查某个界面是否存在
			result = false
			local node = self.showNodeList[v]
			node = tolua.cast(node,"cc.Node")
			if node then
				result = true
			end
		elseif k =="touchnode" then --检查某个节点是否存在
			result = false
			local node = self.touchNodeList[v]
			node = tolua.cast(node,"cc.Node")
			if node and node:isVisible() then
				result = true
				print("飞鞋教程OK")
			end
		end
	end

	--如果引导是不能有本地记录的(一个角色只引导一次)，也不引导
	-- if condition.noRecord == true then
	-- 	if getLocalRecord("tuto"..id) == true then
	-- 		result = false
	-- 	end
	-- end

	return result
end

function TutoTrigger:trigger(tutoInfo, isMainScene)
	log("TutoTrigger:trigger")
	local layer

	--部分按钮需要先打开菜单
	self:openMenu(tutoInfo)

	--部分按钮需要先关闭菜单
	self:closeMenu(tutoInfo)

	if G_MAINSCENE then
		--停止挂机
		--if game.getAutoStatus() == AUTO_ATTACK then --tutoInfo.stopHang == true and 
			--log("G_MAINSCENE.map_layer:resetHangup() 111111111111111111111111111111111111111111")
			if not tutoInfo.stop then
				G_MAINSCENE.map_layer:cleanAstarPath(true, true)
				G_MAINSCENE.map_layer:resetHangup()
			end	
			
		--end

		--关闭目标提示
		if G_MAINSCENE.newFuntionNodeEx then
			G_MAINSCENE.newFuntionNodeEx:removeShow()
		end
	end

	local zOrder 
	if isMainScene then
		zOrder = 100
	else
		zOrder = 300
	end

	if tutoInfo.q_controls[tutoInfo.q_step].zOrder then
    	zOrder = tutoInfo.q_controls[tutoInfo.q_step].zOrder
    end

    --避免重复触发同一个引导
    if self.tutoLayer then
    	if self.tutoLayer.tutoStepInfo == tutoInfo.q_controls[tutoInfo.q_step] then
    		log("same step tuto trigger!")
    		return
    	end
    end

    --去除任务面板的指引手势
    tutoRemoveHungUpCheck()

 --    if (G_SHOW_ORDER_DATA.showFuncEx == true or G_SHOW_ORDER_DATA.showFunc == true) and tutoInfo.q_step == 1 then
 --    	self.delayTuto = true
 --    	startTimerAction(self, 5, false, function() 
	-- 			if tutoInfo.q_type == TUTO_TYPE_COMPULSIVE then
	-- 				layer = require("src/layers/tuto/TutoCompulsiveLayer").new(self.showNodeList, self.touchNodeList, tutoInfo)
	-- 				Director:getRunningScene():addChild(layer, zOrder)
	-- 			elseif tutoInfo.q_type == TUTO_TYPE_HALF_COMPULSIVE then
	-- 				layer = require("src/layers/tuto/TutoCompulsiveLayer").new(self.showNodeList, self.touchNodeList, tutoInfo, true)
	-- 				Director:getRunningScene():addChild(layer, zOrder)
	-- 			elseif tutoInfo.q_type == TUTO_TYPE_FREEWILL then
	-- 				layer = require("src/layers/tuto/TutoFreewillLayer").new(tutoInfo, TutoTrigger.protoId)
	-- 				Director:getRunningScene():addChild(layer, 100)
	-- 			end

	-- 			self.delayTuto = false
	-- 		end)
	-- else	
		if tutoInfo.q_type == TUTO_TYPE_COMPULSIVE then
			layer = require("src/layers/tuto/TutoCompulsiveLayer").new(self.showNodeList, self.touchNodeList, tutoInfo)
			G_MAINSCENE:addChild(layer, zOrder)
		elseif tutoInfo.q_type == TUTO_TYPE_HALF_COMPULSIVE then
			layer = require("src/layers/tuto/TutoCompulsiveLayer").new(self.showNodeList, self.touchNodeList, tutoInfo, true)
			getRunScene():addChild(layer, zOrder)
		elseif tutoInfo.q_type == TUTO_TYPE_FREEWILL then
			layer = require("src/layers/tuto/TutoFreewillLayer").new(tutoInfo, TutoTrigger.protoId)
			getRunScene():addChild(layer, 100)
		end	
	--end
end

function TutoTrigger:openMenu(tutoInfo)
	log("TutoTrigger:openMenu")

	if G_MAINSCENE == nil then
		return
	end

	if tutoInfo.q_step ~= 1 then
		return
	end

	if tutoInfo.stop then
		return
	end

	-- if (tutoInfo.q_controls[1].showNode == SHOW_MAIN and tutoInfo.q_controls[1].touchNode == TOUCH_MAIN_HEAD) == false then
	-- 	local touchTag = tutoInfo.q_controls[tutoInfo.q_step].touchNode
	-- 	for k,v in pairs(TOUCH_NEED_MENU) do
	-- 		if touchTag == v then
	-- 			--如果教程第一步不是点击头像则打开底部菜单
	-- 			G_MAINSCENE:setFullShortNode(true)
	-- 			break
	-- 		end
	-- 	end

	-- 	for k,v in pairs(TOUCH_NEED_CONTROL) do
	-- 		if touchTag == v then
	-- 			G_MAINSCENE:setFullShortNode(false)
	-- 			break
	-- 		end
	-- 	end
	-- else
	-- 	G_MAINSCENE:setFullShortNode(false)
	-- end

	G_MAINSCENE:setFullShortNode(true)
	startTimerAction(self, 0.25, false, function() G_MAINSCENE:setFullShortNode(true) end)
	startTimerAction(self, 0.4, false, function() G_MAINSCENE:setFullShortNode(true) end)

	--打开顶部菜单
	if TOPBTNMG then
		TOPBTNMG:openTop(true)
	end
	G_MAINSCENE:hideTopIcon(false)
end

function TutoTrigger:closeMenu(tutoInfo)
	log("TutoTrigger:closeMenu")
	if tutoInfo.q_controls[tutoInfo.q_step].closeMenu == true then
		log("1111111111111111111111111111")
		G_MAINSCENE:setFullShortNode(false)
		startTimerAction(self, 0.4, false, function() G_MAINSCENE:setFullShortNode(false) end)
	end
end

function TutoTrigger:isNodeRunningAction(tutoInfo)
	log("TutoTrigger:isNodeRunningAction")
	local node = tutoGetNode(self.touchNodeList, tutoInfo)
	return (node:getNumberOfRunningActions() > 0)
end

function TutoTrigger:openMenuDelay(time)
	startTimerAction(self, time, false, function() G_MAINSCENE:setFullShortNode(true) end)
end

function TutoTrigger:checkIsDress(dressId)
	--log("TutoTrigger:checkIsDress dressId = "..dressId)
	if MPackManager then
		local dressPack = MPackManager:getPack(MPackStruct.eDress)
		if dressPack then
			local grid = dressPack:getGirdByGirdId(dressId)
			--dump(grid)
			if grid then
				return true
			end
		end
	end

	return false
end

return TutoTrigger