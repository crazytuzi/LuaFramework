--[[author: lvxiaolong
date: 2013/8/6
function: quick team dlg
]]

require "ui.dialog"
require "ui.quickteam.quickteambtn"
require "ui.quickteam.quickteamcell"

require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.team.bianjie.cbjjoin"
require "protocoldef.knight.gsp.team.bianjie.cbjquit"
require "protocoldef.knight.gsp.team.bianjie.crequestbjdata"


QuickTeamDlg = {
    
    m_numTotal = 0,

    m_lCells = {},
    m_iMaxCells = 0,

    m_iMaxPage = 1,
	m_iCurPage = 1,
	m_iCellNum = 0,
    m_iOnePageCount = 20,
    m_iBarPos = 0,
    m_listCon = nil,
}
setmetatable(QuickTeamDlg, Dialog)
QuickTeamDlg.__index = QuickTeamDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function QuickTeamDlg:GetMinimizeBtnPos()
    LogInfo("____QuickTeamDlg:GetMinimizeBtnPos")
    if self.m_btnMinimize then
    
        local posMizeBtn = {}
        posMizeBtn.x = self.m_btnMinimize:GetScreenPos().x
        posMizeBtn.y = self.m_btnMinimize:GetScreenPos().y
        
        return true, posMizeBtn
    else
        return false, nil
    end
end

function QuickTeamDlg.IsShow()
    --LogInfo("QuickTeamDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function QuickTeamDlg.getInstance()
	LogInfo("QuickTeamDlg.getInstance")
    if not _instance then
        _instance = QuickTeamDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function QuickTeamDlg.getInstanceAndShow()
	LogInfo("____QuickTeamDlg.getInstanceAndShow")
    if not _instance then
        _instance = QuickTeamDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function QuickTeamDlg.getInstanceNotCreate()
    --print("QuickTeamDlg.getInstanceNotCreate")
    return _instance
end

function QuickTeamDlg.DestroyDialog()
	if _instance then
        _instance:cleanupPane()
		_instance:OnClose() 
		_instance = nil
	end
end

function QuickTeamDlg:HandleCloseBtnClick(args)
    LogInfo("___QuickTeamDlg:HandleCloseBtnClick")
    
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145133),QuickTeamDlg.HandleQuitQTeamConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)

	--QuickTeamDlg.DestroyDialog()
	return true
end

function QuickTeamDlg.ToggleOpenClose()
	if not _instance then 
		_instance = QuickTeamDlg:new() 
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

function QuickTeamDlg.GetLayoutFileName()
    return "quickteamdlg.layout"
end

function QuickTeamDlg:OnCreate()
	LogInfo("enter QuickTeamDlg oncreate")

    Dialog.OnCreate(self)
    self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_btnMinimize = CEGUI.Window.toPushButton(winMgr:getWindow("quickteamdlg/small"))
    self.m_btnMinimize:subscribeEvent("Clicked", QuickTeamDlg.HandleClickeMinimize, self)

    self.m_txtDungMode = winMgr:getWindow("quickteamdlg/txt0")
    self.m_rEditBoxInQueue = CEGUI.Window.toRichEditbox(winMgr:getWindow("quickteamdlg/txt1"))
    
    self.m_pPaneContent = CEGUI.Window.toScrollablePane(winMgr:getWindow("quickteamdlg/back/main"))
    self.m_pPaneContent:subscribeEvent("NextPage", QuickTeamDlg.HandleQuickTeamNextPage, self)
    
    self.m_btnShout = CEGUI.Window.toPushButton(winMgr:getWindow("quickteamdlg/call"))
    self.m_btnShout:subscribeEvent("Clicked", QuickTeamDlg.HandleClickeShout, self)
    --self.m_btnShout:setVisible(false)

    self.m_btnRefresh = CEGUI.Window.toPushButton(winMgr:getWindow("quickteamdlg/call1"))
    self.m_btnRefresh:subscribeEvent("Clicked", QuickTeamDlg.HandleClickeRefresh, self)

    self:ClearDisplay()
    
	LogInfo("exit QuickTeamDlg OnCreate")
end

function QuickTeamDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QuickTeamDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function QuickTeamDlg:HandleClickeMinimize(args)
    LogInfo("____QuickTeamDlg:HandleClickeMinimize")
    
    local bFoundMizePos, posStart = self:GetMinimizeBtnPos()

    QuickTeamDlg.ToggleOpenClose()
    local dlgQuickTeamBtn = QuickTeamBtn.getInstanceAndShow()
    
    if dlgQuickTeamBtn and bFoundMizePos and posStart then
        dlgQuickTeamBtn:StartFly(1000, posStart)
    end

    return true
end

