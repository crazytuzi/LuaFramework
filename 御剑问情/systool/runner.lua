-- 说明: 根据外部设定的优先级在每一帧中依次执行所有托管的RunObj
Runner = Runner or BaseClass()

Status = Status or {NowTime = 0, ElapseTime = 0}

function Runner:__init()
	if Runner.Instance ~= nil then
		error("[Runner] attempt to create singleton twice!")
		return
	end
	Runner.Instance = self

	-- 用于标记某个模块是否已经注册,避免重复性的注册
	self.all_run_obj_list = {}
	self.id_count = 0

	--支持1 ~ 16级优先级指定, 1为最先执行, 16为最后执行
	self.priority_run_obj_list = {}
	for i = 1, 16 do
		table.insert(self.priority_run_obj_list, {})
	end
end

function Runner:__delete()
	Runner.Instance = nil
end

function Runner:Update(now_time, elapse_time)
	Status.NowTime = now_time
	Status.ElapseTime = elapse_time

	for i = 1, 16 do
		local priority_tbl = self.priority_run_obj_list[i]
		for _, v in pairs(priority_tbl) do
			v:Update(now_time, elapse_time)
		end
	end
end

-- 向Runner添加一个RunObj, RunObj必须存在Update方法
-- priority_level Update优先级 1-16,数字越小越先执行
function Runner:AddRunObj(run_obj, priority_level)
	local obj = self.all_run_obj_list[run_obj]
	if obj ~= nil then
		--已经存在该对象, 不重复添加
		return false
	end

	if run_obj["Update"] == nil then
		error("Runner:AddRunObj try to add a obj not have Update method!")
	end

	--对象不存在,正常添加
	self.id_count = self.id_count + 1
	priority_level = priority_level or 16
	self.all_run_obj_list[run_obj] = {priority_level, self.id_count}
	self.priority_run_obj_list[priority_level][self.id_count] = run_obj
end

-- 从Runner中删除一个run_obj
function Runner:RemoveRunObj(run_obj)
	local key_info = self.all_run_obj_list[run_obj]
	if key_info ~= nil then
		self.all_run_obj_list[run_obj] = nil
		self.priority_run_obj_list[key_info[1]][key_info[2]] = nil
	end
end

function Runner:IsExistRunObj(run_obj)
	return nil ~=  self.all_run_obj_list[run_obj]
end