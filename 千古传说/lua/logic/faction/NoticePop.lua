--[[
******帮派公告、宣言编辑界面*******

	-- by quanhuan
	-- 2015/10/28
]]


local NoticePop = class("NoticePop",BaseLayer)

function NoticePop:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.NoticePop")
end

function NoticePop:initUI( ui )

	self.super.initUI(self, ui)

	self.txt_title = TFDirector:getChildByPath(ui, "txt_title")
	self.txt_contect = TFDirector:getChildByPath(ui, "txt_contect")
	self.btn_ok = TFDirector:getChildByPath(ui, "btn_ok")
	self.btn_cancel = TFDirector:getChildByPath(ui, "btn_cancel")

    self.playernameInput = TFDirector:getChildByPath(ui, 'playernameInput')
	self.playernameInput:setCursorEnabled(true)
	self.playernameInput:setVisible(true)
	self.playernameInput:setMaxLengthEnabled(true)
    

	self.btn_ok.logic = self
	self.btn_cancel.logic = self
	
end

function NoticePop:removeUI()
	self.super.removeUI(self)
end

function NoticePop:registerEvents()
	self.super.registerEvents(self)

	self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.okButtonClick))
	self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.cancelButtonClick))    

	local function checkStrLength(str)
		local stringIndex = 1
		local prevStr = ""
		local currStr = ""
		local fontNum = 0
		local strLength = string.len(str)
		
		if strLength <= self.maxLength then
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
            if fontNum > (self.maxLength/2) then
            	return prevStr
            end
            prevStr = currStr
		end  
		return str     
	end 

	local function onTextFieldAttachHandle(input)
		local text = self.txt_contect:getText()
		text = checkStrLength(text)
		self.playernameInput:setText(text)
		self.txt_contect:setText(text)
    end    
    self.playernameInput:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)
    local function onTextFieldChangedHandle(input)
		local text = self.playernameInput:getText()
		text = checkStrLength(text)
		self.playernameInput:setText(text)
		self.txt_contect:setText(text)
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    local function onTextFieldDetachHandle(input)
        local text = self.playernameInput:getText()
		text = checkStrLength(text)
		text = FactionManager:printByte(text)      
        self.txt_contect:setText(text)
        self.playernameInput:setText(text)
        self.playernameInput:closeIME()
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)

    local function spaceAreaClick(sender)
    	self.playernameInput:closeIME()
	end
    self.ui:setTouchEnabled(true)
    self.ui:addMEListener(TFWIDGET_CLICK, spaceAreaClick)
    -- ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end

function NoticePop:removeEvents()
    self.super.removeEvents(self)

	self.btn_ok:removeMEListener(TFWIDGET_CLICK)
	self.btn_cancel:removeMEListener(TFWIDGET_CLICK)

    self.playernameInput:removeMEListener(TFTEXTFIELD_ATTACH)
    self.playernameInput:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    self.playernameInput:removeMEListener(TFTEXTFIELD_DETACH)   
    if self.ui then
    	self.ui:removeMEListener(TFWIDGET_CLICK)
    end
end


function NoticePop:setBtnHandle(okhandle, cancelhandle)

	self.btn_ok.fun = okhandle
	self.btn_cancel.fun = cancelhandle
end

function NoticePop:setTitle( title )

	self.txt_title:setText(title)

end

function NoticePop:setMsg( msg )

	if msg then
		self.txt_contect:setText(msg)
		self.playernameInput:setText(msg)
	else
		self.txt_contect:setText("")
		self.playernameInput:setText("")
	end

end

function NoticePop:setContectMaxLength( length )

	if length then
		self.maxLength = length	
	else
		self.maxLength = 40
	end	

	self.playernameInput:setMaxLength(1024)
end

function NoticePop.okButtonClick(btn)
	
	local self = btn.logic
	AlertManager:close()
	if self.btn_ok.fun then
		local text = self.txt_contect:getText()
		self.btn_ok.fun(text)
	end

end

function NoticePop.cancelButtonClick(btn)

	local self = btn.logic
	AlertManager:close()
	if self.btn_cancel.fun then
		self.btn_cancel.fun()
	end

end



return NoticePop