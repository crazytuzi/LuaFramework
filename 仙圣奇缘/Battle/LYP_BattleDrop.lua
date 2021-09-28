--------------------------------------------------------------------------------------
-- 文件名:	Game_BattleDrop.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2015-1-7 19:37
-- 版  本:	1.0
-- 描  述:	战斗掉落界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_BattleDrop = class("Game_BattleDrop")
Game_BattleDrop.__index = Game_BattleDrop

function Game_BattleDrop:initWnd(widget)
	local Image_BattleDropPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleDropPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_BattleDropPNL:getChildByName("Image_ContentPNL"), "ImageView")
    local ListView_DropItemList = tolua.cast(Image_ContentPNL:getChildByName("ListView_DropItemList"), "ListViewEx")
    local Panel_DropItem = ListView_DropItemList:getChildByName("Panel_DropItem") 

    local LuaListView_DropItemList = Class_LuaListView:new()
    LuaListView_DropItemList:setModel(Panel_DropItem)
    LuaListView_DropItemList:setListView(ListView_DropItemList)	
    self.LuaListView_DropItemList = LuaListView_DropItemList
    self:registerEvent()
	
	local imgScrollSlider = LuaListView_DropItemList:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_DropItemList_X then
		g_tbScrollSliderXY.LuaListView_DropItemList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_DropItemList_X)
end 

local function onClick_DropItemModel(pSender, nTag)
	local CSV_DropItem = TbBattleReport.tbDropInfo[nTag]
	if CSV_DropItem == nil then
		return
	end
	g_ShowDropItemTip(CSV_DropItem)
end

function Game_BattleDrop:registerEvent()
    local function onUpdateListView(Panel_DropItem, index)
		local CSV_DropItem = TbBattleReport.tbDropInfo[index]
		local itemModel, tbCsvBase = g_CloneDropItemModel(CSV_DropItem)
		
		local Button_DropItem = tolua.cast(Panel_DropItem:getChildByName("Button_DropItem"),"Button")
		if tbCsvBase then
            local Label_Name = tolua.cast(Button_DropItem:getChildByName("Label_Name"),"Label")
            Label_Name:setText(tbCsvBase.Name)

            local Label_Desc = tolua.cast(Button_DropItem:getChildByName("Label_Desc"),"Label")
			local desc = tbCsvBase.Desc or ""
            Label_Desc:setText(desc)
        end
		if itemModel then
			Button_DropItem:addChild(itemModel)
			itemModel:setPosition(ccp(-397,2))
			g_SetBtnWithEvent(itemModel, index, onClick_DropItemModel, true)
		end
    end

    self.LuaListView_DropItemList:setUpdateFunc(onUpdateListView)
end

function Game_BattleDrop:closeWnd()
	if TbBattleReport then
		TbBattleReport.openDrop = nil
	end
    self.LuaListView_DropItemList:updateItems(0)
end

function Game_BattleDrop:openWnd()
	if g_bReturn then return end
	if not TbBattleReport then return end
	
	TbBattleReport.openDrop = true
	if TbBattleReport.tbDropInfo then
	   self.LuaListView_DropItemList:updateItems(#TbBattleReport.tbDropInfo)
	else
	   self.LuaListView_DropItemList:updateItems(0)
	end
end

function Game_BattleDrop:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_BattleDropPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleDropPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_BattleDropPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BattleDrop:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_BattleDropPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleDropPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_BattleDropPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end