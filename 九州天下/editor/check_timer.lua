local CheckTimer = {}
local fun_map = {}
local output_list = {}

function CheckTimer:Update(now_time, elapse_time)
	self:OutputReport()
end

function CheckTimer:OnBindFun(obj, func, new_func)
	if nil == obj or nil == func or nil == new_func then
		return
	end

	if nil == fun_map[obj] then
		fun_map[obj] = {}
	end

	fun_map[obj][func] = new_func
end

function CheckTimer:OnReleaseView(obj)
	local fun_t = fun_map[obj]
	if nil ~= fun_t then
		self:CheckFunRefrence(obj, fun_t)
		fun_map[obj] = nil
	end
end

function CheckTimer:OnDeleteObj(obj)
	local fun_t = fun_map[obj]
	if nil ~= fun_t then
		self:CheckFunRefrence(obj, fun_t)
		fun_map[obj] = nil
	end
end

function CheckTimer:CheckFunRefrence(obj, fun_t)
	local view_name = obj.view_name
	if "" == view_name then
		view_name = "undefind"
	end

	for _, v in pairs(fun_t) do
		if GlobalTimerQuest:IsExistCallback(v) then
			local msg = string.format("Do you remember remove timer from TimerQuest ? view_name:%s \n%s", view_name, debug.traceback())
			table.insert(output_list, msg)
		end

		if CountDown.Instance:IsExistCallback(v) then
			local msg = string.format("Do you remember remove timer from CountDown ? view_name:%s \n%s", view_name, debug.traceback())
			table.insert(output_list, msg)
		end
	end

	if Runner.Instance:IsExistRunObj(obj) then
		local msg = string.format("Do you remember remove timer from Runnner ? view_name:%s \n%s", view_name, debug.traceback())
		table.insert(output_list, msg)
	end
end

function CheckTimer:OutputReport()
	if #output_list <= 0 then
		return
	end

	for _, v in pairs(output_list) do
		UnityEngine.Debug.LogError(v)
	end

	output_list = {}
end

return CheckTimer