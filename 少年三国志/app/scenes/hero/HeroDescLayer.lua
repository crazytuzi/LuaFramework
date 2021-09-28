--HeroDescLayer.lua

local knightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"
require "app.cfg.knight_god_info"
local KnightConst = require("app.const.KnightConst")
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"

local HeroDescLayer = class ("HeroDescLayer", UFCCSModelLayer)

local PET_INFO_LAYER_TAG = 10100

local findIdInTable = function( t, value ) 
		if type(t) ~= "table" or not value then
			return false
		end

		for key, obj in pairs(t) do 
			if obj == value then
				return true
			end
		end

		return false
	end

function HeroDescLayer:ctor( ... )
	self._teamId = 0
	self._posIndex = -1
	self._mainKnightId = 0
	self._baseId = 0
	self._showBorder = false
	self._showBottom = false
	self._heroPageView = nil 
	self._associationPercent = 100
	self._fingerNode = nil
	self._isPlayingVoice = false
	self._lastCommonVoice = false
	self._lastVoiceName = nil

	self.super.ctor(self, ...)

	self:adapterWithScreen()
	self:registerTouchEvent(false, true, 0)

	 self:enableLabelStroke("Label_baseInfo", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_skill_info", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_yuanfen_info", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_tianfu_info", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_juexing_info", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_knight_info", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_zizhi", Colors.strokeBrown, 2 )
	 self:enableLabelStroke("Label_jxInfo", Colors.strokeBrown, 2)
	 self:enableLabelStroke("Label_God_Info", Colors.strokeBrown, 2)

	 self:attachImageTextForBtn("Button_strengthen", "Image_97")
	 self:attachImageTextForBtn("Button_jingjie", "Image_98")
	 self:attachImageTextForBtn("Button_xilian", "Image_99")
	 self:attachImageTextForBtn("Button_guanghuan", "Image_100")
	 self:attachImageTextForBtn("Button_juexing", "Image_101")
	  self:attachImageTextForBtn("Button_God", "Image_102")

	 self:attachImageTextForBtn("Button_change", "ImageView_5221")

	--self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	--self:enableLabelStroke("Label_jingjie_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_hp_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_attack_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_def_wuli_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_def_mofa_value", Colors.strokeBrown, 1 )
	
	-- self:enableLabelStroke("Label_skill_pu", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_skill_ji", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_skill_he", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_1", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_2", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_3", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_4", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_5", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_6", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_7", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_tianfu_8", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jipan_1", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jipan_2", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jipan_3", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jipan_4", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jipan_5", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jipan_6", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_heroName", Colors.strokeBrown, 2 )
	-- self:enableLabelStroke("Label_desc", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_jingjie_value_top", Colors.strokeBrown, 2 )

	local createStoke = function ( name )
		local label = self:getLabelByName(name)
		if label then 
			label:createStroke(Colors.strokeBrown, 1)
		end
	end
	--createStoke("Label_jingjie")
	-- createStoke("Label_hp")
	-- createStoke("Label_attack")
	-- createStoke("Label_def_wuli")
	-- createStoke("Label_def_mofa")
	self:enableAudioEffectByName("Button_close", false)	


end

function HeroDescLayer:onLayerEnter( ... )
	--self:closeAtReturn(true)
	local label = self:getLabelByName("Label_heroName")
	if label then 
		label:setSize(CCSizeMake(300, 46))
	end

	local widget = self:getLabelByName("Label_hp_value_jx")
	if widget then 
		local size = widget:getSize()
		size.width = size.width + 50
		widget:setSize(size)
		widget:setTextAreaSize(size)
	end	

	widget = self:getLabelByName("Label_hp_value")
	if widget then 
		local size = widget:getSize()
		size.width = size.width + 50
		widget:setSize(size)
		widget:setTextAreaSize(size)
	end	
	
	self:registerKeypadEvent(true, false)
	self:callAfterFrameCount(1, function ( ... )
		self:_adapterLayer(self._showBorder)
		--self:_blurArrow(true)
		if self._showBottom then
			self:callAfterFrameCount(3, function ( ... )
			local scrollView = self:getScrollViewByName("ScrollView_knight_details")
			if scrollView then
				scrollView:jumpToPercentVertical(self._associationPercent)
				--scrollView:jumpToBottom()
			end
		end)
		 
		end	
	end)

	if G_Me.userData.level < 20 then 
		local size = CCDirector:sharedDirector():getWinSize()
		self._fingerNode  = EffectNode.new("effect_shouzhi")
    	self._fingerNode:play()
    	self._fingerNode:setPositionXY(size.width - 100, 300)
    	self:addChild(self._fingerNode)

    	self:callAfterDelayTime(4, nil, function ( ... )
    		self:_stopMovingFinger()
    	end)
	end


end

function HeroDescLayer:onLayerExit( ... )
	if type(self._lastVoiceName) == "string" and #self._lastVoiceName > 3 then
		G_SoundManager:stopSound(self._lastVoiceName)
	end
end

function HeroDescLayer:_stopMovingFinger( ... )
	if self._fingerNode then 
    	self._fingerNode:stop()
    	self._fingerNode:removeFromParentAndCleanup(true)
    	self._fingerNode = nil
    end
end

function HeroDescLayer:onBackKeyEvent( ... )
	self:_closeWindow()
    return true
end

function HeroDescLayer:_closeWindow( ... )
	local tLayer = uf_sceneManager:getCurScene():getChildByTag(PET_INFO_LAYER_TAG)
	if tLayer and tLayer.close then
		tLayer:close()
		tLayer = nil
	end

	self:close()
end

function HeroDescLayer:_adapterLayer( shwoBorder )
	self:adapterWidgetHeight("Panel_scrollPanel", "Panel_top", "", 0, 0)
	if shwoBorder then 
		--self:adapterWidgetHeight("Panel_scrollPanel", "Panel_top", "Panel_btns", -20, 0)
		self:adapterWidgetHeight("ScrollView_knight_details", "Panel_top_border", "Panel_btns", 0, -35)
	else
		self:adapterWidgetHeight("ScrollView_knight_details", "Panel_top_border", "", 0, 0)
	end
end

function HeroDescLayer:_showUpgradeColor( quality )
	--比较早以前，当主将是蓝色或紫色时，要显示升品质的提示文本
	if not quality or quality < 3 or quality > 4 then 
		self:showWidgetByName("Panel_uplevel", false)
		return
	end

	if self._mainKnightId ~= G_Me.formationData:getMainKnightId() then 
		self:showWidgetByName("Panel_uplevel", false)
		return 
	end

	local panel = self:getPanelByName("Panel_uplevel")
	if not panel then 
		return
	end

	self:showWidgetByName("Panel_uplevel", true)
	if self._richText then 
		return 
	end

	local knightColor = G_lang:get(Colors.getColorText(quality + 1))
	local color = Colors.getColor(quality + 1)
	local colorNum = color.r * 256 *256 + color.g*256 + color.b
	local text = G_lang:get("LANG_KNIGHT_COLOR_UPGRADE_FORMAT", {tagValue=(quality == 3) and 3 or 12 ,dungeonName=(quality == 3) and "汉室危" or "争徐州下", colorValue = colorNum, colorKnight=knightColor})

	local size = panel:getSize()
	self._richText = CCSRichText:create(size.width, size.height)
    self._richText:setFontName("ui/font/FZYiHei-M20S.ttf")
    self._richText:setFontSize(20)
    self._richText:setShowTextFromTop(true)
    self._richText:enableStroke(Colors.strokeBrown)
    self._richText:appendContent(text, ccc3(0xfe, 0xf6, 0xd8))
    self._richText:reloadData()
    self._richText:adapterContent()
    local textSize = self._richText:getSize()
    self._richText:setPosition(ccp(size.width/2, 5))
    panel:addChild(self._richText)

    self._richText:setTouchEnabled(true)
    self._richText:setClickHandler(function ( widget, x, y, eleType, tag )
    	if CCS_ATLAS_TYPE_LABEL == eleType then 
    		if tag > 0 then 
    			uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.dungeon.DungeonMainScene").new(nil, nil, 0, tag))
    			self:_closeWindow()
    		end
    	end
    end)
end

function HeroDescLayer:initHeroDesc( teamId, posIndex, knightId, showBorder, showBottom)
	self._showBottom = showBottom or false
	self._showBorder = showBorder or false

	self._teamId = teamId or 1
	self._posIndex = posIndex or -1
	self._mainKnightId = knightId

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if not knightInfo then 
		return
	end

	local baseId = knightInfo["base_id"]
	local level = knightInfo["level"]

	self:showWidgetByName("Button_change", self._teamId ~= 2)
	self:showWidgetByName("Button_change_copy", self._teamId == 2)
	self:showWidgetByName("Button_remove", self._teamId == 2)
	
	-- self:getLabelByName("Label_skill_pu"):setFixedWidth(true)
	-- self:getLabelByName("Label_skill_ji"):setFixedWidth(true)
	-- self:getLabelByName("Label_skill_he"):setFixedWidth(true)

	-- self:getLabelByName("Label_jipan_1"):setFixedWidth(true)
	-- self:getLabelByName("Label_jipan_2"):setFixedWidth(true)
	-- self:getLabelByName("Label_jipan_3"):setFixedWidth(true)
	-- self:getLabelByName("Label_jipan_4"):setFixedWidth(true)
	-- self:getLabelByName("Label_jipan_5"):setFixedWidth(true)
	-- self:getLabelByName("Label_jipan_6"):setFixedWidth(true)

	-- self:getLabelByName("Label_tianfu_1"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_2"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_3"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_4"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_5"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_6"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_7"):setFixedWidth(true)
	-- self:getLabelByName("Label_tianfu_8"):setFixedWidth(true)

	self:_createKnightPage()

	self:initKnightDesc(baseId, level, showBorder, knightInfo)	
end

function HeroDescLayer:_createKnightPage(  )
	-- 当显示阵容界面的武将时，要创建一个pageview，用来滑动切换阵上的武将
	if self._posIndex < 0 or self._heroPageView or self._teamId ~= 1 then 
		return 
	end

	local heroCount = G_Me.formationData:getFormationHeroCount() or 1
	local pagePanel = self:getPanelByName("Panel_knight_pic_back")
	if pagePanel == nil then
		return 
	end	

	self._heroPageView = CCSNewPageViewEx:createWithLayout(pagePanel)
	self._heroPageView:setPageCreateHandler(function ( page, index )
		local cell = CCSPageCellBase:create("ui_layout/knight_info_page.json")
    	return cell
	end)

    self._heroPageView:setPageUpdateHandler(function ( page, index, cell )
        if cell then 
        	local knightRoot = cell:getWidgetByName("Panel_knight")
        	if knightRoot then 
        		knightRoot:removeAllChildren()
        	end

        	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index + 1)
        	baseId = baseId or 0
        	if baseId > 0 then 
        		local knightInfo = knight_info.get(baseId)
        		if knightInfo then 
        			local resId = knightInfo.res_id
        			local knighId, mainBaseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
					if baseId == mainBaseId then 
      					resId = G_Me.dressData:getDressedPic()
    				end
        			local pic = knightPic.createKnightPic(resId, knightRoot)
				end
				if self._tEffectPic then
					self._tEffectPic:removeFromParentAndCleanup(true)
					self._tEffectPic = nil
				end
        	else
        		local tFightPet = G_Me.bagData.petData:getFightPet()
        		__LogError("wrong baseId!")
        		-- 放一个战宠的形象
        		local tPetTmpl = pet_info.get(tFightPet["base_id"])
        		local eff = G_Path.getPetReadyEffect(tPetTmpl.ready_id)
                if not self._tEffectPic then
                    self._tEffectPic = EffectNode.new(eff)
                    assert(self._tEffectPic)
                    local tParent = cell:getPanelByName("Panel_knight")
                    if tParent then
                        tParent:setScale(0.8)
                        tParent:addNode(self._tEffectPic)
                        self._tEffectPic:play()
                    end
                end

        	end
        end
    end)

	self._heroPageView:setPageTurnHandler(function ( page, index, cell )
		if index < heroCount then
			local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index + 1)
			self:initHeroDesc( 1, index + 1, knightId, self._showBorder, self._showBottom)

			self:setVisible(true)
			local tLayer = uf_sceneManager:getCurScene():getChildByTag(PET_INFO_LAYER_TAG)
			if tLayer and tLayer:isVisible() then
				tLayer:setVisible(false)
			end
		else
			local tLayer = uf_sceneManager:getCurScene():getChildByTag(PET_INFO_LAYER_TAG)
			if not tLayer then
				local tFightPet = G_Me.bagData.petData:getFightPet()
				__Log("-- tFightPet id = " .. tFightPet["id"])

				tLayer = require("app.scenes.pet.PetInfo").showEquipmentInfo(tFightPet, 2, {teamId=1, slot=7, pos=7})
				tLayer:setTag(PET_INFO_LAYER_TAG)
				tLayer:setVisible(true)
				self:setVisible(false)
			else
				tLayer:setVisible(true)
				self:setVisible(false)
				tLayer:scrollToPageWithIndex(1)
			end
		end

		local tLayer = uf_sceneManager:getCurScene():getChildByTag(PET_INFO_LAYER_TAG)
		if index == (heroCount - 1) and tLayer then
            tLayer:scrollToPageWithIndex(1)
		end
	end)

	self._heroPageView:setClippingEnabled(false)
	self._heroPageView:showPageWithCount(heroCount + (G_Me.bagData.petData:getFightPetId() ~= 0 and 1 or 0), self._posIndex - 1)
