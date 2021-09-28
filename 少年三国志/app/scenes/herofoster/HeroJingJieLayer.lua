--HeroJingJieLayer.lua

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local KnightConst = require("app.const.KnightConst")
local KnightPic = require "app.scenes.common.KnightPic"
local JumpCard = require "app.scenes.common.JumpCard"

local HeroJingJieLayer = class ("HeroJingJieLayer", UFCCSNormalLayer)


function HeroJingJieLayer:ctor( ... )
	self._costInfo = nil
	self._mainKnightLevel = 1
	self._mainBaseInfo = nil
	self._advancedBaseInfo = nil
	self._mainKnightId = 0
	self._costKnightList = {}
	--self._allCostKnightList = {}
	self._selectKnight = {}
	self._isWaiting = false

	self._knightCostId = 0
	self._knightCostCount = 0
	self._itemCostId = 0
	self._itemCostCount = 0

	self._knightBefore = nil
	self._knightAfter = nil


	self.super.ctor(self, ...)
end


function HeroJingJieLayer:onLayerLoad( jsonFile, knightId, ... )
	self._mainKnightId = knightId
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_ADVANCED_KNIGHT, self._onReceiveAdvancedRet, self)

	self:enableLabelStroke("Label_name_before", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_name_after", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_jingjie_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attack_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_hp_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_hp_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attack_value_1", Colors.strokeBrown, 1 )
    --self:enableLabelStroke("Label_cost_yinbi_value", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_count_2", Colors.strokeBrown, 1 )
     self:enableLabelStroke("Label_name_2", Colors.strokeBrown, 1 )
     self:enableLabelStroke("Label_name_1", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_count_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_tianfu_unlock", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_tianfu_content", Colors.strokeBrown, 1 )
    --self:enableLabelStroke("Label_cost_tip", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_cur_attri", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_next_attri", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_cost_title", Colors.strokeBrown, 2 )

    local createStroke = function ( name )
        local label = self:getLabelByName(name)
        if label then 
            label:createStroke(Colors.strokeBrown, 1)
        end
    end
    createStroke("Label_attack")
    createStroke("Label_hp")
    createStroke("Label_defense_p")
    createStroke("Label_defense_m")
    createStroke("Label_hp_1")
    createStroke("Label_defense_p_1")
    createStroke("Label_attack_1")
    createStroke("Label_defense_m_1")

	self:registerBtnClickEvent("Button_shengjie", function ( widget )
		self:_doShengJie()
	end)

	self:registerBtnClickEvent("Button_cost_1", function ( widget )
		self:_onKnightItemClick( widget )
	end)
	self:registerBtnClickEvent("Button_cost_2", function ( widget )		
		self:_onCostItemClick( widget )
	end)
	

	--self:callAfterFrameCount(2, function (  )
	--	self:_initKnightLine()
	--end)

	-- local vipLevel = G_Me.userData.vip 
	-- if vipLevel < 2 then 
	-- 	self:showTextWithLabel("Label_cost_tip", G_lang:get("LANG_JINGJIE_YINGBI_COST_TIP_VIP2"))
	-- elseif vipLevel >= 5 then 
	-- 	self:showTextWithLabel("Label_cost_tip", "")
	-- else
	-- 	self:showTextWithLabel("Label_cost_tip", G_lang:get("LANG_JINGJIE_YINGBI_COST_TIP_VIP5"))
	-- end
              
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local EffectNode = require("app.common.effects.EffectNode")
		local effect  = EffectNode.new("effect_jinjiechangjing")
    	effect:play()
    	local left = self:getWidgetByName("ImageView_4674")
    	if left then 
    		left:addNode(effect)
    	end
    end  
end
function HeroJingJieLayer:onLayerUnload(  )
	uf_eventManager:removeListenerWithTarget(self)

	
end

function HeroJingJieLayer:onLayerEnter( ... )
	self:_updateJineJieKnight( self._mainKnightId )
        

	self:showWidgetByName("ImageView_arrow_gray", false)
	self:showWidgetByName("Panel_after", false)
	self:showWidgetByName("Panel_back_after", false)
	local tianfu = self:getWidgetByName("Image_tianfu_back")
	local tianfuVisible = tianfu:isVisible()
	self:showWidgetByName("Image_tianfu_back", false)
	self:showWidgetByName("Panel_baseinfo", false)
	--self:showWidgetByName("Panel_costinfo", false)
	self:callAfterFrameCount(1, function ( ... )
		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_before"), self:getWidgetByName("Panel_back_before")}, true, 0.2, 2, 0, function ( ... )
			self:showWidgetByName("ImageView_arrow_gray", true)
			self:showWidgetByName("Panel_after", true)
			self:showWidgetByName("Panel_back_after", true)
			--self:showWidgetByName("Panel_costinfo", true)
			GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_after"), self:getWidgetByName("Panel_back_after")}, false, 0.2, 2, 0, function ( ... )
				self:showWidgetByName("Image_tianfu_back", tianfuVisible)
			end)
			--GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_costinfo")}, false, 0.2, 2, 0, function ( ... )
			--end)

			self:showWidgetByName("Panel_baseinfo", true)
			GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_left")}, true, 0.2, 2, 50, function ( ... )
				
			end)
			GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_right")}, false, 0.2, 2, 50, function ( ... )
			end)
		end)


	end)
	self:callAfterFrameCount(1, function ( ... )
		local widget = self:getWidgetByName("Panel_knight")
		if widget then 
			local posx, posy = widget:getPosition()
			widget:setPositionXY(posx + 20, posy)
		end
	end)
