-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_superArenaWeaponSet = i3k_class("wnd_superArenaWeaponSet", ui.wnd_base)

local WIDGET_SBXZT = "ui/widgets/sbxzt"
local RowitemCount = 5 -- 每行五个神兵

function wnd_superArenaWeaponSet:ctor()
	self._isChange = false
	self._weaponsTable = {}
end

function wnd_superArenaWeaponSet:configure()
	local widgets = self._layout.vars
	self.scroll = self._layout.vars.scroll
	self.headBg = self._layout.vars.headBg
	for i = 1, 3 do
		local weaponWidget = {}
		weaponWidget.root = widgets["petRoot"..i]
		weaponWidget.btn = widgets["petBtn"..i]
		weaponWidget.icon = widgets["petIcon"..i]
		-- pet.petLvl = widgets["petLvl"..i]
		table.insert(self._weaponsTable, weaponWidget)
	end
	self._layout.vars.closeBtn:onClick(self, self.saveData)
	self._layout.vars.saveBtn:onClick(self, self.saveData)
end

function wnd_superArenaWeaponSet:refresh()
	self:loadHeadIconInfo()
	self:loadData()
end

function wnd_superArenaWeaponSet:loadHeadIconInfo()
	self.headBg:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype()))
	self._layout.vars.heroLvl:setText(g_i3k_game_context:GetLevel())
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(g_i3k_game_context:GetRoleHeadIconId(), g_i3k_db.eHeadShapeCircie)
	if hicon and hicon > 0 then
		self._layout.vars.heroIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
end

function wnd_superArenaWeaponSet:loadData()
	for i, e in ipairs(self._weaponsTable) do --默认都隐藏
		e.icon:hide()
		e.btn:setTouchEnabled(false)
	end
	
	local tournamentWeapons = g_i3k_game_context:GetTournamentWeapons()
	for i, v in ipairs(tournamentWeapons) do
		local node = self._weaponsTable[i]
		if node then
			node.icon:show()
			node.btn:setTouchEnabled(true)
			if g_i3k_game_context:IsShenBingAwake(v) then
				node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[v].awakeWeaponIcon))
			else
				node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[v].icon))
			end
			node.btn:onClick(self, self.onWeaponPlay, v)
		end
	end
	
	local allShenbing = self:sortAllShenbing(g_i3k_game_context:GetShenbingData())
	local children = self.scroll:addChildWithCount(WIDGET_SBXZT, RowitemCount, #allShenbing)
	for i, v in ipairs(children) do
		local shenbing = allShenbing[i]
		if g_i3k_game_context:IsShenBingAwake(shenbing.id) then
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[shenbing.id].awakeWeaponIcon))
			v.vars.pet_iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[shenbing.id].awakeBackground))
		else
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[shenbing.id].icon))
		end
		v.vars.level_label:setText(shenbing.qlvl)
		v.vars.isSelect:hide()
		for _, t in ipairs(tournamentWeapons) do
			if t == shenbing.id then
				v.vars.isSelect:show()
			end
		end
		if #tournamentWeapons >= i3k_db_tournament_base.weaponCanSelectCount and not v.vars.isSelect:isVisible() then
			v.vars.play_btn:setTouchEnabled(false)
		else
			v.vars.play_btn:onClick(self, self.onWeaponPlay, shenbing.id)
		end
	end
end

--排序 神兵星级 > 等级 > ID
function wnd_superArenaWeaponSet:sortAllShenbing(allShenbing)
	local tmp = {}
	for _, v in pairs(allShenbing) do
		local order = v.slvl * 1000 + v.qlvl * 100 + 100 - v.id
		table.insert(tmp, {order = order, id = v.id, qlvl = v.qlvl})
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

function wnd_superArenaWeaponSet:onWeaponPlay(sender, id)
	self._isChange = true
	g_i3k_game_context:AddTournamentWeapons(id)
	self:loadData()
end

function wnd_superArenaWeaponSet:saveData(sender)
	local weapons = g_i3k_game_context:GetTournamentWeapons()
	if self._isChange and #weapons > 0 then
		i3k_sbean.superarena_weaponseq(weapons)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_SuperArenaWeaponSet)
	end
end

function wnd_create(layout)
	local wnd = wnd_superArenaWeaponSet.new()
	wnd:create(layout)
	return wnd
end
