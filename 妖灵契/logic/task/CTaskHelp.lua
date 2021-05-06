module(..., package.seeall)

-- 获取指定门派NpcID
function GetSchoolNpcID(typeName)
	if not typeName or typeName(typeName) ~= "string" then
		typeName = "tutorid"
	end
	return DataTools.GetSchoolNpcID(g_AttrCtrl.school, typeName)
end

-- 获取任务分类名称
function GetTaskCategory(oTask)
	if not oTask then
		return
	end
	local taskType = oTask:GetValue("type")
	local taskCategory = define.Task.TaskCategory
	for _,v in pairs(taskCategory) do
		if taskType == v.ID then
			return v
		end
	end
end

-- 查找指定寻物任务所需物品，返回1:sidlist 2:itemTable
function GetTaskFindItemDic(oTask)
	if not oTask or not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		return
	end

	local needitem = oTask:GetValue("needitem")
	if needitem and #needitem > 0 then
		local sidList = {}
		local itemTable = {}
		for _,v in ipairs(needitem) do
			table.insert(sidList, v.itemid)
			itemTable[v.itemid] = v
		end
		return sidList, itemTable
	end
end

function IsTwoPointInRadiusTask(oTask)
	if not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_USE_ITEM) then
		printerror("不是有效的到达某地使用物品任务类型")
		return
	end
	local taskThing = oTask:GetProgressThing()
	if taskThing then
		return CTaskHelp.IsTwoPointInRadiusThing(taskThing)
	end
end

function IsTwoPointInRadiusThing(taskThing)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		local heroPos = oHero:GetPos()
		local centerPos = Vector3.New(taskThing.pos_x, taskThing.pos_y, 0)
		return CTaskHelp.IsTwoPointInRadiusPos(heroPos, centerPos, taskThing.radius)
	end
end

function IsTwoPointInRadiusPos(aPos, bPos, radius)
	local distance = Vector3.Distance(aPos, bPos)
	return distance < radius
end
