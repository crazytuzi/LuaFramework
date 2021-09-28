SkillInfo = class("SkillInfo");

local skillCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL);
local skillCDCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_CD);

function SkillInfo:New(id, level)
    local skLevel = level or 1;
    self = { };
    setmetatable(self, { __index = SkillInfo });
    self._timer = nil;
    self._isCooling = false;
    self._isCommonCD = false;
    self._currCoolTime = 0;
    self.cdTime = 0
    self._delayCooTime = 0;
    self:_Init(id, skLevel);
    return self;
end

function SkillInfo:_Init(id, level)
    if (self.id ~= id or self.skill_lv ~= level) then
        local skillItem = skillCfg[id .. "_" .. level];
        if (skillItem) then
            ConfigManager.copyTo(skillItem, self);
            self:_InitStages();
            if (skillItem.com_cd > 0) then
                local cdItem = skillCDCfg[skillItem.com_cd];
                if (cdItem) then
                    self.cd = cdItem.cd_time;
                    self._isCommonCD = true;
                end
            else
                self._isCommonCD = false
            end
        end
        if (self._series == nil) then
            self:_InitSeriesSkill();
            self:Reset();
        end
    end
end

function SkillInfo:_InitSeriesSkill()
    if (self.skill_link) then
        local index = 1;
        for i, v in pairs(self.skill_link) do
            if (v ~= "") then
                local info = SkillInfo:New(tonumber(v), self.skill_lv);
                if (self._series == nil) then
                    self._series = { };
                    self._seriesNum = 0
                end
                self._series[self._seriesNum + 1] = info;
                self._seriesNum = self._seriesNum + 1;
            end
        end
    end
end

function SkillInfo:Next()
    if (self._series) then
        if (self._seriesIndex < self._seriesNum) then
            self._seriesIndex = self._seriesIndex + 1;
            self._seriesSkill = self._series[self._seriesIndex];
        end
    end

end

function SkillInfo:Reset()
    self._delayCooTime = 0;
    self._seriesIndex = 0;
    self._seriesSkill = self;
end

function SkillInfo:ResetDelayCooling(r)
    if (self._series) then
        if (not self._isCooling) then
            self._coolR = r;
            self._delayCooTime = self.link_time;
            self:_StartTimer();
        end
    end
end

function SkillInfo:PauseDelayCooling()
    if (self._series) then
        if (not self._isCooling) then
            self:_StopTimer();
        end
    end
end

function SkillInfo:IsSeries()
    return(self._series ~= nil)
end

function SkillInfo:IsSeriesComplete()
    return(self._seriesIndex >= self._seriesNum)
end

function SkillInfo:GetSeries()
    return self._series;
end

function SkillInfo:GetSeriesSkill()
    return self._seriesSkill;
end

function SkillInfo:GetSkill(id)
    if (self.id == id) then
        return self;
    end
    if (self._series) then
        for i, v in pairs(self._series) do
            if (v.id == id) then
                return v;
            end
        end
    end
    return nil;
end
local insert = table.insert
function SkillInfo:_InitStages()
    local stageCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILLSTAGE);
    if (stageCfg) then
        local index = 1;
        self.stages = { };
        while (true) do
            local sInfo = stageCfg[self.id .. "_" .. self.skill_lv .. "_" .. index];
            if (sInfo) then
                insert(self.stages, sInfo);
                index = index + 1;
            else
                return;
            end
        end
    end
end

function SkillInfo:GetStage(id)
    if self.stages then
        if (self.stages[id]) then
            return self.stages[id];
        end
        return self.stages[1];
    end
    return nil
end

function SkillInfo:SetLevel(level)
    if (self.id ~= 0) then
        local sLevel = level or 1;
        self:_Init(self.id, sLevel);
    end
end

function SkillInfo:IsCommonCD()
    return self._isCommonCD;
end

function SkillInfo:IsCooling()
    return self._isCooling;
end

function SkillInfo:CurrCoolTime()
    return self._currCoolTime;
end

function SkillInfo:SetCurrCoolTime(val)
    if (self._isCooling) then
        self._currCoolTime = math.clamp(val, 0, self.cd)
    end
end

function SkillInfo:DelayCooTime()
    return self._delayCooTime;
end

function SkillInfo:StartCool(v)
    if (self.cd > 500) then
        local r = v or 1;
        self.cdTime =(self.cd * r) + 400
        if (self.cdTime > 500) then
            self._currCoolTime = self.cdTime;
            if (not self._isCooling) then
                self._isCooling = true;
                self:_StartTimer()
            end
        end
    end
    self:Reset();
end

function SkillInfo:StopCool()
    if (self._isCooling) then
        self:_StopTimer();
        self._currCoolTime = 0;
        self._delayCooTime = 0;
        self._isCooling = false;
    end
end

function SkillInfo:_StartTimer()
    if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1);
    end
    if (not self._timer.running) then
        self._timer:Start();
    end
end

function SkillInfo:_StopTimer()
    if (self._timer ) then
        self._timer:Stop();
    end
end

function SkillInfo:_OnTimerHandler()
    local dt = Timer.deltaTime * 1000;
    if (self._isCooling) then
        self._currCoolTime = self._currCoolTime - dt;
        if (self._currCoolTime <= 0) then
            self:StopCool();
            self:Reset();
        end
    else
        if (self._delayCooTime >= 0) then
            self._delayCooTime = self._delayCooTime - dt;
            if (self._delayCooTime <= 0) then
                self:StartCool(self._coolR);
            end
        end
    end
end

function SkillInfo:Dispose()
    if (self._series) then
        for i, v in pairs(self._series) do
            v:Dispose()
            self._series[i] = nil;
            v = nil;
        end
        self._series = nil;
    end
    self.stages = nil;
    self._seriesSkill = nil;
    self:StopCool();
    self._timer = nil
end
