
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_fiveEndActivity = i3k_class("wnd_fiveEndActivity",ui.wnd_base)

function wnd_fiveEndActivity:ctor()
	self._Tick = 0
	self.taskWidgets = {}
	self.endTime = 0
	self.start = true
	self.isLastStr = ""
	self.targetTbl = { }
end

local TargetFunc = 
{
	[1] = function(cfg)				--等级
	end ,

	[2] = function(cfg)				--活跃度
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule)
	end , 

	[3] = function(cfg)				--击杀任意怪物

	end , 

	[4] = function(cfg)				--击杀指定怪物
		g_i3k_game_context:GotoMonsterPos(cfg.arg2)
	end ,

	[5] = function()				--花费金币
	end , 

	[6] = function(cfg)			--装备升级
		g_i3k_logic:OpenStrengEquipUI()
	end , 

	[7] = function(cfg)				 --升星
		g_i3k_logic:OpenEquipStarUpUI()
	end ,

	[8] = function(cfg)				 --宝石
		g_i3k_logic:OpenEquipGemInlayUI()
	end ,

	[9] = function(cfg)				 --技能
		g_i3k_logic:OpenSkillLyUI()
	end ,

	[10] = function(cfg)		 --坐骑
		g_i3k_logic:OpenSteedUI()
	end ,

	[11] = function(cfg)		 --坐骑
		g_i3k_logic:OpenSteedUI()
	end ,

	[12] = function(cfg)			--宠物
		g_i3k_logic:OpenPetUI()
	end,

	[13] = function(cfg)
		
	end ,

	[14] = function(cfg)		 --神兵
		g_i3k_logic:OpenShenBingUI()
	end ,

	[15] = function(cfg)			 --神兵
		g_i3k_logic:OpenShenBingUI()
	end ,

	[16] = function(cfg)			--历史消耗X元宝 --宝石祝福
		-- g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
		g_i3k_logic:OpenEquipGemInlayUI()
	end ,

	[17] = function(cfg)			--成就
		g_i3k_logic:OpenDailyTask(1)
	end ,

	[18] = function(cfg)			--生产
		--g_i3k_logic:OpenShenBingUI()
		i3k_sbean.product_data_sync(6,1)
	end ,

	[19] = function(cfg)			--加入帮派
		g_i3k_logic:OpenFactionUI()
	end ,

	[20] = function(cfg)			--好友
		g_i3k_logic:OpenMyFriendsUI()
	end ,

	[21] = function(cfg)			--试炼之地
		g_i3k_logic:OpenShiLianUI()
	end ,

	[22] = function(cfg)			--运镖
		g_i3k_logic:OpenFactionEscortUI()
	end ,

	[23] = function(cfg)			--自创武功
		g_i3k_logic:OpenFactionCreateGongfuUI()
	end ,
	-------------------------------------------------------
	[24] = function(cfg)			--时装
		g_i3k_logic:OpenFashionDressUI()
	end ,
	[25] = function(cfg)			--探宝
		g_i3k_logic:OpenTreasureUI()
	end ,
	[26] = function(cfg)			--充值
		g_i3k_logic:OpenChannelPayUI()
	end ,
	[27] = function(cfg)			--贵族等级
		g_i3k_logic:OpenChannelPayUI()
	end ,
	[28] = function(cfg)			--累计充值
		g_i3k_logic:OpenChannelPayUI()
	end ,
	[29] = function(cfg)			--竞技场
		g_i3k_logic:OpenArenaUI()
	end ,
	[30] = function(cfg)			--内甲
		g_i3k_logic:enterUnderWearUI()
	end ,
	[31] = function(cfg)			--内甲
		g_i3k_logic:enterUnderWearUI()
	end ,
	[32] = function(cfg)		 --坐骑
		g_i3k_logic:OpenSteedUI()
	end ,
	[33] = function(cfg)		 --单人本
		g_i3k_logic:OpenDungeonUI(false)
	end ,
	-- [36] = function(cfg)			--进入坐骑界面
	-- 	g_i3k_logic:OpenSteedUI()
	-- end ,
	-- [37] = function(cfg)			--进入会武界面
	-- 	--参与会武副本
	-- 	g_i3k_logic:OpenTournamentUI()
	-- end ,
	-- [38] = function(cfg)			--进入势力战界面
	-- 	g_i3k_logic:OpenForceWarUI()
	-- end ,
	
	-- [39] = function(cfg)			--进入五绝试炼界面
	-- 	--参与五绝试炼
	-- 	g_i3k_logic:OpenFiveUniqueUI()
	-- end ,
	-- [40] = function(cfg)			--进入正邪界面
	-- 	g_i3k_logic:OpenTaoistUI()
	-- end ,
	-- [41] = function(cfg)			--江湖百事通之
	-- 	g_g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	-- end ,
	-- [42] = function(cfg)			--江湖百事通之
	-- 	g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	-- end ,
	-- [43] = function(cfg)			--进入生产界面
	-- 	g_i3k_logic:OpenFactionProduction()
	-- end ,
	-- [44] = function(cfg)			--进入售卖界面
	-- 	g_i3k_logic:OpenAuctionUI()
	-- end ,
	-- [45] = function(cfg)			--进入内甲界面
	-- 	g_i3k_logic:enterUnderWearUI()

	-- end ,
	-- [46] = function(cfg)			--进入内甲界面
	-- 	g_i3k_logic:enterUnderWearUI()
	-- end ,
}


