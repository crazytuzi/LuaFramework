ColorDataManager = { };
ColorDataManager.grayColor = Color.New(0, 0, 0)
ColorDataManager.ungrayColor = Color.New(1, 1, 1)

local colorWhite = Color.New(1, 1, 1);
--  白色
function ColorDataManager.Get_white()
    return colorWhite
end


local colorGreen = Color.New(119 / 0xff, 255 / 0xff, 71 / 0xff);
function ColorDataManager.Get_green()
    return colorGreen
end

local colorBlue =  Color.New(52 / 0xff, 224 / 0xff, 255 / 0xff);
-- 蓝色
function ColorDataManager.Get_blue()
    return colorBlue
end

local colorPurple = Color.New(229 / 0xff, 123 / 0xff, 255 / 0xff);
-- 紫色
function ColorDataManager.Get_purple()
    return colorPurple
end

local colorGolden = Color.New(255 / 0xff, 246 / 0xff, 0 / 0xff);
-- 金色
function ColorDataManager.Get_golden()
    return colorGolden
end

local colorOrange = Color.New(1, 168 / 0xff, 17 / 0xff);
-- 橙色
function ColorDataManager.Get_orange()
    return colorOrange
end

local colorRed = Color.New(250 / 0xff, 64 / 0xff, 64 / 0xff, 0xff / 0xff);
-- 红色
function ColorDataManager.Get_red()
    return colorRed
end

local colorYellow = Color.New(1, 0xd7 / 0xff, 43 / 0xff, 0xff / 0xff);
-- 黄色
function ColorDataManager.Get_yellow()
    return colorYellow
end
-- vip 着色
function ColorDataManager.Get_Vip(vl)
    return (vl ~= nil and vl > 0) and ('[e57bff]V' .. vl .. '[-]') or ''
end

local colorGrey = Color.New(0x70 / 0xff, 0x70 / 0xff, 0x70 / 0xff);
function ColorDataManager.Get_greyf()
    return colorGrey
end

local colorWhitef = Color.New(0xff / 0xff, 0xff / 0xff, 0xff / 0xff);
function ColorDataManager.Get_whitef()
    return colorWhitef 
end

local pkWhite = Color.New(0 / 0xff, 255 / 0xff, 0 / 0xff);
local pkYellow = Color.New(1, 168 / 0xff, 17 / 0xff);
local pkRed = Color.New(255 / 0xff, 0 / 0xff, 0 / 0xff);

-- 英雄名字颜色
function ColorDataManager.GetHeroNameColor(pkState, blArathi)
    local state = pkState or 0;
    if (state < 0 or state > 3) then state = 0 end;
    if (state == 0 or blArathi) then
        -- pk白名
        return pkWhite
    elseif (state == 1) then
        -- pk黄名
        return pkYellow
    elseif (state == 2) then
        -- pk红名
        return pkRed
    end
end
function ColorDataManager.GetPkRed()
    return pkRed
end

local playerName0 = Color.New(103 / 0xff, 161 / 0xff, 255 / 0xff);
local playerName1 = Color.New(1, 168 / 0xff, 17 / 0xff);
local playerName2 = Color.New(255 / 0xff, 0 / 0xff, 0 / 0xff);

-- 玩家名字颜色
function ColorDataManager.GetPlayerNameColor(pkState, blArathi)
    local state = pkState or 0;
    if (state < 0 or state > 3) then state = 0 end;
    if (state == 0 or blArathi) then
        return playerName0
    elseif (state == 1) then
        return playerName1
    elseif (state == 2) then
        return  playerName2 
    end
end

local petName =  Color.New(247 / 0xff, 151 / 0xff, 39 / 0xff);
-- 宠物名字颜色
function ColorDataManager.GetPetNameColor()
    return petName
end

local npcName = Color.New(255 / 0xff, 255 / 0xff, 0 / 0xff);
-- NPC名字颜色
function ColorDataManager.GetNPCNameColor()
    return npcName
end

