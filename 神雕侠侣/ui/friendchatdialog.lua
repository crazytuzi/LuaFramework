require "ui.dialog"
require "utils.mhsdutils"
require "ui.minifriendchatdialog"
--require "ui.friendsdialog"


FriendChatDialog = {}
setmetatable(FriendChatDialog, Dialog)
FriendChatDialog.__index = FriendChatDialog 

g_maxInputHisFriChatCt = 20
g_inputHisFriChatInfo = {}
local g_addFriendText

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FriendChatDialog.getInstance()
	print("enter getfriendchatdialoginstance")
    if not _instance then
        _instance = FriendChatDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FriendChatDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = FriendChatDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end

    return _instance
end

function FriendChatDialog.getInstanceNotCreate()
    return _instance
end

function FriendChatDialog.IsShow()
    --LogInfo("FriendChatDialog.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function FriendChatDialog.RefreshRoleDisplay(roleID)
    print("____FriendChatDialog.RefreshRoleDisplay")

    if not FriendChatDialog.IsShow() then
        return
    end
    
    if _instance.m_ChatRoleID == 0 or _instance.m_ChatRoleID ~= roleID then
       return
    end
    
    if not GetFriendsManager() then
        return
    end

    local roleInf=GetFriendsManager():GetContactRole(_instance.m_ChatRoleID)
    if roleInf.roleID==0 then
        return
    end
      
    local strHead=""
    if roleID==-1 then
        strHead=GetIconManager():GetImagePathByID(9034):c_str()
    else
        local npcTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(roleInf.shape)
        if npcTmp.id~=-1 then
            strHead=GetIconManager():GetImagePathByID(npcTmp.headID):c_str()
        end
    end
    _instance.RoleHeadWnd:setProperty("Image",strHead)
    _instance.m_RoleName=roleInf.name
    _instance.RoleNameWnd:setText(roleInf.name)
    
  	
    if roleID==-1 then
        _instance.m_AddFriendBtn:setVisible(false)
    else
        _instance.m_AddFriendBtn:setVisible(true)
        local isMyFriend=GetFriendsManager():isMyFriend(roleID)
	if isMyFriend then
	  	local character=GetScene():FindCharacterByID(roleID)
	    if character then
	      if(character:IsOnTeam()) then
	      	 _instance.m_TeamState=1
	         _instance.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2740))
	      else
	         _instance.m_TeamState=0
	         _instance.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2738))
	      end
	    else
            if roleID > 0 then
                GetNetConnection():send(knight.gsp.CReqRoleTeamState(roleID))
            end
	    end
	  end
    end

    local bOnline=GetFriendsManager():isFriendOnline(roleID)
    _instance.m_OnlineWnd:setVisible(not bOnline)
end

function FriendChatDialog.DestroyDialog()
	
    LogInfo("____FriendChatDialog.DestroyDialog")

    if _instance then

        --added by lvxiaolong for friend chat histroy records
        if _instance.m_InputBox ~= nil and _instance.m_ChatRoleID ~= 0 then
            local sendMsgContent = _instance.m_InputBox:GenerateParseText(false)
            FriendChatDialog.AddFriendChatInputHistroy(_instance.m_ChatRoleID, sendMsgContent)
		end

        _instance:OnClose()
		_instance = nil
	end
end

function FriendChatDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FriendChatDialog:new() 
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

function FriendChatDialog.GetLayoutFileName()
    return "friendchatdialo.layout"
end

