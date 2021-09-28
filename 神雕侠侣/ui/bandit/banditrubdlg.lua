--[[author: lvxiaolong
date: 2013/9/5
function: band it rub dlg
]]

require "ui.dialog"
require "ui.bandit.banditrubcell"
require "ui.bandit.banditrubteamcell"
require "ui.bandit.banditrubmyteam"
require "protocoldef.knight.gsp.faction.cfreshjbiaolist"
require "protocoldef.knight.gsp.faction.cfreshjbiaoteamlist"
require "protocoldef.knight.gsp.faction.ccreatejbiaoteam"
require "protocoldef.knight.gsp.faction.cleavejbiaoteam"
require "protocoldef.knight.gsp.faction.cjbiaostart"

require "utils.mhsdutils"
require "manager.beanconfigmanager"

BanditRubDlg = {
    
    --bandit car info list type
    Type_BanditListInfo = 0,
    Type_BanditFilterInfo = 1,
    
    m_curTypeCarList = 0,

    m_nCtRubToday = 0,
    
    m_timeRefreshCoolDown = -1,

    --bandit car info
    m_numTotal = 0,

    m_lCells = {},
    m_iMaxCells = 0,

    m_iMaxPage = 1,
	m_iCurPage = 1,
	m_iCellNum = 0,
    m_iOnePageCount = 10,
    m_iBarPos = 0,
    m_listCon = nil,
    
    --bandit rub team info
    m_numTotalRT = 0,

    m_lCellsRT = {},
    m_iMaxCellsRT = 0,

    m_iMaxPageRT = 1,
	m_iCurPageRT = 1,
	m_iCellNumRT = 0,
    m_iOnePageCountRT = 10,
    m_iBarPosRT = 0,
    m_listConRT = nil,
    
    --bandit my rub team info
    m_subDlgMyTeam = nil,
    m_bHaveRubTeam = false,
    m_bIsRubTeamLeader = false,
    m_infoMyRubTeam = nil,
}

g_countRubCarToday = 0

setmetatable(BanditRubDlg, Dialog)
BanditRubDlg.__index = BanditRubDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function BanditRubDlg.IsShow()
    --LogInfo("BanditRubDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function BanditRubDlg.getInstance()
	LogInfo("BanditRubDlg.getInstance")
    if not _instance then
        _instance = BanditRubDlgg:new()
        _instance:OnCreate()
    end

    return _instance
end

function BanditRubDlg.getInstanceAndShow()
	LogInfo("____BanditRubDlg.getInstanceAndShow")
    if not _instance then
        _instance = BanditRubDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function BanditRubDlg.getInstanceNotCreate()
    --print("BanditRubDlg.getInstanceNotCreate")
    return _instance
end

function BanditRubDlg.DestroyDialog()
	if _instance then
        _instance:cleanupPane()
		_instance:OnClose() 
		_instance = nil
	end
end

function BanditRubDlg:HandleCloseBtnClick(args)
    LogInfo("___BanditRubDlg:HandleCloseBtnClick")
    
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145202),BanditRubDlg.HandleQuitRubConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)

	--BanditRubDlg.DestroyDialog()
	return true
end

function BanditRubDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BanditRubDlg:new() 
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

function BanditRubDlg.GetLayoutFileName()
    return "banditall.layout"
end

