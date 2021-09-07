AssetConfig = AssetConfig or {}

-- fontreportwindow
AssetConfig.font = "font/wqy.unity3d"
-- 用于安卓手机上聊天和公告模块的文字，以减缓游戏卡帧现象
AssetConfig.font_android = "font/wqy_android.unity3d"

-- Ctr
AssetConfig.animation = "prefabs/roles/animation/role.unity3d"
AssetConfig.headanimation_male = "prefabs/roles/headanimation/male.unity3d"
AssetConfig.headanimation_female = "prefabs/roles/headanimation/female.unity3d"

AssetConfig.sound_effect_path = "prefabs/sound/effect.unity3d"
AssetConfig.sound_battle_path = "prefabs/sound/battleeffect.unity3d"

-- prefab
AssetConfig.startpage = "prefabs/startpage.unity3d";
AssetConfig.sceneelements = "prefabs/ui/sceneelement/sceneelements.unity3d" -- 主界面图标
AssetConfig.effect = "prefabs/effect/%s.unity3d" -- 特效目录

AssetConfig.demo_mainui_prefab = "prefabs/ui/demo/demomainui.unity3d";
AssetConfig.demo_mainui_window1 = "prefabs/ui/demo/demowin1.unity3d";
AssetConfig.demo2_window = "prefabs/ui/demo/demo2window.unity3d"
AssetConfig.demo2_panel1 = "prefabs/ui/demo/demo2panel1.unity3d"
AssetConfig.demo2_panel2 = "prefabs/ui/demo/demo2panel2.unity3d"
AssetConfig.effect_path = "prefabs/effect/20089.unity3d"
AssetConfig.demo_pool_window = "prefabs/ui/demo/demopoolwin.unity3d";
AssetConfig.demo_layout_window = "prefabs/ui/demo/demolayoutwin.unity3d";
AssetConfig.demo_page_window = "prefabs/ui/demo/demopagewindow.unity3d";
AssetConfig.demo_preview_window = "prefabs/ui/demo/demopreviewwindow.unity3d";
AssetConfig.gm_window = "prefabs/ui/console/gmwindow.unity3d";

AssetConfig.login_window = "prefabs/ui/login/loginwindow.unity3d" -- 登录界面
AssetConfig.reconnect = "prefabs/ui/reconnect/reconnect.unity3d" -- 断线重连
AssetConfig.createrole_texture = "textures/createrole.unity3d"
AssetConfig.createrole2_texture = "textures/createrole2.unity3d"
-- AssetConfig.create_role_desc_small = "textures/createrole/descsmall.unity3d" --创建角色小描述
-- AssetConfig.create_role_desc_big = "textures/createrole/descbig.unity3d" --创建角色小描述
-- AssetConfig.create_role_big = "textures/createrole/big.unity3d" --创建角色大item
-- AssetConfig.create_role_small = "textures/createrole/small.unity3d" --创建角色小item
AssetConfig.create_win_bg = "textures/ui/bigbg/createwinbg.unity3d" --创建角色大背景图
AssetConfig.create_role = "prefabs/ui/createrole/createrolewindow.unity3d" --
AssetConfig.login_window = "prefabs/ui/login/loginwindow.unity3d"
AssetConfig.login_textures = "textures/ui/login.unity3d"
AssetConfig.reconnect = "prefabs/ui/reconnect/reconnect.unity3d"
AssetConfig.chat_window = "prefabs/ui/chat/chatwindow.unity3d"
AssetConfig.chat_mini_window = "prefabs/ui/chat/chatmini.unity3d"
AssetConfig.chat_mini_window_android = "prefabs/ui/chat/chatmini_android.unity3d"
AssetConfig.chat_item = "prefabs/ui/chat/chatitem.unity3d"
AssetConfig.shop_window = "prefabs/ui/shop/shopwindow.unity3d"      -- 商城界面
AssetConfig.number_pad = "prefabs/ui/numberpad/numberpad.unity3d"   -- 数字小键盘
AssetConfig.market_window = "prefabs/ui/market/marketwindow.unity3d"    -- 市场主界面
AssetConfig.market_gold_panel = "prefabs/ui/market/market1.unity3d"     -- 金币市场分页
AssetConfig.market_sliver_panel = "prefabs/ui/market/market2.unity3d"   -- 银币市场分页
AssetConfig.market_sell_panel = "prefabs/ui/market/market3.unity3d"     -- 出售物品分页
AssetConfig.market_sell_select_window = "prefabs/ui/market/sellwindow.unity3d" -- 选择物品出售窗口
AssetConfig.market_oneclick_setting = "prefabs/ui/market/defaultsellpanel.unity3d" -- 一键上架默认设置

AssetConfig.npc_shop_window = "prefabs/ui/shop/npcshopwindow.unity3d"   -- NPC商店窗口
AssetConfig.rank_window = "prefabs/ui/rank/rankwindow.unity3d"          -- 排行榜窗口
AssetConfig.rank_panel = "prefabs/ui/rank/rankpanel.unity3d"          -- 排行榜面板
AssetConfig.half_length = "textures/halflength.unity3d"                 -- 角色半身
AssetConfig.exit_confirm_window = "prefabs/ui/tips/exitconfirmwindow.unity3d" -- 退出确认按钮

----公会
AssetConfig.guild_find_win = "prefabs/ui/guild/guildfindwindow.unity3d" --帮派查找面板
AssetConfig.guild_create_win = "prefabs/ui/guild/guildcreatewindow.unity3d" --公会创建界面
AssetConfig.guild_main_win = "prefabs/ui/guild/guildmainwindow.unity3d" --公会信息主界面
AssetConfig.guild_main_tab1 = "prefabs/ui/guild/guildmaintab1.unity3d" --公会信息子面板
AssetConfig.guild_main_tab2 = "prefabs/ui/guild/guildmaintab2.unity3d" --公会福利子面板
AssetConfig.guild_main_tab3 = "prefabs/ui/guild/guildmaintab3.unity3d" --公会活动子面板
AssetConfig.guild_pray_win = "prefabs/ui/guild/guildpraywindow.unity3d" --公会祈祷
AssetConfig.guild_build_win = "prefabs/ui/guild/guildmanagewindow.unity3d" --管理帮派建筑面板
AssetConfig.guild_position_win ="prefabs/ui/guild/guildpositionwindow.unity3d" --设置帮派职位面板
AssetConfig.guild_change_purpose_win="prefabs/ui/guild/guildchangepurposewindow.unity3d" --帮派改宗旨面板
AssetConfig.guild_change_signature_win = "prefabs/ui/guild/guildchangesignaturewindow.unity3d" --公会成员改签名
AssetConfig.guild_apply_list_win = "prefabs/ui/guild/guildapplywindow.unity3d" --公会申请列表界面
AssetConfig.guild_store_win = "prefabs/ui/guild/guildstorewindow.unity3d" --帮派货栈面板
AssetConfig.guild_totem_win="prefabs/ui/guild/guildtotemlook.unity3d" --公会图腾界面
AssetConfig.guild_question_win = "prefabs/ui/guild/guildquestionwindow.unity3d" --公会温泉答题界面
AssetConfig.guild_recommend_win = "prefabs/ui/guild/guildrecommendwindow.unity3d"
AssetConfig.guild_speedup_win = "prefabs/ui/guild/guildbuildspeedupwin.unity3d"
AssetConfig.guild_week_pay_win = "prefabs/ui/guild/guildweekpaywin.unity3d"
AssetConfig.guild_red_bag_win = "prefabs/ui/guild/guildredbagopenwindow.unity3d"
AssetConfig.guild_red_bag_unopen_win = "prefabs/ui/guild/guildredbagunopenwindow.unity3d"
AssetConfig.guild_red_bag_set_win = "prefabs/ui/guild/guildredbagsetwindow.unity3d"
AssetConfig.guild_red_bag_money_win = "prefabs/ui/guild/guildredbagmoneywin.unity3d"
AssetConfig.guild_mem_manage_win = "prefabs/ui/guild/guildmemmanagewindow.unity3d" --公会成员管理
AssetConfig.guild_merge_win = "prefabs/ui/guild/guildmregewindow.unity3d" --公会合并界面
AssetConfig.guild_healthy_win = "prefabs/ui/guild/guildhealthywindow.unity3d" --公会健康度界面
AssetConfig.guild_npc_exchange_win = "prefabs/ui/guild/guildnpcexchangewin.unity3d" --公会健康度界面
AssetConfig.guild_merge_tips_win = "prefabs/ui/guild/guildmergetipswindow.unity3d" --公会合并提示界面
AssetConfig.guild_mem_delete_win = "prefabs/ui/guild/guildmemdeletewin.unity3d" --公会踢出成员确认
AssetConfig.guild_set_fresh_man_lev_win = "prefabs/ui/guild/guildsetfreshmanlevwindow.unity3d" --设置公会新秀转正等级界面
AssetConfig.guild_change_name_win = "prefabs/ui/guild/guildchangenamewindow.unity3d" --更改公会名字
AssetConfig.guild_look_name_win = "prefabs/ui/guild/guildlooknamewindow.unity3d" --查看公会名字公会名字
AssetConfig.guild_pray_win = "prefabs/ui/guild/guildpraywindow.unity3d"
AssetConfig.guild_pray_manage_panel = "prefabs/ui/guild/guildpraymanagepanel.unity3d"
AssetConfig.guild_pray_panel = "prefabs/ui/guild/guildpraypanel.unity3d"
AssetConfig.guild_apply_msg_panel = "prefabs/ui/guild/guildapplymsgwindow.unity3d"
AssetConfig.guild_pray_confirm_panel = "prefabs/ui/guild/guildprayconfirmwin.unity3d"
AssetConfig.guild_npc_exchange_fund_win = "prefabs/ui/guild/guildnpcexchangefundwin.unity3d"
--每日运势
AssetConfig.daily_horoscope_win = "prefabs/ui/dailyhoroscope/dailyhoroscopewin.unity3d" --公会踢出成员确认

--科举答题
AssetConfig.exam_question_win = "prefabs/ui/exam/examquestionwindow.unity3d" --科举答题主界面
AssetConfig.exam_question_help_win = "prefabs/ui/exam/examquestionhelpwindow.unity3d" --科举答题帮助主界面
AssetConfig.exam_my_score_win = "prefabs/ui/exam/exammyscorewin.unity3d" --科举答题主界面
AssetConfig.exam_final_win = "prefabs/ui/exam/examfinalquestionwindow.unity3d" --科举答题决赛主界面
AssetConfig.exam_final_rank_win = "prefabs/ui/exam/examfinalrankwindow.unity3d" --科举答题决赛排行榜界面
AssetConfig.exam_res = "textures/ui/exam.unity3d" --科举答题依赖资源
AssetConfig.newexamtopwindow = "prefabs/ui/exam/newexamtopwindow.unity3d" --新答题主界面
AssetConfig.newexamrankwindow = "prefabs/ui/exam/newexamrankwindow.unity3d" --新答题排行榜
AssetConfig.newexamdescwindow = "prefabs/ui/exam/newexamdescwindow.unity3d" --新答题说明界面

----巅峰对决
AssetConfig.top_compete_finish_win = "prefabs/ui/topcompete/topcompetefinishwindow.unity3d" --巅峰对决结算界面
AssetConfig.top_compete_box_win = "prefabs/ui/topcompete/topcompeteboxwin.unity3d" --宝箱
----守护
AssetConfig.shouhu_main_win = "prefabs/ui/shouhu/shouhumainwindow.unity3d" --守护主面板
AssetConfig.shouhu_main_tab1 = "prefabs/ui/shouhu/shouhumaintab1.unity3d" --守护主面板选项卡1
AssetConfig.shouhu_main_tab2 = "prefabs/ui/shouhu/shouhumaintab2.unity3d" --守护主面板选项卡2
AssetConfig.shouhu_wakeup_panel = "prefabs/ui/shouhu/shouhumainwakeuptab.unity3d" --守护星阵
AssetConfig.shouhu_success_win = "prefabs/ui/shouhu/shouhurecsuccesswindow.unity3d" --守护招募成功面板
AssetConfig.shouhu_equip_win = "prefabs/ui/shouhu/shouhuequip.unity3d" --守护装备面板
AssetConfig.shouhu_look_window =  "prefabs/ui/shouhu/shouhulookwindow.unity3d" --守护查看面板
AssetConfig.shouhu_look_equip_win = "prefabs/ui/shouhu/shouhulookequip.unity3d" --守护查看装备面板
AssetConfig.shouhu_help_change_panel = "prefabs/ui/shouhu/shouhuhelpchangepanel.unity3d"
AssetConfig.shouhu_wakeup_big_bg = "textures/ui/bigbg/shouhuwakeupbg.unity3d"
AssetConfig.shouhu_wakeup_attr_tips = "prefabs/ui/shouhu/shouhuwakeupattrtips.unity3d"
AssetConfig.shouhu_wakeup_point_tips = "prefabs/ui/shouhu/shouhuwakeuppointtips.unity3d"
AssetConfig.shouhu_get_look_view = "prefabs/ui/shouhu/getnewshouhulook.unity3d"
AssetConfig.shouhu_get_point_look_view = "prefabs/ui/shouhu/getnewshouhupointlook.unity3d"
AssetConfig.shouhu_stone_look_win = "prefabs/ui/shouhu/shouhustonelookwindow.unity3d"

--守护转换
AssetConfig.shouhu_transfer_panel = "prefabs/ui/shouhu/shouhutransfertab.unity3d"
AssetConfig.shouhu_transferlist_panel = "prefabs/ui/shouhu/shouhutransferlistpanel.unity3d"
AssetConfig.shouhu_Normal_bg = "textures/ui/bigbg/normalbg.unity3d"
AssetConfig.shouhu_texture = "textures/ui/shouhu.unity3d"


--装备强化锻造宝石
AssetConfig.equip_strength_main_win = "prefabs/ui/equipstrength/equipstrengthmainwindow.unity3d"
AssetConfig.equip_strength_tab1 = "prefabs/ui/equipstrength/strengthtab.unity3d"
AssetConfig.equip_strength_tab2 = "prefabs/ui/equipstrength/stonetab.unity3d"
AssetConfig.equip_strength_role = "prefabs/ui/equipstrength/equiprolecon.unity3d"
AssetConfig.equip_strength_build = "prefabs/ui/equipstrength/equipbuildcon.unity3d"
AssetConfig.equip_strength_con = "prefabs/ui/equipstrength/equipstrengthcon.unity3d"
AssetConfig.equip_strength_material_win = "prefabs/ui/equipstrength/equipluckwindow.unity3d"
AssetConfig.equip_strength_stone_look_win = "prefabs/ui/equipstrength/equipstonelookwindow.unity3d"
AssetConfig.equip_strength_stone_buy_win = "prefabs/ui/equipstrength/quickbuycon.unity3d"
AssetConfig.equip_strength_hero_stone_buy_win = "prefabs/ui/equipstrength/quickbuyherocon.unity3d"
AssetConfig.equip_strength_prop_transform_win = "prefabs/ui/equipstrength/equipproptransformwindow.unity3d"
AssetConfig.equip_strength_trans_right_con = "prefabs/ui/equipstrength/equptransrightcon.unity3d"
AssetConfig.equip_strength_dianhua_con = "prefabs/ui/equipstrength/equipdianhuacon.unity3d"
AssetConfig.equip_strength_dianhua_look_win = "prefabs/ui/equipstrength/equipdianhualookwindow.unity3d"
AssetConfig.equip_strength_dianhua_book_win = "prefabs/ui/equipstrength/equipdianhuabookwindow.unity3d"
AssetConfig.equip_strength_dianhua_get_win = "prefabs/ui/equipstrength/equipdianhuagetshenqiwindow.unity3d"
AssetConfig.equip_strength_dianhua_badge_panel = "prefabs/ui/equipstrength/dianhuabadgepanel.unity3d"
AssetConfig.equip_strength_dianhua_share_panel = "prefabs/ui/equipstrength/dianhuabadgetips.unity3d"
AssetConfig.equip_strength_dianhua_badge_tips_panel = "prefabs/ui/equipstrength/dianhuabadgetips.unity3d"
AssetConfig.equip_strength_dianhua_badges = "textures/equipbadge.unity3d"
AssetConfig.equip_strength_res = "textures/ui/equipstrength.unity3d" --公会依赖资源
AssetConfig.equip_strength_buy_panel = "prefabs/ui/equipstrength/strengthquickbuypanel.unity3d"
AssetConfig.appoint_effect_window = "prefabs/ui/equipstrength/appointeffectwindow.unity3d"

--星辰乐园
AssetConfig.starpark_main_window = "prefabs/ui/starpark/starparkmainwindow.unity3d"
AssetConfig.starpark_pumpkin_panel = "prefabs/ui/starpark/starparkpumpkinpanel.unity3d"
AssetConfig.starpark_pumpkin_bg = "prefabs/ui/bigatlas/starparkpumpkin.unity3d"
AssetConfig.starpark_pumpkin_bg1 = "prefabs/ui/bigatlas/starparkpumpkin1.unity3d"
AssetConfig.starpark_animal_chess = "prefabs/ui/bigatlas/starparkanimalchess.unity3d"
AssetConfig.starpark_dragon_chess = "prefabs/ui/bigatlas/starparkdragonchess.unity3d"
AssetConfig.starpark_texture = "textures/ui/starpark.unity3d"

--时装
AssetConfig.fashion_window = "prefabs/ui/fashion/fashionwin.unity3d"
AssetConfig.fashion_suit_tab = "prefabs/ui/fashion/fashionsuittab.unity3d"
AssetConfig.fashion_belt_tab = "prefabs/ui/fashion/fashionbelttab.unity3d"
AssetConfig.fashionweapontab = "prefabs/ui/fashion/fashionweapontab.unity3d"
AssetConfig.fashion_belt_confirm_win = "prefabs/ui/fashion/fashionbeltconfirmpanel.unity3d"
AssetConfig.fashion_open_win = "prefabs/ui/fashion/fashionopenwindow.unity3d"
AssetConfig.weapon_fashion_open_win = "prefabs/ui/fashion/weaponfashionopenwindow.unity3d"
AssetConfig.fashion_facescore = "prefabs/ui/fashion/fashionfacescorelevupwin.unity3d"
AssetConfig.fashion_facereward = "prefabs/ui/fashion/fashionfacemorerewardwin.unity3d"
AssetConfig.weaponfashionpreviewwindow = "prefabs/ui/fashion/weaponfashionpreviewwindow.unity3d"

--炼化
AssetConfig.alchemy_window = "prefabs/ui/alchemy/alchemywindow.unity3d"
AssetConfig.alchemy_item_window = "prefabs/ui/alchemy/alchemyitemwindow.unity3d"
AssetConfig.alchemy_confirm_win = "prefabs/ui/alchemy/alchemyconfirmwin.unity3d" --公会踢出成员确认

AssetConfig.mainui_canvas = "prefabs/ui/mainui/mainuicanvas.unity3d" -- 主界面Canvas
AssetConfig.basefunctioniconarea = "prefabs/ui/mainui/basefunctioniconarea.unity3d" -- 主界面图标
AssetConfig.roleinfoarea = "prefabs/ui/mainui/roleinfoarea.unity3d" -- 主界面 人物头像
AssetConfig.petinfoarea = "prefabs/ui/mainui/petinfoarea.unity3d" -- 主界面 宠物头像
AssetConfig.worldmaparea = "prefabs/ui/mainui/worldmaparea.unity3d" -- 主界面 地图
AssetConfig.exparea = "prefabs/ui/mainui/exparea.unity3d" -- 主界面 经验
AssetConfig.playerselect = "prefabs/ui/mainui/selecticon.unity3d" -- 主界面 经验
AssetConfig.systemarea = "prefabs/ui/mainui/systemarea.unity3d" -- 主界面 系统信息
AssetConfig.clicknpcpanel = "prefabs/ui/mainui/clicknpcpanel.unity3d" -- 主界面 选择npc面板

AssetConfig.pet_window = "prefabs/ui/pet/petwindow.unity3d" -- 宠物窗口
AssetConfig.pet_window_headbar = "prefabs/ui/pet/petwindow_headbar.unity3d" -- 宠物窗口 头像栏
AssetConfig.pet_window_base = "prefabs/ui/pet/petwindow_base.unity3d" -- 宠物窗口 信息面板
AssetConfig.pet_window_wash = "prefabs/ui/pet/petwindow_wash.unity3d" -- 宠物窗口 洗髓面板
AssetConfig.pet_window_manual = "prefabs/ui/pet/petwindow_manual.unity3d" -- 宠物窗口 图鉴面板
AssetConfig.pet_stone_mark_panel = "prefabs/ui/pet/petstonemarkwindow.unity3d" --宠物符石刻印
AssetConfig.pet_skin_window = "prefabs/ui/pet/petskinwindow.unity3d" -- 宠物皮肤窗口
AssetConfig.getpetskin = "prefabs/ui/pet/getpetskin.unity3d" -- 宠物皮肤窗口
AssetConfig.petfusewindow = "prefabs/ui/pet/petfusewindow.unity3d" -- 宠物合成窗口
AssetConfig.petskinpreviewwindow = "prefabs/ui/pet/petskinpreviewwindow.unity3d" -- 宠物图鉴皮肤预览界面
AssetConfig.petskillselect = "prefabs/ui/pet/petskillselect.unity3d" -- 宠物技能选择/重置界面

AssetConfig.petskinwindow_bg = "textures/ui/bigbg/childskinbg.unity3d"
AssetConfig.petskinwindow_bg1 = "textures/ui/bigbg/childskinbg1.unity3d"
AssetConfig.petskinwindow_bg2 = "textures/ui/bigbg/childskinbg2.unity3d"

--宠物内丹
AssetConfig.petrunepanel_bg = "textures/ui/bigbg/petrunepanelbg.unity3d"
AssetConfig.petquickshowrunepanel_bg = "textures/ui/bigbg/petquickshowrunepanelbg.unity3d"
AssetConfig.petresonancesrunepanel_bg = "textures/ui/bigbg/petresonancesrunepanelbg.unity3d"

AssetConfig.petrunestudypanel = "prefabs/ui/pet/petrunestudypanel.unity3d"  --内丹学习 
AssetConfig.petsavvyrunepanel = "prefabs/ui/pet/petsavvyrunepanel.unity3d"  --内丹领悟 
AssetConfig.petresonancesrunepanel = "prefabs/ui/pet/petresonancerunepanel.unity3d"  --内丹共鸣





AssetConfig.petspiritwindow = "prefabs/ui/pet/petspiritwindow.unity3d" -- 宠物附灵界面
AssetConfig.petspiritselectpanel = "prefabs/ui/pet/petspiritselectpanel.unity3d" -- 宠物附灵选择宠物界面
AssetConfig.petspiritsuccesspanel = "prefabs/ui/pet/petspiritsuccesspanel.unity3d" -- 宠物附灵选择宠物界面
AssetConfig.childskinwindow = "prefabs/ui/pet/childskinwindow.unity3d"	--子女皮肤界面

AssetConfig.selectpetwindow = "prefabs/ui/pet/selectpetwindow.unity3d" -- 选择宠物窗口

AssetConfig.pet_skill_window = "prefabs/ui/pet/learnskillpanel.unity3d" -- 宠物学习技能窗口

AssetConfig.pet_feed_window = "prefabs/ui/pet/petfeedwindow.unity3d" -- 宠物喂养窗口
AssetConfig.petchildspiritwindow = "prefabs/ui/pet/petchildspiritwindow.unity3d" -- 宠物附灵界面
AssetConfig.pet_feed_window_happy = "prefabs/ui/pet/petfeedhappy.unity3d" -- 宠物喂养窗口 快乐值
AssetConfig.pet_feed_window_quality = "prefabs/ui/pet/petfeedquality.unity3d" -- 宠物喂养窗口 资质

AssetConfig.pet_gen_window = "prefabs/ui/pet/petgemwindow.unity3d" -- 宠物符石窗口
AssetConfig.pet_upgrade_window = "prefabs/ui/pet/petupgradewindow.unity3d" -- 宠物进阶窗口
AssetConfig.pet_child_upgrade_window = "prefabs/ui/pet/petchildupgradewindow.unity3d" -- 宠物进阶窗口
AssetConfig.pet_trans_gen_panel = "prefabs/ui/pet/pettransgempanel.unity3d" -- 宠物幻化选择窗口

AssetConfig.pet_quickshow_window = "prefabs/ui/pet/petquickshow.unity3d" -- 宠物查看窗口
AssetConfig.pet_genwash_window = "prefabs/ui/pet/petgenwash.unity3d" -- 宠物符石技能洗炼窗口
AssetConfig.pet_receive_window = "prefabs/ui/pet/petreceive.unity3d" -- 宠物领取
AssetConfig.pet_talk_panel = "prefabs/ui/pet/pettalksetpanel.unity3d" -- 宠物领取
AssetConfig.pet_release_panel = "prefabs/ui/pet/petreleasepanel.unity3d" -- 宠物放生确认窗口
AssetConfig.pet_stone_wash_panel = "prefabs/ui/pet/petstonewash.unity3d" -- 宠物符石洗炼窗口
AssetConfig.petgenselect = "prefabs/ui/pet/petgenselect.unity3d" -- 宠物超级符石选择窗口

AssetConfig.recommendskillpanel = "prefabs/ui/pet/recommendskillpanel.unity3d" -- 宠物技能推荐
AssetConfig.newpetwashskillwindow = "prefabs/ui/pet/newpetwashskillwindow.unity3d"

AssetConfig.petartificewindow = "prefabs/ui/pet/petartificewindow.unity3d" -- 宠物炼化
AssetConfig.petbreakwindow = "prefabs/ui/pet/petbreakwindow.unity3d" -- 宠物突破
AssetConfig.pet_wash_window = "prefabs/ui/pet/petwashwindow.unity3d" --宠物符石刻印

AssetConfig.skill_window = "prefabs/ui/skill/skillwindow.unity3d" -- 技能窗口
AssetConfig.skill_window_base = "prefabs/ui/skill/skillbase.unity3d" -- 技能窗口 人物技能面板
AssetConfig.skill_window_prac = "prefabs/ui/skill/skillprac.unity3d" -- 技能窗口 冒险技能面板
AssetConfig.skill_life = "prefabs/ui/skill/skilllife.unity3d" --生活技能入口
AssetConfig.skill_life_produce = "prefabs/ui/skill/skilllifeupwindow.unity3d"
AssetConfig.prac_skill_chestbox = "prefabs/ui/skill/chestboxwin.unity3d"
AssetConfig.prac_skill_chestbox2 = "prefabs/ui/skill/chestboxwin2.unity3d"
AssetConfig.skill_use_energy = "prefabs/ui/skill/skilluseenergy.unity3d"
AssetConfig.marryskill = "prefabs/ui/skill/marryskill.unity3d"
AssetConfig.marryskillwindow = "prefabs/ui/skill/marryskillwindow.unity3d"
AssetConfig.newmarryskillwindow = "prefabs/ui/skill/newmarryskillwindow.unity3d"
AssetConfig.skill_assist = "prefabs/ui/skill/skillassist.unity3d"

