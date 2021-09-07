ResPath = ResPath or {}

local _sformat = string.format

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
	["rune_suipian"] = 90120,	--符文碎片
	["magic_crystal"] = 90013,	--符文水晶
	["huoyue"] = 90014,         --活跃度
	["rune_jinghua"] = 90121,	--符文精华
	--下面的还没有道具id
	["yuanli"] = 65534,
	["xianhun"] = 65534,
	["gongxian"] = 65534,
	["nvwashi"] = 65534,
	["guild_gongxian"] = 90009,  -- 公会贡献
	["jifen"] = 90012, 			 -- 日常积分
	["kuafu_jifen"] = 90017, 	 -- 跨服积分
	["jungong"] = 90005,		 -- 军工
}

function ResPath.GetLoginRes(res_name)
	return "uis/views/login/images_atlas", res_name
end

function ResPath.GetLoginPackRes(res_name)
	return "uis/views/login/images/nopack_atlas", res_name
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
	return "uis/guideres_atlas", tostring(res_id)
end

function ResPath.GetSexRes(sex)
	local asset = sex == 0 and "icon_1004" or "icon_1003"
	return "uis/images_atlas", asset
end

function ResPath.GetMiscPreloadRes(res_id)
	return "uis/views/miscpreload_prefab", tostring(res_id)
end

-----------------------表情目录--------------------------
--表情资源路径(小)
function ResPath.GetResFaceSmall(res_id)
	return "uis/views/main", tostring(res_id)
end

--表情资源路径(大)
function ResPath.GetResFaceBig(res_id)
	return "uis/views/chatview_prefab", tostring(res_id)
end

--大表情资源路径
function ResPath.GetResBigFace(res_id)
	return "uis/icons/bigface_prefab", tostring(res_id)
end

--大表情资源路径Index
function ResPath.GetResBigFaceByIndex(index, res_id)
	local new_index = 100 + index
	return "uis/icons/bigface/face_" .. new_index .. "_prefab", tostring(res_id)
end

--普通动态标签资源路径
function ResPath.GetResNormalFace(res_id)
	return "uis/icons/normalface_prefab", tostring(res_id)
end

--普通动态标签资源路径ByIndex
function ResPath.GetResNormalFaceByIndex(index, res_id)
	return "uis/icons/normalface/" .. index .. "_prefab", tostring(res_id)
end

--特殊表情资源路径
function ResPath.GetResSpecialFace(res_id)
	return "uis/icons/special", tostring(res_id)
end

-- 获取进阶装备格子图标
function ResPath.GetAdvanceEquipIcon(res_id)
	return "uis/views/advanceview/images_atlas", res_id
end

function ResPath.GetDpsIcon()
	return "uis/images_atlas", "boss_dps"
end

-- 获取家族徽章默认图片
function ResPath.GetGuildBadgeIcon(index)
	return "uis/views/guildview/images/nopack_atlas", "guild_badge".. index
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

-- 获取经验、阶段副本背景图
function ResPath.GetFubenRawImage(small, big)
	return "uis/rawimages/background" .. small, "Background" .. big .. ".png"
end

-- 获取经验、阶段副本背景图
function ResPath.GetStoryFubenRawImage(res_id)
	return "uis/rawimages/storyimage" .. res_id, "storyimage" .. res_id .. ".png"
end

function ResPath.GetRawImage(res_name, is_jpg)
	local lower_res_name = string.lower(res_name)
	return "uis/rawimages/" .. lower_res_name, res_name .. (is_jpg and ".jpg" or ".png")
end

function ResPath.GetHaloSpirit(index)
	return "uis/views/marriageview/images_atlas", (26296 + index) .. ""
end

function ResPath.GetChatRes(res_id)
	return "uis/views/chatview/images_atlas", tostring(res_id)
end

function ResPath.GetMarryImage(res_id)
	return "uis/views/marriageview/images_atlas", res_id
end

-- 获取本国地图王城普通图片
function ResPath.GetCountryCityImage(res_id)
	return "uis/views/map/images/nopack_atlas", "city_" .. res_id
end

-- 获取本国地图王城高光图片
function ResPath.GetCountryCityHighImage(res_id)
	return "uis/views/map/images/nopack_atlas", "city_" .. res_id .. "_high"
end

-- 获取世界地图地图名字图片
function ResPath.GetWorldMapNameImage(res_id)
	return "uis/views/map/images_atlas", "world_name_" .. res_id
end

function ResPath.GetMedalSuitIcon(index)
	return "uis/views/baoju/images_atlas", "Suit" .. index
end

function ResPath.GetStrengthenStarIcon(index)
	return "uis/images_atlas", "star" .. index
end
--得到标签底
function ResPath.GetQualityTagBg(color_name)
	-- body
	return "uis/images_atlas","tag_"..color_name
end

function ResPath.GetStrengthenMoonIcon(index)
	return "uis/images_atlas", "moon" .. index
end

