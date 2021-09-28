local MasterNode = class("MasterNode", function() return cc.Node:create() end)

local StudentListLayer = class("StudentListLayer", require("src/TabViewLayer"))
local ApplyListLayer = class("ApplyListLayer", require("src/TabViewLayer"))

local DetailNode = class("DetailNode", function() return cc.Node:create() end)

local TeachNode = class("TeachNode", function() return cc.Node:create() end)

local TaskNode = class("TaskNode", function() return cc.Node:create() end)

function MasterNode:ctor(parentBg, mainLayer)
    local msgids = {MASTER_SC_INFORMATION_RET, MASTER_SC_APPLY_LIST_RET, MASTER_SC_GET_WORD_RET, MASTER_SC_GET_EXPERIENCE_RET}
	require("src/MsgHandler").new(self, msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_INFORMATION, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_INFORMATION, "MasterInformation", t)
	addNetLoading(MASTER_CS_INFORMATION, MASTER_SC_INFORMATION_RET)

	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_GET_WORD, "ii", G_ROLE_MAIN.obj_id, 0)
	local t = {}
	t.roleSID = 0
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_GET_WORD, "MasterGetWord", t)
	addNetLoading(MASTER_CS_GET_WORD, MASTER_SC_GET_WORD_RET)

	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_GET_EXPERIENCE, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_GET_EXPERIENCE, "MasterGetExperience", t)
	addNetLoading(MASTER_CS_GET_EXPERIENCE, MASTER_SC_GET_EXPERIENCE_RET)

	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_APPLY_LIST, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_APPLY_LIST, "MasterApplyList", t)
	addNetLoading(MASTER_CS_APPLY_LIST, MASTER_SC_APPLY_LIST_RET)

	--数据
    self.data = {}
    self.mainLayer = mainLayer

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

    --背景框
    --createSprite(baseNode, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))
    --tab背景
    --createSprite(baseNode, "res/common/bg/bg68.png", cc.p(122, 330), cc.p(0.5, 0.5))
	local leftBg = createScale9Frame(
        baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(30, 40),
        cc.size(185,502),
        5
    )
    --view背景
    --createSprite(baseNode, "res/common/bg/bg60.png", cc.p(574, 330), cc.p(0.5, 0.5))
	createScale9Frame(
        baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(220, 40),
        cc.size(710,502),
        5
    )
    --名称 战斗力 等级 职业 状态等label
	CreateListTitle(baseNode, cc.p(223, 514), 702, 43, cc.p(0, 0.5))
    createLabel(baseNode, game.getStrByKey("show_flowers3"), cc.p(316, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(baseNode, game.getStrByKey("combat_power"), cc.p(596, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(baseNode, game.getStrByKey("level"), cc.p(471, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(baseNode, game.getStrByKey("school"), cc.p(706, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(baseNode, game.getStrByKey("state"), cc.p(834, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)

    --左侧tab按钮
 --    self.m_tab1 = createTouchItem(baseNode, "res/component/button/40.png", cc.p(122, 500), function(sender) self:setTab(sender, 1) end)
	-- createLabel(self.m_tab1, game.getStrByKey("master_student"), getCenterPos(self.m_tab1), cc.p(0.5, 0.5), 24, true)

 --    self.m_tab2 = createTouchItem(baseNode, "res/component/button/40.png", cc.p(122, 428), function(sender) self:setTab(sender, 2) end)
	-- createLabel(self.m_tab2, game.getStrByKey("master_history"), getCenterPos(self.m_tab2), cc.p(0.5, 0.5), 24, true)

	local textTab = {
		game.getStrByKey("master_student"),
		game.getStrByKey("master_history")
	}
	local callback = function(idx)
		log("idx = "..idx)
		self:setTab(idx)
	end
	self.leftSelectNode = require("src/LeftSelectNode").new(leftBg, textTab, cc.size(200, 465), cc.p(2, 30), callback)

    --view
    self.studentListLayer = StudentListLayer.new(self)	
	self.studentListLayer:setPosition(cc.p(224, 121))
    baseNode:addChild(self.studentListLayer)

    --选择的索引
    self.m_curSelDataIndex = 0

 --    local function detailBtnFunc()
	-- 	local node = DetailNode.new()
	-- 	self.baseNode:addChild(node)
	-- 	node:setPosition(getCenterPos(parentBg))
	-- end
	-- local detailBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(290, 76), detailBtnFunc)
	-- self.detailBtn = detailBtn
	-- createLabel(detailBtn, game.getStrByKey("master_master_detail_tile"), getCenterPos(detailBtn), cc.p(0.5, 0.5), 22, true)
	local detailBtn = __createHelp({parent=baseNode, str=game.getStrByKey('master_master_detail_1'), pos=cc.p(125, 76)})
	-- detailBtn:setImages("res/component/button/2.png")
	-- createLabel(detailBtn, game.getStrByKey("master_master_detail_tile"), getCenterPos(detailBtn), cc.p(0.5, 0.5), 22, true)
	self.detailBtn = detailBtn

	local function taskBtnFunc()
		self.taskLayer = TaskNode.new(self)	
	    self.baseNode:addChild(self.taskLayer)
	    self.taskLayer:setPosition(getCenterPos(parentBg))
	end
	local taskBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(290, 76), taskBtnFunc)
	self.taskBtn = taskBtn
	createLabel(taskBtn, game.getStrByKey("master_task_send"), getCenterPos(taskBtn), cc.p(0.5, 0.5), 22, true)

	local function applyBtnFunc()
		self.applyListLayer = ApplyListLayer.new(self)	
	    self.baseNode:addChild(self.applyListLayer)
	    self.applyListLayer:setPosition(getCenterPos(parentBg))

	    --g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_APPLY_LIST, "i", G_ROLE_MAIN.obj_id)
	    local t = {}
		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_APPLY_LIST, "MasterApplyList", t)
		addNetLoading(MASTER_CS_APPLY_LIST, MASTER_SC_APPLY_LIST_RET)
	end
	local applyBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(480, 76), applyBtnFunc)
	self.applyBtn = applyBtn
	createLabel(applyBtn, game.getStrByKey("master_apply_list"), getCenterPos(applyBtn), cc.p(0.5, 0.5), 22, true)

	local function teachBtnFunc()
		self.teachNode = TeachNode.new(self.data.teach)	
	    self.baseNode:addChild(self.teachNode)
	    self.teachNode:setPosition(getCenterPos(parentBg))

	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=1})
	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=2})
	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=3})
	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=4})
	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=5})
	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=6})
	 	-- self:addHistoryData({time=os.time(), name="李霸天", flag=7})
	end
	local teachBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(670, 76), teachBtnFunc)
	self.teachBtn = teachBtn
	createLabel(teachBtn, game.getStrByKey("master_master_teach"), getCenterPos(teachBtn), cc.p(0.5, 0.5), 22, true)

	local function moreFunc()
		dump(self.m_curSelDataIndex)
        local record = nil
        if self.m_curTab == 1 then
            record = self.data.studentTab[self.m_curSelDataIndex]
        end

        if record == nil then
            return
        end

        self:showOperationPanel(record)		
	end
	local moreBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(860, 76), moreFunc)
	moreBtn:setEnabled(false)
	self.moreBtn = moreBtn
	createLabel(moreBtn, game.getStrByKey("chat_moreOperation"), getCenterPos(moreBtn), cc.p(0.5, 0.5), 22, true)

	-- local function checkFunc()
	-- 	if self.checkFlag:isVisible() then
	-- 		self.checkFlag:setVisible(false)
	-- 		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_INITIATIVE_APPLY, "ib", G_ROLE_MAIN.obj_id, true)
	-- 		local t = {}
	-- 		t.initiative = true
	-- 		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_INITIATIVE_APPLY, "MasterInitiative", t)
	-- 	else
	-- 		self.checkFlag:setVisible(true)
	-- 		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_INITIATIVE_APPLY, "ib", G_ROLE_MAIN.obj_id, false)
	-- 		local t = {}
	-- 		t.initiative = false
	-- 		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_INITIATIVE_APPLY, "MasterInitiative", t)
	-- 	end
	-- end
	-- local checkbox = createTouchItem(baseNode, "res/component/checkbox/1.png", cc.p(50, 76), checkFunc)
	-- self.checkFlag = createSprite(checkbox, "res/component/checkbox/1-1.png", getCenterPos(checkbox), cc.p(0.5, 0.5))
	-- self.checkFlag:setVisible(false)
	-- createLabel(baseNode, game.getStrByKey("master_check_tip"), cc.p(70, 76), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow)

    self:setTab(1)

    local function eventCallback(eventType)
        if eventType == "enter" then
        elseif eventType == "exit" then
        end
    end
    self:registerScriptHandler(eventCallback)
