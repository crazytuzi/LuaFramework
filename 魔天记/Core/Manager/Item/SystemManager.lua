SystemManager = { };
SystemManager.list = nil;
SystemManager.lvList = nil;
SystemManager.taskList = nil;
SystemManager.letter = false -- 有新邮件
SystemManager.tong_ap = false -- 有申请入会代审批

SystemConst = {
    Id =
    {
        ROLE = 1;
        EQUIP = 2;
        SKILL = 3;
        REALM = 4;-- 境界
        PET = 5;-- 伙伴
        FABAO = 6;-- 命星--法宝
        MOUNT = 7;-- 坐骑
        WING = 8;-- 翅膀
        XIANMENG = 9;-- 仙盟
        YAOYUAN = 10;-- 药园
        RANK = 11;-- 排行
        SETTING = 12;-- 设置
        LingYao = 13;-- 灵药
        XINFABAO = 14;-- 新法宝		
        COMPOSE = 15;-- 合成
        WiseEquip = 16;-- 仙器
        Formation = 17;-- 阵图
        SHOP = 50;-- 商城
        LOTTERY = 51;-- 抽奖
        MALL = 52;-- 商城
        DAYSRANK = 53;-- 开服狂欢
        DAYSRANK2 = 202;-- 开服狂欢
        INSTANCE = 70;-- 副本
        ARENA = 71;-- 竞技场
        ACTIVITY = 72;-- 活动
        ACTIVITY2 = 203;-- 活动
        FIRSTRECHARGEAWARD = 73;-- 首充
        WildBoss = 75;
        Lot = 76;
        XUANBAO = 77;
		MidAutumn = 78;--  中秋

        FIRSTRECHARGEAWARD2 = 200;-- 首充
        Gem = 100;-- 宝石镶嵌
        GM = 99;
        APP_DOWN = 74;-- 补丁包下载
        APP_DOWN2 = 201;-- 补丁包下载
        MALL2 = 204;

        SALE = 56;-- 寄售
        Weal = 54;-- 福利
        ACTIVITY_GIFTS = 55;-- 礼包活动
        ACTIVITY_GIFTS2 = 205;-- 礼包活动(外)

        STRONG = 60;-- 变强
        EquipRefine = 101,
        -- 精炼
        ShenQi = 102,
        JingJieNinLian = 104,
        PetSkill = 106,
        PetAdvance = 107,
        PetFormation = 108,

        EquipNewStrong = 109;
        EquipFuLing = 113;--  附灵



        OffLineExp = 111;-- 离线经验
        NewTrumpRefine = 114;-- 法宝炼制
        EquipSuit = 115;-- 装备套装

        

        Theurgy = 168;-- 神通
        WingUpdate = 169;-- 翅膀培养
        Mobao = 172;-- 魔宝

        WiseEquip_FoMo = 174;-- 仙器附魔
        WiseEquip_DuanZao = 173;-- 仙器锻造
        JiuYaoKing = 175;-- 九幽王座
        FuJiaoShan = 176;-- 伏蛟山
        Taboo = 177;-- 禁忌之地
        WorldLev = 180;-- 世界等级,
        XJDMX = 181; -- 心机大冒险
        RideFeed = 182;-- 坐骑养魂
        PublicNotice = 183;-- 最新公告
        WingFashion = 184;-- 翅膀时装
        StarSplit = 185;-- 命星分解
        StarExchange = 186;-- 命星兑换
        StarDivination = 187;-- 命星占星
        PetFashion = 188, -- 宠物幻形       
        VIP = 150,


        shop_petJinjieDan = 189,
        -- 商城-伙伴进阶丹（对应商城上架id 152） UI_MallPanel  1
        bind_shop_petJinjieDan = 190,
        -- 绑定商城-伙伴进阶丹（对应商城上架id 709）  UI_MallPanel 2
        shop_wing = 191,
        -- 商城-翅膀（对应商城上架id 153）
        shop_ride = 192,-- 商城-金色坐骑（对应商城上架id 104）
        Artifact = 193,-- 神器
        ActTipsOpen = 194,
        WildVipBoss = 195,
        YaoShou = 196,

        RechargeAward = 301, -- 单笔充值活动
        DaysTarget = 302;
        ImmortalShop = 303;-- 魔天盛典
        Charge = 305,--充值相关跳转接口是否开启
        CloudPurchase = 306,
        CashGift = 307,--现金礼包

        Group_1 = 500,
        Group_2 = 501,
    };

    Type = {
        SYS = 1,
        -- 功能入口
        ACT = 2,
        -- 活动入口
        Other = 3,-- 标签入口
    };

    OpenType = {
        LEVEL = 1,
        TASK = 2,
    };
}

