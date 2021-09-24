-- 结算
function api_skyladderserver_startnextseasondata(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }
    
    local ts = getClientTs()
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    skyladderserver.setautocommit(false)
    local skyladderStatus,err = skyladderserver.getStatus()
    
    if not skyladderStatus or not skyladderStatus.cubid or tonumber(skyladderStatus.status) == 0 then
        response.ret = -19000
        response.msg = "error"
        return response
    end
    
    --if not skyladderStatus or not skyladderStatus.nextready or skyladderStatus.nextready == 1 then
    if not skyladderStatus or (skyladderStatus.nextready and tonumber(skyladderStatus.nextready == 1)) then
        response.ret = -19001
        response.err = err
        return response
    end
    
    local nextreadytime = tonumber(skyladderStatus.nextreadytime) or 0
    if nextreadytime > 0 and nextreadytime <= ts then
        writeLog('start next data','skyladderCheckNextData')
        local ret1 = skyladderserver.startnextseasondata(skyladderStatus.cubid,'person')
        local ret2 = skyladderserver.startnextseasondata(skyladderStatus.cubid,'alliance')
        if ret1 and ret2 and skyladderserver.commit() then
            response.ret = 0
            response.msg = 'Success'
            response.data = {nextready=1}
        end
    end
    
    -- 刷新下赛季数据
    local nextBid = skyladderStatus.cubid + 1
    local num1 = skyladderserver.checkRecordNum(nextBid,'person')
    local ranklist1 = skyladderserver.refRanking(nextBid,'person',1,100)
    if not next(ranklist1) and num1 > 0 then
        local num,resetnum = skyladderserver.resetPointRank(nextBid,'person',true)
        ranklist1 = skyladderserver.refRanking(nextBid,'person',1,100)
    end
    
    local num2 = skyladderserver.checkRecordNum(nextBid,'alliance')
    local ranklist2 = skyladderserver.refRanking(nextBid,'alliance',1,100)
    if not next(ranklist2) and num2 > 0 then
        local num,resetnum = skyladderserver.resetPointRank(nextBid,'alliance',true)
        ranklist2 = skyladderserver.refRanking(nextBid,'alliance',1,100)
    end
    
    local db = getCrossDbo("skyladderserver")
    local list = db:getAllRows("select id,zid from skyladder_personinfo where bid = '"..nextBid.."'")
    local num = #list
    
    for i=1,num do
        local myrank = skyladderserver.refRank(nextBid,'person',list[i].zid,list[i].id) or 0
        local rankdata = skyladderserver.refRankData(nextBid,'person',list[i].zid,list[i].id,true) or {}
        local blog = skyladderserver.refLogData(nextBid,'person',list[i].zid,list[i].id) or {}
    end
    
    local db = getCrossDbo("skyladderserver")
    local list = db:getAllRows("select id,zid from skyladder_allianceinfo where bid = '"..nextBid.."'")
    local num = #list
    
    for i=1,num do
        local myrank = skyladderserver.refRank(nextBid,'alliance',list[i].zid,list[i].id) or 0
        local rankdata = skyladderserver.refRankData(nextBid,'alliance',list[i].zid,list[i].id,true) or {}
        local blog = skyladderserver.refLogData(nextBid,'alliance',list[i].zid,list[i].id) or {}
    end
    
    writeLog(json.encode(response),'skyladderCheckNextData')

    return response
end