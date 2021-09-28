local NumLabelExt = {}
NumLabelExt.__index = NumLabelExt

function NumLabelExt.New(labels, value)
    local o = {}
    setmetatable(o, NumLabelExt)
    o:_init(labels, value)
    return o
end

function NumLabelExt:setValue(value)
    self._value = value
    
    local str = string.format(self._format, value)
    local offset = #str - #self._labels
    for i,v in ipairs(self._labels) do
        v.Text = string.sub(str, i + offset, i + offset)
    end
end

function NumLabelExt:getValue()
    return self._value
end

function NumLabelExt:_init(labels, value)
    self._labels = labels
    self._format = string.format("%%0%dd", #labels)
    self:setValue(value or 0)
end

return NumLabelExt
