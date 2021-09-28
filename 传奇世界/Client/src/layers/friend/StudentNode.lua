local StudentNode = class("StudentNode", function() return cc.Node:create() end)

local TeachNode = class("TeachNode", function() return cc.Node:create() end)

local path = "res/master/"

function StudentNode:ctor(parentBg, mainLayer)
	local msgids = {APPRENTICE_SC_INFORMATION_RET, MASTER_SC_GET_WORD_RET}
	require("src/MsgHandler").new(self,msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_INFORMATION, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_INFORMATION, "ApprenticeInformation", t)
	addNetLoading(APPRENTICE_CS_INFORMATION, APPRENTICE_SC_INFORMATION_RET)

	self.data = {}
	self.parentBg = parentBg
	self.mainLayer = mainLayer
	self.level = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) or 0

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	--背景框
    --createSprite(baseNode, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))

	--local rightBg = createSprite(baseNode, "res/common/bg/bg51.png", cc.p(358, 40), cc.p(0, 0))
	local rightBg = createScale9Frame(
        baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(358, 40),
        cc.size(570, 500),
        5
    )
	self.rightBg = rightBg
	local topBg = CreateListTitle(rightBg, cc.p(rightBg:getContentSize().width/2, 455), 564, 43, cc.p(0.5, 0))
	createLabel(topBg, game.getStrByKey("master_my_master"), getCenterPos(topBg), cc.p(0.5, 0.5), 22, true)
	local masterBg = createSprite(rightBg, "res/common/table/cell28.png", cc.p(rightBg:getContentSize().width/2, 385), cc.p(0.5, 0))
	self.masterBg = masterBg

	local leftBg = createSprite(baseNode, "res/common/bg/bg45.png", cc.p(30, 40), cc.p(0, 0))
	self.leftBg = leftBg

	local function praviteBtnFunc(name)
		PrivateChat(name)
	end
	local praviteBtn = createMenuItem(leftBg, "res/component/button/2.png", cc.p(leftBg:getContentSize().width/2+75, 45), function() praviteBtnFunc(self.data.masterData.name) end)
	createLabel(praviteBtn, game.getStrByKey("private_chat"), getCenterPos(praviteBtn), cc.p(0.5, 0.5), 22, true)

	local function moreFunc(name)
        self:showOperationPanel(self.data.masterData)		
	end
	local moreBtn = createMenuItem(leftBg, "res/component/button/2.png", cc.p(leftBg:getContentSize().width/2-75, 45), function() moreFunc() end)
	createLabel(moreBtn, game.getStrByKey("chat_moreOperation"), getCenterPos(moreBtn), cc.p(0.5, 0.5), 22, true)

	createSprite(rightBg, "res/common/bg/line7.png", cc.p(rightBg:getContentSize().width/2, 125), cc.p(0.5, 0.5))

	local richText = require("src/RichText").new(rightBg, cc.p(40, 110), cc.size(510, 30), cc.p(0, 1), 30, 20, MColor.lable_black)
	self.richText = richText
 	richText:addText(game.getStrByKey("master_student_detail_2"))
 	richText:format()

 	local rewardBg = createSprite(rightBg, "res/common/bg/bg51-2.png", cc.p(rightBg:getContentSize().width/2, 360), cc.p(0.5, 0))
	createLabel(rewardBg, game.getStrByKey("master_reward"), getCenterPos(rewardBg), cc.p(0.5, 0.5), 22, true)

	self.taskInfoNode = cc.Node:create()
	self.rightBg:addChild(self.taskInfoNode)
	self.taskInfoNode:setPosition(cc.p(0, 0))

 	self:updateData()
end

function StudentNode:updateData()
	self:updateUI()
end

function StudentNode:updateUI()
	--if true then
		self:updateLeftInfo()
		--log("test 1")
		self:updateMasterInfo()
		--log("test 2")
		--self:updateReward()
		self:updateTask()
		--log("test 3")
	--end
end