function BanditRubDlg:OnCreate()
	LogInfo("____enter BanditRubDlg oncreate")

    Dialog.OnCreate(self)
    self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_pGroupBtn = {}
    self.m_pGroupBtn[1] = CEGUI.Window.toGroupButton(winMgr:getWindow("banditall/biaocheliebiao"))
    self.m_pGroupBtn[2] = CEGUI.Window.toGroupButton(winMgr:getWindow("banditall/biaocheliebiao1"))

    self.m_pGroupBtn[1]:setID(self.Type_BanditListInfo)
    self.m_pGroupBtn[1]:subscribeEvent("SelectStateChanged", BanditRubDlg.HandleSelectStateChanged, self)
    
    self.m_pGroupBtn[2]:setID(self.Type_BanditFilterInfo)
    self.m_pGroupBtn[2]:subscribeEvent("SelectStateChanged", BanditRubDlg.HandleSelectStateChanged, self)
    
    self.m_curTypeCarList = self.Type_BanditListInfo
    self.m_pPaneContent = CEGUI.Window.toScrollablePane(winMgr:getWindow("banditall/biaocheshuaxinlist"))
    self.m_pPaneContent:subscribeEvent("NextPage", BanditRubDlg.HandleCarListNextPage, self)

    self.m_pPaneContentRT = CEGUI.Window.toScrollablePane(winMgr:getWindow("banditall/jiebiaolist"))
    self.m_pPaneContentRT:subscribeEvent("NextPage", BanditRubDlg.HandleRTListNextPage, self)
    
    self.m_btnCreateTeam = CEGUI.Window.toPushButton(winMgr:getWindow("banditall/ok"))
    self.m_btnCreateTeam:subscribeEvent("Clicked", BanditRubDlg.HandleClickCreateTeam, self)
    
    self.m_btnChat = CEGUI.Window.toPushButton(winMgr:getWindow("banditall/laba"))
    self.m_btnChat:subscribeEvent("Clicked", BanditRubDlg.HandleClickChat, self)

    self.m_btnRefreshCarList = CEGUI.Window.toPushButton(winMgr:getWindow("banditall/ok11"))
    self.m_btnRefreshCarList:subscribeEvent("Clicked", BanditRubDlg.HandleClickRefreshCarList, self)
    
    self.m_btnRefreshRTList = CEGUI.Window.toPushButton(winMgr:getWindow("banditall/ok1"))
    self.m_btnRefreshRTList:subscribeEvent("Clicked", BanditRubDlg.HandleClickRefreshRTList, self)

    self.m_txtCountRub = winMgr:getWindow("banditall/wenben1")
    
    self.m_picHuawen = winMgr:getWindow("banditall/huawen")
    
    self:GetWindow():subscribeEvent("WindowUpdate", BanditRubDlg.HandleWindowUpdate, self)

    self:ClearDisplay()
    
    self.m_pGroupBtn[1]:setSelected(true)
    self.m_pGroupBtn[2]:setSelected(false)

	LogInfo("exit BanditRubDlg OnCreate")
end

function BanditRubDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BanditRubDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function BanditRubDlg:HandleWindowUpdate(eventArgs)
    
    if self.m_timeRefreshCoolDown < 0 then
        return true
    end
    
    self.m_timeRefreshCoolDown = self.m_timeRefreshCoolDown + CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame*1000
    
    if self.m_timeRefreshCoolDown > 2000 then
        self.m_timeRefreshCoolDown = -1
    end

    return true
end

function BanditRubDlg:HandleSelectStateChanged(args)
    LogInfo("____BanditRubDlg:HandleSelectStateChanged")
    
    local selected = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
    if selected == self.Type_BanditListInfo or selected == self.Type_BanditFilterInfo then
        self.m_curTypeCarList = selected
        
        local reqDataAction = CFreshJBiaoList.Create()
        reqDataAction.flag = self.m_curTypeCarList
        reqDataAction.startindex = 0
        LuaProtocolManager.getInstance():send(reqDataAction)
    end
    
    return true
end

function BanditRubDlg:HandleCarListNextPage(args)
    LogInfo("____BanditRubDlg:HandleCarListNextPage")

	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
            self.m_iBarPos = self.m_pPaneContent:getVertScrollbar():getScrollPosition()
			self.m_pPaneContent:getVertScrollbar():Stop()
            
            local nextStartIndex = (self.m_iCurPage-1) * self.m_iOnePageCount
            LogInfo("____nextStartIndex: " .. nextStartIndex)

            if nextStartIndex > 0 then
                local reqDataAction = CFreshJBiaoList.Create()
                reqDataAction.flag = self.m_curTypeCarList
                reqDataAction.startindex = nextStartIndex
                LuaProtocolManager.getInstance():send(reqDataAction)
            else
                LogInfo("___error in BanditRubDlg:HandleCarListNextPage")
            end
		end
	end
    
	return true
