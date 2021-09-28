local common = import("..common.common")
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local task = class("task", function ()
	return display.newNode()
end)

table.merge(slot3, {
	container = {}
})

task.ctor = function (self, params)
	self._supportMove = true
	params = params or {}
	local bg = res.get2("pic/common/black_2.png"):addTo(self):anchor(0, 0)

	self.size(self, bg.getContentSize(bg)):anchor(0.5, 0.5):center()

	local leftbg = display.newScale9Sprite(res.getframe2("pic/common/black_4.png"), 14, 14, cc.size(145, 392)):addTo(self):anchor(0, 0)
	local rightbg = display.newScale9Sprite(res.getframe2("pic/common/black_4.png"), 164, 14, cc.size(466, 392)):addTo(self):anchor(0, 0)

	display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/node_bg.png"), 2, 2, cc.size(462, 386)):addTo(rightbg):anchor(0, 0)

	self.leftbg = rightbg

	an.newLabel("任务", 20, 0, {
		color = def.colors.Cd2b19c
	}):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 10):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).addTo(slot5, bg):pos(bg.getw(bg) - 9, bg.geth(bg) - 9):anchor(1, 1)

	local strs = {
		"主线任务",
		"支线任务",
		"日常任务",
		"限时任务"
	}
	self.tabs = common.tabs(leftbg, {
		strs = strs,
		lc = {
			normal = def.colors.Cf0c896,
			select = def.colors.Cf0c896
		}
	}, function (idx, btn)
		self:processUpt(idx, g_data.task:getTaskWithType(idx))

		return 
	end, {
		tabTp = 2,
		repeatClk = true,
		pos = {
			offset = 50,
			x = 18,
			y = self.geth(common) - 96,
			anchor = cc.p(0, 0.5)
		}
	})

	return 
end
task.processUpt = function (self, idx, items)
	if self.curSubIdx == idx and idx ~= nil then
		return 
	end

	idx = idx or self.curSubIdx
	items = items or g_data.task:getTaskWithType(idx)
	self.curSubIdx = idx

	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addTo(self.leftbg)
	local infoView = an.newScroll(1, 2, 466, 386):add2(self.content)
	local h = 114

	infoView.setScrollSize(infoView, 478, math.max(324, math.modf((#items - 1)/2)*h))
	table.sort(items, function (lv, rv)
		if lv.taskId < rv.taskId then
			return true
		end

		return 
	end)

	for k = #items, 1, -1 do
		local v = items[k]
		local i = #items - k + 1
		local node = res.get2("pic/panels/task/bg.png").anchor(slot11, 0, 1):pos((i%2 == 0 and 233) or 3, infoView.getScrollSize(infoView).height - math.modf((i - 1)/2)*h - 2):add2(infoView)

		node.setTouchSwallowEnabled(node, false)
		res.get2("pic/panels/shop/line02.png"):pos(node.getw(node)*0.5, node.geth(node) - 50):add2(node)

		if v.taskInfo then
			print("v.taskState ", v.taskState)

			if v.taskState ~= 3 then
				local btnText = nil

				if v.taskState == 1 then
					btnText = "可接取"
				elseif v.taskState == 2 then
					btnText = "进行中"
				end

				local param = {
					body = v.taskInfo,
					taskId = v.taskId
				}

				self.parseContent(self, nil, param)
				an.newLabel(param.taskTitleStr or "", 22, 1, {
					color = def.colors.Cdcd2be
				}):anchor(0.5, 0.5):add2(node):pos(node.getw(node)*0.5, node.geth(node) - 30)
				an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					local rsb = DefaultClientMessage(CM_TaskCommand)
					rsb.FTaskID = v.taskId or 0
					rsb.FParam = param.cmdStr or ""

					MirTcpClient:getInstance():postRsb(rsb)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					label = {
						btnText,
						18,
						1,
						{
							color = def.colors.btn20
						}
					}
				}).add2(slot14, node):anchor(0.5, 0.5):pos(node.getw(node)*0.5, 40)
			else
				local content = an.newLabelM(node.getw(node) - 30, 22, 1, {
					center = 1
				}):anchor(0.5, 0.5)
				local pos1 = string.find(v.taskInfo, "{")
				local pos2 = string.find(v.taskInfo, "}")
				local bodyStr = v.taskInfo
				local goods, ends = nil

				if pos1 and pos2 then
					bodyStr = string.sub(v.taskInfo, 1, pos1 - 1)
					goods = string.sub(v.taskInfo, pos1 + 1, pos2 - 1)
					ends = string.sub(v.taskInfo, pos2 + 1)
					bodyStr = bodyStr .. (ends or "")
				end

				local param = {
					body = bodyStr,
					taskId = v.taskId
				}

				self.parseContent(self, content, param)

				if goods then
					self.parseGoods(self, content, {
						body = goods,
						taskId = v.taskId
					})
				end

				content.add2(content, node):pos(node.getw(node)*0.5, node.geth(node)*0.5):anchor(0.5, 0.5)
				node.enableClick(node, function ()
					local rsb = DefaultClientMessage(CM_TaskCommand)
					rsb.FTaskID = v.taskId or 0
					rsb.FParam = param.cmdStr or ""

					MirTcpClient:getInstance():postRsb(rsb)

					return 
				end, {
					support = "scroll"
				})
				res.get2("pic/panels/task/wanc.png").add2(slot19, node):pos(node.getw(node) - 45, node.geth(node) - 35)
			end
		else
			an.newLabel(v.taskTitle, 22, 1, {
				color = def.colors.Cdcd2be
			}):anchor(0.5, 0.5):add2(node):pos(node.getw(node)*0.5, node.geth(node) - 30)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				local rsb = DefaultClientMessage(CM_TaskDetail)
				rsb.FTaskID = v.taskId
				rsb.FShowUIFlag = 1

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					"查看详情",
					18,
					1,
					{
						color = def.colors.btn20
					}
				}
			}).add2(slot12, node):anchor(0.5, 0.5):pos(node.getw(node)*0.5, 40)
		end
	end

	return 
