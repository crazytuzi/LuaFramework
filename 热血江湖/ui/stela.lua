-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_stela = i3k_class("wnd_stela", ui.wnd_base)

function wnd_stela:ctor()
	self._page = 1
	self._stlType = 0
	self._info = nil
	self._remainTimes = nil
	self._selectedIndex = 1
	self._freshDelaye = 0
	self._rankDelaye = 0
	self._lastStaleBtn = nil
	self._isFinish = false
end

function wnd_stela:configure()
	local vars = self._layout.vars
	vars.closeBtn:onClick(self, self.onCloseUI)
	vars.helpBtn:onClick(self, self.help)
	vars.freshBtn:onClick(self, self.refreshStelaInfo)
	vars.goBtn:onClick(self, self.gotoStela)
	vars.tsPage:onClick(self, self.selectPage, 1)
	vars.chPage:onClick(self, self.selectPage, 2)
	for i = 1 , 6 do
		local str = "stelaBtn"..i
		vars[str]:onClick(self, self.changeStela,i)
	end
end

function wnd_stela:refresh(stlType, info, remainTimes)
	local vars = self._layout.vars
	self._info = info
	if stlType == 0  then--nowTime > limitTime or 
		self._isFinish = true
		self._page = 2
		i3k_sbean.stele_rank_req_send()
		vars.chPage:stateToPressed()
		return
	end

	self._stlType = stlType
	
	self._remainTimes = remainTimes
	
	vars.awardNum:setText(info.card)

	if not self._lastStaleBtn then
		self._selectedIndex = info.index
		if info.index == 0 then
			self._selectedIndex = 1
		end
		self._lastStaleBtn = vars["stelaBtn"..self._selectedIndex]
		self._lastStaleBtn:stateToPressed()
	end
	if info.index > 0 then
		vars.goBtn:hide()
	end
	vars.actDesc:setText(i3k_get_string(15200))

	local oneGroup = i3k_db_steleAct.stale[self._stlType]
	for i = 1 , 6 do
		vars["finshIcon"..i]:hide()
		if self._remainTimes[i] == 0 then
			vars["Icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(oneGroup[i].brokenIcon))
		end
		if info.index > i or info.allFinish > 0 then
			vars["finshIcon"..i]:show()
		end
	end
	vars.tsPage:stateToPressed()
	self:exploreStela()
end

function wnd_stela:selectPage(sender, args)
	if self._page == args and self._page == 1 then
		return
	end
	self._page = args

	local vars = self._layout.vars
	if args == 1 then
		
		if not self._isFinish then
			self:exploreStela()
			sender:stateToPressed()
			vars.chPage:stateToNormal()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(898))
		end
	else
		vars.tsPage:stateToNormal()
		if i3k_game_get_time() - self._rankDelaye > 2 then
			i3k_sbean.stele_rank_req_send()
			self._rankDelaye = i3k_game_get_time()
			sender:stateToPressed()
		else
			vars.tsRoot:hide()
			vars.ckRoot:show()
		end
	end
end

function wnd_stela:getExplorStateText(remainTimes, allFinish, index1, index2, endTime)
	local id = 0 
	if remainTimes == 0 then
		id = 889--return "剩余次数为0无法探索"
	elseif (index2 < index1) or allFinish == 1 then
		id = 899 --return "已探索"
	elseif index1 == index2 then
		id = 900 --return "正在探索"
	else
		id = 901 --return "未探索"
	end

	return i3k_get_string(id)
end

function wnd_stela:exploreStela()
	local vars = self._layout.vars
	vars.tsRoot:show()
	vars.ckRoot:hide()
	
	local stlCfg = i3k_db_steleAct.stale[self._stlType][self._selectedIndex]
	local mineCfg = i3k_db_resourcepoint[stlCfg.mineId]


	vars.stelaImg:setImage(g_i3k_db.i3k_db_get_icon_path(mineCfg.headID))
	vars.stelaName:setText(mineCfg.name)
	vars.mapName:setText(i3k_db_field_map[stlCfg.mapId].desc)

	local remainTimes = self._remainTimes[self._selectedIndex] or 0
	vars.remainTimes:setText(remainTimes)
	vars.personal:setText(self:getExplorStateText(remainTimes, self._info.allFinish, self._info.index, self._selectedIndex))
end

function wnd_stela:lookRanklist(ranks, selfRank)
	local vars = self._layout.vars
	vars.tsRoot:hide()
	vars.ckRoot:show()

	vars.awardNum2:setText(self._info.card)
	if selfRank > 0 then
		vars.rankTxt:setText(i3k_get_string(902,selfRank))
	else
		vars.rankTxt:setText(i3k_get_string(15349))
	end
	local scroll = vars.scroll
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)
	for i,v in ipairs(ranks)  do
		local node = require("ui/widgets/txbwt")()
		node.vars.rankTxt:setText(i)
		node.vars.name:setText(v.role.name)
		node.vars.level:setText(v.role.level)
		node.vars.career:setText(g_i3k_db.i3k_db_get_general(v.role.type).name)
		node.vars.awardNum:setText(math.floor(v.rankKey / math.pow(2,16)))
		node.vars.fighting:setText(v.role.fightPower)
		scroll:addItem(node)
	end
end

function wnd_stela:changeStela(sender, i)
	self._selectedIndex = i
	self._lastStaleBtn:stateToNormal()
	sender:stateToPressed()
	self._lastStaleBtn = sender
	self:exploreStela()
end

function wnd_stela:refreshStelaInfo(sender)
	if i3k_game_get_time() - self._freshDelaye > 2 then
		i3k_sbean.stele_sync_req_send()
		self._freshDelaye = i3k_game_get_time()
	end
end

function wnd_stela:gotoStela()
	i3k_sbean.stele_join_req_send()
	self:onCloseUI()
end

function wnd_stela:help(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(897))
end

function wnd_create(layout, ...)
	local wnd = wnd_stela.new()
	wnd:create(layout, ...)
	return wnd;
end
