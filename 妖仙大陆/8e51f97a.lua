local ScrollCellUpdateExt = {}
ScrollCellUpdateExt.__index = ScrollCellUpdateExt

function ScrollCellUpdateExt.New(scrollPan, updateCellHandler, updateTime)
    local o = {}
    setmetatable(o, ScrollCellUpdateExt)
    o:_init(scrollPan, updateCellHandler, updateTime)
    return o
end

function ScrollCellUpdateExt:start()
    if not self._runing then
        self._runing = true
        self._timer:Start()
    end
end

function ScrollCellUpdateExt:stop()
    if self._runing then
        self._runing = false
        self._timer:Stop()
    end
end

function ScrollCellUpdateExt:clean()
    self._addList = {}
    self._removeList = {}
    self._indexMap = {}
end

function ScrollCellUpdateExt:setIndexs(indexs)
    self:clean()
    for _,v in ipairs(indexs or {}) do
        self._indexMap[v] = true
    end
end

function ScrollCellUpdateExt:removeIndex(idx)
    if self._progressing then
        table.insert(self._removeList, idx)
    else
        self._indexMap[idx] = nil
    end
end

function ScrollCellUpdateExt:addIndex(idx)
    if self._progressing then
        table.insert(self._addList, idx)
    else
        self._indexMap[idx] = true
    end
end

function ScrollCellUpdateExt:_init(scrollPan, updateCellHandler, updateTime)
    self._scrollPan = scrollPan
    self._scrollable = scrollPan.Scrollable
    self._updateCellHandler = updateCellHandler
    self._progressing = false
    self._addList = {}
    self._removeList = {}
    self._indexMap = {}
    self._runing = false
    self._timer = Timer.New(function() self:_onTimer() end, updateTime or 1, -1)
end

function ScrollCellUpdateExt:_getCell(luaIdx)
    local cols = self._scrollPan.Columns
    local gx = (luaIdx - 1) % cols
    local gy = math.floor((luaIdx - 1) / cols)
    return 
end

function ScrollCellUpdateExt:_onTimer()
    self._progressing = true
    for luaIdx in pairs(self._indexMap) do
        local cols = self._scrollPan.Columns
        local gx = (luaIdx - 1) % cols
        local gy = math.floor((luaIdx - 1) / cols)
        local cell = self._scrollable:GetCell(gx, gy)
        if cell then
            self._updateCellHandler(gx, gy, cell, luaIdx)
        end
    end
    self._progressing = false
    if #self._addList > 0 then
        for _,v in ipairs(self._addList) do
            self._indexMap[v] = true
        end
        self._addList = {}
    end
    if #self._removeList > 0 then
        for _,v in ipairs(self._removeList) do
            self._indexMap[v] = nil
        end
        self._removeList = {}
    end
end


return ScrollCellUpdateExt
