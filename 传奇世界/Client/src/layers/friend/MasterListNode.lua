local MasterListNode = class("MasterListNode", require("src/TabViewLayer"))

local DetailNode = class("DetailNode", function() return cc.Node:create() end)

local path = "res/master/"

function MasterListNode:ctor(parentBg)
	local msgids = {APPRENTICE_SC_RECOMMEND_LIST_RET, APPRENTICE_SC_APPLY_RET, APPRENTICE_SC_SEARCH_RET}
	require("src/MsgHandler").new(self,msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_RECOMMEND_LIST, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_RECOMMEND_LIST, "ApprenticeRecommend", t)
	addNetLoading(APPRENTICE_CS_RECOMMEND_LIST, APPRENTICE_SC_RECOMMEND_LIST_RET)

	self.data = {}
	self.data.masterTab = {}

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	--背景框
    --createSprite(baseNode, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))

	local leftBg = createSprite(baseNode, path.."1.png", cc.p(30, 40), cc.p(0, 0))
	__createHelp({parent=leftBg, str=game.getStrByKey('master_student_detail_1'), pos=cc.p(35, 465)})

	local richText = require("src/RichText").new(leftBg, cc.p(15, 90), cc.size(300, 25), cc.p(0, 1), 25, 20, MColor.lable_yellow)
 	richText:addText(game.getStrByKey("master_list_tip"))
 	richText:format()

	--local rightBg = createSprite(baseNode, "res/common/bg/bg51.png", cc.p(358, 40), cc.p(0, 0))
	local rightBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(358, 40),
        cc.size(570, 500),
        5
    )
	self.rightBg = rightBg
	local topBg = CreateListTitle(rightBg, cc.p(rightBg:getContentSize().width/2, 455), 564, 43, cc.p(0.5, 0))
	createLabel(topBg, game.getStrByKey("master_my_master"), getCenterPos(topBg), cc.p(0.5, 0.5), 22, true)

	self.emptyTip = createLabel(rightBg, game.getStrByKey("master_list_empty_tip"), getCenterPos(rightBg), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.white)
	
	--createLabel(baseNode, game.getStrByKey("master_find"), cc.p(300, 530), cc.p(0, 0), 22, true, nil, nil, MColor.lable_black)
	local editeBg = createScale9Sprite(rightBg, "res/common/scalable/input_1.png", cc.p(15, 425), cc.size(400, 50), cc.p(0, 0.5))
	local editBox = createEditBox(editeBg, nil, getCenterPos(editeBg), cc.size(390, 34), MColor.white)
	editBox:setAnchorPoint(cc.p(0.5, 0.5))
	editBox:setPlaceHolder(game.getStrByKey("master_find_input"))
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	local findBtnFunc = function() 
		local nameStr = editBox:getText()
    	if string.len(nameStr) > 0 then
    		self.searchName = nameStr
    		--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_SEARCH, "iS", G_ROLE_MAIN.obj_id, nameStr)
    		local t = {}
    		t.name = nameStr
			g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_SEARCH, "ApprenticeSearch", t)
		end
	end
	local findBtn = createMenuItem(rightBg, "res/component/button/39.png", cc.p(490, 425), findBtnFunc)
	self.findBtn = findBtn
	createLabel(findBtn, game.getStrByKey("master_find"), getCenterPos(findBtn), cc.p(0.5, 0.5), 22, true)

	local systemBg = createSprite(rightBg, "res/common/bg/bg51-2.png", cc.p(rightBg:getContentSize().width/2, 375), cc.p(0.5, 0))
	createLabel(systemBg, game.getStrByKey("master_system"), getCenterPos(systemBg), cc.p(0.5, 0.5), 22, true)

	createSprite(rightBg, "res/common/bg/line7.png", cc.p(rightBg:getContentSize().width/2, 50), cc.p(0.5, 0))
	createLabel(rightBg, game.getStrByKey("master_apply_tip"), cc.p(rightBg:getContentSize().width/2, 15), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)

	self:createTableView(rightBg, cc.size(565, 295), cc.p(5, 70), true)

 --    local function detailBtnFunc()
	-- 	local node = DetailNode.new()
	-- 	self.baseNode:addChild(node)
	-- 	node:setPosition(getCenterPos(parentBg))
	-- end
	-- self.detailBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(150, 76), detailBtnFunc)

	self:updateData()
end

function MasterListNode:updateNetData()
	--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_RECOMMEND_LIST, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_RECOMMEND_LIST, "ApprenticeRecommend", t)
	addNetLoading(APPRENTICE_CS_RECOMMEND_LIST, APPRENTICE_SC_RECOMMEND_LIST_RET)
end

function MasterListNode:updateData()
	self:updatUI()
end

