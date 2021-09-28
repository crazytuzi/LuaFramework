local antiMotor = class("antiMotor", function ()
	return display.newNode()
end)
local TEMP_FILENAME = device.writablePath
antiMotor.ctor = function (self)
	self.FGUID = ""
	self._supportMove = true

	self.setNodeEventEnabled(self, true)
	self.pos(self, 60, display.height - 360):anchor(0, 0)

	self.image = nil
	self.bg = display.newNode():add2(self):anchor(0, 0)

	self.bg:setVisible(false)

	local imagebg = res.get2("pic/common/msgbox.png"):addto(self.bg):anchor(0, 0)

	self.bg:size(cc.size(imagebg.getContentSize(imagebg).width, imagebg.getContentSize(imagebg).height))
	self.size(self, cc.size(imagebg.getContentSize(imagebg).width, imagebg.getContentSize(imagebg).height))
	an.newLabel("验证", 20, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):addTo(self.bg):pos(imagebg.getw(imagebg)/2, imagebg.geth(imagebg) - 18)
	an.newLabel("请输入验证信息", 22, 0, {
		color = def.colors.Cf0c896
	}):add2(self.bg):pos(50, 120)
	an.newLabel("倒计时:", 22, 0, {
		color = def.colors.Cdcd2de
	}):add2(self.bg):pos(240, 120)
	an.newLabel("300秒", 22, 0, {
		color = def.colors.Ce66946
	}):add2(self.bg):anchor(0, 0):pos(315, 120):setName("countdown")

	local input = nil
	self.isClicked = false
	input = an.newInput(55, 110, 320, 36, 4, {
		label = {
			"",
			22,
			1,
			{
				color = def.colors.Cdcd2de
			}
		},
		bg = {
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-5,
				0
			}
		}
	}):anchor(0, 1):add2(self.bg)

	input.setName(input, "input")

	local y = input.label:getPositionY() - 3

	input.label:setPositionY(y)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		if not self.isClicked then
			local text = input:getText()
			local rsb = DefaultClientMessage(CM_AnsIdentifyCode)
			rsb.FGUID = self.FGUID
			rsb.FId = self.FId
			rsb.FAnswer = text

			MirTcpClient:getInstance():postRsb(rsb)

			self.isClicked = true

			self:setVisible(false)
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"确定",
			22,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot4, self.bg):pos(imagebg.getw(imagebg)/2, 30)
	self.setMiniBg(self)

	return 
end
antiMotor.setMiniBg = function (self)
	self.pos(self, 60, display.height - 160)

	self.miniBg = display.newNode():add2(self):anchor(0, 0):pos(60, 80)

	an.newBtn(res.gettex2("pic/common/vertifyIcon.png"), function ()
		if self.miniBg then
			self.miniBg:setVisible(false)
		end

		if self.bg then
			self.bg:setVisible(true)
			self:pos(60, display.height - 360)
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/vertifyIcon.png")
	}).add2(slot1, self.miniBg):anchor(0, 0):scale(1.1, 1.1)
	display.newSprite(res.gettex2("pic/common/button_click02.png")):anchor(0, 0):add2(self.miniBg):pos(36, 36):scale(1.5, 1.5)
	an.newLabel("", 20, 0, {
		color = cc.c3b(241, 15, 15)
	}):add2(self.miniBg):anchor(0.5, 1):pos(16, 0):setName("countdown")

	return 
end
antiMotor.update = function (self, dt)
	local label = self.bg:getChildByName("countdown")
	local miniLabel = self.miniBg:getChildByName("countdown")
	self.countDown = self.countDown - dt
	local num = math.floor(self.countDown)

	label.setText(label, tostring(num) .. "秒")
	miniLabel.setText(miniLabel, tostring(num) .. "秒")

	if label and miniLabel and num <= 0 then
		self.setVisible(self, false)
	end

	return 
end
antiMotor.updateImage = function (self, result)
	self.countDown = result.FTimeNum
	self.FGUID = result.FGUID
	self.FId = result.FId
	local input = self.bg:getChildByName("input")

	if input then
		input.setText(input, "")
	end

	local filepath = TEMP_FILENAME .. result.FGUID .. "jpg"
	local isSuccess = self.genImageFromByte(self, result.FPictureList, filepath)

	if isSuccess then
		self.image = display.newSprite(filepath):add2(self.bg):pos(self.getw(self)/2, self.bg:geth() - 98)
	end

	self.isClicked = false

	os.remove(filepath)
	self.setVisible(self, true)

	return 
end
antiMotor.genImageFromByte = function (self, picbyte, filename)
	local bytesfile = io.open(filename, "wb")

	if not bytesfile then
		return false
	end

	for i = 1, table.getn(picbyte), 1 do
		bytesfile.write(bytesfile, string.format("%c", picbyte[i]))
	end

	io.close(bytesfile)

	return true
end

return antiMotor
