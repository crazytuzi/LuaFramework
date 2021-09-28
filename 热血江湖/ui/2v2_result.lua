-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_2v2_result = i3k_class("wnd_2v2_result", ui.wnd_base)

function wnd_2v2_result:ctor()
	
end

function wnd_2v2_result:configure()
	self._layout.vars.closeBtn:onClick(self, self.onQuit)
	self._widgets = { winNode = {}, loseNode = {}}
	for i=1, 4 do
		local node = {}
		node.nameLabel = self._layout.vars["nameLabel"..i]
		node.icon = self._layout.vars["icon"..i]
		node.iconType = self._layout.vars["iconType"..i]
		node.powerLabel = self._layout.vars["powerLabel"..i]
		node.killLabel = self._layout.vars["killLabel"..i]
		node.deadLabel = self._layout.vars["deadLabel"..i]
		node.honorLabel = self._layout.vars["honorLabel"..i]
		node.coinLabel = self._layout.vars["coinLabel"..i]
		node.levelLabel = self._layout.vars["levelLabel"..i]
		node.scoreLabel = self._layout.vars["scoreLabel"..i]
		if i<=2 then
			table.insert(self._widgets.winNode, node)
		else
			table.insert(self._widgets.loseNode, node)
		end
	end
	self._timeTick = 0
end

function wnd_2v2_result:onShow()
	
end

function wnd_2v2_result:refresh(win, teams, oldTeams)
	if win==0 then
		self._layout.anis.c_sb.play()
	elseif win==1 then
		self._layout.anis.c_sl.play()
	elseif win==2 then
		self._layout.anis.c_pj.play()
	end
	local widget = self._layout.vars
	local index = 2
	for i,v in ipairs(teams[1]) do
		if v.rid==g_i3k_game_context:GetRoleId() then
			index = 1
			break
		end
	end
	self:setData(index, teams)
	
	local winTimes = 0
	local drawTimes = 0
	local loseTimes = 0
	local results = oldTeams[index].results
	for i,v in ipairs(results) do
		if v==0 then
			loseTimes = loseTimes + 1
		elseif v==1 then
			winTimes = winTimes + 1
		elseif v==2 then
			drawTimes = drawTimes + 1
		end
	end
	self._layout.vars.winLabel:setText(winTimes)
	self._layout.vars.loseLabel:setText(loseTimes)
	self._layout.vars.drawLabel:setText(drawTimes)
end

function wnd_2v2_result:setData(index, teams)
	for i,v in ipairs(teams[index]) do
		local node = self._widgets.winNode[i]
		node.nameLabel:setText(v.name)
		node.levelLabel:setText(v.level)
		node.powerLabel:setText(v.fightPower)
		node.killLabel:setText(v.kills)
		node.deadLabel:setText(v.dead)
		node.honorLabel:setText("+"..v.addHonor)
		node.coinLabel:setText("+"..v.addHonor)
		node.scoreLabel:setText(string.format("积分：%s", v.addELO))
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.headIcon, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		node.iconType:setImage(g_i3k_get_head_bg_path(v.BWType))
		--[[if v.rid==g_i3k_game_context:GetRoleId() then
			local blueWord = "FF30B4FF"
			node.nameLabel:setTextColor(blueWord)
			node.levelLabel:setTextColor(blueWord)
			node.powerLabel:setTextColor(blueWord)
			node.killLabel:setTextColor(blueWord)
			node.deadLabel:setTextColor(blueWord)
			node.honorLabel:setTextColor(blueWord)
			node.coinLabel:setTextColor(blueWord)
		end--]]
	end
	index = index==1 and 2 or 1
	for i,v in ipairs(teams[index]) do
		local node = self._widgets.loseNode[i]
		node.nameLabel:setText(v.name)
		node.levelLabel:setText(v.level)
		node.powerLabel:setText(v.fightPower)
		node.killLabel:setText(v.kills)
		node.deadLabel:setText(v.dead)
		node.honorLabel:setText("+"..v.addHonor)
		node.coinLabel:setText("+"..v.addHonor)
		node.scoreLabel:setText(string.format("积分：%s", v.addELO))
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.headIcon, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		node.iconType:setImage(g_i3k_get_head_bg_path(v.BWType))
	end
end

function wnd_2v2_result:onQuit(sender)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero._AutoFight = false
	end
	i3k_sbean.mapcopy_leave()
end

function wnd_2v2_result:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	local time = i3k_db_tournament_base.baseData.autoCloseTime - self._timeTick
	time = time > 0 and time or 0 
	self._layout.vars.timeLabel:setText(string.format("%s秒后退出", math.ceil(time)))
end

function wnd_create(layout, ...)
	local wnd = wnd_2v2_result.new()
	wnd:create(layout, ...)
	return wnd;
end