end

function MasterNode:updateData()
	self:updateUI()
end

function MasterNode:updateUI()
	-- if self.data.isAccept then
	-- 	self.checkFlag:setVisible(false)
	-- else
	-- 	self.checkFlag:setVisible(true)
	-- end

	if self.data.hasTask then
		self.taskBtn:setEnabled(true)
	else
		self.taskBtn:setEnabled(false)
	end

	--dump(self.data)
	if self.data.studentTab and #self.data.studentTab == 0 then
		self.taskBtn:setEnabled(false)
	end
end

function MasterNode:setTab(idx)
	dump(idx)
    -- if self.m_curTab == idx then
    --     return
    -- end
    
    -- self.m_tab1:setTexture("res/component/button/40.png");
    -- self.m_tab2:setTexture("res/component/button/40.png");
    -- sender:setTexture("res/component/button/40_sel.png");

    -- if self.m_arrow == nil then
    --     self.m_arrow = createSprite(self.baseNode, "res/group/arrows/9.png", cc.p(0, 0), cc.p(0, 0.5))
    -- end

    -- self.m_arrow:setPosition(sender:getContentSize().width/2 + sender:getPositionX(), sender:getPositionY());

    -- --选择view
    self.m_curSelDataIndex = 0
    self.m_curTab = idx
    if idx == 1 then
        self.detailBtn:setVisible(true)
        self.applyBtn:setVisible(true)
        self.teachBtn:setVisible(true)
        self.moreBtn:setVisible(true)

        self.moreBtn:setEnabled(false)

        self.studentListLayer:updateData(self.data.studentTab)

        self:updateHistoryNode(false)
    else
        self.detailBtn:setVisible(false)
        self.applyBtn:setVisible(false)
        self.teachBtn:setVisible(false)
        self.moreBtn:setVisible(false)

        self.studentListLayer:updateData(self.data.studentTab)

        self:updateHistoryNode(true)
    end   
    --AudioEnginer.playTouchPointEffect()
end