function QuickTeamDlg:HandleClickeShout(args)
    LogInfo("____QuickTeamDlg:HandleClickeShout")
    
    if g_curQTeamServiceID < 0 or not GetDataManager() then
        return true
    end
    
    if GetTeamManager() and GetTeamManager():IsOnTeam() then
        if GetGameUIManager() then
            GetGameUIManager():AddMessageTipById(145140)
        end
        return true
    end

    local strbuilder1 = StringBuilder:new()
    local strbuilder2 = StringBuilder:new()
    
    local roleLevel = GetDataManager():GetMainCharacterLevel() 
    if roleLevel then
        strbuilder1:SetNum("parameter1", roleLevel)
        strbuilder2:SetNum("parameter1", roleLevel)
    end
    
    local nSchool = GetDataManager():GetMainCharacterSchoolID()
    if nSchool then
        local record = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(nSchool)
        if record and record.id ~= -1 and record.name then
            strbuilder1:Set("parameter2", record.name)
            strbuilder2:Set("parameter2", record.name)
        end
    end

    local ttBJ = BeanConfigManager.getInstance():GetTableByName("knight.gsp.team.cbianjie")
    local recordBJ = ttBJ:getRecorder(g_curQTeamServiceID)
    
    if recordBJ and recordBJ.id ~= -1 and recordBJ.miaoshu then
        strbuilder1:Set("parameter3", recordBJ.miaoshu)
        strbuilder2:Set("parameter3", recordBJ.miaoshu)
    end
    
    local inputChannel = 1
    local strChatContent = strbuilder1:GetString(MHSD_UTILS.get_msgtipstring(145137))
    local strPureText = strbuilder2:GetString(MHSD_UTILS.get_msgtipstring(145138))
    
    print("____strChatContent: " .. strChatContent)
    print("____strPureText: " .. strPureText)

    local showinfos = std.vector_knight__gsp__msg__ShowInfo_()
    showinfos:clear()

    local ChatCmd = knight.gsp.msg.CSendChatMsg(inputChannel, strChatContent, strPureText, showinfos)
    GetNetConnection():send(ChatCmd)
    
    strbuilder1:delete()
    strbuilder2:delete()

    return true
end

function QuickTeamDlg:HandleClickeRefresh(args)
    LogInfo("____QuickTeamDlg:HandleClickeRefresh")
    
    if g_curQTeamServiceID < 0 then
        return
    end

    local reqDataAction = CRequestBJData.Create()
    reqDataAction.serviceid = g_curQTeamServiceID
    reqDataAction.startindex = 0
    LuaProtocolManager.getInstance():send(reqDataAction)

    return true
end

function QuickTeamDlg:HandleQuickTeamNextPage(args)
    LogInfo("____QuickTeamDlg:HandleQuickTeamNextPage")
    
	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
            self.m_iBarPos = self.m_pPaneContent:getVertScrollbar():getScrollPosition()
			self.m_pPaneContent:getVertScrollbar():Stop()
            
            local nextStartIndex = (self.m_iCurPage-1) * self.m_iOnePageCount
            LogInfo("____nextStartIndex: " .. nextStartIndex)

            if nextStartIndex > 0 then
                local reqDataAction = CRequestBJData.Create()
                reqDataAction.serviceid = g_curQTeamServiceID
                reqDataAction.startindex = nextStartIndex
                LuaProtocolManager.getInstance():send(reqDataAction)
            else
                LogInfo("___error in QuickTeamDlg:HandleQuickTeamNextPage")
            end
		end
	end
    
	return true
end

