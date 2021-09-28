local AchievementListLayer = class("AchievementListLayer", require("src/TabViewLayer"))

local ListLayer = class("ListLayer", require("src/TabViewLayer"))

local path = "res/achievement/"
local pathCommon = "res/common/"

-- local achievementCfgData = require("src/config/AchieveDB")

function AchievementListLayer:ctor(bg, parent, achieveData)
	local msgids = {ACHIEVE_SC_GETACHIEVEDATARET, ACHIEVE_SC_GETCOUNTRET}
	require("src/MsgHandler").new(self, msgids)

	g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_GETACHIEVEDATA, "AchieveGetAchieveData", {})
	addNetLoading(ACHIEVE_CS_GETACHIEVEDATA, ACHIEVE_SC_GETACHIEVEDATARET)

	g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_GETCOUNT, "AchieveGetCount", {})

	self:initData()
	self.achieveData = achieveData
	dump(self.achieveData)

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	--createSprite(baseNode, pathCommon.."bg/bg-6.png", cc.p(bg:getContentSize().width/2, 20), cc.p(0.5, 0))

	-- local frame_width = 5
 --    local rightBg = cc.Sprite:create("res/common/scalable/panel_outer_base_1.png", cc.rect(0, 0, 710 - frame_width * 2, 500 - frame_width * 2))
 --    self.rightBg = rightBg
 --    rightBg:setAnchorPoint(cc.p(0, 0))
 --    rightBg:setPosition(cc.p(217 + frame_width, 38 + frame_width))
 --    rightBg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
 --    baseNode:addChild(rightBg)
 --    createScale9Sprite(baseNode, "res/common/scalable/panel_outer_frame_scale9_1.png", cc.p(217, 38), cc.size(710, 500), cc.p(0, 0))

    local rightBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(217, 38),
        cc.size(710, 500),
        5
    )
    self.rightBg = rightBg

    --local topBg = createSprite(rightBg, pathCommon.."bg/infoBg16.png", cc.p(0, 0), cc.p(0, 0))
    --createScale9Sprite(self, "res/common/scalable/panel_outer_frame_scale9.png", cc.p(217, 38), cc.size(710, 500), cc.p(0, 0))
    
	local leftBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 38),
        cc.size(180, 500),
        5
    )
	self.leftBg = leftBg

	self:createTableView(leftBg, cc.size(190, 495), cc.p(4, 2), true, false)
	self.selectMain = 0
	self.selectSub = nil
	self.normal_img = "res/component/button/40.png"
	self.select_img = "res/component/button/40_sel.png"

	self.totalLayer = require("src/layers/achievementEx/AchievementTotalLayer").new()
	--dump(self.data)
	self.totalLayer:setData(self.data)
	rightBg:addChild(self.totalLayer)
	self.totalLayer:setPosition(cc.p(5, 5))

	self.listLayer = ListLayer.new()
	rightBg:addChild(self.listLayer)
	self.listLayer:setPosition(cc.p(5, 5))

 --    local function goFunc(tab)
 --    	local mainType = tab.mainType
 --    	local subType = tab.subType
 --    	local groupId = tab.groupId

	--     local function getGroupData(selectSub)
	-- 		for i,v in ipairs(self.data) do
	-- 			if v.subData then
	-- 				local subData = v.subData
	-- 				for i,v in ipairs(subData) do
	-- 					if v.subType == selectSub then
	-- 						return v.groupData
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- 	self:setData(mainType, subType)
	-- 	self.listLayer:setData(getGroupData(subType), self.progressData, groupId)
	-- 	self.totalLayer:setVisible(false)
	-- 	self.listLayer:setVisible(true)
	-- end
	-- -- local addFriendBtn = createMenuItem(baseNode, "res/component/button/2.png", cc.p(290, 600), addFriendBtnFunc)

	-- if achieveData then
	-- 	startTimerAction()
	-- end

	self:setData(0)
end

