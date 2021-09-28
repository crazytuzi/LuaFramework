----------------------------------------------------------------
module(..., package.seeall)

local require = require;

require("i3k_global");
require("logic/i3k_logic_def");

local MAX_CURRENCY_AMOUNT = 999999999
local ARENAID = 20000

local l_task_side = 3
local l_task_weapon = 2             --神兵任务类型

local steedUIID = {
	eUIID_SteedFight,
	eUIID_SteedSprite,
	eUIID_SteedEquip,
	eUIID_SteedSuit,
	eUIID_SteedStove
}
local function manageSteedUI(uiid)
	for k, v in ipairs(steedUIID) do
		if v ~= uiid then
			g_i3k_ui_mgr:CloseUI(v)
		end
	end
	if not g_i3k_ui_mgr:GetUI(uiid) then
		return true
	end
end
-------------------------------------------------------------
i3k_logic = i3k_class("i3k_logic")

function i3k_logic:ctor()

end

function i3k_logic:IsRootUIBattle()
	return g_i3k_ui_mgr:GetUI(eUIID_BattleBase) ~= nil
end

function i3k_logic:OpenBattleUI(callback)
	if not g_i3k_ui_mgr:GetUI(eUIID_BattleBase) then
		g_i3k_ui_mgr:CloseAllOpenedUI()
		g_i3k_ui_mgr:OpenUI(eUIID_BattleBase)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleBase)
		if g_i3k_game_context:getBackstageBtn() then
			g_i3k_ui_mgr:OpenUI(eUIID_GMEntrance)
			g_i3k_ui_mgr:RefreshUI(eUIID_GMEntrance)
		end
	end
	if g_i3k_ui_mgr:GetUI(eUIID_Bag) then
		g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	end
	local pigeonPost = g_i3k_game_context:getPigeonPost()
	if pigeonPost and pigeonPost.time and i3k_game_get_time() - pigeonPost.time < i3k_db_pigeon_post.itemInfo[pigeonPost.kiteId].lastTime then
		g_i3k_ui_mgr:OpenUI(eUIID_PigeonPost)
		g_i3k_ui_mgr:RefreshUI(eUIID_PigeonPost)
	else
		g_i3k_game_context:updatePigeonPost()
	end
	if callback then
		callback()
	end
end

function i3k_logic:OpenMainUI(callback)
	--[[if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		self:OpenBattleUI(callback)
		return
	end--]]
	if not g_i3k_ui_mgr:GetUI(eUIID_Main) then
		g_i3k_ui_mgr:CloseAllOpenedUI()
		g_i3k_ui_mgr:OpenUI(eUIID_Main)
		g_i3k_ui_mgr:RefreshUI(eUIID_Main)
		if g_i3k_game_context:getBackstageBtn() then
			g_i3k_ui_mgr:OpenUI(eUIID_GMEntrance)
			g_i3k_ui_mgr:RefreshUI(eUIID_GMEntrance)
		end
	end
	if callback then
		callback()
	end
end

function i3k_logic:OpenBattleTaskUI(state)
	if not g_i3k_ui_mgr:GetUI(eUIID_BattleTask) then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTask)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleTask,state)
	else
		if state then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"ShowTaskList", state)
		end
	end
end

function i3k_logic:OpenCallBack(isShowTips)
	if not g_i3k_game_context:testCallBackState() then
		return
	end
	i3k_sbean.request_role_back_sync_req()
end

function i3k_logic:OpenFactionSalary()
	--检查是否有分堂
	if not g_i3k_game_context:GetFactionGarrisonIsOpen() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3211))
		return
	end

	i3k_sbean.request_sect_salary_sync_req()
end

function i3k_logic:OpenDynamicActivityUI(actName)
	--self:OpenMainUI(function ()
		--i3k_sbean.sync_dynamic_activities()
		i3k_sbean.sync_dynamic_benefit(actName)
	--end)
end

function i3k_logic:OpenFactionBlessing(callback)
	i3k_sbean.sync_sect_zone_spirit_bless(callback)
end

function i3k_logic:OpenDailyActivityUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_activities_luckywheel()--幸运转盘
	end)
end

-- 充值活动入口（jumpID表示跳转固定页签【1周卡 2月卡 3逍遥卡 4龙魂币】）
function i3k_logic:OpenPayActivityUI(jumpID)
	i3k_sbean.sync_pay_activity(jumpID)
end

--排行榜个人榜
function i3k_logic:OpenRankListUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_rankList_info()
	end)
end

--排行榜其他榜
function i3k_logic:OpenOtherRankListUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_OtherRankList_info()
		--g_i3k_ui_mgr:OpenUI(eUIID_RankList_Other)
		--g_i3k_ui_mgr:RefreshUI(eUIID_RankList_Other,1)
	end)
end


--进入内甲系统
function i3k_logic:enterUnderWearUI()
	local cur_level = g_i3k_game_context:GetLevel()
	if cur_level >= i3k_db_under_wear_alone.underWearOpenLvl then
		g_i3k_logic:OpenUnderWearUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("内甲系统将于%d%s",i3k_db_under_wear_alone.underWearOpenLvl,"级开启"))
	end
end

--内甲
function i3k_logic:OpenUnderWearUI()
	self:OpenMainUI(function ()
		--i3k_sbean.sync_underWear_info()
		local curUnderWear, UnderWearData =  g_i3k_game_context:getUnderWearData()
		if curUnderWear ==0 then
			g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear)
			g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		else
			curData = UnderWearData[curUnderWear]
			local level = curData.level
			local rank =curData.rank
			if curData.level==0 then
				level = 1
			end
			if curData.rank==0 then
				rank = 1
			end
			local nameStr = i3k_db_under_wear_upStage[curUnderWear][rank].stageName
			local levelStr = i3k_db_under_wear_update[curUnderWear][level].underWearLevel
			local stageStr = i3k_db_under_wear_upStage[curUnderWear][rank].stageRank
			local tab = {underwear_name = nameStr ,underwear_level =levelStr ,underwear_stage = stageStr }
			self:OpenUnderWearUpdate(curUnderWear, tab)
		end

	end)
end

--内甲介绍
function i3k_logic:OpenUnderWearIntroduce()
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Introduce)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Introduce)
end

--内甲解锁
function i3k_logic:OpenUnderWearUnlock(index)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Unlock)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Unlock,index)
end

--内甲升级
function i3k_logic:OpenUnderWearUpdate(index,tab)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_update)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_update,index,tab)
end

--内甲升阶
function i3k_logic:OpenUnderWearUpStage(index,tab)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_upStage)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_upStage,index,tab)
end

--内甲天赋
function i3k_logic:OpenUnderWearTalent(index,tab)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Talent)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Talent,index,tab)
end

--内甲符文
function i3k_logic:OpenUnderWearRune(index,tab)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Rune)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Rune,index,tab)
end

--符文插槽解锁
function i3k_logic:OpenRuneSoltUnlock(index ,slotTag)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Slot_Unlock)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Slot_Unlock,index,slotTag)
end
------------------------
--结婚进度说明
function i3k_logic:OpenMerryProInstructions()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Progress_Inst)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Progress_Inst)
end

--缔结姻缘
function i3k_logic:OpenMerryCreate()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Create_Marriage)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Create_Marriage)
end

--立即求婚
function i3k_logic:OpenGotoMarry()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Demande_Marriage)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Demande_Marriage)
end

--选择规模
function i3k_logic:OpenSelectSize()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Select_Size)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Select_Size)
end

--收到求婚消息
function i3k_logic:OpenMarryProposing(grade)
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Proposing)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Proposing,grade)
end

--开启游街
function i3k_logic:OpenMarryWendding()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Wendding)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Wendding)
end

--星耀界面
function i3k_logic:OpenStarDish()
	g_i3k_ui_mgr:OpenUI(eUIID_StarDish)
	g_i3k_ui_mgr:RefreshUI(eUIID_StarDish)
end

--经脉界面
function i3k_logic:OpenMeridian(closeUIID)
	local openLvl = i3k_db_meridians.common.openLvl
	if g_i3k_game_context:GetLevel() < openLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16886, openLvl))
	end
	if closeUIID then
		g_i3k_ui_mgr:CloseUI(closeUIID)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Meridian)
	g_i3k_ui_mgr:RefreshUI(eUIID_Meridian, g_i3k_game_context:getMeridians())
end

--星魂界面
function i3k_logic:OpenStarSoul()
	local isOpen = false
	local lvl = g_i3k_game_context:GetLevel()
	local transLvl = g_i3k_game_context:GetTransformLvl()
	local heirloom = g_i3k_game_context:getHeirloomData()
	if heirloom.isOpen ~= 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15181))
	else
		if lvl >= i3k_db_chuanjiabao.cfg.openLvl then
			if transLvl >= i3k_db_chuanjiabao.cfg.needTransformLvl then
				g_i3k_ui_mgr:OpenUI(eUIID_XingHun)
				g_i3k_ui_mgr:RefreshUI(eUIID_XingHun)
				isOpen = true
			else
				g_i3k_ui_mgr:PopupTipMessage(string.format("神器星魂功能%s转开启", i3k_db_chuanjiabao.cfg.needTransformLvl))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(string.format("神器星魂功能将于%s级开启", i3k_db_chuanjiabao.cfg.openLvl))
		end
	end
	return isOpen
end

--坐骑骑战界面,state = 1,属性界面，=2 良驹之灵
function i3k_logic:OpenSteedFight(state)
	local isOpen = false
	if g_i3k_game_context:getUseSteed() ~= 0 then
		if g_i3k_game_context:getSteedFightShowCount() ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedFight,state)
			isOpen = true
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1258))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
	end
	return isOpen
end
function i3k_logic:OpenSteedFight1()
	local isOpen = false
	if g_i3k_game_context:getUseSteed() ~= 0 then
		if g_i3k_game_context:getSteedFightShowCount() ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedFight,1)
			isOpen = true
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1258))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
	end
	return isOpen
end
function i3k_logic:OpenSteedFight2()
	local isOpen = false
	if g_i3k_game_context:getUseSteed() ~= 0 then
		if g_i3k_game_context:getSteedFightShowCount() ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedFight,2)
			isOpen = true
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1258))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
	end
	return isOpen
end

--八卦界面
function i3k_logic:OpenBagua()
	local isOpen = true
	if g_i3k_game_context:GetLevel() < i3k_db_bagua_cfg.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17123,i3k_db_bagua_cfg.openLvl))
		isOpen = false
	end
	i3k_sbean.request_eightdiagram_sync_req()
	return isOpen
end


--开启婚宴
function i3k_logic:OpenMarryBanquet()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Banquat)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Banquat)
end

--未婚时开启界面
function i3k_logic:OpenUnmarried()
	g_i3k_ui_mgr:OpenUI(eUIID_Marry_Unmarried)
	g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Unmarried)
end

--已婚后开启界面(夫妻姻缘)
function i3k_logic:OpenMarried_Yinyuan(callback)
	--self:OpenMainUI(function ()
		i3k_sbean.marryInfo(1, callback)
	--end)
end

--已婚后开启界面(婚姻技能)
function i3k_logic:OpenMarried_skills()
	--self:OpenMainUI(function ()
		i3k_sbean.marryInfo(2)
	--end)
end

--已婚后开启界面(姻缘破裂)
function i3k_logic:OpenMarried_lihun()
	--self:OpenMainUI(function ()
		i3k_sbean.marryInfo(3)
	--end)
end

--已婚后开启界面(姻缘成就)
function i3k_logic:OpenMarried_achievement()
	--self:OpenMainUI(function ()
		i3k_sbean.marryInfo(4)
	--end)
end

--打开送花
function i3k_logic:OpenSendFlowerUI(player)
	local id = g_i3k_db.i3k_db_get_common_cfg().give_flower.flowerID
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
	if g_i3k_game_context:GetCommonItemCanUseCount(id) > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_GiveFlower)
		g_i3k_ui_mgr:RefreshUI(eUIID_GiveFlower, player)
	else
		local fun = (function(ok)
			if ok then
				g_i3k_ui_mgr:CloseUI(eUIID_Friends)
				g_i3k_logic:OpenVipStoreUI(cfg.showType, cfg.isBound, cfg.id)
			end
		end)
		local desc = string.format("您的背包里没有鲜花可以赠送~")
		g_i3k_ui_mgr:ShowCustomMessageBox2("前往购买", "以后再买", desc, fun)
	end
end
--打开定期活动
function i3k_logic:OpenTimingActivity()
	if g_i3k_db.i3k_db_get_timing_activity_state() == g_TIMINGACTIVITY_STATE_PREVIEW then
		g_i3k_ui_mgr:OpenUI(eUIID_TimingActivityTips)
	    g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivityTips)
	elseif g_i3k_db.i3k_db_get_timing_activity_state() == g_TIMINGACTIVITY_STATE_OPEN then
		i3k_sbean.open_timing_activity_req(function()
			g_i3k_ui_mgr:OpenUI(eUIID_TimingActivity)
			g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivity)
		end
		)	
	elseif g_i3k_db.i3k_db_get_timing_activity_state() == g_TIMINGACTIVITY_STATE_RECEIVE then
		i3k_sbean.open_timing_activity_req(function()
			g_i3k_ui_mgr:OpenUI(eUIID_TimingActivity)
			g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivity, g_EXCHANGE_UI)
		end
		)	
	end
end

--打开驻地队伍信息
function i3k_logic:OpenGarrisonTeam()
	local isOpen = g_i3k_db.i3k_db_get_faction_spirit_is_open()
	if isOpen then
		i3k_sbean.open_sect_zone_spirit_req(function()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrisonSpirit)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionGarrisonSpirit)
		
		g_i3k_ui_mgr:OpenUI(eUIID_SpiritSkill)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpiritSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSummary)
		local hero = i3k_game_get_player_hero()
		hero:LoadSpiritSkill();
		end,
		function()
			g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrisonSummary)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionGarrisonSummary)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)
			g_i3k_ui_mgr:CloseUI(eUIID_SpiritSkill)
		end
		)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrisonSummary)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionGarrisonSummary)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)
		g_i3k_ui_mgr:CloseUI(eUIID_SpiritSkill)
	end
