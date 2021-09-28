require "ui.xiake.xiake_exchangecell"
require "ui.dialog"

XiakeQiyu = {
    
    -- for qian san xiake
    m_selStateXiakeKeys_QS = {},
    m_lCells_QS = {},
    m_iMaxCells_QS = 0,
    m_iMaxPage_QS = 1,
	m_iCurPage_QS = 1,
	m_iCellNum_QS = 0,
    m_iOnePageCount_QS = 8,
    m_iBarPos_QS = 0,
    m_idleXiakes_QS = nil
}

setmetatable(XiakeQiyu, Dialog);
XiakeQiyu.__index = XiakeQiyu;

local _instance;
local exchangeCellPerpage = 5
function XiakeQiyu.getInstance()
    print("____XiakeQiyu.getInstance")
    
	if not _instance then
		_instance = XiakeQiyu:new();
		_instance:OnCreate();
	end

	return _instance;
end

function XiakeQiyu.peekInstance()
	return _instance;
end

function XiakeQiyu:SetVisible(bV)
    LogInfo("____XiakeQiyu:SetVisible")
    
	if bV == self.m_pMainFrame:isVisible() then
        return
    end

	self.m_pMainFrame:setVisible(bV)

	if bV then
        self:RefreshQianSanInfo()
	else
	end
end

function XiakeQiyu.GetLayoutFileName()
	return "quackspecial.layout"
end

function XiakeQiyu.GetAndShow()
    LogInfo("____XiakeQiyu.GetAndShow")
    
	local qy = XiakeQiyu.getInstance()
    
    local needRefreshQianSanInfo = true

	if qy ~= nil then
        
        if qy.m_pMainFrame:isVisible() then
            needRefreshQianSanInfo = false
        end
        
		qy.m_pMainFrame:setVisible(true)
	end
    
    if needRefreshQianSanInfo then
        qy:RefreshQianSanInfo()
    end
end

function XiakeQiyu.IsVisible()
    
    print("____XiakeQiyu.IsVisible")

	local qy = XiakeQiyu.peekInstance();
	if qy == nil then
        return false
    end

	return qy.m_pMainFrame:isVisible();
end

function XiakeQiyu.DestroyDialog()
    LogInfo("____XiakeQiyu.DestroyDialog")
	
    if _instance then
		_instance:cleanupPane()
        _instance:OnClose();
		_instance = nil;
	end

	if XiakeMainFrame.peekInstance() then
		XiakeMainFrame.DestroyDialog();
	end
end

function XiakeQiyu.RefreshXiaYiValue(xiayi)
	LogInfo("____XiakeQiyu:RefreshXiaYiValue")
	if _instance then
		_instance.m_pXiaYi_DH:setText(tostring(xiayi))
		_instance.m_pXiaYi_QS:setText(tostring(xiayi))
	end
end

function XiakeQiyu:new()
    print("____XiakeQiyu:new")

	local qiyu = {};
	qiyu = Dialog:new();
	setmetatable(qiyu, XiakeQiyu);
	return qiyu;
end

