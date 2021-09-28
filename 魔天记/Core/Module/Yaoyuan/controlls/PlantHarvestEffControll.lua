

PlantHarvestEffControll = class("PlantHarvestEffControll");



function PlantHarvestEffControll:New()
    self = { };
    setmetatable(self, { __index = PlantHarvestEffControll });
    return self
end


function PlantHarvestEffControll:Init(gameObject)
    self.gameObject = gameObject;
    self.gameObject.gameObject:SetActive(false);

    self.enterFrameRun = EnterFrameRun:New();

    PlantHarvestEffControll.ins = self;

end

function PlantHarvestEffControll:PlayMc(idxs, playCompleteHandler)


    self.idxs = idxs;
    self.playCompleteHandler = playCompleteHandler;

    self.idx_index = 1;
    local len = table.getn(self.idxs);

    self.enterFrameRun:Stop();
    self.enterFrameRun:Clean();

    local fctr = FarmsControll.ins;

    if len > 0 then

        for i = 1, len do

            local idx = self.idxs[self.idx_index];
            local pland = fctr:GetPanelByIdx(idx);
            local old_pos = pland.gameObject.localPosition;
            local target_pos = Vector3.New(-585, 303, 0);

            local dx = target_pos.x - old_pos.x;
            local dy = target_pos.y - old_pos.y;

            local m_time = 10;

            local speed_x = dx / m_time;
            local speed_y = dy / m_time;

            local data = { plant = pland, c_x = old_pos.x, c_y = old_pos.y, speed_x = speed_x, speed_y = speed_y };



            self.enterFrameRun:AddHandler(PlantHarvestEffControll.ShowIcon, self, 1, data);
            self.enterFrameRun:AddHandler(PlantHarvestEffControll.MoveToTarget, self, m_time, data);
            self.enterFrameRun:AddHandler(PlantHarvestEffControll.HideIcon, self, 1);


            self.idx_index = self.idx_index + 1;
        end
        -- end for

        self.enterFrameRun:AddHandler(PlantHarvestEffControll.DisCompleteHandler, self, 1);

    end

    self.enterFrameRun:Start()

end

--[[
动画 结束
]]
function PlantHarvestEffControll:DisCompleteHandler()

    if self.playCompleteHandler ~= nil then

        self.playCompleteHandler();
    end

end

function PlantHarvestEffControll:ShowIcon(data)
    self.gameObject.gameObject:SetActive(true);
    Util.SetLocalPos(self.gameObject, data.c_x, data.c_y, 0)
    --    self.gameObject.transform.localPosition = Vector3.New(data.c_x, data.c_y, 0);

    local tpath = data.plant._mainTexturePath;
    self.gameObject.mainTexture = UIUtil.GetTexture(tpath);


    data.plant:SetData(nil, 0, 0, false);

end

function PlantHarvestEffControll:MoveToTarget(data)

    local old_x = data.c_x;
    data.c_x = data.c_x + data.speed_x;
    data.c_y = data.c_y + data.speed_y;

    self.gameObject.transform.localPosition = Vector3.New(data.c_x, data.c_y, 0);

end

function PlantHarvestEffControll:HideIcon()
    self.gameObject.gameObject:SetActive(false);
end

function PlantHarvestEffControll:Dispose()

    self.enterFrameRun:Stop();
    self.enterFrameRun = nil;
    self.playCompleteHandler = nil;


    self.gameObject = nil;

end