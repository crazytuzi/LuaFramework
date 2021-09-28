require "Core.Role.ModelCreater.MonsterModelCreater"
UIMonsterModelCreater = class("UIMonsterModelCreater", MonsterModelCreater);

function UIMonsterModelCreater:New(data, parent, withRide, asyncLoad, onLoadedSource)
    self = { };
    setmetatable(self, { __index = UIMonsterModelCreater });

    self._withRide = true
    if (withRide ~= nil) then
        self._withRide = withRide  
    end

    self.asyncLoadSource =  true
    if(asyncLoad ~= nil) then
       self.asyncLoadSource = asyncLoad
    end
    -- 是否异步加载模型
    self.onLoadedSource = onLoadedSource
    -- 异步加载后回调
    self.hasCollider = true
    -- 是否要挂点击触发器
    self._isWingActive = true    
    self:Init(data, parent);
    return self;
end