function XiakeQiyu:OnCreate()
    LogInfo("____Enter XiakeQiyu:OnCreate")

	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.m_pGroupBtn = {}
	self.m_pGroupBtn[1] = CEGUI.Window.toGroupButton(winMgr:getWindow("quackspecial/main/btn1"))
	self.m_pGroupBtn[2] = CEGUI.Window.toGroupButton(winMgr:getWindow("quackspecial/main/btn2"))
	
	self.m_pTab = {}
	self.m_pTab[1] = winMgr:getWindow("quackspecial/main/info0")
	self.m_pTab[2] = winMgr:getWindow("quackspecial/main/info1")

	self.m_pXiaYi_QS = winMgr:getWindow("quackspecial/main/info/num0")
	self.m_pXiaYi_DH = winMgr:getWindow("quackspecial/main/info1/num1")

    for i = 1,2 do
		self.m_pGroupBtn[i]:setID(i)
   		self.m_pGroupBtn[i]:subscribeEvent("SelectStateChanged", XiakeQiyu.HandleSelectStateChanged, self) 
		if i == 1 then
			self.m_pGroupBtn[i]:setSelected(true)
			self.m_pTab[i]:setVisible(true)
		else
			self.m_pGroupBtn[i]:setSelected(false)
			self.m_pTab[i]:setVisible(false)
		end
	end
    
    --xia ke qian san wnd content
    self.m_pPaneQianSan = CEGUI.Window.toScrollablePane(winMgr:getWindow("quackspecial/main/scroll"))
	self.m_pPaneQianSan:EnableHorzScrollBar(true)
    self.m_pPaneQianSan:subscribeEvent("NextPage", XiakeQiyu.HandleQianSanNextPage, self)
    self.m_btnQianSan = CEGUI.Window.toPushButton(winMgr:getWindow("quackspecial/main/info/ok"))
    self.m_btnQianSan:subscribeEvent("Clicked", XiakeQiyu.HandleClickQianSanBtn, self)
    self:ResetListQS()
    self:RefreshQianSanInfo()
    self.m_btnQuickQianSan = CEGUI.Window.toPushButton(winMgr:getWindow("quackspecial/main/info/okall"))
    if self.m_btnQuickQianSan then
        self.m_btnQuickQianSan:subscribeEvent("Clicked", XiakeQiyu.HandleClickQuickQianSanBtn, self)
    end

    --xia yi dui huan wnd content
    self.m_pPaneExchange = CEGUI.Window.toScrollablePane(winMgr:getWindow("quackspecial/main/info1/scroll"))
	self.m_pPaneExchange:EnableHorzScrollBar(true)
    self.m_pPaneExchange:subscribeEvent("NextPage", XiakeQiyu.HandleExchangeNextPage, self)
	local ids = std.vector_int_()
	knight.gsp.npc.GetCXiakeXiaYiTableInstance():getAllID(ids)
	local num = ids:size()
	self.m_iMaxExhangePage = math.ceil(num / exchangeCellPerpage)	
	self.m_iCurExchangePage = 1

	GetNetConnection():send(knight.gsp.xiake.CReqXiayiValue())


	LogInfo("____Exit XiakeQiyu:OnCreate")
end

function XiakeQiyu:HandleClickQianSanBtn(args)
    LogInfo("____XiakeQiyu:HandleClickQianSanBtn")
    
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        GetGameUIManager():AddMessageTipById(144879)
        return true
    end
    
    if self.m_iCellNum_QS < 4 then
        GetGameUIManager():AddMessageTipById(144974)
        return true
    end

    local vecQianSan = std.vector_int_()
    for k,v in pairs(self.m_selStateXiakeKeys_QS) do
        if v.xiakekey and v.bSelected then
            print("____qiansan xiake key: " .. v.xiakekey)
            vecQianSan:push_back(v.xiakekey)
        end
    end
    local req = knight.gsp.xiake.CReleaseXiake(vecQianSan)
	GetNetConnection():send(req)
    
    return true
end

function XiakeQiyu:HandleQuickQianSanConfirmClicked(args)
    LogInfo("____XiakeQiyu:HandleQuickQianSanConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        GetGameUIManager():AddMessageTipById(144879)
        return true
    end
    
    if self.m_iCellNum_QS < 4 then
        GetGameUIManager():AddMessageTipById(144974)
        return true
    end
    
    if not self.m_idleXiakes_QS then
        return true
    end

    local vecQianSan = std.vector_int_()
    
    for k,v in pairs(self.m_idleXiakes_QS) do
        local xk = XiakeMng.ReadXiakeData(v.xiakeid)
        if xk then
            if v.color == 1 or v.color == 2 then
                if v.starlv == 1 then
                    print("____qiansan xiake key: " .. v.xiakekey)
                    vecQianSan:push_back(v.xiakekey)
                end
            end
        end
    end
    
    if vecQianSan:size() > 0 then
        local req = knight.gsp.xiake.CReleaseXiake(vecQianSan)
        GetNetConnection():send(req)
    else
        GetGameUIManager():AddMessageTipById(145241)
    end

    return true
end

function XiakeQiyu:HandleClickQuickQianSanBtn(args)
    LogInfo("____XiakeQiyu:HandleClickQuickQianSanBtn")
    
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145240),XiakeQiyu.HandleQuickQianSanConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
    
    return true
