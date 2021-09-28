require "ui.dialog"
require "ui.faction.factiondatamanager"
FamilyFound = {}
setmetatable(FamilyFound, Dialog)
FamilyFound.__index = FamilyFound
local npcid = 10012
local pagesize = 20
local _instance
local function createdlg()
	assert(not _instance)
	local dlg = {}
	setmetatable(dlg, FamilyFound)
--	dlg.__index = FamilyFound
	function dlg.GetLayoutFileName()
		return "familyfound.layout"
	end
	Dialog.OnCreate(dlg)
	local winMgr = CEGUI.WindowManager:getSingleton()
	dlg.m_pGroup = winMgr:getWindow("familyfound/zhenying")
	dlg.m_pFaction = winMgr:getWindow("familyfound/family")
	
	dlg.m_pGoCampNpcBtn = CEGUI.toPushButton(winMgr:getWindow("familyfound/go"))
	dlg.m_pNpcLinkText = CEGUI.toRichEditbox(winMgr:getWindow("familyfound/case/text2/npc"))
    dlg.m_pSubscribeJoin = CEGUI.toPushButton(winMgr:getWindow("familyfound/aply"))
    dlg.m_pConnectBangzhu = CEGUI.toPushButton(winMgr:getWindow("familyfound/friend"))
    dlg.m_pCreateFaction = CEGUI.toPushButton(winMgr:getWindow("familyfound/found"))
    dlg.m_pFactionIntroduce = winMgr:getWindow("familyfound/case/text")
    dlg.m_pFactionList = CEGUI.toMultiColumnList(winMgr:getWindow("familyfound/FamilyFrame/FamilyMember"))
 	
    dlg.m_pCreateFaction:subscribeEvent("Clicked", FamilyFound.HandleCreateFactionBtn, dlg)
    dlg.m_pFactionList:subscribeEvent("SelectionChanged", FamilyFound.HandleFactionSelected, dlg)
    dlg.m_pSubscribeJoin:subscribeEvent("Clicked", FamilyFound.HandleApplyFaction, dlg)
    dlg.m_pConnectBangzhu:subscribeEvent("Clicked", FamilyFound.HandleContactMaster, dlg)
    dlg.m_pNpcLinkText:setReadOnly(true)
    local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(npcid)
    local npcname = npcConfig.name
    --CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff000000"))
    dlg.m_pNpcLinkText:AppendLinkText(CEGUI.String(npcname))
    dlg.m_pNpcLinkText:Refresh()
    dlg.m_pNpcLinkText:subscribeEvent("MouseButtonDown", FamilyFound.HandleLinkNpcBtnDown, dlg)
    dlg.m_pGoCampNpcBtn:subscribeEvent("Clicked", FamilyFound.HandleGoCampBtnClicked, dlg)
    
    dlg.m_pFactionIntroduce:setText("")
 
 	dlg.roleids = {}
    local factions = FactionDataManager.GetFactions()
    local s = #factions <= pagesize and #factions or pagesize
    local rowId = 0
    for i = 1, s do
    	local faction = factions[i]
        dlg.m_pFactionList:addRow()
        local pitem = dlg:AddFactionListboxItem(faction.index, 0, rowId)
        dlg.roleids[pitem] = faction.factionmasterid
        dlg:AddFactionListboxItem(faction.factionname, 1, rowId)
        dlg:AddFactionListboxItem(faction.factionlevel, 2, rowId)
        dlg:AddFactionListboxItem(faction.membernum, 3, rowId)
        dlg:AddFactionListboxItem(faction.factionmastername, 4, rowId)
        rowId = rowId + 1
    end
    dlg.m_iCurpage = 1
    dlg.m_pFactionList:subscribeEvent("NextPage", FamilyFound.HandleFactionNextPage, dlg)
	if #factions > 0 then
		if dlg.m_pFactionList:getRowCount() > 0 then
			local grid_ref = CEGUI.MCLGridRef(0, 0)
			dlg.m_pFactionList:setItemSelectState(grid_ref, true)
		end
	end
	return dlg
end
function FamilyFound:HandleFactionNextPage(e)
--	print("FamilyFound:HandleFactionNextPage")
	local startidx = self.m_iCurpage * pagesize + 1
	local factions = FactionDataManager.GetFactions()
	if startidx <= #factions then
		for i = startidx, startidx + pagesize - 1 do
			if i > #factions then
				break
			end
			local faction = factions[i]
			local rowId = i - 1
	        self.m_pFactionList:addRow()
	        local pitem = self:AddFactionListboxItem(faction.index, 0, rowId)
	        self.roleids[pitem] = faction.factionmasterid
	        self:AddFactionListboxItem(faction.factionname, 1, rowId)
	        self:AddFactionListboxItem(faction.factionlevel, 2, rowId)
	        self:AddFactionListboxItem(faction.membernum, 3, rowId)
	        self:AddFactionListboxItem(faction.factionmastername, 4, rowId)
		end
		self.m_iCurpage = self.m_iCurpage + 1
	end
	return true
