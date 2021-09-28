require "ui.dialog"
require "ui.contactroledlg"
require "protocoldef.knight.gsp.move.creqaroundroles"

AroundDialog = {}
setmetatable(AroundDialog, Dialog)
AroundDialog.__index = AroundDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local cellPerPage = 20 
function AroundDialog.getInstance()
	print("enter get arounddialog instance")
    if not _instance then
        _instance = AroundDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function AroundDialog.getInstanceAndShow()
	print("enter arounddialog instance show")
    if not _instance then
        _instance = AroundDialog:new()
        _instance:OnCreate()
	else
		print("set arounddialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function AroundDialog.getInstanceNotCreate()
    return _instance
end

function AroundDialog.DestroyDialog()
	if TeamLabel.getInstanceNotCreate() then
		TeamLabel.getInstanceNotCreate().DestroyDialog()		
	elseif _instance then
		_instance:CloseDialog()
	end
end

function AroundDialog:CloseDialog()
	if _instance then 
		print("destroy around dialog")
		_instance:ResetList()
		_instance:OnClose()
		_instance = nil
	end
end

function AroundDialog.ToggleOpenClose()
	if not _instance then 
		_instance = AroundDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function AroundDialog.refreshAroundRoles(roles)
	LogInfo("arounddialog refresh around roles")
	if _instance then
		_instance:RefreshCharList(roles)
	end
end

----/////////////////////////////////////////------

function AroundDialog.GetLayoutFileName()
    return "arounddialog.layout"
end

function AroundDialog:OnCreate()
	print("around dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pNpcBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("arounddialog/back/part1"))
	self.m_pNpcBtn:setID(1)
	self.m_pNpcBtn:setSelected(false)
	self.m_pCharBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("arounddialog/back/part2"))
	self.m_pCharBtn:setID(2)
	self.m_pCharBtn:setSelected(true)

	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("arounddialog/back/main"))

    -- subscribe event
    self.m_pNpcBtn:subscribeEvent("SelectStateChanged", AroundDialog.HandleSelectStateChanged, self) 
    self.m_pCharBtn:subscribeEvent("SelectStateChanged", AroundDialog.HandleSelectStateChanged, self)
	self.m_pPane:subscribeEvent("NextPage", AroundDialog.HandleNextPage, self)
	
	--self:RefreshNpcList()
	self:HandleSelectStateChanged()
	print("around dialog oncreate end")

end

------------------- private: -----------------------------------


function AroundDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AroundDialog)
    return self
end

function AroundDialog:HandleSelectStateChanged(args)
	print("handle select state change")
	local selected = self.m_pNpcBtn:getSelectedButtonInGroup():getID()

	if selected == 1 then 
		self:RefreshNpcList()
	elseif selected == 2 then
		self:ResetList()
        local reqRole = CReqAroundRoles.Create()
        LuaProtocolManager.getInstance():send(reqRole)
	end

	return true
end

function AroundDialog:RefreshNpcList()
	print("refresh npc list")	
	self:ResetList()
	self.m_iMapID = GetScene():GetMapInfo().id	
	local filename = "/map/" .. GetScene():GetMapInfo().resdir .. "/npc.dat"
	local fr = XMLIO.CFileReader()
	if fr:OpenFile(filename) ~= XMLIO.EC_SUCCESS then
		print("open npc.xml error!")
		return
	end
	local root = XMLIO.CINode(), rval;
	rval = fr:GetRootNode(root)
	if not rval then
		fr:CloseFile()
		fr = nil
		return
	end

	self.m_lNpcList = {}
	--read all npc info
	for i=1, root:GetChildrenCount() do
		local typenode = XMLIO.CINode()
		root:GetChildAt(i - 1, typenode)
		
		if typenode:GetType() == XMLIO.NT_ELEMENT then
			local npcInfo = {}
			npcInfo.npcID = typenode:GetAttributeInteger("id")
			local npcTmp = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(npcInfo.npcID);
			--only show the visible npc
			if npcTmp.hide == 0	and npcTmp.showinUI == 1 then
				npcInfo.xpos = npcTmp.xPos
				npcInfo.ypos = npcTmp.yPos
				npcInfo.name = npcTmp.name
				npcInfo.title = npcTmp.foottitle
				npcInfo.modelID = npcTmp.modelID
				table.insert(self.m_lNpcList, npcInfo)
			end
		end
	end
	self:AddNpc()