function AchievementListLayer:goTo(achieveData)
	if achieveData.mainType == nil or achieveData.subType == nil or achieveData.groupId == nil then
		return
	end

	local mainType = achieveData.mainType
	local subType = achieveData.subType
	local groupId = achieveData.groupId

    local function getGroupData(selectSub)
		for i,v in ipairs(self.data) do
			if v.subData then
				local subData = v.subData
				for i,v in ipairs(subData) do
					if v.subType == selectSub then
						return v.groupData
					end
				end
			end
		end
	end

	self:setData(mainType, subType)
	self.listLayer:setData(getGroupData(subType), self.progressData, groupId)
	self.totalLayer:setVisible(false)
	self.listLayer:setVisible(true)
end

function AchievementListLayer:initData()
	self.data = {}
	self.progressData = {}
	self.mainData = {}
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)

	local function isWithMainType(data, mainType)
		if data then
			for i,v in ipairs(data) do
				if v.mainType == mainType then
					return true
				end
			end
		end

		return false
	end

	local function isWithSubType(data, subType)
		if data then
			for i,v in ipairs(data) do
				if v.subType == subType then
					return true
				end
			end
		end

		return false
	end

	local function isWithGroupId(data, groupId)
		if data then
			for i,v in ipairs(data) do
				if v.groupId == groupId then
					return true
				end
			end
		end

		return false
	end

	table.insert(self.data, {mainType=0, mainTypeDesc=game.getStrByKey("achievement_total"), subData={}})

	local cfgData = require("src/config/AchieveDB")
	for i,v in ipairs(cfgData) do
		if isWithMainType(self.data, v.q_mainType) ~= true then
			table.insert(self.data, {mainType=v.q_mainType, mainTypeDesc=v.q_mainTypeDesc, subData={}})
		end
	end
	--dump(self.data)

	for i,v in ipairs(cfgData) do
		local record = v
		for i,v in ipairs(self.data) do
			if v.mainType == record.q_mainType then
				if isWithSubType(v.subData, record.q_subType) ~= true then
					table.insert(v.subData, {subType=record.q_subType, subTypeDesc=record.q_subTypeDesc, groupData={}})
				end
			end
		end
	end
	--dump(self.data)

	for i,v in ipairs(cfgData) do
		local record = v
		for i,v in ipairs(self.data) do
			if record.q_school == nil or (record.q_school and record.q_school == self.school) then
				if v.mainType == record.q_mainType then
					for i,v in ipairs(v.subData) do
						if v.subType == record.q_subType then
							local newRecord = copyTable(record)
							if isWithGroupId(v.groupData, record.q_groupid) ~= true then
								table.insert(v.groupData, {groupId=record.q_groupid, groupDesc=record.q_name, recordData={}})
							end

							for i,v in ipairs(v.groupData) do
								if v.groupId == record.q_groupid then
									-- if record.q_school then 
									-- 	dump(record.q_school)
									-- 	dump(record.q_school == self.school)
									-- 	if record.q_school == self.school then
									-- 		table.insert(v.recordData, newRecord)
									-- 	end
									-- else
										table.insert(v.recordData, newRecord)
									-- end
								end
							end

							-- if not v.groupData[newRecord.q_groupid] then
							-- 	--dump(v.groupData)
							-- 	v.groupData[newRecord.q_groupid] = {}
							-- end
							-- table.insert(v.groupData[newRecord.q_groupid], newRecord)
						end
					end
				end
			end
		end
	end
	--dump(self.data)
end

function AchievementListLayer:setData(selectMainType, selectSubType, showSubType)
	if self.selectMain == selectMainType then
		selectMainType = 0
	end

	self.mainData = {}
	--dump(selectMainType)
	for i,v in ipairs(self.data) do
		local record = v
		table.insert(self.mainData, {mainType=record.mainType, mainTypeDesc=record.mainTypeDesc})
		if selectMainType and selectMainType == record.mainType then
			--dump(record.subData)
			for i,v in ipairs(record.subData) do
				table.insert(self.mainData, {subType=v.subType, subTypeDesc=v.subTypeDesc})
			end
		end
	end
	--dump(self.mainData)

	self.selectMain = selectMainType
	self.selectSub = nil

	if selectSubType then
		self.selectSub = selectSubType
		for i,v in ipairs(self.mainData) do
			if v.subType and v.subType == selectSubType then
				self:showCell(i)
			end
		end
	end

	if showSubType then
		for i,v in ipairs(self.mainData) do
			if v.subType and v.subType == showSubType then
				self:showCell(i)
			end
		end
	end

	self:updateData()
