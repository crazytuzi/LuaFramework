statisticsHelper={
     appid=0,
     appkey="fdskafjdksafkds",
     clientErrLastSendTime=0,
}

if platCfg.platCfgAppid[G_curPlatName()]~=nil then

    if G_curPlatName()=="9" then
        local tmpTb={}
        tmpTb["action"]="getPaymentStatistics"
        local cjson=G_Json.encode(tmpTb)
        local paymentStatistics=G_accessCPlusFunction(cjson)
        statisticsHelper.appid=paymentStatistics
    else
        statisticsHelper.appid=platCfg.platCfgAppid[G_curPlatName()]
        -- if G_curPlatName()=="11" and tonumber(base.curZoneID)>3 and tonumber(base.curZoneID)<100 then --德国ios特殊处理
        --         statisticsHelper.appid=10118
        -- end
    end
end

--新手引导统计
function statisticsHelper:tutorial(step,lastStep)
    if(G_isToday(playerVoApi:getRegdate())~=true)then
        do return end
    end
    local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."user/tutorial?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&step="..step.."&zid="..curZid.."&laststep="..lastStep.."&stime="..base.serverTime
    if G_isToday(playerVoApi:getRegdate()) then
        HttpRequestHelper:sendAsynHttpRequest(url,"")
        print("新手引导",url)
    end
end

--连续登录统计
function statisticsHelper:login(day,isactive)
    local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."user/login?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&day="..day.."&zid="..curZid.."&invite=0".."&stime="..base.serverTime
    if(isactive)then
        url=url.."&isactive="..isactive
    end
    if(playerVoApi:getTutorial()>=10)then
        url=url.."&tutorial=1"
    end
    HttpRequestHelper:sendAsynHttpRequest(url,"")
    local localUidData=CCUserDefault:sharedUserDefault():getStringForKey("localUidData")
    if(localUidData==nil or localUidData=="")then
        localUidData={}
    else
        localUidData=G_Json.decode(localUidData)
    end
    local zoneID
    if(base.curOldZoneID and tonumber(base.curOldZoneID)>0)then
        zoneID=tonumber(base.curOldZoneID)
    else
        zoneID=tonumber(base.curZoneID)
    end
    local num=#localUidData
    local flag=false
    for k,v in pairs(localUidData) do
        if(v[1]==base.curUid)then
            flag=true
            localUidData[k]={base.curUid,zoneID,playerVoApi:getPlayerName(),playerVoApi:getRegdate()}
            break
        end
    end
    if(flag==false)then
        table.insert(localUidData,{base.curUid,zoneID,playerVoApi:getPlayerName(),playerVoApi:getRegdate()})
    end
    if(num>=100)then
        table.remove(localUidData,1)
    end
    CCUserDefault:sharedUserDefault():setStringForKey("localUidData",G_Json.encode(localUidData))
    print("连续登录",url)
end

--前台错误日志统计
function statisticsHelper:clientErr(msg)
    if (self.clientErrLastSendTime==0 or (base.serverTime-self.clientErrLastSendTime)>600) then --发送错误日志的最短时间间隔是10分钟
        self.clientErrLastSendTime=base.serverTime
        if self.clientErrLastSendTime==0 then
            self.clientErrLastSendTime=1
        end
        local url
        if(G_curPlatName()=="0")then
            url="http://192.168.8.213/test_gm_index/GetErrorApi/getError"
        else
            url="http://gm.rayjoy.com/tank_gm/gm_index/GetErrorApi/getError"
        end
        local gameName="tkfy"
        local platID
        if(platCfg and platCfg.platCfgAppid and platCfg.platCfgAppid[G_curPlatName()])then
            platID=platCfg.platCfgAppid[G_curPlatName()]
        else
            platID=G_curPlatName()
        end
        local cVersion=G_Version
        local uid=base.curUid
        local data={msg=msg,game=gameName,platid=platID,version=cVersion,uid=uid}
        data=G_Json.encode(data)
        G_sendHttpAsynRequest(url,"data="..data,nil,2)
        print("错误日志统计",url)
    end
end

