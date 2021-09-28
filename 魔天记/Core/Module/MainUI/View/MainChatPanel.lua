require "Core.Module.Common.UIComponent"
require "Core.Module.Common.ChatItemSimple"

MainChatPanel = class("MainChatPanel",UIComponent);
MainChatPanel._MaxPanelHeight = 180
MainChatPanel._MinPanelHeight = 110
MainChatPanel._MaxScale = Vector3.New(1,1,1)
MainChatPanel._MinScale = Vector3.New(1,-1,1)

local _Insert = table.insert
local _Rmove = table.remove
function MainChatPanel:New()
	self = { };
	setmetatable(self, { __index =MainChatPanel });
    self._items = {}
	return self
end
function MainChatPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end
function MainChatPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	local imgs = UIUtil.GetComponentsInChildren(self._gameObject, "UISprite");
	self._imgChatBg = UIUtil.GetChildInComponents(imgs, "imgChatBg");
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UIButton");
	self._btnChatUp = UIUtil.GetChildInComponents(btns, "btnChatUp");
	self._btnWidget = UIUtil.GetComponent(self._btnChatUp, "UIWidget");
	self._btnChatSet = UIUtil.GetChildInComponents(btns, "btnChatSet");
	local togs = UIUtil.GetComponentsInChildren(self._gameObject, "UIToggle");
	local trss = UIUtil.GetComponentsInChildren(self._gameObject, "Transform");
	self._trsScrollView = UIUtil.GetChildInComponents(trss, "trsScrollView");
	self._trsChatItem = UIUtil.GetChildInComponents(trss, "trsChatItem");

    self._trsChatItemGo = self._trsChatItem.gameObject
    self._trsChatItemGo:SetActive(false)
	self._scrollView = UIUtil.GetComponent(self._trsScrollView, "UIScrollView");
	self._scrollPanel = UIUtil.GetComponent(self._trsScrollView, "UIPanel");
	--self._uiTable = UIUtil.GetComponent(self._trsScrollView, "UITable");
end
function MainChatPanel:_InitListener()
	self._onClickBtnChatUp = function(go) self:_OnClickBtnChatUp(self) end
	UIUtil.GetComponent(self._btnChatUp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnChatUp);
	UIUtil.GetComponent(self._btnChatSet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._OnClickBtnChatSet);
	UIUtil.GetComponent(self._imgChatBg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._OnClickChatBg);
    MessageManager.AddListener(ChatManager, ChatManager.CHAT_RECEIVE_DATA, MainChatPanel.ChatReceive, self);
end

function MainChatPanel:_OnClickBtnChatUp()
    if self._imgChatBg.height == MainChatPanel._MinPanelHeight then
	    --self._btnChatUp.transform.localScale = MainChatPanel._MaxScale 
        Util.SetRotation(self._btnChatUp, 0, 0, 180)
        self._imgChatBg.height = MainChatPanel._MaxPanelHeight
        self._btnWidget:UpdateAnchors()
        self._scrollPanel:UpdateAnchors()
    else 
	    --self._btnChatUp.transform.localScale = MainChatPanel._MinScale 
        Util.SetRotation(self._btnChatUp, 0, 0, 0)
        self._imgChatBg.height = MainChatPanel._MinPanelHeight
        self._btnWidget:UpdateAnchors()
        self._scrollPanel:UpdateAnchors()
    end
end
function MainChatPanel:_OnClickChatBg()
    ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_PANEL)
end
function MainChatPanel:_OnClickBtnChatSet()
    ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_SET_PANEL)
end

--[[s_id:发送者id
s_name:发送者name
k:职业
t:类型（1：文字2：语音）
c:channel渠道（1：世界2：门派3：队伍）
msg：（1：文字聊天信息 2： 语音翻译语音文字）
url：语音地址
time:语音消息时长（秒为单位）
date:发送时间毫秒数--]]
function MainChatPanel:ChatReceive(data)
    local chl = data.tag
    if chl == ChatTag.world and not ChatSettingData.world then return end
    if chl == ChatTag.team and not ChatSettingData.team then return end
    if chl == ChatTag.school and not ChatSettingData.school then return end
    if chl == ChatTag.active and not ChatSettingData.active then return end
    if chl == ChatTag.system and not ChatSettingData.system then return end
    if ChatManager.isFirstMsg(data) then
        self:AddMsg(data)
    else --第二次语音翻译
        for _,value in pairs(self._items) do
            if ChatManager.CheckSameMsg(value.data, data) then
                value:UpdataVoiceMsg(data)
                break
            end
        end
    end
    self:UpdateReset()
end
function MainChatPanel:AddMsg(data)
    local c = nil
    if #self._items > ChatManager.MsgMaxUINum then 
        c = _Rmove(self._items, 1)
        c:OnRecycle()
    end
    if not c then 
        local itemv = Resourcer.Clone(self._trsChatItemGo, self._trsScrollView)
        itemv:SetActive(true)
        c = ChatItemSimple:New()
        c:Init(itemv.transform)
    end
    c:InitData(data, true)
    _Insert(self._items, c)
end
function MainChatPanel:UpdateReset()
    local currentHH = 0
    for _,value in ipairs(self._items) do
        currentHH = currentHH - value:SetPos(Vector3(0,currentHH,0))
    end
    self._scrollView:ResetPosition()
end

function MainChatPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
    for _,value in pairs(self._items) do
        value:Dispose()
    end
end
function MainChatPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnChatUp, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnChatUp = nil;
	UIUtil.GetComponent(self._btnChatSet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._imgChatBg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    MessageManager.RemoveListener(ChatManager, ChatManager.CHAT_RECEIVE_DATA, MainChatPanel.ChatReceive);
end
function MainChatPanel:_DisposeReference()
	self._btnChatUp = nil;
	self._btnChatSet = nil;
	self._imgChatBg = nil;
	self._trsChatItem = nil;
end
