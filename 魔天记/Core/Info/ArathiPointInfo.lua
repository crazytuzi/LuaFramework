ArathiPointInfo = class("ArathiPointInfo");

function ArathiPointInfo:New(data)
    self = { };
    setmetatable(self, { __index = ArathiPointInfo });
    self:_Init(data);
    return self;
end

function ArathiPointInfo:_Init(data)
    if (data) then
        self.id = data.id
        self.name = data.l_name
        self.type = data.type;
        self.radius = data.r / 100;
        self.modle = data.modle;
        if (self.id == 1 or self.id == 2) then
            self.camp = self.id;
        else
            self.camp = 0;
        end
        self.buff = 0;
        self.position = Convert.PointFromServer(data.x, data.y, data.z);
    end
end