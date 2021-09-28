require "ui.dialog"
FactionAccept = {}
setmetatable(FactionAccept, Dialog)
FactionAccept.__index = FactionAccept
local pagesize = 20
local function createdlg()
	local self = {}
	setmetatable(self, FactionAccept)
	function self.GetLayoutFileName()
		return "familyaccept.layout"
	end
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pApplyList = CEGUI.toMultiColumnList(winMgr:getWindow("FamilyAccept/FamilyList"))
	self.m_pAcceptBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyAccept/Apply"))
	self.m_pRejectBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyAccept/Contact"))
	self.m_pAddFriendBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyAccept/friend"))
	self.m_pClearBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyAccept/clear"))
	self.m_pMenu = winMgr:getWindow("FamilyAccept/FamilyList/list")
	self.m_pMenu:setVisible(false)
	
	self.m_pApplyList:subscribeEvent("SelectionChanged", self.HandleMemberSelected, self)
	self.m_pAcceptBtn:subscribeEvent("Clicked", self.HandleAcceptBtnClicked, self)
	self.m_pRejectBtn:subscribeEvent("Clicked", self.HandleRejectBtnClicked, self)
	self.m_pAddFriendBtn:subscribeEvent("Clicked", self.HandleAddFriendBtnClicked, self)
	self.m_pClearBtn:subscribeEvent("Clicked", self.HandleClearBtnClicked, self)
	self.m_iCurpage = 0
    self.m_pApplyList:subscribeEvent("NextPage", self.HandleApplyNextPage, self)
	local p = require "protocoldef.knight.gsp.faction.crequestapplicantlist2":new()
	require "manager.luaprotocolmanager":send(p)
	return self
end

function FactionAccept:HandleMemberSelected(e)
	local selecteditem = self.m_pApplyList:getFirstSelectedItem()
    if not selecteditem then
        return
    end
    self.m_pMenu:setVisible(true)
    self.m_curRoleid = self.roleids[selecteditem]
    return true
end

function FactionAccept:HandleApplyNextPage(e)
	local startnum = self.m_iCurpage * pagesize + 1
	print(startnum.."/"..#self.applicantlist.."=======\n")
	if not self.applicantlist then
		return true
	end
	
	if startnum <= #self.applicantlist then
		for i = startnum, startnum + pagesize - 1 do
			if i > #self.applicantlist then
				break
			end
			local applicant = self.applicantlist[i]
			self.m_pApplyList:insertRow(self.row_id)
	        
	        local pItem = CEGUI.createListboxTextItem(applicant.rolename)
	        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
	        self.m_pApplyList:setItem(pItem, 0, self.row_id)
	        self.roleids[pItem] = applicant.roleid
	        table.insert(self.roleid_rowidx, applicant.roleid)
	        pItem = CEGUI.createListboxTextItem(applicant.rolelevel)
	        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
	        self.m_pApplyList:setItem(pItem, 1, self.row_id)
	        
	        local roleschool = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(applicant.roleschool).name
	        
	        pItem = CEGUI.createListboxTextItem(roleschool)
	        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
	        self.m_pApplyList:setItem(pItem, 2, self.row_id)
	        
	        self.row_id = self.row_id + 1
		end
		self.m_iCurpage = self.m_iCurpage + 1
	end
end

function FactionAccept:HandleAcceptBtnClicked(e)
	local send = require "protocoldef.knight.gsp.faction.cacceptorrefuseapplication2":new()
    send.applicantroleid = self.m_curRoleid
    send.accept = 1
    require "manager.luaprotocolmanager":send(send)
end

function FactionAccept:HandleRejectBtnClicked(e)
	local send = require "protocoldef.knight.gsp.faction.cacceptorrefuseapplication2":new()
    send.applicantroleid = self.m_curRoleid
    send.accept = 0
    require "manager.luaprotocolmanager":send(send)
end

function FactionAccept:HandleAddFriendBtnClicked(e)
	if self.m_curRoleid > 0 then
		GetFriendsManager():RequestAddFriend(self.m_curRoleid)
	end
end

function FactionAccept:HandleClearBtnClicked(e)
	local send = require "protocoldef.knight.gsp.faction.cclearapplicantlist2":new()
    require "manager.luaprotocolmanager":send(send)
end

function FactionAccept:ProcessList(applicantlist)
	self.m_pApplyList:resetList()
    self.row_id = 0
    self.roleids = {}
    self.roleid_rowidx = {}
    self.m_pMenu:setVisible(false)
    self.m_pApplyList:resetList()
    self.applicantlist = {}
    for k, v in pairs(applicantlist) do
    	self.applicantlist[k] = v
    end
    local shownum = pagesize > #applicantlist and #applicantlist or pagesize
	for i = 1, shownum do
		local applicant = applicantlist[i]
		self.m_pApplyList:insertRow(self.row_id)
        
        local pItem = CEGUI.createListboxTextItem(applicant.rolename)
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
        self.m_pApplyList:setItem(pItem, 0, self.row_id)
        self.roleids[pItem] = applicant.roleid
        table.insert(self.roleid_rowidx, applicant.roleid)
        pItem = CEGUI.createListboxTextItem(applicant.rolelevel)
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
        self.m_pApplyList:setItem(pItem, 1, self.row_id)
        
        local roleschool = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(applicant.roleschool).name
        
        pItem = CEGUI.createListboxTextItem(roleschool)
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
        self.m_pApplyList:setItem(pItem, 2, self.row_id)
        
        self.row_id = self.row_id + 1
	end
	self.m_iCurpage = 1
end

function FactionAccept:AddApplicant(applicant)
	self.m_pApplyList:insertRow(self.row_id)
    
    local pItem = CEGUI.createListboxTextItem(applicant.rolename)
    pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
    self.m_pApplyList:setItem(pItem, 0, self.row_id)
    if not self.roleids then self.roleids = {} end
    if not self.roleid_rowidx then self.roleid_rowidx = {} end
    self.roleids[pItem] = applicant.roleid
    table.insert(self.roleid_rowidx, applicant.roleid)
    
    pItem = CEGUI.createListboxTextItem(applicant.rolelevel)
    pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
    self.m_pApplyList:setItem(pItem, 1, self.row_id)
    
    local roleschool = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(applicant.roleschool).name
    
    pItem = CEGUI.createListboxTextItem(roleschool)
    pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
    self.m_pApplyList:setItem(pItem, 2, self.row_id)
    
    self.row_id = self.row_id + 1
end

function FactionAccept:RemoveApplicant(applicantid)
	if not self.roleids then
		return false
	end
	local textitem
	for i = 1, #self.roleid_rowidx do
		if self.roleid_rowidx[i] == applicantid then
			table.remove(self.roleid_rowidx, i)
			textitem = i
			break
		end
	end
	if not textitem then
		return false
	end
	self.m_pApplyList:removeRow(textitem - 1)
	self.row_id = self.row_id - 1
	self.m_pMenu:setVisible(false)
	return true
end

local _instance
function FactionAccept.GetSingletonDialogAndShowIt(memberid)
	if not _instance then
		_instance = createdlg(memberid)
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true)
	end
	return _instance
end

function FactionAccept.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function FactionAccept.getInstanceOrNot()
	return _instance
end

return FactionAccept
