require "Core.Module.Common.Panel"
ChatFacePanel = class("ChatFacePanel", Panel);

ChatFacePanel.CLOSE_CHAT_FACE_PANEL = "CLOSE_CHAT_FACE_PANEL";
ChatFacePanel.CLOSE_CHAT_FACE_PANEL2 = "CLOSE_CHAT_FACE_PANEL2";
ChatFacePanel.FACE_SELECTED = "FACE_SELECTED";-- 选择了表情, face:string

ChatFacePanel.Height = 165
ChatFacePanel.TweenTime = 0.386
ChatFacePanel._FaceMin = 0
ChatFacePanel._FaceMax = 64
ChatFacePanel._OldX = 0

function ChatFacePanel:New()
    self = { };
    setmetatable(self, { __index = ChatFacePanel });
    return self
end

function ChatFacePanel:GetUIOpenSoundName( )
    return ""
end

function ChatFacePanel:IsPopup()
    return false
end

function ChatFacePanel:_Init()
    self:_InitReference();
    self:_InitListener();

    Timer.New(function(val) self:_InitFaces() end, 0.1, 1, false):Start()
end

function ChatFacePanel:_InitReference()
    local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
    self._imgItem = UIUtil.GetChildInComponents(imgs, "imgItem");
    self._imgBg = UIUtil.GetChildInComponents(imgs, "imgBg");
    self._trsBg = self._imgBg.transform
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsScrollView = UIUtil.GetChildInComponents(trss, "trsScrollView");
    -- self._oldPos = self._trsContent.localPosition
end
function ChatFacePanel:_InitFaces()
    local sw = self._imgBg.width x = 10 y = -10 w = 80
    local col = math.floor(sw / w) w =(sw / col) h = - w
    --Warning(sw .. ":" .. col .. ":" .. w)
    self._Faces = { }
    for i = ChatFacePanel._FaceMin, ChatFacePanel._FaceMax, 1 do
        local go = i == ChatFacePanel._FaceMin and self._imgItem
        or Resourcer.Clone(self._imgItem.gameObject, self._trsScrollView)
        local spr = UIUtil.GetComponent(go, "UISprite")
        local sn = i < 10 and "0" .. i or i
        spr.spriteName = sn
        go.name = sn
        Util.SetLocalPos(go, x +(i % col) * w, y + math.floor(i / col) * -86, 0)

        --        go.transform.localPosition = Vector3(x + (i % col) * w ,y + math.floor(i / col) * -86 )
        UIUtil.GetComponent(go, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBg);
        -- logTrace(tostring(go.transform.localPosition))
        self._Faces[i] = go
    end
end
-- t: 1聊天表情,2好友聊天表情
function ChatFacePanel:Show(t)
    --self._gameObject:SetActive(true)
    self:SetPanelLayer(true)
    self:UpdateDepth()
    self._type = t
    -- self._trsContent.localPosition = Vector3(self._oldPos.x, self._oldPos.y - ChatFacePanel.Height, 0)
    -- LuaDOTween.DOLocalMoveY(self._trsContent, self._oldPos.y + ChatFacePanel.Height, ChatFacePanel.TweenTime, false)
end
function ChatFacePanel:Hide()
    --self._gameObject:SetActive(false)
    self:SetPanelLayer(false)
    --[[
    local twe = DelegateFactory.DOSetter_float(function(val)
        self._trsContent.localPosition = Vector3(self._oldPos.x, val, 0)
        if val == self._oldPos.y then self._gameObject:SetActive(false) end
    end)
    DG.Tweening.DOTween.To(twe, self._oldPos.y + ChatFacePanel.Height,self._oldPos.y , ChatFacePanel.TweenTime)
    --]]
end

function ChatFacePanel:_InitListener()
    self._onClickBg = function(go) self:_OnClickBg(go) end
    UIUtil.GetComponent(self._imgItem, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBg);
end

function ChatFacePanel:_OnClickBg(go)
    -- logTrace("_OnClickBg:go=" .. go.name)
    ModuleManager.SendNotification(ChatFacePanel.FACE_SELECTED, go.name)
end

function ChatFacePanel:_OnClickMask()
    ModuleManager.SendNotification(self._type == 1 and ChatFacePanel.CLOSE_CHAT_FACE_PANEL or ChatFacePanel.CLOSE_CHAT_FACE_PANEL2)
end

function ChatFacePanel:_DisposeListener()
    UIUtil.GetComponent(self._imgItem, "LuaUIEventListener"):RemoveDelegate("OnClick");
    for i = ChatFacePanel._FaceMin, ChatFacePanel._FaceMax, 1 do
        UIUtil.GetComponent(self._Faces[i], "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onClickBg = nil;
end

function ChatFacePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ChatFacePanel:_DisposeReference()
    self._imgItem = nil;
    self._imgBg = nil
    self._trsBg = nil;
    self._trsScrollView = nil;
    self._Faces = nil
end
