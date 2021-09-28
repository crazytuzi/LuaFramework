--AcquireInfoLayer.lua


local AcquireInfoLayer = class("AcquireInfoLayer", UFCCSModelLayer)

require("app.cfg.way_type_info")


function AcquireInfoLayer:ctor(...)
	self.super.ctor(self, ...)
    self:showAtCenter(true)

    self._wayIdList = {}	

    self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
end

function AcquireInfoLayer:onLayerEnter( ... )
    self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function AcquireInfoLayer:init( typeId, value, scenePack )
    scenePack = scenePack or GlobalFunc.generateScenePack()
    value = value or 0
    self:enableAudioEffectByName("Button_close", false)
	self:registerBtnClickEvent("Button_close", function ( widget )
		self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	end)

    self:registerBtnClickEvent("Button_Go", function()
        uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
    end)

    local addWayId = function ( wayId )
        if wayId and wayId > 0 then 
            table.insert(self._wayIdList, #self._wayIdList + 1, wayId)
        end
    end

    local wayTypeInfo = way_type_info.get(typeId, value)
    if wayTypeInfo then
        addWayId(wayTypeInfo.way_id1)
        addWayId(wayTypeInfo.way_id2)
        addWayId(wayTypeInfo.way_id3)
        addWayId(wayTypeInfo.way_id4)
        addWayId(wayTypeInfo.way_id5)
        addWayId(wayTypeInfo.way_id6)
        addWayId(wayTypeInfo.way_id7)
        addWayId(wayTypeInfo.way_id8)
        addWayId(wayTypeInfo.way_id9)
        addWayId(wayTypeInfo.way_id10)
        addWayId(wayTypeInfo.way_id11)
        addWayId(wayTypeInfo.way_id12)
        addWayId(wayTypeInfo.way_id13)
        addWayId(wayTypeInfo.way_id14)
        addWayId(wayTypeInfo.way_id15)
    end

    dump(self._wayIdList)

__Log("typdId:%d, value:%d, num_type:%d", typeId, value, wayTypeInfo and wayTypeInfo.num_type or 0)
    self:_initList(scenePack)
    self:_initIconInfo( typeId, value, wayTypeInfo and (wayTypeInfo.num_type == 1) or false )
end

function AcquireInfoLayer:_initList( scenePack )
    if #self._wayIdList < 1 then
        self:getLabelByName("Label_not_open_tip"):setFixedWidth(true)
        self:getLabelByName("Label_not_open_tip"):createStroke(Colors.strokeBrown, 1)
        self:showTextWithLabel("Label_not_open_tip", G_lang:get("LANG_WAY_FUNCTION_NOT_OPEN"))
        self:showWidgetByName("Button_Go", false)
        return self:showWidgetByName("Label_not_open_tip", true)
    else
        self:showWidgetByName("Label_not_open_tip", false)
    end

	local panel = self:getPanelByName("Panel_list")
	if not panel then
		return 
	end

    local flagGetChapterList = false
    local goButtonIsShow = true
	self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    
    self._listview:setCreateCellHandler(function ( list, index)
        return require("app.scenes.common.acquireInfo.AcquireInfoItem").new(list, index, "ui_layout/dropinfo_AcquireItem.json")
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
        cell._scenePack = scenePack
        flagGetChapterList = cell:initWithWayId( self._wayIdList[index + 1] ) or flagGetChapterList
        if cell:isOpen() then
            goButtonIsShow = false
        end
    end)
    self._listview:setSelectCellHandler(function ( list, knightId, param, cell )
    	self:animationToClose()
    end)

    self._listview:reloadWithLength(#self._wayIdList, 0, 0.2)

    if #self._wayIdList <= 2 then
        self._listview:setBouncedEnable(false)
    else
        self._listview:setBouncedEnable(true)
    end

    local goButton = self:getButtonByName("Button_Go")
    if goButton then
        goButton:setVisible(goButtonIsShow and G_SceneObserver:getSceneName() == "HeroScene" )
    end

    if flagGetChapterList then 
        G_HandlersManager.dungeonHandler:sendGetChapterListMsg()
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_RECVCHAPTERLIST, function ( ... )
            self._listview:refreshAllCell()
        end, self)
    end
end

function AcquireInfoLayer:_initIconInfo( typeId, value, showNum )
    typeId = typeId or G_Goods.TYPE_ITEM
    local goods_info = G_Goods.convert(typeId, value)
    if goods_info then
        self:getLabelByName("Label_name"):setColor(Colors.qualityColors[goods_info.quality])
        self:getLabelByName("Label_name"):setText(goods_info.name)
        self:getImageViewByName("Image_icon"):loadTexture(goods_info.icon, UI_TEX_TYPE_LOCAL) 
        
        self:getImageViewByName("Image_pingji"):loadTexture(G_Path.getEquipColorImage(goods_info.quality, typeId))

        local image = self:getImageViewByName("Image_equip_back")
        local showBack = (typeId == G_Goods.TYPE_EQUIPMENT) or
                                        (typeId == G_Goods.TYPE_FRAGMENT) or
                                        (typeId == G_Goods.TYPE_TREASURE) or
                                        (typeId == G_Goods.TYPE_TREASURE_FRAGMENT) or 
                                        (typeId == G_Goods.TYPE_AWAKEN_ITEM) or 
                                        (typeId == G_Goods.TYPE_ITEM) or
                                        (typeId == G_Goods.TYPE_ZHUAN_PAN_SCORE) or
                                        (typeId == G_Goods.TYPE_COUPON) or
                                        (typeId == G_Goods.TYPE_SHENHUN) or
                                        (typeId == G_Goods.TYPE_PET) or
                                        (typeId == G_Goods.TYPE_PET_SCORE) or
                                        (typeId == G_Goods.TYPE_WUHUN)
        if image then 
            image:setVisible(showBack)
            if showBack then 
                image:loadTexture(G_Path.getEquipIconBack(goods_info.quality))
            end
        end
    end   

    if not showNum then
        self:showWidgetByName("Label_have", false)
        self:showWidgetByName("Label_count", false)
        self:showWidgetByName("Label_geshu", false)
    else
        local count = 0
        if typeId == G_Goods.TYPE_ITEM then 
            count = G_Me.bagData:getItemCount(value)
        elseif typeId == G_Goods.TYPE_FRAGMENT then
            count = G_Me.bagData:getFragmentNumById(value)
        elseif typeId == G_Goods.TYPE_GOLD then
            count = G_Me.userData.gold
        elseif typeId == G_Goods.TYPE_MONEY then
            count = G_Me.userData.money
        elseif typeId == G_Goods.TYPE_KNIGHT then
            count = G_Me.bagData:getKnightNumByBaseId(value)
        elseif typeId == G_Goods.TYPE_EQUIPMENT then
            count = G_Me.bagData:getEquipmentNumByBaseId(value)
        elseif typeId == G_Goods.TYPE_TREASURE then
            count = G_Me.bagData:getTreasureNumByBaseId(value)
        elseif typeId == G_Goods.TYPE_TREASURE_FRAGMENT then
            count = G_Me.bagData:getTreasureFragmentNumById(value)
        elseif typeId == G_Goods.TYPE_WUHUN then
            count = G_Me.userData.essence
        elseif typeId == G_Goods.TYPE_CHUANGUAN then 
            count = G_Me.userData.tower_score
        elseif typeId == G_Goods.TYPE_SHENGWANG then 
            count = G_Me.userData.prestige
        elseif typeId == G_Goods.TYPE_MOSHEN then 
            count = G_Me.userData.medal
        elseif typeId == G_Goods.TYPE_CORP_DISTRIBUTION then
            count = G_Me.userData.corp_point
        elseif typeId == G_Goods.TYPE_AWAKEN_ITEM then 
            count = G_Me.bagData:getAwakenItemNumById(value)
        elseif typeId == G_Goods.TYPE_SHENHUN then 
            count = G_Me.userData.god_soul
        elseif typeId == G_Goods.TYPE_PET then
            count = G_Me.bagData:getPetNumByBaseId(value)
        elseif typeId == G_Goods.TYPE_PET_SCORE then 
            count = G_Me.userData.pet_points
        elseif typeId == G_Goods.TYPE_HERO_SOUL_POINT then -- 灵玉
            count = G_Me.userData.hero_soul_point
        elseif typeId == G_Goods.TYPE_HERO_SOUL then
            count = G_Me.heroSoulData:getSoulNum(value)
        end

        __Log("type=%d, value:%d, count=%d", typeId, value, count)
        self:getLabelByName("Label_count"):setText(count)
    end
end

function AcquireInfoLayer.show( typeId, value, scenePack )
	local acquireInfo = AcquireInfoLayer.new( "ui_layout/dropinfo_AcquireLayer.json", Colors.modelColor)
	acquireInfo:init( typeId, value, scenePack )
	uf_sceneManager:getCurScene():addChild(acquireInfo)

	return acquireInfo
end

return AcquireInfoLayer
