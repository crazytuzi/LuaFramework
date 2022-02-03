--队列执行,按帧处理
--战斗加载场景使用
--author:upbins

QueueManager = QueueManager or BaseClass()

function QueueManager:getInstance( )
	if not self.is_init then
		self.require_list = {} --请求列表
		self.finish_list = {} --加载完成列表
		self.is_in_require = false
		self.is_init = true
	end
	return self
end

-- 增加队列
-- id           是唯一标志，可以多次添加，但是同样id的如果已经处理过不会再次等待（例如图片相关创建加载就只有第一次卡）
-- callfunc     轮到执行实际时回调函数
-- type_name    类型名称，用于清除某一类

function QueueManager:add(id,type_name,call_fun)
	if keyfind("id",id,self.finish_list) then
		if call_fun then
			call_fun()
		end
		return 
	end
	type_name = type_name or ""
	if #self.require_list == 0 then
		GlobalTimeTicket:getInstance():add(function ()
			self:doOne()
		end, 0.1, 0,"queueMgrTimer")
		self.is_in_require = true
	end
	local data = {id = id ,call_back = call_fun,type_name = type_name}
	table.insert(self.require_list,data)
end

--按类清除
function QueueManager:remove(type_name,call_fun)
	local new_finish_list,new_require_list = {},{}
	for _, v in pairs(self.finish_list) do
		if v.type_name == type_name and call_fun then
			call_fun(v)
		else
			table.insert(new_finish_list,v)
		end
	end
	for _,v2 in pairs(self.require_list) do
		if v2.type_name ~= type_name then
			table.insert(new_require_list,v2)
		end
	end
	self.finish_list = new_finish_list
	self.require_list = new_require_list
	self:isAllFinish()
end

--是否全部执行完成
function QueueManager:isAllFinish()
	self.finish_list = {}
	if #self.require_list == 0 and self.is_in_require then
		GlobalTimeTicket:getInstance():remove("queueMgrTimer")
		self.is_in_require = false
	end
end

--检测是否加载完成
function QueueManager:doOne()
	if #self.require_list > 0 then
		local one = self.require_list[1]
		table.remove(self.require_list,1)
		if one.call_back then
			one.call_back()
		end
		table.insert(self.finish_list,one)
		self:isAllFinish()
	else
		self:isAllFinish()
	end
end