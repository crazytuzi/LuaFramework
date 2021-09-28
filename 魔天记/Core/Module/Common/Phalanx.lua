Phalanx =
{
    _phalanxBehaviour = nil,
    maxRows = 0,
    maxColumns = 0,
    isRowFirst = true,
    template = nil,
    spacing = { x = 0, y = 0 },
    firstCount = 0,
    _items = { },

}
Phalanx = class("Phalanx")
local insert = table.insert

function Phalanx:New()
    local o = { };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function Phalanx:Init(phalanxBehaviour, itemClass, dontNeedData)
    self._pool = { }
    self._phalanxBehaviour = phalanxBehaviour
    self.maxRows = self._phalanxBehaviour.maxRows
    self.maxColumns = self._phalanxBehaviour.maxColumns
    self.isRowFirst = self._phalanxBehaviour.isRowFirst
    self.template = self._phalanxBehaviour.template
    self.spacing = { x = self._phalanxBehaviour.spacing.x, y = self._phalanxBehaviour.spacing.y }
    self.firstCount = self._phalanxBehaviour.firstCount
    self._items = { }
    self.itemClass = itemClass
    self._dontNeedData = dontNeedData or false
end

-- 设置间距
function Phalanx:SetSpacing(w, h)
    self.spacing = { x = w, y = h }
end

function Phalanx:Build(maxRows, maxColumns, datas)
    self.maxRows = maxRows;
    self.maxColumns = maxColumns;
    self:_Refresh(datas);
end

function Phalanx:BuildSpe(maxColumns, datas)
    self.maxColumns = maxColumns;
    self:_RefreshBySpeSort(datas)
end

function Phalanx:BuildSphere(maxCount, r, datas)
    self.maxCount = maxCount
    self.r = r
    self._degree =(2 * math.pi) / maxCount
    self:_RefreshSphere(datas)
end 

function Phalanx:_RefreshSphere(datas)
    local max = math.min(self.maxCount, table.getCount(datas))
    local i = 0
    if (self._items ~= nil and table.getCount(self._items) >= max) then
        local count = 0;
        for i = table.getCount(self._items), max + 1, -1 do
            insert(self._pool, self._items[i].gameObject)
            self._items[i].gameObject:SetActive(false)
            if (self._items[i].itemLogic) then
                self._items[i].itemLogic:Dispose();
            end
            self._items[i] = nil
        end

        if (max > 0) then
            for i = 1, max do
                self._items[i].data = datas[i]
                if (self._items[i].itemLogic) then
                    self._items[i].itemLogic:UpdateItem(self._items[i].data)
                end
            end
        end
    elseif (self._items == nil or(table.getCount(self._items) < max)) then
        self:_CreaterSphereComponent(datas)
    end
end

function Phalanx:_CreaterSphereComponent(datas)
    if (self.template ~= nil) then
        local itemCount =(self._items == nil) and 0 or table.getCount(self._items)
        --        local begin = itemCount
        self:_ResetDataRowFirst(0, itemCount, datas);
        self:_BuildSphereFirst(itemCount, datas);
    end
end

function Phalanx:_BuildSphereFirst(begin, datas)
    local brFlag = false
    local i = 0
    local localPos = self.template.transform.localPosition

    for x = begin, self.maxCount - 1 do
        local item = self:_BuildItem(x, 0, datas[x + 1], x);
        local posX = self.r * math.sin(self._degree * x);
        local posY = self.r * math.cos(self._degree * x);
        Util.SetLocalPos(item.gameObject, localPos.x + posX, localPos.y + posY, 0)
        --        item.gameObject.transform.localPosition = Vector3.New(localPos.x + posX, localPos.y + posY, 0)

        if (x + 1 >= table.getCount(datas)) then
            brFlag = true;
            break;
        end
        if (brFlag == true) then break end;
    end

end

