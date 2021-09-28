require "ui.dialog"
require "ui.friendsdialog"

FriendEntranceDialog = {}
setmetatable(FriendEntranceDialog, Dialog)
FriendEntranceDialog.__index = FriendEntranceDialog 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FriendEntranceDialog.getInstance()
	LogInfo("enter FriendEntranceDialog")
    if not _instance then
        _instance = FriendEntranceDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FriendEntranceDialog.getInstanceAndShow()
	LogInfo("enter instance show")
    if not _instance then
        _instance = FriendEntranceDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FriendEntranceDialog.getInstanceNotCreate()
    return _instance
end 

function FriendEntranceDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function FriendEntranceDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FriendEntranceDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function FriendEntranceDialog.GetLayoutFileName()
    return "friendentrance.layout"
end

function FriendEntranceDialog:OnCreate()
	LogInfo("enter FriendEntranceDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_FriendDlgBtn=CEGUI.Window.toPushButton(winMgr:getWindow("friendentrance/btn") )
    self.m_FriendDlgBtn:subscribeEvent("Clicked", FriendEntranceDialog.HandleClickRestorBtn, self)
    self.m_Notify=winMgr:getWindow("friendentrance/mark")
    self.m_Notify:setVisible(false)
    local msgNum=GetFriendsManager():GetNotReadMsgNum()
  
    if msgNum>0 then
       self.m_Notify:setVisible(true)
       self.m_Notify:setText(tostring(msgNum))
    end
	LogInfo("exit FriendEntranceDialog OnCreate")
end

------------------- private: -----------------------------------

function FriendEntranceDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FriendEntranceDialog)

    return self
end



function FriendEntranceDialog:HandleClickRestorBtn(args)
  LogInfo("FriendEntranceDialog:HandleClickRestorBtn")

  --FriendsDialog.getInstanceAndShow()
  
  if GetFriendsManager() then
    if GetFriendsManager():HasNotShowMsg() then
        GetFriendsManager():PopChatMsg()
    else
        FriendsDialog.getInstanceAndShow()
    end
  else
    FriendsDialog.getInstanceAndShow()
  end

  return true
end

function FriendEntranceDialog.RefreshNotify()
  LogInfo("FriendEntranceDialog:RefreshNotify")
  if not _instance then 
     return
  end
 _instance.m_Notify:setVisible(false)
  local msgNum=GetFriendsManager():GetNotReadMsgNum()
  
  if msgNum>0 then
     _instance.m_Notify:setVisible(true)
     _instance.m_Notify:setText(tostring(msgNum))
  end
  
end