end


--------------------------

--打开势力战排行榜
function i3k_logic:OpenForceWarRankListUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_rankList_info(9)
	end)
end

--打开帮派战排行榜
function i3k_logic:Openfactionfightrank()
	self:OpenMainUI(function ()
		i3k_sbean.sync_OtherRankList_info(2)
	end)
end

--打开会武周荣誉榜的接口
function i3k_logic:OpenSuperArenaWeekrankUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_rankList_info(6)
	end)
end

--单人竞技场
function i3k_logic:OpenArenaUI(callback)
	self:OpenMainUI(function ()
		i3k_sbean.sync_arena_info(callback)
	end)
end

--正邪道场
function i3k_logic:OpenTaoistUI(callback)
	self:OpenMainUI(function ()
		i3k_sbean.sync_taoist(callback)
	end)
end
--会武场
function i3k_logic:OpenTeamArenaUI(callback)
	self:OpenMainUI(function ()
		i3k_sbean.team_arena_sync()
	end)
end

--决战排行
function i3k_logic:OpenDesertBattleRankListUI()
	--TODO
	self:OpenMainUI(function ()
		i3k_sbean.sync_rankList_info(42)
	end)
end

function i3k_logic:OpenPetUI()
	self:OpenMainUI(function ()
		i3k_sbean.pet_sync()
	end)
end

function i3k_logic:OpenMyFriendsUI()
		self:OpenMainUI(function ()
		i3k_sbean.syncFriend(1)
	end)
end

-- 打开好友-我界面
function i3k_logic:OpenMyUI()
	self:OpenMainUI(function ()
		local callback = function ()
			i3k_sbean.item_unlock_head()
		end
		i3k_sbean.syncFriend(1, callback)
	end)
end

function i3k_logic:openLuckyStar()
		--self:OpenMainUI(function ()
		i3k_sbean.lucklystar_sync_req_send()
	--end)
end

function i3k_logic:OpenBagUI(showItemID)
	self:OpenBattleUI(function ()

		g_i3k_ui_mgr:OpenUI(eUIID_Bag)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bag,showItemID)
	end)
end

function i3k_logic:OpenRoleTitleUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleTitles)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleTitles)
	end)
end

function i3k_logic:OpenRoleTitleUIByRoleLy()
	if g_i3k_ui_mgr:GetUI(eUIID_RoleLy) then
		g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
	end
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleTitles)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleTitles)
	end)
end

function i3k_logic:OpenSignInUI()
	self:OpenMainUI(function ()
		i3k_sbean.checkin_sync()
	end)
end

function i3k_logic:OpenOfflineExpUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_OfflineExpReceive)
		g_i3k_ui_mgr:RefreshUI(eUIID_OfflineExpReceive)
	end)
end

function i3k_logic:OpenWizardUI()
	local lvl = g_i3k_game_context:GetLevel()
	local openLevel = i3k_db_offline_exp.fairyOpenLvl
	if lvl < openLevel then
		return
	end

	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_OfflineExpReceive)
		g_i3k_ui_mgr:RefreshUI(eUIID_OfflineExpReceive, true)
	end)
end

function i3k_logic:OpenVipStoreUI(curPoint, showType, itemId, callback)
	--self:OpenBattleUI(function ()
		i3k_sbean.mall_sync(curPoint, showType, itemId, callback)
	--end)
end

function i3k_logic:OpenRoleLyUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleLy)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleLy)
	end)
end

-- 打开经验系统描述页面
function i3k_logic:OpenExpDescUI()
	g_i3k_ui_mgr:OpenUI(eUI_EXP_DESC)
	g_i3k_ui_mgr:RefreshUI(eUI_EXP_DESC)
end

-- 打开帮助描述页面
function i3k_logic:OpenHelpUI(str)
	g_i3k_ui_mgr:OpenUI(eUIID_HelpPanel)
	g_i3k_ui_mgr:RefreshUI(eUIID_HelpPanel, str)
end

function i3k_logic:OpenFashionDressUI(showType, closeUIID)
	if g_i3k_game_context:GetIsInHomeLandZone() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5092))
	end
	self:OpenBattleUI(function ()
		if closeUIID then
			g_i3k_ui_mgr:CloseUI(closeUIID)
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FashionDress)
		g_i3k_ui_mgr:RefreshUI(eUIID_FashionDress, showType)
	end)
end

function i3k_logic:OpenArtufact1UI()
	if g_i3k_game_context:GetIsInHomeLandZone() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5092))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_OpenArtufact1)
	g_i3k_ui_mgr:RefreshUI(eUIID_OpenArtufact1)
end

function i3k_logic:OpenRoleLyUI2()
	self:OpenBattleUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleLy2)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleLy2)
	end)
end

function i3k_logic:OpenWarehouseUI(uiid)
	if g_i3k_game_context:GetLevel() < i3k_db_common.warehouse.unlockLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3059, i3k_db_common.warehouse.unlockLvl))
	else
		i3k_sbean.private_warehouse(uiid)
	end
end

function i3k_logic:OpenSkillLyUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_SkillLy)
		g_i3k_ui_mgr:RefreshUI(eUIID_SkillLy)
	end)
end

function i3k_logic:OpenXinfaUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_XinFa)
		g_i3k_ui_mgr:RefreshUI(eUIID_XinFa)
	end)
end

function i3k_logic:OpenShenBingUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ShenBing)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing)
	end)
end

function i3k_logic:OpenChatUI(chatType)
	self:OpenBattleUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_Chat)
		g_i3k_ui_mgr:RefreshUI(eUIID_Chat, chatType)
	end)
end

function i3k_logic:OpenFactionProduction()	--打开生产第一页第一签
	local role_lvl = g_i3k_game_context:GetLevel()
	if role_lvl < i3k_db_producetion_args.open_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(587,i3k_db_producetion_args.open_lvl))
		return
	end
	self:OpenMainUI(function ()
		i3k_sbean.product_data_sync()
	end)
end

--打开生产装备精炼

function i3k_logic:OpenFactionProdunctionRefine()
	local role_lvl = g_i3k_game_context:GetLevel()
	if role_lvl < i3k_db_producetion_args.open_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(587,i3k_db_producetion_args.open_lvl))
		return
	end
	self:OpenMainUI(function ()
		i3k_sbean.product_data_sync(nil,nil,3)
	end)
end

function i3k_logic:OpenEmpowermentUI()
	local lvl = g_i3k_game_context:GetLevel()
	local openLevel = i3k_db_experience_args.args.openLevel
	if lvl < openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(476, openLevel))
		return
	end
	self:OpenMainUI(function ()
		i3k_sbean.goto_expcoin_sync()
	end)
end

function i3k_logic:OpenLongyinUI()
		if g_i3k_game_context:GetLevel() < i3k_db_LongYin_arg.openNeed.hideLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(490))
			return
		end
	g_i3k_ui_mgr:OpenUI(eUIID_LongYin)
	g_i3k_ui_mgr:RefreshUI(eUIID_LongYin)

end

--back:日常打开充值标记（关闭返回日常）
function i3k_logic:OpenChannelPayUI(fun, openLonghun)
	self:OpenMainUI(function()
		i3k_sbean.sync_channel_pay(fun, openLonghun)
	end)
end

function i3k_logic:OpenAnswerQuestionsUI()
	self:OpenBattleUI(function()
		i3k_sbean.sync_activities_quizgift(1)
		--g_i3k_ui_mgr:OpenUI(eUIID_AnswerQuestions)
		--g_i3k_ui_mgr:RefreshUI(eUIID_AnswerQuestions)
	end)
end

function i3k_logic:OpenRewardTestUI()
	g_i3k_ui_mgr:OpenUI(eUIID_RewardTest)
	g_i3k_ui_mgr:RefreshUI(eUIID_RewardTest)
end

function i3k_logic:OpenRightHeart()
	g_i3k_ui_mgr:OpenUI(eUIID_RightHeart)
	g_i3k_ui_mgr:RefreshUI(eUIID_RightHeart)
end

function i3k_logic:OpenVipSystemUI(payInfo, curLvl)
	g_i3k_ui_mgr:OpenUI(eUIID_VipSystem)
	g_i3k_ui_mgr:RefreshUI(eUIID_VipSystem, payInfo, curLvl)
end

function i3k_logic:OpenDailyTask(state)
	self:OpenMainUI(function()
		i3k_sbean.sync_chtask_info(state)
		--[[g_i3k_ui_mgr:OpenUI(eUIID_DailyTask)
		g_i3k_ui_mgr:RefreshUI(eUIID_DailyTask, state, jumpTo)--]]
	end)
end

function i3k_logic:OpenAdventrue()
	self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_DailyTask)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "onUpdateAdventrue")
	end)
end

function i3k_logic:OpenOutCast()
	self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_DailyTask)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "OnOutCast")
	end)
end


function i3k_logic:OpenTaskUI(taskId,taskType,petId,callback)
	g_i3k_ui_mgr:OpenUI(eUIID_Task)
	g_i3k_ui_mgr:RefreshUI(eUIID_Task,taskId,taskType,petId)
	if callback then
		callback()
	end
end

function i3k_logic:openTaskSpecifiedUI(jumpUIID, args, taskId, taskCat)
	if jumpUIID and jumpUIID ~= 0 and i3k_db_task_leadUI[jumpUIID] then
		local cfg = i3k_db_task_leadUI[jumpUIID]
		if cfg.openMainUI then
			--g_i3k_coroutine_mgr:StartCoroutine(function ()
				--g_i3k_coroutine_mgr.WaitForNextFrame()
				g_i3k_logic:OpenMainUI()
			--end)
		end
		for i,v in ipairs(i3k_db_compound) do
			if itemID == v.getItemID then
				itemID = v.needItemId1
			end
		end
		if cfg.open then
			cfg.open(itemID)
		end
	elseif taskCat ~= TASK_CATEGORY_EPIC and taskCat ~= TASK_CATEGORY_ADVENTURE then
		g_i3k_logic:OpenTaskUI(taskId, taskCat)
	end
end

function i3k_logic:openWeaponTaskUI()
	local taskID = g_i3k_game_context:getWeaponTaskIdAndLoopType()
	self:OpenTaskUI(taskID,l_task_weapon)
end

function i3k_logic:OpenDungeonUI(zuidui, mapID, goldMap)
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_FBLB)
		g_i3k_ui_mgr:RefreshUI(eUIID_FBLB, zuidui, mapID, goldMap)
	end)
end

function i3k_logic:OpenBuyVitUI(isBuy)
	if not isBuy then
		local vitItems = g_i3k_game_context:getCanUseVitItems(true)
		if next(vitItems) then
			self:OpenUseVitUI()
			return
		end
	end
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_BuyVit)
		g_i3k_ui_mgr:RefreshUI(eUIID_BuyVit)
	end)
end

--有道具是优先弹出使用道具加体力值的界面
function i3k_logic:OpenUseVitUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_UseVit)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseVit, false)
	end)
end

-- 体力不足时是够打开购买体力界面提示
function i3k_logic:GotoOpenBuyVitUI()
	local fun = (function(ok)
		if ok then
			self:OpenBuyVitUI()
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(15184), fun)
end

function i3k_logic:OpenStrengEquipUI(partID, equip_id)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.strengLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(125, i3k_db_common.functionOpen.strengLvl))
		return
	end
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_StrengEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_StrengEquip, partID, equip_id)
	end)
end

function i3k_logic:OpenEquipStarUpUI()
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.starUpLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(126, i3k_db_common.functionOpen.starUpLvl))
		return
	end
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_EquipUpStar)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipUpStar)
	end)
end
-----------------------------------------------------------------------------------------------------------
function i3k_logic:OpenBillBoardUI()
	if g_i3k_game_context:GetLevel() < i3k_db_bill_board_reqlvl.open_bill_board_reqlvl[1] then
		g_i3k_ui_mgr:PopupTipMessage(string.format("留言板需要%d%s",i3k_db_bill_board_reqlvl.open_bill_board_reqlvl[1],"级开启"))
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	else
		i3k_sbean.sync_bill_bord()
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	end
end

function i3k_logic:OpenNpcExchange(npcId,exchangeId)
		g_i3k_ui_mgr:OpenUI(eUIID_npcExchange)
		g_i3k_ui_mgr:RefreshUI(eUIID_npcExchange,npcId,exchangeId, "exchange")
end
--------------------------------------------------------------------------------------------------------
function i3k_logic:OpenEquipGemInlayUI()
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.inlayLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, i3k_db_common.functionOpen.inlayLvl))
		return
	end
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_Jewel)
		g_i3k_ui_mgr:RefreshUI(eUIID_Jewel)
	end)
end
--开启装备锤炼界面
function i3k_logic:OpenEquipTemperUI(UIID)
	if not g_i3k_db.i3k_db_get_equip_temper_open() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17410, i3k_db_equip_temper_base.openLevel))
		return
	end
	if not self:GetDefaultCanTemperWeapon() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17406))
		return
	end
	g_i3k_ui_mgr:CloseUI(UIID)
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTemper)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemper)
	end)
end

--找出默认可以锤炼的装备位置
function i3k_logic:GetDefaultCanTemperWeapon()
	local wEquips = g_i3k_game_context:GetWearEquips()
	for k, v in ipairs(i3k_db_equip_temper_base.partDetail) do
		if v.isOpen == 1 then
			if wEquips[k] and wEquips[k].equip and g_i3k_db.i3k_db_get_equip_can_temper(wEquips[k].equip.equip_id) then
				return k
			end
		end
	end
	return false
