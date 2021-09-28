local staticAlpha = 122
local sizeMin = 200
local sizeMax = 400
local rocker = class("rocker", function ()
	return display.newNode()
end)
local common = import("...common.common")

table.merge(slot3, {
	config,
	data,
	spr_walk,
	spr_run,
	sprBg,
	beginPos,
	img_dir,
	showBGAndDir = true,
	isStepShow = false,
	img_step = {},
	use = {
		beginPos,
		originPos,
		step,
		spr,
		len
	},
	default = {
		type = 2,
		size = 300
	}
})

rocker.ctor = function (self, config, data)
	data.size = data.size or self.default.size
	data.type = self.default.type

	self.size(self, data.size, data.size):anchor(0.5, 0.5):pos(data.x, data.y)

	self.data = data
	self.config = config
	local rType = 1

	if g_data.setting.base.doubleRocker then
		rType = 2
	end

	self.setRockerType(self, rType)

	self.showBGAndDir = not g_data.login:isChangeSkinCheckServer()

	return 
end
rocker.uptUI = function (self)
	self.size(self, self.data.size, self.data.size)

	if self.spr_walk then
		self.spr_walk:pos(self.walkSprPos(self))
	end

	self.spr_run:pos(self.runSprPos(self))
	self._sizeChanged(self)

	return 
end
rocker.setRockerType = function (self, t)
	self.data.type = t

	self.loadSpr(self)

	return 
end
rocker.loadSpr = function (self)
	if self.spr_walk then
		self.spr_walk:removeSelf()

		self.spr_walk = nil
	end

	if self.spr_run then
		self.spr_run:removeSelf()

		self.spr_run = nil
	end

	if self.data.type == 2 then
		self.spr_walk = res.get2("pic/console/rock1.png"):pos(self.walkSprPos(self)):add2(self, 1)

		self.spr_walk:setName("rocker_walk")
	end

	self.spr_run = res.get2("pic/console/rock2.png"):pos(self.runSprPos(self)):add2(self, 1)

	self.spr_run:setName("rocker_run")

	self.img_step[2] = res.get2("pic/console/run.png"):add2(self.spr_run, 2):anchor(0.5, 0.5)
	self.img_step[1] = res.get2("pic/console/walk.png"):add2(self.spr_run, 1):anchor(0.5, 0.5)

	self.hideAllStepImg(self)

	self.img_dir = res.get2("pic/console/rockerDir.png"):add2(self.spr_run):anchor(0.5, 0.5)

	self.img_dir:setVisible(false)

	return 
end
rocker.getEditNode = function (self)
	local node = display.newNode():size(400, 80)
	local num = an.newLabel("", 16, 1, {
		color = cc.c3b(0, 255, 255)
	}):add2(node):anchor(0.5, 1):pos(node.getw(node)/2, node.geth(node))

	local function upt(uptUI)
		num:setString("“°∏À¥Û–°(" .. self.data.size .. ")")

		if uptUI then
			self:size(self.data.size, self.data.size)

			if self.spr_walk then
				self.spr_walk:pos(self:walkSprPos())
			end

			self.spr_run:pos(self:runSprPos())
			self:_sizeChanged()
		end

		return 
	end

	slot3()

	local slider = an.newSlider(res.gettex2("pic/common/sliderBg.png"), res.gettex2("pic/common/sliderBar.png"), res.gettex2("pic/common/sliderBlock.png"), {
		value = (self.data.size - sizeMin)/(sizeMax - sizeMin),
		valueChange = function (value)
			local size = (sizeMax - sizeMin)*value + sizeMin
			self.data.size = math.modf(size)

			upt(true)

			return 
		end,
		valueChangeEnd = function (value)
			local size = (sizeMax - sizeMin)*value + sizeMin
			self.data.size = math.modf(size)

			upt(true)

			return 
		end
	}).add2(slot4, node):anchor(0.5, 0.5):pos(node.getw(node)/2, node.geth(node) - 50)

	return node
end
rocker.walkSprPos = function (self)
	return self.getw(self)*0.33, self.geth(self)*0.33
end
rocker.runSprPos = function (self)
	if self.data.type == 1 then
		return self.getw(self)*0.5, self.geth(self)*0.5
	end

	return self.getw(self)*0.66, self.geth(self)*0.66
end
rocker.showbg = function (self, b, x, y)
	if b then
		if not self.sprBg then
			self.sprBg = res.get2("pic/console/rockBg.png"):add2(self)
		end

		self.sprBg:show():pos(x, y)
	elseif self.sprBg then
		self.sprBg:hide()
	end

	return 
end
rocker.showStepImg = function (self, state, rockerBar)
	local flag = self.img_step[state] == nil or rockerBar == nil or self.isStepShow

	if flag then
		return 
	end

	self.hideAllStepImg(self)
	self.img_step[state]:retain()
	self.img_step[state]:removeSelf()
	rockerBar.addChild(rockerBar, self.img_step[state])
	self.img_step[state]:pos(rockerBar.getw(rockerBar)/2, rockerBar.geth(rockerBar)/2)
	self.img_step[state]:setVisible(true)

	if self.data.type == 2 then
		self.isStepShow = true
	end

	return 
end
rocker.hideAllStepImg = function (self)
	local maxIdx = #self.img_step

	for i = 1, maxIdx, 1 do
		local v = self.img_step[i]

		if v then
			v.setVisible(v, false)
		end
	end

	self.isStepShow = false

	return 
