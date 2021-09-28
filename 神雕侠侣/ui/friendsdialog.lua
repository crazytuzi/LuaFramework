require "ui.dialog"
require "ui.friendchatdialog"
require "ui.contactroledlg"
require "utils.mhsdutils"
require "ui.searchfrienddlg"
require "ui.searchbanfrienddlg"
require "ui.newswarndlg"
--require "ui.minifriendchatdialog"
require "utils.bit"

FriendsDialog = {
  m_vFriendDataList = {};
  m_vCellIndexList = {};
  m_vCellList = {};

  m_vEnemyList = {}
}

local ZHUIZONGDIE_ID = 39846

setmetatable(FriendsDialog, Dialog)
FriendsDialog.__index = FriendsDialog 
local function getLabel()
	return require "ui.label".getLabelById("jianghu")
end
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FriendsDialog.getInstance()
	print("enter getfriendsdialoginstance")
    if not _instance then
        _instance = FriendsDialog:new()
        _instance:OnCreate()
    end
    if not getLabel() then
		  LabelDlg.InitJianghu()
	  end

    return _instance
end

function FriendsDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = FriendsDialog:new()
        _instance:OnCreate()
    else
  		print("set visible")
  		_instance:SetVisible(true)
  		_instance.m_pMainFrame:setAlpha(1)
    end
    
    if not getLabel() then
		  LabelDlg.InitJianghu()
    end

    return _instance
end

function FriendsDialog.getInstanceNotCreate()
    return _instance
end

function FriendsDialog:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function FriendsDialog.DestroyDialog()
	if _instance then 
		local dlg = LabelDlg.getLabelById("jianghu")
		if dlg then
			dlg:OnClose()
		end
		
		if _instance then
		  _instance:OnClose()
		end
	end
end

function FriendsDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FriendsDialog:new() 
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

function FriendsDialog.GetLayoutFileName()
    return "frienddialog.layout"
end

function FriendsDialog:OnCreate()
	print("enter FriendsDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_FriendsGroupBtn = 
		CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/right/back/part1") )
	self.m_FriendsGroupBtn:setID(1)
		
    self.m_FriendsNotify=winMgr:getWindow("Frienddialog/right/back/part1/mark1")
    self.m_FriendsNotify:setVisible(false)

    self.m_RecentCGroupBtn = 
		CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/right/back/part2") )
	self.m_RecentCGroupBtn:setID(2)
   self.m_RecentChatNotify=winMgr:getWindow("Frienddialog/right/back/part2/mark2")
   self.m_RecentChatNotify:setVisible(false)
    self.m_ContactRoleList = 
		CEGUI.Window.toScrollablePane(winMgr:getWindow("Frienddialog/right/back/main") )
   
	self.m_btnYaoQing = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/invitefriend"))
	self.m_btnYaoQing:subscribeEvent("Clicked", FriendsDialog.HandleClickYaoQingBtn, self)
   
    self.m_btnNewsWarn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/info"))
	self.m_btnNewsWarn:subscribeEvent("Clicked", FriendsDialog.HandleClickNewsWarnBtn, self)

	self.m_btnSearch = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/searchfriend"))
	self.m_btnSearch:subscribeEvent("Clicked", FriendsDialog.HandleSearchBtn, self)

    -- subscribe event
    self.m_FriendsGroupBtn:subscribeEvent("SelectStateChanged", 
			FriendsDialog.HandleGroupSelectChange, self) 
    
    self.m_RecentCGroupBtn:subscribeEvent("SelectStateChanged",
			FriendsDialog.HandleGroupSelectChange, self) 

    self.m_ContactRoleList:subscribeEvent("NextPage", FriendsDialog.HandleListNextPage, self)
	
	  -- add for ban list
    self.m_BanListButton = CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/right/back/part3"))
    self.m_BanListButton:setID(3)
    self.m_BanListButton:subscribeEvent("SelectStateChanged", FriendsDialog.HandleGroupSelectChange, self) 

    -- add for enemy list
    self.m_EnemyListButton = CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/right/back/part4"))
    self.m_EnemyListButton:setID(4)
    self.m_EnemyListButton:subscribeEvent("SelectStateChanged", FriendsDialog.HandleGroupSelectChange, self) 
    --init settings
  FriendsDialog.m_vFriendDataList = {}
  FriendsDialog.m_vCellIndexList = {}
  FriendsDialog.m_vCellList = {}
	self.m_FriendsGroupBtn:setSelected(true)
	self:RefreshLabelNotify()
  self:RequireEnemyList()
	
	print("exit FriendsDialog OnCreate")
end

------------------- private: -----------------------------------

function FriendsDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FriendsDialog)

    return self
