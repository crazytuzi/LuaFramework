ResPath = ResPath or {}

ResPath.CurrencyToIconId = {
	["diamond"] = 65534,		--钻石
	["bind_diamond"] = 65533,	--绑钻
	["exp"] = 90050,			--经验
	["chengjiu"] = 90001,		--成就
	["shengwang"] = 90002,		--魔晶
	["honor"] = 90003,			--声望
	["gongxun"] = 90004,		--功勋
	["weiwang"] = 90005,		--威望
	["hunli"] = 90010,			--魂力
	["rune_suipian"] = 90012,	--符文碎片
	["magic_crystal"] = 90013,	--符文水晶
	["huoyue"] = 90014,         --活跃度
	["rune_jinghua"] = 90210,	--符文精华
	--下面的还没有道具id
	["yuanli"] = 65534,
	["xianhun"] = 65534,
	["gongxian"] = 65534,
	["nvwashi"] = 65534,
	["guild_gongxian"] = 90009,  -- 公会贡献
	["kuafu_jifen"] = {
	90004,90017,}				 -- 跨服积分
}

function ResPath.GetLoginRes(res_name)
	return "uis/views/login/images_atlas", res_name
end

function ResPath.GetBgChapter(index)
	return "uis/rawimages/slaughter_devil" .. index, "slaughter_devil" .. index .. ".png"
end

function ResPath.GetLevelIcon(index)
	return "uis/views/lianhun/images_atlas", "level_" .. index
end

-- Icon  sex:1男 0女
function ResPath.GetRoleHeadBig(res_id, sex)
	sex = sex or 1
	return "uis/icons/portrait_atlas", res_id .. sex
end

function ResPath.GetRoleIconBig(res_id)
	return "uis/icons/portrait_atlas", res_id
end

--引导资源
function ResPath.GetGuideRes(res_id)
	return "uis/rawimages/guidegirl", tostring(res_id) .. ".png"
end

function ResPath.GetSexRes(sex)
	local asset = sex == 0 and "Icon_Fmale" or "Icon_Male"
	return "uis/images_atlas", asset
end

function ResPath.GetMiscPreloadRes(res_id)
	return "uis/views/miscpreload_prefab", tostring(res_id)
end

function ResPath.GetMiscPreloadImgRes(res_id)
	return "uis/views/miscpreload/images_atlas", tostring(res_id)
end
-----------------------表情目录--------------------------
--表情资源路径(小)
function ResPath.GetResFaceSmall(res_id)
	return "uis/views/main_prefab", tostring(res_id)
end

--表情资源路径(大)
function ResPath.GetResFaceBig(res_id)
	return "uis/views/chatview_prefab", tostring(res_id)
end

--大表情资源路径
function ResPath.GetResBigFace(res_id, str)
	return "uis/icons/bigface/face_" .. (res_id+100) .. "_prefab", str..tostring(res_id)
end

--普通动态标签资源路径
function ResPath.GetResNormalFace(res_id, str)
	res_id = res_id + 100
	return "uis/icons/normalface/"..res_id.."_prefab", str..tostring(res_id)
end
function ResPath.GetResSpecialFace(res_id)
	return "uis/icons/special", tostring(res_id)
end

-- 获取进阶装备格子图标
function ResPath.GetAdvanceEquipIcon(res_id)
	return "uis/views/advanceview/images_atlas", res_id
end

-- 获取进阶装备格子图标(Main用)
function ResPath.GetAdvanceEquipIconByMain(res_id)
	return "uis/views/main/images_atlas", res_id
end
-- （无）
function ResPath.GetDpsIcon()
	return "uis/images_atlas", "boss_dps"
end

function ResPath.GetNpcVoiceRes(res_id)
	return "audios/sfxs/npcvoice/" .. res_id, tostring(res_id)
end

function ResPath.GetVoiceRes(res_id)
	return "audios/sfxs/voice/" .. res_id, tostring(res_id)
end

function ResPath.GetBGMResPath(res_id)
	return "audios/musics/bgm" .. res_id, "BGM" .. res_id
end

function ResPath.GetClashterritory(res_id)
	return "uis/views/clashterritory/images_atlas", tostring(res_id)
end

function ResPath.GetChargeImage(res_id)
	return "uis/views/firstchargeview/images_atlas", "daily_charge_00" .. res_id
end

function ResPath.GetFirstChargeImage(res_id, pos)
	if pos then
		return "uis/views/firstchargeview/images_atlas", "first_charge_" .. res_id .. pos
	else
		return "uis/views/firstchargeview/images_atlas", "first_charge_" .. res_id
	end
end

-- 获取经验、阶段副本背景图
function ResPath.GetFubenRawImage(small, big)
	return "uis/rawimages/background" .. small, "Background" .. big .. ".png"
end

function ResPath.GetFishingRes(res_name)
	return "uis/views/fishing/images_atlas", res_name
end

-- 获取经验、阶段副本背景图
function ResPath.GetStoryFubenRawImage(res_id)
	return "uis/rawimages/storyimage" .. res_id, "storyimage" .. res_id .. ".png"
end

function ResPath.GetRawImage(res_name)
	local bundle_name = string.lower(res_name)
	bundle_name = string.gsub(bundle_name, ".jpg", "")
	bundle_name = string.gsub(bundle_name, ".png", "")
	return "uis/rawimages/" .. bundle_name, res_name
end

function ResPath.GetChatRes(res_id)
	return "uis/views/chatview/images_atlas", tostring(res_id)
end

function ResPath.GetHaloSpirit(index)
	return "uis/views/marriageview/images_atlas", (26296 + index) .. ""
end

function ResPath.GetGoldHuntModelAnim(gather_index)
	return "uis/views/goldhuntview_prefab", "Anim" .. gather_index
end

function ResPath.GetGoldHuntModelHeadImg(name)
	return "uis/views/goldhuntview/images_atlas", name
end

function ResPath.GetMarryImage(res_id)
	return "uis/views/marriageview/images_atlas", res_id
end

function ResPath.GetMarryImageBg(res_id)
	return "uis/rawimages/"..res_id, res_id .. ".png"
end

function ResPath.GetMedalSuitIcon(index)
	return "uis/views/baoju/images_atlas", "Suit" .. index
end

function ResPath.GetBossItemIcon(index)
	return "uis/views/bossview/images_atlas", "boss_item_" .. index
end

function ResPath.GetStrengthenStarIcon(index)
	return "uis/images_atlas", "star" .. index
end

function ResPath.GetRisingStarIcon(index)
	return "uis/views/risingstarview/images_atlas", "star" .. index
end

function ResPath.GetSpiritImage(res_id)
	return "uis/views/spiritview/images_atlas", res_id
end

--得到标签底
function ResPath.GetQualityTagBg(color_name)
	return "uis/images_atlas","tag_"..color_name
end
--（无）
function ResPath.GetStrengthenMoonIcon(index)
	return "uis/images_atlas", "moon" .. index
end

function ResPath.GetBuffSmallIcon(client_type)
	return "uis/icons/buff_atlas", "buff_" .. client_type
end

