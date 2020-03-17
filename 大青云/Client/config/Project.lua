
_dofile (ClientConfigPath .. 'config/global.lua')
_dofile (ClientConfigPath .. 'config/RenderConfig.lua')
--预加载的配置
--_dofile (ClientConfigPath .. 'config/PreloadCfg.lua')
--字典表
_dofile (ClientConfigPath .. 'config/str/Include.lua')
--手动配置的表
_dofile (ClientConfigPath .. 'config/common/Project.lua')
_dofile (ClientConfigPath .. 'config/activity/Project.lua')
_dofile (ClientConfigPath .. 'config/gui/Project.lua')
_dofile (ClientConfigPath .. 'config/map/Project.lua')
--版本配置文件
_dofile (ClientConfigPath .. 'config/version/Project.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/Storynpclist.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/StoryConfig.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/PatrolConfig.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/NpcActConfig.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/StoryMonster.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/StoryAutoCamaraConfig.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/StorySceneEffect.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/StoryDialogConfig.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/ResListCfg.lua')
_dofile (ClientConfigPath .. 'config/storyconfig/StoryChangePos.lua')
_dofile (ClientConfigPath .. 'config/t_juqing_action.lua')
_dofile (ClientConfigPath .. 'config/t_juqing_actionOld.lua')
--任务脚本
_dofile (ClientConfigPath .. 'config/questScript/Project.lua')
_dofile (ClientConfigPath .. 'config/itemGuideScript/Project.lua');
--物品脚本
_dofile (ClientConfigPath .. 'config/itemScript/Project.lua')
--公告脚本
_dofile (ClientConfigPath .. 'config/noticeScript/Project.lua')
--加载提示
_dofile (ClientConfigPath .. 'config/loading/Project.lua')
--常量表
_dofile (ClientConfigPath .. 'config/t_consts.lua')
--玩家配置
_dofile (ClientConfigPath .. 'config/t_playerinfo.lua')
--NPC,怪物,模型
_dofile (ClientConfigPath .. "config/t_npc.lua")
_dofile (ClientConfigPath .. "config/t_monster.lua")
_dofile (ClientConfigPath .. 'config/t_model.lua')
_dofile (ClientConfigPath .. 'config/t_rolemodel.lua')
_dofile (ClientConfigPath .. "config/t_mountmodel.lua")
_dofile (ClientConfigPath .. "config/t_equipmodel.lua")
--物品装备
_dofile (ClientConfigPath .. "config/t_equip.lua")
_dofile (ClientConfigPath .. "config/t_equipgroup.lua");
_dofile (ClientConfigPath .. "config/t_equipgrade.lua");
_dofile (ClientConfigPath .. "config/t_item.lua")
_dofile (ClientConfigPath .. "config/t_itemguide.lua")
_dofile (ClientConfigPath .. "config/t_horn.lua")
_dofile (ClientConfigPath .. "config/t_packetcost.lua")
_dofile (ClientConfigPath .. "config/t_storagecost.lua")
_dofile (ClientConfigPath .. "config/t_equippro.lua")
_dofile (ClientConfigPath .. "config/t_equipdevour.lua")
_dofile (ClientConfigPath .. "config/t_equipgem.lua")
_dofile (ClientConfigPath .. "config/t_gemgroup.lua")
_dofile (ClientConfigPath .. "config/t_gemcost.lua")
_dofile (ClientConfigPath .. "config/t_gemlock.lua")
--技能
_dofile (ClientConfigPath .. "config/t_skill.lua")
_dofile (ClientConfigPath .. "config/t_skill_action.lua")
_dofile (ClientConfigPath .. "config/t_skillgroup.lua")
_dofile (ClientConfigPath .. "config/t_effect.lua")
_dofile (ClientConfigPath .. "config/t_buff.lua")
_dofile (ClientConfigPath .. "config/t_buffeffect.lua")
_dofile (ClientConfigPath .. "config/t_passiveskill.lua")