end

function FriendsDialog.GlobalRefreshLastChatList()
   if _instance then
      _instance:RefreshRoleList(2)
   end
end

function FriendsDialog.GlobalRefreshFriendsList()
   if _instance then
      _instance:RefreshRoleList(1)
   end
   local dlg = require "ui.friendchatdialog".getInstanceNotCreate()
	if dlg then
		dlg.RefreshRoleDisplay(dlg.m_ChatRoleID)
	end
end

function FriendsDialog.GlobalOnNewMsg()
   FriendChatDialog.OnNewMsg()
   MiniFriendChatDialog.OnNewMsg()
   FriendEntranceDialog.RefreshNotify()
   
  local _ins = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
  if _ins ~= nil then
    _ins.RefreshNotify()
  end
  
   if _instance then
      _instance:RefreshLabelNotify()
      local roleID=GetFriendsManager():GetLastMsgRoleID()
      if roleID>0 then
         _instance:RefreshRoleCellNotify(roleID)
      end
      
   end
end

----/////////////////////////////////////////------
--

local displaySize = 8

function FriendsDialog:HandleClickNewsWarnBtn(args)
    LogInfo("____FriendsDialog:HandleClickNewsWarnBtn")
    
    NewsWarnDlg.getInstanceAndShow()

    return true
end

function FriendsDialog:HandleSearchBtn(args)
	LogInfo("_____FriendsDialog:HandleSearchBtn")
	SearchFriendDlg.getInstanceAndShow()
end

function FriendsDialog:HandleClickYaoQingBtn(args)
	LogInfo("____FriendsDialog:HandleClickYaoQingBtn")
	require "protocoldef.knight.gsp.friends.cinvitemainview"
	local m = CInviteMainView.Create()
	LuaProtocolManager.getInstance():send(m)
	--[[
	require "ui.yaoqing.friendyaoqingdlg"
--	FriendYaoQingDlg.getInstanceAndShow()
	local a = {}
	a[1] = 0
	a[5] = 2
	a[4] = 1
	local b = {}
	b[1] = {roleName = "hahaha", level = 12}
	b[2] = {roleName = "hehe", level = 20}
	b[3] = {roleName = "jiuming", level = 13}
	FriendYaoQingDlg.getInstanceAndShow():setInfo(123, b, 38627, a)
	]]
	return true
end

function FriendsDialog:HandleGroupSelectChange(args)
   print("FriendsDialog:HandleGroupSelectChange") 
  displaySize = 8
  self.m_ContactRoleList:cleanupNonAutoChildren()
  FriendsDialog.m_vFriendDataList = {}
  FriendsDialog.m_vCellIndexList = {}
  FriendsDialog.m_vCellList = {}
  self:RefreshRoleList(0)
   return true
end

--old implementation and not used

-- function FriendsDialog:RefreshRoleList(type)
--   print("begin RefreshRoleList") 
--   self.m_ContactRoleList:cleanupNonAutoChildren()
  
--   if type==0 then
--     local selectedgbtn = self.m_FriendsGroupBtn:getSelectedButtonInGroup()
-- 	if not selectedgbtn then 
-- 	  return 
--     end
-- 	local id=selectedgbtn:getID();
-- 	type=id
--   end
	

--   --For ban list, the cell is different
--   if type == 3 then
--     self:RefreshBanListView()
--     return
--   end
	 
--   local friendNum=0
--   if(type==1) then
--      friendNum=GetFriendsManager():GetCurFriendNum()
--   elseif type==2 then
--       friendNum=GetFriendsManager():GetRecentChatListNum()
--   end 
  
--   print("friendNum:"..tostring(friendNum))
--   if(friendNum==0) then
--     return
--   end
--   for i=0,friendNum-1,1 do
--       local roleID=0
--       if(type==1) then
--           roleID=GetFriendsManager():GetFriendRoleIDByIdx(i)
--       elseif type==2 then
--           roleID=GetFriendsManager():GetRecentChatRoleIDByIdx(friendNum-i-1)
--       end 
      
