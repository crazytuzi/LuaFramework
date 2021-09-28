require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.friends.crequestsearchfriend"

SearchFriendDlg = {}
setmetatable(SearchFriendDlg, Dialog)
SearchFriendDlg.__index = SearchFriendDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SearchFriendDlg.getInstance()
	LogInfo("enter get SearchFriendDlg instance")
    if not _instance then
        _instance = SearchFriendDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SearchFriendDlg.getInstanceAndShow()
	LogInfo("enter SearchFriendDlg instance show")
    if not _instance then
        _instance = SearchFriendDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set SearchFriendDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SearchFriendDlg.getInstanceNotCreate()
    return _instance
end

function SearchFriendDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy SearchFriendDlg")
		NumInputDlg.DestroyDialog()
		_instance:OnClose()
		_instance = nil
	end
end

function SearchFriendDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SearchFriendDlg:new() 
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

function SearchFriendDlg.GetLayoutFileName()
    return "searchfrienddlg.layout"
end

function SearchFriendDlg:OnCreate()
	LogInfo("SearchFriendDlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pEdit = CEGUI.toEditbox(winMgr:getWindow("searchfrienddlg/in"))
	self.m_pHead = winMgr:getWindow("searchfrienddlg/line1")
	self.m_pName = winMgr:getWindow("searchfrienddlg/name")
	self.m_pSchool = winMgr:getWindow("searchfrienddlg/school")
	self.m_pLevel = winMgr:getWindow("searchfrienddlg/level")
	self.m_pCloseBtn = CEGUI.toPushButton(winMgr:getWindow("searchfrienddlg/closed"))
	self.m_pSearchBtn = CEGUI.toPushButton(winMgr:getWindow("searchfrienddlg/ok"))
	self.m_pInfoBtn = CEGUI.toPushButton(winMgr:getWindow("searchfrienddlg/more"))

    -- subscribe event
    self.m_pCloseBtn:subscribeEvent("Clicked", SearchFriendDlg.HandleCloseBtnClicked, self) 
    self.m_pSearchBtn:subscribeEvent("Clicked", SearchFriendDlg.HandleSearchBtnClicked, self) 
    self.m_pInfoBtn:subscribeEvent("Clicked", SearchFriendDlg.HandleInfoBtnClicked, self) 
    if self:checkable() then
        self.m_pEdit:subscribeEvent("MouseClick", SearchFriendDlg.HandleEditClicked, self)
        self.m_pEdit:subscribeEvent("TextChanged", SearchFriendDlg.OnTextChanged, self)
        self.m_pEdit:setReadOnly(true)
    end
	self:InitDefault()
	LogInfo("SearchFriendDlg oncreate end")
end

------------------- private: -----------------------------------


function SearchFriendDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SearchFriendDlg)
    return self
end

function SearchFriendDlg:HandleCloseBtnClicked()
	LogInfo("SearchFriendDlg HandleCloseBtnClicked")
	SearchFriendDlg.DestroyDialog()
end

function SearchFriendDlg:HandleSearchBtnClicked()
	LogInfo("SearchFriendDlg HandleSearchBtnClicked")
	self:InitDefault()
	local text = self.m_pEdit:getText()
	local len = string.len(text)
	if len < 1 then
		GetGameUIManager():AddMessageTipById(145344)
		return
	end


    if self:checkable() then
        local allNum = true
        for i = 1, len do
            local ch = string.sub(text, i, i)
            if ch < '0' or ch > '9' then
                allNum = false
                break
            end
        end
        if not allNum then
            GetGameUIManager():AddMessageTipById(145344)
            return
        end
        text = tonumber(text)
    end
	
	local roleid = text
	local req = CRequestSearchFriend.Create()
	req.roleid = roleid
	LuaProtocolManager.getInstance():send(req)
end


function SearchFriendDlg:checkable()
    return false
--[[
    if  ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
        return true
    else
        return false
    end
]]
end


function SearchFriendDlg:HandleInfoBtnClicked()
	LogInfo("SearchFriendDlg HandleInfoBtnClicked")
	GetFriendsManager():SetContactRole(self.m_roleBean.roleid, self.m_roleBean.name, self.m_roleBean.rolelevel, self.m_roleBean.camp)
end

function SearchFriendDlg:InitDefault()
	self.m_pName:setVisible(false)
	self.m_pSchool:setVisible(false)
	self.m_pLevel:setVisible(false)
	self.m_pInfoBtn:setVisible(false)
	self.m_pHead:setProperty("Image", "set:roleandmonster16 image:9067")
end

function SearchFriendDlg:Init(friendBean)
	LogInfo("SearchFriendDlg Init")
	self.m_roleBean = friendBean
	self.m_pName:setVisible(true)
	self.m_pSchool:setVisible(true)
	self.m_pLevel:setVisible(true)
	self.m_pInfoBtn:setVisible(true)
	
	self.m_pName:setText(friendBean.name)
	self.m_pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(friendBean.school).name)
	self.m_pLevel:setText(tostring(friendBean.rolelevel) .. MHSD_UTILS.get_resstring(2397))
	local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(friendBean.shape)
	local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
	self.m_pHead:setProperty("Image", path)
end

function SearchFriendDlg:HandleEditClicked(args)
	LogInfo("SearchFriendDlg HandleEditClicked")
	NumInputDlg:ToggleOpenHide()
    NumInputDlg:GetSingleton():setTargetWindow(self.m_pEdit)

end

function SearchFriendDlg:OnTextChanged(args)
	LogInfo("SearchFriendDlg OnTextChanged")
	local longID = self.m_pEdit:getText()
	if string.len(longID) > 15 then
		local shortID = string.sub(longID, 1, 15)
		self.m_pEdit:setText(shortID)
	end
end

return SearchFriendDlg
