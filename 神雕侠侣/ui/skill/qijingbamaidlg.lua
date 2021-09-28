--qijingbamai.lua
--It is a dialog for qijingbamai
--create by wuyao in 2014-2-25
require "ui.dialog"
require "utils.mhsdutils"

QijingbamaiDlg = {}
setmetatable(QijingbamaiDlg, Dialog)
QijingbamaiDlg.__index = QijingbamaiDlg

local SHEDAN_ID = 39844

--For singleton
local _instance
function QijingbamaiDlg.getInstance()
    if not _instance then
        _instance = QijingbamaiDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function QijingbamaiDlg.getInstanceAndShow()
    if not _instance then
        _instance = QijingbamaiDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function QijingbamaiDlg.getInstanceNotCreate()
    return _instance
end

function QijingbamaiDlg:OnClose()
    Dialog.OnClose(self)
    _instance = nil
end

function QijingbamaiDlg.DestroyDialog()
    if _instance then
        if SkillLable.getInstanceNotCreate() then
            SkillLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end

    end
end

function QijingbamaiDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()
        _instance = nil
    end
end

function QijingbamaiDlg.ToggleOpenClose()
    if not _instance then 
        _instance = QijingbamaiDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function QijingbamaiDlg.GetLayoutFileName()
    return "qijingbamai.layout"
end

function QijingbamaiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QijingbamaiDlg)

    return self
end