-- 绝学&心法   --adder:houxudong 
_dofile (ClientConfigPath .. "config/t_juexue.lua")
_dofile (ClientConfigPath .. "config/t_juexuezu.lua")
_dofile (ClientConfigPath .. "config/t_xinfa.lua")   
_dofile (ClientConfigPath .. "config/t_xinfazu.lua")
--任务
_dofile (ClientConfigPath .. "config/t_quest.lua")
_dofile (ClientConfigPath .. "config/t_questlevel.lua")
_dofile (ClientConfigPath .. "config/t_questChapter.lua")
_dofile (ClientConfigPath .. "config/t_dailyquest.lua")
_dofile (ClientConfigPath .. "config/t_dailygroup.lua")
--地图相关
_dofile (ClientConfigPath .. "config/t_map.lua")
_dofile (ClientConfigPath .. "config/t_portal.lua")
_dofile (ClientConfigPath .. "config/t_position.lua")
_dofile (ClientConfigPath .. "config/t_collection.lua")
--邮件
_dofile (ClientConfigPath .. "config/t_mailContent.lua")
--升级
_dofile (ClientConfigPath .. "config/t_lvup.lua")
--创角名字
_dofile (ClientConfigPath .. "config/t_womansurname.lua")
_dofile (ClientConfigPath .. "config/t_womanname.lua")
_dofile (ClientConfigPath .. "config/t_mansurname.lua")
_dofile (ClientConfigPath .. "config/t_manname.lua")
--公告,系统通知
_dofile (ClientConfigPath .. "config/t_notice.lua")
_dofile (ClientConfigPath .. "config/t_sysnotice.lua")
--武魂
--_dofile (ClientConfigPath .. "config/t_wuhun.lua")
--_dofile (ClientConfigPath .. "config/t_wuhunachieve.lua")
--_dofile (ClientConfigPath .. "config/t_wuhunskin.lua")
--_dofile (ClientConfigPath .. "config/t_lingshoumodel.lua")
--_dofile (ClientConfigPath .. "config/t_lingshouui.lua")
_dofile (ClientConfigPath .. "config/t_lingshouskill.lua")
--剧情副本
_dofile (ClientConfigPath .. "config/t_dunstep.lua")
_dofile (ClientConfigPath .. "config/t_dungeons.lua")
_dofile (ClientConfigPath .. "config/t_dunreward.lua")
_dofile (ClientConfigPath .. "config/t_dungeonevent.lua")
--商店
_dofile (ClientConfigPath .. "config/t_shop.lua")
--新功能开启
_dofile (ClientConfigPath .. "config/t_funcOpen.lua")
--坐骑
_dofile (ClientConfigPath .. "config/t_horse.lua")
_dofile (ClientConfigPath .. "config/t_horselv.lua")
_dofile (ClientConfigPath .. "config/t_horseskill.lua")
_dofile (ClientConfigPath .. "config/t_horseskn.lua")
_dofile (ClientConfigPath .. "config/t_horsestar.lua")
_dofile (ClientConfigPath .. "config/t_horselingshou.lua")
_dofile (ClientConfigPath .. "config/t_horselsstar.lua")
--骑战
_dofile (ClientConfigPath .. "config/t_ridewar.lua")

