--------------------------------------------------------------------------------------
-- 文件名:	NetWorkWarning.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-3-18 20:51
-- 版  本:	1.0
-- 描  述:	网络连接提示界面
-- 应  用:  
---------------------------------------------------------------------------------------

NetWorkWarning = class("NetWorkWarning")--, function() return CCLayer:create() end
NetWorkWarning.__index = NetWorkWarning

local DelTag = 0x11ff11ff
local CoverTag = 0xff01ff11

local AnimaFile = "NectworkConnecting"

function NetWorkWarning:ctor()
	self.Activation = true
end

function NetWorkWarning:setActivation(bActivation)
	self.Activation = bActivation
end

-------------------------外部接口----------------------
--截取界面消息 bhide 为 nil or fasle 显示八卦
function NetWorkWarning:showWarningText(bhide)
	if not self.Activation then
		cclog("NetWorkWarning:showWarningText not Activation")
		return false
	end

	if bhide then --不显示八卦图
		self:ShowCover()
	else
		local pDirector = CCDirector:sharedDirector()

		if pDirector:getRunningScene():getChildByTag(DelTag) == nil then
			self:purge()

			if self:initNetWorkWarning() then
				pDirector:getRunningScene():addChild(self.layer, INT_MAX)
			end
		end

		if g_OnExitGame then
			if self.layer and self.layer:isExsit() then
				self.layer:setVisible(true)
				self.layer:setTouchEnabled(true)
			end
		else
			if self.layer then
				self.layer:setVisible(true)
				self.layer:setTouchEnabled(true)
			end
		end
		

		if self.userAnimation then
			self.userAnimation:playWithIndex(0)
		end
	end
	cclog("NetWorkWarning:showWarningText")
	return true
end

function NetWorkWarning:closeNetWorkWarning()

	self:CloseCover()

	if g_OnExitGame then
		if self.layer and self.layer:isExsit() then
			self.layer:setVisible(false)
			self.layer:setTouchEnabled(false)
		end
	else
		if self.layer then
			self.layer:setVisible(false)
			self.layer:setTouchEnabled(false)
		end
	end
	

    if self.func then
        self.func()
    end

    cclog("NetWorkWarning:closeNetWorkWarning")
end

function NetWorkWarning:registerFunc(func)
    self.func = func
end

-----------------------内部接口-------------------------------
function NetWorkWarning:initNetWorkWarning()
    self.layer = TouchGroup:create()
    self.layer:setTag(DelTag)

    self.userAnimation = nil
    self.armature = nil

    local widget = GUIReader:shareReader():widgetFromJsonFile("Game_NetworkConnect.json")
    if not widget then
    	self.layer  = nil
    	return false
    end

    self.layer:addWidget(widget)  
    
    local armature,Animation = g_CreateCoCosAnimation("NectworkConnecting", nil, 5)	
    self.userAnimation = Animation
    self.armature = armature
    if not armature then
    	self.layer  = nil
    	return false
    end

	armature:setPosition(VisibleRect:center())
	widget:addNode(armature)
	self.userAnimation:playWithIndex(0)

	widget:setTouchEnabled(true)
	self.layer:retain() --必须这样 否则会析构

	--
	self.layout = TouchGroup:create()
	self.layout:setTag(CoverTag)
	local Panel_Warning =  Widget:create()
	Panel_Warning:retain()
	Panel_Warning:ignoreContentAdaptWithSize(false)
	Panel_Warning:setContentSize(CCSize(1280,720))
	Panel_Warning:setSize(CCSize(1280,720))
	Panel_Warning:setAnchorPoint(ccp(0,0))
	Panel_Warning:setTouchEnabled(true)
	Panel_Warning:setName("Panel_Warning")

	self.layout:addWidget(Panel_Warning)
	self.layout:retain()

	return true
end

function NetWorkWarning:purge()
	local pDirector = CCDirector:sharedDirector()
	pDirector:getRunningScene():removeChild(self.layer, true)
	self.layer = nil

	pDirector:getRunningScene():removeChild(self.layout, true)
	self.layout = nil
end

--截取屏幕消息 看不见八卦图的 
function NetWorkWarning:ShowCover()
	local pDirector = CCDirector:sharedDirector()
	if pDirector:getRunningScene():getChildByTag(CoverTag) == nil then
		cclog("添加＝＝＝＝＝＝＝＝＝NetWorkWarning:ShowCover()")
		pDirector:getRunningScene():addChild(self.layout, INT_MAX )
		self.layout:setTouchPriority(0)
	end

	self.layout:setVisible(true)
	self.layout:setTouchEnabled(true)

	cclog("=========NetWorkWarning:ShowCover============")
end


function NetWorkWarning:CloseCover()
	if g_OnExitGame then
		if self.layout and self.layout:isExsit() then
			self.layout:setVisible(false)
			self.layout:setTouchEnabled(false)
		end
	else
		if self.layout then
			self.layout:setVisible(false)
			self.layout:setTouchEnabled(false)
		end
	end
	
	cclog("=========NetWorkWarning:CloseCover============")
end

--------------------------------------------
g_MsgNetWorkWarning = nil
local function CreateNetWarning()
	g_MsgNetWorkWarning = NetWorkWarning.new()
	g_MsgNetWorkWarning:initNetWorkWarning()
end

CreateNetWarning()