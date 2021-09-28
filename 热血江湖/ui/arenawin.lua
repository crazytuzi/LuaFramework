-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaWin = i3k_class("wnd_arenaWin", ui.wnd_base)

local f_numberImgTable = {"jjc#jjc_0.png", "jjc#jjc_1.png", "jjc#jjc_2.png", "jjc#jjc_3.png", "jjc#jjc_4.png", "jjc#jjc_5.png", "jjc#jjc_6.png", "jjc#jjc_7.png", "jjc#jjc_8.png", "jjc#jjc_9.png"}

local star_icon = {129,38,39,40,41,42}

function wnd_arenaWin:ctor()
end

function wnd_arenaWin:configure(...)
	self._timeTick = 0
	
	self._layout.vars.exitBtn:onClick(self, self.onQuit)
	self._layout.vars.ShareBtn:onClick(self,self.onShare)
	
	local winner = {}
	winner.icon = self._layout.vars.winnerIcon
	winner.star = self._layout.vars.winnerStar
	winner.lvl = self._layout.vars.winnerLvl
	winner.name = self._layout.vars.winnerName
	winner.power = self._layout.vars.winnerPower
	
	self._winner = winner
	
	
	local loser = {}
	loser.icon = self._layout.vars.loserIcon
	loser.star = self._layout.vars.loserStar
	loser.lvl = self._layout.vars.loserLvl
	loser.name = self._layout.vars.loserName
	loser.power = self._layout.vars.loserPower
	
	self._loser = loser
	
end

function wnd_arenaWin:onShow()
	local ShareBtn = self._layout.vars.ShareBtn
	ShareBtn:setVisible(false)
	if i3k_game_get_os_type() ~= eOS_TYPE_IOS then
	    if	g_i3k_game_handler:IsSupportShareSDK() then
	 	     ShareBtn:setVisible(true)
	    end
	else 
	  	ShareBtn:setVisible(true)
	end
	ShareBtn:setVisible(false)
end

function wnd_arenaWin:refresh(result)
	self:setData(result)
	local function callbackfun()
		g_i3k_logic:OpenArenaUI()
	end
	local mId,value = g_i3k_game_context:getMainTaskIdAndVlaue()
	local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
	if main_task_cfg.type == g_TASK_PERSONAL_ARENA then
		callbackfun = function()
			g_i3k_logic:OpenBattleUI()
		end
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end
	
