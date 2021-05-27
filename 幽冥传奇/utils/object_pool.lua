------------------------------------------------------
--对象池。池中的对象必须含有GetView方法。否则不入池
--入池时。会尝试调用Dispose方法,出池时。会尝试调用Resume方法.因此如有数据清理及恢复的需要可实现这两个方法
--@author bzw
------------------------------------------------------
ObjectPool = ObjectPool or BaseClass()

--池的大小
ObjectPool.MAX_POOLING_SIZE = 50

ObjectPool.pools = {}

function ObjectPool.GetPool(class_name)
	if class_name == nil then return nil end

	return ObjectPool.pools[class_name]
end

--在返回true时，记得在addChild后release
function ObjectPool.GetObject(class_name, param1, param2, param3)
	if class_name == nil then return end

	local pool = ObjectPool.GetPool(class_name)
	if pool == nil or #pool == 0 then
		if class_name.New then
			return class_name.New(param1, param2, param3), false
		end
	else
		local obj = pool[#pool]
		if obj.Resume then
			obj:Resume()
		end
	
		pool[#pool] = nil
		return obj, true
	end
end

function ObjectPool.DisposeObject(obj, class_name)
	if obj == nil then return end
		
	if not ObjectPool.IsCanIntoPool(obj) then
		return
	end

	if obj.Dispose then
		obj:Dispose()
	end

	obj:GetView():retain() --添加引用，不被释放

	local pool = ObjectPool.GetPool(class_name)
	if pool == nil then
		pool = {}
		ObjectPool.pools[class_name] = pool
	end

	if #pool < ObjectPool.MAX_POOLING_SIZE then
		table.insert(pool, obj)
	end
end

--是否可入池
--必须有名叫GetView的根节点，否则不入池
--池满不入池
function ObjectPool.IsCanIntoPool(obj, class_name)
	if obj == nil then return false end
	
	local pool = ObjectPool.GetPool(class_name)
	if obj.GetView == nil or obj:GetView() == nil or (pool ~= nil and #pool >= ObjectPool.MAX_POOLING_SIZE) then 
		return false
	end
	return true
end

--清空一个池
function ObjectPool.ClearOnePool(class_name)
	if class_name == nil then return end

	local pool = ObjectPool.GetPool(class_name)
	if pool == nil then return end

	for k,v in pairs(pool) do
		if v.GetView ~= nil or v:GetView() ~= nil then --从池中取出时取消进池时的引用
			v:GetView():release() 	
		else
			Log("注意：对象池引起内存泄露")
		end

		if v.DeleteMe then
			v:DeleteMe()
		end
	end

	ObjectPool.pools[class_name] = nil
end

--清空所有池
function ObjectPool.ClearAllPool()
	for k,v in pairs(ObjectPool.pools) do
		ObjectPool.ClearOnePool(k)
	end
end