end

function HeroJingJieLayer:onLayerExit( ... )
	if self._jumpCardNode ~= nil then 
		self._jumpCardNode:removeFromParentAndCleanup(true)
		self._jumpCardNode = nil
	end
end

function HeroJingJieLayer:_updateJineJieKnight( knightId )
	self._mainKnightId = knightId

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if knightInfo ~= nil then
		self._mainKnightLevel = knightInfo["level"]
		require("app.cfg.knight_advance_info")
		local baseId = knightInfo["base_id"] or 0
		local resId = 1
		local knightBaseInfo = knight_info.get(baseId)
		if knightBaseInfo then
			-- local __id = 0
			 local mainKnightId = G_Me.formationData:getMainKnightId()
			-- local knightType = (mainKnightId == knightId) and 1 or 2
			-- for i=1,knight_advance_info.getLength() do
			-- 	local __advanceInfo = knight_advance_info.indexOf(i)
			-- 	if __advanceInfo.advanced_level == knightBaseInfo.advanced_level and knightType == __advanceInfo.knight_type then
			-- 		__id = i
			-- 	end
			-- end
			-- self._costInfo = knight_advance_info.get(knightBaseInfo.advanced_level)
			self._costInfo = knight_advance_info.get(knightBaseInfo.type, knightBaseInfo.advanced_level)
			self._mainBaseInfo = knightBaseInfo

			local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
			local secondTeam = G_Me.formationData:getSecondTeamKnightIds()
			local exceptArr = {}
			if firstTeam then
				table.foreach(firstTeam, function ( i , value )
					if value > 0 then
						exceptArr[value] = 1
					end
				end)
			end
			if secondTeam then
				table.foreach(secondTeam, function ( i , value )
					if value > 0 then
						exceptArr[value] = 1
					end
				end)
			end
			exceptArr[self._mainKnightId] = 1
			local tempArr = {}
			tempArr[self._mainKnightId] = 1
			local costKnightCount = 1
			-- 根据武将材料值计算当前可用做材料武将的列�?
			if self._costInfo.cost1_type == 1 then
				costKnightCount = self._costInfo.cost1_num
				self._costKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, exceptArr)
				--self._allCostKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, tempArr)
			elseif self._costInfo.cost2_type == 1 then
				costKnightCount = self._costInfo.cost2_num
				self._costKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, exceptArr)
				--self._allCostKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, tempArr)
			elseif self._costInfo.cost3_type == 1 then
				costKnightCount = self._costInfo.cost3_num
				self._costKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, exceptArr)
				--self._allCostKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, tempArr)
			elseif self._costInfo.cost4_type == 1 then
				costKnightCount = self._costInfo.cost4_num
				self._costKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, exceptArr)
				--self._allCostKnightList = G_Me.bagData.knightsData:getCostKnight(self._mainBaseInfo.advance_code, tempArr)
			end

			--dump(self._mainKnightId)
			--dump(self._costKnightList)
			--dump(self._allCostKnightList)
			local sortFun = function ( indexA, indexB )  
				local a = G_Me.bagData.knightsData:getKnightByKnightId(indexA)
        		local b = G_Me.bagData.knightsData:getKnightByKnightId(indexB)
        		if not a then 
        		    __LogError("a wrong knigh info for knightId:%d", indexA or 0)
        		    return false
        		end
        		if not b then 
        		    __LogError("b wrong knigh info for knightId:%d", indexB or 0)
        		    return true
        		end

        		local kniA = knight_info.get(a.base_id)
        		local kniB = knight_info.get(b.base_id)
        		if not kniA then 
        		    __LogError("a wrong knigh info for baseid:%d", a.base_id)
        		end
        		if not kniB then 
        		    __LogError("b wrong knigh info for baseid:%d", b.base_id)
        		end

        		if kniA.advanced_level ~= kniB.advanced_level then 
        			return kniA.advanced_level < kniB.advanced_level 
        		end

        		if a.halo_level ~= b.halo_level then 
        			return a.halo_level < b.halo_level
        		end

        		if a.level ~= b.level then 
        			return a.level < b.level
        		end

        		return kniA.id < kniB.id
        	end
        	table.sort(self._costKnightList, sortFun )
			
			local loopi = 1
			self._selectKnight = {}
			while loopi <= costKnightCount do 
				table.insert(self._selectKnight, #self._selectKnight + 1, self._costKnightList[loopi])
				loopi = loopi + 1
			end

			self:_initBaseInfo( knightId, knightInfo, knightBaseInfo )
			self:_initCostInfo( knightId, knightInfo, knightBaseInfo )

			self._advancedBaseInfo = G_Me.bagData.knightsData:getJineJieResultKnightInfo(knightBaseInfo.id)

			self:_initAdvancedKnightInfo( knightInfo, self._advancedBaseInfo )
			self:_updateTianfuUnlock(knightBaseInfo, self._advancedBaseInfo)
		else
			self:_initBaseInfo( knightId, knightInfo, nil )
			self:_initCostInfo( knightId, knightInfo, nil )
			self:_initAdvancedKnightInfo( knightInfo, nil )
			self:_updateTianfuUnlock(nil, nil)
		end
	else
		self:_initBaseInfo( knightId, nil, nil )
		self:_initCostInfo( knightId, nil, nil )
		self:_initAdvancedKnightInfo( nil, nil )
		self:_updateTianfuUnlock(nil, nil)
	end
        
        -- level_limit
        require("app.cfg.knight_advance_info")

        -- local __id = nil
        -- for i=1,knight_advance_info.getLength() do
        --     local __advanceInfo = knight_advance_info.indexOf(i)
        --     if __advanceInfo.advanced_level == self._mainBaseInfo.advanced_level and self._mainBaseInfo.type == __advanceInfo.knight_type then
        --         __id = i
        --     end
        -- end
        
        local _level = self._mainKnightLevel
        local _total = knight_advance_info.get(self._mainBaseInfo.type, self._mainBaseInfo.advanced_level).level_ban
        local _color = _level >= _total and ccc3(0x99, 0xff, 0x33) or Colors.titleGreen
        
        local needLevelLable = self:getLabelByName('Label_level_need')
        local limitLevelLable = self:getLabelByName('Label_level_limit')

        if limitLevelLable then 
            if _total == 0 then
                limitLevelLable:setVisible(false)
                needLevelLable:setVisible(false)
            else
                limitLevelLable:setVisible(true)
                needLevelLable:setVisible(true)                
                limitLevelLable:setText(G_lang:get('LANG_KNIGHT_JINGJIE_TIP_MAX_LEVLE_LIMIT_DESC', {level = _level, total = _total}))
                limitLevelLable:setColor(_color)
                limitLevelLable:createStroke(Colors.strokeBrown, 1)
                needLevelLable:createStroke(Colors.strokeBrown, 1)
            end
        end
        
end

function HeroJingJieLayer:_brighterKnightLine( brighter )
	local line = self:getWidgetByName("ImageView_arrow")
	if not line then
		return 
	end
	brighter = brighter or false
	line:setVisible(brighter)

	if brighter then
		line:stopAllActions()
		line:setScaleX(0.1)

		local scale = CCScaleTo:create(1, 1, 1)
		scale = CCEaseIn:create(scale, 1)
		local arr = CCArray:create()
		arr:addObject(scale)
		arr:addObject(CCCallFunc:create(function (  )
			line:setScale(0.1)
		end))
		local seqAction = CCSequence:create(arr)
		local repeatAction = CCRepeatForever:create(seqAction)
		line:runAction(repeatAction)
	else
		line:stopAllActions()
	end
end

function HeroJingJieLayer:_onReceiveAdvancedRet( ret, newKnightId )
	if ret == NetMsg_ERROR.RET_OK then

		-- local baseId = 0
		-- if self._mainBaseInfo then  
		-- 	baseId = self._mainBaseInfo.id
		-- end
		-- if baseId == 0 then 
		-- 	return 
		-- end
		__Log("newKnightId:%d", newKnightId and newKnightId or 0)
		local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(newKnightId or 0)
		
		self:_doPlayAnimation(baseId, function ( ... )
			self._isWaiting = false
			self:_updateJineJieKnight(newKnightId or 0)
			if self.__EFFECT_FINISH_CALLBACK__ then 
				self.__EFFECT_FINISH_CALLBACK__()
			end
		end)

		-- G_playAttribute.playTextArray({G_lang:get("LANG_KNIGHT_JINGJIE_TIP_SUCCESS")}, 0, function ( ... )
		-- 	if self.__EFFECT_FINISH_CALLBACK__ then 
		-- 		self.__EFFECT_FINISH_CALLBACK__()
		-- 	end
		-- end)

		
		--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_SUCCESS"))
	else
		self._isWaiting = false
	end
end

function HeroJingJieLayer:_doPlayAnimation( newKnightId, func )
	newKnightId = newKnightId or 0
	if newKnightId == 0 then 
		return 
	end

	local panelBefore = self:getWidgetByName("Panel_icon_before")
	local panelAfter = self:getWidgetByName("Panel_icon_after")
	if not panelBefore or not panelAfter then 
		return 
	end

	local scaleValue = 0.5
	if panelBefore then 
		scaleValue = panelBefore:getScale()
	end

    local effect = nil
    effect = EffectNode.new("effect_jingjie", 
        function(event)

            if event == "finish" then
                effect:removeFromParentAndCleanup(true)
            elseif event == "hide_left" then
                --慢慢隐藏左边的武�?
                transition.fadeTo(self._knightBefore, {time=0.2,opacity=0})    

                local soundConst = require("app.const.SoundConst")               
    			G_SoundManager:playSound(soundConst.GameSound.KNIGHT_EAT_MATERIAL)
    			__Log("play finish")
            elseif event == "show_right" then
                --慢慢显示右边的武�?
                transition.fadeTo(self._knightAfter,  {time=0.2,opacity=255})  
            elseif event == "fullscreen" then
                --全屏显示
                --knightId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback
                local waitfunc = function() 
                	local HeroJingJieResult = require("app.scenes.herofoster.HeroJingJieResult")
                	if self._mainBaseInfo and self._advancedBaseInfo then 
                		HeroJingJieResult.showHeroJingJieResult(self, self._mainBaseInfo.id, 
                			self._advancedBaseInfo.id, 
                			self._mainKnightLevel, 
                			function ( ... )
                				if self._jumpCardNode then
                					self._jumpCardNode:resume()
                				end
                		end)
                	else
                		if self._jumpCardNode then
                    		self._jumpCardNode:resume()
                    	end
                	end
                    --这个时候可以顺便删掉右边那个武�? 免得待会播放跳跃回来的时候还看得到右边那个武�?
                    self._knightAfter:removeFromParentAndCleanup(true)
                end

                local endfunc = function() 
                    --动画结束�? 清理一�?
                    if self._jumpCardNode then
                    	self._jumpCardNode:removeFromParentAndCleanup(true)    
                    	self._jumpCardNode = nil               
                    end
                    self._knightBefore:removeFromParentAndCleanup(true)
                    ---重新创建个pic放到pic1的位�?
                    --self._pic1 = KnightPic.createKnightNode(res_id)
                    --self._pic1:setPosition(150, 400)
                    --self._pic1:setScale(0.5)
                    --self._pic1:setCascadeOpacityEnabled(true)
                    --self:addChild(self._pic1)

                    if func then 
                    	func()
                    end
                end

                self._jumpCardNode = JumpCard.create(newKnightId, ccp(panelAfter:convertToWorldSpaceXY(0, 0)),
                 ccp(panelBefore:convertToWorldSpaceXY(0, 0)), scaleValue, waitfunc, endfunc)
                uf_notifyLayer:getModelNode():addChild(self._jumpCardNode)
            end
        end
    )
    
    local localPosx, localPosy = panelBefore:convertToWorldSpaceXY(0, 0)
    localPosx, localPosy = self:convertToNodeSpaceXY(localPosx, localPosy)
    effect:setPositionXY( localPosx, localPosy )
    self:addChild(effect)
    effect:play()
end

function HeroJingJieLayer:_doShengJie(  )
	if self._isWaiting then 
		return 
	end
        
        require("app.cfg.knight_advance_info")

        -- local __id = nil
        -- for i=1,knight_advance_info.getLength() do
        --     local __advanceInfo = knight_advance_info.indexOf(i)
        --     if __advanceInfo.advanced_level == self._mainBaseInfo.advanced_level and self._mainBaseInfo.type == __advanceInfo.knight_type then
        --         __id = i
        --     end
        -- end

        if knight_advance_info.get(self._mainBaseInfo.type, self._mainBaseInfo.advanced_level).level_ban > self._mainKnightLevel then
            return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_MAX_LEVLE_LIMIT"))
        end
        
	if not self._advancedBaseInfo then
		if self._mainBaseInfo and self._mainBaseInfo.advanced_level >= 15 then
			return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_MAX_JIESHU"))
		else
			return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_ERROR_CONFIG"))
		end
	end
	
	local checkCostEnough = function ( costType, costCount, costValue )
		if not costType or costType == 0 then 
			return true
		end

		local ret = false
		if costType == 1 then 
			ret = #self._costKnightList >= costCount
			if not ret then
				local knightBaseInfo = knight_info.get(self._knightCostId)
				if knightBaseInfo then
					require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, knightBaseInfo.id,
					GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId}))
				end
				--self:_onKnightItemClick()
				--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_KNIGHT_RES"))
			end
		elseif costType == 2 then
			ret = G_Me.bagData:hasEnoughProp( costValue, costCount )
			if not ret then
				self:_onCostItemClick()
				--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_JINGJIEDAN"))
			end
		end

		return ret
	end

	local ret = true
	if self._costInfo then
		if self._costInfo.cost_money > G_Me.userData.money then
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId}))
			--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_MONEY"))
			ret = false
		end
		ret = ret and checkCostEnough(self._costInfo.cost1_type, self._costInfo.cost1_num, self._costInfo.cost1_value)
		ret = ret and checkCostEnough(self._costInfo.cost2_type, self._costInfo.cost2_num, self._costInfo.cost2_value)
		ret = ret and checkCostEnough(self._costInfo.cost3_type, self._costInfo.cost3_num, self._costInfo.cost3_value)
		ret = ret and checkCostEnough(self._costInfo.cost4_type, self._costInfo.cost4_num, self._costInfo.cost4_value)
	end

	if ret then
		self:_checkKnightMaterialValid(function ( ... )
			self._isWaiting = true
			G_HandlersManager.heroUpgradeHandler:sendAdvancedKnight(self._mainKnightId, self._selectKnight)	
		end)
	end
