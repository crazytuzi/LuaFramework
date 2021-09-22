local GUITaskView = {}

local var = {}
-- 构造任务描述富文本
local function buildTaskDesp(pTask)
	-- print("buildTaskDesp", pTask.mTaskID);
	local mInfo = pTask.mInfo
	local strDesp = ""
	local lines = 1
	local strs = {}
	--table.insert(strs, "<font color=#fff843>["..mInfo.task_type.."] "..mInfo.task_name..mInfo.task_state.."</font>")
	table.insert(strs, "            <font color=#e09100>"..mInfo.task_name..mInfo.task_state.."</font>")
	if mInfo.target_type == "mon" then
		if pTask.mTaskID == 1000 then
			table.insert(strs, "<font color=#ffffff>击杀:</font><font color=#30ff00>"..mInfo.target_name.."<font color=#ffffff>("..pTask.mParam_1.."/"..mInfo.target_num..")</font></font>")
		elseif pTask.mTaskID == 2000 then
			table.insert(strs, "<font color=#ffffff>击杀:"..mInfo.target_name.."的</font><font color=#30ff00>怪物</font>("..pTask.mParam_1.."/"..mInfo.target_num..")</font>")
		end
	elseif mInfo.target_type == "level" then
		table.insert(strs, "<font color=#ffffff>升到</font><font color=#30ff00>"..mInfo.target_num.."级("..pTask.mParam_1.."/"..mInfo.target_num..")</font>")
	elseif mInfo.target_type == "ownequip" then
		table.insert(strs, "<font color=#ffffff>穿戴</font><font color=#30ff00>"..mInfo.target_num.."件"..mInfo.target_name.."级装备("..pTask.mParam_1.."/"..mInfo.target_num..")</font>")
	elseif mInfo.target_type == "friend" then
		table.insert(strs, "<font color=#ffffff>添加:</font><font color=#30ff00>("..pTask.mParam_1.."/"..mInfo.target_num..")名好友</font>")
	elseif mInfo.target_type == "exploit" then
		table.insert(strs, "<font color=#ffffff>获得:</font><font color=#30ff00>("..pTask.mParam_1.."/"..mInfo.target_num..")点功勋</font>")
	elseif mInfo.target_type == "innerpowerlevel" then
		table.insert(strs, "<font color=#ffffff>内功提升到</font><font color=#30ff00>"..mInfo.target_num.."级("..pTask.mParam_1.."/"..mInfo.target_num..")</font>")
	end
	
	if GameUtilSenior.isTable(mInfo.desc) then
		for i,v in ipairs(mInfo.desc) do
			table.insert(strs, v)
		end
	else
		if mInfo.desc then
			table.insert(strs, mInfo.desc)
		end
	end
	
	for i=1,#strs do
		if strDesp ~= "" then
			strDesp = strDesp.."<br>"
			lines = lines + 1
		end
		strDesp = strDesp..strs[i]
	end
	return strDesp, lines
end

local mapids = {
	"kingcity", "kinghome"
}

-- 给任务条加选中态
local function onTaskSelected(taskDespItem, scroll)
	local items = var.listTask:getItems()
	local imgTaskSelectedBg
	for i, item in ipairs(items) do
		imgTaskSelectedBg = item:getChildByName("img_task_selected_bg")
		if imgTaskSelectedBg then
			imgTaskSelectedBg:stopAllActions():hide()
		end
	end
	if not taskDespItem then return end
	imgTaskSelectedBg = taskDespItem:getChildByName("img_task_selected_bg")
	if not imgTaskSelectedBg then return end
	imgTaskSelectedBg:setOpacity(255)
	imgTaskSelectedBg:show():runAction(cca.repeatForever(cca.seq({
			cca.fadeOut(0.8),
			cca.fadeIn(0.8),
		})
	))
	if scroll then
		if var.listTask:getInnerContainerPosition().y < 0 then
			var.listTask:scrollToItem(var.listTask:getIndex(taskDespItem), cc.p(0.5, 1), cc.p(0.5, 1))
		elseif var.listTask:getInnerContainerPosition().y == 0 then
			if taskDespItem:getPositionY() + taskDespItem:getContentSize().height * 0.5 > var.listTask:getContentSize().height then
				var.listTask:scrollToItem(var.listTask:getIndex(taskDespItem), cc.p(0.5, 1), cc.p(0.5, 1))
			end
		end
	end
