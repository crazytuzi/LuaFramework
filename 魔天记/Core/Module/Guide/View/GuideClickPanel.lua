require "Core.Module.Common.Panel"

GuideClickPanel = class("GuideClickPanel", Panel);

function GuideClickPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GuideClickPanel:GetUIOpenSoundName( )
    return ""
end

function GuideClickPanel:_InitReference()
    self._uipanel = UIUtil.GetComponent(self._transform, "UIPanel");

    self._trsBg = UIUtil.GetChildByName(self._trsContent, "Transform", "bg");

    self._imgEffect = UIUtil.GetChildByName(self._trsContent, "UISprite", "icoEffect");
    self._trsEffect = UIUtil.GetChildByName(self._trsContent, "Transform", "trsEffect");
    self._trsCtrl = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCtrl");

    self._btnSkip = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnSkip");

    -- if not self._effect then
    self._effect = UIUtil.GetUIEffect("ui_guide_1", self._trsEffect, self._imgEffect);
    -- end
    if self._effect then
        NGUITools.SetLayer(self._effect, self._trsEffect.gameObject.layer);
    end

    self._onEnable = function() self:_OnEnable() end
    self._luaBehaviour:RegisterDelegate("OnEnable", self._onEnable);
    self._onDisable = function() self:_OnDisable() end
    self._luaBehaviour:RegisterDelegate("OnDisable", self._onDisable);

    --UpdateBeat:Add(self.Update, self)
    self._clickCount = 0;
    self._timer = Timer.New( function(val) self:Update(val) end, 2, -1, false);
    self._timer:Start();
end

function GuideClickPanel:_InitListener()
    self._onClickBtSkip = function(go) self:_OnClickBtSkip(self) end
    UIUtil.GetComponent(self._btnSkip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtSkip);
    self._onClickMask = function(go) self:_OnClickMask(self) end
    UIUtil.GetComponent(self._trsBg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMask);

    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE_BEFORE, GuideClickPanel.OnSceneLoadBefore, self);
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, GuideClickPanel.OnSceneLoadAfter, self);
end

function GuideClickPanel:_OnEnable()
    self:_ApplyMask();
end

function GuideClickPanel:_OnDisable()
    GuideMaskEffect.StopGuideMaskEffect();
end

function GuideClickPanel:_Dispose()
    self:_DisposeReference();
    self:_DisposeListener();
end

function GuideClickPanel:_DisposeReference()

    --UpdateBeat:Remove(self.Update, self)
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    self._luaBehaviour:RemoveDelegate("OnEnable");
    self._luaBehaviour:RemoveDelegate("OnDisable");

    GuideManager.isForceGuiding = false;
    GuideMaskEffect.StopGuideMaskEffect();
    
    if self._effect then
        Resourcer.Recycle(self._effect, false)
        self._effect = nil;
    end
end

function GuideClickPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnSkip, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtSkip = nil;

    UIUtil.GetComponent(self._trsBg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMask = nil;

    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE_BEFORE, GuideClickPanel.OnSceneLoadBefore);
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, GuideClickPanel.OnSceneLoadAfter);
end

function GuideClickPanel:IsFixDepth()
    return true;
end

function GuideClickPanel:IsPopup()
    return false;
end

function GuideClickPanel:Update()
    self._clickCount = 0;
end

function GuideClickPanel:UpdateGuide(data)
    self.data = data;
    self._clickCount = 0;
    self:UpdateDisplay();
end

--[[
    msg
    target
    anchorTr
    posType
    offset
    isUITarget
]]

function GuideClickPanel:UpdateDisplay()

    GuideManager.isForceGuiding = true;

    -- self._uipanel:Refresh();
    local d = self.data;
    self.useMask = d.useMask;

    local pos = d.anchorTr.position;

    if self.useMask then
        pos.z = -20;
    end

    d.pos = pos;
    self._displayCtrl = GuideDisplayCtrl.New(self._trsCtrl, d);
    -- GuideTools.SetMsgFrameDisplay(self. , d);
    Util.SetPos(self._trsEffect, pos.x, pos.y, pos.z)

    self._trsEffect.gameObject:SetActive(true);

    local w = nil
    for i, v in ipairs(d.target) do
        w = v:GetComponent("UIWidget");
        if w then
            break;
        end
    end

    if w then
        UIUtil.SetEffectOrder(self._effect, w);
    else
        UIUtil.SetEffectByGo(self._effect);
    end
    
    Util.SetLocalPos(self._trsEffect, self._trsEffect.transform.localPosition + d.effectOffset)
    
    self._btnSkip.gameObject:SetActive(d.canSkip);

    self:_ApplyMask();

    self._displayCtrl:Play();
end

function GuideClickPanel:_ApplyMask()
    if self.data and self.useMask then
        if (self.data.maskAlpha) then
            GuideMaskEffect.ApplyGuideMaskEffect(self.data.target, true, self.data.maskAlpha);
        else
            GuideMaskEffect.ApplyGuideMaskEffect(self.data.target, true);
        end
    end
end

function GuideClickPanel:_OnClickBtSkip()
    
    if GuideManager.currentId > 0 then
        GuideProxy.ReqStop(GuideManager.currentId);
    end
    
    GuideManager.Stop();
end

function GuideClickPanel:_OnClickMask()
    self._clickCount = self._clickCount and self._clickCount + 1 or 1;
    
    if self._clickCount > 4 then
        self:_OnClickBtSkip();
    end

    SequenceManager.TriggerEvent(SequenceEventType.Guide.BLANK_CLICK, self._clickCount);
end

function GuideClickPanel:OnSceneLoadBefore()
    self._hide = true;
    self:_OnDisable();
end

function GuideClickPanel:OnSceneLoadAfter()
    if self._hide then
        self:_OnEnable();
    end
end
