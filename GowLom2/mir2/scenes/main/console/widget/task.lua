local common = import("...common.common")
local pointTip = import("...common.pointTip")
local task = class("task", function ()
	return display.newNode()
end)

table.merge(slot2, {
	useShoeMsgBoxTip = true,
	taskLines = {}
})

task.ctor = function (self, config, data)
	local deviceFix = 0

	if game.deviceFix then
		deviceFix = game.deviceFix
	end

	self.bg = display.newNode():size(260, 212):anchor(0.5, 0.5):pos(deviceFix + 40, display.height - 215)

	self.bg:addTo(self):anchor(0, 0.5)

	local showState = true
	local state = nil
	state = an.newBtn(res.gettex2("pic/panels/task/state.png"), function ()
		sound.playSound("103")

		showState = not showState

		state:setPositionX((showState and deviceFix + 316) or deviceFix + 48)
		self.bg:setVisible(showState)
		state:setScaleX((showState and 1) or -1)

		return 
	end, {
		pressImage = res.gettex2("pic/panels/task/state.png")
	}).addTo(slot6, self, 1):pos(deviceFix + 316, display.height - 214):anchor(0.5, 0.5)

	state.setScaleX(state, (showState and 1) or -1)

	local v = cache.getDiy(common.getPlayerName(), "taskshoeTipkey")

	if v then
		self.useShoeMsgBoxTip = v.taskshoeTip
	end

	return 
end
task.updateOnce = function (self)
	self.bg:removeAllChildren(true)

	self.taskLines = {}
	local task = g_data.task:getTaskWithType(-1, 1)

	table.sort(task, function (a, b)
		return a.taskType < b.taskType
	end)

	local colors = {
		cc.c3b(241, 237, 2),
		cc.c3b(50, 177, 108),
		cc.c3b(50, 177, 108),
		cc.c3b(50, 177, 108),
		cc.c3b(255, 255, 255)
	}
	local content = an.newLabelM(self.bg.getw(slot4) - 4, 20, 0):anchor(0, 0)

	for i, v in ipairs(task) do
		if v.taskState ~= 3 then
			print("v.taskState ", v.taskType)
			self.parseContent(self, content, {
				body = v.taskInfo,
				taskId = v.taskId,
				color = colors[v.taskType],
				type = v.taskType
			})
		end
	end

	local showH = math.min(self.bg:geth(), content.geth(content))
	local contentH = content.geth(content)
	local taskView = an.newScroll(2, 2, self.bg:getw() - 4, showH):add2(self.bg)

	display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), self.bg:getw()*0.5, self.bg:geth()*0.5, cc.size(self.bg:getw(), showH + 4)):add2(self.bg, -1)
	taskView.setScrollSize(taskView, self.bg:getw() - 4, math.max(showH, content.geth(content)))
	content.add2(content, taskView):pos(0, 0)
	taskView.anchor(taskView, 0.5, 0.5):pos(self.bg:getw()*0.5, self.bg:geth()*0.5)

	return 
