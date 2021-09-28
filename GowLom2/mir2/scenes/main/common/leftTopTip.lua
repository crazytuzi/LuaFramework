local tip = class("leftTopTip", function ()
	return display.newNode()
end)

table.merge(slot0, {
	msgs = {}
})

tip.ctor = function (self)
	self.msgs = {}
	self.maxLine = {}
	self.lastTime = nil
	self.labelLines = nil
	self.msgPerson = {}
	self.timePerLeft = nil
	self.msgLight = {}
	self.timeLight = nil
	self.lightLines = nil
	self.defaultColorLabel = nil
	self.defaultColorLight = nil
	self.maxCahce = 10

	return 
end
local maxLine = {
	10,
	10,
	10,
	10,
	nil,
	8,
	5,
	3,
	3
}
local config = {
	{
		fontSize = 20,
		smokeSize = 1,
		fontColor = display.COLOR_GREEN,
		smokeColor = display.COLOR_BLACK,
		position = {
			x = 40,
			y = display.height - 70
		}
	},
	{
		fontSize = 20,
		smokeSize = 1,
		fontColor = cc.c3b(50, 177, 108),
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2 + 50,
			y = display.height/2 - 50
		}
	},
	{
		fontSize = 20,
		smokeSize = 1,
		fontColor = cc.c3b(240, 200, 150),
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2 + 50,
			y = display.height/2 - 50
		}
	},
	{
		fontSize = 20,
		smokeSize = 1,
		fontColor = cc.c3b(243, 3, 2),
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2 - 85,
			y = display.height/2 - 135
		}
	},
	[6] = {
		fontSize = 22,
		smokeSize = 1,
		fontColor = cc.c3b(230, 105, 70),
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2,
			y = display.height/2 + 90
		}
	},
	[7] = {
		fontSize = 20,
		smokeSize = 1,
		fontColor = display.COLOR_WHITE,
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2 - 50,
			y = display.height/2
		}
	},
	[8] = {
		fontSize = 24,
		smokeSize = 1,
		fontColor = cc.c3b(241, 237, 2),
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2,
			y = display.height - 130
		}
	},
	[9] = {
		fontSize = 20,
		smokeSize = 1,
		fontColor = cc.c3b(28, 58, 210),
		smokeColor = display.COLOR_BLACK,
		position = {
			x = display.width/2,
			y = display.height - 150
		}
	}
}
tip.update = function (self)
	local time = socket.gettime()

	if not self.lastTime then
		self.lastTime = time
	end

	if (self.labelLines or 1)*0.5 < socket.gettime() - self.lastTime then
		self.refreshLabel(self)
	end

	if not self.timeLight then
		self.timeLight = time
	end

	if 3 < socket.gettime() - self.timeLight then
		self.refreshLight(self)
	end

	return 
