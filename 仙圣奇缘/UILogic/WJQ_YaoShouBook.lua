--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_YaoShouBook = class("Game_YaoShouBook")
Game_YaoShouBook.__index = Game_YaoShouBook

local nBeginCardFateCsvId = 1
local nEndCardFateCsvId = 49
local nShowCardFateCount = 0

local function sortFateBookList(CsvCardFateA, CsvCardFateB)
	local nColorTypeA = CsvCardFateA.ColorType
	local nColorTypeB = CsvCardFateB.ColorType
	if nColorTypeA == nColorTypeB then
		local nCsvIdA = CsvCardFateA.ID
		local nCsvIdB = CsvCardFateB.ID
		return nCsvIdA < nCsvIdB
	else
		return nColorTypeA > nColorTypeB
	end
end

function Game_YaoShouBook:initWnd()
end

function Game_YaoShouBook:closeWnd()
	self.tbFateBookList = nil
end

function Game_YaoShouBook:openWnd(tbData)
	if not self.rootWidget then return end
	if g_bReturn then return end
	
	local CSV_CardFate = g_DataMgr:getCsvConfig("CardFate")
	self.tbFateBookList = {}
	for k1, v1 in pairs (CSV_CardFate) do
		if k1 >= nBeginCardFateCsvId and k1 <= nEndCardFateCsvId then
			table.insert(self.tbFateBookList, v1)
			nShowCardFateCount = nShowCardFateCount + 1
		end
    end
	table.sort(self.tbFateBookList, sortFateBookList)
	
	local function update_ListView_Book(Image_YaoShouBookPNL, nIndex)
		local wndInstance = g_WndMgr:getWnd("Game_YaoShouBook")
		if wndInstance then
			if wndInstance.tbFateBookList ~= nil and wndInstance.tbFateBookList ~= {} then
				local CSV_CardFate = wndInstance.tbFateBookList[nIndex]
				
				local Label_FateName = tolua.cast(Image_YaoShouBookPNL:getChildByName("Label_FateName"), "Label")
				Label_FateName:setText(CSV_CardFate.Name)
				g_SetWidgetColorBySLev(Label_FateName, CSV_CardFate.ColorType)
				
				local Label_FateProp = tolua.cast(Image_YaoShouBookPNL:getChildByName("Label_FateProp"), "Label")
				Label_FateProp:setText(string.format("%s +%d", g_tbFatePropName[CSV_CardFate.Type], CSV_CardFate[1].PropValue))
				
				g_AdjustWidgetsPosition({Label_FateName, Label_FateProp}, 40)
				
				local Label_FateDesc = tolua.cast(Image_YaoShouBookPNL:getChildByName("Label_FateDesc"), "Label")
				Label_FateDesc:setText(CSV_CardFate.Desc)
				
				local Image_Fate = tolua.cast(Image_YaoShouBookPNL:getChildByName("Image_Fate"), "ImageView")
				Image_Fate:removeAllChildren()
				
				local CSV_DropItem = {
					DropItemType = macro_pb.ITEM_TYPE_FATE,
					DropItemID = CSV_CardFate.ID,
					DropItemStarLevel = CSV_CardFate.ColorType,
					DropItemNum = 0,
					DropItemEvoluteLevel = 1,
				}
				local itemModel = g_CloneDropItemModel(CSV_DropItem)
				itemModel:setPositionXY(0, 0)
				Image_Fate:addChild(itemModel)
			end
		end
	end
	
	local Image_YaoShouBookPNL = tolua.cast(self.rootWidget:getChildByName("Image_YaoShouBookPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_YaoShouBookPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local ListView_Book = tolua.cast(Image_ContentPNL:getChildByName("ListView_Book"),"ListViewEx")
	local Image_BookItemPNL = tolua.cast(ListView_Book:getChildByName("Image_BookItemPNL"),"ImageView")
	local LuaListView_Book = Class_LuaListView:new()
	LuaListView_Book:setModel(Image_BookItemPNL)
	LuaListView_Book:setListView(ListView_Book)
	LuaListView_Book:setUpdateFunc(update_ListView_Book)
	LuaListView_Book:updateItems(nShowCardFateCount)
end

function Game_YaoShouBook:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_YaoShouBookPNL = tolua.cast(self.rootWidget:getChildByName("Image_YaoShouBookPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_YaoShouBookPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_YaoShouBook:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_YaoShouBookPNL = tolua.cast(self.rootWidget:getChildByName("Image_YaoShouBookPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_YaoShouBookPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end