local _sortfunc = table.sort  

function SystemManager.Init()

    SystemManager.tmpSys = nil;

    SystemManager.list = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SYSTEM);

    SystemManager.lvList = { };
    SystemManager.taskList = { };
    for k, v in pairs(SystemManager.list) do
        if v.newTips then
            if v.openType == SystemConst.OpenType.LEVEL and v.openVal > 1 then
                SystemManager.lvList[k] = v;
            end

            if v.openType == SystemConst.OpenType.TASK then
                SystemManager.taskList[k] = v;
            end
        end
    end

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_NewReqJoin, SystemManager._RspNewReqJoin);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_NewReqJoin, SystemManager._RspNewReqJoin);
end

function SystemManager.Clear()
    SystemManager.tmpSys = nil;
end

-- 新审核
function SystemManager._RspNewReqJoin(cmd, data)
    -- Warning("_RspNewReqJoin")
    SystemManager.tong_ap = true
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
end

function SystemManager.GetCfg(id)
    return ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SYSTEM)[id];
end

function SystemManager.GetHasMail()
    return SystemManager.letter
end
function SystemManager.GetHasTong()
    return SystemManager.tong_ap
end
local insert = table.insert

function SystemManager.GetList(sysType)
    local tmp = { };
    for k, v in pairs(SystemManager.list) do
        if v.type == sysType and v.isOpen == true then
            insert(tmp, v);
        end
    end

    _sortfunc(tmp, function(a, b) return a.order < b.order; end);
    return tmp;
end

function SystemManager.Filter(list, fun)
    local tmp = { };
    for i, v in ipairs(list) do
        if SystemManager.SysIsOpen(v) and TimeLimitActManager.CheckSys(v.id) then
            if fun == nil or fun(v) then
                insert(tmp, v);
            end
        end
    end
    return tmp;
end

function SystemManager.IsOpen(sysId)
    local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SYSTEM)[sysId];
    return cfg ~= nil and SystemManager.SysIsOpen(cfg)
end

-- 只作为按钮显示, 标签页显示开关.
function SystemManager.SysIsOpen(sysCfg)
    if not sysCfg.isOpen then
        return false
    end
    if sysCfg.minipack_open == 0 and not AppSplitDownProxy.Loaded() then return false end

    local val = false;
    if sysCfg.openType == SystemConst.OpenType.LEVEL then
        local level = NoviceManager.oldLevel or PlayerManager.GetPlayerLevel();
        val = sysCfg.openVal <= level;
    elseif sysCfg.openType == SystemConst.OpenType.TASK then
        val = TaskManager.TaskIsAccess(sysCfg.openVal);
    end
    return val and SystemManager.SepicalOpen(sysCfg);
end

function SystemManager.SepicalOpen(cfg)
    if cfg.id == SystemConst.Id.FIRSTRECHARGEAWARD or cfg.id == SystemConst.Id.FIRSTRECHARGEAWARD2 then
        -- 首冲未领取
        return VIPManager.GetFirstStatus() < 2;
    elseif cfg.id == SystemConst.Id.RechargeAward then
        return not RechargeAwardProxy.IsRechargeOver()
    elseif cfg.id == SystemConst.Id.DAYSRANK or cfg.id == SystemConst.Id.DAYSRANK2 then
        return KaiFuManager.GetKaiFuHasDate() <= 8;
    elseif cfg.id == SystemConst.Id.APP_DOWN or cfg.id == SystemConst.Id.APP_DOWN2 then
        return not AppSplitDownProxy.Loaded() or not AppSplitDownProxy.GetAwarded()
    end

    return true;
end

function SystemManager.Check(openType, param)
    local newSys = false;
    if openType == SystemConst.OpenType.LEVEL then
        for k, v in pairs(SystemManager.lvList) do
            if v.openVal == param then
                SystemManager.OpenNewSys(v);
            end
        end
        newSys = true;
    elseif openType == SystemConst.OpenType.TASK then
        for k, v in pairs(SystemManager.taskList) do
            if v.openVal == param then
                SystemManager.OpenNewSys(v);
                newSys = true;
            end
        end
    end
    if newSys then
        MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
    end
end

function SystemManager.OpenNewSys(cfg)
    if PanelManager.IsOnMainUI() == false then
        SystemManager.AddToDelay(cfg);
    else
        SystemManager.ShowNewTips(cfg);
    end
end