--       print("friendID"..tostring(roleID))
--       if roleID~=0  then
--          local roleinf=GetFriendsManager():GetContactRole(roleID)
--          print("friendInfID:"..tostring( roleinf.roleID))
--          if  roleinf.roleID~=0  then
--             local shape=roleinf.shape
--             local name=roleinf.name
--             local level=roleinf.rolelevel
--             local school=roleinf.school
-- 			local camp=roleinf.camp
--             local winMgr=CEGUI.WindowManager:getSingleton()
--             local namePrefix=tostring(roleID)
--             local rootWnd=winMgr:loadWindowLayout("friendcell.layout",namePrefix)
--             print(namePrefix)
--             if rootWnd then
--                self.m_ContactRoleList:addChildWindow(rootWnd)
--                print("add childWindow")
--                local height=rootWnd:getPixelSize().height
--                print("height:"..tostring(height))
--                local yPos=1.0+(height+5.0)*i
--                local xPos=1.0
               
--                rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
               
--                local RoleCellBtn=CEGUI.Window.toPushButton(rootWnd)
--                local strRoleID=tostring(roleID)
--                if RoleCellBtn then
--                   RoleCellBtn:subscribeEvent("Clicked", FriendsDialog.HandleClickRoleCell, self)
                  
--                   RoleCellBtn:setUserString("id",strRoleID)
--                end
               
--                local headWndName=namePrefix.."friendcell/icon"
--                local headWnd=winMgr:getWindow(headWndName)
--                local strHead=""
--                if roleID==-1 then
--                   strHead=GetIconManager():GetImagePathByID(9034):c_str()
--                else
--                    strHead=GetFriendsManager():GetContactRoleIcon(roleID )
--                end
--                headWnd:setProperty("Image",strHead)
               
--                local nameWndName=namePrefix.."friendcell/name"
--                local nameWnd=winMgr:getWindow(nameWndName)
--                nameWnd:setText(name)
                
--                local levelWndName=namePrefix.."friendcell/level"
--                local levelWnd=winMgr:getWindow(levelWndName)
               
--                if roleID == -1 then
--                     local strLevel = "89" .. MHSD_UTILS.get_resstring(2397)
--                     local instaStringRes = knight.gsp.message.GetCStringResTableInstance()
--                     if instaStringRes and instaStringRes:getRecorder(2926) then
--                         strLevel = instaStringRes:getRecorder(2926).msg
--                     end
--                     levelWnd:setText(strLevel)
--                else
--                     levelWnd:setText(tostring(level) .. MHSD_UTILS.get_resstring(2397))
--                end
               
--                local schoolName=""
--                if roleID==-1 then
--                   schoolName=MHSD_UTILS.get_resstring(2774)
--                else
--                   schoolName= knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(school).name
--                end
--                local schoolWndName=namePrefix.."friendcell/level1"
--                local schoolWnd=winMgr:getWindow(schoolWndName)
--                schoolWnd:setText(schoolName)
               
--                local moreBtnName=namePrefix.."friendcell/more"
--                local moreBtn=CEGUI.Window.toPushButton(winMgr:getWindow(moreBtnName))
--                moreBtn:setUserString("id",strRoleID)
               
--                moreBtn:subscribeEvent("Clicked", FriendsDialog.HandleClickMore, self) 
--                if roleID==-1 then
--                   moreBtn:setVisible(false)
--                end

--                local notifyWndName=namePrefix.."friendcell/mark"
--                local notifyWnd=winMgr:getWindow(notifyWndName)
--                local bHasNotReadMsg=GetFriendsManager():RoleHasNotReadMsg(roleID)
--                notifyWnd:setVisible(bHasNotReadMsg)
--                local num=GetFriendsManager():GetRoleNotReadMsgNum(roleID)
--                notifyWnd:setText(tostring(num))
               
--                local onlineWndName=namePrefix.."friendcell/out"
--                local onlineWnd=winMgr:getWindow(onlineWndName)
--                local bOnline=false
--                if(roleinf.isOnline>0) then
--                    bOnline=true;
--                end
--                onlineWnd:setVisible(not bOnline)

-- 				local campWndName=namePrefix.."friendcell/camp"
-- 				local campWnd=winMgr:getWindow(campWndName)
				
-- 				if camp == 1 then
-- 					campWnd:setVisible(true)
-- 					campWnd:setProperty("Image", "set:MainControl image:campred")	
-- 				elseif camp == 2 then
-- 					campWnd:setVisible(true)
-- 					campWnd:setProperty("Image", "set:MainControl image:campblue")	
-- 				else
-- 					campWnd:setVisible(false)
-- 				end
			
--             end
--          end
--       end
--   end	
-- end

