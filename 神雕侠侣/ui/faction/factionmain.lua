require "ui.dialog"

FactionMain = {}
setmetatable(FactionMain, Dialog)
FactionMain.__index = FactionMain

local GETPUSHBUTTON = function(name)
	return CEGUI.toPushButton(CEGUI.WindowManager:getSingleton():getWindow(name))
end

local strcmp = StringCover.strcmpByPinyin

local BIND_BUTTON_FUNCTION = function(wnd, f, dlg)
	assert(wnd)
	wnd:subscribeEvent("Clicked", f, dlg)
end

local function createdlg()
	local dlg = {}
	setmetatable(dlg, FactionMain)
	function dlg:GetLayoutFileName()
		return "family.layout"
	end
	Dialog.OnCreate(dlg)
	local winMgr = CEGUI.WindowManager:getSingleton()
	dlg.m_pFactionName = winMgr:getWindow("Family/FamilyName")
    dlg.m_pFactionId = winMgr:getWindow("Family/FamilyID")
    dlg.m_pFactionLevel = winMgr:getWindow("Family/FamilyLevel")
    dlg.m_pFactionMemeberNum = winMgr:getWindow("Family/FamilyMemberNum")
 --   dlg.m_pFactionCreator = winMgr:getWindow("Family/FamilyFrame/FamilyCreater")
    dlg.m_pFactionMaster = winMgr:getWindow("Family/FamilyManager")
    dlg.m_pFactionMoney = CEGUI.toProgressBar(winMgr:getWindow("Family/FamilyMoney"))
    dlg.m_pFactionBroad = winMgr:getWindow("Family/FamilyPurpose")
    dlg.m_pBuildCost = winMgr:getWindow("Family/Buildneed")
    dlg.m_pFactionMembers = CEGUI.toMultiColumnList(winMgr:getWindow("Family/FamilyMember"))
    dlg.m_pFactionMembers:getListHeader():setSortingEnabled(true)
    dlg.m_pAddFriend = GETPUSHBUTTON("Family/friend")
    dlg.m_pStartChat = GETPUSHBUTTON("Family/StartChat");
    dlg.m_pDissoloveMember = GETPUSHBUTTON("Family/KickMember")
    dlg.m_pChangePos = GETPUSHBUTTON("Family/ChangePosition")
  --  dlg.m_pBanChat = GETPUSHBUTTON("Family/ChangePosition1")
    dlg.m_pGoback = GETPUSHBUTTON("Family/goback")
    dlg.m_pEditBroad = GETPUSHBUTTON("Family/change")
    dlg.m_pLeaveFaction = GETPUSHBUTTON("Family/leave")
    dlg.m_pApplyList = GETPUSHBUTTON("Family/StartChat2")
    dlg.m_pTips = winMgr:getWindow("Family/Tips")
    dlg.m_pTips:setVisible(false)
    dlg.m_pApplyMark = winMgr:getWindow("Family/StartChat2/mark")
	dlg.m_pApplyMark:setVisible(false)
	dlg.m_pWeiboShareBtn =GETPUSHBUTTON("Family/Back1/share")


	dlg.m_pWeiboShareBtn:setVisible(false)
	if Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "tiger" then
		dlg.m_pWeiboShareBtn:setVisible(true)
    	BIND_BUTTON_FUNCTION(dlg.m_pWeiboShareBtn, FactionMain.HandleWeiboShareBtnClicked, dlg)
    elseif ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
		dlg.m_pWeiboShareBtn:setVisible(true)
    	BIND_BUTTON_FUNCTION(dlg.m_pWeiboShareBtn, FactionMain.HandleFacebookShareBtnClicked, dlg)
	end
    BIND_BUTTON_FUNCTION(dlg.m_pDissoloveMember, FactionMain.HandleFireMemberBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pLeaveFaction, FactionMain.HandleLeaveFactionBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pChangePos, FactionMain.HandleChangePosBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pApplyList, FactionMain.HandleApplylistBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pEditBroad, FactionMain.HandleEditBroadBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pAddFriend, FactionMain.HandleAddFriendBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pStartChat, FactionMain.HandleStartChatBtnClicked, dlg)
    BIND_BUTTON_FUNCTION(dlg.m_pGoback, FactionMain.HandleGobackBtnCLicked, dlg)
    dlg.m_pFactionMembers:subscribeEvent("SelectionChanged", FactionMain.HandleMemberSelected, dlg)
    dlg.m_pFactionMembers:subscribeEvent("SortDirChanged", FactionMain.HandleSortDirChanged, dlg)
    dlg.m_pFactionMembers:subscribeEvent("SortColChanged", FactionMain.HandleSortColChanged, dlg)
    local datamanager = require "ui.faction.factiondatamanager"
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.faction.cfactionbaseinfo")
	dlg.m_pInfoConfig = tt:getRecorder(datamanager.factionlevel)
    dlg.m_pFactionName:setText("")
    dlg.m_pFactionId:setText("")
    dlg.m_pFactionLevel:setText("")
    dlg.m_pFactionMemeberNum:setText("0/0")
