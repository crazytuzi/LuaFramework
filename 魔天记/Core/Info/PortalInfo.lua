PortalInfo = class("PortalInfo");

function PortalInfo:New(data)
    self = { };
    setmetatable(self, { __index = PortalInfo });
    self:_Init(data);
    return self;
end

function PortalInfo:_Init(data)
    if (data) then
        self.id = data.id
        self.name = data.name
        self.map = data.map
        self.to_map = data.to_map
        self.position = Convert.PointFromServer(data.x, data.y, data.z);
        self.toPosition = Convert.PointFromServer(data.to_x,data.to_y, data.to_z);
    end
end