local StarNumExt = {}
StarNumExt.__index = StarNumExt

function StarNumExt.New(items, num)
    local o = {}
    setmetatable(o, StarNumExt)
    o:_init(items, num)
    return o
end


function StarNumExt:_init(items, num, enabledNum)
    self._items = items
    self._num = nil
    self._enabledNum = nil

    local len = #items
    local left = items[1].Position2D
    local right = items[len].Position2D
    self.center = left:Clone():Add(right):Div(2)
    self.gap = Vector2.New(0, 0)
    if len > 1 then
        self.gap:Add(right):Sub(left):Div(len - 1)
    end

    self:setNum(num or len)
    self:setEnableNum(enabledNum or len)
end

function StarNumExt:setNum(num)
    if self._num == num then return end
    self._num = num

    local pos = self.gap:Clone():Mul(-(num-1)/2):Add(self.center)
    for i=1, num do
        self._items[i].Visible = true
        self._items[i].Position2D = pos
        pos:Add(self.gap)
    end
    for i = num + 1, #self._items do
        self._items[i].Visible = false
    end
end

function StarNumExt:setEnableNum(num)
    if self._enabledNum == num then return end
    self._enabledNum = num
    for i,v in ipairs(self._items) do
        v.Enable = i <= num
    end
end

return StarNumExt