function FriendsDialog:HandleClickMore(args)
  print("FriendsDialog:HandleClickMore")
  
  local e = CEGUI.toWindowEventArgs(args)
  
  local strRoleId = e.window:getUserString("id")
  
  if not strRoleId then
     return true
  end
  
  local roleID=tonumber(strRoleId)
  if roleID<=0 then 
     return true
  end
  
  GetFriendsManager():SetContactRole(roleID,"")
  return true
end



function FriendsDialog:HandleClickRoleCell(args)
  print("FriendsDialog:HandleClickRoleCell")
  e = CEGUI.toWindowEventArgs(args)
  
  local strRoleId = e.window:getUserString("id")
  
  if not strRoleId then
     return true
  end
  
  local roleID=tonumber(strRoleId)
  if roleID==0 then 
     return true
  end
  
  local chatdlg=FriendChatDialog.getInstanceAndShow()
  chatdlg:SetChatRole(roleID,"")
	
  return true
end

function FriendsDialog.GlobalRefreshLabelNotify()
   if _instance then
     _instance:RefreshLabelNotify()
   end
end

function FriendsDialog.GlobalRefreshRoleCellNotify(roleID)
   if _instance then
     _instance:RefreshRoleCellNotify(roleID)
   end
end

function FriendsDialog:RefreshRoleCellNotify(roleID)
    local winMgr=CEGUI.WindowManager:getSingleton()
    local hasNotReadMsg=GetFriendsManager():RoleHasNotReadMsg(roleID)
    local index = 1
    local notifyWnd = nil
    for i = 1, #FriendsDialog.m_vCellIndexList, 1 do
        if FriendsDialog.m_vCellIndexList[index] ~= nil then
            if FriendsDialog.m_vCellIndexList[index].roleid == roleID then
                notifyWnd = winMgr:getWindow(tostring(index) .. "friendcell/mark")
                break
            end
        end
        index = index+1
    end

    if notifyWnd ~= nil then
        notifyWnd:setVisible(hasNotReadMsg)
        notifyWnd:setText(tostring(GetFriendsManager():GetRoleNotReadMsgNum(roleID)))
    end
end

function FriendsDialog:RefreshLabelNotify()
  print("FriendsDialog:RefreshLabelNotify")
  local hasFriendMsg=false
  local hasRecentChatMsg=false
  local friendNum=0
  
  
  
  friendNum=GetFriendsManager():GetCurFriendNum()
  local friendNotReadMsgNum=0
  local recentChatNotReadMsgNum=0
  for i=0,friendNum-1,1 do
      local roleID=0
      roleID=GetFriendsManager():GetFriendRoleIDByIdx(i)
      if GetFriendsManager():RoleHasNotReadMsg(roleID) then
         hasFriendMsg=true
         friendNotReadMsgNum=friendNotReadMsgNum+GetFriendsManager():GetRoleNotReadMsgNum(roleID)
      end
     
  end 
  
  friendNum=GetFriendsManager():GetRecentChatListNum()
  for i=0,friendNum-1,1 do
      local roleID=0
      roleID=GetFriendsManager():GetRecentChatRoleIDByIdx(i)
      if GetFriendsManager():RoleHasNotReadMsg(roleID)  then
         hasRecentChatMsg=true
         recentChatNotReadMsgNum=recentChatNotReadMsgNum+GetFriendsManager():GetRoleNotReadMsgNum(roleID)
      end
     
  end
  
  self.m_FriendsNotify:setVisible(hasFriendMsg)
  self.m_FriendsNotify:setText(tostring(friendNotReadMsgNum))
  
  self.m_RecentChatNotify:setVisible(hasRecentChatMsg)
  self.m_RecentChatNotify:setText(tostring(recentChatNotReadMsgNum))
   
  
end

--new implementation of RefreshRoleList

