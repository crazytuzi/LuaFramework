require "ui.dialog"

MiniFriendChatDialog = {}
setmetatable(MiniFriendChatDialog, Dialog)
MiniFriendChatDialog.__index = MiniFriendChatDialog 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function MiniFriendChatDialog.getInstance()
	print("enter MiniFriendChatDialog")
    if not _instance then
        _instance = MiniFriendChatDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function MiniFriendChatDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = MiniFriendChatDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function MiniFriendChatDialog.getInstanceNotCreate()
    return _instance
end

function MiniFriendChatDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function MiniFriendChatDialog.ToggleOpenClose()
	if not _instance then 
		_instance = MiniFriendChatDialog:new() 
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

function MiniFriendChatDialog.GetLayoutFileName()
    return "chatsmallbtn.layout"
end

function MiniFriendChatDialog:OnCreate()
	print("enter FriendChatDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_RestoreBtn=CEGUI.Window.toPushButton(winMgr:getWindow("chatsmallbtn/btm") )
    self.m_Notify=winMgr:getWindow("chatsmallbtn/btm/mark")
     self.m_Notify:setVisible(false)
     
     self.m_RestoreBtn:subscribeEvent("Clicked", MiniFriendChatDialog.HandleClickRestorBtn, self)
 
    --init settings
	self.m_ChatRoleID=0
	
	self.m_pMainFrame:moveToBack()
	print("exit FriendsDialog OnCreate")
end

------------------- private: -----------------------------------

function MiniFriendChatDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, MiniFriendChatDialog)

    return self
end

function MiniFriendChatDialog:SetChatRoleID(roleID)
  print("MiniFriendChatDialog:SetChatRoleID")
  self.m_ChatRoleID=roleID

end

function MiniFriendChatDialog:HandleClickRestorBtn(args)
  print("MiniFriendChatDialog:HandleClickRestorBtn")
  GetFriendsManager():SetChatRoleID(self.m_ChatRoleID,"")
  self:DestroyDialog()
	
  return true
end

function MiniFriendChatDialog.OnNewMsg()
  print("MiniFriendChatDialog:OnNewMsg")
  if not _instance then 
    return
  end
  local NewMsgNum=GetFriendsManager():GetRoleNotReadMsgNum(_instance.m_ChatRoleID)
  if NewMsgNum>0 then 
    
     _instance.m_Notify:setVisible(true)
     _instance.m_Notify:setText(tostring(NewMsgNum))
  else
     _instance.m_Notify:setVisible(false)
     _instance.m_Notify:setText(tostring(0))
  end

end

