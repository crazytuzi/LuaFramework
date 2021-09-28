-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_layer = i3k_class("wnd_faction_dungeon_layer", ui.wnd_base)

--体力id
local PHYSICLAID = 101
local star_icon = {405,409,410,411,412,413}
local show_count = 1


function wnd_faction_dungeon_layer:ctor()
	self._id = nil
	self._pet_root = {}
	self._boss_root = {}
	
	self._unlock_root = {}
end



function wnd_faction_dungeon_layer:configure(...)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	local apply_award = widgets.apply_award 
	apply_award:onTouchEvent(self,self.onApplyAward)
	local hurtList_btn = widgets.hurtList_btn 
	hurtList_btn:onTouchEvent(self,self.onHurtList)
	self.challenge_boss = widgets.challenge_boss 
	self.challenge_boss:onTouchEvent(self,self.onChallengeBoss)
	local adjustPet_btn = widgets.adjustPet_btn 
	adjustPet_btn:onTouchEvent(self,self.onAdjustPet)
	
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	local myIcon = widgets.myIcon 
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon,g_i3k_db.eHeadShapeCircie)
	if hicon then
		myIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
	local _level = g_i3k_game_context:GetLevel()
	local my_level = widgets.my_level 
	my_level:setText(_level)
	local have_desc = widgets.have_desc 
	have_desc:setText("剩余次数：")
	local roleHeadBg = widgets.roleHeadBg 
	roleHeadBg:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	self.have_count = widgets.have_count 
	self.dungeonName = widgets.dungeonName 
	self._dungeonName = widgets._dungeonName 
	self.dungeon_desc = widgets.dungeon_desc 
	self.noRoot = widgets.noRoot 
	self.haveRoot = widgets.haveRoot 
	self.playingName = widgets.playingName 
	self.playingIcon = widgets.playingIcon 
	self.playingState = widgets.playingState 
	self.bigBossIcon = widgets.bigBossIcon 
	self.bigBossBlood = widgets.bigBossBlood 
	self.revengeIcon = widgets.revengeIcon
	
	for i=1 ,3 do
		local tmppetRoot = string.format("petRoot%s",i)
		local petRoot = widgets[tmppetRoot]
		petRoot:hide()
		local tmp_no = string.format("noPet%s",i)
		local noPet = widgets[tmp_no]
		local tmp_icon = string.format("petIcon%s",i)
		local petIcon = widgets[tmp_icon]
		local tmp_star = string.format("petStar%s",i)
		local petStar = widgets[tmp_star]
		local tmp_lvl = string.format("level%s",i)
		local level = widgets[tmp_lvl]
		
		self._pet_root[i] = {petRoot = petRoot,noPet = noPet,petIcon = petIcon,petStar = petStar,level = level}
	end
	
	for i=1, 6 do
		local tmp_boss_icon = string.format("bossIcon%s",i)
		local bossIcon = widgets[tmp_boss_icon]
		
		local tmp_boss_blood = string.format("bossBlood%s",i)
		local bossBlood = widgets[tmp_boss_blood]
		local temp_dead = string.format("bossDead%s",i)
		local bossDead = widgets[temp_dead]
		local temp_root = string.format("bloodRoot%s",i)
		local bloodRoot = widgets[temp_root]
		local temp_root = string.format("bossRoot%s",i)
		local bossRoot = widgets[temp_root]
		self._boss_root[i] = {bossIcon = bossIcon,bossBlood = bossBlood,bossDead = bossDead,bloodRoot = bloodRoot,bossRoot = bossRoot}	
	end
	
	for i=2,3 do
		local tmp_root = string.format("nroot%s",i)
		local nroot = widgets[tmp_root]
		
		local tmp_desc = string.format("nroot_desc%s",i)
		local nroot_desc = widgets[tmp_desc]
		
		self._unlock_root[i] = {nroot = nroot,nroot_desc = nroot_desc}
	end
	
	self.boss_name = widgets.boss_name 
	
	self.vit_count = widgets.vit_count
	widgets.addVit:onClick(self, self.onAddVitBtnClick)
end

function wnd_faction_dungeon_layer:onShow()
	
