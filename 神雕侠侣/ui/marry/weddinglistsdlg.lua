require "ui.dialog"
require "utils.mhsdutils"

WeddingListsDlg = {
	m_weddinglists = {}
}

setmetatable(WeddingListsDlg, Dialog)
WeddingListsDlg.__index = WeddingListsDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function WeddingListsDlg.getInstance()
	print("enter WeddingListsDlg.ginstance")
    if not _instance then
        _instance = WeddingListsDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WeddingListsDlg.getInstanceAndShow()
	print("enter WeddingListsDlg.getInstanceAndShow")
    if not _instance then
        _instance = WeddingListsDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
   
    return _instance
end

function WeddingListsDlg.getInstanceNotCreate()
    return _instance
end

function WeddingListsDlg:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function WeddingListsDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function WeddingListsDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WeddingListsDlg:new() 
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

function WeddingListsDlg.GetLayoutFileName()
    return "wedding.layout"
end

function WeddingListsDlg:OnCreate()
	print("enter WeddingListsDlg oncreate")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_tianshangrenjianGroupBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("wedding/right/back/part1"))
	self.m_tianshangrenjianGroupBtn:setID(1)
	self.m_tianshangrenjianNotify=winMgr:getWindow("wedding/right/back/part1/mark1")
	self.m_tianshangrenjianNotify:setVisible(false)

	self.m_zuixianlouGroupBtn = CEGUI.Window.toPushButton(winMgr:getWindow("wedding/right/back/part2"))
	self.m_zuixianlouGroupBtn:setID(2)
	self.m_zuixianlouNotify=winMgr:getWindow("wedding/right/back/part2/mark2")
	self.m_zuixianlouNotify:setVisible(false)

	self.m_ContactRoleList = CEGUI.Window.toScrollablePane(winMgr:getWindow("wedding/right/back/main"))

	self.m_tianshangrenjianGroupBtn:subscribeEvent("SelectStateChanged", WeddingListsDlg.HandleGroupSelectChange, self)
	self.m_zuixianlouGroupBtn:subscribeEvent("SelectStateChanged", WeddingListsDlg.HandleGroupSelectChange, self)
	self.m_tianshangrenjianGroupBtn:setSelected(true)

	self.m_btnRefresh = CEGUI.Window.toPushButton(winMgr:getWindow("wedding/refresh"))
	self.m_btnRefresh:subscribeEvent("Clicked", WeddingListsDlg.HandleRefreshClicked, self)

	print("exit WeddingListsDlg OnCreate")
end

------------------- private: -----------------------------------
function WeddingListsDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WeddingListsDlg)

    return self
end

function WeddingListsDlg:HandleGroupSelectChange(args)
	LogInfo("WeddingListsDlg HandleGroupSelectChange.")

	self.m_ContactRoleList:cleanupNonAutoChildren()

	local index = 1
	--args == nil for Fresh function call
	if args ~= nil then
		index = CEGUI.toWindowEventArgs(args).window:getID()
		self.m_CurrentIndex = index;
	else
		index = self.m_CurrentIndex;
	end

	local winMgr=CEGUI.WindowManager:getSingleton()
	local prefix = 0

	for k,v in pairs(WeddingListsDlg.m_weddinglists) do
		
		local cellWnd = nil
		--tianshangrenjian
		if v.flag == 3 and index == 1 then
			LogInfo("WeddingListsDlg HandleGroupSelectChange tianshangrenjian")
			prefix = prefix + 1
			cellWnd = CEGUI.Window.toPushButton(winMgr:loadWindowLayout("weddingcell.layout", tostring(prefix)))
			self.m_ContactRoleList:addChildWindow(cellWnd)
		end

		--zuixianlou
		if v.flag == 2 and index == 2 then
			LogInfo("WeddingListsDlg HandleGroupSelectChange zuixianlou")
			prefix = prefix + 1
			cellWnd = CEGUI.Window.toPushButton(winMgr:loadWindowLayout("weddingcell.layout", tostring(prefix)))
			self.m_ContactRoleList:addChildWindow(cellWnd)
		end
		
		if cellWnd ~= nil then
			local name1 = winMgr:getWindow(tostring(prefix) .. "weddingcell/name")
        	local name2 = winMgr:getWindow(tostring(prefix) .. "weddingcell/level1")
        	local icon1 = winMgr:getWindow(tostring(prefix) .. "weddingcell/icon")
        	local icon2 = winMgr:getWindow(tostring(prefix) .. "weddingcell/icon1")
        	local btnGo = winMgr:getWindow(tostring(prefix) .. "weddingcell/more")

			name1:setText(v.man)
			name2:setText(v.woman)

	        local shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.manshape)
	        local strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
	        icon1:setProperty("Image", strHead)
   	        shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.womanshape)
	        strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
	        icon2:setProperty("Image", strHead)

	        btnGo:subscribeEvent("Clicked", WeddingListsDlg.HandleGotoWedding, self)
	        btnGo:setUserString("index", tostring(v.weddingid))

			local height = cellWnd:getPixelSize().height
	    	local yPos = (height+5.0) * (prefix - 1) + 5
	    	local xPos = 1.0
	    	cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
		end
	end
end

function WeddingListsDlg:HandleRefreshClicked(args)
	LogInfo("FriendsDialog:HandleRefreshClicked")

	--send get wedding list protocol
	require "protocoldef.knight.gsp.marry.cweddinglist"
	local p = CWeddingList.Create()
	require "manager.luaprotocolmanager":send(p)
end

function WeddingListsDlg:HandleGotoWedding(args)
	LogInfo("FriendsDialog:HandleGotoWedding")
    local e = CEGUI.toWindowEventArgs(args)
    local weddingId = e.window:getUserString("index")
    LogInfo("weddingId = " .. tostring(weddingId))
    if weddingId ~= nil then
		--attend wedding party proptocol
	    require "protocoldef.knight.gsp.marry.cattendwedding"
		local p = CAttendWedding.Create()
		p.coupleid = tonumber(weddingId)
		require "manager.luaprotocolmanager":send(p)
    end
end

function WeddingListsDlg:SetWeddingListsData(data)
	LogInfo("WeddingListsDlg:SetWeddingListsData")
	WeddingListsDlg.m_weddinglists = data;
	if _instance ~= nil then
		_instance:HandleGroupSelectChange();
	end
end

return WeddingListsDlg
