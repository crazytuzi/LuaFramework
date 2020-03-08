local Lplus = require("Lplus")
local CircleQueue = Lplus.Class("CircleQueue")
local def = CircleQueue.define
def.field("number").size = 0
def.field("table").data = nil
def.field("number").head = 2
def.field("number").tail = 1
def.static("number", "=>", CircleQueue).new = function(size)
  if size <= 1 then
    return nil
  end
  local queue = CircleQueue()
  queue.size = size
  queue.data = {}
  for i = 1, size do
    table.insert(queue.data, nil)
  end
  return queue
end
def.method("table").In = function(self, item)
  if self:IsFull() then
    self.data[self.head] = item
    self.head = self.head < self.size and self.head + 1 or 1
    self.tail = self.head
  else
    self.data[self.head] = item
    self.head = self.head < self.size and self.head + 1 or 1
  end
end
def.method().Out = function(self)
  if self:IsEmpty() then
    return
  end
  self.tail = self.tail < self.size and self.tail + 1 or 1
end
def.method("number").Length = function(self)
  local len = self.head - self.tail - 1
  if len > 0 then
    return len
  else
    return len + self.size - 1
  end
end
def.method("=>", "boolean").IsEmpty = function(self)
  return self.head > self.tail and self.head - self.tail == 1 or self.head == 1 and self.tail == self.size
end
def.method("=>", "boolean").IsFull = function(self)
  return self.head == self.tail
end
def.method("=>", "table").GetNewOne = function(self)
  if self:IsEmpty() then
    return nil
  end
  local pointer = self.head - 1
  if not (pointer > 0) or not pointer then
    pointer = pointer + self.size
  end
  return self.data[pointer]
end
def.method("number").DeleteOne = function(self, index)
  if self:IsValid(index) then
    local current = index
    while true do
      local next = current > 1 and current - 1 or self.size
      self.data[current] = self.data[next]
      if next == self.tail then
        self.tail = current
        break
      else
        current = next
      end
    end
  end
end
def.method("number", "=>", "table").GetList = function(self, count)
  local list = {}
  local pointer = self.head - 1
  if not (pointer > 0) or not pointer then
    pointer = pointer + self.size
  end
  if count < 0 then
    count = self.size
  end
  local num = 1
  while count >= num and pointer ~= self.tail do
    table.insert(list, self.data[pointer])
    num = num + 1
    pointer = pointer - 1
    if not (pointer > 0) or not pointer then
      pointer = pointer + self.size
    end
  end
  return list
end
def.method("number", "=>", "table").GetListReverse = function(self, count)
  local list = {}
  local pointer = self.tail + 1
  if not (pointer <= self.size) or not pointer then
    pointer = pointer - self.size
  end
  if count < 0 then
    count = self.size
  end
  local num = 1
  while count >= num and pointer ~= self.head do
    table.insert(list, self.data[pointer])
    num = num + 1
    pointer = pointer + 1
    if not (pointer <= self.size) or not pointer then
      pointer = pointer - self.size
    end
  end
  return list
end
def.method("function", "=>", "table", "number").SearchOne = function(self, isThis)
  local pointer = self.head - 1
  if not (pointer > 0) or not pointer then
    pointer = pointer + self.size
  end
  while pointer ~= self.tail do
    if isThis(self.data[pointer]) then
      return self.data[pointer], pointer
    end
    pointer = pointer - 1
    if not (pointer > 0) or not pointer then
      pointer = pointer + self.size
    end
  end
  return nil, 0
end
def.method("number", "=>", "boolean").IsValid = function(self, index)
  if self.head > self.tail then
    if index < self.head and index > self.tail then
      return true
    else
      return false
    end
  elseif index < self.head or index > self.tail then
    return true
  else
    return false
  end
end
def.method("number", "=>", "table").GetOne = function(self, index)
  if self:IsValid(index) then
    return self.data[index]
  else
    return nil
  end
end
def.method("number", "number", "=>", "table").GetBackward = function(self, index, count)
  local list = {}
  if not self:IsValid(index) then
    return list
  end
  local pointer = index - 1
  if not (pointer > 0) or not pointer then
    pointer = pointer + self.size
  end
  if count < 0 then
    count = self.size
  end
  local num = 1
  while count >= num and pointer ~= self.tail do
    table.insert(list, self.data[pointer])
    num = num + 1
    pointer = pointer - 1
    if not (pointer > 0) or not pointer then
      pointer = pointer + self.size
    end
  end
  return list
end
def.method("number", "number", "=>", "table").GetForward = function(self, index, count)
  local list = {}
  if not self:IsValid(index) then
    return list
  end
  local pointer = index + 1
  if not (pointer <= self.size) or not pointer then
    pointer = pointer - self.size
  end
  if count < 0 then
    count = self.size
  end
  local num = 1
  while count >= num and pointer ~= self.head do
    table.insert(list, self.data[pointer])
    num = num + 1
    pointer = pointer + 1
    if not (pointer <= self.size) or not pointer then
      pointer = pointer - self.size
    end
  end
  return list
end
local iter = function(circleQueue, i)
  local value = circleQueue:GetOne(i)
  if value then
    i = i + 1
    if not (i <= circleQueue.size) or not i then
      i = i - circleQueue.size
    end
    return i, value
  else
    return nil, nil
  end
end
def.method("=>", "function", "table", "number").Traverse = function(self)
  local i = self.tail + 1
  if not (i <= self.size) or not i then
    i = i - self.size
  end
  return iter, self, i
end
local reiter = function(circleQueue, i)
  local value = circleQueue:GetOne(i)
  if value then
    i = i - 1
    if not (i > 0) or not i then
      i = i + circleQueue.size
    end
    return i, value
  else
    return nil, nil
  end
end
def.method("=>", "function", "table", "number").ReTraverse = function(self)
  local i = self.head - 1
  if not (i > 0) or not i then
    i = i + self.size
  end
  return reiter, self, i
end
def.method().Test = function(self)
  warn("Traverse:")
  for k, v in self:Traverse() do
    warn(v.content)
  end
  warn("ReTraverse:")
  for k, v in self:ReTraverse() do
    warn(v.content)
  end
end
CircleQueue.Commit()
return CircleQueue