function StudentNode:updateLeftInfo()
	if self.leftInfoNode == nil then
		self.leftInfoNode = cc.Node:create()
		self.leftBg:addChild(self.leftInfoNode)
		self.leftInfoNode:setPosition(cc.p(0, 0))
	end

	self.leftInfoNode:removeAllChildren()

	local function teachFunc()
		local node = TeachNode.new(self.data.teach)
		self.baseNode:addChild(node)
		node:setPosition(getCenterPos(self.parentBg))
	end
	local teachBtn = createTouchItem(self.leftInfoNode, path.."2.png", cc.p(self.leftBg:getContentSize().width/2, 450), teachFunc)
	teachBtn:setLocalZOrder(10)
	local str = self.data.teach or ""
	if string.utf8len(str) > 25 then
		str = string.utf8sub(str, 1, 25).."……"
	end
	createMultiLineLabel(teachBtn, str, cc.p(10, 55), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow, 290, 30, true)

	local function callback(roleNode)
		dump(roleNode)
		if self.leftInfoNode and checkNode(self.leftInfoNode) then
			self.leftInfoNode:addChild(roleNode)
			roleNode:setPosition(cc.p(self.leftBg:getContentSize().width/2, 240))
			roleNode:setScale(0.9)
		end
	end

	if self.data.masterData and self.data.masterData.name then
		LookupRoleNode(self.data.masterData.name, callback)
	end
end

function StudentNode:updateMasterInfo()
	self.masterBg:removeAllChildren()

	local schoolStrTab = {
			game.getStrByKey("zhanshi"),
			game.getStrByKey("fashi"),
			game.getStrByKey("daoshi")
		}

	if self.data.masterData then
		local y = self.masterBg:getContentSize().height/2
		createLabel(self.masterBg, self.data.masterData.name, cc.p(75, y), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.yellow)
		createLabel(self.masterBg, self.data.masterData.level..game.getStrByKey("faction_player_level"), cc.p(170, y), cc.p(0, 0.5), 22, true, nil, nil, MColor.lable_yellow)
		createLabel(self.masterBg, schoolStrTab[self.data.masterData.school], cc.p(260, y), cc.p(0, 0.5), 22, true, nil, nil, MColor.lable_yellow)

		if self.data.masterData.online == true then
			createLabel(self.masterBg, game.getStrByKey("online"), cc.p(370, y), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.green)
		else
			createLabel(self.masterBg, game.getStrByKey("offline"), cc.p(370, y), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_black)
		end

		local function sendFlowerFunc()
			SendFlower(self.data.masterData.name)
		end
		local sendFlowerBtn = createMenuItem(self.masterBg, "res/component/button/49.png", cc.p(480, y), sendFlowerFunc)
		createLabel(sendFlowerBtn, game.getStrByKey("send_flower_text"), getCenterPos(sendFlowerBtn), cc.p(0.5, 0.5), 22, true)
		if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
			sendFlowerBtn:setVisible(false)
		end
	end
end

function StudentNode:updateTask()
	self.taskInfoNode:removeAllChildren()

	if self.data.taskData == nil then
		return
	end

	if self.level >= 50 then
    	local outBg = createSprite(self.rightBg, path.."3.png", cc.p(self.rightBg:getContentSize().width/2, 10), cc.p(0.5, 0))
    	createLabel(outBg, 50, cc.p(340, 215), cc.p(0.5, 0.5), 30, false, nil, nil, MColor.red)

    	local function outBtnFunc(name)
	        --g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_FINISH, "i", G_ROLE_MAIN.obj_id)
	        local t = {}
			g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_FINISH, "ApprenticeFinish", t)
	        removeFromParent(self.mainLayer)
		end
		local outBtn = createMenuItem(self.rightBg, "res/component/button/2.png", cc.p(self.rightBg:getContentSize().width/2, 105), outBtnFunc)
		createLabel(outBtn, game.getStrByKey("master_out"), getCenterPos(outBtn), cc.p(0.5, 0.5), 22, true)

		removeFromParent(self.richText)

		return
    end

	if self.data.taskData.taskState == 1 then
		createLabel(self.taskInfoNode, game.getStrByKey("master_task_no_task"), cc.p(self.rightBg:getContentSize().width/2, 260), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_black)
	elseif self.data.taskData.taskState == 2 or self.data.taskData.taskState == 3 then
		local record = getConfigItemByKey("MasterTaskDB", "q_id", self.data.taskData.taskID)
		dump(record)
		if record then
			--local bg = createSprite(self.rightBg, "res/common/bg/bg36.png", cc.p(self.rightBg:getContentSize().width/2, 140), cc.p(0.5, 0.5))
			local richText = require("src/RichText").new(self.taskInfoNode, cc.p(40, 340), cc.size(490, 25), cc.p(0, 1), 40, 20, MColor.lable_black)
			
			local rewardText = ""
			if record.q_rewards_exp and tonumber(record.q_rewards_exp) > 0 then
				rewardText = rewardText..string.format(game.getStrByKey("master_task_reward_exp"), numToFatString(record.q_rewards_exp))
			end

			if record.q_rewards_money and tonumber(record.q_rewards_money) > 0 then
				rewardText = rewardText.."、"..string.format(game.getStrByKey("master_task_reward_money"), numToFatString(record.q_rewards_money))
			end

			if record.q_rewards_bindIngot and tonumber(record.q_rewards_bindIngot) > 0 then
				rewardText = rewardText.."、"..string.format(game.getStrByKey("master_task_reward_bindIngot"), numToFatString(record.q_rewards_bindIngot))
			end

			local text = ""
			text = string.format(game.getStrByKey("master_task_conent"), record.q_title, record.q_discript, rewardText, self.data.taskData.now.."/"..record.q_finish)
			dump(text)
			richText:addText(text, MColor.lable_black, false)
  			richText:format()
  			if self.data.taskData.taskState == 3 then
  				createSprite(self.taskInfoNode, "res/component/flag/2.png", cc.p(230, 190), cc.p(0.5, 0.5))
  			end
		end
	end
