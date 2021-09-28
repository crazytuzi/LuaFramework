
--------------------------------------------------------------------------------------
-- 文件名:	HJW_DuJieSelectHelper.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-05-04
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  渡劫选择协助伙伴（必须选择两位）
---------------------------------------------------------------------------------------

Game_DuJieSelectHelper = class("Game_DuJieSelectHelper")
Game_DuJieSelectHelper.__index = Game_DuJieSelectHelper
--[[
	在此 初始化 是为了保证在数据没有变化的时候 不重新获取数据 和重新排序
]]
local cardId = nil --卡牌ID  
local tbCardIndex = {} --保存要去渡劫的卡牌信息 第一个位置默认为 渡劫主卡牌
local tbNewCardsList = {}	--排好序的卡牌

g_LuaListView_HelperList_Index = 1

local function cardsListSort(cardObj_A,cardObj_B)
	local nServerID_A = cardObj_A.nServerID
	local nServerID_B = cardObj_B.nServerID

	local tbCard_A = g_Hero:getCardObjByServID(nServerID_A)
	local tbCard_B = g_Hero:getCardObjByServID(nServerID_B)
	local strengthA = tbCard_A:getCardStrength()
	local strengthB = tbCard_B:getCardStrength()
	
	local flag_A = cardObj_A.batteCard
	local flag_B = cardObj_B.batteCard
	if flag_A == 1 or flag_B == 1 then
		return flag_A > flag_B
	else
		return strengthA > strengthB
	end

end

function Game_DuJieSelectHelper:initWnd()
	local Image_DuJieSelectHelperPNL = tolua.cast(self.rootWidget:getChildByName("Image_DuJieSelectHelperPNL"), "ImageView")
	local Image_Arrow = tolua.cast(Image_DuJieSelectHelperPNL:getChildByName("Image_Arrow"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Arrow, 0.6)
	
	g_LuaListView_HelperList_Index = 1
end

function Game_DuJieSelectHelper:openWnd(nCardID)

	if not nCardID then return end
	self.selectCardTag_ = {}
	self.nCountCardIndex = 1
	tbCardIndex = {}
	local tb = {}
	tb.nCardID =  nCardID
	table.insert(tbCardIndex,tb)
	local battleList = g_Hero:getBattleCardList()

	local function showSort()
		tbNewCardsList = {}
		local tbBattle = g_Hero:GetCardsList() --拥有的所有卡牌
		for key,value in pairs(tbBattle) do
			if value.nServerID ~= nCardID then 
				value.batteCard = 0
				for i = 1,#battleList do 
					if battleList[i].nServerID == value.nServerID then 
						 value.batteCard = 1
					end
				end
				table.insert(tbNewCardsList,value) 
			end
		end
		table.sort(tbNewCardsList,cardsListSort)
	end
	self.selectCardNum_ = 0 --
	if next(tbNewCardsList) == nil then 
		showSort()
	end
	if cardId ~= nCardID then 
		cardId = nCardID
		showSort()
	else
		local cardCount = 0
		for key,value in pairs(g_Hero:GetCardsList()) do
			if value.nServerID ~= nCardID then 
				cardCount = cardCount + 1
			end
		end
		if cardCount > #tbNewCardsList then
			cardId = nCardID
			showSort()
		end
	end
	self:targetPnlShow()
	
	self:helperListPnl()
	self:combatStart()
end

function Game_DuJieSelectHelper:closeWnd()
	self.selectCardNum_ = nil
	self.selectCardTag_ = nil
end

--卡牌头像信息
function Game_DuJieSelectHelper:headPortrait(widget,tbCard,flag)
	
	if not tbCard then return end
	local CSV_CardBase = tbCard:getCsvBase()
	--头像背景
	local Image_CardBase = tolua.cast(widget:getChildByName("Image_CardBase"), "ImageView")
	Image_CardBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
	
	--头像边框
	local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))

	--头像星级
	local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
	
	--头像
	local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation) )
	
	--卡牌名称 +1
	local Label_Name = tolua.cast(widget:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))	
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Name:setFontSize(20)
	end
	--渡劫名称 1/8
	local Label_RealmName = tolua.cast(widget:getChildByName("Label_RealmName"), "Label") 
	Label_RealmName:setText(tbCard:getRealmNameWithSuffix(Label_RealmName))
	
	--卡牌等级 Lv.1
	local LabelBMFont_Level = tolua.cast(widget:getChildByName("LabelBMFont_Level"), "LabelBMFont") 
	LabelBMFont_Level:setText(_T("Lv.")..tbCard:getLevel())
	-- LabelBMFont_Level:setText(_T("Lv.")..tbCard:getCardStrength())
	
	g_AdjustWidgetsPosition({Label_Name, LabelBMFont_Level},10)
	
	--类型
	local AtlasLabel_Profession = tolua.cast(widget:getChildByName("AtlasLabel_Profession"), "LabelAtlas") 
	AtlasLabel_Profession:setValue(CSV_CardBase.Profession)	
	if flag then 
		g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession, LabelBMFont_Level},10)
	end
