local CheckDeleteMe = {}

local del_view_name = ""
local un_deleted_list = {}

function CheckDeleteMe:Update(now_time, elapse_time)
	self:OutputReport()
end

function CheckDeleteMe:OnReleaseView(view)
	if nil ~= view.view_name and "" ~= view.view_name then
		del_view_name = view.view_name
	elseif nil ~= view.ui_config then
		del_view_name = view.ui_config[1]
	end
	
	self:CheckChildDelete(view)
	del_view_name = ""
end

function CheckDeleteMe:OnDeleteObj(obj)
	self:CheckChildDelete(obj)
	obj.__is_deleted = true
end

function CheckDeleteMe:CheckChildDelete(obj)
	if nil == obj or "table" ~= type(obj) then
		return
	end

	for k1, v1 in pairs(obj) do
		if "table" == type(v1) then
			if nil ~= v1.DeleteMe then
				if not v1.__is_deleted then
					v1.__view_name = del_view_name
					table.insert(un_deleted_list, {v1, k1, debug.traceback()})
				end
			else
				for _, v2 in pairs(v1) do
					self:CheckChildDelete(v2)
				end
			end
		end
	end
end

function CheckDeleteMe:OutputReport()
	if #un_deleted_list > 0 then
		for _, v in pairs(un_deleted_list) do
			if nil ~= v[1] and not v[1].__is_deleted then
				local msg = string.format(" Do you remember call 'DeleteMe' ? key = %s\n%s", v[2], v[3])
				if "" ~= v[1].__view_name and nil ~= v[1].__view_name then
					msg = string.format("view_name %s, %s", v[1].__view_name, msg)
				else
					msg = msg .. "\nBecause not found view_name, so print detail :\n"
					for k2, v2 in pairs(v[1]) do
						msg = msg .. k2 .. '=' .. tostring(v2) .. "	"
					end
				end

				UnityEngine.Debug.LogError(msg)
			end
		end

		un_deleted_list = {}
	end
end

return CheckDeleteMe