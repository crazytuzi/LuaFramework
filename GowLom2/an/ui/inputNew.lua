local input, UIInputTypeFlag = nil
slot2 = class("an.input", function (x, y, w, h, max, params)
	local inputLabel = nil

	if not params or not params.UIInputType or params.UIInputType == 1 then
		inputLabel = input.newEditBox_(x, y, w, h, max, params)
		inputLabel.UIInputType = 1
		UIInputTypeFlag = 1
	elseif params.UIInputType == 2 then
		inputLabel = input.newTextField_(x, y, w, h, max, params)
		inputLabel.UIInputType = 2
		UIInputTypeFlag = 2
	end

	return inputLabel
end)
input = slot2
input.ctor = function (self, x, y, w, h, max, params)
	if params.UIInputType == 2 then
		self.getText = self.getString
		self.setText = self.setString
	end

	self.chatItemNum = 0
	self.return_call = params.return_call
	self.getWorldY_call = params.getWorldY_call
	slot8 = y
	slot9 = w
	slot10 = h
	slot11 = max
	slot12 = params
	self.args_ = x

	return 
end
input.newEditBox_ = function (x, y, w, h, max, params)
	local imageNormal = params.image or "res/public/empty.png"
	local imagePressed = params.imagePressed
	local imageDisabled = params.imageDisabled

	if type(imageNormal) == "string" then
		imageNormal = display.newScale9Sprite(imageNormal)
	end

	if type(imagePressed) == "string" then
		imagePressed = display.newScale9Sprite(imagePressed)
	end

	if type(imageDisabled) == "string" then
		imageDisabled = display.newScale9Sprite(imageDisabled)
	end

	local editbox = ccui.EditBox:create(cc.size(w, h), imageNormal, imagePressed, imageDisabled)

	if editbox then
		if max then
			editbox.setMaxLength(editbox, max)
		end

		if params.listener then
			editbox.registerScriptEditBoxHandler(editbox, params.listener)
		else
			local function editboxEventHandler(eventType)
				if (eventType ~= "began" or false) and (eventType ~= "ended" or false) and (eventType ~= "changed" or false) and eventType == "return" and params.return_call then
					params.return_call()

					if params.keyboardEx then
						params.keyboardEx.remove()
					end
				end

				return 
			end

			editbox.registerScriptEditBoxHandler(slot9, editboxEventHandler)
		end

		if x and y then
			editbox.setPosition(editbox, x, y)
		end

		if params.label then
			local labelParams = params.label or {}
			local text = labelParams[1] or ""
			local fontSize = labelParams[2] or display.DEFAULT_TTF_FONT_SIZE
			local strokeSize = labelParams[3] or 0

			editbox.setText(editbox, text)
			editbox.setFontSize(editbox, math.round(fontSize))
		end

		editbox.setFontName(editbox, display.DEFAULT_TTF_FONT)

		if params.password then
			editbox.setInputFlag(editbox, 0)
		end
	end

	return editbox
end
input.newTextField_ = function (x, y, w, h, max, params)
	local textfieldCls = nil
	local editbox = ccui.TextField:create()

	editbox.setPlaceHolder(editbox, params.tip)

	if x and y then
		editbox.setPosition(editbox, x, y)
	end

	if params.listener then
		editbox.addEventListener(editbox, params.listener)
	end

	if cc.size(w, h) then
		editbox.setTextAreaSize(editbox, cc.size(w, h))
		editbox.setTouchSize(editbox, cc.size(w, h))
		editbox.setTouchAreaEnabled(editbox, true)
	end

	editbox.setFontSize(editbox, display.DEFAULT_TTF_FONT_SIZE)

	if params.label then
		local labelParams = params.label or {}
		local text = labelParams[1] or ""
		local fontSize = labelParams[2] or display.DEFAULT_TTF_FONT_SIZE
		local strokeSize = labelParams[3] or 0

		if editbox.setString then
			editbox.setString(editbox, params.text)
		else
			editbox.setText(editbox, params.text)
		end

		editbox.setFontSize(editbox, math.round(fontSize))
	end

	editbox.setFontName(editbox, params.fontName or display.DEFAULT_TTF_FONT)

	if max and max ~= 0 then
		editbox.setMaxLengthEnabled(editbox, true)
		editbox.setMaxLength(editbox, max)
	end

	if params.password then
		editbox.setPasswordEnabled(editbox, true)
	end

	if params.passwordChar then
		editbox.setPasswordStyleText(editbox, params.passwordChar)
	end

	if params.VerticalalignLeft then
		editbox.setTextVerticalAlignment(editbox, 0)
	end

	return editbox
end
input.createcloneInstance_ = function (self)
	return input.new(unpack(self.args_))
end

if UIInputTypeFlag == 1 then
	input.setString = function (self, ...)
		self.setText(self, ...)

		return 
	end
	input.getString = function (self)
		return self.getText(self)
	end
end

input.addText = function (self, str)
	self.setText(self, self.getText(self) .. str)

	return 
end
input.deleteBackward = function (self)
	local text = string.sub(self.getText(self), 1, #self.getText(self) - 1)

	self.setText(self, text)

	return 
end

return input