end
task.parseContent = function (self, content, params)
	local function parseCMD(v)
		while true do
			local pos1 = string.find(v, "<")
			local pos2 = string.find(v, ">")

			if pos1 and pos2 then
				if content then
					content:addLabel(string.sub(v, 1, pos1 - 1), def.colors.Cdcd2be)
				end

				params.taskTitleStr = string.sub(v, 1, pos1 - 1)
				local cmd = string.sub(v, pos1 + 1, pos2 - 1)

				if string.upper(cmd) ~= "C" and string.upper(cmd) ~= "/C" then
					local text = ""
					local cmdstr, color = nil
					local pos3 = string.find(cmd, "/")

					if pos3 then
						text = string.sub(cmd, 1, pos3 - 1)
						cmdstr = string.sub(cmd, pos3 + 1, #cmd)

						print(text, cmdstr)

						local pos4 = string.find(cmdstr, "=")

						if pos4 then
							color = string.sub(cmdstr, pos4 + 1, #cmdstr)
							cmdstr = string.sub(cmdstr, 1, pos4 - 1)

							if color == "red" then
								color = 249
							end
						end
					else
						text = cmd
					end

					if string.upper(text) == "FONTSIZE" then
						if content then
							content:setFontSize(tonumber(cmdstr))
						end
					else
						local labelParams = nil

						if cmdstr and string.upper(cmdstr) ~= "FCOLOR" then
							params.cmdStr = color
							slot9 = {
								addTouchSizeY = 12,
								easyTouch = true,
								ani = true,
								callback = function ()
									print(" cmdstr ", cmdstr, color)

									local rsb = DefaultClientMessage(CM_TaskCommand)
									rsb.FTaskID = params.taskId or 0
									rsb.FParam = color or ""

									MirTcpClient:getInstance():postRsb(rsb)

									return 
								end
							}
							labelParams = slot9
						end

						if content then
							content:addLabel(text, def.colors.clYellow, nil, nil, labelParams):setName(text)
						end
					end
				end

				v = string.sub(v, pos2 + 1, string.len(v))
			else
				if content then
					content:addLabel(v, def.colors.Cdcd2be)
				end

				break
			end
		end

		return 
	end

	params.body = string.gsub(params.body, "\\", "")
	local lines = string.split(params.body, "|")

	for i, line in ipairs(slot4) do
		local parts = string.split(line, "^")

		if content then
			slot11 = content.getw(content)/#parts
		end

		for i, str in ipairs(parts) do
			if 1 < i and content then
				content.setCurLineWidthCnt(content, (i - 1)*space)
			end

			parseCMD(str)
		end

		if content then
			content.nextLine(content)
		end
	end

	return 
end
task.parseGoods = function (self, content, params)
	params.body = string.gsub(params.body, "\\", "")
	params.body = string.gsub(params.body, "\"", "")
	local lines = string.split(params.body, ",")
	local nodeContain = display.newNode():size(content.getw(content) - 10, 60)

	content.addNode(content, nodeContain, 2)

	local beginX = 0

	for i, line in ipairs(lines) do
		local parts = string.split(line, "*")

		print("Goods ", parts[1], parts[2])

		local data = nil

		if parts[1] == "金币" then
			data = {
				looks = 115
			}
		elseif parts[1] == "经验" then
			data = {
				looks = 1186
			}
		else
			data = self.getItemProWithName(self, parts[1])
		end

		if data then
			local pic = res.get2("pic/common/itembg2.png"):addTo(nodeContain):anchor(0, 0):pos(beginX, 10)

			res.get("items", data.looks):add2(pic):pos(pic.getw(pic)*0.5, pic.geth(pic)*0.5)

			beginX = beginX + pic.getw(pic) + 4
			local label = an.newLabel("X" .. parts[2], 22, 1):anchor(0, 0):pos(beginX, 10):addto(nodeContain)
			beginX = beginX + label.getw(label) + 10
		end
	end

	return 
end
task.getItemProWithName = function (self, name)
	for k, v in pairs(def.items) do
		if type(v) == "table" and v.name == name then
			return v
		end
	end

	return 
end

return task
