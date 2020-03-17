--[[
资源管理
lizhuangzhuang
2014年7月31日10:38:44
]]

_G.ResUtil = {};

--获取UI文件的url
function ResUtil:GetUIUrl(name)
	return "resfile/swf/" .. name;
end

--物品Icon
function ResUtil:GetItemIconUrl(iconName, size)
	if not iconName or iconName == "" then return "" end;
	if not size then size = ""; end
	if size ~= "" then
		size = "_" .. size;
	end

	return "img://resfile/itemicon/" .. iconName .. size .. '.png';
end

function ResUtil:GetRelicIconUrl(iconName)
	return "img://resfile/icon/v_neweq/" .. iconName
end

--物品标识
function ResUtil:GetBiaoShiUrl(name, size)
	if not name or name == "" then return "" end;
	if not size then size = ""; end
	if size ~= "" then
		size = "_" .. size;
	end
	return "img://resfile/icon/bag_" .. name .. size .. ".png";
end

;

--物品tips标识  唯一
function ResUtil:GetTipsBiaoShiUrl(name)
	if not name or name == "" then return "" end;
	return "img://resfile/icon/tips_" .. name .. ".png";
end

;

--技能Icon
function ResUtil:GetSkillIconUrl(iconName, size)
	if not size then size = ""; end
	if size ~= "" then
		if size == "54" or size == "64" or size== "70" then
			size = "_" .. size;
		else
			size = "";
		end
	end
	return "img://resfile/skillicon/" .. iconName .. size .. '.png';
end

--技能Icon
function ResUtil:GetSpecialSkillIconUrl(iconName, size)
	if not size then size = ""; end
	if size ~= "" then
		if size ~= "54" then
			size = "";
		else
			size = "_" .. size;
		end
	end
	return "img://resfile/itemicon/" .. iconName .. size .. '.png';
end

-- 获取宝石镶嵌孔位icon
function ResUtil:GetGemIcon(i)
	return "img://resfile/icon/v_zhuangbei/" .. "v_zbw_" .. i .. "_small" .. '.png';
end

--获取技能名Icon
function ResUtil:GetSkillNameIconUrl(iconName)
	return "img://resfile/skillicon/" .. iconName .. '.png';
end

--获取装备位图标
function ResUtil:GetEquipPosUrl(pos, size)
	if size == 64 or size == "64" then
		size = "_64";
	else
		size = "";
	end
	return "img://resfile/icon/zbw_" .. pos .. size .. '.png';
end

--Tips线
function ResUtil:GetTipsLineUrl()
	return "img://resfile/icon/tipsLine.png";
end

--Tips星星
function ResUtil:GetTipsStarUrl()
	return "img://resfile/icon/v_tipsStar.png";
end

--Tips灰色星星
function ResUtil:GetTipsGrayStarUrl()
	return "img://resfile/icon/v_tipsGrayStar.png";
end

--Tips星星
function ResUtil:GetTipsMoonUrl()
	return "img://resfile/icon/v_tipsMoon.png";
end

--Tips灰色星星
function ResUtil:GetTipsGrayMoonUrl()
	return "img://resfile/icon/v_tipsGrayMoon.png";
end

--Tips太阳
function ResUtil:GetTipsSunUrl()
	return "img://resfile/icon/v_tipsSun.png";
end

--Tips灰色太阳
function ResUtil:GetTipsGraySunUrl()
	return "img://resfile/icon/v_tipsGraySun.png";
end

--Tips钻
function ResUtil:GetTipsGemUrl()
	return "img://resfile/icon/tipsGem.png";
end

--Tips灰色钻
function ResUtil:GetTipsGrayGemUrl()
	return "img://resfile/icon/tipsGrayGem.png";
end

--Tips战斗力(大)
function ResUtil:GetTipsZhandouliUrlMax()
	return "img://resfile/icon/v_tipszhandoulimax.png";
end
--Tips战斗力（小）
function ResUtil:GetTipsZhandouliUrlSmall()
	return "img://resfile/icon/v_tipszhandoulimall.png";
end
--Tips基础属性  
function ResUtil:GetTipsBaseScoreliUrl()
	return "img://resfile/icon/baseSocre.png";
end

--tips数字
function ResUtil:GetTipsNum(num)
	return "img://resfile/num/fight_" .. num .. ".png";
end

--新tips数字
function ResUtil:GetNewTipsNum(num)
	return "img://resfile/num/tips_fight_" .. num .. ".png"; --timeExp_0
end

--新小tips数字
function ResUtil:GetNewSmTipsNum(num)
	return "img://resfile/num/tips_fight_" .. num .. ".png";
end

--tips炼化数字
function ResUtil:GetTipsRefinNum(num)
	return "img://resfile/num/tipsrefin_" .. num .. ".png";
end

--tips标记
function ResUtil:GetTipsFlagUrl()
	return "img://resfile/icon/tipsFlag.png";
end

--tips名字背景
function ResUtil:GetTipsNameBgUrl()
	return "img://resfile/icon/tipsNameBg.png";
end

--tips已装备
function ResUtil:GetTipsEquipedUrl()
	return "img://resfile/icon/tipsEquiped.png";
end

--tips宝石
function ResUtil:GetTipsGemIconUrl(name)
	return "img://resfile/icon/" .. name .. ".png";
end

--tips卓越锁定
function ResUtil:GetTipsSuperLockUrl()
	return "img://resfile/icon/tipsSuperLock.png";
end

--tips最好属性
function ResUtil:GetTipsSuperBestUrl()
	return "img://resfile/icon/tipsSuperBest.png";
end

--头像图标
-- @param forTeam组队副本服务
function ResUtil:GetHeadIcon(iconId, isGray,forTeam)
	local grayFlag = "";
	if isGray then
		grayFlag = "_gray";
	end
	if forTeam then
		return "img://resfile/icon/head80_" .. iconId .. grayFlag .. ".png";
	end
	return "img://resfile/icon/head_" .. iconId .. grayFlag .. ".png";
end

--头像图标
function ResUtil:GetHeadIcon60(iconId)
	return "img://resfile/icon/head" .. iconId .. "_60.png";
end

--物品品质框
function ResUtil:GetSlotQuality(quality, size)
	if type(quality) == "number" then
		if quality < BagConsts.Quality_Purple or quality > BagConsts.Quality_Green3 then return ""; end
	end
	local sSize = size and "_" .. size or "";

	return "resfile/swf/slotQuality" .. quality .. sSize .. ".swf"
