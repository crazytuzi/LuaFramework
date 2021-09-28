require "Core.Module.Common.Panel"

GuideSelectRolePanel = class("GuideSelectRolePanel", Panel);

function GuideSelectRolePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end


function GuideSelectRolePanel:GetUIOpenSoundName( )
    return ""
end

function GuideSelectRolePanel:_InitReference()
    self._imgMask = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgMask");
    self._trsCtrl = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCtrl");
    self._trsMsg = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCtrl/UI_GuideActMsg");



    self._btnSkip = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnSkip");
    self._btnHot = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgHot");

    UpdateBeat:Add(self.Update, self)
end

function GuideSelectRolePanel:_InitListener()
    self._onClickBtSkip = function(go) self:_OnClickBtSkip(self) end
    UIUtil.GetComponent(self._btnSkip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtSkip);

    self._onClickBtHot = function(go) self:_OnClickBtHot(self) end
    UIUtil.GetComponent(self._btnHot, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtHot);
end

function GuideSelectRolePanel:_Dispose()
    MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE, true);
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuideSelectRolePanel:_DisposeReference()
    self._trsCtrl = nil;
    self._btnSkip = nil;
    self._btnHot = nil;
end

function GuideSelectRolePanel:_DisposeListener()
    UpdateBeat:Remove(self.Update, self)

    UIUtil.GetComponent(self._btnSkip, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtSkip = nil;

    UIUtil.GetComponent(self._btnHot, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtHot = nil;
end

function GuideSelectRolePanel:IsFixDepth()
    return true;
end

function GuideSelectRolePanel:IsPopup()
    return false;
end

function GuideSelectRolePanel:Update()
    if (self.data) then
        local d = self.data;
        local offset = d.offset or Vector3.zero;
        local pos = UIUtil.WorldToUI(d.target:GetPos());
        Util.SetPos(self._trsCtrl, pos.x, pos.y, pos.z)
        pos = self._trsCtrl.localPosition + offset;
        Util.SetLocalPos(self._trsCtrl, pos.x, pos.y, pos.z)

        --        self._trsCtrl.position = pos;
        --        self._trsCtrl.localPosition = self._trsCtrl.localPosition + offset;

        if (self._imgMask) then
            local tf = d.target:GetCenter();
            local pos = UIUtil.WorldToView(d.target:GetPos());

            local ss = 0;
            if (self._ssss == nil) then
                if (d.target.transform ~= d.target:GetTop()) then
                    local top = UIUtil.WorldToView(d.target:GetTop().position);
                    self._ssss =(top.y - pos.y) / 2;
                    ss = self._ssss
                end
            else
                ss = self._ssss
            end

            local offsetX = 0.5 - pos.x;
            local offsetY = 0.5 - pos.y - ss;

            UIUtil.SetMaterialUV(self._imgMask, offsetX, offsetY)
            Util.SetLocalPos(self._btnHot, offsetX * -1280, offsetY * -720, 0)

            --            self._btnHot.transform.localPosition = Vector3.New(offsetX * -1280, offsetY * -720);
        end
    end
end

function GuideSelectRolePanel:UpdateGuide(data)
    self.data = data;
    self:UpdateDisplay();
end


function GuideSelectRolePanel:UpdateDisplay()
    GuideManager.isForceGuiding = true;
    -- self._uipanel:Refresh();
    local d = self.data;
    self.useMask = d.useMask;
    d.pos = UIUtil.WorldToUI(d.target:GetPos());
    self._btnSkip.gameObject:SetActive(d.canSkip);
    -- GuideTools.SetMsgFrameDisplay(self._trsMsg, d);
    self._displayCtrl = GuideDisplayCtrl.New(self._trsCtrl, d);
    self._displayCtrl:Play();
    Util.SetLocalPos(self._trsMsg, 0, 0, 0)

    --    self._trsMsg.transform.localPosition = Vector3.zero;
end


function GuideSelectRolePanel:_OnClickBtSkip()
    --[[
    if GuideManager.currentId > 0 then
        GuideProxy.ReqError(GuideManager.currentId);
    end
    ]]
    GuideManager.Stop();
    GuideManager.isForceGuiding = false;
end

function GuideSelectRolePanel:_OnClickBtHot()
    if (PlayerManager.hero) then
        PlayerManager.hero:SetTarget(self.data.target);
    end
    ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_SELECT_ROLE);
end