end

-- 当材料武将中有升级过的或光环级别不为1的，则需要弹出提示框供选择
function HeroJingJieLayer:_checkKnightMaterialValid( fun )
	local _callback = function ( ... )
		if fun then 
			fun()
		end
	end
	if not self._costInfo or not self._selectKnight or #self._selectKnight < 1 then 
		return _callback()
	end

	local flag = false
	for key, value in pairs(self._selectKnight) do
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
		if knightInfo and (not flag) then 
			if (knightInfo.halo_level > 1) or (knightInfo.level > 1) then 
				flag = true
			else
				local baseInfo = knight_info.get(knightInfo.base_id)
				if baseInfo and baseInfo.advanced_level > 1 then 
					flag = true
				end
			end
		end
	end

	if flag then 
		require("app.scenes.herofoster.HeroJingjieMaterial").create(self._selectKnight, function ( ... )
			_callback()
		end)
	else
		return _callback()
	end
end

function HeroJingJieLayer:_onCostItemClick( widget )
	if not self._itemCostId or self._itemCostCount < 1 then
		return 
	end 
		
	local itemInfo = item_info.get(self._itemCostId )
	if not itemInfo then
		return 
	end

	local curItemCount = G_Me.bagData:getPropCount( self._itemCostId ) or 0
	--if curItemCount < self._itemCostCount then
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, self._itemCostId,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId}))
		--MessageBoxEx.showCustomMessage(nil, G_lang:get("LANG_KNIGHT_JINGJIE_TIP_LACK_JINGJIEDAN", {curCount=""..curItemCount, needCount=""..(self._itemCostCount - curItemCount)}), 
		--	MessageBoxEx.CustomButton.CustomButton_MainDugeon, function (  )
		--		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
		--	end)
	--end