_dofile (ClientConfigPath .. "config/t_shenlingachieve.lua")
_dofile (ClientConfigPath .. "config/t_shenlingmodel.lua")
--强化
_dofile (ClientConfigPath .. "config/t_stren.lua")
_dofile (ClientConfigPath .. "config/t_strenattr.lua")
_dofile (ClientConfigPath .. "config/t_strenlink.lua")
--融合
_dofile (ClientConfigPath .. "config/t_fuse.lua")
--升星
_dofile (ClientConfigPath .. "config/t_fuse.lua")
--卓越
_dofile (ClientConfigPath .. "config/t_fujiashuxing.lua");
_dofile (ClientConfigPath .. "config/t_strenxingji.lua");
--新卓越
_dofile (ClientConfigPath .. "config/t_zhuoyueshuxing.lua");
_dofile (ClientConfigPath .. "config/t_zhuoyue3.lua");
_dofile (ClientConfigPath .. "config/t_zhuoyuenum.lua");
_dofile (ClientConfigPath .. "config/t_zhuoyuelink.lua");
--追加
_dofile (ClientConfigPath .. "config/t_equipExtra.lua");
--称号
_dofile (ClientConfigPath .. "config/t_title.lua")
_dofile (ClientConfigPath .. "config/t_titlegroup.lua")
--亲密度
_dofile (ClientConfigPath .. "config/t_intimacy.lua")
-- 帮派
_dofile (ClientConfigPath .. "config/t_guild.lua")
_dofile (ClientConfigPath .. "config/t_guildskill.lua")
_dofile (ClientConfigPath .. "config/t_guildskillgroud.lua")
_dofile (ClientConfigPath .. "config/t_guildtitle.lua")
_dofile (ClientConfigPath .. "config/t_guildwash.lua")
_dofile (ClientConfigPath .. "config/t_guildActivity.lua")
_dofile (ClientConfigPath .. "config/t_guildHell.lua")
_dofile (ClientConfigPath .. "config/t_hellReward.lua")
_dofile (ClientConfigPath .. "config/t_guildpray.lua")
_dofile (ClientConfigPath .. "config/t_citywar.lua")
_dofile (ClientConfigPath .. "config/t_guilddigong.lua")
_dofile (ClientConfigPath .. "config/t_digongreward.lua")
_dofile (ClientConfigPath .. "config/t_digongguildreward.lua")
-- 世界boss
_dofile (ClientConfigPath .. "config/t_worldboss.lua")
--传承
_dofile (ClientConfigPath .. "config/t_strentrans.lua")
--活动
_dofile (ClientConfigPath .. "config/t_activity.lua");
--封妖
_dofile (ClientConfigPath .. "config/t_fengyao.lua");
_dofile (ClientConfigPath .. "config/t_fengyaogroup.lua");
_dofile (ClientConfigPath .. "config/t_fengyaojifen.lua");
--世界boss
_dofile (ClientConfigPath .. "config/t_worldboss.lua");
--音效配置
_dofile (ClientConfigPath .. "config/t_music.lua");
--等级奖励
_dofile (ClientConfigPath .. "config/t_lvreward.lua");
--打坐加成
_dofile (ClientConfigPath .. "config/t_zazen.lua");
--道具合成
_dofile (ClientConfigPath .. "config/t_itemcompound.lua");
_dofile (ClientConfigPath .. "config/t_itemresolve.lua");
--流水副本
_dofile (ClientConfigPath .. "config/t_liushuifuben.lua");

--竞技场
_dofile (ClientConfigPath .. "config/t_jjcEvent.lua");
_dofile (ClientConfigPath .. "config/t_jjc.lua");
_dofile (ClientConfigPath .. "config/t_jjcPrize.lua");

--解救冰奴
_dofile (ClientConfigPath .. "config/t_product.lua")
--战场奖励
_dofile (ClientConfigPath .. "config/t_campAward.lua")
--每日杀戮属性
_dofile (ClientConfigPath .. "config/t_killtask.lua")

--时装衣柜
_dofile (ClientConfigPath .. "config/t_fashions.lua")
_dofile (ClientConfigPath .. "config/t_fashiongroup.lua")
--神兵
_dofile (ClientConfigPath .. "config/t_shenbing.lua")
--神兵model
_dofile (ClientConfigPath .. "config/t_shenbingmodel.lua")
--神兵神灵
_dofile (ClientConfigPath .. "config/t_shenbingbingling.lua")
--灵器
_dofile (ClientConfigPath .. "config/t_lingqi.lua")
--灵器model
_dofile (ClientConfigPath .. "config/t_lingqimodel.lua")
--灵器神灵
_dofile (ClientConfigPath .. "config/t_lingqibingling.lua")
--命玉
_dofile (ClientConfigPath .. "config/t_mingyu.lua")
--命玉model
_dofile (ClientConfigPath .. "config/t_mingyumodel.lua")
--命玉神灵
_dofile (ClientConfigPath .. "config/t_mingyubingling.lua")
--通天塔
_dofile (ClientConfigPath .. "config/t_doupocangqiong.lua")
-- 帮派战奖励
_dofile (ClientConfigPath .. "config/t_guildbattle.lua")
--仙缘洞府BOSS寻路
_dofile (ClientConfigPath .. "config/t_xianyuancave.lua")
_dofile (ClientConfigPath .. "config/t_xyreward.lua")
--定时副本
_dofile (ClientConfigPath .. "config/t_monkeytime.lua")
_dofile (ClientConfigPath .. "config/t_monkeytimereward.lua")
--新版极限挑战
_dofile (ClientConfigPath .. "config/t_limitreward.lua")
--签到
_dofile (ClientConfigPath .. "config/t_signreward.lua")
--活跃度
_dofile (ClientConfigPath .. "config/t_xianjie.lua")
_dofile (ClientConfigPath .. "config/t_xianjielv.lua")
_dofile (ClientConfigPath .. "config/t_pendant.lua")

