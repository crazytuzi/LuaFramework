local NormalButton = {}
NormalButton.TYPE_NORMAL = 1
NormalButton.TYPE_BUBBLE = 2
NormalButton.TYPE_DARKER = 3
local btnContentsize
function NormalButton.new(params)
	local listener = params.listener
	local button
	dump(params.btnType)
	params.btnType = params.btnType or NormalButton.TYPE_NORMAL
	function params.listener(tag)
		if params.prepare then
			params.prepare()
		end
		button:setEnabled(false)
		local function normal1(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			local scaleX = button:getScaleX() * (size.width + offset) / size.width
			local scaleY = button:getScaleY() * (size.height + offset) / size.height
			transition.scaleTo(button, {
			scaleX = scaleX,
			scaleY = scaleY,
			time = time,
			onComplete = onComplete
			})
			if offset < 0 then
				button:setOpacity(150)
			else
				button:setOpacity(255)
			end
		end
		local function normal2(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			transition.scaleTo(button, {
			scaleX = 1,
			scaleY = 1,
			time = time,
			onComplete = onComplete
			})
		end
		local function zoom1(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			local scaleX = button:getScaleX() * (size.width + offset) / size.width
			local scaleY = button:getScaleY() * (size.height - offset) / size.height
			transition.moveTo(button, {
			y = y - offset,
			time = time
			})
			transition.scaleTo(button, {
			scaleX = scaleX,
			scaleY = scaleY,
			time = time,
			onComplete = onComplete
			})
		end
		local function zoom2(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			transition.moveTo(button, {
			y = y + offset,
			time = time / 2
			})
			transition.scaleTo(button, {
			scaleX = 1,
			scaleY = 1,
			time = time,
			onComplete = onComplete
			})
		end
		local function dark1(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			button:setOpacity(100)
			transition.scaleTo(button, {
			scaleX = 0.9,
			scaleY = 0.9,
			time = time,
			onComplete = onComplete
			})
		end
		local function dark2(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			button:setOpacity(255)
			transition.scaleTo(button, {
			scaleX = 1.1,
			scaleY = 1.1,
			time = time,
			onComplete = onComplete
			})
		end
		local function dark3(offset, time, onComplete)
			local x, y = button:getPosition()
			local size = button:getContentSize()
			button:setOpacity(255)
			transition.scaleTo(button, {
			scaleX = 1,
			scaleY = 1,
			time = time,
			onComplete = onComplete
			})
		end
		if params.btnType == NormalButton.TYPE_NORMAL and button.actioning == false then
			button.actioning = true
			normal1(-10, 0.11, function ()
				normal1(10, 0.05, function ()
					normal1(5, 0.05, function ()
						normal2(5, 0.08, function ()
							button:getParent():setEnabled(true)
							listener(tag)
							button.actioning = false
							button:setEnabled(true)
						end)
					end)
				end)
			end)
		elseif params.btnType == NormalButton.TYPE_BUBBLE and button.actioning == false then
			button.actioning = true
			zoom1(40, 0.08, function ()
				zoom2(40, 0.09, function ()
					zoom1(20, 0.1, function ()
						zoom2(20, 0.11, function ()
							button:getParent():setEnabled(true)
							listener(tag)
							button.actioning = false
							button:setEnabled(true)
						end)
					end)
				end)
			end)
		elseif params.btnType == NormalButton.TYPE_DARKER and button.actioning == false then
			button.actioning = true
			dark2(40, 0.08, function (...)
				dark1(40, 0.1, function ()
					dark3(40, 0.08, function (...)
						listener(tag)
						button.actioning = false
						button:setEnabled(true)
					end)
				end)
			end)
		end
	end
	button = ui.newImageMenuItem(params)
	btnContentsize = button:getContentSize()
	button.actioning = false
	return button
end
function NormalButton.getContentSize(...)
	return btnContentsize
end

return NormalButton