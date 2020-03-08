Require("CommonScript/Player/PlayerEventRegister.lua");
local SdkMgr = luanet.import_type("SdkInterface");

function PlayerEvent:OnLogin(nIsReconnect)
    self.bLogin = true;
    if self.tbMapOnEnterParam then
        Lib:CallBack({Map.OnEnter, Map, unpack(self.tbMapOnEnterParam)});
        self.tbMapOnEnterParam = nil;
    end
    -- 玩家在野外时登陆改变战斗状态的时候会在uservalue同步之前调GetVipLevel()导致vip等级不对，所以必须放在前面保证下面的函数调用的时候vip等级正确
    Lib:CallBack({Recharge.OnLogin, Recharge});
    if nIsReconnect == 0 then
        Lib:CallBack({Guide.OnLogin, Guide});
    end
    if nIsReconnect ~= 1 then
        Lib:CallBack({Map.OnLogin, Map});
    end
    Lib:CallBack({LoginAwards.OnLogin, LoginAwards});
    Lib:CallBack({Recharge.CheckCanBuyVipAward, Recharge}) --特权礼包红点检查
    Lib:CallBack({Partner.UpdateRedPoint, Partner});
    Lib:CallBack({Strengthen.OnLogin, Strengthen, me})
    Lib:CallBack({Item.GoldEquip.OnLogin, Item.GoldEquip, me})

    Lib:CallBack({EverydayTarget.OnLogin, EverydayTarget})
    Lib:CallBack({WelfareActivity.OnLogin, WelfareActivity, nIsReconnect == 1})
    Lib:CallBack({MarketStall.OnLogin, MarketStall, nIsReconnect == 1})
    Lib:CallBack({Player.OnLogin_SafeCall, Player, nIsReconnect});
    Lib:CallBack({Compose.ValueCompose.CheckShowRedPoint, Compose.ValueCompose});       --任务红点检查
    Lib:CallBack({Achievement.CheckRedPoint, Achievement});
    Lib:CallBack({Kin.StartRedPointTimer, Kin})
    Lib:CallBack({OnHook.OnLogin, OnHook, nIsReconnect == 1});
    Lib:CallBack({ChuangGong.OnLogin, ChuangGong, nIsReconnect == 1})
    Lib:CallBack({Sdk.OnLogin, Sdk, nIsReconnect == 1})
    Lib:CallBack({Kin.RedBagOnLogin, Kin})
    Lib:CallBack({NewInformation.OnLogin, NewInformation})
    Lib:CallBack({SeriesFuben.OnLogin, SeriesFuben})
    Lib:CallBack({Kin.OnLogin, Kin})
    Lib:CallBack({Sdk.GsdkInit, Sdk})
    Lib:CallBack({ArenaBattle.OnLogin, ArenaBattle})
    Lib:CallBack({Player.CheckMoneyDebtBuff, Player})
    Lib:CallBack({HuaShanLunJian.RequestHSLJStateInfo, HuaShanLunJian, true});
    SendBless.dwSynRoleId = nil;
    Lib:CallBack({ChatMgr.ChatDecorate.OnLogin, ChatMgr.ChatDecorate, nIsReconnect == 1})
    Lib:CallBack({ChatMgr.OnLogin, ChatMgr, nIsReconnect == 1})
    Lib:CallBack({House.OnLogin, House, nIsReconnect == 1});
    Lib:CallBack({Wedding.OnLogin, Wedding, nIsReconnect == 1});
    Lib:CallBack({AddictionTip.OnClientLogin, AddictionTip});
    Lib:CallBack({ZhenFa.OnLogin, ZhenFa});
    Lib:CallBack({Activity.LabaAct.OnLogin, Activity.LabaAct});
    Lib:CallBack({Toy.OnLogin, Toy, nIsReconnect == 1})
    --@_@ 经脉刷新
    --Lib:CallBack({JingMai.OnLogin, JingMai})

    if Ui.nLockScreenState then
        Ui:OpenWindow("LockScreenPanel")
    end

    local nDay = tonumber(os.date("%d", GetTime()))
    if IOS and nDay ~= Client:GetFlag("PAY_WARNNING") and me.nLevel >= 14 and not version_kor then
        Client:SetFlag("PAY_WARNNING", nDay)
        --me.Msg("腾讯公司将会严厉打击使用第三方代充的相关行为，包括采取“扣除代充的元宝、限制游戏权限、短期封号、永久封号” 等措施。如需充值，请使用游戏内苹果官方渠道充值！");
    end

    SdkMgr.ReportDataEnterGame("0", Sdk:GetCurAppId(),  tostring(SERVER_ID), Login.szReportRoleList)

    if nIsReconnect == 1 then
        Ui:CloseWindow("QuickUseItem")
        Ui:CloseWindow("FloatingWindowDisplay")
        if me.dwKinId<=0 then
            Ui:CloseWindow("KinDetailPanel")
        end
        Ui:CloseWindow("ProgressBarPanel");
    end

    local pPlayerNpc = me.GetNpc();
    if pPlayerNpc then
        Lib:CallBack({AutoFight.UpdateSkillSetting, AutoFight});
    end

    Lib:CallBack({WeatherMgr.OnLogin, WeatherMgr});
    Lib:CallBack({Operation.OnLogin, Operation});
    Lib:CallBack({JueXue.OnLogin, JueXue, me});
    Lib:CallBack({PartnerCard.OnLogin, PartnerCard, me});
    Lib:CallBack({Ui.tbTaskListener.OnLogin, Ui.tbTaskListener});
    --Lib:CallBack({Item.tbChangeColor.OnLogin, Item.tbChangeColor, me})
    --Lib:CallBack({Furniture.Cook.OnLogin, Furniture.Cook, me, nIsReconnect == 1})
