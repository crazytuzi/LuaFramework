--HeroFosterItem.lua

local FunctionLevelConst = require "app.const.FunctionLevelConst"
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"

local HeroFosterItem = class("HeroFosterItem", function (  )
	return CCSItemCellBase:create("ui_layout/HeroStrengthen_ListItem.json")
end)

function HeroFosterItem:ctor( ... )
	self._heroKnightId = -1
	self._isShowDetail = false

	self:registerBtnClickEvent("Button_showDetail", function ( widget )
		self:_onShowKnightDetail( self._heroKnightId, true )

		--self._isShowDetail = true
		self:_updateShowDetail()
	end)
	self:registerBtnClickEvent("Button_hideDetail", function ( widget )
		self:_onShowKnightDetail( self._heroKnightId, false )
		--self._isShowDetail = false
		self:_updateShowDetail()
	end)
	self:registerBtnClickEvent("Button_hero_back", function ( widget )
		local heroDesc = require("app.scenes.hero.HeroDescLayer")
		heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), self._heroKnightId, false)

		--require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, G_Me.bagData.knightsData:getBaseIdByKnightId(self._heroKnightId))
	end)

	--self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	--self:enableLabelStroke("Label_zizhi", Colors.strokeBrown, 1 )
	--self:enableLabelStroke("Label_knight_type", Colors.strokeBrown, 1 )
	--self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
	--local label = self:getLabelByName("Label_level_title")
	--if label then 
	--	label:createStroke(Colors.strokeBrown, 1)
	--end
	--label = self:getLabelByName("Label_jingjie_title")
	--if label then 
	--	label:createStroke(Colors.strokeBrown, 1)
	--end

	self:setTouchEnabled(true)

	self:_updateShowDetail()
end

function HeroFosterItem:_updateShowDetail( ... )
	self:showWidgetByName("Button_showDetail", not self._isShowDetail)
	self:showWidgetByName("Button_hideDetail", self._isShowDetail)
end

function HeroFosterItem:onDetailShow( show )
	self._isShowDetail = show or false
	self:_updateShowDetail()
end