end

function i3k_logic:OpenFactionMainUI(callback)
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionMain)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionMain)
		if callback then
			--g_i3k_ui_mgr:OpenUI(callback)
			callback()
		end
	end)
end

--打开帮派宴席界面
function i3k_logic:OpenFactionDine()
	local fun = (function()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionDineTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionDineTips)
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开帮派任务界面
function i3k_logic:OpenFactionTaskUI()
	local fun = (function()
		local data = i3k_sbean.sect_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_sync_res.getName())
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开帮派商路界面
function i3k_logic:OpenFCBSTaskUI()
	local fun = (function()
		i3k_sbean.sect_trade_routeReq()
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开龙穴任务界面
function i3k_logic:OpenDragonTaskUI()
	local fun = (function()
		i3k_sbean.dragon_hole_task_sync()
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开帮派共享任务界面
function i3k_logic:OpenFactionShareTaskUI()
	local fun1 = (function()
			local data = i3k_sbean.sect_share_task_sync_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_share_task_sync_res.getName())
		end)

	local fun = (function()
		local data = i3k_sbean.sect_task_sync_req.new()
		data.callBack = fun1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_sync_res.getName())
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开帮派单人副本
function i3k_logic:OpenFactionDungeonUI()
	local tmp_dungeon = {}
	for k, v in pairs(i3k_db_faction_dungeon) do
		table.insert(tmp_dungeon,v)
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.enterLevel < b.enterLevel
	end)
	local fun = function ()
		local data = i3k_sbean.sectmap_query_req.new()
		data.mapId = tmp_dungeon[1].id
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_query_res.getName())
	end

	local fun1 = function ()
		local data = i3k_sbean.sectmap_status_req.new()
		data.fun = fun
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_status_res.getName())
	end

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun1
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开单人副本扫荡界面
function i3k_logic:OpenDungeonWipe(mapID)
	g_i3k_ui_mgr:OpenUI(eUIID_WIPE)
	g_i3k_ui_mgr:RefreshUI(eUIID_WIPE, mapID)
end

--打开帮派运镖
function i3k_logic:OpenFactionEscortUI()
	local need_role_lvl = i3k_db_escort.escort_args.join_lvl
	local roleLvl = g_i3k_game_context:GetLevel()
	local need_faction_lvl = i3k_db_escort.escort_args.open_lvl
	if roleLvl >= need_role_lvl then
		local fun = (function()
			local now_level = g_i3k_game_context:GetFactionLevel()
			if now_level >= need_faction_lvl then
				i3k_sbean.sect_escort_data()
			else
				local tmp_str = i3k_get_string(541,need_faction_lvl)
				g_i3k_ui_mgr:PopupTipMessage(tmp_str)
				return
			end
		end)

		local data = i3k_sbean.sect_sync_req.new()
		data.callBack = fun
		i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
	else
		local tmp_str = i3k_get_string(542,need_role_lvl)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	end
end

--打开自创武功
function i3k_logic:OpenFactionCreateGongfuUI()
	local fun = (function()
		i3k_sbean.getDiySkillSync()
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

function i3k_logic:OpenFactionSkillUI()
	local fun = (function()
		local data = i3k_sbean.sect_aurasync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_aurasync_res.getName())
	end)

	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

function i3k_logic:OpenFactionUI()
	self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_Bangpai)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bangpai)
	end)
end

--如果要打开默认的 调用下面的OpenShiLian
function i3k_logic:OpenActivityUI()
	self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_Activity)
		g_i3k_ui_mgr:RefreshUI(eUIID_Activity)
	end)
end

function i3k_logic:OpenShiLianUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadDailyActivity")
end
function i3k_logic:OpenActivityToIDUI(id)
	self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_Activity)
		g_i3k_ui_mgr:RefreshUI(eUIID_Activity,id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadDailyActivity")
	end)
end

function i3k_logic:OpenTreasureUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_TREASURE_STATE)
end

function i3k_logic:OpenEpickActUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_EPIC_STATE)
end

-- 巨灵攻城UI入口
function i3k_logic:OpenSpiritBossUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_SPIRIT_MONSTER_STATE)
end

function i3k_logic:OpenRobberMonsterUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_ROBBER_STATE)
end

function i3k_logic:OpenWithTreasure()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "openWithTreasure")
end
function i3k_logic:OpenSwordsmanCircle()
	if g_i3k_game_context:GetLevel() < i3k_db_swordsman_circle_cfg.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(434, i3k_db_swordsman_circle_cfg.openLvl))
		return
	end
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_SWORDSMAM_CIRCLE)
end

function i3k_logic:OpenHostelUI()
	local needId = i3k_db_common.activity.transNeedItemId
	local itemCount = g_i3k_game_context:GetBagMiscellaneousCanUseCount(needId)
	local needName = g_i3k_db.i3k_db_get_common_item_name(needId)
	local cfg = i3k_db_common.npcHotelTeleport
	-- if itemCount < 1 then
	if not g_i3k_game_context:CheckCanTrans(needId, 1) then
		local tips = i3k_get_string(15185)
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		if g_i3k_game_context:IsTransNeedItem() then
			descText = i3k_get_string(15174)
			local function callback(isOk)
				if isOk then
					local hero = i3k_game_get_player_hero()
					g_i3k_game_context:ClearFindWayStatus()
					hero:StopMove(true);
					i3k_sbean.transToNpc(cfg.mapId, cfg.npcId)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
		else
			local hero = i3k_game_get_player_hero()
			g_i3k_game_context:ClearFindWayStatus()
			hero:StopMove(true);
			i3k_sbean.transToNpc(cfg.mapId, cfg.npcId)
		end
	end
end

function i3k_logic:OpenTournamentUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "openWithTournament")
	end)
end

function i3k_logic:OpenFiveUniqueUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "openWithFiveUnique")
end

function i3k_logic:OpenTowerUI(state,fun)
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "openWithFiveUniqueActivity",state,fun)
end

function i3k_logic:OpenFiveUniqueFameUI()
	local function func(groupId)
		i3k_sbean.sync_fame_tower(groupId)
	end
	self:OpenTowerUI(nil,func)
end

function i3k_logic:OpenForceWarUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "openWithForceWar")
	end)
end

function i3k_logic:OpenDemonHoleUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_DEMON_HOLE_STATE)
	end)
end

-- 打开决战荒漠
function i3k_logic:OpenDesertUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_BATTLE_DESERT)
	end)
end

-- 打开跨服pve入口
function i3k_logic:OpenGlobalPveUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_GLOBAL_PVE_STATE)
	end)
end

function i3k_logic:OpenSectFightUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_BANGPAIZHAN)
	end)
end

function i3k_logic:OpenFightTeamUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_FIGHT_TEAM_STATE)
	end)
end

function i3k_logic:OpenDefenceWarUI()
	if g_i3k_game_context:GetLevel() < i3k_db_defenceWar_cfg.playerLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5188))
	end

	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_DEFENCE_WAR_STATE)
	end)
end

function i3k_logic:OpenDriftBottleUI()
	g_i3k_ui_mgr:OpenUI(eUIID_DriftBottle)
	g_i3k_ui_mgr:RefreshUI(eUIID_DriftBottle)
end

function i3k_logic:OpneMazeBattleInfoUI()
	g_i3k_ui_mgr:OpenUI(eUIID_MazeBattleInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_MazeBattleInfo)
end
function i3k_logic:OpenDemonHoleSummaryUI()
	g_i3k_ui_mgr:OpenUI(eUIID_DemonHolesummary)
	g_i3k_ui_mgr:RefreshUI(eUIID_DemonHolesummary)
end


function i3k_logic:OpenWorldBossUI(levelClose)
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "openWithWorldBoss", levelClose)
end

function i3k_logic:OpenTreasurePage1UI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "openWithTreasurePage1")
end

function i3k_logic:OpenSteedUI()
	manageSteedUI(eUIID_Steed)
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_Steed)
		local steedId = g_i3k_game_context:getUseSteed()
		g_i3k_ui_mgr:RefreshUI(eUIID_Steed,steedId)
	end)
end

function i3k_logic:OpenSuitUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_SuitEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuitEquip)
	end)
end

function i3k_logic:OpenReviveUI(isThunder)
	self:OpenBattleUI(function()
		if g_i3k_game_context:GetSuperOnHookValid() then
			local revivetime = i3k_db_common.rolerevive.revivetime
			local serverTime = i3k_game_get_time()
			local lastrevive = g_i3k_game_context:GetReviveTickLine()
			if serverTime - lastrevive > revivetime then
				i3k_sbean.role_revive_other()
				return
			end
		end
		g_i3k_ui_mgr:OpenUI(eUIID_PlayerRevive)
		g_i3k_ui_mgr:RefreshUI(eUIID_PlayerRevive, isThunder)
	end)
end

function i3k_logic:OpenDefenceWarReviveUI()
	self:OpenBattleUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarReLife)
		g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarReLife)
	end)
end

--打开货币直购
function i3k_logic:OpenBuyBaseItemUI(id)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyBaseItem)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuyBaseItem, id)
end

--打开运镖求援界面
function i3k_logic:OpenEscortHelpTips()
	if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		return
	end
	local str = g_i3k_game_context:GetEscortForHelpStr()
	if #str ~= 0 and i3k_game_get_map_type() == g_FIELD then
		g_i3k_ui_mgr:OpenUI(eUIID_EscortHelpTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_EscortHelpTips)
	end
end

--打开运镖行为界面
function i3k_logic:OpenEscortAction()
	if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		return
	end
	local escort_taskId = g_i3k_game_context:GetFactionEscortTaskId()

	if escort_taskId ~= 0 and i3k_game_get_map_type() == g_FIELD then
		g_i3k_ui_mgr:OpenUI(eUIID_EscortAction)
		g_i3k_ui_mgr:RefreshUI(eUIID_EscortAction)
	end
end

--打开npc对话界面
function i3k_logic:OpenNpcDialogue(id,count, instanceID)
	g_i3k_ui_mgr:OpenUI(eUIID_NpcDialogue)
	g_i3k_ui_mgr:RefreshUI(eUIID_NpcDialogue,id,count, instanceID)
end

function i3k_logic:OpenDemonHoleDialogueUI(id)
	g_i3k_ui_mgr:OpenUI(eUIID_DemonHoleDialogue)
	g_i3k_ui_mgr:RefreshUI(eUIID_DemonHoleDialogue, id)
end

--打开游戏登录页面
function i3k_logic:OpenLoginUI()
	g_i3k_ui_mgr:OpenUI(eUIID_Login)
	g_i3k_ui_mgr:RefreshUI(eUIID_Login)
end

--打开实时语音
function i3k_logic:OpenOnlineVoice()
	--g_i3k_ui_mgr:OpenUI(eUIID_OnlineVoice)
	--g_i3k_ui_mgr:RefreshUI(eUIID_OnlineVoice)
end

--打开游戏公告页面
function i3k_logic:OpenGameNoticeUI()
	g_i3k_ui_mgr:OpenUI(eUIID_GameNotice)
	g_i3k_ui_mgr:RefreshUI(eUIID_GameNotice)
end

--打开游戏协议页面
function i3k_logic:OpenUserAgreementUI()
	g_i3k_ui_mgr:OpenUI(eUIID_UserAgreement)
	g_i3k_ui_mgr:RefreshUI(eUIID_UserAgreement)
end

function i3k_logic:OpenClanUI(callback)
	self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_ClanMain)
		g_i3k_ui_mgr:RefreshUI(eUIID_ClanMain)
		if callback then
			callback()
		end
	end)
end

--打开小地图
function i3k_logic:OpenMapUI(mapId)
	if not i3k_db_field_map[mapId] then
		error("mapID "..mapId.." cfg not found!")
	end
	local fun = (function ()
		g_i3k_ui_mgr:OpenUI(eUIID_SceneMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_SceneMap, mapId)
	end)

	i3k_sbean.req_big_map_flag_info(fun)

end

--打开伏魔洞小地图
function i3k_logic:OpenDemonHoleMap(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_DemonHoleMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_DemonHoleMap, mapId, cfg)
end

--伏魔洞，跨服PVE和平区 战区地图 小地图
function i3k_logic:OpenDungeonMap(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_DungeonMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_DungeonMap, mapId, cfg)
end

--打开决战荒漠小地图
function i3k_logic:OpenDroiyanDesertMap(mapId, cfg)
	--TODO
	g_i3k_ui_mgr:OpenUI(eUIID_DesertBattleMiniMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_DesertBattleMiniMap, mapId, cfg)
end

--打开帮派夺旗界面
function i3k_logic:OpenFactionGrabBanner()
	local fun = function()
		g_i3k_logic:OpenFactionFlagLog()
	end
	local data = i3k_sbean.sect_sync_req.new()
	data.callBack = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

--打开帮派地图旗帜占领信息
function i3k_logic:OpenFactionFlagLog()
	local fun = (function ()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionRobFlagLog)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionRobFlagLog)
		g_i3k_game_context:LeadCheck()
	end)

	i3k_sbean.req_big_map_flag_info(fun)
end

--进入帮派驻地
function i3k_logic:OnOpenFactionZone(needSync)
	local fun = function()
		g_i3k_game_context:onEnterFactionZone()
	end
	if needSync then
		local data = i3k_sbean.sect_sync_req.new()
		data.callBack = fun
		i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
	else
		fun()
	end
end

function i3k_logic:OpenBattleMiniMap()
	g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleMiniMap)
end

--打开绝技道具预览界面
function i3k_logic:OpeneUniqueskillPreviewUI(id)
	g_i3k_ui_mgr:OpenUI(eUIID_UniqueskillPreview)
	g_i3k_ui_mgr:RefreshUI(eUIID_UniqueskillPreview, id)