end

function StudentNode:updateReward()
	if self.level >= 40 then
    	local outBg = createSprite(self.rightBg, path.."3.png", cc.p(self.rightBg:getContentSize().width/2, 10), cc.p(0.5, 0))
    	createLabel(outBg, 40, cc.p(340, 215), cc.p(0.5, 0.5), 30, false, nil, nil, MColor.red)

    	local function outBtnFunc(name)
	        --g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_FINISH, "i", G_ROLE_MAIN.obj_id)
	        local t = {}
			g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_FINISH, "ApprenticeFinish", t)
	        removeFromParent(self.mainLayer)
		end
		local outBtn = createMenuItem(self.rightBg, "res/component/button/2.png", cc.p(self.rightBg:getContentSize().width/2, 105), outBtnFunc)
		createLabel(outBtn, game.getStrByKey("master_out"), getCenterPos(outBtn), cc.p(0.5, 0.5), 22, true)

		removeFromParent(self.richText)

		return
    end

	if self.data.rewardData == nil then
		return
	end

    local function createPropNode(protoId, num, pos)
    	local Mprop = require("src/layers/bag/prop")
		local iconNode = Mprop.new({cb = "tips", protoId = protoId, num = num})
		iconNode:setAnchorPoint(cc.p(0.5, 0.5))
        iconNode:setPosition(pos)
        if self.data.isReward == false then
        	createSprite(iconNode, "res/component/flag/18.png", getCenterPos(iconNode), cc.p(0.5, 0.5), 100)
	    end
        self.rightBg:addChild(iconNode)
    end

    local num = #self.data.rewardData
    local width = 400 
    local addX = width / (num-1)
    local x = self.rightBg:getContentSize().width/2 - width/2
    local y = 160

    for i,v in ipairs(self.data.rewardData) do
    	createPropNode(v.itemId, v.num, cc.p(x+(i-1)*addX, y))
    end

    local function getBtnFunc(name)
        --g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_REWARD, "i", G_ROLE_MAIN.obj_id)
        local t = {}
		g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_REWARD, "ApprenticeReward", t)
	end
	local getBtn = createMenuItem(self.rightBg, "res/component/button/2.png", cc.p(self.rightBg:getContentSize().width/2, 45), getBtnFunc)
	createLabel(getBtn, game.getStrByKey("master_get"), getCenterPos(getBtn), cc.p(0.5, 0.5), 22, true)
	if self.data.isReward == false then
    	getBtn:setEnabled(false)
    end
end

