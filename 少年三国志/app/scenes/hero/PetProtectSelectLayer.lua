-- PetProtectSelectLayer.lua

local PetSelectPetItem = require("app.scenes.hero.PetProtectSelectItem")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
local PetProtectSelectLayer = class("PetProtectSelectLayer", UFCCSModelLayer)

function PetProtectSelectLayer.show(...)
	-- local count = G_Me.bagData.petData:getPetCountExceptFightOne()
	-- local pet = G_Me.bagData.petData:getFightPet()
	-- if count == 0 then
	-- 	local str = pet and G_lang:get("LANG_PET_FORM_NO_PET2") or G_lang:get("LANG_PET_FORM_NO_PET1")
	-- 	G_MovingTip:showMovingTip(str)
	-- 	return false
	-- end
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
	    return
	end
	local p = PetProtectSelectLayer.create(...)
	uf_sceneManager:getCurScene():addChild(p)
	
	return p
end

function PetProtectSelectLayer.create(...)
	return PetProtectSelectLayer.new("ui_layout/PetBag_SelectPetLayer.json", nil, ...)
end

function PetProtectSelectLayer:ctor(json, param, pos, selectCallback, ...)

	self._pos = pos or 1
	self._selectCallback = selectCallback
	self._showWearOnPet = false
	self._showPetList = {}
	self._tPetListView = nil
	self._noPetLayer = nil

	self.super.ctor(self, json, param, ...)

	self:_initWidgets()
	
end

function PetProtectSelectLayer:onLayerEnter()

	self:adapterLayer()

	self:registerKeypadEvent(true)

	self:_initListView()
end

function PetProtectSelectLayer:onLayerExit()
	
end

function PetProtectSelectLayer:adapterLayer()
	self:adapterWithScreen()
	self:adapterWidgetHeight("Panel_list", "Panel_260", "", 0, 30)
	self:adapterWidgetHeight("Panel_Content", "Panel_260", "", 14, 0)
end

function PetProtectSelectLayer:_initWidgets()
	self:enableLabelStroke("Label_hide", Colors.strokeBrown, 2)

	self:registerBtnClickEvent("Button_return", function()
		self:_closeWindow()
	end)

	local check = self:getCheckBoxByName("CheckBox_show")
	if check then
		check:setSelectedState(not self._showWearOnPet)
	end

	self:registerCheckboxEvent("CheckBox_show", function ( widget, checkType, isCheck )
		self._showWearOnPet = not isCheck
		self:_doLoadPetList()
		self._tPetListView:reloadWithLength(#self._showPetList,0.2)
	end)
end

function PetProtectSelectLayer:_closeWindow()
	self:close()
end

function PetProtectSelectLayer:onBackKeyEvent()
	self:close()
	return true
end

function PetProtectSelectLayer:_initListView()
	if G_Me.bagData.petData:getPetCount() == 0 then
		self:_hasNoPet()
	else
		self:_doLoadPetList()
		if not self._tPetListView then
			local panel = self:getPanelByName("Panel_list")
			if panel then
				self._tPetListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	        
		        self._tPetListView:setCreateCellHandler(function(list, index)
		            return PetSelectPetItem.new(self._pos)
		        end)

		        self._tPetListView:setUpdateCellHandler(function(list, index, cell)
		        	local tPet = self._showPetList[index + 1]
		        	if tPet then
		        		cell:updateItem(tPet)
		        	end
		        end)

		        self._tPetListView:setSelectCellHandler(function ( cell, index )
		        
		        	if self._selectCallback then
			    		self._selectCallback( index )
			    	end
			    	self:close()
			    end)

		        self._tPetListView:initChildWithDataLength(#self._showPetList, 0.2)
		    --    self._tPetListView:setSpaceBorder(0, 120)
			end
		end
	end
end

function PetProtectSelectLayer:_doLoadPetList()

	self._showPetList = {}
	local petList = G_Me.bagData.petData:getPetList()
	local fightPetId = G_Me.bagData.petData:getFightPetId()
	for k, v in pairs(petList) do
		if self._showWearOnPet then
			self._showPetList[#self._showPetList + 1] = v
		elseif v.id ~= fightPetId and not G_Me.formationData:isProtectPetByPetId(v.id) 
			and not G_Me.formationData:isSampleNameProtectPetByPetIdExclusivePosId(v.id, self._pos) then
			self._showPetList[#self._showPetList + 1] = v
		end
	end

	local function func(lhs, rhs)
		if lhs.fight_value == rhs.fight_value then
			return lhs.id < rhs.id
		else
			return lhs.fight_value > rhs.fight_value
		end
		
	end
	table.sort(self._showPetList, func)
end

function PetProtectSelectLayer:_hasNoPet()
    local rootWidget = self:getPanelByName("Panel_Content")
    if not self._noPetLayer then
    	self._noPetLayer = require("app.scenes.common.EmptyLayer").createWithPanel(require("app.const.EmptyLayerConst").SELECT_PET, rootWidget)
    else
    	self._noPetLayer:setVisible(true)
    end
end

return PetProtectSelectLayer