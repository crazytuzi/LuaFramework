
local MsgBox = class("MsgBox", function (param)	
	return  require("utility.ShadeLayer").new()
end)
function MsgBox:ctor(param)

	local size = param.size or CCSizeMake(display.width*0.9, display.height*0.5)
	local baseNode = display.newNode()
	self:addChild(baseNode)
	baseNode:setContentSize(size)

	local content = param.content or ""
    local leftBtnName = param.leftBtnName or ""
    local midBtnName = param.midBtnName or ""
    local rightBtnName = param.rightBtnName or ""



    local leftBtnFunc = param.leftBtnFunc 
    	-- body
    
    local midBtnFunc = param.midBtnFunc
    local rightBtnFunc = param.rightBtnFunc

	local rootProxy = CCBProxy:create()
    self._rootnode = {}

    local rootnode = CCBuilderReaderLoad("public/window_msgBox", rootProxy, self._rootnode,baseNode,size)
    baseNode:setPosition(display.cx, display.cy)
    baseNode:addChild(rootnode, 1)

	
	local bgWidth = size.width
	local bgHeight = size.height

	self._rootnode["content"]:setString(content)

	-- 是否显示关闭按钮
	local showClose = param.showClose or false
	if showClose then
		self._rootnode["backBtn"]:setVisible(true)
	end

	self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
		if( param. directclose == nil ) then
	        if leftBtnFunc ~= nil then
	            leftBtnFunc()
	        end
	    end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
		self:removeSelf()
		end,
	    CCControlEventTouchDown)

	if leftBtnName == "" and midBtnName == "" and rightBtnName == "" then
		midBtnName = "确 定"
    end

	
	self.leftLabel = ui.newBMFontLabel({
		text = leftBtnName,
		x = self._rootnode["leftBtn"]:getContentSize().width*0.51,
		y = self._rootnode["leftBtn"]:getContentSize().height*0.4,
		font = FONTS_NAME.font_btns,
		textAlign = ui.TEXT_ALIGN_CENTER
		})
	self._rootnode["leftBtn"]:addChild(self.leftLabel)

	self.rightLabel = ui.newBMFontLabel({
		text = rightBtnName,
		x = self._rootnode["rightBtn"]:getContentSize().width*0.51,
		y = self._rootnode["rightBtn"]:getContentSize().height*0.4,
		font = FONTS_NAME.font_btns,
		textAlign = ui.TEXT_ALIGN_CENTER
		})
	self._rootnode["rightBtn"]:addChild(self.rightLabel)

	self.midLabel = ui.newBMFontLabel({
		text = midBtnName,
		x = self._rootnode["midBtn"]:getContentSize().width*0.51,
		y = self._rootnode["midBtn"]:getContentSize().height*0.4,
		font = FONTS_NAME.font_btns,
		textAlign = ui.TEXT_ALIGN_CENTER
		})
	self._rootnode["midBtn"]:addChild(self.midLabel)


	if leftBtnName == "" then
		self._rootnode["leftBtn"]:setVisible(false)
	else
		self._rootnode["leftBtn"]:setVisible(true)
		-- self._rootnode["leftBtn"]:setTitleForState(CCString:create(leftBtnName), CCControlStateNormal)
	    self._rootnode["leftBtn"]:addHandleOfControlEvent(function(eventName,sender)
	    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	    	if leftBtnFunc ~= nil then
	            leftBtnFunc()
	        end
            self:removeSelf()
	    end,
	    CCControlEventTouchUpInside)
	end

	if midBtnName == "" then
		self._rootnode["midBtn"]:setVisible(false)
	else
		self._rootnode["midBtn"]:setVisible(true)
		-- self._rootnode["midBtn"]:setTitleForState(CCString:create(midBtnName), CCControlStateNormal)
	    self._rootnode["midBtn"]:addHandleOfControlEvent(function(eventName,sender)
	    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if midBtnFunc ~= nil then
                midBtnFunc()
            end
            self:removeSelf()
	    end,
	    CCControlEventTouchUpInside)
	end

	if rightBtnName == "" then
		self._rootnode["rightBtn"]:setVisible(false)
	else
		self._rootnode["rightBtn"]:setVisible(true)
		-- self._rootnode["rightBtn"]:setTitleForState(CCString:create(rightBtnName), CCControlStateNormal)
	    self._rootnode["rightBtn"]:addHandleOfControlEvent(function(eventName,sender)
	    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            rightBtnFunc()
            self:removeSelf()
	    end,
	    CCControlEventTouchUpInside)
	end

	baseNode:setScale(0.6)
	baseNode:runAction(CCScaleTo:create(0.1, 1))

	
	
end


return MsgBox