end

function HeroDescLayer:scrollToPageWithIndex(nIndex)
	if self._heroPageView then
		local nPageCount = self._heroPageView:getPageCount()
		if nIndex >= 0 and nIndex <= (nPageCount - 1) then
			self._heroPageView:scrollToPage(nIndex)
		end
	end
end


function HeroDescLayer:_resetCtrls( ... )
	self:showTextWithLabel("Label_skill_he", "")
	self:showTextWithLabel("Label_skill_he", "")
end

function HeroDescLayer:setClickPicFunc(func)

end

function HeroDescLayer:_blurArrow( blur )
	local line = self:getWidgetByName("Image_arrow")
	if not line then
		return 
	end
	blur = blur or false
	if blur and G_Me.userData.level >= 20 then 
		blur = false
	end

	line:setVisible(blur)

	if blur then
		line:stopAllActions()
		local arrowX, arrowY = line:getPosition()

		local arr = CCArray:create()
		arr:addObject(CCResetPosition:create(line, ccp(arrowX, arrowY + 60)))
		arr:addObject(CCResetOpacity:create(line, 255))
		local moveby = CCMoveBy:create(0.8, ccp(0, -60))
		arr:addObject(CCEaseIn:create(moveby, 0.3))
		arr:addObject(CCFadeOut:create(0.2))
		local seqAction = CCSequence:create(arr)
		local repeatAction = CCRepeat:create(seqAction, 8)
		line:runAction(CCSequence:createWithTwoActions(repeatAction, CCCallFunc:create(function ( ... )
			self:_blurArrow(false)
		end)))
	else
		line:stopAllActions()
	end
