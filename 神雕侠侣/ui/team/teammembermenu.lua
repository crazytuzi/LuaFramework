require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.item.cgetotherroleinfo"


TeamMemberMenu = {}
setmetatable(TeamMemberMenu, Dialog)
TeamMemberMenu.__index = TeamMemberMenu

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeamMemberMenu.getInstance()
	LogInfo("enter get TeamMemberMenu instance")
    if not _instance then
        _instance = TeamMemberMenu:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeamMemberMenu.getInstanceAndShow()
	LogInfo("enter TeamMemberMenu instance show")
    if not _instance then
        _instance = TeamMemberMenu:new()
        _instance:OnCreate()
	else
		LogInfo("set TeamMemberMenu visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeamMemberMenu.getInstanceNotCreate()
    return _instance
end

function TeamMemberMenu.DestroyDialog()
	if _instance then 
		LogInfo("destroy TeamMemberMenu")
		_instance:OnClose()
		_instance = nil
	end
end

function TeamMemberMenu.ToggleOpenClose()
	if not _instance then 
		_instance = TeamMemberMenu:new() 
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

function TeamMemberMenu.GetLayoutFileName()
    return "teaminter.layout"
end

function TeamMemberMenu:OnCreate()
	LogInfo("TeamMemberMenu oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pButton = {}
	for i = 0, 4 do
    	self.m_pButton[i] = CEGUI.Window.toPushButton(winMgr:getWindow("teaminter/" .. tostring(i)))
    	self.m_pButton[i]:setVisible(false)
	end    

	LogInfo("TeamMemberMenu oncreate end")

end

------------------- private: -----------------------------------


function TeamMemberMenu:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamMemberMenu)
    return self
end

function TeamMemberMenu:InitBtn(state, id)
	self.m_iCurSelectMember = id

	for i = 0, 4 do
		self.m_pButton[i]:removeEvent("Clicked")
		self.m_pButton[i]:setVisible(false)
	end
	if state == 0 then
    	self.m_pButton[0]:setText(MHSD_UTILS.get_resstring(2673))    --召唤队员
        self.m_pButton[0]:setVisible(true)
        self.m_pButton[0]:subscribeEvent("Clicked", TeamMemberMenu.HandleCallbackBtnClicked,self)
        if not GetTeamManager():IsHaveAbsentMember() then
        	self.m_pButton[0]:setEnabled(false)
        else
	        self.m_pButton[0]:setEnabled(true);
		end
		self.m_pButton[1]:setText(MHSD_UTILS.get_resstring(2674)) 	--升为队长
		self.m_pButton[1]:setVisible(true)
		self.m_pButton[1]:subscribeEvent("Clicked", TeamMemberMenu.HandleSetLeaderBtnClicked, self)
		self.m_pButton[2]:setText(MHSD_UTILS.get_resstring(2675)) 	--查看资料
		self.m_pButton[2]:setVisible(true)
		self.m_pButton[2]:subscribeEvent("Clicked", TeamMemberMenu.HandleViewBtnClicked, self)
		self.m_pButton[3]:setText(MHSD_UTILS.get_resstring(2676)) 	--加为好友
		self.m_pButton[3]:setVisible(true)
		self.m_pButton[3]:subscribeEvent("Clicked", TeamMemberMenu.HandleAddFriendBtnClicked, self)
		self.m_pButton[4]:setText(MHSD_UTILS.get_resstring(2677)) 	--请离队员
		self.m_pButton[4]:setVisible(true)
		self.m_pButton[4]:subscribeEvent("Clicked", TeamMemberMenu.HandleExpelBtnClicked, self)
		self:GetWindow():setHeight(self.m_pButton[0]:getHeight() + self.m_pButton[1]:getHeight() + self.m_pButton[2]:getHeight() + self.m_pButton[3]:getHeight() + self.m_pButton[4]:getHeight() + CEGUI.UDim(0, 10))
	elseif state == 1 then
		self.m_pButton[0]:setText(MHSD_UTILS.get_resstring(2678)) 	--解散队伍
		self.m_pButton[0]:setVisible(true)
		self.m_pButton[0]:subscribeEvent("Clicked", TeamMemberMenu.HandleDismissTeamBtnClicked, self)
		self.m_pButton[0]:setEnabled(true)
		self.m_pButton[1]:setText(MHSD_UTILS.get_resstring(2679)) 	--退出队伍
		self.m_pButton[1]:setVisible(true)
		self.m_pButton[1]:subscribeEvent("Clicked", TeamMemberMenu.HandleQuitTeamBtnClicked, self)
		self:GetWindow():setHeight(self.m_pButton[0]:getHeight() + self.m_pButton[1]:getHeight() + CEGUI.UDim(0, 10))
	elseif state == 2 then
		self.m_pButton[0]:setText(MHSD_UTILS.get_resstring(2675)) 	--查看资料
		self.m_pButton[0]:setVisible(true)
		self.m_pButton[0]:subscribeEvent("Clicked", TeamMemberMenu.HandleViewBtnClicked, self)
		self.m_pButton[0]:setEnabled(true)
		self.m_pButton[1]:setText(MHSD_UTILS.get_resstring(2676)) 	--加为好友
		self.m_pButton[1]:setVisible(true)
		self.m_pButton[1]:subscribeEvent("Clicked", TeamMemberMenu.HandleAddFriendBtnClicked, self)
		self:GetWindow():setHeight(self.m_pButton[0]:getHeight() + self.m_pButton[1]:getHeight() + CEGUI.UDim(0, 10))
	elseif state == 3 then
		if GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberAbsent then
			self.m_pButton[0]:setText(MHSD_UTILS.get_resstring(2680)) 	--回归队伍
			self.m_pButton[0]:setVisible(true)
			self.m_pButton[0]:subscribeEvent("Clicked", TeamMemberMenu.HandleBackBtnClicked, self)
		else
			self.m_pButton[0]:setText(MHSD_UTILS.get_resstring(2681)) 	--暂离队伍
			self.m_pButton[0]:setVisible(true)
			self.m_pButton[0]:subscribeEvent("Clicked", TeamMemberMenu.HandleAbsentBtnClicked, self)
		end	
		self.m_pButton[0]:setEnabled(true)
		self.m_pButton[1]:setText(MHSD_UTILS.get_resstring(2679)) 	--退出队伍
		self.m_pButton[1]:setVisible(true)
		self.m_pButton[1]:subscribeEvent("Clicked", TeamMemberMenu.HandleQuitTeamBtnClicked, self)
		self:GetWindow():setHeight(self.m_pButton[0]:getHeight() + self.m_pButton[1]:getHeight() + CEGUI.UDim(0, 10))
	end
end

function TeamMemberMenu:HandleCallbackBtnClicked(args)
 	LogInfo("TeamMemberMenu handle callback btn clicked")
	GetTeamManager():RequestCallbackMember()
    self:SetVisible(false)
	return true
end

function TeamMemberMenu:HandleSetLeaderBtnClicked(args)
	LogInfo("TeamMemberMenu handle setleader btn clicked")
	GetTeamManager():RequestSetLeader(self.m_iCurSelectMember)
    self:SetVisible(false)
	return true
end


function TeamMemberMenu:HandleExpelBtnClicked(args)
	LogInfo("TeamMemberMenu handle expel btn clicked")
	GetTeamManager():RequestExpelMember(self.m_iCurSelectMember)
    self:SetVisible(false)
	return true
end

function TeamMemberMenu:HandleDismissTeamBtnClicked(args) 
	LogInfo("TeamMemberMenu handle dismiss btn clicked")
	if GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader() then
		if GetBattleManager():IsInBattle() then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(141363)  	--战斗中不能进行此项操作
            end
		else
			GetTeamManager():RequestDismissTeam()
		end
	end
    self:SetVisible(false);
	return true;
end

function TeamMemberMenu:HandleQuitTeamBtnClicked(args)
	LogInfo("TeamMemberMenu handle quit btn clicked")
	GetTeamManager():RequestQuitTeam()
    self:SetVisible(false)
	return true
end

function TeamMemberMenu:HandleAbsentBtnClicked(args)
	LogInfo("TeamMemberMenu handle absent btn clicked")
	GetTeamManager():RequestAbsentReturnTeam(true)
    self:SetVisible(false)
	return true
end

function TeamMemberMenu:HandleBackBtnClicked(args)
	LogInfo("TeamMemberMenu handle back btn clicked")
	GetTeamManager():RequestAbsentReturnTeam(false)
    self:SetVisible(false)
	return true
end

function TeamMemberMenu:HandleAddFriendBtnClicked(args)
	LogInfo("TeamMemberMenu handle addfriend btn clicked")
	GetFriendsManager():RequestAddFriend(GetTeamManager():GetMember(self.m_iCurSelectMember+1).id)
    self:SetVisible(false)
	return true
end

function TeamMemberMenu:HandleViewBtnClicked(args)
	LogInfo("TeamMemberMenu handle view btn clicked")
	local getOtherRoleInfo = CGetOtherRoleInfo.Create()
	getOtherRoleInfo.roleid = GetTeamManager():GetMember(self.m_iCurSelectMember + 1).id
	LuaProtocolManager.getInstance():send(getOtherRoleInfo)
    self:SetVisible(false)
	return true
end


return TeamMemberMenu