end

function BanditRubDlg:HandleRTListNextPage(args)
    LogInfo("____BanditRubDlg:HandleRTListNextPage")

	if self.m_iMaxPageRT and self.m_iCurPageRT then
		if self.m_iCurPageRT < self.m_iMaxPageRT then
			self.m_iCurPageRT = self.m_iCurPageRT + 1
            self.m_iBarPosRT = self.m_pPaneContentRT:getVertScrollbar():getScrollPosition()
			self.m_pPaneContentRT:getVertScrollbar():Stop()
            
            local nextStartIndex = (self.m_iCurPageRT-1) * self.m_iOnePageCountRT
            LogInfo("____nextStartIndex: " .. nextStartIndex)

            if nextStartIndex > 0 then
                local reqDataAction = CFreshJBiaoTeamList.Create()
                reqDataAction.startindex = nextStartIndex
                LuaProtocolManager.getInstance():send(reqDataAction)
            else
                LogInfo("___error in BanditRubDlg:HandleRTListNextPage")
            end
		end
	end

	return true
end

function BanditRubDlg:HandleClickCreateTeam(args)
    LogInfo("____BanditRubDlg:HandleClickCreateTeam")
    
    local createJBTeamAction = CCreateJBiaoTeam.Create()
    LuaProtocolManager.getInstance():send(createJBTeamAction)

    return true
end

function BanditRubDlg:HandleClickChat(args)
    LogInfo("____BanditRubDlg:HandleClickChat")
    
    CChatOutputDialog:GetSingletonDialogAndShowIt()

    return true
end

function BanditRubDlg:HandleClickRefreshCarList(args)
    LogInfo("____BanditRubDlg:HandleClickRefreshCarList")
    
    if self.m_timeRefreshCoolDown >= 0 then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end

    local reqJBListAction = CFreshJBiaoList.Create()
    reqJBListAction.flag = self.m_curTypeCarList
    reqJBListAction.startindex = 0
    LuaProtocolManager.getInstance():send(reqJBListAction)
    
    self.m_timeRefreshCoolDown = 0

    return true
end

function BanditRubDlg:HandleClickRefreshRTList(args)
    LogInfo("____BanditRubDlg:HandleClickRefreshRTList")
    
    if self.m_timeRefreshCoolDown >= 0 then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end

    if self.m_bHaveRubTeam and self.m_subDlgMyTeam and self.m_subDlgMyTeam.m_pWnd and self.m_subDlgMyTeam.m_pWnd:isVisible() then
    else
        local reqJBTeamListAction = CFreshJBiaoTeamList.Create()
        reqJBTeamListAction.startindex = 0
        LuaProtocolManager.getInstance():send(reqJBTeamListAction)
    end
    
    self.m_timeRefreshCoolDown = 0

    return true
end

function BanditRubDlg:ResetCarList()
	print("____BanditRubDlg:ResetCarList")
    
    self.m_iCurPage = 1
    self.m_lCells = {}
    self.m_iMaxCells = 0
    self.m_iCellNum = 0
    self.m_pPaneContent:cleanupNonAutoChildren()
end

function BanditRubDlg:ResetRTList()
	print("____BanditRubDlg:ResetRTList")
    
    self.m_iCurPageRT = 1
    self.m_lCellsRT = {}
    self.m_iMaxCellsRT = 0
    self.m_iCellNumRT = 0
    self.m_pPaneContentRT:cleanupNonAutoChildren()
end

function BanditRubDlg:HideMyTeam()
    LogInfo("____BanditRubDlg:HideMyTeam")
    
    if self.m_subDlgMyTeam then
        self.m_subDlgMyTeam.m_pWnd:setVisible(false)
        self.m_subDlgMyTeam:ClearContent()
    end
    
    self.m_bHaveRubTeam = false
    self.m_bIsRubTeamLeader = false
    self.m_infoMyRubTeam = nil
end

