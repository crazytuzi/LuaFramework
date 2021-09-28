AddAttrPanel = class("AddAttrPanel", UIComponent)
function AddAttrPanel:New(data,parent)
    self = { };
    setmetatable(self, { __index = AddAttrPanel });
    self.data = data 
    self.parent = parent
    self:_LoadUI();
end

function AddAttrPanel:_LoadUI()
    local ui = UIUtil.GetUIGameObject(ResID.UI_ATTRADDPANEL, self.parent);
    self:Init(ui.transform);
end 

function AddAttrPanel:_Init()
    self:_InitReference()
    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    self._timer:Start();
    self:UpdatePanel()
end

function AddAttrPanel:_InitReference()
    local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
    self._animator = trsContent:GetComponent("Animator");
    self._txtAttr = UIUtil.GetChildByName(self._transform, "UILabel", "trsContent/txtLabel")
end

function AddAttrPanel:UpdatePanel()
    self._txtAttr.text = self.data.k .. "+" .. self.data.v
end

function AddAttrPanel:_Dispose()
    if (self._timer) then
        self._timer:Stop();
    end
    self._animator = nil
    Resourcer.Recycle(self._gameObject, true)
end

 
function AddAttrPanel:_OnTimerHandler()
    local info = self:_GetAnimatorStateInfo(); 
    if not info or info.normalizedTime >= 1 then
        self:Dispose();
    end
end

function AddAttrPanel:_GetAnimatorStateInfo()
    local anim = self._animator;
    if not IsNil(anim) then
        return anim:GetCurrentAnimatorStateInfo(0);
    end
    return nil;
end