function SystemManager.OnMainUI()
    if SystemManager.tmpSys then
        SystemManager.ShowNewTips(SystemManager.tmpSys);
        SystemManager.tmpSys = nil;
    end
end

function SystemManager.AddToDelay(cfg)
    SystemManager.tmpSys = cfg;
end

function SystemManager.ShowNewTips(cfg)
    ModuleManager.SendNotification(MessageNotes.SHOW_NEW_SYS_TIP, cfg);
end


function SystemManager.Nav(id)
    Warning("SystemManager.Nav " .. id)
    local str = ""
    if id == SystemConst.Id.ROLE then
        -- 1角色
        str = "角色"
        ModuleManager.SendNotification(MainUINotes.OPEN_MYROLEPANEL, {1});
    elseif id == SystemConst.Id.EQUIP then
        -- 2装备
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_1);
    elseif id == SystemConst.Id.SKILL then
        str = "技能"
        ModuleManager.SendNotification(SkillNotes.OPEN_SKILLPANEL);
    elseif id == SystemConst.Id.REALM then
        -- 4境界
        str = "境界"
        ModuleManager.SendNotification(RealmNotes.OPEN_REALM);
    elseif id == SystemConst.Id.PET then
        -- 5宠物
        str = "伙伴"
        ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL);
    elseif id == SystemConst.Id.FABAO then
        -- 6法宝
        ModuleManager.SendNotification(StarNotes.OPEN_STAR_PANEL);  
    elseif id == SystemConst.Id.MOUNT then
        -- 7坐骑
        str = "坐骑"
        ModuleManager.SendNotification(RideNotes.OPEN_RIDEPANEL);
    elseif id == SystemConst.Id.WING then
        -- 8翅膀
        str = "翅膀"
        ModuleManager.SendNotification(WingNotes.OPEN_WINGPANEL);
    elseif id == SystemConst.Id.XIANMENG then
        -- 9仙盟
        str = "仙盟"
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILDPANEL);
    elseif id == SystemConst.Id.YAOYUAN then
        -- 10 药园
        str = "药园"
        ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANROOTPANEL);
    elseif id == SystemConst.Id.RANK then
        -- 11排行
        str = "排行"
        ModuleManager.SendNotification(RankNotes.OPEN_RANKPANEL);
    elseif id == SystemConst.Id.SETTING then
        -- 12设置
        str = "设置"
        if GameSceneManager.debug then
            Warning(string.format("luamemory:%dm,UpdateLen:%d,LateUpdateLen:%d,FixedUpdateLen:%d,CoUpdateLen:%d"
            , collectgarbage("count"), UpdateBeat.list.length, LateUpdateBeat.list.length
            , FixedUpdateBeat.list.length, CoUpdateBeat.list.length))
            PrintEvents();
        end
        ModuleManager.SendNotification(AutoFightNotes.OPEN_AUTOFIGHTPANEL);
    elseif id == SystemConst.Id.LingYao then
        -- 13灵药
        str = "灵药"
        ModuleManager.SendNotification(LingYaoNotes.OPEN_LINGYAOPANEL);
    elseif id == SystemConst.Id.XINFABAO then
        -- 14新法宝
        str = "法宝"
        ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPPANEL);
    elseif id == SystemConst.Id.COMPOSE then
        -- 15合成
        str = "合成"
        ModuleManager.SendNotification(ComposeNotes.OPEN_COMPOSE_PANEL);
    elseif id == SystemConst.Id.WiseEquip then
        -- 16
        str = "仙器"
        ModuleManager.SendNotification(WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL, {tabIndex = 2, eqIndex = 1, selectEqInBag = nil});
    elseif id == SystemConst.Id.Formation then
        -- 17阵图
        ModuleManager.SendNotification(FormationNotes.OPEN_FORMATION_PANEL);
    elseif id == SystemConst.Id.SHOP then
        -- 50商城
        ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_temp});
    elseif id == SystemConst.Id.LOTTERY then
        -- 51
        str = "宝库"
        LotteryProxy.SendGetLotteryInfo();
    elseif id == SystemConst.Id.MALL then
        -- 52
        str = "商城" 
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL);
    elseif id == SystemConst.Id.DAYSRANK then
        -- 53
        str = "开服狂欢"
        ModuleManager.SendNotification(DaysRankNotes.OPEN_DAYSRANK_PANEL);
    elseif id == SystemConst.Id.Weal then
        -- 54
        str = "福利"
        ModuleManager.SendNotification(SignInNotes.OPEN_SIGNINPANEL);
    elseif id == SystemConst.Id.ACTIVITY_GIFTS then
        -- 55
        str = "礼包"
        ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL);
    elseif id == SystemConst.Id.SALE then
        -- 56
        str = "寄售"
        ModuleManager.SendNotification(SaleNotes.OPEN_SALEPANEL);
    elseif id == SystemConst.Id.STRONG then
        -- 60
        str = "变强"
        ModuleManager.SendNotification(PromoteNotes.OPEN_PROMOTE);
    elseif id == SystemConst.Id.INSTANCE then
        -- 70副本
        ModuleManager.SendNotification(MainInstanceNotes.OPEN_FB);
    elseif id == SystemConst.Id.ARENA then
        -- 71竞技场
        PVPProxy.SendGetPVPPlayer()
    elseif id == SystemConst.Id.ACTIVITY or id == SystemConst.Id.ACTIVITY2 then
        -- 72 
        str = "活动"
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, {type = ActivityNotes.PANEL_RICHANGACTIVITY});
    elseif id == SystemConst.Id.FIRSTRECHARGEAWARD then
        -- 73
        if(VIPManager.GetFirstStatus() < 2) then
            str = "首充"
        else
            str = "再充"
        end
        ModuleManager.SendNotification(FirstRechargeAwardNotes.OPEN_FIRSTRECHARGEAWARDPANEL);
    elseif id == SystemConst.Id.APP_DOWN then
        -- 74
        str = "下载"
        ModuleManager.SendNotification(AppSplitDownNotes.OPEN_APPSPLITDOWN);
    elseif id == SystemConst.Id.WildBoss then
        -- 75古魔
        str = "古魔"
        ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL);
    elseif id == SystemConst.Id.Lot then
        -- 76仙缘
        str = "仙缘"
        ModuleManager.SendNotification(LotNotes.OPEN_LOT_PANEL);
    elseif id == SystemConst.Id.XUANBAO then
        -- 77 玄宝
        ModuleManager.SendNotification(XuanBaoNotes.OPEN_XUANBAOPANEL);
    elseif id == SystemConst.Id.Gem then
        -- 100宝石
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_4);
    elseif id == SystemConst.Id.PetFormation then
        -- 108伙伴阵法
        ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 4);
    elseif id == SystemConst.Id.EquipNewStrong then
        -- 109装备强化
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_5);
    elseif id == SystemConst.Id.EquipFuLing then
        -- 113装备附灵
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_1);
    elseif id == SystemConst.Id.NewTrumpRefine then
        -- 114法宝炼制
        ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPPANEL, 2)
    elseif id == 150 then
        -- VIP
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 4 })
    elseif id == 151 then
        -- 经验坐骑
        local storeCfg = MallManager.GetStoreById(1);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })
    elseif id == 152 then
        -- 无尽试炼
        -- interface_data = TeamMatchDataManager.type_12;
        -- interface_id = ActivityDataManager.interface_id_18;
        -- instance_type = 12;
        -- local args = { interface_id = interface_id, interface_data = interface_data, type = instance_type, kind = InstanceDataManager.kind_0 };
        -- ModuleManager.SendNotification(LSInstanceNotes.OPEN_LSINSTANCEPANEL, args);
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGFB, id = 14 });
    elseif id == 153 then
        -- 商城-强化石
        local storeCfg = MallManager.GetStoreById(151);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })
    elseif id == 154 then
        -- 海皇宫
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGFB, id = 28 });
    elseif id == 155 then
        -- 商城-宝石
        local storeCfg = MallManager.GetStoreById(211);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })
    elseif id == 156 then
        -- 上界争霸
        ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIPANEL);
    elseif id == 157 then
        -- 商城-紫阳石
        local storeCfg = MallManager.GetStoreById(152);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })
    elseif id == 158 then
        -- 商城-法宝礼包
        local storeCfg = MallManager.GetStoreById(2);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })
    elseif id == 159 then
        -- 159小炎界
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 27 });
    elseif id == 160 then
        -- 充值
       -- ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3 })
       ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
    elseif id == 161 then
        -- 161古魔
        ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL);
    elseif id == 162 then
        -- 162商城经验丹
        local storeConfig = MallManager.GetStoreById(104);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeConfig })
    elseif id == 163 then
        -- 163虚灵塔
        ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTINSTANCE_PANEL);
    elseif id == 164 then
        -- 164玄榜任务
        ModuleManager.SendNotification(TaskNotes.OPEN_REWARDTASKPANEL);
    elseif id == 165 then
        -- 165背包
        ModuleManager.SendNotification(BackpackNotes.OPEN_BAG_ALL);
    elseif id == 166 then
        -- 循环任务
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 2 });
    elseif id == 167 then
        -- 仙盟聚饮
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILDPANEL, 3);
    elseif id == 170 then
        -- 螟族入侵
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 18 });
    elseif id == 171 then
        -- 商城-伙伴
        local storeConfig = MallManager.GetStoreById(512);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeConfig })
    elseif id == SystemConst.Id.ImmortalShop then
        -- 魔天盛典
        ModuleManager.SendNotification(ImmortalShopNotes.CLOSE_IMMORTAL_SHOP_PANEL)
        ModuleManager.SendNotification(ImmortalShopNotes.OPEN_IMMORTAL_SHOP_PANEL, 1)
    elseif id == SystemConst.Id.INSTANCE then
        -- 剧情任务
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 26 });
    elseif id == SystemConst.Id.JiuYaoKing then
        -- 九幽王座
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 30 });
    elseif id == SystemConst.Id.Taboo then
        -- 禁忌之地
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 31 });
    elseif id == SystemConst.Id.FuJiaoShan then
        -- 伏蛟山
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGFB, id = 29 });


    elseif id == SystemConst.Id.shop_petJinjieDan then
        -- 商城-伙伴进阶丹（对应商城上架id 152） UI_MallPanel  1
        local storeCfg = MallManager.GetStoreById(152);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })

    elseif id == SystemConst.Id.bind_shop_petJinjieDan then
        -- 绑定商城-伙伴进阶丹（对应商城上架id 709）  UI_MallPanel 2
        local storeCfg = MallManager.GetStoreById(709);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 2, other = storeCfg })

    elseif id == SystemConst.Id.shop_wing then
        -- 商城-翅膀（对应商城上架id 153）
        local storeCfg = MallManager.GetStoreById(153);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })

    elseif id == SystemConst.Id.shop_ride then
        -- 商城-金色坐骑（对应商城上架id 104）
        local storeCfg = MallManager.GetStoreById(104);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeCfg })
    elseif id == SystemConst.Id.WildVipBoss then
        --195 vip古魔
        ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL, {tab = 2})

    elseif id == SystemConst.Id.YaoShou then
        ModuleManager.SendNotification(YaoShouNotes.OPEN_YAOSHOUPANEL);

    elseif id == SystemConst.Id.MidAutumn then
        ModuleManager.SendNotification(FestivalNotes.OPEN_FESTIVAL_PANEL)
    elseif id == SystemConst.Id.PublicNotice then
        -- 183
        str = "最新消息"
        ModuleManager.SendNotification(NewestNoticeNotes.OPEN_NEWESTNOTICENOTESPANEL)
    elseif id == SystemConst.Id.StarDivination then
        ModuleManager.SendNotification(StarNotes.OPEN_STAR_PANEL, 4);
    elseif id == SystemConst.Id.RechargeAward then
        -- 301
        str = "单笔充值"
        ModuleManager.SendNotification(RechargeAwardNotes.OPEN_RECHARGET_PANEL)
    elseif id == SystemConst.Id.DaysTarget then
        -- 302
        ModuleManager.SendNotification(DaysTargetNotes.OPEN_DAYSTARGET_PANEL);
    elseif id == SystemConst.Id.ImmortalShop then
        -- 303
        str = "魔天盛典"
        ModuleManager.SendNotification(ImmortalShopNotes.OPEN_IMMORTAL_SHOP_PANEL)
    elseif id == SystemConst.Id.GM then
        ModuleManager.SendNotification(GMNotes.OPEN_GMPANEL);
	elseif id == SystemConst.Id.CloudPurchase then
		CloudPurchaseProxy.GetCloudPurchaseInfo()
	elseif id == SystemConst.Id.CashGift then--现金礼包
        ModuleManager.SendNotification(CashGiftNotes.OPEN_CASHGIFTSPANEL)
    end

    if(str ~= "") then
        LogHttp.SendOperaLog(str);
    end
end

function SystemManager.GetRedPoint(id)
    
    local cfg = SystemManager.GetCfg(id);

    if cfg.group and #cfg.group > 0 then
        for i, v in ipairs(cfg.group) do
            if SystemManager.GetRedPoint(v) then
                return true;
            end
        end
    else
        if id == SystemConst.Id.DAYSRANK then
            return DaysRankProxy.GetRedPoint();
        elseif id == SystemConst.Id.XUANBAO then
            return XuanBaoManager.GetRedPoint();
        elseif id == SystemConst.Id.LOTTERY then
            return LotteryManager.GetIsFree();
        elseif id == SystemConst.Id.StarDivination then
            return StarManager.HasDivinationTips();
        end
    end

    
    return false;
end