end

--战印，圆品质框
function ResUtil:GetSlotYuanQuality(quality)
	return "resfile/swf/slotQualityYuan" .. quality .. ".swf"
end

;

function ResUtil:GetSlotYuanQualityLingBaoBig(quality)
	return "resfile/swf/slotQualityYuan" .. quality .. "_100" .. ".swf"
end

function ResUtil:GetSlotYuanQualityLingBaoSmall(quality)
	return "resfile/swf/slotQualityYuan" .. quality .. "_69" .. ".swf"
end

--Tips品质特效
function ResUtil:GetTipsQuality(quality)

	if quality < BagConsts.Quality_Orange or quality > BagConsts.Quality_Green3 then return ""; end
	-- return "resfile/swf/tipsQuality7.swf";
	return "resfile/swf/tipsQuality" .. quality .. ".swf";
end

--获取Buff图标

function ResUtil:GetBuffIcon(name)
	return "img://resfile/skillicon/" .. name .. '.png';
end

--获取任务章节图标
function ResUtil:GetChapterIconURL(chapterIndex)
	local chapterCfg = t_questChapter[chapterIndex];
	if not chapterCfg then return end
	local icon = chapterCfg.icon;
	if not icon then return end
	if icon == "" then return end
	return "img://resfile/icon/" .. icon .. ".png";
end

--获取任务章节标题图片
function ResUtil:GetChapterTitleImgURL(chapterIndex)
	local chapterCfg = t_questChapter[chapterIndex];
	if not chapterCfg then return end
	local titleImg = chapterCfg.titleImg;
	if not titleImg then return end
	if titleImg == "" then return end
	return "img://resfile/icon/" .. titleImg .. ".png";
end

--获取任务数量数字URL
function ResUtil:GetQuestNumURL(char)
	return "img://resfile/icon/questNum_" .. char .. ".png";
end

-- 武魂图标
function ResUtil:GetWuhunIcon(name)
	return "img://resfile/icon/wuhun/" .. name .. ".png";
end

-- 武魂描述图标
function ResUtil:GetWuhunDesIcon(name)
	return "img://resfile/icon/wuhun/" .. name .. ".png";
end

-- -- 灵阵描述图标
-- function ResUtil:GetLingzhenDesIcon(name)
-- 	return "img://resfile/icon/lingzhen/" ..name;
-- end

-- 获取技能栏武魂图标
function ResUtil:GetWuhunMainIcon(name)
	if name == "" then
		name = "wuhun_empty"
	end
	return "img://resfile/icon/wuhun/" .. name .. ".png";
end

-- VIP类型info图标
function ResUtil:GetVipshowIcon(_type)
	return "img://resfile/icon/vip/viptype_" .. _type .. ".png";
end

-- 武魂等级图标
function ResUtil:GetWuhunLevelIcon(level)
	return "img://resfile/icon/wuhun/wuhun_level_little" .. level .. ".png";
end

-- 武魂等级图标 大
function ResUtil:GetWuhunLevelIconBig(level)
	return "img://resfile/icon/wuhun/wuhun_level_big" .. level .. ".png";
end

-- 武魂未得图标
function ResUtil:GetWuhunNoGetIcon()
	return "img://resfile/icon/wuhun/wuhun_noget.png";
end

-- 武魂可激活图标
function ResUtil:GetWuhunKejihuoIcon()
	return "img://resfile/icon/wuhun/wuhun_weijihuo.png";
end

--获取货币图标URL
--moneyType：货币类型 10金币，11绑定金币，12元宝，13绑元
function ResUtil:GetMoneyIconURL(moneyType)
	return "img://resfile/icon/mo_" .. moneyType .. ".png";
end

--获取功能图片
function ResUtil:GetFuncIconUrl(iconName, isSmall)
	if isSmall then
		return "img://resfile/icon/" .. iconName .. "_small.png";
	else
		return "img://resfile/icon/" .. iconName .. ".png";
	end
end

--获取功能名字图片
function ResUtil:GetFuncNameUrl(name)
	return "img://resfile/icon/" .. name .. ".png";
end

--获取功能预览图片Url
function ResUtil:GetFuncPreviewUrl(name)
	return "img://resfile/icon/" .. name .. ".png";
end

--背包满特效
function ResUtil:GetBagFullUrl()
	return "resfile/swf/bagFullEffect.swf";
end

-- 红点
function ResUtil:GetRedPoint()
	return "resfile/swf/redPoint.swf"
end
-- 按天数开启的功能图标提示
function ResUtil:GetFunPrompt()
	return "resfile/swf/OpenFunByDay.swf"
end

--得到怪物头像，名字
function ResUtil:GetMonsterIconName(iconName, isSmall)
	local LookUp = "";
	if isSmall then
		LookUp = "s_"
	else
		LookUp = "";
	end;
	return "img://resfile/icon/monster/" .. LookUp .. iconName .. ".png";
end

-- 得到宝箱id
function ResUtil:GetBoxIcon(canGet)
	local box = ""
	if canGet then
		box = "muyebox"
	else
		box = "muyebox_gray"
	end
	return "img://resfile/icon/"..box..".png";
end

--境界名称图标
function ResUtil:GetRealmIconName(iconName)
	return "img://resfile/icon/realm/" .. iconName .. ".png";
end

function ResUtil:GetRealmlv(lvImg)
	return "img://resfile/num/" .. lvImg .. ".png";
end
--境界背景图标
function ResUtil:GetRealmBg(iconName)
	return "img://resfile/icon/realm/" .. iconName .. ".jpg";
end

--获取境界头顶图标
function ResUtil:GetRealmIcon(id)
	if id <= 0 then
		return
	end
	return 'resfile/icon/realm/v_realm_' .. id .. '.png'
end

--境界特效
function ResUtil:GetRealmEffect(order)
	return "resfile/swf/realm" .. order .. ".swf";
end
--首日目标名字
function ResUtil:GetGoalName(img)
	return "img://resfile/icon/v_mubiao/" .. img;
end
--运营活动
function ResUtil:GetOperName(img)
	return "img://resfile/icon/" .. img;
end
--武魂球特效
function ResUtil:GetWuhunBallEffect(level)
	if level > 0 then
		return "resfile/swf/wuhunBallEffect_" .. level .. ".swf";
	end

	return ""
end

--武魂球
function ResUtil:GetWuhunBallImg(level)
	if level then
		return "img://resfile/icon/wuhun/wuhunball_" .. level .. ".png";
	end

	return ""
