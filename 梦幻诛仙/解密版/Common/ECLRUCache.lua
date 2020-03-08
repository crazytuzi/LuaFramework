local Lplus = require("Lplus")
local ECLRUCache = Lplus.Class("ECLRUCache")
local def = ECLRUCache.define
def.field("string").m_Name = "UnDefined"
def.field("number").m_capacity = 10
def.field("number").m_curSize = 0
def.field("number").m_nTotalGetCount = 0
def.field("number").m_nHitCount = 0
def.field("table").m_mapNodes = nil
def.field("table").m_HeadNode = nil
def.field("table").m_TailNode = nil
def.static("dynamic", "dynamic", "=>", "table").LinkedNode = function(_key, _value)
  local node = {
    key = _key,
    value = _value,
    prev = nil,
    next = nil
  }
  return node
end
def.static("table", "dynamic", "dynamic").ResetLinkedNode = function(_node, _key, _value)
  _node.key = _key
  _node.value = _value
  _node.prev = nil
  _node.next = nil
end
def.static("string", "number", "=>", ECLRUCache).new = function(name, capacity)
  local obj = ECLRUCache()
  obj.m_Name = name
  obj.m_mapNodes = {}
  obj.m_HeadNode = ECLRUCache.LinkedNode(nil, nil)
  obj.m_TailNode = ECLRUCache.LinkedNode(nil, nil)
  obj.m_TailNode.prev = obj.m_HeadNode
  obj.m_HeadNode.next = obj.m_TailNode
  obj.m_capacity = capacity
  return obj
end
def.method().Release = function(self)
  if not self.m_HeadNode then
    return
  end
  local cur = self.m_HeadNode.next
  while cur ~= nil and cur ~= self.m_TailNode do
    self.m_mapNodes[cur.key] = nil
    cur.value = nil
    cur.prev = nil
    cur = cur.next
  end
  self.m_mapNodes = {}
  self.m_TailNode.prev = self.m_HeadNode
  self.m_HeadNode.next = self.m_TailNode
  self.m_curSize = 0
end
def.method("=>", "table").GetAllNodes = function(self)
  if not self.m_HeadNode then
    return nil
  end
  local ret = {}
  local cur = self.m_HeadNode.next
  while cur ~= nil and cur ~= self.m_TailNode do
    table.insert(ret, cur.value)
    cur = cur.next
  end
  return ret
end
def.method().PrintAll = function(self)
  local str = string.format("----Name %s, Count: %d/%d, Node: ", self.m_Name, self.m_curSize, self.m_capacity)
  local cur = self.m_HeadNode.next
  while cur ~= nil and cur ~= self.m_TailNode do
    str = str .. " -> " .. cur.key
    cur = cur.next
  end
  print(str)
end
def.method().PrintStatistic = function(self)
  local info = string.format("---------- %s: size %d / %d, TotalGetCount %d, HitRatio %f", self.m_Name, self.m_curSize, self.m_capacity, self.m_nTotalGetCount, self:GetHitRatio())
  print(info)
end
def.method("=>", "number").GetHitRatio = function(self)
  return self.m_nTotalGetCount > 0 and self.m_nHitCount / self.m_nTotalGetCount or 0
end
def.method("table").move_to_tail = function(self, current)
  current.prev = self.m_TailNode.prev
  self.m_TailNode.prev = current
  current.prev.next = current
  current.next = self.m_TailNode
end
def.method("dynamic", "=>", "dynamic").Peek = function(self, key)
  self.m_nTotalGetCount = self.m_nTotalGetCount + 1
  local current = self.m_mapNodes[key]
  if not current then
    return nil
  end
  self.m_nHitCount = self.m_nHitCount + 1
  current.prev.next = current.next
  current.next.prev = current.prev
  self.m_mapNodes[key] = nil
  self.m_curSize = self.m_curSize - 1
  current.prev = nil
  current.next = nil
  return current.value
end
def.method("dynamic", "=>", "dynamic").Get_Node = function(self, key)
  local current = self.m_mapNodes[key]
  if not current then
    return nil
  end
  current.prev.next = current.next
  current.next.prev = current.prev
  self:move_to_tail(current)
  return current
end
def.method("dynamic", "=>", "dynamic").Get = function(self, key)
  self.m_nTotalGetCount = self.m_nTotalGetCount + 1
  local current = self:Get_Node(key)
  if not current then
    return nil
  end
  self.m_nHitCount = self.m_nHitCount + 1
  return current.value
end
def.method("dynamic", "dynamic", "=>", "dynamic", "dynamic").Set = function(self, key, value)
  local removedKey, removedVal
  local current = self:Get_Node(key)
  if current ~= nil then
    current.value = value
    return removedVal, removedKey
  end
  local bNeedRemove = false
  if self.m_curSize > self.m_capacity then
    bNeedRemove = true
    print("LRUCache: m_curSize > m_capacity!", self.m_Name, self.m_curSize, self.m_capacity)
  elseif self.m_curSize == self.m_capacity then
    bNeedRemove = true
  end
  local tabReuse
  if bNeedRemove then
    tabReuse = self.m_HeadNode.next
    removedKey = self.m_HeadNode.next.key
    removedVal = self.m_HeadNode.next.value
    self.m_mapNodes[self.m_HeadNode.next.key] = nil
    self.m_HeadNode.next = self.m_HeadNode.next.next
    self.m_HeadNode.next.prev = self.m_HeadNode
  else
    self.m_curSize = self.m_curSize + 1
  end
  local insert
  if tabReuse then
    insert = tabReuse
    ECLRUCache.ResetLinkedNode(insert, key, value)
  else
    insert = ECLRUCache.LinkedNode(key, value)
  end
  self.m_mapNodes[key] = insert
  self:move_to_tail(insert)
  return removedVal, removedKey
end
ECLRUCache.Commit()
return ECLRUCache
