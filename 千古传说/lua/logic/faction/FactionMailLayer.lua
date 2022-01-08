--[[
******帮派邮件*******

	-- by quanhuan
	-- 2016/4/25
]]


local FactionMailLayer = class("FactionMailLayer",BaseLayer)

function FactionMailLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionMail")
end

function FactionMailLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.btn_send = TFDirector:getChildByPath(ui, "btn_send")
	self.btn_close = TFDirector:getChildByPath(ui, "btn_close")

	self.inputNode1 = TFDirector:getChildByPath(ui, 'playernameInput1')
	self.inputNode1:setCursorEnabled(true)
	self.inputNode1:setVisible(true)
	self.inputNode1:setMaxLengthEnabled(true)
	self.inputNode1:setMaxLength(40)
	self.txtContect1 = TFDirector:getChildByPath(ui, 'txt_contect1')
	self.txtContect1:setText("")
	self.txtTips1 = TFDirector:getChildByPath(ui, 'txt_contect11')

	self.inputNode2 = TFDirector:getChildByPath(ui, 'playernameInput2')
	self.inputNode2:setCursorEnabled(true)
	self.inputNode2:setVisible(true)
	self.inputNode2:setMaxLengthEnabled(true)
	self.inputNode1:setMaxLength(400)
	self.txtContect2 = TFDirector:getChildByPath(ui, 'txt_contect2')
	self.txtContect2:setText("")
	self.txtTips2 = TFDirector:getChildByPath(ui, 'txt_contect21')

	self.btn_send.logic = self
	self.btn_close.logic = self	
	self:resetTxt()
end

function FactionMailLayer:removeUI()
	self.super.removeUI(self)
end

function FactionMailLayer:registerEvents()
	self.super.registerEvents(self)

	self.btn_send:addMEListener(TFWIDGET_CLICK, audioClickfun(self.okButtonClick))
	ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

	local function checkStrLength(str, maxLength)
		local stringIndex = 1
		local prevStr = ""
		local currStr = ""
		local fontNum = 0
		local strLength = string.len(str)
		
		if strLength <= maxLength then
			return str
		end
		
		for i=1,strLength do			
			if stringIndex >= strLength then
				return currStr
			end
			local c = string.sub(str,stringIndex,stringIndex)
			local b = string.byte(c)

			if b >= 240 then
            	currStr = currStr..string.sub(str,stringIndex,stringIndex+3)
            	stringIndex = stringIndex + 4
			elseif b >= 224 then
            	currStr = currStr..string.sub(str,stringIndex,stringIndex+2)
            	stringIndex = stringIndex + 3
			elseif b >= 192 then
                currStr = currStr..string.sub(str,stringIndex,stringIndex+1)
                stringIndex = stringIndex + 2
            else
                currStr = currStr..c
                stringIndex = stringIndex + 1
            end		
            fontNum = fontNum + 1
            if fontNum > (maxLength/2) then
            	return prevStr
            end
            prevStr = currStr
		end  
		return str     
	end 

	local function checkString( str, isTips )
		local len = string.len(str)
		if len < 1 then
			str = nil
		end
		if isTips then
			FactionManager:setFactionMailTips( str )	 
		else
			FactionManager:setFactionMailContent( str )
		end
		self:resetTxt()
	end

	local function onTextFieldAttachHandle(input)
		local text = self.txtContect1:getText()
		text = checkStrLength(text,40)
		self.inputNode1:setText(text)
		self.txtContect1:setText(text)
		checkString(text, true)
    end    
    self.inputNode1:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)
    local function onTextFieldChangedHandle(input)
		local text = self.inputNode1:getText()
		text = checkStrLength(text,40)
		self.inputNode1:setText(text)
		self.txtContect1:setText(text)
		checkString(text, true)
    end
    self.inputNode1:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    local function onTextFieldDetachHandle(input)
        local text = self.inputNode1:getText()
		text = checkStrLength(text,40)
		text = FactionManager:printByte(text)      
        self.txtContect1:setText(text)
        self.inputNode1:setText(text)
        self.inputNode1:closeIME()
        checkString(text, true)
    end
    self.inputNode1:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)

    -----
    local function onTextFieldAttachHandle2(input)
    	print('onTextFieldAttachHandle2')
		local text = self.txtContect2:getText()
		text = checkStrLength(text,400)
		self.inputNode2:setText(text)
		self.txtContect2:setText(text)
		checkString(text, false)
    end    
    self.inputNode2:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle2)
    local function onTextFieldChangedHandle2(input)
		local text = self.inputNode2:getText()
		text = checkStrLength(text,400)
		self.inputNode2:setText(text)
		self.txtContect2:setText(text)
		checkString(text, false)
    end
    self.inputNode2:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle2)
    local function onTextFieldDetachHandle2(input)
        local text = self.inputNode2:getText()
		text = checkStrLength(text,400)
		text = FactionManager:printByte(text)      
        self.txtContect2:setText(text)
        self.inputNode2:setText(text)
        self.inputNode2:closeIME()
        checkString(text, false)
    end
    self.inputNode2:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle2)

    local function spaceAreaClick(sender)
    	self.inputNode1:closeIME()
    	self.inputNode2:closeIME()
    	self:resetTxt()
	end

    self.ui:setTouchEnabled(true)
    self.ui:addMEListener(TFWIDGET_CLICK, spaceAreaClick)
end

function FactionMailLayer:removeEvents()
    self.super.removeEvents(self)

	self.btn_send:removeMEListener(TFWIDGET_CLICK)

    self.inputNode2:removeMEListener(TFTEXTFIELD_ATTACH)
    self.inputNode2:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    self.inputNode2:removeMEListener(TFTEXTFIELD_DETACH)   
    if self.ui then
    	self.ui:removeMEListener(TFWIDGET_CLICK)
    end
end

function FactionMailLayer.okButtonClick(btn)
	
	local self = btn.logic

    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 and myPost ~= 2 then
        toastMessage(localizable.common_no_power)
        return
    end    
	if MainPlayer:getSycee() < 10 then
		toastMessage(localizable.factionMail_noSycee)
		return
	end
	local mailInfo = FactionManager:getFactionMailInfo()
	if not mailInfo.tips then
		toastMessage(localizable.factionMail_noTips)
		return
	end
	if not mailInfo.content then
		toastMessage(localizable.factionMail_noContent)
		return
	end
	FactionManager:requestFactionMail()
end

function FactionMailLayer:resetTxt()
	local mailInfo = FactionManager:getFactionMailInfo()
	if mailInfo.tips then
		self.txtTips1:setVisible(false)
		self.txtContect1:setVisible(true)
		self.txtContect1:setText(mailInfo.tips)
	else
		self.txtTips1:setVisible(true)
		self.txtContect1:setVisible(false)
	end

	if mailInfo.content then
		self.txtTips2:setVisible(false)
		self.txtContect2:setVisible(true)
		self.txtContect2:setText(mailInfo.content)
	else
		self.txtTips2:setVisible(true)
		self.txtContect2:setVisible(false)
	end
end

return FactionMailLayer