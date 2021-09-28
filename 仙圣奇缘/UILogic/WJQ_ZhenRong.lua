--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_ZhenRong = class("Game_ZhenRong")
Game_ZhenRong.__index = Game_ZhenRong

function Game_ZhenRong:initWnd()
	
end

function Game_ZhenRong:closeWnd()
	
end

local function onClick_DropItemModel(pSender, nTag)
	local wndInstance = g_WndMgr:getWnd("Game_ZhenRong")
	if wndInstance then
		local nZhenRongIndex = math.floor(nTag/10)
		local nCardIndex = nTag - nZhenRongIndex*10
		local CSV_CardZhenRong = g_DataMgr:getCsvConfigByOneKey("CardZhenRong", nZhenRongIndex)
		local nCardID = CSV_CardZhenRong["CardID"..nCardIndex]
		local nEvoluteLevel = CSV_CardZhenRong["EvoluteLevel"..nCardIndex]
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nCardID)
		local CSV_DropItem = {
			DropItemType = macro_pb.ITEM_TYPE_CARD,
			DropItemID = nCardID,
			DropItemStarLevel = CSV_CardHunPo.CardStarLevel,
			DropItemNum = 0,
			DropItemEvoluteLevel = nEvoluteLevel,
		}
		g_ShowDropItemTip(CSV_DropItem)
	end
end

function Game_ZhenRong:openWnd(tbData)
	if not self.rootWidget then return end
	if g_bReturn then return end
	
	local function update_ListView_ZhenRong(Image_ZhenRongPNL, nIndex)
		local CSV_CardZhenRong = g_DataMgr:getCsvConfigByOneKey("CardZhenRong", nIndex)
		local Label_ZhenRongName = tolua.cast(Image_ZhenRongPNL:getChildByName("Label_ZhenRongName"), "Label")
		Label_ZhenRongName:setText(CSV_CardZhenRong.Name)
		g_SetWidgetColorBySLev(Label_ZhenRongName, CSV_CardZhenRong.ColorType)
		
		for nCardIndex = 1, 5 do
			local Image_Card = tolua.cast(Image_ZhenRongPNL:getChildByName("Image_Card"..nCardIndex), "ImageView")
			Image_Card:removeAllChildren()
			local nCardID = CSV_CardZhenRong["CardID"..nCardIndex]
			local nEvoluteLevel = CSV_CardZhenRong["EvoluteLevel"..nCardIndex]
			local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nCardID)
			local CSV_DropItem = {
				DropItemType = macro_pb.ITEM_TYPE_CARD,
				DropItemID = nCardID,
				DropItemStarLevel = CSV_CardHunPo.CardStarLevel,
				DropItemNum = 0,
				DropItemEvoluteLevel = nEvoluteLevel,
			}
			local itemModel = g_CloneDropItemModel(CSV_DropItem)
			itemModel:setPositionXY(0, 0)
			Image_Card:addChild(itemModel)
			g_SetBtnWithEvent(itemModel, nIndex*10+nCardIndex, onClick_DropItemModel, true)
		end
	end
	
	local Image_ZhenRongPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenRongPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ZhenRongPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local ListView_ZhenRong = tolua.cast(Image_ContentPNL:getChildByName("ListView_ZhenRong"),"ListViewEx")
	local Image_ZhenRongItemPNL = tolua.cast(ListView_ZhenRong:getChildByName("Image_ZhenRongItemPNL"),"ImageView")
	local LuaListView_ZhenRong = Class_LuaListView:new()
	LuaListView_ZhenRong:setModel(Image_ZhenRongItemPNL)
	LuaListView_ZhenRong:setListView(ListView_ZhenRong)
	LuaListView_ZhenRong:setUpdateFunc(update_ListView_ZhenRong)
	LuaListView_ZhenRong:updateItems(#g_DataMgr:getCsvConfig("CardZhenRong"))
end

function Game_ZhenRong:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ZhenRongPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenRongPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ZhenRongPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ZhenRong:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ZhenRongPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenRongPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ZhenRongPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end