function FriendsDialog:RefreshRoleList(type)
  
    if type == 0 then
        local selectedgbtn = self.m_FriendsGroupBtn:getSelectedButtonInGroup()
        if not selectedgbtn then
            return 
        end
        local id = selectedgbtn:getID();
        type = id
    end

    --For ban list, the cell is different
    if type == 3 then
        self:RefreshBanListView()
        return
    end
   
    local index = nil
    local size = 0

    --For enemy list, the cell is different
    if type == 4 then
        self:RefreshEnemyListView()
        return
    end
   
    local index = nil
    local size = 0

    index = 1
    if type == 1 then
        size = GetFriendsManager():GetCurFriendNum()
        FriendsDialog.m_vFriendDataList = {}
        for i = 1, size, 1 do
            FriendsDialog.m_vFriendDataList[index] = GetFriendsManager():GetFriendRoleIDByIdx(i-1)
            index = index + 1
        end
    end

    index = 1
    if type == 2 then
        size = GetFriendsManager():GetRecentChatListNum()
        FriendsDialog.m_vFriendDataList = {}
        for i = 1, size, 1 do
            FriendsDialog.m_vFriendDataList[index] = GetFriendsManager():GetRecentChatRoleIDByIdx(size-index)
            index = index + 1
        end
    end

    if displaySize < 8 then
        displaySize = 8
    end

    if displaySize>size or type==2 then
        displaySize = size
    end

    index = 1
    for i = 1, displaySize, 1 do
        m_vCellIndexList = {}
        FriendsDialog.m_vCellIndexList[index] =  GetFriendsManager():GetContactRole(FriendsDialog.m_vFriendDataList[index])
        FriendsDialog.m_vCellIndexList[index].roleid = FriendsDialog.m_vFriendDataList[index]
        index = index + 1
    end

    index = 1
    for i = 1, displaySize do
        local roleid = FriendsDialog.m_vCellIndexList[index].roleid
        local name = FriendsDialog.m_vCellIndexList[index].name
        local level = FriendsDialog.m_vCellIndexList[index].rolelevel
        local school = FriendsDialog.m_vCellIndexList[index].school
        local isOnline = FriendsDialog.m_vCellIndexList[index].isOnline
        local camp = FriendsDialog.m_vCellIndexList[index].camp
        local relation = FriendsDialog.m_vCellIndexList[index].relation

        local namePrefix = tostring(index)
        local winMgr = CEGUI.WindowManager:getSingleton()
        local curCell = FriendsDialog.m_vCellList[index]
        if curCell == nil then
            curCell = winMgr:loadWindowLayout("friendcell.layout", namePrefix)
            self.m_ContactRoleList:addChildWindow(curCell)
            FriendsDialog.m_vCellList[index] = curCell
            local height = curCell:getPixelSize().height
            local yPos = 1.0+(height+5.0)*(index-1)
            local xPos = 1.0
            curCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
            winMgr:getWindow(namePrefix.."friendcell/jiehun"):setVisible(false)
            winMgr:getWindow(namePrefix.."friendcell/jiebai"):setVisible(false)
            winMgr:getWindow(namePrefix.."friendcell/shitu"):setVisible(false)
        end
               
        local RoleCellBtn = CEGUI.Window.toPushButton(curCell)
        local strRoleID = tostring(roleid)
        if RoleCellBtn then
            RoleCellBtn:subscribeEvent("Clicked", FriendsDialog.HandleClickRoleCell, self)
            RoleCellBtn:setUserString("id",strRoleID)
        end
               
        local headWndName = namePrefix.."friendcell/icon"
        local headWnd = winMgr:getWindow(headWndName)

        local strHead = ""
        if roleid == -1 then
            strHead = GetIconManager():GetImagePathByID(9034):c_str()
        else
            strHead = GetFriendsManager():GetContactRoleIcon(roleid)
        end
        headWnd:setProperty("Image",strHead)
               
        local nameWndName=namePrefix.."friendcell/name"
        local nameWnd=winMgr:getWindow(nameWndName)
        nameWnd:setText(name)
                
        local levelWndName=namePrefix.."friendcell/level"
        local levelWnd=winMgr:getWindow(levelWndName)
               
        if roleid == -1 then
            local strLevel = "89" .. MHSD_UTILS.get_resstring(2397)
            local instaStringRes = knight.gsp.message.GetCStringResTableInstance()
            if instaStringRes and instaStringRes:getRecorder(2926) then
                strLevel = instaStringRes:getRecorder(2926).msg
            end
            levelWnd:setText(strLevel)
        else
            levelWnd:setText(tostring(level) .. MHSD_UTILS.get_resstring(2397))
        end
               
        local schoolName = ""
        if roleid == -1 then
            schoolName = MHSD_UTILS.get_resstring(2774)
        else
            schoolName = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(school).name
        end
        local schoolWndName = namePrefix.."friendcell/level1"
        local schoolWnd = winMgr:getWindow(schoolWndName)
        schoolWnd:setText(schoolName)
               
        local moreBtnName = namePrefix.."friendcell/more"
        local moreBtn = CEGUI.Window.toPushButton(winMgr:getWindow(moreBtnName))
        moreBtn:setUserString("id",strRoleID)               
        moreBtn:subscribeEvent("Clicked", FriendsDialog.HandleClickMore, self) 
        if roleid == -1 then
            moreBtn:setVisible(false)
        end

        local notifyWndName = namePrefix.."friendcell/mark"
        local notifyWnd = winMgr:getWindow(notifyWndName)
        local bHasNotReadMsg = GetFriendsManager():RoleHasNotReadMsg(roleid)
        notifyWnd:setVisible(bHasNotReadMsg)
        local num = GetFriendsManager():GetRoleNotReadMsgNum(roleid)
        notifyWnd:setText(tostring(num))
               
        local onlineWndName=namePrefix.."friendcell/out"
        local onlineWnd=winMgr:getWindow(onlineWndName)
        local bOnline=false
        if(isOnline>0) then
            bOnline=true;
        end
        onlineWnd:setVisible(not bOnline)

        local campWndName=namePrefix.."friendcell/camp"
        local campWnd=winMgr:getWindow(campWndName)
        
        if camp == 1 then
            campWnd:setVisible(true)
            campWnd:setProperty("Image", "set:MainControl image:campred") 
        elseif camp == 2 then
            campWnd:setVisible(true)
            campWnd:setProperty("Image", "set:MainControl image:campblue")  
        else
            campWnd:setVisible(false)
        end
        
        
        local headWnd = nil
        --jiehun
        if bit.band(relation, 1) ~= 0 then
           winMgr:getWindow(namePrefix.."friendcell/jiehun"):setVisible(true)
           headWnd = winMgr:getWindow(namePrefix.."friendcell/icon0")
        --jiebai
        elseif bit.band(relation, 2) ~= 0 then
          winMgr:getWindow(namePrefix.."friendcell/jiebai"):setVisible(true)
          headWnd = winMgr:getWindow(namePrefix.."friendcell/icon1")
        --shitu
        elseif bit.band(relation, 4) ~= 0 then
          winMgr:getWindow(namePrefix.."friendcell/shitu"):setVisible(true)
          headWnd = winMgr:getWindow(namePrefix.."friendcell/icon2")
        end

        if headWnd ~= nil then
          winMgr:getWindow(namePrefix.."friendcell/icon"):setVisible(false)
          local strHead = ""
          if roleid == -1 then
              strHead = GetIconManager():GetImagePathByID(9034):c_str()
          else
              strHead = GetFriendsManager():GetContactRoleIcon(roleid)
          end
          headWnd:setProperty("Image",strHead)
        end

        FriendsDialog.m_vCellList[index]:setVisible(true)
        index = index + 1
    end

    for i = index, #FriendsDialog.m_vCellIndexList, 1 do
        FriendsDialog.m_vCellList[index]:setVisible(false)
        index = index+1
    end