_dofile (ClientConfigPath .. "config/t_onlinetimes.lua")
--境界
_dofile (ClientConfigPath .. "config/t_jingjie.lua")
_dofile (ClientConfigPath .. "config/t_jingjiegonggu.lua")
--翅膀升星
_dofile (ClientConfigPath .. "config/t_wingequip.lua")
--战铠宝甲
_dofile (ClientConfigPath .. "config/t_baojia.lua")
_dofile (ClientConfigPath .. "config/t_jialing.lua")
--灵力徽章
_dofile (ClientConfigPath .. "config/t_huizhang.lua")
--福神降临
_dofile (ClientConfigPath .. "config/t_doorposition.lua")
--冰魂
_dofile (ClientConfigPath .. "config/t_binghun.lua")
_dofile (ClientConfigPath .. "config/t_binghunmodel.lua")
--激活码
_dofile (ClientConfigPath .. "config/t_jihuoma.lua")
--剧情对话
_dofile (ClientConfigPath .. "config/t_duntalk.lua")
--王城战
_dofile (ClientConfigPath .. "config/t_guildwangchengextra.lua")
_dofile (ClientConfigPath .. "config/t_guildwangcheng.lua")
--VIP
_dofile (ClientConfigPath .. "config/t_vip.lua")
_dofile (ClientConfigPath .. "config/t_viptype.lua")
_dofile (ClientConfigPath .. "config/t_vippower.lua")
--在线奖励
_dofile (ClientConfigPath .. "config/t_onlineaward.lua")
--今日必做
_dofile (ClientConfigPath .. "config/t_bizuo.lua")
_dofile (ClientConfigPath .. "config/t_extremity.lua")
_dofile (ClientConfigPath .. "config/t_bizuolingguang.lua")
--萌宠
_dofile (ClientConfigPath .. "config/t_lovelypet.lua")
_dofile (ClientConfigPath .. "config/t_petmodel.lua")
_dofile (ClientConfigPath .. "config/lovelypetchatcfg.lua")
--主要活动开启时间
_dofile (ClientConfigPath .. "config/t_activityremindfirst.lua")
_dofile (ClientConfigPath .. "config/t_activitytime.lua")
--灵兽墓地
-- _dofile (ClientConfigPath .. "config/t_lingshoumudi.lua")
--运营活动
_dofile (ClientConfigPath .. "config/t_yunying.lua")
--阵营
_dofile (ClientConfigPath .. "config/t_camp.lua")
-- 灵兽战印
_dofile (ClientConfigPath .. "config/t_zhanyin.lua")
_dofile (ClientConfigPath .. "config/t_zhanyinachieve.lua")
_dofile (ClientConfigPath .. "config/t_zhanyinhole.lua")
_dofile (ClientConfigPath .. "config/t_zhanyincost.lua")
_dofile (ClientConfigPath .. "config/t_zhanyinexchange.lua")
_dofile (ClientConfigPath .. "config/t_zhanyinexchangepage.lua")
_dofile (ClientConfigPath .. "config/t_zhanyinmodel.lua")
--陷阱
_dofile (ClientConfigPath .. "config/t_trap.lua")
--服务器等级
_dofile (ClientConfigPath .. "config/t_worldlevel.lua")
_dofile (ClientConfigPath .. "config/t_limitbossaward.lua")
_dofile (ClientConfigPath .. "config/t_limitmonaward.lua")

-- V计划
_dofile (ClientConfigPath .. "config/t_vlevel.lua")
_dofile (ClientConfigPath .. "config/t_vtype.lua")
_dofile (ClientConfigPath .. "config/t_vlvlreward.lua")
_dofile (ClientConfigPath .. "config/t_vconsume.lua")

