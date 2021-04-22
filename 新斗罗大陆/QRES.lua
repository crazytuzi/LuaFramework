--[[
	res 资源表
	支持填写key value模式
	value可以为数组或者一个字符串值
	
	function QSpriteFrameByPath 通过path获取spriteFrame，这里会自动加载plist获取出spriteFrame
	function QCheckFileIsExist 检查文件是否存在，这里会检查全路径
	function QCheckPlistFile 检查plist文件以及文件内部的切图是否存在
	function QCheckPath 检查所有res表中的文件是否存在
	function QRes 对路径做一个标记，sublime中的插件会检查所有QRes(<path>)中的路径是否存在，详见checkimport.py
	function QResPath 根据一个key进获取res表中的值

]]

--标记路径
function QRes(path)
	return path
end

local res = {}

-- 主界面icon
res.menu_icon = {}
res.menu_icon.icon_bg_daytime = "ui/Activity_game/activity_icon/main_menu_icon_bg_daytime.png" -- icon背景，常規、默認、白天
res.menu_icon.icon_bg_evening = "ui/Activity_game/activity_icon/main_menu_icon_bg_evening.png" -- icon背景，晚上

--QUIWidgetItemBox中使用
res.rect_frame = {
		"ui/common/Hero_Equipmentbox_normal_green.png",
		"ui/common/Hero_Equipmentbox_normal_green2.png",
		"ui/common/Hero_Equipmentbox_normal_blue.png",
		"ui/common/Hero_Equipmentbox_normal_blue2.png",
		"ui/common/Hero_Equipmentbox_normal_blue3.png",
		"ui/common/Hero_Equipmentbox_normal_blue4.png",
		"ui/common/Hero_Equipmentbox_normal_blue5.png",
		"ui/common/Hero_Equipmentbox_normal_purple.png",
		"ui/common/Hero_Equipmentbox_normal_purple2.png",
		"ui/common/Hero_Equipmentbox_normal_purple3.png",
		"ui/common/Hero_Equipmentbox_normal_purple4.png",
		"ui/common/Hero_Equipmentbox_normal_purple5.png",
		"ui/common4/Hero_Equipmentbox_normal_orange.png",
		"ui/common4/Hero_Equipmentbox_normal_orange2.png",
		"ui/common4/Hero_Equipmentbox_normal_orange3.png",
		"ui/common4/Hero_Equipmentbox_normal_orange4.png",
		"ui/common4/Hero_Equipmentbox_normal_orange5.png",
		"ui/common5/Hero_Equipmentbox_normal_hong.png",
		"ui/common5/Hero_Equipmentbox_normal_hong2.png",
		"ui/common5/Hero_Equipmentbox_normal_hong3.png",
		"ui/common5/Hero_Equipmentbox_normal_hong4.png",
		"ui/common5/Hero_Equipmentbox_normal_hong5.png",
		"ui/common6/Hero_Equipmentbox_normal_yellow.png",
		"ui/common6/Hero_Equipmentbox_normal_yellow2.png",
		"ui/common6/Hero_Equipmentbox_normal_yellow3.png",
		"ui/common6/Hero_Equipmentbox_normal_yellow4.png",
		"ui/common6/Hero_Equipmentbox_normal_yellow5.png",
		"ui/common6/Hero_Equipmentbox_normal_yellow6.png"
	}
res.head_rect_frame = {
		"ui/common2/Hero_HeadBox_big_green.png",
		"ui/common2/Hero_HeadBox_big_green2.png",
		"ui/common2/Hero_HeadBox_big_blue.png",
		"ui/common2/Hero_HeadBox_big_blue2.png",
		"ui/common2/Hero_HeadBox_big_blue3.png",
		"ui/common2/Hero_HeadBox_big_blue4.png",
		"ui/common2/Hero_HeadBox_big_blue5.png",
		"ui/common2/Hero_HeadBox_big_purple.png",
		"ui/common2/Hero_HeadBox_big_purple2.png",
		"ui/common2/Hero_HeadBox_big_purple3.png",
		"ui/common2/Hero_HeadBox_big_purple4.png",
		"ui/common2/Hero_HeadBox_big_purple5.png",
		"ui/common4/Hero_HeadBox_big_orange.png",
		"ui/common4/Hero_HeadBox_big_orange2.png",
		"ui/common4/Hero_HeadBox_big_orange3.png",
		"ui/common4/Hero_HeadBox_big_orange4.png",
		"ui/common4/Hero_HeadBox_big_orange5.png",
		"ui/common5/Hero_HeadBox_big_hong.png",
		"ui/common5/Hero_HeadBox_big_hong2.png",
		"ui/common5/Hero_HeadBox_big_hong3.png",
		"ui/common5/Hero_HeadBox_big_hong4.png",
		"ui/common5/Hero_HeadBox_big_hong5.png",
		"ui/common6/Hero_HeadBox_big_yellow.png",
		"ui/common6/Hero_HeadBox_big_yellow2.png",
		"ui/common6/Hero_HeadBox_big_yellow3.png",
		"ui/common6/Hero_HeadBox_big_yellow4.png",
		"ui/common6/Hero_HeadBox_big_yellow5.png",
		"ui/common6/Hero_HeadBox_big_yellow6.png"
	}
res.color_frame_default = {"ui/common/Hero_Equipmentbox_normal.png", "ui/common/Hero_EquipmentBox_pieces.png", "ui/common5/baoshi_normal.png"}
res.color_frame_white = {"ui/common/Hero_Equipmentbox_normal.png", "ui/common/Hero_EquipmentBox_pieces.png", "ui/common5/baoshi_normal.png"}
res.color_frame_green = {"ui/common/Hero_Equipmentbox_normal_green.png", "ui/common2/Hero_EquipmentBox_pieces_green.png", "ui/common5/baoshi_green.png"}
res.color_frame_blue = {"ui/common/Hero_Equipmentbox_normal_blue.png", "ui/common2/Hero_EquipmentBox_pieces_blue.png", "ui/common5/baoshi_blue.png"}
res.color_frame_purple = {"ui/common/Hero_Equipmentbox_normal_purple.png", "ui/common2/Hero_EquipmentBox_pieces_purple.png", "ui/common5/baoshi_purple.png"}
res.color_frame_orange = {"ui/common4/Hero_Equipmentbox_normal_orange.png", "ui/common4/Hero_EquipmentBox_pieces_orange.png", "ui/common5/baoshi_orange.png"}
res.color_frame_red = {"ui/common5/Hero_Equipmentbox_normal_hong.png", "ui/common5/Hero_EquipmentBox_pieces_hong.png", "ui/common5/baoshi_red.png"}
res.color_frame_yellow = {"ui/common6/Hero_Equipmentbox_normal_yellow.png", "ui/common6/Hero_EquipmentBox_pieces_yellow.png", "ui/common6/baoshi_yellow.png"}
res.color_frame_spar = {"ui/spar/spar_k_o.png", "ui/spar/spar_k_o.png", "ui/spar/spar_k_o.png"}  --xurui: 晶石的框只有一种, 所以加一个特殊的框
res.circle_frame = {
		"ui/common5/baoshi_green.png",
		"ui/common5/baoshi_green1.png",
		"ui/common5/baoshi_blue.png",
		"ui/common5/baoshi_blue1.png",
		"ui/common5/baoshi_blue2.png",
		"ui/common5/baoshi_blue3.png",
		"ui/common5/baoshi_blue4.png",
		"ui/common5/baoshi_purple.png",
		"ui/common5/baoshi_purple1.png",
		"ui/common5/baoshi_purple2.png",
		"ui/common5/baoshi_purple3.png",
		"ui/common5/baoshi_purple4.png",
		"ui/common5/baoshi_orange.png",
		"ui/common5/baoshi_orange1.png",
		"ui/common5/baoshi_orange2.png",
		"ui/common5/baoshi_orange3.png",
		"ui/common5/baoshi_orange4.png",
		"ui/common5/baoshi_red.png",
		"ui/common5/baoshi_red1.png",
		"ui/common5/baoshi_red2.png",
		"ui/common5/baoshi_red3.png",
		"ui/common5/baoshi_red4.png",
		"ui/common6/baoshi_yellow.png",
		"ui/common6/baoshi_yellow1.png",
		"ui/common6/baoshi_yellow2.png",
		"ui/common6/baoshi_yellow3.png",
		"ui/common6/baoshi_yellow4.png"	
	}

--神技等级文字
res.god_skill = {
		"ui/dl_wow_pic/zi_shen1.png",
		"ui/dl_wow_pic/zi_shen2.png",
		"ui/dl_wow_pic/zi_shen3.png",
		"ui/dl_wow_pic/zi_shen4.png",
		"ui/dl_wow_pic/zi_shen5.png",
	}
res.god_skill_0 = "ui/dl_wow_pic/zi_shen0.png"

--图鉴等级文字
res.handbook_level = {
		"ui/update_hero/sp_tu1.png",
		"ui/update_hero/sp_tu2.png",
		"ui/update_hero/sp_tu3.png",
		"ui/update_hero/sp_tu4.png",
		"ui/update_hero/sp_tu5.png",
	}
res.handbook_level_0 = "ui/update_hero/sp_tu0.png"


--暗器配件等级文字
res.mount_dress_star = {
		"ui/update_mount/zi_pei1.png",
		"ui/update_mount/zi_pei2.png",
		"ui/update_mount/zi_pei3.png",
		"ui/update_mount/zi_pei4.png",
		"ui/update_mount/zi_pei5.png",
	}

--神器职业
res.godarm_job = {
		"ui/update_godarm/sp_xiee.png",
		"ui/update_godarm/sp_shengming.png",
		"ui/update_godarm/sp_shanliang.png",
		"ui/update_godarm/sp_huimie.png",
	}
--神器职业
res.godarm_job_bg = {
		"ui/update_godarm/sp_xiee_1.png",
		"ui/update_godarm/sp_shengming_1.png",
		"ui/update_godarm/sp_shanliang_1.png",
		"ui/update_godarm/sp_huimie_1.png",
	}


res.circle_frame_normal = "ui/common5/baoshi_normal.png"
res.head_rect_frame_normal = "ui/common5/Hero_HeadBox_big_normal.png"

--assist界面的按钮
res.assist_input_normal = "ui/common3/but_arena_2.png"
res.assist_input_highlight = "ui/common3/but_arena_1.png"

--海商船只图
res.maritime_ship_frame = {
		"ui/Haishang/haishang1.png",
		"ui/Haishang/haishang2.png",
		"ui/Haishang/haishang3.png",
		"ui/Haishang/haishang4.png",
		"ui/Haishang/haishang5.png",
		"ui/Haishang/haishang6.png",
	}

--世界BOSS战斗胜利界面文字
res.worldBoss_win_word = {
		"ui/panjun.plist/zi_huoderongyu.png",
		"ui/panjun.plist/zi_rongyumingci.png"
	}

--胜 负 平 剪影
res.score_result_flag = {
		"ui/update_common/flag_win.png",
		"ui/update_common/flag_lose.png",
		"ui/update_common/flag_draw.png",
		"ui/update_common/flag_sketch.png",
	}

