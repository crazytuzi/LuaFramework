local FactionFBSetOpenTimeLayer = class("FactionFBSetOpenTimeLayer", function() return cc.Layer:create() end)

local imagePathButton = "res/component/button/50.png"


function FactionFBSetOpenTimeLayer:ctor(parent, bossName, copyId)

	self.mTimeList = {{10,0}, {10,30}, {13,0}, {13,30}, {16,0}, {16,30}, {19,0}, {19,30}, {22,0}, {22,30}}
--	self.mTimeList = {{10,0}, {11,49}, {13,0}, {13,30}, {16,26}, {18,8}, {20,46}, {21,06}, {21,10}}
	self.mTimeCount = #self.mTimeList
	self.mCurChoose = 1
	self.mCopyId = copyId

	self.mImageNormal = "res/common/table/cell30.png"
	self.mImageSelect = "res/common/table/cell30_sel.png"


	if parent then
		parent:addChild(self)
	end

	local nodeDlg = createSprite(self, "res/common/bg/bg27.png", cc.p(60, 20), cc.p(0.0, 0.0))
	self.mNodeDlg = nodeDlg

	local centerX = 201

    local bgPanel = createScale9Frame(nodeDlg,
			"res/common/scalable/panel_outer_base_1.png",
			"res/common/scalable/panel_outer_frame_scale9_1.png",
	        cc.p(16, 90),
	        cc.size(370,376),
	        5)
	local bgSubTitle = createSprite(nodeDlg, "res/common/bg/titleLine4.png", cc.p(centerX, 446), cc.p(0.5, 0.5))

	local funcYes = function()
		local ret = self:setOpenTime(self.mCurChoose)
	end

	local funcCancel = function(name)
		self:closeDialog()
	end

	-------------------------------------------------------

	local strTitle = game.getStrByKey("faction_setTime")
	createLabel(nodeDlg, strTitle, cc.p(centerX, 520), cc.p(0.5, 1.0), 26, true, 10)

    -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
    local labBossName = require("src/RichText").new(nodeDlg, cc.p(centerX, 456), cc.size(300, 20), cc.p(0.5, 1.0), 24, 22, MColor.white)
    print(labBossName:getContentSize().width);
	labBossName:addText(bossName)
	labBossName:format();

	local menuItemYes = createTouchItem(nodeDlg, imagePathButton, cc.p(300,45), funcYes)
	createLabel(menuItemYes, game.getStrByKey("sure"), getCenterPos(menuItemYes), nil, 21, true)
	self.mBtnConfirm = menuItemYes

	local menuItemCancel = createTouchItem(nodeDlg, imagePathButton, cc.p(100,45), funcCancel)
	createLabel(menuItemCancel, game.getStrByKey("cancel"), getCenterPos(menuItemCancel), nil, 21, true)


	-------------------------------------------------------

	local tvSize = cc.size(360, 333)
	local tableView = cc.TableView:create(tvSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(40, 95))
	tableView:setDelegate()
	nodeDlg:addChild(tableView)
	tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
	tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table, cell) end,cc.TABLECELL_TOUCHED)    
	tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end ,cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end ,cc.TABLECELL_SIZE_AT_INDEX)
	tableView:reloadData()
	self.mTabView = tableView


	self:updateBtnConfirm(self.mCurChoose)

	SwallowTouches(nodeDlg)
end


function FactionFBSetOpenTimeLayer:closeDialog()
	if self.mNodeDlg then
		removeFromParent(self.mNodeDlg)
		self.mNodeDlg = nil
	end
end

function FactionFBSetOpenTimeLayer:setOpenTime(index)
	if index < 1 or index > #self.mTimeList then
		return false
	end

	local timeEntry = self.mTimeList[index]
	local timeHour = timeEntry[1]
	local timeMinute = timeEntry[2]
	local strText = string.format("%02s:%02s", timeHour, timeMinute)

	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_SETOPEN_TIME, "FactionCopySetOpenTime", {copyID=self.mCopyId, timeId=index})
	cclog("[FactionFBSetOpenTimeLayer:setOpenTime] called. copyId = %s, time = %s.", self.mCopyId, strText)
    self:closeDialog()


	return true
end


function FactionFBSetOpenTimeLayer:numberOfCellsInTableView(table)
	return self.mTimeCount