--获取活动大图标
function ResPath.GetActivityBigIcon(act_id)
	return "uis/rawimages/activitybigicon_" .. act_id, "ActivityBigIcon_" .. act_id .. ".jpg"
end

--获取开服活动
function ResPath.GetOpenGameActivityRes(res_name)
	return "uis/views/kaifuactivity/images_atlas", res_name
end

--获取中秋活动
function ResPath.GetOpenFestivalActivityRes(res_name)
	return "uis/views/festivalactivity/image/autumnimage_atlas", res_name
end

--获取助力升星
function ResPath.GetRisingStarActivityRes(res_name)
	return "uis/views/main/images_atlas", res_name
end

--获得活动预告背景图
function ResPath.GetActivityPreviewBg(act_id)
	return "uis/views/main/images_atlas", "ActivityPreviewBg_" .. act_id
end

--获得匠心月饼类型
function ResPath.GetMoonCakeTypeImage(str_type, item_id)
	return "uis/views/festivalactivity/image/".. str_type .."image_atlas", "moon_image" .. item_id
end

--获得匠心月饼名字
function ResPath.GetMoonCakeTypeName(str_type, item_id)
	return "uis/views/festivalactivity/image/".. str_type .."image_atlas", "moon_name_" .. item_id
end

--获取活动预告活动名
function ResPath.GetActivityPreviewTitle(act_id)
	return "uis/views/main/images_atlas", "ActivityPreviewTitle_" .. act_id
end

function ResPath.GetGuajiTaIcon()
	return "uis/views/guajitaview/images_atlas", "Icon_Rune_Tower_Top"
end

function ResPath.GetXingZuoYiJiIcon()
	return "uis/views/shengeview/images_atlas", "Icon_XingZuo_YiJi"
end

function ResPath.GetTowerMojieIcon(id)
	return "uis/icons/towermojie_atlas", "mojie_icon_"..id
end

function ResPath.GetTowerMojieName(id)
	return "uis/views/fubenview/images_atlas", "mojie_name_"..id
end

--获取活动底图
function ResPath.GetActivityBg(act_id)
	return "uis/rawimages/activitybg_" .. act_id, "ActivityBg_" .. act_id .. ".jpg"
end

--获取卡牌图标
function ResPath.GetCardRes(res_name)
	return "uis/views/cardview/images_atlas", res_name
end

--获取卡牌底图
function ResPath.GetCardBg(id)
	return "uis/rawimages/cardbg" .. id, "CardBg" .. id .. ".jpg"
end

--获取Boss卡牌图标
function ResPath.GetBossCardRes(res_name)
	return "uis/views/illustratedhandbook/images_atlas", res_name
end

--获取Boss图鉴底图
function ResPath.GetBossCardBg(id)
	return "uis/rawimages/bosscardbg" .. id, "BossCardBg" .. id .. ".jpg"
end

--获取进阶奖励图标
function ResPath.GetJinJieBg(id)
	return "uis/views/jinjiereward/images_atlas", "Image_" .. id
end

--零元礼包
function ResPath.GetZeroGiftBg(req)
	req = req == 0 and "" or req
	return "uis/rawimages/zero_gift_word" .. req, "zero_gift_word" .. req .. ".png"
end
--（无）
function ResPath.GetGetChatLableIcon(color_name)
	return "uis/images_atlas", "label_08_" .. color_name
end

function ResPath.GetBossHp(index)
	return "uis/views/main/images_atlas", "progress_14_" .. index
end

function ResPath.GetBossDarkHp(index)
	return "uis/views/main/images_atlas", "progress_dark_14_" .. index
end

--（无）
function ResPath.GetHelperIcon(res)
	return "uis/icons/helper", "Helper_" .. res
end

--（无）
function ResPath.GetHelpIcon(res)
	return "uis/icons/helper", res
end

function ResPath.GetActiveDegreeIcon(icon_name)
	return "uis/views/baoju/images_atlas", icon_name
end

function ResPath.GetMedalIcon(medal_id)
	return "uis/views/baoju/images_atlas", "Medal_Icon" .. medal_id
end

function ResPath.GetHelper(res_str)
	return "uis/views/helperview/images_atlas", res_str
end

function ResPath.GetAchieveIcon(client_type)
	return "uis/views/baoju/images_atlas", "AchieveItem_Icon" .. client_type
end

--循环进阶活动标题
function ResPath.GetDegreeTitle(activity_type)
	return "uis/views/degreerewardsview/image_atlas", "jinjie_"..activity_type
end

function ResPath.GetDegreeLeftText(activity_type)
	return "uis/views/degreerewardsview/image_atlas", "left_text"..activity_type
end

--循环进阶活动按钮名称
function ResPath.GetDegreeName(activity_type)
	return "uis/views/main/images_atlas", "degree_name_"..activity_type
end

-- 角色小头像 1男 0女
function ResPath.GetRoleHeadSmall(res_id, sex)
	sex = sex or 1
	return "uis/icons/portrait_atlas", res_id .. sex
end

-- 技能图标
function ResPath.GetRoleSkillIcon(res_id)
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	return "uis/icons/skill/roleprof_" .. prof .. "skill_atlas", "Skill_" .. res_id
end

-- 技能图标
function ResPath.GetRoleSkillIconTwo(res_id)
	return "uis/icons/skill/rolepassiveskill_atlas", "Skill_" .. res_id
end

-- 技能图标
function ResPath.GetRoleSkillIconThree(res_id)
	return "uis/icons/skill/huobanskill_atlas", "Skill_" .. res_id
end

-- 技能图标
function ResPath.GetRoleChangeSkillIcon(res_id)
	return "uis/icons/skill/changeskill_atlas", "Skill_" .. res_id
end

-- 怪物小头像
function ResPath.GetBossIcon(res_id)
	return "uis/icons/boss_atlas", "Boss_" .. res_id
end

function ResPath.GetlingxingBossIcon(res_id)
	return "uis/icons/lxboss_atlas", "Boss_" .. res_id
end

-- NPC 小头像
function ResPath.GetNpcHeadSmall(res_id)
	return "uis/icons/npc_atlas", "Npc_Icon_" .. res_id
end

-- NPC 对话头像
function ResPath.GetNpcHeadBig(res_id)
	return "uis/icons/npc_atlas", "Npc_" .. res_id
end

-- 表情图片
function ResPath.GetEmoji(res_id)
	return "uis/icons/emoji_atlas", tostring(res_id)
end

-- 兑换货币(同1)
function ResPath.GetExchangeIcon(res_id)
	return "uis/icons/coin_atlas", "Coin_" .. res_id
end
--(同1)
function ResPath.GetExchangeNewIcon(res)
	return "uis/icons/coin_atlas", "Coin_" .. res
end

-- 累计充值箱子图标
function ResPath.GetLeiJiRechargeBoxIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "open_box" .. res
end

-- 累计充值奖励图片
function ResPath.GetLeiJiRechargeIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "reward_text_" .. res
end

-- 根据职业获取累计充值奖励图片
function ResPath.GetLeiJiNewRechargeIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "recharge_text_" .. res
end

-- 累积充值奖励展示图片
function ResPath.GetLeiJiRechargeImage(res)
	return "uis/views/leijirechargeview/images_atlas", "leiji_recharge" .. res