end

function AchievementListLayer:updateData()
	self:updateUI()
end

function AchievementListLayer:updateUI()
	-- if self.selectMain == 0 then
	-- 	self.totalLayer:setVisible(true)
	-- 	self.listLayer:setVisible(false)
	-- else
	-- 	self.totalLayer:setVisible(false)
	-- end
	self.totalLayer:setVisible(true)
	self.listLayer:setVisible(false)

	-- if self.selectSub then
	-- 	self.totalLayer:setVisible(false)
	-- end

	self:getTableView():reloadData()
end

function AchievementListLayer:showCell(idx)
	local y = 70 * (#self.mainData - idx)

	startTimerAction(self, 0.0, false, function() 
		dump(self:getTableView():getContentSize())
		if self:getTableView():getContentSize().height - y < 500 then
			y = y - (500 - (self:getTableView():getContentSize().height - y))
		end
		self:getTableView():setContentOffset(cc.p(0, -y)) 
		end)
end

function AchievementListLayer:tableCellTouched(table, cell)
	local index = cell:getIdx()
	local pos = cc.p(cell:getPosition())
	local record = self.mainData[index+1]
	--dump(record)
	local function getIdxBySub(selectSub)
		for i,v in ipairs(self.mainData) do
			if v.subType and v.subType == selectSub then
				--dump(v)
				return i
			end
		end
	end

	local function getGroupData(selectSub)
		for i,v in ipairs(self.data) do
			if v.subData then
				local subData = v.subData
				for i,v in ipairs(subData) do
					if v.subType == selectSub then
						return v.groupData
					end
				end
			end
		end
	end

	local function getLastSubType(mainType)
		for i,v in ipairs(self.data) do
			if v.mainType == mainType then
				if v.subData and #v.subData > 0 then
					if #v.subData <= 2 then
						return v.subData[#v.subData].subType
					else
						return v.subData[2].subType
					end
				end
			end
		end
	end

	-- if record.mainType then
	-- 	self.selectMain = record.mainType
	-- end

	-- startTimerAction(self, 0.3, false, function()
	-- dump(self.selectMain)
	-- if self.selectMain == 0 then
	-- 	if self.offset then
			 
	-- 				dump(self.offset)
	-- 				self:getTableView():setContentOffset(self.offset, true)
				
	-- 	end
	-- 	self.offset = self:getTableView():getContentOffset()
	-- 	dump(self.offset)
	-- -- else
	-- -- 	self.offset = nil
	-- end
	-- end)
	
	if record.subType then
		if self.selectSub == record.subType then
			return 
		else
			AudioEnginer.playTouchPointEffect()
			--dump(self.selectSub)
			if self.selectSub then
				--dump(self.selectSub)
				local selectIdx = getIdxBySub(self.selectSub) - 1
				--dump(selectIdx)
				local oldCell = table:cellAtIndex(selectIdx)
				if oldCell then 
					local cellBg = tolua.cast(oldCell:getChildByTag(10), "cc.Sprite")
					if cellBg then
						if record.subType then
							--log("111111111")
							cellBg:setOpacity(0)
							--cellBg:setTexture()
						end
					end
				end
			end

			local cellBg = cell:getChildByTag(10)
			if cellBg then
				if record.subType then
					cellBg:setTexture("res/component/button/64.png")
					cellBg:setPosition(cc.p(-8, 0))
		    		cellBg:setOpacity(255)
				end
				cellBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
			end
		end

		self.selectSub = record.subType

		local groupData = getGroupData(self.selectSub)
		--dump(groupData)
		if groupData then
			self.listLayer:setData(groupData, self.progressData)
			self.totalLayer:setVisible(false)
			self.listLayer:setVisible(true)
		end
	end

	if record.mainType then
		--dump(pos)
		local subType
		if pos.y <= 70 then
			subType = getLastSubType(record.mainType)
			--dump(subType)
		end
		self:setData(record.mainType, nil, subType)
	end
end

function AchievementListLayer:cellSizeForTable(table, idx) 
    return 70, 200
end

function AchievementListLayer:tableCellAtIndex(table, idx)
	local record = self.mainData[idx+1]

	local cell = table:dequeueCell()

    local function createCellContent(cell)
    	local cellBg = createSprite(cell, "res/component/button/40.png", cc.p(0, 0), cc.p(0, 0))
    	cellBg:setTag(10)

		if record.mainType then
			cellBg:setTexture("res/component/button/40.png")
		end

		if record.subType then
			cellBg:setOpacity(0)
		end

		if record.mainType and self.selectMain == record.mainType then
			cellBg:setTexture("res/component/button/40_sel.png")
		end

		if record.subType and self.selectSub == record.subType then
			cellBg:setOpacity(255)
			cellBg:setTexture("res/component/button/64.png")
			cellBg:setPosition(cc.p(-8, 0))
			--cellBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
		end

    	if record.mainType then
    		createLabel(cell, record.mainTypeDesc, cc.p(87, 34), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
    	else
    		createLabel(cell, record.subTypeDesc, cc.p(87, 34), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
		end
    end

    if nil == cell then
        cell = cc.TableViewCell:new()  
    else
    	cell:removeAllChildren()
    end
    createCellContent(cell)

    return cell
end

function AchievementListLayer:numberOfCellsInTableView(table)
   	return #self.mainData
end

function AchievementListLayer:networkHander(buff,msgid)
	local switch = {
		[ACHIEVE_SC_GETACHIEVEDATARET] = function()
			log("get ACHIEVE_SC_GETACHIEVEDATARET")
			local t = g_msgHandlerInst:convertBufferToTable("AchieveGetAchieveDataRet", buff)
			--dump(t)
			--dump(t.achieveData)
			--dump(t.achieveProgress)
			for i,v in ipairs(t.achieveData) do
				--dump(i)
				local id = v.achieveID
				local finishTime = v.finishTime
				local mainType = getConfigItemByKey("AchieveDB", "q_id", id, "q_mainType")
				local subType = getConfigItemByKey("AchieveDB", "q_id", id, "q_subType")
				local groupId = getConfigItemByKey("AchieveDB", "q_id", id, "q_groupid")
				for i,v in ipairs(self.data) do
					if v.mainType == mainType then
						for i,v in ipairs(v.subData) do
							if v.subType == subType then
								for i,v in ipairs(v.groupData) do
									if v.groupId == groupId then
										for i,v in ipairs(v.recordData) do
											if v.q_id == id then
												v.finishTime = finishTime
											end
										end
									end
								end
							end
						end
					end
				end
			end

			self.progressData = {}
			for i,v in ipairs(t.achieveProgress) do
				local groupId = v.eventType
				local progress = v.progress
				
				self.progressData[groupId] = progress
			end
			dump(self.progressData)
			self:updateData()

			self.totalLayer:setData(self.data)

			if self.achieveData and self.achieveData ~= {} then
				dump(self.achieveData)
				self:goTo(self.achieveData)
			end
		end
		,

		[ACHIEVE_SC_GETCOUNTRET] = function()
			log("get ACHIEVE_SC_GETCOUNTRET")
			local t = g_msgHandlerInst:convertBufferToTable("AchieveGetCountRet", buff)
			dump(t)
			self.data.achievementComplete = t.achieveCount
			self.data.titleComplete = t.titleCount
			self.data.achieveLevel = t.achieveLevel
			self.data.achieveActivety = t.achievePoint
			self.data.attTab = unserialize(t.attrData)
			-- dump(t.achieveCount)
			-- dump(t.titleCount)
			dump(t.achieveLevel)
			dump(t.achievePoint)
			-- dump(self.data)
			--self:updateData()
			self.totalLayer:setData(self.data)
		end
		,

	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

----------------------------------------------------------------------------------
function ListLayer:ctor()
	self.data = {}
	self.selectGroup = nil
	self.detailSize = 40

	local topBg = CreateListTitle(self, cc.p(-2, 450), 702, 43, cc.p(0, 0))

	createLabel(topBg, game.getStrByKey("achievement_progress_achievement_one"), cc.p(25, topBg:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow)
	self.progressLabel = createLabel(topBg, "0/0", cc.p(165, topBg:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)

	local function checkFunc()
		if self.checkFlag:isVisible() then
			self.checkFlag:setVisible(false)
			self:updateData()
		else
			self.checkFlag:setVisible(true)
			self:updateData()
		end
	end
	local checkbox = createTouchItem(topBg, "res/component/checkbox/1.png", cc.p(515, topBg:getContentSize().height/2), checkFunc)
	self.checkFlag = createSprite(checkbox, "res/component/checkbox/1-1.png", getCenterPos(checkbox), cc.p(0.5, 0.5))
	self.checkFlag:setVisible(false)
	createLabel(topBg, game.getStrByKey("achievement_show_achievement"), cc.p(540, topBg:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow)

	self:createTableView(self, cc.size(710, 450), cc.p(0, 0), true, true)
end

function ListLayer:setData(data, progressData, selectGroup)
	self.data = data
	self.progressData = progressData
	self.selectGroup = nil

	if selectGroup then
		self.selectGroup = selectGroup
		for i,v in ipairs(self.data) do
			if v.groupId == selectGroup then
				self:showCell(i)
			end
		end
	end
	--dump(self.data)
	self:updateData()
end

function ListLayer:showCell(idx)
	local y = 73 * (#self.data - idx)

	startTimerAction(self, 0.2, false, function() 
		dump(self:getTableView():getContentSize())
		if self:getTableView():getContentSize().height - y < 450 then
			y = y - (450 - (self:getTableView():getContentSize().height - y))
		end
		self:getTableView():setContentOffset(cc.p(0, -y)) 
		end)
end

function ListLayer:updateData()
	self:updateUI()
end

function ListLayer:updateUI(selectGroup)
	local function getProgress()
		local count = 0
		local finishCount = 0
		for i,v in ipairs(self.data) do
			for i,v in ipairs(v.recordData) do
				count = count + 1
				if v.finishTime then
					--log("11111111111111111111111111111111")
					finishCount = finishCount + 1
				end
			end
		end

		return count, finishCount
	end
	local count, finishCount = getProgress()
	if count and finishCount then
		self.progressLabel:setString(finishCount.."/"..count)
	end

	self:getTableView():reloadData()

	if selectGroup then
		for i,v in ipairs(self.data) do
			if v.groupId == selectGroup then
				self:showCell(i)
			end
		end
	end
end

function ListLayer:tableCellTouched(table, cell)
	local idx = cell:getIdx()

	local selectGroup = self:getDataByIdx(idx+1).recordData[1].q_groupid

	if self.selectGroup == nil then
		self.selectGroup = selectGroup
	else
		if self.selectGroup == selectGroup then
			self.selectGroup = nil
		else
			self.selectGroup = selectGroup
		end
	end

	self:updateUI(self.selectGroup)
end

function ListLayer:isFinishOnly()
	return self.checkFlag:isVisible()
end

function ListLayer:getDataCount()
	local count = 0
	for k,v in pairs(self.data) do
		if self:isFinishOnly() then
			if self.progressData[v.groupId] and self.progressData[v.groupId] > 0 then
				count = count + 1
			end
		else
			count = count + 1
		end
	end

	return count
end

function ListLayer:getDataByIdx(idx)
	local index = 0
	for i,v in ipairs(self.data) do
		if self:isFinishOnly() then
			if self.progressData[v.groupId] and self.progressData[v.groupId] > 0 then
				index = index + 1
				if index == idx then
					return v
				end
			end
		else
			index = index + 1
			if index == idx then
				return v
			end
		end
	end
end

function ListLayer:cellSizeForTable(table, idx) 
	if self.selectGroup and self.selectGroup == self:getDataByIdx(idx+1).recordData[1].q_groupid then
		return self.detailSize * #self.data[idx+1].recordData + 73
	end
    return 73, 710
end

function ListLayer:tableCellAtIndex(table, idx)
	local groupData = self:getDataByIdx(idx+1)

	local function getNowRecord(data)
		for i,v in ipairs(data) do
			if v.finishTime == nil then
				return v
			end
		end

		return nil
	end

	local function isAllFinished(data)
		for i,v in ipairs(data) do
			if v.finishTime == nil then
				return false
			end
		end

		return true
	end

	local groupId = groupData.recordData[1].q_groupid
	local lastSubRecord = getNowRecord(groupData.recordData) or groupData.recordData[#groupData.recordData]

	local cell = table:dequeueCell()

	local function createCellContent(cell)
		local cellBg = createSprite(cell, "res/common/table/cell21.png", cc.p(0, 0), cc.p(0, 0))
		local flagBg = createSprite(cellBg, path.."4.png", cc.p(3, cellBg:getContentSize().height/2), cc.p(0, 0.5))
		createLabel(flagBg, lastSubRecord.q_activity, getCenterPos(flagBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
		createLabel(cellBg, lastSubRecord.q_name, cc.p(100, cellBg:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow)
		createLabel(cellBg, string.format(lastSubRecord.q_conditonDesc, numToFatString(lastSubRecord.q_value)), cc.p(270, cellBg:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
		local progressLabel = createLabel(cellBg, "0/"..numToFatString(lastSubRecord.q_value), cc.p(580, cellBg:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
		if groupId and groupId == 11 then
			progressLabel:setString(0)
		end
		
		if isAllFinished(groupData.recordData) then
			removeFromParent(progressLabel)
			createSprite(cellBg, "res/component/flag/2.png", cc.p(600, cellBg:getContentSize().height/2), cc.p(0.5, 0.5))
		else
			if self.progressData[groupId] then
				progressLabel:setString(numToFatString(self.progressData[groupId]).."/"..numToFatString(lastSubRecord.q_value))
				if groupId and groupId == 11 then
					progressLabel:setString(numToFatString(self.progressData[groupId]))
				end
			end
		end

		if self.selectGroup == groupId then
	    	local bg = createScale9Sprite(cell, "res/common/scalable/11.png", cc.p(5, 0), cc.size(690, self.detailSize*#self.data[idx+1].recordData), cc.p(0, 0))
	    	for i,v in ipairs(self.data[idx+1].recordData) do
	    		local y = (#groupData.recordData-i+1) * self.detailSize-(self.detailSize/2)
	    		createLabel(bg, "◆", cc.p(30, y), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
	    		createLabel(bg, v.q_name, cc.p(100, y), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
	    		createLabel(bg, string.format(v.q_conditonDesc, numToFatString(v.q_value)), cc.p(270, y), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
	    		local progressLabel = createLabel(bg, "0/"..numToFatString(v.q_value), cc.p(575, y), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
	    		if groupId and groupId == 11 then
					progressLabel:setString(0)
				end
	    		
    			if v.finishTime then
    				progressLabel:setPosition(cc.p(560, y))
    				progressLabel:setString("【"..game.getStrByKey("achievement_finish").."】")
    				progressLabel:setColor(MColor.green)
    			else
    				if self.progressData[groupId] then
						progressLabel:setString(numToFatString(self.progressData[groupId]).."/"..numToFatString(v.q_value))
						if groupId and groupId == 11 then
							progressLabel:setString(numToFatString(self.progressData[groupId]))
						end
					end
				end
	    	end
	    	cellBg:setPosition(cc.p(0, bg:getContentSize().height))
	    end
    end

    if nil == cell then
        cell = cc.TableViewCell:new()  
    else
    	cell:removeAllChildren()
    end
    createCellContent(cell)

    return cell
end

function ListLayer:numberOfCellsInTableView(table)
   	return self:getDataCount()
end

return AchievementListLayer