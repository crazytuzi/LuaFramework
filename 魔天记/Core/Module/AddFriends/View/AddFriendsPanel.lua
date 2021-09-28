require "Core.Module.Common.Panel"
require "Core.Module.AddFriends.item.PlayerItem"


AddFriendsPanel = class("AddFriendsPanel", Panel);
function AddFriendsPanel:New()
    self = { };
    setmetatable(self, { __index = AddFriendsPanel });
    return self
end


function AddFriendsPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function AddFriendsPanel:_InitReference()
    self._txttitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txttitle");
    self.txtTip = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTip");

    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_changeFd = UIUtil.GetChildInComponents(btns, "btn_changeFd");
    self._btn_search = UIUtil.GetChildInComponents(btns, "btn_search");

    self.bottpmPar = UIUtil.GetChildByName(self._trsContent, "Transform", "bottpmPar");
    self.txtChatInput = UIUtil.GetChildByName(self.bottpmPar, "Transform", "txtChatInput");
    self.inputTxt = UIUtil.GetChildByName(self.txtChatInput, "UILabel", "Label");

    self.playerList = UIUtil.GetChildByName(self._trsContent, "Transform", "playerList");

    self.players = { };
    for i = 1, 8 do
        local pitem = UIUtil.GetChildByName(self.playerList, "Transform", "item" .. i);
        self.players[i] = PlayerItem:New();
        self.players[i]:Init(pitem)
    end

    self.txtTip.gameObject:SetActive(false);

    MessageManager.AddListener(AddFriendsNotes, AddFriendsNotes.MESSAGE_FRIENDLIST_UPDATA, AddFriendsPanel.FriendListUpData, self);

end

function AddFriendsPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_changeFd = function(go) self:_OnClickBtn_changeFd(self) end
    UIUtil.GetComponent(self._btn_changeFd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_changeFd);
    self._onClickBtn_search = function(go) self:_OnClickBtn_search(self) end
    UIUtil.GetComponent(self._btn_search, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_search);
end


function AddFriendsPanel:FriendListUpData(list)

    for i = 1, 8 do
        local pitem = UIUtil.GetChildByName(self.playerList, "Transform", "item" .. i);
        self.players[i]:SetData(list[i])
    end

    local t_num = table.getn(list);

    if t_num > 0 then
        self.txtTip.gameObject:SetActive(false);
    else
        self.txtTip.gameObject:SetActive(true);
    end

end

function AddFriendsPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(AddFriendsNotes.CLOSE_ADDFRIENDSPANEL);
end

function AddFriendsPanel:_OnClickBtn_changeFd()
    AddFriendsProxy.TryGetTJFriendList();
end

function AddFriendsPanel:_OnClickBtn_search()

    local name = self.inputTxt.text;
    AddFriendsProxy.TryFindFriend(name)
end


function AddFriendsPanel:Show()

    AddFriendsProxy.TryGetTJFriendList();

end

function AddFriendsPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();


    for i = 1, 8 do
        self.players[i]:Dispose();
        self.players[i] = nil;
    end

    self._txttitle = nil;
    self.txtTip = nil;


    self._btn_close = nil;
    self._btn_changeFd = nil;
    self._btn_search = nil;

    self.bottpmPar = nil;
    self.txtChatInput = nil;
    self.inputTxt = nil;

    self.playerList = nil;

    self.players = nil;

end

function AddFriendsPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_changeFd, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_changeFd = nil;
    UIUtil.GetComponent(self._btn_search, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_search = nil;

    MessageManager.RemoveListener(AddFriendsNotes, AddFriendsNotes.MESSAGE_FRIENDLIST_UPDATA, AddFriendsPanel.FriendListUpData);

end

function AddFriendsPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_changeFd = nil;
    self._btn_search = nil;
end
