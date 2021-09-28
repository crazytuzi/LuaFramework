
require "Core.Info.GuildInfo";

GuildDataManager = { };
GuildDataManager.gId = nil;
GuildDataManager.reqNum = 0;                  -- 申请的仙盟数量
GuildDataManager.reqMax = 10;
GuildDataManager.enemyNum = 0;
GuildDataManager.enemyMax = 3;
GuildDataManager.iNum = { };
GuildDataManager.mapId = 706500;
GuildDataManager.warMapId = 707200;

GuildDataManager.reqVertifyNum = 0;
GuildDataManager.awardFpNum = 0;
GuildDataManager.awardMyNum = 0;
GuildDataManager.canGetSalary = false;

GuildDataManager.war = { };
GuildDataManager.war.camp = 0;		-- 所属阵营
GuildDataManager.war.startTime = 0;	-- 开始时间
GuildDataManager.war.endTime = 0;	-- 结束时间
GuildDataManager.war.wp1 = 0;		-- 阵营1分数
GuildDataManager.war.wp2 = 0;		-- 阵营2分数
GuildDataManager.war.m = 0;			-- 中央归属
GuildDataManager.war.num = 0;		-- 参战人数
GuildDataManager.war.mp = 0;		-- 个人积分
GuildDataManager.war.mr = 0;		-- 个人排名
GuildDataManager.war.etgn = "";		-- 敌对仙盟名称


GuildDataManager.MESSAGE_MONEYCHANGE = "MESSAGE_MONEYCHANGE"
GuildDataManager.MESSAGE_DKPCHANGE = "MESSAGE_DKPCHANGE"
GuildDataManager.HONGBAOREDPOINT = "HONGBAOREDPOINT"
local hasHongBao = false

GuildDataManager.tfec = 1;

GuildDataManager.sortType = {
    level = 1;
    identity = 2;
    todayDkp = 3;
    allDkp = 4;
    online = 5;
}

GuildDataManager.Open = {
    MOBAI = 1,
    -- 强者膜拜
    BOSS = 3,
    -- 仙盟boss
    MINZU = 4,
    -- 瞑族入侵
    TASK = 5,
    -- 仙盟技能
    -- SKILL = 6,          -- 仙盟任务
    -- YaoYuan = 7,        -- 仙盟药园
    WAR = 8,
    -- 仙盟战
    -- XM_JuYin = 10,      -- 聚饮
    SHOP = 50,
    -- 仙盟商店
    XMBoss_FuLi = 51,
    -- 仙盟福利
    SALARY = 52,
    -- 仙盟工资
    SKILL = 53,
    -- 仙盟任务
    XMJuHui = 9,-- 仙盟聚会
}

GuildDataManager.opt = {
    dismissal = "dismissal";-- 踢人
    quit = "quit";-- 退出
    invitation = "invitation";-- 邀请
    approve = "approve";-- 审核
    open = "open";-- 开启活动
    notice = "notice";-- 修改公告
    promotion = "promotion";-- 修改职位
                            -- assignment = 7;       --转让工会
                            -- dissolve = 8;           --解散
    tong_war = "tong_war";-- 帮会战报名
    booking_battle = "booking_battle";-- 约战
    hostile = "hostile";-- 设置敌对仙盟
    recruit = "recruit";-- 发布招募喊话
    assign = "assign";-- 分配宝箱
    research = "research_skill";-- 研究技能

}

local skCfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDSKILL);

function GuildDataManager.Clear()
    GuildDataManager.gId = "";
    GuildDataManager._configs = nil;
    GuildDataManager.data = nil;
    GuildDataManager.info = nil;
    GuildDataManager.act = nil;
    GuildDataManager.reqNum = 0;
    GuildDataManager.enemyNum = 0;
    GuildDataManager.iNum = { };
    GuildDataManager.reqVertifyNum = 0;
    GuildDataManager.skillCache = nil;
    GuildDataManager.warCfg = nil;

    GuildDataManager.war = { };
    GuildDataManager.war.camp = 0;
    GuildDataManager.war.endTime = 0;
    GuildDataManager.war.wp1 = 0;
    GuildDataManager.war.wp2 = 0;
    GuildDataManager.war.m = 0;
    GuildDataManager.war.num = 0;
    GuildDataManager.war.mp = 0;
    GuildDataManager.war.mr = 0;

    GuildDataManager.rSkill = { };
    GuildDataManager.sSkill = { };
    hasHongBao = false

end

