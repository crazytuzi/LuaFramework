--[[
    弹框队列管理类

    --By: haidong.gan
    --2013/11/11
]]

--[[
--用法举例

1、缓存聊天数据5分钟
   ViewDataCache:setCache("chat",chatList,ViewDataCache.ChatCap)

2、从缓存中获取聊天数据
   local chatList = ViewDataCache:getCache["chat"];
   if chatList ==nil then
     --从服务端获取数据
   end
]]

function getDynamicData(delegate, fun, ...)
    local dacheData = ViewDataCache:getCache(fun) ;
    if dacheData then
        TFDirector:dispatchGlobalEventWith(fun, dacheData);
    else
        TFFunction.call(fun, delegate, ...);
    end
end


local ViewDataCache = class("ViewDataCache");

--定义缓存过期时间期限(秒)（setCacheData 方法调用时使用）

--不缓存
ViewDataCache.None      = (0);

--默认
ViewDataCache.DefualtCap      = (5);

--永久保存
ViewDataCache.Forever         = (-1);

--好友
ViewDataCache.FriendCap      = (5*60);
ViewDataCache.FriendAddCap   = (5*60);
--情报
ViewDataCache.MessageCap     = (5*60);
ViewDataCache.MessageNumCap  = (5*60);
--聊天
ViewDataCache.ChatCap        = (2*60);
--任务
ViewDataCache.MissionCap     = (20*60);
--竞技
ViewDataCache.ArenaCap       = (10*60);
--36
ViewDataCache.ThirtySixCap       = (10*60);


function ViewDataCache:ctor( )
    self:init();
end

function ViewDataCache:init( )
    self.cacheDic      = {}; --缓存数据
    self.updateTimeDic = {}; --更新时刻
    self.updateCapDic  = {}; --过期时间



    local function onUpdated()
        self:checkAndDestroyCache();
    end
    TFDirector:addTimer(1000, -1, nil, onUpdated); 
end

function ViewDataCache:clear()
    self.cacheDic      = {};
    self.updateTimeDic = {};
    self.updateCapDic  = {};
end

--更新缓存数据，如果数据不存在，则添加。
function ViewDataCache:setCache(key,data,cap)

    if cap == ViewDataCache.None  then
        return;
    end

    if not cap then
        cap = ViewDataCache.DefualtCap;
    end

    self.cacheDic[key]      = data;
    self.updateTimeDic[key] = os.time();
    self.updateCapDic[key]  = cap;

end

--释放缓存数据
function ViewDataCache:destroyCache(key)
    print("Destroy Cache：" , key);

    self.cacheDic[key]      = nil;
    self.updateTimeDic[key] = nil;
    self.updateCapDic[key]  = nil;
end

--判断缓存数据是否已过期（缓存不存在也是为过期）
function ViewDataCache:checkCacheIsExpired(key)
    local updateTime = self.updateTimeDic[key];
    local cap        = self.updateCapDic[key];
    if cap == ViewDataCache.Forever then
        return;
    end
    if (updateTime == nil) then
        -- print("缓存不存在：%s" .. key);
        return true;
    end
    
    if (os.time() - updateTime >cap) then
        -- print("updateTime:%s" .. updateTime);
        -- print("currentTimeNow:%lld" .. os.time() );
        print("expired：" , key);
        return true;
    end
    -- print("缓存未过期：%s" .. key);
    return false;
end

--检查所有缓存是否存在过期，并释放过期缓存
function ViewDataCache:checkAndDestroyCache()
    for k in pairs(self.cacheDic) do
        if self:checkCacheIsExpired(k) then
            self:destroyCache(k);
        end
    end
end

--获取缓存数据
function ViewDataCache:getCache(key)
    return self.cacheDic[key];
end

function ViewDataCache:restart()
    self:clear();
end

return ViewDataCache:new();