end

--坐骑名称图标
function ResUtil:GetMountIconName(iconName)
	return "img://resfile/icon/mount/" .. iconName .. ".png";
end

--封妖名称图标
function ResUtil:GetFengYaoIconUrl(iconName)
	return "img://resfile/icon/xuanshang/" .. iconName .. ".png";
end

--兵魂图标
function ResUtil:GetBingHunIconName(iconName)
	return "img://resfile/icon/binghun/" .. iconName .. ".png";
end

--双倍成长特效
function ResUtil:GetChengZhangDoubleUrl()
	return "resfile/swf/chengzhangDouble.swf";
end

--第几轮特效
function ResUtil:GetDiJiLunUrl()
	return "resfile/swf/dijilunEffect.swf";
end

--背包开启星星特效
function ResUtil:GetBagOpenStarEffect()
	return "resfile/swf/bagOpenStar.swf";
end

--翅膀合成图标
function ResUtil:GetWingHeChengName(iconName)
	return "img://resfile/icon/wing/" .. iconName .. ".png";
end

--神技绝学图标
function ResUtil:GetMagicSkillIcon(iconName)
	return "img://resfile/icon/magicskill/" .. iconName .. ".png";
end

--背包开启爆炸特效
function ResUtil:GetBagOpenBombEffect()
	return "resfile/swf/bagOpenBomb.swf";
end

--背包格子CD特效
function ResUtil:GetBagSlotCD()
	return "resfile/swf/bagSlotCD.swf";
end

--获取进阶成功特效
function ResUtil:GetJinJieSuccess()
	return "resfile/swf/jinjiechenggong.swf";
end

-- --获取灵兽墓地挑战成功特效
-- function ResUtil:GetLSMDChallSuccess()
-- 	return "resfile/swf/lsmdChallSuccess.swf";
-- end

--获取境界进阶成功特效
function ResUtil:GetJingjieUpSuccess()
	return "resfile/swf/jingjieUpSuccess.swf";
end

--获取称号图标
function ResUtil:GetTitleIconUrl(iconName)
	return "img://resfile/icon/" .. iconName .. ".png";
end

--获取称号图标(未拥有)
function ResUtil:GetNotTitleIconUrl(iconName)
	return "img://resfile/icon/" .. iconName .. ".png";
end

--获取装备宝石图标
function ResUtil:GetEquipGemIconUrl(iconName, lvl, str)
	if not iconName then return end;
	if not lvl then return end;
	local url = iconName .. "_" .. lvl
	if str == "54" then
		return "img://resfile/itemicon/" .. url .. "_54.png"
	else
		return "img://resfile/itemicon/" .. url .. ".png"
	end
end

;

--获取PK图标
function ResUtil:GetPKStateIconUrl(indexNum, pkState)
	if not indexNum then return end;
	if not pkState then return end;
	local url = indexNum .. "_" .. pkState;
	return "img://resfile/icon/pkicon" .. url .. ".png";
end

--世界Boss头像
function ResUtil:GetWorldBossIcon(bossId, isGray)
	local bossCfg = t_worldboss[bossId];
	if not bossCfg then return end
	local iconName = "";
	if not isGray then
		iconName = bossCfg.icon;
	else
		iconName = bossCfg.icon .. "_gray";
	end
	return string.format("img://resfile/icon/monster/%s.png", iconName);
end

--世界Boss名字图片
function ResUtil:GetWorldBossNameUrl(bossId)
	local bossCfg = t_worldboss[bossId]
	if not bossCfg then return end
	local iconName = bossCfg.name_pic_big
	return string.format("img://resfile/icon/monster/%s.png", iconName)
end

--野外 Boss头像
function ResUtil:GetFieldBossIcon(icon)
	return string.format("img://resfile/icon/monster/%s.png", icon);
end

-- 地宫BOSS伤害头像
function ResUtil:GetCaveBossHurtIcon( bossId )
	local bossCfg = t_xianyuancave[bossId]
	if not bossCfg then return end
	-- local iconName = bossCfg.name_pic_big
	-- return string.format("img://resfile/icon/monster/%s.png", iconName)
end
--地宫BOSS面板头像
function ResUtil:GetCaveBossHeadIcon(icon)
	return "img://resfile/icon/personboss/" .. icon .. ".png"
end

--世界Boss名字图片(世界bossUI中列表里面的名字)
function ResUtil:GetWorldBossNameImg(bossId, isGray)
	local bossCfg = t_worldboss[bossId]
	if not bossCfg then return end
	local iconName = ""
	if not isGray then
		iconName = bossCfg.name_pic_small
	else
		iconName = bossCfg.name_pic_small .. "_gray"
	end
	return string.format("img://resfile/icon/monster/%s.png", iconName)
end

-- BOSS地图美术图
function ResUtil:GetBossMapIcon(name)
	return "img://resfile/icon/monster/" .. name .. ".png"
end

-- 伤害排名界面世界boss名字
function ResUtil:GetWorldBossNameImgS(bossId)
	local bossCfg = t_worldboss[bossId]
	if not bossCfg then return end
	local iconName = bossCfg.name_pic_damageRank
	return string.format("img://resfile/icon/monster/%s.png", iconName)
end

--世界Boss描述图片
function ResUtil:GetWorldBossDesUrl(bossId)
	local bossCfg = t_worldboss[bossId];
	if not bossCfg then return end
	local iconName = bossCfg.des_pic;
	return string.format("img://resfile/icon/monster/%s.png", iconName);
end

--坐骑进阶成功特效
function ResUtil:GetHorseJinJieSuccess()
	return "resfile/swf/horseLvlUpSuccess.swf";
end

--获取活动图片路径
function ResUtil:GetActivityUrl(resName, bo)
	if bo then
		return "img://resfile/icon/" .. resName .. "_h.png";
	end;
	return "img://resfile/icon/" .. resName .. ".png";
end

--获取主线任务副本图片路径
function ResUtil:GetTruckDungeonTitle(resName, bo)
	if bo then
		return "img://resfile/icon/" .. resName .. "_h.png";
	end;
	return "img://resfile/icon/" .. resName .. ".png";
end

--获取快速购买途径图片路径
function ResUtil:GetQuicklyBuyImg(i)
	return "img://resfile/icon/recommend.png";
end

--获取活动jpg图片路径
function ResUtil:GetActivityJpgUrl(resName, bo)
	if bo then
		return "img://resfile/icon/" .. resName .. "_h.jpg";
	end;
	return "img://resfile/icon/" .. resName .. ".jpg";