end

-- 对应的罗马数字图片
function ResPath.GetRomeNumImage(res)
	return "uis/images_atlas", "rome_num_" .. res
end

-- 组队副本对应的罗马数字图片
function ResPath.GetTeamRomeNumImage(res)
	return "uis/images_atlas", "rome_num_" .. res
end

--(无)
function ResPath.GetProgress(name)
	return "uis/progress", name
end

function ResPath.GetStarsIcon(res_id)
	return "uis/images_atlas","Star0" .. res_id
end

function ResPath.GetXingXiangIcon(res_id)
	return "uis/icons/xingmai_atlas","XingZuo_4020" .. (res_id + 25)
end

-- 货币信息
function ResPath.GetCurrencyID(currency_name)
	return ResPath.CurrencyToIconId[currency_name]
end

function ResPath.GetCurrencyIcon(currency_name)
	return ResPath.GetItemIcon(ResPath.CurrencyToIconId[currency_name])
end

-- 货币信息--旧的
-- function ResPath.GetCurrencyIcon(res_id)
-- 	return "uis/icons/currency", "Currency_"..tostring(res_id)
-- end
--(同3)
function ResPath.GetItemIcon(res_id)
	local bundle_id = math.floor(res_id / 1000)

	-- 这些物品id段是策划一直会加的物品，因此细分到100
	if bundle_id == 27
		or bundle_id == 26
		or bundle_id == 23
		or bundle_id == 22 then

		bundle_id = math.floor(res_id / 100)
		return "uis/icons/item/" .. bundle_id .. "00_atlas", "Item_" .. res_id
	else
		return "uis/icons/item/" .. bundle_id .. "000_atlas", "Item_" .. res_id
	end
end


function ResPath.GetQualityIcon(id)
	return "uis/images_atlas", QUALITY_ICON[id]
end

function ResPath.GetRoleEquipQualityIcon(id)
	return "uis/images_atlas", ROLE_EQUIP_QUALITY_ICON[id]
end

function ResPath.GetEquipStarQualityIcon(id)
	return "uis/images_atlas", EQUIP_STAR_QUALITY_ICON[id]
end

function ResPath.GetRoleEquipDefualtIcon(res_id)
	return "uis/views/player/images_atlas", tostring(res_id)
end

function ResPath.GetEquipShadowDefualtIcon(res_id)
	return "uis/icons/equipshadow_atlas", tostring(res_id)
end

--（同6）
function ResPath.GetQualityBgIcon(res_id)
	return "uis/images_atlas", "QualityBG_0" .. res_id
end

function ResPath.GetQualityLineBgIcon(res_id)
	return "uis/images_atlas", "QualityLine_0" .. res_id
end

-- 送花信息
function ResPath.GetFlowerItemIcon(res_id)
	return ResPath.GetItemIcon(res_id)
end

--获取坐骑阶数品质背景(同2)
function ResPath.GetMountGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end
--(同2)
function ResPath.GetWingGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--(同2)
function ResPath.GetFootGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--(同2)
function ResPath.GetHaloGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--(同2)
function ResPath.GetShengongGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--(同2)
function ResPath.GetShenyiGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--(同2)
function ResPath.GetSpiritFazhenGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--(同2)
function ResPath.GetSpiritHaloGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

--获取坐骑幻化形象图标(无)
function ResPath.GetMountImage(id)
	return "uis/icons/huanhua", "Mount_" .. id
end

--获取羽翼幻化形象图标(无)
function ResPath.GetWingImage(id)
	return "uis/icons/huanhua", "Wing_" .. id
end

--获取神弓幻化形象图标(无)
function ResPath.GetShengongImage(id)
	return "uis/icons/huanhua", "Shengong_" .. id
end

--获取神翼幻化形象图标(无)
function ResPath.GetShenyiImage(id)
	return "uis/icons/huanhua", "Image_" .. id
end

function ResPath.GetHaloSkillIcon(res_id)
	return "uis/icons/skill/haloskill_atlas", "HaloSkill_" .. res_id
end

function ResPath.GetShengongSkillIcon(res_id)
	return "uis/icons/skill/shengongskill_atlas", "ShengongSkill_" .. res_id
end

function ResPath.GetShenShouSkillIcon(res_id)
	return "uis/views/shenshouview/images_atlas", "Skill_SS_" .. res_id
end

function ResPath.GetShenyiSkillIcon(res_id)
	return "uis/icons/skill/shenyiskill_atlas", "ShenyiSkill_" .. res_id
end

--神兵技能图标
function ResPath.GetShenBingSkillIcon(res_id)
	return "uis/icons/skill/shenbingskill_atlas", "ShenbingSkill_" .. res_id
end

-- 坐骑技能图标
function ResPath.GetMountSkillIcon(res_id)
	return "uis/icons/skill/mountskill_atlas", "MountSkill_" .. res_id
end

-- 宝具技能图标
function ResPath.GetBaoJuSkillIcon(res_id)
	return "uis/icons/skill/baojuskill_atlas", "BaoJuSkill_" .. res_id
end

-- 公会技能图标
function ResPath.GetGuildSkillIcon(res_id)
	return "uis/icons/skill/guildskill_atlas", "GuildSkill_" .. res_id
end

-- 披风技能图标
function ResPath.GetCloakSkillIcon(res_id)
	return "uis/icons/skill/pifengskill_atlas", "PiFengSkill_" .. res_id
end

function ResPath.GetImgFuLingTypeIcon(type)
	return "uis/views/imagefuling/images_atlas", "fuling_type_icon" .. type
end

function ResPath.ImgFuLingTypeRawImage(fl_type)
	return "uis/rawimages/fuling_bg_type" .. fl_type, "fuling_bg_type" .. fl_type .. ".png"
end

function ResPath.ImgFuLingSkillIcon(fl_type)
	return "uis/icons/skill/fulingskill_atlas", "FuLingSkill_" .. fl_type
end

function ResPath.GetFamousTalentTypeIcon(fl_type)
	return "uis/icons/generalskillicon_atlas", "famous_type_icon" .. fl_type
end

--获取仙女图标
function ResPath.GetGoddessIcon(res_id)
	return "uis/icons/goddess_atlas", "Goddess_" .. res_id
end

--得到排名图标
function ResPath.GetRankIcon(rank)
	return "uis/views/rank/images_atlas", "rank_" .. rank
end

--得到排名图标（新）
function ResPath.GetRankNewIcon(rank)
	return "uis/icons/rank_atlas", "rank_" .. rank
end

--得到竞技场排名图标
function ResPath.GetArenaRankIcon(rank)
	return "uis/views/arena/images_atlas", "rank_" .. rank
end

--得到排行榜图标
function ResPath.GetRankImage(res_id)
	return "uis/views/rank/images_atlas", tostring(res_id)
end

--排行榜对应text
function ResPath.GetRankText(str)
	return "uis/views/rank/images_atlas", "rank_" ..str.. "_text"
end

--得到跨服1v1段位图标
function ResPath.Get1v1RankIcon(rank)
	return "uis/views/kuafu1v1/images_atlas", "Rank_0" .. rank
end

