-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaSetBattle = i3k_class("wnd_arenaSetBattle", ui.wnd_base)

local star_icon = {405,409,410,411,412,413}

function wnd_arenaSetBattle:ctor()
	self._playPets = {}
end

function wnd_arenaSetBattle:configure(...)
	self._layout.vars.close:onClick(self, self.onClose)
	
	local pet1 = {}
	local icon2 = self._layout.vars.enemyIcon2
	local lvl2 = self._layout.vars.enemyLvl2
	local star1 = self._layout.vars.enemyStarIcon2
	pet1.icon = icon2
	pet1.lvl = lvl2
	pet1.star = star1
	
	local pet2 = {}
	local icon3 = self._layout.vars.enemyIcon3
	local lvl3 = self._layout.vars.enemyLvl3
	local star2 = self._layout.vars.enemyStarIcon3
	pet2.icon = icon3
	pet2.lvl = lvl3
	pet2.star = star2
	
	local pet3 = {}
	local icon4 = self._layout.vars.enemyIcon4
	local lvl4 = self._layout.vars.enemyLvl4
	local star3 = self._layout.vars.enemyStarIcon4
	pet3.icon = icon4
	pet3.lvl = lvl4
	pet3.star = star3
	self._mercenaryTable = {pet1, pet2, pet3}
	
	
	
	local myPet1 = {}
	myPet1.icon = self._layout.vars.icon2
	myPet1.lvl = self._layout.vars.lvl2
	myPet1.btn = self._layout.vars.btn2
	myPet1.star = self._layout.vars.myStarIcon2
	
	local myPet2 = {}
	myPet2.icon = self._layout.vars.icon3
	myPet2.lvl = self._layout.vars.lvl3
	myPet2.btn = self._layout.vars.btn3
	myPet2.star = self._layout.vars.myStarIcon3
	
	local myPet3 = {}
	myPet3.icon = self._layout.vars.icon4
	myPet3.lvl = self._layout.vars.lvl4
	myPet3.btn = self._layout.vars.btn4
	myPet3.star = self._layout.vars.myStarIcon4
	
	self._myPets = {myPet1, myPet2, myPet3}
	
	
	
	self._enemyPetRoot = {self._layout.vars.enemyPet1Root, self._layout.vars.enemyPet2Root, self._layout.vars.enemyPet3Root}
	self._myPetRoot = {self._layout.vars.myPet1Root, self._layout.vars.myPet2Root, self._layout.vars.myPet3Root}
	for i,v in pairs(self._enemyPetRoot) do
		v:hide()
		self._myPetRoot[i]:hide()
	end
	self.hiedDesc = self._layout.vars.hiedDesc
end

function wnd_arenaSetBattle:refresh(enemyRole, enemyRank, enemyMercenaries, myRank, hideDefence)
	local arenaPets = g_i3k_game_context:GetArenaPet()
	if g_i3k_game_context:GetPetCount() == 1 and #arenaPets == 0 then
		local data = g_i3k_game_context:GetAllYongBing()
		for _,v in pairs(data) do
			g_i3k_game_context:SetArenaPet(i3k_db_mercenaries[v.id])
		end
	end
	local enemy = enemyRole
	enemy.rank = enemyRank
	local enemyPets = {}
	local petsPower = 0
	if enemy.id < 0 then
		local enemyRobot = i3k_db_arenaRobot[math.abs(enemy.id)]
		if enemyRobot then
			if enemyRobot.petId1~=0 then
				local pet1 = i3k_db_mercenaries[enemyRobot.petId1]
				pet1.level = enemyRobot.petLvl1
				table.insert(enemyPets, pet1)
			end
			if enemyRobot.petId2~=0 then
				local pet2 = i3k_db_mercenaries[enemyRobot.petId2]
				pet2.level = enemyRobot.petLvl2
				table.insert(enemyPets, pet2)
			end
			if enemyRobot.petId3~=0 then
				local pet3 = i3k_db_mercenaries[enemyRobot.petId3]
				pet3.level = enemyRobot.petLvl3
				table.insert(enemyPets, pet3)
			end
		end
	else
		for k,v in pairs(enemyMercenaries) do
			if v.id ~= 0 then
				local pet = i3k_db_mercenaries[k]
				if pet then
					v.iconID = pet.iconID
				end
				if v.awakeUse and v.awakeUse.use and v.awakeUse.use == 1 then
					local waken = i3k_db_mercenariea_waken_property[k];
					if waken then
						v.iconID = waken.headIcon;
					end
				end
				v.starlvl = v.star
				table.insert(enemyPets, v)
			end
			petsPower = petsPower + v.fightPower
		end
	end
	local needValue = {myRank = myRank, enemy = enemy}
	
	self._layout.vars.fightBtn:onClick(self, self.startFight, needValue)
	
	
	local isRobot = true
	self._layout.vars.enemyIcon1:setImage(g_i3k_db.i3k_db_get_head_icon_path(enemy.headIcon, false))
	self._layout.vars.enemyLvl1:setText(enemy.level)
	self._layout.vars.enemyPower:setText(enemy.fightPower + petsPower)
	self._layout.vars.enemyIconType:setImage(g_i3k_get_head_bg_path(enemy.bwType))
	if enemy.id<0 then
		for i,v in pairs(self._mercenaryTable) do
			v.star:setImage(i3k_db_icons[star_icon[1]].path)
		end
	else
		isRobot = false
	end
	
	
	for i,v in pairs(enemyPets) do
		self._enemyPetRoot[i]:show()
		local iconId = g_i3k_db.i3k_db_get_head_icon_id(v.id)
		self._mercenaryTable[i].icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		self._mercenaryTable[i].lvl:setText(v.level)
		self._layout.vars["enemyIconBg"..i]:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[v.id].rank))
		if isRobot then
			
		else
			self._mercenaryTable[i].star:setImage(i3k_db_icons[star_icon[v.starlvl+1]].path)
		end
	end
	
	
	local hero = i3k_game_get_logic():GetPlayer():GetHero()
	local myIcon = self._layout.vars.icon1
	local myLvl = self._layout.vars.lvl1
	local iconType = self._layout.vars.iconType
	local myPower = self._layout.vars.myPower
	
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		myIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	myLvl:setText(hero._lvl)
	myPower:setText(hero:Appraise())
	self.hiedDesc:setText(i3k_get_string(15359))
	self.hiedDesc:setVisible(hideDefence == 1)
	self:setData()
