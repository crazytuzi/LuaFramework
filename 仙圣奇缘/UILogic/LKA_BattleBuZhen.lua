--------------------------------------------------------------------------------------
-- 文件名:	LKA_Game_BattleBuZhen.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	布阵界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_BattleBuZhen = class("Game_BattleBuZhen")
Game_BattleBuZhen.__index = Game_BattleBuZhen

local tbClientPos = {}
local tbInBattlePos = {}
local MoveWidget = nil
local HitWidget = nil
local nBegin = nil
local BeginWidget = nil
local BeginWidget = nil
local touchBegan = false


local function sortBattlePos(tbBuZhenPosA, tbBuZhenPosB)
	return tbBuZhenPosA.nPosIdx < tbBuZhenPosB.nPosIdx
end

local function sortQiShuZhenfaCsv(CSV_QiShuZhenfaA, CSV_QiShuZhenfaB)
	return CSV_QiShuZhenfaA.SortRank < CSV_QiShuZhenfaB.SortRank
end

function Game_BattleBuZhen:getQiShuZhenfaInSort(nSortRank)
	if not g_TableQiShuZhenfaCsvInSort then
		g_TableQiShuZhenfaCsvInSort = {}
		for k, v in pairs (ConfigMgr.QiShuZhenfa) do
			table.insert(g_TableQiShuZhenfaCsvInSort, v)
		end
		table.sort(g_TableQiShuZhenfaCsvInSort, sortQiShuZhenfaCsv)
	end
	
	local nSortRank = nSortRank or 0
	
    local tbCsv = g_TableQiShuZhenfaCsvInSort[nSortRank]
    if not tbCsv then
		cclog("===Game_BattleBuZhen:getQiShuZhenfaInSort error ==="..nSortRank)
		return ConfigMgr.QiShuZhenfa_[0]
	end
	return tbCsv
end

function Game_BattleBuZhen:closeWnd()
	self.Button_ZhenFaItem_Check = nil
	self.CheckBox_SelectFlag_Check = nil
end

function Game_BattleBuZhen:setCardIcon(Image_BuZhenCard, tbCardBase,nIndex)
	local Image_Frame = tolua.cast(Image_BuZhenCard:getChildByName("Image_Frame"), "ImageView")
	local Image_Icon = tolua.cast(Image_BuZhenCard:getChildByName("Image_Icon"), "ImageView")
	local Image_StarLevel = tolua.cast(Image_BuZhenCard:getChildByName("Image_StarLevel"), "ImageView")
	local AtlasLabel_AttackOrder = tolua.cast(Image_BuZhenCard:getChildByName("AtlasLabel_AttackOrder"), "LabelAtlas")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCardBase:getEvoluteLevel()))
	Image_Icon:loadTexture(getIconImg(tbCardBase:getCsvBase().SpineAnimation))
	Image_StarLevel:loadTexture(getIconStarLev(tbCardBase:getStarLevel()))
	AtlasLabel_AttackOrder:setValue(nIndex)
end