--得到跨服1v1段位图标
function ResPath.GetKuaFu1v1Image(image_name)
	return "uis/views/kuafu1v1/images_atlas", image_name
end

-- 钻石，绑钻图标
function ResPath.GetDiamonIcon(res_id)
	local name = "diamon"
	if res_id == 3 then
		name = "bind_diamon"
	end
	return "uis/images_atlas", name
end

function ResPath.GetWingQualityBgIcon(res_id)
	return "uis/icons/quality", "Wing_Quality0" .. res_id
end

function ResPath.GetWingNameImg(res_id)
	return "uis/icons/wingname", "WingName_" .. res_id
end

function ResPath.GetWingSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "WingSkill_" .. res_id
end

function ResPath.GetFootSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "FootSkill_" .. res_id
end

function ResPath.GetStarIcon(res_id)
	return "uis/images_atlas", "Star0" .. res_id
end

function ResPath.GetSystemIcon(res_id)
	return "uis/views/main/images_atlas", "Icon_System_" .. res_id
end

function ResPath.GetOtherSkill(res_id)
	return "uis/icons/skill/otherskill_atlas", "Skill_" .. res_id
end

function ResPath.GetEffectBoss(res_id)
	return "effects2/prefab/boss_prefab", tostring(res_id)
end

function ResPath.GetEffect(res_id)
	return "effects2/prefabs", tostring(res_id)
end