--    dlg.m_pFactionCreator:setText("")
    dlg.m_pFactionMaster:setText("")
    local blevel = datamanager.buildlevel or 0
    dlg.m_pFactionMoney:setText(string.format("%d/%d", blevel, dlg.m_pInfoConfig.needbuild))
    dlg.m_pFactionMoney:setProgress(blevel/dlg.m_pInfoConfig.needbuild)
    dlg.m_pBuildCost:setText(dlg.m_pInfoConfig.build)
    dlg.m_pFactionBroad:setText("")
    dlg:InitMember()
    dlg.m_pFactionMembers:setSortColumn(0)
    local p = require "protocoldef.knight.gsp.faction.cpositionrequest":new()
	require "manager.luaprotocolmanager":send(p)
	local p = require "protocoldef.knight.gsp.faction.crequestapplicantlist2":new()
	require "manager.luaprotocolmanager":send(p)
    return dlg
end

function FactionMain:OnPositionChange()
	local datamanager = require "ui.faction.factiondatamanager"
	if datamanager.positions then
		local position = datamanager.positions[GetDataManager():GetMainCharacterID()]
		if position == 5 then
			self.m_pChangePos:setEnabled(false)
		else
			self.m_pChangePos:setEnabled(true)
		end
	end
end
					 
function FactionMain:GetSelectMemberid() 
    local selecteditem = self.m_pFactionMembers:getFirstSelectedItem()
    if not selecteditem then
        return
    end
    return self.roleids[selecteditem]
end

function FactionMain:HandleEditBroadBtnClicked(e)
	require "ui.faction.factionaim".getInstanceAndShowIt()
	return true
end

function FactionMain:HandleGobackBtnCLicked(e)
	local p = require "protocoldef.knight.gsp.faction.crequestbacktofaction":new()
	require "manager.luaprotocolmanager":send(p)
end

function FactionMain:HandleStartChatBtnClicked(e)
	local memberid = self:GetSelectMemberid()
	if not memberid then
		return true
	end
	if GetFriendsManager() then
        GetFriendsManager():SetContactRole(memberid,"",-1,0,false)
        GetFriendsManager():SetChatRoleID(memberid, "")
    end
end

function FactionMain:HandleAddFriendBtnClicked(e)
	local memberid = self:GetSelectMemberid()
	if not memberid then
		return true
	end
	local p = require "protocoldef.knight.gsp.team.cfinvitejointeam":new()
	p.roleid = memberid
	require "manager.luaprotocolmanager":send(p)
	return true
end

function FactionMain:HandleMemberSelected(e)
	if not self.m_pTips:isVisible() then
		self.m_pTips:setVisible(true)
	end
	local item = self.m_pFactionMembers:getFirstSelectedItem()
	if item then
		LogInsane("selected itemid="..item:getID())
	end
	return true
end

local function getPositionDescribe(position)
	if position == 1 then
		return require "utils.mhsdutils".get_resstring(2882)
	elseif position == 2 then
		return require "utils.mhsdutils".get_resstring(2883)
	elseif position == 3 then
		return require "utils.mhsdutils".get_resstring(2884)
	elseif position == 4 then
		return require "utils.mhsdutils".get_resstring(2885)
	elseif position == 5 then
		return require "utils.mhsdutils".get_resstring(2886)
	else
		return ""
	end