end

function FriendsDialog:HandleListNextPage()
    if displaySize < GetFriendsManager():GetCurFriendNum() then
        displaySize = displaySize + 8
        self:RefreshRoleList(0)
    end
end


--Refresh the list view
--@return : no return
function FriendsDialog:RefreshBanListView()
    --clear the RoleList
    self.m_ContactRoleList:cleanupNonAutoChildren()

    --create the add button
    local winMgr=CEGUI.WindowManager:getSingleton()

    local btnAddCell = CEGUI.Window.toPushButton(winMgr:loadWindowLayout("friendsheildtop.layout"))
    self.m_ContactRoleList:addChildWindow(btnAddCell)

    btnAddCell:subscribeEvent("Clicked", FriendsDialog.HandleBanListAddClicked, self)

    local height = btnAddCell:getPixelSize().height
    local yPos = 1.0
    local xPos = 1.0
    btnAddCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))

    --get the data of ban list
    local vBanRoleList = {}
    if BanListManager.getInstance() then
        vBanRoleList = BanListManager.getInstance():GetBanList()
    end

    if vBanRoleList == nil then
        print("vBanRoleList is nil")
        return
    end

    self.m_roleidToRemove = 0
    self.m_nameToRemove = ""
    print("Start Refresh BanListView")
    local index = 0
    for k,v in pairs(vBanRoleList) do
        local namePrefix = v.roleid
        local cellWnd = winMgr:loadWindowLayout("friendsheildcell.layout", namePrefix)
        local txtName = winMgr:getWindow(namePrefix .. "friendsheildcell/name")
        local txtLevel = winMgr:getWindow(namePrefix .. "friendsheildcell/level")
        local txtSchool = winMgr:getWindow(namePrefix .. "friendsheildcell/level1")
        local imgIcon = winMgr:getWindow(namePrefix .. "friendsheildcell/icon")
        local imgCamp = winMgr:getWindow(namePrefix .. "friendsheildcell/camp")
        local btnRemove = CEGUI.Window.toPushButton(winMgr:getWindow(namePrefix .. "friendsheildcell/more"))
        self.m_ContactRoleList:addChildWindow(cellWnd)

        txtName:setText(v.name)

        if v.roleid == -1 then
            local strLevel = "89" .. MHSD_UTILS.get_resstring(2397)
            local instaStringRes = knight.gsp.message.GetCStringResTableInstance()
            if instaStringRes and instaStringRes:getRecorder(2926) then
                strLevel = instaStringRes:getRecorder(2926).msg
            end
            txtLevel:setText(strLevel)
        else
            txtLevel:setText(tostring(v.level) .. MHSD_UTILS.get_resstring(2397))
        end

        local schoolName=""
        if v.roleid == -1 then
            schoolName=MHSD_UTILS.get_resstring(2774)
        else
            schoolName= knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name
        end
        txtSchool:setText(schoolName)

        local strHead=""
        if v.roleid == -1 then
            strHead=GetIconManager():GetImagePathByID(9034):c_str()
        else
            local shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.shape)
            strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
        end
        imgIcon:setProperty("Image",strHead)

        if v.camp == 1 then
            imgCamp:setVisible(true)
            imgCamp:setProperty("Image", "set:MainControl image:campred") 
        elseif v.imgCamp == 2 then
            imgCamp:setVisible(true)
            imgCamp:setProperty("Image", "set:MainControl image:campblue")  
        else
            imgCamp:setVisible(false)
        end

        btnRemove:subscribeEvent("Clicked", FriendsDialog.HandleRemoveBanRoleClicked, self)

        local height = cellWnd:getPixelSize().height
        local yPos = 1.0+(height+5.0)*index+btnAddCell:getPixelSize().height+5.0
        local xPos = 1.0
        index = index + 1
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))

        btnRemove:setUserString("id", v.roleid)
        btnRemove:setUserString("name", v.name)
    end
