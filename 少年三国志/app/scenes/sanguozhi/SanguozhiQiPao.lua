local SanguozhiQiPao = class("SanguozhiQiPao",function ()
	return CCSPageCellBase:create("ui_layout/sanguozhi_SanguozhiQiPao.json")
end)

--[[
	text 		文字
	widget 		控件
	diffY 		y的差值,如果没有就不传
	callback	回调  
]]
function SanguozhiQiPao.add(text,widget,diffY,callback)
	if not widget then
		return
	end
	if diffY == nil or type(diffY) ~= "number" then
		diffY = 0
	end
	text = text or " "

	local qipao = SanguozhiQiPao.new(text,callback)
	qipao:setText(text)
	qipao:setVisible(true)
	local size = widget:getContentSize()
	point = ccp(widget:getPositionX()-0.26*size.width,widget:getPositionY() + size.height/2 + diffY)
	qipao:setPosition(point)
	widget:getParent():addChild(qipao,10)
	return qipao
end

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
function SanguozhiQiPao:ctor(text,callback,...)
	self._isStay = true
	self._callback = callback
	self._itemLabel = self:getLabelByName("Label_itemName")
	if self._itemLabel then
		self._itemLabel:createStroke(Colors.strokeBrown,1)
		self._itemLabel:setText(text and text or " ")
	end
end


function SanguozhiQiPao:setText(text)
	if self._itemLabel then
		self._itemLabel:setText(text and text or " ")
	end
end
--[[
	isStay:播放完之后是否停留在界面
	也可以不传
]]
function SanguozhiQiPao:playQiPao(isStay)
	if isStay ~= nil then
		self._isStay = isStay
	end
	self:getImageViewByName("Image_qipao"):setScale(1)
	self._sayEffect = EffectSingleMoving.run(self:getImageViewByName("Image_qipao"), "smoving_scalein", function(event)
		uf_funcCallHelper:callAfterFrameCount(20, function ( ... ) 
			if self and self._isStay == false then
				if self.setVisible then
					self:setVisible(false)
				end
			end
			if self._callback then
				self._callback()
			end
			end)
		end)
end

return SanguozhiQiPao
