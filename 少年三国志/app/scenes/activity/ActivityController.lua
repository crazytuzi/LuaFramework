local ActivityController = class("ActivityController")

require("app.cfg.activity_drink_info")
require("app.cfg.activity_money_info")

function ActivityController:ctor()

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_DATA_CAISHEN_UPDATED, self._onActivityUpdated, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_DATA_WINE_UPDATED, self._onActivityUpdated, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_DATA_DAILY_UPDATED, self._onActivityUpdated, self) 


end   

--在网络连通的情况下, 
function ActivityController:oneTick()   
   -- print(  tostring( uf_sceneManager:getCurScene() ))
    local t = G_ServerTime:getTime()
    self:_caishenOneTick(t)
    self:_wineOneTick(t)
    self:_dailyOneTick(t)
    
    --可配置活动12月25号上线~~
    self:_customActivityTick()
end


function ActivityController:_caishenWantUpdate(t)
    if t - G_Me.activityData.caishen.initData.wantUpdateTime > 5 then
        G_Me.activityData.caishen.initData.wantUpdateTime = t
        G_HandlersManager.activityHandler:sendMrGuanInfo()   
    end

end    

function ActivityController:_caishenOneTick(t)   
   --财神
   if G_Me.activityData.caishen.initData.status == 0  then 
        --没有初始化过
        self:_caishenWantUpdate(t)
        return

    end

    

    if G_ServerTime:isBeforeToday(G_Me.activityData.caishen.initData.lastUpdate) then 
        --需要重新初始化
        self:_caishenWantUpdate(t)
   end

   --next time时间到了之后, 在极短时间之内发个事件给UI, 发完就不发
   if t >=G_Me.activityData.caishen.next_time then
        if  G_Me.activityData.caishen.notifyTime ~= G_Me.activityData.caishen.next_time  then
            G_Me.activityData.caishen.notifyTime =  G_Me.activityData.caishen.next_time 

            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false, nil)
        end
   end

end


function ActivityController:_wineWantUpdate(t)
    if t - G_Me.activityData.wine.initData.wantUpdateTime > 5 then
        G_Me.activityData.wine.initData.wantUpdateTime = t
        G_HandlersManager.activityHandler:sendLiquorInfo()   
    end
end   

function ActivityController:_wineOneTick(t)   
   --对酒
   if G_Me.activityData.wine.initData.status == 0  then 
        --没有初始化过
        self:_wineWantUpdate(t)    
        return
    end

    -- 1, (2,3), 4, (5,6,), 7

    --首先客户端自己先判断状态, 判断lastUpdate,如果没有更新过就更新
    local record1 = activity_drink_info.get(1)
    local record2 = activity_drink_info.get(2)


    --计算今天2次喝酒的时间段
    local currentH, currentM, currentS = G_ServerTime:getCurrentHHMMSS(t)
    local currentSeconds = currentH*3600 + currentM*60 + currentS


    local updateH, updateM, updateS = G_ServerTime:getCurrentHHMMSS(G_Me.activityData.wine.initData.lastUpdate)
    local updateSeconds = updateH*3600 + updateM*60 + updateS

    -- print("currentSeconds=" .. currentSeconds)
    -- print("updateSeconds=" .. updateSeconds)

    local needUpdate = false
    if currentSeconds < record1.start_time then
        if updateSeconds < 0 then
            needUpdate = true
        end  
    elseif  currentSeconds >= record1.start_time and currentSeconds <= record1.end_time then
        if updateSeconds < record1.start_time then
            needUpdate = true
        end 
    elseif  currentSeconds > record1.end_time and currentSeconds < record2.start_time  then  
        if updateSeconds < record1.end_time then
            needUpdate = true
        end 
    elseif currentSeconds >= record2.start_time and currentSeconds <= record2.end_time then
        if updateSeconds < record2.start_time then
            needUpdate = true
        end 
    elseif currentSeconds > record2.end_time  then
        if updateSeconds < record2.end_time then
            needUpdate = true
        end 
    end 

    if needUpdate then
        self:_wineWantUpdate(t)    
    end



end


function ActivityController:_dailyWantUpdate(t)
    if t - G_Me.activityData.daily.initData.wantUpdateTime > 5 then
        G_Me.activityData.daily.initData.wantUpdateTime = t
        G_HandlersManager.activityHandler:sendLoginRewardInfo()   
    end
end   

function ActivityController:_dailyOneTick(t)   
   --对酒
   if G_Me.activityData.daily.initData.status == 0  then 
        --没有初始化过
        self:_dailyWantUpdate(t)    
        return
    end

     --如果最后一次更新是昨天的,那么更新一下吧,可能过月之后 每日活动需要刷新
     if G_ServerTime:isBeforeToday(G_Me.activityData.daily.initData.lastUpdate) then 
         --需要重新初始化
         self:_dailyWantUpdate(t)
    end

end

function ActivityController:_customActivityTick()
    if  G_Me.activityData.custom:hasInit() then
    --     G_HandlersManager.gmActivityHandler:sendCustomActivityInfo()  
    -- else
        --凌晨12点刷新的方法
        G_Me.activityData.custom:refreshNextDay()
    end
end

function ActivityController:_onActivityUpdated()   
   uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false, decodeBuffer)

end



function ActivityController:clear()
    uf_eventManager:removeListenerWithTarget(self)

end






return ActivityController
