-- 按单元中照某个位置的值找数据
-- 返回 false | data()
function keyfind(key, val, list)
	for _, v in pairs(list) do 
		if v[key] == val then 
			return v 
		end
	end
	return false
end

-- 按单元中键位删除
function keydelete(key, val, list)
	for k, v in pairs(list) do 
		if v[key] == val then
			list[k] = nil
			return true
		end
	end
	return false
end

-- 按单元中键值替换
function keyreplace(key, val, list, new)
	for k, v in pairs(list) do 
		if v[key] == val then 
			list[k] = new
			return true
		end
	end
	return false
end

-- 从远程对象赋值给本地vo
function setVoFromRemote(list,remoteList)
	for k, _ in pairs(remoteList) do
		if remoteList[k] ~= nil then
			list[k] = remoteList[k]
		end
	end
end