--充值统计
function statisticsHelper:recharge(orderId,amount,itemId,type)
local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."vc/request?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&zid="..curZid
    if(orderId)then
        url=url.."&orderId="..orderId
    end
    if(amount)then
        url=url.."&amount="..amount
    end
    if(itemId)then
        url=url.."&itemId="..itemId
    end
    if(type)then
        url=url.."&type="..type
    end    
    HttpRequestHelper:sendAsynHttpRequest(url,"")
    print("充值统计",url)
end
--充值成功统计
function statisticsHelper:rechargeSuccess(GoodsCount,num,itemId,orderId,amount)
    local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."vc/success?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&zid="..curZid
    if GoodsCount then
        url=url.."&GoodsCount="..GoodsCount
    end
    if num then
        url = url.."&num="..num
    end
    if itemId then
        url = url.."&itemId="..itemId
    end
    if orderId then
        url = url.."&orderId="..orderId
    end
    if amount then
       url = url.."&amount="..amount
    end
    HttpRequestHelper:sendAsynHttpRequest(url,"")
    print("充值成功统计",url)
end
--购买物品统计
function statisticsHelper:buyItem(itemId,price,num,amount)
local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."item/buy?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&zid="..curZid.."&itemId="..itemId.."&price="..price.."&num="..num.."&amount="..amount
    HttpRequestHelper:sendAsynHttpRequest(url,"")
    print("购买物品统计",url)
end
--使用物品统计
function statisticsHelper:useItem(itemId,num)
local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."item/use?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&zid="..curZid.."&itemId="..itemId.."&num="..num
    HttpRequestHelper:sendAsynHttpRequest(url,"")
    print("使用物品统计",url)
end

--在线统计（5分钟一次）
function statisticsHelper:online(day)
local curZid=G_mappingZoneid()
    local url=serverCfg.statisticsUrl.."user/update?uid="..base.curUid.."&appid="..self.appid.."&appkey="..self.appkey.."&day="..day.."&zid="..curZid.."&invite=0".."&stime="..base.serverTime
    HttpRequestHelper:sendAsynHttpRequest(url,"")
    print("在线统计",url)
end

--统计不支持跨服军团战的用户，如果SocketHandler2为空的话说明不支持跨服军团战
function statisticsHelper:noSocket2()
    HttpRequestHelper:sendAsynHttpRequest("http://203.195.131.211/tank-gflog/gfdata/tongjikfz.php?plat="..base.serverPlatID.."&platid="..G_curPlatName().."&pid="..G_getUserPlatID().."&uid="..playerVoApi:getUid().."&vip="..playerVoApi:getVipLevel().."&level="..playerVoApi:getPlayerLevel().."&cver="..G_Version,"")
end

--统计用户设置选项
function statisticsHelper:uploadOption(key)
    local func
    if key == "ui" then
        local flag = CCUserDefault:sharedUserDefault():getIntegerForKey("ui_statistic")
        if tonumber(flag or 0) ~= 1 then --没有统计过
            local ver = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSetting_newMainUI")
            if ver == 1 then
                func = "ui_ver1"
            end
        end
    end
    if func == nil then
        do return end
    end
    local plat = ""
    local serverpid = G_getServerPlatId()
    if platCfg.gmNameCfg and platCfg.gmNameCfg[serverpid] then
        plat = platCfg.gmNameCfg[serverpid]
    end
    local url = "http://gm.rayjoy.com/tank_gm/gm_index/platform/statistics"
    if G_curPlatName() == "0" then --本地
        url = "http://192.168.8.213/test_gm_index/platform/statistics"
        plat = "gm_213"
    end
    local params = "plat="..plat.."&func="..(func or "")
    -- print("params===> ", params)
    local function callback(data, result)
        if tonumber(result) < 0 then
            do return end
        end
        if key == "ui" then
            -- print("===statistic end===")
            CCUserDefault:sharedUserDefault():setIntegerForKey("ui_statistic", 1)
            CCUserDefault:sharedUserDefault():flush()
        end
    end
    local result = G_sendHttpAsynRequest(url, params, callback, 2)
end