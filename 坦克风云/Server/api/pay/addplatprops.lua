--
-- 新平台增加道具
-- User: luoning
-- Date: 14-12-20
-- Time: 下午3:19
--

function api_pay_addplatprops(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local taskid = request.params.rewardid
    local odder_id = request.params.odder_id
    local platform = request.params.platform or ""

    if uid == nil or taskid == nil or odder_id == nil  then
    print(1111)
        return response
    end
    taskid = tonumber(taskid)
    local giftConfig = getConfig("newPlatGift")
    if not giftConfig[taskid] then
        return response
    end

    local function payLog(logInfo,filename)
        local log = ""
        log = log .. os.time() .. "|"
        log = log .. (logInfo.uid or ' ') .. "|"
        log = log .. (logInfo.msg or ' ') .. "|"
        log = log .. (logInfo.code or '-1')

        filename = filename or 'pay'
        writeLog(log,filename)
    end

    local function createTradeLog(tradelog)
        local db = getDbo()

        local ret = db:insert('tradelog',tradelog)
        local queryStr = db:getQueryString() or ''
        if not ret  then
            payLog({uid=uid,msg='insert failed: '..queryStr,code=-130})
        end
    end

    -- 获取订单
    local function getTradeLog(odder_id)
        local db = getDbo()
        local result = db:getRow("select * from tradelog where id = :id and status = 1",{id=odder_id})
        if type(result) == 'table' and next(result) then
            return true
        end
    end

    -- 订单已经成功处理过
    if getTradeLog(odder_id) then
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local gold_num = 0
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local reward = giftConfig[taskid].serverReward

    if not takeReward(uid, reward) then
        return response
    end

    local tmpProps = {}
    for mtype,mnum in pairs(reward) do
        local tmpType = mtype:split("_")
        tmpProps[tmpType[2]] = mnum
    end

    local cmd = 'pay.addnewplatprops.push'
    regSendMsg(uid, cmd, {props=tmpProps,taskid=taskid})
    if uobjs.save() then
        local ts = getClientTs()
        local tradelog = {
            id = odder_id,
            userid = uid,
            num = gold_num,
            trade_type = platform,
            status = 1,
            create_time = ts,
            updateTime = ts,
            curType="newPlatReward",
            comment=tmpProps,
        }

        createTradeLog(tradelog)

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.userinfo.ip = mUserinfo.ip

        response.ret = 0
        response.msg = "Success"
    else
        writeLog(json.encode(request.params), "newPlatReward")
    end

    return response

end

