-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaSetLineup = i3k_class("wnd_arenaSetLineup", ui.wnd_base)

--local f_myPower
 
local star_icon = {405,409,410,411,412,413}
function wnd_arenaSetLineup:ctor()
	self._isSelect = {}
	self._playPets = {}
	self._hadConfirm = true
	self._hadConfirmTemp = false
	--f_myPower = g_i3k_game_context:GetMyPower()
end

function wnd_arenaSetLineup:configure(...)
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self, self.onClose)
	
	local tips = self._layout.vars.tips_desc
	if tips then tips:hide() end
	
	local myPets = self._layout.vars.myPets
	local factionPets = self._layout.vars.factionPets
	if myPets then myPets:hide() end
	if factionPets then factionPets:hide() end
	
	local blood = self._layout.vars.blood
	if blood then blood:hide() end
	
	local nRoot = self._layout.vars.nRoot1
	local nRoot2 = self._layout.vars.nRoot2
	local nRoot3 = self._layout.vars.nRoot3
	if nRoot and nRoot2 and nRoot3 then
		nRoot:hide()
		nRoot2:hide()
		nRoot3:hide()
	end
	
	local petBlood1 = self._layout.vars.petBlood1
	local petBlood2 = self._layout.vars.petBlood2
	local petBlood3 = self._layout.vars.petBlood3
	if petBlood1 and petBlood2 and petBlood3 then
		petBlood1:hide()
		petBlood2:hide()
		petBlood3:hide()
	end
	
	local noPetImg1 = self._layout.vars.lRoot1
	local noPetImg2 = self._layout.vars.lRoot2
	local noPetImg3 = self._layout.vars.lRoot3
	if noPetImg1 and noPetImg2 and noPetImg3 then
		self._noPetImgTable = {noPetImg1, noPetImg2, noPetImg3}
		noPetImg1:show()
		noPetImg2:show()
		noPetImg3:show()
	end
	
	local pet1 = self._layout.vars.hRoot1
	local pet2 = self._layout.vars.hRoot2
	local pet3 = self._layout.vars.hRoot3
	if pet1 and pet2 and pet3 then
		self._petTable = {pet1, pet2, pet3}
		pet1:hide()
		pet2:hide()
		pet3:hide()
	end
	
	local petIcon1 = self._layout.vars.pet_icon1
	local petIcon2 = self._layout.vars.pet_icon2
	local petIcon3 = self._layout.vars.pet_icon3
	if petIcon1 and petIcon2 and petIcon3 then
		self._petIconTable = {petIcon1, petIcon2, petIcon3}
	end
	
	local lvl1 = self._layout.vars.level1
	local lvl2 = self._layout.vars.level2
	local lvl3 = self._layout.vars.level3
	if lvl1 and lvl2 and lvl3 then
		self._petLvlTable = {lvl1, lvl2, lvl3}
	end
	
	self._starIcon = {self._layout.vars.star_icon1, self._layout.vars.star_icon2, self._layout.vars.star_icon3}
	for i,v in pairs(self._starIcon) do
		--ToDo   需要后边根据实际星级显示，缺资源
		v:setImage(i3k_db_icons[405].path)
	end
	
	self._layout.vars.saveBtn:onClick(self, self.onConfirm)
	
	self._outBtn = {self._layout.vars.out_btn1, self._layout.vars.out_btn2, self._layout.vars.out_btn3}
	self._defendRoot = {defendRoot = widgets.defendRoot, defendBtn = widgets.defendBtn, defendImg = widgets.defendImg}
	self._defendRoot.defendBtn:onClick(self, self.onClickDefendBtn)
end

function wnd_arenaSetLineup:onShow()
	
end

