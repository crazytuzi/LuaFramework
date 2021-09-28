--PartnerLayer.lua


local funLevelConst = require("app.const.FunctionLevelConst")
require("app.cfg.knight_info")
require("app.cfg.association_info")
local knightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"

local PartnerLayer = class("PartnerLayer", UFCCSNormalLayer)


function PartnerLayer:ctor( json, isToFriendLayer,... )
	self._knightPanel = {}
	self._totalYuanfen = -1
	self._knightCount = 0
	self._mainKnightBaseId = {}
	self._isShowList = false
	self._showZhuwei = false
	self._isToFriendLayer = isToFriendLayer

	self.super.ctor(self, ...)
end

function PartnerLayer:onLayerLoad( ... )
	

	table.insert(self._knightPanel, #self._knightPanel + 1, self:getWidgetByName("Panel_knight_1"))
	table.insert(self._knightPanel, #self._knightPanel + 1, self:getWidgetByName("Panel_knight_2"))
	table.insert(self._knightPanel, #self._knightPanel + 1, self:getWidgetByName("Panel_knight_3"))
	table.insert(self._knightPanel, #self._knightPanel + 1, self:getWidgetByName("Panel_knight_4"))
	table.insert(self._knightPanel, #self._knightPanel + 1, self:getWidgetByName("Panel_knight_5"))
	table.insert(self._knightPanel, #self._knightPanel + 1, self:getWidgetByName("Panel_knight_6"))

	for index = 1, 6, 1 do 
		self:enableLabelStroke("Label_name_"..index, Colors.strokeBrown, 1 )
		self:enableLabelStroke("Label_jingjie_"..index, Colors.strokeBrown, 1 )
		self:enableLabelStroke("Label_yuanfen_"..index, Colors.strokeBrown, 1 )
		self:enableLabelStroke("Label_knight_name_"..index, Colors.strokeBrown, 1 )
		self:enableLabelStroke("Label_unlock_level_"..index, Colors.strokeBrown, 1 )

		self:registerBtnClickEvent("Button_p"..index, function ( widget )
			self:_onKnightClick(index)
		end)
	end

	self:enableLabelStroke("Label_bottom_tip_2", Colors.strokeBrown, 1 )
	local createStoke = function ( name )
		local label = self:getLabelByName(name)
		if label then 
			label:createStroke(Colors.strokeBrown, 1)
		end
	end
	createStoke("Label_yf_name_1")
	createStoke("Label_yf_name_2")
	createStoke("Label_yf_name_3")
	createStoke("Label_yf_name_4")
	createStoke("Label_yf_name_5")
	createStoke("Label_yf_name_6")
	createStoke("Label_bottom_tip_1")
	createStoke("Label_bottom_tip_3")

	self:registerBtnClickEvent("Button_effect", function ( widget )
		self:_showYuanfenList( true )
	end)
	self:registerBtnClickEvent("Button_back", function ( widget )
		self:_showYuanfenList( false )
	end)
	self:registerWidgetClickEvent("Panel_zuwei", function ( widget )
		if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.KNIGHT_FRIEND_ZHUWEI) then
			self:showZhuWei(true,0)
		end
	end)
	self:_showYuanfenList(false)

	local effect  = EffectNode.new("effect_zhangu")
	effect:play()
	effect:setPositionXY(40,40)
	effect:setScale(0.8)
	self:getPanelByName("Panel_zuwei"):addNode(effect)
end

function PartnerLayer:onLayerTurn( ... )
	self:_loadKnightYuanfen()
end

function PartnerLayer:onLayerEnter( ... )
	self:_loadKnightBtns()
	self:_loadKnightYuanfen()

	if G_moduleUnlock:isModuleUnlock(funLevelConst.KNIGHT_FRIEND_ZHUWEI) and not self._zhuweiLayer then
		self:getPanelByName("Panel_friend"):setVisible(false)
		self._zhuweiLayer = require("app.scenes.hero.HeroFriendLayer").create(self,offset)
		self._zhuweiLayer:updateView()
		self:getPanelByName("Panel_friend"):addNode(self._zhuweiLayer)
		self._zhuweiLayer:updateView()
	end

	self:getPanelByName("Panel_zuwei"):setVisible(not self._showZhuwei and G_moduleUnlock:canPreviewModule(funLevelConst.KNIGHT_FRIEND_ZHUWEI))
	self:_checkNewAssociation(0)
	
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_FORMATION, self._onChangeFormation, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FORMATION_UPDATE, self._onFormationUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_TEAM_FORMATION, self._onChangeTeamFormation, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ADD_TEAM_KNIGHT, self._onAddTeamKnight, self)

	if self._isToFriendLayer then
		self:showZhuWei(true, 0)
		self._isToFriendLayer = false
	end
end

function PartnerLayer:_onFormationUpdate( teamId )
	teamId = teamId or 0
	if teamId ~= 2 then 

	end
end

function PartnerLayer:showZhuWei(state, offset )
	self._showZhuwei = state
	self:getPanelByName("Panel_left"):setVisible(not state)
	self:getPanelByName("Panel_right"):setVisible(not state)
	self:getPanelByName("Panel_middle"):setVisible(not state)
	self:getPanelByName("Panel_zuwei"):setVisible(not state)
	if state then
		if self._zhuweiLayer then
			self:getPanelByName("Panel_friend"):setVisible(true)
		else
			self._zhuweiLayer = require("app.scenes.hero.HeroFriendLayer").create(self,offset)
			self:getPanelByName("Panel_friend"):addNode(self._zhuweiLayer)
			self:getPanelByName("Panel_friend"):setVisible(true)
		end
		self._zhuweiLayer:updateView()
	else
		self:getPanelByName("Panel_friend"):setVisible(false)
	end
end

function PartnerLayer:_onChangeFormation( ret )
	if ret ~= NetMsg_ERROR.RET_OK then
		return 
	end

	self:_loadKnightYuanfen()
end

function PartnerLayer:_onChangeTeamFormation( ret, teamId, pos, oldKnightId, newKnightId )
	if ret ~= NetMsg_ERROR.RET_OK then
		return 
	end

	self:_loadKnightYuanfen()
	if teamId == 1 then 
		self:_doLoadMainKnightTeam(pos)
	else
		self:_doLoadKnight(newKnightId, pos)
		self:_checkNewAssociation(newKnightId)
	end
end

function PartnerLayer:_onAddTeamKnight( ret, knightId, pos )
	self:_onChangeTeamFormation(ret, pos > 6 and 2 or 1, pos > 6 and (pos - 6) or pos, -1, knightId)
end

function PartnerLayer:_checkNewAssociation( knightId )
	if not knightId or knightId < 1 then 
		if self._zhuweiLayer then
			local has = self._zhuweiLayer:addFlyAttributes()
			if has then
				G_flyAttribute.play(function ( ... )
					if G_SceneObserver:getSceneName() ~= "HeroScene" then
					    return
					end
					self._zhuweiLayer:updateView()
				end)
			else
				self._zhuweiLayer:updateView()
			end
		end
		return 
	end

	--__Log("knightId:%d", knightId)
	local activeAssociton = G_Me.bagData.knightsData:calcJiPanByNewKnight(knightId) or {}
--	dump(activeAssociton)
	if #activeAssociton > 0 then 
		local findKnightAssociation = function ( baseId )
			if not baseId then 
				return nil
			end

			for key, value in pairs(self._mainKnightBaseId) do 
				if value == baseId then 
					return self:getLabelByName("Label_yuanfen_"..key)
				end
			end

			return nil
		end
		for key, value in pairs(activeAssociton) do 
			if type(value) == "table" then 
				local association = findKnightAssociation(value[1])
				if association then 
					value[3] = association
				else
					value[1] = 0
					value[2] = 0
				end
			end
		end
	end

--dump(activeAssociton)
	local has1 = false
	local has2 = false
	if #activeAssociton > 0 then 
		if self._isShowList then 
			self:_showYuanfenList(not self._isShowList)
		end
		G_flyAttribute.addAssocitionChange(activeAssociton)
		has1 = true
		-- G_flyAttribute.play(function ( ... )

		-- end)
	end

	--援军助威的属性加成提示
	if self._zhuweiLayer then
		has2 = self._zhuweiLayer:addFlyAttributes()
	end

	if has1 or has2 then
		G_flyAttribute.play(function ( ... )
			if has2 then
				if G_SceneObserver:getSceneName() ~= "HeroScene" then
				    return
				end
				self._zhuweiLayer:updateView()
			end
		end)
	else
		if self._zhuweiLayer then
			self._zhuweiLayer:updateView()
		end
	end
end

function PartnerLayer:_doLoadKnight( knightId, index )
	local twinkleIcon = function( icon )
        if not icon then
            return
        end

        icon:stopAllActions()

        if icon  then
            local fadeInAction = CCFadeIn:create(0.5)
            local fadeOutAction = CCFadeOut:create(0.5)
            local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
            seqAction = CCRepeatForever:create(seqAction)
            icon:runAction(seqAction)
        end
    end

	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId) 		
	local knightInfo = knight_info.get(baseId or 0)
    local resId = knightInfo and knightInfo.res_id or 0

    local heroImage = self:getImageViewByName("Image_knight_"..index )
    if heroImage then
    	heroImage:stopAllActions()
    	if knightInfo and knightInfo.res_id > 0 then 
    		heroImage:setOpacity(255)
        	heroImage:loadTexture(G_Path.getKnightIcon(resId), UI_TEX_TYPE_LOCAL)        	
        else
        	heroImage:loadTexture(G_Path.getAddKnightIcon())
        	twinkleIcon(heroImage)
        end
    end

    local pingji = self:getImageViewByName("Image_pingji_"..index)
    if pingji then
    	pingji:setVisible( knightInfo ~= nil )
    	if knightInfo then 
        	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo.quality))
    	end
    end

    local nameLabel = self:getLabelByName("Label_knight_name_"..index)
    if nameLabel then     	
    	if knightInfo then 
        	nameLabel:setColor(Colors.getColor(knightInfo.quality))
    		nameLabel:setText(knightInfo.name)
    	end
    	nameLabel:setVisible( knightInfo ~= nil )
    end

    self:showWidgetByName("Image_lock_"..index, false)
    self:enableWidgetByName("Button_p"..index, true)
end

function PartnerLayer:_lockKnight( index, openLevel )
	self:showWidgetByName("Image_lock_"..index, true)
	self:showWidgetByName("Label_knight_name_"..index, false)
	self:showWidgetByName("Image_pingji_"..index, false)
	self:showWidgetByName("Image_knight_"..index, false)

	openLevel = openLevel or 0
	self:showTextWithLabel("Label_unlock_level_"..index, ""..openLevel)

	self:enableWidgetByName("Button_p"..index, false)
end

function PartnerLayer:_loadKnightBtns( ... )
	local maxPartner = G_Me.userData:getMaxPartnerSlot() or 0
	if maxPartner > 0 then 
		for loopi = 1, maxPartner, 1 do
			local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(2, loopi)
			self:_doLoadKnight(knightId, loopi)
		end
	end

	for index = maxPartner + 1, 6, 1 do 
		self:_lockKnight(index, G_moduleUnlock:getModuleUnlockLevel(funLevelConst.PARTNER_ARRAY_1 + index - 1))
	end	
end

function PartnerLayer:_doLoadMainKnightTeam( index )
	if not index then 
		return 
	end

	self._mainKnightBaseId[index] = nil
	local formationIndex, knightId = G_Me.formationData:getFormationIndexAndKnighId(1, index)
		if formationIndex ~= 0 and knightId ~= 0 then

			if self._knightPanel and self._knightPanel[index] then
				self._knightPanel[index]:removeAllChildren()
				self._knightPanel[index]:removeAllNodes()

				local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId) 		
				local knightBaseInfo = knight_info.get(knightInfo and knightInfo.base_id or 0)
    			local resId = knightBaseInfo and knightBaseInfo.res_id or 0
    			if knightBaseInfo and resId > 0 then 
    				self._mainKnightBaseId[index] = knightBaseInfo.id
    				-- local cardJson = decodeJsonFile(G_Path.getBattleConfig("knight", resId.."_fight"))
    				-- local cardSprite = CCSprite:create(G_Path.getBattleConfigImage("knight", resId..".png"))
    				-- self._knightPanel[index]:addNode(cardSprite)
    				-- self._knightPanel[index]:setScale(0.6)
    				-- cardSprite:setScaleX(cardJson.scaleX)
    				-- cardSprite:setScaleY(cardJson.scaleY)
    				-- cardSprite:setPosition(ccp(cardJson.x, cardJson.y))
    				knightPic.createKnightPic(resId, self._knightPanel[index])
    				self._knightPanel[index]:setScale(0.25)

    				local nameLabel = self:getLabelByName("Label_name_"..index)
    				if nameLabel then 
    					nameLabel:setColor(Colors.getColor(knightBaseInfo.quality))
    					nameLabel:setText(knightBaseInfo.name)
    				end
    				
    				self:showTextWithLabel("Label_yuanfen_"..index, ""..(#knightInfo.association))
    				self._totalYuanfen = self._totalYuanfen + #knightInfo.association

    				local jingjieLabel = self:getLabelByName("Label_jingjie_"..index)
    				if jingjieLabel then 
    					jingjieLabel:setColor(Colors.getColor(knightBaseInfo.quality))
    					jingjieLabel:setText("+"..knightBaseInfo.advanced_level)
    				end
    			end
    			self:showWidgetByName("Panel_"..index, knightBaseInfo and resId > 0)
    		end
    	else
    		self:showWidgetByName("Panel_"..index, false)
    	end
end

function PartnerLayer:_loadKnightYuanfen( ... )
	self._mainKnightBaseId  = {}
	local index = 0
	local curYuanfen = self._totalYuanfen
	self._totalYuanfen = 0
	while index <= 6 do 
		self:_doLoadMainKnightTeam(index)
    	index = index + 1
	end

	self:showTextWithLabel("Label_bottom_tip_2", ""..self._totalYuanfen)
	self:_loadYuanfenList()
end

function PartnerLayer:_onKnightClick( index )
	if not index or index < 1 or index > 6 then 
		return 
	end

	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(2, index)
	if knightId < 1 or baseId < 1 then 
		if not G_Me.formationData:isFirstTeamFull() then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_FIRST_TEAM_NOT_FULL"))
		end
    	local team1Knight, team1Count = G_Me.formationData:getFirstTeamKnightIds()
    	local team2Knight, team2Count = G_Me.formationData:getSecondTeamKnightIds()
    	if team1Count + team2Count >= G_Me.bagData.knightsData:getKnightCount() then
    		G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
    	else
    	    local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")
        	heroSelectLayer.showHeroSelectLayer(uf_sceneManager:getCurScene(), index + 6, function ( knightId, effectWaitCallback )
                self.__EFFECT_FINISH_CALLBACK__ = effectWaitCallback
       		    if not G_Me.formationData:isKnightValidjForCurrentTeam(2, knightId, index) then
               	   G_MovingTip:showMovingTip(G_lang:get("LANG_SAME_KNIGHT"))
               	   return 
           	    end

           	    G_HandlersManager.cardHandler:changeTeamFormation(2, index, knightId)
       		    --G_HandlersManager.cardHandler:addTeamKnight(knightId)
       	    end)
   	   end
	else
		local heroDesc = require("app.scenes.hero.HeroDescLayer")
		heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), knightId, true, false, 2, index + 6)
   	end