--装备大师图标
res.enhance_master_icon = {"ui/HeroSystem/zhuangbei_qianghua.png"}
res.enhance_master_word = {"ui/HeroSystem/master_zhuangbeiqianghua_zi.png"}
res.jewelry_master_icon = {"ui/HeroSystem/master_shiping.png"}
res.jewelry_master_word = {"ui/HeroSystem/master_shipingqianghua_zi.png"}
res.zhuangbeifumo_master_icon = {"ui/HeroSystem/zhuangbei_fumo.png"}
res.zhuangbeifumo_master_word = {"ui/HeroSystem/master_zhuangbeifumo_zi.png"}
res.shipingfumo_master_icon = {"ui/HeroSystem/shiping_fumo.png"}
res.shipingfumo_master_word = {"ui/HeroSystem/master_shipingfumo_zi.png"}
res.shipingtupo_master_icon = {"ui/HeroSystem/shiping_tupo.png"}
res.shipingtupo_master_word = {"ui/HeroSystem/master_shipingtupo_zi.png"}
res.herotrain_master_icon = {"ui/HeroSystem/hero_peiyang.png"}
res.herotrain_master_word = {"ui/HeroSystem/master_herogrowup_zi.png"}
res.baoshiqianghua_master_icon = {"ui/update_plist/baoshi_sys/icon_baoshi_dashi.png"}
res.baoshiqianghua_master_word = {"ui/baoshi_sys.plist/baoshiqianghuadashi_g.png"}
res.baoshitupo_master_icon = {"ui/update_plist/baoshi_sys/icon_baoshi_dashi.png"}
res.baoshitupo_master_word = {"ui/baoshi_sys.plist/baoshitupodashi_g.png"}
res.jingshiqianghua_master_icon = {"ui/spar/spar_dashi.png"}
res.jingshiqianghua_master_word = {"ui/spar/master_spar_qh.png"}
res.xianpinshengji_master_icon = {"ui/HeroSystem/xianpin_tupo.png"}
res.xianpinshengji_master_word = {"ui/HeroSystem/master_xianpinqianghua_zi.png"}

--巨龙日结算界面标题
res.dragon_war_title_win = {"ui/society_yanglong/title_longzhanshengli.png"}
res.dragon_war_title_lose = {"ui/society_yanglong/title_longzhanshibai.png"}

--一键购买商店标题
res["shop_quick_buy_title_4"] = {"ui/common6/yijiangoumai_title_i.png"}
res["shop_quick_buy_title_601"] = {"ui/common6/gonghui_shangdian_yj.png"}
res["shop_quick_buy_title_101"] = {"ui/common6/rongyaozhitai_yijian.png"}
res["shop_quick_buy_title_1001"] = {"ui/common6/yaosai_yijian.png"}
res["shop_quick_buy_title_91"] = {"ui/common6/leidian_shangdian_yj.png"}
res["shop_quick_buy_title_10050000"] = {"ui/common6/xilian_yijian.png"}
res["shop_quick_buy_title_5"] = {"ui/common6/zhancheng_shangdian_yj.png"}

--上阵界面魂师底座
res.dragon_war_hero_arrangement = {"ui/society_yanglong/julongzhan_dengzi.png"}
--上阵界面解锁等级数字
res.arrangement_unlock_number =  {
		"ui/FontPicecs.plist/shangzheng_1.png",
		"ui/FontPicecs.plist/shangzheng_2.png",
		"ui/FontPicecs.plist/shangzheng_3.png",
		"ui/FontPicecs.plist/shangzheng_4.png",
		"ui/FontPicecs.plist/shangzheng_5.png",
		"ui/FontPicecs.plist/shangzheng_6.png",
		"ui/FontPicecs.plist/shangzheng_7.png",
		"ui/FontPicecs.plist/shangzheng_8.png",
		"ui/FontPicecs.plist/shangzheng_9.png",
		"ui/FontPicecs.plist/shangzheng_0.png"
	}

res.icon_url = {
    ENERGY = "icon/item/tili2.png",
    ITEM_ID_3 = "icon/item/quanshui2.png",
    ITEM_ID_4 = "icon/item/milk2.png",
    ITEM_ID_5 = "icon/item/fengbao2.png",
    ITEM_ID_6 = "icon/item/boerduo2.png",
    TEAM_EXP = "icon/item/sheet_small_exp.png",
    ACHIEVE_POINT = "icon/item/icon_achievement.png",
    SWEEP = "icon/item/saodang.png",
    VIP = "icon/item/vip_icon.png",
}
--hero_background
res.hero_background = {
		"map/normal_bj_main1.jpg",
		"map/normal_bj_main2.jpg",
		"map/normal_bj_main3.jpg",
		"map/normal_bj_main4.jpg",
	}

res.zhanbao_score = {
		"ui/dl_wow_pic/zhanbao_0.png",
		"ui/dl_wow_pic/zhanbao_1.png",
		"ui/dl_wow_pic/zhanbao_2.png",
	}

--海商上阵界面背景图
res.maritime_arrangement_bg = {
		"ui/Haishang_zr_bj.plist/haishang_zr1.jpg",
		"ui/Haishang_zr_bj.plist/haishang_zr2.jpg",
		"ui/Haishang_zr_bj2.plist/haishang_zr3.jpg",
		"ui/aid_bj_hai2.png",
		"ui/aid_bj_hai2.png",
	}

res.sparfield_arrangement_bg = {
		"map/spar_chang_buzhen1.jpg",
		"map/spar_chang_buzhen2.jpg",
		"map/spar_chang_buzhen3.jpg",
	}

--精英赛的背景图
res.sanctuary_arrangement_bg = { 
		"map/sanctuary_arrange.jpg",
		"map/sanctuary_arrange1.jpg"
	}

--训练关的背景图
res.collegeTrain_arrangement_bg = { 
		"ui/update_collegetrain/sp_xunlianguan_bzbg.jpg",
		"ui/update_collegetrain/sp_xunlianguan_bzbg1.jpg"
	}

res.godarm_arrangement_bg = {
	"ui/HeroSystem/fuwenzhen.png",
	"ui/HeroSystem/green_cricle_zhenfa.png",
	"ui/update_godarm/dizuo.png",
	"ui/update_godarm/godarm_arrment_bg.jpg",
	"ui/HeroSystem/fuwenzhen_hui.png",
	"ui/HeroSystem/fuwenzhen_tibu.png",
	"ui/HeroSystem/fuwenzhen_blue.png",
}

-- 训练关的解锁等级
res.collegeTrain_unlock_png = { 
		"ui/update_collegetrain/zi_43jikaiqi.png",
		"ui/update_collegetrain/zi_58jikaiqi.png"
	}
--云顶之战的背景图
res.soto_team_arrangement_bg = { 
		"map/sototeam_arrange.jpg",
		"map/sototeam_battle_hu.jpg"
	}

--精英赛的背景图
res.sanctuary_show_title = {
		"ui/update_sanctuary/zi_quandalujingyingsai.png",
		"ui/update_sanctuary/zi_taotaisai.png",
		"ui/update_sanctuary/zi_8qiang.png",
		"ui/update_sanctuary/zi_haixuansaizhandou.png",
		"ui/update_sanctuary/zi_taotaisaiyazhu.png",
		"ui/update_sanctuary/zi_jingyingfuli.png",
	}
	
res.sanctuary_help_pic = { 
		"ui/sanctuary/sanctury_wfsm.jpg",
		"ui/sanctuary/sanctury_wfsm1.jpg",
		"ui/sanctuary/sanctury_wfsm2.jpg",
		"ui/sanctuary/sanctury_wfsm3.jpg",
		"ui/stormarena/stormarena_wfsm1.jpg",
	}

res.sanctuary_score_pic = { 
		"ui/sanctuary/q1.jpg",
		"ui/sanctuary/q2.jpg",
		"ui/sanctuary/q3.jpg",
	}

-- 副宗主权限
res.union_right_show_title = {
		"ui/update_union/zi_qxhd.png",
		"ui/update_union/zi_qxhg.png",
	}

res.union_build_ani = {
		"fca/zmxj_3",
		"fca/zmxj_3_2",
		"fca/zmxj_3_3",
	}	

--副本的背景图(前一半)
res.dungeon_bg = {
		"map/BigEliteMap/BigEliteMap1.jpg",
		"map/BigEliteMap/BigEliteMap2.jpg",
		"map/BigEliteMap/BigEliteMap3.jpg",
		"map/BigEliteMap/BigEliteMap4.jpg",
		"map/BigEliteMap/BigEliteMap5.jpg",
		"map/BigEliteMap/BigEliteMap6.jpg",
		"map/BigEliteMap/BigEliteMap7.jpg",
		"map/BigEliteMap/BigEliteMap8.jpg",
		"map/BigEliteMap/BigEliteMap9.jpg",
		"map/BigEliteMap/BigEliteMap10.jpg",
		"map/BigEliteMap/BigEliteMap11.jpg",
		"map/BigEliteMap/BigEliteMap12.jpg",
		"map/BigEliteMap/BigEliteMap13.jpg",
		"map/BigEliteMap/BigEliteMap14.jpg",
		"map/BigEliteMap/BigEliteMap15.jpg",
		"map/BigEliteMap/BigEliteMap16.jpg",
	}

--地狱杀戮场背景
res.fight_club_main_bg = {
		"map/fight_club_map/fight_club_scene_floor.jpg",
		"map/fight_club_map/fight_club_scene_king.jpg",
	}

res.fight_club_arrangement_bg = { 
		"map/fight_club_map/fight_club_buzhen_1.jpg",
		"map/fight_club_map/fight_club_buzhen_2.jpg"
	}

res.fight_club_help_pic = { 
		"ui/fight_club/q1.jpg",
		"ui/fight_club/q2.jpg",
		"ui/fight_club/q3.jpg",
	}

res.super_hero_help_pic = { 
		"ui/hero_introduce/ss_daimubai.jpg",
		"ui/hero_introduce/ssp_sstanghao.jpg",
	}

res.soto_team_help_pic = { 
		"ui/sotoTeam/soto_wfsm1.jpg",
		"ui/sotoTeam/sp_wfjs1.jpg",
	}

res.soto_team_season_pic = { 
		"ui/sotoTeam/sp_wfjs1.jpg",
		"ui/sotoTeam/sp_wfjs2.jpg",
		"ui/sotoTeam/sp_wfjs3.jpg",
	}	

--地狱杀戮场段位icon
res.fight_club_floor = {
		"ui/fight_club/fight_rank_black.png",
		"ui/fight_club/fight_rank_bronze.png",
		"ui/fight_club/fight_rank_silver.png",
		"ui/fight_club/fight_rank_gold.png",
		"ui/fight_club/fight_rank_platinum.png",
		"ui/fight_club/fight_rank_diamond.png",
		"ui/fight_club/fight_rank_king.png",
	}

--大魂師賽選擇界面背景圖（糊）
res.tower_bg = {
		"map/rongyaozt1024.jpg",
		"map/rongyaozhita_hu.jpg",
	}

--魂师段位赛段位icon
res.tower_icon_floor = {
		"icon/glory/GloryTower_lv_Bronze.png",
		"icon/glory/GloryTower_lv_silver.png",
		"icon/glory/GloryTower_lv_Glod.png",
		"icon/glory/GloryTower_lv_platinum.png",
		"icon/glory/GloryTower_lv_Diamond.png",
		"icon/glory/GloryTower_zi_zhizun.png",
		"icon/glory/GloryTower_Floor_lv.png",
	}

--魂师段位赛段位level
res.tower_level_floor = {
		"icon/glory/luoma1.png",
		"icon/glory/luoma2.png",
		"icon/glory/luoma3.png",
		"icon/glory/luoma4.png",
		"icon/glory/luoma5.png",
	}

--宗门武魂level
res.dragon_level_effect = {
		{"ui/society_yanglong/weapon1.png", "ui/society_yanglong/warrior1.png", "fca/zongmenwuhun_01"},
		{"ui/society_yanglong/weapon2.png", "ui/society_yanglong/warrior2.png", "fca/zongmenwuhun_02"},
		{"ui/society_yanglong/weapon3.png", "ui/society_yanglong/warrior3.png", "fca/zongmenwuhun_03"},
		{"ui/society_yanglong/weapon4.png", "ui/society_yanglong/warrior4.png", "fca/zongmenwuhun_03"},
	}

