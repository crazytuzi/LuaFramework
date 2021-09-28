local magic = import("..common.magic")
local iconFunc = import(".iconFunc")
local detail = class("detail", function ()
	return display.newNode()
end)

table.merge(slot2, {
	lock,
	content
})

detail.endLook = function (self, widgetx, widgety)
	if self.lock then
		return 
	end

	self.lock = true
	local x, y = self.content:getPosition()

	self.content:scaleTo(0.2, 0.01)
	self.content:runs({
		cc.MoveTo:create(0.1, cc.p(self.getMovePos(self, widgetx, widgety, x, y))),
		cc.MoveTo:create(0.1, cc.p(widgetx, widgety)),
		cc.CallFunc:create(function ()
			self:removeSelf()

			return 
		end)
	})

	return 
end
detail.ctor = function (self, config, data, widgetx, widgety, widgetw, widgeth, from, widget)
	self.size(self, display.width, display.height):addto(main_scene.ui, main_scene.ui.z.detail)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "ended" then
			self:endLook(widgetx, widgety)
		end

		return true
	end)

	local space = 10
	local count = slot9
	local maxw = 200
	self.content = display.newNode():add2(self)
	local editNode = nil

	if widget and widget.getEditNode then
		editNode = widget.getEditNode(widget)
		maxw = math.max(maxw, editNode.getw(editNode) + space*2)
	end

	local function addLine()
		local line = res.get2("pic/console/line.png"):anchor(0.5, 0):pos(maxw/2, count):add2(self.content)

		line.scaleX(line, (maxw - space*2)/line.getw(line))

		count = count + line.geth(line)

		return 
	end

	local hasRemove = not config.banRemove and from == "console"

	if hasRemove then
		display.newScale9Sprite(res.getframe2("pic/scale/scale10.png")).anchor(slot15, 0.5, 0):pos(maxw/2, count - 3):size(maxw - space*2, 32):add2(self.content):enableClick(function ()
			self:endLook(widgetx, widgety)
			main_scene.ui.console:removeWidget(data.key)

			return 
		end)
		an.newLabel("隐藏", 24, 1, {
			color = cc.c3b(255, 255, 0)
		}).pos(slot15, maxw/2, count - 3):anchor(0.5, 0):add2(self.content)

		count = count + 32 + 5
	end

	if editNode then
		editNode.pos(editNode, space, count):add2(self.content)

		count = count + editNode.geth(editNode)
		local title = an.newLabel("设置:", 18, 1, {
			color = cc.c3b(0, 255, 0)
		}):pos(space, count):add2(self.content)
		count = count + title.geth(title)

		addLine()
	end

	fixedXText = (config.fixedX and "不可左右移动") or "可左右移动"
	local fixedYText = (config.fixedY and "不可上下移动") or "可上下移动"
	local removeText = (config.banRemove and "不可隐藏") or "可隐藏"
	local red = cc.c3b(255, 0, 0)
	local green = cc.c3b(0, 255, 0)
	local xColor = (config.fixedX and red) or green
	local yColor = (config.fixedY and red) or green
	local removeColor = (config.banRemove and red) or green

	if from == "console" and (fixedXText or fixedYText or removeText) then
		local label = an.newLabelM(maxw - space*2, 18, 1, {
			manual = true
		}):pos(space, count):add2(self.content)

		if xColor == red and yColor == red then
			fixedXText = "不可移动"

			label.nextLine(label):addLabel(fixedXText, xColor)
		else
			label.nextLine(label):addLabel(fixedXText, xColor)
			label.nextLine(label):addLabel(fixedYText, yColor)
		end

		label.nextLine(label):addLabel(removeText, removeColor)

		count = count + label.geth(label)

		addLine()
	end

	local desc = config.desc

	if config.class == "btnMove" and config.btntype == "skill" then
		desc = self.processSkillExtend(self, config, data, from)
	end

	if desc then
		if config.class == "btnMove" and config.btntype == "skill" then
			local descLabel = an.newLabelM(maxw - space*2, 18, 1):pos(space, count):add2(self.content):addLabel("描述: ", cc.c3b(0, 255, 0))

			for i, v in ipairs(desc) do
				descLabel.addLabel(descLabel, v.text, v.color)
			end

			count = count + descLabel.geth(descLabel)

			addLine()
		else
			local descLabel = an.newLabelM(maxw - space*2, 18, 1):pos(space, count):add2(self.content):addLabel("描述: ", cc.c3b(0, 255, 0)):addLabel(desc)
			count = count + descLabel.geth(descLabel)

			addLine()
		end
	end

	local subtitle = nil

	if config.class == "btnMove" then
		if config.btntype == "normal" then
			subtitle = "普通按钮"
		elseif config.btntype == "base" then
			subtitle = "基本技能"
		elseif config.btntype == "setting" then
			subtitle = "设置快捷键"
		elseif config.btntype == "skill" then
			subtitle = "职业技能"
		elseif config.btntype == "panel" then
			subtitle = "面板快捷键"

			if "面板快捷键" then
			end
		end
	elseif config.key == "btnTask" or config.key == "rocker" or config.key == "btnPet" or config.key == "chat" then
		subtitle = "普通按钮"
	elseif config.banRemove then
		subtitle = "基础模块"
	end

	local maintitle = config.name or ""

	if config.btntype == "skill" then
		local skillLvl = g_data.player:getMagicLvl(data.magicId)
		local magicData = def.magic.getMagicConfigByUid(data.magicId, skillLvl)

		if magicData then
			if from == "skillHero" then
				maintitle = magicData.heroName
			else
				maintitle = magicData.name
			end
		end
	end

	local mainPos = cc.p(space + 80, count + ((subtitle and 45) or 30))
	local subPos = cc.p(space + 80, count + 15)
	local main_title = an.newLabel(maintitle, 18, 1, {
		color = cc.c3b(0, 255, 0)
	}):pos(mainPos.x, mainPos.y):add2(self.content)
	local sub_title = nil

	if subtitle then
		sub_title = an.newLabel(subtitle, 18, 1):pos(subPos.x, subPos.y):add2(self.content)
	end

	local files = iconFunc:getFilenames(config, data)

	if config.banRemove then
		main_title.setPositionX(main_title, space)

		if sub_title then
			sub_title.setPositionX(sub_title, space)
		end
	elseif files.sprite then
		local icon = res.get2(files.bg):pos(space + 40, count + 40):add2(self.content)

		res.get2(files.sprite):pos(icon.centerPos(icon)):add2(icon)
	end

	count = count + 80
	count = count + space
	local size = cc.size(maxw, count)
	local x, y = nil

	local function checkx(x)
		if x - size.width/2 < 0 then
			x = size.width/2 or x
		end

		if display.width < x + size.width/2 then
			x = display.width - size.width/2 or x
		end

		return x
	end

	local function checky(y)
		if y - size.height/2 < 0 then
			y = size.height/2 or y
		end

		if display.height < y + size.height/2 then
			y = display.height - size.height/2 or y
		end

		return y
	end

	if 0 < widgetx - widgetw/2 - size.width then
		x = widgetx - widgetw/2 - size.width/2
		y = slot35(widgety + 50)
	end

	if not x and widgetx + widgetw/2 + size.width < display.width then
		x = widgetx + widgetw/2 + size.width/2
		y = checky(widgety + 50)
	end

	if not x and widgety + widgeth/2 + size.height < display.height then
		x = checkx(widgetx)
		y = widgety + widgeth/2 + size.height/2
	end

	if not x and 0 < widgety - widgeth/2 - size.height then
		x = checkx(widgetx)
		y = widgety - widgeth/2 - size.height/2
	end

	if not x then
		y = checky(widgety)
		x = checkx(widgetx)
	end

	local beganPos, beganTouchPos = nil

	self.content:setTouchEnabled(true)
	self.content:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			beganPos = cc.p(self.content:getPosition())
			beganTouchPos = cc.p(event.x, event.y)

			return true
		elseif event.name == "moved" then
			self.content:pos(event.x - beganTouchPos.x + beganPos.x, event.y - beganTouchPos.y + beganPos.y)
		end

		return 
	end)
	self.content.anchor(slot38, 0.5, 0.5):size(size):scale(0.01):scaleTo(0.2, 1)
	self.content:pos(widgetx, widgety)
	self.content:runs({
		cc.MoveTo:create(0.1, cc.p(self.getMovePos(self, widgetx, widgety, x, y))),
		cc.MoveTo:create(0.1, cc.p(x, y))
	})
	display.newScale9Sprite(res.getframe2("pic/scale/scale5.png")):size(size):anchor(0, 0):add2(self.content, -1)

	return 
