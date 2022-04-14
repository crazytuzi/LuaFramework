-- @Author: lwj
-- @Date:   2018-11-21 14:25:05
-- @Last Modified time: 2018-11-21 14:25:08

NumKeyPad = NumKeyPad or class("NumKeyPad", BasePanel)
local NumKeyPad = NumKeyPad

function NumKeyPad:ctor(targetText, confirmCallB, numCallB, backCallB, arrowDirection, pos_x, pos_y, close_cb)
    self.abName = "system"
    self.assetName = "NumKeyPad"
    self.layer = "UI"

    self.keyPadItemList = {}
    self.arrowsList = {}
    self.target = targetText
    self.pos_y = pos_y
    self.pos_x = pos_x

    self.arrowDirection = arrowDirection                    --上下左右的箭头  依次对应 1 2 3 4
    self:SetConfirmCallBack(confirmCallB)
    self:SetNumberCallBack(numCallB)
    self:SetBackSpaceCallB(backCallB)
    self.isModifiInput = false
    self.close_cb = close_cb
end

function NumKeyPad:dctor()
end

function NumKeyPad:Open()
    BasePanel.Open(self)
end

function NumKeyPad:LoadCallBack()
    self.nodes = {
        "KeyContainer/KeyPadItem4", "KeyContainer/KeyPadItem3", "KeyContainer/KeyPadItem5", "KeyContainer/KeyPadItem7", "KeyContainer/KeyPadItem1", "KeyContainer/KeyPadItem8", "KeyContainer/Confirm", "KeyContainer/KeyPadItem6", "KeyContainer/KeyPadItem2", "KeyContainer/BackSpace", "KeyContainer/KeyPadItem0", "KeyContainer/KeyPadItem9",
        "ArrowsContainer/top", "ArrowsContainer/bottom", "ArrowsContainer/left", "ArrowsContainer/right",
        "mask",
    }
    self:GetChildren(self.nodes)
    self.numText = self.target:GetComponent('Text')
    self:AddKeysToList()
    self:AddEvent()
    local rectTra = GetRectTransform(self.transform)
    if self.pos_x then
        SetAnchoredPosition(rectTra, self.pos_x, self.pos_y)
    end
end

function NumKeyPad:AddKeysToList()
    table.insert(self.keyPadItemList, self.KeyPadItem1)
    table.insert(self.keyPadItemList, self.KeyPadItem2)
    table.insert(self.keyPadItemList, self.KeyPadItem3)
    table.insert(self.keyPadItemList, self.KeyPadItem4)
    table.insert(self.keyPadItemList, self.KeyPadItem5)
    table.insert(self.keyPadItemList, self.KeyPadItem6)
    table.insert(self.keyPadItemList, self.KeyPadItem7)
    table.insert(self.keyPadItemList, self.KeyPadItem8)
    table.insert(self.keyPadItemList, self.KeyPadItem9)
    table.insert(self.keyPadItemList, self.KeyPadItem0)
    table.insert(self.keyPadItemList, self.Confirm)
    table.insert(self.keyPadItemList, self.BackSpace)

    self.arrowsList[1] = self.top
    self.arrowsList[2] = self.bottom
    self.arrowsList[3] = self.left
    self.arrowsList[4] = self.right
end

function NumKeyPad:AddEvent()

    for i, v in pairs(self.keyPadItemList) do
        local function call_back(target, x, y)
            --退格键
            if target.name == "BackSpace" then
                self.isModifiInput = false
                self.numText.text = "1"
                if self.backspaceCallB then
                    self.backspaceCallB()
                end
                return
                --确认键
            elseif target.name == "Confirm" then
                if self.confirmCallBack then
                    self.confirmCallBack()
                end
                self:Close()
                return
            end
            --数字键
            local name = string.match(target.name, "%d+")
            if self.isModifiInput or name == '0' then
                local curText = self.numText.text
                self.numText.text = curText .. name
            else
                self.numText.text = name
            end
            if self.numberClickCallB then
                self.numberClickCallB()
            end
            self.isModifiInput = true
        end
        AddButtonEvent(v.gameObject, call_back)
    end

    AddClickEvent(self.mask.gameObject, handler(self, self.Close))
end

function NumKeyPad:OpenCallBack()
    if self.arrowDirection then
        for i = 1, table.nums(self.arrowsList) do
            if self.arrowDirection == i then
                SetVisible(self.arrowsList[i], true)
            else
                SetVisible(self.arrowsList[i], false)
            end
        end
    end
end

function NumKeyPad:SetConfirmCallBack(call_back)
    if self.confirmCallBack then
        self.confirmCallBack = nil
    end
    self.confirmCallBack = call_back
end
function NumKeyPad:SetNumberCallBack(call_back)
    if self.numberClickCallB then
        self.numberClickCallB = nil
    end
    self.numberClickCallB = call_back
end
function NumKeyPad:SetBackSpaceCallB(call_back)
    if self.backspaceCallB then
        self.backspaceCallB = nil
    end
    self.backspaceCallB = call_back
end

function NumKeyPad:SetClickCloseDisable()
    self.use_background = false
    self.click_bg_close = false
end

function NumKeyPad:CloseCallBack()
    self.keyPadItemList = {}
    self.arrowsList = {}
    if self.close_cb then
        self.close_cb()
    end
    self.confirmCallBack = nil
    self.numberClickCallB = nil
    self.backspaceCallB = nil
    self.arrowDirection = nil
end