function BanditRubDlg:ClearMyTeam()
	LogInfo("____BanditRubDlg:ClearMyTeam")
    
    if self.m_subDlgMyTeam then
        self.m_subDlgMyTeam:DestroyDialog()
    end
    
    self.m_bHaveRubTeam = false
    self.m_bIsRubTeamLeader = false
    self.m_infoMyRubTeam = nil
end

function BanditRubDlg:ClearDisplay()
    LogInfo("____BanditRubDlg:ClearDisplay")
    
    self.m_timeRefreshCoolDown = -1
    self.m_txtCountRub:setVisible(false)
    self.m_picHuawen:setVisible(true)

    self:ResetCarList()
    self:ResetRTList()
    self:ClearMyTeam()
end

function BanditRubDlg:HandleQuitRubConfirmClicked(args)
    LogInfo("____BanditRubDlg:HandleQuitRubConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    if self.m_bHaveRubTeam and self.m_subDlgMyTeam and self.m_subDlgMyTeam.m_pWnd and self.m_subDlgMyTeam.m_pWnd:isVisible() then
        local quitAction = CLeaveJBiaoTeam.Create()
        quitAction.roleid = 0
        quitAction.flag = 1
        LuaProtocolManager.getInstance():send(quitAction)
    else
        self:ClearDisplay()
        BanditRubDlg.DestroyDialog()
    end

    return true
end

function BanditRubDlg:RefreshCtRubToday(nCtRubToday)
    LogInfo("____BanditRubDlg:RefreshCtRubToday")
    
    self.m_nCtRubToday = nCtRubToday
    
    self.m_txtCountRub:setVisible(true)
    self.m_txtCountRub:setText(tostring(self.m_nCtRubToday) .. "/7")
    
end

function BanditRubDlg:RefreshCarList(typeCarList, totalnum, startindex, dataCarList)
    LogInfo("____BanditRubDlg:RefreshCarList")
    
    LogInfo("____totalnum: " .. totalnum .. " startindex: " .. startindex)
    
    if typeCarList ~= self.m_curTypeCarList then
        return
    end
    
    if startindex == 0 then
        self.m_numTotal = totalnum
        self.m_iMaxPage = math.ceil(self.m_numTotal/self.m_iOnePageCount)
        self.m_iCurPage = 1
        self.m_iCellNum = 0
        self.m_iBarPos = 0
    end
    
    self:RefreshListCon(startindex, dataCarList)
    self:RefreshOpponent()
end

function BanditRubDlg:RefreshListCon(startindex, dataCarList)
    LogInfo("____BanditRubDlg:RefreshListCon")
    
    LogInfo("____startindex: " .. startindex)
    
    self.m_listCon = self.m_listCon or {}
    
    if startindex == 0 then
        self.m_listCon = {}
    end
    
    local num = 0
    if startindex >= 0 then
        for k,v in pairs(dataCarList) do
            num = num+1
            self.m_listCon[startindex+num] = v
        end
    end
    LogInfo("____num: " .. num)
    
    LogInfo("____#self.m_listCon: " .. #self.m_listCon)
end

function BanditRubDlg:RefreshOpponent()
    LogInfo("____BanditRubDlg:RefreshOpponent")
    
    self.m_picHuawen:setVisible(true)
    
    if not self.m_listCon then
        return
    end

    if not self.m_iCurPage then
		return
	end

    for indexTest = 1, #self.m_listCon, 1 do
        local curCon = self.m_listCon[indexTest]
        if  curCon then
            --print("____curIndex: " .. indexTest .. " curCon.rolename: " .. curCon.rolename)
            print("____curIndex: " .. indexTest .. " exist")
        else
            print("____curIndex: " .. indexTest .. " not exist")
        end
    end

    local numTotal = self.m_numTotal

	local startPos = (self.m_iCurPage - 1) * self.m_iOnePageCount + 1

	local endPos = self.m_iCurPage * self.m_iOnePageCount
	if endPos > numTotal then
		endPos = numTotal
	end

    self.m_iCellNum = self.m_iCellNum or 0
    
    local i = self.m_iCellNum
    
    LogInfo("___beforeAddCellNum: " .. self.m_iCellNum)
	for index = startPos, endPos, 1 do

        if self.m_iMaxCells < index then
				self.m_iMaxCells = index
				self.m_lCells[self.m_iMaxCells] = BanditRubCell.CreateNewDlg(self.m_pPaneContent, self.m_iMaxCells)
        end
        
        local myself = self.m_lCells[index]
        
        local xpos = 1 
        local ypos = 1 + (5+myself.m_pWnd:getPixelSize().height) * (index-1)
        myself.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
        myself.m_pWnd:setVisible(true)
        
        local infoCell = self.m_listCon[index]
        if infoCell then
            local nCarKey = infoCell.biaochekey
            local nCarType = infoCell.biaochetype
            local strLeaderName = infoCell.rolename
            local nCamp = infoCell.camp
            local strFaction = infoCell.factionname
            local nAverageLv = infoCell.avglevel
            myself:SetContent(nCarKey, nCarType, strLeaderName, nCamp, strFaction, nAverageLv)
        else
            myself:ClearContent()
        end

        i = i+1
	end
    
    self.m_iCellNum = i
    
    if self.m_iCellNum > 0 then
        self.m_picHuawen:setVisible(false)
    end

    LogInfo("___afterAddCellNum: " .. self.m_iCellNum)

    for j = self.m_iCellNum+1, self.m_iMaxCells, 1 do
        self.m_lCells[j].m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,1)))
        self.m_lCells[j].m_pWnd:setVisible(false)
    end
    
    --set scroll bar pos
    if self.m_iCurPage == 1 then
        self.m_pPaneContent:getVertScrollbar():setScrollPosition(0)
    else
        self.m_pPaneContent:getVertScrollbar():setScrollPosition(self.m_iBarPos)
    end