end
detail.getMovePos = function (self, sx, sy, dx, dy)
	local retx, rety = nil

	if sx < dx then
		retx = sx + 50
	elseif dx < sx then
		retx = sx - 50
	end

	if sy < dy then
		rety = sy - 50
	elseif dy < sy then
		rety = sy + 50
	end

	return retx or sx, rety or sy - 50
end
detail.expressionIsFront = function (self, from, magicId)
	local isFront = from ~= "skillHero"

	if not isFront then
		local isUnion = checkIn(tonumber(magicId), {
			50,
			55
		})

		if isUnion then
			isFront = g_data.player.job <= g_data.hero.job
		end
	end

	return isFront
end
detail.processSkillExtend = function (self, config, data, from)
	local desc = {}
	local skillLvl = g_data.player:getMagicLvl(data.magicId)
	local magicData = def.magic.getMagicConfigByUid(data.magicId, skillLvl)

	if magicData then
		local isFront = self.expressionIsFront(self, from, data.magicId)
		local name = (from == "skillHero" and magicData.heroName) or magicData.name
		local descData = def.skill[name]

		if not descData then
			print("没有取到" .. name .. "技能数据")

			return 
		end

		dump(descData)

		if config.SkillLv then
			local descString = descData and descData[4]
			local pos_start = 1
			local pos_end = nil

			repeat
				local s1, e1 = string.find(descString, "%u~%u", pos_start)
				local s2, e2 = string.find(descString, "%u", pos_start)
				local s, e = nil

				if not s1 and not s2 then
					break
				elseif not s2 then
					e = e1
					s = s1
				elseif not s1 then
					e = e2
					s = s2
				elseif s1 <= s2 then
					e = e1
					s = s1
				else
					e = e2
					s = s2
				end

				desc[#desc + 1] = {
					text = string.sub(descString, pos_start, s - 1)
				}
				local expression = string.sub(descString, s, e)
				local valueString = self.calcExpression(self, expression, descData, config.SkillLv, isFront)
				desc[#desc + 1] = {
					text = valueString,
					color = display.COLOR_RED
				}
				pos_start = e + 1
				pos_end = e
			until pos_end == string.len(descString)

			if not pos_end then
				desc[#desc + 1] = {
					text = descString
				}
			elseif pos_end and pos_end < string.len(descString) then
				desc[#desc + 1] = {
					text = string.sub(descString, pos_end + 1)
				}
			end

			local skill_level = 0

			if config.SkillLv then
				skill_level = config.SkillLv
			end

			if skill_level < 6 then
				local begin_index = 14
				local next_needLevel = tonumber(descData[begin_index + skill_level])

				if next_needLevel then
					local str_level = common.getLevelText(next_needLevel)
					desc[#desc + 1] = {
						text = "提升至下一级所需人物等级："
					}
					desc[#desc + 1] = {
						text = str_level,
						color = display.COLOR_RED
					}
					desc[#desc + 1] = {
						text = "级。"
					}
				end
			end
		else
			local str = ""
			slot11 = string.gmatch
			slot12 = descData and descData[4]

			for sub in slot11(slot12, "[^(A-DN)~]") do
				str = str .. sub
			end

			for i, v in ipairs(self.wordFilter(self)) do
				str = string.gsub(str, v, "")
			end

			desc[#desc + 1] = {
				text = str
			}
		end
	end

	return desc