function MasterNode:updateHistoryNode(isShow)
	if self.historyNode == nil then
		self.historyNode = cc.Node:create()
		self.baseNode:addChild(self.historyNode)
	end

	self.historyNode:removeAllChildren()

	if isShow == false then
		return
	end

	self:getHistoryData()
	dump(self.data.historyData.localData)

	local bg = createScale9Frame(
		self.historyNode,
		"res/common/scalable/panel_outer_base_1.png",
		"res/common/scalable/panel_outer_frame_scale9_1.png",
		cc.p(218, 39),
		cc.size(710, 501),
		4
	)

	local baseNode = cc.Node:create()

	local scrollView = cc.ScrollView:create()	  
	scrollView:setViewSize(cc.size(675, 460))
	scrollView:setPosition(cc.p(20, 10))
	scrollView:setScale(1.0)
	--scrollView:ignoreAnchorPointForPosition(true)
	scrollView:setContainer(baseNode)
	scrollView:updateInset()
	scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	scrollView:setClippingToBounds(true)
	scrollView:setBounceable(true)
	scrollView:setDelegate()
	bg:addChild(scrollView)

	local addNodeTab = {}

	-- local x = 0
	-- local y = 0
	-- local padding = 10

	for i,v in ipairs(self.data.historyData.localData.studentData) do
		local richText = require("src/RichText").new(baseNode, cc.p(0, 0), cc.size(550, 25), cc.p(0, 0), 25, 20, MColor.lable_black)
	 	richText:addText(v)
	 	richText:format()
	 	table.insert(addNodeTab, #addNodeTab+1, {node=richText, height=30})
	end

	local title1Bg = createSprite(baseNode, "res/common/bg/infoBg16-2.png", cc.p(0, 0), cc.p(0, 0))
	createLabel(title1Bg, game.getStrByKey("master_history_hittory"), getCenterPos(title1Bg), cc.p(0.5, 0.5), 22, true)
	table.insert(addNodeTab, #addNodeTab+1, {node=title1Bg, height=30})

	local allNode = cc.Node:create()
	baseNode:addChild(allNode)
	allNode:setContentSize(cc.size(650, 90))
	--allNode:setAnchorPoint(cc.p(0, 0))
	createLabel(allNode, game.getStrByKey("master_history_student_num").."："..self.data.historyData.studentNum, cc.p(50, 45), cc.p(0, 0), 20, true)
	createLabel(allNode, game.getStrByKey("master_history_student_out_num").."："..self.data.historyData.studentOutNum, cc.p(270, 45), cc.p(0, 0), 20, true)
	createLabel(allNode, game.getStrByKey("master_history_fower_num").."："..self.data.historyData.flowerNum, cc.p(480, 45), cc.p(0, 0), 20, true)
	createLabel(allNode, game.getStrByKey("master_history_student_finish_num").."："..self.data.historyData.studentFinishNum, cc.p(50, 0), cc.p(0, 0), 20, true)
	createLabel(allNode, game.getStrByKey("master_history_student_betray_num").."："..self.data.historyData.studentBetrayNum, cc.p(270, 0), cc.p(0, 0), 20, true)
	table.insert(addNodeTab, #addNodeTab+1, {node=allNode, height=90})

	local title2Bg = createSprite(baseNode, "res/common/bg/infoBg16-2.png", cc.p(0, 0), cc.p(0, 0))
	createLabel(title2Bg, game.getStrByKey("master_history_master"), getCenterPos(title2Bg), cc.p(0.5, 0.5), 22, true)
	table.insert(addNodeTab, #addNodeTab+1, {node=title2Bg, height=30})

	for i,v in ipairs(self.data.historyData.localData.masterData) do
		local richText = require("src/RichText").new(baseNode, cc.p(0, 0), cc.size(550, 25), cc.p(0, 0), 25, 20, MColor.lable_black)
	 	richText:addText(v)
	 	richText:format()
	 	table.insert(addNodeTab, #addNodeTab+1, {node=richText, height=30})
	end

	local title3Bg = createSprite(baseNode, "res/common/bg/infoBg16-2.png", cc.p(0, 0), cc.p(0, 0))
	createLabel(title3Bg, game.getStrByKey("master_history_student"), getCenterPos(title3Bg), cc.p(0.5, 0.5), 22, true)
	table.insert(addNodeTab, #addNodeTab+1, {node=title3Bg, height=30})

	local x = 0
	local y = 0
	local padding = 10
	for i,v in ipairs(addNodeTab) do
		v.node:setAnchorPoint(cc.p(0, 0))
		v.node:setPosition(x, y)
		y = y + v.height + padding
		log("y = "..y)
		--log(i.." v:getContentSize().height = "..v:getContentSize().height)
	end

	scrollView:setContentSize(cc.size(675, y))
	if y < 460 then
	 	scrollView:setContentOffset(cc.p(0,460-y),false)
	else
		scrollView:setContentOffset(cc.p(0,0),false)
	end
end

function MasterNode:addHistoryData(param)

	local actionStr = 
	{
		[1] = {str=game.getStrByKey("master_str_history_1"), dir="/master_", isMaster=true},
		[2] = {str=game.getStrByKey("master_str_history_2"), dir="/master_", isMaster=true},
		[3] = {str=game.getStrByKey("master_str_history_3"), dir="/master_", isMaster=true},
		[4] = {str=game.getStrByKey("master_str_history_4"), dir="/student_", isMaster=false},
		[5] = {str=game.getStrByKey("master_str_history_5"), dir="/student_", isMaster=false},
		[6] = {str=game.getStrByKey("master_str_history_6"), dir="/student_", isMaster=false},
		[7] = {str=game.getStrByKey("master_str_history_7"), dir="/student_", isMaster=false},
	}

	local record = actionStr[param.flag]
	--dump(record)
	if record.isMaster then
		local data = {}
		local fileName = getDownloadDir().."master_"..tostring(userInfo.currRoleStaticId)..".cfg"
		local file = io.open(fileName, "r")

		if not file then
			file = io.open(fileName, "w")
			if file then 
				file:close()
				file = io.open(fileName, "r")
			end
		end

		if file then
			local str = file:read()
			while str do
				table.insert(data, str)
				str = file:read()
			end

			local timeStr = os.date(game.getStrByKey("master_master_history_time"), param.time)
			local actionStr = string.format(record.str, param.name or "")
			local str
			if timeStr and actionStr then
				str = timeStr..actionStr
			end
			dump(data)
			if str then
				table.insert(data, #data+1, str)
			end

			while #data > 50 do
				table.remove(data, 1)
			end
			file:close()
		end

		local file = io.open(fileName, "w+")
		if file then
			dump(data)
			for i,v in ipairs(data) do
			 	file:write(v)
				file:write("\n")
			end
			file:close() 
		end
	else
		local data = {}
		local fileName = getDownloadDir().."student_"..tostring(userInfo.currRoleStaticId)..".cfg"
		local file = io.open(fileName, "r")

		if not file then
			file = io.open(fileName, "w")
			if file then 
				file:close()
				file = io.open(fileName, "r")
			end
		end

		if file then
			local str = file:read()
			while str do
				table.insert(data, str)
				str = file:read()
			end

			local timeStr = os.date(game.getStrByKey("master_master_history_time"), param.time)
			local actionStr = string.format(record.str, param.name or "")
			local str
			if timeStr and actionStr then
				str = timeStr..actionStr
			end

			if str then
				table.insert(data, #data+1, str)
			end

			while #data > 50 do
				table.remove(data, 1)
			end
			file:close()
		end

		local file = io.open(fileName, "w+")
		if file then
			for i,v in ipairs(data) do
			 	file:write(v)
				file:write("\n")
			end
			file:close() 
		end
	end
end

function MasterNode:getHistoryData()
	if self.data.historyData == nil then
		self.data.historyData = {}
	end
	self.data.historyData.localData = {}
	self.data.historyData.localData.masterData = {}
	self.data.historyData.localData.studentData = {}

	local fileName = getDownloadDir().."master_"..tostring(userInfo.currRoleStaticId)..".cfg"
	local file = io.open(fileName, "r")
	if file then
		local str = file:read()
		while str do
			table.insert(self.data.historyData.localData.masterData, 1, str)
			str = file:read()
		end
		file:close()
	end

	local fileName = getDownloadDir().."student_"..tostring(userInfo.currRoleStaticId)..".cfg"
	local file = io.open(fileName, "r")
	if file then
		local str = file:read()
		while str do
			table.insert(self.data.historyData.localData.studentData, 1, str)
			str = file:read()
		end
		file:close()
	end

	if self.data.historyData.outData 
		and self.data.historyData.outData.masterStaticId
		and self.data.historyData.outData.masterName
		and self.data.historyData.outData.time and self.data.historyData.outData.time > 0 then
			local timeStr = os.date(game.getStrByKey("master_master_history_time"), self.data.historyData.outData.time)
			local actionStr = game.getStrByKey("master_str_history_8")
			local str
			if timeStr and actionStr then
				str = timeStr..actionStr
				if str then
					table.insert(self.data.historyData.localData.masterData, 1, str)
				end
			end
	end
end

function MasterNode:reloadNetData()
	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 3)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})
	addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)
end

function MasterNode:onSelDataIndex(index)
    self.m_curSelDataIndex = index

    if self.m_curTab == 1 then
        self.moreBtn:setEnabled(true)
    else
        self.moreBtn:setEnabled(false)
    end
end

function MasterNode:showOperationPanel(record)
	local func = function(tag)
		local switch = {
			[1] = function() 
				PrivateChat(record.name)
			end,
			[2] = function() 
				LookupInfo(record.name)
			end,
			[3] = function() 
			  	AddFriends(record.name)
			end,
			[4] = function() 
			  	local layer = require("src/layers/friend/SendFlowerLayer").new({[1]=record.roleId, [2]=record.name})
				Manimation:transit(
				{
					ref = G_MAINSCENE.base_node,
					node = layer,
					sp = g_scrCenter,
					ep = g_scrCenter,
					zOrder = 200,
					curve = "-",
					swallow = true,
				})
			end,
            [5] = function()
            	dump(record)
			  	if record.level < 50 then
			  		local function yesFunc()
			  			--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_EXPEL, "ii", G_ROLE_MAIN.obj_id, record.staticId)
			  			local t = {}
			  			t.roleSID = record.staticId
						g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_EXPEL, "MasterExpel", t)
			  		end

			  		local str = string.format(game.getStrByKey("master_delete_student_tip_1"), record.name)
			  		if record.state > 4*24*3600  then
			  			str = string.format(game.getStrByKey("master_delete_student_tip_2"), record.name)
			  		end
			  		MessageBoxYesNo(nil, str, yesFunc)
				else
					--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_FINISH, "ii", G_ROLE_MAIN.obj_id, record.staticId)
					local t = {}
					t.roleSID = record.staticId
					g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_FINISH, "MasterFinish", t)
				end
			end,
		}
		if switch[tag] then 
			switch[tag]() 
		end
		removeFromParent(self.operateLayer)
		self.operateLayer = nil
	end
	local menus = {
		{game.getStrByKey("chat_personal"), 1, func},
		{game.getStrByKey("look_info"), 2, func},
		{game.getStrByKey("add_friend"), 3, func},
		{game.getStrByKey("send_flower_text"), 4, func},
		--{game.getStrByKey("be_master"), 5, func},
	}

	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
		table.remove(menus, 4)
	end

	if record.level < 50 then
		table.insert(menus, #menus+1, {game.getStrByKey("master_delete_student"), 5, func})
	else
		table.insert(menus, #menus+1, {game.getStrByKey("master_out"), 5, func})
	end

    self.operateLayer = require("src/OperationLayer").new(G_MAINSCENE, 1, menus,"res/component/button/2","res/common/scalable/7.png")
    self.operateLayer:setPosition(380, -40)
end

function MasterNode:addRed(isAdd)
	if self.applyBtn and self.applyBtn:getChildByTag(10) then
		log("remove child 10")
		self.applyBtn:removeChildByTag(10)
	end

	if isAdd then
		local red = createSprite(self.applyBtn, "res/component/flag/red.png", cc.p(self.applyBtn:getContentSize().width-10, self.applyBtn:getContentSize().height-10), cc.p(0.5, 0.5))
		red:setTag(10)
	end
end

function MasterNode:close()
	if self.mainLayer then
		removeFromParent(self.mainLayer)
	end
end

function MasterNode:networkHander(buff, msgid)
	local switch = {	
		[MASTER_SC_INFORMATION_RET] = function() 
			log("MASTER_SC_INFORMATION_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterInformationRet", buff) 
			self.data.studentTab = {}
			self.data.isAccept = t.initiative
			self.data.hasTask = t.hasTask
			for i,v in ipairs(t.list) do
				local record = {}
				record.staticId = v.roleSID
				record.name = v.name
				record.battle = v.battle
				record.level = v.level
				record.school = v.school
				record.state = v.isOnline
				record.finishTask = v.finishTask
				
				table.insert(self.data.studentTab, #self.data.studentTab+1, record)
			end

			dump(self.data)
			self:updateData()
			self.studentListLayer:updateData(self.data.studentTab)
		end,

		[MASTER_SC_APPLY_LIST_RET] = function() 
			log("MASTER_SC_APPLY_LIST_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterApplyListRet", buff)
			self.data.applyTab = {}

			for i,v in ipairs(t.list) do
				local record = {}
				record.staticId = v.roleSID
				record.name = v.name
				record.level = v.level
				record.school = v.school
				record.online = v.isOnline
				table.insert(self.data.applyTab, #self.data.applyTab+1, record)
			end
			
			dump(self.data.applyTab)
			dump(#self.data.applyTab)
			if #self.data.applyTab > 0 then
				self:addRed(true)
			else
				self:addRed(false)
			end

			if self.applyListLayer and self.applyListLayer.updateData then
				self.applyListLayer:updateData(self.data.applyTab, self.data.isAccept)
			end
		end,

		[MASTER_SC_GET_WORD_RET] = function() 
			log("MASTER_SC_GET_WORD_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterGetWordRet", buff) 
			self.data.teach = t.word
			dump(self.data.teach)
		end,
		
		[MASTER_SC_GET_EXPERIENCE_RET] = function() 
			log("MASTER_SC_GET_EXPERIENCE_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterGetExperienceRet", buff) 
			self.data.historyData = {}
			self.data.historyData.studentNum = t.totalApprentice
			self.data.historyData.studentOutNum = t.totalExpel
			self.data.historyData.flowerNum = t.totalFlower
			self.data.historyData.studentFinishNum = t.totalFinish
			self.data.historyData.studentBetrayNum = t.totalBetray

			self.data.historyData.outData = {}
			self.data.historyData.outData.masterStaticId = t.finalMaster
			self.data.historyData.outData.masterName = t.finalName
			self.data.historyData.outData.time = t.finishTime
			dump(self.data.historyData)
		end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end

------------------------------------------------------------------------------------------------
function StudentListLayer:ctor(mainLayer)
	self.mainLayer = mainLayer
	self.data = {}

	self:createTableView(self, cc.size(704, 372), cc.p(0, 0), true, true)
end

function StudentListLayer:updateData(data)
	if data then
		self.data = data

		if self.richText then
			removeFromParent(self.richText)
			self.richText = nil
		end
		dump(self:numberOfCellsInTableView())
		if self:numberOfCellsInTableView() <= 0 then
			local richText = require("src/RichText").new(self, cc.p(80, 290), cc.size(560, 30), cc.p(0, 1), 30, 20, MColor.white)
			self.richText = richText
		 	richText:addText(game.getStrByKey("master_no_student_tip"))
		 	richText:format()
		end
	end

	self:updateUI()
end

function StudentListLayer:updateUI()
	self:getTableView():reloadData()
end

function StudentListLayer:clearSelected()
	if self.selectIndex then
		local selectCell = self:getTableView():cellAtIndex(self.selectIndex)
		if selectCell then
			local flagSpr = selectCell:getChildByTag(10)
			if flagSpr then
				removeFromParent(flagSpr)
			end

            local lab = selectCell:getChildByTag(11)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
            lab = selectCell:getChildByTag(12)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
            lab = selectCell:getChildByTag(13)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
            lab = selectCell:getChildByTag(14)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
		end
	end
	self.selectIndex = nil
end

function StudentListLayer:tableCellTouched(table, cell)
	local index = cell:getIdx()

	if self.selectIdx == index then
		return 
	else
		self:clearSelected()

		local flagSpr = createSprite(cell, "res/common/bg/titleBg4-1.png", cc.p(0, 35), cc.p(0, 0.5))
        flagSpr:setScale(1.44, 1.4)
		flagSpr:setTag(10)

        local lab = cell:getChildByTag(11)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
        lab = cell:getChildByTag(12)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
        lab = cell:getChildByTag(13)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
        lab = cell:getChildByTag(14)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
	end

	self.selectIndex = index
    self.mainLayer:onSelDataIndex(index+1)
end

function StudentListLayer:cellSizeForTable(table, idx) 
    return 70, 490
end

function StudentListLayer:tableCellAtIndex(table, idx)
	local record = self.data[idx+1]

	local cell = table:dequeueCell()

	local function getSchoolStr(school, sex)
		local sexStrTab = 
		{
			game.getStrByKey("man"),
			game.getStrByKey("female"),
		}
		local schoolStrTab = 
		{
			game.getStrByKey("zhanshi"),
			game.getStrByKey("fashi"),
			game.getStrByKey("daoshi"),
		}

		return schoolStrTab[school]
	end

	local function getStateStr(state)
		-- if state == 1 then
		-- 	return game.getStrByKey("master_time_str_1")
		-- elseif state == 2 then
		-- 	return game.getStrByKey("master_time_str_2")
		-- elseif state == 3 then
		-- 	return game.getStrByKey("master_time_str_3")
		-- elseif state == 4 then
		-- 	return game.getStrByKey("master_time_str_4")
		-- elseif state == 5 then
		-- 	return game.getStrByKey("master_time_str_5")
		-- else
		-- 	return game.getStrByKey("master_time_str_6")
		-- end

		dump(state)

		if state == -1 then
			return game.getStrByKey("master_time_str_1")
		elseif state == 0 then
			return game.getStrByKey("master_time_str_2")
		elseif state > 0 then
			if state < 3600 then
				return game.getStrByKey("master_time_str_3")
			elseif state < 24 * 3600 then
				return string.format(game.getStrByKey("master_time_str_7"), math.ceil(state/3600))
			else
				local day = math.floor(state/(24*3600))
				if day > 4 then
					day = 4
				end
				return string.format(game.getStrByKey("master_time_str_8"), day)
			end
		end
	end

	local function getStateColor(state)
		if state == -1 or state == 0 then
			return MColor.green
		else
			return MColor.lable_black
		end
	end

	local function createCellContent(cell)
		local posY = 35
		createSprite(cell, "res/common/table/cell21.png", cc.p(0, 0), cc.p(0, 0))
		createLabel(cell, record.name, cc.p(90, posY), cc.p(0.5, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),11)
        createLabel(cell, tostring(record.battle), cc.p(385, posY), cc.p(0.5, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),12)
		createLabel(cell, record.level..game.getStrByKey("faction_player_level"), cc.p(225, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),13)
		createLabel(cell, getSchoolStr(record.school, record.sex), cc.p(460, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),14)
		if record.state == -1 then
			local function outBtnFunc()
				local t = {}
				t.roleSID = record.staticId
				dump(record)
				g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_FINISH, "MasterFinish", t)
			end
			local outBtn = createMenuItem(cell, "res/component/button/39.png", cc.p(610, posY), outBtnFunc)
			createLabel(outBtn, game.getStrByKey("master_time_str_1"), getCenterPos(outBtn), cc.p(0.5, 0.5), 22, true)
		else
			createLabel(cell, getStateStr(record.state), cc.p(580, posY), cc.p(0, 0.5), 22, true, nil, nil, getStateColor(record.state))
		end

		if record.finishTask then
			createSprite(cell, "res/component/flag/2.png", cc.p(315, posY), cc.p(0.5, 0.5))
		end

		if idx == self.selectIdx then
			local flagSpr = createSprite(cell, "res/common/bg/titleBg4-1.png", cc.p(0, posY), cc.p(0, 0.5))
			flagSpr:setScale(1.44, 1.4)
			flagSpr:setTag(10)
		end
	end

	if nil == cell then
		cell = cc.TableViewCell:new() 
		createCellContent(cell)
    else
    	cell:removeAllChildren()
    	createCellContent(cell)
    end

    return cell
end

function StudentListLayer:numberOfCellsInTableView(table)
	return #self.data
end
------------------------------------------------------------------------------------------------
function ApplyListLayer:ctor(mainLayer)
	self.mainLayer = mainLayer
	self.data = {}

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(0, 0), cc.p(0.5, 0.5))
	local rootSize = bg:getContentSize()
	-- 背景图
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 17),
       	cc.size(rootSize.width-60, rootSize.height-74),
        5
    )
	self.bg = bg
	createLabel(bg, game.getStrByKey("master_apply_list"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-27), cc.p(0.5, 0.5), 22, true)

	self.emptyTip = createLabel(bg, game.getStrByKey("master_tip_apply_empty"), getCenterPos(bg), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.white)
	self.emptyTip:setVisible(false)

	local function checkFunc()
		if self.checkFlag:isVisible() then
			self.checkFlag:setVisible(false)
			--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_INITIATIVE_APPLY, "ib", G_ROLE_MAIN.obj_id, true)
			local t = {}
			t.initiative = true
			g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_INITIATIVE_APPLY, "MasterInitiative", t)

			if self.mainLayer.data then
				self.mainLayer.data.isAccept = true
				--dump(self.mainLayer.data)
			end
			self.isAccept = self.mainLayer.data.isAccept
		else
			self.checkFlag:setVisible(true)
			--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_INITIATIVE_APPLY, "ib", G_ROLE_MAIN.obj_id, false)
			local t = {}
			t.initiative = false
			g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_INITIATIVE_APPLY, "MasterInitiative", t)

			if self.mainLayer.data then
				self.mainLayer.data.isAccept = false
				--dump(self.mainLayer.data)
			end
			self.isAccept = self.mainLayer.data.isAccept
		end
	end
	local checkbox = createTouchItem(bg, "res/component/checkbox/1.png", cc.p(580, 45), checkFunc)
	self.checkFlag = createSprite(checkbox, "res/component/checkbox/1-1.png", getCenterPos(checkbox), cc.p(0.5, 0.5))
	self.checkFlag:setVisible(false)
	createLabel(bg, game.getStrByKey("master_check_tip"), cc.p(600, 45), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow)

	local function closeFunc()
		removeFromParent(self)
	end
	createMenuItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

	local tableView = self:createTableView(bg, cc.size(780, 395), cc.p(38, 75), true, true)

	registerOutsideCloseFunc(bg, closeFunc, true)