end
tip.upt = function (self, type, position, lineNum)
	local count = {}

	for i = 1, 10, 1 do
		count[i] = 0

		if i == 4 then
			count[i] = {}
		end
	end

	for i, v in pairs(self.msgs) do
		if type == 1 and v.type == 1 then
			count[v.type] = count[v.type] + 1

			v.pos(v, position.x, position.y - count[v.type]*22*lineNum)
		end

		if type == 4 and v.type == 4 then
			count[4] = count[4] or {}

			for k, v in pairs(count[4]) do
				v.weight = v.weight + lineNum
			end

			local temp = {
				index = i,
				weight = 0
			}
			count[4][#count[4] + 1] = temp
		end

		if type == 6 and v.type == 6 then
			count[v.type] = count[v.type] + 1

			v.pos(v, position.x, position.y + count[v.type]*22*lineNum)
		end

		if type == 7 and v.type == 7 then
			count[v.type] = count[v.type] + 1

			v.pos(v, position.x, position.y + count[v.type]*22*lineNum)
		end

		if type == 9 and v.type == 9 then
			count[v.type] = count[v.type] + 1

			v.pos(v, position.x, position.y + count[v.type]*22*lineNum)
		end
	end

	if type == 4 then
		for k, v in pairs(count[4]) do
			self.msgs[v.index]:pos(position.x, position.y + v.weight*22)
		end
	end

	return 
end
tip.refreshLabel = function (self)
	self.lastTime = socket.gettime()

	if 0 < #self.msgPerson then
		local tipType = self.msgPerson[1].type
		local contentT = self.msgPerson[1].contentT
		local msg = nil
		msg = an.newLabelM(300, config[tipType].fontSize, config[tipType].smokeSize, {
			manual = true
		}):pos(config[tipType].position.x, config[tipType].position.y):add2(self)

		msg.nextLine(msg)

		for i = 1, #contentT, 1 do
			for j = 1, #contentT[i], 1 do
				if #contentT[i][j] == 1 then
					msg.addLabel(msg, contentT[i][j][1], (self.defaultColorLabel and self.defaultColorLabel) or config[tipType].fontColor)
				else
					msg.addLabel(msg, contentT[i][j][2], contentT[i][j][1])
				end
			end

			msg.nextLine(msg)
		end

		msg.runs(msg, {
			cc.MoveTo:create(2, cc.p(config[tipType].position.x, config[tipType].position.y + 100)),
			cc.FadeOut:create(0.1),
			cc.CallFunc:create(function ()
				msg:removeSelf()

				return 
			end)
		})
		table.remove(self.msgPerson, 1)
	end

	return 
end
tip.refreshLight = function (self)
	self.timeLight = socket.gettime()

	if 0 < #self.msgLight then
		if not self.msgLight[1].contentT[1].set then
			local tipType = self.msgLight[1].type
			local contentT = self.msgLight[1].contentT
			local msg = nil
			msg = an.newLabelM(300, config[tipType].fontSize, config[tipType].smokeSize, {
				manual = true,
				center = true
			}):pos(config[tipType].position.x, config[tipType].position.y):add2(self)

			msg.nextLine(msg)

			for j = 1, #contentT[1], 1 do
				if #contentT[1][j] == 1 then
					msg.addLabel(msg, contentT[1][j][1], (self.defaultColorLight and self.defaultColorLight) or config[tipType].fontColor)
				else
					msg.addLabel(msg, contentT[1][j][2], contentT[1][j][1])
				end
			end

			msg.runs(msg, {
				cc.DelayTime:create(3),
				cc.CallFunc:create(function ()
					msg:removeSelf()

					return 
				end)
			})
			msg.anchor(slot3, 0.5, 0.5)

			self.msgLight[1].contentT[1].set = (self.msgLight[1].contentT[1].set or 0) + 1
		else
			local tipType = self.msgLight[1].type
			local contentT = self.msgLight[1].contentT
			local msg = nil
			msg = an.newLabelM(300, config[tipType].fontSize, config[tipType].smokeSize, {
				manual = true,
				center = true
			}):pos(config[tipType].position.x, config[tipType].position.y):add2(self)

			msg.nextLine(msg)

			for i = 1, 2, 1 do
				if contentT[i] then
					for j = 1, #contentT[i], 1 do
						if #contentT[i][j] == 1 then
							msg.addLabel(msg, contentT[i][j][1], (self.defaultColorLight and self.defaultColorLight) or config[tipType].fontColor)
						else
							msg.addLabel(msg, contentT[i][j][2], contentT[i][j][1])
						end
					end

					msg.nextLine(msg)
				end
			end

			if #contentT < 2 then
				msg.addLabel(msg, "")
				msg.nextLine(msg)
			end

			msg.runs(msg, {
				cc.DelayTime:create(3),
				cc.CallFunc:create(function ()
					msg:removeSelf()

					return 
				end)
			})
			msg.anchor(slot3, 0.5, 0.5)

			self.msgLight[1].contentT[1].set = (self.msgLight[1].contentT[1].set or 0) + 1

			if self.msgLight[1].contentT[2] then
				self.msgLight[1].contentT[2].set = (self.msgLight[1].contentT[2].set or 0) + 1
			end
		end

		if 1 < self.msgLight[1].contentT[1].set then
			table.remove(self.msgLight[1].contentT, 1)
		end

		if #self.msgLight[1].contentT == 0 then
			table.remove(self.msgLight, 1)
		end
	end

	return 
end
tip.show = function (self, text, tipType, defaultColor)
	tipType = tipType or 6

	if g_data.login:isChangeSkinCheckServer() then
		return 
	end

	if text == "资源下载中..." then
		return 
	end

	local function parseColor(val)
		val = tostring(val)

		if string.len(val) ~= 6 then
			return 
		end

		local r, g, b = nil
		val = string.lower(val)
		local val16 = {
			e = 14,
			a = 10,
			c = 12,
			d = 13,
			f = 15,
			b = 11
		}
		r = (val16[string.sub(val, 1, 1)] or tonumber(string.sub(val, 1, 1)))*16 + (val16[string.sub(val, 2, 2)] or tonumber(string.sub(val, 2, 2)))
		g = (val16[string.sub(val, 3, 3)] or tonumber(string.sub(val, 3, 3)))*16 + (val16[string.sub(val, 4, 4)] or tonumber(string.sub(val, 4, 4)))
		b = (val16[string.sub(val, 5, 5)] or tonumber(string.sub(val, 5, 5)))*16 + (val16[string.sub(val, 6, 6)] or tonumber(string.sub(val, 6, 6)))

		return cc.c3b(r, g, b)
	end

	local function parseColorByNum(num)
		if not num then
			return nil
		end

		num = tonumber(num)
		local r, g, b = nil
		r = math.modf(num/65536)
		g = math.modf((num - r*65536)/256)
		b = num - r*65536 - g*256

		return cc.c3b(r, g, b)
	end

	defaultColor = slot5(tonumber(defaultColor))
	local contentT = {}
	local lines = string.split(text, "$$")

	for k, v in pairs(lines) do
		contentT[k] = {}
		local section = string.split(v, "|")

		for j, t in pairs(section) do
			local ret = string.split(t, "#")

			if ret[1] and ret[2] then
				ret[1] = parseColor(ret[1])
			end

			contentT[k][j] = ret
		end
	end

	if tipType == 2 or tipType == 3 then
		if self.maxCahce < #self.msgPerson + 1 then
			table.remove(self.msgPerson, 1)
		end

		local temp = {
			type = tipType,
			contentT = contentT
		}
		self.msgPerson[#self.msgPerson + 1] = temp
		self.labelLines = #lines

		return 
	end

	if tipType == 8 or tipType == 8 then
		if self.maxCahce < #self.msgLight + 1 then
			table.remove(self.msgLight, 1)
		end

		local temp = {
			type = tipType,
			contentT = contentT
		}
		self.msgLight[#self.msgLight + 1] = temp
		self.lightLines = #lines

		return 
	end

	local msg = nil
	local animation = {
		{
			cc.DelayTime:create(3.5),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				table.removebyvalue(self.msgs, msg)
				msg:removeSelf()
				self:upt(tipType, config[tipType].position, #lines)

				return 
			end)
		},
		[4] = {
			cc.DelayTime.create(slot11, 4),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				table.removebyvalue(self.msgs, msg)
				msg:removeSelf()
				self:upt(tipType, config[tipType].position, #lines)

				return 
			end)
		},
		[6] = {
			cc.DelayTime.create(slot11, 3),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				table.removebyvalue(self.msgs, msg)
				msg:removeSelf()
				self:upt(tipType, config[tipType].position, #lines)

				return 
			end)
		},
		[7] = {
			cc.DelayTime.create(slot11, 4),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				table.removebyvalue(self.msgs, msg)
				msg:removeSelf()
				self:upt(tipType, config[tipType].position, #lines)

				return 
			end)
		},
		[9] = {
			cc.MoveTo.create(slot11, 5, cc.p(config[tipType].position.x, config[tipType].position.y + 70)),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				msg:removeSelf()
				self:upt(tipType, config[tipType].position, #lines)

				return 
			end)
		}
	}

	if tipType == 9 then
		local stencil = cc.DrawNode.create(slot10)
		local w = 200
		local h = 10
		local posx = config[tipType].position.x
		local posy = config[tipType].position.y
		local verts = {
			cc.p(posx - w/2, posy - h/2),
			cc.p(posx - w/2, posy + h/2),
			cc.p(posx + w/2, posy + h/2),
			cc.p(posx + w/2, posy - h/2)
		}
		local mask = cc.c3b(0, 1, 0)

		stencil.drawPolygon(stencil, verts, {
			borderWidth = 2,
			fillColor = display.COLOR_BLACK,
			borderColor = cc.c3b(1, 0, 0)
		})
		stencil.pos(stencil, 50, 50):anchor(0.5, 0.5)

		local clipper = cc.ClippingNode:create()

		clipper.pos(clipper, posx, posy):anchor(0.5, 0.5)
		clipper.setStencil(clipper, stencil)
		clipper.add2(clipper, self)

		msg = an.newLabel(text, config[tipType].fontSize, config[tipType].smokeSize, {
			color = config[tipType].fontColor,
			sc = config[tipType].smokeColor
		}):add2(clipper):runs(animation[tipType])
	else
		local alignCenterSet = false

		if tipType == 6 then
			alignCenterSet = true
		end

		msg = an.newLabelM(300, config[tipType].fontSize, config[tipType].smokeSize, {
			manual = true,
			center = alignCenterSet
		}):pos(config[tipType].position.x, config[tipType].position.y):add2(self)

		if tipType == 6 or tipType == 8 then
			msg.anchor(msg, 0.5, 0.5)
		end

		if tipType == 7 then
			msg.anchor(msg, 1, 0.5)
		end

		msg.nextLine(msg)

		for i = 1, #contentT, 1 do
			for j = 1, #contentT[i], 1 do
				if #contentT[i][j] == 1 then
					msg.addLabel(msg, contentT[i][j][1], (defaultColor and defaultColor) or config[tipType].fontColor)
				else
					msg.addLabel(msg, contentT[i][j][2], contentT[i][j][1])
				end
			end

			msg.nextLine(msg)
		end

		msg.runs(msg, animation[tipType])
	end

	msg.setCascadeOpacityEnabled(msg, true)

	msg.type = tipType
	msg.text = text
	self.msgs[#self.msgs + 1] = msg

	local function getMsgCount()
		local count = 0

		for k, v in pairs(self.msgs) do
			if v.type == tipType then
				count = count + 1
			end
		end

		return count
	end

	local function removeFirst()
		for i = 1, #self.msgs, 1 do
			if self.msgs[i].type == tipType then
				self.msgs[i]:removeSelf()
				table.remove(self.msgs, i)

				return 
			end
		end

		return 
	end

	if maxLine[tipType] < slot10() then
		removeFirst()
	end

	self.upt(self, tipType, config[tipType].position, #lines)

	return 
end
tip.showPVP = function (self, leftList, rightList)
	local job_name = {
		[0] = "战",
		"法",
		"道"
	}
	self.pvpLabels = self.pvpLabels or {}

	for k, v in ipairs(self.pvpLabels) do
		v.removeSelf(v)
	end

	for k, v in ipairs(leftList) do
		local job = job_name[v.Fuserjob] or ""
		local state = (v.Fuserdie and "亡") or v.Fuserlifeleft
		self.pvpLabels[#self.pvpLabels + 1] = an.newLabel(v.Fusername, 20, 1, {
			color = def.colors.C3794fb
		}):anchor(0, 0.5):pos(display.left + 50, display.height - 95 - k*25):addTo(self)
		self.pvpLabels[#self.pvpLabels + 1] = an.newLabel(job, 20, 1, {
			color = def.colors.C3794fb
		}):anchor(0, 0.5):pos(display.left + 210, display.height - 95 - k*25):addTo(self)
		self.pvpLabels[#self.pvpLabels + 1] = an.newLabel(state, 20, 1, {
			color = def.colors.C3794fb
		}):anchor(0, 0.5):pos(display.left + 250, display.height - 95 - k*25):addTo(self)
	end

	for k, v in ipairs(rightList) do
		local job = job_name[v.Fuserjob] or ""
		local state = (v.Fuserdie and "亡") or v.Fuserlifeleft
		self.pvpLabels[#self.pvpLabels + 1] = an.newLabel(v.Fusername, 20, 1, {
			color = def.colors.Ce66946
		}):anchor(0, 0.5):pos(display.right - 270, display.height - 95 - k*25):addTo(self)
		self.pvpLabels[#self.pvpLabels + 1] = an.newLabel(job, 20, 1, {
			color = def.colors.Ce66946
		}):anchor(0, 0.5):pos(display.right - 110, display.height - 95 - k*25):addTo(self)
		self.pvpLabels[#self.pvpLabels + 1] = an.newLabel(state, 20, 1, {
			color = def.colors.Ce66946
		}):anchor(0, 0.5):pos(display.right - 70, display.height - 95 - k*25):addTo(self)
	end

	return 
end

return tip