function Game_BattleBuZhen:update_Image_BuZhenPosPNL()	
	table.sort(tbInBattlePos, sortBattlePos)
	
	local nSubSititution = 0
	for nPosIndex = 1, 12 do
		local Button_BuZhenPos = tolua.cast(self.Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos"..nPosIndex), "Button")
		if tbClientPos[nPosIndex] then
			g_SetBtnEnable(Button_BuZhenPos, true)
			local nServerID = tbClientPos[nPosIndex].nServerID
			local nPosIdx = tbClientPos[nPosIndex].nPosIdx
			local CSV_CardBase = g_Hero:getCardObjByServID(nServerID)
			local Image_BuZhenCard = Button_BuZhenPos:getChildByName("Image_BuZhenCard")
			if not Image_BuZhenCard then
				Image_BuZhenCard = g_WndMgr:getWnd("Game_BattleBuZhen").Image_BuZhenCard:clone()
				Button_BuZhenPos:addChild(Image_BuZhenCard)
				Image_BuZhenCard:setName("Image_BuZhenCard")
			end
			Image_BuZhenCard:setVisible(true)
			local nIndex = nil
			for i,v in ipairs(tbInBattlePos)do
				if v.nPosIdx == nPosIdx then
					nIndex = i
				end
			end
			nIndex = nIndex or nPosIdx
			if nIndex > 5 then
				nSubSititution = nSubSititution + 1
				self:setCardIcon(Image_BuZhenCard, CSV_CardBase,5 + nSubSititution)
			else
				self:setCardIcon(Image_BuZhenCard, CSV_CardBase,nIndex)
			end
		else
			local bStatus = false
			for nZhenXinIndex = 1, 5 do
				local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(self.nCurrentCheckBoxIndex)
				local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(CSV_ZhenFaInSort.ZhenFaID, nZhenXinIndex)
				local nIndex = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
				if nIndex == nPosIndex or nPosIndex > 9 then
					bStatus = true
				end
			end
			g_SetBtnBright(Button_BuZhenPos, bStatus)
			
			Button_BuZhenPos:setTouchEnabled(false)
			
			local Image_BuZhenCard = Button_BuZhenPos:getChildByName("Image_BuZhenCard")
			if Image_BuZhenCard then
				Image_BuZhenCard:setVisible(false)
			end
		end 
	end	
end

function Game_BattleBuZhen:setBuZhenPlayerPos()
	local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(self.nCurrentCheckBoxIndex)
	
	local tbBattleList = g_Hero:getBattleCardList()
	tbClientPos = {}
	tbInBattlePos = {}

	for i = 1, 6 do
		local tbBattleCard = tbBattleList[i]
		if tbBattleCard then
			local nServerID = tbBattleCard.nServerID
			local nPosIdx = tbBattleCard.nPosIdx
			if nServerID and nServerID ~= 0 and nPosIdx then 
				local tbCard = g_Hero:getCardObjByServID(nServerID)
				if nPosIdx < 6 and tbCard then
					local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(CSV_ZhenFaInSort.ZhenFaID, nPosIdx)
					local nClientPos = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
					if nClientPos then
						tbClientPos[nClientPos] = tbBattleCard
						table.insert(tbInBattlePos, tbBattleCard)
					end
				elseif nPosIdx >= 6 and tbCard then
					local nClientPos = g_Hero:getBuZhenPosByIndex(i)
					if nClientPos then
						tbClientPos[nClientPos] = tbBattleCard
					end
				end
			end 
		end 
	end
	self:update_Image_BuZhenPosPNL()
end

--请求当前阵法（选择阵法）
function Game_BattleBuZhen:requestSelectZhenFa(nSelectZhenFaCsvID)
	local rootMsg = zone_pb.ArraySelectRequest()
	rootMsg.array_id = nSelectZhenFaCsvID
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ARRAY_SELECT_REQUEST, rootMsg)
end

function Game_BattleBuZhen:requestSelectZhenFaResponse(tbServerMsg)
	local nCurrentZhenFaCsvID = tbServerMsg.array_id
	self:setBuZhenPlayerPos()
	g_Hero:setCurrentZhenFaCsvID(nCurrentZhenFaCsvID)
end