function ResPath.GetBuffSmallIcon(client_type)
	return "uis/icons/buff_atlas", "buff_" .. client_type
end

--获取活动大图标
function ResPath.GetActivityBigIcon(act_id)
	return "uis/icons/activity_atlas", "ActivityBigIcon_" .. act_id
end

function ResPath.GetGuajiTaIcon()
	return "uis/views/guajitaview/images_atlas", "Icon_Rune_Tower_Top"
end

function ResPath.GetXingZuoYiJiIcon()
	return "uis/views/shengeview/images_atlas", "Icon_XingZuo_YiJi"
end

--获取活动底图
function ResPath.GetActivityBg(act_id)
	return "uis/rawimages/activitybg_" .. act_id, "ActivityBg_" .. act_id .. ".jpg"
end

--零元礼包
function ResPath.GetZeroGiftBg(req)
	req = req == 0 and "" or req
	return "uis/rawimages/zero_gift_word" .. req, "zero_gift_word" .. req .. ".png"
end

function ResPath.GetGetChatLableIcon(color_name)
	return "uis/images_atlas", "label_08_" .. color_name
end

function ResPath.GetBossHp(index)
	return "uis/views/main/images_atlas", "progress_14_" .. index
end

function ResPath.GetHelperIcon(res)
	return "uis/icons/helper_atlas", res
end

-- 获取神器icon
function ResPath.GetShenqiIcon(res)
	return "uis/views/shenqiview/images_atlas", res
end

-- 获取地脉Buff
function ResPath.GetDiMaiBuffIcon(res_id)
	return "uis/views/dimaiview/images_atlas", "dimai_buff_" .. res_id
end

function ResPath.GetDiMaiTipsBuffIcon(res_id)
	return "uis/views/tips/dimaitips/images_atlas", "dimai_buff_" .. res_id
end

-- 获取地脉国家Buff
function ResPath.GetDiMaiCampBuffIcon()
	return "uis/views/dimaiview/images_atlas", "dimai_camp_buff"
end

-- 获得地脉层背景
function ResPath.GetDiMaiLayerBg(res_id)
	return "uis/rawimages/dimai_layer_" .. res_id, "dimai_layer_" .. res_id .. ".png"
end

-- 获得地脉挑战地脉背景
function ResPath.GetDiMaiChallengeBg(layer, point)
	return "uis/rawimages/layer_" .. layer .. "_" .. point, "layer_" .. layer .."_" .. point .. ".png"
end

function ResPath.GetActiveDegreeIcon(icon_name)
	return "uis/views/baoju/images_atlas", icon_name
end

function ResPath.GetBaojuImage(name_id)
	return "uis/views/baoju/images_atlas", name_id
end

function ResPath.GetMidAutImage(name_id)
	return "uis/views/qixiactivityview/images_atlas", name_id
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

-- 角色小头像 1男 0女
function ResPath.GetRoleHeadSmall(res_id, sex)
	sex = sex or 1
	return "uis/icons/portrait_atlas", res_id .. sex
end


-- 技能图标
function ResPath.GetRoleSkillIcon(res_id)
	return "uis/icons/skill_atlas", "Skill_" .. res_id
end

-- 技能名字
function ResPath.GetRoleSkillName(res_id)
	return "uis/views/roleskill/images_atlas", "skillname_" .. res_id 
end

-- 世界地图地点名字
function ResPath.GetMapName(res_id)
	return "uis/views/map/images_atlas","placename_0" .. res_id
end

-- 怪物小头像
function ResPath.GetBossIcon(res_id)
	return "uis/icons/boss_atlas", "Boss_" .. res_id
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

-- 兑换货币
function ResPath.GetExchangeIcon(res_id)
	return "uis/icons/coin_atlas", "Coin_" .. res_id
end

function ResPath.GetExchangeNewIcon(res)
	return "uis/icons/coin_atlas", "Coin_" .. res
end

-- 累计充值箱子图标
function ResPath.GetLeiJiRechargeBoxIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "open_box" .. res
end

-- 累计充值奖励图片
function ResPath.GetLeiJiRechargeIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "recharge_text" .. res
end

-- 邮件读取图标
function ResPath.GetMaillScoietyIcon(res)
	return "uis/views/scoietyview/images_atlas", "mail_" .. res
end

-- 根据职业获取累计充值奖励图片
function ResPath.GetLeiJiNewRechargeIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "recharge_text_" .. res
end

-- 累积充值奖励展示图片
function ResPath.GetLeiJiRechargeImage(res)
	return "uis/views/leijirechargeview/images_atlas", "leiji_recharge" .. res
end

-- 获取国家Title(国家战事)
function ResPath.GetCampIcon(res)
	return "uis/views/nationalwarfareview/images_atlas", "camp" .. res
end

-- 对应的罗马数字图片
function ResPath.GetRomeNumImage(res)
	return "uis/images_atlas", "rome_num_" .. res
end

-- 开服充值资源
function ResPath.GetKaiFuChargeImage(res)
	return "uis/views/kaifuchargeview/images_atlas", tostring(res)
