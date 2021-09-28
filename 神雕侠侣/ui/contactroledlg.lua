require "protocoldef.knight.gsp.item.cgetotherroleinfo"
require "protocoldef.knight.gsp.friends.ccamppk"
require "protocoldef.knight.gsp.battle.csendinvitepk2"
require "protocoldef.knight.gsp.ranklist.cusexianhua"

ContactRoleDialog = {}
setmetatable(ContactRoleDialog, Dialog)
ContactRoleDialog.__index = ContactRoleDialog 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ContactRoleDialog.getInstance()
	print("enter ContactRoleDialog")
    if not _instance then
        _instance = ContactRoleDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ContactRoleDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = ContactRoleDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ContactRoleDialog.getInstanceNotCreate()
    return _instance
end

function ContactRoleDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function ContactRoleDialog.ToggleOpenClose()
	if not _instance then 
		_instance = ContactRoleDialog:new() 
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

function ContactRoleDialog.GetLayoutFileName()
    return "contactcharacter.layout"
end

function ContactRoleDialog:OnCreate()
	print("enter ContactRoleDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_Name=winMgr:getWindow("ContactCharacter/Name")
    self.m_ChatBtn=CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/Chat") )
    self.m_AddOrRemoveFriendBtn=CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/Friend") )
    self.m_TeamBtn=CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/Jointeam") )
    self.m_FactionInviteBtn=CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/FamilyInvite") )
    self.m_ViewBtn=CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/View") )
	self.m_RoleID = winMgr:getWindow("ContactCharacter/id")
	self.m_CampPK = winMgr:getWindow("ContactCharacter/camppk")
	self.m_pCampPic = winMgr:getWindow("ContactCharacter/camp")    
    
    self.m_btnSendFlower = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/flower"))
    self.m_btnSendFlower:subscribeEvent("Clicked", ContactRoleDialog.HandleClickSendFlowerBtn, self)

     self.m_ChatBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickChatBtn, self)
     self.m_AddOrRemoveFriendBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickAddOrRemoveFriendBtn, self)
     
     self.m_TeamBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickTeamBtn, self)
     self.m_FactionInviteBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickFactionInviteBtn, self)
     self.m_ViewBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickViewBtn, self)
     self.m_CampPK:subscribeEvent("Clicked", ContactRoleDialog.HandleCampPKBtn, self) 

     --xiaolong added for lei tai 
     self.m_pkBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/pk") )
     self.m_pkBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickPKBtn, self)

    --init settings
	self.m_CharacterRoleID=0
	self.m_CharacterName=""
	self.m_TeamState=-1
	
	print("exit FriendsDialog OnCreate")
end

------------------- private: -----------------------------------

function ContactRoleDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ContactRoleDialog)

    return self
end

function ContactRoleDialog:SetCharacter(roleID,roleName,roleLevel,roleCamp)
  print("ContactRoleDialog:SetCharacter")
  self.m_CharacterRoleID=roleID
  self.m_CharacterName=roleName
  self.m_CharacterLevel=roleLevel
  self.m_CharacterCamp=roleCamp
  
  self.m_Name:setText(roleName)
  if roleLevel == -1 then
	self.m_RoleID:setText(MHSD_UTILS.get_resstring(2846))
  else
  	self.m_RoleID:setText(tostring(roleLevel))
  end

  if roleCamp == 1 then
	self.m_pCampPic:setProperty("Image", "set:MainControl image:campred")
	self.m_pCampPic:setVisible(true)
  elseif roleCamp == 2 then
	self.m_pCampPic:setProperty("Image", "set:MainControl image:campblue")
	self.m_pCampPic:setVisible(true)
  else
	self.m_pCampPic:setVisible(false)
  end

  
  if GetFriendsManager():isMyFriend(roleID) then
      self.m_AddOrRemoveFriendBtn:setText(MHSD_UTILS.get_resstring(2741))
  else
      self.m_AddOrRemoveFriendBtn:setText(MHSD_UTILS.get_resstring(2742))
  end
  
  self.m_TeamState=-1
  
  local character=GetScene():FindCharacterByID(self.m_CharacterRoleID)
   if character then
      if(character:IsOnTeam()) then
         self.m_TeamState=1
         self.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2740))
      else
         self.m_TeamState=0
         self.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2738))
      end

	  if(character:IsInBattle()) then
	  	self.m_pkBtn:setText(MHSD_UTILS.get_resstring(2810));
	  else
	  	self.m_pkBtn:setText(MHSD_UTILS.get_resstring(2809));
	  end
  else
    
    if self.m_CharacterRoleID > 0 then
        GetNetConnection():send(knight.gsp.CReqRoleTeamState(self.m_CharacterRoleID))
    end
  
  end
  


end

function ContactRoleDialog.GlobalSetCharacter()
  print("ContactRoleDialog.GlobalSetCharacter")
  local dla = nil
  if GetDataManager():GetMainCharacterLevel() > 10 then
    dlg = ContactRoleDialog.getInstanceAndShow()
  else
    GetGameUIManager():AddMessageTipById(145677)
    return
  end
  if dlg then
     local roleID=GetFriendsManager():GetWantToContactRoleID()
     local roleName=GetFriendsManager():GetWantToContactRoleName()
	 local roleLevel=GetFriendsManager():GetWantToContactRoleLevel()
	 local roleCamp=GetFriendsManager():GetWantToContactRoleCamp()
     dlg:SetCharacter(roleID,roleName,roleLevel,roleCamp)
     dlg:ResetWndPositon()
  end