--副本的背景图(后一半)
res.dungeon_bg_2 = {
		"map/BigEliteMap/BigEliteMap1.jpg",
		"map/BigEliteMap/BigEliteMap2.jpg",
		"map/BigEliteMap/BigEliteMap3.jpg",
		"map/BigEliteMap/BigEliteMap4.jpg",
		"map/BigEliteMap/BigEliteMap5.jpg",
		"map/BigEliteMap/BigEliteMap6.jpg",
		"map/BigEliteMap/BigEliteMap7.jpg",
		"map/BigEliteMap/BigEliteMap8.jpg",
		"map/BigEliteMap/BigEliteMap9.jpg",
		"map/BigEliteMap/BigEliteMap10.jpg",
		"map/BigEliteMap/BigEliteMap11.jpg",
		"map/BigEliteMap/BigEliteMap12.jpg",
		"map/BigEliteMap/BigEliteMap13.jpg",
		"map/BigEliteMap/BigEliteMap14.jpg",
		"map/BigEliteMap/BigEliteMap15.jpg",
		"map/BigEliteMap/BigEliteMap16.jpg",
	}

--宗门战我方堂建筑
res.union_war_hall_blue = {
		{"ui/unionwar/building_li_blue.png", "ui/unionwar/building_li_blue1.png", "ui/unionwar/building_li_blue2.png"},
		{"ui/unionwar/building_yu_blue.png", "ui/unionwar/building_yu_blue1.png", "ui/unionwar/building_yu_blue2.png"},
		{"ui/unionwar/building_ming_blue.png", "ui/unionwar/building_ming_blue1.png", "ui/unionwar/building_ming_blue2.png"},
		{"ui/unionwar/building_yao_blue.png", "ui/unionwar/building_yao_blue1.png", "ui/unionwar/building_yao_blue2.png"},
	}
--宗门战敌方堂建筑
res.union_war_hall_red = {
		{"ui/unionwar/building_li_red.png", "ui/unionwar/building_li_red1.png", "ui/unionwar/building_li_red2.png"},
		{"ui/unionwar/building_yu_red.png", "ui/unionwar/building_yu_red1.png", "ui/unionwar/building_yu_red2.png"},
		{"ui/unionwar/building_ming_red.png", "ui/unionwar/building_ming_red1.png", "ui/unionwar/building_ming_red2.png"},
		{"ui/unionwar/building_yao_red.png", "ui/unionwar/building_yao_red1.png", "ui/unionwar/building_yao_red2.png"},
	}
-- 堂特效
res.union_war_hall_effect = {
		{"fca/building_li/building_li", "fca/building_li_1/building_li_1", "fca/building_li_2/building_li_2"},
		{"fca/building_yu/building_yu", "fca/building_yu_1/building_yu_1", "fca/building_yu_2/building_yu_2"},
		{"fca/building_min/building_min", "fca/building_min_1/building_min_1", "fca/building_min_2/building_min_2"},
		{"fca/building_yao/building_yao", "fca/building_yao_1/building_yao_1", "fca/building_yao_2/building_yao_2"},
	}
-- duanwei
res.union_war_floor_icon = {
		"icon/jl_duanwei/jl_lv_Bronze.png",
		"icon/jl_duanwei/jl_lv_silver.png",
		"icon/jl_duanwei/jl_lv_Glod.png",
		"icon/jl_duanwei/jl_lv_platinum.png",
		"icon/jl_duanwei/jl_lv_Diamond.png",
		"icon/jl_duanwei/jl_zi_zhizun.png",
		"icon/jl_duanwei/jl_Floor_lv.png",
	}

res.union_war_floor_num = {
		"icon/jl_duanwei/jl_luoma1.png",
		"icon/jl_duanwei/jl_luoma2.png",
		"icon/jl_duanwei/jl_luoma3.png",
		"icon/jl_duanwei/jl_luoma4.png",
		"icon/jl_duanwei/jl_luoma5.png",
	}

--宗门战的弹脸
res.union_war_show_title = {
		"ui/unionwar/yangwudi_ren.png",
		"ui/update_union/zi_zongmenzhankaiqi.png",
		"ui/update_union/zi_zongmenzhanxiuzhan.png",
	}

--变强评价
res.stronger_help_pic = {
		"ui/dl_wow_pic/tip_dubutianxia.png",
		"ui/dl_wow_pic/tip_chaofanjuelun.png",
		"ui/dl_wow_pic/tip_chuleibacui.png",
		"ui/dl_wow_pic/tip_fengmangchulu.png",
		"ui/dl_wow_pic/tip_pingpingwuqi.png",
		"ui/dl_wow_pic/tip_jixutisheng.png",
	}

--默认头像
res.default_user_avatar = {"ui/Elite_normol.plist/head_cricle_di.png"}
--默认头像框
res.default_user_frame = {"ui/Pagehome2/level_cricle.png"}
--头像锁
res.default_user_avatar_lock = {"ui/Fighting.plist/lock.png"}

--酒馆普通抽奖数字
res.chest_silver_number = {
		"ui/PageTreasureChestDraw/gold_floor_wrod2_1.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_2.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_3.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_4.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_5.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_6.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_7.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_8.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_9.png",
		"ui/PageTreasureChestDraw/gold_floor_wrod2_10.png"
	}
-- 训练关图片
res.college_train_png = {
	"ui/update_collegetrain/sp_xinshouyanxichang.png",
	"ui/update_collegetrain/sp_jinjieyanxichang.png",
	"ui/update_collegetrain/sp_jingyingyanxichang.png",
} 

-- 升灵台大数字
res.soul_tower_large_num = {
	"ui/update_soultower/zi_slt_1.png",
	"ui/update_soultower/zi_slt_2.png",
	"ui/update_soultower/zi_slt_3.png",
	"ui/update_soultower/zi_slt_4.png",
	"ui/update_soultower/zi_slt_5.png",
	"ui/update_soultower/zi_slt_6.png",
	"ui/update_soultower/zi_slt_7.png",
	"ui/update_soultower/zi_slt_8.png",
	"ui/update_soultower/zi_slt_9.png",	
	"ui/update_soultower/zi_slt_0.png",			
} 

-- 升灵台小数字
res.soul_tower_small_num = {
	"ui/update_soultower/zi_slt_s_1.png",
	"ui/update_soultower/zi_slt_s_2.png",
	"ui/update_soultower/zi_slt_s_3.png",
	"ui/update_soultower/zi_slt_s_4.png",
	"ui/update_soultower/zi_slt_s_5.png",
	"ui/update_soultower/zi_slt_s_6.png",
	"ui/update_soultower/zi_slt_s_7.png",
	"ui/update_soultower/zi_slt_s_8.png",
	"ui/update_soultower/zi_slt_s_9.png",	
	"ui/update_soultower/zi_slt_s_0.png",			
} 

-- 破碎位面关卡按钮资源
res.maze_explore_btnres = {
	{"ui/update_mazeExplore/posui_01_light.png", "ui/update_mazeExplore/posui_01_dark.png"},
	{"ui/update_mazeExplore/posui_02_light.png", "ui/update_mazeExplore/posui_02_dark.png"},
	{"ui/update_mazeExplore/posui_03_light.png", "ui/update_mazeExplore/posui_03_dark.png"},
	{"ui/update_mazeExplore/posui_04_light.png", "ui/update_mazeExplore/posui_04_dark.png"},
	{"ui/update_mazeExplore/posui_05_light.png", "ui/update_mazeExplore/posui_05_dark.png"},
	{"ui/update_mazeExplore/posui_06_light.png", "ui/update_mazeExplore/posui_06_dark.png"},			
} 

--破碎位面事件图片
res.maze_explore_eventIcon = {
	["4"] = "ui/update_mazeExplore/pswm_shijian05.png",				--宝箱
	["8"] = "ui/update_mazeExplore/pswm_shijian02.png",				--升降开关
	["10"] = "ui/update_mazeExplore/pswm_shijian01.png",			--灯塔
	["12"] = "ui/update_mazeExplore/pswm_shijian04.png",			--追兵
	["16"] = "ui/update_mazeExplore/pswm_shijian06.png",			--地刺
}
--商店激活宿命图标
res.shop_hero_combination = {"ui/common6/lable_jihuosuming_s.png"}

--每日签到灰色图片
res.daily_signin_gray = {"ui/common3/but_qiandao_hui.png"}

--考古界面的图片
res.archaeology_gaoliang = {"ui/Arena2.plist/cricle_on_light_g.png"}
res.archaeology_ball = {
		"ui/Arena2.plist/cricle_on_light_yellow.png",
		"ui/Arena2.plist/cricle_off_light_yellow.png",
		"ui/Arena2.plist/cricle_on_light_green.png",
		"ui/Arena2.plist/cricle_off_light_green.png",
		"ui/Arena2.plist/cricle_on_light_purple.png",
		"ui/Arena2.plist/cricle_off_light_purple.png",
		"ui/Arena2.plist/cricle_on_light_pink.png",
		"ui/Arena2.plist/cricle_off_light_pink.png",
		"ui/Arena2.plist/cricle_on_light_orange.png",
		"ui/Arena2.plist/cricle_off_light_orange.png",
		"ui/Arena2.plist/cricle_on_light_red.png",
		"ui/Arena2.plist/cricle_off_light_red.png",
	}
--战斗中的图片
res.fight_auto_skill = "ui/Fighting.plist/but_zidongjinneg.png"
res.fight_auto_skill_an = "ui/Fighting.plist/but_zidongjinneg_an.png"
res.fight_hero_yuan3 = "ui/common5/icon_yuan3.png"
res.fight_hero_yuan2 = "ui/common5/icon_yuan2.png"
res.fight_hero_yuan1 = "ui/common5/icon_yuan1.png"
res.fight_hero_ling = "ui/common5/icon_lin.png"
res.fight_buff_zi = {
		"ui/Fighting2.plist/battle_buff_zi0.png",
		"ui/Fighting2.plist/battle_buff_zi1.png",
		"ui/Fighting2.plist/battle_buff_zi2.png",
		"ui/Fighting2.plist/battle_buff_zi3.png",
		"ui/Fighting2.plist/battle_buff_zi4.png",
		"ui/Fighting2.plist/battle_buff_zi5.png",
		"ui/Fighting2.plist/battle_buff_zi6.png",
		"ui/Fighting2.plist/battle_buff_zi7.png",
		"ui/Fighting2.plist/battle_buff_zi8.png",
		"ui/Fighting2.plist/battle_buff_zi9.png"
	}
res.fight_jiasu = "ui/Fighting.plist/but_jiasu.png"
res.fight_jiasu_an = "ui/Fighting.plist/but_jiasu_an.png"
res.but_jiasu4 = "ui/Fighting.plist/but_jiasu4.png"
res.but_jiasu4_an = "ui/Fighting.plist/but_jiasu4_an.png"
res.fight_tiaoguo = "ui/Fighting.plist/but_tiaoguo.png"
res.fight_tiaoguo_an = "ui/Fighting.plist/but_tiaoguo_an.png"
-- 战斗中能量存储显示的图片
res.fight_storage_inbar = "ui/storage_inbar.png"
res.fight_storage_outbar = "ui/storage_outbar.png"

res.dragon_war_win_buffer = {
		"ui/society_yanglong2.plist/liansheng1.png",
		"ui/society_yanglong2.plist/liansheng2.png",
		"ui/society_yanglong2.plist/liansheng3.png",
		"ui/society_yanglong2.plist/liansheng4.png",
		"ui/society_yanglong2.plist/liansheng5.png",
		"ui/society_yanglong2.plist/liansheng6.png"
	}

