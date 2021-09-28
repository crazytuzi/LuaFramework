--------------------------------------------------------------------------------------
-- 文件名:	HJW_BattleBuZhenDuJie.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-05-04
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------

Game_BattleBuZhenDuJie = class("Game_BattleBuZhenDuJie")
Game_BattleBuZhenDuJie.__index = Game_BattleBuZhenDuJie

function Game_BattleBuZhenDuJie:initWnd()
	
	--渡劫阵型选择响应
	local order = msgid_pb.MSGID_DUJIE_ARRAY_SELECT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestArraySelectResponse))	
	--修改阵型响应
	local order = msgid_pb.MSGID_DUJIE_CHANGE_ARRAYOP_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestChangeArrayOpResponse))	
	
end

function Game_BattleBuZhenDuJie:openWnd(param)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_BuZhenPosPNL = tolua.cast(ImageView_BattleBuZhenPNL:getChildByName("Image_BuZhenPosPNL"), "ImageView")
	local Image_TeamStrength = tolua.cast(Image_BuZhenPosPNL:getChildByName("Image_TeamStrength"), "ImageView")
	local Label_TeamStrength = tolua.cast(Image_TeamStrength:getChildByName("Label_TeamStrength"), "Label")
	Label_TeamStrength:setPositionX(Image_TeamStrength:getSize().width)
	
	local Image_Initialtive = tolua.cast(Image_BuZhenPosPNL:getChildByName("Image_Initialtive"), "ImageView")
	local Label_Initialtive = tolua.cast(Image_Initialtive:getChildByName("Label_Initialtive"), "Label")
	Label_Initialtive:setPositionX(Image_Initialtive:getSize().width)
	
	g_FormMsgSystem:RegisterFormMsg(FormMsg_BattBuZhenDuJie_Wnd,handler(self,self.battCloseWnd))
	
	if not param then return end
	self.tbQueueCards_ = param.queueCard 
	local nAttackPower = 0
	local nTeamStrength = 0
	for i = 1,#self.tbQueueCards_ do

		local nServerID = self.tbQueueCards_[i].nCardID
		local tbCard = g_Hero:getCardObjByServID(nServerID)
		if tbCard then
			nAttackPower = nAttackPower + tbCard:getAttackPower()
			nTeamStrength = nTeamStrength + tbCard:getCardStrength()
		end
	end
	Label_TeamStrength:setText(nTeamStrength)
	Label_Initialtive:setText(nAttackPower) --先攻
	
	self:zhenFaPNLShow()
	self:updateQueue()
	self:btnStartBattle()
end

function Game_BattleBuZhenDuJie:closeWnd()
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_BattBuZhenDuJie_Wnd)
end


function Game_BattleBuZhenDuJie:battCloseWnd()
	g_WndMgr:closeWnd("Game_BattleBuZhenDuJie")

	 local instance = g_WndMgr:getWnd("Game_DuJieSelectHelper")
	 if instance then 
		g_WndMgr:closeWnd("Game_DuJieSelectHelper")
	 end
end

function Game_BattleBuZhenDuJie:updateQueue()
	local curZhenFaId = g_Hero:getDuJieMethodIndex()
	self.tbQueueCard_ = {}
	local tbDuJieArray = g_Hero:getDuJieArray()
	local nCount = 1
	for i = 1,#tbDuJieArray do
		local nIndex = nil
		local nClientPos = nil
		if i < 6 then 
			local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(curZhenFaId,i)
			nIndex =  tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
		else
			nClientPos =  i - 6 + 10
		end
		local posIdx = tbDuJieArray[i].posidx
		local card_idx = tbDuJieArray[i].card_idx
		local t = {}
		t.nPosIdx = nIndex or nClientPos
		t.nServerID = 0
		t.cardIndex = 0
		
		if self.tbQueueCards_[card_idx] and card_idx <= 3 then 
			t.nServerID  = self.tbQueueCards_[card_idx].nCardID
			t.cardIndex  = self.tbQueueCards_[card_idx].nIndex
			nCount = nCount + 1
		end

		table.insert(self.tbQueueCard_,t)
	end
	
	self:buZhenPosPnlByQueue(curZhenFaId)
end


