--[[
Tips系统的一些常量
lizhuangzhuang
2014年7月24日21:14:53
]]

_G.TipsConsts = {};

--Tips方向,右上
TipsConsts.Dir_RightUp = 1;
--Tips方向,右下
TipsConsts.Dir_RightDown = 2;
--Tips方向，左上
TipsConsts.Dir_LeftUp = 3;
--Tips方向，左下
TipsConsts.Dir_LeftDown = 4;
--Tips类型
TipsConsts.Type_Normal = 1;--普通
TipsConsts.Type_Item = 2;--物品
TipsConsts.Type_Equip = 3;--装备
TipsConsts.Type_Skill = 4;--技能
TipsConsts.Type_Map = 5;--地图
TipsConsts.Type_Buff = 6;--Buff
TipsConsts.Type_StrenLink = 8;--强化连锁
-- TipsConsts.Type_JewelleryInfo = 9;--启灵珍宝
TipsConsts.Type_NewSuperLink = 11;--新卓越连锁
TipsConsts.Type_GemLink = 12;--宝石连锁
TipsConsts.Type_GuildSkill = 13;--帮派技能
TipsConsts.Type_Fanshion = 14;--时装
TipsConsts.Type_SpiritWarPrint = 15;--灵兽印记
TipsConsts.Type_RefinLink = 16;--炼化连锁
TipsConsts.Type_Wing = 17;--翅膀
TipsConsts.Type_Ring = 18;--戒指
TipsConsts.Type_EquipGroup = 19;--套装tips
TipsConsts.Type_Fabao = 20;--灵兽印记
TipsConsts.Type_WashLink = 21 --洗练连锁
TipsConsts.Type_Goal = 22 --目标奖励
TipsConsts.Type_NewEquipGroup = 23 --新装备套装
TipsConsts.Type_Transfor=23   --天神
TipsConsts.Type_Relic = 24   --圣物
TipsConsts.Type_NewTianshen = 25 --新天神

--Tips显示类型,默认
TipsConsts.ShowType_Normal = 1;
--Tips显示类型,对比
TipsConsts.ShowType_Compare = 2;

--默认字色
TipsConsts.Default_Color = "#eeb462";  --changer:houxudong date:2016/7/16

--白色加边字体 
TipsConsts.Normal_Color = "#d8d8d8";  --默认白色字体
--小字号
TipsConsts.Small_Size = 12;
--默认字号
TipsConsts.Default_Size = 14;
--默认大字号
TipsConsts.BlackNew_Size = 20;
--标题字号
TipsConsts.TitleSize_One = 18;--一级标题
TipsConsts.TitleSize_Two = 16;--二级标题
TipsConsts.TitleSize_Three = 14;--新二级标题大小
--二级标签颜色
TipsConsts.TwoTitleColor = "#c29259";  --"#f2bf96";
--红色颜色
TipsConsts.redColor = "#ff0000"
--绿色颜色
TipsConsts.greenColor = "#00ff00"
--装备名字颜色
TipsConsts.orangeColor = "#feaf05"
--禁止颜色
TipsConsts.ForbidColor = "#ff0000";
--卓越属性颜色
TipsConsts.SuperColor = "#8152e1";
--新卓越属性颜色
TipsConsts.NewSuperColor = "#feaf05"; -- befor:#3bde1b
-- 绑定色值
TipsConsts.BlindColor = "#d4d4d4";
-- 获取方式色值
TipsConsts.GetPathColor = "#508cd2";

--根据品质获取物品颜色值(物品、装备)
function TipsConsts:GetItemQualityColor(quality)
	if quality == BagConsts.Quality_White then
		return "#ffffff";
	elseif quality == BagConsts.Quality_Blue then
		return "#00b7ef";
	elseif quality == BagConsts.Quality_Purple then
		return "#b324f6";
	elseif quality == BagConsts.Quality_Orange then
		return "#fff000";
	elseif quality == BagConsts.Quality_Red then
		return "#dc1d03";
	elseif quality == BagConsts.Quality_Green1 then
		return "#ff6c00";
	elseif quality == BagConsts.Quality_Green2 then
		return "#ff6c00";
	elseif quality == BagConsts.Quality_Green3 then
		return "#ff6c00";
	end
	return "#ffffff";
end 

-- adder:houxudong
-- 服务于聊天窗口的灵光封魔
--根据物品难易度显示不同的系统提示颜色
function TipsConsts:GetItemDiffColor(id)
	return "#ff0000"
end

--根据品质获取物品颜色值(物品、装备)
function TipsConsts:GetItemQualityColorVal(quality)
	local color = self:GetItemQualityColor(quality)
	return color and "0xFF" .. string.sub(color, 2);
end

--根据品质获取技能颜色值(技能)
function TipsConsts:GetSkillQualityColor(quality)
	if quality == SkillConsts.Quality_White then
		return "#EEEEEE";
	elseif quality == SkillConsts.Quality_Green then
		return "#22C50B";
	elseif quality == SkillConsts.Quality_Blue then
		return "#00B7EE";
	elseif quality == SkillConsts.Quality_Purple then
		return "#B400FF";
	elseif quality == SkillConsts.Quality_Orange then
		return "#F9680C";
	end
	return "#EEEEEE";
end