end


--获取活动提醒图标
function ResUtil:GetActivityNoticeUrl(iconName)
	return "img://resfile/icon/" .. iconName .. ".png";
end
--获取技能名称图标
function ResUtil:GetSkllNameIcon(iconName)
	return "img://resfile/skillicon/" .. iconName .. ".png";
end

--获取地图图像URL
function ResUtil:GetMapImgUrl(mapId)
	local mapCfg = t_map[mapId];
	if not mapCfg then return; end
	local name = mapCfg.mapImg;
	if name == "" then return end;
	return "img://resfile/icon/map/" .. mapCfg.mapImg .. '.png';
end

--获取场景名称图片URL
function ResUtil:GetSceneNamePicURL(mapId)
	local mapCfg = t_map[mapId];
	local sceneName = mapCfg and mapCfg.sceneName;
	if not sceneName or sceneName == "" then return; end
	return "img://resfile/icon/map/" .. mapCfg.sceneName;
end

--获取地图名称图片URL
function ResUtil:GetMapNamePicURL(mapId)
	local mapCfg = t_map[mapId];
	if not mapCfg then return; end
	return "img://resfile/icon/map/" .. mapCfg.mapName;
end

--坐骑星升级星星特效
function ResUtil:GetHorseStarUpEffect()
	return "resfile/swf/horsestarup.swf";
end

--背包星升级爆炸特效
function ResUtil:GetHorseStarBambEffect()
	return "resfile/swf/horsestarbamb.swf";
end

--得到人物形象 竞技场
function ResUtil:GetArenaRoleImageImg(icon)
	return "img://resfile/icon/arenaimage_" .. icon .. ".png";
end

--获取副本图片(副本面板左侧按钮底图)
function ResUtil:GetDungeonImg(dungeonGroup, isGray)
	local groupInfo = DungeonUtils:GetGroupCfgInfo(dungeonGroup);
	local imgName = groupInfo and groupInfo.img;
	if not imgName then return; end
	local url;
	if isGray then
		url = "img://resfile/icon/" .. imgName .. "_gray.png";
	else
		url = "img://resfile/icon/" .. imgName .. ".png";
	end
	return url;
end

--获取跨服副本图片
function ResUtil:GetInterDungeonImg(dungeonId, isGray)
	local dungeonInfo = t_worlddungeons[dungeonId]
	local imgName = dungeonInfo and dungeonInfo.img;
	if not imgName then return; end
	local url;
	if isGray then
		url = "img://resfile/icon/interDungeon/" .. imgName .. "_gray.png";
	else
		url = "img://resfile/icon/interDungeon/" .. imgName .. ".png";
	end
	return url;
end

--获取副本名字图片
function ResUtil:GetDungeonNameImg(dungeonGroup, isGray)
	local groupInfo = DungeonUtils:GetGroupCfgInfo(dungeonGroup);
	local imgName = groupInfo and groupInfo.name_img;
	if not imgName then return; end
	local url;
	if isGray then
		url = "img://resfile/icon/" .. imgName .. "_gray.png";
	else
		url = "img://resfile/icon/" .. imgName .. ".png";
	end
	return url;
end

--获取跨服副本名字图片
function ResUtil:GetInterDungeonNameImg(dungeonId, isGray)
	local groupInfo = t_worlddungeons[dungeonId]
	local imgName = groupInfo and groupInfo.name_img;
	if not imgName then return; end
	local url;
	if isGray then
		url = "img://resfile/icon/" .. imgName .. "_gray.png";
	else
		url = "img://resfile/icon/" .. imgName .. ".png";
	end
	return url;
end

function ResUtil:GetDungeonDesBg(dungeonGroup)
	local groupInfo = DungeonUtils:GetGroupCfgInfo(dungeonGroup);
	local imgName = groupInfo and groupInfo.des_bg;
	return imgName and "img://resfile/icon/" .. imgName .. ".png";
end

-- 得到单人副本每个组的产出
function ResUtil:GetDungeonOutPutImg(dungeonGroup)
	local groupInfo = DungeonUtils:GetGroupCfgInfo(dungeonGroup);
	local imgName = groupInfo and groupInfo.output_img;
	return imgName and "img://resfile/icon/" .. imgName .. ".png";
end

-- 得到副本的产出
function ResUtil:GetAllDungeonOutPutImg(url)
	return "img://resfile/icon/" .. url .. ".png";
end

function ResUtil:GetInterDungeonDesBg(dungeonId)
	local groupInfo = t_worlddungeons[dungeonId]
	local imgName = groupInfo and groupInfo.des_bg;
	return imgName and "img://resfile/icon/interDungeon/" .. imgName .. ".png";
end

--获取副本描述图片
function ResUtil:GetDungeonDesImg(dungeonGroup)
	local groupInfo = DungeonUtils:GetGroupCfgInfo(dungeonGroup);
	local imgName = groupInfo and groupInfo.des_img;
	return imgName and "img://resfile/icon/" .. imgName .. ".png";
end

--获取跨服副本描述图片
function ResUtil:GetInterDungeonDesImg(dungeonId)
	local groupInfo = t_worlddungeons[dungeonId]
	local imgName = groupInfo and groupInfo.des_img;
	return imgName and "img://resfile/icon/" .. imgName .. ".png";
end

--得到工会职位图标
function ResUtil:GetUnionPosIconImg(posId)
	return "img://resfile/icon/union_" .. posId .. ".png";
end

-- 获取帮派副本名称图片
-- @param id: 帮派副本id
function ResUtil:GetUnionDungeonNameImg(id)
	local cfg = t_guildActivity[id];
	local imgName = cfg and cfg.name_img;
	return imgName and "img://resfile/icon/" .. imgName;
end

-- 获取帮派副本背景图片
-- @param id: 帮派副本id
function ResUtil:GetUnionDungeonBgImg(id)
	local cfg = t_guildActivity[id];
	local imgName = cfg and cfg.bg_img;
	return imgName and "img://resfile/icon/" .. imgName;
end

-- 获取帮派地宫信息背景图片
-- @param id: 帮派副本id
function ResUtil:GetUnionDiGongBgImg(id)
	local cfg = t_guilddigong[id];
	local imgName = cfg and cfg.bgicon;
	return imgName and "img://resfile/icon/" .. imgName .. ".jpg";
end

