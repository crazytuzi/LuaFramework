-- 读取天梯
function api_skyladderserver_refrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local bid = tonumber(request.params.bid) or 0

    if not bid then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    
    local skyladderStatus,err = skyladderserver.getStatus()
    if not skyladderStatus or not skyladderStatus.cubid or tonumber(skyladderStatus.status) == 0 then
        response.ret = -19000
        response.msg = "error"
    end
    
    local num1 = skyladderserver.checkRecordNum(bid,'person')
    local ranklist1 = skyladderserver.refRanking(bid,'person',1,100)
    if not next(ranklist1) and num1 > 0 then
        local num,resetnum = skyladderserver.resetPointRank(bid,'person',true)
        ranklist1 = skyladderserver.refRanking(bid,'person',1,100)
    end
    
    local num2 = skyladderserver.checkRecordNum(bid,'alliance')
    local ranklist2 = skyladderserver.refRanking(bid,'alliance',1,100)
    if not next(ranklist2) and num2 > 0 then
        local num,resetnum = skyladderserver.resetPointRank(bid,'alliance',true)
        ranklist2 = skyladderserver.refRanking(bid,'alliance',1,100)
    end
    
    response.ret = 0
    response.msg = 'Success'
    response.data = {ranklist1=ranklist1,ranklist2=ranklist2}

    return response
end