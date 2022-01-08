--[[--
	背包控件:

	--By: yuqing
	--2013/11/20
]]

TFBagCtrl = class('TFBagCtrl', function()
	local bag = TFScrollView:create()
	bag.panel = bag:getInnerContainer()
	bag.panel:setLayoutType(TF_LAYOUT_GRID)
	-- bag.panel:setClippingEnabled(true)
	-- bag:addChild(bag.panel)
	bag.children = {}
	return bag
end)

function TFBagCtrl:ctor(val)
end

function TFBagCtrl:create()
	local obj = TFBagCtrl:new()
	return obj
end

function TFBagCtrl:initContro(val)
end

function TFBagCtrl:setColumnPaddings(val)
	if type(val) == 'number' then
		self.panel:setColumnPadding(val)
	else
		for k, v in pairs(val) do
			self.panel:setColumnPadding(v, k)
		end
	end
end

function TFBagCtrl:setRowPaddings(val)
	print(type(val), val)
	if type(val) == 'number' then
		self.panel:setRowPadding(val)
	else
		for k, v in pairs(val) do
			print(k, v)
			self.panel:setRowPadding(v, k)
		end
	end
end

function TFBagCtrl:setRow(nRow)
	self.panel:setRows(nRow)
end

function TFBagCtrl:setColumn(nColumn)
	self.panel:setColumns(nColumn)
end

function TFBagCtrl:setBagSize(size)
	self:setSize(size)
end

function TFBagCtrl:setBagInnerSize(size)
	self:setInnerContainerSize(size)
	self.panel:setSize(size)
end

function TFBagCtrl:addChild(child)
	self.panel:addChild(child)
	child:addMEListener(TFWIDGET_CLICK, function()
		if self.bagGoodsCkickFunc then
			-- TFFunction:call(self.bagGoodsCkickFunc, child)
			self.bagGoodsCkickFunc(child)
		end
	end)
end

return TFBagCtrl
