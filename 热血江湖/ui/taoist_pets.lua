-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_taoist_pets = i3k_class("wnd_taoist_pets", ui.wnd_base)

local star_icon = {405,409,410,411,412,413}

function wnd_taoist_pets:ctor()
	self._isSave = true
end

function wnd_taoist_pets:configure()
	local widget = self._layout.vars
	self._isSelect = {}
	self._maxCount = 0
	self._playPets = {}
	local root = {}
	for i=1, 9 do
		local node = {}
		node.petRoot = widget["petRoot"..i]
		node.noPetRoot = widget["noPetRoot"..i]
		node.noOpenRoot = widget["nRoot"..i]
		node.btn = widget["petBtn"..i]
		node.icon = widget["petIcon"..i]
		node.iconBg = widget["petIconBg"..i]
		node.starImg = widget["petStar"..i]
		node.levelLabel = widget["petLvl"..i]
		node.desc = widget["desc"..i]
		node.btn = widget["petBtn"..i]
		root[i] = node
	end
	
	self._pets = root
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	widget.saveBtn:onClick(self, self.onSaveData)
end

function wnd_taoist_pets:onShow()
	
end

function wnd_taoist_pets:refresh(info)
	local pets = {}
	for i,v in pairs(info.pets) do
		table.insert(pets, i)
	end
	local cfg = i3k_db_taoist_level_cfg[info.lvl]
	self._maxCount = cfg.maxPetsCount
	g_i3k_game_context:setTaoistPets(pets)
	self:setPetsData(pets)
end

function wnd_taoist_pets:setPetsData(pets)
	local allPets, playPets = g_i3k_game_context:GetYongbingData(true)
	for i,v in ipairs(self._pets) do
		local pet = nil
		local petId = pets[i]
		for i,v in ipairs(allPets) do
			if v.id==petId then
				pet = allPets[i]
				break
			end
		end
		if i<=#pets then
			local iconId = g_i3k_db.i3k_db_get_head_icon_id(petId)
			if g_i3k_game_context:getPetWakenUse(petId) then
				iconId = i3k_db_mercenariea_waken_property[petId].headIcon;
			end
			v.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			v.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[petId].rank))
			v.levelLabel:setText(pet.level)
			v.starImg:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[pet.starlvl+1]))
			v.btn:onClick(self, self.onPetPlay, petId)
			v.petRoot:show()
			v.noPetRoot:hide()
			v.noOpenRoot:hide()
		else
			if i<=self._maxCount then
				v.petRoot:hide()
				v.noPetRoot:show()
				v.noOpenRoot:hide()
			else
				v.petRoot:hide()
				v.noPetRoot:hide()
				v.noOpenRoot:show()
				for j,t in ipairs(i3k_db_taoist_level_cfg) do
					if t.maxPetsCount==i then
						v.desc:setText(string.format("%d级开放", j))
						break
					end
				end
			end
		end
	end
	local scroll = self._layout.vars.scroll
	scroll:setBounceEnabled(false)
	scroll:removeAllChildren(true)
	local children = scroll:addChildWithCount("ui/widgets/scczt", 5, #allPets)
	for i,v in ipairs(children) do
		local id = allPets[i].id
		local lvl = allPets[i].level
		local star =  allPets[i].starlvl
		local iconid = g_i3k_db.i3k_db_get_head_icon_id(id)
		if g_i3k_game_context:getPetWakenUse(id) then
			iconid = i3k_db_mercenariea_waken_property[id].headIcon;
		end
		v.vars.pet_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconid, true))
		v.vars.pet_iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		v.vars.level_label:setText(lvl)
		v.vars.start_icon:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[star+1]))
		local mercenaryPower = g_i3k_game_context:getBattlePower(id)
		v.vars.pet_power:setText(mercenaryPower)
		v.vars.play_btn:setTag(i)
		table.insert(self._isSelect, v.vars.isSelect)
		v.vars.isSelect:hide()
		v.vars.play_btn:onClick(self,self.onPetPlay, id)
		for _,t in pairs(pets) do
			if tonumber(t)==id then
				v.vars.isSelect:show()
			end
		end
	end
end

function wnd_taoist_pets:onSaveData(sender)
	local pets = g_i3k_game_context:getTaoistPets()
	local setPets = {}
	for i,v in ipairs(pets) do
		setPets[v] = true
	end
	local maxCount = self._maxCount
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "refreshFightPets", pets, maxCount)
	end
	i3k_sbean.set_taoist_pets(setPets, callback)
end

function wnd_taoist_pets:onPetPlay(sender, id)
	g_i3k_game_context:addTaoistPets(id, self._maxCount)
	self:setPetsData(g_i3k_game_context:getTaoistPets())
end

--[[function wnd_taoist_pets:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TaoistPets)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_taoist_pets.new()
	wnd:create(layout, ...)
	return wnd;
end