end
local function gotoNpc()
	
	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(npcid)	
	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, npcConfig.id)
end

function FamilyFound:HandleLinkNpcBtnDown(e)
	gotoNpc()
	self.DestroyDialog()
end

function FamilyFound:HandleGoCampBtnClicked(e)
	gotoNpc()
	self.DestroyDialog()
end

function FamilyFound:GetSelectMemberid() 
    local selecteditem = self.m_pFactionList:getFirstSelectedItem()
    if not selecteditem then
        return
    end
    return self.roleids[selecteditem]
end

function FamilyFound:HandleContactMaster(e)
    local masterid = self:GetSelectMemberid()
	if not masterid then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(145106)
        end
		return true
	end
    --xiaolong added for not appear friendchat window bug
	if GetFriendsManager() then
        GetFriendsManager():SetContactRole(masterid,"",-1,0,false)
        GetFriendsManager():SetChatRoleID(masterid, "")
    end
    
    return true
end

function FamilyFound:AddFactionListboxItem(title, col_id, row_id)
--- may cause crash
	local pItem = CEGUI.createListboxTextItem(title)
	pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
 --   pItem:SetTextHorFormat(1)
    self.m_pFactionList:setItem(pItem, col_id, row_id)
    return pItem
end

function FamilyFound:HandleCreateFactionBtn(e)
--CFactionFoundCheck::GetSingletonDialogAndShowIt();
	require "ui.faction.factionfoundcheck"
	FactionFoundCheck.getInstance()
	return true
end

function FamilyFound:HandleFactionSelected(e)
	local selecteditem = self.m_pFactionList:getFirstSelectedItem()
    if not selecteditem then
        self.m_pFactionIntroduce:setText("")
        return true
    end
    local row_id = self.m_pFactionList:getItemRowIndex(selecteditem)
    local numGrid = CEGUI.MCLGridRef(row_id, 0)
    local pIdItem = self.m_pFactionList:getItemAtGridReference(numGrid)
    local index = CEGUI.PropertyHelper:stringToUint(pIdItem:getText())
    local factiondata = FactionDataManager.at(index)
    if not factiondata then
        self.m_pFactionIntroduce:setText("")
    else
    	if not factiondata.aim then
	    	self.m_pFactionIntroduce:setText("")
	        local p = require "protocoldef.knight.gsp.faction.crequestfactionaim":new()
	        p.factionid = factiondata.factionid
	        require "manager.luaprotocolmanager":send(p)
	    else
	    	self.m_pFactionIntroduce:setText(factiondata.aim)
        end
        
    end
    return true;
end

function FamilyFound:HandleApplyFaction(e) 
    local pSelectedItem = self.m_pFactionList:getFirstSelectedItem()
    if not pSelectedItem then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(145106)
        end
        return true
    end
    local row_id = self.m_pFactionList:getItemRowIndex(pSelectedItem)
    local numGrid = CEGUI.MCLGridRef(row_id, 0)
    local pIdItem = self.m_pFactionList:getItemAtGridReference(numGrid)
    local index = CEGUI.PropertyHelper:stringToUint(pIdItem:getText())
    local factiondata = FactionDataManager.at(index)
    if factiondata then
	    local send = require "protocoldef.knight.gsp.faction.capplyfaction2":new()
	    send.factionid = factiondata.factionid
	    LuaProtocolManager.getInstance():send(send)
    end
    return true
end

function FamilyFound:Show(mode)
	if mode == 0 then
		self:SetVisible(false)
	elseif mode == 1 then
		self.m_pGroup:setVisible(true)
		self.m_pFaction:setVisible(false)
	else
		self.m_pGroup:setVisible(false)
		self.m_pFaction:setVisible(true)
	end
end

function FamilyFound.getInstance()
	if not _instance then
		_instance = createdlg()
		require "ui.label"
		if not LabelDlg.getLabelById("jianghu") then
			LabelDlg.InitJianghu()
		end
	end
	return _instance
end

function FamilyFound.getInstanceOrNot()
	return _instance
end

function FamilyFound:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function FamilyFound.DestroyDialog()
	if _instance then
		local dlg = LabelDlg.getLabelById("jianghu")
		if dlg then
			dlg:OnClose()
		end
		if _instance then _instance:OnClose() end
		_instance = nil
	end
end

return FamilyFound