end

function FactionMain:isSelfItem(item)
	local roleid = GetDataManager():GetMainCharacterID()
	return self.roleids[item] == roleid
end

function FactionMain:sort(idx, func)
	local count = self.m_pFactionMembers:getRowCount()
	local items = {}
	for i = 0, count - 1 do
		local ref = CEGUI.MCLGridRef(i, idx)
		local item = self.m_pFactionMembers:getItemAtGridReference(ref)
		table.insert(items, item)
	end
	table.sort(items, func)
	for i = 1, #items do
		LogInsane("sorted, "..items[i]:getText())
		items[i]:setID(i)
	end
end

local function setFirstItemID(list)
	local count = list:getColumnCount()
	local curcolumn = list:getSortColumn()
	for column = 0, count - 1 do
		local ref = CEGUI.MCLGridRef(0, column)
		local item = list:getItemAtGridReference(ref)
		if not item then
			return true
		end
		
		local dir = list:getSortDirection()
		if dir == 0 then
			return true
		end
		if column == curcolumn then
			item:setID(dir == 1 and 0 or 9999)
		else
			item:setID(0)
		end
		LogInsane(string.format("first item=%s, id=%d, dir=%d", item:getText(), item:getID(), dir))
	end
end

function FactionMain:HandleSortDirChanged(e)
	setFirstItemID(self.m_pFactionMembers)
	return true
end

function FactionMain:relocateIDs()
	local datamanager = require "ui.faction.factiondatamanager"
	local function x(roleid1, roleid2)
		local lastonline1, lastonline2
		for i = 1, #datamanager.members do
			if datamanager.members[i].roleid == roleid1 then
				lastonline1 = datamanager.members[i].lastonlinetime
			end
			if datamanager.members[i].roleid == roleid2 then
				lastonline2 = datamanager.members[i].lastonlinetime
			end
		end
		if not lastonline1 and lastonline2 then
			return -1
		end
		if lastonline1 and not lastonline2 then
			return 1
		end
		if not lastonline1 and not lastonline2 then
			return 0
		end
		assert(lastonline1 or lastonline2)
		if lastonline1 == 0 and lastonline2 ~= 0 then
			return 1
		end
		if lastonline2 == 0 and lastonline1 ~= 0 then
			return -1
		end
		return 0
	end
	self:sort(0, function(item1, item2)
		local roleid1 = self.roleids[item1]
		local roleid2 = self.roleids[item2]
		local online = x(roleid1, roleid2)
		if online == 1 then
			return true
		elseif online == -1 then
			return false
		end
		return StringCover.strcmpByPinyin(item1:getText(), item2:getText()) > 0
	end)
	self:sort(1, function(item1, item2)
		local roleid1 = self.roleids_over[1][item1]
		local roleid2 = self.roleids_over[1][item2]
		local online = x(roleid1, roleid2)
		if online == 1 then
			return true
		elseif online == -1 then
			return false
		end
		local num1 = CEGUI.PropertyHelper:stringToUint(item1:getText())
		local num2 = CEGUI.PropertyHelper:stringToUint(item2:getText())
		LogInsane(string.format("cmp %d,%d", num1, num2))
		return num1 > num2
	end)
	 
	self:sort(2, function(item1, item2)
		local roleid1 = self.roleids_over[2][item1]
		local roleid2 = self.roleids_over[2][item2]
		local online = x(roleid1, roleid2)
		 if online == 1 then
			return true
		elseif online == -1 then
			return false
		end
		return item1:getID() > item2:getID()
	end)
 
	self:sort(3, function(item1, item2)
		local roleid1 = self.roleids_over[3][item1]
		local roleid2 = self.roleids_over[3][item2]
		local online = x(roleid1, roleid2)
		if online == 1 then
			return true
		elseif online == -1 then
			return false
		end
		local num1 = CEGUI.PropertyHelper:stringToUint(item1:getText())
		local num2 = CEGUI.PropertyHelper:stringToUint(item2:getText())
		LogInsane(string.format("cmp %d,%d", num1, num2))
		return num1 > num2
	end)
	self:sort(4, function(item1, item2) 
		local roleid1 = self.roleids_over[4][item1]
		local roleid2 = self.roleids_over[4][item2]
		local online = x(roleid1, roleid2)
		if online == 1 then
			return true
		elseif online == -1 then
			return false
		end
		local num1 = CEGUI.PropertyHelper:stringToUint(item1:getText())
		local num2 = CEGUI.PropertyHelper:stringToUint(item2:getText())
		
		return num1 < num2
	end)
	local count = self.m_pFactionMembers:getRowCount()
	local myidx
	for i = 0, count - 1 do
		local ref = CEGUI.MCLGridRef(i, 0)
		local item = self.m_pFactionMembers:getItemAtGridReference(ref)
		local roleid = GetDataManager():GetMainCharacterID()
		if self.roleids[item] == roleid then
			myidx = i
			break
		end
	end
	count = self.m_pFactionMembers:getColumnCount()
	for i = 0, count - 1 do
		local ref = CEGUI.MCLGridRef(myidx, i)
		local item = self.m_pFactionMembers:getItemAtGridReference(ref)
		local dir = self.m_pFactionMembers:getSortDirection()
		if dir == 0 then
			LogInsane(string.format("%s id=%d", item:getText(), 0))
			item:setID(0)
		else
			local curcolumn = self.m_pFactionMembers:getSortColumn()
			if i == curcolumn then
				item:setID(dir == 1 and 9999 or 0)
			else
				item:setID(dir == 1 and 0 or 9999)
			end
		end
	end