function wnd_arenaSetLineup:refresh(pets, hideDefence)
	local hero = i3k_game_get_logic():GetPlayer():GetHero()
	if hero then
		local icon = self._layout.vars.heroIcon
		
		local roleInfo = g_i3k_game_context:GetRoleInfo()
		local headIcon = roleInfo.curChar._headIcon
		
		self._layout.vars.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
		
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		
		local level = self._layout.vars.my_level_label
		if level then level:setText(hero._lvl) end
	end
	
	self:setData(pets)
	self._defendRoot.defendRoot:setVisible(g_i3k_game_context:GetVipLevel() >= i3k_db_arena.arenaCfg.showHideFunc)
	self:updateDefendImg(hideDefence)
end

function wnd_arenaSetLineup:setData(pets)
	local allPets, playPets = g_i3k_game_context:GetYongbingData()
	self._oldLineup = {}
	for i,v in pairs(pets) do
		table.insert(self._oldLineup, v)
	end
	local petPower = 0
	for i,v in pairs(pets) do
		local mercenaryPower = g_i3k_game_context:getBattlePower(v)
		petPower = petPower + mercenaryPower
	end
	local hero = i3k_game_get_player_hero()
	self._layout.vars.power_label:setText(hero:Appraise() + petPower)
	for i,v in pairs(pets) do
		self._noPetImgTable[i]:hide()
		self._petTable[i]:show()
		local mercenary = i3k_db_mercenaries[tonumber(v)]
		local iconId = g_i3k_db.i3k_db_get_head_icon_id(v)
		if g_i3k_game_context:getPetWakenUse(v) then
			iconId = i3k_db_mercenariea_waken_property[v].headIcon;
		end
		self._petIconTable[i]:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		self._layout.vars["pet_iconBg"..i]:setImage(g_i3k_get_icon_frame_path_by_rank(mercenary.rank))
		for j,k in pairs(allPets) do
			if tonumber(k.id)==tonumber(v) then
				self._petLvlTable[i]:setText(k.level)
				local star =  k.starlvl
				self._starIcon[i]:setImage(i3k_db_icons[star_icon[star+1]].path)
			end
		end
		self._outBtn[i]:setTag(v+10000)
		self._outBtn[i]:onClick(self, self.playCancel)
	end
	
	local count = 0
	if playPets[2] then
		count = #playPets[2]
	end
	if self._cancelBtn then
		for i=1, count do
			self._cancelBtn[i]:setTouchEnabled(true)
		end
	end
	local pet_scroll = self._layout.vars.pet_scroll 
	
	if pet_scroll then
		local width = pet_scroll:getContainerSize().width
		local height = pet_scroll:getContainerSize().height
		
		
		--local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local allPets, playPets = g_i3k_game_context:GetYongbingData(true)
		local petsCount = 0
		for i,v in pairs(allPets) do
			petsCount = petsCount + 1
		end
		
		local children = pet_scroll:addChildWithCount("ui/widgets/scczt", 5, petsCount)
		pet_scroll:setBounceEnabled(false)
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
			for _,t in pairs(pets) do
				if tonumber(t)==id then
					v.vars.isSelect:show()
				end
			end
		end
	end
end

function wnd_arenaSetLineup:updateDefendImg(hideDefence)
	self._defendRoot.defendImg:setVisible(hideDefence == 1)
end

function wnd_arenaSetLineup:onClickDefendBtn(sender)
	if g_i3k_game_context:GetVipLevel() < i3k_db_arena.arenaCfg.useHideFunc then
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15353, i3k_db_arena.arenaCfg.useHideFunc))
		return
	end
	local isHide = self._defendRoot.defendImg:isVisible() and 0 or 1
	i3k_sbean.arena_hidedefence(isHide)
end

function wnd_arenaSetLineup:onPetPlay(sender)
	local index = sender:getTag()-1000
	local isSelect = self._isSelect[index]
	local isShow = isSelect:isVisible()
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
	
	g_i3k_game_context:AddArenaDefensive(mercenary.id)
	
	self:reload()
end

