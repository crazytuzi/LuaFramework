DaysRankInfo = { };

function DaysRankInfo.Init(d, type)
    local info = { };
    info.id = d.idx;
    info.type = type;
    info.uid = d.pid;
    info.uName = d.name;
    info.kind = d.k;
    info.value = d.v;
    info.value2 = d.v2;
    info.gName = d.tn;
    return info;
end

function DaysRankInfo.GetMyVal(type, d)
    local info = { };
    info.id = 0;
    for i, v in ipairs(d.l) do
        if v.pid == PlayerManager.playerId then
            info.id = v.idx;
        end
    end

    info.type = type;

    local myInfo = PlayerManager.GetPlayerInfo();
    info.value = 0;
    if type == DaysRankManager.Type.LEVEL then
        info.value = PlayerManager.hero.info.level;
        --[[
	elseif type == DaysRankManager.Type.TRUMP then
        info.value = CalculatePower(NewTrumpManager.GetAllAttrs());

    elseif type == DaysRankManager.Type.EQUIP then
    	info.value = EquipDataManager.GetDaysRankStrength();
         ]]
    elseif type == DaysRankManager.Type.GEM then
        info.value = GemDataManager.GetAllGemLevel();
    elseif type == DaysRankManager.Type.PET then

         local star,rankLevel = PetManager.GetMyStarAndRankLevel();
        info.value = { rankLevel = rankLevel, star = star };
        -- CalculatePower(PetManager.GetFormationPetProperty()) --PetManager.GetDaysRankFormationPower();
    elseif type == DaysRankManager.Type.RMB then
        info.value = d.r and math.ceil(d.r / 100) or 0;

    elseif type == DaysRankManager.Type.WING then
        local w = WingManager.GetCurrentWingData();
        if w then
            info.value = w.rank;
            info.value2 = w.lev;
        else
            info.value = 0;
            info.value2 = 0;
        end

    elseif type == DaysRankManager.Type.FIGHT then
        info.value = PlayerManager.GetSelfFightPower();
    end

    return info;
end