end

function HeroJingJieLayer:_onKnightItemClick( widget )
	if not self._knightCostId or self._knightCostCount < 1 then
		return 
	end

	local knightBaseInfo = knight_info.get(self._knightCostId)
	--if knightBaseInfo and #self._costKnightList < self._knightCostCount then
	if knightBaseInfo then
		G_GlobalFunc.showBaseInfo(G_Goods.TYPE_KNIGHT, knightBaseInfo.id, 
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId}))
		--require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, knightBaseInfo.id,
			--GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId}))

		--MessageBoxEx.showCustomMessage(nil, G_lang:get("LANG_KNIGHT_JINGJIE_TIP_LACK_KNIGHT", {knightName=knightBaseInfo.name}), 
			--MessageBoxEx.CustomButton.CustomButton_MainDugeon, function (  )
				--uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
				--uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
			--end)
	end
	--local heroJingJieChoose = require("app.scenes.herofoster.heroJingJieChoose")
	--	heroJingJieChoose.showHeroSelectLayer( uf_notifyLayer:getModelNode(), self._allCostKnightList, function ( knightId )
	--		self._selectKnight = knightId
	--		__Log("selecte knightID:%d", knightId)
	--	end)
end

function HeroJingJieLayer:adapterLayer( ... )
	self:adapterWidgetHeight("Panel_heros", "Panel_header", "Panel_baseinfo", 0, 0)