AssetConfig.finalskill_textures = "textures/ui/finalskill.unity3d"
AssetConfig.skill_final_study = "prefabs/ui/skill/finalskillstudypanel.unity3d"
AssetConfig.skill_final = "prefabs/ui/skill/finalskillpanel.unity3d"
AssetConfig.skill_final_get = "prefabs/ui/skill/finalskillgetwindow.unity3d"
AssetConfig.skill_final_preview = "prefabs/ui/skill/finalskillpreview.unity3d"
AssetConfig.final_skill_bg = "textures/ui/bigbg/finalskillbg.unity3d"
AssetConfig.light_circle = "textures/ui/bigbg/lightcircle.unity3d"
AssetConfig.skill_light = "textures/ui/bigbg/skilllight.unity3d"
AssetConfig.name_bg = "textures/ui/bigbg/namebg.unity3d"
AssetConfig.getfinalskill_title = "textures/ui/bigbg/geti18nfinalskilltitle.unity3d"

AssetConfig.exercise_textures = "textures/ui/exercise.unity3d"
AssetConfig.exercise_window = "prefabs/ui/exercise/exercisewindow.unity3d"
AssetConfig.exercise_double_window = "prefabs/ui/exercise/exercisedoublewindow.unity3d"

AssetConfig.world_boss_window = "prefabs/ui/worldboss/worldbosswin.unity3d" --世界boss主窗口
AssetConfig.world_boss_rank_window = "prefabs/ui/worldboss/worldbosskillerswin.unity3d" --世界boss排行榜

--段位赛
AssetConfig.qualifying_window = "prefabs/ui/qualify/qualifymainwindow.unity3d"
AssetConfig.qualifying_finish = "prefabs/ui/qualify/qualifyfinishwindow.unity3d"
AssetConfig.qualifying_match = "prefabs/ui/qualify/qualifymatchwindow.unity3d"
AssetConfig.qualifyBtn = "prefabs/ui/qualify/qualifyfightbtn.unity3d"
AssetConfig.qualifying_mybest = "prefabs/ui/qualify/qualifymybestwindow.unity3d"
AssetConfig.qualifying_openlock = "prefabs/ui/qualify/qualifyopenlockwindow.unity3d"
AssetConfig.qualifying_res = "textures/ui/qualify.unity3d"

--称号
AssetConfig.honor_preview_window = "prefabs/ui/honor/honorpreviewwindow.unity3d"
AssetConfig.new_honor_window = "prefabs/ui/honor/newhonorwindow.unity3d"
--autouse
AssetConfig.auto_use_win = "prefabs/ui/autouse/autouse.unity3d"

--幻境寻宝宝箱
AssetConfig.fairy_land_box_win = "prefabs/ui/fairyland/fairylandboxwin.unity3d"
AssetConfig.fairy_land_letter_win = "prefabs/ui/fairyland/fairylandtipswindow.unity3d"
AssetConfig.fairy_landkey_tipswin = "prefabs/ui/fairyland/fairylandkeytipswin.unity3d"
AssetConfig.fairylandluckdrawwindow = "prefabs/ui/fairyland/fairylandluckdrawwindow.unity3d"

--结算面板预设
AssetConfig.finish_count_box_win = "prefabs/ui/finishcount/finishcountboxwin.unity3d"
AssetConfig.finish_count_reward_win = "prefabs/ui/finishcount/finishrewardwin.unity3d"

-- textures
AssetConfig.base_textures = "textures/ui/base.unity3d"
AssetConfig.basecompress_textures = "textures/ui/basecompress.unity3d"
AssetConfig.mainui_textures = "textures/ui/mainui.unity3d"
AssetConfig.guild_dep_res = "textures/ui/guild.unity3d" --公会依赖资源
AssetConfig.guild_activity_icon = "textures/guild/activityicon.unity3d"
AssetConfig.guild_pray_icon = "textures/guild/prayicon.unity3d"
AssetConfig.guild_build_icon = "textures/guild/buildicon.unity3d"
AssetConfig.guild_element_icon = "textures/guild/element.unity3d"
AssetConfig.guild_totem_icon = "textures/guild/totem.unity3d"
AssetConfig.honor_img = "textures/honor.unity3d"
AssetConfig.pet_textures = "textures/ui/pet.unity3d"
AssetConfig.headother_textures = "textures/headother.unity3d"
AssetConfig.headother_textures2 = "textures/headother2.unity3d"
AssetConfig.rank_textures = "textures/ui/rank.unity3d"
AssetConfig.eyou_activity_textures = "textures/ui/eyou.unity3d"

AssetConfig.big_buff_icon = "textures/bigbufficon.unity3d"

AssetConfig.backpack_main = "prefabs/ui/backpack/backpackwindow.unity3d" --背包主界面
AssetConfig.backpack_item = "prefabs/ui/backpack/backpackitems.unity3d" --背包道具
AssetConfig.backpack_grid = "prefabs/ui/backpack/backpackgrids.unity3d" --背包格子
AssetConfig.backpack_role = "prefabs/ui/backpack/backpackequipment.unity3d" --背包角色
AssetConfig.backpack_attr = "prefabs/ui/backpack/backpackattribute.unity3d"
AssetConfig.backpack_wings = "prefabs/ui/backpack/backpackwings.unity3d"    -- 翅膀页面
AssetConfig.backpack_character = "prefabs/ui/backpack/backpackcharacter.unity3d" --角色信息界面
AssetConfig.backpack_info = "prefabs/ui/backpack/backpackinfomation.unity3d" --角色信息界面
AssetConfig.wing_tips = "prefabs/ui/backpack/wingtips.unity3d"              -- 翅膀tips
AssetConfig.wing_info_window = "prefabs/ui/wings/winginfowindow.unity3d"              -- 翅膀tips
AssetConfig.wing_option_confirm_window = "prefabs/ui/wings/wingoptionconfirmwindow.unity3d" --翅膀技能方案切换确定
AssetConfig.wingawakenwindow = "prefabs/ui/wings/wingawakenwindow.unity3d" --翅膀觉醒技能
AssetConfig.quickbackpackwindow = "prefabs/ui/backpack/quickbackpackwindow.unity3d" --快速9格小背包界面

AssetConfig.attr_icon = "textures/attricon.unity3d"--属性图标
AssetConfig.infoicon_textures = "textures/infoicon.unity3d"--操作提示图标
AssetConfig.chat_window_res = "textures/ui/chat.unity3d"
AssetConfig.chat_prefix = "textures/ui/chatprefix.unity3d"
AssetConfig.shop_textures = "textures/ui/shop.unity3d"
AssetConfig.numberpad_textures = "textures/ui/numberpad.unity3d"

--端午相关 Dragon Boat Festival
AssetConfig.dragonboat_textures = "textures/ui/dragonboat.unity3d"
AssetConfig.dragonboat_consumebg = "prefabs/ui/bigatlas/dragonboatbg0.unity3d"
AssetConfig.dragonboat_consumebg2 = "prefabs/ui/bigatlas/dragonboatbg2.unity3d"
AssetConfig.dragonboat_consumertn_panel = "prefabs/ui/dragonboatfestival/dragonboatconsmrtnpanel.unity3d"
AssetConfig.fastskiingtitle = "prefabs/ui/bigatlas/fastskiingtitle2.unity3d"
AssetConfig.goodcourtesytitle = "prefabs/ui/bigatlas/goodcourtesytitle.unity3d"
AssetConfig.dragonboat_topbg = "prefabs/ui/bigatlas/warmerlabatopbg.unity3d"
AssetConfig.dragonboat_topimage1 = "textures/ui/bigbg/warmertxt1.unity3d"
AssetConfig.dragonboat_topimage2 = "textures/ui/bigbg/warmertxt2.unity3d"
AssetConfig.dragonboat_topimage2 = "textures/ui/bigbg/warmertxt2.unity3d"
AssetConfig.quickbuybg_textures = "prefabs/ui/bigatlas/quickbuybg.unity3d"
AssetConfig.fastskiingi18n = "textures/ui/bigbg/fastskiingi18n.unity3d"


AssetConfig.bufficon = "textures/combat/bufficon.unity3d"
AssetConfig.skill_shout = "textures/combat/skillshout.unity3d"
AssetConfig.combat_texture = "textures/ui/combat.unity3d"
AssetConfig.combat2_texture = "textures/ui/combat2.unity3d"
AssetConfig.combat_mapui = "prefabs/ui/combat/combatmap.unity3d"
AssetConfig.combat_totem = "prefabs/ui/combat/combattotem.unity3d"
AssetConfig.combat_skillareaPath = "prefabs/ui/combat/combatskillarea.unity3d"
AssetConfig.combat_headinfoareaPath = "prefabs/ui/combat/combatheadinfoarea.unity3d"
AssetConfig.combat_counterinfoareaPath = "prefabs/ui/combat/combatcounterinfoarea.unity3d"
AssetConfig.combat_mixareaPath = "prefabs/ui/combat/combatmixarea.unity3d"
AssetConfig.combat_functioniconPath = "prefabs/ui/combat/combatfunctioniconarea.unity3d"
AssetConfig.combat_mainPanelPath = "prefabs/ui/combat/combatpanel.unity3d"
AssetConfig.combat_uires = "textures/ui/combat.unity3d"
AssetConfig.combat_cd_effect = "prefabs/effect/20065.unity3d"
AssetConfig.combat_extend_path = "prefabs/ui/combat/combatextendpanel.unity3d"
AssetConfig.combat_summon_path = "prefabs/ui/combat/combatsummonpetpanel.unity3d"
AssetConfig.combat_itempanel_path = "prefabs/ui/combat/combatitempanel.unity3d"
AssetConfig.transition = "prefabs/ui/combat/transition.unity3d"
AssetConfig.combat_failedwin = "prefabs/ui/combat/combatfailed.unity3d"
AssetConfig.combat_questionwindow = "prefabs/ui/combat/combatquestionwindow.unity3d"

AssetConfig.maxnumber_3 = "textures/bignum/maxnum3.unity3d"
AssetConfig.maxnumber_4 = "textures/bignum/maxnum4.unity3d"
AssetConfig.maxnumber_5 = "textures/bignum/maxnum5.unity3d"
AssetConfig.maxnumber_6 = "textures/bignum/maxnum6.unity3d"
AssetConfig.maxnumber_7 = "textures/bignum/maxnum7.unity3d"
AssetConfig.maxnumber_8 = "textures/bignum/maxnum8.unity3d"
AssetConfig.maxnumber_9 = "textures/bignum/maxnum9.unity3d"
AssetConfig.maxnumber_10 = "textures/bignum/maxnum10.unity3d"
AssetConfig.maxnumber_11 = "textures/bignum/maxnum11.unity3d"
AssetConfig.maxnumber_12 = "textures/bignum/maxnum12.unity3d"
AssetConfig.maxnumber_13 = "textures/bignum/maxnum13.unity3d"
AssetConfig.maxnumber_14 = "textures/bignum/maxnum14.unity3d"
AssetConfig.maxnumber_15 = "textures/bignum/maxnum15.unity3d"
AssetConfig.minnumber_1 = "textures/bignum/minnum1.unity3d"
AssetConfig.maxnumber_str = "textures/bignum/maxstr.unity3d"

AssetConfig.guard_head = "textures/guard/shhead.unity3d"
AssetConfig.guard_couplet = "textures/guard/shcouplet.unity3d"

AssetConfig.slot_res = "textures/ui/slot.unity3d"
AssetConfig.slot_item = "prefabs/ui/slot/itemslot.unity3d"--道具格子预设
AssetConfig.slot_skill = "prefabs/ui/slot/skillslot.unity3d"--技能格子预设
AssetConfig.itemicon = "textures/itemicon.unity3d"--道具图标
AssetConfig.itemicon2 = "textures/itemicon2.unity3d"--道具图标
AssetConfig.itemicon3 = "textures/itemicon3.unity3d"--道具图标
AssetConfig.itemicon4 = "textures/itemicon4.unity3d"--道具图标
AssetConfig.itemicon5 = "textures/itemicon5.unity3d"--道具图标
AssetConfig.itemicon6 = "textures/itemicon6.unity3d"--道具图标
AssetConfig.itemicon7 = "textures/itemicon7.unity3d"--道具图标
AssetConfig.itemicon8 = "textures/itemicon8.unity3d"--道具图标
AssetConfig.equipicon = "textures/itemiconequip.unity3d"--装备图标

-- 图标散文件
AssetConfig.itemiconSingle = "textures/singleicon/itemicon/%s.unity3d"--道具图标
AssetConfig.itemiconSingle2 = "textures/singleicon/itemicon2/%s.unity3d"--道具图标
AssetConfig.itemiconSingle3 = "textures/singleicon/itemicon3/%s.unity3d"--道具图标
AssetConfig.itemiconSingle4 = "textures/singleicon/itemicon4/%s.unity3d"--道具图标
AssetConfig.itemiconSingle5 = "textures/singleicon/itemicon5/%s.unity3d"--道具图标
AssetConfig.itemiconSingle6 = "textures/singleicon/itemicon6/%s.unity3d"--道具图标
AssetConfig.itemiconSingle7 = "textures/singleicon/itemicon7/%s.unity3d"--道具图标
AssetConfig.itemiconSingle8 = "textures/singleicon/itemicon8/%s.unity3d"--道具图标
AssetConfig.equipiconSingle = "textures/singleicon/itemiconequip/%s.unity3d"--装备图标

AssetConfig.singleothericon = "textures/singleothericon/%s.unity3d"--其它单图

AssetConfig.heads = "textures/heads.unity3d"
AssetConfig.smallheads = "textures/smallheads.unity3d"
AssetConfig.market_textures = "textures/ui/market.unity3d"      -- 市场资源
AssetConfig.addpoint = "prefabs/ui/addpoint/addpoint.unity3d"--宠物角色加点

AssetConfig.tips_canvas = "prefabs/ui/tips/tipscanvas.unity3d" --tips容器
AssetConfig.tips_item = "prefabs/ui/tips/itemtips.unity3d" --道具tips
AssetConfig.tips_equip = "prefabs/ui/tips/equiptips.unity3d" --装备tips
AssetConfig.tips_general = "prefabs/ui/tips/generaltips.unity3d" --通用文字tips
AssetConfig.tips_general_btn = "prefabs/ui/tips/generalbtntips.unity3d" --通用文字加按钮tips
AssetConfig.tips_title = "prefabs/ui/tips/titletips.unity3d" --通用文字tips, 带标题
AssetConfig.tips_petequip = "prefabs/ui/tips/petequiptips.unity3d" --宠物装备tips
AssetConfig.tips_skill = "prefabs/ui/tips/skilltips.unity3d" --技能tips
AssetConfig.tips_player = "prefabs/ui/tips/playertips.unity3d" --技能tips
AssetConfig.tips_wing = "prefabs/ui/tips/wingtips.unity3d" --翅膀tips
AssetConfig.tips_fruit = "prefabs/ui/tips/fruittips.unity3d" -- 果实tips
AssetConfig.tips_fruit_new = "prefabs/ui/tips/newfruittips.unity3d" -- 果实tips
AssetConfig.tips_ride_skill = "prefabs/ui/tips/rideskilltips.unity3d" -- 坐骑技能tips
AssetConfig.tips_ride_equip = "prefabs/ui/tips/rideequiptips.unity3d" -- 坐骑装备tips
AssetConfig.tips_rune = "prefabs/ui/tips/runetips.unity3d" --宠物内丹tips
AssetConfig.mainuitrace = "prefabs/ui/teamquest/teamandquestarea.unity3d"
AssetConfig.teamquest ="textures/ui/teamquest.unity3d"
AssetConfig.teamquestshowequippanel = "prefabs/ui/teamquest/teamquestshowequippanel.unity3d" --新手装备展示面板

AssetConfig.dialog = "prefabs/ui/dialog/dialogwindow.unity3d"
AssetConfig.dialog_res = "textures/ui/dialog.unity3d"

AssetConfig.skill_life_icon = "textures/skill/lifeskillicon.unity3d"
AssetConfig.skill_life_name = "textures/skill/lifeskillname.unity3d"
AssetConfig.skill_life_shovel_bg = "textures/skill/lifeshovelbg.unity3d"

AssetConfig.pet_love_talk_panel = "prefabs/ui/petlove/petlovetalk.unity3d"

AssetConfig.drama_canvas = "prefabs/ui/drama/dramacanvas.unity3d"
AssetConfig.drama_btn = "prefabs/ui/drama/dramabutton.unity3d"
AssetConfig.drama_talk = "prefabs/ui/drama/dramatalk.unity3d"
AssetConfig.agenda = "prefabs/ui/agenda/agendawindow.unity3d"
AssetConfig.agenda_clander = "prefabs/ui/agenda/clander.unity3d"
AssetConfig.dailyicon = "textures/dailyicon.unity3d"
AssetConfig.dungeonname = "textures/dungeon/dungeonname.unity3d"
AssetConfig.agenda_textures = "textures/ui/agenda.unity3d"
AssetConfig.agendaweekrewardpanel = "prefabs/ui/agenda/agendaweekrewardpanel.unity3d"
AssetConfig.agendaweekreward_textures = "textures/ui/agendaweekreward.unity3d"

AssetConfig.dungeonroll = "prefabs/ui/dungeon/rollwindow.unity3d"
AssetConfig.dungeonend = "prefabs/ui/dungeon/dungeonendwin.unity3d"
AssetConfig.towerend = "prefabs/ui/dungeon/towerendwin.unity3d"
AssetConfig.world_boss_head_icon = "textures/worldboss/worldbosshead.unity3d"
AssetConfig.teamwindow = "prefabs/ui/team/team.unity3d"
AssetConfig.teamres = "textures/ui/team.unity3d"
AssetConfig.teambutton = "prefabs/ui/team/teambuttonarea.unity3d"
AssetConfig.teamlist = "prefabs/ui/team/teamlist.unity3d"
AssetConfig.teammember = "prefabs/ui/team/teammembers.unity3d"
AssetConfig.teamoption = "prefabs/ui/team/teamoption.unity3d"
AssetConfig.formationoption = "prefabs/ui/team/formationoption.unity3d"
AssetConfig.teamchangeguard = "prefabs/ui/team/teamchangeguard.unity3d"
AssetConfig.formation = "prefabs/ui/team/formation.unity3d"
AssetConfig.formation_icon = "textures/formationicon.unity3d"
AssetConfig.formationlearn = "prefabs/ui/team/formtionlearn.unity3d"
AssetConfig.towerreward = "prefabs/ui/dungeon/towerwindow.unity3d"
AssetConfig.qualifying_lev_icon = "textures/qualifylevicon.unity3d"
AssetConfig.wing_quality_icon = "textures/wingqualityicon.unity3d"
AssetConfig.friend_window = "prefabs/ui/friend/friendwin.unity3d"
AssetConfig.friendpush_window = "prefabs/ui/friend/friendpushwin.unity3d"
AssetConfig.friendselect = "prefabs/ui/friend/friendselect.unity3d"
AssetConfig.friendselectpanel = "prefabs/ui/friend/friendselectpanel.unity3d"
AssetConfig.friendawardoffermedalpanel = "prefabs/ui/friend/friendawardoffermedalpanel.unity3d" --悬赏任务给队长颁发奖章界面
AssetConfig.worldmap_window = "prefabs/ui/worldmap/worldmapwindow.unity3d"
AssetConfig.minimaps_worldmap = "textures/maps/minimaps/worldmap.unity3d"
AssetConfig.minimaps = "textures/maps/minimaps/%s.unity3d"
AssetConfig.dungeon_clear_buff = "prefabs/ui/dungeon/dungeonclearbuff.unity3d"

AssetConfig.zone_window = "prefabs/ui/zone/zonemywin.unity3d"
AssetConfig.zone_textures = "textures/ui/zone.unity3d"
AssetConfig.buy_notify = "prefabs/ui/buybutton/buynotify.unity3d"
AssetConfig.zonegiftsetpanel = "prefabs/ui/zone/zonegiftsetpanel.unity3d"
AssetConfig.zoneinfosetpanel = "prefabs/ui/zone/zoneinfosetpanel.unity3d"
AssetConfig.buy_button = "prefabs/ui/buybutton/buybutton.unity3d"
AssetConfig.arena_window = "prefabs/ui/arena/arenawindow.unity3d"   -- 竞技场
AssetConfig.arena_fight_panel = "prefabs/ui/arena/arenafight.unity3d"
AssetConfig.arena_rank_panel = "prefabs/ui/arena/arenarank.unity3d"
AssetConfig.arena_guild_tips = "prefabs/ui/arena/guildtips.unity3d"
AssetConfig.arena_textures = "textures/ui/arena.unity3d"
AssetConfig.arena_victory_window = "prefabs/ui/arena/treasureraffle.unity3d"    -- 胜利之路
AssetConfig.arenasettlementwindow = "prefabs/ui/arena/arenasettlementwindow.unity3d"    -- 竞技场结算
AssetConfig.improvewin = "prefabs/ui/improve/improvewin.unity3d"

AssetConfig.trialwindow = "prefabs/ui/trial/trialwindow.unity3d"
AssetConfig.trial_textures = "textures/ui/trial.unity3d"

AssetConfig.shiptextures = "textures/ui/shipping.unity3d"
AssetConfig.shippingwin = "prefabs/ui/shipping/shippingwindow.unity3d"
AssetConfig.shipwin = "prefabs/ui/shipping/shipwindow.unity3d"
AssetConfig.shiphelpwin = "prefabs/ui/shipping/shiphelpwindow.unity3d"
AssetConfig.shiptohelpwin = "prefabs/ui/shipping/tohelpwindow.unity3d"
AssetConfig.bible_window = "prefabs/ui/bible/biblewindow.unity3d"
AssetConfig.bible_welfare_panel = "prefabs/ui/bible/welfarepanel.unity3d"
AssetConfig.bible_real_name_panel = "prefabs/ui/bible/realnamepanel.unity3d"
AssetConfig.bible_grow_panel = "prefabs/ui/bible/growguidepanel.unity3d"
AssetConfig.bible_invest_panel = "prefabs/ui/bible/investpanel.unity3d"
AssetConfig.downloadnewapkpanel = "prefabs/ui/bible/downloadnewapkpanel.unity3d"
AssetConfig.bible_textures = "textures/ui/bible.unity3d"
AssetConfig.bible_warm_tips_panel = "prefabs/ui/bible/biblewarmtipspanel.unity3d"
AssetConfig.bible_daily_gift_panel = "prefabs/ui/bible/dailygiftpanel.unity3d"
AssetConfig.bible_daily_gfit_bg1 = "textures/ui/bigbg/dailygiftbg.unity3d"
AssetConfig.bible_daily_gfit_bg2 = "textures/ui/bigbg/dailygiftbigbg.unity3d"
AssetConfig.givepresentwin = "prefabs/ui/gift/givewindow.unity3d"

AssetConfig.qr_code_panel = "prefabs/ui/bible/qrcodepanel.unity3d"
AssetConfig.qrcodebigbg = "prefabs/ui/bigatlas/qrcodebigbg.unity3d"
AssetConfig.qrcodetxt = "prefabs/ui/bigatlas/ti18n_qrcodetxt.unity3d"

AssetConfig.public_number_panel = "prefabs/ui/bible/publicnumebrpanel.unity3d"
AssetConfig.public_number_panel_bgi18n = "prefabs/ui/bigatlas/publicnumberbgi18n.unity3d"

AssetConfig.fashion_big_icon  = "textures/fashion/fashionbigicon.unity3d" --时装
AssetConfig.fashion_big_icon2  = "textures/fashion/fashionbigicon2.unity3d" --时装

AssetConfig.treasuremap_compass = "prefabs/ui/treasuremap/compass.unity3d"
AssetConfig.treasuremapwindow = "prefabs/ui/treasuremap/treasuremapwindow.unity3d"
AssetConfig.treasureexchangewindow = "prefabs/ui/treasuremap/treasureexchangewindow.unity3d"
AssetConfig.guidetaskicon = "textures/guidetaskicon.unity3d"

AssetConfig.i18nlogotxt = "textures/ui/startpage/i18nlogotxt.unity3d"
AssetConfig.loading_page_bg = "textures/ui/startpage/loading_page_bg.unity3d"

AssetConfig.glorywindow = "prefabs/ui/glory/glorywindow.unity3d"
AssetConfig.glory_confirm_window = "prefabs/ui/glory/gloryconfirmwindow.unity3d"
AssetConfig.glory_textures = "textures/ui/glory.unity3d"
AssetConfig.glory_skill_dialog = "prefabs/ui/backpack/gloryskillchoose.unity3d"
AssetConfig.glory_video = "prefabs/ui/glory/gloryvideorank.unity3d"
AssetConfig.glory_attr = "prefabs/ui/glory/gloryattrshowpanel.unity3d"
AssetConfig.glory_fight = "prefabs/ui/glory/gloryfightpanel.unity3d"

AssetConfig.glorybeforefight = "prefabs/ui/glory/glorybeforefight.unity3d"
AssetConfig.glorynewrecord = "prefabs/ui/glory/glorynewrecord.unity3d"
AssetConfig.glorynewrecord_bg_title = "prefabs/ui/bigatlas/uptitlei18n.unity3d"
AssetConfig.glorynewrecord_bg_effect = "prefabs/ui/bigatlas/effectbg.unity3d"


AssetConfig.autofarmwindow = "prefabs/ui/autofarm/autofarmwin.unity3d"
AssetConfig.autofarmbuttonarea = "prefabs/ui/autofarm/autofarmbuttonarea.unity3d"
AssetConfig.autofarm_textures = "textures/ui/autofarm.unity3d"
AssetConfig.fusewindow = "prefabs/ui/fuse/fusewindow.unity3d"

AssetConfig.godanimal_window = "prefabs/ui/godanimal/godanimalwindow.unity3d"
AssetConfig.godanimal_change_window = "prefabs/ui/godanimal/godanimalchangewindow.unity3d"
AssetConfig.warriorMainUIPanel = "prefabs/ui/warrior/warriorscoreboardpanel.unity3d"
AssetConfig.warriorRankWindow = "prefabs/ui/warrior/warriorwindow.unity3d"
AssetConfig.warriorSettleWindow = "prefabs/ui/warrior/warriorsettlewindow.unity3d"
AssetConfig.warrior_textures = "textures/ui/warrior.unity3d"
AssetConfig.face_res = "textures/face.unity3d"
AssetConfig.face_special_res = "textures/specialface.unity3d"

AssetConfig.exchange_panel = "prefabs/ui/exchange/exchangepanel.unity3d"
AssetConfig.exchange_window = "prefabs/ui/exchange/exchangewindow.unity3d"
AssetConfig.exchange_textures = "textures/ui/exchange.unity3d"
AssetConfig.dropicon = "textures/dropicon.unity3d"
AssetConfig.quickdiamonbuypanel = "prefabs/ui/shop/quickbuypanel.unity3d"

AssetConfig.wings_handbook_window = "prefabs/ui/wings/wingshandbookwindow.unity3d"
AssetConfig.role_rename_panel = "prefabs/ui/backpack/renamepanel.unity3d"

AssetConfig.classes_challenge_my_score_win = "prefabs/ui/classeschallenge/classeschallengemyscorewin.unity3d" --职业挑战排名界面
AssetConfig.chief_challenge_win = "prefabs/ui/classeschallenge/chiefchallengewin.unity3d"
AssetConfig.chief_challenge_textures = "textures/ui/chiefchallenge.unity3d"


