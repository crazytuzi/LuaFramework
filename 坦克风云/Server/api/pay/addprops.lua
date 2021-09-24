--
-- 360币增加物品
-- User: luoning
-- Date: 14-11-6
-- Time: 下午4:20
--

function api_pay_addprops(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local pid = request.params.pid
    local odder_id = request.params.odder_id
    local platform = request.params.platform

    if not string.find(pid, "p") then
        pid = "p" .. pid
    end
    local num = request.params.num and tonumber(request.params.num) or 0
    local point = request.params.point and tonumber(request.params.point) or 0

    if uid == nil or pid == nil or num == 0 or point == 0 or odder_id == nil then
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

    local config = getConfig("player")
    if not config.shopVate then
        writeLog(json.encode(request.params), "360pay")
        return response
    end

    local gold_num = point * config.shopVate

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    mUserinfo.addResource({vippoint=gold_num})
    mUserinfo.updateVipLevel()
    local ret = mBag.add(pid, num)
    --记录log
    regActionLogs(uid,1,{action=44,item="",value=gold_num,params={pid,num,point}})
    local cmd = 'pay.addprops.push'
    regSendMsg(uid, cmd, {pid=pid,num=num,point=point,vip=mUserinfo.vip})

    if ret and uobjs.save() then
        local ts = getClientTs()
        local tradelog = {
            id = odder_id,
            userid = uid,
            num = gold_num,
            trade_type = platform,
            status = 1,
            create_time = ts,
            updateTime = ts,
            curType="360money",
        }

        createTradeLog(tradelog)

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.userinfo.ip = mUserinfo.ip

        response.ret = 0
        response.msg = "Success"
    else
        writeLog(json.encode(request.params), "360pay")
    end

    return response
end