end

function BanditRubDlg:RefreshMyTeam(leaderid, teamroles)
    LogInfo("____BanditRubDlg:RefreshMyTeam")
    
    if leaderid == nil or teamroles == nil then
        return
    end
    
    local numTeamMember = 0
    for k,v in pairs(teamroles) do
        numTeamMember = numTeamMember + 1
    end

    if leaderid <= 0 or numTeamMember <= 0 then
        self:HideMyTeam()
        return
    end
    
    self:HideRTList()

    if not self.m_subDlgMyTeam then
        self.m_subDlgMyTeam = BanditRubMyTeam.CreateNewDlg(self.m_pPaneContentRT, 0)
        self.m_subDlgMyTeam.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,1)))
    end
    if self.m_subDlgMyTeam then
        self.m_subDlgMyTeam.m_pWnd:setVisible(true)
        self.m_subDlgMyTeam:SetContent(leaderid, teamroles)
    end
    
    self.m_bHaveRubTeam = true
    if GetDataManager() and leaderid == GetDataManager():GetMainCharacterID() then
        self.m_bIsRubTeamLeader = true
    else
        self.m_bIsRubTeamLeader = false
    end
    self.m_infoMyRubTeam = teamroles
    
    self.m_btnCreateTeam:setEnabled(false)
    self.m_btnRefreshRTList:setEnabled(false)
end

function BanditRubDlg:RefreshRTList(totalnum, startindex, dataRTList)
    LogInfo("____BanditRubDlg:RefreshRTList")
    
    LogInfo("____totalnum: " .. totalnum .. " startindex: " .. startindex)
    
    --clear my team info
    self:HideMyTeam()
    
    if startindex == 0 then
        self.m_numTotalRT = totalnum
        self.m_iMaxPageRT = math.ceil(self.m_numTotalRT/self.m_iOnePageCountRT)
        self.m_iCurPageRT = 1
        self.m_iCellNumRT = 0
        self.m_iBarPosRT = 0
    end
    
    self:RefreshListConRT(startindex, dataRTList)
    self:RefreshOpponentRT()
    
    self.m_btnCreateTeam:setEnabled(true)
    self.m_btnRefreshRTList:setEnabled(true)
end

