local Dialog = require "ui.dialog"
local CReqVote = require "protocoldef.knight.gsp.campleader.creqvote"

CampLeaderDlgCell = {}
setmetatable(CampLeaderDlgCell, Dialog)
CampLeaderDlgCell.__index = CampLeaderDlgCell

CampLeaderDlgCell.SelectId = 0
CampLeaderDlgCell.ReturnMoney = 0

------------------- public: -----------------------------------
function CampLeaderDlgCell.CreateNewDlg(pParentDlg, id)
	print("enter CampLeaderDlgCell.CreateNewDlg")
	local newDlg = CampLeaderDlgCell:new()
	newDlg:OnCreate(pParentDlg, id)
    return newDlg
end

function CampLeaderDlgCell.GetLayoutFileName()
    return "campleadercelldlg.layout"
end

function CampLeaderDlgCell:OnCreate(pParentDlg, id)
	print("enter CampLeaderDlgCell oncreate" .. tostring(id))
    Dialog.OnCreate(self, pParentDlg, id)
	self.m_pWnd = self:GetWindow()
	self.m_id = id

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pOK = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "campleadercelldlg1/ok"))
	self.m_pIcon = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/icon")
	self.m_pName = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/name")
	self.m_pFamilyName = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/familyname")
	self.m_pNum = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/name11")
	self.m_pSchool = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/name2")
	self.m_pText = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/name121")
	self.m_pReturnMoney = winMgr:getWindow(tostring(id) .. "campleadercelldlg1/money")

    -- subscribe event
	self.m_pOK:subscribeEvent("Clicked", CampLeaderDlgCell.HandleOKBtnClicked, self)

	print("exit CampLeaderDlgCell OnCreate")
end

------------------- public: -----------------------------------

function CampLeaderDlgCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampLeaderDlgCell)
    return self
end

-- icon         图片路径
-- name         玩家名字
-- familyname   帮派
-- num          票数
-- school       门派
-- text         宣言
-- returnmoney  获得的竞选基金
function CampLeaderDlgCell:SetInfo(icon, name, familyname, num, school, text, returnmoney)
	self.m_pIcon:setProperty("Image",icon)
	self.m_pName:setText(name)
	self.m_pFamilyName:setText(familyname)
	self.m_pNum:setText(tostring(num))
	self.m_pSchool:setText(school)
	self.m_pText:setText(text)
	self.returnmoney = returnmoney
	local strBuilder = StringBuilder:new()
	strBuilder:Set("parameter1", self.returnmoney/10000)
	self.m_pReturnMoney:setText(strBuilder:GetString(MHSD_UTILS.get_resstring(3027)))
	strBuilder:delete()
end

-- 投票
function CampLeaderDlgCell:HandleOKBtnClicked(args)
	print("enter CampLeaderDlgCell HandleOKBtnClicked")
	CampLeaderDlgCell.SelectId = self.m_id
	local p = CReqVote.Create()
	p.roleid = self.m_id
	p.returnmoney = self.returnmoney
	LuaProtocolManager.getInstance():send(p)
	return true
end

function CampLeaderDlgCell.ConfirmMoney(truth)
	CampLeaderDlgCell.ReturnMoney = truth;
	GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145653),CampLeaderDlgCell.HandleOKConfirm,CampLeaderDlgCell,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

function CampLeaderDlgCell.HandleOKConfirm()
	local CReqVote = require "protocoldef.knight.gsp.campleader.creqvote"
	local req = CReqVote.Create()
	req.roleid = CampLeaderDlgCell.SelectId
	req.returnmoney = 0
	LuaProtocolManager.getInstance():send(req)
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	return true
end

return CampLeaderDlgCell