--得到时装图标
function ResUtil:GetFanshionsIconImg(imgName, size)
	if not size then size = ""; end
	if size ~= "" then
		if size ~= "54" then
			size = "";
		else
			size = "_" .. size;
		end
	end

	return "img://resfile/icon/fashions/" .. imgName .. size .. ".png";
end

--获得称号swf
function ResUtil:GetTitleIconSwf(iconName)
	return "resfile/swf/" .. iconName .. ".swf";
end

--获取tips点
function ResUtil:GetTipsPointURL()
	return "img://resfile/icon/rulePoint.png";
end

--得到排行榜首名名字
function ResUtil:GetUnionIconImg(name)
	-- if bo == true then 
	-- 	return "img://resfile/icon/Ranklist_" .. name .. "_D.png";
	-- end;
	return "img://resfile/icon/rank/Ranklist_" .. name .. ".png";
end

--获取卓越孔图片
function ResUtil:GetSuperHoleIconUrl(name)
	return "img://resfile/icon/" .. name .. ".png";
end

--获取卓越孔默认图片
function ResUtil:GetSuperHoleDefault()
	return "img://resfile/icon/superHoleDefault.png";
end

--id:神兵等阶
function ResUtil:GetMagicWeaponNameImg(id)
	local cfg = t_shenbing[id];
	local iconName = cfg and cfg.name_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName ;
end


--id:神兵等阶
function ResUtil:GetRankMagicWeaponNameImg(id)
	local cfg = t_shenbing[id];
	local iconName = cfg and cfg.rankname_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName ;
end


function ResUtil:GetMagicWeaponLvlImg(id)
	local cfg = t_shenbing[id];
	local iconName = cfg and cfg.lvl_icon;
	return iconName and "img://resfile/icon/" .. iconName;
end

--升阶系统等阶
function ResUtil:GetFeedUpLvlImg(id)
	return "img://resfile/icon/feedLvl_" .. id .. ".png";
end

function ResUtil:GetMagicWeaponDesImg(id)
	local cfg = t_shenbing[id];
	local iconName = cfg and cfg.des_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


--id:灵器等阶
function ResUtil:GetLingQiNameImg(id)
	local cfg = t_lingqi[id];
	local iconName = cfg and cfg.name_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


--id:灵器等阶
function ResUtil:GetRankLingQiNameImg(id)
	local cfg = t_lingqi[id];
	local iconName = cfg and cfg.rankname_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


function ResUtil:GetLingQiLvlImg(id)
	local cfg = t_lingqi[id];
	local iconName = cfg and cfg.lvl_icon;
	return iconName and "img://resfile/icon/" .. iconName;
end

function ResUtil:GetLingQiDesImg(id)
	local cfg = t_lingqi[id];
	local iconName = cfg and cfg.des_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end

--id:玉佩等阶
function ResUtil:GetMingYuNameImg(id)
	local cfg = t_mingyu[id];
	local iconName = cfg and cfg.name_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


--id:玉佩等阶
function ResUtil:GetRankMingYuNameImg(id)
	local cfg = t_mingyu[id];
	local iconName = cfg and cfg.rankname_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


function ResUtil:GetMingYuLvlImg(id)
	local cfg = t_mingyu[id];
	local iconName = cfg and cfg.lvl_icon;
	return iconName and "img://resfile/icon/" .. iconName;
end

function ResUtil:GetMingYuDesImg(id)
	local cfg = t_mingyu[id];
	local iconName = cfg and cfg.des_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


--id:新宝甲等阶
function ResUtil:GetArmorNameImg(id)
	local cfg = t_newbaojia[id];
	local iconName = cfg and cfg.name_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


--id:新宝甲等阶
function ResUtil:GetRankArmorNameImg(id)
	local cfg = t_newbaojia[id];
	local iconName = cfg and cfg.rankname_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end


function ResUtil:GetArmorLvlImg(id)
	local cfg = t_newbaojia[id];
	local iconName = cfg and cfg.lvl_icon;
	return iconName and "img://resfile/icon/" .. iconName;
end

function ResUtil:GetArmorDesImg(id)
	local cfg = t_newbaojia[id];
	local iconName = cfg and cfg.des_icon;
	return iconName and "img://resfile/icon/v_jinjie/" .. iconName;
end

--id:宝甲等阶
function ResUtil:GetBaoJiaNameImg(id)
	local cfg = t_baojia[id];
	local iconName = cfg and cfg.name_icon;
	return iconName and "img://resfile/icon/baojia/" .. iconName;
end

--获取任务完成特效
function ResUtil:GetQuestFinishEff()
	return "resfile/swf/questFinish.swf";
end

function ResUtil:GetQuestTrunkNewEff()
	return "resfile/swf/trunkQuestCanAccept.swf";
end

function ResUtil:GetQuestLvFinishEff()
	return "resfile/swf/lvQuestFinish.swf";
end

-- 杀意值名字
function ResUtil:GetShaYiZhiNameURL(str)
	return "img://resfile/icon/shayizhiname_" .. str .. ".png"
end

;

-- 获取杀戮等级对应的名称图片
function ResUtil:GetKillValueTipsTitleURL(killLvl)
	local imgName;
	for id, cfg in pairs(t_killtask) do
		if cfg.level == killLvl then
			imgName = cfg.title_img;
		end
	end
	return "img://resfile/icon/" .. imgName;
end

--获取斗破苍穹BOSS名称
function ResUtil:GetBabelBossIcon(id, state)
	local cfg = t_doupocangqiong[id]
	if state == 1 then
		return "img://resfile/icon/babel/" .. cfg.bossname_line;
	else
		return "img://resfile/icon/babel/" .. cfg.bossname_row;
	end
end

--获取定时副本难度小图标
function ResUtil:GetTimeDungeonSmallIcon(index)
	return "img://resfile/icon/timeDungeon/timeDungeonND_" .. index .. '.png';
end

--获取定时副本队伍难度顶图标
function ResUtil:GetTimeDungeonTeamNDIcon(index)
	return "img://resfile/icon/timeDungeon/timeDungeonTeamND_" .. index .. '.png';
end

--获取定时副本队伍信息面板难度图标
function ResUtil:GetTimeDungeonInfoNDIcon(index)
	return "img://resfile/icon/timeDungeon/timeDungeonInforND_" .. index .. '.png';
end

-- 每日必做名称
function ResUtil:GetDailyMustDoNameURL(str)
	return "img://resfile/icon/meiribizuo/" .. str .. ".png"
end

;

