require "Core.Module.Common.Panel"

GuildSendHongBaoPanel = class("GuildSendHongBaoPanel", Panel);

local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RED_PACKET);

function GuildSendHongBaoPanel:New()
    self = { };
    setmetatable(self, { __index = GuildSendHongBaoPanel });
    return self
end

function GuildSendHongBaoPanel:_Init()
    self._curNum = 0;
    self._minNum = 0;
    self._maxNum = 0;
    self:_InitReference();
    self:_InitListener();
end

function GuildSendHongBaoPanel:_OnClickMask()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDSENDHONGBAOPANEL);
end

function GuildSendHongBaoPanel:_InitReference()
    self._txtMoney = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMoney");
    self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNum");
    self._txtDesc = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDesc");
    self._btnSub = UIUtil.GetChildByName(self._trsContent, "UIButton", "txtNum/btnSub");
    self._btnAdd = UIUtil.GetChildByName(self._trsContent, "UIButton", "txtNum/btnAdd");
    self._btnSend = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSend");
end

function GuildSendHongBaoPanel:_InitListener()
    self._onClickBtnSub = function(go) self:_OnClickBtnSub(self) end
    UIUtil.GetComponent(self._btnSub, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSub);
    self._onClickBtnAdd = function(go) self:_OnClickBtnAdd(self) end
    UIUtil.GetComponent(self._btnAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAdd);
    self._onClickBtnSend = function(go) self:_OnClickBtnSend(self) end
    UIUtil.GetComponent(self._btnSend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSend);
end

function GuildSendHongBaoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuildSendHongBaoPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnSub, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSub = nil;
     UIUtil.GetComponent(self._btnAdd, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAdd = nil;
    UIUtil.GetComponent(self._btnSend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSend = nil;
end

function GuildSendHongBaoPanel:_DisposeReference()
    self._txtMoney = nil;
    self._txtNum = nil;
    self._txtDesc = nil;
    self._btnSub = nil;
    self._btnAdd = nil;
    self._btnSend = nil;
end


function GuildSendHongBaoPanel:_OnClickBtnSub()
    if (self._curNum > self._minNum) then
        self._curNum = self._curNum - 1
        self._txtNum.text = self._curNum;
    end
end

function GuildSendHongBaoPanel:_OnClickBtnAdd()
    if (self._curNum < self._maxNum) then
        self._curNum = self._curNum + 1
        self._txtNum.text = self._curNum;
    end
end

function GuildSendHongBaoPanel:_OnClickBtnSend()
    if (self._data and self._curNum > 0) then
        GuildProxy.ReqSendHongBao(self._data.rpid, self._curNum);        
    end
    self:_OnClickMask();
end

function GuildSendHongBaoPanel:SetData(data)
    local cfgItem = cfg[data.rptid];
    self._data = data;
    if (cfgItem) then
        self._curNum = cfgItem.num;
        self._minNum = cfgItem.min_num;
        self._maxNum = cfgItem.max_num;
        self._txtDesc.text = cfgItem.name;
    else
        self._curNum = 0;
        self._minNum = 0;
        self._maxNum = 0;
    end
    self._txtMoney.text = self._data.bgold;
    self._txtNum.text = self._curNum
end