end

--打开师徒界面
function i3k_logic:OpenMasterUI()
	--self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_Master_shitu)
		g_i3k_ui_mgr:RefreshUI(eUIID_Master_shitu)
	--end)
end
--打开拜师界面
function i3k_logic:OpenBaishiUI()
	--self:OpenMainUI(function()
		g_i3k_ui_mgr:OpenUI(eUIID_Master_baishi)
		g_i3k_ui_mgr:RefreshUI(eUIID_Master_baishi)
	--end)
end

-- 打开血池使用页面
function i3k_logic:OpenBloodPoolUI()
	g_i3k_ui_mgr:OpenUI(eUIID_Blood_Pool)
	g_i3k_ui_mgr:RefreshUI(eUIID_Blood_Pool)
end


function i3k_logic:SelectNPCByID(id)
	local logic = i3k_game_get_logic();
	local world = logic:GetWorld()
	if world then
		local entity = world:GetNPCEntityByID(id)
		if entity then
			logic:SwitchSelectEntity(entity);
		end
	end
end

-- 势力声望设置npc头顶信息显隐
function i3k_logic:ChangePowerRepNpcTitleVisible(npcID, visible)
	local logic = i3k_game_get_logic()
	local world = logic:GetWorld()
	if world then
		world:SetNpcEntityTitleVisible(npcID, visible)
	end
end


-- 根据任务的接取情况，刷新npc头顶图片的显隐
function i3k_logic:SetPowerRepNpcTitleByInfo()
	local npcs = g_i3k_game_context:getPowerRepHideTitleNpcs()
	local logic = i3k_game_get_logic();
	local world = logic:GetWorld()
	if world then
		for _, v in ipairs(npcs) do
			world:SetNpcEntityTitleVisible(v.npcID, v.show)
		end
	end
end

function i3k_logic:PlaySceneEffect(effectID,Pos,guid)
	local ecfg = i3k_db_effects[effectID];
	if ecfg then
		local id = i3k_gen_attack_effect_guid()
		if guid then
			id = id..guid
		end
		self._effectID = g_i3k_actor_manager:CreateSceneNode(ecfg.path, "PlaySceneEffect_" .. effectID.."_"..id,true);
		if self._effectID ~= -1 then
			g_i3k_actor_manager:EnterScene(self._effectID);
			g_i3k_actor_manager:SetLocalTrans(self._effectID, Engine.SVector3(Pos.x, Pos.y, Pos.z));
			g_i3k_actor_manager:SetLocalScale(self._effectID, ecfg.radius);
			g_i3k_actor_manager:Play(self._effectID, 1);
		end
		return self._effectID
	end
end

function i3k_logic:OpenCommonStoreUI(gid)
	-- self:OpenBattleUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_CommmonStore)
		g_i3k_ui_mgr:RefreshUI(eUIID_CommmonStore,gid)
	-- end)
end
-- index3 页签 index1跳转到第几个物品列表index2物品列表的第几个物品 index3跳转到分解
function i3k_logic:OpenProductUI(index1,index2,index3,callback)  -- 工坊同步
	self:OpenMainUI(function()
		i3k_sbean.product_data_sync(index1,index2,index3)
		if callback then
			callback()
		end
	end)
end

-- 隐藏战斗相关的界面
function i3k_logic:ShowBattleUI(value)
	local str = value and "show" or "hide"
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDrug,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattlePets,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleOfflineExp,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleUnlockSkill,str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Yg, str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTreasure, str)
end

-- 钓鱼隐藏相关界面
function i3k_logic:ShowFishBattleUI(value)
	local str = value and "show" or "hide"
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateFishState", value)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDrug, str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap, str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFishPrompt, str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Yg, str)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomelandCustomer, str)
end

-- 首次登录打开宣传页，隐藏界面ui
function i3k_logic:OpenFirstLoginShow()
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:DigMineCancel()
		hero:ClearFindwayStatus()
	end
	g_i3k_game_context:SetAutoFight(false)
	g_i3k_logic:ShowBattleUI(false)

	g_i3k_ui_mgr:CloseGuideUI()
	g_i3k_ui_mgr:OpenUI(eUIID_FirstLoginShow)
end

--检测任务对话界面是否是打开的
function i3k_logic:isTalkUI()
	if g_i3k_ui_mgr:GetUI(eUIID_Dialogue1) then
		return true
	elseif g_i3k_ui_mgr:GetUI(eUIID_Dialogue3) then
		return true
	elseif g_i3k_ui_mgr:GetUI(eUIID_Dialogue4) then
		return true
	end
end

--打开购买离线精灵点页面
function i3k_logic:OpenBuyWizardPointUI()
	g_i3k_ui_mgr:OpenUI(eUIID_BuyWizardPoint)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuyWizardPoint)
end

-- 打开活动副本随从设置页面
function i3k_logic:OpenActivityPetsUI()
	g_i3k_ui_mgr:OpenUI(eUIID_ActivityPets)
	g_i3k_ui_mgr:RefreshUI(eUIID_ActivityPets)
end

--打开批量兑换界面
function i3k_logic:OpenExchangeMoreUI(tbl, type)
	g_i3k_ui_mgr:OpenUI(eUIID_ExchangeMore)

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ExchangeMore, "firstOpen", tbl, type)
end

--打开暗器界面
function i3k_logic:OpenHideWeaponUI()
	-- g_i3k_ui_mgr:PopupTipMessage("暂未开放暗器系统")
	local cfg = i3k_db_anqi_common
	local roleLevel = g_i3k_game_context:GetLevel()
	if cfg.openLevel > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage("暗器在".. cfg.openLevel.."级开启")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_HideWeapon)
	g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
end

---------------时间换算-------------
function i3k_logic:GetCurrentTimeStamp(time)
	local currentTimeStamp = g_i3k_get_GMTtime(time)
	return currentTimeStamp
end

function i3k_logic:GetCurrentDate(time)---------精确到秒
	local currentTimeStamp = g_i3k_get_GMTtime(time)
	local date=os.date("%Y-%m-%d %H:%M:%S", currentTimeStamp)
	return date
end

function i3k_logic:GetTime(time,chat)
	local currentTimeStamp = g_i3k_get_GMTtime(time)
	local day = tonumber(os.date("%d", currentTimeStamp))
	local timeStampNow = g_i3k_get_GMTtime(i3k_game_get_time())
	local today = tonumber(os.date("%d", timeStampNow))
	local date
	if today~=day then
		date = day.."日"..os.date("%H:%M:%S", currentTimeStamp)
	else
		if chat then
			date = os.date("%H:%M",currentTimeStamp)
		else
			date = os.date("%H:%M:%S", currentTimeStamp)
		end
	end
	return date
end

function i3k_logic:OpenDungeon()
	self:OpenDungeonUI(false, g_i3k_game_context:GetDungeonMapid())
end

function i3k_logic:OpenDungeonGroup()
	self:OpenDungeonUI(true)
end

function i3k_logic:OpenUniqueUI()
	local need_lvl = i3k_db_common.functionHide.HideUniqueSkillLabel
	local open_lvl = i3k_db_common.functionOpen.uniqueSkillOpenLvl
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()

	if g_i3k_game_context:GetLevel() >= need_lvl and g_i3k_game_context:GetLevel() < open_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(495))
	elseif g_i3k_game_context:GetLevel() >= open_lvl then
		if next(role_unique_skill) ~= nil then
			g_i3k_ui_mgr:OpenUI(eUIID_SkillLy)--red_point_3红点
			g_i3k_ui_mgr:RefreshUI(eUIID_SkillLy,true)
		else
			---当没有任何绝技时
			local desc = i3k_get_string(496,i3k_db_climbing_tower_args.openLvl)
			local callfunc = function (isOk)
				if isOk then
				---跳转到活动---爬塔标签
				local fun = (function(id)
						local callBack = function()
							g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
						end
						i3k_sbean.sync_fame_tower(id, nil, callBack)
				end)
				g_i3k_logic:OpenTowerUI(nil,fun)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
		end
	end
end

function i3k_logic:OpenPetAchieveUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_PetAchievement)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetAchievement)
	end)
end

function i3k_logic:OpenAuctionUI()
	self:OpenMainUI(function ()
		local openDay = i3k_game_get_server_open_day()
		local nowDay = g_i3k_get_day(i3k_game_get_time())
		local needLevel = i3k_db_common.aboutAuction.needLevel
		local hero = i3k_game_get_player_hero()
		if hero._lvl<needLevel then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(242, needLevel))
		--elseif nowDay-openDay<i3k_db_common.aboutAuction.coolDay then
			--local str = string.format("%s", "服务器开服3天内不允许进入寄售行")
			--g_i3k_ui_mgr:PopupTipMessage(str)
		else
			local callback = function (itemType)
				g_i3k_ui_mgr:RefreshUI(eUIID_Auction, itemType)
			end
			i3k_sbean.sync_auction(1, "", 1, 2, 0, 0, 0, callback)
		end
	end)
end

function i3k_logic:openRoleTitleUI(id)
	if i3k_game_get_map_type() == g_FIELD or i3k_game_get_map_type() == g_FACTION_GARRISON then
		g_i3k_ui_mgr:OpenUI(eUIID_ShowRoleTitleTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShowRoleTitleTips, id)
	end
end
-- 3D Touch 打开的页面
function i3k_logic:OpenShortCutUI()
	if i3k_get_is_use_short_cut() then
		if i3k_game_get_map_type() == g_FIELD then
			local shortCutType = i3k_get_short_cut_type()
			local roleLevel = g_i3k_game_context:GetLevel()
			if shortCutType == g_ShortCut_Fuli then
				self:OpenDynamicActivityUI()
			elseif shortCutType == g_ShortCut_Activity then
				if roleLevel >= i3k_db_common.schedule.openLvl then
					g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
					g_i3k_ui_mgr:RefreshUI(eUIID_Schedule)
				end
			elseif shortCutType == g_ShortCut_RankList then
				if roleLevel >= i3k_db_common.functionOpen.rankLiskOpenLvl then
					self:OpenRankListUI()
				end
			end
		end
		i3k_set_short_cut_type(0)
	end
end

-- 打开装备淬锋ui
function i3k_logic:openEquipSharpenUI()
	local roleLevel = g_i3k_game_context:GetLevel()
	local openLevel = i3k_db_common.equipSharpen.openLevel
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage("装备淬锋"..openLevel.."级开启")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_EquipSharpen)
	g_i3k_ui_mgr:RefreshUI(eUIID_EquipSharpen)
end

-- 打开坐骑皮肤界面
function i3k_logic:OpenSteedSkinUI(check)
	if check then
		if g_i3k_game_context:getUseSteed() ~= 0 then
			manageSteedUI(eUIID_SteedSkin)
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_SteedSkin)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkin)
	end)
			g_i3k_ui_mgr:CloseUI(eUIID_SteedFight)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
		end
	else
		manageSteedUI(eUIID_SteedSkin)
		self:OpenMainUI(function ()
			g_i3k_ui_mgr:OpenUI(eUIID_SteedSkin)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkin)
		end)
	end
end

function i3k_logic:openPetRaceUI()
	local openLevel = i3k_db_common.petRace.startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage("宠物赛跑"..openLevel.."级开启")
		return
	end

	local nowTime = i3k_game_get_time() % 86400
	local beginTime = i3k_db_common.petRace.beforeTime
	local endTime = i3k_db_common.petRace.endTime
	if beginTime > nowTime or nowTime > endTime then
		local hour = math.modf(beginTime/3600)
		local minute = math.modf(beginTime%3600/60)
		local endHour = math.modf(endTime/3600)
		local endMinute = math.modf(endTime%3600/60)
		g_i3k_ui_mgr:PopupTipMessage(string.format("宠物赛跑在每天%s:%s开启，%s:%s结束", hour, minute, endHour, endMinute))
		return
	end

	i3k_sbean.syncPetRace()
end

function i3k_logic:openPetRaceStore()
	local openLevel = i3k_db_common.petRace.startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage("宠物赛跑"..openLevel.."级开启")
		return
	end
	i3k_sbean.syncPetRaceShop()
end

--武魂
function i3k_logic:OpenMartialSoulUI()
	local isOpen = false
	self:OpenMainUI(function ()
		if g_i3k_game_context:GetLevel() >= i3k_db_martial_soul_cfg.openLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_MartialSoul)
			g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoul)
			isOpen = true
		else
			g_i3k_ui_mgr:PopupTipMessage(string.format("武魂系统%d级开启", i3k_db_martial_soul_cfg.openLvl))
		end
	end)
	return isOpen
end

-- 暂时弃用
-- function i3k_logic:openBattlePetRace()
-- 	local openLevel = i3k_db_common.petRace.startLevel
-- 	local roleLevel = g_i3k_game_context:GetLevel()
-- 	if roleLevel < openLevel then
-- 		g_i3k_ui_mgr:PopupTipMessage("宠物赛跑"..openLevel.."级开启")
-- 		return
-- 	end
-- 	g_i3k_ui_mgr:OpenUI(eUIID_BattlePetRace)
-- 	g_i3k_ui_mgr:RefreshUI(eUIID_BattlePetRace)
-- end

function i3k_logic:openQilingUI(id)
	local roleLevel = g_i3k_game_context:GetLevel()
	local reqLevel = i3k_db_qiling_cfg.openLevel
	local expect = i3k_db_qiling_cfg.weaponStar
	local info = g_i3k_game_context:getQilingData()
	if roleLevel < reqLevel then
		g_i3k_ui_mgr:PopupTipMessage("器灵"..reqLevel.."级开启")
		return
	end
	if not g_i3k_game_context:checkCanActiveQiling() then
		g_i3k_ui_mgr:PopupTipMessage("器灵开启需要神兵星级"..expect.."星")
		return
	end
	if not next(info) then
		i3k_sbean.activeQiling(id)
		return
	-- 如果服务器初始同步的和本地读表的数量不同，那么发送一次激活协议
	elseif #info ~= #i3k_db_qiling_type then
		i3k_sbean.activeQiling(id)
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Qiling)
	g_i3k_ui_mgr:RefreshUI(eUIID_Qiling, id)