AssetConfig.scenetalk = "prefabs/ui/scenetalk/scenetalk.unity3d"
AssetConfig.scenebtn = "prefabs/ui/scenetalk/scenebtn.unity3d"
AssetConfig.sceneblood = "prefabs/ui/scenetalk/sceneblood.unity3d"
AssetConfig.firstrecharge_window = "prefabs/ui/firstrecharge/firstrechargewindow.unity3d"
AssetConfig.buffpanel = "prefabs/ui/buffpanel/buffpanel.unity3d"
AssetConfig.satiation_window = "prefabs/ui/buffpanel/satiationwindow.unity3d"
AssetConfig.prewarpanel = "prefabs/ui/buffpanel/prewarpanel.unity3d"
AssetConfig.setting = "prefabs/ui/settingwindow/settingwindow.unity3d"
AssetConfig.normalbufficon = "textures/normalbufficon.unity3d"
AssetConfig.glyphsquickbackpackwindow = "prefabs/ui/buffpanel/glyphsquickbackpackwindow.unity3d"

AssetConfig.mainuinotice = "prefabs/ui/mainui/mainuinotice.unity3d"
AssetConfig.mainuichallange = "prefabs/ui/mainui/mainuichallange.unity3d"

AssetConfig.guildinvitewaterpanel = "prefabs/ui/guild/guildinvitewaterpanel.unity3d"
AssetConfig.bible_brew_panel = "prefabs/ui/bible/brewpanel.unity3d"
AssetConfig.store_window = "prefabs/ui/store/storewindow.unity3d"
AssetConfig.toolstoreitems_panel = "prefabs/ui/store/toolstoreitems.unity3d"
AssetConfig.petstoreitems_panel = "prefabs/ui/store/petstoreitems.unity3d"

-- AssetConfig.achievementwindow = "prefabs/ui/achievement/achievementwindow.unity3d"
AssetConfig.achievementpanel = "prefabs/ui/achievement/achievementpanel.unity3d"
AssetConfig.achievementnotice = "prefabs/ui/achievement/achievementnotice.unity3d"
AssetConfig.achievementtips = "prefabs/ui/achievement/achievementtips.unity3d"
AssetConfig.achievementshopbuypanel = "prefabs/ui/achievement/achievementshopbuypanel.unity3d"
AssetConfig.achievementshopselectpanel = "prefabs/ui/achievement/achievementshopselectpanel.unity3d"
AssetConfig.achievementshopwindow = "prefabs/ui/achievement/achievementshopwindow.unity3d"
AssetConfig.achievementBadgeTips = "prefabs/ui/achievement/achievementbadgetips.unity3d"
AssetConfig.achievementdetailspanel = "prefabs/ui/achievement/achievementdetailspanel.unity3d"
AssetConfig.achievement_textures = "textures/ui/achievement.unity3d"

AssetConfig.questwindow = "prefabs/ui/task/taskwindow.unity3d"
AssetConfig.questdramawindow = "prefabs/ui/taskdrama/dramataskwindow.unity3d"
AssetConfig.auto_mode_select_window = "prefabs/ui/task/taskautomodeselectwindow.unity3d" -- by 嘉俊 2017/8/28 17:21

AssetConfig.springfestival_texture = "textures/ui/springfestival.unity3d"

AssetConfig.marry_textures = "textures/ui/marry.unity3d"
AssetConfig.marry_propose_window = "prefabs/ui/marry/marry_propose_window.unity3d"
AssetConfig.marry_bepropose_window = "prefabs/ui/marry/marry_bepropose_window.unity3d"
AssetConfig.marry_propose_answer_window = "prefabs/ui/marry/marry_propose_answer_window.unity3d"
AssetConfig.marry_wedding_window = "prefabs/ui/marry/marry_wedding_window.unity3d"
AssetConfig.marry_invite_window = "prefabs/ui/marry/marry_invite_window.unity3d"
AssetConfig.marry_beinvite_window = "prefabs/ui/marry/marry_theinvitation_window.unity3d"
AssetConfig.marry_theinvitation_window = "prefabs/ui/marry/marry_theinvitation_window.unity3d"
AssetConfig.marry_help_window = "prefabs/ui/marry/marry_help_window.unity3d"
AssetConfig.marry_bar_window = "prefabs/ui/marry/marry_iconbar.unity3d"
AssetConfig.marry_request_window = "prefabs/ui/marry/marry_request_window.unity3d"
AssetConfig.marry_now_wedding_window = "prefabs/ui/marry/marry_nowwedding_window.unity3d"
AssetConfig.marry_atmosp_tips = "prefabs/ui/marry/marry_atmosp_tips.unity3d"
AssetConfig.marry_divorce_window = "prefabs/ui/marry/marry_divorce_window.unity3d"
AssetConfig.marriage_certificate_window = "prefabs/ui/marry/marriage_certificate_window.unity3d"
AssetConfig.weddingday_window = "prefabs/ui/marry/weddingday_window.unity3d"
AssetConfig.marryhonor_window = "prefabs/ui/marry/marryhonor_window.unity3d"

AssetConfig.bible_recharge_once_panel = "prefabs/ui/bible/rechargeoncepanel.unity3d" --eyou单笔充值
AssetConfig.bible_supervip_gift = "prefabs/ui/bible/supervipgift.unity3d" --eyou超级VIP
AssetConfig.bible_focus_gift = "prefabs/ui/bible/focusgift.unity3d"     --  eyou 关注送大礼
AssetConfig.bible_evaluate_game = "prefabs/ui/bible/evaluategame.unity3d" --eyou五星评价
AssetConfig.bible_onlinereward_panel = "prefabs/ui/bible/onlinereward.unity3d"
AssetConfig.danmaku_input_window = "prefabs/ui/danmaku/danmakuinput.unity3d"
AssetConfig.danmaku_item = "prefabs/ui/danmaku/danmakuitem.unity3d"
AssetConfig.danmakuhistory = "prefabs/ui/danmaku/danmakuhistory.unity3d"
AssetConfig.bible_daily_panel = "prefabs/ui/bible/dailypanel.unity3d"
AssetConfig.bible_seven_panel = "prefabs/ui/bible/sevendaypanel.unity3d"
AssetConfig.bible_cdkey_panel = "prefabs/ui/bible/cdkeypanel.unity3d"
AssetConfig.bible_levelup_panel = "prefabs/ui/bible/leveluppanel.unity3d"
AssetConfig.bible_daily_horoscope_panel = "prefabs/ui/bible/dailyhoroscopepanel.unity3d"
AssetConfig.lockscreen_panel = "prefabs/ui/lockscreen/lockscreenpanel.unity3d"
AssetConfig.lockscreenicon = "textures/ui/lockscreen.unity3d"
AssetConfig.update_notice = "prefabs/ui/settingwindow/updatenoticewindow.unity3d"

AssetConfig.chat_single_facepanel = "prefabs/ui/chat/chatfacepanel.unity3d"

AssetConfig.shop_panel = "prefabs/ui/shop/buypanel.unity3d"
AssetConfig.shop_select_panel = "prefabs/ui/shop/selectpanel.unity3d"
AssetConfig.shop_charge_panel = "prefabs/ui/shop/chargepanel.unity3d"
AssetConfig.shop_recharge_panel = "prefabs/ui/shop/rechargepanel.unity3d"
AssetConfig.shop_recharge_return_panel = "prefabs/ui/shop/rechargereturnpanel.unity3d"


AssetConfig.chat_single_facepanel = "prefabs/ui/chat/chatfacepanel.unity3d"

AssetConfig.open_server_window = "prefabs/ui/openserver/openserver.unity3d"
AssetConfig.open_server_activity = "prefabs/ui/openserver/activitypanel.unity3d"
AssetConfig.open_server_rank = "prefabs/ui/openserver/rankbattle.unity3d"
AssetConfig.open_server_lucky = "prefabs/ui/openserver/luckymoney.unity3d"
AssetConfig.open_server_therion = "prefabs/ui/openserver/therionexchange.unity3d"
AssetConfig.open_server_textures = "textures/ui/openserver.unity3d"
AssetConfig.open_server_textures2 = "textures/ui/openserver2.unity3d"
AssetConfig.open_server_first = "prefabs/ui/openserver/firstcharge.unity3d"
AssetConfig.open_server_offical = "prefabs/ui/openserver/officalrebate.unity3d"
AssetConfig.open_server_continuerecharge = "prefabs/ui/openserver/openservercontinuerecharge.unity3d"
AssetConfig.open_server_card = "prefabs/ui/openserver/openservercard.unity3d"
AssetConfig.open_server_monthandfund = "prefabs/ui/openserver/openservermonthandfunds.unity3d"  --开服月度和基金
AssetConfig.open_server_monthsub= "prefabs/ui/openserver/openservermonthsubpanel.unity3d"
AssetConfig.open_server_continuousrecharge= "prefabs/ui/openserver/openservercontinuousrecharge.unity3d"
AssetConfig.open_server_continuousrecharge_bg = "prefabs/ui/bigatlas/openservercontinuousrechargebg.unity3d"

--开服直购礼包
AssetConfig.open_server_directbuypanel= "prefabs/ui/openserver/openserverdirectbuypanel.unity3d"
AssetConfig.open_server_directbuypanel_bg = "prefabs/ui/bigatlas/openserverdirectbuypanelbg.unity3d"
AssetConfig.open_server_directbuypanel_txt = "prefabs/ui/bigatlas/openserverdirectbuypaneltxt.unity3d"
AssetConfig.directbuypanel= "prefabs/ui/bible/directbuypanel.unity3d"

--开服超值礼包
AssetConfig.open_server_valuepackagepanel = "prefabs/ui/openserver/openservervaluepackagepanel.unity3d"
AssetConfig.open_server_valuepackagepanel_bg = "prefabs/ui/bigatlas/openservervaluepackagepanelbg.unity3d"
AssetConfig.open_server_valuepackagepanel_txt = "prefabs/ui/bigatlas/openservervaluepackagepaneltxt.unity3d"

AssetConfig.open_server_continuousrecharge_textures = "textures/ui/openservercontinuousrecharge.unity3d"

--开服新扭蛋活动
AssetConfig.open_server_toyreward_panel = "prefabs/ui/openserver/openservertoyrewardpanel.unity3d"
AssetConfig.openserver_toyreward_big_bg = "prefabs/ui/bigatlas/openservertoyrewardbigbg.unity3d"
-- AssetConfig.open_server_toyreward_textures = "textures/ui/openservertoyreward.unity3d"

--开服新累充活动
AssetConfig.open_server_accumulativerecharge = "prefabs/ui/openserver/openserveraccumulativerechargepanel.unity3d"
AssetConfig.open_server_accumulativerecharge_bigbg = "prefabs/ui/bigatlas/openserveraccumulativerechargebigbg.unity3d"
AssetConfig.open_server_accumulativerecharge_bg = "prefabs/ui/bigatlas/openserveraccumulativerechargebg.unity3d"
AssetConfig.open_server_accumulativerecharge_txt = "prefabs/ui/bigatlas/openserveraccumulativerechargetxt.unity3d"
AssetConfig.accumulative_big_icon_textures = "textures/ui/accumulativebigicon.unity3d"



----开服0元购
AssetConfig.open_server_zero_buy = "prefabs/ui/openserver/openserverzerobuywindow.unity3d"
AssetConfig.open_server_zero_buybg = "prefabs/ui/bigatlas/zerobuybg.unity3d"
AssetConfig.open_server_zero_buybg1 = "prefabs/ui/bigatlas/zerobuybigbg1i18n.unity3d"
AssetConfig.open_server_zero_buybg2 = "prefabs/ui/bigatlas/zerobuybigbg2i18n.unity3d"
AssetConfig.open_server_zero_buybg3 = "prefabs/ui/bigatlas/zerobuybigbg3i18n.unity3d"

AssetConfig.open_server_zero_texture = "textures/ui/openserverzerobuy.unity3d"

--满减商城活动
AssetConfig.fullsubtractionshopwindow =  "prefabs/ui/campaign/fullsubtractionshopwindow.unity3d"
AssetConfig.fullshopdescti18n = "prefabs/ui/bigatlas/fullshopdescti18n.unity3d"
AssetConfig.christmastitletop = "prefabs/ui/bigatlas/christmastitletop.unity3d"
AssetConfig.leftgirl = "prefabs/ui/bigatlas/girl.unity3d"
AssetConfig.fullshopdesc = "prefabs/ui/bigatlas/fullshopdesc.unity3d"

--龙凤棋
AssetConfig.dragonphoenixchessmain =  "prefabs/ui/dragonphoenixchess/dragonphoenixchessmain.unity3d"
AssetConfig.dragon_chess_bg = "prefabs/ui/bigatlas/dragonchessbg.unity3d"
AssetConfig.dragon_chess_textures = "textures/ui/dragonchess.unity3d"
AssetConfig.dragon_board_bg = "textures/ui/bigbg/dragonchessboard.unity3d"
AssetConfig.dragon_chess_iconview = "prefabs/ui/dragonphoenixchess/dragonchessiconview.unity3d"
AssetConfig.dragon_chess_tips = "prefabs/ui/bigatlas/dragonchesstipi18n.unity3d"
AssetConfig.dragon_chess_tips1 = "prefabs/ui/bigatlas/dragonchesstip1i18n.unity3d"
AssetConfig.dragon_chess_tips2 = "prefabs/ui/bigatlas/dragonchesstip2i18n.unity3d"
AssetConfig.dragon_chess_match = "prefabs/ui/dragonphoenixchess/dragonchessmatch.unity3d"
AssetConfig.dragon_chess_desc_panel = "prefabs/ui/dragonphoenixchess/dragonchessdescpanel.unity3d"

--奖励预览
AssetConfig.reward_preview_textures = "textures/ui/rewardpreview.unity3d"
AssetConfig.reward_preview_panel =  "prefabs/ui/rewardpreview/rewardpreviewpanel.unity3d"
AssetConfig.reward_preview_panel2 =  "prefabs/ui/rewardpreview/rewardpreviewpanel2.unity3d"


AssetConfig.guild_fight_score_panel = "prefabs/ui/guild/guildfightscorepanel.unity3d" --公会战算分界面
AssetConfig.guild_fight_window = "prefabs/ui/guild/guildfightwindow.unity3d" --公会战信息界面
AssetConfig.guild_fight_mine_panel = "prefabs/ui/guild/guildfightminepanel.unity3d" --公会战自己公会信息界面
AssetConfig.guild_fight_list_panel = "prefabs/ui/guild/guildfightlistpanel.unity3d" --公会战公会对阵信息界面
AssetConfig.guild_fight_settime_panel = "prefabs/ui/guild/guildfightsettimepanel.unity3d" --公会宝藏开启的时间设置界面
AssetConfig.guild_fight_givebox_panel = "prefabs/ui/guild/guildfightgiveboxpanel.unity3d" --公会功能宝箱分发界面
AssetConfig.guild_fight_integral_panel = "prefabs/ui/guild/guildfightintegralpanel.unity3d" --公会战战绩排名
AssetConfig.guild_fight_remain_enemy_panel = "prefabs/ui/guildfight/guildfightremainenemypanel.unity3d" --公会战剩余人数
AssetConfig.guild_fight_team_window = "prefabs/ui/guild/guildfightteamwindow.unity3d" --公会战便捷组队界面
AssetConfig.chat_single_facepanel = "prefabs/ui/chat/chatfacepanel.unity3d"

AssetConfig.bible_limit_time_privilege_panel = "prefabs/ui/bible/limittimeprivilege.unity3d" --限时特惠

AssetConfig.loveteamwindow = "prefabs/ui/petlove/loveteamwindow.unity3d" --情缘匹配
AssetConfig.skilltalentwindow = "prefabs/ui/skill/skilltalentwindow.unity3d" --新天赋

AssetConfig.teacher_window = "prefabs/ui/teacher/teacherwindow.unity3d" --师徒主界面
AssetConfig.teacher_panel = "prefabs/ui/teacher/tmainpanel.unity3d" --师傅窗口
AssetConfig.student_panel = "prefabs/ui/teacher/smainpanel.unity3d" --徒弟窗口
AssetConfig.apprentice_panel = "prefabs/ui/teacher/apprenticepanel.unity3d" --拜师窗口
AssetConfig.bebs_panel = "prefabs/ui/teacher/betspanel.unity3d" --成为师徒的提示窗口
AssetConfig.select_teacher_panel = "prefabs/ui/teacher/selectteacherpanel.unity3d" --选择师傅的窗口
AssetConfig.apprentice_research_panel = "prefabs/ui/teacher/apprenticeresearchpanel.unity3d" --选择师傅前，问卷窗口
AssetConfig.evaluate_panel = "prefabs/ui/teacher/evaluatepanel.unity3d" --评价师傅的窗口
AssetConfig.be_teacher_panel = "prefabs/ui/teacher/beteacherfinishrewardwin.unity3d" --出师奖励窗口
AssetConfig.apprenticesignupwindow = "prefabs/ui/teacher/apprenticesignupwindow.unity3d" --师傅寄语窗口
AssetConfig.findteacherwindow = "prefabs/ui/teacher/findteacherwindow.unity3d" --寻找师傅窗口

AssetConfig.reportwindow = "prefabs/ui/report/reportwindow.unity3d" --举报面板
AssetConfig.growplants_panel = "prefabs/ui/springfestival/growplants.unity3d"
AssetConfig.buybuy_panel = "prefabs/ui/springfestival/buybuy.unity3d"
AssetConfig.killrober_panel = "prefabs/ui/springfestival/killrober.unity3d"
AssetConfig.plantssprite_panel = "prefabs/ui/springfestival/plantssprite.unity3d"
AssetConfig.totlelogin_panel = "prefabs/ui/springfestival/totlelogin.unity3d"
AssetConfig.labour_brave_trials = "prefabs/ui/springfestival/bravetrials.unity3d"   -- 四季试炼

AssetConfig.open_server_baby = "prefabs/ui/openserver/babypanel.unity3d"    -- 开服活动星辰宝贝界面
AssetConfig.open_server_baby_tips = "prefabs/ui/openserver/babytips.unity3d"    -- 开服活动星辰宝贝界面
AssetConfig.open_server_photo_panel = "prefabs/ui/openserver/photoshowpanel.unity3d"

AssetConfig.teacher_show_window = "prefabs/ui/teacher/apprenticesguidewindow.unity3d"
AssetConfig.teacher_daily_panel = "prefabs/ui/teacher/dailylive.unity3d"
AssetConfig.teacher_grow_panel = "prefabs/ui/teacher/growuptarget.unity3d"
AssetConfig.teacher_textures = "textures/ui/teacher.unity3d"
AssetConfig.teacher_accept_panel = "prefabs/ui/teacher/teacheracceptpanel.unity3d"

AssetConfig.force_improve_window = "prefabs/ui/forceimprove/forceimprovement.unity3d"
AssetConfig.force_improve_panel = "prefabs/ui/forceimprove/improvepanel.unity3d"
AssetConfig.force_promotion_panel = "prefabs/ui/forceimprove/promotionpanel.unity3d"
AssetConfig.force_improve_recommend_window = "prefabs/ui/forceimprove/forceimprovementrecommend.unity3d"

AssetConfig.hero_rank_panel = "prefabs/ui/hero/herorankpanel.unity3d"
AssetConfig.hero_textures = "textures/ui/hero.unity3d"

AssetConfig.badge_icon = "textures/badge.unity3d"
AssetConfig.photo_frame = "textures/photoframe.unity3d"
AssetConfig.bigbadge = "textures/bigbadge.unity3d"
AssetConfig.bubble_icon = "textures/bubbleicon.unity3d"

AssetConfig.guild_fight_elite_window = "prefabs/ui/guildfightelite/guildfightelitewindow.unity3d" --公会精英战界面
AssetConfig.guild_fight_elite_member_panel = "prefabs/ui/guildfightelite/guildfightelitepanel.unity3d" --公会精英战领队安排窗口
AssetConfig.guild_fight_elite_look_window = "prefabs/ui/guildfightelite/guildfightelitelookwindow.unity3d" --公会精英战观战操作窗口

AssetConfig.badge_icon = "textures/badge.unity3d"  --徽章
AssetConfig.photo_frame = "textures/photoframe.unity3d"  --相框
AssetConfig.bubble_icon = "textures/bubbleicon.unity3d"  -- 气泡图标
AssetConfig.zonestyleicon = "textures/zonestyleicon.unity3d"  -- 主题图标
AssetConfig.teammark_icon = "textures/teammark.unity3d"  -- 队标图标
AssetConfig.footmark_icon = "textures/footmark.unity3d"  -- 队标图标
AssetConfig.achievementshop = "textures/ui/achievementshop.unity3d"  -- 成就兑换，tab小图标
AssetConfig.combatcmdpanel = "prefabs/ui/combat/combatcmdsetpanel.unity3d"

AssetConfig.mystical_eggs_panel = "prefabs/ui/bible/mysticaleggpanel.unity3d" --神秘彩蛋
AssetConfig.defend_welfare_bag_panel = "prefabs/ui/bible/defendwelfarebagpanel.unity3d" --守护福袋
-- AssetConfig.friend_help_welfare_bag_panel = "prefabs/ui/bible/friendhelpwelfarebagspanel.unity3d" --守护福袋好友求助
AssetConfig.consume_return_panel = "prefabs/ui/openserver/consumereturnpanel.unity3d" --消费返利
AssetConfig.active_reward_panel = "prefabs/ui/openserver/activerewardpanel.unity3d" --活跃度奖励

AssetConfig.teamup_tips = "prefabs/ui/tips/teamuptips.unity3d"  --组队提示

-- shader
AssetConfig.shader_effects = "textures/shader/effectshader.unity3d"
AssetConfig.shader_unlittexturehead = "textures/shader/single/unlittexturehead.unity3d"
AssetConfig.shader_unlittexturemap = "textures/shader/single/unlittexturemap.unity3d"
AssetConfig.shader_unlittexturenpc = "textures/shader/single/unlittexturenpc.unity3d"
AssetConfig.shader_unlittexturerole = "textures/shader/single/unlittexturerole.unity3d"
AssetConfig.shader_unlittexturesurbase = "textures/shader/single/unlittexturesurbase.unity3d"
AssetConfig.shader_unlittextureweapon = "textures/shader/single/unlittextureweapon.unity3d"
AssetConfig.shader_unlittexturewing = "textures/shader/single/unlittexturewing.unity3d"
AssetConfig.shader_unlittextureride = "textures/shader/single/unlittextureride.unity3d"
AssetConfig.shader_unlittexturemasker = "textures/shader/single/unlittexturemask.unity3d"

AssetConfig.bible_festival_panel = "prefabs/ui/bible/festivalpanel.unity3d"

AssetConfig.total_return_panel = "prefabs/ui/may/totalreward.unity3d" -- 累计返利
AssetConfig.may_textures = "textures/ui/may.unity3d" -- 五月活动档
AssetConfig.give_me_your_hand = "prefabs/ui/may/givemeyourhand.unity3d" -- 执子之手
AssetConfig.rose_casting = "prefabs/ui/may/rosecasting.unity3d"         -- 玫瑰传情
AssetConfig.buybuy520 = "prefabs/ui/may/buybuy520.unity3d"              -- 520礼包
AssetConfig.intimacypanel = "prefabs/ui/may/intimacypanel.unity3d" -- 亲密度排行榜界面
AssetConfig.intimacybg = "prefabs/ui/bigatlas/intimacybigbg.unity3d"  -- 亲密度排行榜大底
AssetConfig.intimacybg2 = "prefabs/ui/bigatlas/intimacybigbg2.unity3d"  -- 亲密度排行榜2大底

AssetConfig.treasurehunting = "prefabs/ui/campaign/treasurehunting.unity3d" --新翻牌界面
AssetConfig.treasurehunting_textures = "textures/ui/treasurehunting.unity3d"
AssetConfig.i18ntreasurehuntingbg = "prefabs/ui/bigatlas/i18ntreasurehuntingbg.unity3d"

AssetConfig.worldlevgiftpanel = "prefabs/ui/campaign/worldlevgiftpanel.unity3d" --世界等级活动礼包界面
AssetConfig.worldlevgiftbg = "prefabs/ui/bigatlas/worldlevgiftbg.unity3d" --世界等级活动礼包界面大底
AssetConfig.textures_campaign = "textures/ui/campaign.unity3d" -- 活动UI图片图集资源
AssetConfig.bg_campaignrankbg = "prefabs/ui/bigatlas/campaignrankbg.unity3d" --世界等级排行榜界面大底
AssetConfig.bg_worldlevrechargebg = "prefabs/ui/bigatlas/i18nworldlevrechargebg.unity3d" --世界等级充值返利界面大底
AssetConfig.bg_worldlevtotalrechargebg = "prefabs/ui/bigatlas/i18nworldlevtotalrechargebg.unity3d" --世界等级累计充值界面大底

AssetConfig.bg_campaignrankbg_consume = "prefabs/ui/bigatlas/campaignrankbg_consume.unity3d" --活动累消排行榜界面大底

AssetConfig.dollsrandompanel = "prefabs/ui/marchevent/dollsrandompanel.unity3d" --套娃Panel
AssetConfig.dollsrandombigbg = "prefabs/ui/bigatlas/dolls_bigbg.unity3d"
AssetConfig.dollsrandomdollsitem = "prefabs/ui/may/dollsrandomdollsitem.unity3d" --套娃Item
AssetConfig.dollsrandomrewardpanel = "prefabs/ui/may/dollsrandomrewardpanel.unity3d" --套娃奖励弹窗
AssetConfig.dollsrandomrewarditem = "prefabs/ui/may/dollsrandomrewarditem.unity3d" --套娃奖励弹窗奖励Item
AssetConfig.dollsrandomopenpanel = "prefabs/ui/may/dollsrandomopenpanel.unity3d" --套娃打开弹窗特效

AssetConfig.cakeexchangewindow = "prefabs/ui/may/cakeexchangewindow.unity3d" --周年庆兑换活动窗口

AssetConfig.twoyearbigbg = "prefabs/ui/bigatlas/twoyearbigbg.unity3d"	--两周年福利大图

--周年庆传递花语
AssetConfig.passblesswindow = "prefabs/ui/passblesswindow/passblesswindow.unity3d"
AssetConfig.passblesssubwindow = "prefabs/ui/passblesswindow/passblesssubwindow.unity3d"
AssetConfig.passblesssubbg = "prefabs/ui/bigatlas/passblesssubbg.unity3d"
AssetConfig.passblesstitlebg = "prefabs/ui/bigatlas/passblesstitlebg.unity3d"
AssetConfig.passblesstxti18n = "prefabs/ui/bigatlas/passblesstxti18n.unity3d"
AssetConfig.passbless_res = "textures/ui/passbless.unity3d"
AssetConfig.luckywindowbg = "textures/ui/bigbg/luckywindowbg.unity3d"



AssetConfig.combatlog_window = "prefabs/ui/combatlog/combatlogwindow.unity3d"
AssetConfig.combatlog_panel = "prefabs/ui/combatlog/rankcombatlog.unity3d"
AssetConfig.combatvedio_window = "prefabs/ui/combatlog/combatvediowindow.unity3d"


AssetConfig.combatlog_panel2 = "prefabs/ui/combatlog/rankcombatlog2.unity3d"
AssetConfig.combatlog_viewpanel = "prefabs/ui/combatlog/combatlogviewpanel.unity3d"
AssetConfig.combatwatchvotetips = "prefabs/ui/combatlog/combatwatchvotetips.unity3d"
AssetConfig.combatlog_res = "textures/ui/combatlog.unity3d"