function ResPath.GetEffectMiJi(res_id)
	return "effects2/prefab/ui_x/".. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetShenXiaoStarEfect(res_id)
	return "effects2/prefab/ui/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetMiscEffect(res_id)
	if res_id == "Buff_nvshenzhufu" then
		print_error("buff_nvshenzhufu!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
	return "effects2/prefab/misc/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end
function ResPath.GetBuffEffect(res_id)
	return "effects2/prefab/buff_prefab", tostring(res_id)
end

-- 生肖装备特效
function ResPath.GetShengXiaoEquipEffect(color)
	return "effects2/prefab/ui/" .. string.lower("UI_xingzuo_0" .. color) .. "_prefab" , "UI_xingzuo_0" .. color
end

-- 获取格子特效
function ResPath.GetItemEffect(res_id) 	--策划改的写死了特效
	return "effects2/prefab/ui_x/ui_wp_prefab", "UI_wp"
end

-- 获取运营活动格子特效
function ResPath.GetItemActivityEffect()
	return "effects2/prefab/ui_x/ui_wp_prefab", "UI_wp"
end

function ResPath.GetForgeItemName(res_id)
	return "uis/views/forgeview/images_atlas", "name_" .. res_id
end

function ResPath.GetForgeImg(res_id)
	return "uis/views/forgeview/images_atlas", tostring(res_id)
end

function ResPath.GetShenGeImg(res_id)
	return "uis/views/shengeview/images_atlas", tostring(res_id)
end

function ResPath.GetHunQiImg(res_id)
	return "uis/views/hunqiview/images_atlas", tostring(res_id)
end

function ResPath.GetHunQiIconImg(res_id)
	return "uis/icons/hunqi_atlas", tostring(res_id)
end

--index从0开始，color从1开始
function ResPath.GetHunYinIcon(index, color)
	return "uis/views/hunqiview/images_atlas", "hunyin_" .. index .. "_" .. color
end

function ResPath.GetShengXiaoIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "shengxiao_" .. res_id
end

function ResPath.GetShengXiaoNameIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "name_" .. res_id
end

function ResPath.GetShengXiaoBigIcon(res_id)
	return "uis/rawimages/big_shengxiao_" .. res_id, "big_shengxiao_" .. res_id .. ".png"
end

function ResPath.GetShengXiaoBigIcon2(res_id)
	return "uis/views/shengeview/images_atlas", "big_shengxiao_1_" .. res_id .. ".png"
end

function ResPath.GetShengXiaoStarSoul(res_id)
	return "uis/rawimages/star_soul_" .. res_id, "star_soul_" .. res_id .. ".png"
end

function ResPath.GetShengXiaoSkillIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "shengxiao_skill_" .. res_id
end

function ResPath.GetXingHunIcon(res_id)
	return "uis/rawimages/xinghun_" .. res_id, "xinghun_" .. res_id .. ".png"
end

function ResPath.GetShengXiaoWiget(res_id)
	return "uis/views/shengxiaoview_prefab", res_id
end

function ResPath.GetUITipsEffect(res_id)
	return "effects2/prefabs", "ui_tips_kuantexiao_0" .. res_id
end

function ResPath.GetSelectObjEffect(res_id)
	return "effects2/prefab/misc/" .. "xuan_0" .. res_id .. "_prefab", "xuan_0" .. res_id
end

function ResPath.GetSelectObjEffect2(res_id)
	return "effects2/prefabs", "XZ_" .. res_id
end

function ResPath.GetSelectObjEffect3(res_id)
	return "effects2/prefab/misc/" .. "xz_" .. res_id .. "_prefab", "XZ_" .. res_id
end

function ResPath.GetTaskNpcEffect(index)
	return "effects2/prefabs", "task_effect_" .. index
end

function ResPath.GetQianWenEffect(color)
	return "effects2/prefab/ui_x/" .. string.lower("UI_qianwen_0" .. color .. "_prefab"), "UI_qianwen_0" .. color
end

function ResPath.GetForgeEquipBgEffect(color)
	if color == 1 then
		color = "l"
	elseif color == 2 then
		color = "b"
	elseif color == 3 then
		color = "z"
	elseif color == 4 then
		color = "y"
	elseif color == 5 then
		color = "r"
	end
	return "effects2/prefabs", "UI_ZBqianghua_" .. color
end

function ResPath.GetZhenfaEffect(asset)
	return "effects2/prefab/ui_x/" .. string.lower(asset) .. "_prefab", asset
end

function ResPath.GetForgeEquipGlowEffect(color)
	if color == 1 then
		color = "l"
	elseif color == 2 then
		color = "b"
	elseif color == 3 then
		color = "z"
	elseif color == 4 then
		color = "y"
	elseif color == 5 then
		color = "r"
	end
	return "effects2/prefabs", "UI_ZBqianghua_" .. color .. "_glow"
end

function ResPath.GetImages(res_str)
	return "uis/images_atlas", res_str
end


--(无)
function ResPath.GetStarImages(res_str)
	return "uis/images_atlas", res_str
end

function ResPath.GetZheKou(res_id)
	return "uis/images_atlas", "zhekou_" .. res_id
end

function ResPath.GetErnieImage(res_id)
	return "uis/views/ernieview/images_atlas", "Icon_" .. res_id
end

function ResPath.GetAuraImage(res_id)
	return "uis/views/aurasearchview/images_atlas","aura_"..res_id
end

function ResPath.GetVipIcon(res_str)
	return "uis/views/vipview/images_atlas", res_str
end

function ResPath.GetDanFanHaoLiIconByVip(seq)
	if seq == 0 then
		return "uis/views/vipview/images_atlas", "Diamond3"
	elseif seq == 1 then
		return "uis/views/vipview/images_atlas", "Diamond5"
	elseif seq == 2 then
		return "uis/views/vipview/images_atlas", "Diamond6"
	elseif seq == 3 then
		return "uis/views/vipview/images_atlas", "Diamond7"
	elseif seq == 4 then
		return "uis/views/vipview/images_atlas", "Diamond8"
	end
	return nil
end


function ResPath.GetMainUI(name)
	return "uis/views/main/images_atlas", name
end

function ResPath.GetMainUITaskType(task_type)
	local res_name = "task_type_0"
	if task_type and task_type > 0 then
		res_name = "task_type_1"
	end
	return "uis/views/main/images_atlas", res_name
end

function ResPath.GetMainUITaskButton(name)
	return "uis/views/main/images_atlas", "btn_"..name
end
function ResPath.GetPlayerImage(name)
	return "uis/views/player/images_atlas", name
end

function ResPath.GetPlayerPanel(name)
	return "uis/views/playerpanel/images_atlas", name
end

function ResPath.GetFriendPanelIcon(res_id)
	return "uis/views/friendpanel/images_atlas", tostring(res_id)
end

function ResPath.GetJuBaoPenIcon(res_id)
	return "uis/views/jubaopen/images_atlas", tostring(res_id)
end

function ResPath.GetExpenseNiceGiftIcon(res_id)
	return "uis/views/festivalactivity/image/autumnimage_atlas", "expense_nice_gift_" .. tostring(res_id)
end

function ResPath.GetKaiFuExpanseNiceGiftIcon(res_id)
   return "uis/views/kaifuactivity/images_atlas", "expense_nice_gift_" .. tostring(res_id)
end

-- 公会宝箱图片
function ResPath.GetGuildBoxIcon(res_id, state)
	if state then
		return "uis/rawimages/box_1".. res_id, "Box_1" .. res_id .. ".png"
	else
		return "uis/rawimages/box_0".. res_id, "Box_0" .. res_id .. ".png"
	end
end

function ResPath.GetXiuLuoFBBoxIcon(res_id)
	return "uis/rawimages/box_0".. res_id, "Box_0" .. res_id  .. ".png"
end

function ResPath.GetGuildImg(name)
	return "uis/views/guildview/images_atlas", name
end

function ResPath.GetNpcPic(res_id)
	return "uis/icons/npc", "Npc_" .. res_id
end

function ResPath.GetHunQiKaPaiImg(index,res_id)
	return "uis/icons/hunqikapai/kapai" .. tostring(index) .. "_atlas", tostring(res_id)
end

function ResPath.GetSpiritSoulEffect(name)
	return "effects2/prefabs", name
end

function ResPath.GetWelfareRes(res_id)
	return "uis/views/welfare/images_atlas", tostring(res_id)
end

-- 精灵阵法组合评分图标
function ResPath.GetSpiritScoreIcon(res_id)
	return "uis/views/spiritview/images_atlas", "Score" .. res_id
end

-- 精灵阵法组合评分图标
function ResPath.GetSpiritIcon(name)
	return "uis/views/spiritview/images_atlas", name
end

-- 仙宠技能图标
function ResPath.GetSpiritSkillIcon(name)
	return "uis/icons/spiritskillicon_atlas", name
end

function ResPath.GetRightBubbleIcon(res_id)
	return "uis/chatres/bubbleres/bubble" .. res_id .. "_atlas", "bubble_" .. res_id .. "_right"
end

function ResPath.GetRightHeadFrameIcon(res_id)
	-- tag
	return "uis/chatres/bubbleres/bubble" .. res_id .. "_atlas", "bubble_" .. res_id .. "_right"
end

function ResPath.GetBubblePrefab(res_name, bubble_type)
	return string.format("uis/chatres/bubbleres/bubble%s_prefab", bubble_type), res_name .. bubble_type
end

function ResPath.CrossFBIcon(res_id)
	return "uis/rawimages/kuafufuben_" .. res_id, "kuafufuben_" .. res_id .. ".jpg"
end

function ResPath.GetActivtyIcon(res_id)
	return "uis/images_atlas", "Icon_Activity_" .. res_id
end

function ResPath.GetGuildActivtyBg(res_id)
	return "uis/rawimages/guild_activity_bg_" .. res_id, "guild_activity_bg_" .. res_id .. ".png"
end

function ResPath.GetGuildBadgeIcon()
	return "uis/views/guildview/images_atlas", "guild_badge"
end

function ResPath.GetTerritoryBg(res_id)
	return "uis/rawimages/background0" .. res_id, "Background0" .. res_id .. ".jpg"
end
--(同3)
function ResPath.GetTitleIcon(res_id)
	if res_id == nil then
		return nil, nil
	end

	local bundle_id = math.floor(res_id/1000)
	return "uis/icons/title/"..bundle_id.."000_atlas", "Title_" .. res_id
end

function ResPath.GetSkillGoalsIcon(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "uis/icons/skill/goalsskill_atlas", "Goals_" .. res_id
end

function ResPath.GetChapterIcon(index)
	index = index + 1
	return "uis/views/lianhun/images/word_atlas", "word_" .. index
end
---------------------------------------------------------
-- model
---------------------------------------------------------
function ResPath.GetRoleModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/role/" .. math.floor(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetShenQiWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/weapon/" .. res_id .. "_prefab", tostring(res_id)
end

function ResPath.GetMonsterModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/monster/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetTriggerModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/trigger/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetFallItemModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/fallitem/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetDoorModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/npc/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetGatherModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/gather/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetNpcModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/npc/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/weapon/" .. math.floor(res_id / 100) .. "_prefab", tostring(res_id)
end

function ResPath.GetWeaponModel_1(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/weapon/" .. res_id .. "_prefab", tostring(res_id)
end

function ResPath.GetWingModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/wing/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetFootModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	if type(res_id) == "number" then
		res_id = tonumber(res_id)
		return "effects2/prefab/footprint_prefab", "Foot_" .. string.format("%02d", res_id)
	else
		return "effects2/prefab/footprint_prefab",res_id
	end
end

function ResPath.GetPifengModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	return "actors/pifeng/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetMountModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/mount/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end
--(同4)
function ResPath.GetGoddessModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/goddess/" .. res_id .. "_prefab", tostring(res_id)
end
--(同4)
function ResPath.GetGoddessNotLModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/goddess/" .. res_id .. "_prefab", tostring(res_id)
end
--(同5)
function ResPath.GetHunQiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/hunqi/" .. res_id .. "_prefab", tostring(res_id)
end
--(同5)
function ResPath.GetBoxModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/hunqi/17012_prefab", tostring(res_id)
end

function ResPath.GetWaBaoBoxModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/gather/6039_prefab", tostring(res_id)
end

function ResPath.GetHaloModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	local asset = "Halo_"
	if res_id >= 10 then
		asset = asset .. res_id
	else
		asset = asset .. "0" .. res_id
	end
	return "effects2/prefab/halo_prefab", asset
end

function ResPath.GetStarEffect(res_id)
	local asset = "star_" .. res_id
	return "effects2/prefabs", asset
end

function ResPath.GetTitleModel(res_id)
	if res_id == nil then
		return nil, nil
	end
	return "effects2/prefab/title_prefab", "Title_" .. res_id
end
--(无)
function ResPath.GetStoryFbDoorModel()
	return "effects2/prefabs", "csm"
end

function ResPath.GetSpiritModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/spirit/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetWuXinZhiLingModel(res_id)
	return "actors/wuxingzhiling/" .. res_id ..  "_prefab", tostring(res_id)
end

function ResPath.GetGoddessWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	res_id = tonumber(res_id)
	return "effects2/prefab/huobanhalo_prefab", "HuobanHalo_" .. string.format("%02d", res_id)
end

-- 累计充值名字资源名字
function ResPath.GetLeiJiRechargeDisName(res)
	return "uis/views/leijirechargeview/images_atlas", "show_name_" .. res
end

-- 获取化神元素球
function ResPath.GetHuashenBallModle()
	return "uis/views/advanceview/images_atlas", "BallModles"
end

-- 获取战斗坐骑
function ResPath.GetFightMountModel(res_id)
	return "actors/fightmount/"..tostring(math.floor(res_id / 1000)) .. "_prefab", tostring(res_id)
end

function ResPath.GetGoddessWingModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	res_id = tonumber(res_id)
	return "effects2/prefab/huobanfazhen_prefab", "huobanfz_" .. string.format("%02d", res_id)
end

function ResPath.GetBaoJuModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/baoju/" .. res_id .. "_prefab", tostring(res_id)
end
--根据ID获取模型的预制体以及特效
function ResPath.GetHighBaoJuModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/baoju/" .. res_id .. "_prefab", res_id .. "_L"

end

function ResPath.GetMedalModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	return "actors/medal/" .. res_id .. "_prefab", tostring(res_id)
end

function ResPath.GetForgeEquipModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/forge/" .. res_id .. "_prefab", tostring(res_id)
end

function ResPath.GetQiZhiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/qizhi/" .. res_id .. "_prefab", tostring(res_id)
end

function ResPath.GetPetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/pet/" .. res_id .. "_prefab", res_id .. "001"
end

--头饰
function ResPath.GetTouShiModel(res_id)
	return "actors/headband/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--腰饰
function ResPath.GetWaistModel(res_id)
	return "actors/belt/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--获取小宠物
function ResPath.GetLittlePetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/pet/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

--麒麟臂
function ResPath.GetQilinBiModel(res_id, sex)
	if sex == 1 then
		return "actors/arm/man/" .. math.floor(res_id / 1000) .. "_prefab", res_id
	else
		return "actors/arm/woman/" .. math.floor(res_id / 1000) .. "_prefab", res_id
	end
end

--面饰
function ResPath.GetMaskModel(res_id)
	return "actors/mask/" .. res_id .. "_prefab", res_id
end

--灵珠
function ResPath.GetLingZhuModel(res_id, is_high)
	local param = "_CJ"
	if is_high then
		param = "_UI"
	end
	return "effects2/prefab/lingzhu_prefab", "Lingzhu_" .. res_id .. param
end

--仙宝
function ResPath.GetXianBaoModel(res_id)
	return "actors/lingbao/" .. res_id .. "_prefab", tostring(res_id)
end

function ResPath.GetLingChongModelEffect(res_id)
	return "actors/lingchong/" .. math.floor(res_id / 1000) .. "_prefab", res_id .. "_UIeffect"
end

--灵宠
function ResPath.GetLingChongModel(res_id)
	return "actors/lingchong/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

--灵弓
function ResPath.GetLingGongModel(res_id)
	return "actors/linggong/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

--灵骑
function ResPath.GetLingQiModel(res_id)
	return "actors/mount/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

--尾焰
function ResPath.GetWeiYanModel(res_id)
	return "effects2/prefab/actor/mount_prefab", tostring(res_id)
end

function ResPath.GetA2ChatLableIcon(color_name)
	return "uis/views/main/images_atlas", "label_a2_" .. color_name
end

function ResPath.GetBaseAttrIcon(attr_type)
	local asset, name = "", ""
	if attr_type == Language.Common.AttrNameNoUnderline.hp or attr_type == "maxhp" or attr_type == "max_hp" or attr_type == 33 then
		asset = "uis/images_atlas"
		name = "icon_info_hp"
	elseif attr_type == Language.Common.AttrNameNoUnderline.maxhp then
		asset = "uis/images_atlas"
		name = "icon_info_hp"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_maxhp then
		asset = "uis/images_atlas"
		name = "icon_info_hp"
	elseif attr_type == Language.Common.AttrNameNoUnderline.gongji or attr_type == 35 then
		asset = "uis/images_atlas"
		name = "icon_info_gj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.attack then
		asset = "uis/images_atlas"
		name = "icon_info_gj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_gongji or attr_type == "gongji" or attr_type == "gong_ji" then
		asset = "uis/images_atlas"
		name = "icon_info_gj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.fangyu or attr_type == "fangyu" or attr_type == "fang_yu" or attr_type == 36 then
		asset = "uis/images_atlas"
		name = "icon_info_fy"
	elseif attr_type == Language.Common.AttrNameNoUnderline.mingzhong or attr_type == "mingzhong" or attr_type == "ming_zhong" or attr_type == 37 then
		asset = "uis/images_atlas"
		name = "icon_info_mz"
	elseif attr_type == Language.Common.AttrNameNoUnderline.shanbi or attr_type == "shanbi" or attr_type == "shan_bi" or attr_type == 38 then
		asset = "uis/images_atlas"
		name = "icon_info_sb"
	elseif attr_type == Language.Common.AttrNameNoUnderline.baoji or attr_type == "baoji" or attr_type == "bao_ji" or attr_type == 39 then
		asset = "uis/images_atlas"
		name = "icon_info_bj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_baoji then
		asset = "uis/images_atlas"
		name = "icon_info_bj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_jingzhun then
		asset = "uis/images_atlas"
		name = "icon_info_bj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.jianren or attr_type == "jianren" or attr_type == "jian_ren" or attr_type == 40 then
		asset = "uis/images_atlas"
		name = "icon_info_kb"
	elseif attr_type == Language.Common.AttrNameNoUnderline.movespeed or attr_type == "movespeed" then
		asset = "uis/images_atlas"
		name = "icon_info_sudu"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_pofang or attr_type == "constant_zengshang" then
		asset = "uis/images_atlas"
		name = "icon_info_shjc"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_mianshang or attr_type == "constant_mianshang" then
		asset = "uis/images_atlas"
		name = "icon_info_shjm"
	elseif attr_type == Language.Common.AttrNameNoUnderline.huixinyiji then
		asset = "uis/images_atlas"
		name = "icon_info_huixinyiji"
	elseif attr_type == Language.Common.AttrNameNoUnderline.huixinyiji_hurt then
		asset = "uis/images_atlas"
		name = "icon_info_huixinyiji_hurt"
	elseif attr_type == "lucky" then
		asset = "uis/images_atlas"
		name = "icon_info_luck"
	elseif attr_type == "exp" then
		asset = "uis/images_atlas"
		name = "icon_info_exp"
	end
	return asset, name
end

function ResPath.GetRuneIconResPath(attr_name)
	local asset, bundle = "", ""
	if attr_name == Language.Rune.AttrNameIndex.gongji then
		asset = "uis/images_atlas"
		bundle = "icon_info_gj"
	elseif attr_name == Language.Rune.AttrNameIndex.hp then
		asset = "uis/images_atlas"
		bundle = "icon_info_hp"
	elseif attr_name == Language.Rune.AttrNameIndex.baoji then
		asset = "uis/images_atlas"
		bundle = "icon_info_bj"
	elseif attr_name == Language.Rune.AttrNameIndex.shanbi then
		asset = "uis/images_atlas"
		bundle = "icon_info_sb"
	elseif attr_name == Language.Rune.AttrNameIndex.exp then
		asset = "uis/images_atlas"
		bundle = "icon_info_hp"
	elseif attr_name == Language.Rune.AttrNameIndex.mingzhong then
		asset = "uis/images_atlas"
		bundle = "icon_info_mz"
	elseif attr_name == Language.Rune.AttrNameIndex.kangbao then
		asset = "uis/images_atlas"
		bundle = "icon_info_kb"
	elseif attr_name == Language.Rune.AttrNameIndex.fangyu then
		asset = "uis/images_atlas"
		bundle = "icon_info_fy"
	elseif attr_name == Language.Rune.AttrNameIndex.weapon_gongji then
		asset = "uis/images_atlas"
		bundle = "icon_info_gj"
	elseif attr_name == Language.Rune.AttrNameIndex.weapon_hp then
		asset = "uis/images_atlas"
		bundle = "icon_info_hp"
	elseif attr_name == Language.Rune.AttrNameIndex.armor_shanbi then
		asset = "uis/images_atlas"
		bundle = "icon_info_sb"
	elseif attr_name == Language.Rune.AttrNameIndex.armor_fangyu then
		asset = "uis/images_atlas"
		bundle = "icon_info_fy"
	elseif attr_name == Language.Rune.AttrNameIndex.armor_kangbao then
		asset = "uis/images_atlas"
		bundle = "icon_info_kb"
	end
	return asset, bundle
end

--获取多种模型Asset
function ResPath.GetModelAsset(model_type, res_id)
	local asset, name = nil, nil
	if model_type == "ring" then
		asset, name = ResPath.GetForgeEquipModel("000" .. res_id)
	elseif model_type == "goddess" then
		asset, name = ResPath.GetGoddessModel(res_id)
	elseif model_type == "spirit" then
		asset, name = ResPath.GetSpiritModel(res_id)
	end
	return asset, name
end

function ResPath.GetZhiBaoHuanHuaHead(res_id)
	return "uis/views/baoju/images_atlas", "zhibao_head_" .. res_id
end

function ResPath.GetBoss(res_name)
	return "uis/rawimages/" .. res_name, res_name .. ".png"
end

function ResPath.GetSevenDayGift(res_name)
	return "uis/views/7logingift/images_atlas", res_name
end

function ResPath.GetYewaiGuajiMap(res_name)
	return "uis/rawimages/map" .. res_name, "Map"..res_name .. ".jpg"
end

function ResPath.GetWeaponShowModel(res_id, asset)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/weapon/" .. (asset or res_id) .. "_prefab", tostring(res_id)
end

-- 宝宝头像
function  ResPath.GetBabyIcon(res_id)
	return "uis/views/marriageview/images_atlas" ,res_id
end

function ResPath.GetVipLevelIcon(vip_level)
	return "uis/views/vipview/images_atlas", "vip_level_" .. vip_level
end

function ResPath.GetMiscPreloadVipLevelIcon(vip_level)
	return "uis/views/miscpreload/images_atlas", "vip_level_" .. vip_level
end

function ResPath.GetCompetitionActivity(res_name)
	return "uis/views/competitionactivityview/images_atlas", res_name
end

-- 比拼图标（主界面使用）
function ResPath.GetCompetitionActivityByMain(res_name)
	return "uis/views/main/images_atlas", res_name
end

function ResPath.GetRisingStarActivity(res_name)
	return "uis/views/risingstarview/images_atlas", res_name
end

function ResPath.GetRuneRes(res_id)
	return "uis/views/rune/images_atlas", tostring(res_id)
end

function ResPath.GetRandomActRes(res_name)
	return "uis/views/randomact/images_atlas", res_name
end

function ResPath.GetLuckychessActRes(res_name)
	return "uis/views/randomact/luckychess/images_atlas", res_name
end

function ResPath.GetJumpIcon(act_sep)
	if act_sep == 1 then
		return "uis/views/main/images_atlas", "Icon_Activity_5"
	elseif
		act_sep == 2 then
		return "uis/views/main/images_atlas", "Icon_Activity_21"
	elseif
		act_sep == 3 then
		return "uis/views/main/images_atlas", "Icon_Activity_6"
	elseif
		act_sep == 4 then
		return "uis/views/main/images_atlas", "Icon_Activity_19"
	elseif
		act_sep == 5 then
		return "uis/views/main/images_atlas", "Icon_System_Target"
	else
		return nil, nil
	end
end

-- 跨服挖矿矿石图标
function ResPath.GetKFMiningRes(res_id)
	return "uis/views/kuafumining/images_atlas", "mining_icon_" .. res_id
end

-- 跨服挖矿稀有度
function ResPath.GetKFMiningRarity(res_id)
	return "uis/views/kuafumining/images_atlas", "rarity_" .. res_id
end

-- 跨服挖矿排名Icon
function ResPath.GetKFMiningRankIcon(res_id)
	return "uis/views/kuafumining/images_atlas", "rank_" .. res_id
end


function ResPath.GetWeaponEffect(res_id)
	return "effects2/prefabs_weapon", math.floor(res_id / 100000) .."_04"
end

function ResPath.GetWaBaoPic(scene_id)
	if scene_id == 103 then
		return "uis/rawimages/wabao_bg1", "wabao_bg1.png"
	elseif scene_id == 104 then
		return "uis/rawimages/wabao_bg2", "wabao_bg2.png"
	elseif scene_id == 105 then
		return "uis/rawimages/wabao_bg3", "wabao_bg3.png"
	end
	return nil, nil
end

function ResPath.GetHunQiSkillRes(res_id)
	return "uis/icons/skill/hunqiskill_atlas", "HunQiSkill_" .. res_id
end

function ResPath.GetLianhunRes(res_id)
	return "uis/views/lianhun/images_atlas", res_id
end

function ResPath.GetHeFuCityRes(res_id)
	return "uis/views/hefucitycombatview/images_atlas", res_id
end

function ResPath.GetLianhunEquipRes(res_id)
	return "uis/views/lianhun/images/equip_atlas", res_id
end

function ResPath.GetTianshenhutiRes(res_id)
	return "uis/views/tianshenhutiview/images_atlas", res_id
end

function ResPath.GetTianshenhutiEquipRes(res_id)
	return "uis/views/tianshenhutiview/images/equip_atlas", res_id
end
--(无)
function ResPath.GetFishModelRes(res_id,name)
	return tostring(res_id), tostring(name)
end

function  ResPath.GetIconLock()
	return "uis/views/spiritview/images_atlas","icon_lock"
end

function ResPath.GetGoddessRes(res_str)
	return "uis/views/goddess/images_atlas", res_str
end

function ResPath.GetMiningRes(res_str)
	return "uis/views/mining/images_atlas", res_str
end
--(无)
function ResPath.GetXingLingRes(res_id)
	return "effects2/prefabs", "big_xingling_" .. res_id
end

function ResPath.GetShenXiaoRes(res_id)
	return "uis/rawimages/shengxiao_" .. res_id, "shengxiao_" .. res_id ..".png"
end

function ResPath.GetAuraSearchRes(res_str)
	return "uis/views/aurasearchview/images_atlas", res_str
end

function ResPath.GetZhangkongStarRes(res_id)
	if res_id < 10 then
		return "uis/images_atlas", "Star00" .. res_id
	elseif res_id == 10 then
		return "uis/images_atlas", "Star0" .. res_id
	end
end

function ResPath.GetXingLingEffect(color)
	if color == 1 then
		color = "lvse"
	elseif color == 2 then
		color = "lanse"
	elseif color == 3 then
		color = "zise"
	elseif color == 4 then
		color = "huangse"
	elseif color == 5 then
		color = "hongse"
	end
	return "effects2/prefab/ui/" .. "ui_xingling_" .. color .. "_prefab", "UI_xingling_" .. color
end

function ResPath.GetRuiShouImage(color)
	return "uis/views/shengeview/images_atlas", "Item_" .. color
end
function ResPath.GetGoPawnImg(res_str)
	return "uis/views/gopawnview/images_atlas", res_str
end

function ResPath.GetBiPingImg(res_str)
	return "uis/views/tips/bipingtips_atlas", res_str
end


--tips
function ResPath.GetFocusBossImage(type,id)
	if type == 0 then
		return "uis/views/tips/focustips/images_atlas","bg_"..id
	elseif type == 1 then
		return "uis/views/tips/focustips/images_atlas","title_"..id
	end
end

function ResPath.GetFunTraierImg(res_str)
	return "uis/views/tips/funtrailer/label_atlas", res_str
end
--（同6）
function ResPath.GetTipsImageByIndex(index)
	return "uis/images_atlas","QualityBG_0"..index
end

function ResPath.GetMapImg(res_id)
	return "uis/views/map/images_atlas", "map_"..res_id
end

function ResPath.GetMapFindImg(res_id)
	return "uis/views/mapfind/images_atlas", "map_"..res_id
end

function ResPath.GetHaloEffect(res_id)
	return "effects2/prefab/halo_01_prefab", "FQGH_0" .. res_id
end

function ResPath.GetKuafuGuildBattle(res_id)
	return "uis/views/escortview/images_atlas", res_id
end

-- 情缘圣地背景图
function ResPath.GetShengDiRawImage(res_id)
	return "uis/rawimages/shengdi_bg_" .. res_id, "shengdi_bg_" .. res_id .. ".png"
end

--（同6）
-- 神兽获取图标
function ResPath.GetQualityBgIcon1(res_id)
	return "uis/images_atlas", "QualityBG_" .. res_id
end

function ResPath.GetWingMaterial(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/wing/" .. math.floor(res_id / 1000) .. "_prefab", "Occlusion_" .. tostring(res_id)
end

function ResPath.GetMainRandomActRes(res_id)
	return "uis/views/main/images/randactivityimage_atlas", res_id
end

function ResPath.GetFbViewImage(res_id)
	return "uis/views/fubenview/images_atlas", res_id
end

function ResPath.GetLongxingLevelIcon(level)
	return "uis/icons/longxing_atlas", "longxing_" .. level
end

function ResPath.GetFollowLongxingLevelIcon(level)
	return "uis/icons/longxing_atlas", "longxing_" .. level
end

function ResPath.GetGoldHuntModelAnim(gather_index)
	return "uis/views/goldhuntview_prefab", "Anim" .. gather_index
end

function ResPath.GetTeamFBRawImage(index)
	return "uis/rawimages/team_fb_" .. index, "Team_FB_" .. index .. ".png"
end

local switch_shen_ge_bg =
{
	[1] = "image_01_yellow",
	[4] = "image_bg_01",
	[3] = "image_bg_02",
	[2] = "image_bg_03",
}
function ResPath.GetShenGeBg(index)
	return "uis/views/shengeview/images_atlas", switch_shen_ge_bg[index]
end

function ResPath.GetShenGeAdvance(index)
	return "uis/views/shengeview/images_atlas", "icon_0" .. index
end

function ResPath.GetFilePath2(role_id)
	return string.format("%s/rawimg/%s",
		UnityEngine.Application.persistentDataPath, role_id)
end

function ResPath.GetLeiJIGodImage(num)
	return "uis/views/leijirechargeview/images_atlas", "god_image_" .. num
end

function ResPath.GetGeneralRes(res_id)
	return "actors/mingjiang/" .. res_id .. "_prefab", res_id
end

function ResPath.GetHeadModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return string.format("actors/head/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetTouZiImage(res_id)
    return "uis/images_atlas", "touzi_text_" .. res_id
end

function ResPath.GetScratchTicketRes(res_name)
	return "uis/views/scratchticket/image_atlas", res_name
end

function ResPath.GetHeadFrameIcon(res_id)
	if res_id == nil or res_id == -1 then
		return nil, nil
	end
	return "uis/icons/headframe_atlas", "head_frame_" .. res_id
end

function ResPath.GetMidAutumnRankIcon(index)
	if index < 1 or index > 3 then
		return nil, nil
	end
	return "uis/views/festivalactivity/image/autumnimage_atlas", "rank_"..index
end

function ResPath.GetFestivalImage(str_type, str)
	if str == "" or str == nil then
		return nil, nil
	end
	return "uis/views/festivalactivity/image/" .. str_type .. "_atlas", str
end

function ResPath.GetFestivalImageInMain(str_type, str)
	if str == "" or str == nil then
		return nil, nil
	end
	return "uis/views/main/images_atlas", str_type .. str
end

function ResPath.GetLoginRewardTypeName(item_id)
	return "uis/views/festivalactivity/image/nationalimage_atlas", "login_text_" .. item_id
end

function ResPath.GetShenYinIcon(res_id)
	return "uis/views/shenyinview/images_atlas", "mark_pos" .. res_id
end

function ResPath.GetShenYin(res_id)
	return "uis/rawimages/"..res_id, res_id..".png"
end

function ResPath.GetTianXiangPieceIcon(res_id)
	return "uis/views/shenyinview/images_atlas", "piece_" .. res_id
end

function ResPath.GetTianShenSkill(res_id)
	return "uis/icons/skill/zhoumoskill_atlas", "skill_" .. res_id
end

function ResPath.GetTianShenSkillName(res_id)
	return "uis/icons/skill/zhoumoskill_atlas", "skill_name_" .. res_id
end

function ResPath.GetTimeLimitTitleResPath(res_id)
	return "uis/views/tips/timelimittitletips/images_atlas", tostring(res_id)
end

function ResPath.GetGodTempleShenQiModel(res_id)
	res_id = res_id or 0
	return "actors/shenbing/" .. res_id .. "_prefab", tostring(res_id)
end