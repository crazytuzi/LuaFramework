local SanguozhiMingXingIcon = class("SanguozhiMingXingIcon",function()
	return CCSItemCellBase:create("ui_layout/sanguozhi_MingXingIcon.json")
	end)

function SanguozhiMingXingIcon:ctor(data)
	self._id = data.id
	self._clickFunc = nil

	self._nameLabel = self:getLabelByName("Label_mingxingName")
	self._nameLabel:createStroke(Colors.strokeBrown,1)
	self._nameLabel:setText(data.name)
	self._mingXImage = self:getImageViewByName("Image_mingxing")
	self._mingXImage:loadTexture(G_Path.getSanguozhiIcon(data.seen_icon))
	self:registerWidgetClickEvent("Image_mingxing",function()
		if self._clickFunc ~= nil then
			self._clickFunc()
		end
		end)
end

function SanguozhiMingXingIcon:showSelected(isSelected)
	-- self:showWidgetByName("Image_selected",isSelected)
	-- self:showWidgetByName("Image_normal",not isSelected)
	-- if isSelected then
	-- 	self._mingXImage:setScale(1.2)
	-- else
	-- 	self._mingXImage:setScale(1)
	-- end

	if self.effectNode ~= nil then
		self.effectNode:removeFromParent()
		self.effectNode = nil
	end 
	if isSelected == true then
		local EffectNode = require "app.common.effects.EffectNode"
		self.effectNode = EffectNode.new("effect_mx_light", function(event, frameIndex)
		        end)     
		self.effectNode:play()
		local pt = self.effectNode:getPositionInCCPoint()
		self.effectNode:setPosition(ccp(pt.x, pt.y))
		self.effectNode:setScale(1.4)
		self._mingXImage:addNode(self.effectNode)
	end
end

function SanguozhiMingXingIcon:getId()
	return self._id
end

function SanguozhiMingXingIcon:setOnClickEvent(func)
	self._clickFunc = func
end

function SanguozhiMingXingIcon:showGray(gray)
	if self._mingXImage then
		self._mingXImage:showAsGray(gray)
	end
end


return SanguozhiMingXingIcon