end


function wnd_faction_dungeon_layer:updateUserVit(count)
	self.vit_count:setText(string.format("%s/%s", i3k_db_faction_dungeon[self._id].physicalCount, count))
	self.vit_count:setTextColor(g_i3k_get_cond_color(i3k_db_faction_dungeon[self._id].physicalCount <= count))
end 

function wnd_faction_dungeon_layer:updateBaseData()
	if not self._id then
		return 
	end
	local id = self._id;
	if g_i3k_game_context:isSpecialFacionDungeon(self._id) then
		local special = g_i3k_game_context:getSpecialDungeonID();
		if special and special[id] then
			id = special[self._id ];
		end
	end
	local _num = g_i3k_game_context:getDungeonDayEnterTimes(id)
	local maxCount = i3k_db_faction_dungeon[self._id].openType
	self.have_count:setText(maxCount - _num)
	local name = i3k_db_dungeon_base[self._id].desc
	self.dungeonName:setText(name)
	self._dungeonName:setText(name)
	self.revengeIcon:hide()
	self:updateBoosData()
	self:updatePetData()
	local data = g_i3k_game_context:GetFactionDungeonData()
	local state = g_i3k_game_context:getFacionDungeonState()
	local is_have = false
	if data[self._id].curAttacker then
		is_have = true
	end
	if g_i3k_game_context:isSpecialFacionDungeon(self._id) then
		self.revengeIcon:show()
	end
	if not is_have then
		self.noRoot:show()
		self.haveRoot:hide()
	else 
		self.haveRoot:show()
		self.playingName:setText(data[self._id].curAttacker.name)
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(data[self._id].curAttacker.headIcon,g_i3k_db.eHeadShapeCircie)
		if hicon and hicon > 0 then
			self.playingIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		self.playingState:setText("战斗中.")
		self._timer = i3k_game_timer_dungeon_layer.new()
		self._timer:onTest()
	end
	self.dungeon_desc:setText(i3k_db_faction_dungeon[self._id].desc)
	self:updateUserVit(g_i3k_game_context:GetVit())
end

function wnd_faction_dungeon_layer:updateBoosData()
	local data = g_i3k_game_context:GetFactionDungeonData()
	if data[self._id] then
		local bigBossBloodValue = 0
		local bigBossPos = i3k_db_faction_dungeon[self._id].monsterID1
		if data[self._id] and data[self._id].bossHp then
			bigBossBloodValue = data[self._id].bossHp
		end
		local bigBossID = i3k_db_spawn_point[bigBossPos].monsters[1]
		local bigBossIconid = i3k_db_monsters[bigBossID].icon
		local bigBossName = i3k_db_monsters[bigBossID].name
		self.boss_name:setText(bigBossName)
		bigBossBloodValue = 1 - bigBossBloodValue/10000
		self.bigBossIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(bigBossIconid,false))
		self.bigBossBlood:setPercent(bigBossBloodValue*100)
		for i=1, 6 do
			local a = i+1
			local tmp_monsterID = string.format("monsterID%s",a)
			local bigBossPos = i3k_db_faction_dungeon[self._id][tmp_monsterID]
			if bigBossPos and bigBossPos~=0 then
				local bigBossID = i3k_db_spawn_point[bigBossPos].monsters[1]
				local bigBossIconid = i3k_db_monsters[bigBossID].icon
				local bigBossBloodValue = 0
				local bigBossBloodValue = 0
				if data[self._id].progress and data[self._id].progress[bigBossPos] then
					bigBossBloodValue = data[self._id].progress[bigBossPos]
				end
				bigBossBloodValue = 10000 - bigBossBloodValue 
				local bossIcon = self._boss_root[i].bossIcon
				bossIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(bigBossIconid,true))
				local bossBlood = self._boss_root[i].bossBlood
				bossBlood:setPercent(bigBossBloodValue*100/10000)
				local bossDead = self._boss_root[i].bossDead
				bossDead:hide()
				local bloodRoot = self._boss_root[i].bloodRoot
				if bigBossBloodValue == 0 then
					bossDead:show()
					bloodRoot:hide()
					bossIcon:disable()
				end
			else	
				local bossRoot = self._boss_root[i].bossRoot
				bossRoot:hide()
			end
		end
	end
