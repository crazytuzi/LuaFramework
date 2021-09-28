-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tournament_result = i3k_class("wnd_tournament_result", ui.wnd_base)

function wnd_tournament_result:ctor()
	
end

function wnd_tournament_result:configure()
	local widgets = self._layout.vars
	self._widgets = {}
	self._widgets.winTeam = {}
	self._widgets.loseTeam = {}
	for i=1, 8 do
		local memberWidget = {}
		memberWidget.root = widgets["root"..i]
		memberWidget.nameLabel = widgets["nameLabel"..i]
		memberWidget.levelLabel = widgets["levelLabel"..i]
		memberWidget.powerLabel = widgets["powerLabel"..i]
		memberWidget.killLabel = widgets["killLabel"..i]
		memberWidget.deadLabel = widgets["deadLabel"..i]
		memberWidget.honorLabel = widgets["honorLabel"..i]
		memberWidget.moneyLabel = widgets["moneyLabel"..i]
		memberWidget.assistLabel = widgets["assistLabel"..i]
		memberWidget.iconType = widgets["iconType"..i]
		memberWidget.icon = widgets["icon"..i]
		memberWidget.scoreLabel = widgets["scoreLabel"..i]
		memberWidget.root:hide()
		if i<=4 then
			memberWidget.bg = widgets["bg"..i]
			table.insert(self._widgets.winTeam, memberWidget)
		else
			table.insert(self._widgets.loseTeam, memberWidget)
		end
	end
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		local hero = i3k_game_get_player_hero()
		if hero then
			hero._AutoFight = false
		end
		i3k_sbean.mapcopy_leave()
	end)
	self._timeTick = 0
end

function wnd_tournament_result:onShow()
	
end

function wnd_tournament_result:setData(index, teams)
	for i,v in ipairs(teams[index]) do
		local node = self._widgets.winTeam[i]
		node.nameLabel:setText(v.name)
		node.levelLabel:setText(v.level)
		node.powerLabel:setText(v.fightPower)
		node.killLabel:setText(v.kills)
		node.deadLabel:setText(v.dead)
		node.honorLabel:setText("+"..v.addHonor)
		node.moneyLabel:setText("+"..v.addHonor)
		node.assistLabel:setText(v.assist)
		node.scoreLabel:setText(string.format("积分：%s", v.addELO))
		node.bg:hide()
		if v.rid==g_i3k_game_context:GetRoleId() then
			local yellowColor = "FFFFF956"
			node.levelLabel:setTextColor(yellowColor)
			node.powerLabel:setTextColor(yellowColor)
			node.killLabel:setTextColor(yellowColor)
			node.honorLabel:setTextColor(yellowColor)
			node.moneyLabel:setTextColor(yellowColor)
			node.assistLabel:setTextColor(yellowColor)
			node.bg:show()
		end
		node.root:show()
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.headIcon, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		node.iconType:setImage(g_i3k_get_head_bg_path(v.BWType))
	end
	index = index==1 and 2 or 1
	for i,v in ipairs(teams[index]) do
		local node = self._widgets.loseTeam[i]
		node.nameLabel:setText(v.name)
		node.levelLabel:setText(v.level)
		node.powerLabel:setText(v.fightPower)
		node.killLabel:setText(v.kills)
		node.deadLabel:setText(v.dead)
		node.honorLabel:setText("+"..v.addHonor)
		node.moneyLabel:setText("+"..v.addHonor)
		node.assistLabel:setText(v.assist)
		node.scoreLabel:setText(string.format("积分：%s", v.addELO))
		node.root:show()
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.headIcon, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		node.iconType:setImage(g_i3k_get_head_bg_path(v.BWType))
	end
	--楚汉
	local widgets = self._layout.vars
	local world = i3k_game_get_world()
	local tType = g_i3k_db.i3k_db_get_tournament_type(world._cfg.id)
	if tType == g_TOURNAMENT_CHUHAN then
		--widgets.forceType1:setImage(g_i3k_db.i3k_db_get_icon_path())
		--widgets.forceType1:setImage(g_i3k_db.i3k_db_get_icon_path())
	end
end

function wnd_tournament_result:refresh(win, teams)
	local index = 2
	for i,v in ipairs(teams[1]) do
		if v.rid==g_i3k_game_context:GetRoleId() then
			index = 1
			break
		end
	end
	--index是自己所在队伍，跟输赢无关	
	if win==1 then
		self._layout.anis.c_sl.play()
	elseif win==0 then
		self._layout.anis.c_shibai.play()
	else
		self._layout.anis.c_pj.play()
	end
	self:setData(index, teams)
end

--[[function wnd_tournament_result:onClose(sender)
	--g_i3k_ui_mgr:CloseUI(eUIID_TournamentResult)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero._AutoFight = false
	end
	i3k_sbean.mapcopy_leave()
end--]]

function wnd_tournament_result:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	self._layout.vars.timeLabel:setText(math.ceil(i3k_db_tournament_base.baseData.autoCloseTime - self._timeTick))
end

function wnd_create(layout, ...)
	local wnd = wnd_tournament_result.new()
	wnd:create(layout, ...)
	return wnd;
end
