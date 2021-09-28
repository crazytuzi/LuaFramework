-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_main = i3k_class("wnd_main", ui.wnd_base)

local DAILY_TAG		= 1
local ACT_TAG		= 2
local ARENA_TAG		= 3
local DUNGEON_TAG	= 4
local timeCounter 	= 0
local TIMER_MAX_COUNT = 80 * 60

function wnd_main:ctor()
	self._widgets = {}
end

function wnd_main:configure(...)
	self.dailyNotice = self._layout.vars.red;
	self.arenaNotice = self._layout.vars.arenaRed;

	local widgets = self._layout.vars

	self._widgets = {
		[DAILY_TAG] = {btn = widgets.btnDailyTask, selectImg = widgets.selectDaily},
		[ACT_TAG] = {btn = widgets.btnAct, selectImg = widgets.selectAct},
		[ARENA_TAG] = {btn = widgets.btnPVP, selectImg = widgets.selectPVP},
		[DUNGEON_TAG] = {btn = widgets.btnDungeon, selectImg = widgets.selectDungeon}
	}
	for i,v in ipairs(self._widgets) do
		v.btn:setTag(i)
		v.selectImg:setTag(i)
		v.btn:onTouchEvent(self, self.cardFunction)
	end

	self._layout.vars.closeBtn:onClick(self, function ()
		g_i3k_logic:OpenBattleUI()
	end)
	self._layout.vars.backGround:onClick(self, function ()
		g_i3k_logic:OpenBattleUI()
	end)
end


function wnd_main:onShow()

end

function wnd_main:updateRoleVipExperienceLevel()
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if g_i3k_game_context:GetPracticalVipLevel() ~= 0 and  g_i3k_game_context:GetPracticalVipLevel() >= g_i3k_game_context:GetVipExperienceLevel() then
		g_i3k_game_context:SetVipExperienceLevel(0)
	else
		if g_i3k_game_context:GetVipExperienceLevel() ~= 0 then
			local allTime = g_i3k_game_context:GetVipExperienceEndTime()
			local nowTime = allTime - serverTime
			if nowTime <= 0 then
				g_i3k_game_context:SetVipExperienceLevel(0)
				g_i3k_game_context:SetVipLevel(g_i3k_game_context:GetPracticalVipLevel(), true)
			end
		end
	end
end

function wnd_main:onUpdate(dTime)
	timeCounter = timeCounter + 1
	if timeCounter % (TIMER_MAX_COUNT / 60) == 0 then
		self:updateRoleVipExperienceLevel()		--每秒执行一次
	end
end

function wnd_main:onHide()

end

function wnd_main:cardFunction(sender, eventType)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local tag = sender:getTag()
	if eventType==ccui.TouchEventType.began then
		for i,v in ipairs(self._widgets) do
			v.selectImg:setVisible(tag==i)
		end
	elseif eventType==ccui.TouchEventType.canceled then
		for i,v in ipairs(self._widgets) do
			v.selectImg:hide()
		end
	elseif eventType==ccui.TouchEventType.ended then
		if tag==DAILY_TAG then
			self._layout.vars.red:hide()
			g_i3k_logic:OpenDailyTask(1)
		elseif tag==ACT_TAG then
			g_i3k_ui_mgr:OpenUI(eUIID_Activity)
			g_i3k_ui_mgr:RefreshUI(eUIID_Activity)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadDailyActivity")
		elseif tag==ARENA_TAG then
			local hero = i3k_game_get_player_hero()
			if hero then
				if hero._lvl < i3k_db_arena.arenaCfg.needLvl then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_arena.arenaCfg.needLvl))
				else
					local room = g_i3k_game_context:IsInRoom()
					if not room or room.type~=gRoom_Dungeon then
						i3k_sbean.sync_arena_info()
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(143))
					end
				end
			end
		elseif tag==DUNGEON_TAG then
			local logic = i3k_game_get_logic();
			local world = logic:GetWorld()
			local mapID = world._cfg.id
			local opneType = i3k_db_dungeon_base[mapID].openType
			if opneType ~= 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(49))
				return
			end
			g_i3k_logic:OpenDungeonUI()
		end
		for i,v in ipairs(self._widgets) do
			v.selectImg:hide()
		end
	end
end

---服务器通知的小红点更新
function wnd_main:updateNotices()
	self:updateDailyNotice()
end

--mainUI中间部分小红点显示
function wnd_main:updateCenterNotices()
	self:updateDailyNotice()
	self:setArenaRedSpot(g_i3k_game_context:isShowArenaListRedPoint())
end

--竞技场红点提示
function wnd_main:setArenaRedSpot(isShow)
	self.arenaNotice:setVisible(isShow)
end

--
function wnd_main:updateDailyNotice()
	--g_NOTICE_TYPE_CAN_REWARD_DAILY_TASK) or  日常任务迁移 日常图标不在判断日常任务相关内容
	self.dailyNotice:setVisible(g_i3k_game_context:testNotice(G_NOTICE_TYPE_CAN_REWARD_CHALLENGE_TASK) or 
		(g_i3k_game_context:GetLevel() >= i3k_db_fame_condition.openFameLvl[1] and g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_FAME)) or
		(g_i3k_game_context:isFinishCurrAdventureTask() and g_i3k_game_context:GetLevel() >= i3k_db_adventure.cfg.openlvl) or
		g_i3k_game_context:getCardPacketRed()
		)
end



function wnd_main:refresh()
	g_i3k_ui_mgr:RefreshUI(eUIID_XB)
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	g_i3k_ui_mgr:RefreshUI(eUIID_DBF)
	self:updateCenterNotices()
end


function wnd_create(layout)
	local wnd = wnd_main.new()
	wnd:create(layout)
	return wnd
end