end
detail.calcExpression = function (self, express, data, lv, front)
	local result = nil

	while true do
		local cfg = {
			nil,
			nil,
			nil,
			nil,
			"N",
			"A",
			"B",
			"C",
			"D",
			"A",
			"B",
			"C",
			"D"
		}

		local function dataError(index)
			if data[index] == "" then
				p2("error", "[skilldesc cofig is error] : Name:", (front and data[2]) or data[3], cfg[index] .. " express is nil, index: ", index)

				return true
			end

			return 
		end

		if express == "N" then
			if slot7(5) then
				return result
			end

			result = math.floor(self.calcField(self, data[5], lv)) .. ""
		elseif express == "A" then
			if front then
				if dataError(6) then
					break
				end

				result = math.floor(self.calcField(self, data[6], lv)) .. ""
			else
				if dataError(10) then
					break
				end

				result = math.floor(self.calcField(self, data[10], lv)) .. ""
			end
		elseif express == "A~B" then
			if front then
				if dataError(6) or dataError(7) then
					break
				end

				result = math.floor(self.calcField(self, data[6], lv)) .. "~" .. math.ceil(self.calcField(self, data[7], lv))
			else
				if dataError(10) or dataError(11) then
					break
				end

				result = math.floor(self.calcField(self, data[10], lv)) .. "~" .. math.ceil(self.calcField(self, data[11], lv))
			end
		elseif express == "C~D" then
			if front then
				if dataError(8) or dataError(9) then
					break
				end

				result = math.floor(self.calcField(self, data[8], lv)) .. "~" .. math.ceil(self.calcField(self, data[9], lv))
			else
				if dataError(12) or dataError(13) then
					break
				end

				result = math.floor(self.calcField(self, data[12], lv)) .. "~" .. math.ceil(self.calcField(self, data[13], lv))
			end
		end

		break
	end
