--------------------------------------------------------------------------------------
-- 文件名:	CoverLayer.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-6-3 
-- 版  本:	1.0
-- 描  述:	锁屏效果 使屏幕不能点击
-- 应  用:  
---------------------------------------------------------------------------------------

CoverLayer = class("CoverLayer")
CoverLayer.__index = CoverLayer
-- local DelTag = 0x11ff11ff
-------------------------外部接口----------------------
-- function CoverLayer:showWarning()
	-- local pDirector = CCDirector:sharedDirector()
	-- if pDirector:getRunningScene():getChildByTag(DelTag) == nil then
		-- pDirector:getRunningScene():addChild(self.layer, INT_MAX)
	-- end
	-- self.layer:setVisible(true)
	-- self.layer:setTouchEnabled(true)
-- end

-- function CoverLayer:closeCoverLayer()
	-- self.layer:setVisible(false)
	-- self.layer:setTouchEnabled(false)
    -- if self.func then  self.func() end
-- end

-- function CoverLayer:registerFunc(func)
    -- self.func = func
-- end

-- function CoverLayer:initCoverLayer()
    -- self.layer = TouchGroup:create()
    -- self.layer:setTag(DelTag)
	
	-- self.layer:retain() --否则会析构
-- end

-- function CoverLayer:purge()
	-- local pDirector = CCDirector:sharedDirector()
	-- pDirector:getRunningScene():removeChild(self.layer, true)
	-- self.layer = nil
-- end

--遮罩层  falge 可以不传 是在调试时使用 可以看见颜色层  removeFromParentAndCleanup(false)
function CoverLayer:creationCover(widget,falge)
	if not widget then return end
	local pDirector = CCDirector:sharedDirector()
	self.warning_ = widget:getChildAllByName("warning")
	if not self.warning_ then
		self.warning_ =  Layout:create()
		pDirector:getRunningScene():addChild(warning,INT_MAX)
	end
	self.warning_:setSize(CCSize(1280,720))
	self.warning_:setName("warning")
	-- if falge then 
		-- warning:setBackGroundColorType(2) --1 无颜色 2 单色 3渐变
		-- warning:setBackGroundColor(ccc3(255,0,0))
		-- warning:setBackGroundColorOpacity(128)
	-- end
	self.warning_:setTouchEnabled(true)
	if falge then 
		local BtnClose = tolua.cast(widget:getChildAllByName("Button_Return"),"Button")
		BtnClose:setZOrder(INT_MAX)
	end
	return self.warning_
end

function CoverLayer:coverRemove()
	if self.warning_ then 
		self.warning_:removeFromParentAndCleanup(true)
		self.warning_ = nil
	end
end

--------------------------------------------
g_MsgCoverLayer = CoverLayer.new()
-- g_MsgCoverLayer:initCoverLayer()