end

function HeroDescLayer:initKnightDesc( baseId, level, showBorder, info)
	if not info then 
		return 
	end

	level = level or 1
	local association = info.association or {}
	local passive_skill = info.passive_skill or {}
	showBorder = showBorder or false
	self:showWidgetByName("Panel_btns", showBorder)

	self:updateBtnStatus()

	if self._teamId == 1 and self._posIndex == 1 then
		self:enableWidgetByName("Button_change", false)
		self:showWidgetByName("Button_strengthen", false)
	else
		self:enableWidgetByName("Button_change", true)
		self:showWidgetByName("Button_strengthen", true)
	end

	if not self:isRunning() then 
		--self:callAfterFrameCount(1, function ( ... )
			if showBorder then
				self:adapterWidgetHeight("Panel_scrollPanel", "Panel_top_border", "Panel_btns", -80, -30)
			else
				self:adapterWidgetHeight("Panel_scrollPanel", "Panel_top_border", "", -80, 0)
			end
		--end)
	end

	local guanhuanLevel = info["halo_level"] or 1
	local label = self:getLabelByName("Label_guanghuan_value")
	if label then
		label:setText( guanhuanLevel )
	end

	self._baseId = baseId or 0
	local resId = 1
	local knightInfo = nil
	if baseId > 0 then
		knightInfo = knight_info.get(self._baseId)
	end

	if knightInfo ~= nil then
		resId = knightInfo["res_id"]
	else
		__LogError("knightinfo is nil for baseId:%d", baseId)
	end

	local knighId, mainBaseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
	if baseId == mainBaseId then 
      	resId = G_Me.dressData:getDressedPic()
    end

    local heroPanel = self:getPanelByName("Panel_knight_pic") 
    if heroPanel and not self._heroPageView then
		knightPic.createKnightPic(resId, heroPanel)
		--if pic then
			--local size = heroPanel:getSize()
			--local posx, posy = pic:getPosition()
			--pic:setPosition(ccp(0, posy))
		--end
    end

    self:showWidgetByName("Button_left", not not self._heroPageView)
    self:showWidgetByName("Button_right", not not self._heroPageView)

    local mainKnightId = G_Me.formationData:getMainKnightId()
    local heroName = self:getLabelByName("Label_heroName")
    if heroName ~= nil then
		heroName:setColor(Colors.getColor(knightInfo and knightInfo.quality or 1))
    	if mainKnightId == self._mainKnightId then
			heroName:setText(G_Me.userData.name)
		else
    		heroName:setText(knightInfo ~= nil and knightInfo.name or "Default Name")
    	end
    end

    --self:_showUpgradeColor(knightInfo and knightInfo.quality or 1)

    local attributeLevel1 = {}
	if self._mainKnightId > 0 then
		attributeLevel1 = G_Me.bagData.knightsData:getKnightAttr1(self._mainKnightId)
	end
    --local starPanel = self:getWidgetByName("Panel_stars")
    --GlobalFunc.showStars(self, 
    --		{"ImageView_star_1", "ImageView_star_6","ImageView_star_5","ImageView_star_4","ImageView_star_3","ImageView_star_2"},
    --		knightInfo and knightInfo.star or 1, 2, starPanel:getSize())

	label = self:getLabelByName("Label_hp_value")
	if label then
		if  knightInfo then
			label:setText(attributeLevel1.hp)
		else
			label:setText("")
		end
	else
		__Log("hp label is nil")
	end

	label = self:getLabelByName("Label_attack_value")
	if label then
		if knightInfo then
			label:setText(attributeLevel1.attack)
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_def_wuli_value")
	if label then
		if  knightInfo then
			label:setText(attributeLevel1.phyDefense)
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_def_mofa_value")
	if label then
		if  knightInfo then
			label:setText(attributeLevel1.magicDefense)
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_zizhi")
	if label then
		label:setColor(Colors.getColor(knightInfo and (knightInfo.quality) or 1))
		label:setText( G_lang:get("LANG_ZIZHI_FORMAT", {zizhiValue = knightInfo and knightInfo.potential or 0}), true)
	end

	label = self:getLabelByName("Label_jingjie_value_top")
	if label  then
		label:setColor(Colors.getColor(knightInfo and (knightInfo.quality) or 1))
		label:setText((knightInfo and knightInfo.advanced_level > 0) and ("+"..knightInfo.advanced_level) or "", true)
	end

	label = self:getLabelByName("Label_jingjie_value")
	if label then
		label:setText(knightInfo and ("+"..knightInfo.advanced_level) or "")
	end

	--local mainKnightId = G_Me.formationData:getMainKnightId()
	local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
	self:showTextWithLabel("Label_level_value", string.format("%d/%d", level, mainKnightInfo and mainKnightInfo["level"] or 1 ))

	local image = self:getImageViewByName("ImageView_knight_type")
	if image then
		local groupPath, imgType = G_Path.getJobTipsIcon(knightInfo.character_tips)
		if groupPath then
			image:loadTexture(groupPath, imgType)
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end

	image = self:getImageViewByName("ImageView_country")
	if image then
		local groupPath, imgType = G_Path.getKnightGroupIcon(knightInfo and knightInfo.group or -1)
		if groupPath then
			image:loadTexture(groupPath, imgType)
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end

	label = self:getLabelByName("Label_desc")
	if label then
		label:setColor(Colors.inActiveSkill)
		label:setText(knightInfo and knightInfo.directions or "")
	end

	-- local image = self:getImageViewByName("ImageView_job_type")
	-- if image then
	-- 	local damagePath, imgType = G_Path.getDamageTypeIcon(knightInfo.damage_type)
	-- 	if damagePath then
	-- 		image:loadTexture(damagePath, imgType)
	-- 		image:setVisible(true)
	-- 	else
	-- 		image:setVisible(false)
	-- 	end
	-- end

	image = self:getImageViewByName("ImageView_color")
	if image then
		image:loadTexture(G_Path.getKnightColorText(knightInfo.quality))
	end

	local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(self._mainKnightId) or -1
    self:showWidgetByName("Panel_stars", stars >= 0)
    if stars >= 0 then 
        self:showWidgetByName("Image_start_1_full", stars >= 1)
        self:showWidgetByName("Image_start_2_full", stars >= 2)
        self:showWidgetByName("Image_start_3_full", stars >= 3)
        self:showWidgetByName("Image_start_4_full", stars >= 4)
        self:showWidgetByName("Image_start_5_full", stars >= 5)
        self:showWidgetByName("Image_start_6_full", stars >= 6)

        self:showTextWithLabel("Label_juexing_value", G_lang:get("LANG_KNIGHT_AWAKEN_DESC", {star=math.floor(info.awaken_level / 10), level=info.awaken_level % 10}))

        local awakenUnlock, awakenQualityLimit, awakenLevelValid, notAwakenMaxLevel = G_Me.bagData.knightsData:isKnightAwakenValid(self._mainKnightId)
       -- __Log("awakenUnlock:%d, awakenQualityLimit:%d, awakenLevelValid:%d, notAwakenMaxLevel:%d", 
        --	awakenUnlock and 1 or 0, awakenQualityLimit and 1 or 0, awakenLevelValid and 1 or 0, notAwakenMaxLevel and 1 or 0)
        self:enableWidgetByName("Button_juexing", not (not awakenUnlock or not awakenQualityLimit or not awakenLevelValid or not notAwakenMaxLevel))
    end

	-- 根据武将所在阵容的不同，更新武将培养的各个按钮的显示状态
	if self._teamId == 1 then 
		local guanzhiUnlock, canGuanZhi, qualityPermit = G_Me.bagData.knightsData:isKnightGuanghuanOpen(self._mainKnightId)
		self:enableWidgetByName("Button_guanghuan", guanzhiUnlock and canGuanZhi and qualityPermit)
		self:enableWidgetByName("Button_strengthen", level < (mainKnightInfo["level"] or 1))
		local xilianUnlock, canXilian = G_Me.bagData.knightsData:isKnightCanTraining(self._mainKnightId)
		self:enableWidgetByName("Button_xilian", xilianUnlock and canXilian)

		local notMaxJingjieLevel, canJingjie =  G_Me.bagData.knightsData:canJingJieWithKnightId(self._mainKnightId)
		self:enableWidgetByName("Button_jingjie", notMaxJingjieLevel and canJingjie)
	-- else
	-- 	self:showWidgetByName("Button_guanghuan", false)
	-- 	self:showWidgetByName("Button_strengthen", false)
	-- 	self:showWidgetByName("Button_xilian", false)
	-- 	self:showWidgetByName("Button_jingjie", false)
	end

	-- 播放语音的功能
	self._isPlayingVoice = false
	self._lastCommonVoice = false
	if type(self._lastVoiceName) == "string" and #self._lastVoiceName > 3 then
		G_SoundManager:stopSound(self._lastVoiceName)
	end
	self:registerBtnClickEvent("Button_play_voice", function ( ... )
		if self._isPlayingVoice then 
			return 
		end

		self._isPlayingVoice = true
		self._lastVoiceName  = self._lastCommonVoice and knightInfo.skill_sound or knightInfo.common_sound
		if self._lastVoiceName == "0" then 
			self._lastVoiceName = knightInfo.common_sound
		end
		self._lastCommonVoice = not self._lastCommonVoice
		if type(self._lastVoiceName) == "string" and #self._lastVoiceName > 3 then
			G_SoundManager:playSound(self._lastVoiceName)
		end
		self:callAfterDelayTime(4.0, nil, function ( ... )
			self._isPlayingVoice = false
			self._lastVoiceName = nil
		end)
		--self:enableWidgetByName("Button_play_voice", false)
	end)



	-- local scrollView = self:getScrollViewByName("ScrollView_knight_details")
	-- 	if scrollView then 
	-- 		scrollView:sortAllChildren()
	-- 	end

	-- 按倒序显示武将的 介绍信息，天赋信息，缘分信息，技能信息
	local scrollView = self:getScrollViewByName("ScrollView_knight_details")
	if scrollView then 
		local bottomY = 5
		local scrollSize = scrollView:getInnerContainerSize()

		local widget = self:getWidgetByName("Panel_desc")
		if widget then 
			local descSize = widget:getSize()
			widget:setPosition(ccp(0, bottomY))
			bottomY = bottomY + descSize.height + 5
		end

		
		bottomY = self:_loadTianfuInfo( knightInfo, bottomY, info.passive_skill or {} )
		bottomY = self:_loadAssociationInfo(knightInfo, bottomY, info.association or {})

		local isGodOpen, godState = G_Me.bagData.knightsData:isGodOpen(self._mainKnightId)

		self:enableWidgetByName("Button_God", isGodOpen)

		if godState == G_Me.bagData.knightsData.GOD_MAX_LEVEL then isGodOpen = true end

		bottomY = self:_loadGodInfo(knightInfo, bottomY, isGodOpen)

		local KnightConst = require("app.const.KnightConst")
		
		self:showWidgetByName("Panel_God", isGodOpen)
		
		if isGodOpen then
			widget = self:getWidgetByName("Panel_God")
			if widget then 
				local descSize = widget:getSize()
				widget:setPosition(ccp(0, bottomY))
				local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._mainKnightId)

				local potentialColor = G_lang:get("LANG_GOD_HONG")
				if knightInfo.potential < KnightConst.KNIGHT_GOD_RED_POTENTIAL then
					potentialColor = G_lang:get("LANG_GOD_CHENG")
				end

				self:showTextWithLabel("Label_God_Value", potentialColor .. HeroGodCommon.getDisplyLevel(nowGodLevel))
				bottomY = bottomY + descSize.height + 5
			end
		end

		bottomY = self:_loadJuexingTianfu(knightInfo, bottomY, stars)
		bottomY = self:_loadJuexingInfo(knightInfo, bottomY, stars, info.awaken_level or 0)

		local associationTop = bottomY
		self:showWidgetByName("Panel_juexing", stars >= 0)
		if stars >= 0 then
			widget = self:getWidgetByName("Panel_juexing")
			if widget then 
				local descSize = widget:getSize()
				widget:setPosition(ccp(0, bottomY))
				bottomY = bottomY + descSize.height + 5
			end
		end

		widget = self:getWidgetByName("Panel_guanghuan")
		if widget then 
			local descSize = widget:getSize()
			widget:setPosition(ccp(0, bottomY))
			bottomY = bottomY + descSize.height + 5
		end

		bottomY = self:_loadSkillInfo(knightInfo, guanhuanLevel, bottomY, scrollSize.height)

		widget = self:getWidgetByName("Panel_base_info")
		if widget then 
			local descSize = widget:getSize()
			widget:setPosition(ccp(0, bottomY))
			bottomY = bottomY + descSize.height + 5
		end

		self._associationPercent = associationTop*100/bottomY
		scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY))
	end
