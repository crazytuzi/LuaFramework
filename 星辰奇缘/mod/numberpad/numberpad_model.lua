NumberpadModel = NumberpadModel or BaseClass(BaseModel)

function NumberpadModel:__init()
    self.numberPad = nil
    self.result = nil
    self.result_show = nil
end

function NumberpadModel:__delete()
    if self.numberPad then
        self.numberPad = nil
    end
end

--[[
gameObject : 依附的对象
textObject : 如果依附对象不是键盘而是附带有数量文本框、增加减少按钮的面板的话，需要传入数量文本框
max_result : 允许的最大数量
min_result : 允许的最小数量
funcReturn : 小键盘中回车键所调用的函数，传入一个数量参数
max_by_asset: 允许购买的最大数目，由当前拥有资产决定
show_num   : 是否显示数量文本框
callback   : 数字改变时执行的回调
returnKeep : 点击回车不关闭
returnText : 回车按钮文字
]]--
function NumberpadModel:set_data(info)
    self.parentObj = TipsManager.Instance.model.tipsCanvas
    self.max_result = info.max_result
    self.max_by_asset = info.max_by_asset
    self.min_result = info.min_result
    self.result_keep = info.returnKeep or false
    self.return_text = info.returnText
    self.callback = function()
        if info.callback ~= nil then
            info.callback(self.result)
        end
    end
    local btn = info.gameObject:GetComponent(Button)
    self.attachObj = info.gameObject
    self.boolContainCountPanel = info.show_num
    self.result = 0
    self.result_show = self.min_result
    if not self.boolContainCountPanel then
        self.textObj = info.textObject
    end
    self.BuyIt = info.funcReturn
end

function NumberpadModel:OpenWindow()
    if self.numberPad == nil then
        self.numberPad = NumberpadPanel.New(self)
    end
    self.numberPad:Show()
end

function NumberpadModel:PressNum(i)
    self.result = self.result * 10 + i
    self.result_show = self.result
end

function NumberpadModel:Backspace()
    self.result = self.result - self.result % 10
    self.result = self.result / 10

    self.result_show = self.result
    if self.result_show == 0 then
        self.result_show = self.min_result
    end
end

function NumberpadModel:Add()
    self.result = self.result + 1
end

function NumberpadModel:Minus()
    self.result = self.result - 1
end

function NumberpadModel:CheckForResult()
    if self.max_result > self.max_by_asset then
        if self.result > self.max_by_asset then
            NoticeManager.Instance:FloatTipsByString(TI18N("已达到最大值"))
            self.result = self.max_by_asset
        end
    else
        if self.result > self.max_result then
            NoticeManager.Instance:FloatTipsByString(TI18N("已达到最大值"))
            self.result = self.max_result
        end
    end

    if self.result < self.min_result then
        self.result = self.min_result
    end
    self.result_show = self.result
end

function NumberpadModel:Close()
    if self.numberPad ~= nil then
        self.numberPad:DeleteMe()
        self.numberPad = nil
    end

    self.attachObj = nil
    self.textObj = nil
    self.BuyIt = nil
    self.result_show = self.min_result
end
