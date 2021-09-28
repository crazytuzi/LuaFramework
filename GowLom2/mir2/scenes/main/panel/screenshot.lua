local common = import("..common.common")
local screenshot = class("screenshot", function ()
	return display.newNode()
end)

table.merge(slot1, {
	canvas,
	editBtn,
	editting,
	tools,
	colorPoints
})

local function checkDir()
	if not io.exists(device.writablePath .. "cache/screenshot") then
		ycFunction:mkdir(device.writablePath .. "cache/screenshot")
	end

	return 
end

local function saveScreen(node, fileName)
	checkDir()

	local file = device.writablePath .. "cache/screenshot/" .. fileName .. ".png"

	return printscreen(node, {
		file = file
	})
end

screenshot.ctor = function (self, node)
	self._supportMove = true

	sound.playSound("screen")

	local color = nil
	slot3 = display.newColorLayer(cc.c4b(255, 255, 255, 255)):add2(self):runs({
		cc.FadeOut:create(1),
		cc.CallFunc:create(function ()
			color:removeSelf()
			main_scene.ground.map:setTopRender(false)

			local glview = cc.Director:getInstance():getOpenGLView()

			glview.setDesignResolutionSize(glview, display.sizeInPixels.width, display.sizeInPixels.height, cc.ResolutionPolicy.NO_BORDER)

			local shotnode = node or main_scene
			local screen = saveScreen(shotnode, socket.gettime())

			screen.retain(screen)

			local listener = nil
			slot4 = cc.EventListenerCustom:create("director_after_draw", function ()
				glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)
				main_scene.ground.map:setTopRender(true)
				self:show(screen)
				screen:release()
				cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)

				return 
			end)
			listener = slot4

			cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

			return 
		end)
	})
	color = slot3

	return 
end
screenshot.show = function (self, screen)
	local picw = 615
	local picscale = picw/screen.getw(screen)
	local pich = screen.geth(screen)*picscale
	local size = cc.size(picw, pich)
	self.canvas = display.newNode():pos(13, 60):size(picw, pich):add2(self)
	self.canvas.output = display.newNode():size(picw, pich):add2(self.canvas)

	screen.scale(screen, picscale):anchor(0, 0):add2(self.canvas.output)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, size):pos(self.canvas:getPosition()):anchor(0, 0):add2(self)

	local controlHeight = 110
	local b1 = res.get2("pic/panels/bigmap/bg1.png")
	local b2 = res.get2("pic/panels/bigmap/bg2.png")
	local b3 = res.get2("pic/panels/bigmap/bg3.png")

	self.size(self, b1.getw(b1), size.height + controlHeight):anchor(0.5, 0.5):center()
	self.addTouchFrame(self, cc.rect(0, 0, self.getw(self), self.geth(self)), "main")
	self.scale(self, picscale/1):scaleTo(0.2, 1)
	b3.anchor(b3, 0, 0):add2(self, -1)
	b2.anchor(b2, 0, 0):pos(0, b3.geth(b3)):scaleY((self.geth(self) - b1.geth(b1) - b3.geth(b3))/b2.geth(b2)):add2(self, -1)
	b1.anchor(b1, 0, 1):pos(0, self.geth(self)):add2(self, -1)
	res.get2("pic/panels/screenshot/title.png"):add2(b1):pos(b1.getw(b1)/2, b1.geth(b1) - 23)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}).anchor(slot10, 1, 1):pos(self.getw(self) - 5, self.geth(self) - 5):addto(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		saveScreen(self.canvas.output, common.getPlayerName() .. socket.gettime())
		self:hide()
		scheduler.performWithDelayGlobal(function ()
			self:runs({
				cc.Show:create(),
				cc.ScaleTo:create(0.2, 0.01),
				cc.CallFunc:create(function ()
					self:hidePanel()

					return 
				end)
			})

			return 
		end, 0)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"±£´æ",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).anchor(slot10, 1, 1):pos(self.getw(self) - 13, 54):add2(self)

	self.editBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		if self.tools then
			self.tools:removeSelf()

			self.tools = nil
		end

		if self.colorPoints then
			for i, v in ipairs(self.colorPoints) do
				v.removeSelf(v)
			end

			self.colorPoints = nil
		end

		self.editting = not self.editting

		if self.editting then
			self.editBtn.label:setString("»¹Ô­")
			self:showTools()
		else
			self.editBtn.label:setString("±à¼­")
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"±à¼­",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).anchor(slot10, 1, 1):pos(self.getw(self) - 133, 54):add2(self)

	return 