end
function ContactRoleDialog:ResetWndPositon()
   local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()

	local tw = self:GetWindow():getPixelSize().width
	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width

	local x = mousePos.x
	if mousePos.x + tw > pw then
	
		x = mousePos.x - tw
	end

	local th = self:GetWindow():getPixelSize().height
	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	local y = mousePos.y
	if(mousePos.y + th > ph) then
	
		y = mousePos.y - th
	end	
    
    if x < 0.0 then
        x = 0.0
    end
    
    if y < 0.0 then
        y = 0.0
    end

	self:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,x),CEGUI.UDim(0.0,y)))
end

function ContactRoleDialog:HandleClickSendFlowerBtn(args)
    LogInfo("____ContactRoleDialog:HandleClickSendFlowerBtn")
    
    if self.m_CharacterRoleID and self.m_CharacterRoleID > 0 then
        local useXianhuaAction = CUseXianhua.Create()
        useXianhuaAction.roleid = self.m_CharacterRoleID
        LuaProtocolManager.getInstance():send(useXianhuaAction)
    else
        print("____error no effective self.m_CharacterRoleID")
    end
end

function ContactRoleDialog:HandleClickChatBtn(args)
  print("ContactRoleDialog:HandleClickChatBtn")
  GetFriendsManager():SetChatRoleID(self.m_CharacterRoleID,"")
  self:DestroyDialog()
	
  return true
end

function ContactRoleDialog:HandleClickAddOrRemoveFriendBtn(args)
  print("ContactRoleDialog:HandleClickAddOrRemoveFriendBtn")
   if GetFriendsManager():isMyFriend(self.m_CharacterRoleID) then
      GetFriendsManager():RequestBreakFriendRelation(self.m_CharacterRoleID)
  else
      GetFriendsManager():RequestAddFriend(self.m_CharacterRoleID)
  end
  
  self:DestroyDialog()
	
  return true
end

function ContactRoleDialog:HandleClickTeamBtn(args)
  print("ContactRoleDialog:HandleClickTeamBtn")
--   local character=GetScene():FindCharacterByID(self.m_CharacterRoleID)
--   if character then
--      if(character:IsOnTeam()) then
--         GetTeamManager():RequestJoinOneTeam(self.m_CharacterRoleID)
--      else
--         GetTeamManager():RequestInviteToMyTeam(self.m_CharacterRoleID)
--      end
--  
--   end
     if self.m_TeamState==1 then
         
        if GetTeamManager():IsOnTeam() then
           GetGameUIManager():AddMessageTipById(140855)
        else
           GetTeamManager():RequestJoinOneTeam(self.m_CharacterRoleID)
        end 
     else 
        
         GetTeamManager():RequestInviteToMyTeam(self.m_CharacterRoleID)
     end
  self:DestroyDialog()
	
  return true
end

function ContactRoleDialog:HandleClickFactionInviteBtn(args)
  --[[
  GetGameUIManager():AddMessageTipById(144798)
  self:DestroyDialog()
	--]]
	if self.m_CharacterRoleID > 0 then
		local p = require "protocoldef.knight.gsp.faction.cfactioninvitation":new()
		p.guestroleid = self.m_CharacterRoleID
		require "manager.luaprotocolmanager":send(p)
	end
	  self:DestroyDialog()
  return true
end

function ContactRoleDialog:HandleClickViewBtn(args)
	 
	local getOtherRoleInfo = CGetOtherRoleInfo.Create()
	getOtherRoleInfo.roleid = self.m_CharacterRoleID
	LuaProtocolManager.getInstance():send(getOtherRoleInfo)

   self:DestroyDialog()
	
  return true
end

function ContactRoleDialog:HandleClickPKBtn(args)
  LogInfo("___ContactRoleDialog:HandleClickPKBtn")
  	local character=GetScene():FindCharacterByID(self.m_CharacterRoleID)
	if character then
		if character:IsInBattle() then
			local req = knight.gsp.battle.CSendWatchBattle(self.m_CharacterRoleID);
			GetNetConnection():send(req);
			return;
		end
	end
  
  local invitePKAction = CSendInvitePK2.Create()
  invitePKAction.guestroleid = self.m_CharacterRoleID
  LuaProtocolManager.getInstance():send(invitePKAction)

  self:DestroyDialog()

  return true
end

function ContactRoleDialog:HandleCampPKBtn(args)
	LogInfo("ContactRoleDialog handle camppk clicked")
	
	local campPK = CCampPK.Create()
	campPK.roleid = self.m_CharacterRoleID
	LuaProtocolManager.getInstance():send(campPK)

end


function ContactRoleDialog.GlobalOnLButtonClick()
 
   local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
	
  return true
end

function ContactRoleDialog.RefreshRoleTeamState(roleID,teamState)
   LogInfo("ContactRoleDialog.RefreshRoleTeamState")
   
   if _instance and roleID == _instance.m_CharacterRoleID then 
	  _instance.m_TeamState=teamState
          LogInfo("roleteamstate:"..tostring(teamState))	  
       if teamState==1 then
         
         _instance.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2740))
      else
        
         _instance.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2738))
      end
	end

end

