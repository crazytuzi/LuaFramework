require "ui.dialog"
require "protocoldef.knight.gsp.friends.cgaininvitereward"

FriendYaoQingDlgCell = {}
setmetatable(FriendYaoQingDlgCell, Dialog)
FriendYaoQingDlgCell.__index = FriendYaoQingDlgCell

------------------- public: -----------------------------------
function FriendYaoQingDlgCell.CreateNewDlg(pParentDlg, id)
	print("enter FriendYaoQingDlgCell.CreateNewDlg")
	local newDlg = FriendYaoQingDlgCell:new()
	newDlg:OnCreate(pParentDlg, id)
    return newDlg
end

function FriendYaoQingDlgCell.GetLayoutFileName()
    return "invitefrienditem.layout"
end

function FriendYaoQingDlgCell:OnCreate(pParentDlg, id)
	print("enter FriendYaoQingDlgCell oncreate" .. tostring(id))

    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pOK = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "invitefrienditem/ditu/ok"))
	self.m_Text = winMgr:getWindow(tostring(id) .. "invitefrienditem/ditu/condition0")
	self.m_Prog = winMgr:getWindow(tostring(id) .. "invitefrienditem/ditu/condition2")
	self.m_Reward = CEGUI.Window.toItemCell(winMgr:getWindow(tostring(id) .. "invitefrienditem/ditu/reward"))

    -- subscribe event
	self.m_pOK:subscribeEvent("Clicked", FriendYaoQingDlgCell.HandleOKBtnClicked, self)

	self.id = id
	self.isOK = true
	self.m_pWnd = self:GetWindow()
	print("exit SelectServersDialogcell OnCreate")
end

------------------- public: -----------------------------------

function FriendYaoQingDlgCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FriendYaoQingDlgCell)
    return self
end

function FriendYaoQingDlgCell:HandleOKBtnClicked(args)
	print("enter FriendYaoQingDlgCell HandleOKBtnClicked")
	if self.id ~= nil then
		local reward = CGainInviteReward.Create()
		reward.rewardid = self.id
		LuaProtocolManager.getInstance():send(reward)
		print("Send Protocol self.rewardid = " .. tostring(self.id))
	end
	return true
end

function FriendYaoQingDlgCell:IsOK()
	return self.isOK
end

function FriendYaoQingDlgCell:SetCellPro(cur, max)
	self.m_Prog:setText(tostring(cur) .. "/" .. tostring(max))
	if cur < max then
		self.m_pOK:setEnabled(false)
		self.isOK = false
	else
		self.m_pOK:setEnabled(true)
		self.isOK = true
	end
end

function FriendYaoQingDlgCell:SetCellItem(itemid)
	local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemid)
	self.m_Reward:setVisible(true)
	self.m_Reward:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
	self.m_Reward:setID(itembean.id)
--	self.m_Reward:SetTextUnit(itemCtList[i-1])
	self.m_Reward:removeEvent("TableClick")
	self.m_Reward:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
end

function FriendYaoQingDlgCell:SetCellInfo(pro)
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyaoqinren")
	local record = tt:getRecorder(self.id)
	self:SetCellPro(pro, record.renshuyaoqiu)
	self.m_Text:setText(record.miaoshu)
	self:SetCellItem(record.jiangliid)
end

function FriendYaoQingDlgCell:SetSpecialInfo(cur, max, text, itemid)
	self:SetCellPro(cur, max)
	self.m_Text:setText(text)
	self:SetCellItem(itemid)
end

return FriendYaoQingDlgCell