function StudentNode:showOperationPanel(masterData)
	local func = function(tag)
		local switch = {
			[1] = function() 
				LookupInfo(masterData.name)
			end,
			[2] = function() 
			  	InviteTeamUp(masterData.name)
			end,
			[3] = function()
				-- local function()
				-- 	removeFromParent(self.operateLayer)
				-- 	removeFromParent(self.mainLayer)
				-- end 
				-- BetrayMaster()
				
				g_msgHandlerInst:registerMsgHandler(MASTER_SC_OFFLINE_PUNISH_RET , function(buff)
					local t = g_msgHandlerInst:convertBufferToTable("MasterOfflinePunishRet", buff)
					local isPunish = t.punish
					if isPunish then
						local function yesFunc()
							--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_BETRAY, "ii", G_ROLE_MAIN.obj_id, masterData.staticId)
							g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_BETRAY, "ApprenticeBetray", {})
							removeFromParent(self.operateLayer)
							removeFromParent(self.mainLayer)
						end
						MessageBoxYesNo(nil,game.getStrByKey("master_delete_master_tip_1"),yesFunc)
					else
						local function yesFunc()
							--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_BETRAY, "ii", G_ROLE_MAIN.obj_id, masterData.staticId)
							g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_BETRAY, "ApprenticeBetray", {})
							removeFromParent(self.operateLayer)
							removeFromParent(self.mainLayer)
						end
						MessageBoxYesNo(nil,game.getStrByKey("master_delete_master_tip_2"),yesFunc)
					end
				end)

				--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_OFFLINE_PUNISH, "i", G_ROLE_MAIN.obj_id)
				local t = {}
				g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_OFFLINE_PUNISH, "MasterOfflinePunish", t)
			end,
		}
		if switch[tag] then 
			switch[tag]() 
		end
		removeFromParent(self.operateLayer)
		self.operateLayer = nil
	end

	local menus = {
		{game.getStrByKey("look_info"), 1, func},
		{game.getStrByKey("re_team"), 2, func},
		{game.getStrByKey("betray_master"), 3, func},
	}

    self.operateLayer = require("src/OperationLayer").new(G_MAINSCENE, 1, menus, "res/component/button/2", "res/common/scalable/7.png")
    self.operateLayer:setPosition(-360, -105)
end

function StudentNode:networkHander(buff,msgid)
	local switch = {
		[APPRENTICE_SC_INFORMATION_RET] = function()    
			log("get APPRENTICE_SC_INFORMATION_RET"..msgid)
			local t = g_msgHandlerInst:convertBufferToTable("ApprenticeInformationRet", buff) 
			dump(t)
			self.data.masterData = {}
			self.data.masterData.staticId = t.roleSID
			self.data.masterData.name = t.name
			self.data.masterData.level = t.level
			self.data.masterData.school = t.school
			self.data.masterData.online = t.isOnline
			self.data.taskData = {}
			self.data.taskData.taskState = t.taskState
			self.data.taskData.taskID = t.taskID
			self.data.taskData.now = t.now

			-- self.data.isReward = t.canReward
			-- --self.data.recwardCount = #t.reward
			-- self.data.rewardData = {}
			-- for i,v in ipairs(t.reward) do
			-- 	local record = {}
			-- 	record.itemId = v.itemID
			-- 	record.num = v.count
			-- 	table.insert(self.data.rewardData, #self.data.rewardData+1, record)
			-- end

			dump(self.data)

			--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_GET_WORD, "ii", G_ROLE_MAIN.obj_id, self.data.masterData.staticId)
			local t = {}
			t.roleSID = self.data.masterData.staticId
			g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_GET_WORD, "MasterGetWord", t)
			addNetLoading(MASTER_CS_GET_WORD, MASTER_SC_GET_WORD_RET)

			self:updateData()
		end,

		[MASTER_SC_GET_WORD_RET] = function() 
			log("MASTER_SC_GET_WORD_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterGetWordRet", buff) 
			self.data.teach = t.word
			if self.data.teach == "" then
				self.data.teach = game.getStrByKey("master_teach_no_teach")
			end 
			dump(self.data.teach)

			self:updateData()
		end,
	
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function TeachNode:ctor(str)
	str = str or ""

	local bg = createSprite(self, "res/common/bg/bg31.png", cc.p(0, 0), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("master_master_teach"), cc.p(bg:getContentSize().width/2, 247), cc.p(0.5, 0), 22, true)

	local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2, 160), cc.size(320, 30), cc.p(0.5, 0.5), 25, 20, MColor.lable_yellow)
 	richText:addText(str)
 	richText:format()

 	local function closeFunc()
		removeFromParent(self)
	end
	local closeBtn = createMenuItem(bg, "res/component/button/2.png", cc.p(bg:getContentSize().width/2, 50), closeFunc)
	createLabel(closeBtn, game.getStrByKey("sure"), getCenterPos(closeBtn), cc.p(0.5, 0.5), 22, true)

	registerOutsideCloseFunc(bg, closeFunc, true)
end

return StudentNode