require "Core.Scene.Item.MapPointCheckCtr"


MapPointCheckCtrManager = class("MapPointCheckCtrManager")


function MapPointCheckCtrManager:New(o)
    o = o or { };
    setmetatable(o, { __index = self });
    return o;
end 


function MapPointCheckCtrManager.GetInstance()
    if (MapPointCheckCtrManager._instance == nil) then
        MapPointCheckCtrManager._instance = MapPointCheckCtrManager:New();
        MapPointCheckCtrManager._instance.clist = { };
    end
    return MapPointCheckCtrManager._instance;
end


function MapPointCheckCtrManager:Start(info)

    self.currMapInfo = info;
    self:Stop()

    --------------------------------------------------------------------------
    if self.currMapInfo ~= nil then
        local points = MapPointCheckManager.GetPointsByMapId(self.currMapInfo.id)
        self:SetPoints(points)
    end

end

function MapPointCheckCtrManager:SetPoints(points)

    if points ~= nil then
        local t_num = table.getn(points);
        for i = 1, t_num do
            self.clist[i] = MapPointCheckCtr:New();
            self.clist[i]:Start(points[i])
        end
    end

end


function MapPointCheckCtrManager:Stop()

    local t_num = table.getn(self.clist);
    for i = 1, t_num do
        self.clist[i]:Dispose();
    end

    self.clist = { };
end