function Phalanx:_RefreshBySpeSort(datas)
    local max = math.min(self.maxColumns, table.getCount(datas))

    if (self._dontNeedData) then
        max = self.maxColumns
    end

    local i = 0
    if (self._items ~= nil and table.getCount(self._items) >= max) then
        local count = 0;
        for i = table.getCount(self._items), max + 1, -1 do
            insert(self._pool, self._items[i].gameObject)
            self._items[i].gameObject:SetActive(false)
            if (self._items[i].itemLogic) then
                self._items[i].itemLogic:Dispose();
            end
            self._items[i] = nil
        end

        if (max > 0) then
            for i = 1, max do
                self._items[i].data = datas[i]
                if (self._items[i].itemLogic) then
                    self._items[i].itemLogic:UpdateItem(self._items[i].data)
                end
            end
        end

        self:_ResetPosition()
    elseif (self._items == nil or(table.getCount(self._items) < max)) then
        self:_CreaterSpeComponent(datas)
    end
end

function Phalanx:_CreaterSpeComponent(datas)
    if (self.template ~= nil) then
        local itemCount =(self._items == nil) and 0 or table.getCount(self._items)
        local beginColumn = itemCount % self.maxColumns;
        self:_ResetDataRowFirst(0, beginColumn, datas);
        self:_BuildSpeRowFirst(0, beginColumn, datas);
        self:_ResetPosition()
    end
end

function Phalanx:_ResetPosition()
    local localPos = self.template.transform.localPosition
    if (self._items) then
        local count = table.getCount(self._items)
        for k, v in ipairs(self._items) do
            Util.SetLocalPos(v.gameObject, localPos.x +(k - 1 -(count - 1) * 0.5) * self.spacing.x, localPos.y, 0)

            --            v.gameObject.transform.localPosition = Vector3.New(localPos.x +(k-1 -(count-1) * 0.5) * self.spacing.x, localPos.y, 0)
        end
    end
end

function Phalanx:_BuildSpeRowFirst(beginRow, beginColumn, datas)
    local brFlag = false
    local localPos = self.template.transform.localPosition
    for x = beginColumn, self.maxColumns - 1 do
        local item = self:_BuildItem(x, 0, datas[x + 1], x);
        --        item.gameObject.transform.localPosition = Vector3.New(localPos.x +(x -((self.maxColumns - 1) * 0.5)) * self.spacing.x, localPos.y, 0)
        if (not self._dontNeedData) then
            if (x + 1 >= table.getCount(datas)) then
                brFlag = true;
                break;
            end
            if (brFlag == true) then break end;
        end

    end

end

function Phalanx:_Refresh(datas)
    local max = math.min((self.maxColumns * self.maxRows), table.getCount(datas))
    if (self._dontNeedData) then
        max = self.maxColumns * self.maxRows
    end

    local i = 0;
    if (self._items ~= nil and table.getCount(self._items) >= max) then
        local count = 0;

        for i = table.getCount(self._items), max + 1, -1 do
            insert(self._pool, self._items[i].gameObject)
            self._items[i].gameObject:SetActive(false)
            if (self._items[i].itemLogic) then
                self._items[i].itemLogic:Dispose();
            end
            self._items[i] = nil
        end

        if (max > 0) then
            for i = 1, max do
                self._items[i].data = datas[i]
                if (self._items[i].itemLogic) then
                    self._items[i].itemLogic:UpdateItem(self._items[i].data)
                end
            end
        end
    elseif (self._items == nil or(table.getCount(self._items) < max)) then
        self:_CreateComponent(datas)
    end
end

function Phalanx:_CreateComponent(datas)
    if (self.template ~= nil) then
        local itemCount =(self._items == nil) and 0 or table.getCount(self._items)
        if self.isRowFirst then
            local beginRow = math.floor(itemCount / self.maxColumns);
            local beginColumn = itemCount % self.maxColumns;
            self:_ResetDataRowFirst(beginRow, beginColumn, datas);
            self:_BuildRowFirst(beginRow, beginColumn, datas);
        else
            local beginColumn = itemCount / self.maxRows;
            local beginRow = itemCount % self.maxRows;
            self:_ResetDataColumnFirst(beginRow, beginColumn, datas);
            self:_BuildColumnFirst(beginRow, beginColumn, datas);
        end
    end
end

