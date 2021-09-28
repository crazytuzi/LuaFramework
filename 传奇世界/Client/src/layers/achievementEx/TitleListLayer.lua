local TitleListLayer = class("TitleListLayer", require("src/TabViewLayer"))

local path = "res/achievement/"
local pathCommon = "res/common/"

local achievementCfgData = require("src/config/AchieveDB")

function TitleListLayer:ctor(bg, parent)
	local msgids = {ACHIEVE_SC_GETTITLEDATARET, ACHIEVE_SC_SETTITLERET, ACHIEVE_SC_DISLOADTITLERET, ACHIEVE_SC_GETACHIEVEDATARET}
	require("src/MsgHandler").new(self, msgids)

	g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_GETACHIEVEDATA, "AchieveGetAchieveData", {})

	--g_msgHandlerInst:sendNetDataByFmtExEx(ACHIEVE_CS_GETTITLEDATA, "i", G_ROLE_MAIN.obj_id)
	g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_GETTITLEDATA, "AchieveGetTieleData", {})
	addNetLoading(ACHIEVE_CS_GETTITLEDATA, ACHIEVE_SC_GETTITLEDATARET)

	

	self.parent = parent
	self:initData()
	self:initDataTimer()

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	--createSprite(baseNode, pathCommon.."bg/bg-6.png", cc.p(bg:getContentSize().width/2, 20), cc.p(0.5, 0))

	local rightBg = createScale9Frame(
        baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(217, 38),
        cc.size(710,500),
        5,
        cc.p(0, 0)
    )
	--createSprite(baseNode, pathCommon.."bg/bg49.png", cc.p(217, 38), cc.p(0, 0))
	self.rightBg = rightBg
	local leftBg = createScale9Frame(
        baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 38),
        cc.size(180,500),
        5
    )
    createSprite(self.rightBg, pathCommon.."bg/bg75.jpg", cc.p(self.rightBg:getContentSize().width/2, 2), cc.p(0.5, 0))

	self.rightBaseNode = cc.Node:create()
	self.rightBg:addChild(self.rightBaseNode)
	self.rightBaseNode:setPosition(cc.p(0, 0))

	--createSprite(baseNode, pathCommon.."bg/buttonBg5.png", cc.p(32, 38), cc.p(0, 0))
	self.leftBg = leftBg
	-- local topBg = createScale9Frame(
 --        baseNode,
 --        "res/common/scalable/panel_outer_base_1.png",
 --        "res/common/scalable/panel_outer_frame_scale9_1.png",
 --        cc.p(32, 430),
 --        cc.size(896,111),
 --        5
 --    )
	-- --createSprite(baseNode, pathCommon.."bg/infoBg16.png", cc.p(bg:getContentSize().width/2, 540), cc.p(0.5, 1))
	-- createSprite(topBg, pathCommon.."bg/infoBg16-1.png", getCenterPos(topBg), cc.p(0.5, 0.5))
	-- createSprite(topBg, pathCommon.."bg/infoBg16-2.png", getCenterPos(topBg, 0, 20), cc.p(0.5, 0.5))
	-- self.topBg = topBg
	-- createLabel(topBg, game.getStrByKey("achievement_tip_reward"), cc.p(35, 25), cc.p(0, 0), 20, true)
	-- createLabel(topBg, game.getStrByKey("achievement_att_tip"), getCenterPos(topBg, 0, 20), cc.p(0.5, 0.5), 20, true)

	-- createLabel(baseNode, game.getStrByKey("achievement_progress_title"), cc.p(155, 580), cc.p(1, 0.5), 24, true, nil, nil, MColor.yellow)
	-- --进度条
	-- local progressBg = createSprite(baseNode, pathCommon.."progress/cj3.png", cc.p(160, 580), cc.p(0, 0.5))
	-- self.progress = cc.ProgressTimer:create(cc.Sprite:create(pathCommon.."progress/cj4.png"))  
	-- progressBg:addChild(self.progress)
 --    self.progress:setPosition(getCenterPos(progressBg))
 --    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
 --    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
 --    self.progress:setBarChangeRate(cc.p(1, 0))
 --    self.progress:setMidpoint(cc.p(0, 1))
 --    self.progress:setPercentage(0)
 --    --进度
	-- self.progressLabel = createLabel(progressBg, "0 / 0", getCenterPos(progressBg), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.white)

	-- createLabel(baseNode, game.getStrByKey("achievement_progress_title"), cc.p(65, 550), cc.p(0, 0), 22, true)
	-- self.titileProgressLabel = createLabel(baseNode, "0/0", cc.p(200, 550), cc.p(0, 0), 22, true)

	local function checkFunc()
		if self.checkFlag:isVisible() then
			self.checkFlag:setVisible(false)
		else
			self.checkFlag:setVisible(true)
		end
		--self:setData(self.lastSelectCell:getIdx())
		
		self:updateData()
	end
	local checkbox = createTouchItem(leftBg, "res/component/checkbox/1.png", cc.p(25, 25), checkFunc)
	self.checkFlag = createSprite(checkbox, "res/component/checkbox/1-1.png", getCenterPos(checkbox), cc.p(0.5, 0.5))
	self.checkFlag:setVisible(false)
	createLabel(leftBg, game.getStrByKey("achievement_show_title"), cc.p(45, 25), cc.p(0, 0.5), 18, true, nil, nil, MColor.lable_yellow)

	createSprite(leftBg, pathCommon.."bg/buttonBg2-1.png", cc.p(leftBg:getContentSize().width/2, 50), cc.p(0.5, 0.5))
	self.callBackFunc = function(idx)
		self.lastSelectIdx = idx-1
		local record = self:getDataRecord(idx-1)
		if record and record.finishCount and record.totalCount then
			self.nowAchieveProgressLabel:setString(record.finishCount.."/"..record.totalCount)
		end
		self:setData(idx-1)
    end
    self.lastSelectIdx = 0
    self.normal_img = "res/component/button/40.png"
    self.select_img = "res/component/button/40_sel.png"
    self.lock_img = "res/component/button/40_gray.png"
    self:createTableView(leftBg, cc.size(190, 437), cc.p(4, 60), true)

	self:updateData()
	startTimerAction(self, 0.1, false, function() self:tableCellTouched(self:getTableView(), self:getTableView():cellAtIndex(0)) 
		self.lastSelectCell = self:getTableView():cellAtIndex(0) end)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_TITLE)
		elseif event == "exit" then
		end
	end)
