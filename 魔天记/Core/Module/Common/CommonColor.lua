-- 通用颜色代码 下标从0开始 对应后台物品品质
CommonColor =
{
}

CommonColor.QualityColor =
{
    [0] = Color.New(255 / 255,255 / 255,255 / 255),
    [1] = Color.New(119 / 255,255 / 255,71 / 255),
    [2] = Color.New(52 / 255,224 / 255,255 / 255),
    [3] = Color.New(229 / 255,123 / 255,255 / 255),
    [4] = Color.New(255 / 255,246 / 255,0 / 255),
}

CommonColor.PetTitleColor =
{
    [1] = Color.New(255 / 255,255 / 255,255 / 255),
    [2] = Color.New(119 / 255,255 / 255,71 / 255),
    [3] = Color.New(52 / 255,224 / 255,255 / 255),
    [4] = Color.New(229 / 255,123 / 255,255 / 255),
    [5] = Color.New(255 / 255,246 / 255,0 / 255),
    [6] = Color.New(255 / 255,168 / 255,17 / 255),
    [7] = Color.New(255 / 255,75 / 255,75 / 255),
}

function CommonColor.GetPetTitleColor(rank)
    if (rank >= 1 and rank <= 3) then
        return CommonColor.PetTitleColor[1]
    elseif (rank >= 4 and rank <= 6) then
        return CommonColor.PetTitleColor[2]
    elseif (rank >= 7 and rank <= 9) then
        return CommonColor.PetTitleColor[3]
    elseif (rank >= 10 and rank <= 12) then
        return CommonColor.PetTitleColor[4]
    elseif (rank >= 13 and rank <= 15) then
        return CommonColor.PetTitleColor[5]
    elseif (rank >= 16 and rank <= 18) then
        return CommonColor.PetTitleColor[6]
    elseif (rank >= 19 and rank <= 21) then
        return CommonColor.PetTitleColor[7]
    else
        return CommonColor.PetTitleColor[1]
    end
end

function CommonColor.GetPetTitleColorCode(rank)
    return CommonColor.ConventToColorCode(CommonColor.GetPetTitleColor(rank))
end

-- 输入为颜色 如 Color.New(215 / 255,218 / 255,200 / 255)
function CommonColor.ConventToColorCode(color)
    local temp = ""
    temp = string.format("%x%x%x", math.round(color.r * 255), math.round(color.g * 255), math.round(color.b * 255))
    return temp
end

-- txt 文本 color 颜色 Color.New(215 / 255,218 / 255,200 / 255)
function CommonColor.GetColorText(color, txt)
    local temp = "[%s]%s[-]"
    temp = string.format(temp, CommonColor.ConventToColorCode(color), txt)
    return temp;
end

--function ColorDataManager.GetColorTextByQuality(quality, txt)

--    if quality == 0 then
--        return "[FFFFFF]" .. txt .. "[-]";
--    elseif quality == 1 then
--        return "[77FF47]" .. txt .. "[-]";
--    elseif quality == 2 then
--        return "[34E0FF]" .. txt .. "[-]";
--    elseif quality == 3 then
--        return "[E57BFF]" .. txt .. "[-]";
--    elseif quality == 4 then
--        return "[FFF600]" .. txt .. "[-]";
--    elseif quality == 5 then
--        return "[FFA811]" .. txt .. "[-]";
--    elseif quality == 6 then
--     return "[C0392B]" .. txt .. "[-]";
--    end


--end


function CommonColor.TryButtonEnable(go, bool)
    local spr = UIUtil.GetComponent(go, "UISprite");
    if spr then
        if bool then
            ColorDataManager.SetGray(spr); 
        else
            ColorDataManager.UnSetGray(spr);     
        end
    end

    local collider = UIUtil.GetComponent(go, "BoxCollider");
    if collider then
        collider.enabled = bool;
    end

    local ubc = UIUtil.GetComponent(go, "UIButtonColor");
    if ubc then
        ubc.defaultColor = bool and ColorDataManager.ungrayColor or ColorDataManager.grayColor;
    end
end