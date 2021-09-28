local CityPatrolAwardLayer = class("CityPatrolAwardLayer", UFCCSModelLayer)

-- @param cityIndex: index of the city to harvest, if cityIndex == 0 then show awards of all cities
-- @param callback:  callback when the player got the awards
function CityPatrolAwardLayer.create(cityIndex, callback)
	local layer = CityPatrolAwardLayer.new("ui_layout/city_PatrolEndAwardLayer.json", 
											Colors.modelColor, cityIndex, callback)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function CityPatrolAwardLayer:ctor(json, color, cityIndex, callback)
	self._cityIndex = cityIndex
	self._callback  = callback
	self.super.ctor(self, json, color)
end

function CityPatrolAwardLayer:onLayerLoad()
	self:_initUI()

	self:registerBtnClickEvent("Button_ok", handler(self, self._onClickOK))
	self:registerBtnClickEvent("Button_close", handler(self, self._onClickClose))
    self:enableAudioEffectByName("Button_close", false)

    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function CityPatrolAwardLayer:onLayerEnter()
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_AWARD, self._onRcvGetAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_ONEKEYREWARD, self._onRcvGetAward, self)
end

function CityPatrolAwardLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function CityPatrolAwardLayer:_initUI()
	self:showTextWithLabel("Label_patrol_desc", G_lang:get("LANG_CITY_PATROL_AWARD_DESC"))

	if G_Me.activityData.custom:isCityActive() then
		local label = G_GlobalFunc.createGameLabel(G_lang:get("LANG_CITY_PATROL_ACTIVITY_AWARD_DESC"), 22, Colors.lightColors.TIPS_01)
		label:setAnchorPoint(ccp(0, 0.5))
		local ref = self:getLabelByName("Label_patrol_desc")
		local parent = ref:getParent()
		parent:addChild(label)
		label:setPositionXY(ref:getPositionX()+ref:getSize().width, ref:getPositionY())
	end

	-- award data
	local awards = self._cityIndex > 0 and G_Me.cityData:getAllCityAwardByIndex(self._cityIndex)
										or G_Me.cityData:getAllCityAwards()

	-- 提取由领地技能带来的额外奖励
	local extraAwards = {}
	for i, v in ipairs(awards) do
		if v.extraSize and v.extraSize > 0 then
			extraAwards[#extraAwards + 1] = v
		end
	end

	-- 根据是否有额外奖励调整界面
	local hasExtra = #extraAwards > 0
	self:showWidgetByName("Panel_listboard_long", not hasExtra)
	self:showWidgetByName("Panel_listboard_short", hasExtra)
	self:showWidgetByName("Label_patrol_desc_extra", hasExtra)
	self:showWidgetByName("Panel_listboard_extra", hasExtra)

	-- full award list
	local panel = self:getPanelByName(hasExtra and "Panel_list_short" or "Panel_list_long")
	self:_initAwardList(panel, awards, false)

	-- extra award list
	if hasExtra then
		panel = self:getPanelByName("Panel_listboard_extra")
		self:_initAwardList(panel, extraAwards, true)
	end
end

function CityPatrolAwardLayer:_initAwardList(panel, awards, isExtra)
	local double = G_Me.activityData.custom:isCityActive() and 2 or 1

	local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	listView:setCreateCellHandler(function()
		return CCSItemCellBase:create("ui_layout/city_PatrolEndAwardItem.json")
	end)

	listView:setUpdateCellHandler(function(list, index, cell)
		for i=1, math.min(#awards - index*4, 4) do
			local award = awards[index*4 + i]
			local good = G_Goods.convert(award.type, award.value)
			cell:showWidgetByName("ImageView_item" .. i, true)

			-- background, icon and quality frame
			cell:getImageViewByName("ImageView_bg" .. i):loadTexture(G_Path.getEquipIconBack(good.quality), UI_TEX_TYPE_PLIST)
			cell:getImageViewByName("ImageView_head" .. i):loadTexture(good.icon)
			cell:getImageViewByName("ImageView_frame" .. i):loadTexture(G_Path.getEquipColorImage(good.quality, good.type), UI_TEX_TYPE_PLIST)

			-- award name
			local nameLabel = cell:getLabelByName("Label_name" .. i)
			nameLabel:setText(good.name)
			nameLabel:setColor(Colors.qualityColors[good.quality])
			nameLabel:createStroke(Colors.strokeBlack, 1)

			-- award count
			local countLabel = cell:getLabelByName("Label_amount" .. i)
			countLabel:setText("x" .. (isExtra and award.extraSize or award.size) * double)
			countLabel:createStroke(Colors.strokeBlack, 1)
                
			-- 头像现在需要响应事件用来显示详情
			cell:registerWidgetTouchEvent("ImageView_head"..i, function(widget, state)
				-- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
				if state == 2 then
					require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
				end
			end)        
		end
   	         
		for i=(#awards - index*4+1), 4 do
			cell:showWidgetByName("ImageView_item" .. i, false)
		end
	end)

	listView:initChildWithDataLength(math.ceil(#awards/4))
end

function CityPatrolAwardLayer:_onClickOK()
	if self._cityIndex > 0 then
		G_HandlersManager.cityHandler:sendCityAward(self._cityIndex)
	else
		G_HandlersManager.cityHandler:sendCityOneKeyReward()
	end
end

function CityPatrolAwardLayer:_onClickClose()
	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
	self:animationToClose()
end

function CityPatrolAwardLayer:_onRcvGetAward(message)
	if message.ret == NetMsg_ERROR.RET_OK then
		-- reset city info
		if self._cityIndex > 0 then
			G_Me.cityData:resetCityInfo(self._cityIndex)
		else
			G_Me.cityData:resetAllHarvestCityInfo()
		end

		-- execute callback
		if self._callback then
			self._callback()
		end

		-- close self
		self:animationToClose()
	end
end

return CityPatrolAwardLayer