end
detail.getExpressByLevel = function (self, expression, lv)
	local list = string.split(expression, "#")

	if #list == 1 then
		return expression
	end

	for i, v in ipairs(list) do
		if string.find(v, "@") and string.find(v, "&") then
			local r = string.gsub(v, "@", "")
			local data = string.split(r, "&")
			local num = string.split(data[1], "-")

			if num[2] then
				local num1 = tonumber(num[1])
				local num2 = tonumber(num[2])

				if num1 <= lv and lv <= num2 then
					expression = data[2]

					break
				end
			elseif tonumber(num[1]) == lv then
				expression = data[2]

				break
			end
		end
	end

	return expression
end
detail.calcField = function (self, express, lv)
	local function getExpress(str)
		local express = nil

		xpcall(function ()
			express = loadstring("return " .. str)()

			return 
		end, function ()
			express = str

			return 
		end)

		if type(slot1) == "table" then
			return (express[lv] and express[lv]) or express[0]
		else
			return str
		end

		return 
	end

	local expr = self.getExpressByLevel(slot0, express, lv)
	local newExpress = getExpress(expr)
	newExpress = string.gsub(newExpress, "<SkillLv>", "lv")
	local cfg = {
		"DC",
		"MC",
		"SC",
		"maxDC",
		"maxMC",
		"maxSC"
	}

	for i, v in ipairs(cfg) do
		newExpress = string.gsub(newExpress, "<" .. v .. ">", string.format("g_data.player.ability.F%s", string.gsub(v, "m", "M")))
		newExpress = string.gsub(newExpress, "<hero" .. v .. ">", string.format("g_data.hero.ability.F%s", string.gsub(v, "m", "M")))
	end

	local fun = loadstring("local lv = ... return " .. newExpress)

	return fun(lv)
end
detail.wordFilter = function (self)
	return {
		"%%",
		"点",
		"(骷髅等级最高可提升至级)",
		"(神兽等级最高可提升至级)",
		"(月灵等级最高可提升至级)"
	}
end

return detail