AssetConfig.ridewindow = "prefabs/ui/ride/ridewindow.unity3d"
AssetConfig.ridewindow_headbar = "prefabs/ui/ride/ridewindow_headbar.unity3d"
AssetConfig.ridewindow_base = "prefabs/ui/ride/ridewindow_base.unity3d"
AssetConfig.ridewindow_book = "prefabs/ui/ride/ridewindow_book.unity3d"
AssetConfig.ridewindow_control_panel = "prefabs/ui/ride/ridecontrolpanel.unity3d"
AssetConfig.ridewindow_skill_reset_panel = "prefabs/ui/ride/rideskillresetpanel.unity3d"
AssetConfig.rideequip = "prefabs/ui/ride/rideequip.unity3d"
AssetConfig.rideselectwindow = "prefabs/ui/ride/rideselectwindow.unity3d"
AssetConfig.rideproppreviewwin = "prefabs/ui/ride/rideproppreviewwin.unity3d"
AssetConfig.ridewindow_upgrade = "prefabs/ui/ride/ridewindow_upgrade.unity3d"
AssetConfig.ridecontract = "prefabs/ui/ride/ridewindow_contract.unity3d"
AssetConfig.rideskill = "prefabs/ui/ride/ridewindow_skill.unity3d"
AssetConfig.ridewash = "prefabs/ui/ride/ridewashskillwindow.unity3d"
AssetConfig.ridewash_real = "prefabs/ui/ride/ridewashwindow.unity3d"
AssetConfig.ridegetskill = "prefabs/ui/ride/ridegetskillpanel.unity3d"
AssetConfig.rideuseitem = "prefabs/ui/ride/rideuseitempanel.unity3d"
AssetConfig.getride = "prefabs/ui/ride/getride.unity3d"
AssetConfig.ridepet = "prefabs/ui/ride/ridepetpanel.unity3d"
AssetConfig.rideshowwindow = "prefabs/ui/ride/rideshowwindow.unity3d"
AssetConfig.ridedyewindow = "prefabs/ui/ride/ridedyewindow.unity3d"
AssetConfig.headride = "textures/headride.unity3d"
AssetConfig.rideattricon = "textures/ui/rideattricon.unity3d"


AssetConfig.ride_texture = "textures/ui/ride.unity3d"

AssetConfig.wing_skill_panel = "prefabs/ui/wings/wingskillcontentpanel.unity3d"
AssetConfig.path_finding_panel = "prefabs/ui/campaign/pathfinding.unity3d"
AssetConfig.login_total_panel = "prefabs/ui/campaign/logintotal.unity3d"

AssetConfig.diamond_bag_textures = "textures/ui/diamondbag.unity3d"

AssetConfig.rice_cake = "prefabs/ui/springfestival/ricecake.unity3d"

AssetConfig.wing_skill_preview = "prefabs/ui/wings/wingskillpreview.unity3d"
AssetConfig.wing_textures = "textures/ui/wings.unity3d"

AssetConfig.itemselect = "prefabs/ui/backpack/itemselect.unity3d"

AssetConfig.multi_invest_panel = "prefabs/ui/bible/multiinvestpanel.unity3d"
AssetConfig.invest_textures = "textures/ui/investment.unity3d"

AssetConfig.download_win = "prefabs/ui/download/downloadwindow.unity3d"

AssetConfig.mergeserver_double_panel = "prefabs/ui/mergeserver/doublegift.unity3d"
AssetConfig.mergeserver_endear_panel = "prefabs/ui/mergeserver/endearlove.unity3d"
AssetConfig.mergeserver_gift_panel = "prefabs/ui/mergeserver/mergegift.unity3d"

AssetConfig.mergeserver_textures = "textures/ui/mergeserver.unity3d"


AssetConfig.setpetskillpanel = "prefabs/ui/autofarm/petskillsetpanel.unity3d"
AssetConfig.setroleskillpanel = "prefabs/ui/autofarm/roleskillsetpanel.unity3d"
AssetConfig.skillconfigwindow = "prefabs/ui/autofarm/skillsetwindow.unity3d"

AssetConfig.tower_raffle_window = "prefabs/ui/dungeon/towerrafflewindow.unity3d"
AssetConfig.tower_raffle_textures = "textures/ui/dungeon.unity3d"
AssetConfig.dungeon_video_window = "prefabs/ui/dungeon/dungeonvideowindow.unity3d"

AssetConfig.mergeserver_total_login = "prefabs/ui/mergeserver/mergelogin.unity3d"
AssetConfig.mergeserver_first_charge = "prefabs/ui/mergeserver/mergefirst.unity3d"

AssetConfig.recharge_explain_window = "prefabs/ui/shop/rechargeexplainwindow.unity3d"

AssetConfig.classcardgroup_textures = "textures/classcard.unity3d"
AssetConfig.worldchampionmainpanel = "prefabs/ui/no1inworld/no1inworldpanel.unity3d"
AssetConfig.worldchampionmainpanel2v2 = "prefabs/ui/no1inworld/no1inworldpanel2v2.unity3d"

AssetConfig.worldchampionsuccess = "prefabs/ui/no1inworld/no1inworldsuccess.unity3d"
AssetConfig.worldchampionlevup = "prefabs/ui/no1inworld/no1inworldlvup.unity3d"
AssetConfig.worldchampionlvlup = "prefabs/ui/no1inworld/no1inworldlvlupgame.unity3d"
AssetConfig.no1inworld_textures = "textures/ui/no1inworld.unity3d"
AssetConfig.no1inworldbadge_textures = "textures/ui/no1inworldbadge.unity3d"




AssetConfig.worldchampionquarterbox = "prefabs/ui/no1inworld/no1inworldquarterboxpanel.unity3d"
AssetConfig.worldchampionquarter = "prefabs/ui/no1inworld/  .unity3d"
AssetConfig.worldchampion_LevIcon = "textures/worldchampionbadge.unity3d"

AssetConfig.worldchampionrankpanel = "prefabs/ui/no1inworld/no1inworldrankpanel.unity3d"
AssetConfig.worldchampionallrankpanel = "prefabs/ui/no1inworld/no1allrankpanel.unity3d"
AssetConfig.worldchampionmainwindow = "prefabs/ui/no1inworld/no1inworldwindow.unity3d"
AssetConfig.worldchampionmainsub1 = "prefabs/ui/no1inworld/no1inworldsub1.unity3d"
AssetConfig.worldchampionallranksubpanel = "prefabs/ui/no1inworld/no1inworldsub2.unity3d"
AssetConfig.worldchampionmainsub3 = "prefabs/ui/no1inworld/no1inworldsub3.unity3d"
AssetConfig.worldchampionfightinfo = "prefabs/ui/no1inworld/no1fightinfo.unity3d"
AssetConfig.worldchampionfightinfo2 = "prefabs/ui/no1inworld/no1fightinfo2.unity3d"
AssetConfig.worldchampionno1share = "prefabs/ui/no1inworld/no1inworldsharewindow.unity3d"
AssetConfig.worldchampionno1score = "prefabs/ui/no1inworld/no1inworldhonorscorewindow.unity3d"
AssetConfig.worldchampionno1war = "prefabs/ui/no1inworld/fightrankpanel.unity3d"
AssetConfig.worldchampionno1honor = "prefabs/ui/no1inworld/honorrankpanel.unity3d"
AssetConfig.worldchampionbadgepanel = "prefabs/ui/no1inworld/worldchampionbadgepanel.unity3d"
AssetConfig.worldchampionbadgewindow = "prefabs/ui/no1inworld/no1badgewindow.unity3d"
AssetConfig.badgerewardwindow = "prefabs/ui/no1inworld/badgerewardwindow.unity3d"
AssetConfig.worldchampionbadgecollectpanel = "prefabs/ui/no1inworld/no1badgecollectpanel.unity3d"
AssetConfig.worldchampionbadgecombinationpanel = "prefabs/ui/no1inworld/no1badgecombinationpanel.unity3d"
AssetConfig.worldchampionbadgelookwindow = "prefabs/ui/no1inworld/no1badgelookwindow.unity3d"
AssetConfig.worldchampionbadgeshowwindow = "prefabs/ui/no1inworld/no1badgeshowwindow.unity3d"




AssetConfig.masquerade_rank_window = "prefabs/ui/masquerade/masqueraderankwindow.unity3d"
AssetConfig.masquerade_mainui_panel = "prefabs/ui/masquerade/masqueradeprogresspanel.unity3d"
AssetConfig.masquerade_preview_window = "prefabs/ui/masquerade/masqueradepreviewwindow.unity3d"
AssetConfig.masquerade_textures = "textures/ui/masquerade.unity3d"

AssetConfig.strategy_window = "prefabs/ui/strategy/strategywindow.unity3d"
AssetConfig.strategy_panel = "prefabs/ui/strategy/strategypanel.unity3d"
AssetConfig.strategy_list_panel = "prefabs/ui/strategy/strategylistpanel.unity3d"
AssetConfig.strategy_textures = "textures/ui/strategy.unity3d"
AssetConfig.strategy_edit_panel = "prefabs/ui/strategy/strategyeditpanel.unity3d"
AssetConfig.strategy_read_panel = "prefabs/ui/strategy/strategyreadpanel.unity3d"
AssetConfig.strategy_type_panel = "prefabs/ui/strategy/uploadtypepanel.unity3d"
AssetConfig.strategy_question_panel = "prefabs/ui/strategy/examquestionwindow.unity3d"

AssetConfig.encyclopedia_panel = "prefabs/ui/encyclopedia/encyclopediapanel.unity3d"
AssetConfig.encyclopedia_subpanel = "prefabs/ui/encyclopedia/encyclopediasubpanel.unity3d"

AssetConfig.equip_pedia = "prefabs/ui/encyclopedia/equippedia.unity3d"
AssetConfig.equipbuild_pedia = "prefabs/ui/encyclopedia/equipbuildpedia.unity3d"
AssetConfig.stongstrength_pedia = "prefabs/ui/encyclopedia/stondstrengthpedia.unity3d"
AssetConfig.equiprefine_pedia = "prefabs/ui/encyclopedia/refineotherpedia.unity3d"

AssetConfig.classskill_pedia = "prefabs/ui/encyclopedia/classskillpedia.unity3d"
AssetConfig.equipskill_pedia = "prefabs/ui/encyclopedia/equipskillpedia.unity3d"
AssetConfig.wingskill_pedia = "prefabs/ui/encyclopedia/wingskillpedia.unity3d"
AssetConfig.cpskill_pedia = "prefabs/ui/encyclopedia/cpskillpedia.unity3d"

AssetConfig.pet_pedia = "prefabs/ui/encyclopedia/petpedia.unity3d"
AssetConfig.petlvupandattr_pedia = "prefabs/ui/encyclopedia/lvupattrpedia.unity3d"
AssetConfig.washalearn_pedia = "prefabs/ui/encyclopedia/washlearnpedia.unity3d"
AssetConfig.upgradeother_pedia = "prefabs/ui/encyclopedia/upgradeotherpedia.unity3d"
AssetConfig.pet_spirit_pedia = "prefabs/ui/encyclopedia/petspiritpedia.unity3d"

AssetConfig.guardabout_pedia = "prefabs/ui/encyclopedia/guarddescpedia.unity3d"
AssetConfig.guard_pedia = "prefabs/ui/encyclopedia/guardpedia.unity3d"

AssetConfig.wings_pedia = "prefabs/ui/encyclopedia/wingspedia.unity3d"
AssetConfig.wingupreset_pedia = "prefabs/ui/encyclopedia/wingupresetpedia.unity3d"
AssetConfig.wingskillabout = "prefabs/ui/encyclopedia/wingaboutpedia.unity3d"

AssetConfig.medicine_peida = "prefabs/ui/encyclopedia/medicinepedia.unity3d"

AssetConfig.ride_peida = "prefabs/ui/encyclopedia/ridepedia.unity3d"
AssetConfig.ridebaseinfo_peida = "prefabs/ui/encyclopedia/ridebaseinfopedia.unity3d"
AssetConfig.ridetrans_peida = "prefabs/ui/encyclopedia/ridetranspedia.unity3d"
AssetConfig.rideskill_peida = "prefabs/ui/encyclopedia/rideskillpedia.unity3d"
AssetConfig.talismanpedia = "prefabs/ui/encyclopedia/talismanpedia.unity3d"


AssetConfig.summer_main_window = "prefabs/ui/summer/summermainwindow.unity3d"
AssetConfig.summer_fruit_plant_panel = "prefabs/ui/summer/fruitplantcon.unity3d"
AssetConfig.summer_fruit_help_panel = "prefabs/ui/summer/fruitfriendhelpwindow.unity3d"
AssetConfig.summer_res = "textures/ui/summer.unity3d"
AssetConfig.summer_loss_child_panel = "prefabs/ui/summer/lossboycon.unity3d"
AssetConfig.summer_loss_child_bigbg = "prefabs/ui/bigatlas/summercoldtitlei18n.unity3d"
AssetConfig.summer_loss_child_txt = "prefabs/ui/bigatlas/summercoldi18n.unity3d"
AssetConfig.summer_loss_child_bigtextrue = "textures/ui/bigbg/guidesprite.unity3d"
AssetConfig.summer_to_help_window = "prefabs/ui/summer/tofruithelpwindow.unity3d"
AssetConfig.summer_day_login_panel = "prefabs/ui/summer/logindaypanel.unity3d"


AssetConfig.seek_children_panel = "prefabs/ui/summer/seekchildrenspanel.unity3d"
AssetConfig.seek_children_detail_panel = "prefabs/ui/summer/seekchildrensdetaildescpanel.unity3d"


AssetConfig.sevenday_textures = "textures/ui/sevenday.unity3d"
AssetConfig.sevenday_window = "prefabs/ui/sevenday/sevendaywindow.unity3d"
AssetConfig.sevenday_panel = "prefabs/ui/sevenday/sevendaypanel.unity3d"
AssetConfig.sevenday_welfare = "prefabs/ui/sevenday/sevendaywelfare.unity3d"
AssetConfig.sevenday_target = "prefabs/ui/sevenday/sevendaytarget.unity3d"
AssetConfig.sevenday_halfprice = "prefabs/ui/sevenday/sevendayhalfprice.unity3d"

AssetConfig.homecanvas = "prefabs/ui/home/homecanvas.unity3d"
AssetConfig.homeeditpanel = "prefabs/ui/home/homeeditpanel.unity3d"
AssetConfig.homemaparea = "prefabs/ui/home/homemaparea.unity3d"
AssetConfig.homewindow = "prefabs/ui/home/homewindow.unity3d"
AssetConfig.home_view_info = "prefabs/ui/home/home_view_info.unity3d"
AssetConfig.home_view_build = "prefabs/ui/home/home_view_build.unity3d"
AssetConfig.home_view_extension = "prefabs/ui/home/home_view_extension.unity3d"
AssetConfig.homepettrainwindow = "prefabs/ui/home/homepettrainwindow.unity3d"
AssetConfig.homeshopwindow = "prefabs/ui/home/homeshopwindow.unity3d"
AssetConfig.homeshopsubpanel = "prefabs/ui/home/homeshopsubpanel.unity3d"
AssetConfig.shoplistpanel = "prefabs/ui/home/shoplistpanel.unity3d"
AssetConfig.gethome = "prefabs/ui/home/gethome.unity3d"
AssetConfig.createhomewindow = "prefabs/ui/home/createhomewindow.unity3d"
AssetConfig.visithomewindow = "prefabs/ui/home/visithomewindow.unity3d"
AssetConfig.magicbeenpanel = "prefabs/ui/home/magicbeenpanel.unity3d"
AssetConfig.invitemagicbeenwindow = "prefabs/ui/home/invitemagicbeenwindow.unity3d"
AssetConfig.homeshadowmaterials = "prefabs/ui/home/homeshadowmaterials.unity3d"
AssetConfig.furniturelistwindow = "prefabs/ui/home/furniturelistwindow.unity3d"

AssetConfig.homeTexture = "textures/ui/home.unity3d"
AssetConfig.homebigTexture = "textures/ui/homebig.unity3d"
AssetConfig.homeshadowTexture = "textures/homeshadow.unity3d"
AssetConfig.smallicon = "textures/ui/smallicon.unity3d"

AssetConfig.sing_main = "prefabs/ui/sing/singwindow.unity3d"
AssetConfig.sing_singup = "prefabs/ui/sing/singsinguppanel.unity3d"
AssetConfig.sing_advert = "prefabs/ui/sing/singadvertpanel.unity3d"
AssetConfig.singranktypepanel = "prefabs/ui/sing/singranktypepanel.unity3d"
AssetConfig.sing_res = "textures/ui/sing.unity3d"
AssetConfig.auction_panel = "prefabs/ui/auction/auctionpanel.unity3d"
AssetConfig.auction_offer_panel = "prefabs/ui/auction/auctionoperate.unity3d"
AssetConfig.auction_textures = "textures/ui/auction.unity3d"

AssetConfig.sing_time_window = "prefabs/ui/sing/singtimewindow.unity3d"
AssetConfig.sing_desc_window = "prefabs/ui/sing/singdescwindow.unity3d"

AssetConfig.backpack_expand = "prefabs/ui/backpack/gridexpanpanel.unity3d"

AssetConfig.lottery_res = "textures/ui/lottery.unity3d"
AssetConfig.lottery_main = "prefabs/ui/lottery/lotterymainwindow.unity3d"
AssetConfig.lottery_record = "prefabs/ui/lottery/lotteryrecordpanel.unity3d"
AssetConfig.lottery_show = "prefabs/ui/lottery/lotteryshowpanel.unity3d"
AssetConfig.lottery_detail = "prefabs/ui/lottery/lotterydetailwindow.unity3d"
AssetConfig.lottery_join = "prefabs/ui/lottery/lotteryjoinpanel.unity3d"
AssetConfig.lottery_exchange = "prefabs/ui/lottery/lotteryexchangepanel.unity3d"
AssetConfig.button1 = "textures/ui/button1.unity3d"

AssetConfig.backend_window = "prefabs/ui/backend/backendwindow.unity3d"
AssetConfig.backend_textures = "textures/ui/backend.unity3d"
AssetConfig.backend_continue = "prefabs/ui/backend/backendcontinue.unity3d"
AssetConfig.backend_background_list = "prefabs/ui/backend/backendbackgroundlist.unity3d"
AssetConfig.backend_two_excharge = "prefabs/ui/backend/backendtwoexcharge.unity3d"
AssetConfig.backend_text_list = "prefabs/ui/backend/backendtextlist.unity3d"
AssetConfig.backend_exchange_list = "prefabs/ui/backend/backendexchangelist.unity3d"
AssetConfig.backend_desc_panel = "prefabs/ui/backend/backenddescpanel.unity3d"
AssetConfig.backend_rank_panel = "prefabs/ui/backend/backendrankpanel.unity3d"
AssetConfig.backend_rank_window = "prefabs/ui/backend/backendrankwindow.unity3d"

-- ----------------------------
-- 单张的大图
-- hosr
-- ----------------------------
AssetConfig.stongbg = "textures/ui/bigbg/stonebg.unity3d"
AssetConfig.sing_bg = "textures/ui/bigbg/singbgi18n.unity3d"
AssetConfig.backend_big_bg = "prefabs/ui/bigatlas/backendbgi18n.unity3d"
AssetConfig.backend_exchange_bg = "prefabs/ui/bigatlas/exchangebgi18n.unity3d"
AssetConfig.FashionBg = "textures/bigbg/fashionbigbg.unity3d"
AssetConfig.mergeserver_bg = "textures/ui/bigbg/mergeserverbg.unity3d"
AssetConfig.witch_girl = "textures/ui/bigbg/witch.unity3d"
AssetConfig.summer_fruit_plant_bg1 = "textures/ui/bigbg/fruitplantbg1.unity3d"
AssetConfig.summer_fruit_plant_bg2 = "textures/ui/bigbg/fruitplantbg2.unity3d"
AssetConfig.summer_happy_bg = "textures/ui/bigbg/summerhappybg.unity3d"
AssetConfig.limittimeprivilege_bg = "textures/ui/bigbg/limittimeprivilegebgi18n.unity3d"
AssetConfig.wing_bg = "textures/ui/bigbg/wingbg.unity3d"
AssetConfig.exchangebg = "textures/ui/bigbg/exchangebg.unity3d"
AssetConfig.rolebg = "textures/ui/bigbg/rolebg.unity3d"
AssetConfig.rolebgnew = "textures/ui/bigbg/rolebgnew.unity3d"
AssetConfig.rolebgstand = "textures/ui/bigbg/rolestandbottom.unity3d"
AssetConfig.slotbg = "textures/ui/bigbg/slotbg.unity3d"
AssetConfig.eqmwashbg = "textures/ui/bigbg/eqmwashbg.unity3d"
AssetConfig.wingsbookbg = "textures/ui/bigbg/wingsbookbg.unity3d"
AssetConfig.guidegirl2 = "textures/ui/bigbg/guidegirl2.unity3d"
AssetConfig.ridebg = "textures/ui/bigbg/ridebg.unity3d"
AssetConfig.totembg = "textures/ui/bigbg/totembg.unity3d"
AssetConfig.taskBg = "textures/ui/bigbg/taskbg.unity3d"
AssetConfig.handbookBg = "textures/ui/bigbg/handbookbg.unity3d"
AssetConfig.blue_light = "textures/ui/bigbg/blue_light.unity3d"
AssetConfig.guidesprite = "textures/ui/bigbg/guidesprite.unity3d"
AssetConfig.nationafivebg = "prefabs/ui/bigatlas/nationaldayi18n2.unity3d"
AssetConfig.nationaldayrollbg2 = "prefabs/ui/bigatlas/nationaldayrollbg2.unity3d"
AssetConfig.nationaquestionbg = "prefabs/ui/bigatlas/nationaldayi18n3.unity3d"
AssetConfig.nationaldayballoonbg = "prefabs/ui/bigatlas/nationaldayballoonbg.unity3d"
AssetConfig.nationaldayrollbg1 = "prefabs/ui/bigatlas/i18nnationaldayrollbg1.unity3d"
AssetConfig.titlebg = "textures/ui/bigbg/titlebg.unity3d"
AssetConfig.i18nacticebegin = "textures/ui/bigbg/i18nacticebegin.unity3d"
AssetConfig.i18nacticeend = "textures/ui/bigbg/i18nacticeend.unity3d"
AssetConfig.guild_second_bg = "prefabs/ui/bigatlas/guildwelfaretopbg.unity3d"
AssetConfig.guild_red_bag_bg2 = "prefabs/ui/bigatlas/windowredbagbg2.unity3d"
AssetConfig.guild_activity_bg = "prefabs/ui/bigatlas/i18nguildactivity.unity3d"
AssetConfig.guild_welfare_bg = "prefabs/ui/bigatlas/i18nguildwelfare.unity3d"
AssetConfig.guild_fight_big_bg = "prefabs/ui/bigatlas/guildfightpanelbg.unity3d"
AssetConfig.guild_pray_bg = "prefabs/ui/bigatlas/guildpraybg.unity3d"
AssetConfig.i18n_sevenday_desc = "prefabs/ui/bigatlas/i18n_seventday_desc.unity3d"
AssetConfig.doubleelevengroupbuyi18n = "prefabs/ui/bigatlas/doubleelevengroupbuyi18n.unity3d"
AssetConfig.doubleelevenfeedbacki18n = "prefabs/ui/bigatlas/doubleelevenfeedbacki18n.unity3d"
AssetConfig.christmasgroupbuyi18n = "prefabs/ui/bigatlas/christmasgroupbuyi18n1.unity3d"
AssetConfig.christmasfeedbacki18n = "prefabs/ui/bigatlas/christmasbackendwantedbgi18n.unity3d"

AssetConfig.newlahourbg = "prefabs/ui/bigatlas/fivecolormountainriversbgi18n.unity3d"
AssetConfig.newlabertitle = "textures/ui/bigbg/fivecolormountainriversi18n.unity3d"
AssetConfig.newlahourbg1 = "prefabs/ui/bigatlas/fivecolormountainriversbg1i18n.unity3d"
AssetConfig.newlabertitle1 = "textures/ui/bigbg/fivecolormountainrivers1i18n.unity3d"

AssetConfig.doubleeleveni18n = "prefabs/ui/bigatlas/doubleeleveni18n.unity3d"
AssetConfig.singledog_bg = "prefabs/ui/bigatlas/singledog.unity3d"
AssetConfig.singledog_bg1 = "prefabs/ui/bigatlas/lunaryearbg.unity3d"
AssetConfig.singledog_bg2 = "prefabs/ui/bigatlas/lunaryearbottombg.unity3d"
AssetConfig.singledog_bg3 = "prefabs/ui/bigatlas/lunaryeartitlei18n.unity3d"
AssetConfig.rank_no_1 = "textures/ui/bigbg/no_1.unity3d"
AssetConfig.rank_no_2 = "textures/ui/bigbg/no_2.unity3d"
AssetConfig.warmwinteri18n = "prefabs/ui/bigatlas/warmwinteri18n.unity3d"

AssetConfig.campaigninquiry1 =  "prefabs/ui/bigatlas/campaigninquiry1.unity3d"
AssetConfig.campaigninquiry2 =  "prefabs/ui/bigatlas/campaigninquiry2.unity3d"
AssetConfig.petpartyi18n = "prefabs/ui/bigatlas/petpartyi18n.unity3d"

AssetConfig.petpartyTitle1 = "prefabs/ui/bigatlas/newrechargetitle.unity3d"
AssetConfig.petpartyTitlei18n1 = "prefabs/ui/bigatlas/newrechargetitlei18n.unity3d"

AssetConfig.whiteframe = "textures/ui/bigbg/whiteframe.unity3d"
AssetConfig.winterdiscounti18n = "prefabs/ui/bigatlas/winterdiscounti18n.unity3d"
AssetConfig.christmasridebgi19n = "prefabs/ui/bigatlas/christmasridei18n.unity3d"
AssetConfig.rushtopbg1 = "textures/ui/bigbg/rushtopbg1.unity3d"
AssetConfig.rushtopbg2 = "textures/ui/bigbg/rushtopbg2.unity3d"
AssetConfig.rushtopdecoration1 = "textures/ui/bigbg/rushtopdecoration1.unity3d"
AssetConfig.rushtopdecoration2 = "textures/ui/bigbg/rushtopdecoration2.unity3d"
AssetConfig.rushtopdecoration3 = "textures/ui/bigbg/rushtopdecoration3.unity3d"
AssetConfig.cuplight = "textures/ui/bigbg/cuplight.unity3d"
AssetConfig.getwini18n = "textures/ui/bigbg/getwini18n.unity3d"
AssetConfig.no1inworldlvlupi18n = "textures/ui/bigbg/no1inworldlvlupi18n.unity3d"
AssetConfig.no1inworldlvlupopeni18n = "textures/ui/bigbg/no1inworldlvlupopeni18n.unity3d"


AssetConfig.moment_panel = "prefabs/ui/zone/statuspanel.unity3d"
AssetConfig.moment_send_panel = "prefabs/ui/zone/statussendpanel.unity3d"
AssetConfig.moment_quicksend_panel = "prefabs/ui/zone/quickstatussendpanel.unity3d"
AssetConfig.moment_recall_panel = "prefabs/ui/zone/statusrecallpanel.unity3d"
AssetConfig.moment_photoedit_panel = "prefabs/ui/zone/photoaddpanel.unity3d"
AssetConfig.moment_photoprewview = "prefabs/ui/zone/photowatchpanel.unity3d"
AssetConfig.daily_topic_panel = "prefabs/ui/zone/daliytopicpanel.unity3d"