end

function XiakeQiyu.GetGivenTableNum(tableReg)
    local len = 0
    for k,v in pairs(tableReg) do
        len = len + 1
    end
    
    return len
end

function XiakeQiyu:HandleSelectStateChanged(args)
	LogInfo("_____XiakeQiyu:HandleSelectStateChanged")


    local selected = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
	for i = 1, 2 do
		self.m_pTab[i]:setVisible(false)
	end
	self.m_pTab[selected]:setVisible(true)
	if selected == 2 then
		self:RefreshExhangeTab()
	end

	return true
end

function XiakeQiyu:HandleClickSomeXiaKeForQS(args)
    LogInfo("____XiakeQiyu.HandleClickSomeXiaKeForQS")
    
	local WindowArgs = CEGUI.toWindowEventArgs(args)
	local pCell = CEGUI.toItemCell(WindowArgs.window)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local idCell = pCell:getID()
    
    if not self.m_selStateXiakeKeys_QS[idCell] then
        return true
    end
    if not self.m_selStateXiakeKeys_QS[idCell].xiakekey then
        return true
    end

    LogInfo("_____click xia ke key is: " .. self.m_selStateXiakeKeys_QS[idCell].xiakekey)
    
    local lightWndName = tostring(idCell) .. "quackcelllist3/light0"
    local lightWnd = winMgr:getWindow(lightWndName)

	if pCell and lightWnd then
        if self.m_selStateXiakeKeys_QS[idCell].bSelected then
            self.m_selStateXiakeKeys_QS[idCell].bSelected = false
            lightWnd:setVisible(false)
        else
            self.m_selStateXiakeKeys_QS[idCell].bSelected = true
            lightWnd:setVisible(true)
        end
    end
    
    self.m_btnQianSan:setEnabled(false)
    for k,v in pairs(self.m_selStateXiakeKeys_QS) do
        if v.bSelected then
            self.m_btnQianSan:setEnabled(true)
            break
        end
    end

    return true
end

function XiakeQiyu:RefreshQianSanInfo()
    LogInfo("____XiakeQiyu.RefreshQianSanInfo")

    if not self.m_pTab[1]:isVisible() then
        return
    end

    self:RefreshQSIdlesXiakes()
    self:RefreshQSMyXiaKesInfo()
    self:RefreshQSXYValueInfo()
end

function XiakeQiyu:RefreshQSIdlesXiakes()
    LogInfo("____XiakeQiyu:RefreshQSIdlesXiakes")
    
    self.m_idleXiakes_QS = XiakeMng.GetIdleXiakesOrderByColorScoreIncre()
    
    for k,v in pairs(self.m_idleXiakes_QS) do
        print("____new idle xiakes keys: " .. v.xiakekey)
    end
end

function XiakeQiyu:ResetListQS()
	print("____XiakeQiyu:ResetListQS")
    
    self.m_lCells_QS = {}
    self.m_iMaxCells_QS = 0
    self.m_iCurPage_QS = 1
    self.m_iCellNum_QS = 0
    self.m_iBarPos_QS = 0
    self.m_pPaneQianSan:cleanupNonAutoChildren()
    self.m_selStateXiakeKeys_QS = {}
    self.m_btnQianSan:setEnabled(false)
end