function BanditRubDlg:RefreshListConRT(startindex, dataRTList)
    LogInfo("____BanditRubDlg:RefreshListConRT")
    
    LogInfo("____startindex: " .. startindex)
    
    self.m_listConRT = self.m_listConRT or {}
    
    if startindex == 0 then
        self.m_listConRT = {}
    end
    
    local num = 0
    if startindex >= 0 then
        for k,v in pairs(dataRTList) do
            num = num+1
            self.m_listConRT[startindex+num] = v
        end
    end
    LogInfo("____num: " .. num)
    
    LogInfo("____#self.m_listConRT: " .. #self.m_listConRT)
end

function BanditRubDlg:RefreshOpponentRT()
    LogInfo("____BanditRubDlg:RefreshOpponentRT")

    if not self.m_listConRT then
        return
    end

    if not self.m_iCurPageRT then
		return
	end

    for indexTest = 1, #self.m_listConRT, 1 do
        local curCon = self.m_listConRT[indexTest]
        if  curCon then
            print("____curIndex: " .. indexTest .. " exist")
            --print("____curIndex: " .. indexTest .. " curCon.rolename: " .. curCon.rolename)
        else
            print("____curIndex: " .. indexTest .. " not exist")
        end
    end

    local numTotal = self.m_numTotalRT

	local startPos = (self.m_iCurPageRT - 1) * self.m_iOnePageCountRT + 1

	local endPos = self.m_iCurPageRT * self.m_iOnePageCountRT
	if endPos > numTotal then
		endPos = numTotal
	end

    self.m_iCellNumRT = self.m_iCellNumRT or 0
    
    local i = self.m_iCellNumRT
    
    LogInfo("___beforeAddCellNumRT: " .. self.m_iCellNumRT)
	for index = startPos, endPos, 1 do

        if self.m_iMaxCellsRT < index then
				self.m_iMaxCellsRT = index
				self.m_lCellsRT[self.m_iMaxCellsRT] = BanditRubTeamCell.CreateNewDlg(self.m_pPaneContentRT, self.m_iMaxCellsRT)
        end
        
        local myself = self.m_lCellsRT[index]
        
        local xpos = 1 
        local ypos = 1 + (5+myself.m_pWnd:getPixelSize().height) * (index-1)
        myself.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
        myself.m_pWnd:setVisible(true)
        
        local infoCell = self.m_listConRT[index]
        if infoCell then
            local nRubLeaderRoleID = infoCell.leaderid
            local nShape = infoCell.shape
            local strRubLeaderName = infoCell.leadername
            local nCtRubTeam = infoCell.teamnum
            myself:SetContent(nRubLeaderRoleID, nShape, strRubLeaderName, nCtRubTeam)
        else
            myself:ClearContent()
        end

        i = i+1
	end
    
    self.m_iCellNumRT = i
    
    LogInfo("___afterAddCellNumRT: " .. self.m_iCellNumRT)

    for j = self.m_iCellNumRT+1, self.m_iMaxCellsRT, 1 do
        self.m_lCellsRT[j].m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,1)))
        self.m_lCellsRT[j].m_pWnd:setVisible(false)
    end
    
    --set scroll bar pos
    if self.m_iCurPageRT == 1 then
        self.m_pPaneContentRT:getVertScrollbar():setScrollPosition(0)
    else
        self.m_pPaneContentRT:getVertScrollbar():setScrollPosition(self.m_iBarPosRT)
    end
end

function BanditRubDlg:HideRTList()
    LogInfo("____BanditRubDlg:HideRTList")

    for i = 1, self.m_iMaxCellsRT, 1 do
        if self.m_lCellsRT[i] and self.m_lCellsRT[i].m_pWnd then
            self.m_lCellsRT[i].m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,1)))
            self.m_lCellsRT[i].m_pWnd:setVisible(false)
        end
    end
    self.m_pPaneContentRT:getVertScrollbar():setScrollPosition(0)
end

function BanditRubDlg:cleanupPane()
    LogInfo("____BanditRubDlg:cleanupPane")
    
    self.m_pPaneContent:cleanupNonAutoChildren()
    self.m_pPaneContentRT:cleanupNonAutoChildren()
end


return BanditRubDlg
