Require("CommonScript/Player/PlayerEventRegister.lua");

XiuLian.tbDef = XiuLian.tbDef or {};
local tbDef = XiuLian.tbDef;
--- 策划填写-----------------------------
tbDef.nAddExpPercent = 2000; --击杀野怪的经验倍率
tbDef.nAddDropPercent = 10000; --击杀野怪的掉落的增加倍率
tbDef.nPerDayAddTime = 3 * 60 * 60; --一天增加的修炼时间
tbDef.nMaxAddXiuLianTime = 15 * 60 * 60; --最多累加多长时间
tbDef.szTimeUpdateTime = "4:00"; --每天更新的时间
tbDef.nXiuLianBuffId = 199; --修炼BUFF
tbDef.nXiuLianBuffLevel = 1;
tbDef.nMaxOpenTime = 8 * 60 * 60; --玩家身上最多开启时间
tbDef.nPerOpenXiuLianTime = 30 * 60; --每次开启时间
tbDef.nXiuLianLevel = 5; --获得修炼珠等级
tbDef.tbMailItem = {{"item", 1422, 1},{"item", 2399, 1},{"item", 998070, 1},{"item", 3700, 1}}; --发送修炼珠+枣红马,{"VipExp", 100, 1}
tbDef.nXiuLianExpTiLi = 10000; --每30分钟经验上限（体力基准经验）
tbDef.nJingYingRateCount = 3;  --每30分钟最多3只精英享有10次掉落
tbDef.nJingYingDropCount = 50; --精英的掉落数
tbDef.szXiuLianAchievement = "XiuLian_1"; --修炼成就
tbDef.szXiuLianEveryDay = "XiuLian"; --修炼每日目标
tbDef.nXiuLianDanID = 2301; --修炼丹ID
-------End-------------------------------------

tbDef.nSaveGroupID = 49;
tbDef.nSaveLastTakeTime = 5;
tbDef.nSaveResidueTime  = 6;
tbDef.nSaveResidueExp   = 7;
tbDef.nSaveJingYing     = 8;

function XiuLian:LoadSetting()

end

XiuLian:LoadSetting();

function XiuLian:GetXiuLianResidueTime(pPlayer)
    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveLastTakeTime);
    local nParseTodayTime = Lib:ParseTodayTime(tbDef.szTimeUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = 0;
    if nLastTime == 0 then
        nUpdateLastDay = nUpdateDay - 1;
    else
        nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));
    end

    local nResidueTime    = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueTime);
    local nAddDay = math.abs(nUpdateDay - nUpdateLastDay);
    if nAddDay == 0 then
        return nResidueTime;
    end

    local nAddResiduTime = nAddDay * tbDef.nPerDayAddTime;
    nResidueTime = nResidueTime + nAddResiduTime;
    nResidueTime = math.min(nResidueTime, tbDef.nMaxAddXiuLianTime);

    if MODULE_GAMESERVER then
        pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveLastTakeTime, nTime);
        pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueTime, nResidueTime);
    end

    return nResidueTime;
end

function XiuLian:AddXiuLianResiduTime(pPlayer, nAddResiduTime)
    local nResidueTime = self:GetXiuLianResidueTime(pPlayer);
    nResidueTime = nResidueTime + nAddResiduTime;
    nResidueTime = math.min(nResidueTime, tbDef.nMaxAddXiuLianTime);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueTime, nResidueTime);
    Log("XiuLian AddXiuLianResiduTime", pPlayer.dwID, nAddResiduTime);
end

function XiuLian:CheckOpenXiuLian(pPlayer, nOpenTime, nResidueExp)
    if tbDef.nXiuLianLevel > pPlayer.nLevel then
        return false, string.format("等级不足%s", tbDef.nXiuLianLevel);
	end


	if nResidueExp + tbDef.nXiuLianExpTiLi * pPlayer.GetBaseAwardExp() >= 2147483647 then
		return false, "开启的经验已达上限";
	end

    local nResidueTime = self:GetXiuLianResidueTime(pPlayer);
    if nOpenTime > nResidueTime then
        return false, "剩余修炼时间不足";
    end

    local nStateTime = self:GetCurXiuLianTime(pPlayer)
    nStateTime = nStateTime + nOpenTime;
    if nStateTime >= tbDef.nMaxOpenTime then
        return false, string.format("最多开启%s小时修炼时间", math.floor(tbDef.nMaxOpenTime / 60 / 60));
    end

    local bRet = Map:IsFieldFightMap(pPlayer.nMapTemplateId);
    if not bRet then
        return false, "请前往野外地图再开启修炼";
    end

    return true, "";