end

function AroundDialog:RefreshCharList(roles)
	LogInfo("arounddialog refresh character list")
	self.m_iCurPage = 1	

	self.m_iRoleNum = 0

	self:ResetList()
	self.m_lCharList = {}
	local n = 1
	for i, v in pairs(roles) do
		if v.roleid ~= GetDataManager():GetMainCharacterID() then
			local role = {}
			role.userid = v.roleid
			role.name = v.name
			role.level = v.level
			role.shapeID = v.shape
			role.schoolName = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name
			role.camptype = v.camptype
			self.m_lCharList[n] = role
			n = n + 1
			self.m_iRoleNum = self.m_iRoleNum + 1
		end
	end	

	self.m_iMaxPage = math.ceil(self.m_iRoleNum / cellPerPage)	
	self:AddCharacter()
end

function AroundDialog:ResetList()
	print("reset list")

	print("reset npc list")
	if self.m_lNpcList then
		self.m_pPane:cleanupNonAutoChildren()
		self.m_lNpcList = nil
	end

	if self.m_lCharList then
		self.m_pPane:cleanupNonAutoChildren()
		self.m_lCharList = nil
	end

end

function AroundDialog:AddNpc()
	print("add npc")
	--sort npc by distance
	table.sort(self.m_lNpcList, AroundDialog.NpcSortFunc)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local len = 0
	for i,v in ipairs(self.m_lNpcList) do
		if len % 2 == 0 then
		--load window index start from 0
			local pWnd = winMgr:loadWindowLayout("aroundnpccell.layout", tostring(math.floor(len / 2)))
			self.m_pPane:addChildWindow(pWnd)
			pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(math.floor(len / 2)) * pWnd:getPixelSize().height + 1)))
			local tmpWnd = winMgr:getWindow(tostring(math.floor(len / 2)) .. "aroundnpccell/cell1")
			tmpWnd:setVisible(false)
		end
		v.pWnd = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(math.floor(len / 2)) .. "aroundnpccell/cell" .. tostring(len % 2)))
		v.pWnd:setVisible(true)
		v.pWnd:setID(i)
		v.pWnd:subscribeEvent("Clicked", AroundDialog.HandleNPCClick, self)
		v.pHead = winMgr:getWindow(tostring(math.floor(len / 2)) .. "aroundnpccell/icon" .. tostring(len % 2))
		local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.modelID)
		local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
		v.pHead:setProperty("Image", path)
				
		v.pName = winMgr:getWindow(tostring(math.floor(len / 2)) .. "aroundnpccell/name" .. tostring(len % 2))
		v.pName:setText(v.name)
		v.pTitle = winMgr:getWindow(tostring(math.floor(len / 2)) .. "aroundnpccell/info" .. tostring(len % 2))
		v.pTitle:setText(v.title)
		len = len + 1
	end
	
end

