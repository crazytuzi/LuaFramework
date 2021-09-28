-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tournament = i3k_class("wnd_tournament", ui.wnd_base)

function wnd_tournament:ctor()
	
end

function wnd_tournament:configure()
	--g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "会武场逻辑制作中"))
	self._layout.vars.shop:onClick(self, self.onShop)
end

function wnd_tournament:onShow()
	local widget = self._layout.vars
	local hero = i3k_game_get_player_hero()
	if hero then
		widget.nameLabel:setText(hero._name)
		widget.levelLabel:setText(hero._lvl)
		widget.powerLabel:setText(hero:Appraise())
		widget.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
		local roleInfo = g_i3k_game_context:GetRoleInfo()
		local headIcon = roleInfo.curChar._headIcon
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
	end
end
--[[
function wnd_tournament:setRoleData()
	
end--]]

function wnd_tournament:refresh(info)
	self._layout.vars.rankBtn:onClick(self, self.onRank, info)
	self._layout.vars.toHelp:onClick(self, function (sender)
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15170))
	end)
	
	
	local weekTextTable = {"一", "二", "三", "四", "五", "六", "日"}
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	
	local scroll = self._layout.vars.scroll
	for i,v in ipairs(i3k_db_tournament) do
		local node = require("ui/widgets/4v4jjct")()
		node.vars.nameImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconId))
		node.vars.levelLabel:setText(v.needLvl)
		if info.logs[i] then
			node.vars.timesLabel:setText(info.logs[i].enterTimes)
		else
			node.vars.timesLabel:setText("0")
		end
		--node.vars.typeLabel:setText(v.serverType==1 and "本服" or "跨服")
		
		--设置时间以及开放日
		local isOpen = false
		local isInTime = false
		for _,t in ipairs(v.openDay) do
			if t==week then
				isOpen = true
				break
			end
		end
		local callback = function ()
			node.vars.aloneBtn:disableWithChildren()
			node.vars.teamBtn:disableWithChildren()
		end
		if isOpen then
			for k=1,2 do
				if not v.startTime[k] then
					node.vars["timeLabel"..k]:hide()
					break
				end
				local openTime = string.sub(v.startTime[k], 1, 5)
				local hour = tonumber(string.sub(openTime, 1, #openTime-3))
				local len = #openTime
				local min = tonumber(string.sub(openTime, #openTime-1, #openTime))
				local lifeMin = v.lifeTime/60;
				local lifeHour = lifeMin/60;
				local endMin = lifeMin%60;
				local endHour = hour + lifeHour;
				if endMin + min >= 60 then
					endHour = endHour + 1;
					endMin = endMin + min - 60;
				end
				local closeTime = string.format("%02d:%02d", endHour, endMin)
				if endHour >= 24 then
					endHour = endHour - 24;
					closeTime = string.format("次日%02d:%02d", endHour, endMin)
				end
				local time = openTime.."~"..closeTime
				node.vars["timeLabel"..k]:setText(time)
				--判断是否在开启时段
				local open = string.split(v.startTime[k], ":")
				local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
				local closeTimeStamp = openTimeStamp + v.lifeTime;
				if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
					isInTime = true
					node.vars["timeLabel"..k]:setTextColor(g_i3k_get_green_color())
				else
					node.vars["timeLabel"..k]:setTextColor(g_i3k_get_red_color())
				end
			end
		end
		if isOpen and isInTime then
			node.vars.aloneBtn:onClick(self, self.aloneJoin, {arenaType = i, needLvl = v.needLvl})
			node.vars.teamBtn:onClick(self, self.teamJoin, {arenaType = i, needLvl = v.needLvl})
		else
			if not isOpen then
				local text = string.format("每周")
				for k,t in ipairs(v.openDay) do
					text = text..weekTextTable[t]
					if k~=#v.openDay then
						text = text.."、"
					else
						text = text.."开启"
					end
				end
				node.vars.timeLabel1:hide()
				node.vars.timeLabel2:show()
				node.vars.timeLabel2:setText(text)
				node.vars.timeLabel2:setTextColor(g_i3k_get_red_color())
			end
			callback()
		end
		scroll:addItem(node)
		
		--[[--测试通用遮罩
		local pos = node.vars.teamBtn:getParent():convertToWorldSpace(node.vars.teamBtn:getPosition())
		g_i3k_ui_mgr:ShowGuideUI(pos, 50, function ()
			self:teamJoin(node.vars.teamBtn, {arenaType = i, needLvl = v.needLvl})
		end)--]]
	end
end

function wnd_tournament:aloneJoin(sender, value)
	local room = g_i3k_game_context:IsInRoom()
	if room then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(339, "房间"))
		return
	end
	
	local teamId = g_i3k_game_context:GetTeamId()
	if teamId~=0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(339, "队伍"))
		return
	end
	
	local hero = i3k_game_get_player_hero()
	if hero._lvl<value.needLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341, value.needLvl))
		return
	end
	local func = function ()
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_TOURNAMENT_MATCH, value.arenaType)
		i3k_sbean.mate_alone(value.arenaType)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_tournament:teamJoin(sender, value)
	--判断是否存在副本房间
	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type==gRoom_Force_War then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(343, "势力战"))
			return
		elseif room.type==gRoom_Dungeon then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(343, "副本"))
			return
		elseif room.type==gRoom_Tournament then
			local desc = string.format(i3k_get_string(379))
			local callback = function (isOk)
				if isOk then
					g_i3k_ui_mgr:OpenUI(eUIID_TournamentRoom)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "aboutMyRoom", g_i3k_game_context:getTournameRoomLeader(), g_i3k_game_context:getTournameMemberProfiles())
				else
					
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
			return
		end
	end
	--判断是否处于无队状态
	local teamId = g_i3k_game_context:GetTeamId()
	if teamId==0 then--无队伍情况下
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(340))
		return
	end
	--判断是不是队长
	local leaderId = g_i3k_game_context:GetTeamLeader()
	local roleId = g_i3k_game_context:GetRoleId()
	if roleId~=leaderId then--不是队长不能报名
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(342))
		return
	end
	--判断自己等级是否符合
	local hero = i3k_game_get_player_hero()--判断等级
	if hero and hero._lvl<value.needLvl then
		g_i3k_ui_mgr:PopupTipMessage(341, value.needLvl)
	end
	--判断队伍人数是否满员
	local count = g_i3k_game_context:GetTeamMemberCount()
	local needCount = i3k_db_tournament_base.memberCount
	if count<needCount-1 then--队伍人数太少
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(340))
		return
	end
	--判断是否都在线
	if not g_i3k_game_context:IsAllTeamMemberIsConected() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(346, "离线状态"))
	end
	i3k_sbean.create_arena_room()
end





function wnd_tournament:onShop(sender)
	i3k_sbean.sync_team_arena_store()
end

function wnd_tournament:onRank(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_TournamentRecord)
	g_i3k_ui_mgr:RefreshUI(eUIID_TournamentRecord, info)
end

function wnd_create(layout, ...)
	local wnd = wnd_tournament.new()
	wnd:create(layout, ...)
	return wnd;
end
