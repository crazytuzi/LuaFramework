GuildMemberInfo = class("GuildMemberInfo");

function GuildMemberInfo:ctor(data)
    if data then
        self:Init(data);
    end
end

function GuildMemberInfo:Init(d)
    self.id = d.pid or -1;
    self.guildId = d.tId or -1;
    self.name = d.n or "-1";
    self.level = d.l or -1;
    self.identity = d.s or -1;    --职位
    self.fight = d.f or -1;         --战斗力
    self.kind = d.c or -1;        --职业
    self.dkpWeek = d.wd or -1;
    self.dkpDay = d.d or -1;
    self.dkpAll = d.dt or -1;
    self.joinTime = d.at or -1;
    self.onlineType = d.ol or -1;
    self.offlineTime = d.ot or -1;
    self.vip = d.vip or 0;
end

function GuildMemberInfo:IsOnline()
    return self.onlineType > 0;
end

function GuildMemberInfo:InitWithReqMember(reqMember)
    self.id = reqMember.pid or -1;
    self.name = reqMember.n or "-1";
    self.level = reqMember.l or -1;
    self.kind = reqMember.c or -1;
    self.fight = reqMember.f or -1;
    self.joinTime = reqMember.at or -1;
    self.onlineType = reqMember.onLine or -1;
    self.vip = reqMember.vip or 0;
end