local monsterName = Color.New(255 / 0xff, 255 / 0xff, 255 / 0xff);
-- 怪物名字颜色
function ColorDataManager.GetMonsterNameColor()
    return monsterName
end

local petName = Color.New(250 / 0xff, 255 / 0xff, 126 / 0xff);
-- 怪物名字颜色
function ColorDataManager.GetPetNameColor()
    return petName
end

local targetHurtTop = Color.New(255 / 0xff, 254 / 0xff, 157 / 0xff)
local targetHurtButtom = Color.New(255 / 0xff, 222 / 0xff, 0 / 0xff);

-- 目标伤害颜色,上下
function ColorDataManager.GetTargetHurtColor()
    return targetHurtTop, targetHurtButtom
end

local targetCritTop = Color.New(255 / 0xff, 198 / 0xff, 0 / 0xff)
local targetCritButtom = Color.New(255 / 0xff, 108 / 0xff, 0 / 0xff);

-- 目标暴击伤害颜色,上下
function ColorDataManager.GetTargetCritHurtColor()
    return targetCritTop, targetCritButtom;
end

local targetFatalTop = Color.New(255 / 0xff, 157 / 0xff, 157 / 0xff)
local targetFatalButtom = Color.New(255 / 0xff, 34 / 0xff, 34 / 0xff);

-- 目标必杀伤害颜色,上下
function ColorDataManager.GetTargetFatalHurtColor()
    return targetFatalTop, targetFatalButtom;
end

local targetMissTop = Color.New(125 / 0xff, 253 / 0xff, 255 / 0xff)
local targetMissButtom = Color.New(0 / 0xff, 210 / 0xff, 255 / 0xff)

-- 目标闪避颜色,上下
function ColorDataManager.GetTargetMissColor()
    return targetMissTop, targetMissButtom
end

local heroHurtTop = Color.New(255 / 0xff, 157 / 0xff, 157 / 0xff)
local heroHurtButtom = Color.New(255 / 0xff, 34 / 0xff, 34 / 0xff)

-- 英雄受伤害颜色,上下
function ColorDataManager.GetHeroHurtColor()
    return heroHurtTop, heroHurtButtom;
end


local petHurtTop = Color.New(245 / 0xff, 190 / 0xff, 253 / 0xff)
local petHurtButtom = Color.New(231 / 0xff, 129 / 0xff, 253 / 0xff)

-- 英雄受伤害颜色,上下
function ColorDataManager.GetPetHurtColor()
    return petHurtTop, petHurtButtom;
end

local heroCritTop = Color.New(255 / 0xff, 157 / 0xff, 157 / 0xff)
local heroCritButtom = Color.New(255 / 0xff, 34 / 0xff, 34 / 0xff)

-- 英雄暴击受伤害颜色,上下
function ColorDataManager.GetHeroCritHurtColor()
    return heroCritTop, heroCritButtom;
end

local heroFatalTop = Color.New(255 / 0xff, 157 / 0xff, 157 / 0xff)
local heroFatalButtom = Color.New(255 / 0xff, 34 / 0xff, 34 / 0xff)

-- 英雄必杀受伤害颜色,上下
function ColorDataManager.GetHeroFatalHurtColor()
    return heroFatalTop, heroFatalButtom;
end

local heroMissTop = Color.New(125 / 0xff, 253 / 0xff, 255 / 0xff)
local heroMissButtom = Color.New(0 / 0xff, 210 / 0xff, 255 / 0xff)

-- 英雄闪避颜色,上下
function ColorDataManager.GetHeroMissColor()
    return heroMissTop, heroMissButtom;
end

local heroAbsorptionTop =  Color.New(114 / 0xff, 255 / 0xff, 200 / 0xff)
local heroAbsorptionButtom =  Color.New(108 / 0xff, 255 / 0xff, 0 / 0xff)

--英雄吸收颜色,上下
function ColorDataManager.GetHeroAbsorptionColor()
    return heroAbsorptionTop, heroAbsorptionButtom;
end