end 

function wnd_faction_dungeon_layer:updatePetData()
	local have_pet,play_data = g_i3k_game_context:GetYongbingData()
	local hero_lvl = g_i3k_game_context:GetLevel()
	local first = i3k_db_common.posUnlock.first
	local second = i3k_db_common.posUnlock.second
	local third = i3k_db_common.posUnlock.third
	for i=2,3 do
		if i == 2 then
			if hero_lvl < second then
				self._unlock_root[i].nroot:show()
				self._unlock_root[i].nroot_desc:setText(i3k_get_string(47,second))
				self._pet_root[i].noPet:hide()
			else
				self._unlock_root[i].nroot:hide()
				self._pet_root[i].noPet:show()
			end
		elseif i == 3 then
			if hero_lvl < third then
				self._unlock_root[i].nroot:show()
				self._unlock_root[i].nroot_desc:setText(i3k_get_string(47,third))
				self._pet_root[i].noPet:hide()
			else
				self._unlock_root[i].nroot:hide()
				self._pet_root[i].noPet:show()
			end
		end
		
	end 
	
	for i=1,3 do
		local petRoot = self._pet_root[i].petRoot
		petRoot:hide()
		local noPet = self._pet_root[i].noPet
		if play_data and play_data[FACTION_DUNGEON] and play_data[FACTION_DUNGEON][i] then
			local id = play_data[FACTION_DUNGEON][i]
			petRoot:show()
			petRoot:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
			--noPet:hide()
			local lvl = have_pet[id].level
			local star =  have_pet[id].starlvl
			local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id)
			local petIcon =self._pet_root[i].petIcon
			local iconId = cfg_data.icon;
			if g_i3k_game_context:getPetWakenUse(id) then
				iconId = i3k_db_mercenariea_waken_property[id].headIcon;
			end
			petIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			local petStar = self._pet_root[i].petStar
			petStar:setImage(i3k_db_icons[star_icon[star+1]].path)
			local level = self._pet_root[i].level
			level:setText(lvl)
		else
			--noPet:show()
		end
	end
end 

function wnd_faction_dungeon_layer:onApplyAward(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sectmap_allocation_req.new()
		local state = g_i3k_game_context:getFacionDungeonState();
		local special = g_i3k_game_context:getSpecialDungeonID();
		local specialDungeon = i3k_db_faction_dungeon[self._id].specialDungeon;
		if specialDungeon == -1 and special[self._id] then
			data.mapId = special[self._id ];
		else
			data.mapId = self._id
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_allocation_res.getName())
	end
end

function wnd_faction_dungeon_layer:onHurtList(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sectmap_damage_req.new()
		local state = g_i3k_game_context:getFacionDungeonState();
		local special = g_i3k_game_context:getSpecialDungeonID();
		local specialDungeon = i3k_db_faction_dungeon[self._id].specialDungeon;
		if specialDungeon == -1 and special[self._id ] then
			data.mapId = special[self._id ];
		else
			data.mapId = self._id
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_damage_res.getName())
	end
end

