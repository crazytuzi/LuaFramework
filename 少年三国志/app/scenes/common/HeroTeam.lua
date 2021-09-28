--HeroTeam.lua

local HeroTeam = class("HeroTeam", UFCCSNormalLayer)


function HeroTeam.create()
    return HeroTeam.new("ui_layout/knight_header.json")
end

function HeroTeam:ctor( ... )
	self._curShowTeam = G_Me.formationData:showTeamId( )
    self._knightArr = {}

    self.super.ctor(self, ...)	
end

function HeroTeam:onLayerLoad( jsonFile, ... )
	if jsonFile then
		self._parent = self
		self:_registerEvents()
    	self:_onFormationUpdate(self._curShowTeam)
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FORMATION_UPDATE, self._onFormationUpdate, self)
	end
end

function HeroTeam:init(_panel)
    self._parent = _panel
    self._parent:addChild(self)
    self:_registerEvents()
    self:_onFormationUpdate(self._curShowTeam)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FORMATION_UPDATE, self._onFormationUpdate, self)
end

function HeroTeam:onLayerUnload( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

function HeroTeam:_registerEvents( ... )
	self._parent:registerBtnClickEvent("Button_buzhen", function ( widget )
        uf_sceneManager:replaceScene(require("app.scenes.hero.HeroScene").new(true))
    end)

    self._parent:registerBtnClickEvent("Button_YuanJun", function ( widget )
        self:doSwitchTeam()
    end)

    self._parent:registerBtnClickEvent("Button_Main", function ( widget )
    	self:_onHeroClick(1, widget)        
    end)

    require("app.cfg.role_info")
    local maxKnight = 1
    local userLevel = G_Me.userData.level    
    local roleInfo = role_info.get(userLevel)
    if roleInfo then
        maxKnight = roleInfo.team_num
    end
    maxKnight = maxKnight - 1
    for loopi = 1, 11, 1 do
        self:enableWidgetByName("Button_Sub_"..loopi, loopi <= maxKnight)
        self._parent:registerBtnClickEvent("Button_Sub_"..loopi, function ( widget )
            self:_onHeroClick(loopi + 1, widget)
        end)
    end

    self._parent:showWidgetByName("Button_turnleft", false)
    self._parent:registerScrollViewEvent("ScrollView_knights", function(widget, scrollType)
        if scrollType == SCROLLVIEW_EVENT_SCROLL_TO_LEFT then
            self._parent:showWidgetByName("Button_turnleft", false)
        elseif scrollType == SCROLLVIEW_EVENT_SCROLL_TO_RIGHT then
            self._parent:showWidgetByName("Button_turnright", false)
        elseif scrollType == SCROLLVIEW_EVENT_SCROLLING then
            self._parent:showWidgetByName("Button_turnleft", not widget:isAtLeftBoundary())
            self._parent:showWidgetByName("Button_turnright", not widget:isAtRightBoundary())
        end
    end)

    self._parent:registerBtnClickEvent("Button_turnleft", function ( widget )
        local scrollview = self:getScrollViewByName("ScrollView_knights")
        if scrollview then
            scrollview:scrollToLeft(0.3, true)
        end
    end)

    self._parent:registerBtnClickEvent("Button_turnright", function ( widget )
        local scrollview = self:getScrollViewByName("ScrollView_knights")
        if scrollview then
            scrollview:scrollToRight(0.3, true)
        end
    end)

    local btn = self._parent:getButtonByName("Button_turnleft")
    if btn then
        btn:setPressedActionEnabled(true)
    end

    btn = self._parent:getButtonByName("Button_turnright")
    if btn then
        btn:setPressedActionEnabled(true)
    end
    
end

function HeroTeam:doSwitchTeam( )
    self._curShowTeam = (self._curShowTeam == 1) and 2 or 1
    G_Me.formationData:showMainTeam(self._curShowTeam == 1)
    self:_onFormationUpdate(self._curShowTeam)
end

function HeroTeam:_onFormationUpdate( teamId )
    local heroWidget = self._parent:getButtonByName("Button_Main")
    self:_loadHeroWithAtIndex( heroWidget, 1, 1)

    local levelArr = G_Me.userData:getTeamSlotOpenLevel()
    for loopi = 1, 11 do 
        local heroWidget = self._parent:getButtonByName("Button_Sub_"..loopi)
        self:_loadHeroWithAtIndex(heroWidget, loopi + 1, loopi < 6 and 1 or 2, levelArr[loopi] or 1)
    end
end

function HeroTeam:_loadHeroWithAtIndex( widget, index, teamId, openLevel )
    if widget == nil then
        return 
    end

    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(teamId, index > 6 and (index - 6) or index)
    local curKnightId = self._knightArr[index]
    if curKnightId == knightId then
        return 
    end

    widget:removeNodeByTag(1000)

    if not knightId or not baseId or knightId == 0 or baseId == 0  then
        self._knightArr[index] = nil
        self:_showIconForWidget(index, true, openLevel)
        return 
    end

    require("app.cfg.knight_info")
    local knightInfo = knight_info.get(baseId)
    if knightInfo == nil then
        return 
    end

    local resId = knightInfo.res_id
    
    heroSprite = CCSprite:create( G_Path.getKnightIcon(resId))
    if heroSprite then
        widget:addNode(heroSprite, 0, 1000)
        local widgetSize = widget:getContentSize()
        local spriteSize = heroSprite:getContentSize()
        heroSprite:setScale(widgetSize.width*0.8/spriteSize.width)
    else
        __LogError("icon is nil for knightIcon:%s", G_Path.getKnightIcon(resId))
    end
    
    self._knightArr[index] = knightId
    self:_showIconForWidget(index, false, openLevel)

    local imgPath = nil
    local mainKnightId = G_Me.formationData:getMainKnightId()
    if knightId == mainKnightId then
        imgPath = G_Path.getMainKnightColorImage(knightInfo.quality)
        widget:loadTextureNormal(imgPath, UI_TEX_TYPE_LOCAL)    
    else
        widget:loadTextureNormal(G_Path.getAddtionKnightColorImage(knightInfo.quality))    
    end

end

function HeroTeam:_showIconForWidget( index, show, openLevel )
    if not index or index < 2 or index > 12 then
        return 
    end

    openLevel = openLevel or 1
    if not show then
        self:showWidgetByName("ImageView_icon_"..(index - 1), false)
        self:showWidgetByName("Label_"..(index - 1), false)
    else
        if index <= G_Me.userData:getMaxTeamSlot() then
            local icon = self._parent:getImageViewByName("ImageView_icon_"..(index - 1))
            if icon then
                icon:loadTexture(G_Path.getAddKnightIcon())
            end
            self:showWidgetByName("Label_"..(index - 1), false)
        else
            self:showTextWithLabel("Label_"..(index - 1), ""..openLevel)
        end
    end
end

function HeroTeam:_onHeroClick( index, widget )
    if widget == nil then
        return 
    end

    local sprite = widget:getNodeByTag(1000)
    if sprite == nil then
        local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")
        heroSelectLayer.showHeroSelectLayer(uf_notifyLayer:getModelNode(), function ( knightId )
            if not G_Me.formationData:isKnightValidjForCurrentTeam(knightId) then
                MessageBoxEx.showOkMessage("提醒", "同一阵容上不能上两个相同的角色哦，亲！")
                return 
            end
            G_HandlersManager.cardHandler:addTeamKnight(knightId)
            end)
    else
	   uf_sceneManager:replaceScene(require("app.scenes.hero.HeroScene").new(false, index))
    end
end

return HeroTeam
