--------------------------------------------------------------------------------------
-- 文件名:	Class_LuaListView.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-28 10:24
-- 版  本:	1.0
-- 描  述:	动态变化的ListView
-- 应  用:   
---------------------------------------------------------------------------------------

--Class_LuaListView
Class_LuaListView = class("Class_LuaListView")
Class_LuaListView.__index = Class_LuaListView

--创建c++对象
function Class_LuaListView:create()
	local classObejcet = Class_LuaListView.new()
	local listview = ListViewEx:create()
	classObejcet:setListView(listview)
	
	return classObejcet
end

--设置名字
function Class_LuaListView:setName(szName)
	if self.widgetListView and self.widgetListView:isExsit() then

		self.widgetListView:setName(szName)
	end
end

--设置大小
function Class_LuaListView:setSize(size)
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:setSize(size)
	end
end

--设置位置
function Class_LuaListView:setPosition(pos)
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:setPosition(pos)
	end
end

--设置方向 LISTVIEW_DIR_HORIZONTAL 为水平
--			   LISTVIEW_DIR_VERTICAL 为垂直
function Class_LuaListView:setDirection(dir)
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:setDirection(dir)
	end
end

--设置最大个数
function Class_LuaListView:setMaxCount(nCount)
	self.nMaxCount = nCount
end

--设置背景颜色
function Class_LuaListView:setBackGroundColor(tbColor)
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:setBackGroundColorType(2) --1 无颜色 2 单色 3渐变
		self.widgetListView:setBackGroundColor(tbColor or ccc3(255,0,0))
		self.widgetListView:setBackGroundColorOpacity(128)
	end
end

--设置模板
function Class_LuaListView:setModel(itemModel)
	self.itemModel = itemModel
	if not itemModel then
        cclog("warning Class_LuaListView:setModel itemModel is nil***********")
    end
	if (self.widgetListView and self.widgetListView:isExsit() and itemModel) then
		self.widgetListView:setItemModel(itemModel)
		self.itemModel = nil
	end
end

--注册更新数据回调函数
function Class_LuaListView:setUpdateFunc(func)
	self.UpdateFunc = func
end

--注册校准回调函数
function Class_LuaListView:setAdjustFunc(func)
	self.AdjustFunc = func
end

--注册滑动结束回调函数
function Class_LuaListView:setAdjustOverFunc(func)
	self.AdjustOverFunc = func
end

--注册选中特殊表现效果回调函数
function Class_LuaListView:setSelectFunc(func)
	self.SelectFunc = func
end


function Class_LuaListView:setUpdateNoteFunc(func)
	self.UpdateNoteFunc = func
end

--如果不传参数则是从第1页开始 否则从传入的参数开始显示
function Class_LuaListView:setCurPageIndex(nPage)
	if(nPage)then
		self.nCurPage = nPage 
	else
		self.nCurPage  = 1
	end
	cclog("==================Class_LuaListView:setCurPageIndex"..nPage)
end

--暂时
function Class_LuaListView:setLayoutType(nType)
end

--设置额外显示的Item个数，即在最大能够看到的listview个数的基础上增增加2倍的nExtraCount
function Class_LuaListView:setExtraItem(nExtraCount)
	self.nExtraCount = nExtraCount
end

