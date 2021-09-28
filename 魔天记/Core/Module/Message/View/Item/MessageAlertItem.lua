require "Core.Module.Message.View.Item.MessageItem";

MessageAlertItem = class("MessageAlertItem", MessageItem);


function MessageAlertItem:_Init()
    self._uipanel = UIUtil.GetComponent(self.transform, "UIPanel");
    self.sizeLeft = - self._uipanel.width / 2;
    self.oPos = self._txtLabel.transform.localPosition;
    self:Disable();
    UpdateBeat:Add(self.OnUpdate, self);
end

function MessageAlertItem:_Dispose()
    UpdateBeat:Remove(self.OnUpdate, self);
end

function MessageAlertItem:_Enable()
    Util.SetLocalPos(self._txtLabel, self.oPos.x, self.oPos.y, self.oPos.z)

    -- self._txtLabel.transform.localPosition = self.oPos;
    self.transform.gameObject:SetActive(true);
end

function MessageAlertItem:_Disable()
    self.data = nil;
    self.transform.gameObject:SetActive(false);
end

function MessageAlertItem:Show(data)
    self:Update(data);
    self._time = data.t
end

function MessageAlertItem:OnUpdate()
    if self.data then
        if (self._time > 0) then
            self._time = self._time - Timer.deltaTime;
        else
            self:Disable();
        end
--        local pos = self._txtLabel.transform.localPosition;
--        if pos.x + self._txtLabel.width <= self.sizeLeft then
--            self:OnScrollEnd();
--        else
--            pos.x = pos.x - 2;
--            Util.SetLocalPos(self._txtLabel, pos.x, pos.y, pos.z)
--        end
    end
end

function MessageAlertItem:OnScrollEnd()
    self.data._time = -1;
end