function MasterListNode:updatUI()
	if self.data.cd and self.data.cd ~= 0 then
		self.findBtn:setEnabled(false)
		self:getTableView():setVisible(false)

		local richText = require("src/RichText").new(self.rightBg, cc.p(self.rightBg:getContentSize().width/2, 245), cc.size(240, 30), cc.p(0.5, 0.5), 40, 24, MColor.red)
		local hour = math.floor(self.data.cd / 3600)
		--dump(hour)
		local min = math.floor((self.data.cd - hour*3600) / 60)
		--dump(min)
		local str = string.format(game.getStrByKey("master_student_detail_3"), hour, min)
	 	richText:addText(str)
	 	richText:format()
	end

	self:getTableView():reloadData()

	if #self.data.masterTab > 0 then
		self.emptyTip:setVisible(false)
	else
		self.emptyTip:setVisible(true)
	end
end

function MasterListNode:tableCellTouched(table,cell)
end

function MasterListNode:cellSizeForTable(table,idx) 
    return 73,500
end

function MasterListNode:tableCellAtIndex(table, idx)
	log("idx = "..idx)
	local record = self.data.masterTab[idx+1]

	local function applyFunc()
		if record.state == 1 then
			log("test 1")
			--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_APPLY, "iciScc", G_ROLE_MAIN.obj_id, 1, record.staticId, record.name, record.school, record.level)
			local t = {}
			t.flag = 1
			t.roleSID = record.staticId
			t.name = record.name
			t.school = record.school
			t.level = record.level
            g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_APPLY, "ApprenticeApply", t)
			addNetLoading(APPRENTICE_CS_APPLY, APPRENTICE_SC_APPLY_RET)
		else
			log("test 2")
			--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_APPLY, "iciScc", G_ROLE_MAIN.obj_id, 2, record.staticId, record.name, record.school, record.level)
			local t = {}
			t.flag = 2
			t.roleSID = record.staticId
			t.name = record.name
			t.school = record.school
			t.level = record.level
            g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_APPLY, "ApprenticeApply", t)
			addNetLoading(APPRENTICE_CS_APPLY, APPRENTICE_SC_APPLY_RET)
		end
	end

	local function createCell(cell)  
		local cellBg = createSprite(cell, "res/common/table/cell28.png", cc.p(0, 0), cc.p(0, 0))
		cellBg:setTag(10)
		local y = cellBg:getContentSize().height/2

		local schoolStrTab = {
			game.getStrByKey("zhanshi"),
			game.getStrByKey("fashi"),
			game.getStrByKey("daoshi")
		}

		createLabel(cellBg, record.name, cc.p(75, y), cc.p(0.5, 0.5), 22, true)
		createLabel(cellBg, record.level..game.getStrByKey("faction_player_level"), cc.p(200, y), cc.p(0.5, 0.5), 22, true)
		createLabel(cellBg, schoolStrTab[record.school], cc.p(290, y), cc.p(0.5, 0.5), 22, true)
		if record.online == true then
			createLabel(cellBg, game.getStrByKey("online"), cc.p(380, y), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.green)
		else
			createLabel(cellBg, game.getStrByKey("offline"), cc.p(380, y), cc.p(0.5, 0.5), 22, true)
		end

		local applyBtn = createMenuItem(cellBg, "res/component/button/39.png", cc.p(485, y), applyFunc)
		applyBtn:setTag(10)
		dump(cellBg:getChildByTag(10))
		-- if self.data.applay >= 3 then
		-- 	--applyBtn:setEnabled(false)
		-- end

		local applayStr
		local color
		if record.state == 1 then
			applayStr = game.getStrByKey("master_apply_master")
			color = MColor.lable_yellow
		else
			applayStr = game.getStrByKey("master_apply_already")
			color = MColor.green
		end
		local applyLabel = createLabel(applyBtn, applayStr, getCenterPos(applyBtn), cc.p(0.5, 0.5), 22, true)
		self.data.labelTab[idx+1] = applyLabel
		applyLabel:setTag(10)
	end

	local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()   
        createCell(cell)
    else
    	cell:removeAllChildren()
    	createCell(cell)
    end

    return cell
end

function MasterListNode:numberOfCellsInTableView(table)
   	return #self.data.masterTab
end

