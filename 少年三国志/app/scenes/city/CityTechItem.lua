local CityTechItem = class("CityTechItem", function()
	return CCSItemCellBase:create("ui_layout/city_TechItem.json")
end)

require("app.cfg.city_info")
require("app.cfg.city_technology_info")
local CityConst = require("app.const.CityConst")

function CityTechItem:ctor(jumpCallback)
	self._jumpCallback	= jumpCallback -- 点击城池图标的跳转回调
	self._techState 	= nil	-- 该领地科技的状态
	self._techInfo  	= nil	-- 当前等级科技的具体信息
	self._nextTechInfo 	= nil	-- 下一等级科技的具体信息
	self._stateImg 		= self:getImageViewByName("Image_State")

	self:enableLabelStroke("Label_CityName", Colors.strokeBrown, 1)
	self:registerBtnClickEvent("Button_CityIcon", handler(self, self._onClickCity))
	self:registerBtnClickEvent("Button_Raise", handler(self, self._onClickRaise))
end

function CityTechItem:update(techState)
	self._techState = techState
	local cityID = techState.city_id
	local level = techState.level
	local canOpen = techState.can_open
	local canUp = techState.can_up
	local isMaxLevel = level == CityConst.MAX_TECH_LEVEL
	self._techInfo = city_technology_info.get(cityID, level)
	self._nextTechInfo = city_technology_info.get(cityID, level + 1)

	-- city icon
	self:_updateCityIcon(cityID)

	-- city name
	local cityName = city_info.get(cityID).name
	self:showTextWithLabel("Label_CityName", cityName)

	-- city level
	local strLevel = level > 0 and (level .. G_lang:get("LANG_FRIEND_LEVEL"))
								or G_lang:get("LANG_LEGION_TECH_HAS_CLOSED2")
	self:showTextWithLabel("Label_CityLevel", strLevel)

	-- description
	local desc
	if level == 0 then
		local odds = self._nextTechInfo.odds / 10
		desc = G_lang:get("LANG_CITY_TECH_OPEN_DESC", {city = cityName, num = odds})
	else
		desc = self._techInfo.description
	end
	self:showTextWithLabel("Label_Desc", desc)

	-- open or level-up condition
	local condLabel = self:getLabelByName("Label_Condition")

	if isMaxLevel or canOpen or canUp then
		condLabel:setVisible(false)
	else
		condLabel:setVisible(true)
		local isTimeEnough = G_Me.cityData:getTotalPatrolTime() >= self._nextTechInfo.require_patroltime
		if level == 0 then
			if techState.city_state <= G_Me.cityData.CITY_NEED_ATTACK then
				strCond = G_lang:get("LANG_CITY_TECH_OPEN_CONDITION1")
			else
				strCond = G_lang:get("LANG_CITY_TECH_OPEN_CONDITION2", {num = self._nextTechInfo.require_patroltime})
			end
		elseif not isTimeEnough then
			strCond = G_lang:get("LANG_CITY_TECH_UP_CONDITION", {num = self._nextTechInfo.require_patroltime})
		end
		condLabel:setText(strCond)
	end

	-- button state
	local showBtn = canOpen or (level > 0 and level < CityConst.MAX_TECH_LEVEL)
	self:showWidgetByName("Button_Raise", showBtn)
	self._stateImg:setVisible(not showBtn)

	if showBtn then
		local btnDescImg = G_Path.getSmallBtnTxt(canOpen and "kaiqi.png" or "tisheng.png")
		self:getImageViewByName("Image_ButtonDesc"):loadTexture(btnDescImg)

		-- price to open or raise level
		self:showWidgetByName("Image_Gold", not isMaxLevel)
		self:showWidgetByName("Label_Gold", not isMaxLevel)
		if not isMaxLevel then
			self:showTextWithLabel("Label_Gold", tostring(self._nextTechInfo.learn_cost_size))
		end
	else
		local stateImg = isMaxLevel and "yimanji.png" or "jt_weikaiqi.png"
		self._stateImg:loadTexture(G_Path.getTextPath(stateImg))
	end
end

function CityTechItem:_updateCityIcon(cityID)
	local cityBtn = self:getButtonByName("Button_CityIcon")

	-- set city icon
	local iconPath = "ui/city/city_".. cityID ..".png"
	cityBtn:loadTextureNormal(iconPath)
	cityBtn:loadTexturePressed(iconPath)

	-- if the city is not attacked, set as gray and show lock
	local cityState = G_Me.cityData:getCityByIndex(cityID).state
	local isNotTaken = self._techState.city_state <= G_Me.cityData.CITY_NEED_ATTACK
	cityBtn:showAsGray(isNotTaken)
	self:showWidgetByName("Image_Lock", isNotTaken)
end

function CityTechItem:_onClickCity()
	local cityState = G_Me.cityData:getCityByIndex(self._techState.city_id).state
	local isNotTaken = self._techState.city_state <= G_Me.cityData.CITY_NEED_ATTACK

	if isNotTaken then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_NOT_TAKEN_YET"))
	else
		self._jumpCallback(self._techState.city_id)
	end
end

function CityTechItem:_onClickRaise()
	if not self._techState.can_open and not self._techState.can_up then
		-- 巡逻时间不够
		local needPatrolTime = self._nextTechInfo.require_patroltime
		G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_TECH_UP_CONDITION", {num = needPatrolTime}))
		return
	end

	local cost = self._nextTechInfo.learn_cost_size
	if self._techState.can_open then
		-- 询问开启对话框
		local cityName = city_info.get(self._techState.city_id).name
		local msg = G_lang:get("LANG_CITY_TECH_CONFIRM_OPEN", {num = cost, city = cityName})
		MessageBoxEx.showYesNoMessage(nil, msg, false, handler(self, self._confirmCost), nil, nil)
	else
		-- 判断钱是否够提升技能
		self:_confirmCost()
	end
end

function CityTechItem:_confirmCost()
	local cost = self._nextTechInfo.learn_cost_size
	if cost > G_Me.userData.gold then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
	else
		G_HandlersManager.cityHandler:sendCityTechUp(self._techState.city_id)
	end
end

return CityTechItem