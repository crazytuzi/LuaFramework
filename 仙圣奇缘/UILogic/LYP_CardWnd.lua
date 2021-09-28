--------------------------------------------------------------------------------------
-- 文件名:	LYP_CardWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2013-1-22 9:37
-- 版  本:	1.0
-- 描  述:	伙伴界面
-- 应  用:  本例子是用类对象的方式实现
-- 修  改:  LYP
-- 修  改:  flamehong改成新界面
---------------------------------------------------------------------------------------
--伙伴界面
Game_Card = class("Game_Card")
Game_Card.__index = Game_Card

local return_from_Game_ConfirmHunPo = nil

function Game_Card:initWnd()
	local ImageView_CardPNL = self.rootWidget:getChildByName("ImageView_CardPNL")
	local Image_ContentPNL = ImageView_CardPNL:getChildByName("Image_ContentPNL")
    local ListView_Card = tolua.cast(Image_ContentPNL:getChildByName("ListView_Card"), "ListViewEx")
    local LuaListView_Card = Class_LuaListView:new()
    self.LuaListView_Card = LuaListView_Card
    self:registerListViewEvent()
    LuaListView_Card:setListView(ListView_Card)
	
	local imgScrollSlider = LuaListView_Card:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_Card_X then
		g_tbScrollSliderXY.LuaListView_Card_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_Card_X + 4)
	
	g_Hero:getSortUnSummonCard()
end

