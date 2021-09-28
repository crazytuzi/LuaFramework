require "ui.dialog"
require "ui.yaoqing.inviteconfirmdlg"
require "ui.yaoqing.friendyaoqingdlgcell"

FriendYaoQingDlg = {}
setmetatable(FriendYaoQingDlg, Dialog)
FriendYaoQingDlg.__index = FriendYaoQingDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FriendYaoQingDlg.getInstance()
	print("enter get friendyaoqingdlg dialog instance")
    if not _instance then
        _instance = FriendYaoQingDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FriendYaoQingDlg.getInstanceAndShow()
	print("enter friendyaoqingdlg dialog instance show")
    if not _instance then
        _instance = FriendYaoQingDlg:new()
        _instance:OnCreate()
	else
		print("set friendyaoqingdlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FriendYaoQingDlg.getInstanceNotCreate()
    return _instance
end

function FriendYaoQingDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function FriendYaoQingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FriendYaoQingDlg:new() 
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

function FriendYaoQingDlg.GetLayoutFileName()
    return "invitefriend.layout"
end

function FriendYaoQingDlg:OnCreate()
	print("friendyaoqingdlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pYaoQingRen = CEGUI.Window.toPushButton(winMgr:getWindow("invitefriend/invited"))
    self.m_pXiaoHuoBan = CEGUI.Window.toMultiColumnList(winMgr:getWindow("invitefriend/ditu/list"))
	self.m_pJiangLi = CEGUI.Window.toScrollablePane(winMgr:getWindow("invitefriend/ditu/huadong"))
	self.m_Text = winMgr:getWindow("invitefriend/invitefriendtxt")

    -- subscribe event
    self.m_pYaoQingRen:subscribeEvent("Clicked", FriendYaoQingDlg.HandleYaoQingRenClicked, self) 

	print("friendyaoqingdlg dialog oncreate end")
end

------------------- private: -----------------------------------

function FriendYaoQingDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FriendYaoQingDlg)
	self.m_cells = {}
    return self
end

function FriendYaoQingDlg:setInfo(invitemeRoleId, invitePeopleInfos, inviteRewardInfo, inviteLvRewardInfo)
	if inviteRewardInfo and inviteRewardInfo ~= 0 then
	print("inviteRewardInfo" .. tostring(inviteRewardInfo))
		self.m_cells[0] = FriendYaoQingDlgCell.CreateNewDlg(self.m_pJiangLi, 0)
		self.m_cells[0]:SetSpecialInfo(0, 1, MHSD_UTILS.get_msgtipstring(145233), inviteRewardInfo)
	end
	self:setYaoQingRen(invitemeRoleId)
	local i = 0
	if invitePeopleInfos then
		for k,v in pairs(invitePeopleInfos) do
			self:addRow(i, i+1, v.rolename, v.level)
			i = i+1
		end
	end
	if inviteLvRewardInfo then
		for k,v in pairs(inviteLvRewardInfo) do
			self:addCell(k, v)
		end
	end
	self:setCellPos()
end

function FriendYaoQingDlg:setYaoQingRen(RoleId)
	if RoleId and RoleId > 0 then
		self.m_Text:setText(tostring(RoleId))
		self.m_Text:setVisible(true)
		self.m_pYaoQingRen:setVisible(false)
		if self.m_cells[0] then
			self.m_cells[0]:SetCellPro(1, 1)
			self:setCellPos()
		end
	else
		self.m_Text:setVisible(false)
		self.m_pYaoQingRen:setVisible(true)
	end
end

function FriendYaoQingDlg:HandleYaoQingRenClicked(args)
	InviteConfirmDlg.getInstanceAndShow()
end

function FriendYaoQingDlg:addCell(id, pro)
	self.m_cells[id] = FriendYaoQingDlgCell.CreateNewDlg(self.m_pJiangLi, id)
	self.m_cells[id]:SetCellInfo(pro)
end

function FriendYaoQingDlg:setCellPos()
	local key_table = {}
	for k,_ in pairs(self.m_cells) do
		table.insert(key_table, k)
	end
	table.sort(key_table)
	-- 按配表排序 start
	local i = 0
	local xpos = 1
	local ypos = 1
	for k,v in pairs(key_table) do
		ypos = self.m_cells[v].m_pWnd:getPixelSize().height * i + 1
		self.m_cells[v].m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
		i = i+1
	end
	-- 按配表排序 end
	--[[
	-- 我以为是把可以领的排到最前面
	local cells_yes = {}
	local cells_no = {}
	local i = 1
	local j = 1
	for _,v in pairs(key_table) do
		if self.m_cells[v]:IsOK() then
			cells_yes[i] = self.m_cells[v]
			i = i+1
		else
			cells_no[j] = self.m_cells[v]
			j = j+1
		end
	end
	i = 0
	local xpos = 1
	local ypos = 1
	for k,v in pairs(cells_yes) do
		ypos = v.m_pWnd:getPixelSize().height * i + 1
		v.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
		i = i+1
	end
	for k,v in pairs(cells_no) do
		ypos = v.m_pWnd:getPixelSize().height * i + 1
		v.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,ypos)))
		i = i+1
	end
	]]
end

function FriendYaoQingDlg:rmCell(id)
	self.m_cells[id].m_pWnd:setVisible(false)
	self.m_cells[id] = nil
	self:setCellPos()
end

function FriendYaoQingDlg:addRow(rownum, col0, col1, col2)
	self.m_pXiaoHuoBan:addRow(rownum)
	local color = "FFFFFFFF"
	local pItem0 = CEGUI.createListboxTextItem(col0)
	pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
	pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	self.m_pXiaoHuoBan:setItem(pItem0, 0, rownum)
	local pItem1 = CEGUI.createListboxTextItem(col1)
	pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
	pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	self.m_pXiaoHuoBan:setItem(pItem1, 1, rownum)
	local pItem2 = CEGUI.createListboxTextItem(col2)
	pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
	pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	self.m_pXiaoHuoBan:setItem(pItem2, 2, rownum)
end

return FriendYaoQingDlg
