-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_annunciate = i3k_class("wnd_annunciate", ui.wnd_base)

function wnd_annunciate:ctor()
	self._page = 1
	self._stlType = 0
	self._info = nil
	self._remainTimes = nil
	self._selectedIndex = 1
	self._freshDelaye = 0
	self._rankDelaye = 0
	self._lastStaleBtn = nil
end

function wnd_annunciate:configure()
	local vars = self._layout.vars
	vars.closeBtn:onClick(self, self.onCloseUI)
	vars.helpBtn:onClick(self, self.help)
	vars.xbBtn:onClick(self, self.selectPage, 1)
	vars.rankBtn:onClick(self, self.selectPage, 2)
	vars.xbBtn:stateToPressed()
end

function wnd_annunciate:refresh(infoList)
	self:lookActivityList(infoList)
end

function wnd_annunciate:selectPage(sender, args)
	if self._page == args then
		return
	end
	self._page = args
	sender:stateToPressed()

	local vars = self._layout.vars
	if args == 1 then
		i3k_sbean.emergency_sync_req_send(1)
		vars.rankBtn:stateToNormal()
	else
		vars.xbBtn:stateToNormal()
		if i3k_game_get_time() - self._rankDelaye > 2 then
			i3k_sbean.emergency_rank_req_send()
			self._rankDelaye = i3k_game_get_time()
		else
			vars.xbRoot:hide()
			vars.rankRoot:show()
		end
	end
	
end

function wnd_annunciate:getExplorStateText(roleNum, max)
	local id = (roleNum == 0 and 15197 ) or (roleNum >= 20 and 15198 or 15199)
	return i3k_get_string(id)
end

function wnd_annunciate:getOrderActList(infoList, nowTime)
	local openAct = {}
	local closeAct = {}
	local selfLvl = g_i3k_game_context:GetLevel()
	local actcfg = i3k_db_annunciate.activity

	local index = 0
	for i,v in ipairs(i3k_db_annunciate.time) do
		if nowTime >= v.startTime and nowTime <= v.endTime then
			for _,v1 in ipairs(v.actIdList) do
				if selfLvl >= actcfg[v1].floorLvl and selfLvl <= actcfg[v1].upperLvl then
					local info = infoList[v1]
					if info and info.isFinish == 1 then
						table.insert(closeAct,{actId = v1, endTime = -1, roleSize = 0})
					elseif info and info.openTime == v.startTime then
						table.insert(openAct,{actId = v1, endTime = v.endTime, roleSize = info.roleSize})
					else
						table.insert(openAct,{actId = v1, endTime = v.endTime, roleSize = 0})
					end
				end
			end
			index = i
			break
		end
	end
	if index == 0 or index == #i3k_db_annunciate.time then
		index = 1
	else
		index = index + 1
	end
	for i,v in ipairs(i3k_db_annunciate.time[index].actIdList) do
		if selfLvl >= actcfg[v].floorLvl and selfLvl <= actcfg[v].upperLvl then
			table.insert(closeAct,{actId = v, endTime = 0, roleSize = 0})
		end
	end
	
	table.sort(openAct, function(a,b)
		local ac = actcfg[a.actId]
		local bc = actcfg[b.actId]
		if ac.monsterlevel ~= bc.monsterlevel then
			return ac.monsterlevel < bc.monsterlevel
		end
		if a.endTime ~= b.endTime then
			return a.endTime > b.endTime
		end
		return false
	end)

	table.sort(closeAct, function(a,b)
		local ac = actcfg[a.actId]
		local bc = actcfg[b.actId]
		if a.endTime ~= b.endTime then
			return a.endTime > b.endTime
		end

		if ac.monsterlevel ~= bc.monsterlevel then
			return ac.monsterlevel < bc.monsterlevel
		end

		return false
	end)
	for i,v in ipairs(closeAct) do
		table.insert(openAct, v)
	end
	return openAct
end

function wnd_annunciate:GetTime(nowTime, endTime)
	if endTime == 0 then
		return "尚未开启"
	end
	if endTime == -1 then
		return "已结束"
	end
	local time = endTime - nowTime
	local hour =math.modf(time/(60*60))
	local minite = math.modf((time - hour*60*60)/60)
	local sec = math.modf((time - hour*60*60 - minite *60))
	if hour > 0 then
		return string.format("%d小时%d分%d秒",hour,minite,sec)
	else
		return string.format("%d分%d秒",minite,sec)
	end
end

function wnd_annunciate:GetSate(roleSize)
	if roleSize >= 20 then
		return "激烈"
	elseif roleSize > 0 then
		return "一般"
	else
		return "无情报"
	end
end

function wnd_annunciate:lookActivityList(infoList)
	local vars = self._layout.vars
	vars.xbRoot:show()
	vars.rankRoot:hide()
	
	local nowTime = math.mod(i3k_game_get_time(), 86400)
	local scroll = self._layout.vars.xbScroll
	local actcfg = i3k_db_annunciate.activity
	local list = self:getOrderActList(infoList, nowTime)
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)
	for i,v in ipairs(list) do
		local node = require("ui/widgets/jhgjt2")()
		local cfg = actcfg[v.actId]
		node.vars.headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.headIcon))
		node.vars.name:setText(cfg.monsterName)
		node.vars.level:setText(cfg.monsterlevel)
		node.vars.level:setTextColor(g_i3k_get_cond_color( cfg.monsterlevel - g_i3k_game_context:GetLevel() < 5))
		if v.endTime <= 0 then
			node.vars.goBtn:disableWithChildren()
		else
			node.vars.goBtn:onClick(self, self.gotoActivity, {actId = v.actId, endTime = v.endTime})
		end
		node.vars.time:setText(self:GetTime(nowTime, v.endTime))
		node.vars.stateTxt:setText(self:GetSate(v.roleSize))
		--node.vars.headframe:setImage()
		scroll:addItem(node)
	end
end

function wnd_annunciate:lookRanklist(ranks, selfRank)
	local vars = self._layout.vars
	vars.rankRoot:show()
	vars.xbRoot:hide()
	local anData = g_i3k_game_context:GetAnnunciateData()
	vars.awardNum:setText(anData.prestige)
	vars.rankTxt:setText(i3k_get_string(902,selfRank))
	local scroll = vars.rankScroll
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)
	for i,v in ipairs(ranks)  do
		local node = require("ui/widgets/txbwt")()
		node.vars.rankTxt:setText(i)
		node.vars.name:setText(v.role.name)
		node.vars.level:setText(v.role.level)
		node.vars.career:setText(g_i3k_db.i3k_db_get_general(v.role.type).name)
		node.vars.awardNum:setText(math.floor(v.rankKey / math.pow(2,10)))
		node.vars.fighting:setText(v.role.fightPower)
		scroll:addItem(node)
	end
end

function wnd_annunciate:gotoActivity(sender, args)
	if math.mod(i3k_game_get_time(), 86400) > args.endTime then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(912))
	end
	
	local fun = function()
		i3k_sbean.emergency_enter_req_send(args.actId)
		self:onCloseUI()
	end
	g_i3k_game_context:CheckMulHorse(fun)
end

function wnd_annunciate:help(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(15338))
end

function wnd_create(layout, ...)
	local wnd = wnd_annunciate.new()
	wnd:create(layout, ...)
	return wnd;
end