function wnd_faction_dungeon_layer:onChallengeBoss(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local needLvl = i3k_db_faction_dungeon[self._id].enterLevel
		local needPower = i3k_db_faction_dungeon[self._id].physicalCount
		local hero_lvl = g_i3k_game_context:GetLevel()
		if hero_lvl < needLvl then
			g_i3k_ui_mgr:PopupTipMessage("等级不足不可进入该副本")
			return 
		end
		local vit = g_i3k_game_context:GetVit()
		if vit < needPower then
			g_i3k_logic:GotoOpenBuyVitUI()
			return 
		end
		local id = self._id;
		if g_i3k_game_context:isSpecialFacionDungeon(self._id) then
			local special = g_i3k_game_context:getSpecialDungeonID();
			if special and special[id] then
				id = special[self._id ];
			end
		end
		local _num = g_i3k_game_context:getDungeonDayEnterTimes(id)
		local maxCount = i3k_db_faction_dungeon[self._id].openType
		if _num >= maxCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10043))
			return 
		end
		local room = g_i3k_game_context:IsInRoom()
		if room then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(312))
			return
		end
		
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local count = 0
		if playPets[FACTION_DUNGEON] then
			count = #playPets[FACTION_DUNGEON]
		end
		local have = 0
		for k,v in pairs(allPets) do
			have = have + 1
		end
		local max_count = 1
		local first = g_i3k_db.i3k_db_get_common_cfg().posUnlock.first;
		local second = g_i3k_db.i3k_db_get_common_cfg().posUnlock.second;
		local third = g_i3k_db.i3k_db_get_common_cfg().posUnlock.third;
		if hero_lvl >= third then
			max_count = 3
		elseif hero_lvl >= second then
			max_count = 2
		end
		local state = g_i3k_game_context:getFacionDungeonState()
		local mapid = self._id
				
		local function fun5() --进入副本
			g_i3k_game_context:ClearFindWayStatus()
			self:enterDungeon(mapid)
		end
		
		
		local fun4 = function () --判断随从
			if count < max_count and have - count > 0 then
				local fun = (function(ok)
					if ok then
						g_i3k_ui_mgr:OpenUI(eUIID_FactionSuicongPlay)
						g_i3k_ui_mgr:RefreshUI(eUIID_FactionSuicongPlay)
					else
						fun5()
					end
				end)
				local desc = i3k_get_string(286)
				g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
				return
			else
				fun5()
			end
		end
		
		local fun3 = function () -- 判断队伍
			local teamId = g_i3k_game_context:GetTeamId()
			if teamId ~= 0 then
				local fun = (function(ok)
					if not ok then
						return
					else
						fun4()
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(68),fun)
				return
			else
				fun4()
			end 
		end
		
		local fun2 = function () -- 判断独立副本
			if g_i3k_game_context:isSpecialFacionDungeon(self._id)  then
				local fun = (function(ok)
					if not ok then
						return
					else
						fun3()
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17106),fun)
				return
			else
				fun3()
			end 
		end
		
		local fun1 = function () --多人坐骑
			g_i3k_game_context:CheckMulHorse(fun2)
		end
		
		fun1()
	end
end

function wnd_faction_dungeon_layer:enterDungeon(mapId)
	if i3k_check_resources_downloaded(mapId) then
	local data = i3k_sbean.sectmap_start_req.new()
	data.mapId = mapId
	i3k_game_send_str_cmd(data,	"sectmap_start_res")
	end
end

function wnd_faction_dungeon_layer:onAddVitBtnClick(sender)
	g_i3k_logic:OpenUseVitUI()
end
function wnd_faction_dungeon_layer:onAdjustPet(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionSuicongPlay)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionSuicongPlay)
	end
end

--[[function wnd_faction_dungeon_layer:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonLayer)
	end
end--]]

function wnd_faction_dungeon_layer:setBattleState()
	
	show_count = show_count + 1
	if show_count == 4 then
		show_count = 1
	end
	if show_count == 1 then
		self.playingState:setText("战斗中.")
	elseif show_count == 2 then
		self.playingState:setText("战斗中..")
	elseif show_count == 3 then
		self.playingState:setText("战斗中...")
	end
		
	
end

function wnd_faction_dungeon_layer:refresh(mapId)
	self._id = mapId
	self:updateBaseData()
end 

function wnd_faction_dungeon_layer:onHide()
	if self._timer then
		self._timer:CancelTimer()
	end
end 

function wnd_create(layout, ...)
	local wnd = wnd_faction_dungeon_layer.new()
	wnd:create(layout, ...)
	return wnd
end

local TIMER = require("i3k_timer");
i3k_game_timer_dungeon_layer = i3k_class("i3k_game_timer_dungeon_layer", TIMER.i3k_timer)

function i3k_game_timer_dungeon_layer:Do(args)
	
g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonLayer,"setBattleState")
end

function i3k_game_timer_dungeon_layer:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_dungeon_layer.new(1000))
	end
end

function i3k_game_timer_dungeon_layer:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end