local fightTreatTop = Color.New(114 / 0xff, 255 / 0xff, 200 / 0xff)
local fightTreatButtom = Color.New(108 / 0xff, 255 / 0xff, 0 / 0xff)

-- 受治疗颜色,上下
function ColorDataManager.GetFightTreatColor()
    return fightTreatTop, fightTreatButtom;
end

-- 输入为颜色 如 Color.New(215 / 255,218 / 255,200 / 255)
function ColorDataManager.ConventToColorCode(color)
    local temp = ""

    temp = string.format("%02x%02x%02x", math.round(color.r * 255),
    math.round(color.g * 255), math.round(color.b * 255))

    return temp
end
  
local clQuality =
 { 
    [1] = ColorDataManager.Get_white(),
    [2] = ColorDataManager.Get_green(),
    [3] = ColorDataManager.Get_blue(),
    [4] = ColorDataManager.Get_purple(),
    [5] = ColorDataManager.Get_golden(),
    [6] = ColorDataManager.Get_orange(),
    [7] = ColorDataManager.Get_red(),
 };

 local clSuitLv =
 { 
    [1] = ColorDataManager.Get_orange(),
    [2] = ColorDataManager.Get_red(),
 };

 local clSuitLvCode =
 { 
    [1] = string.format("[%s]", ColorDataManager.ConventToColorCode(clSuitLv[1])),
    [2] = string.format("[%s]", ColorDataManager.ConventToColorCode(clSuitLv[2])),
 };
 
local clQualityCode = 
{
    [1] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[1])),
    [2] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[2])),
    [3] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[3])),
    [4] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[4])),
    [5] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[5])),
    [6] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[6])),
    [7] = string.format("[%s]", ColorDataManager.ConventToColorCode(clQuality[7])),
}

function ColorDataManager.GetColorBySuit(suit_lev)
    return clSuitLvCode[suit_lev];
end

function ColorDataManager.GetColorByQuality(quality)
    return clQuality[quality + 1];
end

function ColorDataManager.GetColorTextByQuality(quality, txt)
    return ColorDataManager.GetColorCodeByQuality(quality) .. txt .. "[-]"
    --    if quality == 0 then
    --        return "[d7dadc]" .. txt .. "[-]";
    --    elseif quality == 1 then
    --        return "[85c55e]" .. txt .. "[-]";
    --    elseif quality == 2 then
    --        return "[4087df]" .. txt .. "[-]";
    --    elseif quality == 3 then
    --        return "[b168f5]" .. txt .. "[-]";
    --    elseif quality == 4 then
    --        return "[e69e57]" .. txt .. "[-]";
    --    elseif quality == 5 then
    --        return "[f79727]" .. txt .. "[-]";
    --    elseif quality == 6 then
    --        return "[c0392b]" .. txt .. "[-]";
    --    end
end

-- 输入颜色，文本 转化成带颜色码的文本
function ColorDataManager.GetColorText(color, txt)
    local temp = ""
    temp = "[" .. ColorDataManager.ConventToColorCode(color) .. "]" .. txt .. "[-]"
    return temp;
end



function ColorDataManager.GetColorCodeByQuality(quality)
    
    return clQualityCode[quality + 1]
end

-- 图标灰化
function ColorDataManager.SetGray(uiSpirte)
    uiSpirte.color = ColorDataManager.grayColor
end 

function ColorDataManager.UnSetGray(uiSpirte)
    uiSpirte.color = ColorDataManager.ungrayColor
end 