function GuildDataManager.Init(data, info)
    GuildDataManager.Clear();
    if data and data.tId then
        GuildDataManager.gId = data.tId;
        GuildDataManager.data = GuildInfo.New(data);
        GuildDataManager.info = { };
        GuildDataManager.act = { };
        GuildDataManager.UpdateInfo(info);

        if data.rsk then
            local rsk = { };
            for i, v in ipairs(data.rsk) do
                table.insert(rsk, v.id);
            end
            GuildDataManager.rSkill = rsk;
        else
            error("仙盟研究技能为空");
        end

        if info.ssk then
            local ssk = { };
            for i, v in ipairs(info.ssk) do
                table.insert(ssk, v.id);
            end
            GuildDataManager.sSkill = ssk;
        else
            error("仙盟学习技能为空");
        end
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.GuideSkill, true);
    end
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_CHG);
end

function GuildDataManager.Set_tfec(tfec)
    GuildDataManager.tfec = tfec;

    MessageManager.Dispatch(GuildNotes, GuildNotes.TFEC_ENV_CHG);
    MessageManager.Dispatch(GuildDataManager, GuildDataManager.HONGBAOREDPOINT)
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
end

function GuildDataManager.Get_tfec()
    return GuildDataManager.tfec;
end


function GuildDataManager.Update(data, info)
    if data and GuildDataManager.data then
        GuildDataManager.data:Init(data);
    end
    if info and GuildDataManager.info then
        GuildDataManager.UpdateInfo(info);
    end
end

-- 1342更新仙盟内数据
function GuildDataManager.UpdateGuildInfo(data)
    if data and GuildDataManager.data then
        if data.c then
            GuildDataManager.data.money = data.c;
        end

        MessageManager.Dispatch(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE)
    end
end

function GuildDataManager.UpdateInfo(info)

    if info.s then
        GuildDataManager.info.identity = info.s;
        -- 身份：1：帮主2：副帮主，3:长老,4：普通成员,5:学徒
    end
    local dkpChg = false;
    if info.d then
        dkpChg = true;
        GuildDataManager.info.dkpDay = info.d;
        -- 当日贡献
    end
    if info.dt then
        dkpChg = true;
        GuildDataManager.info.dkpAll = info.dt;
        -- 累计贡献
    end
    if info.us then
        dkpChg = true;
        GuildDataManager.info.dkpUse = info.us;
        -- 使用贡献
    end
    if info.dit then
        GuildDataManager.info.donateItem = info.dit;
        -- 捐赠道具次数
    end
    if info.dgt then
        GuildDataManager.info.donateMoney = info.dgt;
        -- 捐赠元宝次数
    end

    if dkpChg then
        MessageManager.Dispatch(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE)
    end

end

function GuildDataManager.Set_donateItem(v)
    GuildDataManager.info.donateItem = v;
    -- MessageManager.Dispatch(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE)
end

function GuildDataManager.Set_donateMoney(v)
    GuildDataManager.info.donateMoney = v;
    -- MessageManager.Dispatch(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE)
end

function GuildDataManager.GetInfo()
    return GuildDataManager.info;
end

function GuildDataManager.SetReqNum(val)
    GuildDataManager.reqNum = val;
    MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_REQNUM, nil);
end

function GuildDataManager.InGuild()
    if GuildDataManager.gId == nil then
        -- log(GuildDataManager.gId, "guild data is not init ");
        return false
    end
    return GuildDataManager.gId ~= "";
end

function GuildDataManager.GetMyGuildData()
    return GuildDataManager.data;
end

function GuildDataManager.GetMyGuildCfg()
    if GuildDataManager.data then
        local lv = GuildDataManager.data.level;
        local cfg = ConfigManager.GetGuildLevelConfig(lv);
        return cfg;
    end
    return nil;
end
-- 获取身份字符串
function GuildDataManager.GetIdentityName(identity)
    local cfg = ConfigManager.GetGuildGrantConfig(identity);
    return cfg and cfg.position or "";
end
-- 获取仙盟名称
function GuildDataManager.GetMyGuildName()
    if GuildDataManager.data then
        return GuildDataManager.data.name;
    end
    return "";
end
-- 获取我的仙盟身份
function GuildDataManager.GetMyIdentity()
    if GuildDataManager.gId ~= "" then
        return GuildDataManager.info and GuildDataManager.info.identity or -1;
    end
    return -1;
end
-- 获取我的仙盟贡献度
function GuildDataManager.GetMyDkp()
    -- 2017.4.7 仙盟贡献改为修为.
    return PlayerManager.spend;
    -- return GuildDataManager.info.dkpAll - GuildDataManager.info.dkpUse;
end

function GuildDataManager.GetSkillPoint()
    return PlayerManager.tscapital;
end

function GuildDataManager.GetMoney()
    return GuildDataManager.data.money;
end