end

function ApplyListLayer:updateData(data, isAccept)
	self.data = data
	self.isAccept = isAccept

	self:updateUI()
end

function ApplyListLayer:updateUI()
	if #self.data > 0 then
		self.emptyTip:setVisible(false)
	else
		self.emptyTip:setVisible(true)
	end

	if self.isAccept then
		self.checkFlag:setVisible(false)
	else
		self.checkFlag:setVisible(true)
	end

	self:getTableView():reloadData()
end

function ApplyListLayer:tableCellTouched(table, cell)
end

function ApplyListLayer:cellSizeForTable(table, idx) 
    return 72, 785
end

function ApplyListLayer:tableCellAtIndex(table, idx)
	local record = self.data[idx+1]

	local cell = table:dequeueCell()

	local function getSchoolStr(school, sex)
		local sexStrTab = 
		{
			game.getStrByKey("man"),
			game.getStrByKey("female"),
		}
		local schoolStrTab = 
		{
			game.getStrByKey("zhanshi"),
			game.getStrByKey("fashi"),
			game.getStrByKey("daoshi"),
		}

		return schoolStrTab[school]
	end

	local function getOnlineStr(isOnline)
		if isOnline == true then
			return game.getStrByKey("online")
		else
			return game.getStrByKey("offline")
		end
	end

	local function getOnlineColor(isOnline)
		if isOnline == true then
			return MColor.green
		else
			return MColor.gray
		end
	end

	local function createCellContent(cell)
		local cellBg = createSprite(cell, "res/common/table/cell29.png", cc.p(0, 0), cc.p(0, 0))
		local y = cellBg:getContentSize().height/2
		createLabel(cellBg, record.name, cc.p(85, y), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_black)
        createLabel(cellBg, record.level..game.getStrByKey("faction_player_level"), cc.p(210, y), cc.p(0.5, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),12)
		createLabel(cellBg, getSchoolStr(record.school), cc.p(300, y), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),13)
		createLabel(cellBg, getOnlineStr(record.online), cc.p(400, y), cc.p(0, 0.5), 22, true, nil, nil, getOnlineColor(record.online))

		local function goFunc()
			GotoRolePos(record.staticId)
			self.mainLayer:close()
		end
		local goBtn = createMenuItem(cellBg, "res/component/button/48.png", cc.p(510, y), goFunc)
		createLabel(goBtn, game.getStrByKey("master_go"), getCenterPos(goBtn), cc.p(0.5, 0.5), 22, true)
		if record.online == true then
			goBtn:setEnabled(true)
		else
			goBtn:setEnabled(false)
		end

		local function privateFunc()
			PrivateChat(record.name)
		end
		local privateBtn = createMenuItem(cellBg, "res/component/button/48.png", cc.p(615, y), privateFunc)
		createLabel(privateBtn, game.getStrByKey("private_chat"), getCenterPos(privateBtn), cc.p(0.5, 0.5), 22, true)
		if record.online == true then
			privateBtn:setEnabled(true)
		else
			privateBtn:setEnabled(false)
		end

		local function deleteFunc()
			--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_DELETE_APPLY, "ii", G_ROLE_MAIN.obj_id, record.staticId)
			local t = {}
			t.roleSID = record.staticId
			g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_DELETE_APPLY, "MasterDeleteApply", t)
		end
		local deleteBtn = createMenuItem(cellBg, "res/component/button/48.png", cc.p(720, y), deleteFunc)
		createLabel(deleteBtn, game.getStrByKey("delete_relation"), getCenterPos(deleteBtn), cc.p(0.5, 0.5), 22, true)
	end

	if nil == cell then
		cell = cc.TableViewCell:new() 
		createCellContent(cell)
    else
    	cell:removeAllChildren()
    	createCellContent(cell)
    end

    return cell
