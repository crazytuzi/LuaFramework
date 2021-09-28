require "Core.Manager.Item.MapPointCheckManager"

MapPointCheckCtr = class("MapPointCheckCtr")

MapPointCheckCtr.TYPE_NONE = 0;
MapPointCheckCtr.TYPE_HAS_IN = 1;
MapPointCheckCtr.TYPE_HAS_OUT = 2;

function MapPointCheckCtr:New()
    self = { };
    setmetatable(self, { __index = MapPointCheckCtr });
    return self;
end 

--[[
['id'] = '100001',
		['in_map_id'] = 709999,
		['check_x'] = -1868,
		['check_y'] = 570,
		['check_z'] = -1880,
		['check_radius'] = 400,
		['check_time'] = 200,
		['fun'] = 'onLMount',
		['fun_params'] = {'862000'}
]]
function MapPointCheckCtr:Start(info)


    self.info = info;
    self.checkTimeNum = 999999;

    self:Stop();
     -- 是否 在 检测点
    self.inCheckPoint = MapPointCheckCtr.TYPE_NONE;

    self.check_time = self.info.check_time * 0.001;

    self.check_x = self.info.check_x * 0.01;
    self.check_y = self.info.check_y * 0.01;
    self.check_z = self.info.check_z * 0.01;

    self.check_radius = self.info.check_radius * 0.01;


    self._sec_timer = Timer.New( function()
        self:Check()
    end , self.check_time, self.checkTimeNum, false);

    self._sec_timer:Start();

end

function MapPointCheckCtr:Check()

    local me = HeroController:GetInstance();
    local transform = me.transform;
    local my_x = transform.localPosition.x;
    local my_z = transform.localPosition.z;

    

    local dx = my_x - self.check_x;
    local dz = my_z - self.check_z;

    local dlen = dx * dx + dz * dz;

     ---log("MapPointCheckCtr:Check dlen "..dlen.." check_radius "..self.check_radius);
  
    if dlen < self.check_radius then

        if  self.inCheckPoint == MapPointCheckCtr.TYPE_NONE or self.inCheckPoint == MapPointCheckCtr.TYPE_HAS_OUT  then
            self:DisMoveInFun();
            self.inCheckPoint = MapPointCheckCtr.TYPE_HAS_IN ;
        end
    else

        if self.inCheckPoint == MapPointCheckCtr.TYPE_HAS_IN  then
            self:DisMoveOutFun();
            self.inCheckPoint = MapPointCheckCtr.TYPE_HAS_OUT ;
        end

    end

end

function MapPointCheckCtr:DisMoveOutFun()

  --  log("---------DisMoveOutFun-------------");

     local fun = self.info.move_out_fun;
    local fun_params = self.info.move_out_fun_params;


end

function MapPointCheckCtr:DisMoveInFun()

  -- log("---------DisMoveInFun-------------");

    local fun = self.info.move_in_fun;
    local fun_params = self.info.move_in_fun_params;

    if fun == MapPointCheckManager.FUN_ONLMOUNT then
        -- 地面载具
        HeroController:GetInstance():OnMountLang(fun_params[1], nil,true);

    elseif fun == MapPointCheckManager.FUN_ONFMOUNT then
        -- 飞行载具
        local mound_id = fun_params[1];
        local movePath_id =  fun_params[2];
     
        HeroController:GetInstance():OnMountByRid(mound_id, movePath_id, true, 0);

    end

end

function MapPointCheckCtr:Stop()

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

end

function MapPointCheckCtr:Dispose()

    self:Stop()

    self.info = nil;
end