res.dragon_war_floor_icon = {
		"icon/jl_duanwei/jl_lv_Bronze.png",
		"icon/jl_duanwei/jl_lv_silver.png",
		"icon/jl_duanwei/jl_lv_Glod.png",
		"icon/jl_duanwei/jl_lv_platinum.png",
		"icon/jl_duanwei/jl_lv_Diamond.png",
		"icon/jl_duanwei/jl_zi_zhizun.png",
		"icon/jl_duanwei/jl_Floor_lv.png",
	}

res.dragon_war_floor_num = {
		"icon/jl_duanwei/jl_luoma1.png",
		"icon/jl_duanwei/jl_luoma2.png",
		"icon/jl_duanwei/jl_luoma3.png",
		"icon/jl_duanwei/jl_luoma4.png",
		"icon/jl_duanwei/jl_luoma5.png",
	}

res.artifact_box_kezhuangbei = "ui/common/kezhuangbei_g.png"
res.artifact_box_keshouji = "ui/common2/keshouji_g.png"
res.artifact_box_kehecheng = "ui/common2/kehecheng_g.png"

res.spar_fighter_tip = {
	"ui/spar_chang/dichangyudi_1_w.png",
	"ui/spar_chang/dichangyudi_2_w.png",
	"ui/spar_chang/dichangyudi_3_w.png",
	"ui/spar_chang/dichangyudi_4_w.png",
	"ui/spar_chang/zuizhongqiangdi_u.png",
}

res.spar_hero_kuang = "ui/kuang_icon/Hero_Equipmentbox_normal_white.png"
res.spar_hero_yongyou = "ui/spar_chang/lable_yongyou.png"

res.spar_progress_dot = {
		"ui/spar_chang/dot_spar1.png",
		"ui/spar_chang/dot_spar2.png",
		"ui/spar_chang/dot_spar3.png",
	}

res.maginifier = "ui/update_common/button.plist/btn_check.png"

res.shenqi_box_k = "ui/artifact/shenqi_box_k.png"

res.spar_item_shadow = "ui/update_reborn/shadow_waigu.png"
res.soul_spirit_shadow = "ui/update_reborn/shadow_hunlin.png"
res.blue_light_line = "ui/blue_light.png"

res.itemBoxGloryTowerTypeIcon = "ui/GloryTower/rongyaozhita_jiaobiao.png"

res.itemBoxPingZhi_a = "ui/update_hero/aptitude_a_small.png"
res.itemBoxPingZhi_b = "ui/update_hero/aptitude_b_small.png"
res.itemBoxPingZhi_c = "ui/update_hero/aptitude_c_small.png"
res["itemBoxPingZhi_a+"] = "ui/update_hero/aptitude_ax_small.png"
res.itemBoxPingZhi_s = "ui/update_hero/aptitude_s_small.png"
res.itemBoxPingZhi_ss = "ui/update_hero/aptitude_ss_small.png" 
res["itemBoxPingZhi_ss+"] = "ui/update_hero/aptitude_ssx_small.png"

res.up_grade_max = "ui/update_common/sp_yishangxian.png"

res.storm_team_dizuo = {
		"ui/StormArena.plist/S_wenhao.png",
		"ui/HeroSystem/fuwenzhen.png"
	}

--开场漫画图片
res.start_game_cartoon = {
		"ui/manhua/dlmh1.jpg",
		"ui/manhua/dlmh2.jpg",
		"ui/manhua/dlmh3.jpg",
		"ui/manhua/dlmh4.jpg",
		"ui/manhua/dlmh5.jpg",
		"ui/manhua/dlmh6.jpg",
		"ui/manhua/dlmh7.jpg",
		"ui/manhua/dlmh8.jpg",
	}

--装备突破钻石图片
res.equipment_evolution_icon_green = "ui/dl_wow_pic/jj_zuan/zuan_green.png"
res.equipment_evolution_icon_blue = "ui/dl_wow_pic/jj_zuan/zuan_blue.png"
res.equipment_evolution_icon_purple = "ui/dl_wow_pic/jj_zuan/zuan_purple.png"
res.equipment_evolution_icon_orange = "ui/dl_wow_pic/jj_zuan/zuan_orange.png"
res.equipment_evolution_icon_red = "ui/dl_wow_pic/jj_zuan/zuan_red.png"
res.equipment_evolution_icon_yellow = "ui/dl_wow_pic/jj_zuan/zuan_yellow.png"

-- 游戏里的宝箱 {关，开}
res.chest = {
	-- {"ui/SunWell.plist/baoxiang_jin_panjun.png", "ui/SunWell.plist/baoxiang_jin_panjun_open.png"},
	{"ui/update_plist/SunWell/sunwell_baoxiang1_close.png", "ui/update_plist/SunWell/sunwell_baoxiang1_open2.png"},
	{"ui/SunWell.plist/baoxiang3_close.png", "ui/SunWell.plist/baoxiang3_open.png"},
	{"ui/society_union2.plist/society_baoxiang1_1.png", "ui/society_union2.plist/society_baoxiang2_2.png"},
	{"ui/update_plist/society_union2/society_shuijing.png", "ui/update_plist/society_union2/society_shuijing_an.png"},
}

-- boss类型标签 单、群、魔防、物防
res.bossType = {
	"ui/update_common/sp_dan.png",
	"ui/update_common/sp_qun.png",
	"ui/update_common/sp_fafang.png",
	"ui/update_common/sp_wufang.png",
}

res.societyBuff = {
	"ui/socity_fuben/society_nuqi.png",
	"ui/socity_fuben/society_baoji.png",
	"ui/socity_fuben/society_fashushanghai.png",
	"ui/socity_fuben/society_wulishanghai.png",
}

res.mount_frame_default = {"ui/weapon/kuang_green.png", "ui/weapon/kuang_huewen_green.png", "ui/HeroOverview/HeroOverview_green3.png"}
res.mount_frame_green = {"ui/weapon/kuang_green.png", "ui/weapon/kuang_huewen_green.png", "ui/HeroOverview/HeroOverview_green3.png"}
res.mount_frame_blue = {"ui/weapon/kuang_blue.png", "ui/weapon/kuang_huewen_blue.png", "ui/HeroOverview/HeroOverview_blue3.png"}
res.mount_frame_purple = {"ui/weapon/kuang_purple.png", "ui/weapon/kuang_huewen_purple.png", "ui/HeroOverview/HeroOverview_purple3.png"}
res.mount_frame_orange = {"ui/weapon/kuang_orange.png", "ui/weapon/kuang_huewen_orange.png", "ui/HeroOverview/HeroOverview_orange3.png"}
res.mount_frame_red = {"ui/weapon/kuang_red.png", "ui/weapon/kuang_huewen_red.png", "ui/HeroOverview/HeroOverview_red3.png"}
res.mount_frame_yellow = {"ui/weapon/kuang_gold.png", "ui/weapon/kuang_huewen_gold.png", "ui/HeroOverview/HeroOverview_yellow3.png"}

res.soulSpirit_frame_purple = {"ui/common/hl_h_purper.png", "ui/common/hunling_k_purper_t.png"}
res.soulSpirit_frame_orange = {"ui/common/hl_h_glod.png", "ui/common/hunling_k_glod_t.png"}
res.soulSpirit_frame_yellow = {"ui/common/hl_h_glod.png", "ui/common/hunling_k_glod_t.png"}
res.soulSpirit_frame_red = {"ui/common/hl_h_red.png", "ui/common/hunling_k_glod_t.png"}

res.soulSpirit_big_frame_purple = {"ui/common/hl_k_purper.png", "ui/common/hunling_k_purper_t.png"}
res.soulSpirit_big_frame_orange = {"ui/common/hl_k_orange.png", "ui/common/hunling_k_glod_t.png"}
res.soulSpirit_big_frame_yellow = {"ui/common/hl_k_orange.png", "ui/common/hunling_k_glod_t.png"}
res.soulSpirit_big_frame_red = {"ui/common/hl_k_orange.png", "ui/common/hunling_k_glod_t.png"}

res.soul_guide_ani = "fca/tx_ssanqi_zhanshi_effect"

res.soulSpirit_help_pic = { 
		"ui/help/soul_spirit/help_1.jpg",
		"ui/help/soul_spirit/help_2.jpg",
	}

res.societyBuffNameBg = {
	"ui/socity_fuben/buff_1.png",
	"ui/socity_fuben/buff_2.png",
	"ui/socity_fuben/buff_3.png",
	"ui/socity_fuben/buff_4.png",
}

res.serverStateds = {
	"ui/Login/Game_Login_tuijian.png",
	"ui/Login/Game_Login_weihu.png",
	"ui/Login/Game_Login_jijiang.png",
	"ui/Login/Game_Login_huobao.png",
}

res.rank_empty_tips = {
	"ui/HeroSystem/xuweiyidai.png", ---虚位以待，敬请期待
}

res.cricle_kuang = "ui/cricle_kuang.png"

--新章节介绍中截图的名称
res.dungeon_aside_bg = "dungeonAside.jpg"

--vip界面new标志
res.vip_new_icon = "ui/Vip_Chongzhi/new_zi.png"
--vip界面分割线
res.vip_line = "ui/dl_wow_pic/fengexian.png"

--战力展示——当前战力数字
res.floatForceNum =  {
		"ui/zhanli_i/zhanli_1.png",
		"ui/zhanli_i/zhanli_2.png",
		"ui/zhanli_i/zhanli_3.png",
		"ui/zhanli_i/zhanli_4.png",
		"ui/zhanli_i/zhanli_5.png",
		"ui/zhanli_i/zhanli_6.png",
		"ui/zhanli_i/zhanli_7.png",
		"ui/zhanli_i/zhanli_8.png",
		"ui/zhanli_i/zhanli_9.png",
		"ui/zhanli_i/zhanli_0.png"
	}

--战力展示——增加战力数字
res.floatForceAddNum =  {
		"ui/zhanli_i/lv_1.png",
		"ui/zhanli_i/lv_2.png",
		"ui/zhanli_i/lv_3.png",
		"ui/zhanli_i/lv_4.png",
		"ui/zhanli_i/lv_5.png",
		"ui/zhanli_i/lv_6.png",
		"ui/zhanli_i/lv_7.png",
		"ui/zhanli_i/lv_8.png",
		"ui/zhanli_i/lv_9.png",
		"ui/zhanli_i/lv_0.png"
	}

--活动图片数字
res.activity_num =  {
		"ui/updata_activity/act_1.png",
		"ui/updata_activity/act_2.png",
		"ui/updata_activity/act_3.png",
		"ui/updata_activity/act_4.png",
		"ui/updata_activity/act_5.png",
		"ui/updata_activity/act_6.png",
		"ui/updata_activity/act_7.png",
		"ui/updata_activity/act_8.png",
		"ui/updata_activity/act_9.png",
		"ui/updata_activity/act_0.png",
		"ui/updata_activity/act_point.png"
	}

--天降福袋图片数字
res.activity_sky_fall_num =  {
		"ui/update_skyfall/common_zi_1_1.png",
		"ui/update_skyfall/common_zi_1_2.png",
		"ui/update_skyfall/common_zi_1_3.png",
		"ui/update_skyfall/common_zi_1_4.png",
		"ui/update_skyfall/common_zi_1_5.png",
		"ui/update_skyfall/common_zi_1_6.png",
		"ui/update_skyfall/common_zi_1_7.png",
		"ui/update_skyfall/common_zi_1_8.png",
		"ui/update_skyfall/common_zi_1_9.png",
		"ui/update_skyfall/common_zi_1_0.png",
	}