local PetTitleColor =
{
    [1] = Color.New(215 / 255,218 / 255,200 / 255),
    [2] = Color.New(123 / 255,197 / 255,94 / 255),
    [3] = Color.New(64 / 255,135 / 255,223 / 255),
    [4] = Color.New(177 / 255,104 / 255,245 / 255),
    [5] = Color.New(230 / 255,158 / 255,87 / 255),
    [6] = Color.New(247 / 255,151 / 255,39 / 255),
    [7] = Color.New(192 / 255,57 / 255,43 / 255),
}
function ColorDataManager.GetPetTitleColor(rank)
    if (rank >= 1 and rank <= 3) then
        return PetTitleColor[1]
    elseif (rank >= 4 and rank <= 6) then
        return PetTitleColor[2]
    elseif (rank >= 7 and rank <= 9) then
        return PetTitleColor[3]
    elseif (rank >= 10 and rank <= 12) then
        return PetTitleColor[4]
    elseif (rank >= 13 and rank <= 15) then
        return PetTitleColor[5]
    elseif (rank >= 16 and rank <= 18) then
        return PetTitleColor[6]
    elseif (rank >= 19 and rank <= 21) then
        return PetTitleColor[7]
    else
        return PetTitleColor[1]
    end
end

function ColorDataManager.GetPetTitleColorCode(rank)
    return ColorDataManager.ConventToColorCode(CommonColor.GetPetTitleColor(rank))
end


local qulityEffectColor =
{
    [1] = { ["bc"] = Color.New(204 / 255, 234 / 255, 246 / 255), ["tc"] = Color.New(255 / 255, 255 / 255, 255 / 255), ["ec"] = Color.New(75 / 255, 131 / 255, 277 / 255, 128 / 255) },
    [2] = { ["bc"] = Color.New(49 / 255, 228 / 255, 36 / 255), ["tc"] = Color.New(233 / 255, 255 / 255, 215 / 255), ["ec"] = Color.New(36 / 255, 130 / 255, 53 / 255, 128 / 255) },
    [3] = { ["bc"] = Color.New(44 / 255, 133 / 255, 255 / 255), ["tc"] = Color.New(228 / 255, 249 / 255, 255 / 255), ["ec"] = Color.New(16 / 255, 41 / 255, 210 / 255, 128 / 255) },
    [4] = { ["bc"] = Color.New(137 / 255, 59 / 255, 255 / 255), ["tc"] = Color.New(237 / 255, 228 / 255, 255 / 255), ["ec"] = Color.New(113 / 255, 23 / 255, 155 / 255, 128 / 255) },
    [5] = { ["bc"] = Color.New(239 / 255, 246 / 255, 38 / 255), ["tc"] = Color.New(254 / 255, 255 / 255, 228 / 255), ["ec"] = Color.New(157 / 255, 128 / 255, 13 / 255, 128 / 255) },
    [6] = { ["bc"] = Color.New(255 / 255, 172 / 255, 28 / 255), ["tc"] = Color.New(255 / 255, 249 / 255, 228 / 255), ["ec"] = Color.New(191 / 255, 112 / 255, 0 / 255, 128 / 255) },
}

-- 获取品质UILabel效果颜色
function ColorDataManager.GetQulityEffectColor(qulity)
    return qulityEffectColor[qulity];
end


 


local RealmEffectColor =
{
    [1] = { ["bc"] = Color.New(204 / 255, 234 / 255, 246 / 255), ["tc"] = Color.New(255 / 255, 255 / 255, 255 / 255), ["ec"] = Color.New(75 / 255, 131 / 255, 277 / 255, 128 / 255) },
    [2] = { ["bc"] = Color.New(49 / 255, 228 / 255, 36 / 255), ["tc"] = Color.New(233 / 255, 255 / 255, 215 / 255), ["ec"] = Color.New(36 / 255, 130 / 255, 53 / 255, 128 / 255) },
    [3] = { ["bc"] = Color.New(44 / 255, 133 / 255, 255 / 255), ["tc"] = Color.New(228 / 255, 249 / 255, 255 / 255), ["ec"] = Color.New(16 / 255, 41 / 255, 210 / 255, 128 / 255) },
    [4] = { ["bc"] = Color.New(137 / 255, 59 / 255, 255 / 255), ["tc"] = Color.New(237 / 255, 228 / 255, 255 / 255), ["ec"] = Color.New(113 / 255, 23 / 255, 155 / 255, 128 / 255) },
    [5] = { ["bc"] = Color.New(239 / 255, 246 / 255, 38 / 255), ["tc"] = Color.New(254 / 255, 255 / 255, 228 / 255), ["ec"] = Color.New(157 / 255, 128 / 255, 13 / 255, 128 / 255) },
    [6] = { ["bc"] = Color.New(255 / 255, 172 / 255, 28 / 255), ["tc"] = Color.New(255 / 255, 249 / 255, 228 / 255), ["ec"] = Color.New(191 / 255, 112 / 255, 0 / 255, 128 / 255) },
    [7] = { ["bc"] = Color.New(255 / 255, 28 / 255, 28 / 255), ["tc"] = Color.New(255 / 255, 232 / 255, 228 / 255), ["ec"] = Color.New(140 / 255, 0 / 255, 0 / 255, 128 / 255) },
}