end

function HeroJingJieLayer:_initBaseInfo( knightId, knightInfo, knightBaseInfo )
	
	local name = self:getLabelByName("Label_name_before")
	if name ~= nil then
		name:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		name:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "")
	end

	local jieShu = self:getLabelByName("Label_jingjie")
	if jieShu ~= nil then
		if knightBaseInfo then
			local jingjie = knightBaseInfo.advanced_level
			jieShu:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
			jieShu:setText(jingjie > 0 and ("+"..jingjie) or "")
			jieShu:setPositionX(name:getPositionX()+ name:getContentSize().width / 2)
		else
			jieShu:setText("")
		end
	end

	local level = self._mainKnightLevel or 1

	local knightPicBefore = self:getWidgetByName("Panel_icon_before")
	if knightPicBefore then 
		knightPicBefore:removeAllChildren()
		self._knightBefore = nil
	end

	if knightPicBefore and knightBaseInfo then
		local knightPic = require("app.scenes.common.KnightPic")
		self._knightBefore = knightPic.createKnightButton(knightBaseInfo.res_id, knightPicBefore, "mainKnight_button", self, function ( ... )
			if CCDirector:sharedDirector():getSceneCount() > 1 then 
				uf_sceneManager:popScene()
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
			end
		end, true)
		local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        EffectSingleMoving.run(self._knightBefore, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
		--self._knightBefore = knightPic.createKnightPic(knightBaseInfo.res_id, knightPicBefore)
		self._knightBefore:setTag(1000)
		self._knightBefore:setCascadeOpacityEnabled(true)
	end

-- attributes before jingjie
	label = self:getLabelByName("Label_hp_value")
	if label then
		if knightBaseInfo then
			label:setText(""..(knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp))
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_attack_value")
	if label then
		if knightBaseInfo then
			label:setText(""..(G_Me.bagData.knightsData:calcAttack(knightId)))
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_defense_p_value")
	if label then
		if knightBaseInfo then
			label:setText(""..(knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence))
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_defense_m_value")
	if label then
		if knightBaseInfo then
			label:setText(""..(knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence))
		else
			label:setText("")
		end
	end
	
	--GlobalFunc.loadStars(self, 
	--	{"ImageView_lstar_1", "ImageView_lstar_2","ImageView_lstar_3","ImageView_lstar_4","ImageView_lstar_5", "ImageView_lstar_6", },
	--	knightBaseInfo and knightBaseInfo.star or 0, 1, G_Path.getNormalStarIcon())

end

function HeroJingJieLayer:_initKnightLine( ... )
	local beforeKnight = self:getWidgetByName("ImageView_knight_dizou_before")
	local afterKnight = self:getWidgetByName("ImageView_knight_dizou_after")
	local knightLine = self:getWidgetByName("ImageView_arrow_gray")
	local panelRoot = self:getWidgetByName("Panel_heros")
	if not beforeKnight or not afterKnight or not knightLine or not panelRoot then
		return 
	end

	local beforeKnightPosx, beforeKnightPosy = beforeKnight:convertToWorldSpaceXY(0, 0)
	local afterKnightPosx, afterKnightPosy = afterKnight:convertToWorldSpaceXY(0, 0)
	local beforeKnightPosInPanelx, beforeKnightPosInPanely = panelRoot:convertToNodeSpaceXY(beforeKnightPosx, beforeKnightPosy)
	knightLine:setPositionXY(beforeKnightPosInPanelx, beforeKnightPosInPanely)

	local tanValue= 0
	if beforeKnightPosx ~= afterKnightPosx then
		tanValue = (beforeKnightPosy - afterKnightPosy)/(afterKnightPosx - beforeKnightPosx)
	else
		tanValue = 1000000
	end
	local degree = math.deg(math.atan(tanValue))
	if degree < 0 then
		degree = degree + 180
	end

	knightLine:setRotation(degree)

	local length = math.sqrt((beforeKnightPosy - afterKnightPosy)*(beforeKnightPosy - afterKnightPosy) + 
			(afterKnightPosx - beforeKnightPosx)*(afterKnightPosx - beforeKnightPosx))
	local materialSize = knightLine:getSize()
	knightLine:setSize(CCSizeMake(length, materialSize.height))
	knightLine:setVisible(true)

	local materialKnightLineGreen = self:getWidgetByName("ImageView_arrow")
	if materialKnightLineGreen then
		local materialSize = materialKnightLineGreen:getSize()
		materialKnightLineGreen:setSize(CCSizeMake(length, materialSize.height))

	end
end

function HeroJingJieLayer:_initAdvancedKnightInfo( knightInfo, knightBaseInfo )

	local name = self:getLabelByName("Label_name_after")
	if name ~= nil then
		name:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		name:setText( knightBaseInfo ~= nil and knightBaseInfo.name or "")
	end

	local jieShu = self:getLabelByName("Label_jingjie_1")
	if jieShu ~= nil then
		local jingjie = knightBaseInfo ~= nil and knightBaseInfo.advanced_level or 0
		jieShu:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		jieShu:setText(jingjie > 0 and ("+"..jingjie) or "")
		jieShu:setPositionX(name:getPositionX()+ name:getContentSize().width / 2)
	end

	local level = self._mainKnightLevel or 1
	local levelLabel = self:getLabelByName("Label_level_1")
	if levelLabel then
		if knightInfo then
			levelLabel:setText("Lv "..level)
		else
			levelLabel:setText("")
		end
	end

	self:showWidgetByName("ImageView_arrow_gray", knightBaseInfo ~= nil)

	local knightPicAfter = self:getWidgetByName("Panel_icon_after")
	if knightPicAfter then 
		knightPicAfter:removeAllChildren()
		self._knightAfter = nil
	end
	if knightPicAfter and knightBaseInfo then
		local knightPic = require("app.scenes.common.KnightPic")
		self._knightAfter = knightPic.createKnightPic(knightBaseInfo.res_id, knightPicAfter)
		self._knightAfter:setOpacity(100)
		self._knightAfter:setCascadeOpacityEnabled(true)
	end

	label = self:getLabelByName("Label_hp_value_1")
	if label then
		if knightBaseInfo then
			label:setText(""..(knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp))
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_attack_value_1")
	if label then
		if knightBaseInfo then
			label:setText(""..(G_Me.bagData.knightsData:calcAttackByBaseId(knightBaseInfo.id, level)))
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_defense_p_value_0")
	if label then
		if knightBaseInfo then
			label:setText(""..(knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence))
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_defense_m_value_1")
	if label then
		if knightBaseInfo then
			label:setText(""..(knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence))
		else
			label:setText("")
		end
	end

	local trainingArrowAnimation = function ( arrowName, followLabel, showArrow)
		if not arrowName  then
			return 
		end
		local arrow = self:getImageViewByName(arrowName)
		if not arrow then 
			return 
		end

		local arrowX, arrowY = arrow:getPosition()
		local arrowSize = arrow:getSize()
		if followLabel then 
			local followLabelCtrl = self:getWidgetByName(followLabel)
			if followLabelCtrl then 
				local posx, posy = followLabelCtrl:getPosition()
				local anchorPt = followLabelCtrl:getAnchorPoint()
				local followLabelSize = followLabelCtrl:getSize()
				--arrowX = posx + (1 - anchorPt.x)*followLabelSize.width + arrowSize.width/2
				arrowY = posy
			end			
		end

		showArrow = showArrow or false
		arrow:stopAllActions()
		arrow:setVisible(showArrow)
		if showArrow then 
			
			arrow:setVisible(true)
			arrow:setOpacity(255)
		--arrow:loadTexture(G_Path.getGrowupIcon(isGrowup))
			local moveDistUp = 10
			local startPosy = (arrowY - moveDistUp/2)

			local arr = CCArray:create()
			arr:addObject(CCResetPosition:create(arrow, ccp(arrowX, startPosy)))
			arr:addObject(CCResetOpacity:create(arrow, 255))
			local moveby = CCMoveBy:create(0.8, ccp(0, moveDistUp))
			arr:addObject(CCEaseIn:create(moveby, 0.3))
			arr:addObject(CCFadeOut:create(0.2))
			
			arrow:runAction(CCRepeatForever:create(CCSequence:create(arr)))
		end
	end

	trainingArrowAnimation("Image_hp", "Label_hp_value_1", knightBaseInfo ~= nil)
	trainingArrowAnimation("Image_attack", "Label_attack_value_1", knightBaseInfo ~= nil)
	trainingArrowAnimation("Image_def_m", "Label_defense_m_value_1", knightBaseInfo ~= nil)
	trainingArrowAnimation("Image_def_p", "Label_defense_p_value_0", knightBaseInfo ~= nil)
	--GlobalFunc.loadStars(self, 
	--	{"ImageView_rstar_1", "ImageView_rstar_2","ImageView_rstar_3","ImageView_rstar_4","ImageView_rstar_5", "ImageView_rstar_6", },
	--	knightBaseInfo and knightBaseInfo.star or 0, 1, G_Path.getNormalStarIcon())
end

function HeroJingJieLayer:_updateTianfuUnlock( knightBaseInfo, advancedBaseInfo )
	require("app.cfg.passive_skill_info")
	local checkUnlockPassive = function ( passiveId )
		if not passiveId or passiveId < 1 or not advancedBaseInfo then 
			return nil
		end

		local passiveInfo = passive_skill_info.get(passiveId)
		if not passiveInfo then 
			return nil
		end

		if passiveInfo.open_type == 1 and advancedBaseInfo.advanced_level == passiveInfo.open_value then 
			return passiveInfo
		end

		return nil
	end
	
	local passiveInfo = nil 
	if advancedBaseInfo then 
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_1)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_2)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_3)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_4)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_5)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_6)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_7)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_8)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_9)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_10)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_11)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_12)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_13)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_14)
		passiveInfo = passiveInfo or checkUnlockPassive(advancedBaseInfo.passive_skill_15)
	end

	self:showWidgetByName("Image_tianfu_back", passiveInfo ~= nil)
	if passiveInfo then 
		--self:showWidgetByName("Label_tianfu_content", true)
		self:showTextWithLabel("Label_tianfu_unlock", G_lang:get("LANG_KNIGHT_JINGJIE_UNLOCK_TIANFU", {tianfu=passiveInfo.name}))
		local content = self:getLabelByName("Label_tianfu_content")
		if content then 
			--local contentSize = content:getSize()
			--content:setSize(CCSizeMake(contentSize.width, 0))
			content:setText(passiveInfo.directions)
			local contentSize = content:getSize()
			local tianfu = self:getWidgetByName("Label_tianfu_unlock")
			if tianfu then 
				local tianfuSize = tianfu:getSize()
				local posx, posy = tianfu:getPosition()
				content:setPosition(ccp(posx, posy - tianfuSize.height/2 - contentSize.height/2))
			end
		end
	else
		self:showTextWithLabel("Label_tianfu_content", "")
	end