end
--进行渡劫的伙伴信息
function Game_DuJieSelectHelper:targetPnlShow()
	local rootWidget = self.rootWidget
	
	local Image_DuJieSelectHelperPNL = tolua.cast(rootWidget:getChildByName("Image_DuJieSelectHelperPNL"), "ImageView")	
	
	local Image_Arrow = tolua.cast(Image_DuJieSelectHelperPNL:getChildByName("Image_Arrow"), "ImageView")
	Image_Arrow:stopAllActions()
	Image_Arrow:setPositionY(185)
	g_CreateUpAndDownAnimation(Image_Arrow)
	
	local Image_DuJieTargetPNL = tolua.cast(Image_DuJieSelectHelperPNL:getChildByName("Image_DuJieTargetPNL"), "ImageView")
	
	local tbCard = g_Hero:getCardObjByServID(cardId)
	self:headPortrait(Image_DuJieTargetPNL,tbCard,true)
	
end

function Game_DuJieSelectHelper:helperListPnl()
	
	local rootWidget = self.rootWidget
	local Image_DuJieSelectHelperPNL = tolua.cast(rootWidget:getChildByName("Image_DuJieSelectHelperPNL"), "ImageView")
	local Image_HelperPNL = tolua.cast(Image_DuJieSelectHelperPNL:getChildByName("Image_HelperPNL"), "ImageView")
	
	local function onButtonCreate(pSender, index)
		local nTag = pSender:getTag()
		local CheckBox_Flag = tolua.cast(pSender:getChildByName("CheckBox_Flag"), "CheckBox")
		if not self.selectCardTag_[nTag] and CheckBox_Flag:getSelectedState() == false then
			if self.selectCardNum_ <= 2 and #tbCardIndex <= 3 then
				CheckBox_Flag:setSelectedState(true)
				--保存 选择了什么卡牌 在listView 中显示选择卡牌勾选
				self.selectCardTag_[nTag] = tbNewCardsList[nTag].nServerID 
				self.selectCardNum_ = self.selectCardNum_ + 1 --计算已经选择了几个卡牌了

				--保存选中的卡牌的信息和卡牌索引
				local tb = {}
				tb.nCardID =  tbNewCardsList[nTag].nServerID
				for key,value in pairs(tbCardIndex) do 
					if value then 
						if value.nCardID == tb.nCardID then 
							tbCardIndex[key] = nil
						end
					end
				end
				table.insert(tbCardIndex,tb)
				
			end
		else
			
			CheckBox_Flag:setSelectedState(false)
			self.selectCardNum_ = self.selectCardNum_ - 1
			for key,value in pairs(tbCardIndex) do 
				if value then 
					if value.nCardID == tbNewCardsList[nTag].nServerID then 
						tbCardIndex[key] = nil
					end
				end
			end
			self.selectCardTag_[nTag] = nil
		end
		self:helperListPnl()
		self:combatStart()

	end
	
	local function updateListViewItem(widget, nIndex)
		widget:setTag(nIndex)
		local Button_HelperItem = tolua.cast(widget:getChildByName("Button_HelperItem"), "Button")
		g_SetBtnWithGuideCheck(Button_HelperItem, nIndex, onButtonCreate, true, nil, nil, nil)
		
		local CheckBox_Flag = tolua.cast(Button_HelperItem:getChildByName("CheckBox_Flag"), "CheckBox")
		if self.selectCardTag_ and self.selectCardTag_[nIndex]  then 
			CheckBox_Flag:setBright(true)
			CheckBox_Flag:setSelectedState(true)
			
			Button_HelperItem:setTouchEnabled(true)
			Button_HelperItem:setBright(true)
			
		else
			if self.selectCardNum_ == 2  then
				CheckBox_Flag:setBright(false)
				CheckBox_Flag:setSelectedState(false)
				
				Button_HelperItem:setTouchEnabled(false)
				Button_HelperItem:setBright(false)
			else
				CheckBox_Flag:setBright(true)
				CheckBox_Flag:setSelectedState(false)
				
				Button_HelperItem:setTouchEnabled(true)
				Button_HelperItem:setBright(true)
			end
		end
		local tbCard = g_Hero:getCardObjByServID(tbNewCardsList[nIndex].nServerID)
		self:headPortrait(Button_HelperItem,tbCard)

	end
	
	local function onAdjustListView(Panel_HelperItem, nIndex)
		g_LuaListView_HelperList_Index = nIndex
    end

	local ListView_HelperList = tolua.cast(Image_HelperPNL:getChildByName("ListView_HelperList"), "ListViewEx")
	local Panel_HelperItem = ListView_HelperList:getChildByName("Panel_HelperItem")
    local LuaListView_HelperList = Class_LuaListView:new()
    LuaListView_HelperList:setModel(Panel_HelperItem)
	LuaListView_HelperList:setAdjustFunc(onAdjustListView)
    LuaListView_HelperList:setUpdateFunc(updateListViewItem)
    LuaListView_HelperList:setListView(ListView_HelperList)
	local nNum = #tbNewCardsList
	
	g_LuaListView_HelperList_Index = g_LuaListView_HelperList_Index or 1
	LuaListView_HelperList:updateItems(nNum, g_LuaListView_HelperList_Index)
	
	local imgScrollSlider = ListView_HelperList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_HelperList_X then
		g_tbScrollSliderXY.ListView_HelperList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_HelperList_X)
