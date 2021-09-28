--HeroSprite.lua


local HeroSprite = class ("HeroSprite", function (  )
	return CCSItemCellBase:create("ui_layout/knight_item.json")
end)


function HeroSprite:ctor(  )
	self._knightId = -1

	
end

function HeroSprite:updateHero( index, teamId, openLevel )
	self._knightId = -1
	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(teamId, index > 6 and (index - 6) or index)
    if self._knightId == knightId then
        return 
    end

    self._knightId = knightId
    require("app.cfg.knight_info")
    local knightInfo = knight_info.get(baseId)
    if knightInfo == nil then
    	self:_showIconForWidget(index, true, openLevel)
        return 
    end

    local resId = knightInfo.res_id

    local heroImage = self:getImageViewByName("ImageView_icon")
    if heroImage then
    	heroImage:loadTexture(G_Path.getKnightIcon(resId), UI_TEX_TYPE_LOCAL)
    end

    local pingji = self:getImageViewByName("ImageView_pingji")
    if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo.quality))
    end
    
    self:_showIconForWidget(index, false, openLevel)

end

function HeroSprite:_showIconForWidget( index, show, openLevel )
    if not index or index < 2 or index > 12 then
        return 
    end

    openLevel = openLevel or 1
    if not show then
        self:showWidgetByName("ImageView_lock_icon", false)
        self:showWidgetByName("ImageView_add_icon", false)
        self:showWidgetByName("Label_level", false)
        self:showWidgetByName("ImageView_icon", true)
        self:showWidgetByName("ImageView_pingji", true)
        self:enableWidgetByName("Button_back", false)
        self:showWidgetByName("ImageView_lock_text", false)
        self:setTouchEnabled(true)

        self:_twinkleIcon("ImageView_add_icon", false)
    else
        self:showWidgetByName("ImageView_icon", false)
        self:showWidgetByName("ImageView_pingji", false)
        self:enableWidgetByName("Button_back", false)
        if index <= G_Me.userData:getMaxTeamSlot() then
	        self:showWidgetByName("ImageView_add_icon", true)
        	self:showWidgetByName("ImageView_lock_icon", false)
            self:showWidgetByName("Label_level", false)
        	self:setTouchEnabled(true)
        	self:_twinkleIcon("ImageView_add_icon", true)
        	self:showWidgetByName("ImageView_lock_text", false)
        else
        	self:showWidgetByName("ImageView_add_icon", false)
        	self:showWidgetByName("ImageView_lock_icon", true)

            self:showWidgetByName("Label_level", index == G_Me.userData:getMaxTeamSlot() + 1)
        	self:showWidgetByName("ImageView_lock_text", index == G_Me.userData:getMaxTeamSlot() + 1)
            self:showTextWithLabel("Label_level", ""..openLevel)
        	self:setTouchEnabled(false)
        	self:_twinkleIcon("ImageView_add_icon", false)
        end
    end
end

function HeroSprite:_twinkleIcon( iconName, twink )
	if not iconName then
		return 
	end

	local icon = self:getWidgetByName(iconName)
	if not icon then
		return
	end

	twink = twink or false
	icon:stopAllActions()

	if icon then
		local fadeInAction = CCFadeIn:create(0.5)
		local fadeOutAction = CCFadeOut:create(0.5)
		local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
		seqAction = CCRepeatForever:create(seqAction)
		icon:runAction(seqAction)
	end
end
return HeroSprite