end

function XiuLian:GetCurXiuLianTime(pPlayer)
    local pNpc = pPlayer.GetNpc();
    local tbSkillState = pNpc.GetSkillState(tbDef.nXiuLianBuffId);
    if not tbSkillState then
        return 0;
    end

    local nStateFrame = (tbSkillState.nEndFrame - GetFrame());
    local nStateTime = math.floor(nStateFrame / Env.GAME_FPS);
	
	--时间非法就修复
	if (nStateTime > tbDef.nMaxAddXiuLianTime) then
	    --Log("EEEEEEEEEE[GetCurXiuLianTime]", nStateTime)
		pNpc.RemoveSkillState(tbDef.nXiuLianBuffId);
        return 0;
	end
	
    return nStateTime;
end

function XiuLian:IsXiuLianTime(pPlayer)
    local nStateTime = self:GetCurXiuLianTime(pPlayer);
    if nStateTime <= 0 then
        return false;
    end

    return true;
end

function XiuLian:GetAddDropRateP(pPlayer)
    local bRet = self:IsXiuLianTime(pPlayer);
    if not bRet then
        return 0;
    end

    return tbDef.nAddDropPercent;
end

function XiuLian:CanBuyXiuLianDan(pPlayer)
    local nResidueTime = XiuLian:GetXiuLianResidueTime(pPlayer);
    local tbItem = Item:GetClass("XiuLianDan");
    local nCount = tbItem:GetOpenResidueCount(pPlayer);
    local nOpenTime = tbDef.nPerOpenXiuLianTime;
    if nOpenTime > nResidueTime and nCount > 0 then
        return true;
    end

    return false;
end

function XiuLian:OpenXiuLianTime(pPlayer)
    local nOpenTime = tbDef.nPerOpenXiuLianTime;
	local nResidueExp = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueExp);
	nResidueExp = math.max(0, nResidueExp) -- 复位错误的

    local bRet, szMsg  = self:CheckOpenXiuLian(pPlayer, nOpenTime, nResidueExp);
    if not bRet then
        local bRet1 = self:CanBuyXiuLianDan(pPlayer);
        if bRet1 then
            local nCount, tbDanItem = pPlayer.GetItemCountInBags(tbDef.nXiuLianDanID);
            if nCount > 0 and tbDanItem and tbDanItem[1] then
                pPlayer.CallClientScript("Ui:OpenWindow", "ItemTips", "Item", tbDanItem[1].dwId, tbDef.nXiuLianDanID);
            else
                pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Treasure", "tabAllShop", tbDef.nXiuLianDanID);
            end
        else
            pPlayer.CenterMsg(szMsg);
        end

        return;
    end

    local nResidueTime = self:GetXiuLianResidueTime(pPlayer);
    local nCurResidueTime = nResidueTime - nOpenTime;
    nCurResidueTime = math.max(nCurResidueTime, 0);

    local nCurOpenTime = nResidueTime - nCurResidueTime;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueTime, nCurResidueTime);

    nResidueExp = nResidueExp + tbDef.nXiuLianExpTiLi * pPlayer.GetBaseAwardExp();

    local nResidueJingYing = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJingYing);
    nResidueJingYing = nResidueJingYing + tbDef.nJingYingRateCount;

    local pNpc = pPlayer.GetNpc();
    local nCurXiuLianTime = self:GetCurXiuLianTime(pPlayer);
    nCurXiuLianTime = nCurXiuLianTime + nCurOpenTime;
	--技能Id, 等级, 状态类型(类型为0取的是表中时间,1取的是后面自定义时间), 时间, 死亡后是否消失, 覆盖原技能效果.
    pNpc.AddSkillState(tbDef.nXiuLianBuffId, tbDef.nXiuLianBuffLevel, FightSkill.STATE_TIME_TYPE.state_time_gametime, nCurXiuLianTime * Env.GAME_FPS, 1, 1);

    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueExp, nResidueExp);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJingYing, nResidueJingYing);
    pPlayer.CenterMsg("你开启了30分钟修炼时间");
    pPlayer.CallClientScript("XiuLian:UpdateInfo");
    Achievement:AddCount(pPlayer, tbDef.szXiuLianAchievement, 1);
    EverydayTarget:AddCount(pPlayer, tbDef.szXiuLianEveryDay);
    TeacherStudent:TargetAddCount(pPlayer, "OpenXiuLian", 1)
    pPlayer.TLogRoundFlow(Env.LogWay_XiuLian, 0, 0, 0, Env.LogRound_SUCCESS, 0, 0);
    Log("XiuLian OpenXiuLianTime", pPlayer.dwID, nResidueExp, pPlayer.nLevel, nCurXiuLianTime, nCurResidueTime, nCurOpenTime);