function Game_BattleBuZhen:updateListViewItem(Panel_ZhenFaItem, nSortRank)
	local Button_ZhenFaItem = tolua.cast(Panel_ZhenFaItem:getChildByName("Button_ZhenFaItem"), "Button")
	Button_ZhenFaItem:setTouchEnabled(true)
	Button_ZhenFaItem:setTag(nSortRank)
	
	local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(nSortRank)
	
	local Label_ZhenFaName = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaName"), "Label")
	Label_ZhenFaName:setText(CSV_ZhenFaInSort.ZhenFaName.._T("Lv.")..g_Hero:getZhenFaLevel(CSV_ZhenFaInSort.ZhenFaID))
	
	local Label_ZhenFaProp = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaProp"), "Label")
	Label_ZhenFaProp:setText(g_Hero:getZhenFaPropString(CSV_ZhenFaInSort.ZhenFaID))
	
	local nMasterCardLevel = tonumber(g_Hero:getMasterCardLevel())--主角等级
	local nOpenLevel = tonumber(CSV_ZhenFaInSort.OpenLevel)--阵法开启等级
	
	local CheckBox_SelectFlag = tolua.cast(Button_ZhenFaItem:getChildByName("CheckBox_SelectFlag"), "CheckBox")
	local Button_ZhenFaIcon = tolua.cast(Button_ZhenFaItem:getChildByName("Button_ZhenFaIcon"), "Button")
	local BitmapLabel_OpenLevel = tolua.cast(Button_ZhenFaIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local Image_ZhenFaIcon = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_ZhenFaIcon"), "ImageView")
	if nOpenLevel > nMasterCardLevel then	
		local str = getUIImg("Frame_Qishu_Locker")
		Image_ZhenFaIcon:loadTexture(str)
		BitmapLabel_OpenLevel:setText(nOpenLevel)	
		BitmapLabel_OpenLevel:setVisible(true)
		Button_ZhenFaItem:setTouchEnabled(false)
		Button_ZhenFaItem:setBright(false)
	else
		local str = getIconImg("Qishu_ZhenFa"..CSV_ZhenFaInSort.ZhenFaID)
		Image_ZhenFaIcon:loadTexture(str)
		BitmapLabel_OpenLevel:setVisible(false)
		Button_ZhenFaItem:setTouchEnabled(true)
		Button_ZhenFaItem:setBright(true)
	end
	
	local nCurrentZhenFaCsvID = g_Hero:getCurrentZhenFaCsvID()
	CheckBox_SelectFlag:setTag(CSV_ZhenFaInSort.ZhenFaID)
	local function onPressed_Button_ZhenFaItem(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local nSortRank = pSender:getTag()
			local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(nSortRank)
			self.nCurrentCheckBoxIndex = nSortRank
			
			self:requestSelectZhenFa(CSV_ZhenFaInSort.ZhenFaID)
			
			if self.Button_ZhenFaItem_Check then
				self.Button_ZhenFaItem_Check:setTouchEnabled(true)
			end
			if self.CheckBox_SelectFlag_Check then
				self.CheckBox_SelectFlag_Check:setSelectedState(false)
			end
			self.CheckBox_SelectFlag_Check = CheckBox_SelectFlag
			self.Button_ZhenFaItem_Check = pSender
			self.CheckBox_SelectFlag_Check:setSelectedState(true)
			self.Button_ZhenFaItem_Check:setTouchEnabled(false)
		end
	end
	
	if nCurrentZhenFaCsvID == CSV_ZhenFaInSort.ZhenFaID then
		CheckBox_SelectFlag:setSelectedState(true)
		self.CheckBox_SelectFlag_Check = CheckBox_SelectFlag
		self.Button_ZhenFaItem_Check = Button_ZhenFaItem
		Button_ZhenFaItem:setTouchEnabled(false)
	else
		CheckBox_SelectFlag:setSelectedState(false)
		Button_ZhenFaItem:setTouchEnabled(true)
	end
	
	if  nOpenLevel > nMasterCardLevel then
		CheckBox_SelectFlag:setVisible(false)
		Button_ZhenFaItem:setTouchEnabled(false)
	else
		CheckBox_SelectFlag:setVisible(true)
	end

	CheckBox_SelectFlag:setTouchEnabled(false)
	Button_ZhenFaItem:addTouchEventListener(onPressed_Button_ZhenFaItem)
end

function Game_BattleBuZhen:resetBattleBuZhen()
	if HitWidget == nil or MoveWidget == nil then
		return
	end

	HitWidget:setBrightStyle(BRIGHT_NORMAL)
	MoveWidget:retain()
	MoveWidget:removeFromParent()
	BeginWidget:addChild(MoveWidget)
	--移动小伙伴放开的时候
	MoveWidget:setPosition(ccp(0,0))
	MoveWidget:release()
	local nEnd = HitWidget:getTag()
	if nBegin ~= nEnd  then
		self:setBuZhenPlayerPos()
	end
	
	nBegin = nil
	HitWidget = nil
	BeginWidget = nil
	MoveWidget = nil
	touchBegan = false
end

function Game_BattleBuZhen:initWnd()
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	self.Image_BuZhenPosPNL = tolua.cast(ImageView_BattleBuZhenPNL:getChildByName("Image_BuZhenPosPNL"), "ImageView")
	local Image_ZhenFaPNL = tolua.cast(ImageView_BattleBuZhenPNL:getChildByName("Image_ZhenFaPNL"), "ImageView")
	local ListView_ZhenFa = tolua.cast(Image_ZhenFaPNL:getChildByName("ListView_ZhenFa"), "ListViewEx")
	
	local imgScrollSlider = ListView_ZhenFa:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_ZhenFa_BuZhen_X then
		g_tbScrollSliderXY.LuaListView_ZhenFa_BuZhen_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_ZhenFa_BuZhen_X - 3)
	
	local function onUpdate_ListView_ZhenFa(Panel_ZhenFaItem, nSortRank)
		self:updateListViewItem(Panel_ZhenFaItem, nSortRank)
	end
	local function funcAdjust(Panel_ZhenFaItem, nSortRank)
		
	end
	
	local Panel_ZhenFaItem = tolua.cast(g_WidgetModel.Panel_ZhenFaItem:clone(), "Layout")
	self.ListView_ZhenFa = registerListViewEvent(ListView_ZhenFa, Panel_ZhenFaItem, onUpdate_ListView_ZhenFa)
	
	local Button_BuZhenPos1 = tolua.cast(self.Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos1"), "Button")
	self.Image_BuZhenCard = tolua.cast(Button_BuZhenPos1:getChildByName("Image_BuZhenCard"), "ImageView")
	self.Button_StartBattle = tolua.cast(Image_ZhenFaPNL:getChildByName("Button_StartBattle"), "Button")
	if self.Button_StartBattle~= nil then
		self.Button_StartBattle:setVisible(true)
	end

	local Button_Confirm = tolua.cast(Image_ZhenFaPNL:getChildByName("Button_Confirm"), "Button")
	if Button_Confirm ~= nil then
		Button_Confirm:setVisible(false)
	end

	local posY_CheckLight = 0
	local function onPressed_Button_BuZhenPos(pSender, eventType)
		if self.startBattle == true then return end
		if(eventType == ccs.TouchEventType.began) and not touchBegan  then
			touchBegan = true
			MoveWidget = pSender:getChildByName("Image_BuZhenCard")
			nBegin = pSender:getTag()
			BeginWidget = pSender
			HitWidget = pSender
			if not MoveWidget then return end
			--移动小伙伴的时候
			if(MoveWidget)then
				MoveWidget:retain()
				MoveWidget:removeFromParent()
				g_WndMgr:addChild(MoveWidget)
				
				local nPos = pSender:getTouchStartPos()
				MoveWidget:setPosition(ccp(nPos.x, nPos.y))
				MoveWidget:release()
			end
		elseif (eventType == ccs.TouchEventType.ended) or (eventType == ccs.TouchEventType.canceled) then
			if MoveWidget == nil then return end
			if HitWidget and HitWidget:isExsit() then
				HitWidget:setBrightStyle(BRIGHT_NORMAL)
				local nEnd = HitWidget:getTag()
				local nBattleIndex = g_Hero:getBuZhenPosByIndex(1)--队长的位置
				if(nBegin ~= nEnd )then
					if(nBattleIndex == tbClientToServerPosConvert[nBegin] and nEnd > 9)then--说明队长要放到替补位置上面
						g_ClientMsgTips:showMsgConfirm(_T("队长不能成为替补！"))
						self:resetBattleBuZhen()
						return
					else
                        if(nBegin > 9 and nEnd < 10 )then --说明替补要去替换队长位置
						    local nIndex = tbClientToServerPosConvert[nEnd]
                            if(nIndex == nBattleIndex)then
                                g_ClientMsgTips:showMsgConfirm(_T("队长不能成为替补！"))
						        self:resetBattleBuZhen()
                                return
                            end
                         end
					end
					-- local tbCardList = g_Hero:getBattleCardList()
					BeginIndex = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nBegin])
					EndIndex = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nEnd])
					
					g_MsgMgr:requestChangeCard(BeginIndex, EndIndex)
				else
					self:resetBattleBuZhen()
				end
			end
		elseif(eventType == ccs.TouchEventType.moved)then
			local nPos = pSender:getTouchMovePos()
			if not MoveWidget then return end
			MoveWidget:setPosition(ccp(nPos.x, nPos.y))
			for i = 0, 12 do
				local Button_BuZhenPos = tolua.cast(self.Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos"..i), "Button")
				local widget = Button_BuZhenPos
				if(widget ~= nil and widget:hitTest(nPos)) then
					local tbCheckPos = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[i])
			
					if not tbCheckPos then  return  end
					if widget ~= HitWidget then
						if HitWidget and HitWidget:isExsit() then
							HitWidget:setBrightStyle(BRIGHT_NORMAL)
							HitWidget = widget
							HitWidget:setBrightStyle(BRIGHT_HIGHLIGHT)
						end
					end
					break 
				end
				
			end
		end
		
	end
	
	for nPosIndex = 1, 12 do
		local Button_BuZhenPos = tolua.cast(self.Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos"..nPosIndex), "Button")
		Button_BuZhenPos:setTouchEnabled(true)
	    Button_BuZhenPos:addTouchEventListener(onPressed_Button_BuZhenPos)
		Button_BuZhenPos:setTag(nPosIndex)
	end
end

function Game_BattleBuZhen:openWnd(nTag)
	if g_bReturn then
        return      
    end 

	self.startBattle = false
	local nTag = nTag or self.Button_StartBattle:getTag()
	local function clickStartBattle(sender, nTag)
		g_WndMgr:closeWnd("Game_BattleBuZhen")
	end
	g_SetBtnWithGuideCheck(self.Button_StartBattle, nTag, clickStartBattle, true)
	
	local nCurrentZhenFaCsvID = g_Hero:getCurrentZhenFaCsvID()
	local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(nCurrentZhenFaCsvID, 1)
	self.nCurrentCheckBoxIndex = CSV_ZhenFa.SortRank
	
	self:setBuZhenPlayerPos()
	
	self.ListView_ZhenFa:updateItems(g_Hero:getZhenFaListCount(), self.nCurrentCheckBoxIndex)
	
	local Image_TeamStrength = tolua.cast(self.Image_BuZhenPosPNL:getChildByName("Image_TeamStrength"), "ImageView")
	local Label_TeamStrength = tolua.cast(Image_TeamStrength:getChildByName("Label_TeamStrength"), "Label")
	Label_TeamStrength:setText(g_Hero:getTeamStrength())
	
	Label_TeamStrength:setPositionX(Image_TeamStrength:getSize().width)
	
	local Image_Initialtive = tolua.cast(self.Image_BuZhenPosPNL:getChildByName("Image_Initialtive"), "ImageView")
	local Label_Initialtive = tolua.cast(Image_Initialtive:getChildByName("Label_Initialtive"), "Label")
	Label_Initialtive:setText(g_Hero:getTeamAttackPower())
	Label_Initialtive:setPositionX(Image_Initialtive:getSize().width)
end

function Game_BattleBuZhen:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_BattleBuZhenPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BattleBuZhen:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_BattleBuZhenPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end