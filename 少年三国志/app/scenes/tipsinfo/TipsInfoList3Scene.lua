local TipsInfoList3Scene = class("TipsInfoList3Scene",UFCCSBaseScene)

--1=主线副本2=日常副本3=名将副本4=集市5=竞技场6=夺宝7=三国无双8=叛军9=神将商店10=充值11=招募12=武将分解13=装备分解
local funLevelConst = require("app.const.FunctionLevelConst")
local shopLayer = require("app.scenes.shop.ShopLayer")
local GotoScene = 
{
    [1] = {scene = "app.scenes.dungeon.DungeonMainScene",levelConst = 0,param = 0},
    [2] = {scene = "app.scenes.vip.VipMapScene",levelConst = funLevelConst.VIP_SCENE,param = 0},
    [3] = {scene = "app.scenes.storydungeon.StoryDungeonMainScene",levelConst = funLevelConst.STORY_DUNGEON,param = 0},
    [4] = {scene = "app.scenes.shop.ShopScene",levelConst = 0,param = shopLayer.ITEM_CHECKED},
    [5] = {scene = "app.scenes.arena.ArenaScene",levelConst = funLevelConst.ARENA_SCENE,param = 0},
    [6] = {scene = "app.scenes.treasure.TreasureComposeScene",levelConst = funLevelConst.TREASURE_COMPOSE,param = 0},
    [7] = {scene = "app.scenes.wush.WushScene",levelConst = funLevelConst.TOWER_SCENE,param = 0},
    [8] = {scene = "app.scenes.moshen.MoShenScene",levelConst = funLevelConst.MOSHENG_SCENE,param = 0},
    [9] = {scene = "app.scenes.secretshop.SecretShopScene",levelConst = funLevelConst.SECRET_SHOP,param = 0},
    [10] = {scene = "app.scenes.shop.ShopScene",levelConst = 0,param = shopLayer.RECHARGE_SHOW},
    [11] = {scene = "app.scenes.shop.ShopScene",levelConst = 0,param = 0},
    [12] = {scene = "app.scenes.recycle.RecycleScene",levelConst = 0,param = 1},
    [13] = {scene = "app.scenes.recycle.RecycleScene",levelConst = 0,param = 2},
    [14] = {scene = "app.scenes.hero.HeroScene",levelConst = 0,param = 0},        
}
-- @param pos 上一级页面 cell 位置
-- @param cellIndex 上一级页面cell 索引
function TipsInfoList3Scene:ctor(secondId,cellIndex,pos,...)
    self.super.ctor(self,...)
    self._sceondId = secondId
    self._cellIndex = cellIndex
    self._pos = pos
    self._list = require("app.scenes.tipsinfo.TipsInfoData").getListData2And3(secondId)

    self._mainLayer = CCSNormalLayer:create("ui_layout/tipsinfo_list3.json")
    self:addUILayerComponent("TipsInfoMainLayer", self._mainLayer, true)
    
    self._mainLayer:registerBtnClickEvent("Button_Back", function()
        self:onBackKeyEvent()
    end)
    
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedBar, true)
    self:adapterLayerHeight(self._mainLayer, nil, self._speedBar, 0, -56)
    self:registerKeypadEvent(true)
end

function TipsInfoList3Scene:onSceneEnter( ... )
    self:_init()
    self.listview:setSpaceBorder(0, 40)
end

function TipsInfoList3Scene:onBackKeyEvent( ... )
    uf_sceneManager:replaceScene(require("app.scenes.tipsinfo.TipsInfoList2Scene").new(self._cellIndex,self._pos))
    return true
end

function TipsInfoList3Scene:_init()
        local title = self._mainLayer:getLabelByName("Label_Title")
        require("app.cfg.tips_info")
        local data = tips_info.get(self._sceondId)
        if data then
            title:setText(data.comment)
            title:createStroke(Colors.strokeBrown,2)
        end
    	local panel = self._mainLayer:getPanelByName("Panel_List3")
        self._mainLayer:adapterWidgetHeightWithOffset("Panel_List3", 0,140)
	self.listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	-- self.listview._list = dungeon_chapter_info.data
	self.listview:setCreateCellHandler( function(list, index)
		local cell = CCSItemCellBase:create("ui_layout/tipsinfo_list3_item.json")
                 cell:registerBtnClickEvent("Button_GoTo",function (widget)
                     self:_onGotoScene(widget:getTag())
                 end)
		return cell
	end )

	self.listview:setUpdateCellHandler(handler(self, self._updateCell))
        self.listview:initChildWithDataLength(#self._list,0.2)
end


function TipsInfoList3Scene:_onGotoScene(tag)
    if self._list[tag] then
        if GotoScene[self._list[tag].stage_id] ~= 0 then
            local _level = G_moduleUnlock:getModuleUnlockLevel(GotoScene[self._list[tag].stage_id].levelConst)
            if G_Me.userData.level < _level then
                require("app.cfg.function_level_info") 
                local levelinfo = function_level_info.get(GotoScene[self._list[tag].stage_id].levelConst)
                if levelinfo then
                    G_MovingTip:showMovingTip(levelinfo.comment)
                end
                return
            end
        end
        if self._list[tag].stage_id == 12 or self._list[tag].stage_id == 13 or 
             self._list[tag].stage_id == 4 or self._list[tag].stage_id == 10 then
            uf_sceneManager:replaceScene(require(GotoScene[self._list[tag].stage_id].scene).new(nil,nil,GotoScene[self._list[tag].stage_id].param, nil, 
            GlobalFunc.sceneToPack("app.scenes.tipsinfo.TipsInfoList3Scene", {self._sceondId,self._cellIndex,self._pos})))
        else
            uf_sceneManager:replaceScene(require(GotoScene[self._list[tag].stage_id].scene).new(nil, nil, nil, nil, 
            GlobalFunc.sceneToPack("app.scenes.tipsinfo.TipsInfoList3Scene", {self._sceondId,self._cellIndex,self._pos})))
        end
    end
end
function TipsInfoList3Scene:_updateCell(list, index, cell)
    cell:getImageViewByName("Image_ico"):loadTexture(self._list[index+1].icon)
    cell:getLabelByName("Label_Comment"):setText(self._list[index+1].comment)
    local title = cell:getLabelByName("Label_Title")
    title:setText(self._list[index+1].title)
    title:createStroke(Colors.strokeBrown,2)
    cell:setTag(self._list[index+1].id)
    local gotoBtn = cell:getButtonByName("Button_GoTo")
    gotoBtn:setTag(index+1)
    gotoBtn:setVisible(self._list[index+1].stage_id > 0 )
end

return TipsInfoList3Scene
