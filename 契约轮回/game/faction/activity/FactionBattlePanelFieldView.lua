---
--- Created by R2D2.
--- DateTime: 2019/2/19 17:01
---
--local FactionBattlePanelTextList = {}
--function FactionBattlePanelTextList:Add(textBox)
--    self.list = self.list or {}
--    table.insert(self.list, textBox)
--end
--
--function FactionBattlePanelTextList:SetText(...)
--    for i, v in ipairs({ ... }) do
--        if self.list and self.list[i] then
--            self.list[i].text = v
--        end
--    end
--end

--function FactionBattlePanelTextList:SetContent(str1, str2, str3, str4)
--    if (self.Text1 and str1) then
--        self.Text1.text = str1
--    end
--    if (self.Text2 and str2) then
--        self.Text2.text = str2
--    end
--    if (self.Text3 and str3) then
--        self.Text3.text = str3
--    end
--    if (self.Text4 and str4) then
--        self.Text4.text = str4
--    end
--end

local FactionBattlePanelFieldView = {}

function FactionBattlePanelFieldView:AddTextList(typeId, ...)
    self.FieldList = self.FieldList or {}

    local textList = {}
    for _, v in ipairs({ ... }) do
        local t = GetText(v)
        if (t) then
            table.insert(textList, t)
        end
    end

    self.FieldList[typeId] = textList
end

function FactionBattlePanelFieldView:AddWinSign(typeId, signLeft, signRight)
    self.SignList = self.SignList or {}
    local t = {}
    t.SignLeft = GetImage(signLeft)
    t.SignRight = GetImage(signRight)
    self.SignList[typeId] = t
end

function FactionBattlePanelFieldView:HideWinSign(typeId)
    if self.SignList and self.SignList[typeId] then
        self.SignList[typeId].SignLeft.enabled = false
        self.SignList[typeId].SignRight.enabled = false
    end
end

function FactionBattlePanelFieldView:HideAllWinSign()
    for i, _ in pairs(self.SignList) do
        self:HideWinSign(i)
    end
end

function FactionBattlePanelFieldView:SetWinSign(typeId, left, right)
    self:SetWinSignPos(self.FieldList[typeId][left], self.SignList[typeId].SignLeft)
    self:SetWinSignPos(self.FieldList[typeId][right==0 and right or right + 2],  self.SignList[typeId].SignRight)
end

function FactionBattlePanelFieldView:SetWinSignPos(textBox, signImage)
    if (textBox and signImage) then
        signImage.enabled = true
        local x, y = GetAnchoredPosition(textBox.transform)
        SetAnchoredPosition(signImage.transform, x - 40, y + 15)
    else
        signImage.enabled = false
    end
end

function FactionBattlePanelFieldView:SetText(typeId, ...)
    if self.FieldList and self.FieldList[typeId] then
        for i, v in ipairs({ ... }) do
            if self.FieldList[typeId][i] then
                self.FieldList[typeId][i].text = v
            end
        end
    end
end

return FactionBattlePanelFieldView
