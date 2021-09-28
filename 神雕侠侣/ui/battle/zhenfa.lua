BattleZhenFa = {}

setmetatable(BattleZhenFa, Dialog);
BattleZhenFa.__index = BattleZhenFa;

local _instance;

function BattleZhenFa.getInstance()
	if _instance == nil then
		_instance = BattleZhenFa:new();
		_instance:OnCreate();
	end

	return _instance;
end

function BattleZhenFa.peekInstance()
	return _instance;
end

function BattleZhenFa.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function BattleZhenFa:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, BattleZhenFa);

	return zf;
end

function BattleZhenFa.GetLayoutFileName()
	return "zhenfainfo.layout";
end

function BattleZhenFa:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_pFriend = winMgr:getWindow("zhenfainfo/right");
	self.m_pEnemy  = winMgr:getWindow("zhenfainfo/left");

	self.m_pFriend:subscribeEvent("MouseClick", BattleZhenFa.HandleFriendClicked, self);
	self.m_pEnemy:subscribeEvent("MouseClick", BattleZhenFa.HandleEnemyClicked, self);
	
	self.m_iFriendZf = GetBattleManager():GetFriendFormation();
	self.m_iEnemyZf = GetBattleManager():GetEnemyFormation();

	self.m_iFriendZfLv = GetBattleManager():GetFriendFormationLvl();
	self.m_iEnemyZfLv = GetBattleManager():GetEnemyFormationLvl();

	self.m_bFriendBeikezhi = GetBattleManager():IsFriendFormationForbear();
	self.m_bEnemyBeikezhi = GetBattleManager():IsEnemyFormationForbear();

	local fc = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(self.m_iFriendZf);
	local fc2 = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(self.m_iEnemyZf);

	self.m_pFriend:setProperty("Image", fc.imagepath);
	self.m_pEnemy:setProperty("Image", fc2.imagepath);

	print(self.m_iFriendZfLv, self.m_iEnemyZfLv, "+++++++++++++");

	if self.m_iFriendZf == 0 then
		self.m_pFriend:setVisible(false);
	end

	if self.m_iEnemyZf == 0 then
		self.m_pEnemy:setVisible(false);
	end

	if self.m_bFriendBeikezhi == true then
		GetGameUIManager():AddMessageTipById(145371)
	end
end

function BattleZhenFa:HandleFriendClicked(arg)
	local zf = ZhenFaTip.getInstance();
--	self.m_iFriendZfLv = 1;
	zf:SetZhenFa(self.m_iFriendZf, self.m_iFriendZfLv, self.m_bFriendBeikezhi);
end

function BattleZhenFa:HandleEnemyClicked(arg)
	local zf = ZhenFaTip.getInstance();
--	self.m_iEnemyZfLv = 1;
	zf:SetZhenFa(self.m_iEnemyZf, self.m_iEnemyZfLv, self.m_bEnemyBeikezhi);
end

