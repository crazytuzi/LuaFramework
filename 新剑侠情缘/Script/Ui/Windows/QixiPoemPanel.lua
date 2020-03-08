local tbUi = Ui:CreateClass("QixiPoemPanel")

function tbUi:LoadSetting()
    local tbPoem = Lib:LoadTabFile("Setting/Activity/QixiPoem.tab")
    assert(tbPoem and #tbPoem > 0, "QixiPoemPanel LoadSetting Error")
    self.tbPoem = {}
    for _, tbInfo in ipairs(tbPoem) do
        local t = {}
        for i = 1, 4 do
            table.insert(t, tbInfo["Item" .. i])
        end
        table.insert(self.tbPoem, t)
    end
end

function tbUi:CreatePoemOrder()
    local tbTemp = {}
    for i = 1, #self.tbPoem do
        table.insert(tbTemp, i)
    end

    self.tbOrder = {}
    while (next(tbTemp)) do
        local nRan = MathRandom(#tbTemp)
        local nIdx = table.remove(tbTemp, nRan)
        table.insert(self.tbOrder, nIdx)
    end
end

function tbUi:OnOpenEnd()
    if not self.tbPoem then
        self:LoadSetting()
    end

    if not self.tbOrder or #self.tbOrder <= 0 then
        self:CreatePoemOrder()
    end

    local nIdx = table.remove(self.tbOrder, 1)
    local tbPoemText = self.tbPoem[nIdx]
    for i = 1, 4 do
        self.pPanel:Tween_Reset("Describe" .. i)
        self.pPanel:Tween_Reset("Bg_0" .. i)
        self.pPanel:Label_SetText("Describe" .. i, tbPoemText[i])
        self.pPanel:Tween_Play("Describe" .. i)
        self.pPanel:Tween_Play("Bg_0" .. i)
    end
end