end
rocker.hideStepImg = function (self, state)
	if state then
		self.img_step[state]:setVisible(false)
	else
		self.hideAllStepImg(self)
	end

	return 
end
rocker.convertRadToDirIdx = function (self, rad)
	local dir = 0
	local pi = 3.14
	local angle = pi/180*rad

	if angle < 0 then
		angle = angle + 360
	end

	local idx = math.ceil(angle/22.5)

	if idx == 1 or idx == 16 then
		dir = 0
	else
		dir = math.ceil(idx/2 - 0.5)
	end

	dir = math.abs(dir)

	return dir
end
local dir_showAngle = {
	0,
	45,
	90,
	135,
	180,
	-135,
	-90,
	-45
}
rocker.showDir = function (self, dir, maxDis)
	local oriPos = cc.p(self.sprBg:getPositionX(), self.sprBg:getPositionY())
	local pi = 3.14
	local maxDis = maxDis - 5
	local rAngle = dir_showAngle[dir + 1]
	local posX = maxDis*math.cos((rAngle - 90)/180*pi) + oriPos.x
	local posY = maxDis*math.sin((rAngle - 90)/180*pi) + oriPos.y

	self.img_dir:retain()
	self.img_dir:removeSelf()
	self.img_dir:add2(self):pos(posX, posY):anchor(0.5, 0.5):setRotation(rAngle)
	self.img_dir:setVisible(true)

	return 
end
rocker.hideDir = function (self)
	self.img_dir:setVisible(false)

	return 
end
rocker.handleTouch = function (self, event)
	local controller = main_scene.ui.console.controller
	local maxDis = 100
	local x = event.x - self.getPositionX(self) + self.getw(self)/2
	local y = event.y - self.getPositionY(self) + self.geth(self)/2

	if event.name == "began" then
		self.isStepShow = false

		common.stopAuto(false)

		self.use = {
			beginRealPos = cc.p(event.x, event.y),
			beginPos = cc.p(x, y),
			beginTime = socket.gettime()
		}

		if self.data.type == 1 then
			self.use.spr = self.spr_run
			self.use.originPos = cc.p(self.runSprPos(self))
			self.use.len = 30
			self.use.runLen = 80
		elseif x <= self.getw(self)/2 and y <= self.geth(self)/2 then
			self.use.spr = self.spr_walk
			self.use.step = 1
			self.use.originPos = cc.p(self.walkSprPos(self))
			self.use.len = 30
		else
			self.use.spr = self.spr_run
			self.use.step = 2
			self.use.originPos = cc.p(self.runSprPos(self))
			self.use.len = 40
		end

		self.use.spr:stopAllActions()
		self.use.spr:pos(x, y)

		if self.showBGAndDir then
			self.showbg(self, true, x, y)
		end

		return true
	elseif event.name == "moved" then
		local moveVec = cc.p(x - self.use.beginPos.x, y - self.use.beginPos.y)
		local angle = math.atan2(moveVec.x, moveVec.y)
		local destx = x
		local desty = y
		local dis = cc.pGetDistance(self.use.beginPos, cc.p(destx, desty))

		if maxDis < dis then
			destx = self.use.beginPos.x + math.sin(angle)*maxDis
			desty = self.use.beginPos.y + math.cos(angle)*maxDis
		end

		self.use.spr:pos(destx, desty)

		if self.use.len < dis then
			controller.move.enable = "dir"
			controller.move.dir = self.convertRadToDirIdx(self, angle)

			if self.data.type == 1 then
				controller.move.step = (self.use.runLen <= dis and 2) or 1

				if controller.move.step == 1 and socket.gettime() - self.use.beginTime < 0.2 then
					controller.move.enable = false
				end
			else
				controller.move.step = self.use.step
			end

			if main_scene.ui.console.autoRat.enableRat then
				main_scene.ui.console.autoRat:stop()
			end

			if self.showBGAndDir then
				self.showStepImg(self, controller.move.step, self.use.spr)
				self.showDir(self, controller.move.dir, maxDis)
			end
		else
			controller.move.enable = false

			self.hideDir(self)
		end
	elseif event.name == "ended" then
		self.hideAllStepImg(self)
		self.hideDir(self)

		local angle = math.atan2(self.use.spr:getPositionX() - self.use.originPos.x, self.use.spr:getPositionY() - self.use.originPos.y)
		local dis = cc.pGetDistance(self.use.originPos, cc.p(self.use.spr:getPosition())) + 20
		local destx = self.use.spr:getPositionX() - math.sin(angle)*dis
		local desty = self.use.spr:getPositionY() - math.cos(angle)*dis

		self.use.spr:runs({
			cc.MoveTo:create(0.2, cc.p(destx, desty)),
			cc.MoveTo:create(0.1, self.use.originPos)
		})

		if self.showBGAndDir then
			self.showbg(self)
		end

		controller.move.enable = false

		if math.abs(self.use.beginRealPos.x - event.x) < 10 and math.abs(self.use.beginRealPos.y - event.y) < 10 and socket.gettime() - self.use.beginTime < 25 then
			main_scene.ui.console.controller:handleTouch({
				name = "began",
				x = event.x,
				y = event.y
			})
			scheduler.performWithDelayGlobal(function ()
				main_scene.ui.console.controller:handleTouch({
					name = "ended",
					x = event.x,
					y = event.y
				})

				return 
			end, 0)
		else
			main_scene.ui.console.controller.handleRockerEnded(slot10, {
				name = "ended",
				x = event.x,
				y = event.y
			})
		end
	end

	return 
end

return rocker
