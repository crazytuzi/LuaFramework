local SingletonDialog = require "ui.singletondialog"
local Dialog = require "ui.dialog"

local RewardDlg = {}
setmetatable(RewardDlg, SingletonDialog)
RewardDlg.__index = RewardDlg

function RewardDlg.GetLayoutFileName()
	return "xiaganyidanbaoxiang.layout"
end

function RewardDlg.new()
	local inst = {}
	setmetatable(inst, RewardDlg)
	inst:OnCreate()
	inst.m_Name = ""
	return inst
end

function RewardDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_wClose = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidanbaoxiang/closed"))
	self.m_wClose:subscribeEvent("Clicked", RewardDlg.HandleCloseClicked, self)
	self.m_wGetReward = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidanbaoxiang/lingqu"))
	self.m_wGetReward:subscribeEvent("Clicked", RewardDlg.HandleGetRewardClicked, self)

	self.m_Rewards = {}
	for i=0,3 do
		local reward = {}
		reward.wFrame = winMgr:getWindow("xiaganyidanbaoxiang/rolebackpic" .. tostring(i))
		reward.wItem = CEGUI.toItemCell(winMgr:getWindow("xiaganyidanbaoxiang/rolebackpic/item" .. tostring(i)))
		reward.wItem:setID(0)
		reward.wItem:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
		reward.wTxt = winMgr:getWindow("xiaganyidanbaoxiang/txt1" .. tostring(i))
		table.insert(self.m_Rewards, reward)
	end
end

-------------------------- 分割线 ------------------------------------------

-- ids table 物品id
-- fgetreward function 点击领取后回调函数
-- t 回调的第一个参数
function RewardDlg:RefreshData(name, ids, fgetreward, t)
	self.m_Name = name
	if fgetreward then
		self.m_fGetReward = {}
		self.m_fGetReward.fun = fgetreward
		self.m_fGetReward.t = t
		self.m_wGetReward:setEnabled(true)
	else
		self.m_wGetReward:setEnabled(false)
	end
	if type(ids) ~= "table" then
		ids = {}
	end
	local configItem = knight.gsp.item.GetCItemAttrTableInstance()
	for i,v in ipairs(self.m_Rewards) do
		local itemid = ids[i]
		if itemid then
			local item = configItem:getRecorder(itemid)
			v.wItem:setID(itemid)
			v.wItem:SetImage(GetIconManager():GetItemIconByID(item.icon))
			v.wTxt:setText(item.name)
			v.wFrame:setVisible(true)
		else
			v.wFrame:setVisible(false)
		end
	end
end

function RewardDlg:GetRewardBtnEnabled(name, enabled)
	if self.m_Name == name and self.m_fGetReward then
		self.m_wGetReward:setEnabled(enabled)
	end
end

function RewardDlg:CloseRewardDlg(name)
	if self.m_Name == name then
		self:DestroyDialog()
	end
end

function RewardDlg:HandleCloseClicked(args)
	self:DestroyDialog()
end

function RewardDlg:HandleGetRewardClicked(args)
	if self.m_fGetReward then
		self.m_fGetReward.fun(self.m_fGetReward.t)
	end
end

return RewardDlg