function FriendChatDialog:OnCreate()
	print("enter FriendChatDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.RoleHeadWnd = winMgr:getWindow("friendchatdialo/icon")
	
	self.RoleNameWnd=winMgr:getWindow("friendchatdialo/name")
    

    self.m_AddFriendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("friendchatdialo/back/get") )
	
	self.m_ChatRecordBox=CEGUI.Window.toRichEditbox(winMgr:getWindow("friendchatdialo/RichEditBox") )
    self.m_ChatRecordBox:setReadOnly(true)
    
    self.m_InputBox=CEGUI.Window.toRichEditbox(winMgr:getWindow("friendchatdialo/back/chat/input") )
     self.m_InputBox:setMaxTextLength(70)
    
    self.m_MiniBtn=CEGUI.Window.toPushButton(winMgr:getWindow("friendchatdialo/back/back") )
    self.m_InsertBtn=CEGUI.Window.toPushButton(winMgr:getWindow("friendchatdialo/back/chat/emotebtn") )
    self.m_SendBtn=CEGUI.Window.toPushButton(winMgr:getWindow("friendchatdialo/back/chat/sendbtn") )
    self.m_OnlineWnd=CEGUI.Window.toPushButton(winMgr:getWindow("friendchatdialo/back/out") )
    self.m_OnlineWnd:setVisible(false)

	self.m_DeleteBtn = CEGUI.Window.toPushButton(winMgr:getWindow("friendchatdialo/back/delete"))
	if Config.MOBILE_ANDROID == 0 then
		self.m_DeleteBtn:setVisible(false)
	end
	g_addFriendText = self.m_AddFriendBtn:getText()
    -- subscribe event
    self.m_AddFriendBtn:subscribeEvent("Clicked", FriendChatDialog.HandleClickAddFriend, self)
    self.m_MiniBtn:subscribeEvent("Clicked", FriendChatDialog.HandleClickMiniBtn, self) 
    self.m_InsertBtn:subscribeEvent("Clicked", FriendChatDialog.HandleClickInsertBtn, self) 
    self.m_SendBtn:subscribeEvent("Clicked", FriendChatDialog.HandleClickSendBtn, self)
    self.m_InputBox:subscribeEvent("EditboxFullEvent", FriendChatDialog.OnIputTextFull, self)  
	self.m_DeleteBtn:subscribeEvent("Clicked", FriendChatDialog.HandleDeleteClicked, self)
    
  
    --init settings
	self.m_ChatRoleID=0
	
	print("exit FriendsDialog OnCreate")
end

------------------- private: -----------------------------------

function FriendChatDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FriendChatDialog)

    return self
end

function FriendChatDialog:HandleClickAddFriend(args)
--  print("FriendChatDialog:HandleClickAddFriend")
  if self.m_TeamState then
  	if self.m_TeamState==1 then
        if GetTeamManager():IsOnTeam() then
           GetGameUIManager():AddMessageTipById(140855)
        else
           GetTeamManager():RequestJoinOneTeam(self.m_ChatRoleID)
        end 
     else 
        
         GetTeamManager():RequestInviteToMyTeam(self.m_ChatRoleID)
     end
  else
  	GetFriendsManager():RequestAddFriend(self.m_ChatRoleID)
  end	
  return true
end

function FriendChatDialog:HandleClickMiniBtn(args)
  print("FriendChatDialog:HandleClickMiniBtn")
  
	local minichatdlg=MiniFriendChatDialog.getInstanceAndShow()
	if minichatdlg then
	   minichatdlg:SetChatRoleID(self.m_ChatRoleID)
	   self.DestroyDialog()
	end
  return true
end

function FriendChatDialog:HandleClickInsertBtn(args)
  print("FriendChatDialog:HandleClickInsertBtn")
  CInsetdialogDlg:GetSingletonDialogAndShowIt()
  
	
  return true
end

function FriendChatDialog.PushGivenRoleChatHisToTail(roleID)
    
    if not g_inputHisFriChatInfo[roleID] then
        return
    end

    local oldIndexGivenRole = g_inputHisFriChatInfo[roleID].index

    if oldIndexGivenRole < 1 or oldIndexGivenRole >= g_maxInputHisFriChatCt then
        return
    end
    
    local curMaxIndex = 0
    for k,v in pairs(g_inputHisFriChatInfo) do
        
        if v.index > curMaxIndex then
            curMaxIndex = v.index
        end

        if v.index > oldIndexGivenRole then
            g_inputHisFriChatInfo[k].index = v.index - 1
        end

    end
    
    if curMaxIndex >= 1 then
        g_inputHisFriChatInfo[roleID].index = curMaxIndex
    end
end

function FriendChatDialog.DeleteGivenRoleChatHis(roleID)
    
    if not g_inputHisFriChatInfo[roleID] then
        return
    end
    
    local givenRoleIndex = g_inputHisFriChatInfo[roleID].index
    g_inputHisFriChatInfo[roleID] = nil

    if givenRoleIndex >= g_maxInputHisFriChatCt then
       return 
    end

    for k,v in pairs(g_inputHisFriChatInfo) do
        if v.index > givenRoleIndex then
            g_inputHisFriChatInfo[k].index = v.index-1
        end
    end
end

