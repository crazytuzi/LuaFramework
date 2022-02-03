----------------------------------------------------
---- 固定长度数组
---- @author cloud
---- @date 2017.1.5
------------------------------------------------------
FixArray = FixArray or BaseClass()

function FixArray:__init(max, del_call)
    self.max = max
    self.del_call = del_call
    self.idx = 0
    self.size = 0
    self.first = 0
    self.last = -1
    self.items = {}
end

function FixArray:IsEmpty()
    return self.size <= 0
end

function FixArray:GetSize()
    return self.size
end

function FixArray:Clear()
    self.size = 0
    self.first = 0
    self.last = -1
    self.items = {}
end

function FixArray:PushFront__(value)
	self.first = self.first - 1
    self.size = self.size + 1
	self.items[self.first] = value
end

function FixArray:PushBack__(value)
	self.last = self.last + 1
    self.size = self.size + 1
	self.items[self.last] = value
end

function FixArray:GetBack()
	return self.items[self.last]	
end

function FixArray:GetFront()
	return self.items[self.first]
end

function FixArray:Get(i)
    if i < self.size then
        return nil
    end
    local idx = self.first + i
    return self.items[idx]
end

function FixArray:PopFront()
    if(self.size <= 0) then return nil end
    local val = self.items[self.first]
    self.items[self.first] = nil
    self.size = self.size - 1
    self.first = self.first + 1
    return val
end

function FixArray:PopBack()
    if(self.size <= 0) then return nil end
    local val = self.items[self.last]
    self.items[last] = nil
    self.last = self.last - 1
    self.size = self.size -1
    return val
end

function FixArray:ForFront(fun, ...)
    for i = self.first, self.last do
        if not fun(self.items[i], ...) then
            return 
        end
    end
end

function FixArray:ForBack(fun, ...)
    for i = self.last, self.first, -1 do
        if not fun(self.items[i], ...) then
            return 
        end
    end
end

function FixArray:IsMax()
    return self.max <= self.size
end

function FixArray:PushBack(v)
    local delV = nil
    if self.size >= self.max then
        local delV = self:PopFront()
        if self.del_call and delV then
            self.del_call(delV)
        end
    end
    self:PushBack__(v)
    return delV
end

function FixArray:PushFront(v)
    local delV = nil
    if self.size >= self.max then
        delV = self:PopBack()
        if self.del_call and delV then
            self:del_call(delV)
        end
    end
    self:PushFront__(v)
    return delV
end

function FixArray:SetFirst()
    self.idx = self.first
end

function FixArray:SetLast()
    self.idx = self.last
end

function FixArray:GoNext()
    if self.idx >= self.last then
        self.idx = self.first
    else
        self.idx = self.idx + 1
    end
end

function FixArray:GoBack()
    if self.idx <= self.first then
        self.idx = self.last
    else
        self.idx = self.idx - 1
    end
end

-- 获取当前游标值
function FixArray:getNow()
    return self.items[self.idx]
end

-- 循环游标取值
function FixArray:GetRoll()
    local v = self.items[self.idx]
    self:GoNext()
    return v
end

-- 游标反向取值
function FixArray:GetRollReverse()
    local v = self.items[self.idx]
    self:GoBack()
    return v
end