end

function HeroDescLayer:_loadSkillInfo( knightInfo, guanhuan, bottomY, scrollHeight )
	local panel = self:getPanelByName("Panel_skill")
	if not panel or not knightInfo then 
		return bottomY
	end

	local title = self:getWidgetByName("ImageView_header")
	if title then 
		title:retain()
	end

	local dress = G_Me.dressData:getDressed() 
	local dressInfo = nil
	if dress and knightInfo.group == 0 then
		dressInfo = G_Me.dressData:getDressInfo(dress.base_id) 
	end
	local guanhuanLevel = guanhuan or 1
	panel:removeAllChildren()
	scrollHeight = scrollHeight or 0
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 5

	local validSkill, skillIds = self:isUnionSkillActive(knightInfo)
	if dress and knightInfo.group == 0 then 
		if G_Me.dressData:getDressed() and G_Me.dressData:getDressed().level >= 160 then
			validSkill, skillIds = self:isUnionSkillActiveForDress(dressInfo)
		end
	end
	local damageTxt = dressInfo and G_Me.dressData:getAttackTypeTxt() or G_lang:get("LANG_DRESS_ATTACK_TYPE"..knightInfo.damage_type)

	-- 超级技能
	local super_unite_skill_id = dressInfo and dressInfo.super_unite_skill_id or knightInfo.super_unite_skill_id
	if super_unite_skill_id > 0 then 
		local skillInfo = skill_info.get(super_unite_skill_id)
		if skillInfo then
			local descTxt = dressInfo and dressInfo.sp_unite_des or skillInfo.directions
			local heSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(descTxt, 
	 			{num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
	 			 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1), 
	 			 damage_type = damageTxt,
	 			 test = (guanhuanLevel <= 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor((skillInfo.formula_value1_add_1 / 10)*(guanhuanLevel - 1))}) })

			local label = GlobalFunc.createGameLabel(heSkill, 22, 
				(validSkill and (dressInfo and dress.level >= dressInfo.super_unite_clear_level or knightInfo.advanced_level >= 10)) and Colors.activeSkill or Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_chao.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	-- 合击技能
	local unite_skill_id = dressInfo and dressInfo.unite_skill_id or knightInfo.unite_skill_id
	if unite_skill_id > 0 then 
		local skillInfo = skill_info.get(unite_skill_id)
		if skillInfo then
			
			if type(skillIds) == "table" and #skillIds > 0 then
				local label = GlobalFunc.createGameLabel(G_lang:get("LANG_KNIGHT_AQUIRE_KNIGHT_DESC"), 22, Colors.activeSkill, nil, nil, true)
				local labelSize = label:getSize()
			
				local underLine = GlobalFunc.createGameLabel("_", 22, Colors.activeSkill, nil, nil, true)
				local lineSize = underLine:getSize()
				underLine:setPositionXY(size.width - 15 -labelSize.width/2, startYpos + labelSize.height/2)
				panel:addChild(underLine)
				underLine:setScaleX(labelSize.width/lineSize.width + 1)

				panel:addChild(label, 1, 100)
				label:setPositionXY(size.width - 15 -labelSize.width/2, startYpos + labelSize.height/2)
				label:setName("__ACQUIRE_KNIGHT__")
				label:setTouchEnabled(true)
				self:registerWidgetClickEvent("__ACQUIRE_KNIGHT__", function ( ... )
					require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, skillIds[1])
				end)
				startYpos = startYpos + labelSize.height
			end

			local heSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
	 			{num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
	 			 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1), 
	 			 damage_type = damageTxt,
	 			 test = (guanhuanLevel <= 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor((skillInfo.formula_value1_add_1 / 10 )*(guanhuanLevel - 1))})})

			local label = GlobalFunc.createGameLabel(heSkill, 22, 
				validSkill and Colors.activeSkill or Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPositionXY(labelPosX, startYpos + labelSize.height/2)
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_he.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	local active_skill_id = dressInfo and dressInfo.active_skill_id_1 or knightInfo.active_skill_id
	if active_skill_id > 0 then 
		local skillInfo = skill_info.get(active_skill_id)
		if skillInfo then
			local jiSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
	 			{num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
	 			 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1), 
	 			 damage_type = damageTxt,
	 			 test = (guanhuanLevel <= 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3= math.floor((skillInfo.formula_value1_add_1 / 10) *(guanhuanLevel - 1))})})

			local label = GlobalFunc.createGameLabel(jiSkill, 22, Colors.activeSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_ji.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	local common_id = dressInfo and dressInfo.common_skill_id or knightInfo.common_id
	if common_id > 0 then 
		local skillInfo = skill_info.get(common_id)
		if skillInfo then 
			local skillText = "["..skillInfo.name.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1,
				num2 = skillInfo.formula_value1_2,
				damage_type = damageTxt,})

			local label = GlobalFunc.createGameLabel(skillText, 22, Colors.activeSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_pu.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	startYpos = startYpos + 5
	if title then 
		local titleSize = title:getSize()
		panel:addChild(title)
		title:release()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 5))
	panel:setPosition(ccp(0, initYPos))
	
	bottomY = bottomY + 10

	return bottomY
