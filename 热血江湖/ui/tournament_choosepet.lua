-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tournament_choosePet = i3k_class("wnd_tournament_choosePet", ui.wnd_base)

local star_icon = {405,409,410,411,412,413}
local WIDGET_CZT = "ui/widgets/hdscczt"
local RowitemCount = 5 --每行随从个数

function wnd_tournament_choosePet:ctor()
	self._isChange = false
end

function wnd_tournament_choosePet:configure()
	self._layout.vars.closeBtn:onClick(self, self.saveData)
	
	local petRoot1 = self._layout.vars.petRoot1
	local petBtn1 = self._layout.vars.petBtn1
	local petIcon1 = self._layout.vars.petIcon1
	local petStar1 = self._layout.vars.petStar1
	local petLvl1 = self._layout.vars.petLvl1
	local pet1 = {root = petRoot1, btn = petBtn1, icon = petIcon1, star = petStar1, level = petLvl1}
	--[[
	local petRoot2 = self._layout.vars.petRoot2
	local petBtn2 = self._layout.vars.petBtn2
	local petIcon2 = self._layout.vars.petIcon2
	local petStar2 = self._layout.vars.petStar2
	local petLvl2 = self._layout.vars.petLvl2
	local pet2 = {root = petRoot2, btn = petBtn2, icon = petIcon2, star = petStar2, level = petLvl2}
	
	local petRoot3 = self._layout.vars.petRoot3
	local petBtn3 = self._layout.vars.petBtn3
	local petIcon3 = self._layout.vars.petIcon3
	local petStar3 = self._layout.vars.petStar3
	local petLvl3 = self._layout.vars.petLvl3
	local pet3 = {root = petRoot3, btn = petBtn3, icon = petIcon3, star = petStar3, level = petLvl3}
	]]
	self._petsTable = {pet1}
	
	
	self.scroll = self._layout.vars.scroll
	self.headBg = self._layout.vars.headBg
end

function wnd_tournament_choosePet:refresh()
	self:setData()
end

function wnd_tournament_choosePet:setData()
	self.headBg:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype()))
	for i,v in ipairs(self._petsTable) do
		v.root:hide()
		self._layout.vars.noPetRoot1:show()
	end
	
	local hero = i3k_game_get_player_hero()
	local roleLvl = g_i3k_game_context:GetLevel()
	--[[
	local totalCount = 0
	
	if roleLvl >= i3k_db_common.posUnlock.first and roleLvl < i3k_db_common.posUnlock.second then
		totalCount = 1
	elseif roleLvl >= i3k_db_common.posUnlock.second and roleLvl < i3k_db_common.posUnlock.third then
		totalCount = 2
	else
		totalCount = 3
	end
	
	local lvlTable = {self._layout.vars.nRoot1, self._layout.vars.nRoot2, self._layout.vars.nRoot3}
	
	for i,v in ipairs(lvlTable) do
		if i>totalCount then
			v:show()
			self._petsTable[i].root:hide()
			self._noPetTable[i]:hide()
		else
			v:hide()
		end
	end
	
	local descTable = {self._layout.vars.nRoot1_desc, self._layout.vars.nRoot2_desc, self._layout.vars.nRoot3_desc}
	local lvlLimit = {i3k_db_common.posUnlock.first, i3k_db_common.posUnlock.second, i3k_db_common.posUnlock.third}
	for i,v in ipairs(descTable) do
		if i>totalCount then
			v:show()
			v:setText(string.format("%s级开放", lvlLimit[i]))
		else
			v:hide()
		end
	end
	]]
	self._layout.vars.heroLvl:setText(roleLvl)
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie)
	if hicon and hicon > 0 then
		self._layout.vars.heroIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
	
	local heroPower = hero:Appraise()
	
	local allPets, playPets = g_i3k_game_context:GetYongbingData()
	local fightPetID = g_i3k_game_context:GetTournamentPet()
	local power = 0
	if fightPetID ~= 0 then
		self._layout.vars.noPetRoot1:hide()
		local pets = self._petsTable[1]
		pets.root:show()
		local iconId = i3k_db_mercenaries[fightPetID].icon
		if g_i3k_game_context:getPetWakenUse(fightPetID) then
			iconId = i3k_db_mercenariea_waken_property[fightPetID].headIcon;
		end
		pets.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		self._layout.vars.petIconBg1:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[fightPetID].rank))
		pets.star:setImage(i3k_db_icons[star_icon[allPets[fightPetID].starlvl+1]].path)
		pets.level:setText(allPets[fightPetID].level)
		pets.btn:setTag(fightPetID+1000)
		pets.btn:onClick(self, self.onPetPlay)
		power = power + g_i3k_game_context:getBattlePower(fightPetID)
	end
	local count = 0
	local petsTable, playPets = g_i3k_game_context:GetYongbingData(true)
	self._havePets = petsTable
	
	for i,v in pairs(allPets) do
		count = count + 1
	end
	
	local children = self.scroll:addChildWithCount(WIDGET_CZT, RowitemCount, count)
	for i,v in ipairs(children) do
		local pet = self._havePets[i]
		local mercenary = i3k_db_mercenaries[pet.id]
		local iconId = mercenary.icon
		if g_i3k_game_context:getPetWakenUse(pet.id) then
			iconId = i3k_db_mercenariea_waken_property[pet.id].headIcon;
		end
		v.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		v.vars.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(mercenary.rank))
		v.vars.level:setText(pet.level)
		v.vars.starIcon:setImage(i3k_db_icons[star_icon[pet.starlvl+1]].path)
		v.vars.isSelect:hide()
		--[[
		local fightCount = 0
		for _,t in pairs(fightPets) do
			fightCount = fightCount+1
			if t.id==pet.id then
				v.vars.isSelect:show()
			end
		end]]
		if fightPetID == pet.id then
			v.vars.isSelect:show()
		end
		v.vars.btn:setTag(pet.id+1000)
		v.vars.btn:onClick(self, self.onPetPlay)
	end
	
	self._layout.vars.powerLabel:setText(math.ceil(heroPower+power))
end

function wnd_tournament_choosePet:onPetPlay(sender)
	local id = sender:getTag()-1000
	g_i3k_game_context:SetTournamentPet(id)
	self._isChange = true
	self:setData()
end

function wnd_tournament_choosePet:saveData(sender)
	if self._isChange then
		local fightPetID = g_i3k_game_context:GetTournamentPet()
		i3k_sbean.superarena_setpets(fightPetID)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_TournamentChoosePet)
	end
end

function wnd_create(layout)
	local wnd = wnd_tournament_choosePet.new()
	wnd:create(layout)
	return wnd
end

