-- 
-- zxs
-- 通用气泡
--

local QChatDialog = class("QChatDialog", function()
    	return display.newNode()
   	end)
local QRichText = import(".QRichText")
local QColorLabel = import("...utils.QColorLabel")

local fontH = 22 				-- 文字大小
local gap = 20 			  		-- 边距大小
local offsetW = -35 			-- 气泡框左部偏移
local offsetH = 15				-- 气泡框底部偏移
local TextWH = {
	{7, 2}, {8, 2}, {8, 3}, {9, 3}, {10, 3}, {11, 3}, {11, 4}, {12, 4}, {13, 4},
	{14, 4}, {15, 4}, {15, 5}, {16, 5}, {17, 5}, {18, 5}, {19, 5}, {20, 5}, {20, 6}
}

function QChatDialog:ctor(options)
	self._ccbOwner = {}
	local ccbView = CCBuilderReaderLoad("ccb/Widget_chat_vip.ccbi", CCBProxy:create(), self._ccbOwner)
	self:addChild(ccbView)

	self._size = CCSize(0, 0)
	self:setInfo(options or {})

    self._animationManager = tolua.cast(ccbView:getUserObject(), "CCBAnimationManager")
end

function QChatDialog:setInfo(info)
	-- 多颜色
	self._colorful = info.colorful or false
    self._useRichText = info.useRichText or false

	if info.desc then
		self:setString(desc)
	end
	if info.color then
		self:setColor(color)
	end
	if info.scaleX then
		self:setScaleX(scaleX)
	end
end

function QChatDialog:getTextWH(length)
	for i, v in ipairs(TextWH) do
		if length <= fontH*v[1]*v[2] then
			return v
		end
	end
	return TextWH[1]
end

function QChatDialog:setString(desc)
	self._animationManager:stopAnimation()
	self._animationManager:runAnimationsForSequenceNamed("Default Timeline")

	local length = q.wordLen(desc, fontH, fontH)
	local textWH = self:getTextWH(length)
	local width = textWH[1]*fontH
	local height = textWH[2]*(fontH+4)
	
	self._size = CCSize(width+gap*2, height+gap*2)
    if self._colorful then
	    local newMessage = desc
	    local faceTble = QColorLabel.FACE_NAME
	    for index, v in ipairs(faceTble) do
	        for w in string.gmatch(newMessage, v) do
	            newMessage = string.gsub(newMessage or "", w, "#"..index)
	        end
	    end
    	local faceStr = QColorLabel:parseStringToFace(newMessage,c,nil,true)
    	local richText = QRichText.new(faceStr, width+6, {defaultSize = fontH, stringType = 1})
		richText:setAnchorPoint(ccp(0.5,0.5))
		self._ccbOwner.node_desc:removeAllChildren()
		self._ccbOwner.node_desc:addChild(richText)
		self._ccbOwner.node_desc:setPosition(ccp(self._size.width/2+offsetW, (richText:getContentSize().height + gap*2)/2+offsetH))
    	self._ccbOwner.text_bg:setContentSize(CCSize(self._size.width,richText:getContentSize().height + gap*2))
		self._ccbOwner.tf_desc:setString("")
    elseif self._useRichText then
        local richText = QRichText.new(desc, width+6, {defaultSize = fontH, stringType = 1})
        richText:setAnchorPoint(ccp(0.5,0.5))
        self._ccbOwner.node_desc:removeAllChildren()
        self._ccbOwner.node_desc:addChild(richText)
        self._ccbOwner.node_desc:setPosition(ccp(self._size.width/2+offsetW, (richText:getContentSize().height + gap*2)/2+offsetH))
        self._ccbOwner.text_bg:setContentSize(CCSize(self._size.width,richText:getContentSize().height + gap*2))
        self._ccbOwner.tf_desc:setString("")
	else
	    self._ccbOwner.tf_desc:setString(desc)
	    self._ccbOwner.tf_desc:setDimensions(CCSize(width+6, height+10))--这里多加了10个像素，防止某些适配显示不全，如iPhoneX
	    self._ccbOwner.tf_desc:setPosition(ccp(self._size.width/2+offsetW, self._size.height/2+offsetH))
    	self._ccbOwner.text_bg:setContentSize(self._size)
	end
end

function QChatDialog:setScaleX(scaleX)
	self._ccbOwner.node_chat:setScaleX(scaleX)
	self._ccbOwner.tf_desc:setScaleX(scaleX)
	self._ccbOwner.node_desc:setScaleX(scaleX)
end

function QChatDialog:setColor(color)
	self._ccbOwner.tf_desc:setColor(color)
end

function QChatDialog:setDuration(duration)
    self._animationManager:stopAnimation()
	self._animationManager:runAnimationsForSequenceNamed("show")
    self._ccbOwner.node_chat:setScale(0)

    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.06, 1.1))
    array:addObject(CCScaleTo:create(0.04, 1.0))
    array:addObject(CCDelayTime:create(math.max(0, duration - 0.1 * 2)))
    array:addObject(CCScaleTo:create(0.04, 1.1))
    array:addObject(CCScaleTo:create(0.06, 0))
    self._ccbOwner.node_chat:runAction(CCSequence:create(array))
end

function QChatDialog:getContentSize()
	return self._size
end


return QChatDialog
