require "Core.Info.GuildMemberInfo";

GuildInfo = class("GuildInfo");

GuildInfo.Status = {
    NONE = 0;
    REQ = 1;
}

GuildInfo.Identity = {
    Leader = 1;         --帮主
    AssLeader = 2;      --副帮主
    Elder = 3;          --长老
    Normal = 4;         --普通成员
    Trainee = 5;        --学徒
}

function GuildInfo:ctor(data)
    self:Init(data);
end

function GuildInfo:Init(data)
    if data.tId then
        self.id = data.tId or -1;
        self.rank = data.idx or -1;
        self.leader = data.o_name or -1;
        self.leaderId = data.oId or -1;
        self.leaderKind = data.career or -1;
        self.leaderVip = data.vip or 0;
        self.name = data.name or -1;
        self.level = data.l or -1;
        self.money = data.c or -1;
        self.fight = data.f or -1;
        self.totalMoney = data.cat or -1;
        self.exp = data.e or -1;
        self.time = data.ct or -1;
        self.notice = data.n or -1;
        self.status = data.os or -1;
        self.num = data.num or -1;
        self.isEnemy = data.et ~= nil;
        self.enemyTime = data.et and (GetTime() + data.et) or -1;

        self.helpNum = data.thc or -1;
    end
end

function GuildInfo:InitMember(member)
    self.members = {};
    if member then
        for i, v in ipairs(member) do 
            self.members[i] = GuildMemberInfo.New(v);    
        end
    end
end