end

function ApplyListLayer:numberOfCellsInTableView(table)
	return #self.data
end
------------------------------------------------------------------------------------------------
function DetailNode:ctor()
	local bg = createSprite(self, "res/common/bg/bg9.png", cc.p(0, 0), cc.p(0.5, 0.5))
	createLabel(applyBtn, game.getStrByKey("master_student_detail_tile"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-50), cc.p(0.5, 1), 24, true)
	
	local function closeFunc()
		removeFromParent(self)
	end
	createMenuItem(bg, "res/component/button/6.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

	local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2, bg:getContentSize().height-80), cc.size(550, 30), cc.p(0.5, 1), 25, 20, MColor.lable_yellow)
 	richText:addText(game.getStrByKey("master_master_detail_1"))
 	richText:format()

	registerOutsideCloseFunc(bg, closeFunc, true)
end
------------------------------------------------------------------------------------------------
function TeachNode:ctor(str)
	self.teachStr = str or ""

	if self.teachStr == "" then 
		self.teachStr = game.getStrByKey("master_tip_input_teach")
	end

	local function setTeach(str)
		if self.richText then
			removeFromParent(self.richText)
			self.richText = nil
		end

		self.richText = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 170), cc.size(320, 100), cc.p(0.5, 0.5), 25, 20, MColor.lable_yellow)
	 	self.richText:addText(str)
	 	self.richText:format()
	end

	local editBoxHandler = function(strEventName,pSender)
        local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用
        	log("began")
        	setTeach("")
        	self.editBox:setText(self.teachStr)
        elseif strEventName == "ended" then --编辑框完成时调用
        	log("ended")
        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
     		local str = self.editBox:getText()
     		str = checkShield(str)
     		dump(str)
	    	--if string.len(str) > 0 then
	    		if string.utf8len(str) > 40 then
					TIPS({type =1 ,str = game.getStrByKey("master_input_num_error")})
				else
					self.teachStr = str
					if self.teachStr == "" then 
						self.teachStr = game.getStrByKey("master_tip_input_teach")
					end
					setTeach(self.teachStr)
	    		end	
			--end
			self.editBox:setText("")
			-- if self.teachStr == "" then
   --      		self.editBox:setPlaceHolder(game.getStrByKey("master_tip_input_teach"))
   --      	else
   --      		self.editBox:setPlaceHolder("")
   --      	end
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")
        end
	end
	
	local bg = createSprite(self, "res/common/bg/bg31.png", cc.p(0, 0), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("master_master_teach"), cc.p(bg:getContentSize().width/2, 260), cc.p(0.5, 0.5), 22, true)
	createLabel(bg, game.getStrByKey("master_input_teach"), cc.p(bg:getContentSize().width/2, 100), cc.p(0.5, 0), 18, true, nil, nil, MColor.red)

	local editBox = createEditBox(bg, nil, cc.p(bg:getContentSize().width/2, 160), cc.size(350, 160), MColor.lable_yellow, 20)
	self.editBox = editBox
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	-- editBox:setPlaceHolder(game.getStrByKey("master_tip_input_teach"))
	-- editBox:setPlaceholderFontSize(20)
	editBox:registerScriptEditBoxHandler(editBoxHandler)
	--editBox:setText(self.teachStr)
	if self.teachStr ~= "" then
		editBox:setPlaceHolder("")
	end
	
	local function closeFunc()
		removeFromParent(self)
	end
	createMenuItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

	local function sureFunc()
		dump(self.teachStr)
		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_SET_WORD, "iS", G_ROLE_MAIN.obj_id, self.teachStr)
		local t = {}
		t.word = self.teachStr
		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_SET_WORD, "MasterSetWord", t)

		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_GET_WORD, "ii", G_ROLE_MAIN.obj_id, 0)
		local t = {}
		t.roleSID = 0
		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_GET_WORD, "MasterGetWord", t)
		addNetLoading(MASTER_CS_GET_WORD, MASTER_SC_GET_WORD_RET)

		removeFromParent(self)
	end
	local sureBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2, 45), sureFunc)
	createLabel(sureBtn, game.getStrByKey("sure"), getCenterPos(sureBtn), cc.p(0.5, 0.5), 22, true)

	setTeach(self.teachStr)

	registerOutsideCloseFunc(bg, closeFunc, true)