function XiakeQiyu:RefreshQSOpponent()
    
    LogInfo("____XiakeQiyu:RefreshQSOpponent")
    
    if not self.m_idleXiakes_QS then
        self:RefreshQSIdlesXiakes()
    end

    if not self.m_iCurPage_QS then
		return
	end

	local num = XiakeQiyu.GetGivenTableNum(self.m_idleXiakes_QS)
    
	local winMgr = CEGUI.WindowManager:getSingleton()
	local startPos = (self.m_iCurPage_QS - 1) * self.m_iOnePageCount_QS + 1
	local endPos = self.m_iCurPage_QS * self.m_iOnePageCount_QS
	if endPos > num then
		endPos = num
	end
    
    self.m_iCellNum_QS = self.m_iCellNum_QS or 0

	for index = startPos, endPos, 1 do
        local v = self.m_idleXiakes_QS[index]
        local xk = XiakeMng.ReadXiakeData(v.xiakeid)
        local namePrefix = tostring(index)
        if xk then

            local bOutLet = false
            if self.m_iMaxCells_QS < index then
                bOutLet = true
                self.m_iMaxCells_QS = index
                self.m_lCells_QS[self.m_iMaxCells_QS] = winMgr:loadWindowLayout("quackcelllist3.layout",namePrefix)
            end

            local rootWnd = self.m_lCells_QS[index]

            if rootWnd then
                if bOutLet then
                    print("_____add child window: " .. namePrefix)
                    self.m_pPaneQianSan:addChildWindow(rootWnd)
                end
                
                self.m_iCellNum_QS = self.m_iCellNum_QS + 1

                self.m_selStateXiakeKeys_QS[index] = {xiakekey = v.xiakekey, bSelected = false}
                
                local width = rootWnd:getPixelSize().width
                local xPos=1.0+(width+5.0)*(index-1)
                local yPos=1.0
                rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
                rootWnd:setVisible(true)

                local headWndName = namePrefix .. "quackcelllist3/icon0"
                local headWnd = CEGUI.toItemCell(winMgr:getWindow(headWndName))
                if headWnd then
                    headWnd:setProperty("Image", xk.path)
                    headWnd:setID(index)
                    headWnd:removeEvent("MouseClick")
                    headWnd:subscribeEvent("MouseClick", XiakeQiyu.HandleClickSomeXiaKeForQS, self)
                end
                
                local eliteWndName = namePrefix .. "quackcelllist3/elite0"
                local eliteWnd = winMgr:getWindow(eliteWndName)
                if eliteWnd then
                    eliteWnd:setVisible(XiakeMng.IsElite(v.xiakekey))
                else
                    print("____error not get quackcelllist3/elite0")
                end

                local levelWndName = namePrefix .. "quackcelllist3/level0"
                local levelWnd = winMgr:getWindow(levelWndName)
                if levelWnd then
                    levelWnd:setText(tostring(GetDataManager():GetMainCharacterLevel()));
                end
                
                local markWndName = namePrefix .. "quackcelllist3/mark0"
                local markWnd = winMgr:getWindow(markWndName)
                if markWnd then
                    markWnd:setProperty("Image", XiakeMng.eLvImages[v.starlv]);
                end

                local frameWndName = namePrefix .. "quackcelllist3/quack0"
                local frameWnd = winMgr:getWindow(frameWndName)
                if frameWnd then
                    frameWnd:setProperty("Image", XiakeMng.eXiakeFrames[v.color]);
                end

                local nameWndName = namePrefix .. "quackcelllist3/name0"
                local nameWnd = winMgr:getWindow(nameWndName)
                if nameWnd then
                    nameWnd:setText(scene_util.GetPetNameColor(v.color)..xk.xkxx.name);
                end
                
                local scoreWndName = namePrefix .. "quackcelllist3/num0"
                local scoreWnd = winMgr:getWindow(scoreWndName)
                if scoreWnd then
                    local xiayiSup = XiakeMng.GetSupportXiayiFromXKColorJieci(v.color, v.starlv)
                    scoreWnd:setText(tostring(xiayiSup))
                end
                
                local lightWndName = namePrefix .. "quackcelllist3/light0"
                local lightWnd = winMgr:getWindow(lightWndName)
                if lightWnd then
                    lightWnd:setVisible(false)
                end

            end
        end
	end
    
    for j = self.m_iCellNum_QS+1, self.m_iMaxCells_QS, 1 do
        if self.m_lCells_QS[j] then
            self.m_lCells_QS[j]:setPosition(CEGUI.UVector2(CEGUI.UDim(1,0),CEGUI.UDim(1,0)))
            self.m_lCells_QS[j]:setVisible(false)
        end
        self.m_selStateXiakeKeys_QS[j] = nil
    end

    --set scroll bar pos
	if self.m_iCurPage_QS == 1 then
		self.m_pPaneQianSan:getHorzScrollbar():setScrollPosition(0)
	else
		self.m_pPaneQianSan:getHorzScrollbar():setScrollPosition(self.m_iBarPos_QS)
	end