--老玩家回归tips
res.activity_playerReturn_zi =  {
		"ui/updata_activity/zi_playerreturn_1.png",
		"ui/updata_activity/zi_playerreturn_2.png",
		"ui/updata_activity/zi_playerreturn_3.png",
		"ui/updata_activity/zi_playerreturn_4.png",
		"ui/updata_activity/zi_playerreturn_5.png",
	}

--战力展示——加号（绿色）
res.floatForceAddSp = "ui/zhanli_i/lv_jia.png"

--大富翁猜拳
res.monopolyFinger =  {
		"ui/monopoly/monopoly_jiandao.png",
		"ui/monopoly/monopoly_shitou.png",
		"ui/monopoly/monopoly_bu.png",
	}

--世界斗魂场比分数字
res.storm_arena_num =  {
		"ui/stormarena/zi_storm0.png",
		"ui/stormarena/zi_storm1.png",
		"ui/stormarena/zi_storm2.png",
	}

res.animation_linkage_pic = {
		"ui/Dialog_FirstValue/Value_qdh.png",
		"ui/Dialog_FirstValue/sanwupifu1.png",
	} 

--在线提示
res.prompt_icon_invasion =  "ui/Pagehome2/activity_boss.png"
res.prompt_icon_silvermine =  "ui/Pagehome2/activity_jbzd.png"

--仙品物品框
res.magicHerbFrame = {}
res.magicHerbFrame.normal =  "ui/MagicHerb/MagicHerb_kuang_normal.png"
res.magicHerbFrame.purple =  "ui/MagicHerb/MagicHerb_kuang_a.png"
res.magicHerbFrame.orange =  "ui/MagicHerb/MagicHerb_kuang_s.png"
res.magicHerbFrame.red =  "ui/MagicHerb/MagicHerb_kuang_ss.png"

--活动老虎机数字
res.activity_slot_num =  {
		"ui/updata_activity/super_monday/num_0.png",
		"ui/updata_activity/super_monday/num_1.png",
		"ui/updata_activity/super_monday/num_2.png",
		"ui/updata_activity/super_monday/num_3.png",
		"ui/updata_activity/super_monday/num_4.png",
		"ui/updata_activity/super_monday/num_5.png",
		"ui/updata_activity/super_monday/num_6.png",
		"ui/updata_activity/super_monday/num_7.png",
		"ui/updata_activity/super_monday/num_8.png",
		"ui/updata_activity/super_monday/num_9.png"
	}

-- 宗門職權
res.society_op = {}
res.society_op[SOCIETY_OFFICIAL_POSITION.BOSS] = "ui/Arena2/zm_master.png"
res.society_op[SOCIETY_OFFICIAL_POSITION.ADJUTANT] = "ui/Arena2/zm_assistant.png"
res.society_op[SOCIETY_OFFICIAL_POSITION.ELITE] = "ui/Arena2/zm_elite.png"


res.soul_letter_elite = "ui/Battle_pass/icon_jingying.png"
res.soul_letter_title = "ui/tupo/zi_jhcg.png"

res.firstRecharge = {
	"ui/Vip_Chongzhi/zi_chongzhirenyi.png",
	"ui/Vip_Chongzhi/zi_chongzhi18.png",
	"ui/Vip_Chongzhi/zi_chongzhi128.png",
	"ui/Vip_Chongzhi/zi_chongzhi328.png",
	"ui/Vip_Chongzhi/zi_chongzhi688.png",
	"ui/Vip_Chongzhi/zi_chongzhi1288.png",
}

res.firstRechargeTitle = {
	"ui/Vip_Chongzhi/title_shouchonghaoli.png",
	"ui/Vip_Chongzhi/title_shouchongjiangli.png",
}

res.firstRechargeImg = {
	"ui/Vip_Chongzhi/sp_shouchongcx.png",
	"ui/Vip_Chongzhi/sp_shouchong_tangsan.png",
}

res.firstRechargePoster = {
	"ui/Dialog_FirstValue/Value_chongzhitanchukang.png",
	"ui/Dialog_FirstValue/Value_leichong.png",
}

--小红点
res.red_tip = "ui/Pagehome/dot_1.png"

--14日新服基金标题
res.new_service_14_title = "ui/yuejijin_g/zi_achieve1.png"

-- 仙品超量通知界面的title图片
res.magicHerbPromptTitle = "ui/tupo/zi_xpts.png"

-- 武魂神赐通知界面的title图片
res.dragonTrainBuffPromptTitle = "ui/update_dragonTrain/zi_wuhunshenci.png"

-- 武魂神赐Buff icon
res.dragonTrainBuffIcon = "ui/update_dragonTrain/sp_dragonTrain_buff.png"

-- 月基金 或 字
res.activity_huo = "ui/updata_activity/sp_huo.png"


res.monopoly_poison = {
	"ui/monopoly/Monopoly_poison_1.png",
	"ui/monopoly/Monopoly_poison_2.png",
	"ui/monopoly/Monopoly_poison_3.png",
	"ui/monopoly/Monopoly_poison_4.png",
	"ui/monopoly/Monopoly_poison_5.png",
	"ui/monopoly/Monopoly_poison_6.png",
}

res.shaizi = {
	"ui/monopoly/shaizi1.png",
	"ui/monopoly/shaizi2.png",
	"ui/monopoly/shaizi3.png",
	"ui/monopoly/shaizi4.png",
	"ui/monopoly/shaizi5.png",
	"ui/monopoly/shaizi6.png",
}

res.StormArena_S = {
	"ui/StormArena.plist/S_0.png",
	"ui/StormArena.plist/S_1.png",
	"ui/StormArena.plist/S_2.png",
	"ui/StormArena.plist/S_3.png",
}

res.StormArena_Title_Win = {
	"ui/update_common/zi_diyiduishengli.png",
	"ui/update_common/zi_dierduishengli.png",
}
res.StormArena_Title_Loss = {
	"ui/update_common/zi_diyiduishibai.png",
	"ui/update_common/zi_dierduishibai.png",
}

res.StormArena_S_blhs = {
	"ui/StormArena.plist/S_blhs.png",
	"ui/StormArena.plist/S_blhs2.png",
	"ui/StormArena.plist/S_blhs3.png",
}

res.StormArena_S_shibai = {
	"ui/StormArena.plist/S_shibai.png",
	"ui/StormArena.plist/S_shibai2.png",
	"ui/StormArena.plist/S_shibai3.png",
}

res.zhanbu_zn_ = {
	"ui/zhanbu.plist/zn_0.png",
	"ui/zhanbu.plist/zn_1.png",
	"ui/zhanbu.plist/zn_2.png",
	"ui/zhanbu.plist/zn_3.png",
	"ui/zhanbu.plist/zn_4.png",
	"ui/zhanbu.plist/zn_5.png",
	"ui/zhanbu.plist/zn_6.png",
	"ui/zhanbu.plist/zn_7.png",
	"ui/zhanbu.plist/zn_8.png",
	"ui/zhanbu.plist/zn_9.png",
}

res.zhanbu_zl_ = {
	"ui/zhanbu.plist/zl_0.png",
	"ui/zhanbu.plist/zl_1.png",
	"ui/zhanbu.plist/zl_2.png",
	"ui/zhanbu.plist/zl_3.png",
	"ui/zhanbu.plist/zl_4.png",
	"ui/zhanbu.plist/zl_5.png",
	"ui/zhanbu.plist/zl_6.png",
	"ui/zhanbu.plist/zl_7.png",
	"ui/zhanbu.plist/zl_8.png",
	"ui/zhanbu.plist/zl_9.png",
}

res.zhanbu_zb_d_ = {
	"ui/zhanbu.plist/zb_d1.png",
	"ui/zhanbu.plist/zb_d2.png",
	"ui/zhanbu.plist/zb_d3.png",
}


res.PageTreasureChestDraw2_DZP_ = {
	"ui/PageTreasureChestDraw2.plist/DZP_0.png",
	"ui/PageTreasureChestDraw2.plist/DZP_1.png",
	"ui/PageTreasureChestDraw2.plist/DZP_2.png",
	"ui/PageTreasureChestDraw2.plist/DZP_3.png",
	"ui/PageTreasureChestDraw2.plist/DZP_4.png",
	"ui/PageTreasureChestDraw2.plist/DZP_5.png",
	"ui/PageTreasureChestDraw2.plist/DZP_6.png",
	"ui/PageTreasureChestDraw2.plist/DZP_7.png",
	"ui/PageTreasureChestDraw2.plist/DZP_8.png",
	"ui/PageTreasureChestDraw2.plist/DZP_9.png",
	"ui/PageTreasureChestDraw2.plist/DZP_10.png",
	"ui/PageTreasureChestDraw2.plist/DZP_11.png",
	"ui/PageTreasureChestDraw2.plist/DZP_12.png",
	"ui/PageTreasureChestDraw2.plist/DZP_13.png",
	"ui/PageTreasureChestDraw2.plist/DZP_14.png",
	"ui/PageTreasureChestDraw2.plist/DZP_15.png",
}

res.yingkuangzhan_ren ={
	"ui/yingkuangzhan/lv_ren.png",
	"ui/yingkuangzhan/hong_ren.png",
	"ui/yingkuangzhan/hui_ren.png",

}


res.GloryTower_Gl_ = {
	"ui/GloryTower/Gl_0.png",
	"ui/GloryTower/Gl_1.png",
	"ui/GloryTower/Gl_2.png",
	"ui/GloryTower/Gl_3.png",
	"ui/GloryTower/Gl_4.png",
	"ui/GloryTower/Gl_5.png",
	"ui/GloryTower/Gl_6.png",
	"ui/GloryTower/Gl_7.png",
	"ui/GloryTower/Gl_8.png",
	"ui/GloryTower/Gl_9.png",
}

res.fight_g ={
	"fight_g0.png",
	"fight_g1.png",
	"fight_g2.png",
	"fight_g3.png",
	"fight_g4.png",
	"fight_g5.png",
	"fight_g6.png",
	"fight_g7.png",
	"fight_g8.png",
	"fight_g9.png",
	
}

res.fight_y ={
	"fight_y0.png",
	"fight_y1.png",
	"fight_y2.png",
	"fight_y3.png",
	"fight_y4.png",
	"fight_y5.png",
	"fight_y6.png",
	"fight_y7.png",
	"fight_y8.png",
	"fight_y9.png",
	
}

res.fight_r ={
	"fight_r0.png",
	"fight_r1.png",
	"fight_r2.png",
	"fight_r3.png",
	"fight_r4.png",
	"fight_r5.png",
	"fight_r6.png",
	"fight_r7.png",
	"fight_r8.png",
	"fight_r9.png",
	
}

res.fight_rr ={
	"fight_rr0.png",
	"fight_rr1.png",
	"fight_rr2.png",
	"fight_rr3.png",
	"fight_rr4.png",
	"fight_rr5.png",
	"fight_rr6.png",
	"fight_rr7.png",
	"fight_rr8.png",
	"fight_rr9.png",
	
}

res.fight_b ={
	"fight_b0.png",
	"fight_b1.png",
	"fight_b2.png",
	"fight_b3.png",
	"fight_b4.png",
	"fight_b5.png",
	"fight_b6.png",
	"fight_b7.png",
	"fight_b8.png",
	"fight_b9.png",
	
}


res.soto_map ={
	"ui/sotoTeam/sototeam_main.jpg",
	"ui/sotoTeam/sototeam_main_night.jpg",
	"ui/sotoTeam/sototeam_main_sun.jpg",
}