function QijingbamaiDlg:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    --data
    self.m_iQihaiSum = 0
    self.m_iQihaiLeft = 0
    self.m_iHealth = 0
    self.m_iAttack = 0
    self.m_iExternalDefend = 0
    self.m_iInternalDefend = 0
    self.m_iSpeed = 0
    self.m_iShedanNum = 0
    self.m_iMax = 1
    self.m_iHaveCost = 0
    self.m_iLevel = 0
    self.m_iHealthGengu = 0
    self.m_iInternalAttackGengu = 0
    self.m_iExternalAttackGengu = 0
    self.m_iExternalDefendGengu = 0
    self.m_iInternalDefendGengu = 0
    self.m_iSpeedGengu = 0
    self.m_iTime = 0
    self.m_bScrolling = false
    self.m_bShowLastEffect = false
    self.m_iShowPage = 0
    self.m_iPageEnd = 0
    self.m_iPageStart = 0
    self.m_iPageSum = 0
    self.m_vPage = {}

    --init gengu
    self:InitGengu()

    --init page sum
    self:InitPageSum()

    --left ScrollablePane
    self.m_spList = CEGUI.Window.toScrollablePane(winMgr:getWindow("qijingbamai/left"))
    
    self.m_spList:EnableHorzScrollBar(true)
    self.m_spList:EnablePageScrollMode(true)

    self.m_btnPageRight = CEGUI.Window.toPushButton(winMgr:getWindow("qijingbamai/button1"))
    self.m_btnPageLeft = CEGUI.Window.toPushButton(winMgr:getWindow("qijingbamai/button0"))
    self.m_btnPageRight:subscribeEvent("MouseButtonUp", QijingbamaiDlg.HandlePageRightClicked, self)
    self.m_btnPageLeft:subscribeEvent("MouseButtonUp", QijingbamaiDlg.HandlePageLeftClicked, self)

    for i = 0, self.m_iPageSum-1, 1 do
        local namePrefix = tostring(i)
        local rootWnd = winMgr:loadWindowLayout("qijingbamaicell0.layout", namePrefix)
        if rootWnd then
            self.m_spList:addChildWindow(rootWnd)
            local width = rootWnd:getPixelSize().width
            local yPos = 0.1
            local xPos = 0.1 + width*(i)
            rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
            rootWnd:setMousePassThroughEnabled(true)
            rootWnd:setAllChildrenMousePassThroughEnabled(true)
        end
        self.m_vPage[i] = {}
        self.m_vPage[i].wnd = rootWnd
        self.m_vPage[i].points = {}
        for j=0, 7, 1 do
            self.m_vPage[i].points[j] = {}
            self.m_vPage[i].points[j].wnd = winMgr:getWindow(namePrefix .. "qijingbamaicell0/left/point" .. tostring(j+1))
            local pointIcon = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cqjbmaddress"):getRecorder(i+1).point
            self.m_vPage[i].points[j].img = pointIcon
            self.m_vPage[i].points[j].wnd:setProperty("Image", pointIcon)
        end

    end
    self.m_spList:setMousePassThroughEnabled(true)
    self.m_spList:setAllChildrenMousePassThroughEnabled(true)
    
    --left point and exp
    self.m_txtGrade = winMgr:getWindow("qijingbamai/left/text0")
    self.m_txtQihaiNum = winMgr:getWindow("qijingbamai/left/text2")

    self.m_btnUpgrade = winMgr:getWindow("qijingbamai/imagebutton")
    self.m_btnUpgrade:subscribeEvent("Clicked", QijingbamaiDlg.HandleUpgrageClicked, self)

    self.m_txtCost = winMgr:getWindow("qijingbamai/left/text5")
    self.m_pbExp = CEGUI.toProgressBar(winMgr:getWindow("qijingbamai/left/pro"))

    --right scrollbars and point number
    self.m_sbHealth = CEGUI.toScrollbar(winMgr:getWindow("qijingbamai/right/hp"))
    self.m_sbAttack = CEGUI.toScrollbar(winMgr:getWindow("qijingbamai/right/attack"))
    self.m_sbExternalDefend = CEGUI.toScrollbar(winMgr:getWindow("qijingbamai/right/defend"))
    self.m_sbInternalDefend = CEGUI.toScrollbar(winMgr:getWindow("qijingbamai/right/indefend"))
    self.m_sbSpeed = CEGUI.toScrollbar(winMgr:getWindow("qijingbamai/right/speed"))

    self.m_sbHealth:subscribeEvent("ScrollPosChanged", QijingbamaiDlg.HandleHealthChanged, self)
    self.m_sbAttack:subscribeEvent("ScrollPosChanged", QijingbamaiDlg.HandleAttackChanged, self)
    self.m_sbExternalDefend:subscribeEvent("ScrollPosChanged", QijingbamaiDlg.HandleExternalDefendChanged, self)
    self.m_sbInternalDefend:subscribeEvent("ScrollPosChanged", QijingbamaiDlg.HandleInternalDefendChanged, self)
    self.m_sbSpeed:subscribeEvent("ScrollPosChanged", QijingbamaiDlg.HandleSpeedChanged, self)

    self.m_txtHealth = winMgr:getWindow("qijingbamai/right/hpnum/text")
    self.m_txtAttack = winMgr:getWindow("qijingbamai/right/attacknum/text")
    self.m_txtExternalDefend = winMgr:getWindow("qijingbamai/right/defendnum/text")
    self.m_txtInternalDefend = winMgr:getWindow("qijingbamai/right/indefendnum/text")
    self.m_txtSpeed = winMgr:getWindow("qijingbamai/right/speednum/text")

    self.m_txtAttackLabel = winMgr:getWindow("qijingbamai/right/textl1")
    if self:IsExternalScool() then
        self.m_txtAttackLabel:setText(MHSD_UTILS.get_resstring(3041))
    else
        self.m_txtAttackLabel:setText(MHSD_UTILS.get_resstring(3040))
    end

    --right gengu
    self.m_txtHealthGengu = winMgr:getWindow("qijingbamai/right/gengu0")
    self.m_txtAttackGengu = winMgr:getWindow("qijingbamai/right/gengu1")
    self.m_txtExternalDefendGengu = winMgr:getWindow("qijingbamai/right/gengu2")
    self.m_txtInternalDefendGengu = winMgr:getWindow("qijingbamai/right/gengu3")
    self.m_txtSpeedGengu = winMgr:getWindow("qijingbamai/right/gengu4")

    --right save button
    self.m_btnSave = winMgr:getWindow("qijingbamai/right/button")
    self.m_btnSave:subscribeEvent("Clicked", QijingbamaiDlg.HandleSaveClicked, self)
    
    --require data
    self:RequireData()
    self.m_spList:setHorizontalScrollPosition(self.m_iShowPage/self.m_iPageSum)
