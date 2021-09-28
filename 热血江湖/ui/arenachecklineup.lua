-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

wnd_arenaCheckLineup = i3k_class("wnd_arenaCheckLineup", ui.wnd_base)

local f_star_icon = {405, 409,410,411,412,413}

function wnd_arenaCheckLineup:ctor()
	
end

function wnd_arenaCheckLineup:configure(...)
	
	self._myHero = {}
	self._myHero.icon = self._layout.vars.myHeroIcon
	self._myHero.blood = self._layout.vars.myHeroBlood
	self._myHero.level = self._layout.vars.myHeroLvl
	self._myHero.name = self._layout.vars.myName
	self._myHero.iconType = self._layout.vars.myIconType
	
	local mypet1 = {}
	mypet1.icon = self._layout.vars.myPetIcon1
	mypet1.blood = self._layout.vars.myPetBlood1
	mypet1.level = self._layout.vars.myPetLvl1
	mypet1.starIcon = self._layout.vars.myStarIcon1
	
	local mypet2 = {}
	mypet2.icon = self._layout.vars.myPetIcon2
	mypet2.blood = self._layout.vars.myPetBlood2
	mypet2.level = self._layout.vars.myPetLvl2
	mypet2.starIcon = self._layout.vars.myStarIcon2
	
	local mypet3 = {}
	mypet3.icon = self._layout.vars.myPetIcon3
	mypet3.blood = self._layout.vars.myPetBlood3
	mypet3.level = self._layout.vars.myPetLvl3
	mypet3.starIcon = self._layout.vars.myStarIcon3
	
	self._myPet = {mypet1, mypet2, mypet3}
	
	
	self._enemyHero = {}
	self._enemyHero.icon = self._layout.vars.enemyHeroIcon
	self._enemyHero.blood = self._layout.vars.enemyHeroBlood
	self._enemyHero.level = self._layout.vars.enemyHeroLvl
	self._enemyHero.name = self._layout.vars.enemyName
	self._enemyHero.iconType = self._layout.vars.enemyIconType
	
	local enemypet1 = {}
	enemypet1.icon = self._layout.vars.enemyPetIcon1
	enemypet1.blood = self._layout.vars.enemyPetBlood1
	enemypet1.level = self._layout.vars.enemyPetLvl1
	enemypet1.starIcon = self._layout.vars.enemyStarIcon1
	
	local enemypet2 = {}
	enemypet2.icon = self._layout.vars.enemyPetIcon2
	enemypet2.blood = self._layout.vars.enemyPetBlood2
	enemypet2.level = self._layout.vars.enemyPetLvl2
	enemypet2.starIcon = self._layout.vars.enemyStarIcon2
	
	local enemypet3 = {}
	enemypet3.icon = self._layout.vars.enemyPetIcon3
	enemypet3.blood = self._layout.vars.enemyPetBlood3
	enemypet3.level = self._layout.vars.enemyPetLvl3
	enemypet3.starIcon = self._layout.vars.enemyStarIcon3
	
	self._enemyPet = {enemypet1, enemypet2, enemypet3}
end

function wnd_arenaCheckLineup:onShow()
	
end