end

function PlayerEvent:OnLogout()
    self.bSuperVip = nil
    Lib:CallBack({PartnerCard.OnLogout, PartnerCard, me});
    Lib:CallBack({Toy.OnLogout, Toy})
    --Lib:CallBack({Reunion.OnLogout, Reunion})  --重逢;团聚;聚会
end

function PlayerEvent:SetSuperVip(bSuperVip)
    if not version_tx then return end

    self.bSuperVip = bSuperVip
    UiNotify.OnNotify(UiNotify.emNOTIFY_SUPERVIP_CHANGE)

    local bLastSuperVip = Client:GetFlag("bLastSuperVip", me.dwID)
    if bLastSuperVip~=bSuperVip then
        if bSuperVip then
            Ui:SetRedPointNotify("SuperVip")
        end
        Client:SetFlag("bLastSuperVip", bSuperVip, me.dwID, false)
    end
end

function PlayerEvent:OnSyncOrgServerId(nOrgServerId)
    Env.nOrgServerId = nOrgServerId;
end

function PlayerEvent:OnDeath(pKiller)

end

function PlayerEvent:OnShapeShift(nNpcTemplateID, nType)
    if IsAlone() == 1 then
        ActionMode:DoForceNoneActMode(me);
    end
end

function PlayerEvent:OnLevelUp(nNewLevel)
    print("PlayerEvent:OnLevelUp", nNewLevel)
    Guide:OnLevelUp(nNewLevel);
    -- Ui:OpenWindow("PlayerLevelUp")
    -- Ui:OpenWindow("LevelUpPopup", "shengji")
    Partner:UpdateRedPoint();
    ChangeName:CheckShowRedPoint();
    WelfareActivity:OnLevelUp()
    Ui.SoundManager.PlayUISound(8008);
    Player:FlyChar(nNewLevel)
    NewInformation:PushLocalInformation()
    Activity:CheckRedPoint();
    TeamMgr:OnMyInfoChange()
    Recharge:CheckNewLevel()
    Sdk:OnLevelUp();
    TeacherStudent:OnLevelUp()
    ChatMgr.ChatDecorate:ChatDecorateGuide(nNewLevel)
    PartnerCard:OnLevelUp()
end

function PlayerEvent:StartAutoPath(nDesX, nDesY, nPathLen, nPathSize)
    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    if IsAlone() == 0 then
        if not Map:IsForbidRide(me.nMapTemplateId) and nPathLen > AutoRunSpeed.tbDef.nMinRunLen and not House:IsIndoor(me) then
            local pEquip = me.GetEquipByPos(Item.EQUIPPOS_HORSE);
            if pEquip then
                ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_ride);
            end
        end

        local bRet = AutoRunSpeed:CheckCanMapRunSpeed(me, nPathLen)
        if bRet then
            RemoteServer.StartMapAutoRunSpeed(nDesX, nDesY, nPathLen);
            me.bStartAutoRunSpeed = true;
        end
    end

    if nPathLen >= 2000 then
        me.bStartAutoPath = true;
        Player:UpdateHeadState();
    end
end