end

function HeroJingJieLayer:_initCostInfo( knightId, knightInfo, knightBaseInfo )
	require("app.cfg.knight_advance_info")
	local cost = self._costInfo
	if cost == nil then
		self:showWidgetByName("Panel_item", false)
		self:showWidgetByName("Panel_knight", false)
		return 
	end

	local hasLoadItem = false 
	local hasLoadKnight = false
	if cost.cost1_type then
		if cost.cost1_type == 1 then
			hasLoadKnight = true
			self:_loadCostKnight(1, knightBaseInfo.advance_code, cost.cost1_num )
			--index = index + 1
		elseif cost.cost1_type == 2 then
			hasLoadItem = true
			self:_loadCostItem(2, cost.cost1_value, cost.cost1_num )
			--index = index + 1
		end
	end

	if cost.cost2_type then
		if cost.cost2_type == 1 then
			hasLoadKnight = true
			self:_loadCostKnight(1, knightBaseInfo.advance_code, cost.cost2_num )
			--index = index + 1
		elseif cost.cost2_type == 2 then
			hasLoadItem = true
			self:_loadCostItem(2, cost.cost2_value, cost.cost2_num )
			--index = index + 1
		end
	end

	self:showWidgetByName("Panel_item", hasLoadItem)
	self:showWidgetByName("Panel_knight", hasLoadKnight)

	local costMoney = self:getLabelByName("Label_cost_yinbi_value")
	if costMoney then
		-- local vipLevel = G_Me.userData.vip
		-- if vipLevel >= 5 then 
		-- 	self._costInfo.cost_money = 0
		-- elseif vipLevel >= 2 then 
		-- 	self._costInfo.cost_money = self._costInfo.cost_money/2
		-- end
		if cost.cost_money > G_Me.userData.money then
			costMoney:setColor(Colors.titleRed)
		else
			costMoney:setColor(Colors.inActiveSkill)
		end
		costMoney:setText(self._costInfo.cost_money)
	end

	local ret = true
	if self._knightCostId > 0 then
		ret = (self._knightCostCount <= #self._costKnightList)
	end

	if self._itemCostId > 0 then
		local curItemCount = G_Me.bagData:getPropCount( self._itemCostId ) or 0
		ret = ret and (curItemCount >= self._itemCostCount)
	end

	ret = ret and knightInfo ~= nil and knightBaseInfo ~= nil

	--self:_brighterKnightLine( ret )
end

function HeroJingJieLayer:_loadCostKnight( index, baseId, count )
	self._knightCostId = 0
    self._knightCostCount = 0

	self:showWidgetByName("Panel_knight", true)

	baseId = baseId or 0
	local knightBaseInfo = knight_info.get(baseId)
	if knightBaseInfo ~= nil then
		local itemIcon = self:getImageViewByName("ImageView_cost_icon_"..index)
		local itemPath = G_Path.getKnightIcon(knightBaseInfo.res_id)
		itemIcon:loadTexture(itemPath, UI_TEX_TYPE_LOCAL)

		self._knightCostId = baseId
    	self._knightCostCount = count
	end

	local pingji = self:getButtonByName("Button_cost_"..index)
	if pingji then
		pingji:loadTextureNormal(G_Path.getAddtionKnightColorImage(knightBaseInfo.quality))
	end

	local label = self:getLabelByName("Label_count_"..index)
	if label then

		if #self._costKnightList >= count then
			label:setColor(Colors.inActiveSkill)
		else
			label:setColor(Colors.titleRed)
		end
		label:setText(string.format("%u/%u", #self._costKnightList, count))
	end

	label = self:getLabelByName("Label_name_"..index)
	if label then
		label:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		label:setText(knightBaseInfo and knightBaseInfo.name or "")
	end

end

function HeroJingJieLayer:_loadCostItem( index, itemId, count )
	self._itemCostId = 0
	self._itemCostCount = 0


	self:showWidgetByName("Panel_item", true)

	local itemInfo = item_info.get(itemId)
	if itemInfo then
		local itemIcon = self:getImageViewByName("ImageView_cost_icon_"..index)
		local itemPath = G_Path.getItemIcon(itemInfo.res_id)
		itemIcon:loadTexture(itemPath, UI_TEX_TYPE_LOCAL)

		self._itemCostId = itemId
		self._itemCostCount = count
	end

	local label = self:getLabelByName("Label_count_"..index)
	if label then
		local maxCount = G_Me.bagData:getPropCount( itemId )
		label:setColor(maxCount >= count and Colors.inActiveSkill or Colors.titleRed)
		label:setText(string.format("%u/%u", maxCount, count))
	end	

	label = self:getLabelByName("Label_name_"..index)
	if label then
		label:setColor(Colors.getColor(5))
		label:setText(itemInfo and itemInfo.name or "")
	end
end


return HeroJingJieLayer