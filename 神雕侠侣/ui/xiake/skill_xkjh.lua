require "ui.dialog"
require "ui.xiake.skillbooksxk"

SkillXkQh = {
	m_pIcon,
	m_pName,
	m_pBarTop,
	m_pBar,
	m_pBLevel,
	m_pBLife,
	m_pALevel,
	m_pALife,

	m_vBooks,
	m_vBookItems,

	m_SkillInfo,

	m_pBtnOk,
	m_pBtnCancel,
}

setmetatable(SkillXkQh, Dialog);
SkillXkQh.__index = SkillXkQh;

local _instance;
function SkillXkQh.peekInstance()
	return _instance;
end

function SkillXkQh.getInstance()
	if not _instance then
		_instance = SkillXkQh:new();
		_instance:OnCreate();
	end

	return _instance;
end

function SkillXkQh.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function SkillXkQh.GetLayoutFileName()
	return "quackskillqh.layout";
end

function SkillXkQh:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	
	self.m_SkillInfo = nil;

	self.m_pIcon = CEGUI.Window.toSkillBox(winMgr:getWindow("quackskillqh/icon"));
	self.m_pWndEffect = winMgr:getWindow("quackskillqh/effect");
	self.m_pName = winMgr:getWindow("quackskillqh/name");
	self.m_pBarTop = CEGUI.Window.toProgressBar(winMgr:getWindow("quackskillqh/barture"));
	self.m_pBar = CEGUI.Window.toProgressBar(winMgr:getWindow("quackskillqh/bar"));
	self.m_pBar:setProgress(0);
	self.m_pBLevel = winMgr:getWindow("quackskillqh/info/txt");
	self.m_pBLife = winMgr:getWindow("quackskillqh/info/txt1");
	self.m_pALevel = winMgr:getWindow("quackskillqh/info/txt2");
	self.m_pALife = winMgr:getWindow("quackskillqh/info/txt3");

	self.m_vBooks = {};
	self.m_vBookItems = {};
	self.m_vBooks[1] = CEGUI.Window.toItemCell(winMgr:getWindow("quackskillqh/item"));
--	self.m_vBooks[1]:subscribeEvent("TableClick", SkillXkQh.HandleSkillClick, self.m_vBooks[1]);
	for i = 2, 5 do
		self.m_vBooks[i] = CEGUI.Window.toItemCell(winMgr:getWindow("quackskillqh/item"..tostring(i - 1)));
--		self.m_vBooks[i]:subscribeEvent("TableClick", SkillXkQh.HandleSkillClick, self.m_vBooks[i]);
	end

	self.m_pBtnOk = winMgr:getWindow("quackskillqh/ok");
	self.m_pBtnCancel = winMgr:getWindow("quackskillqh/cancel");

	self.m_pBtnOk:subscribeEvent("Clicked", SkillXkQh.HandleOkBtn, self);
	self.m_pBtnCancel:subscribeEvent("Clicked", SkillXkQh.HandleCancelBtn, self);
	self:RefreshBooks();

	self:HandleSkillClick(nil)
end

function SkillXkQh:HandleSkillClick(arg)
	SkillBookXq.getInstance().m_pMainFrame:setVisible(true);
	SkillBookXq.getInstance().m_pMainFrame:moveToFront();
	XiakeMng.SetWndPos(SkillBookXq.getInstance().m_pMainFrame, 560, 100);
	SkillBookXq.getInstance():ModeSelectBooks();
	SkillBookXq.getInstance().m_pBtnOk:setVisible(false)
	SkillBookXq.getInstance().m_pBtnCancel:setVisible(false)
end

function SkillXkQh:SkillJinhuaResult(aXiakeKey, aSkillID, aSkillExp)
	local info = {};
	info.mK = aSkillID;
	info.mV = aSkillExp;
	if MyXiake_xiake.getInstance().m_iSelectedXiakeKey == aXiakeKey and self.m_SelectXiakeKey == aXiakeKey then
		if tonumber(aSkillID) ~= tonumber(self.m_UpgradeSkillID) then
			--sheng ji le
			GetGameUIManager():AddUIEffect(self.m_pWndEffect, MHSD_UTILS.get_effectpath(10379), false);
		else
			--mei sheng ji
			GetGameUIManager():AddUIEffect(self.m_pIcon, MHSD_UTILS.get_effectpath(10384), false);
		end
	end
	self:SetSkillInfo(info);
	self:HandleSkillClick(nil);