--成就
_dofile (ClientConfigPath .. "config/t_achievement.lua")
_dofile (ClientConfigPath .. "config/t_achievementstage.lua")

-- 装备打造
_dofile (ClientConfigPath .. "config/t_equipcreate.lua")
_dofile (ClientConfigPath .. "config/t_decompose.lua")
--炼化
_dofile (ClientConfigPath .. "config/t_refin.lua")
_dofile (ClientConfigPath .. "config/t_refinlink.lua")

--装备评分
_dofile (ClientConfigPath .. "config/t_guildblank.lua")
--地图特殊点
_dofile (ClientConfigPath .. "config/t_mapSpoint.lua")

--主宰之路
_dofile (ClientConfigPath .. "config/t_zhuzairoad.lua")
_dofile (ClientConfigPath .. "config/t_roadbox.lua")
_dofile (ClientConfigPath .. "config/t_roadnum.lua")

--妖丹
_dofile (ClientConfigPath .. "config/t_yaodan.lua")

--北苍界
_dofile (ClientConfigPath .. "config/t_beicangjiescore.lua")
_dofile (ClientConfigPath .. "config/t_beicangjiereward.lua")

--个人BOSS
_dofile (ClientConfigPath .. "config/t_personalboss.lua")
_dofile (ClientConfigPath .. "config/t_swyj.lua")

--属性换算
_dofile (ClientConfigPath .. "config/t_baseAttr.lua")
-- 装备打造，卓越
_dofile (ClientConfigPath .. "config/t_zhuoyue.lua")
--翅膀
_dofile (ClientConfigPath .. "config/t_wing.lua")
--  祈愿
_dofile (ClientConfigPath .. "config/t_dailybuy.lua")
_dofile (ClientConfigPath .. "config/t_buytime.lua")
-- 跨服副本
_dofile (ClientConfigPath .. "config/t_worlddungeons.lua")
--  寻宝
_dofile (ClientConfigPath .. "config/t_wabaolevel.lua")
_dofile (ClientConfigPath .. "config/t_wabao.lua")
_dofile (ClientConfigPath .. "config/t_wabaomap.lua")
_dofile (ClientConfigPath .. "config/t_cangbaotu.lua")
-- 圣灵镶嵌
_dofile (ClientConfigPath .. "config/t_binghungem.lua")
_dofile (ClientConfigPath .. "config/t_binghungrid.lua")
-- 奇遇任务
_dofile (ClientConfigPath .. "config/t_qiyu.lua")
_dofile (ClientConfigPath .. "config/t_qiyuzu.lua")
_dofile (ClientConfigPath .. "config/t_qiyulevel.lua")
_dofile (ClientConfigPath .. "config/t_qiyutiku.lua")
--卓越引导
_dofile (ClientConfigPath .. "config/t_zhuoyueguide.lua")
_dofile (ClientConfigPath .. "config/t_zhuoyuetujing.lua")
--怪物攻城
_dofile (ClientConfigPath .. "config/t_shouweibeicang.lua")
--七日登录
_dofile (ClientConfigPath .. "config/t_sevenday.lua")
_dofile (ClientConfigPath .. "config/t_sevenmodel.lua")
--骑战副本
_dofile (ClientConfigPath .. "config/t_ridereward.lua")
_dofile (ClientConfigPath .. "config/t_ridedungeon.lua")
--挑战副本
_dofile (ClientConfigPath .. "config/t_tiaozhanreward.lua")
_dofile (ClientConfigPath .. "config/t_tiaozhanfuben.lua")
--帮派boss
_dofile (ClientConfigPath .. "config/t_guildBoss.lua")
_dofile (ClientConfigPath .. "config/t_guildBosslevel.lua")
--家园
_dofile (ClientConfigPath .. "config/t_homebuild.lua")
_dofile (ClientConfigPath .. "config/t_homepupilexp.lua")
_dofile (ClientConfigPath .. "config/t_homepupilskill.lua")
_dofile (ClientConfigPath .. "config/t_homequestrange.lua")
_dofile (ClientConfigPath .. "config/t_homequest.lua")
_dofile (ClientConfigPath .. "config/t_homequestmon.lua")
--_dofile (ClientConfigPath .. "config/t_homequesttarget.lua")
_dofile (ClientConfigPath .. "config/t_homepupilexpitem.lua")
_dofile (ClientConfigPath .. "config/t_homepupilRe.lua")
_dofile (ClientConfigPath .. "config/t_homequesttime.lua")
_dofile (ClientConfigPath .. "config/t_homepupilskillrange.lua")
_dofile (ClientConfigPath .. "config/t_homepupilimage.lua")
_dofile (ClientConfigPath .. "config/t_homefighttxt.lua")
_dofile (ClientConfigPath .. "config/t_homequestfit.lua")
_dofile (ClientConfigPath .. "config/t_homeskillcom.lua")