res.soto_ani ={
	"fca/suotuo_5",
	"fca/suotuo_5_1",
}

res.soto_FoceImag ={
	"ui/sotoTeam/sp_cc.png",
	"ui/sotoTeam/sp_jh.png",
}
res.default_shop_name = "ui/update_shop/shop/sp_words_shangdian.png"

res.default_page_main_icon = "ui/Activity_game/activity_icon/tempImg.png"

-----------------嘉年华跟半月庆典背景资源---------------
res.jianianhua_renwu_bg = "ui/update_1_14_activity/lihuibg/jianianhua_7d_bosaixi.png"
res.banyueqingdian_renwu_bg = "ui/update_1_14_activity/lihuibg/jianianhua_14d_bibidong.png"
res.jianianhua_jifen_bg = "ui/update_1_14_activity/lihuibg/jianianhua_7d_zhuzhuqing.png"
res.banyueqingdian_jifen_bg = "ui/update_1_14_activity/lihuibg/jianianhua_14d_tianqingniumang.png"
res.jianianhua_jifen_title = "ui/update_1_14_activity/jianianhua_7d_jianianhua.png"
res.banyueqingdian_jifen_title = "ui/update_1_14_activity/jianianhua_7d_banyueqingdian.png"
----------------------------------------------------

res.card_bg ={
	"ui/update_common/card_bg_green.png",
	"ui/update_common/card_bg_blue.png",
	"ui/update_common/card_bg_purple.png",
	"ui/update_common/card_bg_orange.png",
	"ui/update_common/card_bg_red.png",
}


res.mockbattle_num ={
	"ui/update_mockbattle/sp_mnz_number_0.png",
	"ui/update_mockbattle/sp_mnz_number_1.png",
	"ui/update_mockbattle/sp_mnz_number_2.png",
	"ui/update_mockbattle/sp_mnz_number_3.png",
	"ui/update_mockbattle/sp_mnz_number_4.png",
	"ui/update_mockbattle/sp_mnz_number_5.png",
	"ui/update_mockbattle/sp_mnz_number_6.png",
	"ui/update_mockbattle/sp_mnz_number_7.png",
	"ui/update_mockbattle/sp_mnz_number_8.png",
	"ui/update_mockbattle/sp_mnz_number_9.png",
}

res.mockbattle_card_icon_bg ={
	"ui/update_mockbattle/sp_hunshi_icon.jpg",
	"ui/update_mockbattle/sp_anqi_icon.jpg",
	"ui/update_mockbattle/sp_hunling_icon.jpg",
	"ui/update_mockbattle/sp_godArm_icon.jpg",
}


res.hero_fragment_secretary_icon = {
	"icon/item/hp_orange_s.png",
	"icon/item/hunsrq_mr.png",
}


res.month_fund_title_168 = "ui/updata_activity/monthFund/sp_title_168.png"
res.month_fund_title_268 = "ui/updata_activity/monthFund/sp_title_268.png"

res.month_fund_poster_bg_168 = "ui/updata_activity/monthFund/sp_poster_168_bg.png"
res.month_fund_poster_bg_268 = "ui/updata_activity/monthFund/sp_poster_268_bg.png"

res.monthSignInNums = {
	"ui/update_monthSignIn/sp_nums_1.png",
	"ui/update_monthSignIn/sp_nums_2.png",
	"ui/update_monthSignIn/sp_nums_3.png",
	"ui/update_monthSignIn/sp_nums_4.png",
	"ui/update_monthSignIn/sp_nums_5.png",
	"ui/update_monthSignIn/sp_nums_6.png",
	"ui/update_monthSignIn/sp_nums_7.png",
	"ui/update_monthSignIn/sp_nums_8.png",
	"ui/update_monthSignIn/sp_nums_9.png",
	"ui/update_monthSignIn/sp_nums_0.png",
}

res.recycleSketch = {
	"ui/update_reborn/shadow_yinxiong.png",
	"ui/update_reborn/shadow_hungu.png",
	"ui/update_reborn/shadow_anqi.png",
	"ui/update_reborn/shadow_waigu.png",
	"ui/update_reborn/shadow_xianpin.png",
	"ui/update_reborn/shadow_hunlin.png",
	"ui/update_reborn/sp_godarm_reborn.png",
}

res.shoucibanjia = "ui/update_tavern/sp_bubble_shoucibanjia.png"

res.fashionScroll = {
	"ui/update_fashion/sp_juanzhou_1.png",
	"ui/update_fashion/sp_juanzhou_2.png",
	"ui/update_fashion/sp_juanzhou_3.png",
	"ui/update_fashion/sp_juanzhou_4.png",
	"ui/update_fashion/sp_juanzhou_4.png",
}

res.fashionDisplayBg = {
	"ui/update_fashion/sp_juanzhou_bj_1.png",
	"ui/update_fashion/sp_juanzhou_bj_2.png",
	"ui/update_fashion/sp_juanzhou_bj_3.png",
	"ui/update_fashion/sp_juanzhou_bj_4.png",
	"ui/update_fashion/sp_juanzhou_bj_4.png",
}

res.fashionIcon = "ui/update_fashion/sp_shizhuangbaolu.png"
res.fashionCombinationIcon = "ui/update_fashion/sp_jibanhuijuan.png"
res.fashionTitle = "ui/update_fashion/sp_words_baolushengji.png"
res.fashionCombinationTitle = "ui/update_fashion/sp_words_huijuanjihuo.png"

res.fashionHeadTitle = {
	"ui/update_fashion/sp_tips_jingdian.png",
	"ui/update_fashion/sp_tips_zhengui.png",
	"ui/update_fashion/sp_tips_xiyou.png",
	"ui/update_fashion/sp_tips_jipin.png",
	"ui/update_fashion/sp_tips_zhenpin.png",
}


res.zhangbichenPreheatCountdownNumbers = {
	"ui/update_zhangbichen/sp_number_1.png",
	"ui/update_zhangbichen/sp_number_2.png",
	"ui/update_zhangbichen/sp_number_3.png",
	"ui/update_zhangbichen/sp_number_4.png",
	"ui/update_zhangbichen/sp_number_5.png",
	"ui/update_zhangbichen/sp_number_6.png",
	"ui/update_zhangbichen/sp_number_7.png",
}


res.zhangbichenMusicGameIcon = {
	"ui/update_zhangbichen/music_game/zbc_jiepai_lan.png",
	"ui/update_zhangbichen/music_game/zbc_jiepai_zi.png",
}

res.zhangbichenMusicGameScoreNumber = {
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_1.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_2.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_3.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_4.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_5.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_6.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_7.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_8.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_9.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_zi_0.png",
}

res.zhangbichenMusicGameComboNumber = {
	"ui/update_zhangbichen/music_game/zi_combo_1.png",
	"ui/update_zhangbichen/music_game/zi_combo_2.png",
	"ui/update_zhangbichen/music_game/zi_combo_3.png",
	"ui/update_zhangbichen/music_game/zi_combo_4.png",
	"ui/update_zhangbichen/music_game/zi_combo_5.png",
	"ui/update_zhangbichen/music_game/zi_combo_6.png",
	"ui/update_zhangbichen/music_game/zi_combo_7.png",
	"ui/update_zhangbichen/music_game/zi_combo_8.png",
	"ui/update_zhangbichen/music_game/zi_combo_9.png",
	"ui/update_zhangbichen/music_game/zi_combo_0.png",
}

res.zhangbichenMusicGameTimeBarNumber = {
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_1.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_2.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_3.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_4.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_5.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_6.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_7.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_8.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_9.png",
	"ui/update_zhangbichen/music_game/zbc_gequjindu_zi_0.png",
}

res.zhangbichenMusicGameTotalScoreLevelImg = {
	"ui/update_zhangbichen/music_game/zbc_jingyan_b.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_a.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_s.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_ss.png",
}

res.zhangbichenMusicGameTotalScoreBarImg = {
	"ui/update_zhangbichen/music_game/zbc_jingyan_01.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_02.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_03.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_04.png",
	"ui/update_zhangbichen/music_game/zbc_jingyan_05.png",
}

res.zhangbichenFormalBoxImg = {
	{"ui/Elite_normol.plist/precious_low.png", "ui/Elite_normol.plist/precious_low_open.png"},
	{"ui/Elite_normol.plist/precious_middle.png", "ui/Elite_normol.plist/precious_middle_open.png"},
	{"ui/update_plist/Elite_normol/precious_mzi.png", "ui/update_plist/Elite_normol/precious_zi_open.png"},
	{"ui/update_plist/Elite_normol/precious_top.png", "ui/update_plist/Elite_normol/precious_top_open.png"},
	{"ui/update_plist/Elite_normol/precious_gold.png", "ui/update_plist/Elite_normol/precious_gold_open.png"},
}

res.activity_list_bg_chengse = "ui/updata_activity/sp_list_kuang.png"
res.activity_list_bg_zise = "ui/updata_activity/sp_list_kuang_zise.png"

res.soul_spirit_inherit_effect = "effects/tx_hljiemian_baoguang_effect.ccbi"
res.soul_spirit_inherit_sp = "ui/update_soulspirit/sp_fire_ball.png"
res.soul_spirit_awaken_skill = "ui/update_soulspirit/sp_awaken_skill.jpg"



res.soul_spirit_chuan_sp = {
	"ui/update_soulspirit/sp_chuan1.png",
	"ui/update_soulspirit/sp_chuan2.png",
	"ui/update_soulspirit/sp_chuan3.png",
	"ui/update_soulspirit/sp_chuan4.png",
	"ui/update_soulspirit/sp_chuan5.png",
	"ui/update_soulspirit/sp_chuan6.png",
}


res.sp_empty_star = "ui/update_common/sp_banxing.png"
res.sp_new_word_or = "ui/update_mystery/zi_huo.png"

res.sp_new_word_add = "ui/update_common/sp_add.png"

res.sp_new_word_equal = "ui/dl_wow_pic/battle_jiesuan/equal.png"

res.sp_love = "ui/dl_wow_pic/handbook_love.png"

res.silves_arena_rank_imgs = {
	"ui/update_silvesArena/first.png",
	"ui/update_silvesArena/second.png",
	"ui/update_silvesArena/third.png"
} 

res.silves_arena_poster_title = "ui/update_silvesArena/zi_xierweisidadouhunchang.png"
res.silves_arena_poster_avatar = "ui/update_silvesArena/xierweisi_fulande.png"
res.union_poster_title = "ui/update_union/zi_zongmentongzhi.png"

res.silves_arena_help_pic = { 
		"ui/update_silvesArena/sp_wanfajieshao_1.jpg",
		"ui/update_silvesArena/sp_wanfajieshao_2.jpg",
	}

res.silves_arena_number_left = {
	"ui/update_silvesArena/blue_1.png",
	"ui/update_silvesArena/blue_2.png",
	"ui/update_silvesArena/blue_3.png",
}

res.silves_arena_number_right = {
	"ui/update_silvesArena/red_1.png",
	"ui/update_silvesArena/red_2.png",
	"ui/update_silvesArena/red_3.png",
}

res.silves_arena_number_left_bg = "ui/update_silvesArena/sp_blue_di.png"

res.silves_arena_number_right_bg = "ui/update_silvesArena/sp_red_di.png"
	
res.spar_absorb_sp = {
	"ui/update_spar/sp_xi1.png",
	"ui/update_spar/sp_xi2.png",
	"ui/update_spar/sp_xi3.png",
	"ui/update_spar/sp_xi4.png",
	"ui/update_spar/sp_xi5.png",
	"ui/update_spar/sp_xi6.png",
	"ui/update_spar/sp_xi7.png",
	"ui/update_spar/sp_xi8.png",
	"ui/update_spar/sp_xi9.png",
	"ui/update_spar/sp_xi10.png",
}

