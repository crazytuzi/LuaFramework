require("game/scene/scene_logic/base_scene_logic")
require("game/scene/scene_logic/common_scene_logic")
require("game/scene/scene_logic/base_fb_logic")
require("game/scene/scene_logic/common_act_logic")
require("game/scene/scene_logic/crossserver_scene_logic")
require("game/scene/scene_logic/phase_fb_logic")
require("game/scene/scene_logic/exp_fb_logic")
require("game/scene/scene_logic/story_fb_logic")
require("game/scene/scene_logic/tower_fb_logic")
require("game/scene/scene_logic/vip_fb_logic")
require("game/scene/scene_logic/hunyan_fb_logic")
require("game/scene/scene_logic/qingyuan_fb_logic")
require("game/scene/scene_logic/kf_onevone_scene_logic")
require("game/scene/scene_logic/kf_xiuluo_tower_scene_logic")
require("game/scene/scene_logic/sky_money_fb_logic")
require("game/scene/scene_logic/guild_battle_scene_logic")
require("game/scene/scene_logic/clash_territory_scene_logic")
require("game/scene/scene_logic/element_scene_logic")
require("game/scene/scene_logic/tomb_explore_fb_logic")
require("game/scene/scene_logic/kf_hot_spring_scene_logic")
require("game/scene/scene_logic/city_combat_scene_logic")
require("game/scene/scene_logic/team_equip_fb_logic")
require("game/scene/scene_logic/guild_station_logic")
require("game/scene/scene_logic/cross_boss_scene_logic")
require("game/scene/scene_logic/zhongkui_scene_logic")
require("game/scene/scene_logic/guild_mijing_scene_logic")
require("game/scene/scene_logic/cross_crystal_scene_logic")
require("game/scene/scene_logic/base_guide_fb_logic")
require("game/scene/scene_logic/wing_story_fb_logic")
require("game/scene/scene_logic/mount_story_fb_logic")
require("game/scene/scene_logic/xiannv_story_fb_logic")
require("game/scene/scene_logic/fun_guide_fb_logic")
require("game/scene/scene_logic/rune_tower_fb_logic")
require("game/scene/scene_logic/dafuhao_scene_logic")
require("game/scene/scene_logic/daily_task_fb_scene_logic")
require("game/scene/scene_logic/xing_zuo_yi_ji_scene_logic")
require("game/scene/scene_logic/kf_mining_scene_logic")
require("game/scene/scene_logic/fishing_scene_logic")
require("game/scene/scene_logic/push_fb_logic")
require("game/scene/scene_logic/mining_scene_logic")
require("game/scene/scene_logic/tower_defend_fb_scene_logic")
require("game/scene/scene_logic/kf_guild_battle_scene_logic")
require("game/scene/scene_logic/monster_siege_logic")
require("game/scene/scene_logic/dimai_fb_scene_logic")
require("game/scene/scene_logic/shengdi_fb_logic")
require("game/scene/scene_logic/junxian_fb_scene_logic")
require("game/scene/scene_logic/royal_tomb_fb_scene_logic")
require("game/scene/scene_logic/lianfu_activity_scene_logic")
require("game/scene/scene_logic/cross_server_supremacy_scence_logic")
require("game/scene/scene_logic/team_tower_fb")
require("game/scene/scene_logic/team_equip_fb_logic")
require("game/scene/scene_logic/team_special_fb_logic")

SceneLogic = SceneLogic or {}

