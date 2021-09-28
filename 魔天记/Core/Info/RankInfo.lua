RankInfo = class("RankInfo");

function RankInfo:ctor(d)
    self:Init(d);
end

function RankInfo:Init(d)
    if d then
        self.id = d.id or -1;

        self.playerId = d.pi or -1;
        self.playerName = d.pn or "-1";
        self.playerKind = d.c or -1;

        self.fight = d.ft or -1;
        self.level = d.lv or -1;
        self.gold = d.gold or -1;
        self.money = d.money or -1;

        self.petKind = d.pet_k or -1;
        self.petName = d.pet_n or "-1";

        self.wingRank = d.r or -1;

        self.gId = d.tid or -1;
        self.gName = d.tn or "-1";
        self.leader = d.otn or "-1";
        self.num = d.n or -1;

        self.exp = d.exp or -1;

        self.vip = d.vip or 0;
        self.use_id = d.use_id or 0;
        self.s = d.s or 0;
    end

end

-- 用于0E04
function RankInfo:UpdateWithArena(d)
    self.id = d.r or -1;
    self.playerId = d.p or -1;
    self.playerName = d.n or "-1";
    self.playerKind = d.k or -1;
    self.fight = d.f;
    self.use_id = d.use_id or 0;
end

function RankInfo:GetMyInfo(d)

    self.id = d.r or 0;

    local myInfo = PlayerManager.GetPlayerInfo();

    self.playerId = PlayerManager.playerId;
    self.playerName = myInfo.name;
    self.playerKind = myInfo.kind;

    self.vip = VIPManager.GetSelfVIPLevel();
    -- 战斗力
    if self.type == RankConst.Type.FIGHT then
        -- self.fight = PlayerManager.GetSelfFightPower();
        self.fight = d.v;
        -- 等级
    elseif self.type == RankConst.Type.LEVEL then
        -- self.level = myInfo.level;
        self.level = d.v;
        -- 仙玉
    elseif self.type == RankConst.Type.GOLD then
        -- self.gold = myInfo.gold;
        self.gold = d.v;
        -- 灵石
    elseif self.type == RankConst.Type.MONEY then
        -- self.money = myInfo.money;
        self.money = d.v;
        -- 宠物
    elseif self.type == RankConst.Type.PET then
        if d.r then
            self.id = d.r.id;
            --self.petKind = d.r.pet_k or -1;
            --self.petName = d.r.pet_n or "-1";
            --self.fight = d.r.ft or -1;
            self.use_id = d.r.use_id;
            self.s = d.r.s;
            
        else
            self.id = 0;
        end
        -- 境界
    elseif self.type == RankConst.Type.REALM then
        -- todo
        self.level = d.v;
        -- 翅膀
    elseif self.type == RankConst.Type.WING then
        --[[
        local w = WingManager.GetCurrentWingData();
        if w then
            self.wingRank = w.rank;
            self.level = w.lev;
        else
            self.id = -1;
        end]]
        self.wingRank = d.r1;
        self.level = d.v;
        -- 仙盟
    elseif self.type == RankConst.Type.GUILD_FIGHT or self.type == RankConst.Type.GUILD_RANK then
        -- local g = GuildDataManager.InGuild() and GuildDataManager.data or nil;
        if d.r then
            local g = d.r;
            self.id = g.id;
            self.gId = g.tid;
            self.gName = g.tn or "";
            self.leader = g.otn or -1;
            self.playerKind = g.c or -1;
            self.num = g.n or -1;
            self.fight = g.ft or -1;
            self.level = g.lv or -1;
        else
            self.id = 0;
        end
        -- 竞技场
    elseif self.type == RankConst.Type.ARENA then
        -- if SystemManager.IsOpen(SystemConst.Id.ARENA) then
        self.id = math.max(PVPManager.GetPVPRank(), 0);
        self.fight = PlayerManager.GetSelfFightPower();
        -- else
        -- self.id = -1;
        -- end

        -- 虚灵塔
    elseif self.type == RankConst.Type.XULING then
        if d.r then
            self.id = d.r.id;
            self.level = d.r.lv;
        else
            self.id = 0;
        end

    elseif self.type == RankConst.Type.AUTOFIGHT then

        if d.r then
            self.id = d.r.id;
            self.exp = d.r.exp;
        else
            self.id = 0;
            self.exp = 0;
        end

    end

end