res.silves_arena_big_add = "ui/update_silvesArena/sp_add_big.png"


res.ss_spar_grade_ani = {
		"fca/hgsx_1",
		"fca/hgsx_2",
	}	

res.ss_spar_icon = {
	["2020001"] = "icon/item/sp_hsby_up.png",
	["2020002"] = "icon/item/sp_zhbzm_up.png",
	["2020003"] = "icon/item/sp_zmbzm_up.png",
	["2030001"] = "icon/item/sp_hsby_down.png",
	["2030002"] = "icon/item/sp_zhbzm_down.png",
	["2030003"] = "icon/item/sp_zmbzm_down.png",

}	

res.oppo_title_sp = {
	"ui/update_oppo/sp_gamecenter_title.png",
	"ui/update_oppo/sp_hupo_titile.png",
	"ui/update_oppo/sp_name_title.png",
}


res.oppo_text_sp = {
	"ui/update_oppo/zi_text_2.png",
	"ui/update_oppo/zi_text_hupo.png",
	"ui/update_oppo/zi_text_hupodawanjiadenglu.png",
	"ui/update_oppo/zi_text_huporenzheng.png",
}

res.chat_face_path = {
    "ui/update_chat/face/face_1.png",
    "ui/update_chat/face/face_2.png",
    "ui/update_chat/face/face_3.png",
    "ui/update_chat/face/face_4.png",
    "ui/update_chat/face/face_5.png",
    "ui/update_chat/face/face_6.png",
    "ui/update_chat/face/face_7.png",
    "ui/update_chat/face/face_8.png",
    "ui/update_chat/face/face_9.png",
    "ui/update_chat/face/face_10.png",
    "ui/update_chat/face/face_11.png",
    "ui/update_chat/face/face_12.png",
    "ui/update_chat/face/face_13.png",
    "ui/update_chat/face/face_14.png",
    "ui/update_chat/face/face_15.png",
    "ui/update_chat/face/face_16.png",
    "ui/update_chat/face/face_17.png",
    "ui/update_chat/face/face_18.png",
    "ui/update_chat/face/face_19.png",
    "ui/update_chat/face/face_20.png",
}

res.chat_vip_path = {
    "ui/update_chat/vip/vip_1.png",
    "ui/update_chat/vip/vip_2.png",
    "ui/update_chat/vip/vip_3.png",
    "ui/update_chat/vip/vip_4.png",
    "ui/update_chat/vip/vip_5.png",
    "ui/update_chat/vip/vip_6.png",
    "ui/update_chat/vip/vip_7.png",
    "ui/update_chat/vip/vip_8.png",
    "ui/update_chat/vip/vip_9.png",
    "ui/update_chat/vip/vip_0.png",
}
res.chat_btnTips_path = {
	"ui/update_chat/btnTips/zi_join_fight.png",
	"ui/update_chat/btnTips/zi_join_union.png",
	"ui/update_chat/btnTips/zi_qianwang.png",
	"ui/update_chat/btnTips/zi_xiezhu.png",
	"ui/update_chat/btnTips/zi_xiezhushixiao.png",
	"ui/update_chat/btnTips/zi_xiezhuyizhu.png",
	"ui/update_chat/btnTips/zi_shenqing.png",
}


res.mazeExplore_grid_sp ={
	"ui/update_mazeExplore/posui_gezi_light.png",	--1
	"ui/update_mazeExplore/posui_gezi_dark.png",		--2
	"ui/update_mazeExplore/posui_gezi_xian_light.png",	--3
	"ui/update_mazeExplore/posui_gezi_xian_dark.png",	--4
	"ui/update_mazeExplore/posui_gezi_light_sm.png",	--5
	"ui/update_mazeExplore/posui_gezi_darkk_sm.png",	--6
	"ui/update_mazeExplore/posui_gezi_xian_light_sm.png",--7
	"ui/update_mazeExplore/posui_gezi_xian_dark_sm.png",--8
	"ui/update_mazeExplore/posui_suolue_juese.png",--9
	--red
	"ui/update_mazeExplore/posui_gezi_red.png",--10
	"ui/update_mazeExplore/posui_gezi_xian_red.png",--11
	"ui/update_mazeExplore/posui_gezi_red_sm.png",--12
	"ui/update_mazeExplore/posui_gezi_xian_red_sm.png",--13
	
}

res.mazeExplore_bg_sp ={
	"ui/update_mazeExplore/sp_map_bg_near.png",
	"ui/update_mazeExplore/sp_map_bg_mid.png",
	"ui/update_mazeExplore/sp_map_bg_far.png",
}

res.mazeExplore_Lighthouse_action = "fca/tx_huoju_open"
res.mazeExplore_Tostab_action = "fca/tx_dici_open_effect"
res.mazeExplore_FallingRocks_Role_action = "fca/tx_posui_luoshi01"
res.mazeExplore_FallingRocks_Grid_action = "fca/tx_posui_luoshi00"
res.mazeExplore_FallingRocks_Miss_Face_action = "fca/tx_posui_biaoqing00"
res.mazeExplore_FallingRocks_Hurt_Face_action = "fca/tx_posui_biaoqing01"
res.mazeExplore_Portal_action = "fca/tx_posui_chuansongmen"

res.mazeExplore_gridSprite = {
	"ui/update_mazeExplore/grid_icon/dfw_play_shitou.png",--1	
	"ui/update_mazeExplore/grid_icon/sp_book.png",--2
	"ui/update_mazeExplore/grid_icon/sp_lifts_off.png",--3
	"ui/update_mazeExplore/grid_icon/sp_lifts_on.png",--4
	"ui/update_mazeExplore/grid_icon/sp_lighthouse_off.png",--5
	"ui/update_mazeExplore/grid_icon/sp_secret_off.png",--6
	"ui/update_mazeExplore/grid_icon/sp_secret_on.png",--7
	"ui/update_mazeExplore/grid_icon/sp_tostab_off.png",--8
	"ui/update_mazeExplore/grid_icon/sp_tostab_on.png",--9
	"ui/update_mazeExplore/grid_icon/sp_lock_treasure.png",--10
	"ui/update_mazeExplore/grid_icon/sp_unlock_treasure.png",--11
	"ui/update_mazeExplore/grid_icon/sp_treasure_key.png",--12
	"ui/update_mazeExplore/grid_icon/sp_solider.png",--13
	"ui/update_mazeExplore/grid_icon/sp_lighthouse_on.png",--14
	"ui/update_mazeExplore/grid_icon/sp_chuansong.png",--15
	"ui/update_mazeExplore/grid_icon/sp_posui_qipao.png",--16
	"ui/update_mazeExplore/grid_icon/sp_posui_shaizi.png",--17

	"ui/update_mazeExplore/grid_icon/sp_ending.png",--18
	"ui/update_mazeExplore/grid_icon/sp_fall_rock.png",--19
	"ui/update_mazeExplore/grid_icon/sp_remove.png",--20

	"ui/update_mazeExplore/grid_icon/posui_boss_dark.png",--21
	"ui/update_mazeExplore/grid_icon/posui_boss_light.png",--22
	"ui/update_mazeExplore/grid_icon/posui_luoshi_dark.png",--23
	"ui/update_mazeExplore/grid_icon/posui_luoshi_light.png",--24

	"ui/update_mazeExplore/grid_icon/sp_posui_wenhao.png",--25

}

res.god_skill_activated = "ui/update_hero/sp_jihuo.png"
res.god_skill_next_activated = "ui/update_hero/sp_now.png"


res.value_ningrongrong_nextDay = "ui/Dialog_FirstValue/Value_ningrongrong_nextDay.png"
res.value_songyi_nextDay = "ui/Dialog_FirstValue/Value_songyi_nextDay.png"
res.value_sxiaowu_nextDay = "ui/Dialog_FirstValue/Value_sxiaowu_nextDay.png"

res.handbook_bg = {
	"ui/update_hero/sp_handbook_1_bg.jpg", -- 低级，S及以下
	"ui/update_hero/sp_handbook_2_bg.jpg", -- 高级，SS及以上
}

res.sp_star_res = {
	"ui/common/star_sliver.png", -- 低级，S及以下
	"ui/common/one_star.png", -- 高级，SS及以上
}

res.resource_treasures_gride_card = {
	"ui/update_resource_treasures/card_1.png",
	"ui/update_resource_treasures/card_2.png",
}
res.resource_treasures_gride_bg = {
	"ui/update_resource_treasures/gride_bg_thunder.png",
	"ui/update_resource_treasures/gride_bg_1.png",
	"ui/update_resource_treasures/gride_bg_token.png",
	"ui/update_resource_treasures/gride_bg_2.png",
}
res.resource_treasures_gride_xuanzhong = "ui/update_resource_treasures/gride_light.png"
res.resource_treasures_theme_none = "ui/update_resource_treasures/theme_bg.png"
res.resource_treasures_bonus_icon = "ui/update_resource_treasures/baoji.png"

res.resource_treasures_theme_title = {
	"ui/update_resource_treasures/tejizhuti.png",
	"ui/update_resource_treasures/gaojizhuti.png",
}


res.array_button_res = {
	"ui/update_plist/RebelArmy/but_jiacheng.png",
	"ui/Arena/arena_shuaxin_icon.png",
	"ui/update_common/sp_btn_soul.png",
	"ui/update_common/sp_btn_godArm.png",
}

--通过路径获取spriteFrame
function QSpriteFrameByPath(path)
	if path == nil or path == "" then
		return nil
	end
	local pos1,pos2 = string.find(path,"%.plist")
	if pos1 ~= nil and pos2 ~= nil then
		local plistPath = string.sub(path,0, pos2)
		local fileName = string.sub(path,pos2+2)
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath)
		return CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(fileName)
	else
		local sprite = CCSprite:create(path)
		if sprite then
			return sprite:getDisplayFrame()
		end
		return CCSprite:create("ui/none.png")
		-- assert(false, path.." is neither a plist file nor an image file.")
	end
end

function QSetDisplayFrameByPath( node ,path )
	if node and path then
		local spriteFrame = QSpriteFrameByPath(path)
		if spriteFrame then
			if node.setDisplayFrame then
				node:setDisplayFrame(spriteFrame)
				return true
			elseif node.setSpriteFrame then
				node:setSpriteFrame(spriteFrame)
				return true
			end
		end
	end

	return false
end

function QSetDisplaySpriteByPath( node, path )
	if path then
		node:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	end
end

--通过Key获取spriteFrame
function QSpriteFrameByKey(key, index)
	local paths = QResPath(key)
	if type(paths) == "table" then
		index = index or 1
		return QSpriteFrameByPath(paths[index])
	else
		return QSpriteFrameByPath(paths)
	end
end

--检查文件是否存在
function QCheckFileIsExist(path)
	local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	return CCFileUtils:sharedFileUtils():isFileExist(fullPath)
end

--检查指定的plist类型文件
function QCheckPlistFile(path)
	local paths = string.split(path, ".plist/")
	local plistPath = paths[1]..".plist"
	local fileName = paths[2]
	if QCheckFileIsExist(plistPath) == false then
		return false
	end
	local plistData = CCFileUtils:sharedFileUtils():getFileData(plistPath)
	if string.find(plistData, fileName) ~= nil then
		return true
	end
	return false
end

