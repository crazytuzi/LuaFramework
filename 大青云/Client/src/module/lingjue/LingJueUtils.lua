--[[
灵诀 utils
haohu
2016年1月22日11:33:33
]]

_G.LingJueUtils = {}

function LingJueUtils:AttrAdd( attrList1, attrList2 )
	local list1, list2, list = {}, {}, {}
	for _, vo1 in pairs(attrList1) do
		list1[vo1.type] = vo1
	end
	for _, vo2 in pairs(attrList2) do
		list2[vo2.type] = vo2
	end
	for t1, v1 in pairs(list1) do
		if list2[t] then
			v1.val = v1.val + list2[t].val
		end
	end
	for t2, v2 in pairs(list2) do
		if not list1[t2] then
			list1[t2] = v2
		end
	end
	for t, v in pairs(list1) do
		table.push(list, v)
	end
	return list
end
