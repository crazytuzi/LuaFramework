require "ui.dialog"
require "ui.xiake.skill_xkjh"

SkillXkTip = 
{
m_SkillInfo,
m_pIcon,
m_pPinZhi,
m_pScore,
m_pDesc,
m_pDescDetail,
m_pBtnChange,
m_pBtnQianghua
}

setmetatable(SkillXkTip, Dialog);
SkillXkTip.__index = SkillXkTip;

local _instance;
function SkillXkTip.peekInstance()
	return _instance;
end

function SkillXkTip.getInstance()
	if not _instance then
		_instance = SkillXkTip:new();
		_instance:OnCreate();
	end

	return _instance;
end

function SkillXkTip.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function SkillXkTip.GetLayoutFileName()
	return "quackskilltips.layout";
end

function SkillXkTip:OnCreate()
	Dialog.OnCreate(self);
	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pName = winMgr:getWindow("quacktipsdialog/name");
	self.m_pIcon = CEGUI.Window.toSkillBox(winMgr:getWindow("quacktipsdialog/back/icon"));
	self.m_pPinZhi = winMgr:getWindow("quacktipsdialog/back/info");
	self.m_pScore = winMgr:getWindow("quacktipsdialog/back/info1");
	self.m_pDesc = winMgr:getWindow("quacktipsdialog/back/info2");
	self.m_pDescDetail = CEGUI.Window.toRichEditbox(winMgr:getWindow("quacktipsdialog/back/info3"));

	self.m_pBtnChange = winMgr:getWindow("quacktipsdialog/delete");
	self.m_pBtnQianghua = winMgr:getWindow("quacktipsdialog/use");

	self.m_pBtnChange:subscribeEvent("Clicked", SkillXkTip.HandleChangeClicked, self);
	self.m_pBtnQianghua:subscribeEvent("Clicked", SkillXkTip.HandleQianghuaClicked, self);
end

function SkillXkTip:HandleChangeClicked(arg)
--[[
	SkillBookXq.getInstance().m_pMainFrame:setVisible(true);
	SkillBookXq.getInstance():ModeChange();
	SkillBookXq.getInstance().m_SkillInfo = self.m_SkillInfo;
	XiakeMng.SetWndPos(SkillBookXq.getInstance().m_pMainFrame, 220, 100);
]]
	require "protocoldef.knight.gsp.xiake.cremoveskill"
	local p = CRemoveSkill.Create()
	p.xiakekey = MyXiake_xiake.getInstance().m_iSelectedXiakeKey
	p.skillid = self.m_SkillInfo.mK
	LuaProtocolManager.getInstance():send(p)
	SkillXkTip.DestroyDialog();
end

function SkillXkTip:HandleQianghuaClicked(arg)
	SkillXkQh.getInstance().m_pMainFrame:setVisible(true);
	SkillXkQh.getInstance():SetSkillInfo(self.m_SkillInfo);
	XiakeMng.SetWndPos(SkillXkQh.getInstance().m_pMainFrame, 150, 100);
	SkillXkTip.DestroyDialog();
end

function SkillXkTip:new()
	local st = {};
	st = Dialog:new();
	setmetatable(st, SkillXkTip);
	return st;
end

function SkillXkTip:SetSkillInfo(aSkillInfo, aIsXianTian)
	if aSkillInfo == nil or aSkillInfo.mK == nil or aSkillInfo.mV == nil then
		return;
	end
	if aIsXianTian ~= nil and aIsXianTian == true then
		self.m_pBtnChange:setEnabled(false);
		self.m_pBtnQianghua:setEnabled(false);
	else
		self.m_pBtnChange:setEnabled(true);
		self.m_pBtnChange:setEnabled(true);
	end

	self.m_SkillInfo = aSkillInfo;
	print(self.m_SkillInfo);
	print(aSkillInfo.mK, aSkillInfo.mV);
	local xkSkill = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(aSkillInfo.mK);
	if xkSkill ~= nil then
		print(xkSkill.skillname, xkSkill.icon, xkSkill.describe2);
		CSkillBoxControl:GetInstance():SetSkillInfo(self.m_pIcon, aSkillInfo.mK);
		self.m_pIcon:SetBackgroundDynamic(true);
		self.m_pIcon:SetBackGroundImage(CEGUI.String(XiakeMng.eSkillFrames[xkSkill.color].imageset), CEGUI.String(XiakeMng.eSkillFrames[xkSkill.color].image));
		self.m_pScore:setText(tostring(xkSkill.score));
		self.m_pPinZhi:setProperty("Image", XiakeMng.ePinZhiImgs[xkSkill.color]);
		self.m_pDesc:setText(xkSkill.describe1);
		self.m_pDescDetail:setReadOnly(true);
		self.m_pDescDetail:Clear();
		print(xkSkill.describe2);
		self.m_pDescDetail:AppendText(CEGUI.String(xkSkill.describe2));
		self.m_pDescDetail:Refresh();
		self.m_pName:setText(xkSkill.skillname);
	end
end

return SkillXkTip;