--检查所有的资源路径
function QCheckPath()
	local safePath = {}
	local errorPath = {}
	local __checkFileByPath = function (path)
		if safePath[path] == nil then
			if string.find(path, "%.plist") ~= nil then
				if QCheckPlistFile(path) == false then
					print(path,"not exist!")
					table.insert(errorPath, path)
				end
			elseif QCheckFileIsExist(path) == false then
				print(path,"not exist!")
				table.insert(errorPath, path)
			end
		end
		safePath[path] = true
	end
	for key,paths in pairs(res) do
		if type(paths) == "table" then
			for _,path in ipairs(paths) do
				__checkFileByPath(path)
			end
		elseif type(paths) == "string" then
			__checkFileByPath(paths)
		end
	end
	return errorPath
end

function QResPath(key)
	return res[key]
end


-- useless texture in battle
local uselessTextures = 
{
"ui/intro_bj.png"
,"ui/intro_bj3.png"
,"ui/intro_bj4.png"
,"ui/intro_bj5.png"
,"ui/Pagehome.png"
,"ui/Pagehome2.png"
,"ui/pagehome_effect.png"
,"ui/pagehome_effect2.pvr.ccz"
,"ui/zjm_xuhua.pvr.ccz"
,"ui/Intro_shui_bo.png"
,"ui/zhujiemian_dnghua.pvr.ccz"
,"ui/Haishang.png"
,"ui/haishang_chuan2.png"
,"ui/pagehome_xue.png"
,"ui/Pagehome3.png"
,"ui/AchieveCard.pvr.ccz"
,"ui/normal_bj_main.jpg"
,"ui/NewOpen.png"
,"ui/BigEliteMap14.pvr.ccz"
,"ui/baoshi_sys.png"
,"ui/Black_mountain.png"
,"ui/zjm_wujian.pvr.ccz"
,"ui/zjm_pobu_yan.pvr.ccz"
,"ui/zjm_long.pvr.ccz"
,"ui/shenqi_liuguang.png"
,"ui/thunder_effect.pvr.ccz"
,"ui/zcj_qizhi_2.png"
,"ui/huodongtubiao_new.pvr.ccz"
,"ui/houdongtubiao_k.pvr.ccz"
,"ui/xianshixuangou_pic.png"
,"ui/Dialog_FirstValue.png"
,"ui/yingkuangzhuan.png"
,"ui/DailySignUp_saoguang.pvr.ccz"
,"ui/DailySignUp_effect.png"
,"ui/GloryTower.png"
,"ui/wenjuandati_i.png"
}
local uselessTexturesSunwar = 
{
 "ui/SunWellMap_cloud.pvr.ccz"
,"ui/SunWellMap.png"
,"ui/SunWellMap_bj.pvr.ccz"
,"ui/zhanchang_effect.pvr.ccz"
,"ui/common.png"
,"ui/common2.png"
,"ui/common3.png"
,"ui/common4.png"
,"ui/common5.png"
,"ui/common6.png"
,"ui/society_union2.pvr.ccz"
,"ui/GloryTower.png"
,"ui/fire_bj_new.pvr.ccz"
,"ui/Arena.png"
,"ui/RongYao.png"
,"ui/Glory_head_circle.pvr.ccz"
,"ui/Elite_normol.pvr.ccz"
}
local uselessTexturesTower = 
{
 "ui/Glory_head_circle.pvr.ccz"
,"ui/Arena.png"
,"ui/RongYao.png"
,"ui/GloryMap/Glory_map_6.jpg"
,"ui/GloryTower_bj.pvr.ccz"
,"ui/RebleArmy.pvr.ccz"
,"ui/Arena2.png"
,"ui/artifact.png"
}
local uselessTexturesSocietyDungeon =
{
 "ui/Tap_effect_g.pvr.ccz"
,"ui/RebleArmy.pvr.ccz"
,"ui/society_union2.pvr.ccz"
,"ui/society_fuben_bj.jpg"
,"ui/society_fuben_green.jpg"
,"ui/society_fuben_yellow.jpg"
,"ui/society_fuben_blue.jpg"
,"ui/gonghuifuben_effect.pvr.ccz"
,"ui/society_shouye.pvr.ccz"
,"ui/fire_bj_new.pvr.ccz"
}
local uselessTexturesUnionDragon = 
{
 "ui/Tap_effect_g.pvr.ccz"
,"ui/RebleArmy.pvr.ccz"
,"ui/Arena.png"
,"ui/fire_bj_new.pvr.ccz"
,"ui/RongYao.png"
,"ui/society_yanglong.png"
,"ui/society_yanglong2.png"
,"ui/plunder.png"
}

local uselessTexturesAfterLoad = 
{
 "ui/Login.pvr.ccz"
,"ui/jiazai_bj.pvr.ccz"
}


res.mockbattle_season_title ={
	"ui/update_mockbattle/zi_dashimonizhan.png",
	"ui/update_mockbattle/zi_shuangduimonizhan.png",
}


res.mockbattle_scoreSp_bg ={
	"ui/update_mockbattle/sp_jifenpai01.png",
	"ui/update_mockbattle/sp_jifenpai02.png",
	"ui/update_mockbattle/sp_jifenpai03.png",
	"ui/update_mockbattle/sp_tongguanyoudengsheng.png",
}

res.mockbattle_intro ={
	"ui/update_mockbattle/sp_mockbattle_intro_1.jpg",
	"ui/update_mockbattle/sp_mockbattle_intro_2.jpg",
	"ui/update_mockbattle/sp_mockbattle_intro_3.jpg",
	"ui/update_mockbattle/sp_mockbattle_intro_4.jpg",
}

-- 魂灵秘术点 1未解锁 2解锁 3点亮
res.soulspirit_bigpoint_res = {
	{"ui/update_soulspirit/no_low_light.png", 	"ui/update_soulspirit/no_light.png",	"ui/update_soulspirit/in_light.png"},
	{"ui/update_soulspirit/no_p_light.png", 	"ui/update_soulspirit/in_d_light.png", 	"ui/update_soulspirit/in_ph_light.png"},
	{"ui/update_soulspirit/no_y_light.png", 	"ui/update_soulspirit/in_yd_light.png", 	"ui/update_soulspirit/in_yh_light.png"},
}

-- 魂灵右边法阵
res.soulspirit_fazhen_effect = {
	{"fca/tx_blueglow_effect", 		"fca/tx_blueglow_loop_effect"},
	{"fca/tx_ziglow_effect", 		"fca/tx_ziglow_loop_effect"},
	{"fca/tx_yellowglow_effect", 	"fca/tx_yellowglow_loop_effect"},
}

-- 魂灵秘术特效文件 1开始循环的光效，2爆炸光 3点亮后的循环效果,4解锁效果
res.soulspirit_bigpoint_effect = {
	{"fca/tx_blueglow_start_effect", 	"fca/tx_bluestart_effect", 		"fca/tx_blueglow_loop1_effect", "fca/tx_unlocked_l_effect"},
	{"fca/tx_ziglow_start_effect", 		"fca/tx_zistart_effect", 		"fca/tx_ziglow_loop1_effect", "fca/tx_unlocked_p_effect"},
	{"fca/tx_yellowglow_start_effect", 	"fca/tx_yellowstart_effect", 	"fca/tx_yellowglow_loop1_effect", "fca/tx_unlocked_y_effect"},
}

res.magic_breed_ani = {
		"fca/xianpin_baoguang",
		"fca/xianpin_hua",
		"fca/xianpin_lizipiao",
	}	

res.magic_breed_Bg = {
		"ui/update_magicHerb/sp_breed_bg1.jpg",
		"ui/update_magicHerb/sp_breed_bg2.jpg",
	}	


res.gemstone_mix_ani = "fca/hg_sj_fx_1"


res.team_mark_sp = {
	"ui/common/icon_yuan.png",
	"ui/common5/icon_yuan1.png",
	"ui/common5/icon_yuan2.png",
	"ui/common5/icon_yuan3.png",
	"ui/update_godarm/sp_shen1.png",
	"ui/update_godarm/sp_shen2.png",
	"ui/update_godarm/sp_shen3.png",
	"ui/update_godarm/sp_shen4.png",
}

res.metalAbyss_ani = {
		"fca/syzd_fx_1",
		"fca/syzd_fx_2",
		"fca/syzd_bx_fx_1",
		"fca/syzd_bx_fx_2",
		"fca/syzd_sbx_fx_1",

		"fca/syzd_jbx_fx_1",	--6 铜 待机
		"fca/syzd_jbx_fx_2",	--7 铜 打开
		"fca/syzd_ybx_fx_1",	--8 金 待机
		"fca/syzd_ybx_fx_2",	--9 金 打开
	}	

res.sync_formation_icon_idx = {
	"icon/item/fuben1_tj.jpg",--1
	"icon/item/dhc_tj.png",--2
	"icon/item/gold_tj.png",--3
	"icon/item/shalu_mr.png",--4
	"icon/item/zongmenshoulie_tubiao.jpg",--5
	"icon/item/zongmenfuben.jpg",--6
	"icon/item/activity_whzb.jpg",--7
	"icon/item/hunsrq_mr.png",--8
	"icon/item/haishend_tj.jpg",--9
	"icon/item/hunshousenglin_1.jpg",--10
	"icon/item/dahunshisai.jpg",--11
	"icon/item/activity_diyushaluchang.jpg" ,--12
	"icon/item/activity_chuanlingta.jpg",--13
	"icon/item/activity_shenglingtai.jpg",--14
	"icon/item/icon_xierweisi.jpg",--15
	"icon/item/activity_quandalujingyingsai.jpg",--16
	"icon/item/jingshuzhicheng_tubiao.jpg",--17
	"icon/item/activity_suotuo.jpg",--18
	"icon/item/shengzhutiaozhan.jpg",--19
	"icon/item/activity_haishang.jpg",--20
	"icon/item/yunding_cishu.jpg",--21
	"icon/item/sjboss_shortcut.jpg",--22
	"icon/item/zongmen.jpg",--23
}

res.grave_moun_titile_path = {
	"ui/weapon/zi_diaokechenggong.png",
	"ui/weapon/zi_diaokefazhenjihuo.png",
}

function hibernateUselessTexturesBeforeLoad(dungeonConfig)
	local _process
	_process = function (cond, textures)
		if cond then
		    for _, file in ipairs(textures) do
		        local sprite = CCSprite:create(file)
		        if sprite and sprite.hibernate then
		            sprite:hibernate()
		        end
		    end
		end
	    return _process
	end
	_process(true, uselessTextures)(dungeonConfig.isSunwell, uselessTexturesSunwar)(dungeonConfig.isGlory, uselessTexturesTower)(dungeonConfig.isSocietyDungeon, uselessTexturesSocietyDungeon)(dungeonConfig.isUnionDragonWar, uselessTexturesUnionDragon)
end

function hibernateUselessTexturesAfterLoad(dungeonConfig)
	local _process
	_process = function (cond, textures)
		if cond then
		    for _, file in ipairs(textures) do
		        local sprite = CCSprite:create(file)
		        if sprite and sprite.hibernate then
		            sprite:hibernate()
		        end
		    end
		end
	    return _process
	end
	_process(true, 									uselessTexturesAfterLoad)
end

function wakeupUselessTextures(dungeonConfig)
	local _process
	_process = function (cond, textures)
		if cond then
		    for _, file in ipairs(textures) do
		        local sprite = CCSprite:create(file)
		        if sprite and sprite.wakeup then
		            sprite:wakeup()
		        end
		    end
		end
	    return _process
	end
	_process(true, uselessTextures)(dungeonConfig.isSunwell, uselessTexturesSunwar)(dungeonConfig.isGlory, uselessTexturesTower)(dungeonConfig.isSocietyDungeon, uselessTexturesSocietyDungeon)(dungeonConfig.isUnionDragonWar, uselessTexturesUnionDragon)(true, uselessTexturesAfterLoad)
end
