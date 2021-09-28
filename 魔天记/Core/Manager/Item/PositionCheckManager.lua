
--[[
 两点之间检查 判断
]]

PositionCheckManager = class("PositionCheckManager");

PositionCheckManager.HD_TYPE_NULL = 0;
PositionCheckManager.HD_TYPE_IN = 1;  -- 移动到目标范围内触发
PositionCheckManager.HD_TYPE_OUT = 2;-- 移出到目标范围内触发

function PositionCheckManager:New()
    local o = { };
    setmetatable(o, self);
    self.__index = self;
    self.curr_hd_type = PositionCheckManager.HD_TYPE_NULL;
    return o;
end

--  {x,y,z,map_id}
function PositionCheckManager:SetTargetPosInfo(v)
    self.tg_posInfo = v;
    self.tg_posInfo.map_id = self.tg_posInfo.map_id + 0;

    if self.tg_posInfo.y == nil then
        self.tg_posInfo.y = 0;
    end

    self.tg_posInfo.x = self.tg_posInfo.x * 0.01;
    self.tg_posInfo.y = self.tg_posInfo.y * 0.01;
    self.tg_posInfo.z = self.tg_posInfo.z * 0.01;

   -- log("--SetTargetPosInfo------");


end



function PositionCheckManager:CheckR(v)
    self.cr = v * v * 0.01;
end

--[[
  {hd,hd_tg}
]]
function PositionCheckManager:SetHitHandler(handerObj)
    self.handerObj = handerObj;
end

function PositionCheckManager:Start()
   
    self.curr_hd_type = PositionCheckManager.HD_TYPE_NULL;
    self:Stop();

    self.totalTime = 999999999;
    self._sec_timer = Timer.New( function()

        self:Check()
        if self.totalTime < 0 then
            self:Stop();
        end
    end , 0.5, self.totalTime, false);
    self._sec_timer:Start();

end

function PositionCheckManager:Stop()
  -- 
  
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

end


function PositionCheckManager:Check()
   
   local v1 = self.tg_posInfo.map_id+0;
   local v2 = 0;

   if GameSceneManager.id ~= nil then
    v2 = GameSceneManager.id+0;
   end


   
  -- log("----PositionCheckManager:Check------------------"..v1.."__"..v2);

    if v1 == v2 then

        local myPos = HeroController:GetInstance().transform.position;

        local dx = myPos.x - self.tg_posInfo.x;
        local dz = myPos.z - self.tg_posInfo.z;

        local dl = dx * dx + dz * dz;

       -- log("----myPos----------- "..myPos.x.."     "..myPos.y);
       -- log("----tg_posInfo----------- "..self.tg_posInfo.x.."     "..self.tg_posInfo.y);
       -- log("dl "..dl.." "..self.cr);

        if dl <= self.cr then

            if self.curr_hd_type ~= PositionCheckManager.HD_TYPE_IN then
              self.curr_hd_type = PositionCheckManager.HD_TYPE_IN
              self:TryDisHandler(self.curr_hd_type)
            end

        else
             if self.curr_hd_type ~= PositionCheckManager.HD_TYPE_OUT then
              self.curr_hd_type = PositionCheckManager.HD_TYPE_OUT
              self:TryDisHandler(self.curr_hd_type)
            end
        end

    end


    --  {hd,hd_tg}
end


function PositionCheckManager:TryDisHandler(hd_type)
   
  
    if self.handerObj ~= nil then
        local hd = self.handerObj.hd;
        local hd_tg = self.handerObj.hd_tg;

        if hd_tg ~= nil then
            hd(hd_tg, hd_type);
        else
            hd(hd_type);
        end
    end
end

function PositionCheckManager:Dispose()

    self:Stop();
    self.posInfo1 = nil;
    self.posInfo2 = nil;
    self.handerObj = nil;
end