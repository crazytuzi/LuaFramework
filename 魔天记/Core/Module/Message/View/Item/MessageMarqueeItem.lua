require "Core.Module.Message.View.Item.MessageItem";

MessageMarqueeItem = class("MessageMarqueeItem", MessageItem);


function MessageMarqueeItem:_Init()
    self._uipanel = UIUtil.GetComponent(self.transform, "UIPanel");
    self.sizeLeft = - self._uipanel.width / 2;
    self.oPos = self._txtLabel.transform.localPosition;
    self:Disable();
    UpdateBeat:Add(self.OnUpdate, self);
end

function MessageMarqueeItem:_Dispose()
    UpdateBeat:Remove(self.OnUpdate, self);
end

function MessageMarqueeItem:_Enable()
    Util.SetLocalPos(self._txtLabel, self.oPos.x, self.oPos.y, self.oPos.z)

    -- self._txtLabel.transform.localPosition = self.oPos;
    self.transform.gameObject:SetActive(true);
end

function MessageMarqueeItem:_Disable()
    self.data = nil;
    self.transform.gameObject:SetActive(false);
end

function MessageMarqueeItem:Show(data)
    self:Update(data);
    data._time = 0;
end

function MessageMarqueeItem:OnUpdate()
    if self.data then
        local pos = self._txtLabel.transform.localPosition;
        if pos.x + self._txtLabel.width <= self.sizeLeft then
            self:OnScrollEnd();
        else
            pos.x = pos.x - 2;
            Util.SetLocalPos(self._txtLabel, pos.x, pos.y, pos.z)

            --            self._txtLabel.transform.localPosition = pos;
        end
    end
end

function MessageMarqueeItem:OnScrollEnd()
    self.data._time = -1;
end

