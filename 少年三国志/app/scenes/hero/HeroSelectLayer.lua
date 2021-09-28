--HeroSelectLayer.lua

local HeroSelectLayer = class ("HeroSelectLayer", UFCCSModelLayer)


function HeroSelectLayer:ctor( _, _, pos, ...)
	self._handler = nil
	self._target = nil
	self._params = nil
	self._listview = nil

	self._showWearOnKnight = false
	self._selectedKnights =  {}

	self.super.ctor(self, nil, nil, pos, ...)

	self._knightJipanList = {}
	self._knightHejiList = {}

	self._posIndex = pos or 0

	self:enableLabelStroke("Label_hide", Colors.strokeBrown, 2)
	local check = self:getCheckBoxByName("CheckBox_show")
	if check then
		check:setSelectedState(not self._showWearOnKnight)
	end
	self:_initClickEvent()
	
end

function HeroSelectLayer:_initClickEvent(  )
	self:registerBtnClickEvent("Button_return", function ( widget )
		self:close()
	end)
	self:registerCheckboxEvent("CheckBox_show", function ( widget, checkType, isCheck )
		self._showWearOnKnight = not isCheck
		self:_doLoadHeroList()
	end)
end

function HeroSelectLayer:initCallback( func, target, ... )
	self._handler = func
 	self._target = target
 	self._params = {...}
end

function HeroSelectLayer:onLayerLoad( ... )
	self:adapterWithScreen()
	self:adapterWidgetHeight("Panel_list", "Panel_260", "", -30, 30)
end

function HeroSelectLayer:onLayerEnter( ... )
	self:registerKeypadEvent(true, false)
	--self:closeAtReturn(true)
	self:_loadHeroList()
end

function HeroSelectLayer:onBackKeyEvent( ... )
	self:close()
    return true
end

function HeroSelectLayer:_loadHeroList()
	local animate = not self._listview and true or false

	if not self._listview then 
		local panel = self:getPanelByName("Panel_list")
		if panel == nil then
			return 
		end

		self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

    	self._listview:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.hero.HeroListItem").new(list, index)
    	end)
    	self._listview:setUpdateCellHandler(function ( list, index, cell)
    		local knightId = self._selectedKnights[index + 1]
    	    cell:updateHero(knightId, self._knightHejiList[knightId] or {}, self._knightJipanList[knightId] or 0)
    	end)
    	self._listview:setSelectCellHandler(function ( cell, index )
    		self:_excuteCallback( index )
    		self:close()
    	end)
    	self:registerListViewEvent("Panel_list", function ( ... )
    		-- this function is used for new user guide, you shouldn't care it
    	end)
	end

    self:_doLoadHeroList( animate )
end