AssetConfig.random_fruit_tips = "prefabs/ui/tips/randomfruittips.unity3d"

AssetConfig.open_beta_textures = "textures/ui/openbeta.unity3d"
AssetConfig.open_beta_window = "prefabs/ui/openbeta/openbetawindow.unity3d"
AssetConfig.open_beta_ceremony = "prefabs/ui/openbeta/openbetaceremony.unity3d"
AssetConfig.open_beta_recharge = "prefabs/ui/openbeta/openbetarecharge.unity3d"
AssetConfig.open_beta_lotary = "prefabs/ui/openbeta/openbetalotary.unity3d"
AssetConfig.open_beta_bg1 = "prefabs/ui/bigatlas/i18n_obt1_bg.unity3d"
AssetConfig.open_beta_bg2 = "prefabs/ui/bigatlas/i18n_obt2_bg.unity3d"
AssetConfig.open_beta_bg3 = "prefabs/ui/bigatlas/i18n_obt3_bg.unity3d"


AssetConfig.magicbean_invite_window = "prefabs/ui/home/magicbeaninvitewindow.unity3d"

AssetConfig.multi_item_panel = "prefabs/ui/sing/multiitempanel.unity3d"

AssetConfig.cityset_panel = "prefabs/ui/zone/locationsetpanel.unity3d"
AssetConfig.moment_city_panel = "prefabs/ui/zone/citystatuspanel.unity3d"
AssetConfig.rolelev_frame = "textures/rolelevframe.unity3d"

AssetConfig.ride_skill_preview_panel = "prefabs/ui/ride/rideskillpreview.unity3d"

AssetConfig.notice_bottom_panel = "prefabs/ui/notice/noticebottompanel.unity3d"
AssetConfig.notice_bottom_panel_android = "prefabs/ui/notice/noticebottompanel_android.unity3d"
AssetConfig.notice_float_panel = "prefabs/ui/notice/noticefloatpanel.unity3d"
AssetConfig.notice_float_panel_android = "prefabs/ui/notice/noticefloatpanel_android.unity3d"
AssetConfig.notice_scroll_panel = "prefabs/ui/notice/noticescrollpanel.unity3d"
AssetConfig.dungeon_help_window = "prefabs/ui/dungeon/dungeonhelpwindow.unity3d"

AssetConfig.unlimited_trace = "prefabs/ui/teamquest/unlimitedcontent.unity3d"

AssetConfig.handbook_res = "textures/ui/handbook.unity3d"
AssetConfig.handbook_main = "prefabs/ui/handbook/handbookmainwindow.unity3d"
AssetConfig.handbook_info = "prefabs/ui/handbook/handbookinfopanel.unity3d"
AssetConfig.handbook_match = "prefabs/ui/handbook/handbookmatchpanel.unity3d"
AssetConfig.handbook_item = "prefabs/ui/handbook/handbookitempanel.unity3d"
AssetConfig.handbook_select_item = "prefabs/ui/handbook/handbookselectitem.unity3d"
AssetConfig.handbook_select_match = "prefabs/ui/handbook/handbookselectmatch.unity3d"
AssetConfig.handbook_usetips = "prefabs/ui/handbook/handbookusetips.unity3d"
AssetConfig.handbook_desctips = "prefabs/ui/handbook/handbookdesctips.unity3d"
AssetConfig.handbook_shop = "prefabs/ui/handbook/handbookshoppanel.unity3d"
AssetConfig.handbookmatch = "textures/handbookmatch.unity3d"
AssetConfig.handbookgetnew = "prefabs/ui/handbook/handbookgetnew.unity3d"
AssetConfig.handbooknewtitle = "textures/ui/bigbg/handbooknewtitle.unity3d"
AssetConfig.handbookreward = "prefabs/ui/handbook/handbookrewardpanel.unity3d"
AssetConfig.handbookhead = "textures/handbookheads.unity3d"
AssetConfig.handbook_merge = "prefabs/ui/handbook/handbookmergepanel.unity3d"
AssetConfig.handbook_merge_select_panel = "prefabs/ui/handbook/handbookmergeselepanel.unity3d"

AssetConfig.unlimited_texture = "textures/ui/unlimitedchallenge.unity3d"
AssetConfig.unlimited_panel = "prefabs/ui/unlimitedchallenge/unlimitedchallengepanel.unity3d"
AssetConfig.unlimited_rankpanel = "prefabs/ui/unlimitedchallenge/unlimitedchallengerankpanel.unity3d"
AssetConfig.unlimited_skillsetpanel = "prefabs/ui/unlimitedchallenge/unlimitedchallengeskillsetwindow.unity3d"
AssetConfig.unlimited_frightinfopanel = "prefabs/ui/unlimitedchallenge/unilimitedfrightpanel.unity3d"
AssetConfig.unlimited_cardwindow = "prefabs/ui/unlimitedchallenge/unlimitedchallengecardwindow.unity3d"

AssetConfig.shop_timely_panel = "prefabs/ui/shop/giftbagpanel.unity3d"
AssetConfig.shop_monthly_panel = "prefabs/ui/shop/monthlypanel.unity3d"

AssetConfig.backend_multipage_exchange = "prefabs/ui/backend/backendmultipageexchange.unity3d"

AssetConfig.headslot = "prefabs/ui/slot/headslot.unity3d"

AssetConfig.midAutumnBg = "textures/ui/bigbg/midautumnbg.unity3d"
AssetConfig.enjoy_moon_panel = "prefabs/ui/midautumn/enjoymoon.unity3d"
AssetConfig.midAutumn_textures = "textures/ui/midautumn.unity3d"
AssetConfig.midAutumn_question_window = "prefabs/ui/midautumn/lanternquestion.unity3d"
AssetConfig.midAutumn_lantern_letitgo = "prefabs/ui/midautumn/lanternletitgo.unity3d"   -- 放灯
AssetConfig.midAutumn_mainui_question = "prefabs/ui/midautumn/lanternfairmainuipanel.unity3d"
AssetConfig.midAutumn_lantern_settle = "prefabs/ui/midautumn/lanternsettle.unity3d"
AssetConfig.midAutumn_reward = "prefabs/ui/midautumn/midautumnreward.unity3d"
AssetConfig.midAutumn_enjoymoon_mainui = "prefabs/ui/midautumn/enjonmoonmainuipanel.unity3d"

AssetConfig.midAutumn_enjoymoon = "prefabs/ui/midautumn/enjoymoon.unity3d"
AssetConfig.midAutumn_desc = "prefabs/ui/midautumn/midautumndesc.unity3d"
AssetConfig.midAutumn_window = "prefabs/ui/midautumn/midautumnwindow.unity3d"



AssetConfig.levelbreakwindow = "prefabs/ui/levelbreak/levelbreakwindow.unity3d"
AssetConfig.exchangepointwindow = "prefabs/ui/levelbreak/exchangepointwindow.unity3d"
AssetConfig.levelbreaksuccesswindow = "prefabs/ui/levelbreak/levelbreaksuccesswindow.unity3d"
AssetConfig.levelbreak_texture = "textures/ui/levelbreak.unity3d"
AssetConfig.levelbreakeffect1 = "textures/ui/bigbg/levelbreakeffect1.unity3d"
AssetConfig.levelbreakeffect2 = "textures/ui/bigbg/levelbreakeffect2.unity3d"

AssetConfig.guildleague_window = "prefabs/ui/guildleague/guildleaguewindow.unity3d"
AssetConfig.guildleague_schedule_panel = "prefabs/ui/guildleague/guildleagueschedule.unity3d"
AssetConfig.guildleague_rank_panel = "prefabs/ui/guildleague/guildleaguerank.unity3d"
AssetConfig.guildleague_info_panel = "prefabs/ui/guildleague/guildleagueinfo.unity3d"
AssetConfig.guildleague_fightschedule_panel = "prefabs/ui/guildleague/guildleaguefightschedule.unity3d"
AssetConfig.guildleague_menber_fightrank_panel = "prefabs/ui/guildleague/guildleaguemenberfightrankpanel.unity3d"
AssetConfig.guildleague_count_panel = "prefabs/ui/guildleague/guildleaguecount.unity3d"
AssetConfig.guildleague_texture = "textures/ui/guildleague.unity3d"
AssetConfig.guildleague_levicon = "textures/ui/guildleagueicon.unity3d"
AssetConfig.guildleaguefightinfo = "prefabs/ui/guildleague/guildleaguefightinfo.unity3d"
AssetConfig.guildleague_desc_panel = "prefabs/ui/guildleague/guildleaguedescpanel.unity3d"
AssetConfig.guildleague_groupinfo_panel = "prefabs/ui/guildleague/guildleaguegroupinfopanel.unity3d"
AssetConfig.guildleagueguesswindow = "prefabs/ui/guildleague/guildleagueguesswindow.unity3d"
AssetConfig.guildleague_history_panel = "prefabs/ui/guildleague/guildleaguehistorpanel.unity3d"
AssetConfig.guildleaguelivewindow = "prefabs/ui/guildleague/guildleaguelivewindow.unity3d"
AssetConfig.guildleaguegiveboxpanel = "prefabs/ui/guildleague/guildleaguegiveboxpanel.unity3d"
AssetConfig.guildleague_showcupwindow = "prefabs/ui/guildleague/guildleagueshowcup.unity3d"
AssetConfig.guildleaguecupwindow = "prefabs/ui/guildleague/guildleaguecupwindow.unity3d"
AssetConfig.guildnewguildbuild = "prefabs/ui/guild/getnewguildbuild.unity3d"


AssetConfig.sharemainwindow = "prefabs/ui/share/sharemainwindow.unity3d"
AssetConfig.sharemainpanel = "prefabs/ui/share/sharemainpanel.unity3d"
AssetConfig.shareshopwindow = "prefabs/ui/share/shareshopwindow.unity3d"
AssetConfig.sharebindpanel = "prefabs/ui/share/sharebindwindow.unity3d"
AssetConfig.sharebindtipspanel = "prefabs/ui/share/sharebindtipspanel.unity3d"
AssetConfig.shareres = "textures/ui/share.unity3d"
AssetConfig.shareicon = "textures/shareicon.unity3d"
AssetConfig.settingres = "textures/ui/setting.unity3d"

AssetConfig.guideres = "textures/ui/guide.unity3d"
AssetConfig.midAutumn_danmaku = "prefabs/ui/midautumn/midautumndanmaku.unity3d"

AssetConfig.midAutumnBg1 = "textures/ui/bigbg/midautumni18n1.unity3d"
AssetConfig.midAutumnBg2 = "textures/ui/bigbg/midautumni18n2.unity3d"
AssetConfig.midAutumnBg3 = "textures/ui/bigbg/midautumni18n3.unity3d"

AssetConfig.recharge_package_panel = "prefabs/ui/rechargepackage/rechargepackagepanel.unity3d"

AssetConfig.sales_promotion_panel = "prefabs/ui/salespromotion/salespromotionpanel.unity3d"

AssetConfig.portrait_window = "prefabs/ui/portrait/portraitwindow.unity3d"
AssetConfig.portrait_textures = "textures/ui/portrait.unity3d"

AssetConfig.head_custom_face_male_1 = "textures/headcustom/face/male/part1.unity3d"
AssetConfig.head_custom_face_female_1 = "textures/headcustom/face/female/part1.unity3d"
AssetConfig.head_custom_face_male_2 = "textures/headcustom/face/male/part2.unity3d"
AssetConfig.head_custom_face_female_2 = "textures/headcustom/face/female/part2.unity3d"
AssetConfig.head_custom_hair_male = "textures/headcustom/hair/male.unity3d"
AssetConfig.head_custom_hair_female_1 = "textures/headcustom/hair/female/part1.unity3d"
AssetConfig.head_custom_hair_female_2 = "textures/headcustom/hair/female/part2.unity3d"
AssetConfig.head_custom_wear1 = "textures/headcustom/wear/part1.unity3d"
AssetConfig.head_custom_wear2 = "textures/headcustom/wear/part2.unity3d"
AssetConfig.head_custom_photoframe = "textures/headcustom/photoframe.unity3d"
AssetConfig.head_custom_bg = "textures/headcustom/bg.unity3d"
AssetConfig.head_custom_specail = "textures/headcustom/specailicon.unity3d"
AssetConfig.guildleaguebig = "textures/ui/bigbg/leaguebig.unity3d"

--国庆活动
AssetConfig.national_day_res = "textures/ui/nationday.unity3d"
AssetConfig.national_day_main_window = "prefabs/ui/nationalday/nationaldaymainwindow.unity3d"
AssetConfig.national_day_question_window = "prefabs/ui/nationalday/nationaldayquestionwindow.unity3d"
AssetConfig.national_day_five_panel = "prefabs/ui/nationalday/nationaldayfiveroundpanel.unity3d"
AssetConfig.nationaldayballoonpanel = "prefabs/ui/nationalday/nationaldayballoonpanel.unity3d"
AssetConfig.nationaldayrewardshowpanel = "prefabs/ui/nationalday/nationaldayrewardshowpanel.unity3d"
AssetConfig.nationaldayrollpanel = "prefabs/ui/nationalday/nationaldayrollpanel.unity3d"
AssetConfig.national_day_question_panel = "prefabs/ui/nationalday/nationaldayquestionpanel.unity3d"
AssetConfig.national_day_defense_panel = "prefabs/ui/nationalday/nationaldaydefensepanel.unity3d"
AssetConfig.national_day_defense_question_window = "prefabs/ui/nationalday/nationaldaydefensequestionwindow.unity3d"
AssetConfig.national_day_i18n1 = "prefabs/ui/bigatlas/nationaldayi18n1.unity3d"
AssetConfig.national_day_i18n4 = "prefabs/ui/bigatlas/nationaldayi18n4.unity3d"
AssetConfig.national_treature_bg = "prefabs/ui/bigatlas/nationaltreaturebgi18n.unity3d"
AssetConfig.national_treature_bg1 = "prefabs/ui/bigatlas/nationaltreaturebgi18n1.unity3d"
AssetConfig.national_treature_bg2 = "prefabs/ui/bigatlas/nationaltreaturebgi18n2.unity3d"
--AssetConfig.national_day_i18n5 = "textures/ui/bigbg/nationaldayi18n5.unity3d"

--双十一活动
AssetConfig.doubleeleven_res = "textures/ui/doubleeleven.unity3d"
AssetConfig.double_eleven_main_window = "prefabs/ui/doubleeleven/doubleelevenmainwindow.unity3d"
AssetConfig.double_eleven_groupbuy_panel = "prefabs/ui/doubleeleven/doubleelevengroupbuypanel.unity3d"
AssetConfig.double_eleven_feedback_panel = "prefabs/ui/doubleeleven/doubleelevenfeedbackpanel.unity3d"


AssetConfig.info_window = "prefabs/ui/backpack/infowindow.unity3d"
AssetConfig.info_honor_window = "prefabs/ui/backpack/infohonorwindow.unity3d"
AssetConfig.info_textures = "textures/ui/info.unity3d"
AssetConfig.res_honor = "textures/ui/honor.unity3d"
AssetConfig.classeschangewindow = "prefabs/ui/classeschange/classeschangewindow.unity3d"
AssetConfig.classeschangesuccesswindow = "prefabs/ui/classeschange/classeschangesuccesswindow.unity3d"
AssetConfig.gemchangewindow = "prefabs/ui/classeschange/gemchangewindow.unity3d"
AssetConfig.TalismanChangeWindow = "prefabs/ui/classeschange/talismanchangewindow.unity3d"

AssetConfig.halloweenwindow = "prefabs/ui/halloween/halloweenwindow.unity3d"
AssetConfig.pumpkingoblin = "prefabs/ui/halloween/pumpkingoblin.unity3d"
AssetConfig.halloweenmenu = "prefabs/ui/halloween/halloweenmenu.unity3d"
AssetConfig.halloweentitle = "prefabs/ui/halloween/halloweentitle.unity3d"
AssetConfig.halloweenrank = "prefabs/ui/halloween/halloweenrank.unity3d"
AssetConfig.halloweensignup = "prefabs/ui/halloween/halloweensignup.unity3d"
AssetConfig.halloweenmatchwindow = "prefabs/ui/halloween/halloweenmatchwindow.unity3d"
AssetConfig.halloweendeadtips = "prefabs/ui/halloween/halloweendeadtips.unity3d"
AssetConfig.halloweenKillEvil = "prefabs/ui/halloween/killevilpanel.unity3d"
AssetConfig.halloweensuger = "prefabs/ui/halloween/sugerpanel.unity3d"
AssetConfig.newrechargepanel = "prefabs/ui/halloween/newrechargepanel.unity3d"
AssetConfig.halloweenmoon = "prefabs/ui/halloween/halloweenmoon.unity3d"
AssetConfig.halloweenKillEvilCardWindow = "prefabs/ui/halloween/killevilcardwindow.unity3d"
AssetConfig.halloween_textures = "textures/ui/halloween.unity3d"
AssetConfig.halloweenKillEvilBg = "prefabs/ui/bigatlas/halloweenkillevilbg.unity3d"
AssetConfig.halloweenscenebtn = "prefabs/ui/halloween/halloweenscenebtn.unity3d"
AssetConfig.halloween_pumpkin_ready = "prefabs/ui/halloween/halloweenreadycontent.unity3d"
--春节年货
AssetConfig.newyeargoodstext1 = "prefabs/ui/bigatlas/newyeargoodstitlei18n1.unity3d"
AssetConfig.newyeargoodstext2 = "prefabs/ui/bigatlas/newyeargoodstitlei18n2.unity3d"
AssetConfig.newyeargoodstitle = "prefabs/ui/bigatlas/newyeargoodstitle.unity3d"

AssetConfig.godswarres = "textures/ui/godswar.unity3d"
AssetConfig.godswarmain = "prefabs/ui/godswar/godswarwindow.unity3d"
AssetConfig.godswarinfo = "prefabs/ui/godswar/godswarinfopanel.unity3d"
AssetConfig.godswarrule = "prefabs/ui/godswar/godswarrulepanel.unity3d"
AssetConfig.godswarteam = "prefabs/ui/godswar/godswarteampanel.unity3d"
AssetConfig.godswarteamlist = "prefabs/ui/godswar/godswarteamlistpanel.unity3d"
AssetConfig.godswarteaminfo = "prefabs/ui/godswar/godswarteaminfopanel.unity3d"
AssetConfig.godswarrequestlist = "prefabs/ui/godswar/godswarrequestlistpanel.unity3d"
AssetConfig.godswarprogress = "prefabs/ui/godswar/godswarprogresspanel.unity3d"
AssetConfig.godswarcreate = "prefabs/ui/godswar/godswarcreatepanel.unity3d"
AssetConfig.godswarapply = "prefabs/ui/godswar/godswarapplypanel.unity3d"
AssetConfig.godswarnotice = "prefabs/ui/godswar/godswarnoticepanel.unity3d"
AssetConfig.godswarmember = "prefabs/ui/godswar/godswarmemberpanel.unity3d"
AssetConfig.godswarfight = "prefabs/ui/godswar/godswarfightpanel.unity3d"
AssetConfig.godswarfightmy = "prefabs/ui/godswar/godswarfightmypanel.unity3d"
AssetConfig.godswarfightlist = "prefabs/ui/godswar/godswarfightlistpanel.unity3d"
AssetConfig.godswarfightdetail = "prefabs/ui/godswar/godswarfightdetailpanel.unity3d"
AssetConfig.godswarfightselect = "prefabs/ui/godswar/godswarfightselectpanel.unity3d"
AssetConfig.godswarfightselect1 = "prefabs/ui/godswar/godswarfightselectpanel1.unity3d"
AssetConfig.godswarfightselect2 = "prefabs/ui/godswar/godswarfightselectpanel2.unity3d"
AssetConfig.godswarmainuitrace = "prefabs/ui/teamquest/godswarcontent.unity3d"
AssetConfig.godswarfightshow = "prefabs/ui/godswar/godswarfightshowpanel.unity3d"
AssetConfig.godswarresult = "prefabs/ui/godswar/godswarresultpanel.unity3d"
AssetConfig.godswarelimination = "prefabs/ui/godswar/godswarfighteliminationpanel.unity3d"
AssetConfig.godswarmainuitop = "prefabs/ui/godswar/godswarmainuitop.unity3d"
AssetConfig.godswarfightfinal = "prefabs/ui/godswar/godswarfightfinalpanel.unity3d"
AssetConfig.godswarfinalvote = "prefabs/ui/godswar/godswarfightfinalvotepanel.unity3d"
AssetConfig.godswarmovie = "prefabs/ui/godswar/godswarmoviewindow.unity3d"
AssetConfig.godswarworshipmovie = "prefabs/ui/godswar/godswarworshipmoviewindow.unity3d"
AssetConfig.godswarvote = "prefabs/ui/godswar/godswarvotepanel.unity3d"
AssetConfig.godswarresultbg = "textures/ui/bigbg/godswarresultbg.unity3d"
AssetConfig.godswarsettlementpanel = "prefabs/ui/godswar/godswarsettlementpanel.unity3d"
AssetConfig.godswarchallengesettlementpanel = "prefabs/ui/godswar/godswarchallengesettlementwin.unity3d"
-- 诸神之战历史界面
AssetConfig.godswarhistorypanel = "prefabs/ui/godswar/godswarhistorypanel.unity3d"
AssetConfig.godswarselectseasonpanel = "prefabs/ui/godswar/godswarselectseasonpanel.unity3d"


-- ----------------------------
-- 切割过的大图
-- ----------------------------
AssetConfig.bigatlas_sing_bg = "prefabs/ui/bigatlas/singbgi18n.unity3d"
AssetConfig.bigatlas_taskBg = "prefabs/ui/bigatlas/taskbg.unity3d"
AssetConfig.bigatlas_summer_happy_bg = "prefabs/ui/bigatlas/summerhappybg.unity3d"

AssetConfig.i18nnationaldayrollbg1 = "prefabs/ui/bigatlas/i18nnationaldayrollbg1.unity3d"
AssetConfig.nationaldayballoonbg = "prefabs/ui/bigatlas/nationaldayballoonbg.unity3d"

AssetConfig.bigatlas_titlebg = "prefabs/ui/bigatlas/titlebg.unity3d"
AssetConfig.bigatlas_open_beta_bg1 = "prefabs/ui/bigatlas/i18n_obt1_bg.unity3d"
AssetConfig.bigatlas_open_beta_bg2 = "prefabs/ui/bigatlas/i18n_obt2_bg.unity3d"
AssetConfig.bigatlas_open_beta_bg3 = "prefabs/ui/bigatlas/i18n_obt3_bg.unity3d"
AssetConfig.bigatlas_midAutumnBg1 = "prefabs/ui/bigatlas/midautumni18n1.unity3d"
AssetConfig.bigatlas_midAutumnBg2 = "prefabs/ui/bigatlas/midautumni18n2.unity3d"
AssetConfig.bigatlas_midAutumnBg3 = "prefabs/ui/bigatlas/midautumni18n3.unity3d"
AssetConfig.bigatlas_backend_wanted_bg = "prefabs/ui/bigatlas/backendwantedbgi18n.unity3d"
AssetConfig.bigatlas_shop_monthly_bg= "prefabs/ui/bigatlas/shopmonthlybg.unity3d"

AssetConfig.newmoon_bigdipper = "prefabs/ui/newmoon/bigdipperpanel.unity3d"
AssetConfig.newmoon_continuerecharge = "prefabs/ui/newmoon/continuerecharge.unity3d"
AssetConfig.newmoon_textures = "textures/ui/newmoon.unity3d"

AssetConfig.bigatlas_halloweenbg = "prefabs/ui/bigatlas/halloweenbg.unity3d"
AssetConfig.bigatlas_godswarbg1i18n = "prefabs/ui/bigatlas/godswarbg1i18n.unity3d"
AssetConfig.bigatlas_godswarbg0 = "prefabs/ui/bigatlas/godswarbg0.unity3d"

AssetConfig.fairylandluckdrawbg = "prefabs/ui/bigatlas/fairylandluckdrawbg.unity3d"

AssetConfig.midAutumnBg = "prefabs/ui/bigatlas/midautumnlanternsi18n.unity3d"
AssetConfig.rechargePackage = "prefabs/ui/bigatlas/rechargepacki18n.unity3d"
AssetConfig.poetryChallenge = "prefabs/ui/bigatlas/poetrychallengebg.unity3d"
AssetConfig.poetryChallengeText = "prefabs/ui/bigatlas/poetrychallengetexti18n.unity3d"
AssetConfig.lunarLanterntopBg = "prefabs/ui/bigatlas/lunarlanterntopbg.unity3d"
AssetConfig.realnamei18n = "prefabs/ui/bigatlas/realnamei18n.unity3d"
AssetConfig.chiefchallengebg = "prefabs/ui/bigatlas/chiefchallengebg.unity3d"
AssetConfig.exercisebg = "prefabs/ui/bigatlas/exercisebg.unity3d"
AssetConfig.downloadnewapki18n = "prefabs/ui/bigatlas/downloadnewapki18n.unity3d"

-- 结拜
AssetConfig.sworn_textures = "textures/ui/sworn.unity3d"
AssetConfig.sworn_progress_window = "prefabs/ui/sworn/swornprogresswindow.unity3d"
AssetConfig.sworn_panel = "prefabs/ui/sworn/swornpanel.unity3d"
AssetConfig.sworn_bg = "prefabs/ui/bigatlas/swornbg.unity3d"
AssetConfig.sworn_status_icon = "prefabs/ui/sworn/swornstatusicon.unity3d"
AssetConfig.sworn_desc_window = "prefabs/ui/sworn/sworndescwindow.unity3d"
AssetConfig.sworn_friend_choose = "prefabs/ui/sworn/swornfriendchoosepanel.unity3d"
AssetConfig.sworn_getout = "prefabs/ui/sworn/sworngetoutpanel.unity3d"
AssetConfig.sworn_reason = "prefabs/ui/sworn/swornreasonpanel.unity3d"
AssetConfig.sworn_invite = "prefabs/ui/sworn/sworninvitepanel.unity3d"
AssetConfig.sworn_confirm_window = "prefabs/ui/sworn/swornconfirmwindow.unity3d"
AssetConfig.sworn_modify_window = "prefabs/ui/sworn/swornmodifywindow.unity3d"

AssetConfig.button_list_panel = "prefabs/ui/sworn/buttonlistpanel.unity3d"


AssetConfig.grow_fund_panel = "prefabs/ui/bible/growfundpanel.unity3d"
AssetConfig.grow_fund_bg = "prefabs/ui/bigatlas/growfundbg.unity3d"
AssetConfig.grow_fund_subpanel = "prefabs/ui/bible/growfundsubpanel.unity3d"

AssetConfig.fly_item_panel = "prefabs/ui/bible/flytopanel.unity3d"

AssetConfig.festival_winter = "prefabs/ui/bigatlas/festivalwinter.unity3d"

AssetConfig.thanksgiving_active = "prefabs/ui/thanksgiving/thanksgivingactivepanel.unity3d"
AssetConfig.thanksgiving_textures = "textures/ui/thanksgiving.unity3d"
AssetConfig.thanksgiving_active_i18n = "prefabs/ui/bigatlas/thanksgivingactivei18n.unity3d"
AssetConfig.thanksgiving_question_i18n = "prefabs/ui/bigatlas/thanksgivingquestioni18n.unity3d"