end

function HeroDescLayer:_loadGodInfo(knightBaseInfo, bottomY, isGodOpen)
	local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	if not mainKnightInfo and not isGodOpen or (knightBaseInfo.god_level == 0 and mainKnightInfo.pulse_level == 0) then
		self:showWidgetByName("Panel_God_Info", false)
		return bottomY
	end

	local attrs = G_Me.bagData.knightsData:getGodAttrs(self._mainKnightId)

	local attack = attrs[1]
	local hp = attrs[2]
	local pdef = attrs[3]
	local mdef = attrs[4]

	self:showTextWithLabel("Label_attack_value_hs", "+" .. attack)
	self:showTextWithLabel("Label_hp_value_hs", "+" .. hp)
	self:showTextWithLabel("Label_def_wuli_value_hs", "+" .. pdef)
	self:showTextWithLabel("Label_def_mofa_value_hs", "+" .. mdef)
	
	self:showWidgetByName("Panel_God_Info", true)

	local widget = self:getWidgetByName("Panel_God_Info")
	if widget then 
		local descSize = widget:getSize()
		widget:setPosition(ccp(0, bottomY))
		bottomY = bottomY + descSize.height + 5
	end

	return bottomY
end

function HeroDescLayer:_loadJuexingTianfu( knightInfo, bottomY, stars )
	self:showWidgetByName("Panel_juexing_tianfu", stars >= 0)
	if stars < 0 then 
		return bottomY
	end

	local panel = self:getPanelByName("Panel_juexing_tianfu")
	if not panel or not knightInfo then 
		return bottomY
	end

	local title = self:getWidgetByName("ImageView_header_3")
	if title then 
		title:retain()
	end
	panel:removeAllChildren()
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 5

	local juexingTianfu = G_Me.bagData.knightsData:getKnightAwakenTalent(self._mainKnightId)
	if type(juexingTianfu) == "table" and #juexingTianfu > 0 then
		for loopi = #juexingTianfu, 1, -1 do 
			local value = juexingTianfu[loopi]
			if value and type(value.talentDesc) == "string" then
				local desc = string.format("[%s] %s", value.talentTitle, value.talentDesc)
				local label = GlobalFunc.createGameLabel(desc, 22, value.isActivated and Colors.activeSkill or Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 15, 0), true)

				local labelSize = label:getSize()

				label:setPosition(ccp(size.width/2, startYpos + labelSize.height/2))
				panel:addChild(label)
				startYpos = startYpos + labelSize.height
			end
		end 
	end

	if title then 
		local titleSize = title:getSize()
		panel:addChild(title)
		title:release()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 5))
	panel:setPosition(ccp(0, initYPos))
	bottomY = bottomY + 10

	return bottomY