--获取萌宠图标
function ResUtil:GetLovelyPetIcon(str)
	return "img://resfile/icon/lovelypet/" .. str .. ".png"
end

--获取萌宠品质图标
function ResUtil:GetLovelyPetQualityIcon(index)
	return "img://resfile/icon/lovelypet/lovelypetQuality" .. index .. ".png"
end

--获取萌宠品质图标
function ResUtil:GetLovelyPetQualityName(index)
	return "img://resfile/icon/lovelypet/lovelypetQualityIcon_" .. index .. ".png"
end

--获取骑战图标
function ResUtil:GetQiZhanIcon(stricon)
	return "img://resfile/icon/qizhan/" .. stricon .. ".png"
end

-- 至尊荣耀，titlename
function ResUtil:GetSuperGloryTitleNameURL(str)
	return "img://resfile/icon/superGloryTitleName_" .. str .. ".png"
end

;
-- 灵兽装备icon
function ResUtil:GetSpiritWarPrintIconURL(str, bo)
	if bo == true then
		return "img://resfile/itemicon/" .. str .. "_D.png"
	end
	return "img://resfile/itemicon/" .. str .. ".png"
end

;

-- 五行灵脉装备icon
function ResUtil:GetWuxinglingmaiIconURL(str, bo)
	if bo == true then
		return "img://resfile/itemicon/" .. str .. ".png"
	end
	return "img://resfile/itemicon/" .. str .. ".png"
end

;

-- 帮派活动图标
function ResUtil:GetUnionActivityNameURL(str)
	return "img://resfile/icon/" .. str .. ".png"
end

;

function ResUtil:GetQuestTypeIcon(questType)
	if questType == QuestConsts.Type_Trunk then
		return "img://resfile/icon/quest_trunk.png"
	elseif questType == QuestConsts.Type_Day then
		return "img://resfile/icon/quest_daily.png"
	elseif questType == QuestConsts.Type_Level then
		return "img://resfile/icon/quest_level.png"
	elseif questType == QuestConsts.Type_Achievement then
		return "img://resfile/icon/quest_achievement.png"
	elseif questType == QuestConsts.Type_Random then
		return "img://resfile/icon/quest_qiyu.png"
	elseif questType == QuestConsts.Type_WaBao then
		return "img://resfile/icon/quest_wabao.png"
	elseif questType == QuestConsts.Type_FengYao then
		return "img://resfile/icon/quest_fengyao.png"
	elseif questType == QuestConsts.Type_Super then
		return "img://resfile/icon/quest_super.png"
	elseif questType == QuestConsts.Type_HuoYueDu then
		return "img://resfile/icon/quest_super.png"
	elseif questType == QuestConsts.Type_EXP_Dungeon then
		return "img://resfile/icon/quest_super.png"
	elseif questType == QuestConsts.Type_ZhuanZhi then
		return "img://resfile/icon/quest_super.png"
	end
	return "";
end

--转职图标
function ResUtil:GetZhuanZhiIcon(name, bAllName)
	if bAllName then
		return "img://resfile/icon/v_zhuanzhi/" .. name
	else
		return "img://resfile/icon/v_zhuanzhi/" .. name .. ".png"
	end
end

--获取评分图标  极限副本
function ResUtil:GetExtremityLeveIcon(num)
	return "img://resfile/icon/limit/" .. num .. '.png'
end

--获取V计划头顶图标
function ResUtil:GetVIcon(vflag)
	local vtype = toint(vflag / 1000, -1);
	if vtype ~= VplanConsts.Type_M and vtype ~= VplanConsts.Type_Y then
		return "";
	end
	return "img://resfile/icon/vplan" .. vflag .. ".png";
end

--获取V计划界面展示图标
function ResUtil:GetVUIIcon(index)
	return "img://resfile/icon/vplanui_" .. index .. ".png";
end

function ResUtil:GetProfImg(profId)
	return string.format("img://resfile/icon/prof_%s.png", profId);
end

--获取VIP图标
function ResUtil:GetVIPIcon(vip)
	return "";
end

--幕
function ResUtil:GetMuIcon(str)
	return "img://resfile/icon/v_juqing/" .. str;
end

--幕名字
function ResUtil:GetMuNameIcon(str)
	return "img://resfile/icon/v_juqing/" .. str;
end

--幕背景
function ResUtil:GetMuBGIcon(str, gray)
	local grayFlag = '';
	if gray then
		grayFlag = '_gray';
	end
	return "img://resfile/icon/v_juqing/" .. str .. grayFlag .. '.png';
end

--章节
function ResUtil:GetZhangjieIcon(str)
	return "img://resfile/icon/v_juqing/" .. str;
end

--关卡
function ResUtil:GetGuanQiaIcon(str)
	return "img://resfile/icon/v_juqing/" .. str;
end

--主宰之路首通奖励图片
function ResUtil:GetFirsRewardIcon(str)
	return "img://resfile/icon/v_juqing/" .. str;
end

--获取北仓界头顶等级称号
function ResUtil:GetBCLevelIcon(level)
	return "bcHeadLevel_" .. level .. ".png";
end

function ResUtil:GetBCLevelIcon1(level)
	return "jifendengjiicon" .. level .. ".png";
end

function ResUtil:GetBCLevelIcon2(level)
	return "img://resfile/icon/beicangjie/jifendengjiicon" .. level .. ".png";
end

function ResUtil:GetLingzhiIcon(number)
	return "bcjjifenicon" .. number .. ".png";
end

function ResUtil:GetActivityFight(number)
	return "activityFight_" .. number .. "_v.png";
end

--获取成就等级图标
function ResUtil:GetAchievementLevel(level)
	return "img://resfile/icon/achievementLevel_" .. level .. ".png"
end

-- --id:等阶
-- function ResUtil:GetLingzhenNameImg(id)
-- 	local cfg = t_lingzhen[id];
-- 	local iconName = cfg and cfg.name_icon;
-- 	return iconName and "img://resfile/icon/lingzhen/" .. iconName;
-- end

--id:等阶
function ResUtil:GetLingzhenLevelImg(id)
	local cfg = t_lingzhen[id];
	local iconName = cfg and cfg.lvl_icon;
	return iconName and "img://resfile/icon/" .. iconName;
end

-- --id:等阶
-- function ResUtil:GetLingzhenRnaklistNameImg(id)
-- 	local cfg = t_lingzhen[id];
-- 	local iconName = cfg and cfg.rank_name_icon;
-- 	return iconName and "img://resfile/icon/lingzhen/" .. iconName;
-- end