function QuickTeamDlg:HandleQuitQTeamConfirmClicked(args)
    LogInfo("____QuickTeamDlg:HandleQuitQTeamConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    QuickTeamDlg.DestroyDialog()
    QuickTeamBtn.DestroyDialog()

    if g_curQTeamServiceID < 0 then
        return true
    end
    
    local quitAction = CBJQuit.Create()
    quitAction.serviceid = g_curQTeamServiceID
    LuaProtocolManager.getInstance():send(quitAction)
    g_curQTeamServiceID = -1

    return true
end

function QuickTeamDlg:HandleJoinAnotherConfirmClicked(args)
	LogInfo("____QuickTeamDlg:HandleJoinAnotherConfirmClicked")
    
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    if g_curQTeamServiceID < 0 then
        return true
    end

    local joinAction = CBJJoin.Create()
    joinAction.serviceid = g_curQTeamServiceID
    LuaProtocolManager.getInstance():send(joinAction)

    return true
end

function QuickTeamDlg:RefreshListPage(serviceid,oldserviceid,totalnum,inqueue,startindex,bjdata)
    LogInfo("____QuickTeamDlg:RefreshListPage")
    
    LogInfo("____startindex: " .. startindex .. " serviceid: " .. serviceid .. " oldserviceid: " .. oldserviceid)

    --refresh the dialog
    if startindex == 0 then

        g_curQTeamServiceID = serviceid

        --have joined other team queue before, pop up the join new team queue confirm dialog
        if serviceid ~= oldserviceid then
        GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145134),QuickTeamDlg.HandleJoinAnotherConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
        
            return
        end
        
        self:SetVisible(true)

        self.m_rEditBoxInQueue:setVisible(true)
        self.m_rEditBoxInQueue:Clear()
        if inqueue == 0 then
            self.m_rEditBoxInQueue:AppendParseText(CEGUI.String(MHSD_UTILS.get_msgtipstring(145131)))
        else
            self.m_rEditBoxInQueue:AppendParseText(CEGUI.String(MHSD_UTILS.get_msgtipstring(145130)))
        end
        self.m_rEditBoxInQueue:Refresh()

        local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.team.cbianjie")
        local record = tt:getRecorder(serviceid)
        
        if record and record.id ~= -1 and record.miaoshu then
            self.m_txtDungMode:setVisible(true)
            self.m_txtDungMode:setText(record.miaoshu)
        else
            self.m_txtDungMode:setVisible(false)
        end

        self.m_numTotal = totalnum
        self.m_iMaxPage = math.ceil(self.m_numTotal/self.m_iOnePageCount)
        self.m_iCurPage = 1
        self.m_iCellNum = 0
        self.m_iBarPos = 0

        if serviceid ~= g_curQTeamServiceID then
            if g_curQTeamServiceID >= 0 then
                local quitAction = CBJQuit.Create()
                quitAction.serviceid = g_curQTeamServiceID
                LuaProtocolManager.getInstance():send(quitAction)
            end
        end
    end
    
    self:RefreshListCon(startindex, bjdata)
    self:RefreshOpponent()
end

function QuickTeamDlg:RefreshListCon(startindex, bjdata)
    LogInfo("____QuickTeamDlg:RefreshListCon")
    
    LogInfo("____startindex: " .. startindex)
    
    self.m_listCon = self.m_listCon or {}
    
    if startindex == 0 then
        self.m_listCon = {}
    end
    
    if startindex >= 0 then
        local num = #bjdata
        
        LogInfo("____num: " .. num)

        local startPos = startindex+1
        local endPos = startPos+num-1
        
        for i = startPos, endPos, 1 do
            self.m_listCon[i] = bjdata[i-startPos+1]
        end
    end
    
    LogInfo("____#self.m_listCon: " .. #self.m_listCon)
end

function QuickTeamDlg:RefreshOpponent()
    LogInfo("____QuickTeamDlg:RefreshOpponent")

    if not self.m_listCon then
        return
    end

    if not self.m_iCurPage then
		return
	end
    
    for indexTest = 1, #self.m_listCon, 1 do
        local curCon = self.m_listCon[indexTest]
        if  curCon then
            print("____curIndex: " .. indexTest .. " curCon.rolename: " .. curCon.rolename)
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
				self.m_lCells[self.m_iMaxCells] = QuickTeamCell.CreateNewDlg(self.m_pPaneContent, self.m_iMaxCells)
        end
        
        local myself = self.m_lCells[index]
        
        local row = math.floor((index-1)/2)
        local column = math.floor(math.mod(index-1,2))
        local xpos = 10 + myself.m_pWnd:getPixelSize().width * column 
        local ypos = 1 + (5+myself.m_pWnd:getPixelSize().height) * row
        myself.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
        myself.m_pWnd:setVisible(true)
        
        local infoCell = self.m_listCon[index]
        if infoCell then
            local nRoleID = infoCell.roleid
            local strName = infoCell.rolename
            local nLevel = infoCell.rolelevel
            local nSchool = infoCell.school
            local nCamp = infoCell.camp
            myself:SetContent(nRoleID, strName, nLevel, nSchool, nCamp)
        else
            myself:ClearContent()
        end

        i = i+1
	end
    
    self.m_iCellNum = i
    
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

function QuickTeamDlg:ResetList()
	print("____QuickTeamDlg:ResetList")
    
    self.m_iCurPage = 1
    self.m_lCells = {}
    self.m_iMaxCells = 0
    self.m_iCellNum = 0
    self.m_pPaneContent:cleanupNonAutoChildren()
end

function QuickTeamDlg:ClearDisplay()
    LogInfo("____QuickTeamDlg:ClearDisplay")

    self.m_txtDungMode:setVisible(false)
    self.m_rEditBoxInQueue:setVisible(false)

    self:ResetList()
end

function QuickTeamDlg:cleanupPane()
    LogInfo("____QuickTeamDlg:cleanupPane")
    
    self.m_pPaneContent:cleanupNonAutoChildren()
end


return QuickTeamDlg