end
screenshot.showTools = function (self)
	self.tools = display.newNode():add2(self)
	local colors = {
		cc.c4b(255, 0, 0, 255),
		cc.c4b(250, 155, 19, 255),
		cc.c4b(255, 255, 0, 255),
		cc.c4b(0, 255, 0, 255),
		cc.c4b(0, 255, 255, 255),
		cc.c4b(255, 0, 255, 255)
	}
	local colorPos = cc.p(20, 18)
	local selectIdx = 1
	local pre = nil

	for i, v in ipairs(colors) do
		display.newColorLayer(v):size(37, 37):pos((colorPos.x + (i - 1)*45) - 2, colorPos.y - 2):add2(self.tools):anchor(0.5, 0.5)

		local btn = nil
		slot11 = res.get2("pic/panels/screenshot/frame.png"):anchor(0.5, 0.5):pos(colorPos.x + (i - 1)*45 + 17, colorPos.y + 17):add2(self.tools):enableClick(function ()
			if pre then
				pre:setTouchEnabled(true)
				pre:setColor(cc.c3b(255, 255, 255))
			end

			pre = btn

			btn:setTouchEnabled(false)
			btn:setColor(cc.c3b(255, 0, 0))

			selectIdx = i

			return 
		end, {
			ani = false
		})
		btn = slot11

		if not pre then
			pre = btn

			btn.setTouchEnabled(btn, false)
			btn.setColor(btn, cc.c3b(255, 0, 0))
		end
	end

	self.colorPoints = {}
	local size = 6

	local function add(x, y)
		if x - size/2 < 0 or y - size/2 < 0 or self.canvas:getw() < x + size/2 or self.canvas:geth() < y + size/2 then
			return 
		end

		self.colorPoints[#self.colorPoints + 1] = display.newColorLayer(colors[selectIdx]):size(size, size):pos(x - size/2, y - size/2):add2(self.canvas.output)

		return 
	end

	local lastpos = nil
	local touchNode = display.newNode().size(slot8, self.canvas:getContentSize()):pos(self.canvas:getPosition()):add2(self.tools)

	touchNode.setTouchEnabled(touchNode, true)
	touchNode.addNodeEventListener(touchNode, cc.NODE_TOUCH_EVENT, function (event)
		local rect1 = self:getBoundingBox()
		local rect2 = self.canvas:getBoundingBox()
		local x = event.x - rect1.x - rect2.x
		local y = event.y - rect1.y - rect2.y

		if event.name == "began" then
			add(x, y)

			lastpos = cc.p(x, y)

			return true
		elseif event.name == "moved" then
			local stepMax = math.modf(math.max(math.abs(x - lastpos.x), math.abs(y - lastpos.y))/size/2)
			local stepx = math.abs(x - lastpos.x)/stepMax
			local stepy = math.abs(y - lastpos.y)/stepMax
			local nextx = lastpos.x
			local nexty = lastpos.y

			for i = 1, stepMax, 1 do
				if nextx < x then
					nextx = nextx + stepx
				else
					nextx = nextx - stepx
				end

				if nexty < y then
					nexty = nexty + stepy
				else
					nexty = nexty - stepy
				end

				add(nextx, nexty)
			end

			add(x, y)

			lastpos = cc.p(x, y)
		elseif event.name == "ended" then
			add(x, y)
		end

		return 
	end)

	return 
end

return screenshot