SimpleAudioEngine:sharedEngine():preloadEffect("Sound/Select.mp3") 
--设置listview指针
function Class_LuaListView:setListView(listview)
	if(not listview or listview == self.widgetListView)then
		return 
	end
	local nLastTime = API_GetCurrentTime()
	local function onClickListView(pSender,eventType)
		if(ccs.ListViewExType.LISTVIEW_EVENT_ADJUST_CHILD == eventType)then
			if(self.bPlaySound )then
				local nCurTime = API_GetCurrentTime()
				if(math.abs(nCurTime - nLastTime) > 0.1)then
					nLastTime = nCurTime
					g_playSoundEffect("Sound/Select.mp3")
				end
			end
			
			if(self.AdjustFunc)then
				local nIndex =  listview:getUpdateDataIndex()+1
				local curwidget = listview:getUpdateChild()
				self.AdjustFunc(curwidget, nIndex, listview)
				self.adjustWidget = curwidget
			end
		elseif(ccs.ListViewExType.LISTVIEW_ONSELECTEDITEM_START == eventType)then
			if(self.AdjustOverFunc)then
				local nIndex =  listview:getUpdateDataIndex()+1
				local curwidget = listview:getUpdateChild()
				self.AdjustOverFunc(curwidget, nIndex, listview)
			end
		elseif(ccs.ListViewExType.LISTVIEW_EVENT_UPDATE_BEGIN == eventType)then
			if(self.UpdateNoteFunc)then
				self.UpdateNoteFunc(self, eventType)
			end
		elseif(ccs.ListViewExType.LISTVIEW_EVENT_UPDATE_END == eventType)then
			if(self.UpdateNoteFunc)then
				self.UpdateNoteFunc(self, eventType)
			end
		else
			local nIndex =  listview:getUpdateDataIndex()+1

			if(self.UpdateFunc)then
				local curwidget = listview:getUpdateChild()
				self.UpdateFunc(curwidget, nIndex, self)
				if(nIndex == self.nCurPage)then
					self.adjustWidget = curwidget
					if(self.AdjustFunc)then
						self.AdjustFunc(curwidget, nIndex, listview)
					end
					self.nCurPage = nil
				end
			end
		end
	end


	--处理动画回调action
	local function callListViewActionFunc(pSender, eventType)
		if self.actionfunc then
			self.actionfunc(pSender)
		end
	end
	
	listview:addEventListenerListView(onClickListView)
	listview:addActionListener(callListViewActionFunc)

	self.widgetListView = listview
	
	if(self.itemModel)then
		listview:setItemModel(self.itemModel)
		self.itemModel = nil
	end
end

--更新数据
function Class_LuaListView:updateItems(nMaxCount, nBegin, nShowItem)
	self.bPlaySound = nil
	if g_bReturn then
		self:returnItems(nMaxCount, nBegin, nShowItem)
	else
		self.nMaxCount = nMaxCount or self.nMaxCount
		self.nCurPage = nBegin or self.nCurPage or 1
		self.nExtraCount = nShowItem or self.nExtraCount or 1

		if self.widgetListView and self.widgetListView:isExsit() then
			self.widgetListView:updateItems(self.nMaxCount, self.nCurPage,  self.nExtraCount)
			
			local szListViewName = self.widgetListView:getName()
			if g_PlayerGuide:checkCurrentGuideSequenceNode("UpdateItemsEnd", "szListViewName") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
	end

	self.bPlaySound = true
end

--返回时更新数据
function Class_LuaListView:returnItems(nMaxCount, nBegin, nShowItem)
	self.nMaxCount = nMaxCount or self.nMaxCount
	if self.funcReCalc then
		local nCurCardIndex =  self.funcReCalc(self) --
		self.nCurPage = nCurCardIndex - self.nDistance
	--	cclog(self.nCurPage.."=========nCurCardIndex:"..nCurCardIndex)
	else
	--	error("no zuo,no die, no right type, bye bye!")
		self.nCurPage = nBegin or self.nCurPage or 1
		self.nExtraCount = nShowItem or self.nExtraCount or 1
	end
	
	if(self.widgetListView and self.widgetListView:isExsit())then
		self.widgetListView:updateItems(self.nMaxCount, self.nCurPage,  self.nExtraCount)
	end
end

--设置当前点击对象的参数  
--[[	szType 窗口类型，参考Class_LuaListView:returnItems 
		nTargetID（伙伴，装备，等的id）
		nIndex (当前对象在listviewex中的索引)
--]]
function Class_LuaListView:setTargetParam(funcReCalc, nTargetID, nIndex)
	local nInd = 0
	if self.widgetListView and self.widgetListView:isExsit() then
		nInd = self.widgetListView:getFirstChildIndex()
	end
	self.funcReCalc = funcReCalc
	self.nTargetID = nTargetID
	self.nDistance = nIndex - nInd - 1