function FriendChatDialog.AddFriendChatInputHistroy(roleID, strMsg)
    
    LogInfo("____FriendChatDialog.AddFriendChatInputHistroy")
    LogInfo("____roleID: " .. roleID)

    if roleID == 0 then
        return
    end
    
    local curNum = 0
    local firstHisRoldID = 0
    local maxIndex = 0
    for k,v in pairs(g_inputHisFriChatInfo) do
        curNum = curNum + 1
        
        if v.index > maxIndex then
            maxIndex = v.index
        end

        if v.index == 1 then
            firstHisRoldID = k
        end
    end
    
    print("______curNum: " .. curNum)

    if curNum >= g_maxInputHisFriChatCt then
        if g_inputHisFriChatInfo[roleID] ~= nil then
            if strMsg ~= "" then
                g_inputHisFriChatInfo[roleID].msg = strMsg
                FriendChatDialog.PushGivenRoleChatHisToTail(roleID)
            else
                FriendChatDialog.DeleteGivenRoleChatHis(roleID)
            end
        else
            if firstHisRoldID ~= 0 and g_inputHisFriChatInfo[firstHisRoldID] ~= nil then
                if strMsg ~= "" then
                    g_inputHisFriChatInfo[firstHisRoldID] = nil
                    g_inputHisFriChatInfo[roleID] = {msg = strMsg, index = 1}
                    FriendChatDialog.PushGivenRoleChatHisToTail(roleID)
                end
            end
        end
    elseif g_inputHisFriChatInfo[roleID] ~= nil then
        if strMsg ~= "" then
            g_inputHisFriChatInfo[roleID].msg = strMsg
            FriendChatDialog.PushGivenRoleChatHisToTail(roleID)
        else
            FriendChatDialog.DeleteGivenRoleChatHis(roleID)
        end
    else
        if strMsg ~= "" then
            g_inputHisFriChatInfo[roleID] = {msg = strMsg, index = maxIndex+1}
        end
    end
    
end

function FriendChatDialog:HandleClickSendBtn(args)
  print("FriendChatDialog:HandleClickSendBtn")
  local sendMsgContent=self.m_InputBox:GenerateParseText(false)
  print("friendchat send content:"..sendMsgContent)
  
  if sendMsgContent=="" then
     GetGameUIManager():AddMessageTip(MHSD_UTILS.get_resstring(1446))
     return true
  end
  
  local sendPureMsg=self.m_InputBox:GetPureText()
 
  local sendRoleID=self.m_ChatRoleID
  if BanListManager.getInstance():IsInBanList(sendRoleID) then  
     GetGameUIManager():AddMessageTipById(145665)
     return true
  end

  if sendRoleID>0 then
     GetFriendsManager():SendMessageToRole(self.m_ChatRoleID,sendMsgContent,sendPureMsg)
  end
    
  GetFriendsManager():AddChatReocord(0,self.m_ChatRoleID,"","",sendMsgContent)
  if sendRoleID==-1 then
     local strName=MHSD_UTILS.get_resstring(2773)
     local randIdx=math.random(0,2)
     local strRespone =MHSD_UTILS.get_msgtipstring(142020+randIdx)  
     GetFriendsManager():AddChatReocord(self.m_ChatRoleID,self.m_ChatRoleID,strName,"",strRespone)
  end
  GetFriendsManager():AddLastChat(self.m_ChatRoleID)
  if GetChatManager() then
    GetChatManager():AddToChatHistory(sendMsgContent)
  end
  self:RefreshChatRecord(self.m_ChatRoleID)
  
  self.m_InputBox:Clear()
  self.m_InputBox:Refresh()
	
  return true
end

function FriendChatDialog.GlobalSetChatRole()
  local chatdlg=FriendChatDialog.getInstanceAndShow()
  local roleID=GetFriendsManager():GetWantToChatRoleID()
  if roleID~=0 then
     chatdlg:SetChatRole(roleID,"")
  end
end

function FriendChatDialog.RefreshRoleTeamState(roleID,teamState)
   LogInfo("FriendChatDialog.RefreshRoleTeamState")
   
   if _instance and roleID == _instance.m_ChatRoleID then 
	  _instance.m_TeamState=teamState
          LogInfo("roleteamstate:"..tostring(teamState))	
       local isMyFriend=GetFriendsManager():isMyFriend(roleID)
	   if isMyFriend then  
	       if teamState==1 then
	         _instance.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2740))
	      else
	         _instance.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2738))
	      end
		else
			_instance.m_AddFriendBtn:setText(g_addFriendText)
	  		_instance.m_TeamState=nil
  		end
	end

end

