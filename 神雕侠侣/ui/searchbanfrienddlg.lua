--searchbanfrienddlg.lua
--It is copy and change from searchfrienddlg.lua
--create by wuyao in 2014-2-21

require "ui.dialog"
require "utils.mhsdutils"

SearchBanFriendDlg = {}
setmetatable(SearchBanFriendDlg, Dialog)
SearchBanFriendDlg.__index = SearchBanFriendDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SearchBanFriendDlg.getInstance()
	print("enter get SearchBanFriendDlg instance")
    if not _instance then
        _instance = SearchBanFriendDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SearchBanFriendDlg.getInstanceAndShow()
	print("enter SearchBanFriendDlg instance show")
    if not _instance then
        _instance = SearchBanFriendDlg:new()
        _instance:OnCreate()
	else
		print("set SearchBanFriendDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SearchBanFriendDlg.getInstanceNotCreate()
    return _instance
end

function SearchBanFriendDlg.DestroyDialog()
	if _instance then 
		print("destroy SearchBanFriendDlg")
		NumInputDlg.DestroyDialog()
		_instance:OnClose()
		_instance = nil
	end
end

function SearchBanFriendDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SearchBanFriendDlg:new() 
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

function SearchBanFriendDlg.GetLayoutFileName()
    return "friendsheildsearch.layout"
end

function SearchBanFriendDlg:OnCreate()
	print("SearchBanFriendDlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pEdit = CEGUI.toEditbox(winMgr:getWindow("friendsheildsearch/in"))
	self.m_pHead = winMgr:getWindow("friendsheildsearch/line1")
	self.m_pName = winMgr:getWindow("friendsheildsearch/name")
	self.m_pSchool = winMgr:getWindow("friendsheildsearch/school")
	self.m_pLevel = winMgr:getWindow("friendsheildsearch/level")
	self.m_pCloseBtn = CEGUI.toPushButton(winMgr:getWindow("friendsheildsearch/closed"))
	self.m_pSearchBtn = CEGUI.toPushButton(winMgr:getWindow("friendsheildsearch/ok"))
	self.m_pInfoBtn = CEGUI.toPushButton(winMgr:getWindow("friendsheildsearch/more"))

    -- subscribe event
    self.m_pCloseBtn:subscribeEvent("Clicked", SearchBanFriendDlg.HandleCloseBtnClicked, self) 
    self.m_pSearchBtn:subscribeEvent("Clicked", SearchBanFriendDlg.HandleSearchBtnClicked, self) 
    self.m_pInfoBtn:subscribeEvent("Clicked", SearchBanFriendDlg.HandleBanClicked, self) 

	self.m_pEdit:subscribeEvent("MouseClick", SearchBanFriendDlg.HandleEditClicked, self)
	self.m_pEdit:subscribeEvent("TextChanged", SearchBanFriendDlg.OnTextChanged, self)
	self.m_pEdit:setReadOnly(true)

	self:InitDefault()
	print("SearchBanFriendDlg oncreate end")
end

------------------- private: -----------------------------------


function SearchBanFriendDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SearchBanFriendDlg)
    return self
end

function SearchBanFriendDlg:HandleCloseBtnClicked()
	print("SearchBanFriendDlg HandleCloseBtnClicked")
	SearchBanFriendDlg.DestroyDialog()
end

function SearchBanFriendDlg:HandleSearchBtnClicked()
	print("SearchBanFriendDlg HandleSearchBtnClicked")
	self:InitDefault()
	local text = self.m_pEdit:getText()
	local len = string.len(text)
	if len < 1 then
		GetGameUIManager():AddMessageTipById(145344)
		return
	end
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
	
	local roleid = tonumber(text) 
	local req = require "protocoldef.knight.gsp.pingbi.csearchblackrole".Create()
	req.roleid = roleid
	LuaProtocolManager.getInstance():send(req)
end

--add for ban role search, ban button callback
--return : no return
function SearchBanFriendDlg:HandleBanClicked(args)
	print("SearchBanFriendDlg HandleBanConfirmOKClicked")
	-- GetFriendsManager():SetContactRole(self.m_roleBean.roleid, self.m_roleBean.name, self.m_roleBean.rolelevel, self.m_roleBean.camp)
	if self.m_roleBean.roleid ~= nil then
		local req = require "protocoldef.knight.gsp.pingbi.caddblackrole".Create()
		req.roleid = self.m_roleBean.roleid
		LuaProtocolManager.getInstance():send(req)
	end
	return true
end

function SearchBanFriendDlg:InitDefault()
	self.m_pName:setVisible(false)
	self.m_pSchool:setVisible(false)
	self.m_pLevel:setVisible(false)
	self.m_pInfoBtn:setVisible(false)
	self.m_pHead:setProperty("Image", "set:roleandmonster16 image:9067")
end

function SearchBanFriendDlg:Init(friendBean)
	print("SearchBanFriendDlg Init")
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

function SearchBanFriendDlg:HandleEditClicked(args)
	print("SearchBanFriendDlg HandleEditClicked")
	NumInputDlg:ToggleOpenHide()
    NumInputDlg:GetSingleton():setTargetWindow(self.m_pEdit)

end

function SearchBanFriendDlg:OnTextChanged(args)
	print("SearchBanFriendDlg OnTextChanged")
	local longID = self.m_pEdit:getText()
	if string.len(longID) > 15 then
		local shortID = string.sub(longID, 1, 15)
		self.m_pEdit:setText(shortID)
	end
end

return SearchBanFriendDlg
