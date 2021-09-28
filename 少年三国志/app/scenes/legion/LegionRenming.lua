--LegionRenming.lua


local LegionRenming = class("LegionRenming", UFCCSModelLayer)

function LegionRenming.show( posx, posy, position, func )
	local renming = LegionRenming.new("ui_layout/legion_Rengming.json", nil, posx, posy, position, func)
	uf_sceneManager:getCurScene():addChild(renming)
end

function LegionRenming:ctor( ...)
	self.super.ctor(self, ...)
end

function LegionRenming:onLayerLoad( json, fun, posx, posy, position, func, ... )
	self._cbFunc = func

	self:adapterWithScreen()
	
	local widget = self:getWidgetByName("Image_1")
	if widget then 
		widget:setPositionXY(posx, posy)
	end

	self:closeAtReturn(true)
	position = position or 0
	
	self:attachImageTextForBtn("Button_fu_tuanzhang", "Image_4")

	self:showWidgetByName("Button_fu_tuanzhang", position ~= 2)
	self:showWidgetByName("Button_no_fu_tuanzhang", position == 2)

	self:registerBtnClickEvent("Button_yj_tuanzhang", handler(self, self._onYJTuanZhangClick))
	self:registerBtnClickEvent("Button_fu_tuanzhang", handler(self, self._onFuTuanZhangClick))
	self:registerBtnClickEvent("Button_no_fu_tuanzhang", handler(self, self._onNoFuTuanZhangClick))
end

function LegionRenming:onLayerEnter( ... )
	self:setClickClose(true)
end

function LegionRenming:_onYJTuanZhangClick( ... )
	if self._cbFunc then 
		self._cbFunc(1)
	end
	self:close()
end

function LegionRenming:_onFuTuanZhangClick( ... )
	if self._cbFunc then 
		self._cbFunc(2)
	end
	self:close()
end

function LegionRenming:_onNoFuTuanZhangClick( ... )
	if self._cbFunc then 
		self._cbFunc(3)
	end
	self:close()
end

function LegionRenming:onClickClose( ... )
	self:close()
	return true
end

return LegionRenming

