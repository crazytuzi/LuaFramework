module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petDungeonChosepet = i3k_class("wnd_petDungeonChosepet", ui.wnd_base)

local PETITEM = "ui/widgets/chongwushilianczt"
local star_icon = {405,409,410,411,412,413}

function wnd_petDungeonChosepet:ctor()
	self._isSelect = nil
	self._curInfo = nil
	self._curMapId = 0
end

function wnd_petDungeonChosepet:configure()
	local weight = self._layout.vars
	weight.closeBtn:onClick(self, self.onCloseUI)
	weight.join:onClick(self, self.onJoinBt)
end

function wnd_petDungeonChosepet:refresh(info)
	self._curMapId = info.index
	local weight = self._layout.vars
	local scoll = weight.scroll
	local count, pets = g_i3k_game_context:getPetDungeonSatisfyCount(true)
	local items = scoll:addChildWithCount(PETITEM, 5, count, true)
	
	for k, v in ipairs(items) do
		local node = v.vars
		local pet = pets[k]
		local mercenary = i3k_db_mercenaries[pet.id]
		local iconId = mercenary.icon
		
		if g_i3k_game_context:getPetWakenUse(pet.id) then
			iconId = i3k_db_mercenariea_waken_property[pet.id].headIcon;
		end
		
		node.pet_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		node.pet_iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(mercenary.rank))
		node.level_label:setText(pet.level)
		node.start_icon:setImage(i3k_db_icons[star_icon[pet.starlvl + 1]].path)
		node.isSelect:hide()
		node.team:setText(g_i3k_db.i3k_db_get_PetGroupName_By_PetID(pet.id))
		node.play_btn:onClick(self, self.onChoseBt, {info = pets[k], item = v})
	end
	
	self:onChoseBt()
end

function wnd_petDungeonChosepet:onChoseBt(sender, data)
	local weight = self._layout.vars
	
	if not data then
		weight.petRoot1:hide()
		weight.power:hide()
		weight.noPetRoot1:show()
		weight.join:disableWithChildren()
		return
	end
	
	local info = data.info
	local mercenary = i3k_db_mercenaries[info.id]
	local iconId = mercenary.icon
		
	if g_i3k_game_context:getPetWakenUse(info.id) then
		iconId = i3k_db_mercenariea_waken_property[info.id].headIcon;
	end
	
	weight.powerLabel:setText(g_i3k_game_context:getBattlePower(info.id))
	weight.petIconBg1:setImage(g_i3k_get_icon_frame_path_by_rank(mercenary.rank))
	weight.petIcon1:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
	weight.petStar1:setImage(i3k_db_icons[star_icon[info.starlvl + 1]].path)
	weight.petLvl1:setText(info.level)
	weight.noPetRoot1:hide()
	weight.petRoot1:show()
	weight.power:show()
	weight.join:enableWithChildren()
	
	if self._isSelect then
		self._isSelect.vars.isSelect:hide()
	end
	
	self._isSelect = data.item
	self._isSelect.vars.isSelect:show()
	self._curInfo = info	
end

function wnd_petDungeonChosepet:onJoinBt()
	if not self._curInfo then
		g_i3k_ui_mgr:PopupTipMessage("选择宠物！！")
		return
	end
	
	i3k_sbean.enterPetDungeonMap(self._curMapId, self._curInfo.id)
end

function wnd_create(layout)
	local wnd = wnd_petDungeonChosepet.new();
	wnd:create(layout);
	return wnd;
end