_dofile (ClientConfigPath .. "config/t_kuafuranking.lua")
_dofile (ClientConfigPath .. "config/t_kuafudan.lua")
_dofile (ClientConfigPath .. "config/t_kuafudan360.lua")
_dofile (ClientConfigPath .. "config/t_kuafudanyouxi.lua")
_dofile (ClientConfigPath .. "config/t_kuafudanlianyun.lua")
_dofile (ClientConfigPath .. "config/t_kuafureward.lua")
_dofile (ClientConfigPath .. "config/t_kuafuquest.lua")
_dofile (ClientConfigPath .. "config/t_kuafusceneboss.lua")
_dofile (ClientConfigPath .. "config/t_guildassemble.lua")
--360卫士
_dofile (ClientConfigPath .. "config/t_weishi.lua")
_dofile (ClientConfigPath .. "config/t_youxidating.lua")

--抢门
_dofile (ClientConfigPath .. "config/t_snatchdoor.lua")

_dofile (ClientConfigPath .. "config/t_guildbattleselfindex.lua")
_dofile (ClientConfigPath .. "config/t_guildbattleself.lua")
--转生
_dofile (ClientConfigPath .. "config/t_zhuansheng.lua")
--item卡片
_dofile (ClientConfigPath .. "config/t_itemcard.lua")
--技能推荐设置
_dofile (ClientConfigPath .. "config/t_skillShortCut.lua")
--圣诞
_dofile (ClientConfigPath .. "config/t_chjuanxian.lua")
_dofile (ClientConfigPath .. "config/t_chjuanxianreward.lua")
--熔炼
_dofile (ClientConfigPath .. "config/t_smeltlevel.lua")
_dofile (ClientConfigPath .. "config/t_uiframe.lua")
--套装基础属性
_dofile (ClientConfigPath .. "config/t_equipgrouppos.lua")
-- 套装升级
_dofile (ClientConfigPath .. "config/t_equipgrouphuizhang.lua")
_dofile (ClientConfigPath .. "config/t_equipgroupextra.lua")
_dofile (ClientConfigPath .. "config/t_equipgroupexpand.lua")
--顺网平台vip奖励
_dofile (ClientConfigPath .. "config/t_shunwangvip.lua")
--boss徽章
_dofile (ClientConfigPath .. "config/t_bosshuizhang.lua")
_dofile (ClientConfigPath .. "config/t_bossMediaAttr.lua")

_dofile (ClientConfigPath .. "config/t_kuafubenfu.lua")