end

function HeroDescLayer:_loadJuexingInfo(knightInfo, bottomY, stars, level)
	if not knightInfo or type(stars) ~= "number" or stars < 0 or type(level) ~= "number" then 
		self:showWidgetByName("Panel_juexing_info", false)
		return bottomY
	end

	require("app.cfg.knight_awaken_info")
	local knightAwakeInfo = knight_awaken_info.get(knightInfo.awaken_code, level)
	if not knightAwakeInfo then 
		__LogError("HeroDescLayer:_loadJuexingInfo: invalid awake info for code:%d, level:%d", knightInfo.awaken_code, level)
		self:showWidgetByName("Panel_juexing_info", false)
		return bottomY
	end

	local _showJuexingAttri = function ( typeId, value )
		value = value or 0
		if typeId == 6 then 
			self:showTextWithLabel("Label_attack_value_jx", "+"..value)
		elseif typeId == 5 then 
			__Log("value=%d", value)
			self:showTextWithLabel("Label_hp_value_jx", "+"..value)
		elseif typeId == 3 then 
			self:showTextWithLabel("Label_def_wuli_value_jx", "+"..value)
		elseif typeId == 4 then 
			self:showTextWithLabel("Label_def_mofa_value_jx", "+"..value)
		elseif typeId == 1 or typeId == 2 then 
			self:showTextWithLabel("Label_attack_value_jx", "+"..value)
		elseif typeId == 21 then 
			self:showTextWithLabel("Label_def_wuli_value_jx", "+"..value)
			self:showTextWithLabel("Label_def_mofa_value_jx", "+"..value)
		end	
	end

	self:showTextWithLabel("Label_attack_value_jx", "+0")
	self:showTextWithLabel("Label_hp_value_jx", "+0")
	self:showTextWithLabel("Label_def_mofa_value_jx", "+0")
	self:showTextWithLabel("Label_def_wuli_value_jx", "+0")
	
	_showJuexingAttri(knightAwakeInfo.strength_type_1, knightAwakeInfo.strength_value_1)
	_showJuexingAttri(knightAwakeInfo.strength_type_2, knightAwakeInfo.strength_value_2)
	_showJuexingAttri(knightAwakeInfo.strength_type_3, knightAwakeInfo.strength_value_3)
	_showJuexingAttri(knightAwakeInfo.strength_type_4, knightAwakeInfo.strength_value_4)
	
	self:showWidgetByName("Panel_juexing_info", true)

	local widget = self:getWidgetByName("Panel_juexing_info")
	if widget then 
		local descSize = widget:getSize()
		widget:setPosition(ccp(0, bottomY))
		bottomY = bottomY + descSize.height + 5
	end

	return bottomY
end

function HeroDescLayer:_loadAssociationInfo( knightInfo, bottomY, association )
	local panel = self:getPanelByName("Panel_jipan")
	if not panel or not knightInfo then 
		return bottomY
	end

	local title = self:getWidgetByName("ImageView_header_1")
	if title then 
		title:retain()
	end
	panel:removeAllChildren()
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 5
	require("app.cfg.association_info")
	local addJipanContent = function ( associationId, isActive )
		local associationInfo = association_info.get(associationId)
		if associationInfo == nil then
			return 
		end
		
		local desc = string.format("[%s] %s", associationInfo.name, associationInfo.directions)
		local label = GlobalFunc.createGameLabel(desc, 22, isActive and Colors.activeSkill or Colors.inActiveSkill,
		 nil, CCSizeMake(size.width - 15, 0), true)

		local labelSize = label:getSize()

		label:setPosition(ccp(size.width/2, startYpos + labelSize.height/2))
		panel:addChild(label)
		startYpos = startYpos + labelSize.height
	end

	if self._mainKnightId == G_Me.formationData:getMainKnightId() then
		addJipanContent(knightInfo.association_12, findIdInTable(association, knightInfo.association_12))
		addJipanContent(knightInfo.association_11, findIdInTable(association, knightInfo.association_11))
		addJipanContent(knightInfo.association_10, findIdInTable(association, knightInfo.association_10))
		addJipanContent(knightInfo.association_9, findIdInTable(association, knightInfo.association_9))
	end

	local oldYPos = startYpos
	addJipanContent(knightInfo.association_8, findIdInTable(association, knightInfo.association_8))
	addJipanContent(knightInfo.association_7, findIdInTable(association, knightInfo.association_7))
	addJipanContent(knightInfo.association_6, findIdInTable(association, knightInfo.association_6))	
	addJipanContent(knightInfo.association_5, findIdInTable(association, knightInfo.association_5))
	addJipanContent(knightInfo.association_4, findIdInTable(association, knightInfo.association_4))
	addJipanContent(knightInfo.association_3, findIdInTable(association, knightInfo.association_3))
	addJipanContent(knightInfo.association_2, findIdInTable(association, knightInfo.association_2))
	addJipanContent(knightInfo.association_1, findIdInTable(association, knightInfo.association_1))

	if startYpos == 0 then
		panel:setVisible(false) 
		return bottomY
	end

	if oldYPos == startYpos then
		startYpos = startYpos + 45
	end
	startYpos = startYpos + 5
	
	if title then 
		local titleSize = title:getSize()
		panel:addChild(title)
		title:release()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 5))
	panel:setPosition(ccp(0, initYPos))
	bottomY = bottomY + 10

	return bottomY