end

function FactionFBSetOpenTimeLayer:tableCellTouched(table, cell)
	local index = cell:getIdx()
	local idxf = self.mTimeCount - index

	local oldidx = self.mCurChoose

	if idxf == oldidx then
		return
	end

	local old_idx_ori = self.mTimeCount - oldidx
	local cellOld = table:cellAtIndex(old_idx_ori)
	if cellOld then
		local button = tolua.cast(cellOld:getChildByTag(10), "cc.Sprite")
		if button then
			button:setTexture(self.mImageNormal)
		end
	end

	local buttonNew = cell:getChildByTag(10)
	if buttonNew then
		buttonNew:setTexture(self.mImageSelect)
	end

	self.mCurChoose = idxf
	self:updateBtnConfirm(idxf)

	for i = 1, self.mTimeCount do
		self:updateCellTextColor(table, i)
	end
end

function FactionFBSetOpenTimeLayer:cellSizeForTable(table, idx) 
    return 50, 260
end

function FactionFBSetOpenTimeLayer:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new()   
	else
		cell:removeAllChildren()
	end

	-------------------------------------------------------

	local parNode = cell
	local idxf = self.mTimeCount - idx

	local button = createSprite(parNode, self.mImageNormal, cc.p(0, 0), cc.p(0.0, 0.0))
	button:setTag(10)
	if idxf == self.mCurChoose then
		button:setTexture(self.mImageSelect)
	end

	local timeEntry = self.mTimeList[idxf]
	local timeHour = timeEntry[1]
	local timeMinute = timeEntry[2]
	local strText = string.format("%02s : %02s", timeHour, timeMinute)
	local labText = createLabel(button, strText, getCenterPos(button), cc.p(0.5, 0.5), 22, true, 10)
	labText:setTag(4444)

	local colorText = cc.c3b(240, 200, 140)
	local timeOut = self:checkTimeOut(timeHour, timeMinute)
	if timeOut then
		colorText = cc.c3b(255, 0, 0)
	end
	labText:setColor(colorText)

	-------------------------------------------------------

    return cell
end

function FactionFBSetOpenTimeLayer:updateBtnConfirm(select_index)
	local timeEntrySel = self.mTimeList[select_index]
	local timeHourSel = timeEntrySel[1]
	local timeMinuteSel = timeEntrySel[2]

	local timeOut = self:checkTimeOut(timeHourSel, timeMinuteSel)

	-------------------------------------------------------

	if timeOut then
		self.mBtnConfirm:setEnable(false)
	else
		self.mBtnConfirm:setEnable(true)
	end
end

function FactionFBSetOpenTimeLayer:checkTimeOut(check_time_hour, check_time_minute)
    -- 取服务器当前时间
	--local curDate = os.date("*t")
    local curDate = os.date("*t", GetTime())
	local curHour = curDate.hour
	local curMinute = curDate.min

	local curHourFix = curHour
	local curMinuFix = curMinute
	if curHour < 5 then
		curHourFix = 24 + curHour
	end

	local selHourFix = check_time_hour
	local selMinuFix = check_time_minute
	if selHourFix < 5 then
		selHourFix = 24 + selHourFix
	end

	local timeOut = false
	if selHourFix < curHourFix then
		timeOut = true
	elseif selHourFix > curHourFix then
		timeOut = false
	else
		if selMinuFix <= curMinuFix then
			timeOut = true
		end
	end

	return timeOut
end

function FactionFBSetOpenTimeLayer:updateCellTextColor(table, index)
	local timeEntry = self.mTimeList[index]
	local timeHour = timeEntry[1]
	local timeMinute = timeEntry[2]

	local timeOut = self:checkTimeOut(timeHour, timeMinute)
	local colorText = cc.c3b(240, 200, 140)
	if timeOut then
		colorText = cc.c3b(255, 0, 0)
	end


	local cellIdx = self.mTimeCount - index
	local cell = table:cellAtIndex(cellIdx)
	if cell then
		local button = tolua.cast(cell:getChildByTag(10), "cc.Sprite")
		if button then
			local label = button:getChildByTag(4444)
			if label then
				label:setColor(colorText)
			end
		end
	end
end


return FactionFBSetOpenTimeLayer