end
------------------------------------------------------------------------------------------------
function TaskNode:ctor()
	local msgids = {MASTER_SC_ISSUE_TASK_RET}
	require("src/MsgHandler").new(self, msgids)

	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_ISSUE_TASK, "MasterIssueTask", t)
	addNetLoading(MASTER_CS_ISSUE_TASK, MASTER_SC_ISSUE_TASK_RET)

	self.data = {}

	local bg = createSprite(self, "res/common/bg/bg31.png", cc.p(0, 0), cc.p(0.5, 0.5))
	self.bg = bg

	createLabel(bg, game.getStrByKey("master_task_title"), cc.p(bg:getContentSize().width/2, 260), cc.p(0.5, 0.5), 22, true)

	local function closeFunc()
		removeFromParent(self)
	end
	createMenuItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

	local function sendBtnFunc()
		-- dump(self.teachStr)
		local t = {}
		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_ISSUE_TASK2, "MasterIssueTask2", t)

		removeFromParent(self)
	end
	local sendBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2, 45), sendBtnFunc)
	createLabel(sendBtn, game.getStrByKey("master_task_send_sure"), getCenterPos(sendBtn), cc.p(0.5, 0.5), 22, true)

	registerOutsideCloseFunc(bg, closeFunc, true)
end

function TaskNode:updateData()
	self:updateUI()
