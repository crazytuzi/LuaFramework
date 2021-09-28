local BagTable = class("BagTable")


function BagTable:ctor(keyName)
    self._list = {}
    self._keyName = keyName
    self._listIndex = {}
end

function BagTable:getItemByKey(key)
   return self._listIndex[key]
end


function BagTable:addItem(item)
    local oldItem = self:getItemByKey(item[self._keyName])
    if oldItem then
        -- error, maybe should update the item?
        self:updateItemByKey(item[self._keyName], item)
    else
        table.insert(self._list, item) 
        self._listIndex[item[self._keyName]] = item
    end
    
end


function BagTable:removeItem(item)
    local itemId = item[self._keyName]
    self:removeItemById(itemId)
end

function BagTable:removeItemByKey(key)
    for i, v in ipairs(self._list) do
        if key == v[self._keyName] then
            table.remove(self._list, i)
            break
        end
    end
    
    self._listIndex[key] = nil
end


function BagTable:updateItem(item)
    local key = item[self._keyName]
    self:updateItemByKey(key,item)
end


local function _cloneTable( dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function BagTable:updateItemByKey(key, item)
    for i, v in ipairs(self._list) do
        if key == v[self._keyName] then
            --self._list[i] = item

            --table copy , 1 level
            _cloneTable(self._list[i], item)

            break
        end
    end
    --self._listIndex[key] = item
end

function BagTable:getList()
    return self._list
end 

function BagTable:sortList(func)
    table.sort(self._list,func)
end 

function BagTable:getCount()
    return #self._list
end 

return BagTable