end

function XiakeQiyu:RefreshQSMyXiaKesInfo()
    
    print("____XiakeQiyu:RefreshQSMyXiaKesInfo")
    
    if not self.m_idleXiakes_QS then
        self:RefreshQSIdlesXiakes()
    end

    local num = XiakeQiyu.GetGivenTableNum(self.m_idleXiakes_QS)
    
	self.m_iMaxPage_QS = math.ceil(num / self.m_iOnePageCount_QS)
	self.m_iCurPage_QS = 1
    self.m_iCellNum_QS = 0
    self.m_iBarPos_QS = 0
    self.m_btnQianSan:setEnabled(false)

    self:RefreshQSOpponent()
end



function XiakeQiyu:RefreshQSXYValueInfo()
    LogInfo("____XiakeQiyu:RefreshQSXYValueInfo")
    
    
end

function XiakeQiyu:HandleQianSanNextPage(args)
	LogInfo("____XiakeQiyu:HandleQianSanNextPage")
    
	if self.m_iMaxPage_QS and self.m_iCurPage_QS then
		if self.m_iCurPage_QS < self.m_iMaxPage_QS then
			self.m_iCurPage_QS = self.m_iCurPage_QS + 1
            self.m_iBarPos_QS = self.m_pPaneQianSan:getHorzScrollbar():getScrollPosition()
			self.m_pPaneQianSan:getHorzScrollbar():Stop()
			self:RefreshQSOpponent()
		end
	end
    
	return true
end

function XiakeQiyu:RefreshExhangeTab()
	LogInfo("____XiakeQiyu:RefreshExhangeTab")

	local ids = std.vector_int_()
	knight.gsp.npc.GetCXiakeXiaYiTableInstance():getAllID(ids)	
	local num = ids:size()
	local startpos = (self.m_iCurExchangePage - 1) * exchangeCellPerpage + 1
	local endpos = self.m_iCurExchangePage * exchangeCellPerpage
	if endpos > ids:size() then
		endpos = ids:size()
	end
	for i = startpos, endpos do
		local cell = XiakeExchangeCell.CreateNewDlg(self.m_pPaneExchange)
		cell:Init(ids[i - 1])
		cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, (cell:GetWindow():getPixelSize().width) * (i - 1) + 1), CEGUI.UDim(0, 0)))
	end
end

function XiakeQiyu:HandleExchangeNextPage(args)
	LogInfo("____XiakeQiyu:HandleExchangeNextPage")
	if self.m_iMaxExhangePage and self.m_iCurExchangePage then
		if self.m_iCurExchangePage < self.m_iMaxExhangePage then
			self.m_iCurExchangePage = self.m_iCurExchangePage + 1
			local BarPos = self.m_pPaneExchange:getHorzScrollbar():getScrollPosition()
			self.m_pPaneExchange:getHorzScrollbar():Stop()
			self:RefreshExhangeTab()
			self.m_pPaneExchange:getHorzScrollbar():setScrollPosition(BarPos)
		end
	end
end

function XiakeQiyu:cleanupPane()
	LogInfo("____XiakeQiyu:cleanupPane")
	self.m_pPaneExchange:cleanupNonAutoChildren()
	self:ResetListQS()
end

return XiakeQiyu



