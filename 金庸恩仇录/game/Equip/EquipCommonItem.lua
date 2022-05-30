local EquipCommonItem = class("EquipCommonItem", function()
	return display.newNode()
end)
function EquipCommonItem:ctor(param)
	self._data = param.data
	local titles = {
	common:getLanguageString("@Intensify"),
	common:getLanguageString("@Baptize"),
	common:getLanguageString("@Refinement")
	}
	if self._type == 1 then
	elseif self._type == 2 then
	elseif self._type == 3 then
	end
	self._height = 120 + #self._data.data * 40
	if self._data.type == 2 then
		self._height = self._height - 40
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("equip/equip_item_common.ccbi", proxy, self._rootnode, self, cc.size(640, self._height))
	node:setAnchorPoint(cc.p(0.5, 1))
	self._rootnode.title_name:setString(common:getLanguageString("@Attribute", titles[self._data.type]))
	self._rootnode.attr_title:setString(common:getLanguageString("@Attribute", titles[self._data.type]))
	for k, v in pairs(self._data.data) do
		self._rootnode["attr_value_0" .. k]:setString(v.name .. ":+" .. v.value)
		self._rootnode["attr_value_0" .. k]:setVisible(true)
		if self._data.type == 2 then
			self._rootnode["attr_value_0" .. k]:setPositionY(self._rootnode["attr_value_0" .. k]:getPositionY() + 40)
		end
	end
	if self._data.type == 2 then
		self._rootnode.attr_title_value:setVisible(false)
		self._rootnode.attr_title_base:setVisible(false)
		self._rootnode.attr_title:setVisible(false)
	else
		self._rootnode.attr_title_value:setString(self._data.level)
		self._rootnode.attr_title_base:setString("/" .. self._data.baselevel)
	end
	self:addChild(node)
	alignNodesOneByAll({
	self._rootnode.attr_title,
	self._rootnode.attr_title_value,
	self._rootnode.attr_title_base
	}, 5)
end

function EquipCommonItem:getHeight()
	return self._height
end

return EquipCommonItem