function HeroSelectLayer:_doLoadHeroList( animate ) 
	animate = animate or false
	__Log("_doLoadHeroList:_posIndex:%d", self._posIndex)
	local requireJipan = G_Me.bagData.knightsData:getRequireKnightJipan(self._posIndex) or {}
	local requireHeji = G_Me.bagData.knightsData:getRequireKnightHeji(self._posIndex) or {}
	self._knightJipanList = {}
	self._knightHejiList = {}

	-- 计算武将缘分个数
	local findJipan = function ( advancedCode, isYuanJun )
		isYuanJun = isYuanJun or false
		if type(advancedCode) ~= "number" or advancedCode < 1 then 
			return 0
		end

		local _doCalcJipanCount = function ( jiPanArr, isMainKnight )
			if type(jiPanArr) ~= "table" then 
				return 0
			end

			local _jipanCount = 0
			for key1, value1 in pairs(jiPanArr) do 
					local flag1 = true
					local flag2 = isMainKnight
					if type(value1) == "table" then
						for key2, value2 in pairs(value1) do 
							if type(key2) == "number" then
								if (key2 ~= advancedCode) and not requireJipan[key2] then 
									flag1 = false
								end
								if key2 == advancedCode then 
								 	flag2 = true
								 end
							end
						end
						if flag1 and flag2 then 
							_jipanCount = _jipanCount + 1
						end
					end
				end

			return _jipanCount
		end

		local jipanCount = 0
		for key, value in pairs(requireJipan) do 
			if type(value) == "table" then
				jipanCount = jipanCount + _doCalcJipanCount(value)
			end
		end

		if not isYuanJun then 
			local knightJipan = G_Me.bagData.knightsData:calcAssocition(advancedCode)
			jipanCount = jipanCount + _doCalcJipanCount(knightJipan, true)
		end

		return jipanCount
	end

	-- 计算武将是否有合击
	local findHeji = function ( advancedCode )
		if type(advancedCode) ~= "number" or advancedCode < 1 then 
			return nil
		end

		local hejiIds = {}
		for key, value in pairs(requireHeji) do 
			if type(value) == "table" then
				local flag1 = true
				local flag2 = false
				for key1, value1 in pairs(value) do
					if (key1 ~= advancedCode) and (not requireJipan[key1]) then
						flag1 = false
					end
					if key1 == advancedCode then 
						flag2 = true
					end
				end
				if flag1 and flag2 then 
					table.insert(hejiIds, #hejiIds + 1, key)
					for key1, value1 in pairs(value) do
						if key1 ~= advancedCode then 
							table.insert(hejiIds, #hejiIds + 1, key1)
						end
					end
				end
			end
		end

		return #hejiIds > 0 and hejiIds or nil
	end

	local isYuanJun = (self._posIndex > 6)
	local allKnights = G_Me.bagData.knightsData:getKnightsIdListCopy()
	self._selectedKnights = {}
	-- 如果不显示已上阵的武将
	if not self._showWearOnKnight then
		local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
		local secondTeam = G_Me.formationData:getSecondTeamKnightIds()

		--先把已经上阵的武将排除
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

		-- 再把剩余武将通过计算缘分数和合击数，并保存在列表中
		for key, value in pairs(allKnights) do 
			if exceptArr[value] ~= 1 then
				local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
				if knightInfo then 
					local knightBaseInfo = knight_info.get(knightInfo["base_id"] or 0)
					if knightBaseInfo and not requireJipan[knightBaseInfo.advance_code] then 
						table.insert(self._selectedKnights, #self._selectedKnights + 1, value)

						self._knightJipanList[value] = findJipan(knightBaseInfo.advance_code, isYuanJun)
						self._knightHejiList[value] = findHeji(knightBaseInfo.advance_code)						
					end
				end
			end
		end
	else
		for key, value in pairs(allKnights) do 
			--if exceptArr[value] ~= 1 then
				local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
				if knightInfo then 
					local knightBaseInfo = knight_info.get(knightInfo["base_id"] or 0)
					if knightBaseInfo and not requireJipan[knightBaseInfo.advance_code] then 
						table.insert(self._selectedKnights, #self._selectedKnights + 1, value)

						self._knightJipanList[value] = findJipan(knightBaseInfo.advance_code, isYuanJun)
						self._knightHejiList[value] = findHeji(knightBaseInfo.advance_code)						
					end
				end
			--end
		end
		--self._selectedKnights = allKnights
	end

	-- 对剩余的武将做排序: 合击 > 带激活缘分的武将(高于蓝色品质) > 不带缘分的武将(高于蓝色品质) 
	--  > 带缘分的武将(等于/低于蓝色品质的武将) > 不带缘分的武将(等于/低于蓝色品质的武将)
	local sortFun = function ( indexA, indexB )  
		local a = G_Me.bagData.knightsData:getKnightByKnightId(indexA)
        local b = G_Me.bagData.knightsData:getKnightByKnightId(indexB)
        if not a then 
            __LogError("a wrong knigh info for knightId:%d", indexA or 0)
        end
        if not b then 
            __LogError("b wrong knigh info for knightId:%d", indexB or 0)
        end

        local kniA = knight_info.get(a.base_id)
        local kniB = knight_info.get(b.base_id)
        if not kniA then 
            __LogError("a wrong knigh info for baseid:%d", a.base_id)
        end
        if not kniB then 
            __LogError("b wrong knigh info for baseid:%d", b.base_id)
        end

        if kniA.max_stars > 0 and kniB.max_stars == 0 then
        	return true
        elseif kniA.max_stars == 0 and kniB.max_stars > 0 then
        	return false
        end

        local hejiCountA = self._knightHejiList[indexA] or {}
        local hejiCountB = self._knightHejiList[indexB] or {}
        if #hejiCountA ~= #hejiCountB then 
        	return #hejiCountA > #hejiCountB 
        end

        -- 如果有高于蓝色的将，则在第一阵容中，优先排高品质的将，再考虑缘分个数
        -- 否则优先考虑缘分个数，再考虑高品质的将

        local jipanCountA = self._knightJipanList[indexA] or 0
        local jipanCountB = self._knightJipanList[indexB] or 0
        --local hasHightQuality = (kniA.quality > 3) or (kniB.quality > 3)
        --local hasLowQualityJipan = ((kniA.quality <= 3) and (jipanCountA < 1)) or ((kniB.quality <= 3) and (jipanCountB < 1))
        --if (not isYuanJun) and hasHightQuality and hasLowQualityJipan then 
        if (not isYuanJun) and ( (kniA.quality <= 3 and kniB.quality > 3) or (kniA.quality > 3 and kniB.quality <= 3)) then
        	if kniA.quality ~= kniB.quality then
            	return kniA.quality > kniB.quality
            end
            
        	if jipanCountA ~= jipanCountB then 
        		return jipanCountA > jipanCountB 
        	end
        else
        	if jipanCountA ~= jipanCountB then 
        		return jipanCountA > jipanCountB 
        	end
        	if kniA.quality ~= kniB.quality then
            	return kniA.quality > kniB.quality
            end
        end
        
        if kniA.advanced_level ~= kniB.advanced_level then 
            return kniA.advanced_level > kniB.advanced_level 
        end

        --再比较等级
        if a.level ~= b.level then
            return a.level > b.level
        end

        return a.base_id > b.base_id
	end

	if #self._selectedKnights < 1 then 
		self:close()
		G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
		return 
	end

	table.sort(self._selectedKnights or {}, sortFun)

	self._listview:initChildWithDataLength(#self._selectedKnights, animate and 0.2 or 0)
end

function HeroSelectLayer:_excuteCallback( index )
	--dump(self._params)
	if self._handler ~= nil and self._target ~= nil then
 		self._handler(self._target, index, self.__EFFECT_FINISH_CALLBACK__, unpack(self._params) )
 	elseif self._handler ~= nil then
 		self._handler(index, self.__EFFECT_FINISH_CALLBACK__, unpack(self._params) )
 	else
 		__Log("all is nil")
 	end
end

function HeroSelectLayer.showHeroSelectLayer( parent, pos, func, target, ... )
	if parent == nil then 
		return 
	end

	local heroSelect = require("app.scenes.hero.HeroSelectLayer").new("ui_layout/knight_selectKnight.json", nil, pos)
 	heroSelect:initCallback(func, target, ...)

 	parent:addChild(heroSelect)
end

return HeroSelectLayer