end

--Callback of the ban list top cell to add ban role, the event is Clicked
--@return : no return
function FriendsDialog:HandleBanListAddClicked(args)
    SearchBanFriendDlg.getInstanceAndShow()
end


--Callback of the button at ban list cell to remove ban role, the event is Clicked
--@return : no return
function FriendsDialog:HandleRemoveBanRoleClicked(args)
    local e = CEGUI.toWindowEventArgs(args)  
    local strRoleId = e.window:getUserString("id")
    local strRoleName = e.window:getUserString("name")
  
    if not strRoleId or not strRoleName then
        self.m_roleidToRemove = 0
        self.m_nameToRemove = ""
        return true
    end

    local strbuilder = StringBuilder:new()
    self.roleidToRemove = tonumber(strRoleId)
    self.nameToRemove = strRoleName
    strbuilder:Set("parameter1", self.nameToRemove)
    local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145663))
    strbuilder:delete()

    GetMessageManager():AddConfirmBox(eConfirmNormal,msg, 
                                      FriendsDialog.HandleRemoveBanRoleConfirmOKClicked,self,
                                      CMessageManager.HandleDefaultCancelEvent,
                                      CMessageManager,0,0,nil,"","");
    return true
end

--Callback of the OK button at remove ban role confirm, the event is Clicked
--@return : no return
function FriendsDialog:HandleRemoveBanRoleConfirmOKClicked(args)
    GetMessageManager():CloseConfirmBox(eConfirmNormal, false);
    if self.roleidToRemove ~= nil then
        local req = require"protocoldef.knight.gsp.pingbi.cremoveblackrole".Create()
        req.roleid = self.roleidToRemove
        LuaProtocolManager.getInstance():send(req)
    end
    return true
end

--Set the list of enemy
function FriendsDialog.GlobalSetEnemyList(enemyList)
    LogInfo("FriendsDialog Set Enemy Data")
    FriendsDialog.m_vEnemyList = enemyList
end

--Get the enemy list data from server
function FriendsDialog:RequireEnemyList()
    LogInfo("FriendsDialog Require Enemy Data")
    local req = require "protocoldef.knight.gsp.friends.csearchenemy".Create()
    LuaProtocolManager.getInstance():send(req)
end