function GuildDataManager.GetGrant(opt)
    if GuildDataManager.info then
        local cfg = ConfigManager.GetGuildGrantConfig(GuildDataManager.info.identity);
        local grant = cfg[opt];
        if grant then
            return grant > 0;
        end
    end
    return false;
end

function GuildDataManager.InZone()
    return tonumber(GameSceneManager.id) == GuildDataManager.mapId;
end

function GuildDataManager.ExitGuild()
    ModuleManager.SendNotification(GuildNotes.CLOSE_ALL_GUILDPANEL);
    GuildDataManager.Clear();
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_CHG);
    if GuildDataManager.InZone() then
        GuildProxy.ReqExitZone();
    end

    -- 离开仙盟时 删除所有仙盟任务(后端不肯发消息通知, 前端自己删).
    TaskManager.ClearTaskType(TaskConst.Type.GUILD);
    -- 离开工会 仙盟技能不生效, 影响战斗力
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.GuideSkill)
    --    PlayerManager.CalculatePlayerAttribute();
    -- 离开仙盟时 如果在仙盟战 则自动退出
    if GameSceneManager.map and GameSceneManager.map.info.type == InstanceDataManager.MapType.GuildWar then
        GuildWarProxy.ReqLeave();
    end
end

local exConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDEXTEND);

function GuildDataManager.GetExtends(type)
    if GuildDataManager._configs == nil then
        GuildDataManager._configs = { };
    end
    if GuildDataManager._configs[type] == nil then
        local tmp = { };
        for k, v in pairs(exConfig) do
            if v.type == type then
                table.insert(tmp, v);
            end
        end
        GuildDataManager._configs[type] = tmp;
    end
    return GuildDataManager._configs[type];
end

function GuildDataManager.IsOpen(id)
    local lv = GuildDataManager.data.level;
    local cfg = exConfig[id];
    if lv < cfg.level then
        return false;
    end

    local rolelv = PlayerManager.GetPlayerLevel();
    if rolelv < cfg.req_lev then
        return false;
    end
    return true;
end

function GuildDataManager.InvitatePlayer(playerId)
    -- body
    if GuildDataManager.InGuild() == false then
        MsgUtils.ShowTips("guild/error/-1");
        return;
    end
    if GuildDataManager.GetGrant(GuildDataManager.opt.invitation) then
        GuildProxy.ReqInvate(playerId);
    else
        MsgUtils.ShowTips("guild/invitate/0");
    end
end

function GuildDataManager.OnBeInvite(data)
    MsgUtils.ShowConfirm(GuildDataManager, "guild/beInvite", { name = data.name }, GuildDataManager.DoAnsInvite1, GuildDataManager.DoAnsInvite2, data, nil, nil, nil, nil, nil, 60);
end

function GuildDataManager.DoAnsInvite1(target, data)
    GuildProxy.ReqAnsInvite(data.tid, 1);
end
function GuildDataManager.DoAnsInvite2(target, data)
    GuildProxy.ReqAnsInvite(data.tid, 0);
end

-- 获取可学习, 研究的技能
-- 后端不给默认技能, 前端自己计算
function GuildDataManager.GetSkillList(type)
    local data = type == 1 and GuildDataManager.sSkill or GuildDataManager.rSkill;

    local tmp = { };

    -- 将已存在的技能找到下一级
    for i, v in ipairs(data) do
        local cfg = skCfgs[v];
        tmp[cfg.type] = cfg;
    end

    if not GuildDataManager.skillCache then
        GuildDataManager.skillCache = GuildDataManager.BuildSkillCache();
    end

    -- 先把没有类型的填入0级的技能
    for k, v in pairs(GuildDataManager.skillCache) do
        if tmp[k] == nil then
            tmp[k] = GuildDataManager.GetSkillInCache(k, 0);
        end
    end
    return tmp;
end

-- 构建技能缓存, 计算时不需要重复遍历
function GuildDataManager.BuildSkillCache()
    local cache = { };
    for k, v in pairs(skCfgs) do
        if not cache[v.type] then
            cache[v.type] = { };
        end
        cache[v.type][v.level] = v;
    end
    return cache;
end

function GuildDataManager.GetSkillInCache(type, level)
    return GuildDataManager.skillCache[type][level];
end


function GuildDataManager.GetSkillResLev(id)
    local lv = 0;
    local data = GuildDataManager.rSkill;
    local curCfg = GuildDataManager.GetSkillCfgById(id);

    local cfg = nil;
    for i, v in ipairs(data) do
        cfg = GuildDataManager.GetSkillCfgById(v);
        if cfg.type == curCfg.type then
            return cfg.level;
        end
    end

    return lv;
end