end

function SkillXkQh:HandleOkBtn(arg)
	local books = std.vector_int_();
	for k,v in pairs(self.m_vBookItems) do
		if v then
			books:push_back(k);
		end
	end

	if books:size() > 0 then
		XiakeMng.RequestSkillUpgrade(MyXiake_xiake.getInstance().m_iSelectedXiakeKey, 
			self.m_SkillInfo.mK, books);

		self.m_vBookItems = {};
		self:RefreshBooks();
		self.m_SelectXiakeKey = MyXiake_xiake.getInstance().m_iSelectedXiakeKey;
		self.m_UpgradeSkillID = self.m_SkillInfo.mK;
	end


	self.m_vBookItems = {};
	self:HandleSkillClick(nil);
--	if SkillBookXq.peekInstance() ~= nil then
--		SkillBookXq.DestroyDialog();
--	end

--	SkillXkQh.DestroyDialog();
end

function SkillXkQh:RefreshBooks()
	for i = 1, 5 do
		self.m_vBooks[i]:SetImage(nil);
		GetGameUIManager():RemoveUIEffect(self.m_vBooks[i]);
		GetGameUIManager():AddUIEffect(self.m_vBooks[i], MHSD_UTILS.get_effectpath(10374), true);
	end

	self.m_pBar:setProgress(0);

	local vBooks = std.vector_int_();
	local i = 1;
	for k,v in pairs(self.m_vBookItems) do
		if v == true then
			vBooks:push_back(k);
		end
		if v == true and i < 6 then
		local itemd = GetRoleItemManager():FindItemByBagAndThisID(k, knight.gsp.item.BagTypes.BAG);
		if itemd ~= nil then
		local attr = itemd:GetBaseObject();

		GetGameUIManager():RemoveUIEffect(self.m_vBooks[i]);
		self.m_vBooks[i]:SetImage(GetIconManager():GetItemIconByID(attr.icon));
		end
		i = i+1;
		end
	end
	if vBooks:size() > 0 then
		local req = knight.gsp.xiake.CUpgradeSkillPreview(MyXiake_xiake.getInstance().m_iSelectedXiakeKey, self.m_SkillInfo.mK, vBooks);
		GetNetConnection():send(req);
	end
end

function SkillXkQh:RefreshPreview(aSkillKey, aAddExp)
	if self.m_SkillInfo == nil then return; end
--	if self.m_SkillInfo.mK ~= aSkillKey then return; end
	local xkSkill = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(self.m_SkillInfo.mK);
	if xkSkill ~= nil then
		local iNeed = xkSkill.needexp;
		local iCur = self.m_SkillInfo.mV;

		self.m_pBarTop:setProgress(iCur/iNeed);
		self.m_pBar:setProgress((iCur + aAddExp)/iNeed);
	end
end

function SkillXkQh:SetSkillInfo(aSkillInfo)
	if aSkillInfo == nil then return; end
	self.m_SkillInfo = aSkillInfo;
	
	local xkSkill = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(aSkillInfo.mK);
	if xkSkill ~= nil then
		local nSkill = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(xkSkill.nextskillid);
		CSkillBoxControl:GetInstance():SetSkillInfo(self.m_pIcon, aSkillInfo.mK);
		self.m_pIcon:SetBackgroundDynamic(true);
		self.m_pIcon:SetBackGroundImage(CEGUI.String(XiakeMng.eSkillFrames[xkSkill.color].imageset), CEGUI.String(XiakeMng.eSkillFrames[xkSkill.color].image));
		self.m_pName:setText(xkSkill.skillname);
		
		local iNeed = xkSkill.needexp;
		local iCur = aSkillInfo.mV;
		local pct = iCur/iNeed;
		self.m_pBarTop:setProgress(pct);
	--	self.m_pBar;

		self.m_pBLevel:setText(xkSkill.skillname);
		self.m_pBLife:setText(xkSkill.describe1);

		self.m_pALevel:setText(nSkill.skillname);
		self.m_pALife:setText(nSkill.describe1);
	end
end

function SkillXkQh:HandleCancelBtn(arg)
	SkillXkQh.DestroyDialog();
	if SkillBookXq.peekInstance() ~= nil then
		SkillBookXq.DestroyDialog();
	end
end

function SkillXkQh:new()
	local sq = {};
	sq = Dialog:new();
	setmetatable(sq, SkillXkQh);
	return sq;
end


return SkillXkQh;

