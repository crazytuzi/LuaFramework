require "Core.Module.Common.UIComponent"

DialogBubblePanel = class("DialogBubblePanel", UIComponent);

function DialogBubblePanel:_LoadUI()
    local ui = UIUtil.GetUI(ResID.UI_DIALOG_BUBBLE_PANEL);
    self:Init(ui.transform);
end

function DialogBubblePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function DialogBubblePanel:_InitReference()
    self._txtMsg = UIUtil.GetChildByName(self._transform, "UILabel", "txtMsg");
end

function DialogBubblePanel:SetData(msg, role)
    self:_LoadUI();
    self._role = role
    self:SetMsg(msg)
    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    self._timer:Start();
    self:_OnTimerHandler();
    return self
end
function DialogBubblePanel:SetMsg(msg)
    self._txtMsg.text = msg
    local size = self._txtMsg.printedSize
    local w =(size.x + 30)
    self._txtMsg.width = w
end
local farPos = Vector3(-1000, -1000, 0)
function DialogBubblePanel:_OnTimerHandler()
    -- log(tostring(self._role.__cname) .. "__" .. tostring(self._transform))
    if (self._role) then
        local roleTopTransform = self._role:GetTop()
        if (roleTopTransform) then
            -- Warning(self._role.gameObject.name .. "__" .. tostring(self._role.gameObject.activeSelf))
            if not self._role.visible then
                Util.SetLocalPos(self._gameObject, farPos.x, farPos.y, farPos.z)
--                self._transform.position = farPos
            else
                local roleTopTransform = self._role:GetTop();
                local pos = roleTopTransform.position
                pos.y = pos.y + 1
                local pt = UIUtil.WorldToUI(pos);
                Util.SetLocalPos(self._gameObject, pt.x, pt.y, pt.z)
--                self._transform.position = pt;
            end
        else
            self:Dispose()
        end
    end
end

function DialogBubblePanel:_InitListener()
end

function DialogBubblePanel:_Dispose()
    self:_DisposeReference();
end

function DialogBubblePanel:_DisposeReference()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self._txtMsg = nil;
    Resourcer.Recycle(self._gameObject, false)
end
