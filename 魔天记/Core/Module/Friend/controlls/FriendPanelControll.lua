require "Core.Module.Friend.controlls.FriendRightPanelControll";
require "Core.Module.Friend.controlls.FriendLeftPanelControll";
require "Core.Module.Common.UIComponent";

FriendPanelControll = class("FriendPanelControll",UIComponent);

function FriendPanelControll:New(_btnFriend)
    self = { };
    setmetatable(self, { __index = FriendPanelControll });
    self:Set_btnParty(_btnFriend);
    return self
end


function FriendPanelControll:_Init()
	self:_InitReference();
	
end

function FriendPanelControll:_InitReference()
   


    self.leftPanel = UIUtil.GetChildByName(self._transform, "Transform", "left");
    self.rightPanel = UIUtil.GetChildByName(self._transform, "Transform", "right");

    self.friendLeftPanelControll = FriendLeftPanelControll:New();
    self.friendLeftPanelControll:Init(self.leftPanel);

    self.friendRightPanelControll = FriendRightPanelControll:New();
    self.friendRightPanelControll:Init(self.rightPanel);

        MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, FriendPanelControll.UpTimeFroChatDataChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_CHECK_CHANGE, FriendPanelControll.UpTimeFroChatDataChange, self);


    self:UpTimeFroChatDataChange();

end

function FriendPanelControll:Set_btnParty(_btnFriend)
   
    self._btnFriend = _btnFriend;
    self._btnFriend_npoint = UIUtil.GetChildByName(self._btnFriend, "Transform", "npoint");

end

function FriendPanelControll:UpTimeFroChatDataChange()
    local d = FriendDataManager.HasNewChatMsg();
    if d then
        self._btnFriend_npoint.gameObject:SetActive(true);
    else
        self._btnFriend_npoint.gameObject:SetActive(false);
    end

end

function FriendPanelControll:Show()

    self.friendLeftPanelControll:Show();
    self.friendRightPanelControll:Show();


end

function FriendPanelControll:Dispose()

    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_CHECK_CHANGE, FriendPanelControll.UpTimeFroChatDataChange);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, FriendPanelControll.UpTimeFroChatDataChange);


    self.friendLeftPanelControll:Dispose();
    self.friendRightPanelControll:Dispose();
    FriendDataManager.currSelectTarget = nil;

 

    self.leftPanel = nil;
    self.rightPanel = nil;

    self.friendLeftPanelControll = nil;

    self.friendRightPanelControll = nil;

end