end

function FactionMain:HandleSortColChanged(e)
	setFirstItemID(self.m_pFactionMembers)
	return true
end

function FactionMain:InitMember()
	local datamanager = require "ui.faction.factiondatamanager"
    self.m_pFactionBroad:setText(datamanager.factionaim)
    self.m_pFactionId:setText(datamanager.index)
    self.m_pFactionLevel:setText(datamanager.factionlevel)
    self.m_pFactionName:setText(datamanager.factionname)
    self.m_pFactionMaster:setText(datamanager.factionmaster)
    local memstr = string.format("%s/%s", #datamanager.members, self.m_pInfoConfig.num)
    self.m_pFactionMemeberNum:setText(memstr)
    self.rowid = 0
    self.roleids = {}
    self.roleids_over = {}
    for i = 1, 4 do
    	local t = {}
    	table.insert(self.roleids_over, t)
    end
    self.roleid_rowidx = {}

    table.sort(datamanager.members, function(v1, v2)
    	if v1.roleid == GetDataManager():GetMainCharacterID() then
    		return true
    	end
    	if v2.roleid == GetDataManager():GetMainCharacterID() then
    		return false
    	end
    	if v1.lastonlinetime == 0 and v2.lastonlinetime ~= 0 then
    		return true
    	end
    	if v2.lastonlinetime == 0 and v1.lastonlinetime ~= 0 then
    		return false
    	end
    	return StringCover.strcmpByPinyin(v1.rolename, v2.rolename) < 0
    end)
    for i = 1, #datamanager.members do
    	local member = datamanager.members[i]
    	local color = member.lastonlinetime == 0 and "ff33ff33" or "ffa3a3a3"
    	self.m_pFactionMembers:insertRow(self.rowid)
       	local textitem = self:AddFactionListboxItem(member.rolename, 0, self.rowid, color)
       	self.roleids[textitem] = member.roleid
       	table.insert(self.roleid_rowidx, member.roleid)
        textitem = self:AddFactionListboxItem(member.rolelevel, 1, self.rowid, color)
        self.roleids_over[1][textitem] = member.roleid
        textitem = self:AddFactionListboxItem(getPositionDescribe(member.position), 2, self.rowid, color)
        textitem:setID(member.position)
        self.roleids_over[2][textitem] = member.roleid
        textitem = self:AddFactionListboxItem(member.rolecontribution, 3, self.rowid, color)
        self.roleids_over[3][textitem] = member.roleid
        if member.lastonlinetime == 0 then
            textitem = self:AddFactionListboxItem(MHSD_UTILS.get_resstring(354), 4, self.rowid, color)
        else 
            textitem = self:AddFactionListboxItem(MHSD_UTILS.intToDateTime(member.lastonlinetime), 4, self.rowid, color)
        end
        self.roleids_over[4][textitem] = member.roleid
        self.rowid = self.rowid + 1
    end
    self:relocateIDs()
end

function FactionMain:AddFactionListboxItem(title, col_id, row_id, color)
	local color = color or "ffa3a3a3"
	local pItem = CEGUI.createListboxTextItem(title)
	pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
    self.m_pFactionMembers:setItem(pItem, col_id, row_id);
    return pItem;
end
local confirmtype, cmemberid
local function confirmFireMember()
	if confirmtype then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	if cmemberid then
		local send = require "protocoldef.knight.gsp.faction.cfiremember":new()
	    send.memberroleid = cmemberid
	    require "manager.luaprotocolmanager":send(send)
	    cmemberid = nil
    end
end

function FactionMain:HandleFireMemberBtnClicked(e)
	local memberid = self:GetSelectMemberid()
    if not memberid then
        return true
    end
    cmemberid = memberid
    local datamanager = require "ui.faction.factiondatamanager"
    local memname
    for i = 1, #datamanager.members do
    	local member = datamanager.members[i]
    	if member.roleid == memberid then
    		memname = member.rolename
    		break
    	end
    end
    local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145117).msg
	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", memname or "??")
    confirmtype = MHSD_UTILS.addConfirmDialog(sb:GetString(formatstr), confirmFireMember)
    sb:delete()
    
    return true;