end

function HeroDescLayer:_loadTianfuInfo( knightInfo, bottomY, passive_skill )
	local panel = self:getPanelByName("Panel_tianfu")
	if not panel or not knightInfo then 
		return bottomY
	end

	local title = self:getWidgetByName("ImageView_header_1_0")
	if title then 
		title:retain()
	end
	panel:removeAllChildren()
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 5
	require("app.cfg.passive_skill_info")
	local addTianfuContent = function ( passiveId, isActive )
		if passiveId == 0 then
			return
		end
		local passiveInfo = passive_skill_info.get(passiveId)
		if not passiveInfo then
			return 
		end

		local desc = string.format("[%s] %s", passiveInfo.name, passiveInfo.directions)
		local label = GlobalFunc.createGameLabel(desc, 22, isActive and Colors.activeSkill or Colors.inActiveSkill,
		 nil, CCSizeMake(size.width - 15, 0), true)

		local labelSize = label:getSize()

		label:setPosition(ccp(size.width/2, startYpos + labelSize.height/2))
		panel:addChild(label)
		startYpos = startYpos + labelSize.height
	end

	local oldYPos = startYpos
	addTianfuContent(knightInfo.passive_skill_15, findIdInTable( passive_skill, knightInfo.passive_skill_15))
	addTianfuContent(knightInfo.passive_skill_14, findIdInTable( passive_skill, knightInfo.passive_skill_14))
	addTianfuContent(knightInfo.passive_skill_13, findIdInTable( passive_skill, knightInfo.passive_skill_13))
	addTianfuContent(knightInfo.passive_skill_12, findIdInTable( passive_skill, knightInfo.passive_skill_12))
	addTianfuContent(knightInfo.passive_skill_11, findIdInTable( passive_skill, knightInfo.passive_skill_11))
	addTianfuContent(knightInfo.passive_skill_10, findIdInTable( passive_skill, knightInfo.passive_skill_10))
	addTianfuContent(knightInfo.passive_skill_9, findIdInTable( passive_skill, knightInfo.passive_skill_9))
	addTianfuContent(knightInfo.passive_skill_8, findIdInTable( passive_skill, knightInfo.passive_skill_8))
	addTianfuContent(knightInfo.passive_skill_7, findIdInTable( passive_skill, knightInfo.passive_skill_7))
	addTianfuContent(knightInfo.passive_skill_6, findIdInTable( passive_skill, knightInfo.passive_skill_6))
	addTianfuContent(knightInfo.passive_skill_5, findIdInTable( passive_skill, knightInfo.passive_skill_5))
	addTianfuContent(knightInfo.passive_skill_4, findIdInTable( passive_skill, knightInfo.passive_skill_4))
	addTianfuContent(knightInfo.passive_skill_3, findIdInTable( passive_skill, knightInfo.passive_skill_3))
	addTianfuContent(knightInfo.passive_skill_2, findIdInTable( passive_skill, knightInfo.passive_skill_2))
	addTianfuContent(knightInfo.passive_skill_1, findIdInTable( passive_skill, knightInfo.passive_skill_1))

	if startYpos == 0 then 
		panel:setVisible(false)
		return bottomY
	end
	if oldYPos == startYpos then
		startYpos = startYpos + 45
	end
	startYpos = startYpos + 5
	
	if title then 
		local titleSize = title:getSize()
		panel:addChild(title)
		title:release()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 5))
	panel:setPosition(ccp(0, initYPos))
	bottomY = bottomY + 10

	return bottomY
end