end

-- 点击任务条
local function pushTaskDespItem(pSender)
	
	if table.indexof(mapids, GameSocket.mNetMap.mMapID) then
		return GameSocket:alertLocalMsg("该地图无法传送！", "alert")
	end

	-- print("pushTaskDespItem", pSender.state, pSender.touchLink)
	local equalPos
	if pSender.touchLink then
		equalPos = GameUtilSenior.litenerTaskLink(pSender.touchLink)
	end
	if pSender.showGetEquip then
		GUILeftCenter.initGetEquip(true)
		-- GameSocket:PushLuaTable("gui.moduleGuide.onContinueTask", GameUtilSenior.encode({taskType = "getEquip"}));
	end
	if pSender.netLink then
		GameSocket:PushLuaTable("task.simulateTask.onPushTaskItem", pSender.netLink);
	end
	if pSender.flyInfo then
		-- GameSocket.mTaskFly = pSender.flyInfo
		if not equalPos then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY, info = pSender.flyInfo})
		end
	end
	onTaskSelected(pSender)
end

local function insertTaskItem(mTaskDespItem)
	local items = var.listTask:getItems()
	local index = 0
	for i, item in ipairs(items) do
		if mTaskDespItem.taskId > item.taskId then
			index = i
		end
	end
	var.listTask:insertCustomItem(mTaskDespItem, index)
end

