--
-- Author: LaoY
-- Date: 2018-07-11 20:09:56
-- pblua结构体装换成lua table保存 使用方便 但是内存略大点。
-- 10000条结构复杂的数据占用内存多15k左右
-- map测试，pblua结构体装换成lua table保存，lua table占用内存更小

local descriptor = require "tolua.protobuf.descriptor"
local FieldDescriptor = descriptor.FieldDescriptor

local function recursion(tab,pb,field)
	if field.message_type then
		tab[field.name] = {}
		if field.label == FieldDescriptor.LABEL_REPEATED then
			for i=1,#pb[field.name] do
				if field.message_type.containing_type ~= nil then
					--local key = pb[field.name][i][field.message_type.fields[1].name]
					--local value = pb[field.name][i][field.message_type.fields[2].name]
					local key = pb[field.name][i]["key"]
					
					-- tab[field.name][key] = pb[field.name][i]["value"]
					
					local value = pb[field.name][i]["value"]
					if field.message_type.fields[2].message_type then
						tab[field.name][key] = {}
						local len = #field.message_type.fields[2].message_type.fields
						for j=1,len do
							local info = field.message_type.fields[2].message_type.fields[j]
							if info.message_type or info.label == FieldDescriptor.LABEL_REPEATED then
								recursion(tab[field.name][key],value,info)
							else
								tab[field.name][key][info.name] = value[info.name]
							end
						end
					else
						tab[field.name][key] = value
					end
				else
					tab[field.name][i] = {}
					for j=1,#field.message_type.fields do
						-- local _field = field.message_type.fields[j]
						recursion(tab[field.name][i],pb[field.name][i],field.message_type.fields[j])
					end
				end
				
			end
		else
			for i=1,#field.message_type.fields do
				-- local _field = field.message_type.fields[i]
				recursion(tab[field.name],pb[field.name],field.message_type.fields[i])
			end
		end
	else
		-- local is_int64 = (field.type == FieldDescriptor.TYPE_INT64 and field.cpp_type == FieldDescriptor.CPPTYPE_INT64)
		-- or (field.type == FieldDescriptor.TYPE_FIXED64 and field.cpp_type == FieldDescriptor.CPPTYPE_UINT64)
		local is_int64 = false
		if field.label == FieldDescriptor.LABEL_REPEATED then
			tab[field.name] = {}
			for i=1,#pb[field.name] do
				tab[field.name][i] =  is_int64 and tonumber(pb[field.name][i]) or pb[field.name][i]
			end
		else
			tab[field.name] = is_int64 and tonumber(pb[field.name]) or pb[field.name]
		end
	end
end

function ProtoStruct2Lua(pb)
	local new_pb = getmetatable(pb)
	local tab = {}
	for i=1,#new_pb._descriptor.fields do
		recursion(tab,pb,new_pb._descriptor.fields[i])
		-- tab[new_pb._descriptor.fields[i].name] = pb[new_pb._descriptor.fields[i].name]
	end
	-- pb = nil
	-- new_pb = nil
	return tab
end