end

function i3k_logic:openDiceUI()

	local diceActivityID = g_i3k_db.i3k_db_open_dice_activity_id()
	if not diceActivityID then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16405))
		return
	end

	local levelReq = i3k_db_dice_cfg[diceActivityID].startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < levelReq then
		local str = i3k_get_string(16389, levelReq)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end

	i3k_sbean.syncDice(diceActivityID) -- TODO
	-- g_i3k_ui_mgr:OpenUI(eUIID_Dice)
end

-- 打开帮派战报名/进行/结束 ui
function i3k_logic:OpenFactionFightStateUI()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local isOpen = false
	for _,t in ipairs(i3k_db_faction_fight_cfg.commonrule.openday) do
		if t == week then
			isOpen = true
			break
		end
	end
	local starttime = string.split(i3k_db_faction_fight_cfg.timebucket[1].applytime, ":")
	local opentime = os.time({year = year, month = month, day = day, hour = starttime[1], min = starttime[2], sec = starttime[3]})
	if timeStamp > opentime and isOpen then
		i3k_sbean.request_sect_fight_group_sync_req(function()
			i3k_sbean.sect_fight_group_cur_status(function (data)
				if data.status then
					if data.status.curStatus == 3 or data.status.curStatus == 4 or data.status.curStatus == 5 then
						g_i3k_ui_mgr:OpenUI(eUIID_FactionFightPushResult)
						g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPushResult, data)
						return
					end
				end
				g_i3k_ui_mgr:OpenUI(eUIID_FactionFightPush)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, data)
			end)
		end)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightPush)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, {status = {curStatus = 8}})
	end
end


function i3k_logic:OpenBidUI()
	local cfg = i3k_db_bid_cfg

	local startDate = cfg.startDate
	local endDate = cfg.endDate
	local time = i3k_game_get_time()
	if g_i3k_get_GMTtime(time) < startDate or g_i3k_get_GMTtime(time) > endDate then
		local startDateString = g_i3k_get_commonDateStr(startDate)
		local endDatteString = g_i3k_get_commonDateStr(endDate)
		local str = i3k_get_string(17284, startDateString, endDatteString)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end

	local nowTime = i3k_game_get_time() % 86400
	local beginTime = cfg.startTime
	local endTime = cfg.endTime
	if beginTime > nowTime or nowTime > endTime then
		local hour = math.modf(beginTime/3600)
		local minute = math.modf(beginTime%3600/60)
		local endHour = math.modf(endTime/3600)
		local endMinute = math.modf(endTime%3600/60)
		if minute < 10 then
			minute = "0"..minute
		end
		if endMinute < 10 then
			endMinute = "0"..endMinute
		end
		g_i3k_ui_mgr:PopupTipMessage(string.format("拍卖行在每天%s:%s开启，%s:%s结束", hour, minute, endHour, endMinute))
		return
	end

	local roleLevel = g_i3k_game_context:GetLevel()
	local vipLevel = g_i3k_game_context:GetVipLevel()
	if roleLevel < cfg.needLevel then
		g_i3k_ui_mgr:PopupTipMessage(cfg.needLevel.."级开启拍卖行")
		return
	end
	if vipLevel < cfg.needVipLevel then
		g_i3k_ui_mgr:PopupTipMessage("贵族"..cfg.needVipLevel.."级开启拍卖行")
		return
	end

	-- TODO 发协议
	i3k_sbean.syncBid()
end

-- 打开活动通用公告接口（）
function i3k_logic:checkAndOpenActivityShowUI()
	local list = g_i3k_db.i3k_db_get_activity_show_list()
	if #list > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ActivityShow)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityShow, "showActivity", false)
	end
end
-- 打开需要拍脸的通用公告ui
function i3k_logic:checkAndOpenActivityShowUI_dayLogin()
	local list = g_i3k_db.i3k_db_get_activity_show_list_dayLogin()
	if #list > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ActivityShow)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityShow, "showActivity", true)
	end
end

-- 打开示爱道具ui
function i3k_logic:openShowLoveItemUI(roleID)
	local needLevel = i3k_db_show_love_item.levelLimit
	local roleLevel = g_i3k_game_context:GetLevel()
	if needLevel > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage("示爱功能"..needLevel.."级开启")
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_UseShowLoveItem)
	g_i3k_ui_mgr:RefreshUI(eUIID_UseShowLoveItem, roleID)
end


-- 打开新春福袋界面
function i3k_logic:OpenLuckyPack()
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < i3k_db_lucky_pack_cfg.needLvl then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("新春福袋功能将于%s级开启", i3k_db_lucky_pack_cfg.needLvl))
	end
	i3k_sbean.new_year_pack_sync(function (info)
		g_i3k_ui_mgr:OpenUI(eUIID_LuckyPack)
		g_i3k_ui_mgr:RefreshUI(eUIID_LuckyPack, info)
	end)
end

--打开打地鼠界面
function i3k_logic:OpenHitDiglettUI(id)
	g_i3k_ui_mgr:CloseAllOpenedUI()
	g_i3k_ui_mgr:OpenUI(eUIID_HitDiglett)
	g_i3k_ui_mgr:RefreshUI(eUIID_HitDiglett, id)
end

function i3k_logic:OpenDivination()
	i3k_sbean.divination_state_sync()
end

-- 五转之路
function i3k_logic:OpenFiveTransUI()
	local levelReq = g_i3k_db.i3k_db_get_five_trans_level_requre()
	local roleLevel = g_i3k_game_context:GetLevel()
	if levelReq > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1377, levelReq))
		return
	end
	-- local transfromLvl = g_i3k_game_context:GetTransformLvl()
	-- if transfromLvl < 4 then
	-- 	g_i3k_ui_mgr:PopupTipMessage("请先转职到4转")
	-- 	return
	-- end

	g_i3k_ui_mgr:OpenUI(eUIID_fiveTrans)
	g_i3k_ui_mgr:RefreshUI(eUIID_fiveTrans)
end

-- 天命轮
function i3k_logic:OpenDestinyRollUI()

end

-- 家园种植界面
function i3k_logic:openPlantUI(typeid, groundIndex, groundLevel)
	g_i3k_ui_mgr:OpenUI(eUIID_HomelandPlant)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomelandPlant, typeid, groundIndex, groundLevel)
end

-- 土地升级界面
function i3k_logic:openHomelandStructureUI(groundId, closeUIID)
	if not g_i3k_game_context:hasHomeLand(true) then
		return
	end
	if closeUIID then
		g_i3k_ui_mgr:CloseUI(closeUIID)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandStructure)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandStructure)
	if groundId then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandStructure, "showPlantTitle", groundId)
	end
end

-- 土地操作界面（偷取，护理，浇水，收获)
function i3k_logic:openOperateUI(crop)
	g_i3k_ui_mgr:OpenUI(eUIID_HomelandPlantOperate)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomelandPlantOperate, crop)
end

-- 踢出家园
function i3k_logic:kickOut(roleId, callback)
	if roleId then
		g_i3k_ui_mgr:ShowMessageBox2("是否将该玩家请离家园？", function(flag)
			if flag then
				i3k_sbean.homeland_kick_role(roleId)
			end
			if callback then
				callback()
			end
		end)
	end
end

-- 打开家园访客UI
function i3k_logic:OpenHomelandCustomersUI()
	--[[if g_i3k_game_context:isInMyHomeLand() then
		if not g_i3k_ui_mgr:GetUI(eUIID_HomelandCustomer) then
			g_i3k_ui_mgr:OpenUI(eUIID_HomelandCustomer)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_HomelandCustomer)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_HomelandCustomer)
	end--]]
	if not g_i3k_ui_mgr:GetUI(eUIID_HomelandCustomer) then
		g_i3k_ui_mgr:OpenUI(eUIID_HomelandCustomer)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_HomelandCustomer)
end

function i3k_logic:sendMultiSweepMessage(selectTable, record)
	i3k_sbean.activity_instance_sweep_sync(selectTable, record)
end

-- 打开家园事件ui
function i3k_logic:OpenHomeLandEventUI(closeUIID)
	i3k_sbean.homeland_history_sync(closeUIID)
end

-- 家园装备ui
function i3k_logic:OpenHomeLandEquipUI(fishType)
	i3k_sbean.homeland_equip_sync(fishType)
end

-- 家园钓鱼
function i3k_logic:OpenHomeLandFishUI()
	g_i3k_logic:ShowFishBattleUI(false)
	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandFish)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandFish)
end

-- 打开房屋升级界面
function i3k_logic:OpenHomeLandHouseUI()
	self:OpenMainUI(function ()
		local callback = function ()
			g_i3k_ui_mgr:OpenUI(eUIID_HomeLandStructure)
			g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandStructure)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandStructure, "jumpToHouse")
		end
		i3k_sbean.homeland_sync(false, callback)
	end)
end

-- 打开伙伴系ui
function i3k_logic:OpenPartnerUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_partner_info()
	end)
end

-- 打开势力声望ui
function i3k_logic:OpenReputationUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_PowerReputation)
		g_i3k_ui_mgr:RefreshUI(eUIID_PowerReputation, 1)
	end)
end

-- eUIID_MoodDiaryEffect		= 962 -- 特效
-- eUIID_MoodDiaryEffectGift 	= 963 -- 特效
-- eUIID_MoodDiaryEffectRocket = 964 -- 特效
-- 心情日记特效
function i3k_logic:OpenMoodDiaryEffect(euiid, msg)
	g_i3k_ui_mgr:OpenUI(euiid)
	g_i3k_ui_mgr:RefreshUI(euiid, msg)
end

--打开图钉scoll界面
function i3k_logic:OpenThumbtackScollUI(mapID, mapSize)
	g_i3k_ui_mgr:OpenUI(eUIID_ThumbtackScollUI)
	g_i3k_ui_mgr:RefreshUI(eUIID_ThumbtackScollUI, mapID, mapSize)
end

--打开添加图钉界面
function i3k_logic:OpenThumbtackDetailUI(index, mapID)
	g_i3k_ui_mgr:OpenUI(eUIID_ThumbtackDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_ThumbtackDetail, index, mapID)
end

--打开删除图钉界面
function i3k_logic:OpenThumbtackDeleteUI(curItem)
	g_i3k_ui_mgr:OpenUI(eUIID_ThumbtackDelete)
	g_i3k_ui_mgr:RefreshUI(eUIID_ThumbtackDelete, curItem)
end

--打开图钉传送界面
function i3k_logic:OpenThumbtackTransferUI(index, mapID, freeFlag)
	if freeFlag then
		g_i3k_ui_mgr:OpenUI(eUIID_ThumbtackTransferVip)
		g_i3k_ui_mgr:RefreshUI(eUIID_ThumbtackTransferVip, index, mapID)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ThumbtackTransferNol)
		g_i3k_ui_mgr:RefreshUI(eUIID_ThumbtackTransferNol, index, mapID)
	end
end

--打开心决界面
function i3k_logic:OpenXinJueUI()
	if g_i3k_game_context:getXinjueGrade() > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_XinJue)
		g_i3k_ui_mgr:RefreshUI(eUIID_XinJue)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_XinJueKq)
	end
end

--关闭任务指引界面
function i3k_logic:CloseTaskGuideUI()
	if g_i3k_ui_mgr and g_i3k_ui_mgr:GetUI(eUIID_TaskGuide) then
		g_i3k_ui_mgr:CloseUI(eUIID_TaskGuide)
	end
end

--打开VIP礼包折扣界面
function i3k_logic:OpenVipGiftDistountTips()
	g_i3k_ui_mgr:OpenUI(eUIID_VipGiftDisTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_VipGiftDisTips)
end

function i3k_logic:OpenFamilyDonateUI()
	i3k_sbean.sect_family_donate()
end

-- 打开城战报名ui
function i3k_logic:OpenDefenceWarSignInUI(citySign)
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarSignIn)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarSignIn, citySign)
end

-- 打开城战 奖励
function i3k_logic:OpenDefenceWarRewardUI(kings)
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarReward)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarReward, kings)
end

-- 打开城战 竞标
function i3k_logic:OpenDefenceWarBidUI()
	
	i3k_sbean.syncDefenceWarBid()
end

-- 打开城战小地图
function i3k_logic:OpenDefenceWarMap(mapID)
	-- g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarMap)
	-- g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarMap, mapID)
	i3k_sbean.citywar_entities_info_query(mapID)
end

-- 打开城战传送小地图
function i3k_logic:OpenDefenceWarTrans(npcID)
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarTrans)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarTrans, npcID)
end

-- 夺城竞标结果公示
function i3k_logic:OpenDefenceWarBidResultUI()
	i3k_sbean.syncDefenceWarBidResult()
end

-- 城战成员查询UI
function i3k_logic:OpenDefenceWarMemberUI(roles)
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarMember)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarMember, roles)
end

--打开家园放生界面
function i3k_logic:OpenHomeLandReleaseUI()
	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandRelease)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandRelease)
end

--打开家园放生排行榜
function i3k_logic:OpenHomelandReleaseRankListUI()
	self:OpenMainUI(function ()
		i3k_sbean.sync_rankList_info(g_RANKLIST_HOMELAND_RELEASE)
	end)
end