function HeroDescLayer:_checkValidUnionSkill( uniteSkillId )
	uniteSkillId = uniteSkillId or 0
	if uniteSkillId <= 0 then 
		return false
	end

	require("app.cfg.unite_skill_info")
	local uniteSkill = unite_skill_info.get(uniteSkillId)
	if not uniteSkill then  
		return false
	end

	local skillArr = {}
	local count = 0
	if uniteSkill.need_knight_1 > 0 then 
		skillArr[uniteSkill.need_knight_1] = 1
		count = count + 1
	end
	if uniteSkill.need_knight_2 > 0 then 
		skillArr[uniteSkill.need_knight_2] = 1
		count = count + 1
	end
	if uniteSkill.need_knight_3 > 0 then 
		skillArr[uniteSkill.need_knight_3] = 1
		count = count + 1
	end
	if uniteSkill.need_knight_4 > 0 then 
		skillArr[uniteSkill.need_knight_4] = 1
		count = count + 1
	end

	if count < 1 then  
		return false
	end
	
	local formationKnight = G_Me.formationData:getFirstTeamKnightIds()
	for key, value in pairs(formationKnight) do 
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
		if knightInfo then
			local knightBaseInfo = knight_info.get(knightInfo["base_id"])
			if knightBaseInfo and skillArr[knightBaseInfo.advance_code] then 
				count = count - 1
				skillArr[knightBaseInfo.advance_code] = nil
			end
		end
	end

	local needKnightIds = {}
	for key, value in pairs(skillArr) do 
		table.insert(needKnightIds, #needKnightIds + 1, key)
	end

	return count == 0, needKnightIds
end

function HeroDescLayer:isUnionSkillActive( knightInfo )
	if not knightInfo then 
		return false
	end

	local skillArr = {}
	local count = 0
	if knightInfo.release_knight_1 > 0 then 
		skillArr[knightInfo.release_knight_1] = 1
		count = count + 1
	end
	if knightInfo.release_knight_2 > 0 then 
		skillArr[knightInfo.release_knight_2] = 1
		count = count + 1
	end

	if count < 1 then  
		return false
	end
	
	local formationKnight = G_Me.formationData:getFirstTeamKnightIds()
	for key, value in pairs(formationKnight) do 
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
		if knightInfo then
			local knightBaseInfo = knight_info.get(knightInfo["base_id"])
			if knightBaseInfo and skillArr[knightBaseInfo.advance_code] then 
				count = count - 1
				skillArr[knightBaseInfo.advance_code] = nil
			end
		end
	end

	local needKnightIds = {}
	for key, value in pairs(skillArr) do 
		table.insert(needKnightIds, #needKnightIds + 1, key)
	end

	return count == 0, needKnightIds
end

function HeroDescLayer:isUnionSkillActiveForDress( dressInfo )
	if not dressInfo then 
		return false
	end

	local skillArr = {}
	local count = 0
	if dressInfo.release_knight_id > 0 then 
		skillArr[dressInfo.release_knight_id] = 1
		count = count + 1
	end
	if count < 1 then  
		return false
	end
	
	local formationKnight = G_Me.formationData:getFirstTeamKnightIds()
	for key, value in pairs(formationKnight) do 
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
		if knightInfo then
			local knightBaseInfo = knight_info.get(knightInfo["base_id"])
			if knightBaseInfo and skillArr[knightBaseInfo.advance_code] then 
				count = count - 1
				skillArr[knightBaseInfo.advance_code] = nil
			end
		end
	end

	local needKnightIds = {}
	for key, value in pairs(skillArr) do 
		table.insert(needKnightIds, #needKnightIds + 1, key)
	end

	return count == 0, needKnightIds
end

function HeroDescLayer:updateBtnStatus( ... )
	self:enableAudioEffectByName("Button_back", false)
	self:registerBtnClickEvent("Button_back", function ( widget )
		self:_closeWindow()

		local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	end)

	self:registerBtnClickEvent("Button_strengthen", function ( widget )
		local KnightConst = require("app.const.KnightConst")
		uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
			KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, self._mainKnightId ))
		self:_closeWindow()
	end)

	self:registerBtnClickEvent("Button_jingjie", function (widget )
		local KnightConst = require("app.const.KnightConst")
		uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
			KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId ))
		self:_closeWindow()
	end)

	self:registerBtnClickEvent("Button_xilian", function (widget )
		local KnightConst = require("app.const.KnightConst")
		uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
			KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._mainKnightId ))
		self:_closeWindow()
	end)

	self:registerBtnClickEvent("Button_guanghuan", function (widget )
		local KnightConst = require("app.const.KnightConst")
		uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
			KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN, self._mainKnightId ))
		self:_closeWindow()
	end)

	self:registerBtnClickEvent("Button_God", function (widget )
		local KnightConst = require("app.const.KnightConst")
		uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
			KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId ))
		self:_closeWindow()
	end)

	self:registerBtnClickEvent("Button_change", function ( widget )
		self:_onChangeBtnClick()
	end)

	self:registerBtnClickEvent("Button_left", function ( widget )
		local curIndex = self._heroPageView:getCurPageIndex()
		if curIndex > 0 then 
			self._heroPageView:scrollToPage(curIndex - 1)
			--local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, self._posIndex - 1)
			--self:initHeroDesc( 1, self._posIndex - 1, knightId, self._showBorder, self._showBottom)
		end
	end)

	self:registerBtnClickEvent("Button_right", function ( widget )
		local heroCount = (G_Me.formationData:getFormationHeroCount() or 1) + (G_Me.bagData.petData:getFightPetId() ~= 0 and 1 or 0)
		local curIndex = self._heroPageView:getCurPageIndex()
		if curIndex < heroCount - 1 then 
			self._heroPageView:scrollToPage(curIndex + 1)
			--local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, self._posIndex + 1)
			--self:initHeroDesc( 1, self._posIndex + 1, knightId, self._showBorder, self._showBottom)
		end
	end)
	self:registerBtnClickEvent("Button_change_copy", function ( widget )
		self:_onChangeBtnClick()
	end)
	self:registerBtnClickEvent("Button_remove", function ( widget )
		self:_onRemoveBtnClick()
	end)
	self:registerBtnClickEvent("Button_juexing", function ( widget )
		local KnightConst = require("app.const.KnightConst")
		uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
			KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._mainKnightId ))
		self:_closeWindow()
    end)
	self:registerScrollViewEvent("ScrollView_knight_details", function ( scrollView, scrollType )
		if scrollType and scrollType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
			--self:_blurArrow(false)
			self:_stopMovingFinger()
		end
	end)
end

function HeroDescLayer:_onChangeBtnClick( ... )
	local team1Knight, team1Count = G_Me.formationData:getFirstTeamKnightIds()
    	local team2Knight, team2Count = G_Me.formationData:getSecondTeamKnightIds()
    	if team1Count + team2Count >= G_Me.bagData.knightsData:getKnightCount() then
    		G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
    	else
			local parent = self:getParent()
		
			local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")

        	heroSelectLayer.showHeroSelectLayer(parent, self._posIndex, function ( knightId, effectWaitCallback, teamId, posIndex )
        		if knightId then
        			if teamId == 2 then 
        				posIndex = posIndex - 6
        			end
        			if not G_Me.formationData:isKnightValidjForCurrentTeam(teamId, knightId, posIndex) then
        				__Log("teamid:%d, knightId:%d, posIndex:%d", teamId, knightId, posIndex)
                		G_MovingTip:showMovingTip(G_lang:get("LANG_SAME_KNIGHT"))
                		return 
            		end
        			G_HandlersManager.cardHandler:changeTeamFormation(teamId, 
        				posIndex, knightId )	
        		end
        	end, nil, self._teamId, self._posIndex)
        	self:_closeWindow()
        end
end

function HeroDescLayer:_onRemoveBtnClick( ... )
	if self._teamId ~= 2 then 
		__LogError("wrong teamid!")
		return 
	end

	local posIndex = self._posIndex
	if self._teamId == 2 then 
    	posIndex = posIndex - 6
    end

	G_HandlersManager.cardHandler:changeTeamFormation(2, posIndex, 0)
	self:_closeWindow()
end

function HeroDescLayer:onLayerUnload( ... )
	-- body
end

function HeroDescLayer.showHeroDesc( parent, knightId, showBorder, showBottom, teamId, posIndex)
	if parent == nil then
		return nil
	end

	local heroDesc = require("app.scenes.hero.HeroDescLayer").new("ui_layout/knight_info.json", Colors.modelColor)
	--parent:addChild(heroDesc)
	uf_sceneManager:getCurScene():addChild(heroDesc)
	heroDesc:initHeroDesc(teamId, posIndex or -1, knightId or 0, showBorder, showBottom)

	return heroDesc
end

function HeroDescLayer.showKnightDesc( parent, baseId,func )
	if parent == nil then
		return 
	end

	local heroDesc = require("app.scenes.hero.HeroDescLayer").new("ui_layout/knight_info.json", Colors.modelColor)
	
	heroDesc:initKnightDesc(baseId, nil, false)
        if func then
            heroDesc:setClickPicFunc(func)
            local heroPanel = heroDesc:getPanelByName("Panel_knight_pic") 
            if heroPanel then heroPanel:setTouchEnabled(true) end
           heroDesc:registerWidgetTouchEvent("Panel_knight_pic",func)
        end

    parent:addChild(heroDesc)
    return heroDesc
end

return HeroDescLayer