end

function Game_DuJieSelectHelper:combatStart()

	local function onButtonCombatStart(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			--打开布阵界面
			for i = 1,#tbCardIndex do
				if tbCardIndex[i] then 
					tbCardIndex[i].nIndex = i 
				end
			end
			g_WndMgr:openWnd("Game_BattleBuZhenDuJie",{queueCard = tbCardIndex})
		end
	end
	local Image_DuJieSelectHelperPNL = tolua.cast(self.rootWidget:getChildByName("Image_DuJieSelectHelperPNL"), "ImageView")
	local Button_Confirm = tolua.cast(Image_DuJieSelectHelperPNL:getChildByName("Button_Confirm"), "Button")

	if self.selectCardNum_ <= 2 then 
		Button_Confirm:setTouchEnabled(true)
		Button_Confirm:setBright(true)
		Button_Confirm:addTouchEventListener(onButtonCombatStart)
	else
		Button_Confirm:setTouchEnabled(false)
		Button_Confirm:setBright(false)
	end
end

function Game_DuJieSelectHelper:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_DuJieSelectHelperPNL = tolua.cast(self.rootWidget:getChildByName("Image_DuJieSelectHelperPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_DuJieSelectHelperPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_DuJieSelectHelper:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_DuJieSelectHelperPNL = tolua.cast(self.rootWidget:getChildByName("Image_DuJieSelectHelperPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_DuJieSelectHelperPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end