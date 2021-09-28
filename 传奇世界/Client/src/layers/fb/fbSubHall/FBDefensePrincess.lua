local FBDefensePrincess = class("FBDefensePrincess", function() return cc.Node:create() end)


function FBDefensePrincess:ctor(params)

--	log("[FBDefensePrincess:ctor] called.")

	local parent = params.parent
	parent:addChild(self, 8)

	local msgids = {COPY_SC_GETGUARDDATA_RET,COPY_RESCUEPRINCESS_SC_STEPPRIZE_INFO,COPY_RESCUEPRINCESS_SC_STEPPRIZE_SELECT_RET}
	require("src/MsgHandler").new(self,msgids)
	
	-----------------------------------------------------------

	self.mPrizeType = 1

	self.mDialogOpened = false
	self.mTimeLeft = 0

	self.mDialogText = nil
	self.mDialogPrize = nil

	self.mBtnReset = nil
	self.mBtnStart = nil
	self.mBtnLeft = nil
	self.mBtnRight = nil
	self.mLabLevelInfo = nil
    self.mLabItemName = nil

	self.mCurHardType = 0
	self.mCurPassLevel = 0
	self.mCurHardLevel = 1
	self.mPageIndex = 1
	self.mPageCount = 1
	self.mLabTitle = nil
	self.mLabLevel = nil

	self.mTabView = nil
    self.mCellBg = {}
	self.mCardNode = {}
	self.mCardNodeFront = {}
	self.mCardPos = {}

	self.mSuggestBattleForce = {1000, 1000, 1000}
	self.mPrizeItemInfo = {}
	self.mPrizeItemCount = {}
	self.mPageWidth = 575
	self.mHardCharLevelLow = {39, 51, 61}
	self.mHardCharLevelHigh = {50, 60, 71}


	self:loadData()
end

-----------------------------------------------------------

function FBDefensePrincess:loadData()
	local index = 1
	local itemQId = 0

	local tabDefense = getConfigItemByKey("FBDefense")
	for i,v in ipairs(tabDefense) do
		if v.q_copyLayer == 1 then
			local force = v.q_zdl
			if force == nil then force = 1000 end

			self.mSuggestBattleForce[index] = force
			index = index + 1

			local levelLow = v.q_minlv
			local levelHigh = v.q_maxlv
			if levelLow and levelHight then
				self.mHardCharLevelLow[index] = levelLow
				self.mHardCharLevelHigh[index] = levelHigh
			end

			if itemQId == 0 then
				itemQId = v.q_jl
			end
		end
	end

	-----------------------------------------------------------

	index = 1
	local tab = getConfigItemByKey("DropAward")
	for i,v in ipairs(tab) do
		if v.q_id == itemQId then
			local itemId = v.q_item
			if itemId ~= nil then
				self.mPrizeItemInfo[index] = itemId
				if v.q_count == nil then
					self.mPrizeItemCount[index] = 1
				else
					self.mPrizeItemCount[index] = v.q_count
				end
				index = index + 1
			end
		end
	end
end

function FBDefensePrincess:startDialog()
	local roleid = userInfo.currRoleId
	--g_msgHandlerInst:sendNetDataByFmtExEx(COPY_CS_GETGUARDDATA, "i", roleid)
--	log("[FBDefensePrincess:startDialog] called. roleid = %d.", roleid)
end

-----------------------------------------------------------