function PlayerEvent:StopAutoPath(nStopType)
    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    if IsAlone() == 0 then
        local nMapTID = pNpc.nMapTemplateId;
        if Map:IsRunSpeedMap(nMapTID) and me.bStartAutoRunSpeed then
            RemoteServer.StopMapAutoRunSpeed();
            me.bStartAutoRunSpeed = false;
        end
    end

    me.bStartAutoPath = false;
    Player:UpdateHeadState();
end

function PlayerEvent:GetCloseToNpcTb()
    if not self.tbCloseToNpc then
        self.tbCloseToNpc = LoadTabFile("Setting/Npc/NearToTips.tab", "d", "nNpcTemplateId", {"nNpcTemplateId"});
    end
    return self.tbCloseToNpc
end

function PlayerEvent:OnCloseToNpc(nCurNpcId, nCurNpcTemplateId, nLastNpcId)
    self:GetCloseToNpcTb()

    if nCurNpcId > 0 and not self.tbCloseToNpc[nCurNpcTemplateId] then
        nCurNpcId = 0;
        nCurNpcTemplateId = 0;
    end

    if nCurNpcId > 0 and Ui:WindowVisible("RoleHeadPop") ~= 1 then
        Ui:OpenWindow("RoleHeadPop", {nCurNpcId}, true, true);
    else
        UiNotify.OnNotify(UiNotify.emNOTIFY_CLOSE_TO_NCP, nCurNpcId, nLastNpcId);
    end
end

function PlayerEvent:OnChangeFaction(nFactionId, nOldFacionID)
    if Ui:WindowVisible("HomeScreenBattle") == 1 then
        Ui:OpenWindow("HomeScreenBattle");
    end

    if Ui:WindowVisible("RoleHead") == 1 then
        Ui:OpenWindow("RoleHead");
    end

    local tbOrgPos = AutoFight:ClearAutoSetting();
    AutoFight.tbOrgSetting = tbOrgPos;
    AutoFight:GetSetting()
    AutoFight.tbOrgSetting = nil;
    AutoFight:SaveSetting();
    Log("PlayerEvent OnChangeFaction", nFactionId, nOldFacionID);
end

function PlayerEvent:OnReConnectZoneClient()
    Lib:CallBack({JingMai.UpdatePlayerAttrib, JingMai, me});
    Lib:CallBack({PartnerCard.UpdatePlayerAttribute, PartnerCard, me});
	Lib:CallBack({Strengthen.OnLogin, Strengthen, me, true});
	Lib:CallBack({Item.GoldEquip.OnLogin, Item.GoldEquip, me})
    --@_@ 跨服的绝学和附魔刷新
	--Lib:CallBack({JueXue.OnLogin, JueXue, me})
    --Lib:CallBack({OpenLight.OnClientUpdate, OpenLight})
    Ui:ChangeFightState(me.nFightMode)
    Ui:GetClass("FloatingWindowDisplay").tbShowQueue = {}
    Ui:CloseWindow("FloatingWindowDisplay")
    Ui:CloseWindow("FightPowerTip")
    ChatMgr.nInitPrivateList = 0;
    Achievement:CheckRedPoint()
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end

function PlayerEvent:OnChangeSex(nSex, nOldSex)
end

PlayerEvent:RegisterGlobal("OnLogin",       PlayerEvent.OnLogin, PlayerEvent);
PlayerEvent:RegisterGlobal("OnDeath",       PlayerEvent.OnDeath, PlayerEvent);
PlayerEvent.nRegisterIdOnLevelUp = PlayerEvent:RegisterGlobal("OnLevelUp",     PlayerEvent.OnLevelUp, PlayerEvent);
PlayerEvent:RegisterGlobal("StartAutoPath", PlayerEvent.StartAutoPath, PlayerEvent);
PlayerEvent:RegisterGlobal("StopAutoPath",  PlayerEvent.StopAutoPath, PlayerEvent);
PlayerEvent.nRegisterIdOnCloseToNpc = PlayerEvent:RegisterGlobal("OnCloseToNpc",  PlayerEvent.OnCloseToNpc, PlayerEvent);
PlayerEvent:RegisterGlobal("ShapeShift",    PlayerEvent.OnShapeShift, PlayerEvent);
PlayerEvent:RegisterGlobal("OnChangeFaction",    PlayerEvent.OnChangeFaction, PlayerEvent);
PlayerEvent:RegisterGlobal("OnChangeSex",    PlayerEvent.OnChangeSex, PlayerEvent);

function PlayerEvent:OnSyncServerIsDST(bIsDST)  --服务器是否处于夏令时
    Env.bIsDST = bIsDST
end