end

function TaskNode:updateUI()
	local record = self.data
	local richText = require("src/RichText").new(self.bg, cc.p(40, 230), cc.size(340, 25), cc.p(0, 1), 25, 18, MColor.lable_black)
	local text = ""
	text = string.format(game.getStrByKey("master_task_conent_master"), record.q_title, record.q_discript)
	dump(text)
	if record.q_rewards_exp and tonumber(record.q_rewards_exp) > 0 then
		text = text..string.format(game.getStrByKey("master_task_reward_exp"), numToFatString(record.q_rewards_exp))
	end
	dump(text)
	if record.q_rewards_money and tonumber(record.q_rewards_money) > 0 then
		text = text.."、"..string.format(game.getStrByKey("master_task_reward_money"), numToFatString(record.q_rewards_money))
	end
	dump(text)
	if record.q_rewards_bindIngot and tonumber(record.q_rewards_bindIngot) > 0 then
		text = text.."、"..string.format(game.getStrByKey("master_task_reward_bindIngot"), numToFatString(record.q_rewards_bindIngot))
	end
	dump(text)
	richText:addText(text, MColor.lable_yellow, false)
	richText:format()
end

function TaskNode:networkHander(buff, msgid)
	local switch = {	
		[MASTER_SC_ISSUE_TASK_RET] = function() 
			log("MASTER_SC_ISSUE_TASK_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterIssueTaskRet", buff) 
			local taskId = t.taskID
			dump(taskId)
			self.data = getConfigItemByKey("MasterTaskDB", "q_id", taskId)
			dump(self.data)

			self:updateData()
		end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end

return MasterNode