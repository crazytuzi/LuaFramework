--[[author: lvxiaolong
date: 2013/7/12
function: chengwei dlg
]]

require "ui.dialog"
require "ui.chengwei.chengweicell"


ChengWeiDlg = {

    m_lCells = {},
    m_iMaxCells = 0,
    m_iMaxPage = 1,
	m_iCurPage = 1,
	m_iCellNum = 0,
    m_iBarPos = 0,
    
    m_iOnePageCount = 6,
    m_curTitleID = -1,
    m_listTitleID = nil,
    m_lastCurTitleID = -1,
    m_lastLightIndex = -1,
    m_indexToBeLighted = -1,
}
setmetatable(ChengWeiDlg, Dialog)
ChengWeiDlg.__index = ChengWeiDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function ChengWeiDlg.SendUnloadChengwei()
    LogInfo("____ChengWeiDlg.SendUnloadChengwei")
    
    local offTitleAction = COffTitle.Create()
    LuaProtocolManager.getInstance():send(offTitleAction)
end

function ChengWeiDlg.IsShow()
    --LogInfo("ChengWeiDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function ChengWeiDlg.getInstance()
	LogInfo("ChengWeiDlg.getInstance")
    if not _instance then
        _instance = ChengWeiDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function ChengWeiDlg.getInstanceAndShow()
	LogInfo("____ChengWeiDlg.getInstanceAndShow")
    if not _instance then
        _instance = ChengWeiDlg:new()
        _instance:OnCreate()
        _instance:RefreshAll()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function ChengWeiDlg.getInstanceNotCreate()
    --print("ChengWeiDlg.getInstanceNotCreate")
    return _instance
end

function ChengWeiDlg.DestroyDialog()
	if _instance then
        _instance:cleanupPane()
		_instance:OnClose() 
		_instance = nil
	end
end

function ChengWeiDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ChengWeiDlg:new() 
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

function ChengWeiDlg.GetLayoutFileName()
    return "chengweidlg.layout"
end

function ChengWeiDlg:OnCreate()
	LogInfo("enter ChengWeiDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_pPaneContent = CEGUI.Window.toScrollablePane(winMgr:getWindow("chengweidlg/main"))
    self.m_pPaneContent:subscribeEvent("NextPage", ChengWeiDlg.HandleGiftActNextPage, self)
    
    self:ResetList()
    
	LogInfo("exit ChengWeiDlg OnCreate")
end

function ChengWeiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChengWeiDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function ChengWeiDlg:RecordCurScrollBarPos()
    self.m_iBarPos = self.m_pPaneContent:getVertScrollbar():getScrollPosition()
end

function ChengWeiDlg:HandleGiftActNextPage(args)
    LogInfo("____ChengWeiDlg:HandleGiftActNextPage")

	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
            self.m_iBarPos = self.m_pPaneContent:getVertScrollbar():getScrollPosition()
			self.m_pPaneContent:getVertScrollbar():Stop()
            
            self:RefreshOpponent()
		end
	end
    
	return true
end

function ChengWeiDlg:RefreshTitleListInfo()
    LogInfo("____ChengWeiDlg:RefreshTitleListInfo")
    
    self.m_listTitleID = {}
    self.m_listTitleID[1] = -1
    if GetDataManager() then
        local vecID = std.vector_int_()
        
        GetDataManager():SetAllTitleIDToData(vecID)
        
        local num = vecID:size()
        for i=1,num,1 do
            print("____vecID" .. (i-1) .. ": " .. vecID[i-1])
            self.m_listTitleID[#self.m_listTitleID+1] = vecID[i-1]
        end
    end
    
    self.m_iMaxPage = math.ceil(#self.m_listTitleID / self.m_iOnePageCount)
end

function ChengWeiDlg:RefreshCurTitleID()
    LogInfo("____ChengWeiDlg:RefreshCurTitleID")
    
    if GetDataManager() then
        self.m_curTitleID = GetDataManager():GetCurTitleID()
    end
end

function ChengWeiDlg:RefreshLightPart()
    LogInfo("____ChengWeiDlg:RefreshLightPart")

    --[[if self.m_lastCurTitleID > 0 and self.m_lastLightIndex > 0 and self.m_iCellNum >= self.m_lastLightIndex and self.m_lCells[self.m_lastLightIndex] then

        local titleIDOldCell = self.m_lCells[self.m_lastLightIndex]:GetTitleID()
        if titleIDOldCell == self.m_lastCurTitleID then
            self.m_lCells[self.m_lastLightIndex]:SetLightProperty(false)
        end
    end
    
    local bFindLastLightIndex = false
    if self.m_indexToBeLighted > 0 and self.m_iCellNum >= self.m_indexToBeLighted and self.m_lCells[self.m_indexToBeLighted] then
        local titleIDNewCell = self.m_lCells[self.m_indexToBeLighted]:GetTitleID()
        if titleIDNewCell == self.m_curTitleID then
            bFindLastLightIndex = true
            self.m_lCells[self.m_indexToBeLighted]:SetLightProperty(true)
            self.m_lastLightIndex = self.m_indexToBeLighted
        end
    end
    
    self.m_lastCurTitleID = self.m_curTitleID
    self.m_indexToBeLighted = -1
    if not bFindLastLightIndex then
        self.m_lastLightIndex = -1
        for i = 1,self.m_iCellNum,1 do
            if self.m_lCells[i] and self.m_lCells[i]:GetTitleID() == self.m_curTitleID then
                self.m_lastLightIndex = i
                self.m_lCells[i]:SetLightProperty(true)
                break
            end
        end
    end

    if self.m_curTitleID <= 0 then
        self.m_lastLightIndex = -1
    end]]
    
    self.m_iCellNum = self.m_iCellNum or 0
    if self.m_curTitleID < 0 then
        for i = 1,self.m_iCellNum,1 do
            if self.m_lCells[i] and self.m_lCells[i]:GetTitleID() < 0 then
                self.m_lCells[i]:SetLightProperty(true)
            elseif self.m_lCells[i] then
                self.m_lCells[i]:SetLightProperty(false)
            end
        end
    else
        for i = 1,self.m_iCellNum,1 do
            if self.m_lCells[i] and self.m_lCells[i]:GetTitleID() == self.m_curTitleID then
                self.m_lCells[i]:SetLightProperty(true)
            elseif self.m_lCells[i] then
                self.m_lCells[i]:SetLightProperty(false)
            end
        end
    end
end

function ChengWeiDlg:RefreshIndexToBeLighted(index)
    LogInfo("____ChengWeiDlg:RefreshIndexToBeLighted")
    
    self.m_indexToBeLighted = index
end

function ChengWeiDlg:RefreshListShow()
    LogInfo("____ChengWeiDlg:RefreshListShow")
    
    self.m_iCurPage = 1
    self.m_iCellNum = 0
    
    self:RefreshOpponent()
end

function ChengWeiDlg:RefreshAll()
    LogInfo("____ChengWeiDlg:RefreshAll")
    
    self:RefreshTitleListInfo()
    self:RefreshCurTitleID()
    self:RefreshListShow()
end

function ChengWeiDlg:RefreshOpponent()
    LogInfo("____ChengWeiDlg:RefreshOpponent")
    
    if not self.m_listTitleID then
        return
    end

    if not self.m_iCurPage then
		return
	end

    local numTotal = #self.m_listTitleID
    
	local winMgr = CEGUI.WindowManager:getSingleton()
	local startPos = (self.m_iCurPage - 1) * self.m_iOnePageCount + 1

	local endPos = self.m_iCurPage * self.m_iOnePageCount
	if endPos > numTotal then
		endPos = numTotal
	end

    self.m_iCellNum = self.m_iCellNum or 0
    
    local i = self.m_iCellNum
    
	for index = startPos, endPos, 1 do

        local titleidReg = self.m_listTitleID[index]
        local bIsCurTitleID = false
        if self.m_curTitleID < 0 then
            if titleidReg < 0 then
                bIsCurTitleID = true
            end
        elseif titleidReg == self.m_curTitleID then
            bIsCurTitleID = true
            --self.m_lastCurTitleID = self.m_curTitleID
            --self.m_lastLightIndex = index
            --self.m_indexToBeLighted = -1
        end
        
        if self.m_iMaxCells < index then
				self.m_iMaxCells = index
				self.m_lCells[self.m_iMaxCells] = ChengWeiCell.CreateNewDlg(self.m_pPaneContent, self.m_iMaxCells)
        end
        
        local myself = self.m_lCells[index]
        
        local xpos = 1
        local ypos = myself.m_pWnd:getPixelSize().height * (index - 1) + 1
        
        myself.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
        myself.m_pWnd:setVisible(true)
        myself:SetContent(titleidReg, bIsCurTitleID, index)
        
        i = i+1
	end
    
    self.m_iCellNum = i
    
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

function ChengWeiDlg:ResetList()
	print("____ChengWeiDlg:ResetList")
    
    self.m_lCells = {}
    self.m_iMaxCells = 0
    self.m_iCurPage = 1
    self.m_iCellNum = 0
    self.m_iBarPos = 0

    self.m_pPaneContent:cleanupNonAutoChildren()
end

function ChengWeiDlg:cleanupPane()
    LogInfo("____ChengWeiDlg:cleanupPane")
    
    self.m_pPaneContent:cleanupNonAutoChildren()
end

return ChengWeiDlg