function MasterListNode:updateLabel(index, state)
	-- local cell = self:getTableView():cellAtIndex(index-1)
	-- dump(cell)
	-- log("test 1")
	-- if cell then
	-- 	local cellBg = cell:getChildByTag(10)
	-- 	if cellBg then
	-- 		log("test 2")
	-- 		local applyBtn = cellBg:getChildByTag(10)
	-- 		dump(applyBtn)
	-- 		if applyBtn then
	-- 			log("test 3")
	-- 			local applyLabel = applyBtn:getChildByTag(10)
	-- 			if applyLabel then
	-- 				log("test 4")
	-- 				local applayStr
	-- 				local color

	-- 				if state == 1 then
	-- 					applayStr = game.getStrByKey("master_apply_master")
	-- 					color = MColor.lable_yellow
	-- 				else
	-- 					applayStr = game.getStrByKey("master_apply_already")
	-- 					color = MColor.green
	-- 				end
	-- 				applyLabel:setString(applayStr)
	-- 				applyLabel:setColor(color)
	-- 			end
	-- 		end
	-- 	end
	-- end

	if self.data.labelTab[index] and checkNode(self.data.labelTab[index]) then
		local applayStr
		local color

		if state == 1 then
			applayStr = game.getStrByKey("master_apply_master")
			color = MColor.lable_yellow
		else
			applayStr = game.getStrByKey("master_apply_already")
			color = MColor.green
		end
		self.data.labelTab[index]:setString(applayStr)
		self.data.labelTab[index]:setColor(color)
	end
end

function MasterListNode:networkHander(buff, msgid)
	local switch = {
		[APPRENTICE_SC_RECOMMEND_LIST_RET] = function()    
			log("get APPRENTICE_SC_RECOMMEND_LIST_RET")
			local t = g_msgHandlerInst:convertBufferToTable("ApprenticeRecommendRet", buff)
			self.data = {}
			self.data.cd = t.cd
			--self.data.applay = #t.MasterRecommend
			self.data.masterTab = {}
			self.data.labelTab = {}
			for i,v in ipairs(t.list) do
				local record = {}
				record.staticId = v.roleSID
				record.name = v.name
				record.level = v.level
				record.school = v.school
				record.online = v.isOnline
				record.state = v.flag
				if record.state == 1 then
					table.insert(self.data.masterTab, #self.data.masterTab+1, record)
				else
					table.insert(self.data.masterTab, 1, record)
				end
			end
	
			dump(self.data)

			self:updateData()
		end
		,
		[APPRENTICE_SC_APPLY_RET] = function()    
			log("get APPRENTICE_SC_APPLY_RET")
			local t = g_msgHandlerInst:convertBufferToTable("ApprenticeApplyRet", buff) 
			local masterStaticId = t.roleSID
			local state = t.flag
			local index

			for i,v in ipairs(self.data.masterTab) do
				if v.staticId == masterStaticId then
					v.state = state
					index = i
				end
			end
			print("masterStaticId = "..masterStaticId)
			print("state = "..state)
			print("index = "..tostring(index))

			-- if index then
			-- 	self:updateLabel(index, state)
			-- end
			self:updateNetData()
		end
		,
		[APPRENTICE_SC_SEARCH_RET] = function()    
			log("get APPRENTICE_SC_SEARCH_RET")
			local t = g_msgHandlerInst:convertBufferToTable("ApprenticeSearchRet", buff) 
			local result = t.flag
			if result == 1 then
				--TIPS({type = 1, str = game.getStrByKey("master_find_not_found")})
				MessageBox(string.format(game.getStrByKey("master_find_not_found"), self.searchName))
			elseif result == 2 then
				--TIPS({type = 2, str = string.format(game.getStrByKey("master_find_not_available"), name)})
				MessageBox(string.format(game.getStrByKey("master_find_not_available"), self.searchName))
			elseif result == 3 then
				local staticId = t.roleSID
				local name = t.name
				local school = t.school
				local level = t.level

				local function yesFunc()
					--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_APPLY, "iciScc", G_ROLE_MAIN.obj_id, 1, staticId, name, school, level)
					local t = {}
					t.flag = 1
					t.roleSID = staticId
					t.name = name
					t.school = school
					t.level = level
		            g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_APPLY, "ApprenticeApply", t)
					addNetLoading(APPRENTICE_CS_APPLY, APPRENTICE_SC_APPLY_RET)
				end
				MessageBoxYesNo(nil, string.format(game.getStrByKey("master_find_available"), name), yesFunc)
			elseif result == 4 then
				MessageBox(string.format(game.getStrByKey("master_find_not_accept"), self.searchName))
			end
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

-- function DetailNode:ctor()
-- 	local bg = createSprite(self, "res/common/bg/bg9.png", cc.p(0, 0), cc.p(0.5, 0.5))
-- 	createLabel(applyBtn, game.getStrByKey("master_student_detail_tile"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-50), cc.p(0.5, 1), 24, true)
	
-- 	local function closeFunc()
-- 		removeFromParent(self)
-- 	end
-- 	createMenuItem(bg, "res/component/button/6.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

-- 	local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2, bg:getContentSize().height-80), cc.size(550, 30), cc.p(0.5, 1), 25, 20, MColor.lable_yellow)
--  	richText:addText(game.getStrByKey("master_student_detail_1"))
--  	richText:format()

-- 	registerOutsideCloseFunc(bg, closeFunc, true)
-- end

return MasterListNode