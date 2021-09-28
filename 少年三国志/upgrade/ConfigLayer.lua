--ConfigLayer.lua
require("upgrade.VersionUtils")
local ConfigLayer = class("class", UFCCSModelLayer)

function ConfigLayer.initConfig( ... )
	local node = uf_notifyLayer:getDebugNode():getChildByTag(1000)
	if node then 
		node:removeFromParentAndCleanup(true)
	end

	__show_debug_panel_()
	node = uf_notifyLayer:getDebugNode():getChildByTag(1000)
	if not node then 
		return 
	end

	local winSize = CCDirector:sharedDirector():getWinSize()
	local btnConfig = Button:create()
    btnConfig:setTitleFontSize(24)
    btnConfig:setTitleColor(ccc3(0, 255, 0))
    btnConfig:ignoreContentAdaptWithSize(false)
    btnConfig:setSize(CCSizeMake(150, 40))
    btnConfig:setPosition(ccp(120, winSize.height - 15))
    btnConfig:setTouchEnabled(true)
    btnConfig:setName("Config")
    btnConfig:setTitleText("Config")
    node:addWidget(btnConfig)
    node:registerBtnClickEvent("Config", function ( widget, param )
        ConfigLayer.new("ui_layout/common_ConfigLayer.json", Colors.modelColor)
    end)
end

function ConfigLayer:ctor(...)
	self.super.ctor(self, ...)
	self:_initConfigLayer()

	self:showAtCenter(true)
	uf_notifyLayer:getDebugNode():addChild(self)

	self:closeAtReturn(true)
	
	self:_onGuideClick(SHOW_NEW_USER_GUIDE)
	self:_onExceptionClick(SHOW_EXCEPTION_TIP)

    
    local localUpgradeVersionNo = CCUserDefault:sharedUserDefault():getIntegerForKey("upgrade_version", 0)

	self:showTextWithLabel("Label_VersionName_value", GAME_VERSION_NAME .. "," ..  tostring(G_NativeProxy.getUsedMemory()) .."KB")

	self:showTextWithLabel("Label_VersionNo_value", getLocalVersionNo())
	self:showTextWithLabel("Label_LocalVersion_value", localUpgradeVersionNo)

	if not G_Me.userData or G_Me.userData.id < 1 then 
		self:showTextWithLabel("Label_userId_value", "帐户还未登录！")
	else 
		self:showTextWithLabel("Label_userId_value", G_Me.userData.id)
	end

	self:_initWebDebugButton()
end

function ConfigLayer:_initWebDebugButton( ... )
	local btnWebDebug = Button:create()
	btnWebDebug:loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
	btnWebDebug:setSize(CCSizeMake(100, 30))
	btnWebDebug:setScale(0.8)
	    btnWebDebug:setPosition(ccp(400, 55))
	    btnWebDebug:setTouchEnabled(true)
	    btnWebDebug:setName("webDebug")
	    btnWebDebug:setTitleText("webDebug")
	    self:addWidget(btnWebDebug)
	    self:registerBtnClickEvent("webDebug", function ( widget, param )
	        -- require("app.webDebug.WebDebugLayer").show()
	        -- self:close()
	        local debug = require("app.protocalDebug.MyDebugAuto").new()
	        debug:start()
	    end)
end

function ConfigLayer:_initConfigLayer( ... )
	self:registerBtnClickEvent("Button_close", function ( widget )
		self:close()
	end)

	self:registerWidgetClickEvent("Label_Guide", function ( ... )
		self:_onGuideClick(not SHOW_NEW_USER_GUIDE)
	end)
	self:registerWidgetClickEvent("Label_Exception", function ( ... )
		self:_onExceptionClick(not SHOW_EXCEPTION_TIP)
	end)

	self:registerWidgetClickEvent("Button_1", function ( ... )
		self:onEventBtnClick(1)
		--TextureManger:getInstance():dumpCurrentTexture()
	end)
	self:registerWidgetClickEvent("Button_2", function ( ... )
		--CCFileUtils:sharedFileUtils():dumpFilePathCache()
		self:onEventBtnClick(2)
	end)
	self:registerWidgetClickEvent("Button_3", function ( ... )
		self:onEventBtnClick(3)
	end)
	self:registerWidgetClickEvent("Button_4", function ( ... )
		self:onEventBtnClick(4)
	end)
	self:registerWidgetClickEvent("Button_5", function ( ... )
		self:onEventBtnClick(5)
	end)
	self:registerWidgetClickEvent("Button_6", function ( ... )
		self:onEventBtnClick(6)
	end)
	self:registerWidgetClickEvent("Button_exit", function ( ... )
		self:_onExitGame()
	end)
end

function ConfigLayer:onEventBtnClick( tag )
	uf_eventManager:dispatchEvent("config_event_singal", nil, false, tag or 0)

	-- code sample
	-- uf_eventManager:addEventListener("config_event_singal", function ( obj, tag )
 --        __Log("tag=%d", tag)
 --    end, self)
end

function ConfigLayer:_onGuideClick( flag )
	SHOW_NEW_USER_GUIDE = flag

	local label = self:getLabelByName("Label_Guide")
	if label then 
		label:setColor(SHOW_NEW_USER_GUIDE and ccc3(0, 255, 0) or ccc3(255, 0, 0))
		label:setText(SHOW_NEW_USER_GUIDE and "关闭新手引导" or "打开新手引导")
	end
end

function ConfigLayer:_onExceptionClick( flag )
	SHOW_EXCEPTION_TIP = flag

	local label = self:getLabelByName("Label_Exception")
	if label then 
		label:setColor(SHOW_EXCEPTION_TIP and ccc3(0, 255, 0) or ccc3(255, 0, 0))
		label:setText(SHOW_EXCEPTION_TIP and "关闭崩溃提醒" or "打开崩溃提醒")
	end
end

function ConfigLayer:_onExitGame( ... )
	if G_PlatformProxy then 
		G_PlatformProxy:returnToLogin()
	end
end

return ConfigLayer