end

function XiuLian:OnPlayerLevelUp(pPlayer, nLevel)
    if nLevel ~= tbDef.nXiuLianLevel then
        return;
    end

    Mail:SendSystemMail({
        To = pPlayer.dwID,
        Title = "修炼珠",
        Text = [==[    能提升10倍野外打怪修炼速度的神奇珠子，江湖人称之为【修炼珠】。修炼珠每天4:00自动恢复1小时的修炼时间，最多只能累积7小时的修炼时间，且修炼状态只在“野外地图”击杀野怪时生效。]==],
        From = "纳兰真",
        tbAttach = tbDef.tbMailItem,
    })

    self:GetXiuLianResidueTime(pPlayer);
    local tbItem = Item:GetClass("XiuLianDan");
    tbItem:GetOpenResidueCount(pPlayer);
    Log("XiuLian OnPlayerLevelUp", pPlayer.dwID, nLevel);
end

function XiuLian:ResetResidueExp(pPlayer, szExtMsg)
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueExp, 0);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJingYing, 0);
    Log("XiuLian ResetResidueExp", pPlayer.dwID, szExtMsg or "Buff");
end

function XiuLian:CalcXiuLianDrop(pPlayer, nIsTransBossNpc)
    local nResidueJingYing = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJingYing);
    local bXiuLian = XiuLian:IsXiuLianTime(pPlayer)
    local nTreasureCount = 5;
    local bXiuLianRate   = false;
    if not bXiuLian then
        if nResidueJingYing > 0 then
            XiuLian:ResetResidueExp(pPlayer, "XiuLianRandom");
        end

        return nTreasureCount, bXiuLianRate;
    end

    if nIsTransBossNpc == 1 then
        if nResidueJingYing > 0 then
            nTreasureCount = tbDef.nJingYingDropCount;
            nResidueJingYing = nResidueJingYing - 1;
            pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJingYing, nResidueJingYing);
        end
    else
        bXiuLianRate = true;
    end

    return nTreasureCount, bXiuLianRate;
end

function XiuLian:CalcXiuLianExpAddP(pPlayer, nCalcExp)
    local nXiuLianExp = 0;
    local nResidueExp = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueExp);
    local bRet        = XiuLian:IsXiuLianTime(pPlayer);
    if bRet then
        if nResidueExp > 0 then
            local nExpXiuLianAddP = tbDef.nAddExpPercent - 100;
            nExpXiuLianAddP = math.max(nExpXiuLianAddP, 0);
            nXiuLianExp = nCalcExp * (100 + nExpXiuLianAddP) / 100;
            if nXiuLianExp > nResidueExp then
                nXiuLianExp = nResidueExp;
            end

            nResidueExp = nResidueExp - nXiuLianExp;
            nResidueExp = math.floor(nResidueExp);
            if nResidueExp <= 0 then
                nResidueExp = 0;
            end
            pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveResidueExp, nResidueExp);
        end
    else
        if nResidueExp > 0 then
            XiuLian:ResetResidueExp(pPlayer, "Exp");
        end
    end

    local nCurExp = nCalcExp;
    if nXiuLianExp > nCurExp then
        nCurExp = nXiuLianExp;
    end
    return nCurExp;
end

function XiuLian:UpdateInfo()
    if Ui:WindowVisible("FieldPracticePanel") == 1 then
        Ui("FieldPracticePanel"):UpdateInfo();
    end
end

function XiuLian:OnLogin()
    if me.nLevel < tbDef.nXiuLianLevel then
        return;
    end

    local tbItem = Item:GetClass("XiuLianDan");
    tbItem:GetOpenResidueCount(me);
end

if MODULE_GAMESERVER then
PlayerEvent:RegisterGlobal("OnLogin",  XiuLian.OnLogin, XiuLian);
end