end

function TitleListLayer:initData()
	self.data = {}
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.title = require("src/layers/role/RoleStruct"):getAttr(PLAYER_TITLE)

	local titleTab = getConfigItemByKey("TitleDB")
	for i,v in pairs(titleTab) do
		local record = v
		if v.school == self.school then
			table.insert(self.data, #self.data+1, {id = record.q_titleID, name = record.q_titleName})
		end
	end
end

function TitleListLayer:initDataTimer()
	local function updateTime()
		for i,v in ipairs(self.data) do
			if v.leftTime then
				v.leftTime = v.leftTime - 1
				if v.leftTime < 0 then
					v.finish = nil
					v.leftTime = -1
				end
			end
		end
	end
	startTimerAction(self, 1, true, updateTime)
end

function TitleListLayer:getDataRecord(index)
	local isShowFinishOnly = self.checkFlag:isVisible()
	if isShowFinishOnly then
		local indexTemp = -1
		
		for i,v in ipairs(self.data) do
			if type(v) == "table" then
				if v.finish == true then
					indexTemp = indexTemp + 1
				end

				if indexTemp == index then
					return v
				end
			end
		end
	else
		return self.data[index+1]
	end

	return nil
end

function TitleListLayer:updateData()
	self:reOrderData()
	self:setData(self.lastSelectIdx)
	self:updateUI()
end

function TitleListLayer:reOrderData()
	if self.isReOrder then
		return 
	end
	--dump(self.data)
	for i,v in ipairs(self.data) do
		if v.finish == true then
			local record = v
			table.remove(self.data, i)
			table.insert(self.data, 1, record)
			self.isReOrder = true
		end
	end

	--dump(self.data)
end

function TitleListLayer:setData(idx)
	local record = self:getDataRecord(idx)
	if record then
		--dump(record)
		self:updateRight(record)
		self.selectRecord = record
	else
		self:updateRight(nil)
	end

	--self:updateData()
end

function TitleListLayer:getDataCount()
	local isShowFinishOnly = self.checkFlag:isVisible()
	local count = 0
	for i,v in ipairs(self.data) do
		if isShowFinishOnly then
			if v.finish == true then
				count = count + 1
			end
		else
			count = count + 1
		end
	end

	return count
end

function TitleListLayer:updateRight(record)
	-- if true then
	-- 	return
	-- end

	self.rightBaseNode:removeAllChildren()



	if record == nil then
		return
	end

	local flag = createSprite(self.rightBaseNode, pathCommon.."bg/bg75.jpg", cc.p(self.rightBg:getContentSize().width/2, 2), cc.p(0.5, 0))

	self.leftTimeLabel = nil

	--local titleBg = createSprite(self.rightBg, path.."1.png", cc.p(self.rightBg:getContentSize().width/2-25, 330), cc.p(0.5, 0.5))
	dump(record)
	local res = getConfigItemByKey("TitleDB", "q_titleID", record.id, "q_pic")
	dump(res)
	if res then
		local titleSpr = createSprite(flag, path.."title/"..res..".png", cc.p(flag:getContentSize().width/2, 415), cc.p(0.5, 0.5), nil, 1)
		if res >= 1000 then
			if titleSpr then
				titleSpr:setScale(1)
			end
		end
	end

	createLabel(flag, game.getStrByKey("achievement_title_finish_condition"), cc.p(flag:getContentSize().width/2, 325), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.lable_yellow)
	createSprite(flag, "res/common/bg/line12.png", cc.p(flag:getContentSize().width/2, 305), cc.p(0.5, 0.5))
	createSprite(flag, "res/common/bg/line12.png", cc.p(flag:getContentSize().width/2, 180), cc.p(0.5, 0.5))


	local  data = getConfigItemByKey("TitleDB", "q_titleID", record.id)
	-- local attBg = self:createAttNode(data, self.rightBg, 22, MColor.lable_yellow)
	-- if attBg then
	-- 	self.rightBg:addChild(attBg)
	-- 	attBg:setPosition(cc.p(self.rightBg:getContentSize().width/2, 15))
	-- end

	if record.finishTime then
		local timeStr = os.date(game.getStrByKey("achievement_time_format"), record.finishTime)
		--createLabel(flag, game.getStrByKey("achievement_title_finish_time")..timeStr, cc.p(flag:getContentSize().width/2, 330), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)

		local richText = require("src/RichText").new(flag, cc.p(250 , 160), cc.size(240, 20), cc.p(0, 1), 20, 20, MColor.lable_yellow)
		richText:setAutoWidth()
		richText:addText(game.getStrByKey("achievement_title_finish_time").."^c(white)"..timeStr.."^")
		richText:format()
	end

	if record.finish == true then
		local button
		if self.title == record.id then
			local function buttonFunc()
				--g_msgHandlerInst:sendNetDataByFmtExEx(ACHIEVE_CS_DISLOADTITLE, "ii", G_ROLE_MAIN.obj_id, record.id)
				local t = {}
				g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_DISLOADTITLE, "AchieveRemoveTitle", {})
				addNetLoading(ACHIEVE_CS_DISLOADTITLE, ACHIEVE_SC_DISLOADTITLERET)
			end
			button =  createMenuItem(self.rightBaseNode, "res/component/button/2.png", cc.p(self.rightBg:getContentSize().width/2, 40), buttonFunc)
			createLabel(button, game.getStrByKey("achievement_title_off"), getCenterPos(button), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
		else
			local function buttonFunc()
				--g_msgHandlerInst:sendNetDataByFmtExEx(ACHIEVE_CS_SETTITLE, "ii", G_ROLE_MAIN.obj_id, record.id)
				local t = {}
				t.titleID = record.id
				g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_SETTITLE, "AchieveSetTitle", t)
				addNetLoading(ACHIEVE_CS_SETTITLE, ACHIEVE_SC_SETTITLERET)
			end
			button =  createMenuItem(self.rightBaseNode, "res/component/button/2.png", cc.p(self.rightBg:getContentSize().width/2, 40), buttonFunc)
			G_TUTO_NODE:setTouchNode(button, TOUCH_TITLE_FIRST_EQUIP)
			createLabel(button, game.getStrByKey("achievement_title_on"), getCenterPos(button), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.white)
		end

		-- if record.leftTime and record.leftTime > 0 then
		-- 	--log("record.leftTime = "..record.leftTime)
		-- 	createLabel(self.rightBg, game.getStrByKey("achievement_title_time"), cc.p(self.rightBg:getContentSize().width/2+10, 120), cc.p(1, 0.5), 22, true, nil, nil, MColor.lable_yellow)
		-- 	local timeStr = string.format("%02d", math.floor(record.leftTime/3600))..":"..string.format("%02d", (math.floor(record.leftTime/60)%60))..":"..string.format("%02d", (record.leftTime%60))
		-- 	self.leftTimeLabel = createLabel(self.rightBg, timeStr, cc.p(self.rightBg:getContentSize().width/2+15, 120), cc.p(0, 0.5), 22, true, nil, nil, MColor.green)

		-- 	local updateTimeStr = function()
		--     	if self.leftTimeLabel then
		--     		--log("record.leftTime = "..record.leftTime)
		--     		record.leftTime = record.leftTime - 1
		--     		if record.leftTime < 0 then
		--     			-- record.leftTime = 0
		--     			-- self.leftTimeLabel:setColor(MColor.red)
		--     			-- if button then
		--     			-- 	removeFromParent(button)
		--     			-- 	button = nil
		--     			-- end
		--     			record.finish = nil
		--     			self:updateRight(record)
		--     			return
		--     		end
		-- 	    	local timeStr = string.format("%02d", math.floor(record.leftTime/3600))..":"..string.format("%02d", (math.floor(record.leftTime/60)%60))..":"..string.format("%02d", (record.leftTime%60))
		-- 	    	self.leftTimeLabel:setString(timeStr)
		-- 	    end
		--    	end

		-- 	startTimerAction(self.leftTimeLabel, 1, true, updateTimeStr)
		-- end
	else
		local function getDesFunc(id)
			log("getDesFunc")
			local desc = getConfigItemByKey("TitleDB", "q_titleID", id, "q_desc")
			if desc then
				return desc
			end

			local achieveRecord = nil
			for k,v in pairs (require("src/config/AchieveDB")) do
				if v.q_titleID then
					local tempRecord = v
					local tab = stringsplit(v.q_titleID, ",")
					for k,v in pairs(tab) do
						if tonumber(v) == id then
							achieveRecord = tempRecord
							return achieveRecord.q_eventDes
						end
					end
				end
			end

			return ""
		end

		--createLabel(attBg, game.getStrByKey("achievement_title_active")..getDesFunc(record.id), cc.p(attBg:getContentSize().width/2, 5), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)
		--record.point = 50 record.pointMax = 100
		
		--createLabel(attBg, game.getStrByKey("achievement_title_finish_tip"), cc.p(attBg:getContentSize().width/2, 75), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)
		
		-- local progressBg = createSprite(attBg, "res/component/progress/2.png", cc.p(attBg:getContentSize().width/2, 45), cc.p(0.5, 0))
		-- local progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/2-1.png"))  
		-- progressBg:addChild(progress)
	 --    progress:setPosition(getCenterPos(progressBg))
	 --    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	 --    progress:setAnchorPoint(cc.p(0.5, 0.5))
	 --    progress:setBarChangeRate(cc.p(1, 0))
	 --    progress:setMidpoint(cc.p(0, 1))

	 --    if record.point and record.pointMax then
		--     progress:setPercentage(record.point * 100 / record.pointMax)
		-- 	createLabel(progressBg, record.point.."/"..record.pointMax, getCenterPos(progressBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
		-- else
		-- 	progress:setPercentage(0)
		-- 	createLabel(progressBg, "0/1", getCenterPos(progressBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
		-- end
	end

	local function getCondition(titleId)
		local acheveTab = {}
		dump(titleId)
		local tabStr = getConfigItemByKey("TitleDB", "q_titleID", titleId, "q_needAchieves")
		dump(tabStr)
		if tabStr then
			local tab = stringsplit(tabStr, ",")
			dump(tab)
			if tab then
				for i,v in ipairs(tab) do
					local record = getConfigItemByKey("AchieveDB", "q_id", tonumber(v))
					--dump(record)
					if record then
						table.insert(acheveTab, record)
					end
				end
			end
		end

		return acheveTab
	end

	local function isAchieveFinished(achieveId)
		if self.achieveData then
			for i,v in ipairs(self.achieveData) do
				if v == achieveId then
					return true
				end
			end
		end

		return false
	end

	-- local tip = createLabel(self.rightBg, game.getStrByKey("achievement_title_finish_achievement"), cc.p(210, 260), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
	-- local tab = getCondition(record.id)
	-- dump(tab)
	-- if tab then
	-- 	local x = 250
	-- 	local y = 230
	-- 	local addY = -30
	-- 	for i,v in ipairs(tab) do
	-- 		if v.q_name then
	-- 			--dump(v)
	-- 			--createLabel(self.rightBg, v.q_name, cc.p(x, y), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
	-- 			local color = cc.c3b(150, 150, 150)
	-- 			if isAchieveFinished(v.q_id) then
	-- 				color = MColor.white
	-- 			end
	-- 			local richText = require("src/RichText").new(self.rightBg, cc.p(x , y), cc.size(200, 20), cc.p(0.5, 0), 20, 20, color)
	-- 			richText:setAutoWidth()
	-- 			richText:addTextItem(v.q_name, color, true, true, true, function() self.parent:setDataForAchieve(v.q_mainType, v.q_subType, v.q_groupid) end)
	-- 			richText:format()
	-- 		end
	-- 		y = y + addY
	-- 	end
	-- end

	if data.q_sp then
		local color = cc.c3b(150, 150, 150)
		if record.finish == true then
			color = MColor.white
		end

		local x = 250
		local y = 270
		local addY = -25
		local strTab = stringsplit(data.q_sp, "^")
		dump(strTab)
		for i,v in ipairs(strTab) do
			local richText = require("src/RichText").new(flag, cc.p(flag:getContentSize().width/2 , y), cc.size(150, 20), cc.p(0.5, 0), 20, 20, color)
			richText:setAutoWidth()
			richText:addText(v, color)
			richText:format()
			y = y + addY
		end
	end
end

function TitleListLayer:updateUI()
	if self.data.titleFinish then
		--self.titileProgressLabel:setString(self.data.titleFinish.."/"..#self.data)

		-- self.progressLabel:setString(self.data.titleFinish.." / "..#self.data)
		-- self.progress:setPercentage(self.data.titleFinish*100/#self.data)
	end

	--self:updateAttInfo()
	self:getTableView():reloadData()
	if self.offset then
		self:getTableView():setContentOffset(self.offset)
		self.offset = nil
	end
end

function TitleListLayer:updateUsingTag(isOn)
	-- if self.usingTag then
	-- 	self.usingTag:removeFromParent()
	-- 	self.usingTag = nil
	-- end

	-- if self.lastSelectCell and self.lastSelectIdx == self.lastSelectCell:getIdx() and isOn == true then
	-- 	local cellBg = self.lastSelectCell:getChildByTag(10)
	-- 	self.usingTag = createSprite(self.lastSelectCell, "res/component/flag/1.png", cc.p(0, cellBg:getContentSize().height/2+5), cc.p(0, 0.5))
	-- end
end

function TitleListLayer:tableCellTouched(table, cell)
	local index = cell:getIdx()
	if self.lastSelectIdx == index then
		return 
	else
		AudioEnginer.playTouchPointEffect()
		local old_cell = table:cellAtIndex(self.lastSelectIdx)
		if old_cell then 
			local button = tolua.cast(old_cell:getChildByTag(10),"cc.Sprite")
			local record = self:getDataRecord(self.lastSelectIdx)
			if button then
				if record.finish == true then
					button:setTexture(self.normal_img)
				else
					button:setTexture(self.lock_img)
				end

				if button:getChildByTag(20) then
					button:removeChildByTag(20)
				end
			end
		end
		local button = cell:getChildByTag(10)
		if button then
			button:setTexture(self.select_img)
			button:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
			local select_allow =  button:getChildByTag(20)
			if select_allow then
				select_allow:setPosition(cc.p(button:getContentSize().width, button:getContentSize().height/2))
			else
				local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
				arrow:setTag(20)
				arrow:setOpacity(0)
				arrow:runAction(cc.FadeIn:create(0.5))
			end
		end
	end	
	self.lastSelectCell = cell
	self.lastSelectIdx = index
	dump(self.lastSelectCell)
	log("self.lastSelectIdx = "..index)

	self:setData(index)
end

function TitleListLayer:cellSizeForTable(table, idx) 
    return 70, 190
end

function TitleListLayer:tableCellAtIndex(table, idx)
	local record = self:getDataRecord(idx)

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
    else
    	cell:removeAllChildren()
    end
	local cellBg = createSprite(cell, self.lock_img, cc.p(0, 0), cc.p(0, 0))
	cellBg:setTag(10)
	
	local color = MColor.gray
	if record.finish == true then
		cellBg:setTexture(self.normal_img)
		color = MColor.lable_yellow
	end
	if record.name then
		createLabel(cellBg, record.name, getCenterPos(cellBg), cc.p(0.5, 0.5), 22, true, nil, nil, color)
	end

	if idx == self.lastSelectIdx then
		cellBg:setTexture(self.select_img)
		local arrow = createSprite(cellBg, "res/group/arrows/9.png", cc.p(cellBg:getContentSize().width, cellBg:getContentSize().height/2), cc.p(0, 0.5))
		arrow:setTag(20) 
	end

	if record.finish == true then
		createSprite(cell, "res/component/flag/7.png", cc.p(0, cellBg:getContentSize().height/2+5), cc.p(0, 0.5))
	end 

	if self.title == record.id then
		local usingTag = createSprite(cell, "res/component/flag/1.png", cc.p(0, cellBg:getContentSize().height/2+5), cc.p(0, 0.5))
		usingTag:setTag(30)
	end

    return cell
end

function TitleListLayer:numberOfCellsInTableView(table)
   	return self:getDataCount()
end

function TitleListLayer:updateAttInfo()
	if self.data.attTab then
		self.topBg:removeChildByTag(10)
		local attNode = self:createAttNodeTop(self.data.attTab, 20, MColor.lable_yellow)
		self.topBg:addChild(attNode)
		attNode:setAnchorPoint(cc.p(0, 0))
		attNode:setPosition(cc.p(130, 25))
		attNode:setTag(10)
	end
end

function TitleListLayer:networkHander(buff,msgid)
	local switch = {
		[ACHIEVE_SC_GETTITLEDATARET] = function()
			log("get ACHIEVE_SC_GETTITLEDATARET")
			local t = g_msgHandlerInst:convertBufferToTable("AchieveGetTieleDataRet", buff)
			--self.data.attTab = unserialize(t.attrData)
			dump(self.data.attTab)
			self.data.titleFinish = #t.achieveTitle
			for i,v in ipairs(t.achieveTitle) do
				local id = v.titleID
				local finishTime = v.finishTime
				local leftTime = v.isValidTitle
				for i,v in ipairs(self.data) do
					if type(v) == "table" then
						if v.id == id then
							v.finish = true
							if finishTime > 0 then
								v.finishTime = finishTime
							end
							if leftTime > 0 then
								v.leftTime = leftTime
							end
						end
					end
				end
			end
			self.data.titleNotFinish = #t.achieveTitleProgress
			for i,v in ipairs(t.achieveTitleProgress) do
				local id = v.titleID
				local pointMax = v.total
				local point = v.finish
				print(id.." "..pointMax.." "..point)
				for i,v in ipairs(self.data) do
					if type(v) == "table" then
						if v.id == id then
							log("111111111111111111111")
							v.finish = false
							v.point = point
							v.pointMax = pointMax
						end
					end
				end
			end

			--dump(self.data)
			self:updateData()
		end
		,

		[ACHIEVE_SC_SETTITLERET] = function()
			log("get ACHIEVE_SC_SETTITLERET")
			local t = g_msgHandlerInst:convertBufferToTable("AchieveSetTitleRet", buff) 
			local id = t.titleID
			self.title = id

			self:updateRight(self.selectRecord)
			--self:getParent():updateTitleShow(id)
			--self:updateUsingTag(true)
			self.offset = self:getTableView():getContentOffset()
			self:updateData()
		end
		,

		[ACHIEVE_SC_DISLOADTITLERET] = function()
			log("get ACHIEVE_SC_DISLOADTITLERET")
			local t = g_msgHandlerInst:convertBufferToTable("AchieveRemoveTitleRet", buff)
			self.title = nil

			self:updateRight(self.selectRecord)
			--self:getParent():updateTitleShow(nil)
			--self:updateUsingTag(false)
			self.offset = self:getTableView():getContentOffset()
			self:updateData()
		end
		,

		[ACHIEVE_SC_GETACHIEVEDATARET] = function()
			log("get ACHIEVE_SC_GETACHIEVEDATARET")
			local t = g_msgHandlerInst:convertBufferToTable("AchieveGetAchieveDataRet", buff)
			self.achieveData = {}
			for i,v in ipairs(t.achieveData) do
				local id = v.achieveID
				table.insert(self.achieveData, id)
			end
			dump(self.achieveData)
			self:updateRight(self.selectRecord)
		end
		,

	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function TitleListLayer:createAttNode(record, parent, fontSize, fontColor)
	if record == nil then
		return nil
	end

	local attNodes = {}

	local formatStr2 = function(str1, str2)
		return str1.." ".."^c(white)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		return str1.." ".."^c(white)"..str2.."-"..str3.."^"
	end

	if record.q_max_hp then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_hp"), record.q_max_hp)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_max_mp then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_mp"), record.q_max_mp)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_attack_min and record.q_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_attack"), record.q_attack_min, record.q_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_magic_attack_min and record.q_magic_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_magicAttack"), record.q_magic_attack_min, record.q_magic_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_sc_attack_min and record.q_sc_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_scAttack"), record.q_sc_attack_min, record.q_sc_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_defence_min and record.q_defence_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_defence"), record.q_defence_min, record.q_defence_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_magic_defence_min and record.q_magic_defence_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_magicDefence"), record.q_magic_defence_min, record.q_magic_defence_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_att_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_attackDodge"), record.q_att_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_mac_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_magicDodge"), record.q_mac_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_crit then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_cirt"), record.q_crit)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_hit then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_hit"), record.q_hit)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_dodge"), record.q_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_attack_speed then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_attackSpeed"), record.q_attack_speed)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_luck then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_luck"), record.q_luck)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addSpeed then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subAt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subAt"), record.q_subAt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subMt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subMt"), record.q_subMt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subDt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subDt"), record.q_subDt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addAt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addAt"), record.q_addAt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addMt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addMt"), record.q_addMt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addDt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addDt"), record.q_addDt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	-- local reverseTab = function(tab)
	-- 	local retTab = {}

	-- 	for i=#tab,1,-1 do
	-- 		retTab[#tab-i+1] = tab[i]
	-- 	end

	-- 	return retTab
	-- end

	-- attNodes = reverseTab(attNodes)

	-- local attBg = createSprite(nil, pathCommon.."bg/infoBg17.png", cc.p(0, 0), cc.p(0.5, 0), nil, 1)
	-- local posTab = {cc.p(attBg:getContentSize().width/2-140, 160), 
	-- cc.p(attBg:getContentSize().width/2+20, 160), 
	-- cc.p(attBg:getContentSize().width/2-140, 130), 
	-- cc.p(attBg:getContentSize().width/2+20, 130)}
	local x = 390
	local y = 230
	local addY = -30

	-- if #attNodes == 1 then
	-- 	posTab = {cc.p(attBg:getContentSize().width/2-50, 145)}
	-- end
	createLabel(parent, game.getStrByKey("achievement_tip_reward_att"), cc.p(420, 260), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
	createSprite(parent, "res/common/bg/line11.png", cc.p(parent:getContentSize().width/2, 260-3))

	for i,v in ipairs(attNodes) do
		parent:addChild(v)
		v:setPosition(cc.p(x, y))
		
		y = y + addY
	end

	local x = 390
	local y = 230
	local addY = -30
	for i=1,4 do
		createSprite(parent, "res/common/bg/line11.png", cc.p(parent:getContentSize().width/2, y-3))
		y = y + addY
	end

	return attBg
end

function TitleListLayer:createAttNodeTop(record, fontSize, fontColor)
	if record == nil then
		return nil
	end

	local attStrs = {}

	local formatStr2 = function(str1, str2)
		-- if str2 == 0 then
		-- 	return
		-- end

		return "^c(lable_black)"..str1.."^".." ".."^c(white)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		-- if str2 == 0 and str3 == 0 then
		-- 	return
		-- end
		return "^c(lable_black)"..str1.."^".." ".."^c(white)"..str2.."-"..str3.."^"
	end

	if record.q_max_hp then
		local str = formatStr2(game.getStrByKey("prop_hp"), record.q_max_hp)
		table.insert(attStrs, str)
	end

	if record.q_max_mp then
		local str = formatStr2(game.getStrByKey("prop_mp"), record.q_max_mp)
		table.insert(attStrs, str)
	end

	if record.q_attack_min and record.q_attack_max then
		local str = formatStr3(game.getStrByKey("prop_attack"), record.q_attack_min, record.q_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_magic_attack_min and record.q_magic_attack_max then
		local str = formatStr3(game.getStrByKey("prop_magicAttack"), record.q_magic_attack_min, record.q_magic_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_sc_attack_min and record.q_sc_attack_max then
		local str = formatStr3(game.getStrByKey("prop_scAttack"), record.q_sc_attack_min, record.q_sc_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_defence_min and record.q_defence_max then
		local str = formatStr3(game.getStrByKey("prop_defence"), record.q_defence_min, record.q_defence_max)
		table.insert(attStrs, str)
	end

	if record.q_magic_defence_min and record.q_magic_defence_max then
		local str = formatStr3(game.getStrByKey("prop_magicDefence"), record.q_magic_defence_min, record.q_magic_defence_max)
		table.insert(attStrs, str)
	end

	if record.q_att_dodge then
		local str = formatStr2(game.getStrByKey("prop_attackDodge"), record.q_att_dodge)
		table.insert(attStrs, str)
	end

	if record.q_mac_dodge then
		local str = formatStr2(game.getStrByKey("prop_magicDodge"), record.q_mac_dodge)
		table.insert(attStrs, str)
	end

	if record.q_crit then
		local str = formatStr2(game.getStrByKey("prop_cirt"), record.q_crit)
		table.insert(attStrs, str)
	end

	if record.q_hit then
		local str = formatStr2(game.getStrByKey("prop_hit"), record.q_hit)
		table.insert(attStrs, str)
	end

	if record.q_dodge then
		local str = formatStr2(game.getStrByKey("prop_dodge"), record.q_dodge)
		table.insert(attStrs, str)
	end

	if record.q_attack_speed then
		local str = formatStr2(game.getStrByKey("prop_attackSpeed"), record.q_attack_speed)
		table.insert(attStrs, str)
	end

	if record.q_luck then
		local str = formatStr2(game.getStrByKey("prop_luck"), record.q_luck)
		table.insert(attStrs, str)
	end

	if record.q_addSpeed then
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed)
		table.insert(attStrs, str)
	end

	if record.q_subAt then
		local str = formatStr2(game.getStrByKey("prop_subAt"), record.q_subAt)
		table.insert(attStrs, str)
	end

	if record.q_subMt then
		local str = formatStr2(game.getStrByKey("prop_subMt"), record.q_subMt)
		table.insert(attStrs, str)
	end

	if record.q_subDt then
		local str = formatStr2(game.getStrByKey("prop_subDt"), record.q_subDt)
		table.insert(attStrs, str)
	end

	if record.q_addAt then
		local str = formatStr2(game.getStrByKey("prop_addAt"), record.q_addAt)
		table.insert(attStrs, str)
	end

	if record.q_addMt then
		local str = formatStr2(game.getStrByKey("prop_addMt"), record.q_addMt)
		table.insert(attStrs, str)
	end

	if record.q_addDt then
		local str = formatStr2(game.getStrByKey("prop_addDt"), record.q_addDt)
		table.insert(attStrs, str)
	end

	local reverseTab = function(tab)
		local retTab = {}

		for i=#tab,1,-1 do
			retTab[#tab-i+1] = tab[i]
		end

		return retTab
	end
	
	attStrs = reverseTab(attStrs)
	--dump(attStrs)
	log("test 1")
	local attNodes = {}
	for i,v in ipairs(attStrs) do
		local richText = require("src/RichText").new(nil, cc.p(0, 0), cc.size(190, 30), cc.p(0, 0), 30, fontSize, fontColor)
	    richText:addText(v)
	    richText:format()
	    table.insert(attNodes, 1, richText)
	end

	log("#attNodes="..#attNodes)
	local attNode = Mnode.combineNode({
		nodes = attNodes,
		ori = "-",
		margins = 0,
		align = "c"
	})

	return attNode
end

return TitleListLayer