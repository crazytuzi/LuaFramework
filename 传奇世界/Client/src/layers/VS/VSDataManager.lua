VSDataManager = class("VSDataManager")


function VSDataManager:Init()
    -- 自身战队
    self.m_selfTeam = nil;
end

function VSDataManager:SetSelfTeamId(teamId)
    if self.m_selfTeam == nil then
        self.m_selfTeam = {};
    end

    self.m_selfTeam.teamId = teamId;
end

function VSDataManager:GetSelfTeam()
    return self.m_selfTeam;
end