require "Core.Info.RoleInfo";

NpcInfo = class("NpcInfo", RoleInfo);

function NpcInfo:New(id)
    self = { };
    setmetatable(self, { __index = NpcInfo });
    self:_InitDefAttribute();
    self:_Init(id);
    return self;
end

function NpcInfo:_Init(id)
    local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC);
    local bInfo = npcCfg[id];

    if (bInfo) then
        ConfigManager.copyTo(bInfo, self);
        self.camp = 0
        self.position = Convert.PointFromServer(bInfo.x, bInfo.y, bInfo.z);
        self.mapItemType = MapItemType.Npc
    else
        Error("找不到这个npc" .. id)
    end
end

function NpcInfo:SetNpcState(state)
    self.state = state
end

function NpcInfo:GetNpcState()
    return self.state
end