function wnd_arenaCheckLineup:refresh(logs)
	
	local myInfo = g_i3k_game_context:GetRoleInfo()
	local myId = myInfo.curChar._id
	
	

	if logs.isWin then
		self._layout.vars.myResultImg:setImage(i3k_db_icons[416].path)
		self._layout.vars.myLineup:setTextColor("FFFEDB45")
		self._layout.vars.enemyResultImg:setImage(i3k_db_icons[417].path)
		self._layout.vars.enemyLineup:setTextColor("FFCE81FF")
	else
		self._layout.vars.myResultImg:setImage(i3k_db_icons[417].path)
		self._layout.vars.myLineup:setTextColor("FFCE81FF")
		self._layout.vars.enemyResultImg:setImage(i3k_db_icons[416].path)
		self._layout.vars.enemyLineup:setTextColor("FFFEDB45")
	end
	
	local myLineup
	local enemyLineup
	
	if logs.attackingSide.role.overview.id == myId then
		myLineup = logs.attackingSide
		enemyLineup = logs.defendingSide
	else
		myLineup = logs.defendingSide
		enemyLineup = logs.attackingSide
	end
	local myPets = {}
	for k,v in pairs(myLineup.pets) do
		table.insert(myPets, v)
	end
	myLineup.pets = myPets

	local enemyPets = {}
	for k,v in pairs(enemyLineup.pets) do
		table.insert(enemyPets, v)
	end
	enemyLineup.pets = enemyPets

	
	self._layout.vars.close:onClick(self, self.onClose)
	
	local myPet1Root = self._layout.vars.myPet1
	local myPet2Root = self._layout.vars.myPet2
	local myPet3Root = self._layout.vars.myPet3
	local myPetRoot = {myPet1Root, myPet2Root, myPet3Root}
	
	local enemyPet1Root = self._layout.vars.enemyPet1
	local enemyPet2Root = self._layout.vars.enemyPet2
	local enemyPet3Root = self._layout.vars.enemyPet3
	local enemyPetRoot = {enemyPet1Root, enemyPet2Root, enemyPet3Root}
	
	for i,v in pairs(myPetRoot) do
		v:hide()
	end

	for i,v in pairs(myLineup.pets) do
		myPetRoot[i]:show()
	end
	
	for i,v in pairs(enemyPetRoot) do
		v:hide()
	end
	for i,v in pairs(enemyLineup.pets) do
		enemyPetRoot[i]:show()
	end
		
	self:setData(myLineup, enemyLineup)
end

function wnd_arenaCheckLineup:setData(myLineup, enemyLineup)
	--设置自己的主将及佣兵
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(myLineup.role.overview.headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		self._myHero.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	self._myHero.blood:setPercent(100*myLineup.role.curHp/myLineup.role.maxHp)
	self._myHero.iconType:setImage(g_i3k_get_head_bg_path(myLineup.role.overview.bwType, myLineup.role.overview.headBorder))
	self._myHero.level:setText(myLineup.role.overview.level)
	self._myHero.name:setText(myLineup.role.overview.name)
	local power = 0
	for i,v in pairs(myLineup.pets) do
		local iconId = g_i3k_db.i3k_db_get_head_icon_id(v.overview.id)
		self._myPet[i].icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		self._myPet[i].level:setText(v.overview.level)
		self._myPet[i].blood:setPercent(v.curHp/v.maxHp*100)
		self._myPet[i].starIcon:setImage(i3k_db_icons[f_star_icon[v.overview.star+1]].path)
		power = power + g_i3k_game_context:getBattlePower(v.overview.id)
	end
	
	self._layout.vars.myPower:setText(math.ceil(myLineup.role.overview.fightPower + power))
	
	
	--设置敌人的主将及佣兵
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(enemyLineup.role.overview.headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		self._enemyHero.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	self._enemyHero.iconType:setImage(g_i3k_get_head_bg_path(enemyLineup.role.overview.bwType, enemyLineup.role.overview.headBorder))
	self._enemyHero.blood:setPercent(100*enemyLineup.role.curHp/enemyLineup.role.maxHp)
	self._enemyHero.level:setText(enemyLineup.role.overview.level)
	self._enemyHero.name:setText(enemyLineup.role.overview.name)
	local petsPower = 0
	if enemyLineup.role.overview.id<0 then
		local robot = i3k_db_arenaRobot[math.abs(enemyLineup.role.overview.id)]
		enemyLineup.role.overview.fightPower = robot.power
	else
		for i,v in pairs(enemyLineup.pets) do
			petsPower = petsPower + v.overview.fightPower
		end
	end
	self._layout.vars.enemyPower:setText(enemyLineup.role.overview.fightPower + petsPower)
	
	local enemyId = enemyLineup.role.overview.id
	local isRobot = false
	if enemyId<0 then
		isRobot = true
	end
	for i,v in pairs(enemyLineup.pets) do
		local iconId = g_i3k_db.i3k_db_get_head_icon_id(v.overview.id)
		self._enemyPet[i].icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		self._enemyPet[i].level:setText(v.overview.level)
		local percent = 100*v.curHp/v.maxHp
		self._enemyPet[i].blood:setPercent(v.curHp/v.maxHp*100)
		self._enemyPet[i].starIcon:setImage(i3k_db_icons[f_star_icon[v.overview.star+1]].path)
	end
end

function wnd_arenaCheckLineup:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaCheckLineup)
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaCheckLineup.new();
		wnd:create(layout, ...);

	return wnd;
end
