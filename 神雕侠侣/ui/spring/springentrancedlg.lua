require "ui.dialog"
require "ui.spring.springactivityinfodlg"

SpringEntranceDlg = {}
setmetatable(SpringEntranceDlg, Dialog)
SpringEntranceDlg.__index = SpringEntranceDlg

m_vActivities = {} --ID and state

---- singleton ----
local _instance;
function SpringEntranceDlg.getInstance()
	if not _instance then
		_instance = SpringEntranceDlg:new()
		_instance:OnCreate()
	end

	return _instance
end

function SpringEntranceDlg.getInstanceAndShow()
	if not _instance then
		_instance = SpringEntranceDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
		_instance.m_pMainFrame:setAlpha(1)
	end

	return _instance
end

function SpringEntranceDlg.getInstanceNotCreate()
	return _instance
end

function SpringEntranceDlg:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function SpringEntranceDlg.DestroyDialog()
	SpringActivityInfoDlg.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function SpringEntranceDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SpringEntranceDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

---- end singleton ----

function SpringEntranceDlg.GetLayoutFileName()
	return "springfestival.layout"
end

function SpringEntranceDlg:OnCreate()

	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()

	-- get windows

	self.m_ContextList = 
		CEGUI.Window.toScrollablePane(winMgr:getWindow("springfestival/back/item/list") )
	self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("springfestival/closebutton"))

	self.m_btnClose:subscribeEvent("Clicked", SpringEntranceDlg.DestroyDialog, self)

	self:RequestList()
end

function SpringEntranceDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, SpringEntranceDlg)

	return self
end

function SpringEntranceDlg.GlobalRefreshList()
   if _instance then
      _instance:RefreshList()
   end
end

function SpringEntranceDlg:RequestList()
	--request activities data
	local p = CSpringFestivalList.Create()
	LuaProtocolManager.getInstance():send(p)
end

function SpringEntranceDlg:RefreshList(vUnsortData)
	self.m_ContextList:cleanupNonAutoChildren()

	--init data and sort
	m_vActivities = {}
	m_vOverActivities = {}
	m_vDoingActivities = {}

	local function sortFunc(a ,b)
		local activityInfoA = 
			BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cspringentrance"):getRecorder(a.id)
		local activityInfoB = 
			BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cspringentrance"):getRecorder(b.id)
		return activityInfoA.rank < activityInfoB.rank
	end

	local iIndex = 1
	for k,v in pairs(vUnsortData) do
		if v.status == 0 then
			m_vDoingActivities[iIndex] = v
			iIndex = iIndex + 1
		end
	end
	table.sort(m_vDoingActivities, sortFunc)

	iIndex = 1;
	for k,v in pairs(vUnsortData) do
		if v.status == 1 then
			m_vOverActivities[iIndex] = v
			iIndex = iIndex + 1
		end
	end
	table.sort(m_vOverActivities, sortFunc)

	iIndex = 1
	for k,v in pairs(m_vDoingActivities) do
		m_vActivities[iIndex] = v
		iIndex = iIndex + 1
	end

	for k,v in pairs(m_vOverActivities) do
		m_vActivities[iIndex] = v
		iIndex = iIndex + 1
	end

	--create cell
	local i = 0
	local winMgr = CEGUI.WindowManager:getSingleton()
	for k,v in pairs(m_vActivities) do
		local namePrefix = tostring(v.id)
		local rootWnd = winMgr:loadWindowLayout("springfestivalcell.layout", namePrefix)
		if rootWnd then
			self.m_ContextList:addChildWindow(rootWnd)
			local height = rootWnd:getPixelSize().height
			local yPos = 1.0+(height+5.0)*i
			local xPos = 1.0
			rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))

			local btnInfo = CEGUI.Window.toPushButton(winMgr:getWindow(namePrefix .. "springfestivalcell/info"))
			local btnTransfer = CEGUI.Window.toPushButton(winMgr:getWindow(namePrefix .. "springfestivalcell/transfer"))
			local txtName = winMgr:getWindow(namePrefix .. "springfestivalcell/name")
			local txtTime = winMgr:getWindow(namePrefix .. "springfestivalcell/time")
			local mark = winMgr:getWindow(namePrefix .. "springfestivalcell/finish")


			local activityInfo = 
				BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cspringentrance"):getRecorder(v.id)
			txtName:setText(activityInfo.name)
			txtTime:setText(activityInfo.time)

			btnInfo:subscribeEvent("Clicked", SpringEntranceDlg.HandleClickCellInfo, self)
			btnTransfer:subscribeEvent("Clicked", SpringEntranceDlg.HandleClickCellTransfer, self)

			if v.status == 0 then
				mark:setVisible(false)
			else
				mark:setVisible(true)
			end

			btnInfo:setUserString("id",v.id)
			btnTransfer:setUserString("id",v.id)
		end
		i = i + 1
	end
end

function SpringEntranceDlg:HandleClickCellTransfer(args)
	local cell = CEGUI.toWindowEventArgs(args)
	local id = cell.window:getUserString("id")
	
	local activityInfo = 
		BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cspringentrance"):getRecorder(tonumber(id))

	if activityInfo.mapid == 0 then
		self:ShowInfo(id)
	else
		if GetScene():GetMapID() ~= activityInfo.mapid then
			SpringEntranceDlg.DestroyDialog()
		end
		GetMainCharacter():FlyOrWarkToPos(activityInfo.mapid, activityInfo.x, activityInfo.y, -1)	
	end

end

function SpringEntranceDlg:HandleClickCellInfo(args)
	local cell = CEGUI.toWindowEventArgs(args)
	local id = cell.window:getUserString("id")

	self:ShowInfo(id)

end

function SpringEntranceDlg:ShowInfo(id)
	local infoDlg = SpringActivityInfoDlg.getInstanceAndShow()
	infoDlg:SetInfo(id)
end

return SpringEntranceDlg