function wnd_fiveEndActivity:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.close:onClick(self, function()
	end)
	self.finalBtn = widgets.finalBtn
	self.finalDesc = widgets.finalDesc
	self.nextdesc = widgets.nextdesc
	self.finalBg = widgets.bg7
	self.titleIcon = widgets.titleIcon
	self.finalanim = self._layout.anis.c_bx6
	for i = 1 , 6 do
		self.taskWidgets[i] = {
			frame = widgets["frame"..i],
			icon = widgets["icon"..i],
			btn = widgets["btn"..i],
			count = widgets["count"..i],
			desc = widgets["des"..i],
			bg = widgets["bg"..i],
			lizi = widgets["lizi"..i],
		}
	end
end

function wnd_fiveEndActivity:getTaskFinish(count, target)
	local isFinish = count >= target
	local str = g_i3k_make_color_string(count.."/"..target, g_i3k_get_cond_color(isFinish), true)
	return isFinish, str
end

function wnd_fiveEndActivity:getTargetCount(cfg, count)
	local fmt = i3k_db_fiveEnd_activity.fmts[cfg.type]
	local str = ""
	local isFinish = false
	if cfg.type == 2 then
		isFinish, str = self:getTaskFinish(count, cfg.arg1)
		str = string.format(fmt, str, cfg.arg2)
	elseif cfg.type == 4 then
		isFinish, str = self:getTaskFinish(count, cfg.arg1)
		str = string.format(fmt, g_i3k_db.i3k_db_get_monster_name(cfg.arg2)..":"..str)
	elseif cfg.type == 5 then
		isFinish, str = self:getTaskFinish(count, cfg.arg1)
		local name = g_i3k_db.i3k_db_get_common_item_name(cfg.arg2)
		if cfg.arg1 > 0 then
			name = g_i3k_db.i3k_db_get_common_item_is_free_type(cfg.arg2)..name
		end
		str = string.format(fmt, name, str)
	elseif cfg.type == 11 then
		isFinish = count >= cfg.arg1
		local name = i3k_db_steed_huanhua[ i3k_db_steed_cfg[cfg.arg2].huanhuaInitId ].name
		str = g_i3k_make_color_string(name, g_i3k_get_cond_color(isFinish), true)
		str = string.format(fmt, str)
	elseif cfg.type == 14 then
		isFinish, str = self:getTaskFinish(count, cfg.arg1)
		str = string.format(fmt, str, cfg.arg2)
	elseif cfg.type == 15 then
		isFinish = count >= cfg.arg1
		str = g_i3k_make_color_string(i3k_db_shen_bing[cfg.arg2].name, g_i3k_get_cond_color(isFinish), true)
		str = string.format(fmt, str)
	elseif cfg.type == 19 or cfg.type == 26 then
		isFinish = count >= cfg.arg1
		str = g_i3k_make_color_string(fmt, g_i3k_get_cond_color(isFinish), true)
	elseif cfg.type == 29 then
		isFinish = count ~= 0 and count <= cfg.arg1
		str = g_i3k_make_color_string(count.."/"..cfg.arg1, g_i3k_get_cond_color(isFinish), true)
		str = string.format(fmt, str)
	else
		isFinish, str = self:getTaskFinish(count, cfg.arg1)
		str = string.format(fmt, str)
	end
	return isFinish, str
end

function wnd_fiveEndActivity:isReward(t, targetId)
	for i,v in ipairs(t) do
		if v == targetId then
			return true
		end
	end
	return false
end