function wnd_arenaSetLineup:reload()
	local nowLineup = g_i3k_game_context:GetArenaDefensive()
	
	local allPets, playPets = g_i3k_game_context:GetYongbingData()
	
	for i,v in pairs(self._isSelect) do
		v:hide()
	end
		
	local sortPets, playPets = g_i3k_game_context:GetYongbingData(true)
	
	for a,b in pairs(nowLineup) do
		for i,v in pairs(sortPets) do
			if v.id==b then
				self._isSelect[i]:show()
			end
		end
	end
	
	for i,v in pairs(self._petTable) do
		if nowLineup[i] then
			v:show()
			self._noPetImgTable[i]:hide()
		else
			self._noPetImgTable[i]:show()
			v:hide()
		end
	end
	
	local petPower = 0
	for i,v in pairs(nowLineup) do
		local mercenaryPower = g_i3k_game_context:getBattlePower(v)
		petPower = petPower + mercenaryPower
		local mercenary = i3k_db_mercenaries[v]
		local iconId = g_i3k_db.i3k_db_get_head_icon_id(v)
		if g_i3k_game_context:getPetWakenUse(v) then
			iconId = i3k_db_mercenariea_waken_property[v].headIcon;
		end
		self._petIconTable[i]:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		self._layout.vars["pet_iconBg"..i]:setImage(g_i3k_get_icon_frame_path_by_rank(mercenary.rank))
		for j,k in pairs(sortPets) do
			if k.id==v then
				self._petLvlTable[i]:setText(k.level)
			end
		end
		local starLvl =  allPets[v].starlvl
		self._starIcon[i]:setImage(i3k_db_icons[star_icon[starLvl+1]].path)
		--if i==#nowLineup then
			self._outBtn[i]:setTag(v+10000)
			self._outBtn[i]:onClick(self, self.playCancel)
		--end
	end
	local hero = i3k_game_get_player_hero()
	self._layout.vars.power_label:setText(hero:Appraise() + petPower)
	
	
	if #self._oldLineup~=#nowLineup then
		self._hadConfirm = false
	else
		local isSame = true
		for i,v in pairs(self._oldLineup) do
			if tonumber(v)==tonumber(nowLineup[i]) then
				
			else
				isSame = false
			end
		end
		self._hadConfirm = isSame
	end
end


function wnd_arenaSetLineup:playCancel(sender)
	local tag = sender:getTag()-10000
	local allPets, playPets = g_i3k_game_context:GetYongbingData()
	local scroll = self._layout.vars.pet_scroll
	local children = scroll:getAllChildren()
	local havePets, playPets = g_i3k_game_context:GetYongbingData(true)
	
	for i,v in pairs(havePets) do
		if v.id==tag then
			self:onPetPlay(children[i].vars.play_btn)
		end
	end
end

function wnd_arenaSetLineup:onClose(sender)
	if self._hadConfirm then
		g_i3k_ui_mgr:CloseUI(eUIID_ArenaSetLineup)
	else
		if self._hadConfirmTemp then
			g_i3k_game_context:SetArenaDefensive(self._oldLineup)
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
			g_i3k_ui_mgr:CloseUI(eUIID_ArenaSetLineup)
		else
			g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "防守阵容未保存，再次点击退出"))
			self._hadConfirmTemp = true
		end
	end
	local time = 0
	function update(dTime)
		time = time+dTime
		if time>=3 then
			if self._sc then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
			end
			self._hadConfirmTemp = false
		else
			
		end
	end
	
	self._sc=cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
end

function wnd_arenaSetLineup:onConfirm(sender)
	local setLineup = i3k_sbean.arena_setpets_req.new()
	local nowLineup = g_i3k_game_context:GetArenaDefensive()
	setLineup.pets = nowLineup
	local petPower = 0
	for i,v in pairs(nowLineup) do
		local mercenaryPower = g_i3k_game_context:getBattlePower(v)
		petPower = petPower + mercenaryPower
	end
	local hero = i3k_game_get_player_hero()
	setLineup.power = hero:Appraise() + petPower
	
	i3k_game_send_str_cmd(setLineup, i3k_sbean.arena_setpets_res.getName())
	self._hadConfirm = true
	self._hadConfirmTemp = true
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaSetLineup.new();
		wnd:create(layout, ...);

	return wnd;
end