-- 获取审核的红点
function GuildDataManager.GetRedPoint()
    if GuildDataManager.InGuild() then
        return GuildDataManager.GetInfoRedPoint() or GuildDataManager.GetMemberRedPoint() or GuildDataManager.GetRewardRedPoint();
    end
    return false;
end

--  功能界面 信息 红点
function GuildDataManager.GetInfoRedPoint()
   
   local b1 = (GuildDataManager.tfec == 0) ;
   local b2 = GuildDataManager.GetGuideHongBaoRedPoint();

    return b1 or b2;
end

function GuildDataManager.GetMemberRedPoint()
    if GuildDataManager.data then
        return GuildDataManager.GetGrant(GuildDataManager.opt.approve) and GuildDataManager.reqVertifyNum > 0;
    end
    return false;
end

function GuildDataManager.GetRewardRedPoint()
    if GuildDataManager.data then
        -- return GuildDataManager.awardMyNum > 0 or (GuildDataManager.GetGrant(GuildDataManager.opt.assign) and GuildDataManager.awardFpNum > 0);
        return GuildDataManager.canGetSalary or GuildDataManager.GetSkillRedPoint();
    end
    return false;
end

function GuildDataManager.GetGuildSkillAttr()
    local attrs = { };
    if GuildDataManager.InGuild() then
        local cfg = nil;
        local attr = nil;
        -- local changeAttr = PlayerManager.GetMyCareerDmgType() == 2;
        for k, v in pairs(GuildDataManager.sSkill) do
            cfg = skCfgs[v];
            attr = cfg.attr;

            -- 如果是法术职业 要改属性字段
            -- if attr == "phy_att" and changeAttr then
            -- 	attr = "mag_att";
            -- end

            if attrs[attr] == nil then
                attrs[attr] = 0;
            end
            attrs[attr] = attrs[attr] + cfg.attrVal;
        end
    end

    return attrs;
end

function GuildDataManager.GetSkillCfgById(id)
    return skCfgs[id];
end

-- 获取仙盟技能研究上限
function GuildDataManager.GetSkillMaxByType(type)
    local cfg = GuildDataManager.GetMyGuildCfg();
    if cfg then
        return cfg["type" .. type];
    end
    return 0;
end

function GuildDataManager.GetSkillRedPoint()
    if GuildDataManager.IsOpen(GuildDataManager.Open.SKILL) == false then
        return false;
    end
    return GuildDataManager.GetSkillLearnRedPoint() or GuildDataManager.GetSkillResRedPoint()
end

function GuildDataManager.GetSkillLearnRedPoint()
    local num = GuildDataManager.GetSkillPoint();
    local list = GuildDataManager.GetSkillList(1);
    for k, v in pairs(list) do
        local cost = tonumber(string.split(v.study_need_item, "_")[2]);
        if num >= cost then
            local max = GuildDataManager.GetSkillResLev(v.id);
            if v.level < max then
                return true;
            end
        end
    end

    return false;
end

function GuildDataManager.GetSkillResRedPoint()
    if GuildDataManager.GetGrant(GuildDataManager.opt.research) == false then
        return false;
    end

    local num = GuildDataManager.GetMoney();
    local list = GuildDataManager.GetSkillList(2);

    for k, v in pairs(list) do
        local cost = tonumber(string.split(v.research_need_item, "_")[2]);
        if num >= cost then
            local max = GuildDataManager.GetSkillMaxByType(v.type);
            if v.level < max then
                return true;
            end
        end
    end

    return false;
end

function GuildDataManager.IsSameGuild(val1, val2)
    if (val1 == nil or val1 == "" or val2 == nil or val2 == "") then return false end
    return val1 == val2;
end

function GuildDataManager.GetGuideHongBaoRedPoint()
    return hasHongBao
end

function GuildDataManager.SetHongBaoRedPoint(value)
    hasHongBao = value
    MessageManager.Dispatch(GuildDataManager, GuildDataManager.HONGBAOREDPOINT)
end


function GuildDataManager.GetWarConfig()
    if GuildDataManager.warCfg == nil then
        GuildDataManager.warCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDWAR)[1];
    end
    return GuildDataManager.warCfg;
end

function GuildDataManager.SplitDateTime(date)
	local d = {};
	local arr = string.split(date, "_");
	d.wday = tonumber(arr[1]);
	local time = string.split(arr[2], ":");
	d.hour = tonumber(time[1]);
	d.min = tonumber(time[2]);
	d.sec = tonumber(time[3]);
	return d;
end

function GuildDataManager.InTime(now, time)
	if now.wday == time.wday then
		if now.hour == time.hour then
			if now.min == time.min then
				return now.sec >= time.sec;
			else
				return now.min > time.min;
			end
		else
			return now.hour > time.hour;
		end
	end
	return now.wday > time.wday;
end
