local task = {
	list = {},
	listL = {},
	callback = {}
}
local TASK_TYPE_MAIN = 1
local TASK_TYPE_SUB = 2
local TASK_TYPE_EVERYDAY = 3
local TASK_TYPE_TITLE = 4
local TASK_STATE_UNRECEIVED = 1
local TASK_STATE_RECEIVED = 2
local TASK_STATE_FINISHED = 3
local TaskType = {
	"主线任务",
	"支线任务",
	"每日任务",
	"封号任务",
	"Type Error"
}
local TaskState = {
	"未接",
	"已接",
	"已完成",
	"State Error"
}
task.initAllTask = function (self, result)
	for k, v in pairs(result.FTaskList) do
		local tmpTask = {
			taskId = v.FTaskID,
			taskType = v.FTaskType,
			taskState = v.FTaskState,
			taskInfo = v.FTaskInfo,
			taskTip = v.FShowTip
		}

		if v.FShowUIFlag == 1 then
			self.updateTask(self, tmpTask, 1)
		else
			self.updateTask(self, tmpTask, 2)
		end
	end

	return 
end
task.uptTaskDetail = function (self, result)
	local task = result.FTaskInfo
	local tmpTask = {
		taskId = task.FTaskID,
		taskInfo = task.FTaskInfo,
		taskType = task.FTaskType,
		taskState = task.FTaskState,
		taskTip = task.FShowTip
	}

	self.updateTask(self, tmpTask, task.FShowUIFlag)

	return 
end
task.delete = function (self, result)
	self.delTask(self, result.FTaskInfo.FTaskID, result.FTaskInfo.FShowUIFlag)

	return 
end
task.getTask = function (self, id, type)
	if not type then
		type = {
			0,
			1
		}
	else
		type = {
			type
		}
	end

	for i, v in ipairs(type) do
		local tType = (v == 1 and "left") or "panel"
		local list = self.list[tType] or {}

		for i, v in ipairs(list) do
			if v.taskId == id then
				return v
			end
		end
	end

	return 
end
task.updateTask = function (self, task, type)
	type = type or 0
	local tmpTask = self.getTask(self, task.taskId, type)
	local tType = (type == 1 and "left") or "panel"

	print(" tType ", tType)

	if not tmpTask then
		if not self.list[tType] then
			self.list[tType] = {}
		end

		self.list[tType][#self.list[tType] + 1] = task
	else
		for k, v in pairs(task) do
			tmpTask[k] = v
		end
	end

	return 
end
task.delTask = function (self, id, type)
	type = type or 0
	local tType = (type == 1 and "left") or "panel"
	local list = self.list[tType] or {}

	dump(list)
	print("delTask ============")

	for i, v in ipairs(list) do
		if v.taskId == id then
			table.remove(list, i)

			break
		end
	end

	dump(list)

	return 
end
task.getTaskWithType = function (self, taskType, type)
	type = type or 0
	local taskList = {}

	if not type then
		return taskList
	end

	local tType = (type == 1 and "left") or "panel"
	local list = self.list[tType] or {}

	for i, v in ipairs(list) do
		if v.taskType == taskType or taskType == -1 then
			taskList[#taskList + 1] = v
		end
	end

	table.sort(taskList, function (a, b)
		return (b.taskState or 0) < (a.taskState or 0)
	end)

	return taskList
end
task.parseContent = function (self, content, params)
	local function parseCMD(v)
		while true do
			local pos1 = string.find(v, "<")
			local pos2 = string.find(v, ">")

			if pos1 and pos2 then
				content:addLabel(string.sub(v, 1, pos1 - 1), params.color or cc.c3b(255, 255, 255))

				local cmd = string.sub(v, pos1 + 1, pos2 - 1)

				if string.upper(cmd) ~= "C" and string.upper(cmd) ~= "/C" then
					local text = ""
					local cmdstr, color = nil
					local pos3 = string.find(cmd, "/")

					if pos3 then
						text = string.sub(cmd, 1, pos3 - 1)
						cmdstr = string.sub(cmd, pos3 + 1, #cmd)
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
						content:setFontSize(tonumber(cmdstr))
					else
						local labelParams = nil

						if cmdstr and string.upper(cmdstr) ~= "FCOLOR" then
							params.cmdStr = color
							slot9 = {
								addTouchSizeY = 12,
								easyTouch = true,
								ani = true,
								callback = function ()
									print(" cmdstr ", cmdstr)

									local rsb = DefaultClientMessage(CM_TaskCommand)
									rsb.FTaskID = params.taskId or 0
									rsb.FParam = color or ""

									MirTcpClient:getInstance():postRsb(rsb)

									return 
								end
							}
							labelParams = slot9
						end

						content:addLabel(text, params.color or def.colors.get(tonumber(color)) or def.colors.clYellow, nil, nil, labelParams):setName(text)
					end
				end

				v = string.sub(v, pos2 + 1, string.len(v))
			else
				content:addLabel(v, params.color or cc.c3b(255, 255, 255))

				break
			end
		end

		return 
	end

	if params.body == nil then
		p2("-------------task:parseContent---------params.body == nil---------")

		return 
	end

	params.body = string.gsub(params.body, "\\", "")
	local lines = string.split(params.body, "|")

	for i, line in ipairs(slot4) do
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

return task