function SceneLogic.Create(scene_type, scene_id)
	local scene_logic = nil
	-- 根据场景类型创建场景逻辑
	if SceneType.Common == scene_type then
		scene_logic = CommonSceneLogic.New()
	elseif SceneType.CampGaojiDuobao == scene_type then
		scene_logic = BaseFbLogic.New()
	elseif SceneType.PhaseFb == scene_type then
		scene_logic = PhaseFbLogic.New()
	elseif SceneType.ExpFb == scene_type then
		scene_logic = ExpFbLogic.New()
	elseif SceneType.StoryFB == scene_type then
		scene_logic = StoryFbLogic.New()
	elseif SceneType.PataFB == scene_type then
		scene_logic = TowerFbLogic.New()
	elseif SceneType.VipFB == scene_type then
		scene_logic = VipFbLogic.New()
	elseif SceneType.HunYanFb == scene_type then
		scene_logic = HunYanFbLogic.New()
	elseif SceneType.QingYuanFB == scene_type then
		scene_logic = QingYuanFbLogic.New()
	elseif SceneType.ShengDiFB == scene_type then
		scene_logic = ShengDiFbLogic.New()
	elseif SceneType.Kf_OneVOne == scene_type then
		scene_logic = KfOneVOneSceneLogic.New()
	elseif SceneType.Kf_XiuLuoTower == scene_type then
		scene_logic = KFXiuLuoTowerSceneLogic.New()
	elseif SceneType.TombExplore == scene_type then
		scene_logic = TombExploreFBLogic.New()
	elseif SceneType.TianJiangCaiBao == scene_type then
		scene_logic = SkyMoneySceneLogic.New()
	elseif SceneType.LingyuFb == scene_type then
		scene_logic = GuildBattleSceneLogic.New()
	elseif SceneType.HotSpring == scene_type then
		scene_logic = KfHotSpringSceneLogic.New()
	elseif SceneType.GongChengZhan == scene_type then
		scene_logic = CityCombatFBLogic.New()
	elseif SceneType.TeamEquipFb == scene_type then
		scene_logic = TeamEquipFBLogic.New()
	elseif SceneType.GuildStation == scene_type then
		scene_logic = GuildStationLogic.New()
	elseif SceneType.ClashTerritory == scene_type then
		scene_logic = ClashTerritoryLogic.New()
	elseif SceneType.QunXianLuanDou == scene_type then
		scene_logic = ElementSceneLogic.New()
	elseif SceneType.CrossBoss == scene_type then
		scene_logic = CrossBossSceneLogic.New()
	elseif SceneType.ZhongKui == scene_type then
		scene_logic = ZhongKuiSceneLogic.New()
	elseif SceneType.GuildMiJingFB == scene_type then
		scene_logic = GuildMiJingSceneLogic.New()
	elseif SceneType.ShuiJing == scene_type then
		scene_logic = CrossCrystalSceneLogic.New()
	elseif SceneType.WingStoryFb == scene_type then
		scene_logic = WingStorySceneLogic.New()
	elseif SceneType.MountStoryFb == scene_type then
		scene_logic = MountStoryFbLogic.New()
	elseif SceneType.XianNvStoryFb == scene_type then
		scene_logic = XianNvStoryFbLogic.New()
	elseif SceneType.GuideFb == scene_type then
		scene_logic = FunGuideFbLogic.New()
	elseif SceneType.RuneTower == scene_type then
		scene_logic = RuneTowerFbLogic.New()
	elseif SceneType.DaFuHao == scene_type then
		scene_logic = DafuhaoSceneLogic.New()
	elseif SceneType.DailyTaskFb == scene_type then
		scene_logic = DailyTaskFbSceneLogic.New()
	elseif SceneType.XingZuoYiJi == scene_type then
		scene_logic = XingZuoYiJiSceneLogic.New()
	elseif SceneType.KfMining == scene_type then
		scene_logic = KFMiningSceneLogic.New()
	elseif SceneType.Fishing == scene_type then
		scene_logic = FishingSceneLogic.New()
	elseif SceneType.PushFuBen == scene_type then
		scene_logic = PushFbLogic.New()
	elseif SceneType.Mining == scene_type then
		scene_logic = MiningSceneLogic.New()
	elseif SceneType.CrossGuildBattle == scene_type then
		scene_logic = KfGuildBattleSceneLogic.New()
	elseif SceneType.TowerDefend == scene_type then
		--个人塔防
		scene_logic = TowerDefendFbSceneLogic.New()
	elseif SceneType.MonsterSiegeFb == scene_type then
		scene_logic = MonsterSiegeFbLogic.New()
	elseif SceneType.DiMaiFb == scene_type then
		scene_logic = DiMaiFbSceneLogic.New()
	elseif SceneType.JunXian == scene_type then
		scene_logic = JunXianFbSceneLogic.New()
	elseif SceneType.RoyalTombFB == scene_type then
		scene_logic = RoyalTombFbSceneLogic.New()
	elseif SceneType.XianYangJuDian == scene_type then
		scene_logic = LianFuActivitySceneLogic.New()
	elseif SceneType.XianYangCheng == scene_type then
		scene_logic = LianFuActivitySceneLogic.New()
	elseif SceneType.CrossServerSupremacy == scene_type then
		scene_logic = CrossServerSupremacySceneLogic.New()
	elseif SceneType.BabyBoss == scene_type then
		scene_logic = CommonSceneLogic.New()
	elseif SceneType.ManyTowerFB == scene_type then
		scene_logic = TeamTowerSceneLogic.New()
	elseif SceneType.TeamSpecialFb == scene_type then
		scene_logic = TeamSpecialFbLogic.New()
	else
		scene_logic = BaseSceneLogic.New()
	end
	if scene_logic ~= nil then
		scene_logic:SetSceneType(scene_type)
	end

	return scene_logic
end