--打开神兵觉醒界面
function i3k_logic:OpenShenBingAwakeUI(weaponID)
	local roleLvl = g_i3k_game_context:GetLevel()
	if g_i3k_db.i3k_db_get_weapon_awake_is_open(weaponID, roleLvl) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, 'RefreshAwakeUI', weaponID)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("神兵觉醒于%s级开启", i3k_db_shen_bing_others.awakeOpenLvl))
	end
end

--打开家园挂载UI
function i3k_logic:OpenHomelandAdditionUI(index, furnitureId)
	g_i3k_ui_mgr:OpenUI(eUIID_HomelandAddition)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomelandAddition, index, furnitureId)
end

--打开宠物驯养装备UI
--isFirst == true 默认打开野外出战宠物所在组 isFight == true 屏蔽部分功能
function i3k_logic:OpenPetEquipUI(UIID, isFirst, isFight)
	if not g_i3k_game_context:GetPetEquipHeroLvlIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1552, i3k_db_pet_equips_cfg.openLvl))
		return
	end
	if not g_i3k_game_context:GetPetEquipPetCntIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1553, i3k_db_pet_equips_cfg.needPetCnt, i3k_db_pet_equips_cfg.needPetLvl))
		return
	end
	if isFirst then
		local group = g_i3k_db.i3k_db_get_cur_field_pet_group()
		g_i3k_game_context:SetPetEquipGroup(group)
	end

	if isFight then
		local petID = g_i3k_game_context:getPetDungeonID()
		if petID then
			local group = i3k_db_mercenaries[petID].petGroup
			g_i3k_game_context:SetPetEquipGroup(group)
		end
	end
	g_i3k_ui_mgr:CloseUI(UIID)
	g_i3k_ui_mgr:OpenUI(eUIID_PetEquip)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetEquip, isFirst, isFight)
end

--打开宠物驯养装备升级UI
function i3k_logic:OpenPetEquipUpLevelUI(UIID)
	if not g_i3k_game_context:GetPetEquipHeroLvlIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1552, i3k_db_pet_equips_cfg.openLvl))
		return
	end
	if not g_i3k_game_context:GetPetEquipPetCntIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1553, i3k_db_pet_equips_cfg.needPetCnt, i3k_db_pet_equips_cfg.needPetLvl))
		return
	end
	local curGroup = g_i3k_game_context:GetPetEquipGroup()
	local equip = g_i3k_game_context:GetPetEquipsData(curGroup)

	if not next(equip) then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s未穿戴任何装备", i3k_db_pet_equips_group[curGroup]))
		return
	end

	g_i3k_ui_mgr:CloseUI(UIID)
	g_i3k_ui_mgr:OpenUI(eUIID_PetEquipUpLevel)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipUpLevel)
end

--打开宠物驯养试炼技能升级UI
function i3k_logic:OpenPetEquipUpSkillLevelUI(UIID)
	if not g_i3k_game_context:GetPetEquipHeroLvlIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1552, i3k_db_pet_equips_cfg.openLvl))
		return
	end
	if not g_i3k_game_context:GetPetEquipPetCntIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1553, i3k_db_pet_equips_cfg.needPetCnt, i3k_db_pet_equips_cfg.needPetLvl))
		return
	end
	g_i3k_ui_mgr:CloseUI(UIID)
	g_i3k_ui_mgr:OpenUI(eUIID_PetEquipSkillUpLvl)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipSkillUpLvl)
end

--打开守护灵兽UI
function i3k_logic:OpenPetGuardUI(UIID)
	if not g_i3k_game_context:GetPetEquipHeroLvlIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1552, i3k_db_pet_equips_cfg.openLvl))
		return
	end
	if not g_i3k_game_context:GetPetEquipPetCntIsEnough() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1553, i3k_db_pet_equips_cfg.needPetCnt, i3k_db_pet_equips_cfg.needPetLvl))
		return
	end
	if g_i3k_game_context:GetLevel() >= i3k_db_pet_guard_base_cfg.openLvl then
		if g_i3k_game_context:getPetWakeCount() >= i3k_db_pet_guard_base_cfg.openNeedAwakePetCount then
			g_i3k_ui_mgr:CloseUI(UIID)
			g_i3k_ui_mgr:OpenUI(eUIID_PetGuard)
			g_i3k_ui_mgr:RefreshUI(eUIID_PetGuard)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17956, i3k_db_pet_guard_base_cfg.openNeedAwakePetCount))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17957, i3k_db_pet_guard_base_cfg.openLvl))
	end
end
--打开宠物试炼选择地图UI
function i3k_logic:OpenPetDungeonChoseMapUI()
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonChoseMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonChoseMap)
end

--打开宠物试炼选择宠物UI
function i3k_logic:OpenPetDungeonChosePetUI(info)
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonChosePet)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonChosePet, info)
end

--打开宠物试炼小地图UI
function i3k_logic:OpenPetDungeonMiniMapUI(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonrMiniMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonrMiniMap, mapId, cfg)
end

--打开宠物试炼采集UI
function i3k_logic:OpenPetDungeonGatherOperationUI(cfg, isGoto)
	g_i3k_ui_mgr:OpenUI(eUIID_PetGahterOperation)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetGahterOperation, cfg, isGoto)
end

--打开宠物试炼采集读条UI
function i3k_logic:OpenPetDungeonReadingBarUI(cfg, info)
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonReadingbar)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonReadingbar, cfg, info)
end

--打开试炼界面调转到宠物试炼界面
function i3k_logic:OpenPetDungeonActivityUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_PET_ACTIVITY_STATE)
end

--根据有无代币是否打开重要通知UI
function i3k_logic:OpenImportantNotice(warehouseType)
	local _, bag = g_i3k_game_context:GetWarehouseInfoForType(warehouseType)
	for k,v in pairs(bag) do
		if g_i3k_db.i3k_db_get_bag_item_stack_max(v.id) == 0 then
			return g_i3k_logic:OpenImportantNoticeUI(warehouseType)
	    end
	end
end

--打开重要通知UI
function i3k_logic:OpenImportantNoticeUI(warehouseType, daibis)
	if #daibis > 0 then
	g_i3k_ui_mgr:OpenUI(eUIID_ImportantNotice)
		g_i3k_ui_mgr:RefreshUI(eUIID_ImportantNotice, warehouseType, daibis)
	end
end

--打开决战荒漠观战UI
function i3k_logic:OpenDesertBattleWatchWarUI(name)
	g_i3k_ui_mgr:OpenUI(eUIID_DesertBattleWatchWar)
	g_i3k_ui_mgr:RefreshUI(eUIID_DesertBattleWatchWar, name)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateDesertBattleWatchWar")
	g_i3k_game_context:SetAutoFight(false)
	g_i3k_logic:ShowBattleUI(false)
	local hero = i3k_game_get_player_hero()
	if hero then
		g_i3k_game_context:setdesertBattleViewEntity(hero)
		hero:Show(false, true)
		hero:RmvAiComp(eAType_MOVE)
	end
end

function i3k_logic:OpenWujueUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_wujue.openLevel then
		if not g_i3k_game_context:isWujueOpen() then
			g_i3k_ui_mgr:OpenUI(eUIID_WuJueKQ)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
			g_i3k_ui_mgr:CloseUI(eUIID_XinFa)
			g_i3k_ui_mgr:CloseUI(eUIID_Meridian)

			g_i3k_ui_mgr:OpenUI(eUIID_Wujue)
			g_i3k_ui_mgr:RefreshUI(eUIID_Wujue)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17691, i3k_db_wujue.openLevel))
	end
end

function i3k_logic:OpenSwornUI()
	if g_i3k_game_context:getSwornFriends() then
		local callback = function(data, roleData)
			g_i3k_game_context:forwardSync(data, roleData)
			g_i3k_logic:OpenSwornModifyUI(data, roleData)
		end
		i3k_sbean.sworn_sync(callback)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SwornIntroduce)
		g_i3k_ui_mgr:RefreshUI(eUIID_SwornIntroduce)
	end
end

function i3k_logic:OpenSwornModifyUI(data, roleData)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornModify)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwornModify, data, roleData)
end

function i3k_logic:ShowSuccessAnimation(successType)
	if type(successType) == "string" then
		local map = {
			["break"] = 1,
			["upRank"] = 2,
			["active"] = 3,
		}
		successType = map[successType]
	end
	g_i3k_ui_mgr:OpenUI(eUIID_WujueDH)
	g_i3k_ui_mgr:RefreshUI(eUIID_WujueDH, successType)
end
--日程表到天魔迷宫界面调转
function i3k_logic:OpenMazeBattleActivityUI()
	self:OpenMainUI(function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "changeStateImpl", g_MAZE_BATTLE_STATE)
	end)
end
-- 马术精通
function i3k_logic:OpenSteedFightUI()
	manageSteedUI(eUIID_SteedFight)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedFight)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedFight, STEED_MASTER_STATE)
end
-- 良驹之灵
function i3k_logic:OpenSteedSpriteUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.spiritOpenLvl then
		if manageSteedUI(eUIID_SteedSprite) then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedSprite)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedSprite)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1279, i3k_db_steed_fight_base.spiritOpenLvl))
	end
end
-- 骑战装备
function i3k_logic:OpenSteedEquipUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_equip_cfg.openLevel then
		if manageSteedUI(eUIID_SteedEquip) then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedEquip)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedEquip)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1644, i3k_db_steed_equip_cfg.openLevel))
	end
end
-- 骑战套装
function i3k_logic:OpenSteedSuitUI(suitID)
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_equip_cfg.openLevel then
		if manageSteedUI(eUIID_SteedSuit) then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedSuit)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedSuit, suitID)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1645, i3k_db_steed_equip_cfg.openLevel))
	end
end
-- 熔炉
function i3k_logic:OpenSteedStoveUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_equip_cfg.openLevel then
		if manageSteedUI(eUIID_SteedStove) then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedStove)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedStove)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1646, i3k_db_steed_equip_cfg.openLevel))
	end
end
--八卦合成拆分
function i3k_logic:OpenBaGuaCheck()
	g_i3k_ui_mgr:OpenUI(eUIID_BaGuaSacrificeCheck)
	g_i3k_ui_mgr:RefreshUI(eUIID_BaGuaSacrificeCheck)
end
function i3k_logic:OpenBaGuaSplit(id)
	g_i3k_ui_mgr:OpenUI(eUIID_BaGuaSacrificeSplit)
	g_i3k_ui_mgr:RefreshUI(eUIID_BaGuaSacrificeSplit, id)
end
function i3k_logic:OpenCardPacketUI(oldState)
	g_i3k_ui_mgr:OpenUI(eUIID_CardPacket)
	g_i3k_ui_mgr:RefreshUI(eUIID_CardPacket, oldState)
end
function i3k_logic:OpenCardPacketPushUnlockUI(cardID)
	g_i3k_ui_mgr:OpenUI(eUIID_CardPacketChatInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketChatInfo, cardID, g_i3k_game_context:getCurCardBack()) -- 0 默认卡背
end
-- 打开图鉴分享卡牌界面
function i3k_logic:OpenCardPacketShare(cardID, cardBackID)
	g_i3k_ui_mgr:OpenUI(eUIID_CardPacketChatInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketChatInfo, cardID, cardBackID)
end
function i3k_logic:OpenUnlockCardPacketUI()
	g_i3k_logic:OpenMainUI()
	g_i3k_logic:OpenCardPacketUI()
end
function i3k_logic:OpenBaGuaCompound()
	g_i3k_ui_mgr:OpenUI(eUIID_BaGuaSacrificeCompound)
	g_i3k_ui_mgr:RefreshUI(eUIID_BaGuaSacrificeCompound)
end
function i3k_logic:OpenUpMarryStage()
	--姻缘等级
	local marryLvl = g_i3k_game_context:GetMarryLevel()
	if marryLvl < i3k_db_common.needMarryLevel then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17892, i3k_db_common.needMarryLevel))
	end
	--当前是否有队伍
	if g_i3k_game_context:GetTeamId() == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17893))
	end
	--是否是队长
	if not g_i3k_game_context:getLeaderToHandle() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17894))
	end
	--队伍人数是否足够
	local wife = g_i3k_game_context:GetTeamMembers()
	if #wife ~= 1 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17895))
	end
	--是不是夫妻
	if #wife == 1 and not g_i3k_game_context:checkIsLover(wife[1]) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17895))
	end
	--判断升级次数
	local marryType = g_i3k_game_context:getMarryType()
	if marryType > 1 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17896))
	end
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	--OpenUI
	g_i3k_ui_mgr:OpenUI(eUIID_MarryUpStage)
	g_i3k_ui_mgr:RefreshUI(eUIID_MarryUpStage)
end
function i3k_logic:OpenRoleFlyingFind(areaId)
	local flyId = g_i3k_game_context:isFindFlyingPos(areaId)
	if flyId then
		g_i3k_game_context:addFindFlyingPos(areaId)
		i3k_sbean.soaring_position_open(flyId, areaId)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_RoleFlyingFind)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoleFlyingFind, areaId)
end
function i3k_logic:OpenPrincessMarry()
	g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryBattle)
	g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryBattle)
end
--公主出嫁小地图
function i3k_logic:OpenPrincessMarryMiniMap(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryMap, mapId, cfg)
end
--日程表到公主出嫁界面调转
function i3k_logic:OpenPrincessMarryActivityUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_PRINCESS_MARRY_STATE)
end
--公主出嫁结果
function i3k_logic:OpenPrincessMarryResult(info)
	g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryResult, info)
end
function i3k_logic:OpenFlyingFootUI()
	if g_i3k_game_context:isFinishFlyingTask(1) then
		g_i3k_ui_mgr:OpenUI(eUIID_Bag)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bag)
		i3k_sbean.footeffect_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage("先完成飞升")
	end