end

--Check should be external attack school or interanl attack school
--@return : return ture when external or false when interanl
function QijingbamaiDlg:IsExternalScool()
    local school = GetDataManager():GetMainCharacterSchoolID()
    if BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).ap == 0 then
        return true
    else
        return false
    end
end

--Init the gengu config from table
--@return : no return
function QijingbamaiDlg:InitGengu()
    local school = GetDataManager():GetMainCharacterSchoolID()
    self.m_iHealthGengu = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).hp
    self.m_iInternalAttackGengu = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).ap
    self.m_iExternalAttackGengu = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).ad
    self.m_iExternalDefendGengu = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).arm
    self.m_iInternalDefendGengu = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).mr
    self.m_iSpeedGengu = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cgenguxishu"):getRecorder(school).sp
end

--Init the sun page config from table
--@return : no return
function QijingbamaiDlg:InitPageSum()
    local jinduTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cchongxuejindu"):getDisorderAllID()
    local maxLevel = 0
    for k,v in pairs(jinduTable) do
        local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cchongxuejindu"):getRecorder(v)
        if curRecord.visible then
            if curRecord.stage > maxLevel then
                maxLevel = curRecord.stage
            end
        end
    end

    self.m_iPageSum = maxLevel
end

--Refresh the dialog when receive sqijinginfo
--@param sqijinginfo : the protocol sqijinginfo
--@return : no return
function QijingbamaiDlg:ServerRefresh(sqijinginfo)
    LogInfo("QijingbamaiDlg ServerRefresh")
    --set data
    self.m_iQihaiSum = sqijinginfo.qihaipoint
    self.m_iHealth = sqijinginfo.hppoint
    if self:IsExternalScool() then
        self.m_iAttack = sqijinginfo.atkpoint
    else
        self.m_iAttack = sqijinginfo.skillatkpoint
    end
    self.m_iExternalDefend = sqijinginfo.defpoint
    self.m_iInternalDefend = sqijinginfo.skilldefpoint
    self.m_iSpeed = sqijinginfo.speedpoint
    self.m_iQihaiLeft = sqijinginfo.qihaipoint-sqijinginfo.hppoint-sqijinginfo.atkpoint-sqijinginfo.skillatkpoint-sqijinginfo.defpoint-sqijinginfo.skilldefpoint-sqijinginfo.speedpoint
    if self.m_iLevel == nil or self.m_iLevel ~= sqijinginfo.chongxuelevel then
        if self.m_iLevel ~= nil then
            self.m_bShowLastEffect = true
        end
        self.m_iLevel = sqijinginfo.chongxuelevel
        self.m_iPageStart = self.m_iShowPage
        self.m_iPageEnd = math.floor(self.m_iLevel/8)
        if self.m_iPageEnd > self.m_iPageSum then
            self.m_iPageEnd = self.m_iPageSum
        end
        self.m_iShowPage = self.m_iPageEnd
        self.m_bScrolling = true
        -- self.m_bShowLastEffect = true
    end
    self.m_iHaveCost = sqijinginfo.chongxueexp
    self.m_iMax = tonumber(BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cchongxuejindu"):getRecorder(sqijinginfo.chongxuelevel+1).expneed) 
    --refresh view
    self:RefreshView() 
end

--Refresh the the view
--@return : no return
function QijingbamaiDlg:RefreshView()
    LogInfo("QijingbamaiDlg RefreshView")
    --Refresh document size
    self.m_sbHealth:setDocumentSize(self.m_iQihaiSum+0.5)
    self.m_sbAttack:setDocumentSize(self.m_iQihaiSum+0.5)
    self.m_sbExternalDefend:setDocumentSize(self.m_iQihaiSum+0.5)
    self.m_sbInternalDefend:setDocumentSize(self.m_iQihaiSum+0.5)
    self.m_sbSpeed:setDocumentSize(self.m_iQihaiSum+0.5)
    --Refresh scroll position
    self.m_sbHealth:setScrollPosition(self.m_iHealth)
    self.m_sbAttack:setScrollPosition(self.m_iAttack)
    self.m_sbExternalDefend:setScrollPosition(self.m_iExternalDefend)
    self.m_sbInternalDefend:setScrollPosition(self.m_iInternalDefend)
    self.m_sbSpeed:setScrollPosition(self.m_iSpeed)
    --Refresh nums
    self.m_txtHealth:setText(tostring(self.m_iHealth))
    self.m_txtAttack:setText(tostring(self.m_iAttack))
    self.m_txtExternalDefend:setText(tostring(self.m_iExternalDefend))
    self.m_txtInternalDefend:setText(tostring(self.m_iInternalDefend))
    self.m_txtSpeed:setText(tostring(self.m_iSpeed))
    --Refresh QihaiNum
    local title = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cqjbmaddress"):getRecorder(self.m_iShowPage+1).name
    self.m_txtGrade:setText(title)
    local leftQihaiNum = self.m_iQihaiSum-self.m_iHealth-self.m_iAttack-self.m_iExternalDefend-self.m_iInternalDefend-self.m_iSpeed
    self.m_txtQihaiNum:setText(tostring(leftQihaiNum))
    -- if leftQihaiNum <= 0 then
    --     self.m_txtQihaiNum:setProperty("TextColours", "FFFF0000")
    -- else
    --     self.m_txtQihaiNum:setProperty("TextColours", "FFFFFFFF")
    -- end
    --Refresh Exp
    local strMaxExp = tostring(self.m_iMax)
    local strHaveExp = tostring(self.m_iHaveCost)
    self.m_pbExp:setText(strHaveExp .. "/" .. strMaxExp)
    self.m_pbExp:setProgress(self.m_iHaveCost/self.m_iMax)
    self.m_iShedanNum = GetRoleItemManager():GetItemNumByBaseID(SHEDAN_ID)
    self.m_txtCost:setText(tostring(self.m_iShedanNum))
    --Refresh stars
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- if self.m_iLevel ~= 0 then
        for i=0, self.m_iLevel-1, 1 do
            local iPage = math.floor(i/8)
            local iCount = i%8
            local starWnd = self.m_vPage[iPage].points[iCount].wnd
            starWnd:setProperty("Image", self.m_vPage[iPage].points[iCount].img)
            starWnd:setVisible(true)
            GetGameUIManager():RemoveUIEffect(starWnd)
        end
        if self.m_bShowLastEffect then 
            if self.m_iLevel >= 1 then
                local iPage = math.floor((self.m_iLevel-1)/8)
                local iCount = (self.m_iLevel-1)%8
                if self.m_vPage[iPage] ~= nil and self.m_vPage[iPage].points[iCount] ~= nil then
                    local starWnd = self.m_vPage[iPage].points[iCount].wnd
                    -- starWnd:setVisible(true)
                    -- starWnd:setProperty("Image", "set:MainControl32 image:pointdisable")
                    if not GetGameUIManager():IsWindowHaveEffect(starWnd) then
                        GetGameUIManager():AddUIEffect(starWnd, MHSD_UTILS.get_effectpath(10390), false, 0, 0, true)
                        self.m_bShowLastEffect = false
                    end
                end
            end
        end

        local iPage = math.floor(self.m_iLevel/8)
        local iCount = self.m_iLevel%8
        if self.m_vPage[iPage] ~= nil and self.m_vPage[iPage].points[iCount] ~= nil then
            local starWnd = self.m_vPage[iPage].points[iCount].wnd
            starWnd:setVisible(true)
            starWnd:setProperty("Image", "set:MainControl32 image:pointdisable")
            if not GetGameUIManager():IsWindowHaveEffect(starWnd) then
                GetGameUIManager():AddUIEffect(starWnd, MHSD_UTILS.get_effectpath(10432), true, 0, 0, true)
            end
        end

        for j=self.m_iLevel+1, self.m_iPageSum*8-1, 1 do
            local iPage = math.floor(j/8)
            local iCount = j%8
            local starWnd = self.m_vPage[iPage].points[iCount].wnd
            starWnd:setProperty("Image", "set:MainControl32 image:pointdisable")
            starWnd:setVisible(true)
            starWnd:setEnabled(false)
            GetGameUIManager():RemoveUIEffect(starWnd)
        end
    -- end

    self.m_txtHealthGengu:setText("+" .. tostring(self.m_iHealth*self.m_iHealthGengu))
    if self:IsExternalScool() then
        self.m_txtAttackGengu:setText("+" .. tostring(self.m_iAttack*self.m_iExternalAttackGengu))
    else
        self.m_txtAttackGengu:setText("+" .. tostring(self.m_iAttack*self.m_iInternalAttackGengu))
    end
    self.m_txtExternalDefendGengu:setText("+" .. tostring(self.m_iExternalDefend*self.m_iExternalDefendGengu))
    self.m_txtInternalDefendGengu:setText("+" .. tostring(self.m_iInternalDefend*self.m_iInternalDefendGengu))
    self.m_txtSpeedGengu:setText("+" .. tostring(self.m_iSpeed*self.m_iSpeedGengu))

    if self.m_iHealth > 0 then
        self.m_txtHealthGengu:setProperty("TextColours", "FF15FF0F")
    else
        self.m_txtHealthGengu:setProperty("TextColours", "FFFFFFFF")
    end
    if self.m_iAttack > 0 then
        self.m_txtAttackGengu:setProperty("TextColours", "FF15FF0F")
    else
        self.m_txtAttackGengu:setProperty("TextColours", "FFFFFFFF")
    end
    if self.m_iExternalDefend > 0 then
        self.m_txtExternalDefendGengu:setProperty("TextColours", "FF15FF0F")
    else
        self.m_txtExternalDefendGengu:setProperty("TextColours", "FFFFFFFF")
    end
    if self.m_iInternalDefend > 0 then
        self.m_txtInternalDefendGengu:setProperty("TextColours", "FF15FF0F")
    else
        self.m_txtInternalDefendGengu:setProperty("TextColours", "FFFFFFFF")
    end
    if self.m_iSpeed*self.m_iSpeedGengu > 0 then
        self.m_txtSpeedGengu:setProperty("TextColours", "FF15FF0F")
    else
        self.m_txtSpeedGengu:setProperty("TextColours", "FFFFFFFF")
    end
    -- Set Page Buttons
    if self.m_iShowPage >= self.m_iPageSum-1 then
        self.m_iShowPage = self.m_iPageSum-1
        self.m_btnPageRight:setVisible(false)
    else
        self.m_btnPageRight:setVisible(true)
    end

    if self.m_iShowPage <= 0 then
        self.m_iShowPage = 0
        self.m_btnPageLeft:setVisible(false)
    else
        self.m_btnPageLeft:setVisible(true)
    end
end

--Require the data from server
--@return no return
function QijingbamaiDlg:RequireData()
    LogInfo("QijingbamaiDlg RequireData")
    local req = require "protocoldef.knight.gsp.qijingbamai.creqqijinginfo".Create()
    LuaProtocolManager.getInstance():send(req)
end

--Require the save the points state
--@return no return
function QijingbamaiDlg:RequireSave()
    local req = require "protocoldef.knight.gsp.qijingbamai.creqsetqihaipoint".Create()
    req.hppoint = self.m_iHealth
    if self:IsExternalScool() then
        req.atkpoint = self.m_iAttack
        req.skillatkpoint = 0
    else
        req.skillatkpoint = self.m_iAttack
        req.atkpoint = 0
    end
    req.defpoint = self.m_iExternalDefend
    req.skilldefpoint = self.m_iInternalDefend
    req.speedpoint = self.m_iSpeed
    LuaProtocolManager.getInstance():send(req)
end

--Send a request to server for upgrade
--@return : no return
function QijingbamaiDlg:RequireUpgrade()
    local req = require "protocoldef.knight.gsp.qijingbamai.creqchongxue".Create()
    LuaProtocolManager.getInstance():send(req)
end

--Callback of the Health ScrollBar changed
--@return : no return
function QijingbamaiDlg:HandleHealthChanged(args)
    --the limit of max value
    local iMax = self.m_iQihaiSum-self.m_iAttack-self.m_iExternalDefend-self.m_iInternalDefend-self.m_iSpeed
    if self.m_sbHealth:getScrollPosition() > iMax then
        self.m_sbHealth:setScrollPosition(iMax)
    end
    if self.m_sbHealth:getScrollPosition() < 0 then
        self.m_sbHealth:setScrollPosition(0)
    end

    --Refresh data and view
    local intPos = math.floor(self.m_sbHealth:getScrollPosition())
    self.m_sbHealth:setScrollPosition(intPos)
    self.m_iHealth = intPos
    self:RefreshView()
end

--Callback of the Attack ScrollBar changed
--@return : no return
function QijingbamaiDlg:HandleAttackChanged(args)
    --the limit of max value
    local iMax = self.m_iQihaiSum-self.m_iHealth-self.m_iExternalDefend-self.m_iInternalDefend-self.m_iSpeed
    if self.m_sbAttack:getScrollPosition() > iMax then
        self.m_sbAttack:setScrollPosition(iMax)
    end
    if self.m_sbAttack:getScrollPosition() < 0 then
        self.m_sbAttack:setScrollPosition(0)
    end

    --Refresh data and view
    local intPos = math.floor(self.m_sbAttack:getScrollPosition())
    self.m_sbAttack:setScrollPosition(intPos)
    self.m_iAttack = intPos
    self:RefreshView()

end

--Callback of the ExternalDefend ScrollBar changed
--@return : no return
function QijingbamaiDlg:HandleExternalDefendChanged(args)
    --the limit of max value
    local iMax = self.m_iQihaiSum-self.m_iHealth-self.m_iAttack-self.m_iInternalDefend-self.m_iSpeed
    if self.m_sbExternalDefend:getScrollPosition() > iMax then
        self.m_sbExternalDefend:setScrollPosition(iMax)
    end
    if self.m_sbExternalDefend:getScrollPosition() < 0 then
        self.m_sbExternalDefend:setScrollPosition(0)
    end

    --Refresh data and view
    local intPos = math.floor(self.m_sbExternalDefend:getScrollPosition())
    self.m_sbExternalDefend:setScrollPosition(intPos)
    self.m_iExternalDefend = intPos
    self:RefreshView()
end

--Callback of the InternalDefend ScrollBar changed
--@return : no return
function QijingbamaiDlg:HandleInternalDefendChanged(args)
    --the limit of max value
    local iMax = self.m_iQihaiSum-self.m_iHealth-self.m_iAttack-self.m_iExternalDefend-self.m_iSpeed
    if self.m_sbInternalDefend:getScrollPosition() > iMax then
        self.m_sbInternalDefend:setScrollPosition(iMax)
    end
    if self.m_sbInternalDefend:getScrollPosition() < 0 then
        self.m_sbInternalDefend:setScrollPosition(0)
    end

    --Refresh data and view
    local intPos = math.floor(self.m_sbInternalDefend:getScrollPosition())
    self.m_sbInternalDefend:setScrollPosition(intPos)
    self.m_iInternalDefend = intPos
    self:RefreshView()
end

--Callback of the Speed ScrollBar changed
--@return : no return
function QijingbamaiDlg:HandleSpeedChanged(args)
    --the limit of max value
    local iMax = self.m_iQihaiSum-self.m_iHealth-self.m_iAttack-self.m_iExternalDefend-self.m_iInternalDefend
    if self.m_sbSpeed:getScrollPosition() > iMax then
        self.m_sbSpeed:setScrollPosition(iMax)
    end
    if self.m_sbSpeed:getScrollPosition() < 0 then
        self.m_sbSpeed:setScrollPosition(0)
    end

    --Refresh data and view
    local intPos = math.floor(self.m_sbSpeed:getScrollPosition())
    self.m_sbSpeed:setScrollPosition(intPos)
    self.m_iSpeed = intPos
    self:RefreshView()
end

--Callback of the upgrage button clicked
--@return : no return
function QijingbamaiDlg:HandleUpgrageClicked(args)
    self:RequireSave()
    self:RequireUpgrade()
end

--Callback of the upgrage save clicked
--@return : no return
function QijingbamaiDlg:HandleSaveClicked(args)
    self:RequireSave()
    GetGameUIManager():AddMessageTipById(145770)
end

--Callback of the page left clicked
--@return : no return
function QijingbamaiDlg:HandlePageLeftClicked(args)
    if self.m_iShowPage > 0 then
        self.m_iPageStart = self.m_iShowPage
        self.m_iPageEnd = self.m_iShowPage - 1
        self.m_iShowPage = self.m_iPageEnd
        self.m_bScrolling = true
        local title = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cqjbmaddress"):getRecorder(self.m_iShowPage+1).name
        self.m_txtGrade:setText(title)
    end
    if self.m_iShowPage <= 0 then
        self.m_iShowPage = 0
        self.m_btnPageLeft:setVisible(false)
    else
        self.m_btnPageLeft:setVisible(true)
    end

    if self.m_iShowPage >= self.m_iPageSum-1 then
        self.m_iShowPage = self.m_iPageSum-1
        self.m_btnPageRight:setVisible(false)
    else
        self.m_btnPageRight:setVisible(true)
    end
end

--Callback of the page right clicked
--@return : no return
function QijingbamaiDlg:HandlePageRightClicked(args)
    if self.m_iShowPage < self.m_iPageSum then
        self.m_iPageStart = self.m_iShowPage
        self.m_iPageEnd = self.m_iShowPage + 1
        self.m_iShowPage = self.m_iPageEnd
        self.m_bScrolling = true
        local title = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cqjbmaddress"):getRecorder(self.m_iShowPage+1).name
        self.m_txtGrade:setText(title)
    end
    if self.m_iShowPage <= 0 then
        self.m_iShowPage = 0
        self.m_btnPageLeft:setVisible(false)
    else
        self.m_btnPageLeft:setVisible(true)
    end

    if self.m_iShowPage >= self.m_iPageSum-1 then
        self.m_iShowPage = self.m_iPageSum-1
        self.m_btnPageRight:setVisible(false)
    else
        self.m_btnPageRight:setVisible(true)
    end
end

--Callback of the ScrollablePane position changed
--@return : no return
function QijingbamaiDlg:run(delta)
    if self.m_bScrolling then
        if self.m_iTime >= 300 then
            self.m_iTime = 0
            self.m_bScrolling = false
            self.m_spList:setHorizontalScrollPosition(self.m_iPageEnd/(self.m_iPageSum))
        else
            self.m_spList:setHorizontalScrollPosition((self.m_iPageStart + self.m_iTime/300*(self.m_iPageEnd-self.m_iPageStart))/(self.m_iPageSum))
            self.m_iTime = self.m_iTime + delta
        end
    end
end

return QijingbamaiDlg