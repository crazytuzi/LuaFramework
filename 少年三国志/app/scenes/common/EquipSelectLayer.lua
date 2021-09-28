--EquipSelectLayer.lua


local EquipSelectLayer = class ("EquipSelectLayer", UFCCSModelLayer)


function EquipSelectLayer:ctor( _, _, knightIndex, ... )
	self._handler = nil
	self._target = nil
	self._params = nil
	self._equipList = {}
	self._equipWearOn = {}
	self._equipShow = {}
	self._showWearOnKnight = false
	self._hasWearonEquip = false
	self._slotIndex = 0

	self.super.ctor(self,  nil, nil, knightIndex, ...)
	self._knightIndex = knightIndex or 0
	self._equipJipanList = {}

	self:enableLabelStroke("Label_hide", Colors.strokeBrown, 2)

	local check = self:getCheckBoxByName("CheckBox_show")
	if check then
		check:setSelectedState(not self._showWearOnKnight)
	end

	self:_initClickEvent()
	
end

function EquipSelectLayer:_initClickEvent(  )
	self:registerBtnClickEvent("Button_return", function ( widget )
		self:close()
	end)
	self:registerCheckboxEvent("CheckBox_show", function ( widget, checkType, isCheck )
		if not self._hasWearonEquip then 
			return 
		end

		self._showWearOnKnight = not isCheck
		self:_doLoadEquipList()
	end)
end

function EquipSelectLayer:initCallback( func, target, ... )
	self._handler = func
 	self._target = target
 	self._params = {...}
end

function EquipSelectLayer:onLayerLoad( ... )
	self:adapterWithScreen()
	self:adapterWidgetHeight("Panel_list", "Panel_260", "", -30, 30)
end

function EquipSelectLayer:onLayerEnter( ... )
	self:registerKeypadEvent(true, false)
end

function EquipSelectLayer:onBackKeyEvent( ... )
	self:close()
    return true
end

function EquipSelectLayer:loadEquipList( slot, equipList )
	--dump(slot)
	--dump(equipList)
	local panel = self:getPanelByName("Panel_list")
	if panel == nil then
		return 
	end

	self._slotIndex = slot or 0
	if slot <= 4 then
		self._equipWearOn = G_Me.formationData:getFightEquipmentList(slot)
	else
		self._equipWearOn = G_Me.formationData:getFightTreasureList(slot - 4)
	end
	--dump(self._equipWearOn)

	self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    self._listview:setCreateCellHandler(function ( list, index)
        return require("app.scenes.common.EquipSelectItem").new(list, index)
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
    	local equipInfo = self._equipShow[index + 1]
    	local equipId = equipInfo and equipInfo.id or nil
    	if equipId then
        	cell:updateInfo( equipInfo, self._equipWearOn[equipId], self._equipJipanList[equipId] )
        end
    end)
    self._listview:setSelectCellHandler(function ( cell, index )
    	self:_excuteCallback( index )
    	self:close()
    end)
    self:registerListViewEvent("Panel_list", function ( ... )
    	-- this function is used for new user guide, you shouldn't care it
    end)

	local size = self._listview:getSize()
    self._equipList = equipList or {}
    self:_updateWearonFlag()

    self:_doLoadEquipList(true)
end

function EquipSelectLayer:_updateWearonFlag(  )
	self._hasWearonEquip = false
	for key, value in pairs(self._equipList) do 
		if value then
			local equipId = value.id 
			if self._equipWearOn[equipId] then
				self._hasWearonEquip = true
				return 
			end
		end
	end
end

function EquipSelectLayer:_doLoadEquipList( animate )
	animate = animate or false
	self._equipShow = {}

	local requireEquip = G_Me.bagData.knightsData:getRequireEquipJipan(self._knightIndex, self._slotIndex) or {}
	self._equipJipanList = {}

	local findJipan = function ( advancedCode )
		if type(advancedCode) ~= "number" or advancedCode < 1 then 
			return 0
		end

		if type(requireEquip) ~= "table"  then 
			return 0
		end

		local jipanCount = 0
		for key, value in pairs(requireEquip) do 
			if type(value) == "table" then
				for key1, value1 in pairs(value) do 

					if type(key1) == "number" and key1 == advancedCode then 
						jipanCount = jipanCount + 1
					end
				end
			end
		end

		return jipanCount
	end

	for key, value in pairs(self._equipList) do 
		if (not self._showWearOnKnight and not self._equipWearOn[value.id]) or self._showWearOnKnight then
			table.insert(self._equipShow, #self._equipShow + 1, value)

			local baseInfo = value:getInfo()
			if baseInfo then 
				self._equipJipanList[value.id] = findJipan(baseInfo.id)
			end
		end
	end

	local sortFun = function ( equipA, equipB )
		if not equipA then 
            __LogError("a wrong equp info ")
		end
		if not equipB then 
            __LogError("b wrong equp info ")
		end

		local equipAInfo = equipA:getInfo()
		local equipBInfo = equipB:getInfo()
		if not equipAInfo then 
            __LogError("a wrong equp info ")
		end
		if not equipBInfo then 
            __LogError("b wrong equp info ")
		end

		local jipanCountA = self._equipJipanList[equipA.id]
		local jipanCountB = self._equipJipanList[equipB.id]
		if jipanCountA ~= jipanCountB then 
        	return jipanCountA > jipanCountB 
        end

        if equipAInfo.quality ~= equipBInfo.quality then
        	return equipAInfo.quality > equipBInfo.quality
    	end

    	if equipAInfo.potentiality ~= equipBInfo.potentiality then
    	    return equipAInfo.potentiality > equipBInfo.potentiality
    	end

    	if equipA.refining_level ~= equipB.refining_level then
    	    return equipA.refining_level > equipB.refining_level
    	end

    	return equipA.level > equipB.level
	end

	table.sort(self._equipShow, sortFun)

	self._listview:initChildWithDataLength(#self._equipShow, animate and 0.2 or 0)
end

function EquipSelectLayer:_excuteCallback( index )
	if self._handler ~= nil and self._target ~= nil then
 		self._handler(self._target, index, self.__EFFECT_FINISH_CALLBACK__, unpack(self._params) )
 	elseif self._handler ~= nil then
 		self._handler(index, self.__EFFECT_FINISH_CALLBACK__, unpack(self._params) )
 	else
 		__Log("all is nil")
 	end
end

function EquipSelectLayer.showEquipSelectLayer( parent, knightIndex, slot, equipList, func, target, ... )
	if parent == nil then 
		return 
	end

	local equipSelect = require("app.scenes.common.EquipSelectLayer").new("ui_layout/knight_equipSelect.json", nil, knightIndex)
 	equipSelect:initCallback(func, target, ...)
 	equipSelect:loadEquipList( slot, equipList)-- EquipSelectLayer.sortEquip(equipList) )

 	parent:addChild(equipSelect)
end

--排序,品质,强化等级
local sortEquipmentFunc = function(a,b)
    local infoa = a:getInfo()
    local infob = b:getInfo()

    if infoa.quality ~= infob.quality then
        return infoa.quality > infob.quality
    end
    
    if a.level ~= b.level then
        return a.level > b.level
    end

    return a.id < b.id
end

function EquipSelectLayer.sortEquip( equipList)
    table.sort(equipList, sortEquipmentFunc)
    return equipList
end


return EquipSelectLayer
