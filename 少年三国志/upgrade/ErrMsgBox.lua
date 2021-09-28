--ErrMsgBox.lua
require("upgrade.VersionUtils")

local ErrMsgBox = class("ErrMsgBox", function ( ... )
	return CCSModelLayer:create("ui_layout/common_ErrMsgBox.json")
end)

function ErrMsgBox.showErrorMsgBox( content )
	local errorMsgBox = ErrMsgBox.new(content)
	CCDirector:sharedDirector():getRunningScene():addChild(errorMsgBox, 1000)
end

function ErrMsgBox:ctor( content, ... )
	self:_doInitMsgBox(content)

	self:enableLabelStroke("Label_title", Colors.strokeBrown, 1 )
	self:setBackColor(ccc4(0, 0, 0, 178))
	self:showAtCenter(true)
end

function ErrMsgBox:_doInitMsgBox( content )
	self:regisgerWidgetTouchEvent("Button_close", function ( ... )
		CCDirector:sharedDirector():endToLua()
	end)
	self:regisgerWidgetTouchEvent("Button_continue", function ( ... )
		self:removeFromParentAndCleanup(true)
	end)

	content = content or "[null desc]"
	local text = debug.traceback("", 2)
	if text then 
		content = content..text
	end

	local scrollView = self:getScrollViewByName("ScrollView_content")
	if scrollView and content then 
		local size = scrollView:getSize()
		local realSize = CCSizeMake(size.width - 20, size.height - 20)
		local label = Label:create()
		label:setTextAreaSize(CCSizeMake(realSize.width, 0))
	    label:setFixedWidth(true)
   		label:setFontSize(20)
   		label:setFontName("ui/font/FZYiHei-M20S.ttf")
   		label:setColor(ccc3(0x83, 0x5c, 0x42))
	    label:setText(content)
	    scrollView:addChild(label)

	    local labelSize = label:getSize()
	    if labelSize.height > realSize.height then 
	    	label:setPosition(ccp(size.width/2, labelSize.height/2))
	    	scrollView:setInnerContainerSize(CCSizeMake(realSize.width, labelSize.height))
	    else
	    	label:setPosition(ccp(size.width/2, realSize.height - labelSize.height/2))
	    end
	    scrollView:jumpToTop()
	end

	if not G_Me.userData or G_Me.userData.id < 1 then 
		self:showTextWithLabel("Label_userId", "未登录")
		self:showTextWithLabel("Label_userName", "未登录")
	else 
		self:showTextWithLabel("Label_userId", G_Me.userData.id)
		self:showTextWithLabel("Label_userName", G_Me.userData.name)
	end

	self:showTextWithLabel("Label_time", G_ServerTime:getDataObjectFormat("%m/%d %X"))
	--self:showTextWithLabel("Label_time", os.date("%m/%d %X", os.time()))

	if G_PlatformProxy and G_PlatformProxy:getLoginServer() then 
		self:showTextWithLabel("Label_serverName", G_PlatformProxy:getLoginServer().name)
	else
		self:showTextWithLabel("Label_serverName", "未登录")
	end

    local versionName = GAME_VERSION_NAME 
    local localVersionName = getLocalVersionName()
    if localVersionName ~= "" then
      versionName = versionName .."(".. localVersionName..")"
    end

    self:showTextWithLabel("Label_version", versionName)
end


return ErrMsgBox
