require "Core.Module.Common.UIComponent"
require "Core.Module.Common.TextCode"
ChatItemSimple = class("ChatItemSimple", UIComponent);
ChatItemSimple.VoiceFlg = "#65#"
function ChatItemSimple:New()
    self = { };
    setmetatable(self, { __index = ChatItemSimple });
    return self
end
function ChatItemSimple:_Init()
    self:_InitReference();
    self:_InitListener();
end
function ChatItemSimple:_InitReference()
    self._txtMsg1 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtChatMsg");
    self._txtMsg1Smylog = UIUtil.GetChildByName(self._gameObject, "SymbolLabel", "txtChatMsg");
    self._imgType = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgChatType");
end
--[[
s_id:发送者id
s_name:发送者name
k:职业
t:类型（1：文字2：语音）
c:channel渠道（1：世界2：门派3：队伍）
msg：（1：文字聊天信息 2： 语音翻译语音文字）
url：语音地址
time:语音消息时长（秒为单位）
date:发送时间毫秒数
--]]
function ChatItemSimple:InitData(data, flg)
    self.data = data
    self._transform.name = data.date
    local sn = nil
    if ChatManager.IsPlayerMsg(data) then
        local vc = ColorDataManager.Get_Vip(data.vip)
        sn = "[url=pid_" .. data.s_id .. "][00000000]00000[-]" ..vc  .. "[00ff00]" .. data.s_name .. ": [-][/url]"
        self._txtMsg1.color = ColorDataManager.Get_white()
        if data.t == 2 then
            sn = sn .. ChatItemSimple.VoiceFlg .. "(" ..(math.floor(data.time / 1000) + 1) .. "\")"
        else
            sn = sn .. data.msg
        end
    else
        sn = "[00000000]00000[-]" .. data.msg
    end
    self._imgType.spriteName = ChatManager.GetSpriteNameForTag(data.tag)
    self._txtMsg1.text = sn
    UIUtil.GetComponent(self._txtMsg1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    TextCode.Handler(self._txtMsg1, self.data, flg and self._SelectedPlayer or nil, self)
    self._txtMsg1Smylog:UpdateLabel()
end
function ChatItemSimple:UpdataVoiceMsg(data)
    self.data = data
    self._txtMsg1.text = self._txtMsg1.text .. data.msg
end
function ChatItemSimple:_SelectedPlayer()
    ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_PANEL, self.data.c)
end
function ChatItemSimple:SetPos(pos)
    if (not IsNil(self._transform)) then
        Util.SetLocalPos(self._transform, pos.x,pos.y,pos.z)

--        self._transform.localPosition = pos
    end
    return self._txtMsg1.height + 4
end
function ChatItemSimple:OnRecycle()
    UIUtil.GetComponent(self._txtMsg1, "LuaUIEventListener"):RemoveDelegate("OnClick");
end
function ChatItemSimple:SetVisible(val)
    self._gameObject:SetActive(val)
end

function ChatItemSimple:_InitListener()
end
function ChatItemSimple:_DisposeListener()
    UIUtil.GetComponent(self._txtMsg1, "LuaUIEventListener"):RemoveDelegate("OnClick");
end
function ChatItemSimple:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if not IsNil(self._gameObject)then
        GameObject.Destroy(self._gameObject)
        self._gameObject = nil
    end
end
function ChatItemSimple:_DisposeReference()
    self._txtMsg1 = nil;
    self._txtMsg1Smylog = nil;
    self._imgType = nil;
end
