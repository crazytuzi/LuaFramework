--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_RewardBox = class("Game_RewardBox")
Game_RewardBox.__index = Game_RewardBox

Game_RewardBox_Status = {
	_CanNotObtain = 0,
	_CanObtain = 1,
	_HasObtain = 2,
}

local function onClick_DropItemModel(pSender, nTag)
	local wndInstance = g_WndMgr:getWnd("Game_RewardBox")
	if wndInstance then
		local tbCsvBase = wndInstance.tbItemDataList[nTag]
		g_ShowDropItemTip(tbCsvBase)
	end
end

function Game_RewardBox:initWnd()
	local Image_RewardBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_RewardBoxPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_RewardBoxPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Panel_RewardItems = tolua.cast(Image_ContentPNL:getChildByName("Panel_RewardItems"),"ImageView")
	
	local ListView_RewardItems = tolua.cast(Panel_RewardItems:getChildByName("ListView_RewardItems"), "ListViewEx")
	self.ListView_RewardItems = ListView_RewardItems
	self.ListView_RewardItems:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)
	self.ListView_RewardItems:setVisible(true)
	local Panel_RewardItem = tolua.cast(self.ListView_RewardItems:getChildByName("Panel_RewardItem"),"Layout")
	local function onUpdateListView_RewardItems(widget, nIndex)
		local tbCsvBase = self.tbItemDataList[nIndex]
		widget:removeAllChildren()	
	    local itemModel = g_CloneDropItemModel(tbCsvBase)	    
        if itemModel then
            itemModel:setPosition(ccp(60,80))
			itemModel:setScale(0.85)
            itemModel:setVisible(true)
		    widget:addChild(itemModel)
			g_SetBtnWithEvent(itemModel, nIndex, onClick_DropItemModel, true)
        end
	end
	registerListViewEvent(self.ListView_RewardItems, Panel_RewardItem, onUpdateListView_RewardItems, 0)
	
	local imgScrollSlider = self.ListView_RewardItems:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_RewardItems_RewardBox_Y then
		g_tbScrollSliderXY.ListView_RewardItems_RewardBox_Y = imgScrollSlider:getPositionY()
	end
	imgScrollSlider = imgScrollSlider:setPositionY(g_tbScrollSliderXY.ListView_RewardItems_RewardBox_Y - 20)
end

function Game_RewardBox:closeWnd()
	if self.funcCallBack then
		self.funcCallBack()
	end
	self.tbItemDataList = nil
	self.ListView_RewardItems:updateItems(0)
end

--接口协议
--[[
local tbItemDataList = { 
	[1]={
		DropItemType,
		DropItemID,
		DropItemStarLevel,
		DropItemNum,
		DropItemEvoluteLevel,
	},
}
]]--
--接口协议
--[[
local tbData = {
	nRewardStatus = 0,1,2	--不可领取、可领取、已领取
	tbParamentList{},
	funcCallBack,
}
]]--
function Game_RewardBox:openWnd(tbData)
	if not tbData then return end

	self.nRewardStatus = tbData.nRewardStatus or 0
	self.tbItemDataList = tbData.tbParamentList
	self.funcCallBack = tbData.updateHeroResourceInfo
	local nTotalItemsCount = GetTableLen(self.tbItemDataList)
	self.ListView_RewardItems:updateItems(nTotalItemsCount)
	
	local Image_RewardBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_RewardBoxPNL"),"ImageView")
	local Button_Confirm = tolua.cast(Image_RewardBoxPNL:getChildByName("Button_Confirm"),"Button")
	local BitmapLabel_FuncName = tolua.cast(Button_Confirm:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")

	local bEnable = false
	if self.nRewardStatus == Game_RewardBox_Status._CanNotObtain then
		bEnable = false
		BitmapLabel_FuncName:setText(_T("未领取"))
	elseif self.nRewardStatus == Game_RewardBox_Status._CanObtain then
		bEnable = true
		BitmapLabel_FuncName:setText(_T("确定"))
	elseif self.nRewardStatus == Game_RewardBox_Status._HasObtain then
		bEnable = false
		BitmapLabel_FuncName:setText(_T("已领取"))
	end
	
	local function onClick_Button_Confirm(pSender, nTag)
		g_WndMgr:closeWnd("Game_RewardBox")
	end
	
	g_SetBtnWithGuideCheck(Button_Confirm, 1, onClick_Button_Confirm, bEnable, nil, nil, nil)
end

function Game_RewardBox:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_RewardBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_RewardBoxPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_RewardBoxPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_RewardBox:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_RewardBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_RewardBoxPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_RewardBoxPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end