end

function wnd_arenaSetBattle:onShow()
	
end

function wnd_arenaSetBattle:setData()
	
	local have_pet , play_data = g_i3k_game_context:GetYongbingData()
	local count = 0
	if play_data[2] then
		count = #play_data[2]
	end
	if self._cancelBtn then
		for i=1, count do
			self._cancelBtn[i]:setTouchEnabled(true)
		end
	end
	local scroll = self._layout.vars.scroll 
	
	local arenaPetTable = g_i3k_game_context:GetArenaPet()
	local power = 0
	for i,v in pairs(arenaPetTable) do
		self._myPetRoot[i]:show()
		local mercenaryPower = g_i3k_game_context:getBattlePower(v.id)
		power = power + mercenaryPower
		local iconId = g_i3k_db.i3k_db_get_head_icon_id(v.id)
		if g_i3k_game_context:getPetWakenUse(v.id) then
			iconId = i3k_db_mercenariea_waken_property[v.id].headIcon;
		end
		self._myPets[i].icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		local starLvl =  have_pet[v.id].starlvl
		self._myPets[i].star:setImage(i3k_db_icons[star_icon[starLvl+1]].path)
		self._layout.vars["iconBg"..i]:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[v.id].rank))
		self._myPets[i].icon:show()
		for j,k in pairs(have_pet) do
			if k.id==v.id then
				self._myPets[i].lvl:setText(k.level)
			end
		end
		self._myPets[i].btn:setTag(v.id+10000)
		self._myPets[i].btn:onClick(self, self.playCancel)
	end
	local hero = i3k_game_get_player_hero()
	self._layout.vars.myPower:setText(hero:Appraise() + power)
	g_i3k_game_context:SetAttackPower(hero:Appraise() + power)
	if scroll then
		self._isSelect = {}
		local width = scroll:getContentSize().width
		local height = scroll:getContentSize().height
		
		
		local allPets, playPets = g_i3k_game_context:GetYongbingData(true)
		local petsCount = 0
		for i,v in pairs(allPets) do
			petsCount = petsCount + 1
		end
		
		local children = scroll:addChildWithCount("ui/widgets/scczt", 5, petsCount)
		scroll:setBounceEnabled(false)
		
		for i,v in ipairs(children) do
			local id = allPets[i].id
			local lvl = allPets[i].level
			local star =  allPets[i].starlvl
			local name = i3k_db_mercenaries[id].name
			local iconid = g_i3k_db.i3k_db_get_head_icon_id(id)
			if g_i3k_game_context:getPetWakenUse(id) then
				iconid = i3k_db_mercenariea_waken_property[id].headIcon;
			end
			v.vars.pet_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconid, true))
			v.vars.pet_iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
			v.vars.level_label:setText(lvl)
			--v.vars.name:setText(name)
			v.vars.start_icon:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[star+1]))
			local mercenaryPower = g_i3k_game_context:getBattlePower(id)
			v.vars.pet_power:setText(mercenaryPower)
			v.vars.play_btn:setTag(i+1000)
			table.insert(self._isSelect, v.vars.isSelect)
			v.vars.isSelect:hide()
			v.vars.play_btn:onClick(self,self.onPetPlay)
			for _,t in pairs(arenaPetTable) do
				if t.id==id then
					v.vars.isSelect:show()
					table.insert(self._playPets, v.vars.isSelect)
				end
			end
		end
	end
