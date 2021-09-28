--------------------------------------------------------------------------------------
-- 文件名:	WJQ_CardSelect.lua
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
Game_CardSelect = class("Game_CardSelect")
Game_CardSelect.__index = Game_CardSelect

local nBuZhenIndex_ = nil

function Game_CardSelect:initWnd()
	local Image_CardSelectPNL = self.rootWidget:getChildByName("Image_CardSelectPNL")
	local Image_ContentPNL = Image_CardSelectPNL:getChildByName("Image_ContentPNL")
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
	
	local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
	local num = math.floor((nHasSummonUnBattleCount+1)/2)
	self.LuaListView_Card:updateItems(num)
	
end

function Game_CardSelect:registerListViewEvent()
    local function onClickSelectCard(pSender, nTag) 
		
		if nBuZhenIndex_ then   
			g_MsgMgr:requestInviteCard(nTag, nBuZhenIndex_ - 1)
		end
    end

    local function setSummonCard(Button_CardItemHasSummon, tbCard, nIndex)
        Button_CardItemHasSummon:setTouchEnabled(true)
        Button_CardItemHasSummon = tolua.cast(Button_CardItemHasSummon, "Button")

		Button_CardItemHasSummon:loadTextures(getUIImg("ListItem_Card"), getUIImg("ListItem_Card_Press"), getUIImg("ListItem_Card_Disabled"))

        local CSV_CardBase = tbCard:getCsvBase()
		
        local Label_Name = tolua.cast(Button_CardItemHasSummon:getChildByName("Label_Name"), "Label")
        Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))
        
		--是否出战
		local Image_InBattle = tolua.cast(Button_CardItemHasSummon:getChildByName("Image_InBattle"), "ImageView")
        Image_InBattle:setVisible(tbCard:checkIsInBattle())
		
        local Label_RealmName = tolua.cast(Button_CardItemHasSummon:getChildByName("Label_RealmName"), "Label")
        Label_RealmName:setText(tbCard:getRealmNameWithSuffix(Label_RealmName))    

        local AtlasLabel_Profession = tolua.cast(Button_CardItemHasSummon:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
        AtlasLabel_Profession:setValue(CSV_CardBase.Profession)
        g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession},10)

        --设置伙伴
        local Image_CardBase = tolua.cast(Button_CardItemHasSummon:getChildByName("Image_CardBase"), "ImageView")
        Image_CardBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
        local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
        Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
		local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
        Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))

		g_addUpgradeGuide(Image_CardBase, ccp(50, 45), nil, g_CheckCardUpgrade(tbCard))
		
		local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
        Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
		
		local Button_EquipList = Button_CardItemHasSummon:getChildByName("Button_EquipList")

		g_SetBtnWithGuideCheck(Button_CardItemHasSummon, tbCard:getServerId(), onClickSelectCard, true)
		g_SetBtnWithGuideCheck(Image_Icon, tbCard:getServerId(), onClickSelectCard, true)
		g_SetBtnWithGuideCheck(Button_EquipList, tbCard:getServerId(), onClickSelectCard, false)

        local LabelBMFont_Level = tolua.cast(Button_CardItemHasSummon:getChildByName("LabelBMFont_Level"), "LabelBMFont")
        LabelBMFont_Level:setText(string.format(_T("Lv.%d"), tbCard:getLevel())) 
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

    local function updateFunction(Panel_CardItem, nIndex)
		Panel_CardItem:setName("Panel_CardItem"..nIndex)

		local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
		local nBegin = nIndex * 2 - 1
		if nBegin <= nHasSummonUnBattleCount then
			local Button_CardItemHasSummon1 = Panel_CardItem:getChildByName("Button_CardItemHasSummon1")
			if not Button_CardItemHasSummon1 then
				Panel_CardItem:removeAllChildrenWithCleanup(true)
				Button_CardItemHasSummon1 = g_WidgetModel.Button_CardItemHasSummon:clone()
				Button_CardItemHasSummon1:setName("Button_CardItemHasSummon1")
				Panel_CardItem:addChild(Button_CardItemHasSummon1)
			end
			setSummonCard(Button_CardItemHasSummon1, g_Hero:getHasSummonUnBattleCardByIndex(nBegin), nBegin)
			Button_CardItemHasSummon1:setPositionXY(275,80)
			
			if nBegin + 1 <= nHasSummonUnBattleCount then 
				local Button_CardItemHasSummon2 = Panel_CardItem:getChildByName("Button_CardItemHasSummon2")
				if not Button_CardItemHasSummon2 then
					Button_CardItemHasSummon2 = g_WidgetModel.Button_CardItemHasSummon:clone()
					Button_CardItemHasSummon2:setName("Button_CardItemHasSummon2")
					Panel_CardItem:addChild(Button_CardItemHasSummon2)
				end
				setSummonCard(Button_CardItemHasSummon2, g_Hero:getHasSummonUnBattleCardByIndex(nBegin + 1), nBegin + 1 )
				Button_CardItemHasSummon2:setPositionXY(835,80)
			else
				local Button_CardItemHasSummon2 = Panel_CardItem:getChildByName("Button_CardItemHasSummon2")
				if Button_CardItemHasSummon2 then
					Button_CardItemHasSummon2:removeFromParentAndCleanup(true)
				end
			end
		else
			local Button_CardItemHasSummon1 = Panel_CardItem:getChildByName("Button_CardItemHasSummon1")
			if Button_CardItemHasSummon1 then
				Button_CardItemHasSummon1:removeFromParentAndCleanup(true)
			end	
			local Button_CardItemHasSummon2 = Panel_CardItem:getChildByName("Button_CardItemHasSummon2")
			if Button_CardItemHasSummon2 then
				Button_CardItemHasSummon2:removeFromParentAndCleanup(true)
			end
		end
    end

    local Panel_CardItem = Layout:create()
    Panel_CardItem:setSize(CCSizeMake(1110, 160))
    self.LuaListView_Card:setModel(Panel_CardItem)
    self.LuaListView_Card:setUpdateFunc(updateFunction)
end

function Game_CardSelect:openWnd(nBuZhenIndex)
	--在这个界面时打开 打开了元宝充值界面，招财界面 后 返回此界面会被传回空值
	if nBuZhenIndex then 
		nBuZhenIndex_ = nBuZhenIndex
	end
	-- local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
	-- local num = math.floor((nHasSummonUnBattleCount+1)/2)
	-- self.LuaListView_Card:updateItems(num)
	
end

function Game_CardSelect:closeWnd()
    self.LuaListView_Card:updateItems(0)
    -- self.nBuZhenIndex = nil
end

function Game_CardSelect:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_CardSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardSelectPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_CardSelectPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_CardSelect:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_CardSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardSelectPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_CardSelectPNL, actionEndCall, 1.05, 0.15, Image_Background)
end