AssetConfig.market_sellgold_setting = "prefabs/ui/market/settingpanel.unity3d"
AssetConfig.market_sellgold_window = "prefabs/ui/market/marketsellgoldwindow.unity3d"
AssetConfig.regression_window = "prefabs/ui/regression/regressionwindow.unity3d"
AssetConfig.regression_panel1 = "prefabs/ui/regression/regressionpanel1.unity3d"
AssetConfig.regression_panel2 = "prefabs/ui/regression/regressionpanel2.unity3d"
AssetConfig.regression_panel3 = "prefabs/ui/regression/regressionpanel3.unity3d"
AssetConfig.regression_panel4 = "prefabs/ui/regression/regressionpanel4.unity3d"
AssetConfig.invitationfriendreturnwindow = "prefabs/ui/regression/invitationfriendreturnwindow.unity3d"
AssetConfig.inputrecruitidwindow = "prefabs/ui/regression/inputrecruitidwindow.unity3d"
AssetConfig.regressionloginchestboxwindow = "prefabs/ui/regression/regressionloginchestboxwindow.unity3d"
AssetConfig.regression_textures = "textures/ui/regression.unity3d"
AssetConfig.bigatlas_regression = "prefabs/ui/bigatlas/regression.unity3d"
AssetConfig.bigatlas_regression2 = "prefabs/ui/bigatlas/regression2.unity3d"
AssetConfig.bigatlas_rechargepet = "prefabs/ui/bigatlas/rechargeshowpetbg.unity3d"

AssetConfig.festival_winter = "prefabs/ui/bigatlas/festivalwinter.unity3d"


AssetConfig.warrior_desc_window = "prefabs/ui/warrior/warriordeswindow.unity3d"
AssetConfig.sell_confirm_window = "prefabs/ui/market/sellconfirmwin.unity3d"

AssetConfig.opengiftshowpanel = "prefabs/ui/giftshow/opengiftshowpanel.unity3d"
-- 收集条
AssetConfig.collect_textures = "textures/ui/collectbar.unity3d"
AssetConfig.talkbubble_textures = "textures/ui/talkbubble.unity3d"

AssetConfig.openserver_therion_i18n = "prefabs/ui/bigatlas/openservertherioni18n.unity3d"
AssetConfig.openserver_rank_i18n = "prefabs/ui/bigatlas/openserverranki18n.unity3d"
AssetConfig.open_server_luckymoney1 = "textures/ui/bigbg/i18nluckymoney1.unity3d"
AssetConfig.open_server_luckymoney2 = "textures/ui/bigbg/i18nluckymoney2.unity3d"
AssetConfig.open_server_luckymoney3 = "textures/ui/bigbg/i18nluckymoney3.unity3d"
AssetConfig.open_server_charge_bg = "prefabs/ui/bigatlas/openserverchargei18n.unity3d"
AssetConfig.open_server_dividend = "prefabs/ui/openserver/dividendpanel.unity3d"
AssetConfig.open_server_dividend_bg = "prefabs/ui/bigatlas/openserverdividendi18n.unity3d"
AssetConfig.open_server_reward = "prefabs/ui/openserver/reweardpanel.unity3d"
AssetConfig.open_server_reward_bg = "prefabs/ui/bigatlas/openserverrewardi18n.unity3d"

AssetConfig.unlimitedsinglechallengepanel = "prefabs/ui/unlimitedchallenge/unlimitedsinglechallengepanel.unity3d"

AssetConfig.rechargeshowpet = "prefabs/ui/rechargeshowpet/rechargeshowpet.unity3d"
AssetConfig.rechargeshowpet_res = "textures/ui/rechargeshowpet.unity3d"
AssetConfig.openservertrevifountainpanel = "prefabs/ui/openserver/openservertrevifountainpanel.unity3d"
AssetConfig.trevifountain_i18N = "prefabs/ui/bigatlas/trevifountain.unity3d"
AssetConfig.openserverlpanel = "prefabs/ui/openserver/openserverlpanel.unity3d"

AssetConfig.elementdungeonwindow = "prefabs/ui/elementdungeon/elementdungeonwindow.unity3d"
AssetConfig.elementdungeon_map = "prefabs/ui/elementdungeon/map%s.unity3d"
AssetConfig.elementdungeon_map_bigatlas = "prefabs/ui/bigatlas/elementdungeonmap%s.unity3d"
AssetConfig.elementdungeon_textures = "textures/ui/elementdungeon.unity3d"

AssetConfig.guideheadshow = "prefabs/ui/guide/guideheadshow.unity3d"

AssetConfig.notnamedtreasurewindow = "prefabs/ui/campaign/notnamedtreasurewindow.unity3d"
AssetConfig.notnamedtreasure_textures = "textures/ui/notnamedtreasure.unity3d"

AssetConfig.fashionres = "textures/ui/fashion.unity3d"
AssetConfig.effectbg = "textures/ui/bigbg/effectbg.unity3d"
AssetConfig.effectbg2 = "textures/ui/bigbg/effectbg2.unity3d"

AssetConfig.christmas_textures = "textures/ui/christmas.unity3d"
AssetConfig.christmas_snowman_window = "prefabs/ui/christmas/christmassnowmanwindow.unity3d"
AssetConfig.christmas_desc = "prefabs/ui/christmas/christmasdesc.unity3d"
AssetConfig.christmas_ride = "prefabs/ui/christmas/christmasride.unity3d"
AssetConfig.christmas_bg = "prefabs/ui/bigatlas/christmas_bg.unity3d"
AssetConfig.christmas_bg1 = "prefabs/ui/bigatlas/christmasbg1i18n.unity3d"
AssetConfig.christmassnowfightti18n = "prefabs/ui/bigatlas/christmassnowfightti18n.unity3d"

AssetConfig.continue_recharge_window = "prefabs/ui/newmoon/continuerechargewindow.unity3d"

AssetConfig.guidehatshow = "prefabs/ui/guide/guidehatshow.unity3d"

-- 元旦活动
AssetConfig.new_year_window = "prefabs/ui/newyear/newyearwindow.unity3d"
AssetConfig.new_year_reward = "prefabs/ui/newyear/newyearreward.unity3d"
AssetConfig.new_year_recharge_bg = "prefabs/ui/bigatlas/newyearrechargebg.unity3d"
AssetConfig.new_year_reward_bg_new = "prefabs/ui/bigatlas/haolibg.unity3d"
AssetConfig.newyear_textures = "textures/ui/newyear.unity3d"
AssetConfig.new_year_fight_bg = "prefabs/ui/bigatlas/newyearfighti18n.unity3d"

--新春转盘活动
AssetConfig.new_year_turnable_window = "prefabs/ui/newyear/newyearturntablewin.unity3d"
AssetConfig.turnable_jackpotbg = "textures/ui/bigbg/jackpotbg2.unity3d"
AssetConfig.turnable_jackpotbottombg = "textures/ui/bigbg/jackpotbottombg2.unity3d"
AssetConfig.turnable_recordtitlebg = "textures/ui/bigbg/recordtitlebg.unity3d"
AssetConfig.turnable_turnablebg = "textures/ui/bigbg/turnablebg.unity3d"
AssetConfig.turnable_turnableitembg = "textures/ui/bigbg/turnableitembg2.unity3d"
AssetConfig.turnable_turnableitembg1 = "textures/ui/bigbg/turnableitembg3.unity3d"
AssetConfig.turnable_turnablebtn = "textures/ui/bigbg/turnabledrawbtn.unity3d"
AssetConfig.new_year_turnableleftbg = "textures/ui/bigbg/newyearturnleftbg.unity3d"

AssetConfig.new_year_turn_bg = "prefabs/ui/bigatlas/newyearturnabledecolate.unity3d"
AssetConfig.new_year_turn_titlei18n = "prefabs/ui/bigatlas/newyearturntitlei18n.unity3d"
AssetConfig.new_year_turnablebigbg = "prefabs/ui/bigatlas/newyearturnablebigbg2.unity3d"
AssetConfig.turnable_texture = "textures/ui/newyearturnable.unity3d"


AssetConfig.getrole = "prefabs/ui/equipstrength/getrole.unity3d"
AssetConfig.strengthpreviewtips = "prefabs/ui/equipstrength/strengthpreviewtips.unity3d"
AssetConfig.skiingpanel = "prefabs/ui/skiing/skiingpanel.unity3d"

AssetConfig.snowball_trace = "prefabs/ui/teamquest/snowballcontent.unity3d"
AssetConfig.halloweensignup1 = "prefabs/ui/snowball/snowballsignup.unity3d"
AssetConfig.haloi18ntext = "textures/ui/bigbg/haloi18ntext.unity3d"
AssetConfig.bigRound = "textures/ui/bigbg/round.unity3d"
AssetConfig.itemContanerRound = "textures/ui/bigbg/itemcontainer.unity3d"

AssetConfig.snowballsignup = "prefabs/ui/snowball/snowballsignup.unity3d"
AssetConfig.snowballicon = "textures/ui/snowball.unity3d"
AssetConfig.snowballshowpanel = "prefabs/ui/snowball/snowballshowpanel.unity3d"

AssetConfig.reward_getback = "prefabs/ui/rewardback/rewardgetback.unity3d"
AssetConfig.reward_back_confirm = "prefabs/ui/rewardback/rewardbackconfirm.unity3d"
AssetConfig.reward_back_panel = "prefabs/ui/rewardback/rewardpanel.unity3d"

AssetConfig.childrengetwindow = "prefabs/ui/children/childrengetwindow.unity3d"
AssetConfig.howtogetchildrenpanel = "prefabs/ui/children/howtogetchildrenpanel.unity3d"
AssetConfig.childrenbirthpanel = "prefabs/ui/children/childrenbirthpanel.unity3d"
AssetConfig.childrenafterbirthpanel = "prefabs/ui/children/childrenafterbirthpanel.unity3d"
AssetConfig.childrengetwaypanel = "prefabs/ui/children/childrengetwaypanel.unity3d"
AssetConfig.childrenwaterwindow = "prefabs/ui/children/childrenwaterwindow.unity3d"
AssetConfig.childrencontainerpanel = "prefabs/ui/children/childrencontainerpanel.unity3d"
AssetConfig.childrentextures = "textures/ui/children.unity3d"
AssetConfig.childreneducationwindow = "prefabs/ui/children/childreneducationwindow.unity3d"
AssetConfig.childrennoticepanel = "prefabs/ui/children/childrennoticepanel.unity3d"
AssetConfig.childrennoticetargetpanel = "prefabs/ui/children/childrennoticetargetpanel.unity3d"
AssetConfig.child_change_type = "prefabs/ui/children/childrenchagetypepanel.unity3d"
AssetConfig.child_choose_classes = "prefabs/ui/children/childrenchooseclassespanel.unity3d"
AssetConfig.childrennoticeresultpanel = "prefabs/ui/children/childrennoticeresultpanel.unity3d"

AssetConfig.petwindow_child = "prefabs/ui/pet/petwindow_child.unity3d"
AssetConfig.petwindow_childattrpanel = "prefabs/ui/pet/petwindow_childattrpanel.unity3d"
AssetConfig.petwindow_childheadbar = "prefabs/ui/pet/petwindow_childheadbar.unity3d"
AssetConfig.petwindow_childskillpanel = "prefabs/ui/pet/petwindow_childskillpanel.unity3d"
AssetConfig.petwindow_childtelentpanel = "prefabs/ui/pet/petwindow_childtelentpanel.unity3d"
AssetConfig.petchildchangetelent = "prefabs/ui/pet/petchildchangetelent.unity3d"

AssetConfig.world_red_bag_win = "prefabs/ui/redbag/worldredbagopenwindow.unity3d"
AssetConfig.world_red_bag_unopen_win = "prefabs/ui/redbag/worldredbagunopenwindow.unity3d"
AssetConfig.world_red_bag_set_win = "prefabs/ui/redbag/worldredbagsetwindow.unity3d"
AssetConfig.world_red_bag_money_win = "prefabs/ui/redbag/worldredbagmoneywin.unity3d"
AssetConfig.world_red_bag_list_win = "prefabs/ui/redbag/worldredbaglistwindow.unity3d"
AssetConfig.world_red_bag_input_window = "prefabs/ui/redbag/worldredbaginputwindow.unity3d"

AssetConfig.childbirth_feedback_bg = "prefabs/ui/bigatlas/childfeedbackbgi18n.unity3d"
AssetConfig.child_flower_panel = "prefabs/ui/children/childflowerpanel.unity3d"
AssetConfig.sevencolor_bg = "prefabs/ui/bigatlas/sevencolorti18n.unity3d"
AssetConfig.child_flower_bg = "prefabs/ui/bigatlas/childflowerbg.unity3d"
AssetConfig.child_flower_bg_text = "prefabs/ui/bigatlas/childflowerbgi18n.unity3d"
AssetConfig.child_hundred_panel = "prefabs/ui/children/childhundredpanel.unity3d"
AssetConfig.child_hundred_bg = "prefabs/ui/bigatlas/childhundredbg.unity3d"
AssetConfig.childbirth_textures = "textures/ui/childbirth.unity3d"
AssetConfig.classesnamei18n = "textures/classesnamei18n.unity3d"
AssetConfig.childleanskill = "prefabs/ui/pet/childlearnskillpanel.unity3d"
AssetConfig.childquickshow = "prefabs/ui/pet/childquickshow.unity3d"
AssetConfig.childgenwash = "prefabs/ui/pet/childgenwash.unity3d"
AssetConfig.childhead = "textures/childhead.unity3d"
AssetConfig.childtelenticon = "textures/childtelenticon.unity3d"
AssetConfig.getchildrenafterbirth = "prefabs/ui/children/getchildrenafterbirth.unity3d"
AssetConfig.childfeedwindow = "prefabs/ui/pet/childfeedwindow.unity3d"
AssetConfig.childtelentpreview = "prefabs/ui/pet/petchildtelentpreview.unity3d"
AssetConfig.childstudyplan = "prefabs/ui/children/childrenstudyplanpanel.unity3d"

AssetConfig.luckmoney2 = "prefabs/ui/springfestival/luckymoney2.unity3d"
AssetConfig.snowfighti18n = "prefabs/ui/bigatlas/snowfighti18n.unity3d"
AssetConfig.childrename = "prefabs/ui/children/childrenrenamepanel.unity3d"
AssetConfig.childdepositwindow = "prefabs/ui/children/childdepositwindow.unity3d"

AssetConfig.teamdungeonwindow = "prefabs/ui/teamdungeon/teamdungeonwindow.unity3d"
AssetConfig.teamdungeoncardwindow = "prefabs/ui/teamdungeon/teamdungeoncardwindow.unity3d"
AssetConfig.teamdungeonicon = "prefabs/ui/teamdungeon/teamdungeonicon.unity3d"
AssetConfig.teamdungeon_textures = "textures/ui/teamdungeon.unity3d"

AssetConfig.valentine_bg = "prefabs/ui/bigatlas/valentinesbg.unity3d"

AssetConfig.unitstate = "prefabs/ui/unitstate/unitstatepanel.unity3d"

AssetConfig.valentine_lantern_bg = "prefabs/ui/bigatlas/valentinelanternbg.unity3d"

AssetConfig.openserverseven_bg = "prefabs/ui/bigatlas/openserverseveni18n.unity3d"
AssetConfig.openserverseven = "prefabs/ui/openserver/openserverseven.unity3d"
AssetConfig.rotary_table = "prefabs/ui/bigatlas/rotarytable.unity3d"
AssetConfig.rotary_rabit = "prefabs/ui/bigatlas/rabit.unity3d"

AssetConfig.treasuremazewindow = "prefabs/ui/treasuremaze/treasuremazewindow.unity3d"
AssetConfig.treasuremazerewardpanel = "prefabs/ui/treasuremaze/mazerewardwin.unity3d"
AssetConfig.mazemosterpanel = "prefabs/ui/treasuremaze/mazemosterpanel.unity3d"
AssetConfig.treasuremazetexture = "textures/ui/treasuremaze.unity3d"
AssetConfig.treasuremazestyle = "textures/treasuremazestyle.unity3d"

AssetConfig.guildsiege_castle_window = "prefabs/ui/guildsiege/guildsiegecastlewindow.unity3d"
AssetConfig.guildsiege_desc_window = "prefabs/ui/guildsiege/guildsiegedesc.unity3d"
AssetConfig.guildsiege_loop = "prefabs/ui/bigatlas/guildleagueloop.unity3d"
AssetConfig.guildsiege_start = "prefabs/ui/bigatlas/guildleaguestart.unity3d"
AssetConfig.guildsiege_statistics = "prefabs/ui/guildsiege/guildsiegestatistics.unity3d"
AssetConfig.guildsiege_checkplayer = "prefabs/ui/guildsiege/guildsiegecheckplayer.unity3d"
AssetConfig.guildsiege_checkcastle = "prefabs/ui/guildsiege/guildsiegecheckcastle.unity3d"
AssetConfig.guildsiege = "textures/ui/guildsiege.unity3d"
AssetConfig.guildsiege_settle = "prefabs/ui/guildsiege/guildsiegesettle.unity3d"

AssetConfig.groupinfopanel = "prefabs/ui/friend/groupinfopanel.unity3d"
AssetConfig.groupinvitepanel = "prefabs/ui/friend/groupinvitepanel.unity3d"
AssetConfig.groupcreatepanel = "prefabs/ui/friend/groupcreatepanel.unity3d"
AssetConfig.friendtexture = "textures/ui/friend.unity3d"
AssetConfig.petevaluation_main = "prefabs/ui/petevaluation/petevaluationwindow.unity3d"
AssetConfig.petevaluation_texture = "textures/ui/petevalution.unity3d"

AssetConfig.playerkilltexture = "textures/ui/playkill.unity3d"
AssetConfig.playerkillmain = "prefabs/ui/playkill/playkillwindow.unity3d"
AssetConfig.playerkillrank = "prefabs/ui/playkill/playkillrankpanel.unity3d"
AssetConfig.playerkillfight = "prefabs/ui/playkill/playkillfightpanel.unity3d"
AssetConfig.playkillminimize = "prefabs/ui/playkill/playkillminimizepanel.unity3d"
AssetConfig.playkillbestpreview = "prefabs/ui/playkill/playkillbestpreview.unity3d"
AssetConfig.playkillsettlementwindow = "prefabs/ui/playkill/playkillsettlementwindow.unity3d"
AssetConfig.playkillicon = "textures/playerkillicon.unity3d"
AssetConfig.playkillbgcycle = "textures/ui/bigbg/playkillbgcycle.unity3d"
AssetConfig.playkillbgflag = "textures/ui/bigbg/playkillbgflag.unity3d"

AssetConfig.mazeeventpanel = "prefabs/ui/treasuremaze/mazeeventpanel.unity3d"

AssetConfig.valentine_textures = "textures/ui/valentine.unity3d"
AssetConfig.love_connection = "prefabs/ui/valentine/loveconnection.unity3d"
AssetConfig.newlabourtypepanel = "prefabs/ui/valentine/newlabourtypepanel.unity3d"
AssetConfig.love_wish = "prefabs/ui/valentine/lovewishwindow.unity3d"
AssetConfig.love_wish_back = "prefabs/ui/valentine/lovewishbackwindow.unity3d"
AssetConfig.love_possible_reward = "prefabs/ui/valentine/lovewishpossiblereward.unity3d"
AssetConfig.whitevalentine_bg = "prefabs/ui/bigatlas/whitevalentinebg.unity3d"

AssetConfig.signreward_window = "prefabs/ui/signreward/signrewardpanel.unity3d"
AssetConfig.signreward_texture = "textures/ui/signreward.unity3d"

AssetConfig.fashion_new_listing = "prefabs/ui/bible/fashionnewlisting.unity3d"
AssetConfig.leveljumpscorepanel = "prefabs/ui/leveljump/leveljumpscorepanel.unity3d"
AssetConfig.leveljumpwindow = "prefabs/ui/leveljump/leveljumpwindow.unity3d"
AssetConfig.leveljumptexture = "textures/ui/leveljump.unity3d"
AssetConfig.signreward_big_bg = "prefabs/ui/bigatlas/i18nrewardbg.unity3d"
AssetConfig.gm_hotfixwindow = "prefabs/ui/console/hotfixwindow.unity3d";
AssetConfig.signreward_big_bg = "prefabs/ui/bigatlas/image6i18n.unity3d"


AssetConfig.toyreward_window = "prefabs/ui/toyreward/toyrewardpanel.unity3d"
AssetConfig.toyreward_panel = "prefabs/ui/toyreward/toyrewardpanelsingle.unity3d"
AssetConfig.toyreward_textures = "textures/ui/toyreward.unity3d"
AssetConfig.toyreward_get_panel = "prefabs/ui/toyreward/toygetrewardpanel.unity3d"
AssetConfig.toyreward_big_bg = "prefabs/ui/bigatlas/toyrewardbig.unity3d"
AssetConfig.toyreward_big = "textures/ui/bigbg/toyrewardmachine.unity3d"

AssetConfig.petevalution_chashow_panel = "prefabs/ui/petevaluation/petevaluationchatshow.unity3d"

AssetConfig.feedbackbg = "prefabs/ui/bigatlas/celebrationbgi18n.unity3d"
AssetConfig.groupbuybgti18n = "prefabs/ui/bigatlas/nuanchuntoptitlei18n.unity3d"
AssetConfig.groupbuytxtti18n = "prefabs/ui/bigatlas/nuanchuntoptxti18n.unity3d"


AssetConfig.guildauctiontexture = "textures/ui/guildauction.unity3d"
AssetConfig.guildauctionwindow = "prefabs/ui/guildauction/guildauctionwindow.unity3d"
AssetConfig.guildauctionpanel = "prefabs/ui/guildauction/guildauctionpanel.unity3d"

AssetConfig.custom_grid = "prefabs/ui/talisman/customgrid.unity3d"
AssetConfig.talisman_window = "prefabs/ui/talisman/talismanwindow.unity3d"
AssetConfig.talisman_panel = "prefabs/ui/talisman/talismanpanel.unity3d"
AssetConfig.talisman_textures = "textures/ui/talisman.unity3d"
AssetConfig.talisman_tips = "prefabs/ui/tips/talismantips.unity3d"
AssetConfig.talisman_addition = "prefabs/ui/talisman/talismanaddition.unity3d"
AssetConfig.talisman_absorb = "prefabs/ui/talisman/talismanabsorbwindow.unity3d"
AssetConfig.talisman_fusion = "prefabs/ui/talisman/talismanfusionwindow.unity3d"
AssetConfig.talisman_fusion_textures = "textures/talismanfusion.unity3d"
AssetConfig.talisman_after = "prefabs/ui/talisman/talismanafter.unity3d"
AssetConfig.talisman_set = "textures/talismanset.unity3d"
AssetConfig.talisman_synthesis = "prefabs/ui/talisman/talismansynthesis.unity3d"
AssetConfig.talisman_synthesis_bg = "textures/ui/bigbg/talismansynthesisbg.unity3d"
AssetConfig.talisman_select_window = "prefabs/ui/talisman/talismanselectwindow.unity3d"


AssetConfig.guilddungeonwindow = "prefabs/ui/guilddungeon/guilddungeonwindow.unity3d"
AssetConfig.guilddungeonbosswindow = "prefabs/ui/guilddungeon/guilddungeonbosswindow.unity3d"
AssetConfig.guilddungeonsoldierwindow = "prefabs/ui/guilddungeon/guilddungeonsoldierwindow.unity3d"
AssetConfig.guilddungeonherorank = "prefabs/ui/guilddungeon/guilddungeonherorank.unity3d"
AssetConfig.guilddungeonbosstitle = "prefabs/ui/guilddungeon/guilddungeobosstitle.unity3d"
AssetConfig.guilddungeonsettlementwindow = "prefabs/ui/guilddungeon/guilddungeonsettlementwindow.unity3d"
AssetConfig.guilddungeon_textures = "textures/ui/guilddungeon.unity3d"

AssetConfig.marchevent_window = "prefabs/ui/marchevent/marcheventwindow.unity3d"

AssetConfig.marchevent_panel = "prefabs/ui/marchevent/marcheventpanel.unity3d"
AssetConfig.marchevent_texture = "textures/ui/marchevent.unity3d"
AssetConfig.marchevent_bg = "prefabs/ui/bigatlas/grandceremony2i18n.unity3d"

AssetConfig.marchevent_title = "prefabs/ui/bigatlas/grandceremony2texti18n.unity3d"

AssetConfig.rechargepack_panel = "prefabs/ui/rechargepackpanel/rechargepackpanel.unity3d"
AssetConfig.rechargepack_texture = "textures/ui/rechargepack.unity3d"
AssetConfig.rechargepack_big_bg = "prefabs/ui/bigatlas/i18n_rechargepackpanel.unity3d"
AssetConfig.rechargepackbigti18n = "textures/ui/bigbg/rechargepackbigti18n2.unity3d"
AssetConfig.deluxebagti18n = "prefabs/ui/bigatlas/deluxebagti18n.unity3d"
AssetConfig.recharge_bgti18n = "prefabs/ui/bigatlas/recharge_bgti18n.unity3d"
AssetConfig.recharge_bgtextti18n = "prefabs/ui/bigatlas/recharge_bgtextti18n.unity3d"

AssetConfig.sales_promotion_texture = "textures/ui/salespromotion.unity3d"
-- 南瓜
AssetConfig.mainui_trace_halloween = "prefabs/ui/teamquest/halloweencontent.unity3d"
AssetConfig.pumpkin_damaku_window = "prefabs/ui/halloween/pumpkindamakuwindow.unity3d"
AssetConfig.questionnairewindow = "prefabs/ui/questionnaire/questionnairewindow.unity3d"    --有奖调查问卷

AssetConfig.luckey_chest_window = "prefabs/ui/luckeychest/luckeychesetwindow.unity3d"
AssetConfig.luckey_chest_big_bg = "prefabs/ui/bigatlas/luckeychestbg.unity3d"
AssetConfig.luckey_chest_atlas = "textures/ui/luckeychest.unity3d"

AssetConfig.rewardbg = "prefabs/ui/bigatlas/rewardbgi18n.unity3d"

AssetConfig.fish_mainui = "prefabs/ui/fish/fishmainui.unity3d"
AssetConfig.fish_bg1 = "prefabs/ui/bigatlas/fishbg1.unity3d"
AssetConfig.fish_handbook = "prefabs/ui/fish/fishhandbook.unity3d"
AssetConfig.fish_quest = "prefabs/ui/fishquest.unity3d"
AssetConfig.fish_rod = "prefabs/ui/fish/fishrod.unity3d"
AssetConfig.fish_unlock = "prefabs/ui/fish/fishunlock.unity3d"
AssetConfig.fish_vat = "prefabs/ui/fish/fishvat.unity3d"
AssetConfig.fish_window = "prefabs/ui/fish/fish_window.unity3d"

