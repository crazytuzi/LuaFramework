local ChainTable = {}
function ChainTable.new()
  local chain = {}
  chain.head = nil
  chain.tail = nil
  return chain
end
function ChainTable.insertHead(chain, value)
  local tbl = {
    prev = nil,
    value = value,
    next = chain.head
  }
  if chain.head then
    chain.head.prev = tbl
  end
  if chain.tail == nil then
    chain.tail = tbl
  end
  chain.head = tbl
end
function ChainTable.insertTail(chain, value)
  local tbl = {
    prev = chain.tail,
    value = value,
    next = nil
  }
  if chain.tail then
    chain.tail.next = tbl
  end
  if chain.head == nil then
    chain.head = tbl
  end
  chain.tail = tbl
end
function ChainTable.removeHead(chain)
  local head = chain.head
  if head ~= nil then
    chain.head = head.next
    if chain.head == nil then
      chain.tail = nil
    else
      chain.head.prev = nil
    end
    return head.value
  else
    return nil
  end
end
function ChainTable.removeTail(chain)
  local tail = chain.tail
  if tail ~= nil then
    chain.tail = tail.prev
    if chain.tail == nil then
      chain.head = nil
    else
      chain.tail.next = nil
    end
    return tail.value
  else
    return nil
  end
end
function ChainTable.remove(chain, node)
  if node then
    if node.next == nil then
      ChainTable.removeTail(chain)
    elseif node.prev == nil then
      ChainTable.removeHead(chain)
    else
      node.next.prev = node.prev
      node.prev.next = node.next
    end
  end
end
function ChainTable.insertBefore(chain, node, value)
  local tbl = {
    prev = node.prev,
    value = value,
    next = node
  }
  if node.prev then
    node.prev.next = tbl
  else
    chain.head = tbl
  end
  node.prev = tbl
end
function ChainTable.headIter(chain)
  local node = chain.head
  return function()
    if node then
      local v = node.value
      node = node.next
      return v
    else
      return nil
    end
  end
end
function ChainTable.tostring(chain)
  local strTbl = {}
  local iter = chain.head
  local count = 0
  while iter do
    count = count + 1
    table.insert(strTbl, string.format("<=%s + %s + %s=>", tostring(iter.prev), tostring(iter.value), tostring(iter.next)))
    iter = iter.next
  end
  return tostring(count) .. "::" .. table.concat(strTbl)
end
return ChainTable
