--HeroJingjieMaterial.lua


local HeroJingjieMaterial = class("HeroJingjieMaterial", UFCCSModelLayer)


function HeroJingjieMaterial.create( ... )
	local heroMaterial = HeroJingjieMaterial.new("ui_layout/HeroShengJie_Material.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(heroMaterial)
end

function HeroJingjieMaterial:ctor( ... )
	self._callback = nil
	self._materialKnights = {}

	self.super.ctor(self, ...)
end

function HeroJingjieMaterial:onLayerLoad( _, _, material, callback )
	self._callback = callback
	self._materialKnights = material or {}

	self:showAtCenter(true)
	self:_initKnightMaterial(material)

	self:registerBtnClickEvent("Button_close", function ( ... )
		self:onBackKeyEvent()
	end)
	self:registerBtnClickEvent("Button_close02", function ( ... )
		self:onBackKeyEvent()
	end)
	self:registerBtnClickEvent("Button_tupo", function ( ... )
		self:_onTupoClick()
	end)
end

function HeroJingjieMaterial:onLayerEnter( ... )
	if not self._materialKnights or #self._materialKnights < 1 then 
		self:close()
		return 
	end

	self:closeAtReturn(true)
end

function HeroJingjieMaterial:onBackKeyEvent( ... )
    self:animationToClose()
	return true
end

function HeroJingjieMaterial:_initKnightMaterial( ... )
	local panel = self:getPanelByName("Panel_awardList")
	if not panel then 
		return 
	end

	local listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    listview:setCreateCellHandler(function ()
        local cell = require("app.scenes.herofoster.HeroJingjieMaterialItem").new()
        return cell
    end)
    listview:setUpdateCellHandler(function ( list, index, cell)
    	if cell then 
    		cell:updateItem(self._materialKnights[index + 1] or 0)
    	end
    end)

    listview:initChildWithDataLength(#self._materialKnights)
end

function HeroJingjieMaterial:_onTupoClick( ... )
	if self._callback then 
		self._callback()
	end
	self:onBackKeyEvent()
end

return HeroJingjieMaterial