--卓越洗练
_dofile (ClientConfigPath .. "config/t_equipsuperwash.lua")
--_dofile (ClientConfigPath .. "config/t_zhuoyuewash0.lua")
--_dofile (ClientConfigPath .. "config/t_zhuoyuewash1.lua")
--_dofile (ClientConfigPath .. "config/t_zhuoyuewash2.lua")
--_dofile (ClientConfigPath .. "config/t_zhuoyuewash3.lua")
_dofile (ClientConfigPath .. "config/t_kuafuboss.lua")
_dofile (ClientConfigPath .. "config/t_kuafuactivity.lua")
_dofile (ClientConfigPath .. "config/t_kuafuarenareward.lua")
_dofile (ClientConfigPath .. "config/t_kuafusaireward.lua")
--必做福神
_dofile (ClientConfigPath .. "config/t_bizuofushen.lua")
--结婚
_dofile (ClientConfigPath .. "config/t_marryRing.lua")
_dofile (ClientConfigPath .. "config/t_marrytime.lua")
_dofile (ClientConfigPath .. "config/t_marry.lua")
_dofile (ClientConfigPath .. "config/t_marryIntimate.lua")
_dofile (ClientConfigPath .. "config/t_patrol.lua")
_dofile (ClientConfigPath .. "config/t_marrystren.lua")
--神武
_dofile (ClientConfigPath .. "config/t_shenwu.lua")
_dofile (ClientConfigPath .. "config/t_shenwustar.lua")
_dofile (ClientConfigPath .. "config/t_shenwumodel.lua")
--天命
--_dofile (ClientConfigPath .. "config/t_lingshousoul.lua")
--_dofile (ClientConfigPath .. "config/t_lingshousoulheti.lua")
--灵诀
_dofile (ClientConfigPath .. "config/t_lingjueachieve.lua")
_dofile (ClientConfigPath .. "config/t_lingjue.lua")
_dofile (ClientConfigPath .. "config/t_lingjuegroup.lua")
--烟花
_dofile (ClientConfigPath .. "config/t_firework.lua")

------------------NEW------------------
-----------------VENUS-----------------
--法宝
_dofile (ClientConfigPath .. "config/t_fabao.lua")
_dofile (ClientConfigPath .. "config/t_fabaoshuxing.lua")
_dofile (ClientConfigPath .. "config/t_fabaojineng.lua")
_dofile (ClientConfigPath .. "config/t_fabaolv.lua")

--打宝塔
_dofile (ClientConfigPath .. "config/t_yaota.lua")

--伏魔宝鉴
_dofile (ClientConfigPath .. "config/t_fumobasic.lua")
_dofile (ClientConfigPath .. "config/t_fomolv.lua")
_dofile (ClientConfigPath .. "config/t_fumoliansuo.lua")

-- 星图
_dofile	(ClientConfigPath .. "config/t_xingtu.lua")
_dofile	(ClientConfigPath .. "config/t_xingtuscene.lua")
-- 机关
_dofile	(ClientConfigPath .. "config/t_jiguan.lua")

--- 野外BOSS
_dofile	(ClientConfigPath .. "config/t_fieldboss.lua")
-- 神炉
_dofile (ClientConfigPath .. "config/t_stoveplay.lua")
_dofile (ClientConfigPath .. "config/t_stoveitem.lua")
-- 转职
_dofile (ClientConfigPath .. "config/t_transfer.lua")
_dofile (ClientConfigPath .. "config/t_transferquest.lua")
_dofile (ClientConfigPath .. "config/t_transferattr.lua")
----雨
_dofile (ClientConfigPath .. "config/t_weather.lua")
--- 新版战斗力计算
_dofile (ClientConfigPath .. "config/t_specialAttrfightC.lua")
--- 洗练
_dofile (ClientConfigPath .. "config/t_extrachain.lua")
_dofile (ClientConfigPath .. "config/t_extraatt.lua")
_dofile (ClientConfigPath .. "config/t_extraclass.lua")
_dofile (ClientConfigPath .. "config/t_extraquality.lua")
-- 传承
_dofile (ClientConfigPath .. "config/t_inherit.lua")
-- 金币BOSS
_dofile (ClientConfigPath .. "config/t_goldboss.lua")
_dofile (ClientConfigPath .. "config/t_goldbosspar.lua")
--目标奖励
_dofile (ClientConfigPath .. "config/t_mubiao.lua")
--更新公告
_dofile (ClientConfigPath .. "config/updateContentcfg.lua")
--采集物
_dofile (ClientConfigPath .. "config/t_beicangjiecaiji.lua")
--左戒
_dofile (ClientConfigPath .. "config/t_ring.lua")
--独立副本
_dofile (ClientConfigPath .. "config/t_questdungeon.lua")
--天神附体
_dofile (ClientConfigPath .. "config/t_bianshen.lua")
_dofile (ClientConfigPath .. "config/t_bianshenlv.lua")
_dofile (ClientConfigPath .. "config/t_bianshenstar.lua")
_dofile (ClientConfigPath .. "config/t_bianshenmodel.lua")