end
--打开背包默认显示飞升页签
function i3k_logic:OpenBagFlyingUI()
	if g_i3k_game_context:isFinishFlyingTask(1) then
		g_i3k_ui_mgr:OpenUI(eUIID_Bag)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bag)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "setEquipBtnType", eEquipFeisheng)
	else
		g_i3k_ui_mgr:PopupTipMessage("先完成飞升")
	end
end
function i3k_logic:OpenAthleticsShopUI()
	local data = i3k_sbean.arena_shopsync_req.new()
	i3k_game_send_str_cmd(data, i3k_sbean.arena_shopsync_res.getName())
end
function i3k_logic:OpenArenaShopUI()
	local hero = i3k_game_get_player_hero()
	if hero._lvl >= i3k_db_tournament_base.needLvl then
		i3k_sbean.sync_team_arena_store()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, i3k_db_tournament_base.needLvl))
	end
end
function i3k_logic:OpenMasterShopUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_master_cfg.cfg.apptc_min_lvl then
		i3k_sbean.master_send_store_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, i3k_db_master_cfg.cfg.apptc_min_lvl))
	end
end

function i3k_logic:OpenPetRaceShopUI()
	local openLevel = i3k_db_common.petRace.startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= openLevel then
		i3k_sbean.syncPetRaceShop()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, openLevel))
	end
end

function i3k_logic:OpenBulimShopUI()
	local openLevel = i3k_db_server_limit.breakSealCfg.limitLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= openLevel then
		local data = i3k_sbean.fame_shopsync_req.new()
		i3k_game_send_str_cmd(data, i3k_sbean.fame_shopsync_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, openLevel))
	end
end

function i3k_logic:OpenGroupShopUI()
	if g_i3k_game_context:GetSectId() ~= -1 then
		local data = i3k_sbean.sect_shopsync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_shopsync_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(680))
	end
end

function i3k_logic:OpenBountyShopUI()
	local factionID = g_i3k_game_context:GetFactionSectId()
	if factionID and factionID ~= 0 then
		local openLevel = i3k_db_escort.escort_args.open_lvl
		local now_level = g_i3k_game_context:getSectFactionLevel()
		if g_i3k_game_context:GetLevel() >= i3k_db_escort.escort_args.join_lvl and now_level >= need_faction_lvl then
			i3k_sbean.sect_escort_store_sync()
			g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, need_faction_lvl))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(680))
	end
end
function i3k_logic:OpenGemSaleConfirmUI(id, count)
	g_i3k_ui_mgr:OpenUI(eUIID_GemSaleConfirm)
	g_i3k_ui_mgr:RefreshUI(eUIID_GemSaleConfirm, id, count)
end
function i3k_logic:OpenGemExchangeUI()
	g_i3k_ui_mgr:OpenUI(eUIID_GemExchangeShow)
	g_i3k_ui_mgr:RefreshUI(eUIID_GemExchangeShow)
end

--天枢
function i3k_logic:OpenShenDouUI(close_uiid)
	local godStarLvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	if godStarLvl > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ShenDou)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenDou)
		if close_uiid then
			g_i3k_ui_mgr:CloseUI(close_uiid)
		end
		return
	end
	local roleLvl = g_i3k_game_context:GetLevel()
	if roleLvl >= i3k_db_martial_soul_cfg.shenDouOpenLvl then
		local curStar = g_i3k_game_context:GetCurStar()
		if curStar and curStar / 100 >= i3k_db_martial_soul_cfg.needEquipStarGear then
			g_i3k_ui_mgr:OpenUI(eUIID_ShenDou)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenDou)
			if close_uiid then
				g_i3k_ui_mgr:CloseUI(close_uiid)
			end
		else
			g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1717), i3k_get_string(1718), i3k_get_string(1716), function(bValue)
				if not bValue then
					if close_uiid then
						g_i3k_ui_mgr:CloseUI(close_uiid)
					end
					g_i3k_ui_mgr:OpenUI(eUIID_StarDish)
					g_i3k_ui_mgr:RefreshUI(eUIID_StarDish)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "onAllBtn")
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "updateSelectedCatalog", nil, i3k_db_martial_soul_cfg.needEquipStarGear)
				end
			end)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1715, i3k_db_martial_soul_cfg.shenDouOpenLvl))
	end
end

--神机藏海
function i3k_logic:OpenMagicMachineUI()
	g_i3k_ui_mgr:OpenUI(eUIID_MagicMachineBattle)
	g_i3k_ui_mgr:RefreshUI(eUIID_MagicMachineBattle)
end

function i3k_logic:OpenMagicMachineResultUI(info)
	g_i3k_ui_mgr:OpenUI(eUIID_MagicMachineResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_MagicMachineResult, info)
end

--神机藏海小地图
function i3k_logic:OpenMagicMachineMiniMap(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_MagicMachineMiniMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_MagicMachineMiniMap, mapId, cfg)
end

--神机藏海活动UI
function i3k_logic:OpenMagicMachineActivityUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_MAGIC_MACHINE_STATE)
end
--日程表到万寿阁界面调转
function i3k_logic:OpenLongevityPavilionActivityUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_LONGEVITY_PAVILION_STATE)
end
--打开万寿阁传送
function i3k_logic:OpenLongevityPavilionDeliveryUI()
	g_i3k_ui_mgr:OpenUI(eUIID_LongevityPavilionDelivery)
	g_i3k_ui_mgr:RefreshUI(eUIID_LongevityPavilionDelivery)
end
--打开万寿阁副本ui
function i3k_logic:OpenLongevityPavilionUI()
	g_i3k_ui_mgr:OpenUI(eUIID_LongevityPavilionBattle)
	g_i3k_ui_mgr:RefreshUI(eUIID_LongevityPavilionBattle)
end
--打开万寿阁结算ui
function i3k_logic:OpenLongevityPavilionResultUI(info)
	g_i3k_ui_mgr:OpenUI(eUIID_LongevityPavilionResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_LongevityPavilionResult, info)
end

function i3k_logic:OpenActivityWorldBossUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_WORLD_BOSS_STATE)
end
function i3k_logic:OpenActivityPrincessMarryUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_PRINCESS_MARRY_STATE)
end
function i3k_logic:OpenActivityTowerUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_TOWER_STATE)
end
function i3k_logic:OpenActivityTreasureUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_TREASURE_STATE)
end
function i3k_logic:OpenActivityPetActivityUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_PET_ACTIVITY_STATE)
end
function i3k_logic:OpenActivityEPICUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_EPIC_STATE)
end
function i3k_logic:OpenActivityRobberUI()
	self:OpenActivityUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_ROBBER_STATE)
end
function i3k_logic:OpenSchedule1UI()
	if g_i3k_game_context:GetLevel() >= i3k_db_common.schedule.openLvl then
		local first = 1
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule, first)
	end
end
function i3k_logic:OpenSchedule2UI()
	if g_i3k_game_context:GetLevel() >= i3k_db_common.schedule.openLvl then
		local second = 2
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule, second)
	end
end
function i3k_logic:OpenSchedule3UI()
	if g_i3k_game_context:GetLevel() >= i3k_db_common.schedule.openLvl then
		local third = 3
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule, third)
	end
end
function i3k_logic:OpenSchedule4UI()
	if g_i3k_game_context:GetLevel() >= i3k_db_common.schedule.openLvl then
		local forth = 4
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule, forth)
	end
end
function i3k_logic:OpenPetEquipUIWithParam(close_uiid)
	g_i3k_logic:OpenPetEquipUI(close_uiid, true, false)
end

function i3k_logic:OpenGroupMainUI()
	local data = i3k_sbean.sect_sync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end
function i3k_logic:OpenCityWarExpUI()
	g_i3k_ui_mgr:OpenUI(eUIID_CityWarExp)
	g_i3k_ui_mgr:RefreshUI(eUIID_CityWarExp)
end
function i3k_logic:OpenChallengeSubmitItems(groupId, index)
	g_i3k_ui_mgr:OpenUI(eUIID_ChallengeSubmitItems)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChallengeSubmitItems, groupId, index)
end
--坐骑自动洗练界面
function i3k_logic:OpenAutoRefhineUI(cancel)
	g_i3k_ui_mgr:OpenUI(eUIID_AutoDo)
	g_i3k_ui_mgr:RefreshUI(eUIID_AutoDo, cancel)
end
--坐骑自动洗练设置
function i3k_logic:OpenAutoRefhineSetUI(steedId, sortRefineCfg)
	g_i3k_ui_mgr:OpenUI(eUIID_AutoRefineSet)
	g_i3k_ui_mgr:RefreshUI(eUIID_AutoRefineSet, steedId, sortRefineCfg)
end
--坐骑自动洗练设置预览
function i3k_logic:OpenAutoRefhineSetPreviewUI(sortRefineCfg, previewCfg)
	g_i3k_ui_mgr:OpenUI(eUIID_AutoRefineSetPreview)
	g_i3k_ui_mgr:RefreshUI(eUIID_AutoRefineSetPreview, sortRefineCfg, previewCfg)
end
function i3k_logic:OpenFiveElementsUI()
	g_i3k_ui_mgr:OpenUI(eUIID_FiveElements)
	g_i3k_ui_mgr:RefreshUI(eUIID_FiveElements)
end
--打开合照成功
function i3k_logic:OpenTaskPhotoEnd()
	g_i3k_ui_mgr:OpenUI(eUIID_FactionPhotoEnd)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionPhotoEnd)
end
--技能更换动画界面
function i3k_logic:OpenSkillSetCartoon()
	g_i3k_ui_mgr:OpenUI(eUIID_SkillSetCartoon)
	g_i3k_ui_mgr:RefreshUI(eUIID_SkillSetCartoon)
end
--江湖侠探
function i3k_logic:OpenKnightlyDetectiveUI()
	if g_i3k_game_context:GetLevel() < i3k_db_knightly_detective_common.limitLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(434, i3k_db_knightly_detective_common.limitLevel))
	elseif g_i3k_game_context:isKnightlyDetectiveOpen() then
		local spyData = g_i3k_game_context:getKnightlyDetectiveData()
		if spyData and spyData.lastRefreshDay == g_i3k_get_day(i3k_game_get_time()) then
			g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveMember)
			g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveMember)
		else
			i3k_sbean.spy_open()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18253))
	end
end
--野外支线任务npc
function i3k_logic:OpenFieldSublineTaskUI(npcId)
	g_i3k_ui_mgr:OpenUI(eUIID_FieldSublineTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_FieldSublineTask, npcId)
end
function i3k_logic:OpenSteedStarUI(steedId)
	local info = g_i3k_game_context:getSteedInfoBySteedId(steedId)
	if info then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedStar)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedStar, info)
	end
end
function i3k_logic:OpenFlyingSharpen()
	local level_limit = 6
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	if g_i3k_game_context:isFinishFlyingTask(1) then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeiSheng)
	end
	if flyingLevel >= level_limit then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipSharpen)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1809))
	end
end
function i3k_logic:OpenFlyingTrans()
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeiSheng)
	local level_limit = 6
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	if flyingLevel < level_limit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1809))
	else
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipTrans)
	end
end
function i3k_logic:OpenFlyingStrengthenUI()
	local level_limit = 3
	if g_i3k_game_context:isFinishFlyingTask(level_limit) then
		self:OpenEquipStarUpUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18336))
	end
end
function i3k_logic:OpenFlyingGradeUI()
	local level_limit = 2
	if g_i3k_game_context:isFinishFlyingTask(level_limit) then
		self:OpenStrengEquipUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18335))
	end
end
function i3k_logic:OpenFlyingDiamondUI()
	local level_limit = 4
	if g_i3k_game_context:isFinishFlyingTask(level_limit) then
		self:OpenEquipGemInlayUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18337))
	end
end
function i3k_logic:OpenReceiveFriendInviteUI(friendId, playerName)
	g_i3k_ui_mgr:OpenUI(eUIID_FriendsInviteAnswer)
	g_i3k_ui_mgr:RefreshUI(eUIID_FriendsInviteAnswer, friendId, playerName)
end
function i3k_logic:OpenGoldCoastUI()
	g_i3k_ui_mgr:OpenUI(eUIID_GoldCoastPKMode)
	g_i3k_ui_mgr:RefreshUI(eUIID_GoldCoastPKMode)
end
-- 进入战区地图黄金海岸
function i3k_logic:OpenEnterWarZone()
	g_i3k_ui_mgr:OpenUI(eUIID_EnterWarZone)
	g_i3k_ui_mgr:RefreshUI(eUIID_EnterWarZone)
end
-- 未到战区地图黄金海岸开放时间 则打开宣传图 否则打开 进入ui 卡片ui等
function i3k_logic:OpenWarZoneUI(func)
	local cfg = i3k_db_war_zone_map_cfg
	local GMTtime = g_i3k_get_GMTtime(i3k_game_get_time())
	if GMTtime < cfg.activityOpenTime or GMTtime > cfg.activityEndTime then
		-- TODO 打开宣传UI
		g_i3k_ui_mgr:PopupTipMessage("活动未开放")
		return
	end
	if func then
		func()
	end
end
-- 切换分线进度条
function i3k_logic:OpenWorldLineProcessBarUI(func, line)
	g_i3k_ui_mgr:OpenUI(eUIID_WorldLineProcessBar)
	g_i3k_ui_mgr:RefreshUI(eUIID_WorldLineProcessBar, func, line)
end
function i3k_logic:OpenArrayStonePrayUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_array_stone_common.openLvl then
		self:OpenMainUI(function()
			g_i3k_ui_mgr:OpenUI(eUIID_ArrayStone)
			g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStone)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "onAddPrayExpBtn")
		end)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18400, i3k_db_array_stone_common.openLvl))
	end
end
function i3k_logic:OpenArrayStoneUI()
	if g_i3k_game_context:GetLevel() >= i3k_db_array_stone_common.openLvl then
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStone)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStone)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18400, i3k_db_array_stone_common.openLvl))
	end