-- 任务改变监听函数
local function onTaskChange(event, init)
	local taskId = event and event.cur_id or 1000
	local pTask = GameSocket.mTasks[taskId]
	 --print("///////////////////////////onTaskChange////////////////////////////", GameUtilSenior.encode(pTask))
	if not pTask then return end
	local mInfo = pTask.mInfo
	local mTaskDespItem = var.listTask:getChildByName("taskItem"..taskId)
	if not mInfo or not mInfo.task_state then
		if mTaskDespItem then 
			var.listTask:removeChild(mTaskDespItem)
			var.listTask:requestDoLayout()
		end
		return
	end
	
	if not mTaskDespItem then
		mTaskDespItem = var.itemTaskDesp:clone()
		mTaskDespItem:setName("taskItem"..taskId)
		mTaskDespItem:setTouchEnabled(true):show():setSwallowTouches(false)
		mTaskDespItem.taskId = taskId
		GUIFocusPoint.addUIPoint(mTaskDespItem, pushTaskDespItem)
		insertTaskItem(mTaskDespItem)
	end
	mTaskDespItem.touchLink = nil
	
	--任务背景
	local png = ""
	if pTask.mInfo.task_type=="主线" then
		png = "task_1.png"
	elseif pTask.mInfo.task_type=="支线" then
		png = "task_2.png"
	elseif pTask.mInfo.task_type=="经验" then
		png = "task_3.png"
	else
		png = "task_4.png"
	end
	
	mTaskDespItem:removeChildByName("task_bg")
	local taskImgBg = ccui.ImageView:create()
	taskImgBg:setName("task_bg")
	taskImgBg:loadTexture(png,ccui.TextureResType.plistType)
	mTaskDespItem:addChild(taskImgBg)
	taskImgBg:align(display.LEFT_TOP, 0, 67)


	local richWidget = mTaskDespItem:getChildByName("richDesp")
	if not richWidget then
		local param = {
			size = cc.size(220, 30),
			fontSize = 18, 
			space=20,
			name = "taskDesp",
			outline = {0, 0, 0,255, 1},
			shadowColor = cc.c4b(0, 0, 0, 255 * 0.5),
			shadowOffset = cc.size(2, -2),
			blurRadius = 1,
		}
		richWidget = GUIRichLabel.new(param)
		richWidget:setName("richDesp")
		mTaskDespItem:addChild(richWidget)
	end
	local strDesp, lines= buildTaskDesp(pTask)

	local mNeedSelected = mInfo.selected
	--除魔任务，杀怪数量改变，需要选中
	if taskId == 2000  and pTask.mParam_1 > 0 and mTaskDespItem.param_1 ~= pTask.mParam_1 then
		mNeedSelected = true
		mTaskDespItem.param_1 = pTask.mParam_1
	end

	local space = 5
	if lines == 3 then space = 0 end
	richWidget:setVerticalSpace(space)
	richWidget:setRichLabel(strDesp, "", 16)
	
	space = space - 12

	richWidget:align(display.LEFT_CENTER, 0, mTaskDespItem:getContentSize().height * 0.5 + space)
	richWidget:setLocalZOrder(1000)
	mTaskDespItem.touchLink = mInfo.task_target
	mTaskDespItem.netLink = mInfo.task_link

	-- local state = pTask.mState % 10
	-- local tid = math.floor(pTask.mState / 10)
	-- mTaskDespItem.state = state

	var.listTask:requestDoLayout()

	local flyInfo = nil
	if mInfo.target_fly then
		local param = string.split(mInfo.target_fly, "_")
		if #param == 2 and param[1] == "fly" then
			flyInfo = tonumber(param[2])
		end
	end
	mTaskDespItem.showGetEquip = (mInfo.target_type == "ownequip") and true or false

	if flyInfo then
		if flyInfo ~= mTaskDespItem.flyInfo then
			local showFly = true
			if not mTaskDespItem.flyInfo then showFly = false end
			mTaskDespItem.flyInfo = flyInfo
			if showFly then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY, info = mTaskDespItem.flyInfo})
			end
		end
	else
		mTaskDespItem.flyInfo = flyInfo
	end
	
	-- --处理滑动
	if mInfo.unSelected then
		mTaskDespItem:getChildByName("img_task_selected_bg"):hide():stopAllActions()
	elseif (not init) and mNeedSelected then
		onTaskSelected(mTaskDespItem, true)
	end
end

-- 模拟继续任务（主线）
local function onContinueTask(event)
	local mTaskDespItem = var.listTask:getChildByName("taskItem1000")
	if mTaskDespItem and mTaskDespItem.touchLink then 
		local equalPos = GameUtilSenior.litenerTaskLink(mTaskDespItem.touchLink)
		if mTaskDespItem.flyInfo then
			if not equalPos then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY, info = mTaskDespItem.flyInfo})
			end
		end
	end
end

function GUITaskView.init(taskModel)
	var = {
		listTask,
		itemTaskDesp,
	}
	if taskModel then
		var.listTask = taskModel:getWidgetByName("list_task"):setTouchEnabled(true):setBounceEnabled(true)--:setItemsMargin(1)
		var.itemTaskDesp = taskModel:getWidgetByName("item_task_desp")
		var.itemTaskDesp:getChildByName("img_task_selected_bg"):hide()
		
		for k,v in pairs(GameSocket.mTasks) do
			onTaskChange({cur_id = k}, true)
		end
		
		cc.EventProxy.new(GameSocket, taskModel)
			:addEventListener(GameMessageCode.EVENT_TASK_CHANGE, onTaskChange)
			:addEventListener(GameMessageCode.EVENT_CONTINUE_TASK, onContinueTask)
			:addEventListener(GameMessageCode.EVENT_SCREEN_TOUCHED, function ()
				GUILeftCenter.initGetEquip(false)
			end)
	end
end

return GUITaskView