--[[
    土豪发言编辑界面
]]

local TuhaoPopLayer = class("TuhaoPopLayer",BaseLayer)

function TuhaoPopLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.NoticePop")
end

function TuhaoPopLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.txt_title = TFDirector:getChildByPath(ui, "txt_title")
	self.txt_contect = TFDirector:getChildByPath(ui, "txt_contect")
	self.btn_ok = TFDirector:getChildByPath(ui, "btn_ok")
	self.btn_cancel = TFDirector:getChildByPath(ui, "btn_cancel")

    self.playernameInput = TFDirector:getChildByPath(ui, 'playernameInput')
	self.playernameInput:setCursorEnabled(true)
	self.playernameInput:setVisible(true)
	self.playernameInput:setMaxLengthEnabled(true)

    self.txt_times = TFDirector:getChildByPath(ui, "txt_times")
    self.txt_times:setVisible(true)

    self.img_item = TFDirector:getChildByPath(ui, "img_item")
    self.txt_item = TFDirector:getChildByPath(ui, "txt_item")
    self.txt_item:setColor(ccc3(0, 0, 0))
    self.img_item:setScale(0.5)

	self.btn_ok.logic = self
	self.btn_cancel.logic = self
	
end

function TuhaoPopLayer:removeUI()
	self.super.removeUI(self)
end

function TuhaoPopLayer:registerEvents()
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

function TuhaoPopLayer:removeEvents()
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


function TuhaoPopLayer:setBtnHandle(okhandle, cancelhandle)

	self.btn_ok.fun = okhandle
	self.btn_cancel.fun = cancelhandle
end

function TuhaoPopLayer:setTitle( title )

	self.txt_title:setText(title)

end

function TuhaoPopLayer:setMsg( msg )
	if msg then
		self.txt_contect:setText(msg)
		self.playernameInput:setText(msg)
	else
		self.txt_contect:setText("")
		self.playernameInput:setText("")
	end

end

function TuhaoPopLayer:setTimesInfo(type, num, id)
	print("{{{{{{+++, num = ", num)
    if num and type == 1 then  
        self.txt_times:setVisible(true) 
        self.img_item:setVisible(false)
        self.txt_item:setVisible(false)   
        self.txt_times:setText("今日免费剩余" .. num .. "次")
    elseif type == 0 then
        self.txt_times:setVisible(true)
        self.img_item:setVisible(false)
        self.txt_item:setVisible(false)
        self.txt_times:setText(localizable.common_vip_not_tuhao1)
    elseif type == 2 then
        self.txt_times:setVisible(false)
        self.img_item:setVisible(true)
        self.txt_item:setVisible(true)

        local item = ItemData:objectByID(id)
        self.img_item:setTexture(item:GetPath())
        self.txt_item:setText(num)
    end
end

function TuhaoPopLayer:setContectMaxLength( length )

	if length then
		self.maxLength = length	
	else
		self.maxLength = 40
	end	

	self.playernameInput:setMaxLength(1024)
end

function TuhaoPopLayer.okButtonClick(btn)
	
	local self = btn.logic
	AlertManager:close()
	if self.btn_ok.fun then
		local text = self.txt_contect:getText()
		self.btn_ok.fun(text)
	end

end

function TuhaoPopLayer.cancelButtonClick(btn)

	local self = btn.logic
	AlertManager:close()
	if self.btn_cancel.fun then
		self.btn_cancel.fun()
	end

end



return TuhaoPopLayer