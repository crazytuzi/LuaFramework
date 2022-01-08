TPageView = class('TPageView',function()
	local pageView = TFPageView:create()
	return pageView
end)

function TPageView:ctor(val)
	self.tindex = 1
	self.ttail = 1
	self.thead = 1
	self.tlength = 1
	self.tArray = TFArray:new()
end

function TPageView:create()
	local obj = TPageView:new()
	obj:addMEListener(TFPAGEVIEW_CHANGED, function ()
		obj:ChangeAddPage()
		if obj.ChangeFunc then
			obj.ChangeFunc()
		end
	end)
	return obj
end

function TPageView:initContro(val)
end

function TPageView:setMaxLength(val)
	self.tlength = val
end

function TPageView:InitIndex( index )
	self.tindex = index

	if self.tindex < 1 then
		self.tindex = 1
	end

	if self.tindex > self.tlength then
		self.tindex = self.tlength
	end
	local needScroll = false

	local page1 = self.AddFunc(self.tindex)
	self:addPage(page1)
	self.tArray:push(page1)

	if self.tindex >= self.tlength then
		self.ttail = self.tindex
	else
		self.ttail = self.tindex + 1
		local page = self.AddFunc(self.ttail)
		self:addPage(page)
		self.tArray:push(page)
	end

	if self.tindex <= 1 then
		self.thead = 1
	else
		self.thead = self.tindex - 1
		local page = self.AddFunc(self.thead)
		self:insertPage(page,0)
		self.tArray:pushFront(page)
		self:scrollToPage(self:getCurPageIndex())
	end
end

function TPageView:setAddFunc(func)
	self.AddFunc = func
end

function TPageView:setChangeFunc(func)
	self.ChangeFunc = func
end

function TPageView:ChangeAddPage()
	local _index = self:_getCurPageIndex()
	if _index == self.thead and _index > 1 then
		self.thead = self.thead - 1
		local page = self.AddFunc(self.thead)
		self:insertPage(page,0)
		self.tArray:pushFront(page)
		self:scrollToPage(self:getCurPageIndex())
	end

	if _index == self.ttail and _index < self.tlength then
		self.ttail = self.ttail + 1
		local page = self.AddFunc(self.ttail)
		self:addPage(page)
		self.tArray:push(page)
	end
end

function TPageView:_getCurPageIndex()
	return self.thead + self:getCurPageIndex()
end


function TPageView:_removeAllPages()
	self:clearAllPages()
	self.tindex = 1
	self.ttail = 1
	self.thead = 1
	self.tlength = 1
	self.tArray:clear()
end

return TPageView