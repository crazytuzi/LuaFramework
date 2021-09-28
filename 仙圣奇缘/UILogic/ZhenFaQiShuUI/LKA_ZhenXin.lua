
--------------------------------------------------------------------------------------
-- 文件名:	LKA_ZhenXin.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-1-22 9:37
-- 版  本:	1.0
-- 描  述:	系统界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_ZhenXin = class("Game_ZhenXin")
Game_ZhenXin.__index = Game_ZhenXin
--服务器位置
local ZhenXinIconPos = {
	[1] = {x = -33, y = 33},
	[2] = {x = 0,y = 33},
	[3] = {x = 33,y = 33},
	[4] = {x = -33,y = 0},
	[5] = {x = 0,y = 0},
	[6] = {x = 33,y = 0},
	[7] = {x = -33,y = -33},
	[8] = {x = 0,y = -33},
	[9] = {x = 33,y = -33},
}

local tbClientPos = {}

function Game_ZhenXin:updateZhenXinGuideAnimation()
	for nIndex = 1, 5 do
		local Panel_ZhenXinItem = self.ListView_ZhenXinList:getChildByIndex(nIndex-1)
		if Panel_ZhenXinItem then
			local Button_ZhenXinItem = tolua.cast(Panel_ZhenXinItem:getChildByName("Button_ZhenXinItem"), "Button")
			local Button_ZhenFaIcon = tolua.cast(Button_ZhenXinItem:getChildByName("Button_ZhenFaIcon"), "Button")
			g_addUpgradeGuide(Button_ZhenFaIcon, ccp(45, 40), nil, g_CheckZhenXinItem(self.nZhanShuCsvID, nIndex))
		end
	end
end

