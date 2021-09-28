--剧情
AbsDrama = class("AbsDrama");

function AbsDrama:New()
    self = { };
    setmetatable(self, { __index = AbsDrama })
    return self;
end
-- 开始剧情
function AbsDrama:Begin()
    -- DramaMgr.Begin()
    self._hero = HeroController.GetInstance()
    self._camera = MainCameraController.GetInstance()
    self._camera:ChangeCameraForBlack(function (args)        
        --self:_OnBegin()
    end,function (args)
        self:_Init()
    end,nil,0.03,0.2,0.2)
end
-- 初始化
function AbsDrama:_Init()
   
end
function AbsDrama:_OnBegin()
    
end
-- 结束剧情
function AbsDrama:End()
    --self._camera:ChangeCameraToHero(1,function()
        self:_OnEnd()
        self:Clear()
        DramaMgr.End()
    --end)
end
-- 结束剧情
function AbsDrama:_OnEnd()
    
end

-- 清理
function AbsDrama:Clear()
    self._hero = nil
    self._camera = nil
end