end
--[[
function FactionMain:RemoveMember(memberid)
	local membernum = self.m_pFactionMembers:getRowCount()
	for i = 1, membernum do
		local grid_ref = CEGUI.MCLGridRef(i - 1, 0)
		local pitem = self.m_pFactionMembers:getItemAtGridReference(grid_ref)
		if self.roleids[pitem] == memberid then
			self.m_pFactionMembers:removeRow(i - 1)
			break
		end
	end
    return true
end
--]]
local _instance

local function confirmLeaveFaction()
	local self = _instance
	if not self then return end
	self.leavefaction_co = coroutine.create(function()
		if self.confirmdlgtype then
			GetMessageManager():CloseConfirmBox(self.confirmdlgtype, false)
		end
		local send = require "protocoldef.knight.gsp.faction.cleavefaction2":new()
    	require "manager.luaprotocolmanager":send(send)
    	coroutine.yield()
    	self.DestroyDialog()
	end)
	coroutine.resume(self.leavefaction_co)
end				 
function FactionMain:HandleLeaveFactionBtnClicked(e)
	local datamanager = require "ui.faction.factiondatamanager"
    local memnum = datamanager.members and #datamanager.members or 1
	local strMsg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(
		memnum ~= 1 and 145026 or 145075).msg
	self.confirmdlgtype = require "utils.mhsdutils".addConfirmDialog(strMsg, confirmLeaveFaction)
--	confirmLeaveFaction()
    return true;
end

function FactionMain:HandleChangePosBtnClicked(e)
	local memberid = self:GetSelectMemberid()
    if not memberid or memberid == 0 then
        return true
    end
    local dlg = require "ui.faction.factionposition".GetSingletonDialogAndShowIt(memberid)
 	local datamanager = require "ui.faction.factiondatamanager"
 	if datamanager.factionlevel <= 2 then
 		dlg.m_pEssenceBtn:setEnabled(false)
 	end
    dlg.m_pMainFrame:setTopMost(true)
end

function FactionMain:HandleApplylistBtnClicked(e)
	require "ui.faction.factionaccept".GetSingletonDialogAndShowIt()
end