_dofile (ClientConfigPath .. "config/t_tianshen.lua")
_dofile (ClientConfigPath .. "config/t_tianshenlv.lua")



--大摆筵席
_dofile (ClientConfigPath .. "config/t_lunch.lua")
_dofile (ClientConfigPath .. "config/t_lunchexp.lua")
--假广告
_dofile (ClientConfigPath .. "config/t_shampublicitytext.lua")
_dofile (ClientConfigPath .. "config/t_shampublicityname.lua")

--装备收集
_dofile (ClientConfigPath .. "config/t_equipcollectionbasis.lua")
_dofile (ClientConfigPath .. "config/t_equipcollectionplace.lua")

--右下角提示
_dofile (ClientConfigPath .. "config/t_funcremind.lua")
_dofile (ClientConfigPath .. "config/t_funcremindcondition.lua")

--等级称号
_dofile (ClientConfigPath .. "config/t_leveltitle.lua")
--历练 奇遇任务
_dofile (ClientConfigPath .. "config/t_questrandom.lua")
_dofile (ClientConfigPath .. "config/t_questrandomgruop.lua")

--快速购买推荐获取途径
_dofile (ClientConfigPath .. "config/t_itemacquirelist.lua")
_dofile (ClientConfigPath .. "config/t_itemacquireway.lua")

_dofile (ClientConfigPath .. "config/t_positionlv.lua")
--修为池
_dofile (ClientConfigPath .. "config/t_xiuweipoint.lua")
_dofile (ClientConfigPath .. "config/t_xiuweiitem.lua")
_dofile (ClientConfigPath .. "config/t_xiuwei.lua")

--功能按钮提醒tips
_dofile (ClientConfigPath .. "config/t_funcremindtips.lua")
--讨伐
_dofile (ClientConfigPath .. "config/t_taofa.lua")
--诛仙阵青云志
_dofile (ClientConfigPath .. "config/t_zhuxianzhen.lua")
--任务集会所 新屠魔 新悬赏
_dofile (ClientConfigPath .. "config/t_questagora_consts.lua")
_dofile (ClientConfigPath .. "config/t_questagora.lua")
_dofile (ClientConfigPath .. "config/t_questagora_quality.lua")
_dofile (ClientConfigPath .. "config/t_questagora_rewards.lua")
_dofile (ClientConfigPath .. "config/t_questagora_exp.lua")

--
_dofile (ClientConfigPath .. "config/t_muyeskill.lua")
_dofile (ClientConfigPath .. "config/t_muyewar.lua")
--排行榜
_dofile (ClientConfigPath .. "config/t_ranking.lua")
--新宝甲
_dofile (ClientConfigPath .. "config/t_newbaojia.lua")
_dofile (ClientConfigPath .. "config/t_newbaojiabingling.lua")
_dofile (ClientConfigPath .. "config/t_newbaojialing.lua")
_dofile (ClientConfigPath .. "config/t_newbaojiamodel.lua")
--猎魔
_dofile (ClientConfigPath .. "config/t_todayquest.lua")
--圣物
_dofile (ClientConfigPath .. "config/t_newequip.lua")
--新加的玩家穿戴神铸装备套装属性
_dofile (ClientConfigPath .. "config/t_equipdescribe.lua")

--新版天神
_dofile (ClientConfigPath .. "config/t_newtianshenxishu.lua")
_dofile (ClientConfigPath .. "config/t_newtianshenskill.lua")
_dofile (ClientConfigPath .. "config/t_newtianshenlv.lua")
_dofile (ClientConfigPath .. "config/t_newtianshenup.lua")
_dofile (ClientConfigPath .. "config/t_newtianshenshuxing.lua")
_dofile (ClientConfigPath .. "config/t_newtianshen.lua")
_dofile (ClientConfigPath .. "config/t_newtianshenstar.lua")
_dofile (ClientConfigPath .. "config/t_newtianshencard.lua")
_dofile (ClientConfigPath .. "config/t_newtianshenstarattr.lua")
--挂机任务
_dofile (ClientConfigPath .. "config/t_guaji.lua")
-- wan特殊渠道奖励
_dofile (ClientConfigPath .. "config/t_weishilogin.lua")