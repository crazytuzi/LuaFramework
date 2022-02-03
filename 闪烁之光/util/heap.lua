----------------------------------------------------
---- 二叉堆实现
---- @author whjing2011@gmail.com
------------------------------------------------------
Heap = Heap or BaseClass()

function Heap:__init(key)
    self.key = key
    self.size = 0
    self.items = {}
end

function Heap:clear()
    self.size = 0
    self.items = {}
end

function Heap:IsEmpty()
    return self.size == 0
end

function Heap:GetSize()
    return self.size
end

function Heap:take_smallest()
    local node = self.items[1]
    self.items[1] = self.items[self.size]
    self.items[self.size] = nil
    self.size = self.size - 1
    self:balance()
    return node
end

function Heap:insert(node)
    self.size = self.size + 1
    self.items[self.size] = node
    local temp, father
    local items = self.items
    local ceil = math.ceil
    local len = self.size
    local key = self.key
    while len > 1 do
        father = ceil(len * 0.5)
        if items[father][key] > items[len][key] then
            temp = items[len]
            items[len] = items[father]
            items[father] = temp
            len = father
        else
            return
        end
    end
end

function Heap:balance()
    local checkIdx, tempIdx, temp, idx = 1
    local size = self.size
    local items = self.items
    local key = self.key
    while(true) do
        tempIdx = checkIdx
        idx = tempIdx * 2
        if idx <= size then -- 如果有一个子节点
            if items[idx][key] < items[checkIdx][key] then
                checkIdx = idx
            end
            idx = idx + 1
            if idx <= size then
                if items[idx][key] < items[checkIdx][key] then
                    checkIdx = idx
                end
            end
        end
        if tempIdx == checkIdx then return end
        temp = items[tempIdx]
        items[tempIdx] = items[checkIdx]
        items[checkIdx] = temp
    end
end