-- 聚灵飞灵力粒子
function ResUtil:GetLingLiParticle()
	return "img://resfile/icon/lingli.png"
end

--附加属性图标
function ResUtil:GetSuperIconUrl(iconName, isSmall)
	if isSmall then
		return "img://resfile/icon/" .. iconName .. "_24.png";
	else
		return "img://resfile/icon/" .. iconName .. ".png";
	end
end

--手机助手APP图片
function ResUtil:GetPhoneHelpIcon(picIndex)
	return "img://resfile/icon/phonehelp/phonehelp" .. picIndex .. ".jpg";
end

--获取手机助手二维码
function ResUtil:GetPhoneHelpErweima(versionName)
	return "img://resfile/icon/phonehelp/erweima_" .. versionName .. ".png";
end

--翅膀星星特效
function ResUtil:GetWingStarEffect()
	return "resfile/swf/wingPreviewStar.swf";
end

-- 家园skill
function ResUtil:GetHomeSkillImg(src, str)
	if str == "54" then
		return "img://resfile/icon/home/skill/" .. src .. "_54.png"
	elseif str == "64" then
		return "img://resfile/icon/home/skill/" .. src .. "_64.png"
	end;
	return "img://resfile/icon/home/skill/" .. src .. ".png"
end

-- 家园弟子
function ResUtil:GetHomePupilIcon(iconid, str)
	local cfg = t_homepupilimage[iconid];
	if not cfg then return "" end;
	if str and str == "64" then
		return "img://resfile/icon/home/pupil/" .. cfg.image_man .. "_64.png"
	end;
	return "img://resfile/icon/home/pupil/" .. cfg.image_man .. ".png"
end


-- 家园任务
function ResUtil:GetHomeQuestIcon(str)
	return "img://resfile/icon/home/quest/homesquest_" .. str .. ".png"
end

-- 家园怪物
function ResUtil:GetHomeMonsterIcon(str)
	return "img://resfile/icon/home/monster/" .. str .. ".png"
end

--七日奖励图标
function ResUtil:GetIcon(str)
	return "img://resfile/icon/sevenday/" .. str .. ".png"
end

-- 家园remind
function ResUtil:GetHomeRemindIcon(str)
	return "img://resfile/icon/home/" .. str .. ".png"
end

--Vip图标
function ResUtil:GetVipIconUrl(vipType, level)
	return "img://resfile/icon/vip" .. vipType .. '_' .. level .. ".png"
end

--Vip信息图标
function ResUtil:GetVipInfoUrl(url)
	return "img://resfile/icon/vip/" .. url .. ".png"
end

--帮派等级图标
function ResUtil:GetUnionLevelIcon(url)
	return "img://resfile/icon/guild/" .. url .. ".png"
end

--运营活动的广告图
function ResUtil:GetOperActivityIcon(url)
	return "img://resfile/icon/" .. url
end

--运营活动图标的名字
function ResUtil:GetOperActivityNameIcon(url)
	if url then
		return "img://resfile/icon/" .. url .. ".png"
	end
end

function ResUtil:GetFlowerEffect()
	return "resfile/swf/flowerEffect.swf"
end

--装备新套装资源
function ResUtil:GetNewEquipGrouNameIcon(icon, isUi, isIcon, isTips2)
	if isIcon then
		return "img://resfile/icon/equipgroup/icon_" .. icon .. ".png"
	end;
	if isTips2 then
		return "img://resfile/icon/equipgroup/tips2_" .. icon .. ".png"
	end;
	if isUi then
		return "img://resfile/icon/equipgroup/ui_" .. icon .. ".png"
	end;
	return "img://resfile/icon/equipgroup/tips_" .. icon .. ".png"
end

;

function ResUtil:GetShenWuSlotIcon(shenWuLvl, shenWuStar)
	if shenWuLvl <= 0 then return "" end
	local cfg = ShenWuUtils:GetStarCfg(shenWuLvl, shenWuStar)
	local imgName = cfg and cfg.name_icon or ""
	return "img://resfile/icon/shenwu/" .. imgName .. ".png"
end

--圣器图片
function ResUtil:GetHallowsBgIcon(name)
	if not name then return end
	return "img://resfile/icon/binghun/" .. name .. ".png";
end

function ResUtil:GetHallowsHoleIcon(name)
	if not name then return end
	return "img://resfile/icon/binghun/" .. name .. ".png";
end

--id:神兵等阶
function ResUtil:GetShenWuNameImg(level)
	local cfg = t_shenwu[level]
	local iconName = cfg and cfg.name_icon
	return iconName and "img://resfile/icon/shenwu/" .. iconName .. ".png" or ""
end

--id:神武等阶
function ResUtil:GetShenWuUINameImg(level)
	local cfg = t_shenwu[level]
	local iconName = cfg and cfg.uiname_icon
	return iconName and "img://resfile/icon/shenwu/" .. iconName .. ".png" or ""
end

--跨服boss宝箱图标
function ResUtil:GetTreasureIcon()
	return "treasureicon.png"
end

--跨服boss数字
function ResUtil:GetBossNumberIcon(id)
	return 'boss_treasure_' .. id .. '.png'
end

--结婚
function ResUtil:GetMarryQinmiIcon(icon)
	return "img://resfile/icon/marry/" .. icon .. ".png"
end


--养成套装，icon
function ResUtil:GetNewEquipGrouNameIconYangcheng(icon)
	return "img://resfile/icon/equipgroup/" .. icon .. ".png"
end

;

-- 灵诀
function ResUtil:GetLingJueBookUrl(id)
	local cfg = t_lingjueachieve[id]
	if not cfg then
		print(id)
	end
	if not cfg then return end
	local imgName = cfg.name
	return "img://resfile/icon/lingjue/" .. tostring(imgName)
end

-- 灵诀组
function ResUtil:GetLingJueGroupUrl(id)
	for _, cfg in pairs(t_lingjuegroup) do
		if cfg.gourp_id == id then
			local imgName = cfg.gourp_name
			return "img://resfile/icon/lingjue/" .. tostring(imgName)
		end
	end
end

-- 法宝
function ResUtil:GetFabaoLevelImg(id)
	local cfg = t_fabao[id];
	local iconName = cfg and cfg.lvl_icon;
	return iconName and "img://resfile/icon/" .. iconName;
end

function ResUtil:GetFabaoImg(id)
	local cfg = t_fabao[id];
	local iconName = cfg and cfg.name_icon;
	return iconName and "img://resfile/icon/" .. iconName .. ".png";