end

function PartnerLayer:_showYuanfenList( showYuanfen )
	showYuanfen = showYuanfen or false
	self._isShowList = showYuanfen

	self:showWidgetByName("Panel_knights", not showYuanfen)
	self:showWidgetByName("Image_title", not showYuanfen)
	self:showWidgetByName("Panel_knight_effect", showYuanfen)

	if not showYuanfen then 
		local yuanfenList = self:getScrollViewByName("ScrollView_yuanfen")
		if yuanfenList then 
			yuanfenList:jumpToTop()
		end
	end
end

function PartnerLayer:_loadYuanfenList( reload )
	local yuanfenList = self:getScrollViewByName("ScrollView_yuanfen")
	if not yuanfenList then 
		return 
	end

	yuanfenList:removeAllChildren()
	local scrollSize = yuanfenList:getSize()
	local topPt = ccp(scrollSize.width/2, scrollSize.height - 10)
	local leftEdge = 10
	local associationEdge = 5
	local associationSpace = 5
	local nameSpace = 15

	local addKnightName = function ( scrollView, name, quality, centerX, topY )
		if not scrollView then 
			return topY
		end

		local back = ImageView:create()
		back:loadTexture(G_Path.getKnightNameBack())
		local nameLabel = GlobalFunc.createGameLabel(name, 24, Colors.getColor(quality or 1), Colors.strokeBrown)
		back:addChild(nameLabel)
		nameLabel:setPosition(ccp(0, 6))
		scrollView:addChild(back)
		local size = back:getSize()
		back:setPosition(ccp(centerX, topY + size.height/2))
		topY = topY + size.height + nameSpace

		return topY
	end

	local addJipanContent = function ( scrollView, associationId, isActive, width, topY )
		if not scrollView then 
			return topY
		end

		local associationInfo = association_info.get(associationId)
		if associationInfo == nil then
			return topY
		end

		local nameLabel = GlobalFunc.createGameLabel(associationInfo.name, 22, 
			isActive and Colors.activeSkill or Colors.inActiveSkill, nil )
		scrollView:addChild(nameLabel)
		local nameSize = nameLabel:getSize()

		local descLabel = GlobalFunc.createGameLabel(associationInfo.directions, 22, 
			isActive and Colors.activeSkill or Colors.inActiveSkill, nil, CCSizeMake(width - nameSize.width - 10, 0), true)
		scrollView:addChild(descLabel)
		local descSize = descLabel:getSize()

		descLabel:setPosition(ccp(nameSize.width + leftEdge + associationEdge + descSize.width/2, topY + descSize.height/2))
		topY = descSize.height > nameSize.height and (topY + descSize.height) or (topY + nameSize.height)

		nameLabel:setPosition(ccp(nameSize.width/2 + leftEdge, topY - nameSize.height/2))

		topY = topY + associationSpace

		return topY
	end

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

	local topY = 5
	for loopi = 6, 1, -1 do
		local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, loopi)
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId) 		
		local knightBaseInfo = knight_info.get(knightInfo and knightInfo.base_id or 0)

		local curTop = topY
		if knightBaseInfo and knightInfo then 
			if knightBaseInfo.association_12 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_12) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_12, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_11 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_11) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_11, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_10 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_10) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_10, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_9 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_9) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_9, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_8 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_8) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_8, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_7 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_7) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_7, false, scrollSize.width, topY)
			end		

			if knightBaseInfo.association_6 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_6) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_6, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_5 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_5) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_5, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_4 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_4) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_4, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_3 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_3) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_3, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_2 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_2) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_2, false, scrollSize.width, topY)
			end
			if knightBaseInfo.association_1 > 0 and not findIdInTable(knightInfo.association, knightBaseInfo.association_1) then
				topY = addJipanContent(yuanfenList, knightBaseInfo.association_1, false, scrollSize.width, topY)
			end		

			for key, value in pairs(knightInfo.association) do 
				topY = addJipanContent(yuanfenList, value, true, scrollSize.width, topY)
			end	

			if topY ~= curTop then
				topY = addKnightName(yuanfenList, knightBaseInfo.name, knightBaseInfo.quality, topPt.x, topY)
			end
		end
	end

	yuanfenList:setInnerContainerSize(CCSizeMake(scrollSize.width, topY))
	--yuanfenList:getInnerContainer():setPosition(ccp(0, 0))
	yuanfenList:jumpToTop()
end

return PartnerLayer
