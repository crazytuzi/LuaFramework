XiakeExchangeCell = {}

setmetatable(XiakeExchangeCell, Dialog)
XiakeExchangeCell.__index = XiakeExchangeCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function XiakeExchangeCell.CreateNewDlg(pParentDlg)
	LogInfo("enter XiakeExchangeCell.CreateNewDlg")
	local newDlg = XiakeExchangeCell:new()
	newDlg:OnCreate(pParentDlg)
    return newDlg
end



----/////////////////////////////////////////------

function XiakeExchangeCell.GetLayoutFileName()
    return "quackspecialcell.layout"
end

function XiakeExchangeCell:OnCreate(pParentDlg)
	LogInfo("enter XiakeExchangeCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pItem = CEGUI.Window.toItemCell(winMgr:getWindow(tostring(prefix) .. "quackspecialcellcell/item0"))
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "quackspecialcell/name0")
	self.m_pNum = winMgr:getWindow(tostring(prefix) .. "quackspecialcell/num0")
	self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(prefix) .. "quackspecialcell/ok0"))

	self.m_pBtn:subscribeEvent("Clicked", XiakeExchangeCell.HandleBtnClicked, self)

	LogInfo("exit XiakeExchangeCell OnCreate")
end

------------------- public: -----------------------------------

function XiakeExchangeCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, XiakeExchangeCell)

    return self
end

function XiakeExchangeCell:Init(id)
	LogInfo("xiakeexchange cell init")
	local record = knight.gsp.npc.GetCXiakeXiaYiTableInstance():getRecorder(id)
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(id)
	
	self.m_pNum:setText(record.needxiayi)
	self.m_pName:setText(item.name)
	self.m_pBtn:setID(id)
	self.m_pItem:SetImage(GetIconManager():GetImageByID(item.icon))
	self.m_pItem:setID(item.id)
	self.m_pItem:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)	
end

function XiakeExchangeCell:HandleBtnClicked(args)
	LogInfo("xiakeexchange cell handle btn clicked")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	GetNetConnection():send(knight.gsp.xiake.CExchangeXiayi(id))	

end


return XiakeExchangeCell