--队列
function Game_BattleBuZhenDuJie:buZhenPosPnlByQueue(curZhenFaId)
	local tbQueueCard  = {}
	local moveToObj = nil
	local moveWidget = nil
	--移动过的地方 恢复回原来的样子
	local function recover(objStyle)
		if objStyle then 
			objStyle:setBrightStyle(BRIGHT_NORMAL)
			objStyle = nil
		end
	end
	local function zhenFaIndex(nIndex)
		local tbZhenFa = g_DataMgr:getCsvConfig_SecondKeyTableData("QiShuZhenfa",curZhenFaId)
		local nPos = nIndex
		if nPos >  9 then return nPos - 10 + 6 end
		for i=1, #tbZhenFa do
			if tbZhenFa[i].BuZhenPosIndex == nPos then
				return tbZhenFa[i].ZhenXinID
			end
		end
	end
	
	--进行一次 服务器布阵下标的更新 （有客户端下标更新为服务器下标）
	for i = 1, #self.tbQueueCard_ do 
		local tbQueue = self.tbQueueCard_[i]
		if tbQueue then 
			local nServerID = tbQueue.nServerID 
			-- local nPosIdx = tbQueue.nPosIdx
			if nServerID and nServerID > 0 then 
				local tbCard = g_Hero:getCardObjByServID(nServerID)
				if tbCard and i < 6 then 
					local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(curZhenFaId, i)
					local nClientPos = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
					tbQueueCard[nClientPos] = tbQueue
				elseif tbCard and i >= 6 then
					local nClientPos = i - 6 + 10
					tbQueueCard[nClientPos] = tbQueue
				end
			end
		end
	end
	
	local function replaceWidget(moveWidget,widget)
		if moveWidget and moveWidget:isExsit() then
			moveWidget:retain()
			moveWidget:removeFromParent()
			moveWidget:setPosition(ccp(0,0))
			widget:addChild(moveWidget)
			moveWidget = nil
		end
	end

	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_BuZhenPosPNL = tolua.cast(ImageView_BattleBuZhenPNL:getChildByName("Image_BuZhenPosPNL"), "ImageView")
	
	local function onClick_Button_BuZhenPos(pSender, eventType)
		if eventType == ccs.TouchEventType.began then
			moveWidget = pSender:getChildByName("Image_BuZhenCard")
			
			--移动小伙伴的时候
			if moveWidget then
				moveToObj = pSender
				moveWidget:retain()
				moveWidget:removeFromParent()
				g_WndMgr:addChild(moveWidget)
				local nPos = pSender:getTouchStartPos()
				moveWidget:setPosition(ccp(nPos.x, nPos.y))
				moveWidget:release()
			end
		elseif eventType == ccs.TouchEventType.ended or eventType == ccs.TouchEventType.canceled then
			
			-- if not moveWidget then return end
			if not moveToObj then return end
			local nBeginIndex = pSender:getTag()
			local moveStartPos = zhenFaIndex(tbClientToServerPosConvert[nBeginIndex])
			local nEndIndex = moveToObj:getTag()
			local moveEndPos = zhenFaIndex(tbClientToServerPosConvert[nEndIndex])
			if not tbQueueCard[nBeginIndex] then return end
			if tbQueueCard[nBeginIndex].cardIndex == 1 and nEndIndex >= 10 then 
				g_ClientMsgTips:showMsgConfirm( _T("队长不能成为替补！") )
				replaceWidget(moveWidget,pSender)
				recover(moveToObj)
				return
			else
				if(nBeginIndex > 9 and nEndIndex < 10 )  then
					if tbQueueCard[nEndIndex] and tbQueueCard[nEndIndex].cardIndex == 1 then 
						g_ClientMsgTips:showMsgConfirm( _T("队长不能成为替补！") )
						replaceWidget(moveWidget,pSender)
						recover(moveToObj)
						return
					end
				end
			end
			
			local widget = moveToObj:getChildByName("Image_BuZhenCard")
			if widget then 
				widget:retain()
				widget:removeFromParent()
				pSender:addChild(widget)
				widget = nil
			end
			--移动小伙伴放开的时候
			replaceWidget(moveWidget,moveToObj)
			-- moveWidget = nil
			if moveStartPos == moveEndPos then return end
			self:requestChangeArrayOpRequest(moveStartPos,moveEndPos)

		elseif eventType == ccs.TouchEventType.moved then
			
			if not moveWidget then return end
			local nPos = pSender:getTouchMovePos()
			moveWidget:setPosition(ccp(nPos.x, nPos.y))
			for i = 1, 12 do
				local Button_BuZhenPos = tolua.cast(Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos"..i), "Button")
				if(Button_BuZhenPos ~= nil and Button_BuZhenPos:hitTest(nPos)) then
					local tbCheckPos = zhenFaIndex(tbClientToServerPosConvert[i]) 
					if not tbCheckPos then return end
					recover(moveToObj)
					Button_BuZhenPos:setBrightStyle(BRIGHT_HIGHLIGHT)
					moveToObj = Button_BuZhenPos
					break 
				end
			end
		end
	end
	
	local Button_BuZhenPos1 = tolua.cast(Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos1"), "Button")
	local firstIndex = 0
	local firstIndexReplace = 5
	for i = 1, 12 do 
		local Button_BuZhenPos = tolua.cast(Image_BuZhenPosPNL:getChildByName("Button_BuZhenPos"..i), "Button")
		if i <= 9 then 
			Button_BuZhenPos:setBright(false)
		end
		for j = 1,5 do
			local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(curZhenFaId,j)
			local nIndex = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
			if nIndex == i then
				Button_BuZhenPos:setBright(true)
			end
		end
	
		local tbQueue = tbQueueCard[i]
		if tbQueue then 
			local nServerID = tbQueue.nServerID
			local Image_BuZhenCard = tolua.cast(Button_BuZhenPos:getChildByName("Image_BuZhenCard"), "ImageView")
			if not Image_BuZhenCard then 
				local Image_BuZhenCard1 = tolua.cast(Button_BuZhenPos1:getChildByName("Image_BuZhenCard"), "ImageView")
				if Image_BuZhenCard1 then 
					Image_BuZhenCard = Image_BuZhenCard1:clone()
				end
				if Image_BuZhenCard and Image_BuZhenCard:isExsit() then 
					Image_BuZhenCard:setName("Image_BuZhenCard")
					Button_BuZhenPos:addChild(Image_BuZhenCard)
				end
			end
			if Image_BuZhenCard then
				Image_BuZhenCard:setVisible(true)
				if nServerID and nServerID > 0 then 
					local tbCard = g_Hero:getCardObjByServID(nServerID)
					local Image_Frame = tolua.cast(Image_BuZhenCard:getChildByName("Image_Frame"), "ImageView")
					local Image_Icon = tolua.cast(Image_BuZhenCard:getChildByName("Image_Icon"), "ImageView")
					local Image_StarLevel = tolua.cast(Image_BuZhenCard:getChildByName("Image_StarLevel"), "ImageView")
					local AtlasLabel_AttackOrder = tolua.cast(Image_BuZhenCard:getChildByName("AtlasLabel_AttackOrder"), "LabelAtlas")
					Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
					Image_Icon:loadTexture(getIconImg(tbCard:getCsvBase().SpineAnimation))
					Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
				
					if i >= 10 then
						firstIndexReplace = firstIndexReplace + 1
						AtlasLabel_AttackOrder:setValue(firstIndexReplace) --显示卡牌为第几手
					else
						firstIndex = firstIndex + 1
						AtlasLabel_AttackOrder:setValue(firstIndex) --显示卡牌为第几手
					end
				end
			end
		else
			local GameObj_Card = Button_BuZhenPos:getChildByName("Image_BuZhenCard")
			if GameObj_Card then
				GameObj_Card:setVisible(false)
			end
		end
		
		Button_BuZhenPos:setTag(i)
		Button_BuZhenPos:setTouchEnabled(true)
		Button_BuZhenPos:addTouchEventListener(onClick_Button_BuZhenPos)
	end
end

local function sortQiShuZhenfaCsv(CSV_QiShuZhenfaA, CSV_QiShuZhenfaB)
	return CSV_QiShuZhenfaA.SortRank < CSV_QiShuZhenfaB.SortRank
end

function Game_BattleBuZhenDuJie:getQiShuZhenfaInSort(nSortRank)
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
		cclog("===Game_BattleBuZhenDuJie:getQiShuZhenfaInSort error ==="..nSortRank)
		return ConfigMgr.QiShuZhenfa_[0]
	end
	return tbCsv
end

function Game_BattleBuZhenDuJie:zhenFaPNLShow()
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_ZhenFaPNL = tolua.cast(ImageView_BattleBuZhenPNL:getChildByName("Image_ZhenFaPNL"), "ImageView")
	local ListView_ZhenFa = tolua.cast(Image_ZhenFaPNL:getChildByName("ListView_ZhenFa"), "ListViewEx")
	
	local function updateListViewItem(Panel_ZhenFaItem, nSortRank)
		local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(nSortRank)
		local nZhenFaLevel = g_Hero:getZhenFaLevel(CSV_ZhenFaInSort.ZhenFaID)
		
		local Button_ZhenFaItem = tolua.cast(Panel_ZhenFaItem:getChildByName("Button_ZhenFaItem"), "Button")
		Button_ZhenFaItem:setTag(nSortRank)
		
		local Button_ZhenFaIcon = tolua.cast(Button_ZhenFaItem:getChildByName("Button_ZhenFaIcon"), "Button")
		local Image_Frame = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_Frame"), "ImageView")
		
		local BitmapLabel_OpenLevel = tolua.cast(Button_ZhenFaIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
		local Image_ZhenFaIcon = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_ZhenFaIcon"), "ImageView")
		
		local Label_ZhenFaName = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaName"), "Label")
		Label_ZhenFaName:setText(CSV_ZhenFaInSort.ZhenFaName.._T("Lv.")..nZhenFaLevel)
		
		local Label_ZhenFaProp = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaProp"), "Label")
		Label_ZhenFaProp:setText(g_Hero:getZhenFaPropString(CSV_ZhenFaInSort.ZhenFaID))
		
		local CheckBox_SelectFlag = tolua.cast(Button_ZhenFaItem:getChildByName("CheckBox_SelectFlag"), "CheckBox")
		CheckBox_SelectFlag:setTouchEnabled(false)
		
		if g_Hero:getDuJieMethodIndex() == CSV_ZhenFaInSort.ZhenFaID then
			CheckBox_SelectFlag:setSelectedState(true)
			self.CheckBox_SelectFlag_ = CheckBox_SelectFlag
			self.Button_ZhenFaItem_ = Button_ZhenFaItem 
		else
			CheckBox_SelectFlag:setSelectedState(false)
		end
		
		if tonumber(CSV_ZhenFaInSort.OpenLevel) > tonumber(g_Hero:getMasterCardLevel()) then	
			local str = getUIImg("Frame_Qishu_Locker")
			Image_ZhenFaIcon:loadTexture(str)

			BitmapLabel_OpenLevel:setText(tonumber(CSV_ZhenFaInSort.OpenLevel))	
			BitmapLabel_OpenLevel:setVisible(true)
			Button_ZhenFaItem:setTouchEnabled(false)
		else
			local str = getIconImg("Qishu_ZhenFa"..CSV_ZhenFaInSort.ZhenFaID)
			Image_ZhenFaIcon:loadTexture(str)
			Button_ZhenFaItem:setTouchEnabled(true)
			BitmapLabel_OpenLevel:setVisible(false)
		end
		
		local function onClickSelect(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				if self.CheckBox_SelectFlag_ then self.CheckBox_SelectFlag_:setSelectedState(false) end
				CheckBox_SelectFlag:setSelectedState(true)
				self.CheckBox_SelectFlag_ = CheckBox_SelectFlag
				if self.Button_ZhenFaItem_ then self.Button_ZhenFaItem_:setTouchEnabled(true); end
				self.Button_ZhenFaItem_ = pSender
				pSender:setTouchEnabled(false)
				
				local nSortRank = pSender:getTag()
				local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(nSortRank)
				self:buZhenPosPnlByQueue(CSV_ZhenFaInSort.ZhenFaID)
				self:requestArraySelectRequest(CSV_ZhenFaInSort.ZhenFaID)
			end
		end
		Button_ZhenFaItem:addTouchEventListener(onClickSelect)
	end
	
	local Panel_ZhenFaItem = tolua.cast(g_WidgetModel.Panel_ZhenFaItem:clone(), "Layout")
    local LuaListView_ZhenFa = Class_LuaListView:new()
    LuaListView_ZhenFa:setModel(Panel_ZhenFaItem)
    LuaListView_ZhenFa:setUpdateFunc(updateListViewItem)
    LuaListView_ZhenFa:setListView(ListView_ZhenFa)
	
	local nDuJieMethodIndex = g_Hero:getDuJieMethodIndex()
	local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(nDuJieMethodIndex, 1)
	LuaListView_ZhenFa:updateItems(#g_DataMgr:getCsvConfig("QiShuZhenfa"), CSV_ZhenFa.SortRank)
	
	local imgScrollSlider = LuaListView_ZhenFa:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_ZhenFa_BuZhen_X then
		g_tbScrollSliderXY.LuaListView_ZhenFa_BuZhen_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_ZhenFa_BuZhen_X - 3)
end

function Game_BattleBuZhenDuJie:btnStartBattle()
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_ZhenFaPNL = tolua.cast(ImageView_BattleBuZhenPNL:getChildByName("Image_ZhenFaPNL"), "ImageView")
	local Button_StartBattle = tolua.cast(Image_ZhenFaPNL:getChildByName("Button_StartBattle"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_StartBattle:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText( _T("进入战斗") )
	
	Button_StartBattle:setTouchEnabled(true)
	local function clickStartBattle(sender,eventType)
		if(eventType == ccs.TouchEventType.began) then
			g_MsgMgr:requestDujie(self.tbQueueCards_)
		end
	end
	Button_StartBattle:addTouchEventListener(clickStartBattle)
end

--渡劫阵型选择请求
function Game_BattleBuZhenDuJie:requestArraySelectRequest(selectedArray)
	cclog("渡劫阵型选择请求")
	local msg = zone_pb.ArraySelectRequest() 
	msg.array_id = selectedArray--选择的阵法
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DUJIE_ARRAY_SELECT_REQUEST,msg)
end	

--渡劫阵型选择响应
function Game_BattleBuZhenDuJie:requestArraySelectResponse(tbMsg)
	cclog("---------requestArraySelectResponse-------------")
	cclog("---------渡劫阵型选择响应-------------")
	local msgDetail = zone_pb.ArraySelectResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local array_id = msgDetail.array_id 
	g_Hero:setDuJieMethodIndex(array_id)
end

--修改阵型请求
function Game_BattleBuZhenDuJie:requestChangeArrayOpRequest(move_start_pos,move_end_pos)
	cclog("修改阵型请求")
	local msg = zone_pb.ChangeArrayOpRequest() 
	msg.change_op = zone_pb.ChangeArrayType_Move--// 操作类型
	msg.move_start_pos = move_start_pos--// 移动开始位置 阵心索引，从1开始 
	msg.move_end_pos = move_end_pos --// 移动结束位置	 阵心索引，从1开始
	
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DUJIE_CHANGE_ARRAYOP_REQUEST,msg)
	
	g_MsgNetWorkWarning:showWarningText()
	
end	

--修改阵型响应
function Game_BattleBuZhenDuJie:requestChangeArrayOpResponse(tbMsg)
	cclog("---------requestChangeArrayOpResponse-------------")
	cclog("---------修改阵型响应-------------")
	local msgDetail = zone_pb.ChangeArrayOpResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local change_op = msgDetail.change_op --// 操作类型 
	local array_card_list =  msgDetail.array_card_list--操作的卡牌列表
	for i = 1,#array_card_list do
		if array_card_list[i] then 
			local index = array_card_list[i].index + 1
			local cardid = array_card_list[i].cardid
			local posidx = array_card_list[i].posidx
			g_Hero:setDuJieArray(index,cardid)
		end
	end
	
	self:updateQueue()

	g_MsgNetWorkWarning:closeNetWorkWarning()
end

function Game_BattleBuZhenDuJie:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_BattleBuZhenPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BattleBuZhenDuJie:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_BattleBuZhenPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