function wnd_fiveEndActivity:refresh(info)
	--info = {nowId = 2, startTime = 1499918400, takedGoals={}, takedRewards ={7,}, goalsTimes = {[7] = 0, [8] = 0, [9] = 0, [10] = 0,[11] = 0,[12] = 0}}
	local titles = {4193, 4194, 4191, 4190, 4192}
	local cfg = i3k_db_fiveEnd_activity.cfg[info.nowId]
	self.endTime =  cfg.time + info.startTime - i3k_game_get_time()
	self.isLastStr = i3k_get_string(#i3k_db_fiveEnd_activity.cfg == info.nowId and 15547 or 15546 )
	self.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(titles[info.nowId or #titles]))
	if self.endTime <=	0 then
		self.nextdesc:hide()
	else
		self.nextdesc:show()
		self.nextdesc:setText("")
	end

	local isAllFinish = true
	local tCfg = i3k_db_fiveEnd_activity.target
	for i = 1 , #cfg.targetIds do
		local targetId = cfg.targetIds[i]
		local value = info.goalsTimes[targetId] or 0
		local node = self.taskWidgets[i]
		local targetCfg = tCfg[targetId]
		node.frame:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(targetCfg.rewards.id)))
		node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(targetCfg.rewards.id, i3k_game_context:IsFemaleRole()))
		node.count:setText("X"..i3k_get_num_to_show(targetCfg.rewards.count))
		
		local isFinish, str = self:getTargetCount(targetCfg, value)
		if isFinish then
			node.bg:hide()
		else
			node.bg:show()
			isAllFinish = false
		end
		
		if self:isReward(info.takedGoals, targetId) then
			node.btn:setTouchEnabled(false)
			node.desc:setText(i3k_get_string(15561))
			node.lizi:setVisible(false)
		else
			node.desc:setText(str)
			node.desc:onClick(self, self.doTask, {isFinish = isFinish, type = targetCfg.type})
			node.btn:onClick(self, self.lookReward, {isFinish = isFinish, rewards = targetCfg.rewards, targetId = targetId})
			if isFinish then
				node.lizi:setVisible(isFinish)
			else
				node.lizi:setVisible(isFinish)
			end
		end
	end
	self.finalBg:setVisible(not isAllFinish)
	if self:isReward(info.takedRewards, info.nowId) then
		self.finalBtn:setTouchEnabled(false)
		self.finalDesc:setText(i3k_get_string(15561))
		self.finalanim.stop()
	else
		self.finalDesc:setText(i3k_get_string(15548))
		self.finalBtn:onClick(self, self.lookFinalReward, {isAllFinish = isAllFinish, nowId = info.nowId})
		if isAllFinish then
			self.finalanim.play()
		else
			self.finalanim.stop()
		end
	end
end 

function wnd_fiveEndActivity:onUpdate(dTime)
	self._Tick = self._Tick + dTime
	if self._Tick >= 1 and self.endTime > 0 then
		self._Tick = 0
		self.endTime = self.endTime - 1
		if self.endTime > 0 then
			local time = self.endTime
			time = string.format("%02d:%02d:%02d", time/3600, (time%3600)/60, time%60)
			self.nextdesc:setText(self.isLastStr..time)
		else
			self.nextdesc:hide()
			i3k_sbean.five_goals_syncReq()
		end
	end
end

function wnd_fiveEndActivity:gotoActivity(targetId)
	self:onCloseUI()
	local cfg = i3k_db_fiveEnd_activity.target[targetId]
	TargetFunc[targetId](cfg)
end

function wnd_fiveEndActivity:lookReward(sender, args)
	local rewards = args.rewards
	if args.isFinish then
		local items = {[rewards.id] = rewards.count}
		self:sendRewardPtl(items, 2, args.targetId)
	else
		g_i3k_ui_mgr:ShowCommonItemInfo(rewards.id)
	end
end

function wnd_fiveEndActivity:lookFinalReward(sender, args)
	local finalRewards = i3k_db_fiveEnd_activity.cfg[args.nowId].finalRewards
	if not args.isAllFinish then
		local gift = {}
		for i = 1 , #finalRewards do
			gift[i] = {ItemID = finalRewards[i].id, count = finalRewards[i].count}
		end
		g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips,gift)
	else
		local items = {}
		for i = 1 , #finalRewards do
			items[finalRewards[i].id] = finalRewards[i].count
		end
		self:sendRewardPtl(items, 1, args.nowId)
	end
end

function wnd_fiveEndActivity:sendRewardPtl(items, rtype, id)
	if not g_i3k_game_context:IsBagEnough(items) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
	i3k_sbean.five_goals_take_rewardReq(rtype, id, items)
end

function wnd_fiveEndActivity:doTask(sender, args)
	if not args.isFinish then
		self:gotoActivity(args.type)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_fiveEndActivity.new()
	wnd:create(layout, ...)
	return wnd;
end

