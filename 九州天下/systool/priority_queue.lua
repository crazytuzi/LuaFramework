PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

local Floor = math.floor
local function DefaultCompare(a, b)
	if a < b then
		return true
	else
		return false
	end
end

local function SiftUp(queue, index)
	local parentIndex
	if index ~= 1 then
		parentIndex = Floor(index/2)
		if queue.Compare(queue.Priorities[parentIndex], queue.Priorities[index]) then
			queue.Values[parentIndex], queue.Priorities[parentIndex], queue.Values[index], queue.Priorities[index] =
				queue.Values[index], queue.Priorities[index], queue.Values[parentIndex], queue.Priorities[parentIndex]
			SiftUp(queue, parentIndex)
		end
	end
end

local function SiftDown(queue, index)
	local lcIndex, rcIndex, minIndex
	lcIndex = index * 2
	rcIndex = index * 2 + 1
	if rcIndex > #queue.Values then
		if lcIndex > #queue.Values then
			return
		else
			minIndex = lcIndex
		end
	else
		if not queue.Compare(queue.Priorities[lcIndex], queue.Priorities[rcIndex]) then
			minIndex = lcIndex
		else
			minIndex = rcIndex
		end
	end

	if queue.Compare(queue.Priorities[index], queue.Priorities[minIndex]) then
		queue.Values[minIndex], queue.Priorities[minIndex], queue.Values[index], queue.Priorities[index] =
			queue.Values[index], queue.Priorities[index], queue.Values[minIndex], queue.Priorities[minIndex]
		SiftDown(queue, minIndex)
	end
end

function PriorityQueue.new(comparator)
	local newQueue = { }
	setmetatable(newQueue, PriorityQueue)
	if comparator then
		newQueue.Compare = comparator
	else
		newQueue.Compare = DefaultCompare
	end

	newQueue.Values = { }
	newQueue.Priorities = { }

	return newQueue
end

function PriorityQueue:Add(newValue, priority)
	table.insert(self.Values, newValue)
	table.insert(self.Priorities, priority)

	if #self.Values <= 1 then
		return
	end

	SiftUp(self, #self.Values)
end

function PriorityQueue:Pop()
	if #self.Values <= 0 then
		return nil, nil
	end

	local returnVal, returnPriority = self.Values[1], self.Priorities[1]
	self.Values[1], self.Priorities[1] = self.Values[#self.Values], self.Priorities[#self.Priorities]
	table.remove(self.Values, #self.Values)
	table.remove(self.Priorities, #self.Priorities)
	if #self.Values > 0 then
		SiftDown(self, 1)
	end

	return returnVal, returnPriority
end

function PriorityQueue:Peek()
	if #self.Values > 0 then
		return self.Values[1], self.Priorities[1]
	else
		return nil, nil
	end
end

function PriorityQueue:GetAsTable()
	if not self.Values or #self.Values < 1 then
		return nil, nil
	end

	local vals = { }
	local pris = { }

	for i = 1, #self.Values do
		table.insert(vals, self.Values[i])
		table.insert(pris, self.Priorities[i])
	end

	return vals, pris
end

function PriorityQueue:Clear()
	for k in pairs(self.Values) do
		self.Values[k] = nil
	end
	for k in pairs(self.Priorities) do
		self.Priorities[k] = nil
	end
	for k in pairs(self) do
		self[k] = nil
	end
end

function PriorityQueue:Print(withPriorities)
	if not withPriorities then
		local out = ""
		for i = 1, #self.Values do
			out = out .. tostring(self.Values[i]) .. " "
		end
		print(out)
	else
		local out = ""
		for i = 1, #self.Values do
			out = out .. tostring(self.Values[i]) .. "(" .. tostring(self.Priorities[i]) .. ") "
		end
		print(out)
	end
end

function PriorityQueue:Size()
	return #self.Values
end

function PriorityQueue:Clone()
	local newQueue = PriorityQueue.new(self.Compare)
	for i = 1, #self.Values do
		table.insert(newQueue.Values, self.Values[i])
		table.insert(newQueue.Priorities, self.Priorities[i])
	end
	return newQueue
end

-- Functions that are not self-referential
function PriorityQueue:CreateFromTables(table1, table2, comparator)
	local newQueue = PriorityQueue.new(comparator)
	for i = #table1, 1, -1 do
		if table2[i] then
			newQueue:Add(table1[i], table2[i])
		else
			return
		end
	end
end

function PriorityQueue:Merge(queue1, queue2, comparator)
	if not comparator then
		comparator = queue1.Compare or queue2.Compare
	end
	local newQueue = PriorityQueue.new(comparator)
	for i = #queue1.Values, 1, -1 do
		newQueue:Add(queue1.Values[i], queue1.Priorities[i])
	end
	for i = #queue2.Values, 1, -1 do
		newQueue:Add(queue2.Values[i], queue2.Priorities[i])
	end
	return newQueue
end