function HeroFosterItem:updateHeroItem( knightId, isCurDetail )
	self._heroKnightId = knightId

	self._isShowDetail = isCurDetail or false
	self:_updateShowDetail()

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if knightInfo == nil then
		return 
	end
	local baseId = knightInfo["base_id"]
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	end

	local teamId = G_Me.formationData:getKnightTeamId(knightId)
	local wearon = self:getImageViewByName("ImageView_wearon")
	if wearon then 
		wearon:setVisible(teamId > 0)
		if teamId == 2 then 
			wearon:loadTexture("ui/text/txt/shuiyin_yuanjun.png")
		else
			wearon:loadTexture("ui/text/txt/yishangzhen_zuo.png")
		end
	end
	
	if knightBaseInfo ~= nil then
		resId = knightBaseInfo["res_id"]
	else
		__LogError("knightinfo is nil for baseId:%d", baseId)
	end

	if knightId == G_Me.formationData:getMainKnightId() then 
		resId = G_Me.dressData:getDressedPic()
	end
	local icon = self:getImageViewByName("ImageView_hero_head")
	if icon ~= nil then
		--icon:removeChildByTag(1000, true)
		local heroPath = G_Path.getKnightIcon(resId)
		--local heroSprite = CCSprite:create(heroPath)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
	end

	local pingji = self:getImageViewByName("ImageView_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo.quality))  
    end

    local clr = Colors.qualityColors[knightBaseInfo.quality]
	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(clr)
		local jieshu = knightBaseInfo and knightBaseInfo.advanced_level or 0
		name:setText((knightBaseInfo ~= nil and knightBaseInfo.name or "Default Name")..(jieshu > 0 and (" +"..jieshu) or ""))
	end

	-- name = self:getLabelByName("Label_zizhi")
	-- if name ~= nil then
	-- 	--name:setColor(clr)
	-- 	name:setText(G_lang:get("LANG_ZIZHI_FORMAT", {zizhiValue=knightBaseInfo ~= nil and knightBaseInfo.potential or 1}))
	-- end

	name = self:getLabelByName("Label_knight_type")
	if name then 
		--name:setColor(clr)
		name:setText(G_lang.getKnightTypeStr(knightBaseInfo and knightBaseInfo.character_tips or 1))
	end
	-- local image = self:getImageViewByName("Image_knight_type")
	-- if image then
	-- 	local groupPath, imgType = G_Path.getJobTipsIcon_List(knightBaseInfo and knightBaseInfo.character_tips or 1)
	-- 	if groupPath then
	-- 		image:loadTexture(groupPath, imgType)
	-- 		image:setVisible(true)
	-- 	else
	-- 		image:setVisible(false)
	-- 	end
	-- end

	local haloLevel = knightInfo and knightInfo.halo_level or 1
	--self:showWidgetByName("Label_jingjie", knightInfo and knightInfo.halo_level > 0)
	--self:showWidgetByName("Label_jingjie_title", knightInfo and knightInfo.halo_level > 0)
	self:showTextWithLabel("Label_jingjie", G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = haloLevel}))
	self:showTextWithLabel("Label_level", knightInfo and knightInfo["level"] or 1)
	self:showTextWithLabel("Label_zizhi_value", knightBaseInfo ~= nil and knightBaseInfo.potential or 1)
	--GlobalFunc.loadStars(self, 
	--	{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5", "ImageView_star_6", },
	--	knightBaseInfo and knightBaseInfo.star or 0, 1, G_Path.getListStarIcon())

	local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(self._heroKnightId) or -1
	self:showWidgetByName("Image_star_1", stars >= 0)
    self:showWidgetByName("Image_star_2", stars >= 0)
    self:showWidgetByName("Image_star_3", stars >= 0)
    self:showWidgetByName("Image_star_4", stars >= 0)
    self:showWidgetByName("Image_star_5", stars >= 0)
    self:showWidgetByName("Image_star_6", stars >= 0)
    if stars >= 0 then 
        self:showWidgetByName("Image_star_1_full", stars >= 1)
        self:showWidgetByName("Image_star_2_full", stars >= 2)
        self:showWidgetByName("Image_star_3_full", stars >= 3)
        self:showWidgetByName("Image_star_4_full", stars >= 4)
        self:showWidgetByName("Image_star_5_full", stars >= 5)
        self:showWidgetByName("Image_star_6_full", stars >= 6)
    end
    
    local unlock = stars ~= -1
    self:showWidgetByName("Label_juexing_title", unlock)
    self:showWidgetByName("Label_juexing_value", unlock)
    
    if unlock then
        self:showTextWithLabel("Label_juexing_value", G_lang:get("LANG_KNIGHT_AWAKEN_DESC", {star=math.floor(knightInfo.awaken_level / 10), level=knightInfo.awaken_level % 10}))
    end

    --化神
    local godTitleLabel = self:getLabelByName("Label_God_Title")
    local godImage = self:getImageViewByName("Image_God_Level")
    if knightBaseInfo.god_level == 0 and knightInfo.pulse_level == 0 then
    	godTitleLabel:setVisible(false)
    	godImage:setVisible(false)
    else
    	godTitleLabel:setVisible(true)
    	godImage:setVisible(true)
    	local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._heroKnightId)
    	godTitleLabel:setText(HeroGodCommon.getDisplyLevel4(nowGodLevel, knightBaseInfo.quality))
    	-- godTitleLabel:createStroke(Colors.strokeBrown, 1)
    	godImage:loadTexture(G_Path.getGodQualityShuiYin(knightBaseInfo.quality))
    end
    
end

function HeroFosterItem:_onShowKnightDetail( knightId, show )
	self:selectedCell(knightId, show and 1 or 0)
end



return HeroFosterItem