AssetConfig.animal_chess_main = "prefabs/ui/animalchess/animalchessmain.unity3d"
AssetConfig.animal_chess_match = "prefabs/ui/animalchess/animalchessmatch.unity3d"
AssetConfig.animal_chess_iconview = "prefabs/ui/animalchess/animalchessiconview.unity3d"
AssetConfig.animal_chess_bg = "prefabs/ui/bigatlas/animalchessbg.unity3d"
AssetConfig.animal_chess_left = "prefabs/ui/bigatlas/animalchessleft.unity3d"
AssetConfig.animal_chess_right = "prefabs/ui/bigatlas/animalchessright.unity3d"
AssetConfig.vsbg = "prefabs/ui/bigatlas/vsbg.unity3d"
AssetConfig.animal_chess_textures = "textures/ui/animalchess.unity3d"
AssetConfig.animalchesssettle = "prefabs/ui/animalchess/animalchesssettle.unity3d"
AssetConfig.animal_chess_operation = "prefabs/ui/animalchess/animalchessoperation.unity3d"
AssetConfig.mainui_trace_animal = "prefabs/ui/animalchess/animalchesstrace.unity3d"

AssetConfig.seven_login_panel = "prefabs/ui/sevenlogin/sevenlogin.unity3d"
AssetConfig.seven_login_panel_texture = "textures/ui/sevenlogin.unity3d"
AssetConfig.seven_login_reward = "prefabs/ui/sevenlogreward/sevenlogreward.unity3d"
AssetConfig.dragonboatlogin_big_bg = "prefabs/ui/bigatlas/dragonboatlogini18n.unity3d"
AssetConfig.seven_login_big_bg = "prefabs/ui/bigatlas/sevenlogini18n.unity3d"
AssetConfig.seven_login_tips = "prefabs/ui/sevenloginrewardtips/sevenloginrewardtips.unity3d"

AssetConfig.love_wish_tips = "prefabs/ui/valentine/lovewishtips.unity3d"
AssetConfig.iconbigbg = "prefabs/ui/bigatlas/marcheventbg.unity3d"
AssetConfig.wishlove_title = "textures/ui/bigbg/wishlovetitlei18n.unity3d"

AssetConfig.bible_rechargepanel = "prefabs/ui/rechargedevelop/rechargedeveloppanel.unity3d"
AssetConfig.bible_rechargepanel_textures = "textures/ui/rechargedevelop.unity3d"

AssetConfig.wings_window = "prefabs/ui/wings/wingswindow.unity3d"
AssetConfig.wing_panel_bg = "prefabs/ui/bigatlas/wingbg.unity3d"

AssetConfig.inti_macy_rank = "prefabs/ui/may/intimacyrank.unity3d"

AssetConfig.firstrechargedevelopwindow = "prefabs/ui/firstrecharge/firstrechargedevelopwindow.unity3d"
AssetConfig.firstrechargedeveloptexture = "textures/ui/firstrechargedevelop.unity3d"
AssetConfig.firstrechargedevelopbig = "prefabs/ui/bigatlas/firstrechargebigbg.unity3d"

AssetConfig.dragonboatrankscorewin = "prefabs/ui/dragonboat/dragonboatrankscorewin.unity3d"
AssetConfig.dragonboatstartwin = "prefabs/ui/dragonboat/dragonboatstartwin.unity3d"
AssetConfig.dragonboaticon = "prefabs/ui/dragonboat/dragonboaticon.unity3d"
AssetConfig.dragonboatpanel = "prefabs/ui/dragonboat/dragonboatpanel.unity3d"
AssetConfig.i18ndragonboat = "prefabs/ui/bigatlas/i18ndragonboat.unity3d"

AssetConfig.firstrechargetextBigbg1 = "prefabs/ui/bigatlas/rechargetexti18n1.unity3d"
AssetConfig.firstrechargetextBigbg2 = "prefabs/ui/bigatlas/rechargetexti18n2.unity3d"
AssetConfig.firstrechargetextBigbg3 = "prefabs/ui/bigatlas/rechargetexti18n4.unity3d"
AssetConfig.firstrechargetextBigbg4 = "prefabs/ui/bigatlas/rechargetexti18n5.unity3d"
AssetConfig.firstrechargetextBigbg5 = "prefabs/ui/bigatlas/rechargetexti18n3.unity3d"

AssetConfig.rice_dumpling = "prefabs/ui/dragonboat/ricedumpling.unity3d"
AssetConfig.rice_dumpling_bg = "prefabs/ui/bigatlas/dragonboatbg1.unity3d"


AssetConfig.specialitem_window = "prefabs/ui/specialitemget/specialitemgetwindow.unity3d"
AssetConfig.specialitem_texture = "textures/ui/specialitem.unity3d"

AssetConfig.specialitem_bigbg = "textures/ui/bigbg/i18nspecialbigbg.unity3d"
AssetConfig.grild_bigbg = "textures/ui/bigbg/grild.unity3d"
AssetConfig.specialitem_text_bigbg ="prefabs/ui/bigatlas/i18nspecialitemtextbg.unity3d"
AssetConfig.specialitem_icon_bigbg ="prefabs/ui/bigatlas/specialitemiconbg.unity3d"

AssetConfig.rebatereward_window = "prefabs/ui/rebatereward/rebaterewardwindow.unity3d"
AssetConfig.rebatereward_main_window = "prefabs/ui/rebatereward/rebaterewardmainwindow.unity3d"
AssetConfig.rebatereward_texture = "textures/ui/rebatereward.unity3d"
AssetConfig.rebatereward_bigbg = "prefabs/ui/bigatlas/rebaterewardbigbg.unity3d"


AssetConfig.model_show_window = "prefabs/ui/wings/modelshowwindow.unity3d"
AssetConfig.wing_illusion_success = "prefabs/ui/wings/wingillusionsuccss.unity3d"

AssetConfig.RebateRewardBgText1 = "textures/ui/bigbg/rebaterewardbg.unity3d"
AssetConfig.RebateRewardBgText2 = "textures/ui/bigbg/rebatetitle.unity3d"
AssetConfig.RebateRewardBgText3 = "textures/ui/bigbg/witch.unity3d"
AssetConfig.RebateRewardBgText4 = "textures/ui/bigbg/rebatetitle2.unity3d"
AssetConfig.RebateRewardBgText5 = "textures/ui/bigbg/rebatetitle3.unity3d"
AssetConfig.RebateRewardBgText6 = "textures/ui/bigbg/rebatetitle4.unity3d"
AssetConfig.RebateRewardBgText7 = "textures/ui/bigbg/rebatetitle5.unity3d"
AssetConfig.FriendBg = "textures/ui/bigbg/friendbg3.unity3d"
AssetConfig.RewardBg2 = "textures/ui/bigbg/rewardbg.unity3d"

AssetConfig.quest_king_progress = "prefabs/ui/questking/questkingprogress.unity3d"
AssetConfig.quest_king_textures = "textures/ui/questking.unity3d"
AssetConfig.quest_king_scroll_marked = "prefabs/ui/questking/questkingscrollmarked.unity3d"
AssetConfig.quest_king_bg = "prefabs/ui/bigatlas/questkingbg.unity3d"
AssetConfig.AutumnHelpBg = "textures/ui/bigbg/autumnhelpbg.unity3d"

AssetConfig.GameBgOne = "prefabs/ui/bigatlas/ti18ngamebgone.unity3d"
AssetConfig.GameBgTwo = "prefabs/ui/bigatlas/ti18ngamebgtwo.unity3d"
AssetConfig.GameBgPanel = "prefabs/ui/settingwindow/gamebgpanel.unity3d"

AssetConfig.campbox_main_window = "prefabs/ui/campbox/campboxmainwindow.unity3d"
AssetConfig.campbox_tab_window = "prefabs/ui/campbox/campboxtabwindow.unity3d"
AssetConfig.campbox_window = "prefabs/ui/campbox/campboxpanel.unity3d"

AssetConfig.campbox_texture = "textures/ui/campbox.unity3d"
AssetConfig.cambox_big_bg = "prefabs/ui/bigatlas/campboxbg.unity3d"

-- 元宝争霸
AssetConfig.ingotcrash_content = "prefabs/ui/ingotcrash/ingotcrashcontent.unity3d"
AssetConfig.ingotcrash_window = "prefabs/ui/ingotcrash/ingotcrashwindow.unity3d"
AssetConfig.ingotcrash_rank = "prefabs/ui/ingotcrash/ingotcrashrank.unity3d"
AssetConfig.ingotcrash_vote = "prefabs/ui/ingotcrash/ingotcrashvote.unity3d"
AssetConfig.ingotcrash_textures = "textures/ui/ingotcrash.unity3d"
AssetConfig.ingotcrash_mainui = "prefabs/ui/ingotcrash/ingotcrashtop.unity3d"
AssetConfig.ingotcrash_use = "prefabs/ui/ingotcrash/ingotcrashuse.unity3d"
AssetConfig.ingotcrash_show = "prefabs/ui/ingotcrash/ingotcrashshow.unity3d"
AssetConfig.ingotcrash_watch = "prefabs/ui/ingotcrash/ingotcrashwatch.unity3d"
AssetConfig.ingotcrash_reward = "prefabs/ui/ingotcrash/ingotcrashreward.unity3d"
AssetConfig.ingotcrash_show = "prefabs/ui/ingotcrash/ingotcrashshow.unity3d"
AssetConfig.ingotcrash_damaku = "prefabs/ui/ingotcrash/ingotcrashdamaku.unity3d"
-- 星座驾照界面UI
AssetConfig.constellationprofilewindow = "prefabs/ui/constellation/constellationprofilewindow.unity3d"
AssetConfig.constellationhonorwindow = "prefabs/ui/constellation/constellationhonorwindow.unity3d"
AssetConfig.res_constellation = "textures/ui/constellation.unity3d"

AssetConfig.summer_quest = "prefabs/ui/summer/summerquest.unity3d"
AssetConfig.summer_quest_big_bg = "prefabs/ui/bigatlas/summerquestbgi18n.unity3d"
AssetConfig.summer_quest_big_bg2 = "prefabs/ui/bigatlas/summerbg3.unity3d"
AssetConfig.summer_camp_box_big_bg = "prefabs/ui/bigatlas/summercampboxbigbgi18n.unity3d"
--AssetConfig.summer_recharge_big_bg = "prefabs/ui/bigatlas/summerrechargebigbgi18n.unity3d"
AssetConfig.summer_gift_main_window = "prefabs/ui/onesevenmainwin/summergiftmainwindow.unity3d"
AssetConfig.newyearrebate_big_bg3 = "prefabs/ui/bigatlas/newyearrebateimage3.unity3d"
AssetConfig.newyearrebate_big_bg2 = "prefabs/ui/bigatlas/newyearrebateimage2.unity3d"
AssetConfig.newyearrebate_txt1 = "prefabs/ui/bigatlas/rebatetxti18n1.unity3d"
AssetConfig.newyearrebate_txt2 = "prefabs/ui/bigatlas/rebatetxti18n3.unity3d"

-- 选择礼包界面
AssetConfig.backpackselectgiftpanel = "prefabs/ui/backpack/backpackselectgiftpanel.unity3d"
--时装礼包选择界面
AssetConfig.backpackselectsuitpanel = "prefabs/ui/backpack/backpackselectsuit.unity3d"
AssetConfig.suitselectgift_texture = "textures/ui/suitselectgift.unity3d"
AssetConfig.suitselectbigbg = "prefabs/ui/bigatlas/suitselectbigbg2.unity3d"
AssetConfig.suitselecttitle = "prefabs/ui/bigatlas/suitselecttitlei18n.unity3d"
AssetConfig.suitselecttitle2 = "prefabs/ui/bigatlas/suitselecttitlei18n2.unity3d"

AssetConfig.suitselecttoptitle = "prefabs/ui/bigatlas/suitselecttoptitlei18n.unity3d"
AssetConfig.suitselecttoptitle2 = "prefabs/ui/bigatlas/suitselecttoptitlei18n2.unity3d"

AssetConfig.dragonpixtitle = "prefabs/ui/bigatlas/dragonpixtitle.unity3d"

AssetConfig.summergift_main_window_textures = "textures/ui/summergift.unity3d"

AssetConfig.rule_tips = "prefabs/ui/ingotcrash/ruletips.unity3d"

AssetConfig.sevenday_other = "prefabs/ui/sevenday/sevendayother.unity3d"

AssetConfig.sevenday_other_bg = "prefabs/ui/bigatlas/sevendayotherbigbg.unity3d"
AssetConfig.starchallengewindow = "prefabs/ui/starchallenge/starchallengewindow.unity3d"
AssetConfig.starchallengevideowindow = "prefabs/ui/starchallenge/starchallengevideowindow.unity3d"
AssetConfig.starchallengerewardwindow = "prefabs/ui/starchallenge/starchallengerewardwindow.unity3d"
AssetConfig.starchallengeicon = "prefabs/ui/starchallenge/starchallengeicon.unity3d"
AssetConfig.starchallengesettlementwindow = "prefabs/ui/starchallenge/starchallengesettlementwindow.unity3d"
AssetConfig.starchallengefightrewardpanel = "prefabs/ui/starchallenge/starchallengefightrewardpanel.unity3d"
AssetConfig.starchallengeteampanel = "prefabs/ui/starchallenge/starchallengeteampanel.unity3d"
AssetConfig.starchallengetowerendwin = "prefabs/ui/starchallenge/starchallengetowerendwin.unity3d"

AssetConfig.starchallenge_textures = "textures/ui/starchallenge.unity3d"

AssetConfig.ApocalypseLordicon = "prefabs/ui/apocalypselord/apocalypselordicon.unity3d"
AssetConfig.ApocalypseLordsettlementwindow = "prefabs/ui/apocalypselord/apocalypselordsettlementwindow.unity3d"
AssetConfig.ApocalypseLord_content = "prefabs/ui/apocalypselord/apocalypselordcontent.unity3d"


AssetConfig.bigsummer_main_window = "prefabs/ui/bigsummer/bigsummermainwindow.unity3d"
AssetConfig.bigsummer_pub_panel = "prefabs/ui/bigsummer/bigsummerpanel.unity3d"
AssetConfig.bigsummer_pub_bigbg = "prefabs/ui/bigatlas/bigsummerb.unity3d"

AssetConfig.glory_friend_rank = "prefabs/ui/glory/gloryfriendrank.unity3d"
AssetConfig.glory_reward_window = "prefabs/ui/glory/gloryrewardwindow.unity3d"
AssetConfig.campaign_icon = "textures/ui/campaignicon.unity3d"


AssetConfig.guild_build_restriction_select_win = "prefabs/ui/guild/guildbuildrestrictionselectwindow.unity3d" -- 公会建筑升级额度选择界面


AssetConfig.rechargepointpanel = "prefabs/ui/beginautumn/rechargepointspanel.unity3d"
AssetConfig.discountshop_window = "prefabs/ui/beginautumn/discountshopwindow.unity3d"
AssetConfig.discountshopwindow2 = "prefabs/ui/beginautumn/discountshopwindow2.unity3d"
AssetConfig.beginautum = "textures/ui/beginautum.unity3d"
AssetConfig.beginautumn_bigbg = "prefabs/ui/bigatlas/beginautumni18n.unity3d"

AssetConfig.shop_roleshow_panel = "prefabs/ui/shop/shoproleshowpanel.unity3d"

AssetConfig.fashionBg = "textures/ui/bigbg/i18nfashion.unity3d"
AssetConfig.newFashionBg = "textures/ui/bigbg/i18nnewfashion.unity3d"

AssetConfig.mesh_fashion = "prefabs/ui/campaign/meshfashion.unity3d"
AssetConfig.mesh_fashion_special = "prefabs/ui/specialitem/meshfashionbuy.unity3d"
AssetConfig.mesh_fashion_bigbg = "prefabs/ui/bigatlas/meshfashionbigbgi18n.unity3d"
AssetConfig.mesh_fashion_buybg = "prefabs/ui/bigatlas/meshfashionbuybgi18n.unity3d"
AssetConfig.mesh_fashion_show_bg = "prefabs/ui/bigatlas/meshfashionshowbgi18n.unity3d"

AssetConfig.buy_confirm = "prefabs/ui/buybutton/buyconfirm.unity3d"
AssetConfig.buy_textures = "textures/ui/buybutton.unity3d"

AssetConfig.love_check = "prefabs/ui/magpiefestival/lovecheckwindow.unity3d"
AssetConfig.love_match_window = "prefabs/ui/magpiefestival/loveevaluationwindow.unity3d"
AssetConfig.love_active_panel = "prefabs/ui/magpiefestival/loveactivepanel.unity3d"
AssetConfig.love_texture = "textures/ui/magpiefestivalmatch.unity3d"
AssetConfig.love_check_bg = "textures/ui/bigbg/qixilovei18n.unity3d"
AssetConfig.love_active_bg = "prefabs/ui/bigatlas/i18nqixi.unity3d"

AssetConfig.picture_desc = "prefabs/ui/campaign/picturedesc.unity3d"
AssetConfig.picture_desc1 = "prefabs/ui/bigatlas/picturedesci18n1.unity3d"

AssetConfig.chaintreasurewindow = "prefabs/ui/chain/chaintreasurewindow.unity3d"
AssetConfig.chain_textures = "textures/ui/chain.unity3d"

AssetConfig.face_window = "prefabs/ui/face/facemergewindow.unity3d"
AssetConfig.face_textures = "textures/ui/face.unity3d"
AssetConfig.new_face_bg = "prefabs/ui/bigatlas/newfacebg.unity3d"
AssetConfig.face_call_bg = "prefabs/ui/bigatlas/facecallbg.unity3d"
AssetConfig.face_get_effect = "prefabs/ui/face/getfaceeffectpanel.unity3d"

AssetConfig.bigface1 = "textures/bigface/face1.unity3d"

AssetConfig.single_select = "prefabs/ui/face/single_select_panel.unity3d"

-- 玲珑宝阁
AssetConfig.exquisite_shelf_content = "prefabs/ui/exquisiteshelf/exquisiteshelfcontent.unity3d"
AssetConfig.exquisite_shelf_window = "prefabs/ui/exquisiteshelf/exquisiteshelfwindow.unity3d"
AssetConfig.exquisite_shelf_reward = "prefabs/ui/exquisiteshelf/exquisiteshelfreward.unity3d"
AssetConfig.exquisite_shelf_mainui = "prefabs/ui/exquisiteshelf/exquisiteshelfmainui.unity3d"
AssetConfig.exquisite_shelf_textures = "textures/ui/exquisiteshelf.unity3d"
AssetConfig.exquisite_bg1 = "prefabs/ui/bigatlas/exquisitebg1.unity3d"
AssetConfig.exquisite_bg2 = "prefabs/ui/bigatlas/exquisitebg2.unity3d"
AssetConfig.exquisite_bg3 = "prefabs/ui/bigatlas/exquisitebg3.unity3d"
AssetConfig.exquisite_select = "prefabs/ui/bigatlas/exquisiteselect.unity3d"

AssetConfig.single_select = "prefabs/ui/face/singleselectpanel.unity3d"

AssetConfig.turntable_recharge_panel = "prefabs/ui/rewardturntable/rechargeturntable.unity3d"
AssetConfig.turntablerecharge_textures = "textures/ui/rechargeturntabel.unity3d"
AssetConfig.turntable_recharge_bg = "prefabs/ui/bigatlas/i18nrechargeturn.unity3d"
AssetConfig.exquisiteshelfshowwindow = "prefabs/ui/exquisiteshelf/exquisiteshelfshowwindow.unity3d"
AssetConfig.exquisiteshelfshowbg = "prefabs/ui/bigatlas/linglong.unity3d"
AssetConfig.nationalsecond_reward_panel = "prefabs/ui/nationalsecondday/nationalsecondflowerrewardpanel.unity3d"

AssetConfig.nationalsecond_accept_panel = "prefabs/ui/nationalsecondday/nationalsecondflowerpanel.unity3d"
AssetConfig.nationalsecond_accept_bg = "prefabs/ui/bigatlas/i18nnationalsecondbg.unity3d"
AssetConfig.nationalsecond_accept_texture = "textures/ui/nationalsecondday.unity3d"
AssetConfig.nationalsecond_show_panel = "prefabs/ui/nationalsecondday/nationalsecondflowershowpanel.unity3d"
AssetConfig.nationalsecond_tips_panel = "prefabs/ui/nationalsecondday/nationalsecondflowertipspanel.unity3d"

AssetConfig.campaign_autumn_panel = "prefabs/ui/campaignautumn/campaignautumnpanel.unity3d"
AssetConfig.campaign_autumn_texture = "textures/ui/campaignautumn.unity3d"

AssetConfig.campaign_autumn_help_window = "prefabs/ui/campaignautumn/campaignautumnhelpwindow.unity3d"
AssetConfig.campaign_autumn_friend_window = "prefabs/ui/campaignautumn/campaignautumnfriendwindow.unity3d"

AssetConfig.big_reward = "textures/ui/bigbg/bigrewardbox.unity3d"
AssetConfig.big_reward_flash = "textures/ui/bigbg/bigrewardflash.unity3d"
AssetConfig.big_reward_bg = "textures/ui/bigbg/bigrewardbg.unity3d"

AssetConfig.campaignautumn_bigbg = "prefabs/ui/bigatlas/campaignautumnbg.unity3d"

AssetConfig.reportzonewindow = "prefabs/ui/report/reportzonewindow.unity3d"

AssetConfig.opengiftshowwindow = "prefabs/ui/giftshow/opengiftshowwindow.unity3d"
AssetConfig.christmasshopwindow = "prefabs/ui/christmas/christmasshopwindow.unity3d"
AssetConfig.campaign_title_res = "textures/ui/campaigntitle.unity3d"

AssetConfig.halloween_i18n_bg2 = "prefabs/ui/bigatlas/halloweeni18nbg2.unity3d"
AssetConfig.halloween_i18n_bg3 = "prefabs/ui/bigatlas/halloweeni18nbg3.unity3d"
AssetConfig.halloween_i18n_bg4 = "prefabs/ui/bigatlas/labatopbg.unity3d"
AssetConfig.halloween_top_bg = "prefabs/ui/bigatlas/halloweentopbg.unity3d"

AssetConfig.LabaTerrorBg = "prefabs/ui/bigatlas/labazs.unity3d"
AssetConfig.Laba_top_Txt1 = "textures/ui/bigbg/lababgtxt1i18n.unity3d"
AssetConfig.Laba_top_Txt2 = "textures/ui/bigbg/lababgtxt2i18n.unity3d"


AssetConfig.christmas_top_bg = "prefabs/ui/bigatlas/titletop.unity3d"
AssetConfig.Newyeardiscount_top_bg = "prefabs/ui/bigatlas/newyeardiscounttopbg.unity3d"
AssetConfig.christmas_ghost = "prefabs/ui/bigatlas/chrismasman.unity3d"
AssetConfig.christmas_tree = "prefabs/ui/bigatlas/christmastree.unity3d"

AssetConfig.campaign_desc = "prefabs/ui/beginautumn/camapaigndesc.unity3d"
AssetConfig.halloween_icon = "textures/ui/halloweenicon.unity3d"
AssetConfig.christmas_icon = "textures/ui/christmasicon.unity3d"

AssetConfig.book_bg = "prefabs/ui/bigatlas/bookbg.unity3d"

AssetConfig.ride_choose_window = "prefabs/ui/ride/ridechoosewindow.unity3d"
AssetConfig.ride_choos_end_window = "prefabs/ui/ride/ridechooseendwindow.unity3d"
AssetConfig.ride_choose_textures = "textures/ui/ridechosses.unity3d"

AssetConfig.ride_choose_bigbg1 = "textures/ui/bigbg/biglight.unity3d"
AssetConfig.ride_choose_bigbg2 = "textures/ui/bigbg/rideground.unity3d"
AssetConfig.ride_choose_bigText = "textures/ui/bigbg/ti18nchooseride.unity3d"

AssetConfig.ride_choose_end_bigText = "textures/ui/bigbg/ti18nrideendtitle.unity3d"

AssetConfig.ride_choose_end_bigRabbit = "textures/ui/bigbg/rabbit.unity3d"
AssetConfig.ride_choose_end_bigbg = "textures/ui/bigbg/bigbg.unity3d"


AssetConfig.turnpalte_bg1 = "prefabs/ui/bigatlas/turnpalte.unity3d"



AssetConfig.singledog = "prefabs/ui/doubleeleven/singledogpanel.unity3d"


AssetConfig.wings_turnplant = "prefabs/ui/wings/wingsturnwindow.unity3d"
AssetConfig.turnpalte_bg2 = "prefabs/ui/bigatlas/rotorywing.unity3d"

AssetConfig.trial_content = "prefabs/ui/trial/trialcontent.unity3d"

AssetConfig.guilddragon_main = "prefabs/ui/guilddragon/guilddragonmain.unity3d"
AssetConfig.guilddragon_rod = "prefabs/ui/guilddragon/guilddragonrod.unity3d"
AssetConfig.guilddragon_rank = "prefabs/ui/guilddragon/guilddragonrank.unity3d"
AssetConfig.guilddragon_settle = "prefabs/ui/guilddragon/guilddragonsettle.unity3d"
AssetConfig.guilddragon_spoils = "prefabs/ui/guilddragon/guilddragonspoils.unity3d"
AssetConfig.guilddragon_endrod = "prefabs/ui/guilddragon/guilddragonendrod.unity3d"
AssetConfig.guilddragon_closedamaku = "prefabs/ui/guilddragon/guilddragonclosedamaku.unity3d"
AssetConfig.guilddragon_endfight = "prefabs/ui/guilddragon/guilddragonendfight.unity3d"
AssetConfig.guilddragon_textures = "textures/ui/guilddragon.unity3d"

AssetConfig.textures_magicegg = "textures/ui/magicegg.unity3d"
AssetConfig.magicegg = "prefabs/ui/campaign/magiceggpanel.unity3d"
AssetConfig.luckydog = "prefabs/ui/campaign/luckydogwindow.unity3d"
AssetConfig.magiceggbg = "prefabs/ui/bigatlas/godeggbg.unity3d"
AssetConfig.magiceggbg2 = "prefabs/ui/bigatlas/godeggbg2.unity3d"
AssetConfig.magiceggdesc = "prefabs/ui/bigatlas/ti18ngodeggdesc.unity3d"
AssetConfig.challenge_title = "prefabs/ui/bigatlas/challengetitlei18n.unity3d"

AssetConfig.starchallenge_content = "prefabs/ui/starchallenge/starchallengecontent.unity3d"
AssetConfig.guilddragon_content = "prefabs/ui/guilddragon/guilddragoncontent.unity3d"

AssetConfig.campaign_inquiry_select = "prefabs/ui/campaigninquiry/campaigninquiryselect.unity3d"
AssetConfig.campaign_inquiry_window = "prefabs/ui/campaigninquiry/campaigninquirywindow.unity3d"
AssetConfig.campaign_inquiry = "textures/ui/campaigninquiry.unity3d"

