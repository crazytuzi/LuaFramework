-- 
-- 远洋征战定时生成战力快照
-- yunhe
-- 
function api_cron_oceanexfcrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local zoneid = getZoneId()
    local ts = getClientTs()

    writeLog("远洋征战战力排行榜快照" .. ts, "ocean")
    -- 判断当前是哪种结算
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local oceaninfo,code = mServerbattle.getOceanExpeditionInfo()
    if code~=0 or not next(oceaninfo) then
        response.ret = -102
        response.msg = 'not open'
        return response
    end

    local cfg = getConfig("oceanExpedition")
    local bid = tonumber(oceaninfo.bid)
    local st = tonumber(oceaninfo.st)
    local et = tonumber(oceaninfo.et)
    local mOceanMatch = getModelObjs("oceanmatches",bid)
    -- 有预热期 则在预热期之后生成
    if cfg.proTime>0 then
        if ts>=st + cfg.proTime*86400 then
            mOceanMatch.ranksnap(st,et)
        end
    else
        mOceanMatch.ranksnap(st,et)
    end

    response.ret=0
    response.msg ='Success'
     
    return response

end