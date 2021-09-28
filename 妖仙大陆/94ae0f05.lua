local Util = require "Zeus.Logic.Util"

local DropDownExt = {}
Util.WrapOOPSelf(DropDownExt)

function DropDownExt.New(tbBtn, canvas, nameValueMap, cb)
    local obj = {}
    setmetatable(obj, DropDownExt)
    obj:_init(tbBtn, canvas, nameValueMap, cb)
    return obj
end

function DropDownExt:close()
    self._tbBtn.IsChecked = false
    self._canvas.Visible = false
end

function DropDownExt:getValue()
    return self._value
end

function DropDownExt:setValue(value)
    for k,v in pairs(self._nameValueMap) do
        if v == value then
            self._value = v
            local btn = self._canvas:FindChildByEditName(k, true)
            self._tbBtn.Text = btn.Text
            self:close()
            break
        end
    end
end

function DropDownExt:_init(tbBtn, canvas, nameValueMap, cb)
    self._value = 0
    self._tbBtn = tbBtn
    self._canvas = canvas
    self._cb = cb
    self._nameValueMap = nameValueMap
    tbBtn.TouchClick = self._self__onTbBtnClick
    self:close()
    for k,v in pairs(nameValueMap) do
        local btn = canvas:FindChildByEditName(k, true)
        btn.UserTag = v
        btn.TouchClick = self._self__onItemBtnClick
    end
end

function DropDownExt:_onItemBtnClick(sender)
    self._value = sender.UserTag
    self._tbBtn.Text = sender.Text
    self:close()
    if self._cb then
        self._cb(self._value)
    end
end

function DropDownExt:_onTbBtnClick(sender)
    self._canvas.Visible = self._tbBtn.IsChecked
end

return DropDownExt