end


--装备镶嵌
function ResUtil:GetSmithingIcon(icon)
	return "img://resfile/icon/v_zhuangbei/" .. icon .. ".png"
end

--- 图鉴
function ResUtil:GetFumoIcon(icon)
	return "img://resfile/icon/map/" .. icon .. ".png";
end

--- 星图
function ResUtil:GetXingtuIcon(icon)
	return "img://resfile/icon/v_xingtu/" .. icon .. ".png";
end

--活跃度
function ResUtil:GetHuoyueduLvlName(name)
	return "img://resfile/icon/v_xianjie/" .. name .. ".png";
end

--神炉
function ResUtil:GetStoveNameIcon(name)
	return "img://resfile/icon/" .. name;
end

function ResUtil:GetStoveLevelIcon(name)
	return "img://resfile/icon/" .. name;
end

function ResUtil:GetStoveIcon(name)
	return "img://resfile/icon/v_shenluzhuangbei/" .. name;
end

--目标奖励tips
function ResUtil:GetGoalIcon(name)
	return "img://resfile/icon/v_mubiao/" .. name;
end

function ResUtil:GetGroupIcon(name)
	return "img://resfile/icon/equipgroup/" .. name .. ".png"
end

--- 获取戒指资源
function ResUtil:GetRingIcon(name)
	return "img://resfile/icon/equipgroup/" .. name .. ".png"
end

--天神附体头像
function ResUtil:GetTianshenIcon(roleId, isGray)

	local roleCfg = t_tianshen[roleId];
	if not roleCfg then return end
	local iconName = "";
	if not isGray then
		iconName = roleCfg.icon_large;
	else
		iconName = roleCfg.icon .. "_gray";
	end
	return string.format("img://resfile/icon/v_bianshen/%s.png", iconName);
end

--天神附体名字图片
function ResUtil:GetTianshenNameUrl(modelid)
	local roleCfg = t_tianshenlv[modelid]
	if not roleCfg then return end
	local iconName = roleCfg.name
	return string.format("img://resfile/icon/v_bianshen/%s.png", iconName)
end

function ResUtil:GetTianshenNormalIcon(roleId)
	local roleCfg = t_tianshen[roleId]
	if not roleCfg then return end
	local iconName = roleCfg.icon
	return string.format("img://resfile/icon/v_bianshen/%s.png", iconName)
end

function ResUtil:GetTianShenEffectIcon(roleId)

	return "img://resfile/icon/v_bianshen/v_bs_effect_lzz_d_" .. roleId .. ".png";
end

function ResUtil:GetTianShenEffectIconname(roleId)

	return "img://resfile/icon/v_bianshen/v_bs_effect_lzz_" .. roleId .. ".png";
end

function ResUtil:GetGoldSmallIcon()
	return "img://resfile/icon/gold_s.png";
end
function ResUtil:GetMoneySmallIcon()
	return "img://resfile/icon/money_s.png";
end
-- 获取装备收集
function ResUtil:GetEquipCollectIcon(name)
	return "img://resfile/icon/v_shenzhuang/" .. name .. ".png"
end

function ResUtil:GetButtonEffect10()
	return "resfile/swf/buttoneffect-10.swf"
end

function ResUtil:GetButtonEffect7()
	return "resfile/swf/buttoneffect-7.swf"
end

function ResUtil:GetButtonEffect9()
	return "resfile/swf/buttoneffect-9.swf"
end

function ResUtil:GetRemindFuncTipsBG(bg)
	return "img://resfile/icon/v_remindfunctips/" .. bg .. ".png"
end

function ResUtil:GetRemindFuncTipsContent(content)
	return "img://resfile/icon/v_remindfunctips/" .. content .. ".png"
end
--按天数开启的功能图标提示
function ResUtil:GetOpenFunTitle(id)
	local cfg = t_funcOpen[id];
	local open_display = cfg and cfg.open_display;
	return open_display and "img://resfile/icon/v_funcopen/" .. open_display;
end
function ResUtil:GetOpenFunDescribe(id)
	local cfg = t_funcOpen[id];
	local describe = cfg and cfg.describe;
	return describe and "img://resfile/icon/v_funcopen/" .. describe;
end
function ResUtil:GetOpenFunAttribute(id)
	local cfg = t_funcOpen[id];
	local attribute = cfg and cfg.attribute;
	return attribute and "img://resfile/icon/v_funcopen/" .. attribute;
end

--获取技能框特效
function ResUtil:GetSkillFrameEffect(type,skillId)
	local result = '';
	if type<1 then return result; end
	local skill = t_skill[skillId];
	if not skill then return result; end
	if skill.gain_type == 0 then return result; end
	-- result = "resfile/swf/skillFrame"..type.."_"..skill.gain_type;
	result = "resfile/swf/skillFrame"..type.."_1.swf";
	return result;
end

--获取技能点特效
function ResUtil:GetSkillPointEffect(type,skillId)
	local result = '';
	if type<1 then return result; end
	local skill = t_skill[skillId];
	if not skill then return result; end
	if skill.gain_type == 0 then return result; end
	result = "resfile/swf/skilldot_"..skill.gain_type..".swf";
	return result;
end

--获取天神主界面头像
function ResUtil:GetTianshenMainIcon(modelid)
	local roleCfg = t_tianshen[modelid]
	if not roleCfg then return end
	return "img://resfile/icon/v_bianshen/"..roleCfg.ui_head;
end


-- 获取绝学背景图
function ResUtil:GetMagicOrXinfaIcon( id,tableOne,tableTwo)
	local magicCfg = tableOne[id]
	local gid = 0;
	for i,v in ipairs(tableOne) do
		if v.id == id then
			gid = v.juexuezu
			break;
		end
	end
	if not gid or gid == 0 then return; end
	local juexuezuCfg = tableTwo[gid]
	if not juexuezuCfg then return end
	local chart = juexuezuCfg.chart
	if not chart then return end
	return "img://resfile/icon/" .. chart ;
end

function ResUtil:GetTianshenTitle(index)
	return "v_tstitle"..index..'.png';
end

function ResUtil:GetBigStar()
	return "v_bigstar.png";
end

function ResUtil:GetNewTianshenIcon(name)
	return "img://resfile/icon/v_bianshen/" ..name .. ".png"
end

function ResUtil:GetNewTianshenUIcon(name)
	return "img://resfile/icon/v_bianshen/" ..name .. ".png"
end

