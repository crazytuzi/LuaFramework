--
-- 注册送话费活动
-- User: luoning
-- Date: 14-8-27
-- Time: 下午12:03
--
function api_active_calls(request)
    --活动名称
    local aname = 'calls'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local action = request.params.action
    local payBaseUrl = "http://tank-fl-app.raysns.com/tank_rayapi/index.php/";

    local fetchUrl = function(url)
        local http = require("socket.http")
        http.TIMEOUT= 5
        local respbody, code = http.request(url)
        return respbody, code
    end

    --回调用户充值信息记录
    if action == 'callResult' then
        local tradeId = request.params.orderId
        local resultStatus = request.params.result
	    local uid = request.uid
        if tradeId == nil or resultStatus == nil or uid == nil then
            return response
        end
         --记录用户手机号充值状态
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        mUseractive.info[aname].ls = ""..resultStatus
        -- 活动检测
        local activstatus = mUseractive.getActiveStatus(aname)
        if activstatus ~= 1 then
            response.ret = activstatus
            return response
        end

        local db = getDbo()
        local result = db:getRow("select id,uid,reward from phoneinfo where tradeId = :id",{id=tradeId})
        if not result then
            return response
        end
        --存放交易数据
        db:update('phoneinfo', {status=resultStatus}, "tradeId = '"..tradeId.."'")
        --充值返回状态推送给前台
        local cmd = 'active.calls.push'
        regSendMsg(uid, cmd, {status=resultStatus,phone=result['id'],num=result['reward']})

        if not uobjs.save() then
            return response
        end
        response.ret = 0
        return response
    --查询话费信息接口
    elseif action == 'search' then

        local uid = request.uid
        local tradeId = request.params.tradeId
        if uid == nil or tradeId == nil then
            return response
        end

        --记录用户手机号充值状态
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activstatus = mUseractive.getActiveStatus(aname)
        if activstatus ~= 1 then
            response.ret = activstatus
            return response
        end

        response.resCode = {}
        local db = getDbo()
        local result = db:getRow("select id,tradeId,reward,status from phoneinfo where tradeId = :id",{id=tradeId})
        if not result then
            response.ret = 0
            response.resCode.status = 3
            response.resCode.num = 0
            response.resCode.phone = 0
            return response
        end
	    response.msg = 'Success'
        if result['status'] == '0' then
            response.ret = 0
            response.resCode.status = 0
	        response.resCode.phone = result['id']
            response.resCode.num = result['reward']
            return response
        end

        local requestStr = 'tradeId='..result['tradeId']..'&phoneNum='..result['id']..'&account='..result['reward']
        local str = payBaseUrl .. 'feiliuappcallssearch?'..requestStr
        local resultStatus = fetchUrl(str)

        if not resultStatus or resultStatus == nil then
            response.ret = -1
            return response
        end
        resultStatus = json.decode(resultStatus)
        if type(resultStatus) ~= 'table' then
            response.ret = -1
            return response
        end

        --[[
        1000 = 订单支付成功
        1001 = 订单下单失败
        1002 = 订单支付中
        1003 = 订单支付失败
        1004 = 订单不存
        --]]
        local status = resultStatus['status']
        if status == "1000" then
            mUseractive.info[aname].ls = 0
        elseif status == "1001" then
            mUseractive.info[aname].ls = 1
        elseif status == "1002" then
            mUseractive.info[aname].ls = 2
        elseif status == "1003" then
            mUseractive.info[aname].ls = 1
        elseif status == "1004" then
            mUseractive.info[aname].ls = 1
        end
        --支付失败时更新支付状态
        if (mUseractive.info[aname].ls == 1 and result['status'] ~= '1')
        or (mUseractive.info[aname].ls == 0 and result['status'] ~= '0') then
            db:update('phoneinfo', {status=""..mUseractive.info[aname].ls}, "id='" .. result['id'].."'")
        end

        if uobjs.save() then
            response.ret = 0
            response.resCode.status = mUseractive.info[aname].ls
            response.resCode.num = result['reward']
            response.resCode.phone = result['id']
        end
	    return response
    --前台请求接口
    else

        local uid = request.uid
        local phoneNum = request.params.phoneNum

        if uid == nil or phoneNum == nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activstatus = mUseractive.getActiveStatus(aname)
        if activstatus ~= 1 then
            response.ret = activstatus
            return response
        end
        local activeCfg =  getConfig("active." .. aname )
        --标识
        local getVipTag = function(userVip, vipCfg)
            local length = #vipCfg
            for i = 1, length do
                if userVip >= vipCfg[length - i + 1] then
                    return length - i + 1
                end
            end
            return false
        end

        --发送奖励
        local takePhoneReward = function(userFlag, phoneNum, vipReward, mt, ls)
            if mt == nil then
                mt = 0
            end
            --用户充值失败次数
            if mt > 5 then
                return "1005"
            end
            --改账号是否已经领取奖励
            if userFlag > 0 and tonumber(ls) ~= 1 then
                if tonumber(ls) == 0 then
                    return "1004"
                else
                    return "1003"
                end
            end
            --验证手机号
            if not (type(phoneNum) == 'string' or type(phoneNum) == 'number') then
                return "1002"
            end
            local phoneNum = ""..phoneNum
            local phoneNewNum = string.gsub(phoneNum, "[^0-9]", "")
            if #phoneNum ~= #phoneNewNum or #phoneNewNum ~= 11  or string.sub(phoneNewNum, 1, 1) ~= "1" then
                return "1002"
            end
            phoneNewNum = tonumber(phoneNewNum)
            local db = getDbo()
            local tradeResult = db:getRow("select id,status from phoneinfo where id = :id",{id=phoneNewNum})
            --检查充值， 充值是否成功 1的时候为失败 2为正在充值
            if tradeResult and tonumber(tradeResult['status']) ~= 1 then
                if tradeResult['status'] == '0000' then
                    return "1006"
                else
                    return "1006"
                end
            end
            mt = mt + 1
            --生成交易Id号
            local getTradeId = function(mt)
                local tradeId = getZoneId() .. 'ray' .. phoneNewNum ..'m'.. uid .. 'm'
                local must = 32
                while #tradeId < must do
                    tradeId = tradeId .. mt
                end
                return tradeId
            end

            local tradeId = getTradeId(mt);
            local requestUrl = 'tradeId='..tradeId..'&phoneNum='..phoneNum..'&account='..vipReward
            local url = payBaseUrl .. 'feiliuappcalls?' .. requestUrl
            --请求飞流api
            local result = fetchUrl(url);
            if not result or result == nil then
                return "9999"
            end
            result = json.decode(result);
	    
            if type(result) ~= 'table' then
                return "9999"
            end
            if result["code"] == '0000' then
                if not tradeResult then
                    db:insert("phoneinfo", {id = phoneNewNum, reward = vipReward, updated_at = os.time(),
                                            tradeId = tradeId, uid = uid, status = result['code']})
                else
                    db:update('phoneinfo', {tradeId = tradeId, status=result['code']}, "id='" .. phoneNum.."'")
                end
            else
                tradeId = nil
		        if result["code"] ~= "1002" then
		            result["code"] = '9999'
		        end
            end
            return result["code"], tradeId, mt
        end

        local tag = getVipTag(mUserinfo.vip, activeCfg.vip)
        --test
        --tag = 2
        if not tag then
            response.ret = -1981
            return response
        end
        local vipReward = activeCfg.money[tag]

        --continueFlag = true
        --连续签到活动 newuseraward
        if (not mUseractive.info[aname].nt) or mUseractive.info[aname].nt ~= 1  then
            response.ret = -1981
            return response
        end

        local resCode, tradeId, mt = takePhoneReward(mUseractive.info[aname].v,
            phoneNum, vipReward, mUseractive.info[aname].mt, mUseractive.info[aname].ls)
        if (type(resCode) == 'number' and resCode < 0)
        or (type(resCode) == 'string' and resCode ~= '0000')
        then
            if type(resCode) == 'string' then
                if mUseractive.info[aname].tId then
                    response.tId = mUseractive.info[aname].tId
                end
                response.ret = 0
                response.resCode = resCode
            else
                response.ret = resCode
            end
            return response
        end

        --标识用户已领取
        mUseractive.info[aname].v = tag
        --正在充值
        mUseractive.info[aname].ls = 2
        mUseractive.info[aname].mt = mt
        mUseractive.info[aname].tId = tradeId

        if uobjs.save() then
            response.ret = 0
            response.resCode = "1003"
            response.tId = tradeId
            response.mt = mt
            response.msg = 'Success'
        end
        return response
    end
end