AssetConfig.newexam_content = "prefabs/ui/exam/newexamcontent.unity3d"
AssetConfig.dragonboat_content = "prefabs/ui/dragonboat/dragonboatcontent.unity3d"
AssetConfig.guilddungeon_content = "prefabs/ui/guilddungeon/guilddungeoncontent.unity3d"
AssetConfig.nationalday_content = "prefabs/ui/nationalday/nationaldaycontent.unity3d"
AssetConfig.lanternfair_content = "prefabs/ui/midautumn/lanternfaircontent.unity3d"
AssetConfig.enjoymoon_content = "prefabs/ui/midautumn/enjoymooncontent.unity3d"
AssetConfig.masquerade_content = "prefabs/ui/masquerade/masqueratecontent.unity3d"
AssetConfig.hero_content = "prefabs/ui/hero/herocontent.unity3d"
AssetConfig.guildelitefight_content = "prefabs/ui/guildfightelite/guildelitefightcontent.unity3d"
AssetConfig.marry_content = "prefabs/ui/marry/marrycontent.unity3d"
AssetConfig.guildfight_content = "prefabs/ui/guildfight/guildfightcontent.unity3d"
AssetConfig.warrior_content = "prefabs/ui/warrior/warriorcontent.unity3d"
AssetConfig.topcomplete_content = "prefabs/ui/topcompete/topcompetecontent.unity3d"
AssetConfig.fairyland_content = "prefabs/ui/fairyland/fairylandcontent.unity3d"
AssetConfig.examqueston_content = "prefabs/ui/exam/examquestoncontent.unity3d"
AssetConfig.parade_content = "prefabs/ui/parade/paradecontent.unity3d"
AssetConfig.qualify_content = "prefabs/ui/qualify/qualifycontent.unity3d"
AssetConfig.dungeon_content = "prefabs/ui/dungeon/dungeoncontent.unity3d"
AssetConfig.team_content = "prefabs/ui/team/teamcontent.unity3d"
AssetConfig.task_content = "prefabs/ui/teamquest/taskcontent.unity3d"

AssetConfig.guilddragon_mainui = "prefabs/ui/guilddragon/guilddragonmainui.unity3d"

AssetConfig.getpet_textures = "textures/ui/getpet.unity3d"

AssetConfig.rightbg_bigbg = "textures/ui/bigbg/rightbg%s.unity3d"
-- AssetConfig.rightbg2023_bigbg = "textures/ui/bigbg/rightbg2023.unity3d"
-- AssetConfig.rightbg2031_bigbg = "textures/ui/bigbg/rightbg2031.unity3d"
-- AssetConfig.rightbg2038_bigbg = "textures/ui/bigbg/rightbg2038.unity3d"
-- AssetConfig.rightbg2045_bigbg = "textures/ui/bigbg/rightbg2045.unity3d"
-- AssetConfig.rightbg2051_bigbg = "textures/ui/bigbg/rightbg2051.unity3d"
-- AssetConfig.rightbg2057_bigbg = "textures/ui/bigbg/rightbg2057.unity3d"
-- AssetConfig.rightbg2063_bigbg = "textures/ui/bigbg/rightbg2063.unity3d"
-- AssetConfig.rightbg2070_bigbg = "textures/ui/bigbg/rightbg2070.unity3d"

-- AssetConfig.skillIcon_pet = "textures/skilliconbig/petskill.unity3d"
-- AssetConfig.skillIcon_pet2 = "textures/skilliconbig/petskill2.unity3d"
-- AssetConfig.skillIcon_guard = "textures/skilliconbig/guardskill.unity3d"
-- AssetConfig.skillIcon_roleother = "textures/skilliconbig/roleskill/other.unity3d"
-- AssetConfig.skillIcon_ride = "textures/skilliconbig/ride.unity3d"
-- AssetConfig.skillIcon_endless = "textures/skilliconbig/endlessskill.unity3d"
-- AssetConfig.wing_skill = "textures/skilliconbig/wingskill.unity3d"
-- AssetConfig.talisman_skill = "textures/skilliconbig/talisman.unity3d"

AssetConfig.single_skillIcon = "textures/singleskilliconbig/%s.unity3d"

AssetConfig.getpetbtn = "textures/ui/bigbg/getpetbtn.unity3d" --创建角色大背景图
AssetConfig.getpethalo1 = "textures/ui/bigbg/getpethalo1.unity3d"
AssetConfig.getpetlight1 = "textures/ui/bigbg/getpetlight1.unity3d"

AssetConfig.geti18nevolvetitle = "textures/ui/bigbg/geti18nevolvetitle.unity3d"
AssetConfig.geti18ngetpetskintitle = "textures/ui/bigbg/geti18ngetpetskintitle.unity3d"
AssetConfig.geti18ngetpettitle = "textures/ui/bigbg/geti18ngetpettitle.unity3d"

AssetConfig.geti18ngetwingtitle = "textures/ui/bigbg/geti18ngetwingtitle.unity3d"
AssetConfig.geti18npandatitle = "textures/ui/bigbg/geti18npandatitle.unity3d"

AssetConfig.worldlevgiftitem1 = "textures/ui/bigbg/worldlevitemlight1.unity3d"
AssetConfig.worldlevgiftitem2 = "textures/ui/bigbg/worldlevitemlight2.unity3d"
AssetConfig.worldlevgiftitem3 = "textures/ui/bigbg/worldlevitemlight3.unity3d"
AssetConfig.worldlevitembg1 = "textures/ui/bigbg/worldlevitembg1.unity3d"
AssetConfig.worldlevitembg2 = "textures/ui/bigbg/worldlevitembg2.unity3d"
AssetConfig.worldlevitembg3 = "textures/ui/bigbg/worldlevitembg3.unity3d"

AssetConfig.real_name = "prefabs/ui/realname/realnamepanel.unity3d"
AssetConfig.fashion_selection_window = "prefabs/ui/fashionselectionwin/fashionselectionwin.unity3d"
AssetConfig.fashion_selection_show_window = "prefabs/ui/fashionselectionwin/fashionselectionshowwin.unity3d"
AssetConfig.fashion_selection_lucky_window = "prefabs/ui/fashionselectionwin/fashionluckywin.unity3d"

AssetConfig.fashion_discount_window = "prefabs/ui/fashionselectionwin/fashiondiscountwin.unity3d"
AssetConfig.fashion_discount_detail_window = "prefabs/ui/fashionselectionwin/fashiondiscountdetailwin.unity3d"
AssetConfig.fashion_discount_detail_bg = "prefabs/ui/bigatlas/fashiondetailbg2.unity3d"
AssetConfig.fashion_discount_detail_title = "prefabs/ui/bigatlas/fashiondiscountdetailtitle.unity3d"
AssetConfig.fashion_discount_title2 = "prefabs/ui/bigatlas/fashiondiscounttitle.unity3d"
AssetConfig.fashion_discount_bigbg = "prefabs/ui/bigatlas/fashiondiscountbg.unity3d"
AssetConfig.fashion_discount_texture = "textures/ui/fashiondiscount.unity3d"


AssetConfig.fashion_help_window = "prefabs/ui/fashionselectionwin/fashionhelpwin.unity3d"
AssetConfig.fashion_selection_big_bg = "prefabs/ui/bigatlas/i18nfashionseleciton.unity3d"
AssetConfig.fashion_selection_show_big_bg = "prefabs/ui/bigatlas/i18nfashonselectionshow.unity3d"

AssetConfig.fashion_selection_show_big1 = "textures/ui/bigbg/fashionselectiontop.unity3d"
AssetConfig.fashion_selection_show_big2 = "textures/ui/bigbg/fashionselectionbottom.unity3d"

AssetConfig.fashion_selection_help_big1 = "textures/ui/bigbg/fashionlookbg1.unity3d"
AssetConfig.fashion_selection_help_big2 = "textures/ui/bigbg/fashionlookbg2.unity3d"
AssetConfig.fashion_selection_help_big3 = "textures/ui/bigbg/fashionlookbg3.unity3d"
AssetConfig.fashion_selection_help_big4 = "textures/ui/bigbg/fashionlookbg4.unity3d"

AssetConfig.fashion_selection_lucky_bottom1 = "textures/ui/bigbg/bottom11.unity3d"
AssetConfig.fashion_selection_lucky_bottom2 = "textures/ui/bigbg/bottom12.unity3d"
AssetConfig.fashion_selection_lucky_top = "prefabs/ui/bigatlas/fashionluckytitle.unity3d"
AssetConfig.fashion_selection_lucky_big2 = "textures/ui/bigbg/fashionluckybg2.unity3d"
AssetConfig.fashion_selection_texture = "textures/ui/fashionselection.unity3d"

AssetConfig.childspiritwindow = "prefabs/ui/pet/childspiritwindow.unity3d"
AssetConfig.godswarjifenpanel = "prefabs/ui/godswar/godswarjifenpanel.unity3d"
AssetConfig.godswarjifenrankgepanel = "prefabs/ui/godswar/godswarjifenrankpanel.unity3d"
AssetConfig.godswarsshowpanel = "prefabs/ui/godswar/godswarsharewindow.unity3d"
AssetConfig.godswartexture = "textures/ui/godswarjifen.unity3d"
AssetConfig.godswarjifenbadgepanel = "prefabs/ui/godswar/godswarjifenbadgepanel.unity3d"
AssetConfig.godswartoppanel = "prefabs/ui/godswar/godswartoppanel.unity3d"
AssetConfig.godswarjifenbg = "prefabs/ui/bigatlas/godswarjifenbg.unity3d"

AssetConfig.godswarjifenlight = "textures/ui/bigbg/godswarlightbg.unity3d"
AssetConfig.godswarjifenCircleBg = "textures/ui/bigbg/godswarcirclebg.unity3d"

AssetConfig.godswarjifenBadge1000 = "textures/ui/bigbg/godswarbadge1000.unity3d"
AssetConfig.godswarjifenBadge1001 = "textures/ui/bigbg/godswarbadge1001.unity3d"
AssetConfig.godswarjifenBadge1002= "textures/ui/bigbg/godswarbadge1002.unity3d"
AssetConfig.godswarjifenBadge1003= "textures/ui/bigbg/godswarbadge1003.unity3d"
AssetConfig.godswarjifenBadge1004= "textures/ui/bigbg/godswarbadge1004.unity3d"
AssetConfig.godswarjifenBadge1005= "textures/ui/bigbg/godswarbadge1005.unity3d"
AssetConfig.godswarjifenBadge1006= "textures/ui/bigbg/godswarbadge1006.unity3d"
AssetConfig.chancetips_window = "prefabs/ui/tips/chancetipswindow.unity3d"
AssetConfig.chance_tips = "prefabs/ui/tips/chancetips.unity3d"

AssetConfig.godswarworshippanel = "prefabs/ui/godswar/godswarworshipwin.unity3d"
AssetConfig.godswarworshiptexture = "textures/ui/godswarworship.unity3d"
AssetConfig.godswarworshipcontent = "prefabs/ui/godswar/godswarworshipcontent.unity3d"
AssetConfig.godswarworshipicon = "prefabs/ui/godswar/godswarworshipicon.unity3d"
AssetConfig.godswarworshipBg = "textures/ui/bigbg/worshipbigbg.unity3d"

AssetConfig.rushtop_texture = "textures/ui/rushtop.unity3d"
AssetConfig.rushtopmain = "prefabs/ui/rushtop/rushtopmain.unity3d"
AssetConfig.rushtopsignup = "prefabs/ui/rushtop/rushtopsignup.unity3d"
AssetConfig.rushtopcontent = "prefabs/ui/rushtop/rushtopcontent.unity3d"
AssetConfig.rushtopclosedamaku = "prefabs/ui/rushtop/rushtopclosedamaku.unity3d"
AssetConfig.rushtoppanel = "prefabs/ui/rushtop/rushtoppanel.unity3d"
AssetConfig.rushtopdescpanel = "prefabs/ui/rushtop/rushtopdescpanel.unity3d"


AssetConfig.exercise_quickbuy_window = "prefabs/ui/exercise/exercisequickbuywindow.unity3d"

AssetConfig.pack = "textures/ui/bigbg/pack%s.unity3d"   --礼包特惠大图


AssetConfig.playkillbg_yellow = "textures/ui/bigbg/playkillbg_yellow.unity3d"

AssetConfig.LunarlanternTopBg = "prefabs/ui/bigatlas/lunarlanterntopbg.unity3d"
AssetConfig.LunarlanternTopTitleI18N = "prefabs/ui/bigatlas/lunarlanterntoptitlei18n.unity3d"
AssetConfig.LunarypreferenceTopBgI18N = "prefabs/ui/bigatlas/lunarypreferencetopbgi18n.unity3d"
AssetConfig.RushtopTopBg = "prefabs/ui/bigatlas/rushtoptopbg.unity3d"
AssetConfig.RushtopTopTitleI18N = "prefabs/ui/bigatlas/rushtoptoptitlei18n.unity3d"
AssetConfig.LunarypreferenceTopTitleI18N = "textures/ui/bigbg/lunarypreferencetoptitlei18n.unity3d"
AssetConfig.christmas_desc2 = "prefabs/ui/christmas/christmasdesc2.unity3d"

AssetConfig.signdraw_window = "prefabs/ui/signdraw/signdrawwindow.unity3d"
AssetConfig.signdraw_bg1 = "prefabs/ui/bigatlas/signdraw_bg1.unity3d"
AssetConfig.signdraw_bg2 = "prefabs/ui/bigatlas/signdraw_bg2.unity3d"
AssetConfig.signdraw_bgtexti18n = "prefabs/ui/bigatlas/signdraw_bgtexti18n.unity3d"
AssetConfig.signdraw_textures = "textures/ui/signdraw.unity3d"
AssetConfig.signdraw_bg3 = "textures/ui/bigbg/signdraw_bg3.unity3d"
AssetConfig.signdraw_bg4 = "textures/ui/bigbg/singdrawinnerbg.unity3d"

AssetConfig.path_finding_bg = "prefabs/ui/bigatlas/pathfinding_bg.unity3d"
--植树摇摇乐
AssetConfig.arborDayShake_panel = "prefabs/ui/arborday/arborshakepanel.unity3d"
AssetConfig.arborDayReward_win = "prefabs/ui/arborday/arborrewardwin.unity3d"
AssetConfig.arborDayShake_texture = "textures/ui/arbordayshake.unity3d"
AssetConfig.logobg = "textures/ui/bigbg/arbordaylogobg.unity3d"
AssetConfig.logotitleI18N = "textures/ui/bigbg/arbordaylogoti18n.unity3d"
AssetConfig.ArborDayShakeBg = "textures/ui/bigbg/arbordayshakeareabgi18n.unity3d"
AssetConfig.ArborDayShakeShader = "textures/ui/bigbg/arbordayshakeshader.unity3d"
AssetConfig.ArborDayBg = "prefabs/ui/bigatlas/arbordaybg.unity3d"


--欢乐寻宝
AssetConfig.aprilTreasure_win = "prefabs/ui/apriltreasure/apriltreasurewindow.unity3d"
AssetConfig.aprilReward_win = "prefabs/ui/apriltreasure/aprilturnrewardwindow.unity3d"
AssetConfig.aprilTurnDice_win = "prefabs/ui/apriltreasure/luckydicewindow.unity3d"
AssetConfig.apriltreasure_Texture = "textures/ui/apriltreasure.unity3d"
AssetConfig.apriltreasureBg = "prefabs/ui/bigatlas/apriltreasurebigbg.unity3d"


AssetConfig.crossarenawindow = "prefabs/ui/crossarena/crossarenawindow.unity3d"
AssetConfig.crossarenaroomlistwindow = "prefabs/ui/crossarena/crossarenaroomlistwindow.unity3d"
AssetConfig.crossarenacreateteamwindow = "prefabs/ui/crossarena/crossarenacreateteamwindow.unity3d"
AssetConfig.crossarenaroomwindow = "prefabs/ui/crossarena/crossarenaroomwindow.unity3d"
AssetConfig.crossarenaicon = "prefabs/ui/crossarena/crossarenaicon.unity3d"
AssetConfig.crossarenatracecontent = "prefabs/ui/crossarena/crossarenatracecontent.unity3d"
AssetConfig.crossarenalogwindow = "prefabs/ui/crossarena/crossarenalogwindow.unity3d"
AssetConfig.crossarenainvitation = "prefabs/ui/crossarena/crossarenainvitation.unity3d"
AssetConfig.crossarenafighterwindow = "prefabs/ui/crossarena/crossarenafighterwindow.unity3d"
AssetConfig.crossarena_bg = "prefabs/ui/bigatlas/crossarena_bg.unity3d"
AssetConfig.crossarena_textures = "textures/ui/crossarena.unity3d"
AssetConfig.crossarena2_textures = "textures/ui/crossarena2.unity3d"

--周年庆
AssetConfig.anniversaryWin = "prefabs/ui/twoyearanniversary/twoyearanniverwindow.unity3d"
AssetConfig.anniversaryPanel = "prefabs/ui/twoyearanniversary/anniversarytwopanel.unity3d"
AssetConfig.anniversary_textures = "textures/ui/anniversary.unity3d"
AssetConfig.anniversary_bg1 = "prefabs/ui/bigatlas/anniversarybg.unity3d"
AssetConfig.anniversary_flower = "prefabs/ui/bigatlas/anniversaryholeflower.unity3d"
AssetConfig.anniversary_firstBg = "prefabs/ui/bigatlas/anniversaryfirstbg.unity3d"
AssetConfig.statusSendtyPanel = "prefabs/ui/twoyearanniversary/statussendtwoyearpanel.unity3d"

AssetConfig.anniversarygiftPanel = "prefabs/ui/twoyearanniversary/anniversarygiftpanel.unity3d"
AssetConfig.anniversarygiftclose = "textures/ui/bigbg/anniversarygiftclose.unity3d"
AssetConfig.bigbg1001 = "textures/ui/bigbg/1001.unity3d"
AssetConfig.bigbg1002 = "textures/ui/bigbg/1002.unity3d"
AssetConfig.bigbg1003 = "textures/ui/bigbg/1003.unity3d"
AssetConfig.topicbigbg = "textures/ui/bigbg/topicbigbg.unity3d"

AssetConfig.dailytopic = "textures/ui/dailytopic.unity3d"
--传声
AssetConfig.crossvoicewin = "prefabs/ui/corssvoice/crossvoicewindow.unity3d"
AssetConfig.crossvoicecontent = "prefabs/ui/corssvoice/crossvoicesystemcontent.unity3d"
AssetConfig.godswarchallangecontent = "prefabs/ui/teamquest/godswarchallengecontent.unity3d"
AssetConfig.godswarchallangepanel = "prefabs/ui/godswar/godswarchallangepanel.unity3d"
AssetConfig.godswarchallengebg = "prefabs/ui/bigatlas/godswarchallengebg.unity3d"
AssetConfig.crossvoicedecorate = "textures/ui/bigbg/crossvoicedecorate.unity3d"
AssetConfig.crossvoicetexture = "textures/ui/crossvoice.unity3d"
AssetConfig.crossvoiceimgtexture = "textures/ui/crossvoiceimg.unity3d"
AssetConfig.ConfirmTwice = "prefabs/ui/corssvoice/confirmtwicepanel.unity3d"

AssetConfig.newrebatepanel = "prefabs/ui/campaign/newrebatepanel.unity3d"
AssetConfig.newrebatebg = "prefabs/ui/bigatlas/newrebatebg.unity3d"
AssetConfig.newrebatedesc = "prefabs/ui/bigatlas/newrebatdesc.unity3d"

AssetConfig.addpointTexture = "textures/ui/addpoint.unity3d"

--峡谷之巅
AssetConfig.canyonotherteampanel = "prefabs/ui/canyon/canyonotherteampanel.unity3d"
AssetConfig.canyon_member_fight_rank_panel = "prefabs/ui/canyon/canyonmemberfightrankpanel.unity3d"
AssetConfig.trace_canyon_panel = "prefabs/ui/canyon/canyoncontent.unity3d"
AssetConfig.canyon_map_window = "prefabs/ui/canyon/canyonmapwindow.unity3d"
AssetConfig.canyon_fight_info_panel = "prefabs/ui/canyon/canyonfightinfopanel.unity3d"
AssetConfig.canyon_result_panel = "prefabs/ui/canyon/canyonresultpanel.unity3d"
AssetConfig.canyonbig = "textures/ui/bigbg/leaguebig.unity3d"
AssetConfig.canyon_make_team_panel = "prefabs/ui/canyon/canyonmaketeampanel.unity3d"
AssetConfig.canyon_desc_panel = "prefabs/ui/canyon/canyondescpanel.unity3d"

AssetConfig.rank_team_panel = "prefabs/ui/godswar/godswarrankshowpanel.unity3d"

AssetConfig.verify_textures = "textures/ui/verify.unity3d"

AssetConfig.truthordare_textures = "textures/ui/truthordare.unity3d"
AssetConfig.truthordarechatpanel = "prefabs/ui/truthordare/truthordarechatpanel.unity3d"
AssetConfig.truthordareagendawindow = "prefabs/ui/truthordare/truthordareagendawindow.unity3d"
AssetConfig.truthordarejoinwindow = "prefabs/ui/truthordare/truthordarejoinpanel.unity3d"
AssetConfig.truthordarequestionwindow = "prefabs/ui/truthordare/truthordarequestionwindow.unity3d"
AssetConfig.truthordareroomwindow = "prefabs/ui/truthordare/truthordareroomwindow.unity3d"
AssetConfig.truthordareboompanel = "prefabs/ui/truthordare/truthordareboompanel.unity3d"
AssetConfig.truthordareeditorwindow = "prefabs/ui/truthordare/truthordareeditorwindow.unity3d"
AssetConfig.truthordaresingleendwindow = "prefabs/ui/truthordare/truthordaresingleendpanel.unity3d"
AssetConfig.truthordareselectpanel = "prefabs/ui/truthordare/truthordareselectpanel.unity3d"
AssetConfig.truthordareagendaselepanel = "prefabs/ui/truthordare/truthordareagendaselepanel.unity3d"

AssetConfig.truthordareeditorpanel = "prefabs/ui/truthordare/truthordareeditorpanel.unity3d"
AssetConfig.truthordarevotepanel = "prefabs/ui/truthordare/truthordarevotepanel.unity3d"
AssetConfig.truthordarerulepanel = "prefabs/ui/truthordare/truthordarerulepanel.unity3d"
AssetConfig.truthordareguidepanel = "prefabs/ui/truthordare/truthordareguidepanel.unity3d"
AssetConfig.truthordarevotedetailspanel = "prefabs/ui/truthordare/truthordarevotedetailspanel.unity3d"

AssetConfig.TruthordareSelected = "textures/ui/bigbg/truthordarechooseselected.unity3d" 
AssetConfig.TruthordareTI18NChoose1 = "textures/ui/bigbg/truthordareti18nchoose1.unity3d" 
AssetConfig.TruthordareTI18NChoose2 = "textures/ui/bigbg/truthordareti18nchoose2.unity3d" 

AssetConfig.notice_tips = "prefabs/ui/tips/noticetips.unity3d"

--冬季积分兑换活动
AssetConfig.integral_exchange_window = "prefabs/ui/integralexchange/integralexchangewindow.unity3d"
AssetConfig.integral_obtain_panel = "prefabs/ui/integralexchange/integralobtainpanel.unity3d"
AssetConfig.integralexchange_bg1 = "prefabs/ui/bigatlas/integralexchange_bg1.unity3d"
AssetConfig.integralexchange_bg2 = "textures/ui/bigbg/integralexchange_bg2.unity3d"
AssetConfig.integralexchange_textures = "textures/ui/integralexchange.unity3d"

AssetConfig.WarmHeartGiftBigbg = "textures/ui/bigbg/warmheartgiftbigbg.unity3d"
AssetConfig.WarmHeartGift_window = "prefabs/ui/specialitemget/warmheartgiftwindow.unity3d"
AssetConfig.WarmHeartGiftbottombg = "prefabs/ui/bigatlas/warmheartgiftbottombg.unity3d"
AssetConfig.WarmHeartGift_textures = "textures/ui/warmheartgift.unity3d"
 
--刮刮乐系列活动
AssetConfig.cardexchangetexture = "textures/ui/cardexchange.unity3d"
AssetConfig.card_exchange_window = "prefabs/ui/cardexchange/cardexchangewindow.unity3d"
AssetConfig.card_exchange_bg1 = "prefabs/ui/bigatlas/cardexchangebg1.unity3d"
AssetConfig.card_exchange_bg2 = "prefabs/ui/bigatlas/cardexchangebg2.unity3d"
AssetConfig.card_exchange_bg3 = "prefabs/ui/bigatlas/cardexchangebg3.unity3d"
AssetConfig.card_exchange_bg4 = "prefabs/ui/bigatlas/cardexchangebg4.unity3d"

AssetConfig.surprise_discount_shop_panel = "prefabs/ui/cardexchange/surprisediscountshoppanel.unity3d"
AssetConfig.collection_word_exchange_panel = "prefabs/ui/cardexchange/collectionwordexchangepanel.unity3d"
AssetConfig.scratchcardpanel = "prefabs/ui/cardexchange/scratchcardpanel.unity3d"
AssetConfig.scratchcardbg = "prefabs/ui/bigatlas/scratchbg.unity3d"
 
--直购七日礼包
AssetConfig.directpackageWindow = "prefabs/ui/directpackage/directpackagewindow.unity3d"
AssetConfig.directpackagebg = "prefabs/ui/bigatlas/directpackagebg.unity3d"
AssetConfig.directpackagetxt = "prefabs/ui/bigatlas/directpackagetxt.unity3d"
AssetConfig.directpackagetextures = "textures/ui/directpackage.unity3d"

--幸运树摇一摇
AssetConfig.lucky_tree_window = "prefabs/ui/campaignproto/luckytree/luckytreewindow.unity3d"
AssetConfig.lucky_tree_bg = "prefabs/ui/bigatlas/luckytreebg.unity3d"
AssetConfig.luckytreetextures = "textures/ui/luckytree.unity3d"

--战令活动
AssetConfig.war_order_window = "prefabs/ui/campaignproto/warorder/warorderwindow.unity3d"
AssetConfig.war_order_buy_window = "prefabs/ui/campaignproto/warorder/warorderbuywindow.unity3d"
AssetConfig.war_order_reward_panel = "prefabs/ui/campaignproto/warorder/warorderrewardpanel.unity3d"
AssetConfig.war_order_quest_panel = "prefabs/ui/campaignproto/warorder/warorderquestpanel.unity3d"
AssetConfig.war_order_lev_panel = "prefabs/ui/campaignproto/warorder/warorderlevpanel.unity3d"
AssetConfig.war_order_preview_panel = "prefabs/ui/campaignproto/warorder/warorderpreviewpanel.unity3d"
AssetConfig.war_order_bg = "prefabs/ui/bigatlas/warorderbg.unity3d"
AssetConfig.war_order_buy_bg = "prefabs/ui/bigatlas/warorderbuybg.unity3d"
AssetConfig.warordertextures = "textures/ui/warorder.unity3d"

--定制礼包活动
AssetConfig.custom_gift_panel = "prefabs/ui/campaignproto/customgift/customgiftpanel.unity3d"
AssetConfig.custom_gift_panel_big_bg = "prefabs/ui/bigatlas/customgiftbigbg.unity3d"
AssetConfig.custom_gift_panel_bg = "prefabs/ui/bigatlas/customgiftbg.unity3d"
AssetConfig.custom_gift_textures = "textures/ui/customgift.unity3d"

--祈愿宝阁活动
AssetConfig.pray_treasure_window = "prefabs/ui/campaignproto/praytreasure/praytreasurewindow.unity3d"
AssetConfig.pray_treasure_main_panel = "prefabs/ui/campaignproto/praytreasure/praytreasuremainpanel.unity3d"
AssetConfig.pray_treasure_reward_panel = "prefabs/ui/campaignproto/praytreasure/praytreasurerewardpanel.unity3d"
AssetConfig.pray_treasure_shop_panel = "prefabs/ui/campaignproto/praytreasure/praytreasureshoppanel.unity3d"
AssetConfig.pray_treasure_bg = "prefabs/ui/bigatlas/praytreaturesbg.unity3d"
AssetConfig.praytreasuretextures = "textures/ui/praytreasure.unity3d"
