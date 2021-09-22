local GUIPageView = class("GUIPageView", function ()
	return ccui.PageView:create()
end)

function GUIPageView:ctor()
	self._data = nil
	self._callfunc = nil
	self._initPageCall = nil
	self._addRecord = {}--记录是否添加了page
	self._curPageIdx = 0
	self._scrolling = false
	self._scrollListener = nil

	getmetatable(self).addEventListener(self,function(pageView,eventType)
		if eventType == ccui.PageViewEventType.turning then
			if not GameUtilSenior.isObjectExist(pageView) then return end
			self._curPage = pageView:getCurPageIndex()
			self._scrolling = false
			if GameUtilSenior.isFunction(self._scrollListener) then
				self._scrollListener(self,self._scrolling)
			end
			local index = self:getPage(self._curPage).index--实际data中第几个
			self._curPageIdx = index

			if GameUtilSenior.isFunction(self._callfunc) then
				self._callfunc(pageView,self._data[index],index)
			end
			self:addPageByIndex( index-1)
			-- self:addPageByIndex( index)
			self:addPageByIndex( index+1)
			if self._curPage <= 1 then--插入第一个的时候
				self:setCurPageIndex(index)
			end
		end
	end)

	cc(self):addTouchEventListener(function(_,touchtype )
		if touchtype == ccui.TouchEventType.began then
			self._scrolling = true
			if GameUtilSenior.isFunction(self._scrollListener) then
				self._scrollListener(self,self._scrolling)
			end
		end
	end)
	return self
end
--滑动监听
function GUIPageView:addEventListener(func)
	self._callfunc = func
end
--初始化page的
function GUIPageView:addPageInitFunc(func)
	self._initPageCall = func
end

function GUIPageView:addPageUpdateFunc(func)
	if not self.scheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
		local function updatePage(dt)
			if GameUtilSenior.isFunction(self.updatePageView) then
				self.updatePageView(self)
			end
		end
		cc(self):addNodeEventListener(cc.NODE_EVENT, function(event)
			if event.name == "enter" then

	        elseif event.name == "exit" then
	            scheduler:unscheduleScriptEntry(self.scheduler)
	        end
	    end)
		self.scheduler = scheduler:scheduleScriptFunc(updatePage,1/30,false)
	end
	self.updatePageView = func
end

function GUIPageView:addPageByIndex(index)
	local curpageData = self._data[index]
	if not curpageData then return end
	if self._addRecord[index] then return end
	
	local layout = ccui.Layout:create()
	layout.index = index
	layout:setContentSize(self:getContentSize())
	layout:setName("layout"..index)
	if GameUtilSenior.isFunction(self._initPageCall) then
		self._initPageCall(layout,curpageData,index)
	end

	local hasadd = 0
	for i,v in ipairs(self._data) do
		if i == index then break end
		if self._addRecord[i] then
			hasadd = hasadd + 1
		end
	end
	self._addRecord[index] = true
	self:insertPage(layout,hasadd)
	return self
end
---绑定有序表
function GUIPageView:bindData(data)
	self._data = data
	local t = {}
	for i,v in ipairs(data) do
		t[i] = self._addRecord[i] and true or false
	end
	self._addRecord = t;
	return self
end

function GUIPageView:scrollToPage(index)
	if not GameUtilSenior.isTable(self._data) then return end

	self:addPageByIndex(index)

	--必须放到下一帧操作，不然会崩溃
	self:runAction(cca.seq({
		cca.cb(function()
			self:addPageByIndex(index-1)
		end),
		cca.cb(function()
			self:addPageByIndex(index+1)
		end),
		cca.cb(function()
			self._scrolling = true
			local real = self:getRealIndex(index)
			if real and real~=self:getCurPageIndex() then
				getmetatable(self).scrollToPage(self,real)
			else
				self._scrolling = false
			end
			if GameUtilSenior.isFunction(self._scrollListener) then
				self._scrollListener(self,self._scrolling)
			end
		end)
	}))

	return self
end

function GUIPageView:scrollToPrev()
	local curIndex = self:getCurPageIdx()
	if curIndex>1 then
		self:scrollToPage(curIndex-1)
	end
	return self
end

function GUIPageView:scrollToNext()
	local curIndex = self:getCurPageIdx()
	if curIndex<#self._data then
		self:scrollToPage(curIndex+1)
	end
	return self
end

function GUIPageView:getCurPageIdx()
	self._curPage = self:getCurPageIndex()
	local curPage = self:getPage(self._curPage)
	if curPage then
		self._curPageIdx = curPage.index--实际data中第几个
		return self._curPageIdx
	end
	return 0
end

function GUIPageView:getCurPageIndex()
	return getmetatable(self).getCurPageIndex(self)
end

function GUIPageView:setCurPageIndex(index)
	index = GameUtilSenior.bound(1, index, #self._data)
	self:addPageByIndex(index-1)
	self:addPageByIndex(index)
	self:addPageByIndex(index+1)

	local real = self:getRealIndex(index)
	if real then
		self._curPageIdx = index
		getmetatable(self).setCurPageIndex(self,real)

		if GameUtilSenior.isFunction(self._callfunc) then
			self._callfunc(self,self._data[index],index)
		end
	end
	return self
end

function GUIPageView:getRealPage(index)
	local real = self:getRealIndex(index)
	if real then
		return getmetatable(self).getPage(self,real)
	end
	return nil
end

-- 返回实际加载的第几页
function GUIPageView:getRealIndex(index)
	if index<0 or index>#self._data then return false end
	local real = 0
	for i,v in ipairs(self._data) do
		if i >= index then break end
		if self._addRecord[i] then
			real = real+1
		end
	end
	return real
end

function GUIPageView:removePageAtIndex(index)
	local real = self:getRealIndex(index)
	if real then
		self._addRecord[index] = false
		getmetatable(self).removePageAtIndex(self,real)
	end
	return self
end

function GUIPageView:removeAllPages()
	for k,v in pairs(self:getPages()) do
		getmetatable(self).removePage(self,v)
	end
	self._data = nil
	self._addRecord = {}
	self._curPage = nil
	-- self._callfunc = nil
	-- self._initPageCall = nil

	--scrolltopage 未结束的时候会报错，只能循环移除
	-- getmetatable(self).removeAllPages(self)
	return self
end

function GUIPageView:isScrolling()
	return self._scrolling
end

function GUIPageView:addScrollEventListener(func)
	if GameUtilSenior.isFunction(func) then
		self._scrollListener = func
	end
	return self
end

return GUIPageView