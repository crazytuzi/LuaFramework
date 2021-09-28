--Author:		bishaoqing
--DateTime:		2016-04-26 16:48:46
--Region:		widget控件工厂
local WidgetFactory = class( "WidgetFactory" )

function WidgetFactory:ctor()
	local bInit = true
	self:InitOrDelete(bInit)
end

--这个是用来优化 构造/析构
function WidgetFactory:InitOrDelete( bInit )
	-- body
	-- if IsNodeValid(self.m_pButton) then
	-- 	self.m_pButton:release()
	-- 	self.m_pButton = nil
	-- end

	-- if bInit then
	-- 	self.m_pButton = ccui.Button:create()
	-- 	self.m_pButton:retain();
	-- end

	-- if IsNodeValid(self.m_pImage) then
	-- 	self.m_pImage:release()
	-- 	self.m_pImage = nil
	-- end

	-- if bInit then
	-- 	self.m_pImage = ccui.ImageView:create()
	-- 	self.m_pImage:retain();
	-- end

	-- if IsNodeValid(self.m_pText) then
	-- 	self.m_pText:release()
	-- 	self.m_pText = nil
	-- end

	-- if bInit then
	-- 	self.m_pText = ccui.Text:create()
	-- 	self.m_pText:retain();
	-- end

	-- if IsNodeValid(self.m_pSlider) then
	-- 	self.m_pSlider:release()
	-- 	self.m_pSlider = nil
	-- end

	-- if bInit then
	-- 	self.m_pSlider = ccui.Slider:create()
	-- 	self.m_pSlider:retain();
	-- end
end

function WidgetFactory:CreateNode( ... )
	-- body
	return cc.Node:create()
end

function WidgetFactory:CreateButton(parent, pszFileName, pos, callback,zorder,noswan,noDefaultVoice)
	-- return self.m_pButton:clone();
	return createMenuItem(parent, pszFileName, pos, callback,zorder,noswan,noDefaultVoice)
end

function WidgetFactory:CreateImage(parent, pszFileName, pos, anchor, zOrder, fScale)
	-- local imgRet = self.m_pImage:clone();
	-- if strFilePath then
	-- 	GetUIHelper():LoadTexture(imgRet, strFilePath)
	-- end
	-- return imgRet
	return createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
end

function WidgetFactory:CreateText(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
	-- return self.m_pText:clone();
	return createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
end

function WidgetFactory:CreateProgress(strBgPath, strTimerPath)
	-- return self.m_pProgress:clone();
	local spritebg = cc.Sprite:create(strBgPath)
	local progress1 = cc.ProgressTimer:create(cc.Sprite:create(strTimerPath or "res/common/progress/cj2.png"))
	-- progress1:setPosition(cc.p(158,11))
	progress1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress1:setAnchorPoint(cc.p(0.5,0.5))
	progress1:setBarChangeRate(cc.p(1, 0))
 	progress1:setMidpoint(cc.p(0,1))
 	progress1:setPercentage(0)
 	progress1:setName("progress")
 	spritebg:addChild( progress1 )
 	return spritebg, progress1
end

-- function WidgetFactory:CreateSlider()
-- 	return self.m_pSlider:clone();
-- end

--创建ccscrollview
function WidgetFactory:CreateScrollView( stSize, bHorizontal )
	-- body
	-- 滚动区域
	local stScrollSize = stSize or cc.size(500, 400)
	local stContainnerSize = stScrollSize
	local content = cc.Node:create()
	content:setContentSize(stContainnerSize)

	local scroll = cc.ScrollView:create()
	if bHorizontal then
		scroll:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	else
		scroll:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	end
	scroll:ignoreAnchorPointForPosition(false)
	scroll:setClippingToBounds(true)
	scroll:setBounceable(true)
	scroll:setViewSize(stScrollSize)
	scroll:setContainer(content)
	scroll:updateInset()
	scroll:setContentOffset(cc.p(0, 0))
	scroll:addSlider("res/common/slider.png")
	return scroll
end

function WidgetFactory:OnDispose( ... )
	-- body
	local bInit = false
	self:InitOrDelete(bInit)
end

return WidgetFactory;