end

-- 比拼类型图片
function ResPath.GetBiPinTypeImage(res)
	return "uis/views/kaifuchargeview/images_atlas", "binpin_type" .. res
end

-- 比拼类型名字图片
function ResPath.GetBiPinTypeNameImage(res)
	return "uis/views/kaifuchargeview/images_atlas", "binpin_text_type" .. res
end

-- 升星类型名字图片
function ResPath.GetRisingTypeNameImage(res)
	return "uis/views/kaifuchargeview/images_atlas", "font_theme_" .. res
end

-- 三星送礼Item背景图
function ResPath.GetSanXinSongLiLiemBg(res)
	return "uis/views/kaifuchargeview/images_atlas", "item_bg_0" .. res
end

-- 三星送礼描述功能类型
function ResPath.GetSanXingSongLiGiftType(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "type_" .. res_id
end

-- 三星送礼描述礼包类型
function ResPath.GetSanXingSongLiDesType(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "gift_type_" .. res_id
end

-- 个人抢购背景图片
function ResPath.GetPersonalBuyBg(res_id)
	return "uis/views/kaifuchargeview/images/nopack_atlas", "itemcell_bg_" .. res_id
end

-- 个人抢购标题背景图片
function ResPath.GetPersonalBuyTitleBg(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "itemcell_title_bg_" .. res_id
end

-- 个人抢购礼包背景图片
function ResPath.GetPersonalBuyItemBaseBg(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "itembase_bg_" .. res_id
end

-- 个人抢购原价背景图片
function ResPath.GetPersonalBuyOriginalPriceBg(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "original_price_bg_" .. res_id
end

-- 个人抢购特价背景图片
function ResPath.GetPersonalBuySalePriceBg(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "saleprice_bg_" .. res_id
end

-- 等级投资类型
function ResPath.GetLevelTouziType(res_id)
	return "uis/views/kaifuchargeview/images_atlas", "touzhi_" .. res_id
end

function ResPath.GetProgress(name)
	return "uis/progress", name
end

function ResPath.GetStarsIcon(res_id)
	return "uis/images_atlas","Star0" .. res_id
end
function ResPath.GetXingXiangIcon(res_id)
	return "uis/icons/xingmai","XingZuo_4020" .. (res_id + 25)
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

function ResPath.GetItemIcon(res_id)
	local bundle_id = math.floor(res_id/1000)
	return "uis/icons/item/"..bundle_id.."000_atlas", "Item_" .. res_id
end

function ResPath.GetQualityIcon(id)
	return "uis/images_atlas", QUALITY_ICON[id]
end

function ResPath.GetQualityBgIcon(res_id)
	return "uis/images_atlas", "QualityBG_0" .. res_id
end

function ResPath.GetQualityLineBgIcon(res_id)
	return "uis/views/tips/equiptips/images/nopack_atlas", "QualityLine_0" .. res_id
end

-- 送花信息
function ResPath.GetFlowerItemIcon(res_id)
	return ResPath.GetItemIcon(res_id)
end

--获取坐骑阶数品质背景
function ResPath.GetMountGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetWingGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetHaloGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetShengongGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetShenyiGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetSpiritFazhenGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetSpiritHaloGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetBabyGradeQualityBG(id)
	return "uis/views/baby/images_atlas", MOUNT_QUALITY_ICON[id]
end

--获取坐骑幻化形象图标
function ResPath.GetMountImage(id)
	return "uis/icons/huanhua", "Mount_" .. id
end

--获取羽翼幻化形象图标
function ResPath.GetWingImage(id)
	return "uis/icons/huanhua", "Wing_" .. id
end

--获取神弓幻化形象图标
function ResPath.GetShengongImage(id)
	return "uis/icons/huanhua", "Shengong_" .. id
end

--获取神翼幻化形象图标
function ResPath.GetShenyiImage(id)
	return "uis/icons/huanhua", "Image_" .. id
end

function ResPath.GetHaloSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "HaloSkill_" .. res_id
end

function ResPath.GetShengongSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "ShengongSkill_" .. res_id
end

function ResPath.GetShenyiSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "ShenyiSkill_" .. res_id
end

--神兵技能图标
function ResPath.GetShenBingSkillIcon(res_id)
	return "uis/icons/skill_atlas", "ShenbingSkill_" .. res_id
end

-- 坐骑技能图标
function ResPath.GetMountSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "MountSkill_" .. res_id
end

-- 宝具技能图标
function ResPath.GetBaoJuSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "BaoJuSkill_" .. res_id
end

-- 美人光环技能图标
function ResPath.GetBeautyHaloSkillIcon(res_id)
	return "uis/views/advanceview/images_atlas", "BeautyHaloSkill_" .. res_id
end

-- 战斗坐骑技能图标
function ResPath.GetFightMountSkillIcon(res_id)
	return "uis/icons/skill_atlas", "FightMountSkill_" .. res_id
end

-- 公会技能图标
function ResPath.GetGuildSkillIcon(res_id)
	return "uis/icons/skill_atlas", "GuildSkill_" .. res_id
end

--获取仙女图标
function ResPath.GetGoddessIcon(res_id)
	return "uis/icons/goddess", "Goddess_" .. res_id
end

--得到排名图标
function ResPath.GetRankIcon(rank)
	return "uis/images_atlas", "rank_" .. rank
end

--得到跨服1v1段位图标
function ResPath.Get1v1RankIcon(rank)
	local str = rank < 10 and "Rank_0" or "Rank_"
	return "uis/views/kuafu1v1/images_atlas", str .. rank
end

-- 钻石，绑钻图标
function ResPath.GetDiamonIcon(res_id)
	return "uis/images_atlas", "Icon_Diamon0" .. res_id
end

-- 元宝，绑元图标
function ResPath.GetYuanBaoIcon(res_id)
	return "uis/images_atlas", "icon_gold_100" .. res_id
end

-- 1000钻石，1001绑钻图标
function ResPath.GetGoldIcon(res_id)
	return "uis/images_atlas", "icon_gold_" .. res_id
end

function ResPath.GetWingQualityBgIcon(res_id)
	return "uis/icons/quality", "Wing_Quality0" .. res_id
end

function ResPath.GetWingNameImg(res_id)
	return "uis/icons/wingname", "WingName_" .. res_id
end

function ResPath.GetWingSkillIcon(res_id)
	return "uis/icons/skill_atlas", "WingSkill_" .. res_id
end

function ResPath.GetFootEffec(res_id)
	return "effects2/prefab/footprint_prefab", res_id
end

-- function ResPath.GetUiEffect(res_name)
-- 	return "effects2/prefab/ui_prefab", res_name
-- end

function ResPath.GetUiEffect(res_name)
	return "effects2/prefab/ui/" .. string.lower(res_name) .. "_prefab", res_name
end

function ResPath.GetStarIcon(res_id)
	return "uis/images_atlas", "Star0" .. res_id
end

function ResPath.GetCoupleHaloRes(res_id)
	return "effects2/prefab/halo_01_prefab", "FQGH_0" .. res_id
end

function ResPath.GetNewStarIcon(res_id)
	res_id = tonumber(res_id)
	local multiple = math.floor(res_id/5)
	if multiple > 0 and res_id == 5*multiple then
		res_id = 5
	else
		res_id = res_id - 5*multiple
	end
	return "uis/images_atlas", "star_new_0" .. res_id
end

function ResPath.GetSystemIcon(res_id)
    return "uis/views/main/images/button_atlas", "Icon_System_" .. res_id
end

function ResPath.GetEffectBoss(boss_id,res_id)
	return _sformat("effects2/prefab/boss/%s_prefab", tostring(boss_id)), tostring(res_id)
end

function ResPath.GetEffect(res_id)
	return "effects2/prefab/misc/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetBuffEffect(file_str, res_id)
	return _sformat("effects2/prefab/%s", tostring(file_str)), tostring(res_id)
end

function ResPath.GetEffect2(res_id)
	return "effects2/prefab_prefab", tostring(res_id)
end

-- 获取格子特效
function ResPath.GetItemEffect(res_id) 	--策划改的写死了特效
	return "effects2/prefab/misc/ui_wp_prefab", "UI_wp"
end

-- 获取运营活动格子特效
function ResPath.GetItemActivityEffect()
	return "effects2/prefab/misc/ui_wp_prefab", "UI_wp"
end

function ResPath.GetForgeItemName(res_id)
	return "uis/views/forgeview/images_atlas", "name_" .. res_id
end

function ResPath.GetForgeImg(res_name)
	return "uis/views/forgeview/images_atlas", res_name
end

function ResPath.GetShenGeImg(res_id)
	return "uis/views/shengeview/images_atlas", tostring(res_id)
end

function ResPath.GetHunQiImg(res_id)
	return "uis/views/hunqiview/images_atlas", tostring(res_id)
end

function ResPath.GetShengXiaoIcon(res_id)
	return "uis/views/shengeview/images_atlas", "shengxiao_" .. res_id
end

function ResPath.GetShengXiaoBigIcon(res_id)
	return "uis/views/shengeview/images_atlas", "big_shengxiao_" .. res_id
end

function ResPath.GetShengXiaoBigIcon2(res_id)
	return "uis/views/shengeview/images_atlas", "big_shengxiao_1_" .. res_id
end

function ResPath.GetShengXiaoSkillIcon(res_id)
	return "uis/views/shengeview/images_atlas", "shengxiao_skill_" .. res_id
end

function ResPath.GetPieceIcon(res_id)
	return "uis/views/shengeview/images_atlas", "piece_" .. res_id
end

function ResPath.GetXingHunIcon(res_id)
	return "uis/views/shengeview/images_atlas", "xinghun_" .. res_id
end

function ResPath.GetShengXiaoWiget(res_id)
	return "uis/views/shengeview_prefab", res_id
end

-- 获取经验、阶段副本背景图
function ResPath.GetBossView(head_id)
	return "uis/rawimages/boss_item_" .. head_id, "boss_item_" .. head_id .. ".png"
end

-- 获取VIP相关Tip的描述图片
function ResPath.GetVipLoadImage(res_id)
	return "uis/views/tips/lockviptips/images_atlas",  "Des_" .. res_id
end

function ResPath.GetUITipsEffect(res_id)
	local eff_name = "ui_tips_kuantexiao_0" .. res_id
	return "effects2/prefab/ui/" .. string.lower(eff_name) .. "_prefab", eff_name
end

function ResPath.GetSelectObjEffect(res_id)
	local eff_name = "xuan_0" .. res_id
	return "effects2/prefab/misc/" .. string.lower(eff_name) .. "_prefab", eff_name
end

function ResPath.GetSelectObjEffect2(res_id)
	local eff_name = "XZ_" .. res_id
	return "effects2/prefab/misc/" .. string.lower(eff_name) .. "_prefab", eff_name
end

function ResPath.GetTaskNpcEffect(index)
	local eff_name = "task_effect_" .. index
	return "effects2/prefab/ui/" .. string.lower(eff_name) .. "_prefab", eff_name
end

function ResPath.GetImages(res_str)
	return "uis/images_atlas", res_str
end

function ResPath.GetErnieImage(res_id)
	return "uis/views/ernieview_atlas", "Icon_" .. res_id
end

function ResPath.GetVipIcon(res_str)
	return "uis/views/vipview/images_atlas", res_str
end

function ResPath.GetRechargeVipIcon(res_str)
	return "uis/views/recharge/images_atlas", res_str
end

function ResPath.GetVipShowImage(res_id)
	return "uis/rawimages/vip_" .. res_id, "vip_" .. res_id .. ".png"
end

function ResPath.GetRechargeIcon(res_str)
	return "uis/views/recharge/images_atlas", res_str
end

function ResPath.GetBuffIcon(res_id)
	return "uis/icons/buff_atlas", "Buff_00"..res_id
end

function ResPath.GetMainUI(name)
	return "uis/views/main/images_atlas", name
end

function ResPath.GetMainUIButton(name)
    return "uis/views/main/images/button_atlas", name
end

function ResPath.GetPlayerPanel(name)
	return "uis/views/playerpanel/images_atlas", name
end

function ResPath.GetPlayerImage(name)
	return "uis/views/player/images_atlas", name
end

function ResPath.GetPlayerIcon(name)
	return "uis/views/player/images/icon_atlas", name
end


function ResPath.GetRedEquipImage(name)
	return "uis/views/redequipview/images_atlas", name
end

function ResPath.GetRebirthEquipImage(name)
	return "uis/views/rebirthview/images_atlas", name
end

function ResPath.GetFriendPanelIcon(res_id)
	return "uis/views/friendpanel_images", tostring(res_id)
end

function ResPath.GetCampRes(name)
	return "uis/views/camp/images_atlas", name
end

function ResPath.GetCampRawRes(name)
	return "uis/rawimages/" .. name, name .. ".png"
end

function ResPath.GetMarryRawImage(res_id)
	return "uis/rawimages/marry_body_" .. res_id, "Marry_Body_" .. res_id .. ".png"
end

-- 公会宝箱图片
function ResPath.GetGuildBoxIcon(res_id, state)
	if state then
		return "uis/views/guildview/images_atlas", "Box_1" .. res_id
	else
		return "uis/views/guildview/images_atlas", "Box_0" .. res_id
	end
end

function ResPath.GetGuildRes(res_name)
	return "uis/views/guildview/images_atlas", res_name
end

function ResPath.GetNpcPic(res_id)
	return "uis/icons/npc", "Npc_" .. res_id
end

function ResPath.GetWelfareRes(res_id)
	return "uis/views/welfare/images_atlas", tostring(res_id)
end

-- 精灵阵法组合评分图标
function ResPath.GetSpiritScoreIcon(res_id)
	return "uis/views/spiritview/images_atlas", "Score" .. res_id
end

-- 公会宝箱图片
-- function ResPath.GetGuildBoxIcon(res_id, state)
-- 	if state then
-- 		return "uis/images", "Box_1" .. res_id
-- 	else
-- 		return "uis/images", "Box_0" .. res_id
-- 	end
-- end

function ResPath.GetRightBubbleIcon(res_id)
	return "uis/chatres/bubbleres/" .. "bubble" .. res_id .. "_atlas", "bubble_" .. res_id .. "_right"
end

function ResPath.CrossFBIcon(res_id)
	return "uis/rawimages/kuafufuben_" .. res_id, "kuafufuben_" .. res_id .. ".jpg"
end

function ResPath.GetActivtyIcon(res_id)
	return "uis/images_atlas", "Icon_Activity_" .. res_id
end

function ResPath.GetGuildActivtyBg(res_id)
	return "uis/rawimages/guild_activity_bg_" .. res_id, "guild_activity_bg_" .. res_id .. ".jpg"
end

function ResPath.GetTerritoryBg(res_id)
	return "uis/rawimages/background0" .. res_id, "Background0" .. res_id .. ".jpg"
end

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
	return "uis/icons/skill_atlas", "Goals_" .. res_id
end

function ResPath.GetBabyImage(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "uis/views/baby/images_atlas", res_id
end

--得到跨服1v1段位图标
function ResPath.GetKuaFu1v1Image(image_name)
	return "uis/views/kuafu1v1/images_atlas", image_name
end
---------------------------------------------------------
-- model
---------------------------------------------------------
function ResPath.GetRoleModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

    return _sformat("actors/role/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetMonsterModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

    return _sformat("actors/monster/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetTriggerModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/trigger/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetFallItemModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/fallitem/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetDoorModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/npc/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetGatherModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/gather/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetNpcModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/npc/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/weapon/%s_prefab", math.floor(res_id / 100)), tostring(res_id)
end

function ResPath.GetWingModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/wing/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetPifengModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/pifeng/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetMountModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/mount/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetGoddessModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/goddess/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetItemModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/item/%s_prefab", res_id), tostring(res_id)
end


function ResPath.GetGoddessNotLModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/goddess/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetHunQiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/hunqi/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetBoxModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/hunqi/17008_prefab", tostring(res_id)
end

function ResPath.GetOtherModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/other/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetHaloModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	local asset = "Halo_"
	-- if res_id >= 10 then
		asset = asset .. res_id
	-- else
	-- 	asset = asset .. "0" .. res_id
	-- end
	return "effects2/prefab/halo_prefab", asset
end

function ResPath.GetTitleModel(res_id)
	if res_id == nil then
		return nil, nil
	end
	return "effects2/prefab/title_prefab", "Title_" .. res_id
end

function ResPath.GetSpiritModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/spirit/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end

function ResPath.GetGoddessWingModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/goddesswing/%s_prefab", res_id), tostring(res_id)
end

-- 获取化神元素球
function ResPath.GetHuashenBallModle()
	return "uis/views/advanceview/images_atlas", "BallModles"
end

-- 获取战斗坐骑
function ResPath.GetFightMountModel(res_id)
	return "effects2/prefab/fazhen_prefab", tostring(res_id)
end

function ResPath.GetGoddessWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/goddessweapon/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetBaoJuModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/baoju/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetZuJiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "effects2/prefab/footprint_prefab", "Foot_".. tostring(res_id)
end


function ResPath.GetHighBaoJuModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/baoju/%s_prefab", res_id), res_id .. "_L"
end

function ResPath.GetMedalModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

    return _sformat("actors/medal/%s_prefab", res_id) , tostring(res_id)
end

-- 获取神兵模型
-- function ResPath.GetShenbingModel(res_id)
-- 	if res_id == nil or res_id == 0 then
-- 		return nil, nil
-- 	end
-- 	return "actors/forge/000" .. res_id, "000" .. tostring(res_id)
-- end

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
    return _sformat("actors/qizhi/%s_prefab", res_id), tostring(res_id)
end

function ResPath.GetPetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/pet/%s_prefab", res_id), res_id .. "001"
end

function ResPath.GetBabyModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/baby/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
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
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_gongji or attr_type == "gongji" then
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
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_pofang then
		asset = "uis/images_atlas"
		name = "icon_info_shjc"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_mianshang then
		asset = "uis/images_atlas"
		name = "icon_info_shjm"
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
	elseif model_type == "item" then
		asset, name = ResPath.GetItemModel(res_id)
	end
	return asset, name
end

function ResPath.GetZhiBaoHuanHuaHead(res_id)
	return "uis/views/baoju/images_atlas", "zhibao_head_" .. res_id
end

function ResPath.GetBoss(res_name)
	return "uis/views/bossview/images_atlas", res_name
end

function ResPath.GetTaskBG(res_name)
	return "uis/views/taskview/images_atlas", res_name
end

function ResPath.GetSevenDayGift(res_name)
	return "uis/views/7logingift/images_atlas", res_name
end

function ResPath.GetWeaponShowModel(res_id, asset)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/weapon/%s_prefab", (asset or res_id)), tostring(res_id)
end

function ResPath.GetVipLevelIcon(vip_level)
	return "uis/views/main/images/vip_atlas", "vip_level_" .. vip_level
end

function ResPath.GetCompetitionActivity(res_name)
	return "uis/views/competitionactivityview/images_atlas", res_name
end

function ResPath.GetRuneRes(res_id)
	return "uis/views/rune/images_atlas", tostring(res_id)
end

function ResPath.GetWidgets(res_name)
	return "uis/views/miscpreload_prefab", res_name
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

function ResPath.GetWeaponEffect(res_id)
	return "effects/prefabs_weapon", math.floor(res_id / 100000) .."_04"
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
	return "uis/icons/skill_atlas", "HunQiSkill_" .. res_id
end

function  ResPath.GetIconLock(res_id)
	return "uis/images_atlas", "lock_" .. res_id
end

function ResPath.GetNationalWarfare(res_name)
	return "uis/views/nationalwarfareview/images_atlas", res_name
end

function ResPath.GetNationalWarfareNoPack(res_name)
	return "uis/views/nationalwarfareview/images/nopack_atlas", res_name
end

function ResPath.GetFamousGeneral(res_name)
	return "uis/views/famousgeneralview/images_atlas", res_name
end

function ResPath.GetShengXiaoStarSoul(res_id)
	return "uis/rawimages/general_bone_" .. res_id, "general_bone_" .. res_id .. ".png"
end

function ResPath.GetFishingRes(res_name)
	return "uis/views/fishing/images_atlas", res_name
end

function ResPath.GetBeautyRes(res_name)
	return "uis/views/beauty_prefab", res_name
end

function ResPath.GetBeautyNameRes(res_name)
	return "uis/views/beauty/images_atlas", res_name
end

function ResPath.GetBeautySkillRes(res_name)
	return "uis/views/beauty/images_atlas", res_name
end


function ResPath.GetMingJiangRes(res_name)
    return _sformat("actors/mingjiang/%s_prefab", res_name), res_name
end

function ResPath.GetChatlblIcon(color_name)
	return "uis/views/chatview/images_atlas", "lbl_bg_" .. color_name
end

function ResPath.GetMainlblIcon(color_name)
	return "uis/views/main/images_atlas", "lbl_bg_" .. color_name
end

function ResPath.GetKaiFuActivityRes(res_name)
	return "uis/views/kaifuactivity/images_atlas", res_name
end

function ResPath.GetHappyBargainActivityRes(res_name)
	return "uis/views/happybargainview/images_atlas", res_name
end

function ResPath.GetNvShenHaloModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	-- local asset = "Halo_"
	-- if res_id >= 10 then
		-- asset = asset .. res_id
	-- else
	-- 	asset = asset .. "0" .. res_id
	-- end
	return "effects2/prefab/halo_01_prefab", res_id
end

function ResPath.GetFloatTextRes(res_name)
	return "uis/views/floatingtext_atlas", res_name
end

function ResPath.GetZhangkongStarRes(res_id)
	if res_id < 10 then
		return "uis/views/shengeview/images_atlas", "Star0" .. res_id
	elseif res_id == 10 then
		return "uis/views/shengeview/images_atlas", "Star" .. res_id
	end
end

function ResPath.GetGoddessRes(res_str)
	return "uis/views/goddess/images_atlas", res_str
end

function ResPath.GetAuraImage(res_id)
	return "uis/views/aurasearchview/images_atlas","aura_"..res_id
end

-- 获取神器武器模型
function ResPath.GetShenQiWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/weapon/%s_prefab", math.floor(res_id / 100)), tostring(res_id + 1) -- 策划复用命名规则
end

-- 获取法阵
function ResPath.GetFaZhenModel(res_id)
	if res_id == nil or res_id == 0 then 
		return nil, nil
	end
	return "effects2/prefab/fazhen_prefab", tostring(res_id)
end

function ResPath.GetKFMiningRes(res_id)
	return "uis/views/kuafumining/images_atlas", "mining_icon_" .. res_id
end

function ResPath.GetMilitaryRankImage(res_str)
	return "uis/views/militaryrankview/images_atlas", res_str
end

function ResPath.GetMiningRes(res_str)
	return "uis/views/mining/images_atlas", res_str
end

-- 获取个人塔防美人图片
function ResPath.GetPersonGuard(res_id)
	local images_id = 0
	if res_id <=7 then
		images_id = res_id
	else
		images_id = res_id%7
	end
	return "uis/views/fubenview/images_atlas", "defense_bg_" .. images_id
end

function ResPath.GetFuBenImage(res_name)
	return "uis/views/fubenview/images_atlas", res_name
end

function ResPath.GetRandomActRes(res_name)
	return "uis/views/serveractivity/luckychess/images_atlas", res_name
end

function ResPath.GetImageName(res_id)
	return "uis/views/militaryrankview/images_atlas", "level_name_0" .. res_id
end

function ResPath.GetKuafuGuildBattle(res_id)
	return "uis/views/escortview/images_atlas", res_id
end

function ResPath.GetfuBenIcon(res_id)
	return "uis/views/main/images/button_atlas", res_id
end

function ResPath.GetHaloEffect(res_id)
	return "effects2/prefab/halo_prefab", "FQGH_0" .. res_id
end

function ResPath.GetJuBaoPenIcon(res_id)
	return "uis/views/jubaopen/images_atlas", tostring(res_id)
end

function ResPath.GetHeadModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return _sformat("actors/head/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)	
end

-- 情缘圣地背景图
function ResPath.GetShengDiRawImage(res_id)
	return "uis/rawimages/shengdi_bg_" .. res_id, "shengdi_bg_" .. res_id .. ".png"
end

function ResPath.GetGoldHuntModelImg(name, index)
	return "uis/views/goldhuntview/images/" .. index .. "_atlas", name
end

function ResPath.GetCallImg(res_id)
	return "uis/views/callview/images_atlas", res_id
end

function ResPath.GetImgWorldMap(res_id)
	return "uis/views/map/images/nopack_atlas", "0" .. res_id
end

function ResPath.GetShenQuSlider(res_id)
	return "uis/images_atlas", "progress_100" .. res_id
end

function ResPath.GetReviveview(res_id)
	return "uis/views/reviveview/images_atlas", res_id
end

function ResPath.GetBuffProgress(res_id)
	return "uis/views/buffprogress/images_atlas", res_id
end

function ResPath.GetTouXianImage(res_id)
	return "uis/views/touxianview/images_atlas", res_id
end

function ResPath.GetLianFuDailyImage(res_id)
	return "uis/views/lianfuactivity/lianfudaily/images_atlas", res_id
end

function ResPath.GetKuaFuFlowerRankImage(res_id)
	return "uis/views/kuafuflowerrank/images_atlas", res_id
end

--勋章背景图片
function ResPath.GetHonourRawImage(name_id)
	return "uis/rawimages/" .. name_id, name_id..".png"
end

-- 真言秘宝
function ResPath.GetRareTreasureImage(name_id)
	return "uis/views/serveractivity/raretreasure/images_atlas", name_id
end

function ResPath.GetMuseumCardImage(res_id)
	return "uis/views/museumcardview/images_atlas", res_id
end

-- 获取装扮名字图标
function ResPath.GetDressUpEquipIcon(res_id)
	return "uis/views/dressup/images_atlas", res_id
end

function ResPath.GetHeadwearSkillIcon(res_id)
	return "uis/views/dressup/images_atlas", "HeadwearSkill_" .. res_id
end

function ResPath.GetMaskSkillIcon(res_id)
	return "uis/views/dressup/images_atlas", "MaskSkill_" .. res_id
end

function ResPath.GetWaistSkillIcon(res_id)
	return "uis/views/dressup/images_atlas", "WaistSkill_" .. res_id
end

function ResPath.GetBeadSkillIcon(res_id)
	return "uis/views/dressup/images_atlas", "BeadSkill_" .. res_id
end

function ResPath.GetFaBaoSkillIcon(res_id)
	return "uis/views/dressup/images_atlas", "FaBaoSkill_" .. res_id
end

function ResPath.GetKirinArmSkillIcon(res_id)
	return "uis/views/dressup/images_atlas", "KirinArmSkill_" .. res_id
end

--麒麟臂
function ResPath.GetQilinBiModel(res_id, sex)
	if not res_id or res_id == 0 then
		return nil, nil
	end
	if sex == 1 then
		return "actors/arm/man/" .. math.floor(res_id / 1000) .. "_prefab", res_id
	else
		return "actors/arm/woman/" .. math.floor(res_id / 1000) .. "_prefab", res_id
	end
end

--头饰
function ResPath.GetTouShiModel(res_id)
	if not res_id or res_id == 0 then
		return nil, nil
	end
	return "actors/headband/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--腰饰
function ResPath.GetWaistModel(res_id)
	if not res_id or res_id == 0 then
		return nil, nil
	end
	return "actors/belt/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--面饰
function ResPath.GetMaskModel(res_id)
	if not res_id or res_id == 0 then
		return nil, nil
	end
	return "actors/mask/" .. res_id .. "_prefab", res_id
end

--灵珠
function ResPath.GetLingZhuModel(res_id, is_high)
	if not res_id or res_id == 0 then
		return nil, nil
	end
	local param = "_CJ"
	if is_high then
		param = "_UI"
	end
	return "effects2/prefab/lingzhu_prefab", "Lingzhu_" .. res_id .. param
end

--仙宝
function ResPath.GetXianBaoModel(res_id)
	if not res_id or res_id == 0 then
		return nil, nil
	end
	return "actors/lingbao/" .. res_id .. "_prefab", tostring(res_id)
end

-- 头像框
function ResPath.GetHeadFrameIcon(res_id)
	if res_id == nil or res_id == -1 then
		return nil, nil
	end
	return "uis/icons/headframe_atlas", "head_frame_" .. res_id
end

function ResPath.GetSpecialRebate(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "uis/views/actspecialrebate/images_atlas", res_id
end

--获取小宠物
function ResPath.GetLittlePetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/pet/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetSuperVipImage(res_id)
	return "uis/views/supervip/images_atlas", res_id
end

function ResPath.GetWuXinZhiLingModel(res_id)
	return "actors/wuxingzhiling/" .. res_id ..  "_prefab", tostring(res_id)
end

function ResPath.GetSymbolImage(res_name)
	return "uis/views/symbol/images_atlas", res_name
end
