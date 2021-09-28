require "Core.Module.Common.Panel"
require "Core.Module.Notice.View.NoticeItem"

NoticePanel = class("NoticePanel", Panel);
function NoticePanel:New()
    self = { };
    setmetatable(self, { __index = NoticePanel });
    return self
end


function NoticePanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self:_InitConfig()
end
function NoticePanel:_InitConfig()
    self._notices = NoticeProxy.GetNotices()
    self._noticeItem = { }
    for k, v in ipairs(self._notices) do
        -- PrintTable(v)
        self:_InitItem(k, v)
    end
    self._scrollItemView:ResetPosition()
end
function NoticePanel:_InitItem(i, config)
    local item = NoticeItem:New(self)
    local go = Resourcer.Clone(self._btnItem.gameObject, self._trsItemScroll)
    item:Init(go.transform, i, config)
    Util.SetLocalPos(go, 0, i * -80, 0)

    --    go.transform.localPosition = Vector3(0, i * -80, 0)
    go:SetActive(true)
    table.insert(self._noticeItem, item)
end

function NoticePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtTitle = UIUtil.GetChildInComponents(txts, "txtTitle");
    self._txtCon = UIUtil.GetChildInComponents(txts, "txtCon");
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
    self._btnLogin = UIUtil.GetChildInComponents(btns, "btnLogin");
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsItemScroll = UIUtil.GetChildInComponents(trss, "trsItemScroll");
    self._scrollItemView = UIUtil.GetComponent(self._trsItemScroll, "UIScrollView");
    self._btnItem = UIUtil.GetChildInComponents(trss, "btnItem");
    self._btnItem.gameObject:SetActive(false)
    self._trsScroll = UIUtil.GetChildInComponents(trss, "trsScroll");
    self._scrollView = UIUtil.GetComponent(self._trsScroll, "UIScrollView");
end

function NoticePanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    self._onClickBtnLogin = function(go) self:_OnClickBtnLogin(self) end
    UIUtil.GetComponent(self._btnLogin, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLogin);
end

function NoticePanel:_OnClickBtnClose()
    ModuleManager.SendNotification(NoticeNotes.CLOSE_NOTICE_PANEL)
end

function NoticePanel:_OnClickBtnLogin()
    self:_OnClickBtnClose()
end

function NoticePanel:OnClickItem(title, context)
    self._txtTitle.text = title
    self._txtCon.text = context
    self._scrollView:ResetPosition()
end

function NoticePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if (self._noticeItem) then
        for k, v in pairs(self._noticeItem) do
            v:Dispose()
        end
        self._noticeItem = nil
    end
end

function NoticePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    UIUtil.GetComponent(self._btnLogin, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnLogin = nil;
end

function NoticePanel:_DisposeReference()
    self._btnClose = nil;
    self._btnLogin = nil;
    self._txtItem = nil;
    self._txtTitle = nil;
    self._txtCon = nil;
    self._trsItemScroll = nil;
    self._trsScroll = nil;
    self._btnItem = nil
end