function Game_ZhenXin:initCheckBox_ZhenXin()
	local tbBattleList = g_Hero:getBattleCardList()
	tbClientPos = {}
	for i = 1, 6 do
		local tbBattleCard = tbBattleList[i]
		if tbBattleCard then
			local nServerID = tbBattleCard.nServerID
			local nPosIdx = tbBattleCard.nPosIdx
			if nPosIdx < 6 then
				local tbCard = g_Hero:getCardObjByServID(nServerID)
				if tbCard then
					local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(g_Hero:getCurrentZhenFaCsvID(), nPosIdx)
					local nClientPos = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
					tbClientPos[nClientPos] = tbCard
				end
			end
		end 
	end
	
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_ZhenXinContentPNL = tolua.cast(Image_ZhenXinPNL:getChildByName("Image_ZhenXinContentPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ZhenXinContentPNL:getChildByName("Image_ContentPNL"), "ImageView")
	for nPosIndex = 1, 9 do
		local CheckBox_ZhenXin = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_ZhenXin"..nPosIndex), "CheckBox")
		CheckBox_ZhenXin:setOpacity(0)
		CheckBox_ZhenXin:setTouchEnabled(false)
		CheckBox_ZhenXin:removeAllChildren()
		if tbClientPos[nPosIndex] then
			local CSV_CardBase = tbClientPos[nPosIndex]:getCsvBase()
			local Panel_CardPos = g_WidgetModel.Panel_CardPos:clone()
			local Image_Card = tolua.cast(Panel_CardPos:getChildByName("Image_Card"), "ImageView")
			local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1, true)
			Image_Card:setPositionXY(CSV_CardBase.Pos_X, CSV_CardBase.Pos_Y)
			Image_Card:addNode(CCNode_Skeleton)
            g_runSpineAnimation(CCNode_Skeleton, "idle", true)
			Panel_CardPos:setPositionXY(0, 0)
			CheckBox_ZhenXin:addChild(Panel_CardPos)
		end 
	end
end

function Game_ZhenXin:setImage_ZhenXinPropPNL()
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_ZhenXinContentPNL = tolua.cast(Image_ZhenXinPNL:getChildByName("Image_ZhenXinContentPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ZhenXinContentPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Image_ZhenXinPropPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_ZhenXinPropPNL"), "ImageView")
	local Label_ZhenXinNameSource = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Label_ZhenXinNameSource"), "Label")
	local Label_ZhenXinPropSource = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Label_ZhenXinPropSource"), "Label")
	local Label_ZhenXinNameTarget = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Label_ZhenXinNameTarget"), "Label")
	local Label_ZhenXinPropTarget = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Label_ZhenXinPropTarget"), "Label")
	local Button_LevelUp = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Button_LevelUp"), "Button")
	local CSV_ZhenFa = g_DataMgr:getQiShuZhenfaCsv(g_Hero:getCurrentZhenFaCsvID(), self.nCurZhenXinCsvID)
	
	local CSV_ZhanShu = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu",self.nZhanShuCsvID,self.nCurZhenXinCsvID)
	
	local nZhenXinLevel = g_Hero:getZhanShuZhenXinLev(self.nZhanShuCsvID, self.nCurZhenXinCsvID) or 1
	Label_ZhenXinNameSource:setText(CSV_ZhanShu.ZhenXinName.." ".._T("Lv.")..nZhenXinLevel)
	Label_ZhenXinNameTarget:setText(CSV_ZhanShu.ZhenXinName.." ".._T("Lv.")..nZhenXinLevel+1)
	
	Label_ZhenXinPropSource:setText(g_Hero:getZhenXinPropString(self.nZhanShuCsvID, self.nCurZhenXinCsvID))
	Label_ZhenXinPropTarget:setText(g_Hero:getZhenXinPropStringNextLv(self.nZhanShuCsvID, self.nCurZhenXinCsvID))
	
	local nClientPos = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
	local CheckBox_ZhenXin = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_ZhenXin"..nClientPos), "CheckBox")
	
	if self.curCheckBox_ZhenXin then
		self.curCheckBox_ZhenXin:setSelectedState(false)
	end
	self.curCheckBox_ZhenXin = CheckBox_ZhenXin
	self.curCheckBox_ZhenXin:setSelectedState(true)
	local nZhenFaLevel = g_Hero:getZhenFaLevel(self.nZhanShuCsvID)
	
	local function onClickButton(pSender, nTag)
		g_MsgMgr:requestArrayHeartUpgradeRequest(self.nZhanShuCsvID-1, nTag)
	end
	
	local Label_NeedXueShi = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Label_NeedXueShi"), "Label")
	Label_NeedXueShi:setText(_T("需阅历")..g_Hero:getZhanShuZhenXinNeedKnowledge(self.nZhanShuCsvID, self.nCurZhenXinCsvID))
	
	local bBtnStatus = true
	
	--判断消耗条件是否符合
	if not g_Hero:checkZhanShuZhenXinCost(self.nZhanShuCsvID, self.nCurZhenXinCsvID) then
		bBtnStatus = false
		g_setTextColor(Label_NeedXueShi, ccs.COLOR.RED)
	else
		g_setTextColor(Label_NeedXueShi, ccs.COLOR.BRIGHT_GREEN)
	end
	
	--判断等级条件是否符合
	if not g_Hero:checkZhanShuZhenXinLevel(self.nZhanShuCsvID, self.nCurZhenXinCsvID) then
		bBtnStatus = false
	end
	
	g_SetBtnWithGuideCheck(Button_LevelUp, self.nCurZhenXinCsvID - 1, onClickButton, bBtnStatus)
end

function Game_ZhenXin:setZhenFaInfo(Panel_ZhenXinItem, nIndex)
	local Button_ZhenXinItem = tolua.cast(Panel_ZhenXinItem:getChildByName("Button_ZhenXinItem"), "Button")
	local Image_CheckCover = tolua.cast(Button_ZhenXinItem:getChildByName("Image_CheckCover"), "ImageView")
	if self.Image_CheckCover then
		self.Image_CheckCover:setVisible(false)
	end
	self.Image_CheckCover = Image_CheckCover
	self.Image_CheckCover:setVisible(true)
	self:setImage_ZhenXinPropPNL()
end

function Game_ZhenXin:setListViewItem(Panel_ZhenXinItem, nIndex)
	local CSV_ZhenFa =  g_DataMgr:getQiShuZhenfaCsv(g_Hero:getCurrentZhenFaCsvID(), nIndex)
	local nClientPos = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
	local tbCard = tbClientPos[nClientPos]
	
	local CSV_ZhanShu = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu",self.nZhanShuCsvID,nIndex)
	
	local Button_ZhenXinItem = tolua.cast(Panel_ZhenXinItem:getChildByName("Button_ZhenXinItem"), "Button")
	
	local Button_ZhenFaIcon = tolua.cast(Button_ZhenXinItem:getChildByName("Button_ZhenFaIcon"), "Button")
	
	local Image_CardIconBase = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_CardIconBase"), "ImageView")
	local Image_ZhenFaIcon = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_ZhenFaIcon"), "ImageView")
	if nIndex == 1 then
		self.ZhenFaIcon = CSV_ZhanShu.ZhanShuIcon
	end 

	Image_ZhenFaIcon:loadTexture(getIconImg(self.ZhenFaIcon))
	Image_ZhenFaIcon:setVisible(true)
	local Label_ZhenXinName = tolua.cast(Button_ZhenXinItem:getChildByName("Label_ZhenXinName"), "Label")
	local Label_CardName = tolua.cast(Button_ZhenXinItem:getChildByName("Label_CardName"), "Label")

	local nZhenXinLevel = g_Hero:getZhanShuZhenXinLev(self.nZhanShuCsvID, nIndex) or 1

	Label_ZhenXinName:setText(CSV_ZhanShu.ZhenXinName.." ".._T("Lv.")..nZhenXinLevel)
	
	local AtlasLabel_AttackOrder = tolua.cast(Button_ZhenXinItem:getChildByName("AtlasLabel_AttackOrder"), "LabelAtlas")
	AtlasLabel_AttackOrder:setValue(nIndex)
	
	local Label_ZhenXinProp = tolua.cast(Button_ZhenXinItem:getChildByName("Label_ZhenXinProp"), "Label")
	Label_ZhenXinProp:setText(g_Hero:getZhenXinPropString(self.nZhanShuCsvID, nIndex))
	
	local Image_CheckCover = tolua.cast(Button_ZhenXinItem:getChildByName("Image_CheckCover"), "ImageView")
	Image_CheckCover:setVisible(false)
	
	local function onClickZhenXinItem()
		self.ListView_ZhenXinList:scrollToTop(nIndex)
	end
	g_SetBtnWithEvent(Button_ZhenXinItem, nil, onClickZhenXinItem, true)
	
	if not tbCard then
		Image_CardIconBase:setVisible(false)
		local Image_ZhenXinIcon = tolua.cast(Image_ZhenFaIcon:getChildByName("Image_ZhenXinIcon"), "ImageView")
		Image_ZhenXinIcon:setPositionXY(ZhenXinIconPos[CSV_ZhenFa.BuZhenPosIndex].x, ZhenXinIconPos[CSV_ZhenFa.BuZhenPosIndex].y)
		Label_CardName:setText(_T("阵心无伙伴"))
	else  
		Image_CardIconBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
		Image_CardIconBase:setVisible(true)
		Label_CardName:setText(tbCard:getNameWithSuffix(Label_CardName))
		local Image_Icon = tolua.cast(Image_CardIconBase:getChildByName("Image_Icon"), "ImageView")
		local Image_Frame = tolua.cast(Image_CardIconBase:getChildByName("Image_Frame"), "ImageView")
		Image_Icon:loadTexture(getIconImg(tbCard:getPainting()))
		Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
	end
	
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_ZhenXinContentPNL = tolua.cast(Image_ZhenXinPNL:getChildByName("Image_ZhenXinContentPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ZhenXinContentPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local nClientPos = tbServerToClientPosConvert[CSV_ZhenFa.BuZhenPosIndex]
	local CheckBox_ZhenXin = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_ZhenXin"..nClientPos), "CheckBox")
	CheckBox_ZhenXin:setOpacity(255)
	
	local function onClickButton_ZhenFa()
		local tbParam = {}
		tbParam.nZhanShuCsvID = self.nZhanShuCsvID
		tbParam.nIndex = nIndex 
		local nZhenXinLevel = g_Hero:getZhanShuZhenXinLev(self.nZhanShuCsvID, nIndex) or 1
		tbParam.nZhenXinLevel = nZhenXinLevel
		tbParam.ZhenFaIcon = self.ZhenFaIcon
		g_WndMgr:showWnd("Game_TipZhenXin",tbParam)
	end
	
	g_addUpgradeGuide(Button_ZhenFaIcon, ccp(45, 40), nil, g_CheckZhenXinItem(self.nZhanShuCsvID, nIndex))
	
	g_SetBtnWithEvent(Button_ZhenFaIcon, nil, onClickButton_ZhenFa, true)
end

function Game_ZhenXin:initWnd(widget)
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_ZhenXinContentPNL = tolua.cast(Image_ZhenXinPNL:getChildByName("Image_ZhenXinContentPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ZhenXinContentPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local ListView_ZhenXinList = tolua.cast(Image_ContentPNL:getChildByName("ListView_ZhenXinList"), "ListViewEx")
	local Panel_ZhenXinItem = tolua.cast(ListView_ZhenXinList:getChildByName("Panel_ZhenXinItem"), "Layout")
	local function updataListViewItem(Panel_ZhenXinItem, nIndex)
		self:setListViewItem(Panel_ZhenXinItem, nIndex)
	end
	local function onAdjustListView(Panel_ZhenXinItem, nIndex)
		self.nCurZhenXinCsvID = nIndex
		self:setZhenFaInfo(Panel_ZhenXinItem, nIndex)
    end
	self.ListView_ZhenXinList = registerListViewEvent(ListView_ZhenXinList, Panel_ZhenXinItem, updataListViewItem, nil, onAdjustListView)
	
	local imgScrollSlider = ListView_ZhenXinList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_ZhenXinList_X then
		g_tbScrollSliderXY.ListView_ZhenXinList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_ZhenXinList_X + 5)
	
	local Image_ZhenXinPropPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_ZhenXinPropPNL"), "ImageView")
	local Image_SymbolBlueLight1 = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Image_SymbolBlueLight1"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight1:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight2 = tolua.cast(Image_ZhenXinPropPNL:getChildByName("Image_SymbolBlueLight2"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight2:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	local Button_ZhenXinGuide = tolua.cast(Image_ZhenXinPNL:getChildByName("Button_ZhenXinGuide"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_ZhenXinGuide)
	
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_BackgroundInside = tolua.cast(Image_ZhenXinPNL:getChildByName("Image_BackgroundInside"), "ImageView")
	Image_BackgroundInside:loadTexture(getBackgroundJpgImg("Background_ZhenYan"))
end

function Game_ZhenXin:closeWnd()
	self.Image_CheckCover = nil
	self.ListView_ZhenXinList:updateItems(0)
	
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_BackgroundInside = tolua.cast(Image_ZhenXinPNL:getChildByName("Image_BackgroundInside"), "ImageView")
	Image_BackgroundInside:loadTexture(getUIImg("Blank"))
end

function Game_ZhenXin:updateAnima(nZhanShuCsvID, nIndex)
	local Panel_ZhenXinItem = self.ListView_ZhenXinList:getChildByIndex(nIndex-1)
	local Button_ZhenXinItem = tolua.cast(Panel_ZhenXinItem:getChildByName("Button_ZhenXinItem"), "Button")

	local CSV_ZhanShu = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu",nZhanShuCsvID,nIndex)
	local Label_ZhenXinName = tolua.cast(Button_ZhenXinItem:getChildByName("Label_ZhenXinName"), "Label")
	local nZhenXinLevel = g_Hero:getZhanShuZhenXinLev(self.nZhanShuCsvID, nIndex)
	Label_ZhenXinName:setText(CSV_ZhanShu.ZhenXinName.." ".._T("Lv.")..nZhenXinLevel)
	
	local Label_ZhenXinProp = tolua.cast(Button_ZhenXinItem:getChildByName("Label_ZhenXinProp"), "Label")
	Label_ZhenXinProp:setText(g_Hero:getZhenXinPropString(self.nZhanShuCsvID, nIndex))

	local armature,userAnima = g_CreateCoCosAnimationWithCallBacks("QiShuLevelUp", nil, nil, 5)
	local Button_ZhenFaIcon = tolua.cast(Button_ZhenXinItem:getChildByName("Button_ZhenFaIcon"), "Button")
	armature:setPosition(Button_ZhenFaIcon:getWorldPosition())
	self.rootWidget:addNode(armature, 100)
	userAnima:playWithIndex(0)
end

function Game_ZhenXin:updateZhenXinWnd(nZhanShuCsvID,nIndex)
	self:setImage_ZhenXinPropPNL(self.nCurZhenXinCsvID)
	self:updateZhenXinGuideAnimation()
	self:updateAnima(nZhanShuCsvID,nIndex)
end

function Game_ZhenXin:openWnd(nZhanShuCsvID)
	if g_bReturn then return end
	self.nZhanShuCsvID = nZhanShuCsvID or self.nZhanShuCsvID or 1
	self.Image_CheckCover = nil
	self:initCheckBox_ZhenXin()

	self.ListView_ZhenXinList:updateItems(5)
end

function Game_ZhenXin:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ZhenXinPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background, funcInitAniCall)
end

function Game_ZhenXin:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenXinPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ZhenXinPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end