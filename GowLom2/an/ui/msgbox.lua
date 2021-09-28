local msgbox = class("an.msgbox", function ()
	return display.newNode()
end)
local config = nil

table.merge(slot0, {
	scroll,
	input,
	bg
})

msgbox.init = function (_config)
	assert(_config.bg, "[bg] not found.")
	assert(_config.content, "[content] not found.")
	assert(_config.confirm, "[confirm] not found.")

	config = _config or {}

	for k, v in pairs(config) do
		if type(v) == "userdata" and tolua.type(v) == "cc.Texture2D" then
			v.retain(v)
		end
	end

	config.cancel = config.cancel or _config.confirm
	config.inputListBgScale = config.inputListBgScale or 1
	config.contentLabelSize = config.contentLabelSize or 18
	config.btny = config.btny or 0
	config.btnColor = config.btnColor or display.COLOR_WHITE
	config.btnSColor = config.btnSColor or display.COLOR_BLACK
	config.btnLabelSize = config.btnLabelSize or 18
	config.btnAlignStyle = config.btnAlignStyle or "center"
	config.btnSpace = config.btnSpace or 0

	return 
end
msgbox.ctor = function (self, text, func, params)
	assert(config, "msgbox not inited.")

	params = params or {}
	self.params = params

	self.size(self, display.width, display.height):addto(display.getRunningScene(), an.z.msgbox)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function ()
		return 
	end)

	local bg = display.newSprite(config.bg).center(slot4):addto(self)
	local title = params.title or config.title

	if title then
		assert(config.titlepos, "titlepos not inited.")

		if type(title) == "string" and not string.find(title, ".png") then
			an.newLabel(title, 18, 1, {
				color = def.colors.Cd2b19c
			}):anchor(0.5, 0.5):addTo(bg):pos(config.titlepos.x, config.titlepos.y)
		else
			display.newSprite(title):add2(bg):pos(config.titlepos.x, config.titlepos.y - 3)
		end
	end

	if config.close and not params.noclose then
		an.newBtn(config.close, function ()
			if self.autoCloseId then
				scheduler.unscheduleGlobal(self.autoCloseId)

				self.autoCloseId = nil
			end

			self:removeSelf()

			return 
		end, {
			pressImage = config.close2
		}).anchor(slot6, 1, 1):pos(bg.getw(bg) - 5, bg.geth(bg) - 5):add2(bg)
	end

	local btnw = config.confirm:getContentSize().width
	local btnh = config.confirm:getContentSize().height
	local spacex = config.btnSpace
	local btns = {}
	local centerpos = cc.p(config.content.x + config.content.w/2, config.content.y + config.content.h/2)

	local function clickBtn(idx)
		if config.sound then
			audio.playSound(config.sound)
		end

		print("msgbox idx", idx)

		if func then
			func(idx, self)
		end

		if not params.manualRemove then
			if self.autoCloseId then
				scheduler.unscheduleGlobal(self.autoCloseId)

				self.autoCloseId = nil
			end

			self:removeSelf()
		end

		return 
	end

	local function btnPosx(i, cnt)
		if config.btnAlignStyle == "center" then
			return bg:getw()/(cnt + 1)*i
		elseif config.btnAlignStyle == "left" then
			return config.content.x + btnw/2 + (i - 1)*(btnw + spacex)
		elseif config.btnAlignStyle == "right" then
			return (config.content.x + config.content.w) - btnw/2 - (i - 1)*(btnw + spacex)
		end

		return 
	end

	local btnConfigs = nil

	if params.btnTexts then
		btnConfigs = {}

		for i, v in ipairs(params.btnTexts) do
			btnConfigs[#btnConfigs + 1] = {
				v,
				i,
				config.confirm,
				config.confirm2
			}
		end
	else
		slot14 = {
			{
				"确定",
				1,
				config.confirm,
				config.confirm2
			}
		}
		btnConfigs = slot14

		if params.hasCancel then
			btnConfigs[2] = {
				"取消",
				0,
				config.confirm,
				config.confirm2
			}

			if config.btnAlignStyle == "right" then
				btnConfigs[2] = btnConfigs[1]
				btnConfigs[1] = btnConfigs[2]
			end
		end
	end

	for i, v in ipairs(btnConfigs) do
		btns[#btns + 1] = an.newBtn(v[3], function ()
			clickBtn(v[2])

			return 
		end, {
			pressImage = v[4],
			label = not v[5] and {
				v[1],
				config.btnLabelSize,
				1,
				{
					color = config.btnColor,
					sc = config.btnSColor
				}
			},
			sprite = v[5]
		}).pos(slot20, btnPosx(i, #btnConfigs), config.btny + btnh/2):add2(bg)
	end

	local labelM = nil

	if params.center then
		labelM = an.newLabelM(config.content.w, params.fontSize or config.contentLabelSize, 1, {
			center = true
		}):anchor(0.5, 0.5):pos(bg.centerPos(bg)):add2(bg)
	else
		self.scroll = an.newScroll(config.content.x, config.content.y, config.content.w, config.content.h, {
			labelM = {
				params.fontSize or config.contentLabelSize,
				1
			}
		}):add2(bg)

		if params.disableScroll then
			self.scroll:enableTouch(false)
		end

		labelM = self.scroll.labelM
	end

	if text == nil or #text == 0 then
		text = ""
	end

	if type(text) == "string" then
		labelM.addLabel(labelM, text)
	else
		for i, v in ipairs(text) do
			labelM.addLabel(labelM, unpack(v))
		end
	end

	if params.input then
		if params.center then
			self.input = an.newInput(centerpos.x, centerpos.y, config.content.w, 40, params.input, {
				label = {
					"",
					18,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/edit.png")
				},
				tip = {
					params.inputTip
				}
			}):anchor(0, 1):add2(self.scroll)
		else
			local size = self.scroll:getScrollSize()
			self.input = an.newInput(0, size.height - self.scroll.labelM:geth(), size.width, 40, params.input, {
				label = {
					"",
					18,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/edit.png")
				},
				tip = {
					params.inputTip
				}
			}):anchor(0, 1):add2(self.scroll)
		end

		if params.inputStopCall then
			self.input.stop_call = params.inputStopCall
		end

		if params.inputNow then
			self.input:startInput()
		end

		if params.inputList then
			display.newSprite(config.inputListBg):pos(display.cx + 315, display.cy):scale(config.inputListBgScale or 1):add2(self)
			an.newLabel(params.inputList[1], 18, 1, {
				color = cc.c3b(255, 255, 0)
			}):anchor(0.5, 0.5):pos(display.cx + 315, display.cy + 140):add2(self)

			local select, scroll = nil
			scroll = an.newScroll(display.cx + 250, display.cy - 155, 130, 280, {
				labelM = {
					18,
					1,
					params = {
						manual = true,
						center = true,
						clickLine_call = function (data)
							select:show():pos(0, scroll:getScrollSize().height - data.i*scroll.labelM.wordSize.height)
							self.input:setString(data.v)

							return 
						end
					}
				}
			}).addTo(slot17, self)
			select = display.newColorLayer(cc.c4b(0, 200, 200, 255)):size(scroll.getw(scroll), scroll.labelM.wordSize.height):add2(scroll, -1):hide()

			for i, v in ipairs(params.inputList[2]) do
				scroll.labelM:nextLine({
					i = i,
					v = v
				}):addLabel(v)
			end
		end
	end

	self.bg = bg
	self.btns = btns

	if params.autoClose then
		if self.btns and #self.btns ~= 0 then
			self.btns[1].label:setText(params.btnTexts[1] .. "(" .. tostring(params.autoClose) .. "s)")
		end

		self.autoCloseId = scheduler.scheduleGlobal(function ()
			if params.autoClose ~= 1 then
				params.autoClose = params.autoClose - 1

				self.btns[1].label:setText(params.btnTexts[1] .. "(" .. tostring(params.autoClose) .. "s)")
			else
				scheduler.unscheduleGlobal(self.autoCloseId)

				self.autoCloseId = nil

				clickBtn(1)
			end

			return 
		end, 1)
	end

	g_data.eventDispatcher.addListener(slot15, "M_CHANGEMAP", self, self.onM_CHANGEMAP)

	return 
end
msgbox.onM_CHANGEMAP = function (self)
	if self and self.params and not self.params.manualRemove then
		if self.autoCloseId then
			scheduler.unscheduleGlobal(self.autoCloseId)

			self.autoCloseId = nil
		end

		self.removeSelf(self)
	end

	return 
end

return msgbox