end
function i3k_logic:OpenWarZoneCard(state, id)
	--self:OpenMainUI(function()
	g_i3k_ui_mgr:OpenUI(eUIID_WarZoneCard)
	g_i3k_ui_mgr:RefreshUI(eUIID_WarZoneCard, state, id)
	--end)
end
function i3k_logic:OpenWarZoneCardGetShow(id)
	g_i3k_ui_mgr:OpenUI(eUIID_WarZoneCardGetShow)
	g_i3k_ui_mgr:RefreshUI(eUIID_WarZoneCardGetShow, id)
end
function i3k_logic:OpenSpyStoryUI()
	self:OpenBattleUI(function()
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpyStory)
	end)
end
--鬼岛驭灵小地图
function i3k_logic:OpenCatchSpiritMiniMap(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritMap, mapId, cfg)
	local info = g_i3k_game_context:getGhostSkillInfo()
	if info.skillFlag == 2 then
		local point = g_i3k_game_context:getCatchSpiritPoint()
		local pointCD = g_i3k_game_context:getCatchSpiritPointCD()
		local curTime = i3k_game_get_time()
		local data = {}
		for k, _ in pairs(point) do
			if (not pointCD[k]) or (pointCD[k] and curTime - pointCD[k] >= i3k_db_catch_spirit_base.dungeon.callCold) then
				data[k] = {}
				data[k].x = i3k_db_catch_spirit_position[k].pos[1] * 100
				data[k].y = i3k_db_catch_spirit_position[k].pos[2] * 100
				data[k].z = i3k_db_catch_spirit_position[k].pos[3] * 100
			end
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritMap, "updateTeammatePos", data, i3k_db_catch_spirit_base.dungeon.modelMapIcon)
	end
	local boss = {}
	local bossPoint = g_i3k_game_context:getCatchSpiritBoss()
	if next(bossPoint) then
		for k, v in pairs(bossPoint) do
			boss[k] = {}
			boss[k].x = i3k_db_catch_spirit_position[k].pos[1] * 100
			boss[k].y = i3k_db_catch_spirit_position[k].pos[2] * 100
			boss[k].z = i3k_db_catch_spirit_position[k].pos[3] * 100
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritMap, "updateSpiritBossPos", boss, i3k_db_catch_spirit_base.dungeon.bossMapIcon)
end
function i3k_logic:OpenBiographyCareerMiniMap(mapId, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_BiographyCareerMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_BiographyCareerMap, mapId, cfg)
end
function i3k_logic:OpenActivityVipBuyTimesUI(id)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local maxBuyTimes = i3k_db_kungfu_vip[vipLvl].buyActTimes
	local dayBuyTimes = g_i3k_game_context:getActDayBuyTimes(id)
	local maxCount = 0
	for i,v in ipairs(i3k_db_common.activity.buyTimesNeedDiamond) do
		maxCount = v
	end
	local needDiamond = i3k_db_common.activity.buyTimesNeedDiamond[dayBuyTimes+1] or maxCount
	local isMaxLvl = true
	local nextLvl = 0
	local nextTimes = 0
	for i,v in ipairs(i3k_db_kungfu_vip) do
		if v.level>vipLvl and v.buyActTimes>maxBuyTimes then
			isMaxLvl = false
			nextTimes = v.buyActTimes
			nextLvl = v.level
			break
		end
	end
	if dayBuyTimes==maxBuyTimes then
		local dungeonName = i3k_db_activity[id].name
		if isMaxLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(268, dungeonName))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(269, nextLvl, dungeonName, nextTimes - maxBuyTimes))
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_BuyDungeonTimes)
		g_i3k_ui_mgr:RefreshUI(eUIID_BuyDungeonTimes, {mapId = id, vipLevel = vipLvl, buyTimes = maxBuyTimes, mapType = 2})
	end
end
------------------------------------------------

local UIIDTab = {
	i3k_logic.OpenDynamicActivityUI,	--1
	i3k_logic.OpenDailyActivityUI,		--2
	i3k_logic.OpenRankListUI,			--3（排行榜）
	i3k_logic.OpenForceWarRankListUI,	--4
	i3k_logic.OpenPetUI,				--5(随从)
	i3k_logic.OpenMyFriendsUI,			--6（好友）
	i3k_logic.OpenBagUI,				--7（背包）
	i3k_logic.OpenRoleTitleUI,			--8（称号）
	i3k_logic.OpenSignInUI,				--9（签到）
	i3k_logic.OpenOfflineExpUI,			--10
	i3k_logic.OpenRoleLyUI,				--11（属性）
	i3k_logic.OpenFashionDressUI,		--12  todoYDL (披风)
	i3k_logic.OpenSkillLyUI,			--13    todoYDL(技能)
	i3k_logic.OpenShenBingUI,			--14（神兵）
	i3k_logic.OpenAnswerQuestionsUI,	--15（答题）
	i3k_logic.OpenEquipStarUpUI,		--16（升星）
	i3k_logic.OpenEquipGemInlayUI,		--17（镶嵌）
	i3k_logic.OpenFactionUI,			--18（帮派）
	i3k_logic.OpenShiLianUI,			--19 日常试炼
	i3k_logic.OpenTreasureUI,			--20
	i3k_logic.OpenHostelUI,				--21
	i3k_logic.OpenTournamentUI,			--22
	i3k_logic.OpenFiveUniqueUI,			--23
	i3k_logic.OpenSteedUI,				--24(坐骑)
	i3k_logic.OpenSuitUI,				--25
	i3k_logic.OpenReviveUI,				--26
	i3k_logic.OpenEscortHelpTips,		--27
	i3k_logic.OpenEscortAction,			--28
	i3k_logic.OpenStrengEquipUI, 		--29(强化)
	i3k_logic.OpenXinfaUI, 				--30(心法)
	i3k_logic.OpenChatUI,				--31(聊天)
	i3k_logic.OpenDungeon,				--32(副本)
	i3k_logic.OpenFactionProduction,	--33(生产)
	i3k_logic.OpenEmpowermentUI, 		--34(历练)
	i3k_logic.OpenLongyinUI, 			--35(龙印)

	i3k_logic.OpenFactionTaskUI, 			--36(帮派任务)
	i3k_logic.OpenFactionSkillUI, 			--37(帮派技能)
	i3k_logic.OpenDungeonGroup,				--38(组队副本)
	i3k_logic.OpenFactionCreateGongfuUI, --39(帮派技能)
	i3k_logic.OpenFiveUniqueFameUI,			--40(五绝声望)
	i3k_logic.OpenUniqueUI,							--41(武功绝技)
	i3k_logic.OpenPetAchieveUI,         --42(随从成就)
	i3k_logic.openWeaponTaskUI,         --43(神兵任务)
	i3k_logic.OpenAuctionUI, 						--44(寄售行)
	i3k_logic.OpenRoleTitleUIByRoleLy,	--45（从角色界面进称号）
	i3k_logic.OpenFactionProdunctionRefine,	--46打开精炼
	i3k_logic.OpenWizardUI,				--47（打开挂机精灵界面）
	i3k_logic.OpenMyUI,			--48打开好友界面
	i3k_logic.OpenFlyingFootUI,	--49打开飞升脚印界面
	i3k_logic.OpenAthleticsShopUI,-- 50打开竞技商城
	i3k_logic.OpenArenaShopUI, --51打开会武商城
	i3k_logic.OpenMasterShopUI, --52打开师徒商城
	i3k_logic.OpenPetRaceShopUI, --53打开龟龟商城
	i3k_logic.OpenBulimShopUI, --54打开武林商城
	i3k_logic.OpenGroupShopUI, --55打开帮派商城
	i3k_logic.OpenBountyShopUI, --56打开赏金商城
	i3k_logic.OpenMagicMachineActivityUI, --57打开神机藏海活动UI
	i3k_logic.OpenUnderWearUpdate, -- 58 内甲升级
	i3k_logic.OpenUnderWearUpStage, -- 59 内甲升阶
	i3k_logic.OpenUnderWearTalent, -- 60 内甲天赋
	i3k_logic.OpenUnderWearRune, -- 61 内甲符文
	i3k_logic.OpenMeridian, -- 62 经脉
	i3k_logic.OpenWujueUI, -- 63 武诀
	i3k_logic.OpenShenBingAwakeUI, -- 64 神兵觉醒
	i3k_logic.OpenHideWeaponUI, -- 65 暗器
	i3k_logic.OpenBagua, -- 66 八卦
	i3k_logic.OpenPetEquipUI, -- 67 驯养：宠物装备
	i3k_logic.OpenPetEquipUpLevelUI, -- 68 驯养：装备升级
	i3k_logic.OpenPetEquipUpSkillLevelUI, -- 69 驯养：试炼技能
	i3k_logic.OpenMartialSoulUI, -- 70 武魂
	i3k_logic.OpenSteedFight1, -- 71 坐骑骑战
	i3k_logic.OpenSteedFight2, -- 72 良驹之灵
	i3k_logic.OpenArenaUI, -- 73 单人竞技场
	i3k_logic.OpenTaoistUI, -- 74 正邪道场
	i3k_logic.OpenPetGuardUI, -- 75 驯养：守护灵兽
	i3k_logic.OpenShiLianUI, -- 76 重复了
	i3k_logic.OpenActivityWorldBossUI, -- 77 魔王降临
	i3k_logic.OpenSpiritBossUI, -- 78 巨灵攻城
	i3k_logic.OpenActivityPrincessMarryUI, -- 79 漠海争花
	i3k_logic.OpenActivityTowerUI, -- 80 五绝试炼
	i3k_logic.OpenActivityTreasureUI, -- 81 江湖探宝
	i3k_logic.OpenActivityPetActivityUI, -- 82 宠物试炼
	i3k_logic.OpenActivityEPICUI, -- 83 武道侠魂
	i3k_logic.OpenActivityRobberUI, -- 84 江洋大盗
	i3k_logic.OpenTaskUI, -- 85 主线任务
	i3k_logic.OpenTaskUI, -- 86 支线任务
	i3k_logic.OpenSchedule1UI, -- 87 活动推荐
	i3k_logic.OpenSchedule2UI, -- 88 活动限时
	i3k_logic.OpenSchedule3UI, -- 89 活动日常
	i3k_logic.OpenSchedule4UI, -- 90 活动周常
	i3k_logic.OpenTeamArenaUI, -- 91 会武场
	i3k_logic.OpenForceWarUI, -- 92 正邪势力战
	i3k_logic.OpenDemonHoleUI, -- 93
	i3k_logic.OpenDesertUI, -- 94 决战荒漠
	i3k_logic.OpenGlobalPveUI, -- 95 神地幽冥境
	i3k_logic.OpenSectFightUI, -- 96 帮派战
	i3k_logic.OpenFightTeamUI, -- 97 武道会
	i3k_logic.OpenMazeBattleActivityUI, -- 98 天魔迷宫
	i3k_logic.OpenDefenceWarUI, -- 99 城战
	i3k_logic.OpenFactionDungeonUI, -- 100 帮派单人副本
	i3k_logic.OpenFactionEscortUI, -- 101 帮派运镖
	i3k_logic.OpenEquipTemperUI, -- 102 装备锤炼
	i3k_logic.OpenUnderWearUI, -- 103 内甲
	i3k_logic.OpenPetEquipUIWithParam, -- 104宠物装备
	i3k_logic.OpenGroupMainUI, -- 105 帮派主页
	i3k_logic.OpenSkillSetCartoon, -- 106 技能切换动画界面
	i3k_logic.OpenFlyingSharpen, -- 107 飞升淬锋
	i3k_logic.OpenFlyingTrans, -- 108 飞升精锻
	i3k_logic.OpenFlyingStrengthenUI, -- 109 飞升——强化
	i3k_logic.OpenFlyingGradeUI, -- 110 飞升——升级
	i3k_logic.OpenFlyingDiamondUI, -- 111 飞升——宝石
	i3k_logic.OpenArrayStonePrayUI, -- 112 真言升级
	i3k_logic.OpenArrayStoneUI, -- 113 阵法石
}

function i3k_logic:JumpUIID(uiid)
	local funUI = UIIDTab[uiid]
	if funUI then
		funUI(self)
	end
end

local TIMER = require("i3k_timer");
i3k_game_timer = i3k_class("i3k_game_timer", TIMER.i3k_timer);
function i3k_game_timer:Do(args)
	local hero = i3k_game_get_player_hero();
	if not hero then
		return
	end

	local blood = hero._hp
	if blood == 0 then
		return
	end

	local time = i3k_game_get_time()
	g_i3k_game_context:TryRefreshVit(time)

end

function i3k_game_timer:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer.new(1000));
	end
end



local test = i3k_game_timer:onTest()
function i3k_logic:OpenHotelDetailUI(npcID)
	g_i3k_ui_mgr:OpenUI(eUIID_NPCHotelDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_NPCHotelDetail, npcID)
end
function i3k_logic:openKniefShootingUI(id)
	local isOpen = g_i3k_db.i3k_db_get_findMooncake_is_open_by_id(id)
	if not isOpen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16405))
	elseif g_i3k_game_context:GetLevel() < i3k_db_findMooncake[id].openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3205, i3k_db_findMooncake[id].openLevel))
	elseif g_i3k_game_context:checkBagCanAddCell(2, true) then
		i3k_sbean.findMooncake_start(id)
	end
end
function i3k_logic:OpenPetActivityTipUI()
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonTip)
end

-- 新节日任务特殊NPC显示状态
function i3k_logic:ChangeNpcPlayAction(npcID, actionName)
	local logic = i3k_game_get_logic()
	local world = logic:GetWorld()
	if world then
		world:SetNpcEntityPlayAction(npcID, actionName)
	end
end