function FriendChatDialog:SetChatRole(roleID,roleName)
  print("_____FriendChatDialog:SetChatRole: " .. roleID)
  
  local roleInf=GetFriendsManager():GetContactRole(roleID)
  if roleInf.roleID==0 then
     self:OnClose()
     return
  end
  
  self.m_ChatRoleID=roleID
  self.m_RoleName=roleInf.name
  self.RoleNameWnd:setText(roleInf.name)
  
  
  GetFriendsManager():PopRoleMsg(roleID)
  
  local strHead=""
  if roleID==-1 then
     strHead=GetIconManager():GetImagePathByID(9034):c_str()
  else

    local npcTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(roleInf.shape)
    if npcTmp.id~=-1 then
       strHead=GetIconManager():GetImagePathByID(npcTmp.headID):c_str()
    end
  end
  self.RoleHeadWnd:setProperty("Image",strHead)
 
  
 
  
  
  if roleID==-1 then
     self.m_AddFriendBtn:setVisible(false)
  else
     self.m_AddFriendBtn:setVisible(true)
	      local isMyFriend=GetFriendsManager():isMyFriend(roleID)
	  if isMyFriend then
	  	local character=GetScene():FindCharacterByID(roleID)
	    if character then
	      if(character:IsOnTeam()) then
	      	 self.m_TeamState=1
	         self.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2740))
	      else
	         self.m_TeamState=0
	         self.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2738))
	      end
	    else
            if roleID > 0 then
                GetNetConnection():send(knight.gsp.CReqRoleTeamState(roleID))
            end
	    end
	  else
	  	self.m_AddFriendBtn:setText(g_addFriendText)
	  	self.m_TeamState=nil
	  end
  end

  local bOnline=GetFriendsManager():isFriendOnline(roleID)
  self.m_OnlineWnd:setVisible(not bOnline)
 
  self:RefreshChatRecord(roleID)
  
  FriendsDialog.GlobalRefreshRoleCellNotify(roleID)
  FriendsDialog.GlobalRefreshLabelNotify()
  FriendEntranceDialog.RefreshNotify()

  local _ins = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
  if _ins ~= nil then
    _ins.RefreshNotify()
  end

  --when friendchat dialog opened and is set for chatrole, we need to init the input box
  --with the role chat histroy
  self.m_InputBox:Clear()
  local chatHis = g_inputHisFriChatInfo[self.m_ChatRoleID]
  if chatHis ~= nil and chatHis.msg ~= nil then
    self.m_InputBox:AppendParseText(CEGUI.String(chatHis.msg), false)
  end
  self.m_InputBox:Refresh()
  self.m_InputBox:SetCaratEnd()

  return
end

function FriendChatDialog:RefreshChatRecord(roleID)
  print("FriendChatDialog:RefreshChatRecord")
  
  local roleInf=GetFriendsManager():GetContactRole(roleID)
--  if roleInf.roleID<=0 then
--     return
--  end
 self.m_ChatRecordBox:Clear()
 local chatRecordNum=roleInf:GetChatRecrodNum()
 print("chatRecordNum:"..tonumber(chatRecordNum))
 if chatRecordNum>0 then
    
    for i=0,chatRecordNum-1,1 do
        
        
        local chatUnit=roleInf:GetChatRecordByIndex(i)
        
        local strTitle="["..chatUnit.name.."]"..chatUnit.time
        local textColour=CEGUI.PropertyHelper:stringToColourRect("FFF9c96D")
        local BorderColour=CEGUI.PropertyHelper:stringToColour("FF220B01")
        self.m_ChatRecordBox:AppendText(CEGUI.String(strTitle),textColour,true,BorderColour)
        self.m_ChatRecordBox:AppendBreak()
        self.m_ChatRecordBox:AppendParseText(CEGUI.String(chatUnit.chatContent), chatUnit.roleid ~= -1)
         self.m_ChatRecordBox:AppendBreak()
        
         
        
    end
 end
 self.m_ChatRecordBox:Refresh()

end


function FriendChatDialog.OnNewMsg()
  print("FriendChatDialog:OnNewMsg")
  if not _instance then 
    return
  end
  local hasNewMsg=GetFriendsManager():RoleHasNotReadMsg(_instance.m_ChatRoleID)
  if hasNewMsg then 
     GetFriendsManager():PopRoleMsg(_instance.m_ChatRoleID)
     _instance:RefreshChatRecord(_instance.m_ChatRoleID)
  end

end

function FriendChatDialog:OnIputTextFull(args)
  print("FriendChatDialog:OnIputTextFull")
  GetGameUIManager():AddMessageTip(MHSD_UTILS.get_resstring(2423))

  return true
end

function FriendChatDialog.HandleDeleteClicked(args)
	LogInfo("FriendChatDialog handle delete clicked")
	GetGameUIManager():OnBackSpace()
	return true
end

return FriendChatDialog