function Game_Card:registerListViewEvent()

    local function onClickCard(pSender, nIndex)
		local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
		local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
		-- local nUnSummonCount =  g_Hero:getUnSummonCardListCount()
		
		if nIndex <= nHasSummonBattleCount then
			if g_PlayerGuide:checkIsInGuide() then return end
			local tbCard = g_Hero:getHasSummonBattleCardByIndex(nIndex)
			g_WndMgr:openWnd("Game_Equip1", {nCardID = tbCard:getServerId()})
		elseif nIndex <= nHasSummonUnBattleCount then
			local tbCard = g_Hero:getHasSummonUnBattleCardListIndex(nIndex)
			-- local tbCard = g_Hero:getHasSummonUnBattleCardByIndex(nIndex)
			g_WndMgr:openWnd("Game_Equip1", {nCardID = tbCard:getServerId()})
		else
			local nBegin = math.floor((nHasSummonUnBattleCount + nHasSummonBattleCount + 1)/2)*2
			local CSV_CardHunPo = g_Hero:getUnSummonCardByIndex(nIndex - nBegin)
			
			if not CSV_CardHunPo then return end 
			
			local nStarLevel = CSV_CardHunPo.CardStarLevel
			
			local GameObj_HunPo = g_Hero:getHunPoObj(CSV_CardHunPo.ID)
			
			if not GameObj_HunPo or GameObj_HunPo == "" then return  end
			
			local nHaveHunPoNum  = GameObj_HunPo:getNum() --拥有多少个魂魄
			self.GameObj_HunPo_ = GameObj_HunPo
			local nHaveMaterialNum = g_Hero:getItemNumByCsv(CSV_CardHunPo.ReplaceMaterialID, CSV_CardHunPo.ReplaceMaterialLevel)
	
			local nCostHunPoNum = math.min(nHaveHunPoNum, CSV_CardHunPo.NeedNum)
			local nReplaceMaxNum = math.min(nHaveMaterialNum, CSV_CardHunPo.NeedNum - nCostHunPoNum)
			
			if (nCostHunPoNum + nReplaceMaxNum) >= CSV_CardHunPo.NeedNum then
				local function onClick_Confirm(itemType)
					--预加载窗口缓存防止卡顿
					g_WndMgr:getFormtbRootWidget("Game_SummonAnimation")
					--itemType == 1 优先消耗魂魄 2 优先消耗万能魂石
					local wndInstance = g_WndMgr:getWnd("Game_Card")
					if not wndInstance then return end 
					local serverId = wndInstance.GameObj_HunPo_:getServerId()
					g_MsgMgr:requestExChangeCard(serverId, itemType)
				end
				
				local function onClick_Cancel(itemType)
				end
				
				local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, CSV_CardHunPo.CardStarLevel)
				local txt = string.format(_T("消耗%d个%s的魂魄和%d个万能魂石进行召唤, 是否继续?"), nCostHunPoNum, CSV_CardBase.Name,nReplaceMaxNum)
				return_from_Game_ConfirmHunPo = true
				g_WndMgr:showWnd("Game_ConfirmHunPo", {txt = txt, csvCardHunPo = CSV_CardHunPo, btnConfirm = onClick_Confirm, btnCancel = onClick_Cancel})
			end
		end
    end

    local function onClickCardDetail(pSender, nIndex)
        local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
        if nIndex <= nHasSummonBattleCount then
            local tbCard = g_Hero:getHasSummonBattleCardByIndex(nIndex)
            g_WndMgr:openWnd("Game_Equip1", {nCardID = tbCard:getServerId()})
        else
            local tbCard = g_Hero:getHasSummonUnBattleCardByIndex(nIndex - nHasSummonBattleCount)
            g_WndMgr:openWnd("Game_Equip1", {nCardID = tbCard:getServerId()})
        end
    end

    local function setSummonCard(Button_CardItemHasSummon, tbCard, nIndex, bCheck)
		if not tbCard then return end
        Button_CardItemHasSummon:setTouchEnabled(true)
        Button_CardItemHasSummon = tolua.cast(Button_CardItemHasSummon, "Button")
        if bCheck then
            Button_CardItemHasSummon:loadTextures(getUIImg("ListItem_Card_Check"), getUIImg("ListItem_Card_Check_Press"), getUIImg("ListItem_Card_Disabled"))
        else
            Button_CardItemHasSummon:loadTextures(getUIImg("ListItem_Card"), getUIImg("ListItem_Card_Press"), getUIImg("ListItem_Card_Disabled"))
        end
        local CSV_CardBase = tbCard:getCsvBase()
		
        local Label_Name = tolua.cast(Button_CardItemHasSummon:getChildByName("Label_Name"), "Label")
        Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))
        
        local Label_RealmName = tolua.cast(Button_CardItemHasSummon:getChildByName("Label_RealmName"), "Label")
        Label_RealmName:setText(tbCard:getRealmNameWithSuffix(Label_RealmName))    

        local AtlasLabel_Profession = tolua.cast(Button_CardItemHasSummon:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
        AtlasLabel_Profession:setValue(CSV_CardBase.Profession)
        g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession},10)
		
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Label_Name:setFontSize(18)
			Label_RealmName:setFontSize(18)
		end

		g_AdjustWidgetsPosition({Label_Name,AtlasLabel_Profession},10)
		-- 
		local Image_InBattle = tolua.cast(Button_CardItemHasSummon:getChildByName("Image_InBattle"), "ImageView")
        Image_InBattle:setVisible(tbCard:checkIsInBattle())
		
        --设置伙伴
        local Image_CardBase = tolua.cast(Button_CardItemHasSummon:getChildByName("Image_CardBase"), "ImageView")
        Image_CardBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
        local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
        Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
		local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
        Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))

		local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
        Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
		
		local Button_EquipList = Button_CardItemHasSummon:getChildByName("Button_EquipList")
		g_SetBtnWithGuideCheck(Button_CardItemHasSummon, nIndex, onClickCardDetail, true, nil, nil, nil)
		g_SetBtnWithGuideCheck(Image_Icon, nIndex, onClickCardDetail, true, nil, nil, nil)
		g_SetBtnWithGuideCheck(Button_EquipList, nIndex, onClickCardDetail, true, nil, nil, nil)

        local LabelBMFont_Level = tolua.cast(Button_CardItemHasSummon:getChildByName("LabelBMFont_Level"), "LabelBMFont")
        LabelBMFont_Level:setText(string.format(_T("Lv.%d"), tbCard:getLevel())) 
		
		g_addUpgradeGuide(Image_CardBase, ccp(50, 45), nil, g_CheckCardUpgrade(tbCard))
		
		--装备框
        local tbEquipIdList = tbCard:getEquipIdList()
        for i=1, 6 do
            local Image_EquipPos = Button_EquipList:getChildByName("Image_EquipPos"..i)
            local Image_Equip = tolua.cast(Image_EquipPos:getChildByName("Image_Equip"), "ImageView")

            local nEquipID = tbEquipIdList[i]
            local tbEquip = g_Hero:getEquipObjByServID(nEquipID)
            if tbEquip then
				local tbEquipBase = tbEquip:getCsvBase()
						 
                Image_Equip:setVisible(true)
				local box = getFrameBackGround(tbEquipBase.ColorType)
				Image_Equip:loadTexture(box)
       
                local Image_Icon = tolua.cast(Image_Equip:getChildByName("Image_Icon"), "ImageView")
                Image_Icon:loadTexture(getIconImg(tbEquipBase.Icon) )
				equipSacleAndRotate(Image_Icon,tbEquipBase.SubType)
			   
				local box = getIconFrame(tbEquipBase.ColorType)
				local Image_Frame = tolua.cast(Image_Equip:getChildByName("Image_Frame"), "ImageView")
                Image_Frame:loadTexture(box)				
            else
                Image_Equip:setVisible(false)
            end
        end
    end

    local function setUnSummonCard(Button_CardItemUnSummon, CSV_CardHunPo, nIndex)
        if CSV_CardHunPo then
			g_SetBtnWithGuideCheck(Button_CardItemUnSummon, nIndex, onClickCard, true)
            local nStarLevel = CSV_CardHunPo.CardStarLevel
			
            local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, nStarLevel)
             --设置伙伴
            local Image_CardBase = tolua.cast(Button_CardItemUnSummon:getChildByName("Image_CardBase"), "ImageView")   
            Image_CardBase:loadTexture(getCardBackByEvoluteLev(1) )
			local function showUnSummonCardInfo(pSender, eventType)
				if eventType == ccs.TouchEventType.ended then
					-- echoj("CSV_CardHunPo.ID,",CSV_CardHunPo.ID)
					--查看未召唤的卡牌信息
					g_WndMgr:openWnd("Game_CardHandBook", CSV_CardHunPo.ID)
				end
			end
			Image_CardBase:setTouchEnabled(true)
			Image_CardBase:addTouchEventListener(showUnSummonCardInfo)
			
            local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
            Image_Frame:loadTexture(getCardFrameByEvoluteLev(1) )
			local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
            Image_StarLevel:loadTexture(getIconStarLev(nStarLevel) )
            local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
            Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation) )

            local Label_Name = tolua.cast(Button_CardItemUnSummon:getChildByName("Label_Name"), "Label")
            Label_Name:setText(CSV_CardBase.Name)
            g_SetCardNameColorByEvoluteLev(Label_Name, 1)
			
			if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
				Label_Name:setFontSize(18)
			end
			
			local nHaveHunPoNum = 0
			local GameObj_HunPo = g_Hero:getHunPoObj(CSV_CardHunPo.ID)
			if GameObj_HunPo then
				nHaveHunPoNum = GameObj_HunPo:getNum()
			end
			local nHaveMaterialNum = g_Hero:getItemNumByCsv(CSV_CardHunPo.ReplaceMaterialID, CSV_CardHunPo.ReplaceMaterialLevel)
			local nReplaceMaxNum = math.min(nHaveMaterialNum, CSV_CardHunPo.ReplaceMaterialMaxNum)
			local nCostHunPoNum = math.min(nHaveHunPoNum, CSV_CardHunPo.NeedNum - nReplaceMaxNum)
			
			local Label_CollectStatusFalse = tolua.cast(Button_CardItemUnSummon:getChildByName("Label_CollectStatusFalse"),"Label")
			local Label_CollectStatusTrue = tolua.cast(Button_CardItemUnSummon:getChildByName("Label_CollectStatusTrue"),"Label")
			
			local Image_HunPo = Button_CardItemUnSummon:getChildByName("Image_HunPo")
			local ProgressBar_HunPo = tolua.cast(Image_HunPo:getChildByName("ProgressBar_HunPo"), "LoadingBar")
			local Label_HunPo = tolua.cast(Image_HunPo:getChildByName("Label_HunPo"), "Label")
			
			if (nCostHunPoNum + nReplaceMaxNum) >= CSV_CardHunPo.NeedNum then
				local Label_NeedHunShi = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunShi"),"Label")
				local Label_NeedHunShiLB = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunShiLB"),"Label")
				local Label_NeedHunPoLB1 = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunPoLB1"),"Label")
				local Label_NeedHunPo = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunPo"),"Label")
				local Label_NeedHunPoLB2 = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunPoLB2"),"Label")
				
				if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
					local size = 16
					Label_CollectStatusTrue:setFontSize(size)
					Label_NeedHunShi:setFontSize(size)
					Label_NeedHunShiLB:setFontSize(size)
					Label_NeedHunPoLB1:setFontSize(size)
					Label_NeedHunPo:setFontSize(size)
					Label_NeedHunPoLB2:setFontSize(size)
				end
				
				Label_CollectStatusTrue:setVisible(true)
				Label_CollectStatusFalse:setVisible(false)
				Label_NeedHunShi:setText(nReplaceMaxNum)
				Label_NeedHunPo:setText(nCostHunPoNum)
				
				local nWidth1 = Label_CollectStatusTrue:getSize().width
				local nWidth2 = Label_NeedHunShi:getSize().width
				local nWidth3 = Label_NeedHunShiLB:getSize().width
				local nWidth4 = Label_NeedHunPoLB1:getSize().width
				local nWidth5 = Label_NeedHunPo:getSize().width
				local nWidth6 = Label_NeedHunPoLB2:getSize().width
				Label_NeedHunShi:setPositionX(nWidth1)
				Label_NeedHunShiLB:setPositionX(nWidth1+nWidth2)
				Label_NeedHunPoLB1:setPositionX(nWidth1+nWidth2+nWidth3)
				Label_NeedHunPo:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4)
				Label_NeedHunPoLB2:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5)
				
				Label_HunPo:setText(string.format("%d/%d", nReplaceMaxNum + nCostHunPoNum, CSV_CardHunPo.NeedNum))
				ProgressBar_HunPo:setPercent(100)
			else
				local Label_NeedHunShi = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunShi"),"Label")
				local Label_NeedHunShiLB = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunShiLB"),"Label")
				local Label_NeedHunPoLB1 = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunPoLB1"),"Label")
				local Label_NeedHunPo = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunPo"),"Label")
				local Label_NeedHunPoLB2 = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunPoLB2"),"Label")
				
				if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
					local size = 16
					Label_CollectStatusFalse:setFontSize(size)
					Label_NeedHunShi:setFontSize(size)
					Label_NeedHunShiLB:setFontSize(size)
					Label_NeedHunPoLB1:setFontSize(size)
					Label_NeedHunPo:setFontSize(size)
					Label_NeedHunPoLB2:setFontSize(size)
				end
				
				Label_CollectStatusTrue:setVisible(false)
				Label_CollectStatusFalse:setVisible(true)
				Label_NeedHunShi:setText(nReplaceMaxNum)
				Label_NeedHunPo:setText(CSV_CardHunPo.NeedNum - nCostHunPoNum - nReplaceMaxNum)
				
				local nWidth1 = Label_CollectStatusFalse:getSize().width
				local nWidth2 = Label_NeedHunShi:getSize().width
				local nWidth3 = Label_NeedHunShiLB:getSize().width
				local nWidth4 = Label_NeedHunPoLB1:getSize().width
				local nWidth5 = Label_NeedHunPo:getSize().width
				local nWidth6 = Label_NeedHunPoLB2:getSize().width
				Label_NeedHunShi:setPositionX(nWidth1)
				Label_NeedHunShiLB:setPositionX(nWidth1+nWidth2)
				Label_NeedHunPoLB1:setPositionX(nWidth1+nWidth2+nWidth3)
				Label_NeedHunPo:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4)
				Label_NeedHunPoLB2:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5)
				
				Label_HunPo:setText(string.format("%d/%d", nReplaceMaxNum + nCostHunPoNum, CSV_CardHunPo.NeedNum))
				ProgressBar_HunPo:setPercent((nReplaceMaxNum + nCostHunPoNum)*100/CSV_CardHunPo.NeedNum)
			end
            local AtlasLabel_Profession = tolua.cast(Button_CardItemUnSummon:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
            AtlasLabel_Profession:setValue(CSV_CardBase.Profession) 
			g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession},10)
        end
		
    end

    local function updateFunction(Panel_CardItem, nIndex)
		Panel_CardItem:setName("Panel_CardItem"..nIndex)
		Panel_CardItem:setTag(nIndex)
		local Panel_CardTitle = Panel_CardItem:getChildByName("Panel_CardTitle")
		if Panel_CardTitle then
		  Panel_CardItem:removeChild(Panel_CardTitle)
		end

		local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
		local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
		local nHasSummonCount = nHasSummonBattleCount + nHasSummonUnBattleCount
		local nBegin = nIndex*2 -1
		if nBegin <= nHasSummonCount then
		   local Button_CardItemHasSummon1 = Panel_CardItem:getChildByName("Button_CardItemHasSummon1")
		   if not Button_CardItemHasSummon1 then
			  Panel_CardItem:removeAllChildrenWithCleanup(true)
			  Button_CardItemHasSummon1 = g_WidgetModel.Button_CardItemHasSummon:clone()
			  Button_CardItemHasSummon1:setName("Button_CardItemHasSummon1")
			  Panel_CardItem:addChild(Button_CardItemHasSummon1)
		   end
			
		   if nBegin <= nHasSummonBattleCount then
			  setSummonCard(Button_CardItemHasSummon1, g_Hero:getHasSummonBattleCardByIndex(nBegin), nBegin, true )
		   else
			  setSummonCard(Button_CardItemHasSummon1, g_Hero:getHasSummonUnBattleCardByIndex(nBegin - nHasSummonBattleCount), nBegin )
		   end

		   Button_CardItemHasSummon1:setPositionXY(275,80)
		   if nBegin + 1 <= nHasSummonCount then 
			   local Button_CardItemHasSummon2 = Panel_CardItem:getChildByName("Button_CardItemHasSummon2")
			   if not Button_CardItemHasSummon2 then
				  Button_CardItemHasSummon2 = g_WidgetModel.Button_CardItemHasSummon:clone()
				  Button_CardItemHasSummon2:setName("Button_CardItemHasSummon2")
				  Panel_CardItem:addChild(Button_CardItemHasSummon2)
			   end

			   if nBegin + 1 <= nHasSummonBattleCount then
				  setSummonCard(Button_CardItemHasSummon2, g_Hero:getHasSummonBattleCardByIndex(nBegin + 1), nBegin + 1, true )
			   else
				  setSummonCard(Button_CardItemHasSummon2, g_Hero:getHasSummonUnBattleCardByIndex(nBegin + 1-nHasSummonBattleCount), nBegin + 1 )
			   end     
			   Button_CardItemHasSummon2:setPositionXY(835,80)
		   else
				local Button_CardItemHasSummon2 = Panel_CardItem:getChildByName("Button_CardItemHasSummon2")
				if Button_CardItemHasSummon2 then
					Button_CardItemHasSummon2:removeFromParentAndCleanup(true)
				end
		   end
		else
			local nLineIndex = math.floor((nHasSummonCount+1)/2)
			local nCurIndex = nIndex - nLineIndex 
			local nUnSummonBegin = nCurIndex*2 -1
			local nUnSummonCount =  g_Hero:getUnSummonCardListCount()
			local Button_CardItemUnSummon1 = Panel_CardItem:getChildByName("Button_CardItemUnSummon1")
			if not Button_CardItemUnSummon1 then
			   Panel_CardItem:removeAllChildrenWithCleanup(true)
			   Button_CardItemUnSummon1 = g_WidgetModel.Button_CardItemUnSummon:clone()
			   Button_CardItemUnSummon1:setName("Button_CardItemUnSummon1")
			   Panel_CardItem:addChild(Button_CardItemUnSummon1)
			end  
			setUnSummonCard(Button_CardItemUnSummon1, g_Hero:getUnSummonCardByIndex(nUnSummonBegin), nBegin)                  
			Button_CardItemUnSummon1:setPositionXY(275,20)
			nUnSummonBegin = nUnSummonBegin + 1
			if nUnSummonBegin <= nUnSummonCount then 
			   local Button_CardItemUnSummon2 = Panel_CardItem:getChildByName("Button_CardItemUnSummon2")
			   if not Button_CardItemUnSummon2 then
				  Button_CardItemUnSummon2 = g_WidgetModel.Button_CardItemUnSummon:clone()
				  Button_CardItemUnSummon2:setName("Button_CardItemUnSummon2")
				  Panel_CardItem:addChild(Button_CardItemUnSummon2)
			   end
			   setUnSummonCard(Button_CardItemUnSummon2, g_Hero:getUnSummonCardByIndex(nUnSummonBegin), nBegin + 1)          
			   Button_CardItemUnSummon2:setPositionXY(835,20)
			else
				local Button_CardItemUnSummon2 = Panel_CardItem:getChildByName("Button_CardItemUnSummon2")
				if Button_CardItemUnSummon2 then
					Button_CardItemUnSummon2:removeFromParentAndCleanup(true)
				end
			end

			if nLineIndex + 1 == nIndex then
			   local Panel_CardTitle = g_WidgetModel.Panel_CardTitle:clone()
			   Panel_CardTitle:setPositionXY(0,100)
			   Panel_CardItem:addChild(Panel_CardTitle)
			   --Panel_CardItem:setTag(INT_MAX)
			   Panel_CardTitle:setName("Panel_CardTitle")
			end
		end
    end
	
	local function onAdjust_LuaListView_Card(Panel_CardItem, nIndex)
		self.nCurrentListViewIndex = nIndex
	end
    local Panel_CardItem = Layout:create()
    Panel_CardItem:setSize(CCSizeMake(1110, 160))
    self.LuaListView_Card:setModel(Panel_CardItem)
    self.LuaListView_Card:setUpdateFunc(updateFunction)
	self.LuaListView_Card:setAdjustFunc(onAdjust_LuaListView_Card)