function AroundDialog:AddCharacter()
	print("add character")
	--sort character
	--table.sort(self.m_lCharList, AroundDialog,CharSortFunc)
	
	if self.m_iCurPage > self.m_iMaxPage then
		return
	end
	local startPos = (self.m_iCurPage - 1) * cellPerPage + 1
	local endPos = self.m_iCurPage * cellPerPage
	if self.m_iRoleNum < endPos then
		endPos = self.m_iRoleNum 
	end

	local winMgr = CEGUI.WindowManager:getSingleton()
	for i = startPos, endPos do
		print("load cell " .. tostring(i))
		self.m_lCharList[i].pWnd = winMgr:loadWindowLayout("aroundusercell.layout", tostring(i))
		self.m_pPane:addChildWindow(self.m_lCharList[i].pWnd)
		self.m_lCharList[i].pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, (i - 1) * self.m_lCharList[i].pWnd:getPixelSize().height + 1)))

		self.m_lCharList[i].pButton = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(i) .. "aroundusercell/back"))
		self.m_lCharList[i].pButton:subscribeEvent("Clicked", AroundDialog.HandleCharacterClick, self)
		self.m_lCharList[i].pButton:setID(i)
		self.m_lCharList[i].pHead = winMgr:getWindow(tostring(i) .. "aroundusercell/icon")
		local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(self.m_lCharList[i].shapeID)
		local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
		self.m_lCharList[i].pHead:setProperty("Image", path)
		
		self.m_lCharList[i].pName = winMgr:getWindow(tostring(i) .. "aroundusercell/name")
		self.m_lCharList[i].pName:setText(self.m_lCharList[i].name)

		print(self.m_lCharList[i].level)
		self.m_lCharList[i].pLevel = winMgr:getWindow(tostring(i) .. "aroundusercell/level")
		self.m_lCharList[i].pLevel:setText(tostring(self.m_lCharList[i].level))

		self.m_lCharList[i].pSchool = winMgr:getWindow(tostring(i) .. "aroundusercell/school")
		self.m_lCharList[i].pSchool:setText(self.m_lCharList[i].schoolName)

		self.m_lCharList[i].pCamp = winMgr:getWindow(tostring(i) .. "aroundusercell/camp")
		if self.m_lCharList[i].camptype == 1 then
			self.m_lCharList[i].pCamp:setVisible(true)
			self.m_lCharList[i].pCamp:setProperty("Image", "set:MainControl image:campred")	
		elseif self.m_lCharList[i].camptype == 2 then
			self.m_lCharList[i].pCamp:setVisible(true)
			self.m_lCharList[i].pCamp:setProperty("Image", "set:MainControl image:campblue")	
		else
			self.m_lCharList[i].pCamp:setVisible(false)
		end

	end
end

function AroundDialog.NpcSortFunc(first, second)
	print("npc sort")
	
	local point1 = {}
	local point2 = {}
	point1.x = first.xpos * 24
	point1.y = first.ypos * 16
	point2.x = GetMainCharacter():getXPos()
	point2.y = GetMainCharacter():getYPos()

	local dis1 = distance2(point1, point2)
	point1.x = second.xpos * 24
	point1.y = second.ypos * 16
	local dis2 = distance2(point1, point2)
	
	return dis1 < dis2
end

function AroundDialog:HandleNPCClick(args)
	print("NPCClicked")	
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	GetMainCharacter():FlyOrWarkToPos(self.m_iMapID, self.m_lNpcList[id].xpos, self.m_lNpcList[id].ypos, self.m_lNpcList[id].npcID)
end

function AroundDialog:HandleCharacterClick(args)
	print("character clicked")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local userid = self.m_lCharList[id].userid
	local username = self.m_lCharList[id].name
    local level = self.m_lCharList[id].level
	local camp = self.m_lCharList[id].camptype
    GetFriendsManager():SetContactRole(userid,username,level,camp)
end

function distance2(from, to)
	print("function distance")
	return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
end

function AroundDialog:HandleNextPage(args)
	LogInfo("arounddialog handle next page")
	
	local selectTab = self.m_pNpcBtn:getSelectedButtonInGroup():getID()
	if selectTab == 1 then
		return true
	end

	if self.m_iCurPage < self.m_iMaxPage then
		self.m_iCurPage = self.m_iCurPage + 1
		local BarPos = self.m_pPane:getVertScrollbar():getScrollPosition()
		self.m_pPane:getVertScrollbar():Stop()
		self:AddCharacter()
		self.m_pPane:getVertScrollbar():setScrollPosition(BarPos)
	end
	return true
end

return AroundDialog