local RealmTitleEffectColor =
{
    [1] = { ["bc"] = Color.New(204 / 255, 234 / 255, 246 / 255), ["tc"] = Color.New(255 / 255, 255 / 255, 255 / 255), ["ec"] = Color.New(75 / 255, 131 / 255, 277 / 255, 128 / 255) },
    [2] = { ["bc"] = Color.New(49 / 255, 228 / 255, 36 / 255), ["tc"] = Color.New(233 / 255, 255 / 255, 215 / 255), ["ec"] = Color.New(36 / 255, 130 / 255, 53 / 255, 128 / 255) },
    [3] = { ["bc"] = Color.New(44 / 255, 133 / 255, 255 / 255), ["tc"] = Color.New(228 / 255, 249 / 255, 255 / 255), ["ec"] = Color.New(16 / 255, 41 / 255, 210 / 255, 128 / 255) },
    [4] = { ["bc"] = Color.New(137 / 255, 59 / 255, 255 / 255), ["tc"] = Color.New(237 / 255, 228 / 255, 255 / 255), ["ec"] = Color.New(113 / 255, 23 / 255, 155 / 255, 128 / 255) },
    [5] = { ["bc"] = Color.New(239 / 255, 246 / 255, 38 / 255), ["tc"] = Color.New(254 / 255, 255 / 255, 228 / 255), ["ec"] = Color.New(157 / 255, 128 / 255, 13 / 255, 128 / 255) },
    [6] = { ["bc"] = Color.New(255 / 255, 172 / 255, 28 / 255), ["tc"] = Color.New(255 / 255, 249 / 255, 228 / 255), ["ec"] = Color.New(191 / 255, 112 / 255, 0 / 255, 128 / 255) },
    [7] = { ["bc"] = Color.New(255 / 255, 28 / 255, 28 / 255), ["tc"] = Color.New(255 / 255, 232 / 255, 228 / 255), ["ec"] = Color.New(140 / 255, 0 / 255, 0 / 255, 128 / 255) },
}

-- 获取境界UILabel效果颜色
function ColorDataManager.GetRealmEffectColor(qulity)
    return RealmEffectColor[qulity];
end

function ColorDataManager.GetRealmTitleEffectColor(qulity)
    return RealmTitleEffectColor[qulity];
end

local RealmMeridiansEffectColor =
{
    [1] = Color.New(255 / 255, 255 / 255, 255 / 255),
    [2] = Color.New(21 / 255, 255 / 255, 0 / 255),
    [3] = Color.New(0 / 255, 76 / 255, 255 / 255),
    [4] = Color.New(255 / 255, 25 / 255, 255 / 255),
    [5] = Color.New(255 / 255, 72 / 255, 0 / 255),
}

-- 获取境界UILabel效果颜色
function ColorDataManager.GetRealmMeridiansEffectColor(qulity)
    return RealmMeridiansEffectColor[qulity];
end


local CampColor =
{
    [0] = Color.New(255 / 255,255 / 255,255 / 255),
    [1] = Color.New(255 / 255,75 / 255,64 / 255),
    [2] = Color.New(98 / 255,210 / 255,255 / 255),
}

-- 获阵营颜色
function ColorDataManager.GetCampColor(id)
    if (CampColor[id]) then
        return CampColor[id];
    end
    return CampColor[0];
end