function FBDefensePrincess:showDialogText(_hardtype, _level, _resetcount)

	self.mCurHardType = _hardtype
	self.mCurPassLevel = _level

	local hardtype = _hardtype
	local pagecount = 3

	pagecount, hardtype = self:getShowPageCount(_hardtype)
	self.mPageCount = pagecount
	self.mCurHardLevel = hardtype
	self.mPageIndex = 1

	if self.mDialogText then
		return self:updateDialogText(_hardtype, _level, _resetcount)
	end

	-------------------------------------------------------

	local layer = cc.Layer:create()

	local bgFilePath = "res/common/bg/bg18.png"
	local btnNormal = "res/component/button/50.png"
	local btnClose = "res/component/button/x2.png"
	local btnStart = "res/component/button/4.png"
	local btnPage = "res/group/arrows/17.png"


	local centerX = 428


	local nodeDlg = createSprite(layer, bgFilePath, cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.mDialogText = layer

	createScale9Frame(
        nodeDlg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	createSprite(nodeDlg, "res/fb/defense/dlgBg.png", cc.p(centerX, 95), cc.p(0.5, 0.0))

	local strTitle = game.getStrByKey("rescue_princess_title")
	createLabel(nodeDlg, strTitle, cc.p(centerX, 518), cc.p(0.5, 1.0), 26, true, 10)

	----------------------------------------------------------

	local tvSize = cc.size(self.mPageWidth, 240)
	local tableView = cc.TableView:create(tvSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	tableView:setPosition(cc.p(140, 220))
	tableView:setDelegate()
	nodeDlg:addChild(tableView)
	tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
	tableView:registerScriptHandler(function(table,cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)    
	tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end ,cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end ,cc.TABLECELL_SIZE_AT_INDEX)
	tableView:setBounceable(false)
	tableView:setDeaccelerate(false)
	tableView:reloadData()
	self.mTabView = tableView

	local tFunc = function(touch, event)
		self:viewTouchEnded(touch, event)
		return false
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(tFunc, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = tableView:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tableView)


	----------------------------------------------------------

	local strPrizeIntro = game.getStrByKey("prize_introduce")
	createLabel(nodeDlg, strPrizeIntro, cc.p(102, 202), cc.p(0.5, 0.5), 20, true, 10)


	----------------------------------------------------------

	local funcCBStart = function()
		local ret = self:checkNeedReset(_hardtype, _level, _resetcount)
		if not ret then
			--g_msgHandlerInst:sendNetDataByFmtExEx(COPY_CS_GUARDCOPY_ACTION, "is", userInfo.currRoleId, self.mCurHardLevel)
			userInfo.lastFbType = 4
			setLocalRecordByKey(2,"subFbType", "" .. 1)
		end
	end

	local funcCBReset = function()
		if _resetcount > 0 then
			--g_msgHandlerInst:sendNetDataByFmtExEx(COPY_CS_GUARDCOPY_ACTION, "is", userInfo.currRoleId, 4)
		end
	end

	local funcCBLeftPage = function()
		self:scrollDecreasePage()
	end

	local funcCBRightPage = function()
		self:scrollIncreasePage()
	end

	local funcCBClose = function()
		self:closeDialogText()
	end


	-----------------------------------------------------

	local x1 = 260
	local y1 = 112

	local labText = game.getStrByKey("fb_challege")
	self.mBtnStart = createTouchItem(nodeDlg, btnStart, cc.p(centerX, 54), funcCBStart)
	createLabel(self.mBtnStart, labText, getCenterPos(self.mBtnStart), cc.p(0.5, 0.5), 22, true)

	createMenuItem(nodeDlg, btnClose, cc.p(810, 502), funcCBClose)

	self.mBtnReset = createTouchItem(nodeDlg, btnNormal, cc.p(700, 135), funcCBReset)
	if _resetcount == 0 then
		self.mBtnReset:setEnable(false)
	end

	local labText =  game.getStrByKey("reset_progress")
	local labReset = createLabel(self.mBtnReset, labText, getCenterPos(self.mBtnReset), cc.p(0.5, 0.5), 20, true)
	labReset:setTag(40)


	self.mBtnLeft = createTouchItem(nodeDlg, btnPage, cc.p(110, 300), funcCBLeftPage)
	self.mBtnLeft:setRotation(180)
	self.mBtnRight = createTouchItem(nodeDlg, btnPage, cc.p(744, 300), funcCBRightPage)

	-----------------------------------------------------
	if pagecount > 1 then
		local curPage = hardtype
		self.mPageIndex = curPage
		self:scrollToPage(curPage, false)
	end
	-----------------------------------------------------

	if pagecount == 1 then
		self.mBtnLeft:setVisible(false)
		self.mBtnRight:setVisible(false)
	elseif self.mPageIndex == 1 then
		self.mBtnLeft:setVisible(false)
	elseif self.mPageIndex == 2 then
		if pagecount <= 2 then
			self.mBtnRight:setVisible(false)
		end
	elseif self.mPageIndex == 3 then
		self.mBtnRight:setVisible(false)
	end

	-----------------------------------------------------
	-- text hint
	local textHead = game.getStrByKey("rescue_princess_curprogress")
	local textInfo = nil
	local textLevel = nil

	if _hardtype == 0 then
		textInfo = game.getStrByKey("rescue_princess_nolevel")
	elseif _hardtype >= 1 and _hardtype <= 3 then
		textInfo = string.format(game.getStrByKey("rescue_princess_level"), _level)
	elseif _hardtype == 4 then
		textInfo = game.getStrByKey("rescue_princess_alllevel")
	end

	local labHintHead = createLabel(nodeDlg, textHead, cc.p(618, 186), cc.p(0.0, 0.5), 20, true)
	local labHintInfo = createLabel(nodeDlg, textInfo, cc.p(710, 186), cc.p(0.0, 0.5), 20, true)
	self.mLabLevelInfo = labHintInfo

	-----------------------------------------------------

	local strItemBg = "res/common/bg/itemBg.png"
	local itemCount = #self.mPrizeItemInfo
	if itemCount > 6 then itemCount = 6 end
	local x = 102
	local y = 146

	local Mprop = require "src/layers/bag/prop"
	for i = 1, itemCount do
		local icon = Mprop.new(
		{
			protoId = tonumber(self.mPrizeItemInfo[i]),
		--	num = tonumber(self.mPrizeItemCount[i]),
			swallow = true,
			cb = "tips",
		})
		nodeDlg:addChild(icon)
		icon:setPosition(cc.p(x, y))
		icon:setAnchorPoint(0.5, 0.5)

		x = x + 90
	end

	-----------------------------------------------------

	Manimation:transit(
	{
	ref = getRunScene() ,
	node = layer ,
	curve = "-",
	sp = cc.p( display.width/2, display.height/2 ),
	zOrder = 199 ,
	swallow = false,
	})

	registerOutsideCloseFunc(nodeDlg, function() self:closeDialogText() end, true)

	-----------------------------------------------------

	self.mDialogText:registerScriptHandler(function(event) if event == "exit" then self.mDialogText = nil end end)

end

function FBDefensePrincess:updateDialogText(_hardtype, _level, _resetcount)
	if self.mDialogText == nil then
		return
	end

	-------------------------------------------------------

	if self.mTabView then
		self.mTabView:reloadData()
		self.mTabView:setVisible(false)
	end

	-------------------------------------------------------
	if self.mPageCount > 1 then
		local curPage = self.mCurHardLevel
		self.mPageIndex = curPage
		self:scrollToPage(curPage, false)
	end
	-------------------------------------------------------
	if self.mTabView then
		self.mTabView:setVisible(true)
	end

	self:updateDialogPage()

	-------------------------------------------------------

	if self.mBtnReset then
		if _resetcount == 0 then
			self.mBtnReset:setEnable(false)
		else
			self.mBtnReset:setEnable(true)
		end
	end

	self:updatePageButtonState()
end

function FBDefensePrincess:closeDialogText()
	if self.mDialogText then
		removeFromParent(self.mDialogText)
		self.mDialogText = nil
	end

--	log("[FBDefensePrincess:closeDialogText] called.")
end

function FBDefensePrincess:updateDialogPage()

	local textInfo = nil

	local hardtype = self.mCurHardType
	if hardtype == 0 then
		textInfo = game.getStrByKey("rescue_princess_nolevel")
	elseif hardtype == 4 then
		textInfo = game.getStrByKey("rescue_princess_alllevel")
	elseif hardtype ~= self.mCurHardLevel then
		textInfo = game.getStrByKey("rescue_princess_nolevel")
	elseif hardtype >= 1 and hardtype <= 3 then
		textInfo = string.format(game.getStrByKey("rescue_princess_level"), self.mCurPassLevel)
	end

	if self.mLabLevelInfo then
		self.mLabLevelInfo:setString(textInfo)
	end
end

function FBDefensePrincess:getShowPageCount(_hardtype)
	local pagecount = 1
	local hardtype = _hardtype

	if hardtype < 1 or hardtype > 3 then
		pagecount = 3
		hardtype = 1
	end

	local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
	if ILevel <= self.mHardCharLevelHigh[1] then
		pagecount = 1
		hardtype = 1
	elseif ILevel <= self.mHardCharLevelHigh[2] then
		if pagecount > 2 then
			pagecount = 2
		end
		if hardtype > 2 then
			hardtype = 2
		end
	end

	if _hardtype == 0 then
		if pagecount >= 2 then
			if ILevel >= self.mHardCharLevelLow[3] then
				hardtype = 3
			elseif ILevel >= self.mHardCharLevelLow[2] then
				hardtype = 2
			end
		end
	end

	return pagecount, hardtype
end

function FBDefensePrincess:numberOfCellsInTableView(table)
	return self.mPageCount
end

function FBDefensePrincess:tableCellTouched(table, cell)

end

function FBDefensePrincess:cellSizeForTable(table, idx) 
    return 240, self.mPageWidth
end

function FBDefensePrincess:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new()   
	else
		cell:removeAllChildren()
	end

	-------------------------------------------------------

	local parNode = cell
	local page = idx + 1
	local centerX = 288

	if self.mPageCount == 1 then
		if self.mCurHardType == 2 then
			page = 2
		elseif self.mCurHardType == 3 then
			page = 3
		end
	end

	createSprite(parNode, "res/fb/defense/textBg.png", cc.p(0, 0), cc.p(0.0, 0.0))
	createSprite(parNode, "res/fb/defense/sepe_name.png", cc.p(centerX, 214), cc.p(0.5, 0.5))
	createSprite(parNode, "res/fb/defense/flag-red.png", cc.p(120, 80), cc.p(0.5, 0.5))


	local strText = game.getStrByKey("rescue_princess_init_read")
	local richText = require("src/RichText").new(parNode, cc.p(210, 135), cc.size(390, 0), cc.p(0, 1), 22, 20)
	richText:setAutoWidth()
	richText:addText(strText, nil, true)
	richText:format()


	local strLevelKey = { "skillLevel1", "skillLevel2", "skillLevel3" }
	local strLevelN1 = game.getStrByKey(strLevelKey[page])
	local strLevelN2 = game.getStrByKey("rescue_princess_title")
	createLabel(parNode, strLevelN1..strLevelN2, cc.p(centerX, 215), cc.p(0.5, 0.5), 22, true, 10)
--	self.mLabTitle = createLabel(nodeDlg, strLevelN1..strLevelN2, cc.p(centerX, 430), cc.p(0.5, 0.5), 22, true, 10)

	local strLvTitle = {"(LV.39-50)", "(LV.51-60)", "(LV.61-71)"}
	createLabel(parNode, strLvTitle[page], cc.p(centerX, 185), cc.p(0.5, 0.5), 20, true, 10, nil, MColor.white)


	local strSuggestBattleForce = game.getStrByKey("suggest_battleforce")
	createLabel(parNode, strSuggestBattleForce, cc.p(120, 100), cc.p(0.5, 0.5), 20, true, 10)
	local lvNeedForce = tostring(self.mSuggestBattleForce[page])
	createLabel(parNode, lvNeedForce, cc.p(120, 70), cc.p(0.5, 0.5), 20, true, 10)


	-------------------------------------------------------

    return cell
end

function FBDefensePrincess:viewTouchEnded(touch, event)

	local tbView = self.mTabView
	if not tbView then return end
	local curOffset = tbView:getContentOffset()

--	log("[FBDefensePrincess:viewTouchEnded] x = %d, y = %d.", curOffset.x, curOffset.y)

	local pageOld = self.mPageIndex
	local destPage = self:scrollToNearPage(curOffset.x)
	self.mPageIndex = destPage
	self:updateHardTypeByPageIndex(destPage)

	if pageOld ~= self.mPageIndex then
		self:updatePageButtonState()
	end
end

function FBDefensePrincess:scrollToPage(_page, _animate)
	local viewOffset = (_page - 1) * self.mPageWidth

	if self.mTabView then
		self.mTabView:setContentOffset(cc.p(-viewOffset, 0), _animate)
	end
end

function FBDefensePrincess:scrollDecreasePage()
	local curPage = self.mPageIndex
	local pageCount = self.mPageCount

	if pageCount == 1 then return end
	if curPage <= 1 then return end


	curPage = curPage - 1
	if curPage == 1 then
		self.mBtnLeft:setVisible(false)
	end
	self.mBtnRight:setVisible(true)

	self.mPageIndex = curPage
	self:updateHardTypeByPageIndex(curPage)
	self:scrollToPage(curPage, true)
	self:updateDialogPage()
end

function FBDefensePrincess:scrollIncreasePage()
	local curPage = self.mPageIndex
	local pageCount = self.mPageCount

	if pageCount == 1 then return end
	if curPage >= 3 then return end
	if pageCount == 2 and curPage == 2 then return end


	curPage = curPage + 1

	if curPage == 3 or pageCount == 2 then
		self.mBtnRight:setVisible(false)
	end
	self.mBtnLeft:setVisible(true)

	self.mPageIndex = curPage
	self:updateHardTypeByPageIndex(curPage)
	self:scrollToPage(curPage, true)
	self:updateDialogPage()
end

function FBDefensePrincess:scrollToNearPage(posX)
	local px = -posX
	local nDestPage = math.floor((px+self.mPageWidth/2) / self.mPageWidth) + 1
	if nDestPage < 1 then nDestPage = 1
	elseif nDestPage > 3 then nDestPage = 3 end

	if nDestPage > self.mPageCount then
		nDestPage = self.mPageCount
	end

	self:scrollToPage(nDestPage, true)

	return nDestPage
end

function FBDefensePrincess:updatePageButtonState()
	local pagecount = self.mPageCount

	if pagecount == 1 then
		self.mBtnLeft:setVisible(false)
		self.mBtnRight:setVisible(false)
	elseif pagecount == 2 then
		if self.mPageIndex == 1 then
			self.mBtnLeft:setVisible(false)
			self.mBtnRight:setVisible(true)
		elseif self.mPageIndex == 2 then
			self.mBtnLeft:setVisible(true)
			self.mBtnRight:setVisible(false)
		end
	else
		if self.mPageIndex == 1 then
			self.mBtnLeft:setVisible(false)
			self.mBtnRight:setVisible(true)
		elseif self.mPageIndex == 2 then
			self.mBtnLeft:setVisible(true)
			self.mBtnRight:setVisible(true)
		else
			self.mBtnLeft:setVisible(true)
			self.mBtnRight:setVisible(false)
		end
	end
end

function FBDefensePrincess:updateHardTypeByPageIndex(pageindex)
	local pagecount = self.mPageCount
	if pagecount > 1 then
		self.mCurHardLevel = pageindex
	end
end

function FBDefensePrincess:checkNeedReset(_hardtype, _level, _resetcount)
	local needReset = false
	if _hardtype ~= 0 and _level == 5 then
		needReset = true
	end

	if needReset then
		if _resetcount == 0 then
			TIPS({ type = 1, str = game.getStrByKey("rescue_princess_tomorrow") })
		else
			TIPS({ type = 1, str = game.getStrByKey("rescue_princess_needreset") })
		end
	end

	return needReset
end

-----------------------------------------------------------

function FBDefensePrincess:showDialogPrize(type, level)

	self.mPrizeType = type

	local layer = cc.Layer:create()

	local bgFilePath = "res/jjc/winBg.png"
	local btnNormal = "res/component/button/50.png"
	local imagePathCardBack = "res/fb/defense/card_back.png"
	local imagePathCardFront = "res/fb/defense/card_front.png"


	local nodeDlg = createSprite(layer, bgFilePath, cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	nodeDlg:setTag(1111)
	self.mDialogPrize = layer


	local strText = nil
	local posCenter = getCenterPos(nodeDlg)
	local posCenterX = posCenter.x + 5
	local posCenterY = posCenter.y
	local sec = 5

	self.mCardPos[1] = cc.p(posCenterX - 200, posCenterY - 15)
	self.mCardPos[2] = cc.p(posCenterX,       posCenterY - 15)
	self.mCardPos[3] = cc.p(posCenterX + 200, posCenterY - 15)


	local btnCBFuncNext = function()
		self:goNextLevel()
	end

	local btnCBFuncExit = function()
		self:goExit()
	end

	createSprite(nodeDlg, "res/fb/defense/text_passlevel.png", cc.p(posCenterX, 540), cc.p(0.5, 0.5))

	self.btnNext = createMenuItem(nodeDlg, btnNormal, cc.p(posCenterX, 85), btnCBFuncNext)
	self.btnNext:setVisible(false)

	self.btnExit = createMenuItem(nodeDlg, btnNormal, cc.p(posCenterX, 85), btnCBFuncExit)
	self.btnExit:setVisible(false)

	self.mTimeLeft = 5

	if type == 1 then

		strText = string.format(game.getStrByKey("rescue_princess_title_pass"), level)
		local labUp = createLabel(nodeDlg, strText, cc.p(posCenterX, 465), cc.p(0.5, 0.5), 20, true, 10)

        strText = game.getStrByKey("rescue_princess_btn_nextlevel")
        self.labDownBtn = createLabel(self.btnNext, strText, cc.p(70, 30), cc.p(0.5, 0.5), 20, true, 10)

	elseif type == 3 then

		strText = game.getStrByKey("rescue_princess_title_success")
		local labUp = createLabel(nodeDlg, strText, cc.p(posCenterX, 465), cc.p(0.5, 0.5), 20, true, 10)

        strText = game.getStrByKey("fb_exitFb")
        self.labDownBtn = createLabel(self.btnExit, strText, cc.p(70, 30), cc.p(0.5, 0.5), 20, true, 10)

	end

	strText = string.format(game.getStrByKey("rescue_princess_autoselect"), sec)
	self.labDown = createLabel(nodeDlg, strText, cc.p(posCenterX, 45), cc.p(0.5, 0.5), 20, true, 10)

	----------------------------------------------------------
	-- draw card prize

	local cardCBFunc = function(target, node)
		local tag = 1
		if node ~= nil then
			tag = node:getTag()
		end

		local index = tag

		self:sendSelectPrize(index)
	end


	for i = 1, 3 do
		local cardItem = createMenuItem(nodeDlg, imagePathCardBack, self.mCardPos[i], cardCBFunc)
		cardItem:setTag(i)
		cardItem:setAnchorPoint(cc.p(0.5, 0.5))
		self.mCardNode[i] = cardItem

		cardItem = createMenuItem(nodeDlg, imagePathCardFront, self.mCardPos[i])
		cardItem:setTag(i)
		cardItem:setAnchorPoint(cc.p(0.5, 0.5))
		cardItem:setVisible(false)
		self.mCardNodeFront[i] = cardItem
	end

    self.mLabItemName = createLabel(nodeDlg, "", cc.p(posCenterX, 100), cc.p(0.5, 0.5), 20, true, 10)
    self.mLabItemName:setVisible(false)

	-----------------------------------------------------

	Manimation:transit(
	{
	ref = getRunScene() ,
	node = layer ,
	curve = "-",
	sp = cc.p( display.width/2, display.height/2 ),
	zOrder = 199 ,
	swallow = false,
	})

	self.mDialogOpened = true
end

function FBDefensePrincess:updateDialogPrize(itemIdGet, itemIdxSelect)
	if self.mDialogPrize == nil then
		return
	end

	local nodeDlg = self.mDialogPrize:getChildByTag(1111)
	if nodeDlg == nil then
		return
	end

	self.mPrizeType = self.mPrizeType + 1

	----------------------------------------------------------

	self.mTimeLeft = 5

	local showNext = true
	local showExit = false
	if self.mPrizeType == 4 then
		showNext = false
		showExit = true
		self.mTimeLeft = 10
	end

	if self.btnNext ~= nil then
		self.btnNext:setVisible(showNext)
	end
	if self.btnExit ~= nil then
		self.btnExit:setVisible(showExit)
	end

	----------------------------------------------------------


	local strDown = nil
	local sec = self.mTimeLeft
	if type == 2 then
		strDown = string.format(game.getStrByKey("rescue_princess_autonextlevel"), sec)
	else
		strDown = string.format(game.getStrByKey("rescue_princess_autoexit"), sec)
	end


	if self.labDown ~= nil then
		self.labDown:setString(strDown)
	end

	----------------------------------------------------------

--	if self.mCardNode[itemIdxSelect] ~= nil then
--		self.mCardNode[itemIdxSelect]:setImages("res/fb/defense/card_front.png")
--	end


	local effPos = getCenterPos(self.mCardNode[itemIdxSelect])
	effPos.y = effPos.y + 5
	local cardEff = Effects:create(false)
	cardEff:playActionData("card", 20, 1.5, 1)
	addEffectWithMode(cardEff,3)
	cardEff:setPosition(effPos)
	self.mCardNodeFront[itemIdxSelect]:addChild(cardEff)

	local cardBack = self.mCardNode[itemIdxSelect]
	local cardFront = self.mCardNodeFront[itemIdxSelect]
	cardBack:stopAllActions()
	cardFront:stopAllActions()
	local orbitFront = cc.OrbitCamera:create(0.15,1,0,90,-90,0,0)
	local orbitBack = cc.OrbitCamera:create(0.15,1,0,0,-90,0,0)
	local action = cc.TargetedAction:create(cardFront, cc.Sequence:create(cc.Show:create(), orbitFront))
	cardFront:setVisible(false)
	cardBack:runAction(cc.Sequence:create(cc.Show:create(), orbitBack, cc.Hide:create(), action))

	----------------------------------------------------------

	local prizePos = self.mCardPos[itemIdxSelect]
    prizePos.y = prizePos.y + 37

	local Mprop = require "src/layers/bag/prop"
	local itemData = unserialize(itemIdGet)
	local itemID = 0
	for k, v in pairs(itemData) do
		local icon = Mprop.new(
		{
			protoId = tonumber(v.itemID),
			num = tonumber(v.count),
			swallow = true,
			cb = "tips",
		})
		icon:setTag(9)
		nodeDlg:addChild(icon)
		icon:setPosition(prizePos)
		icon:setAnchorPoint(0.5, 0.5)
		itemID = v.itemID

		break
	end


	----------------------------------------------------------

	local propOp = require("src/config/propOp")
	local itemName = propOp.name(itemID)
	log("FBShowName itemName = %s, itemId = %d.", itemName, itemID)

	prizePos.y = prizePos.y - 98
	if itemName then
        self.mLabItemName:setString(itemName)
		self.mLabItemName:setPosition(prizePos)
        self.mLabItemName:setVisible(true)
	else
        self.mLabItemName:setVisible(false)
	end

end

function FBDefensePrincess:closeDialogPrize()
	if self.mDialogPrize then
		removeFromParent(self.mDialogPrize)
		self.mDialogPrize = nil
	end

	self.mDialogOpened = false

--	log("[FBDefensePrincess:closeDialogPrize] called.")
end


function FBDefensePrincess:sendSelectPrize(index)
	if index < 1 then index = 1 end
	local roleid = userInfo.currRoleId
	--g_msgHandlerInst:sendNetDataByFmtExEx(COPY_RESCUEPRINCESS_CS_STEPPRIZE_SELECT, "iis", roleid, index, 2)
	log("[FBDefensePrincess:sendSelectPrize] called. roleid = %d, index = %d.", roleid, index)
end

function FBDefensePrincess:goNextLevel()
	local levelID = self.mCurrentLevel + 1

	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol",{copyId = levelID, friendId = 0, isInCopy = 1})
	log("[FBDefensePrincess:goNextLevel] called. levelID = %d.", levelID)
	self:closeDialogPrize()
end

function FBDefensePrincess:goExit()
	log("[FBDefensePrincess:goExit] called.")
	--g_msgHandlerInst:sendNetDataByFmtExEx(COPY_CS_GUARDCOPY_AFTERDRAW, "i", userInfo.currRoleId)
	self:closeDialogPrize()
end

function FBDefensePrincess:autoSelectCard()
	local index = math.random(1, 3)
	return index
end

function FBDefensePrincess:updateTimeLeft()
	if self.mDialogOpened == false then
		return
	end

	if self.mTimeLeft > 0 then
		self.mTimeLeft = self.mTimeLeft - 1

		if self.labDown ~= nil then
			self.labDown:setString(self:getTimeString(self.mPrizeType, self.mTimeLeft))
		end

		if self.mTimeLeft <= 0 then
			self:goStep()
		end
	end
end

function FBDefensePrincess:getTimeString(type, second)
	if second < 0 then
		second = 0
	end

	if type < 1 then type = 1 end
	if type > 4 then type = 4 end

	local strkey =
	{
		"rescue_princess_autoselect",
		"rescue_princess_autonextlevel",
		"rescue_princess_autoselect",
		"rescue_princess_autoexit"
	}

	local strTime = string.format(game.getStrByKey(strkey[type]), second)
	return strTime
end

function FBDefensePrincess:goStep()
	local step = self.mPrizeType

	if step == 1 then
		local cardIndex = self:autoSelectCard()
		self:sendSelectPrize(cardIndex)
	elseif step == 2 then
		self:goNextLevel()
	elseif step == 3 then
		local cardIndex = self:autoSelectCard()
		self:sendSelectPrize(cardIndex)
	else
		self:goExit()
	end
end


-----------------------------------------------------------

function FBDefensePrincess:networkHander(luabuffer,msgid)

	cclog("[FBDefensePrincess:networkHander] called." .. msgid)

    local switch = {
		[COPY_SC_GETGUARDDATA_RET] = function()
		 	local roleID = luabuffer:popInt()
 			local hardType = luabuffer:popShort()
			local curLevel = luabuffer:popShort()
			local curResetCount = luabuffer:popShort()

			local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
			if ILevel == nil or ILevel < 39 then
				TIPS({type=1, str=game.getStrByKey("rescue_princess_levellow")})
			else
				self:showDialogText(hardType, curLevel, curResetCount)
			end

			cclog("[COPY_SC_GETGUARDDATA_RET] %d, %d, %d, %d.", roleID, hardType, curLevel, curResetCount)
        end,

		[COPY_RESCUEPRINCESS_SC_STEPPRIZE_INFO] = function()
		 	local itemId1 = luabuffer:popInt()
 			local itemId2 = luabuffer:popInt()
 			local itemId3 = luabuffer:popInt()
 			local mapID = luabuffer:popInt()
			local curLevel = luabuffer:popInt()

			local type = 1
			if mapID == 0 then
				type = 3
			end

			self.mCurrentLevel = curLevel
			self:showDialogPrize(type, mapID)

			if mapID == 0 and G_MAINSCENE.map_layer then
				G_MAINSCENE.map_layer:setNpcNormal(10398)
			end

            cclog("[COPY_RESCUEPRINCESS_SC_STEPPRIZE_INFO] %d, %d, %d, %d, %d.", itemId1, itemId2, itemId3, mapID, curLevel)
        end,

		[COPY_RESCUEPRINCESS_SC_STEPPRIZE_SELECT_RET] = function()
		 	local itemIdGet = luabuffer:popString()
 			local itemIdxSelect = luabuffer:popInt()

            cclog("[COPY_RESCUEPRINCESS_SC_STEPPRIZE_SELECT_RET] %s, %d", itemIdGet, itemIdxSelect)
			self:updateDialogPrize(itemIdGet, itemIdxSelect)
        end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end

end

-----------------------------------------------------------

return FBDefensePrincess
