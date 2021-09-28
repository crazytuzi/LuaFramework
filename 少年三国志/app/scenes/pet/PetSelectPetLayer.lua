local PetSelectPetItem = require("app.scenes.pet.PetSelectPetItem")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
local PetSelectPetLayer = class("PetSelectPetLayer", UFCCSModelLayer)

function PetSelectPetLayer.show(...)
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
	local p = PetSelectPetLayer.create()
	uf_sceneManager:getCurScene():addChild(p)
	return true
end

function PetSelectPetLayer.create(...)
	return PetSelectPetLayer.new("ui_layout/PetBag_SelectPetLayer.json", nil, ...)
end

function PetSelectPetLayer:ctor(json, param, ...)

	self._showWearOnPet = false
	self._showPetList = {}

	self.super.ctor(self, json, param, ...)

	self._tPetListView = nil

	self:adapterWithScreen()
	self:adapterWidgetHeight("Panel_list", "Panel_260", "", 0, 30)
	self:adapterWidgetHeight("Panel_Content", "Panel_260", "", 14, 0)

	self:_initWidgets()
	self:_initListView()
end

function PetSelectPetLayer:onLayerEnter()
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_CHANGE, self._onPetChange, self)
end

function PetSelectPetLayer:onLayerExit()
	
end

function PetSelectPetLayer:_onPetChange()
	self:close()
end

function PetSelectPetLayer:_initWidgets()

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
		if self._tPetListView then
			self._tPetListView:reloadWithLength(#self._showPetList,0.2)
		end
	end)
end

function PetSelectPetLayer:_closeWindow()
	self:close()
end

function PetSelectPetLayer:_initListView()
	if G_Me.bagData.petData:getPetCount() == 0 then
		self:_hasNoPet()
	else
		self:_doLoadPetList()
		if not self._tPetListView then
			local panel = self:getPanelByName("Panel_list")
			if panel then
				self._tPetListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	        
		        self._tPetListView:setCreateCellHandler(function(list, index)
		            return PetSelectPetItem.new()
		        end)

		        self._tPetListView:setUpdateCellHandler(function(list, index, cell)
		        	local tPet = self._showPetList[index + 1]
		        	if tPet then
		        		cell:updateItem(tPet)
		        	end
		        end)

		        self._tPetListView:initChildWithDataLength(#self._showPetList, 0.2)
		    --    self._tPetListView:setSpaceBorder(0, 120)
			end
		end
	end
end

function PetSelectPetLayer:_doLoadPetList()

	self._showPetList = {}
	local petList = G_Me.bagData.petData:getPetList()
	local fightPetId = G_Me.bagData.petData:getFightPetId()
	for k, v in pairs(petList) do
		if self._showWearOnPet then
			self._showPetList[#self._showPetList + 1] = v
		elseif v.id ~= fightPetId and not G_Me.formationData:isProtectPetByPetId(v.id) then
			self._showPetList[#self._showPetList + 1] = v
		end
	end

	local function func(lhs, rhs)
		return lhs.fight_value > rhs.fight_value
	end
	table.sort(self._showPetList, func)

end

function PetSelectPetLayer:_hasNoPet()
    local rootWidget = self:getPanelByName("Panel_Content")
    if not self._noPetLayer then
    	self._noPetLayer = require("app.scenes.common.EmptyLayer").createWithPanel(require("app.const.EmptyLayerConst").SELECT_PET, rootWidget)
    else
    	self._noPetLayer:setVisible(true)
    end
end

return PetSelectPetLayer