function Phalanx:_ResetDataRowFirst(row, column, datas)
    local i = 1
    for i = 1,(row * self.maxColumns) + column do
        if (self._items[i] and self._items[i].itemLogic) then
            self._items[i].itemLogic:UpdateItem(datas[i])
        end
    end
end

function Phalanx:_BuildRowFirst(beginRow, beginColumn, datas)
    local brFlag = false;
    local i = 0
    for y = beginRow, self.maxRows - 1 do
        if (y > beginRow) then
            beginColumn = 0
        end

        for x = beginColumn, self.maxColumns - 1 do
            if (brFlag and not self._dontNeedData) then
                break
            end;
            i = y * self.maxColumns + x;
            self:_BuildItem(x, y, datas[i + 1], i);
            if (not self._dontNeedData) then
                if (i + 1 >= table.getCount(datas)) then
                    brFlag = true;
                    break;
                end

            end
        end
    end
end

function Phalanx:_ResetDataColumnFirst(row, column, datas)
    for i = 1, column * self.maxRows + row do
        --        if (self._items[i] == nil) then
        --            self._items[i] = { }
        --        end
        if (self._items[i] and self._items[i].itemLogic) then
            self._items[i].itemLogic:UpdateItem(datas[i])
        end
    end
end

function Phalanx:_BuildColumnFirst(beginRow, beginColumn, datas)
    local brFlag = false;
    local i = 0
    for x = beginColumn, self.maxColumns - 1 do
        if (x > beginColumn) then
            beginRow = 0
        end

        for y = beginRow, self.maxRows - 1 do
            if (brFlag and not self._dontNeedData) then break end;

            i = x * self.maxRows + y;
            self:_BuildItem(x, y, datas[i + 1], i);
            if (not self._dontNeedData) then
                if (i + 1 >= table.getCount(datas)) then
                    brFlag = true;
                    break;
                end
            end
        end

    end
end

function Phalanx:_BuildItem(x, y, data, index)
    local go = nil
    if (table.getCount(self._pool) > 0) then
        go = self._pool[1]
        table.remove(self._pool, 1)
    else
        go = NGUITools.AddChild(self._phalanxBehaviour.gameObject, self.template);
    end
    go.gameObject.name = self.template.name .. "_" .. y .. "_" .. x;
 
    
    local localPos = self.template.transform.localPosition
    Util.SetLocalPos(go, localPos.x + x * self.spacing.x, localPos.y - y * self.spacing.y, 0)

    --    go.transform.localPosition = Vector3.New(localPos.x + x * self.spacing.x, localPos.y - y * self.spacing.y, 0)
    go:SetActive(true)
    local item = { }
    item.data = data
    item.gameObject = go
    if (self.itemClass ~= nil) then
        item.itemLogic = self.itemClass:New()
        if (index ~= nil) then
            -- 下标从1开始
            item.itemLogic.index = index + 1
        end
        item.itemLogic:Init(go, data)
    end
    insert(self._items, item);
    return item
end

function Phalanx:GetItem(index)
    return self._items[index];
end

function Phalanx:GetItems()
    return self._items
end

function Phalanx:Dispose()
    if (self._items and table.getCount(self._items) > 0) then
        for k, v in pairs(self._items) do
            if (v.itemLogic) then
                v.itemLogic:Dispose()
            end
--            if (v.gameObject) then
            if not IsNil(v.gameObject)then
                GameObject.Destroy(v.gameObject)
                v.gameObject = nil
            end
            self._items[k] = nil
        end
    end

    if (self._pool and table.getCount(self._pool)) then
        for k, v in pairs(self._pool) do
--            if (v) then
--                GameObject.Destroy(v)
--            end
            if not IsNil(v) then GameObject.Destroy(v) end
            self._pool[k] = nil
        end
    end

    self._items = nil
    self.itemClass = nil
    self._phalanxBehaviour = nil

end

function Phalanx:GetItemIndex(go)
    local count = table.getCount(self._items)
    if (self._items and count > 0) then
        for i = 1, count do
            if (self._items[i].gameObject.name == go.name) then
                return i
            end
        end
    else
        return -1
    end
end