end

function wnd_arenaSetBattle:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaSetBattle)
end

function wnd_arenaSetBattle:onPetPlay(sender)
	local petsTable = g_i3k_game_context:GetArenaPet()
	local index = sender:getTag()-1000
	
	local isSelect = self._isSelect[index]
	local isShow = isSelect:isVisible()
	if #petsTable<3 or isShow then
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		if isShow then
			isSelect:hide()
			for i,v in pairs(self._playPets) do
				if v==isSelect then
					table.remove(self._playPets, i)
				end
			end
		else
			if #self._playPets<3 then
				table.insert(self._playPets, isSelect)
			else
				local select1 = self._playPets[1]
				table.remove(self._playPets, 1)
				table.insert(self._playPets, isSelect)
				select1:hide()
			end
			isSelect:show()
		end
		local sortPets, playPets = g_i3k_game_context:GetYongbingData(true)
		
		local mercenary = i3k_db_mercenaries[sortPets[index].id]
		g_i3k_game_context:SetYongbingPlay(mercenary.id, 4)
		g_i3k_game_context:SetArenaPet(mercenary)
		local arenaPetTable = g_i3k_game_context:GetArenaPet()
		
		
		for i,v in pairs(self._myPetRoot) do
			v:hide()
		end
		local power = 0
		for i,v in pairs(arenaPetTable) do
			self._myPetRoot[i]:show()
			local mercenaryPower = g_i3k_game_context:getBattlePower(v.id)
			power = power + mercenaryPower
			local starLvl =  allPets[v.id].starlvl
			self._myPets[i].star:setImage(i3k_db_icons[star_icon[starLvl+1]].path)
			local iconId = g_i3k_db.i3k_db_get_head_icon_id(v.id)
			if g_i3k_game_context:getPetWakenUse(v.id) then
				iconId = i3k_db_mercenariea_waken_property[v.id].headIcon;
			end
			self._myPets[i].icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			self._layout.vars["iconBg"..i]:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[v.id].rank))
			self._myPets[i].icon:show()
			--if i==#arenaPetTable then
				self._myPets[i].btn:setTag(v.id+10000)
				self._myPets[i].btn:onClick(self, self.playCancel)
			--end
			for j,k in pairs(allPets) do
				if k.id==v.id then
					self._myPets[i].lvl:setText(k.level)
				end
			end
		end
		local hero = i3k_game_get_player_hero()
		self._layout.vars.myPower:setText(hero:Appraise() + power)
		g_i3k_game_context:SetAttackPower(hero:Appraise() + power)
	end
end

function wnd_arenaSetBattle:playCancel(sender)
	local tag = sender:getTag()-10000
	local scroll = self._layout.vars.scroll
	local children = scroll:getAllChildren()
	local havePets, playPets = g_i3k_game_context:GetYongbingData(true)
	for i,v in pairs(havePets) do
		if v.id==tag then
			self:onPetPlay(children[i].vars.play_btn)
		end
	end
end

function wnd_arenaSetBattle:startFight(sender, needValue)
	local func = function ()
		local arenaPetTable = g_i3k_game_context:GetArenaPet()
		local petCount = g_i3k_game_context:GetPetCount()
		petCount = petCount < 3 and petCount or 3
		if #arenaPetTable ~= petCount then
			local callback = function (isOk)
				if not isOk then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaSetBattle, "startFightCB", needValue)
				end
			end 
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(286), callback)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaSetBattle, "startFightCB", needValue)
		end
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_arenaSetBattle:startFightCB(needValue)
	if g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	local arenaPetTable = g_i3k_game_context:GetArenaPet()
	g_i3k_game_context:ClearFindWayStatus()
	local fight = i3k_sbean.arena_startattack_req.new()
	fight.selfRank = needValue.myRank
	fight.targetRoleId = needValue.enemy.id
	fight.targetRank = needValue.enemy.rank
	local pets = {}
	for i,v in ipairs(arenaPetTable) do
		table.insert(pets, v.id)
	end
	fight.selfPets = pets
	fight.petNum = #arenaPetTable
	i3k_game_send_str_cmd(fight, i3k_sbean.arena_startattack_res.getName())
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaSetBattle.new();
		wnd:create(layout, ...);

	return wnd;
end