end

function Game_Card:openWnd(bIsShowSummon)
	if return_from_Game_ConfirmHunPo ~= nil and return_from_Game_ConfirmHunPo == true then
		return_from_Game_ConfirmHunPo = nil
		return
	end

    if g_bReturn then
		local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
        local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
        local nUnSummonCount = g_Hero:getUnSummonCardListCount()
        local nHasSummonCount = math.floor((nHasSummonBattleCount+nHasSummonUnBattleCount+1)/2)
        local nTotalCount = nHasSummonCount + math.floor((nUnSummonCount+1)/2)
		self.LuaListView_Card:updateItems(nTotalCount, self.nCurrentListViewIndex)
		return
	end
	
	local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
	local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
	local nUnSummonCount = g_Hero:getUnSummonCardListCount()
	local nHasSummonCount = math.floor((nHasSummonBattleCount+nHasSummonUnBattleCount+1)/2)
	local nTotalCount = nHasSummonCount + math.floor((nUnSummonCount+1)/2)
	
	if (g_PlayerGuide:checkIsInGuide() and g_PlayerGuide:checkIsInGuide() == 7) or bIsShowSummon then
		self.nCurrentListViewIndex = nHasSummonCount + 1
		self.LuaListView_Card:updateItems(nTotalCount, self.nCurrentListViewIndex or 1)
	else
		self.nCurrentListViewIndex = 1
		self.LuaListView_Card:updateItems(nTotalCount, self.nCurrentListViewIndex or 1)
	end
end

function Game_Card:closeWnd()
    self.LuaListView_Card:updateItems(0)
end

function Game_Card:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_CardPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_CardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_CardPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_Card:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_CardPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_CardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(ImageView_CardPNL, actionEndCall, 1.05, 0.15, Image_Background)
end

function Game_Card:updateExChangeHunPo()
	--关闭召唤动画的时候已经有刷新了，没必要再刷一遍导致动画卡
    -- if g_WndMgr:isVisible("Game_Card") then   
        -- local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
        -- local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
        -- local nUnSummonCount = g_Hero:getUnSummonCardListCount()
        -- local nHasSummonCount = math.floor((nHasSummonBattleCount+nHasSummonUnBattleCount+1)/2)
        -- local nTotalCount = nHasSummonCount + math.floor((nUnSummonCount+1)/2)
	    -- self.LuaListView_Card:updateItems(nTotalCount, self.nCurrentListViewIndex or 1)
    -- end
end