end

--从给定位置开始转到第一位
function Class_LuaListView:scrollToLeft(nIndex)
	if(self.widgetListView and self.widgetListView:isExsit())then
		self.widgetListView:scrollToLeft(nIndex)
	end
end

--获取listview控件
function Class_LuaListView:getListView()
	return self.widgetListView
end

--清除说有的数据
function Class_LuaListView:removeAllChildren()
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:updateItems(0)
	end
end

--获取子节点的个数
function Class_LuaListView:getChildrenCount()
	local count = 0
	if self.widgetListView and self.widgetListView:isExsit() then
		count = self.widgetListView:getChildrenCount()
	end
	return  count
end

--返回子节点数据
function Class_LuaListView:getChildByIndex(nIndex)
	local wgt = nil
	if self.widgetListView and self.widgetListView:isExsit() then
		wgt = self.widgetListView:getChildByIndex(nIndex)
	end
	return  wgt
end

--根据名字获取控件
function Class_LuaListView:getChildByName(szName)
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:getChildByName(szName)
	end
end 

function Class_LuaListView:getFirstChildIndex()
	local nidx = 1
	if self.widgetListView and self.widgetListView:isExsit() then
		nidx = self.widgetListView:getFirstChildIndex()
	end
	return nidx
end  

function Class_LuaListView:getFirstChild()
	local wgt = nil
	if self.widgetListView and self.widgetListView:isExsit() then
		wgt = self.widgetListView:getFirstChild()
	end
	return  wgt
end  

--[[
typedef enum
{
    LISTVIEW_GRAVITY_LEFT,
    LISTVIEW_GRAVITY_RIGHT,
    LISTVIEW_GRAVITY_CENTER_HORIZONTAL,
    
    LISTVIEW_GRAVITY_TOP,
    LISTVIEW_GRAVITY_BOTTOM,
    LISTVIEW_GRAVITY_CENTER_VERTICAL,
}ListViewGravity;
]]
function Class_LuaListView:setGravity(nGravity)
	self.widgetListView:setGravity(nGravity)
end

function Class_LuaListView:setTouchEnabled(bEnable)
	self.widgetListView:setTouchEnabled(bEnable)
end

function Class_LuaListView:setBounceEnabled(bEnable)
	self.widgetListView:setBounceEnabled(bEnable)
end

function Class_LuaListView:setAdjustEnabled(bEnable)
	self.widgetListView:setAdjustEnabled(bEnable)
end

function Class_LuaListView:setClippingEnabled(bEnable)
	self.widgetListView:setClippingEnabled(bEnable)
end

--滑到最左边
function Class_LuaListView:scrollToLeft(nIndex)
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:scrollToLeft(nIndex)
	end
end

--滑到最边
function Class_LuaListView:scrollToTop()
	if self.widgetListView and self.widgetListView:isExsit() then
		self.widgetListView:scrollToTop()
	end
end

function Class_LuaListView:getLastAdjustWidget()
	return self.adjustWidget
end

function Class_LuaListView:setPlaySound(bPlay)
	self.bPlaySound = bPlaySound
end

function Class_LuaListView:setSliderEnabled(bEnable)
	self.widgetListView:setSliderEnabled(bEnable)
end

function Class_LuaListView:setIgnoreDis(fDis)
	self.widgetListView:setIgnoreDis(fDis)
end

function Class_LuaListView:setScrollSliderTexture(szPic)
	self.widgetListView:setScrollSliderTexture(szPic)
end

function Class_LuaListView:calcSliderPosition()
	self.widgetListView:calcSliderPosition()
end

--返回滚动条img图片
function Class_LuaListView:getScrollSlider()
	return self.widgetListView:getScrollSlider()
end

--增加单个item 动画回调接口
--滑动的时候 会回调每个item
function Class_LuaListView:setScrollingFunc(actionfunc)
	self.actionfunc = actionfunc
end

function Class_LuaListView:isExsit()
    return self.widgetListView:isExsit()
end