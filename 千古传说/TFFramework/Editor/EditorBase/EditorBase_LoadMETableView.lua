local tMETableView =  {}

function EditLua:createTableView(szId, tParams)
	print("createTableView")
	if targets[szId] ~= nil then
		return
	end
	local  tableView =  TFTableView:create()
	tableView:setTableViewSize(CCSizeMake(200 ,350))
	tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
	tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
	tableView:setBeyondPercent(0.3)--	????

	tableView.objCellSize = {width = 60, height = 60}
	tableView.nNumber = 20

	--registerScriptHandler functions must be before the reloadData function
	-- tableView:addMEListener(TFTABLEVIEW_SCROLL,tMETableView.scrollViewDidScroll)
	-- tableView:addMEListener(TFTABLEVIEW_ZOOM, tMETableView.scrollViewDidZoom)
	-- tableView:addMEListener(TFTABLEVIEW_TOUCHED, tMETableView.tableCellTouched)

	tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, tMETableView.cellSizeForTable)
	tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, tMETableView.tableCellAtIndex)
	tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, tMETableView.numberOfCellsInTableView)
	tableView:reloadData()

	-- tTouchEventManager:registerEvents(tableView)
	targets[szId] = tableView
	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

	--registerScriptHandler functions must be before the reloadData function
function tMETableView.cellSizeForTable(table, idx)
	return table.objCellSize.width, table.objCellSize.height
end

function tMETableView.tableCellAtIndex(table, idx)
	local strValue = string.format("%d",idx)
	local cell = table:dequeueCell()
	local label = nil
	local btn = nil
	local i = 0
	if nil == cell then
		table.cells = table.cells or {}
		cell = TFTableViewCell:create()
		table.cells[cell] = true
		if table:getDirection() == TFTableView.TFSCROLLHORIZONTAL then
			for i=1,3 do 
				local mBtn = TFButton:create()
				mBtn:setTextureNormal("test/Icon-57.png") 
				mBtn:setAnchorPoint(CCPointMake(0,0))
				mBtn:setPosition(CCPointMake(0, (i-1)*(mBtn:getSize().height + 5)))
				mBtn:setTag(100+i)
				mBtn.name = '[' .. idx.. ' : ' .. i .. ']'
				cell:addChild(mBtn)
				cell.mBtns = cell.mBtns or {}
				cell.mBtns[i] = mBtn
				local label = TFLabel:create()
				label:setText(strValue..'-'..i)
				label:setFontSize(20)
				label:setPosition(CCPointMake(0,(i-1)*(mBtn:getSize().height + 5)))
				label:setAnchorPoint(CCPointMake(0,0))
				label:setTag(200+i)
				cell:addChild(label)
				cell.labels = cell.labels or {}
				cell.labels[i] = label
			end
		elseif table:getDirection() == TFTableView.TFSCROLLVERTICAL then
			for i=1,3 do 
				local mBtn = TFButton:create()
				mBtn:setTextureNormal("test/Icon-57.png") 
				mBtn:setAnchorPoint(CCPointMake(0,0))
				mBtn:setPosition(CCPointMake((i-1)*(mBtn:getSize().width + 5),0))
				mBtn:setTag(100+i)
				mBtn.name = '[' .. idx.. ' : ' .. i .. ']'
				cell:addChild(mBtn)
				mBtn:setTouchEnabled(true)
				mBtn:addMEListener(TFWIDGET_CLICK, function()
					print("--tag--",mBtn:getTag())
				end)
				cell.mBtns = cell.mBtns or {}
				cell.mBtns[i] = mBtn

				local mBtn2 = TFButton:create()
				mBtn2:setTextureNormal("scrollBar.png") 
				mBtn2:setAnchorPoint(CCPointMake(0,0))
				mBtn2:setPosition(CCPointMake((i-1)*(mBtn:getSize().width + 5),0))
				mBtn2:setTag(1000+i)
				mBtn2.name = '[' .. idx.. ' : ' .. i .. ']'
				cell:addChild(mBtn2)
				cell.mBtn2s = cell.mBtn2s or {}
				cell.mBtn2s[i] = mBtn2

				local label = TFLabel:create()
				label:setText(strValue..'-'..i)
				label:setFontSize(20)
				label:setPosition(CCPointMake((i-1)*(mBtn:getSize().width + 5),0))
				label:setAnchorPoint(CCPointMake(0,0))
				label:setTag(200+i)
				cell:addChild(label)
				cell.labels = cell.labels or {}
				cell.labels[i] = label
			end

			for i =1,3 do
				local btn = cell.mBtns[i]
				local label = cell.labels[i]

				if nil ~= label then
					label:setText(strValue..'-'..i)
					if idx == 0 and i ~= 2 then
						btn:setVisible(false)
						label:setVisible(false)
					elseif idx == 1 and i == 2 then
						btn:setVisible(false)
						label:setVisible(false)
					else
						btn:setVisible(true)
						label:setVisible(true)
					end
			   end
		   end

		end
	else
		for i =1,3 do
			local btn = cell.mBtns[i]
			local label = cell.labels[i]

			if nil ~= label then
				label:setText(strValue..'-'..i)
				if idx == 0 and i ~= 2 then
					btn:setVisible(false)
					label:setVisible(false)
				elseif idx == 1 and i == 2 then
					btn:setVisible(false)
					label:setVisible(false)
				else
					btn:setVisible(true)
					label:setVisible(true)
				end
			end
		end
	end
	cell:setTouchBeganDelayEabled(true)
	return cell
end

function tMETableView.numberOfCellsInTableView(table, idx)
	return table.nNumber
end

--[[
	TFSCROLLNONE		= kCCScrollViewDirectionNone,		-1
	TFSCROLLHORIZONTAL	= kCCScrollViewDirectionHorizontal,	0
	TFSCROLLVERTICAL		= kCCScrollViewDirectionVertical,	1
	TFSCROLLBOTH		= kCCScrollViewDirectionBoth 		2
 ]]
function tMETableView:setDirection(szId, tParams)
	print("setDirection")
	targets[szId]:setDirection(tParams.nDir)
	print("setDirection success")
end

function tMETableView:setSize(szId, tParams)
	print("setTableViewSize")
	targets[szId]:setTableViewSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
	print("setTableViewSize success")
end

--[[
	kCCTableViewFillTopDown,
	kCCTableViewFillBottomUp
 ]]
function tMETableView:setVerticalFillOrder(szId, tParams)
	print("setVerticalFillOrder")
	targets[szId]:setVerticalFillOrder(tParams.nOrder)
	print("setVerticalFillOrder success")
end



return tMETableView