function FactionMain:AddApplicant(member)
	LogInsane("rowid="..self.rowid)
	self.m_pFactionMembers:insertRow(self.rowid)
	local color = member.lastonlinetime == 0 and "ff33ff33" or "ffa3a3a3"
   	local textitem = self:AddFactionListboxItem(member.rolename, 0, self.rowid, color)
   	self.roleids[textitem] = member.roleid
   	table.insert(self.roleid_rowidx, member.roleid)
    self:AddFactionListboxItem(member.rolelevel, 1, self.rowid, color)
    textitem = self:AddFactionListboxItem(getPositionDescribe(member.position), 2, self.rowid, color)
    textitem:setID(member.position)
    self:AddFactionListboxItem(member.rolecontribution, 3, self.rowid, color)
    if member.lastonlinetime == 0 then
        self:AddFactionListboxItem(MHSD_UTILS.get_resstring(354), 4, self.rowid, color)
    else 
        self:AddFactionListboxItem(MHSD_UTILS.intToDateTime(member.lastonlinetime), 4, self.rowid, color)
    end
    self.rowid = self.rowid + 1
    self:relocateIDs()
end

function FactionMain:RemoveApplicant(memberid)
	if not self.roleids then
		return false
	end
	local textitem
	for i = 1, #self.roleid_rowidx do
		if self.roleid_rowidx[i] == memberid then
			table.remove(self.roleid_rowidx, i)
			textitem = i
			break
		end
	end
	if not textitem then
		return false
	end
	self.m_pFactionMembers:removeRow(textitem - 1)
	self.rowid = self.rowid - 1
	return true
end


function FactionMain.getInstanceAndShowIt()
	if not _instance then
		_instance = createdlg()
		require "ui.label"
		if not LabelDlg.getLabelById("jianghu") then
			LabelDlg.InitJianghu()
		end
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true)
	end
	return _instance
end

function FactionMain.getInstance()
	if not _instance then
		_instance = createdlg()
		require "ui.label"
		if not LabelDlg.getLabelById("jianghu") then
			LabelDlg.InitJianghu()
		end
	end
	return _instance
end

function FactionMain.getInstanceOrNot()
	return _instance
end

function FactionMain:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end
function FactionMain.DestroyDialog()
	if _instance then 
		local dlg = LabelDlg.getLabelById("jianghu")
		if dlg then
			dlg:OnClose()
		end
		if _instance then _instance:OnClose() end
		_instance = nil
	end
end

function FactionMain:HandleWeiboShareBtnClicked(args)
	LogInfo("FactionMain HandleWeiboShareBtnClicked")
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cweiboshow", 601)
	local title = record.title
	if record.title == "0" then
		title = ""
	end
	local msg = record.msg
	if record.msg == "0" then
		msg = ""
	end
	local link = record.link
	if record.link == "0" then
		link = ""
	end
    local link1 = record.link1
	if record.link1 == "0" then
		link1 = ""
	end
	local strbuilder = StringBuilder:new()	
	local datamanager = require "ui.faction.factiondatamanager"
	strbuilder:Set("parameter1", datamanager.factionname) 
	
	SDXL.ChannelManager:CommonShare(title, strbuilder:GetString(msg), link, link1)
	strbuilder:delete()
end

function FactionMain:HandleFacebookShareBtnClicked(args)
	LogInfo("FactionMain HandleWeiboShareBtnClicked")
	-- local strbuilder = StringBuilder:new()	
	-- strbuilder:SetNum("parameter1", GetPKManager():getRank())
	--strbuilder:GetString(msg)
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cfacebook", 1)
	local shareinfo = {}
	shareinfo[1] = record.Comment
	shareinfo[2] = record.Link
	shareinfo[3] = record.LinkPicture
	shareinfo[4] = record.LinkName
	shareinfo[5] = record.LinkCaption
	shareinfo[6] = record.LinkDescription


	if Config.TRD_PLATFORM == 1 and Config.isKoreanAndroid() then
		local luaj = require "luaj"
		luaj.callStaticMethod("com.wanmei.korean.KoreanCommon", "ShareFacebook", luaj.checkArguments(shareinfo))
	elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" then
         SDXL.ChannelManager:CommonShare(record.Comment,record.Link, record.LinkPicture, record.LinkName,record.LinkCaption,record.LinkDescription)
	end

	-- strbuilder:delete()
end


return FactionMain
