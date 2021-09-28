--------------------------------------------------------------------------------------
-- 文件名:	Class_LuaPageView.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-28 10:24
-- 版  本:	1.0
-- 描  述:	动态变化的pageview
-- 应  用:  
---------------------------------------------------------------------------------------

--Class_LuaPageView
Class_LuaPageView = class("Class_LuaPageView")
Class_LuaPageView.__index = Class_LuaPageView

function Class_LuaPageView:setPageIndex(widgetPageIndex)
	self.widgetPageIndex = widgetPageIndex
end

function Class_LuaPageView:setItemMaxCount(nCount)
	self.nMaxCount = nCount
end

function Class_LuaPageView:setModel(itemModel, forwardwidget, nextwidget, nStartScaleX, nStartScaleY, bIsNotFade)
	self.itemModel = itemModel
	if self.itemModel and self.itemModel:isExsit() then
		self.itemModel:retain()
	end

	self.forwardwidget = forwardwidget
	self.nextwidget = nextwidget
	if self.forwardwidget then
		LandRActionButton(self.forwardwidget, nil, nStartScaleX, nStartScaleY, bIsNotFade)
		self.forwardwidget:setTouchEnabled(true)
		local function onClickForward(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
				if self.widgetPageView and self.widgetPageView:isExsit() then
					local nCurPageIndex = self.widgetPageView:getCurPageIndex()
					self.widgetPageView:setTouchMoveDir(PAGEVIEW_TOUCHRIGHT)
					self.widgetPageView:scrollToPage(nCurPageIndex-1)
				end
			end
		end
		self.forwardwidget:addTouchEventListener(onClickForward)
	end
	if self.nextwidget then
		LandRActionButton(self.nextwidget, nil, nStartScaleX, nStartScaleY, bIsNotFade)
		self.nextwidget:setTouchEnabled(true)
		local function onClickNext(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
				if self.widgetPageView and self.widgetPageView:isExsit() then
					local nCurPageIndex = self.widgetPageView:getCurPageIndex()
					self.widgetPageView:setTouchMoveDir(PAGEVIEW_TOUCHLEFT)
					self.widgetPageView:scrollToPage(nCurPageIndex+1)
				end
			end
		end
		self.nextwidget:addTouchEventListener(onClickNext)
	end
end


function Class_LuaPageView:registerClickEvent(func)
	self.ClickEventFuc = func
end

function Class_LuaPageView:registerUpdateFunction(func)
	self.UpdateFunc = func
end

--如果不传参数则是从第1页开始 否则从传入的参数开始显示
function Class_LuaPageView:setCurPageIndex(nPage)
	if(nPage)then
		self.nPage = nPage 
	else
		self.nPage  = 1
	end
	
	cclog("==setCurPageIndex=="..self.nPage )
end

--只能往右移动
function Class_LuaPageView:processBegin(nPage)
	if(self.widgetPageView:getTouchMoveDir() == PAGEVIEW_TOUCHRIGHT )then
	--	cclog("==========right============")
		return
	end
--	cclog(self.nToUpdatePage.."==========right============"..nPage)
	if(nPage == 3)then --说明已经到第三页了 需要初始化下一页了
		self.nStatus = 2 --状态的转换
		local widgetPage = self.widgetPageView:getPage(0) --第一个替换
		widgetPage:retain()
		self.nToUpdatePage = 3
		self.widgetPageView:removePage(widgetPage)
		self.widgetPageView:addPage(widgetPage)
		widgetPage:release()
		--放到下一帧执行 20150701 by zgj
		--g_Timer:pushTimer(0,function ()
			self.UpdateFunc(widgetPage, self.nToUpdatePage +1)
		--end)
	end
end

--可以左右移动
function Class_LuaPageView:processCenter(nPage)
	if(self.widgetPageView:getTouchMoveDir() == PAGEVIEW_TOUCHLEFT)then --右移动
		if self.nToUpdatePage + 1 == self.nMaxCount  then --最大一个的时候不需要处理
			self.nStatus = 3 --状态的转换
			self.nToUpdatePage = self.nMaxCount - 2
		else--说明在中间某一页
			local widgetPage = self.widgetPageView:getPage(0) --第三个替换
			widgetPage:retain()
			self.nToUpdatePage = self.nToUpdatePage  + 1
			
			self.widgetPageView:removePage(widgetPage)
			self.widgetPageView:addPage(widgetPage)
			widgetPage:release()
			g_Timer:pushTimer(0,function ()
				self.UpdateFunc(widgetPage, self.nToUpdatePage +1)
			end)
			
		end
	else
		if self.nToUpdatePage  == 2  then --最大一个的时候不需要处理
			self.nStatus = 1 --状态的转换
			self.nToUpdatePage = 3
	--		cclog("	转换状态 1 "..self.nToUpdatePage)
		else--说明在中间某一页
			local widgetPage = self.widgetPageView:getPage(2) --第三个替换
			widgetPage:retain()
			self.nToUpdatePage = self.nToUpdatePage  - 1
			self.widgetPageView:removePage(widgetPage)
			self.widgetPageView:insertPageToHead(widgetPage)
			widgetPage:release()
			g_Timer:pushTimer(0,function ()
				self.UpdateFunc(widgetPage, self.nToUpdatePage -1)
			end)
			
		end
	end
	
--	cclog(self.nStatus.."==processCenter=="..self.nToUpdatePage)
end

--只能左移动
function Class_LuaPageView:processEnd(nPage)
	if(self.widgetPageView:getTouchMoveDir() == PAGEVIEW_TOUCHLEFT )then
	--	cclog("==========left============")
		return
	end
	--说明滚动到第一页了 需要初始化前一页
	if(nPage == 1)then --说明已经到第三页了 需要初始化下一页了
		self.nStatus = 2 --状态的转换
		local widgetPage = self.widgetPageView:getPage(2) --第三个替换
		widgetPage:retain()
		self.nToUpdatePage = self.nMaxCount - 2
		self.widgetPageView:removePage(widgetPage)
		self.widgetPageView:insertPageToHead(widgetPage)
		widgetPage:release()
		g_Timer:pushTimer(0,function ()
			self.UpdateFunc(widgetPage, self.nToUpdatePage - 1)
		end)
	end
end

function Class_LuaPageView:getCurPageIndex()
	if(self.nStatus == 1)then
		local curPage = widgetPageView:getCurPageIndex() + 1
		return curPage
	elseif(self.nStatus == 2)then
		return self.nToUpdatePage
	else
		local curPage = widgetPageView:getCurPageIndex() + 1
		return self.nMaxCount + curPage - 2
	end
end

function Class_LuaPageView:SetWidgetVisible()
	if self.forwardwidget then
		if self:IsFirstPage() then
			self.forwardwidget:setVisible(false)
		else
			self.forwardwidget:setVisible(true)
		end
		--self.forwardwidget:setVisible(not self:IsFirstPage() )
	end
	
	if self.nextwidget then
		if self:IsEndPage() then
			self.nextwidget:setVisible(false)
		else
			self.nextwidget:setVisible(true)
		end
	end
end

function Class_LuaPageView:turningEvent()
    if(self.ClickEventFuc)then
		self.ClickEventFuc(widgetPageView, self:getCurPageIndex())
	end
end

--设置pageview指针
function Class_LuaPageView:setPageView(widgetPageView)
	---PageView 处理函数
	local function onClickPageViewEventDelete()
		local curPage = widgetPageView:getCurPageIndex() + 1
		if(self.widgetPageIndex)then
			self.widgetPageIndex:setStringValue(string.format("%d=%d", curPage, nMax))
		end
		
		if(not self.nToUpdatePage)then
			return
		end
		
		if(self.nStatus == 1)then
			self:processBegin(curPage)
		elseif(self.nStatus == 2)then
			self:processCenter(curPage)
		else
			self:processEnd(curPage)
		end
	end

	local function onPageViewEvent(pSender, eventType)
		if eventType == ccs.PageViewEventType.turning then
			onClickPageViewEventDelete()
			self:SetWidgetVisible() 
            self:turningEvent()     
		end
	end
	
	widgetPageView:addEventListenerPageView(onPageViewEvent)
	widgetPageView:setTouchEnabled(true)
	widgetPageView:removeAllPages()
	
	self.widgetPageView = widgetPageView
	
	widgetPageView:setEnablePlaySound(true)
end

function Class_LuaPageView:registerPageView(widgetPageView)
	self:setPageView(widgetPageView)
	self:updatePageView()
end

function Class_LuaPageView:getCurPageIndex()
	if(not self.nStatus or	self.nStatus == 1)then
		return self.widgetPageView:getCurPageIndex() + 1
	elseif(self.nStatus == 2)then
		return self.nToUpdatePage
	else
		return self.widgetPageView:getCurPageIndex() + self.nToUpdatePage
	end
end

function Class_LuaPageView:getCurPage()
	local nCurIndex = self.widgetPageView:getCurPageIndex()
	return self.widgetPageView:getPage(nCurIndex)
end

function Class_LuaPageView:scrollToPage(nPage)
	return self.widgetPageView:scrollToPage(nPage)
end

function Class_LuaPageView:removeAllPages()
	return self.widgetPageView:removeAllPages()
end

function Class_LuaPageView:ReleaseItemModle()
	if self.itemModel and self.itemModel:isExsit() then
		self.itemModel:release()
		cclog("=========Class_LuaPageView:ReleaseItemModle()===========")
	end
end

function Class_LuaPageView:IsFirstPage()
	return self:getCurPageIndex() == 1
end

function Class_LuaPageView:IsEndPage()
	return self:getCurPageIndex() == self.nMaxCount
end

function Class_LuaPageView:updatePageView(nMaxCount)
	self.widgetPageView:removeAllPages()
	self.nMaxCount = nMaxCount or self.nMaxCount 
	self.nToUpdatePage = nil
	self.nStatus = nil
	if(not self.nMaxCount or self.nMaxCount <= 0)then--说明没有数据
		return
	end
	
	--模板必须是Layout类型的
	local function createPage()
		local page = self.itemModel:clone()
		if self.itemModel:getDescription() ~= "Layout" then
		--	page:setName("PV_Layout_Child")
			return self.widgetPageView:addWidgetToPage(page, self.widgetPageView:getChildrenCount(), true)
		else
			self.widgetPageView:addPage(tolua.cast(page, "Layout"))
		end
		return page
	end
	
	self.nPage = self.nPage or 1
	if(self.nMaxCount == 1)then--只有一个，不需要动态创建
		self.UpdateFunc(createPage(), 1)
	elseif(self.nMaxCount == 2)then--只有两个
		self.UpdateFunc(createPage(), 1)
		self.UpdateFunc(createPage(), 2)
			
		if(self.nPage ~= 1)then
			self.widgetPageView:setToPage(1)
		end
	elseif(self.nMaxCount == 3)then--只有三个
		self.UpdateFunc(createPage(), 1)
		self.UpdateFunc(createPage(), 2)
		self.UpdateFunc(createPage(), 3)	
		self.widgetPageView:setToPage(self.nPage - 1)
	else
		if(self.nPage == 1)then--说明在第一页
			self.nStatus = 1
			self.nToUpdatePage = 3
			self.UpdateFunc(createPage(), 1)
			self.UpdateFunc(createPage(), 2)
			self.UpdateFunc(createPage(), 3)	
		elseif(self.nPage == self.nMaxCount)then--说明在最后一页
			self.UpdateFunc(createPage(), self.nPage - 2)
			self.UpdateFunc(createPage(), self.nPage - 1)
			self.UpdateFunc(createPage(), self.nPage)	
			
			self.widgetPageView:setToPage(2)
			self.nToUpdatePage = self.nMaxCount - 2
			self.nStatus = 3
		else--说明在中间某一页
			self.UpdateFunc(createPage(), self.nPage - 1)
			self.UpdateFunc(createPage(), self.nPage )
			self.UpdateFunc(createPage(), self.nPage + 1)	
			
			self.widgetPageView:setToPage(1)
			if(self.nPage == 2)then
				self.nStatus = 1
				self.nToUpdatePage = 3
			elseif(self.nPage == self.nMaxCount - 1)then
				self.nToUpdatePage = self.nMaxCount - 2
				self.nStatus = 3
			else
				self.nToUpdatePage = self.nPage
				self.nStatus = 2
			end
		end
	end
	
	self:SetWidgetVisible()
	self.widgetPageView:resetPageIndex()
    self:turningEvent()
end