end
task.parseContent = function (self, content, params)
	local flyshoeCounts = nil

	local function addShoeNode(label, text, cmdNum)
		local shoePos = string.find(text, "=")
		flyshoeCounts = string.sub(text, shoePos + 1, #text)

		if label then
			local shoeNode = res.get2("pic/panels/flyshoe/task_fly.png"):anchor(0.5, 0)

			an.newLabel("X" .. tostring(flyshoeCounts), 20, 1):anchor(0, 0.5):add2(shoeNode):pos(shoeNode.getw(shoeNode), 15)
			shoeNode.add2(shoeNode, label):pos(205, -15):enableClick(function ()
				if main_scene.ground.player.die then
					return 
				end

				if self.useShoeMsgBoxTip == true and tonumber(flyshoeCounts) ~= 0 then
					an.newMsgbox("使用传送功能将消耗" .. flyshoeCounts .. "个飞鞋,确认这么做吗?", function (idx)
						if idx == 2 then
							cache.saveDiy(common.getPlayerName(), "taskshoeTipkey", {
								taskshoeTip = false
							})

							self.useShoeMsgBoxTip = false
						end

						if g_data.player.ability.FFlyShoeCounts < tonumber(flyshoeCounts) then
							main_scene.ui:tip("飞鞋数量不足")

							return 
						end

						local rsb = DefaultClientMessage(CM_TaskCommand)
						rsb.FTaskID = params.taskId or 0
						rsb.FParam = cmdNum or ""

						MirTcpClient:getInstance():postRsb(rsb)

						return 
					end, {
						disableScroll = true,
						hasCancel = true,
						btnTexts = {
							"确定",
							"不再提示"
						}
					})
				else
					if g_data.player.ability.FFlyShoeCounts < tonumber(flyshoeCounts) then
						main_scene.ui.tip(self, "飞鞋数量不足")

						return 
					end

					local rsb = DefaultClientMessage(CM_TaskCommand)
					rsb.FTaskID = params.taskId or 0
					rsb.FParam = cmdNum or ""

					MirTcpClient:getInstance():postRsb(rsb)
				end

				if params.taskId then
					self:readTask(params.taskId)
				end

				return 
			end)
		end

		return 
	end

	local function parseCMD(v)
		while true do
			local pos1 = string.find(v, "<")
			local pos2 = string.find(v, ">")

			if pos1 and pos2 then
				local cmd = string.sub(v, pos1 + 1, pos2 - 1)

				if string.upper(cmd) ~= "C" and string.upper(cmd) ~= "/C" then
					local text = ""
					local cmdstr, cmdNum = nil
					local pos3 = string.find(cmd, "/")

					if pos3 then
						text = string.sub(cmd, 1, pos3 - 1)
						cmdstr = string.sub(cmd, pos3 + 1, #cmd)
						local pos4 = string.find(cmdstr, "=")

						if pos4 then
							cmdNum = string.sub(cmdstr, pos4 + 1, #cmdstr)
							cmdstr = string.sub(cmdstr, 1, pos4 - 1)
						end

						if cmdstr == "flycmd" and string.find(text, "=") then
							addShoeNode(content:getCurLabel(), text, cmdNum)

							return 
						end
					else
						text = cmd
					end

					if string.upper(text) == "FONTSIZE" then
						content:setFontSize(tonumber(cmdstr))
					else
						local labelParams = nil

						if cmdstr and string.upper(cmdstr) ~= "FCOLOR" then
							params.cmdStr = cmdNum
							slot9 = {
								addTouchSizeY = 12,
								easyTouch = true,
								ani = true,
								callback = function ()
									if cmdstr == "flycmd" then
										if main_scene.ground.player.die then
											return 
										end

										if self.useShoeMsgBoxTip == true and tonumber(flyshoeCounts) ~= 0 then
											an.newMsgbox("使用传送功能将消耗" .. flyshoeCounts .. "个飞鞋,确认这么做吗?", function (idx)
												if idx == 2 then
													cache.saveDiy(common.getPlayerName(), "taskshoeTipkey", {
														taskshoeTip = false
													})

													self.useShoeMsgBoxTip = false
												end

												if g_data.player.ability.FFlyShoeCounts < tonumber(flyshoeCounts) then
													main_scene.ui:tip("飞鞋数量不足")

													return 
												end

												local rsb = DefaultClientMessage(CM_TaskCommand)
												rsb.FTaskID = params.taskId or 0
												rsb.FParam = cmdNum or ""

												MirTcpClient:getInstance():postRsb(rsb)

												return 
											end, {
												disableScroll = true,
												hasCancel = true,
												btnTexts = {
													"确定",
													"不再提示"
												}
											})
										else
											if cmdstr == "flycmd" and g_data.player.ability.FFlyShoeCounts < tonumber(flyshoeCounts) then
												main_scene.ui.tip(cmdstr, "飞鞋数量不足")

												return 
											end

											local rsb = DefaultClientMessage(CM_TaskCommand)
											rsb.FTaskID = params.taskId or 0
											rsb.FParam = cmdNum or ""

											MirTcpClient:getInstance():postRsb(rsb)
										end
									else
										local rsb = DefaultClientMessage(CM_TaskCommand)
										rsb.FTaskID = params.taskId or 0
										rsb.FParam = cmdNum or ""

										MirTcpClient:getInstance():postRsb(rsb)
									end

									if params.taskId then
										self:readTask(params.taskId)
									end

									return 
								end
							}
							labelParams = slot9
						end

						content:addLabel(text, params.color or def.colors.clYellow, nil, nil, labelParams):setName(text)

						if params.taskId then
							self.taskLines[params.taskId] = content:getCurLabel()
						end

						if params.type == 2 then
							self:setTitlePointTip(params.taskId)
						end
					end
				end

				v = string.sub(v, pos2 + 1, string.len(v))
			else
				content:addLabel(v, cc.c3b(220, 210, 190))

				break
			end
		end
	end

	if params.body == nil then
		p2("-------------task:parseContent---------params.body == nil---------")

		return 
	end

	params.body = string.gsub(params.body, "\\", "")
	local lines = string.split(params.body, "|")

	for i, line in ipairs(slot6) do
		local parts = string.split(line, "^")
		local space = content.getw(content)/#parts

		for i, str in ipairs(parts) do
			if 1 < i then
				content.setCurLineWidthCnt(content, (i - 1)*space)
			end

			parseCMD(str)
		end

		content.nextLine(content)
	end

	return 
end
task.setTitlePointTip = function (self, taskId)
	local line = self.taskLines[taskId]
	local task = g_data.task:getTask(taskId, 1)

	if not line or not line.labelL or not task then
		return 
	end

	local visible = task.taskTip == 1
	local label = line.labelL[1]

	if label then
		local tip = line.getChildByName(line, "tip")

		if tip then
			tip.removeFromParent(tip)
		end

		if not visible then
			return 
		end

		tip = pointTip.attach(line, {
			type = 1,
			visible = true,
			dir = "right",
			ui = "small",
			custom = true,
			pos = cc.p(label.getw(label), label.geth(label) - 3)
		})

		tip.setName(tip, "tip")
	end

	return 
end
task.readTask = function (self, taskId)
	local task = g_data.task:getTask(taskId, 1)

	if not task then
		return 
	end

	task.taskTip = 0

	self.setTitlePointTip(self, taskId)

	local rsb = DefaultClientMessage(CM_TASKTIP)
	rsb.FTaskID = taskId

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

return task