function wnd_arenaWin:setData(result)
	if result then
		local mww = self._layout.vars.mww
		local mqw = self._layout.vars.mqw
		local mbw = self._layout.vars.mbw
		local msw = self._layout.vars.msw
		local mgw = self._layout.vars.mgw
		
		local eww = self._layout.vars.eww
		local eqw = self._layout.vars.eqw
		local ebw = self._layout.vars.ebw
		local esw = self._layout.vars.esw
		local egw = self._layout.vars.egw
		
		local selfRank = result.selfRank
		local targetRank = result.targetRank
		
		if selfRank<10000 then
			mgw:hide()
			if selfRank<1000 then
				msw:hide()
				if selfRank<100 then
					mbw:hide()
					if selfRank<10 then
						mqw:hide()
						mww:setImage(f_numberImgTable[selfRank+1])
					else
						local sw = math.floor(selfRank/10)
						local gw = math.floor(selfRank%10/1)
						mww:setImage(f_numberImgTable[sw+1])
						mqw:setImage(f_numberImgTable[gw+1])
					end
				else
					local bw = math.floor(selfRank/100)
					local sw = math.floor(selfRank%100/10)
					local gw = math.floor(selfRank%1000%100%10/1)
					mww:setImage(f_numberImgTable[bw+1])
					mqw:setImage(f_numberImgTable[sw+1])
					mbw:setImage(f_numberImgTable[gw+1])
				end
			else
				local qw = math.floor(selfRank/1000)
				local bw = math.floor(selfRank%1000/100)
				local sw = math.floor(selfRank%1000%100/10)
				local gw = math.floor(selfRank%1000%100%10/1)
				mww:setImage(f_numberImgTable[qw+1])
				mqw:setImage(f_numberImgTable[bw+1])
				mbw:setImage(f_numberImgTable[sw+1])
				msw:setImage(f_numberImgTable[gw+1])
			end
		else
			local ww = math.floor(selfRank/10000)
			local qw = math.floor(selfRank%10000/1000)
			local bw = math.floor(selfRank%10000%1000/100)
			local sw = math.floor(selfRank%10000%1000%100/10)
			local gw = math.floor(selfRank%10000%1000%100%10/1)
			mww:setImage(f_numberImgTable[ww+1])
			mqw:setImage(f_numberImgTable[qw+1])
			mbw:setImage(f_numberImgTable[bw+1])
			msw:setImage(f_numberImgTable[sw+1])
			mgw:setImage(f_numberImgTable[gw+1])
		end
		
		
		if targetRank<10000 then
			egw:hide()
			if targetRank<1000 then
				esw:hide()
				if targetRank<100 then
					ebw:hide()
					if targetRank<10 then
						eqw:hide()
						eww:setImage(f_numberImgTable[targetRank+1])
					else
						local sw = math.floor(targetRank/10)
						local gw = math.floor(targetRank%10/1)
						eww:setImage(f_numberImgTable[sw+1])
						eqw:setImage(f_numberImgTable[gw+1])
					end
				else
					local bw = math.floor(targetRank/100)
					local sw = math.floor(targetRank%100/10)
					local gw = math.floor(targetRank%1000%100%10/1)
					eww:setImage(f_numberImgTable[bw+1])
					eqw:setImage(f_numberImgTable[sw+1])
					ebw:setImage(f_numberImgTable[gw+1])
				end
			else
				local qw = math.floor(targetRank/1000)
				local bw = math.floor(targetRank%1000/100)
				local sw = math.floor(targetRank%1000%100/10)
				local gw = math.floor(targetRank%1000%100%10/1)
				eww:setImage(f_numberImgTable[qw+1])
				eqw:setImage(f_numberImgTable[bw+1])
				ebw:setImage(f_numberImgTable[sw+1])
				esw:setImage(f_numberImgTable[gw+1])
			end
		else
			local ww = math.floor(targetRank/10000)
			local qw = math.floor(targetRank%10000/1000)
			local bw = math.floor(targetRank%10000%1000/100)
			local sw = math.floor(targetRank%10000%1000%100/10)
			local gw = math.floor(targetRank%10000%1000%100%10/1)
			eww:setImage(f_numberImgTable[ww+1])
			eqw:setImage(f_numberImgTable[qw+1])
			ebw:setImage(f_numberImgTable[bw+1])
			esw:setImage(f_numberImgTable[sw+1])
			egw:setImage(f_numberImgTable[gw+1])
		end
		
		
		
		local logic = i3k_game_get_logic();
		
		local hero = logic:GetPlayer():GetHero()
		local roleInfo = g_i3k_game_context:GetRoleInfo()
		local headIcon = roleInfo.curChar._headIcon
		
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, 1);--1圆2方
		if hicon and hicon > 0 then
			self._winner.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		self._winner.lvl:setText(hero._lvl)
		self._winner.name:setText(hero._name)
		local power = g_i3k_game_context:GetAttackPower()
		self._winner.power:setText(power)
		
		
		if result.defendingSide.id<0 then
			local robot = i3k_db_arenaRobot[math.abs(result.defendingSide.id)]
			result.defendingSide.fightPower = robot.power
		end
		self._loser.power:setText(result.defendingSide.fightPower)
		self._loser.lvl:setText(result.defendingSide.level)
		self._loser.name:setText(result.defendingSide.name)
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(result.defendingSide.headIcon, 1);
		if hicon and hicon > 0 then
			self._loser.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
	end
end

function wnd_arenaWin:onShare(sender)
	g_i3k_game_handler:ShareScreenSnapshotAndText(i3k_get_string(15369), true)
end



function wnd_arenaWin:onQuit(sender, eventType)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaWin)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero._AutoFight = false
	end
	i3k_sbean.mapcopy_leave()
end

function wnd_arenaWin:onUpdate(dTime)
	local timeLabel = self._layout.vars.coolTimeLabel
	local autoCloseTime = i3k_db_arena.arenaCfg.autoCloseTime
	self._timeTick = self._timeTick+dTime
	local time = math.floor(autoCloseTime-self._timeTick)
	time = time>0 and time or 0
	timeLabel:setText(math.floor(autoCloseTime-self._timeTick))
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaWin.new();
		wnd:create(layout, ...);

	return wnd;
end