--Refresh the list view for enemy
function FriendsDialog:RefreshEnemyListView()
    LogInfo("FriendsDialog RefreshEnemyListView")

    --clear the RoleList
    self.m_ContactRoleList:cleanupNonAutoChildren()

    local function sortFunc(a ,b)
        return a.online > b.online
    end
    table.sort(FriendsDialog.m_vEnemyList, sortFunc)

    --Refresh the

    local winMgr=CEGUI.WindowManager:getSingleton()
    local index = 0
    for k,v in pairs(FriendsDialog.m_vEnemyList) do
        local namePrefix = v.roleid
        local cellWnd = winMgr:loadWindowLayout("enemycell.layout", namePrefix)
        local txtName = winMgr:getWindow(namePrefix .. "enemycell/name")
        local txtLevel = winMgr:getWindow(namePrefix .. "enemycell/level")
        local txtSchool = winMgr:getWindow(namePrefix .. "enemycell/level1")
        local imgIcon = winMgr:getWindow(namePrefix .. "enemycell/icon")
        local imgCamp = winMgr:getWindow(namePrefix .. "enemycell/camp")
        local imgOnline = winMgr:getWindow(namePrefix .. "enemycell/out")
        local btnFind = CEGUI.Window.toPushButton(winMgr:getWindow(namePrefix .. "enemycell/more"))
        self.m_ContactRoleList:addChildWindow(cellWnd)

        txtName:setText(v.name)

        if v.roleid == -1 then
            local strLevel = "89" .. MHSD_UTILS.get_resstring(2397)
            local instaStringRes = knight.gsp.message.GetCStringResTableInstance()
            if instaStringRes and instaStringRes:getRecorder(2926) then
                strLevel = instaStringRes:getRecorder(2926).msg
            end
            txtLevel:setText(strLevel)
        else
            txtLevel:setText(tostring(v.rolelevel) .. MHSD_UTILS.get_resstring(2397))
        end

        local schoolName=""
        if v.roleid == -1 then
            schoolName=MHSD_UTILS.get_resstring(2774)
        else
            schoolName= knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name
        end
        txtSchool:setText(schoolName)

        local strHead=""
        if v.roleid == -1 then
            strHead=GetIconManager():GetImagePathByID(9034):c_str()
        else
            local shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.shape)
            strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
        end
        imgIcon:setProperty("Image",strHead)

        if v.camp == 1 then
            imgCamp:setVisible(true)
            imgCamp:setProperty("Image", "set:MainControl image:campred") 
        elseif v.camp == 2 then
            imgCamp:setVisible(true)
            imgCamp:setProperty("Image", "set:MainControl image:campblue")  
        else
            imgCamp:setVisible(false)
        end

        if v.online == 1 then
            imgOnline:setVisible(false)
        else
            imgOnline:setVisible(true)
        end

        btnFind:subscribeEvent("Clicked", FriendsDialog.HandleFindEnemyClicked, self)

        local height = cellWnd:getPixelSize().height
        local yPos = 1.0+(height+5.0)*index
        local xPos = 1.0
        index = index + 1
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))

        btnFind:setUserString("id", v.roleid)
        btnFind:setUserString("name", v.name)
        btnFind:setUserString("online", tostring(v.online))
    end

end

--Callback of the button at enemy list cell to find enemy, the event is Clicked
--@return : no return
function FriendsDialog:HandleFindEnemyClicked(args)
    local e = CEGUI.toWindowEventArgs(args)  
    local strRoleId = e.window:getUserString("id")
    local strRoleName = e.window:getUserString("name")
    local strOnline = e.window:getUserString("online")

    if tonumber(strOnline) == 0 then
        GetGameUIManager():AddMessageTipById(145890)
    elseif GetRoleItemManager():GetItemNumByBaseID(ZHUIZONGDIE_ID) <= 0 then
        GetGameUIManager():AddMessageTipById(145892)
    else
        local function CilckOK(self, args)
            GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            req = require "protocoldef.knight.gsp.friends.cbutterflyusing".Create()
            req.enemyid = tonumber(strRoleId)
            req.itemid = ZHUIZONGDIE_ID
            LuaProtocolManager.getInstance():send(req)
        end

        local msg = require "utils.mhsdutils".get_msgtipstring(145891)
        msg = string.gsub(msg, "%$parameter1%$", strRoleName)
        GetMessageManager():AddConfirmBox(eConfirmNormal, msg, CilckOK, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager ,0,0,nil,"","")
    end

    return true
end

--Show enemy list
--@return : no return
function FriendsDialog:OpenEnemyView()
    self.m_EnemyListButton:setSelected(true)

end

return FriendsDialog
