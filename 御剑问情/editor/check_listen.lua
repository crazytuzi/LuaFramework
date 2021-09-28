local CheckListen = {}

local all_objs = {}
local output_list = {}

function CheckListen:Update(now_time, elapse_time)
	self:OutputReport()
end

function CheckListen:OnDeleteObj(obj)
	all_objs[obj] = nil
end

function CheckListen:OnCreateClass(class_type)
	self:RwObjNewFunction(class_type)
end

function CheckListen:RwObjNewFunction(_class_type)
	local class_type = _class_type
	local old_fun = class_type.New

	class_type.New = function ( ... )
		local t1 = self:CalcListenTotalNum()
		local obj = old_fun(...)
		local t2 = self:CalcListenTotalNum()

		self:RwObjDelFunction(obj, class_type, self:CalcDiffListenNum(t1, t2))

		return obj
	end
end

function CheckListen:RwObjDelFunction(_obj, _class_type, _old_t)
	local obj = _obj
	local class_type = _class_type
	local old_t = _old_t
	local old_fun = obj.DeleteMe

	obj.DeleteMe = function ( ... )
		local t1 = self:CalcListenTotalNum()
		old_fun(obj, ...)
		local t2 = self:CalcListenTotalNum()

		local end_t = self:CalcDiffListenNum(t2, t1)

		for k, v in pairs(old_t) do
			if v ~= end_t[k] then
				local view_name = ""
				if obj.view_name ~= nil then
					view_name = obj.view_name
				elseif nil ~= obj.ui_config then
					view_name = obj.ui_config[2]
				end

				local msg = string.format("Do you remember unlisten ? view_name:%s  reason : %s\n%s", view_name, k, debug.traceback())

				if nil == view_name or "" == view_name then
					msg = msg .. "\nBecause not found view_name, so print detail :\n"
					for k2, v2 in pairs(obj) do
						msg = msg .. k2 .. '=' .. tostring(v2) .. "	"
					end
				end

				table.insert(output_list, msg)
			end
		end
	end
end

function CheckListen:OnCreateObj(obj, class_type)
	all_objs[obj] = {class_type = class_type, begin_t = {}}
	local rw_list = {
			{"LoadCallBack", "ReleaseCallBack"},
			{"OpenCallBack", "CloseCallBack"},
		}

	for _, v1 in pairs(rw_list) do
		for _, v2 in pairs(v1) do
			if nil == obj[v2] then
				return
			end
		end
	end

	for k1, v1 in ipairs(rw_list) do
		for k2, v2 in ipairs(v1) do
			self:RwObjFunction(k1, k2, v2, obj, class_type)
		end
	end
end

function CheckListen:RwObjFunction(_group, _state, _fun_name, _obj, _class_type)
	if nil == _obj[_fun_name] then
		return
	end

	local group = _group
	local state = _state
	local fun_name = _fun_name
	local obj = _obj
	local class_type = _class_type

	obj[fun_name] = function ( ... )
		local view_name = obj.view_name
		if "" == view_name or nil == view_name then
			if nil ~= obj.ui_config then
				view_name = obj.ui_config[2] or "undefind"
			else
				view_name = "undefind"
			end
		end

		local t1_s = self:CalcListenTotalNum()

		class_type[fun_name](obj, ...)

		local t1_e = self:CalcListenTotalNum()
		local begin_t = all_objs[obj].begin_t

		if 1 == state then
			begin_t[group] = self:CalcDiffListenNum(t1_s, t1_e)

		elseif 2 == state then
			-- 计算事件差异
			local old1_t = begin_t[group] or {}
			begin_t[group] = {}

			local end1_t = self:CalcDiffListenNum(t1_e, t1_s)

			for k3, v3 in pairs(old1_t) do
				if v3 ~= end1_t[k3] then
					local msg = string.format("Do you remember unlisten ? view_name:%s  reason : %s\n%s", view_name, k3, debug.traceback())
					table.insert(output_list, msg)
				end
			end
		end
	end
end

function CheckListen:CalcDiffListenNum(t1, t2)
	local diff_t = {}
	for k,v in pairs(t2) do
		if nil == t1[k] or t2[k] > t1[k] then
			diff_t[k] = (diff_t[k] or 0) + 1
		end
	end

	return diff_t
end

function CheckListen:CalcListenTotalNum()
	local t = {}
	-- 全局事件
	if nil ~= GlobalEventSystem then
		GlobalEventSystem:GetEventNum(t)
	end

	-- 物品变化
	if nil ~= ItemData.Instance then
		t["item_change"] = ItemData.Instance:GetNotifyCallBackNum()
	end

	-- 人物数据
	if nil ~= PlayerData.Instance then
		t["player_data_change"] = PlayerData.Instance:GetTotalEventNum()
	end

	-- 红点提醒
	if nil ~= RemindManager.Instance then
		RemindManager.Instance:GetBindNum(t)
	end

	-- 红点提醒
	if nil ~= RemindManager.Instance then
		RemindManager.Instance:GetRegisterNum(t)
	end

	-- 功能引导
	if nil ~= FunctionGuide.Instance then
		FunctionGuide.Instance:GetRegisteGuideNum(t)
	end

	return t
end

function CheckListen:OutputReport()
	if #output_list <= 0 then
		return
	end

	for _, v in pairs(output_list) do
		UnityEngine.Debug.LogError(v)
	end

	output_list = {}
end

function CheckListen:OnGameStop()
	self:OutputReport()
end

return CheckListen