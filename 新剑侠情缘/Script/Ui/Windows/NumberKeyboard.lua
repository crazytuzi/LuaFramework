local KeyboardUi = Ui:CreateClass("NumberKeyboard");
local DEC = 10; --10进制

function KeyboardUi:SetClick()
    KeyboardUi.tbOnClick = {
        Delete = function (self)
            self:OnDeleteOne();
        end,
        OK = function (self)
            self:OnInputOver();
        end,
    };
    for i = 0, DEC - 1 do
        KeyboardUi.tbOnClick[string.format("%s", i)] = function (self)
            self:OnNumPress(i);
        end
    end
end
KeyboardUi:SetClick();

function KeyboardUi:OnOpen(fnUpdate)
    self.fnUpdate = fnUpdate;
    self.nInput   = 0
end

function KeyboardUi:OnScreenClick()
    if self.nInput > 0 then
        self:UpdateListener(true);
    end
    Ui:CloseWindow(self.UI_NAME);
end

function KeyboardUi:OnNumPress(nPress)
    self.nInput = self.nInput * DEC + nPress;
    self:UpdateListener();
end

function KeyboardUi:OnDeleteOne()
    self.nInput = math.floor(self.nInput / DEC);
    self:UpdateListener();
end

function KeyboardUi:OnInputOver()
    self:UpdateListener(true);
    Ui:CloseWindow(self.UI_NAME);
end

function KeyboardUi:UpdateListener(bClose)
    self.nInput = tonumber(self.nInput) or 0;

    if self.fnUpdate then
        local nResult = self.fnUpdate(self.nInput, bClose);
        self.nInput = nResult;
    end
end