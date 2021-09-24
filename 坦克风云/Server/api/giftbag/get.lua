function api_giftbag_get(request)
    local response = {
            ret=-1,
            msg='error',
            data = {giftbagget={}},
        }
    
    -- 兑奖平台暂时关闭，请稍候再试 
    if moduleIsEnabled('code') == 0 then
        response.ret = -309
        return response
    end

    local card = request.params.card
    local uid = tonumber(request.uid)
    local zoneid = getZoneId()
    local systemos = request.system or 'other'
    local appid = request.appid or getConfig('base').AppPlatformID
    
    if not card or not uid then
        response.ret = -102
        return response
    end
    
    -- 判断card前3位，E01为跨平台激活码
    local px = string.upper(string.sub(card,1,3))
    if px ~= 'S01' then
        -- print('old api')
        -- 向礼包中心获取礼包信息---------------------------------------

        local cardInfo  -- 礼包信息
        local zoneid = getZoneId()
        local postdata = "card="..card
        local giftCenterUrl = getConfig("config.z".. zoneid ..".giftCenterUrl")
        -- giftCenterUrl = 'http://192.168.8.112/giftbag/index.php/'

        local http = require("socket.http")
        http.TIMEOUT= 3    
        local respbody, code = http.request(giftCenterUrl.. 'get',postdata)

        -- 调试信息
        if sysDebug() then
            ptb:p(giftCenterUrl ..'get' .. '?' .. (postdata or ''))
        end

        if tonumber(code) == 200 then     
            local result = json.decode(respbody)
            if type(result) ~= 'table' then
                writeLog('alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'giftFaild')
                response.ret = -304
                return response
            end

            if tonumber(result.ret) ~= 0 then
                response.ret = tonumber(result.ret)
                return response
            end

            cardInfo = result.data.card 
        else
            writeLog(code..'alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'giftFaild')
            response.ret = -307
            return response
        end

        -- ------------------------------------------------
        local giftCfg = getConfig("gift")

        -- 类型为1的时候，只能使用一次，不管cdkey，都只能使用一次
        local cardType = tonumber(cardInfo.type)    
        local cardBag = tonumber(cardInfo.bag)
        local mCard = require "model.card"
        local selfCardInfo

        -- 如果是人为规过类的，在此类型中都按一种类型处理
        local giftCategoryBag = nil

        if cardType == 1 then
            if giftCfg.giftCategory and giftCfg.giftCategory[cardBag] then
                giftCategoryBag = giftCfg.giftCategory[cardBag]
            else
                giftCategoryBag = cardBag
            end
            selfCardInfo = mCard:getCardByType(uid,cardType,giftCategoryBag,card)
        elseif cardType ==2 then
            selfCardInfo = mCard:get(card)
        elseif cardType == 3 then
            selfCardInfo = {}
            local use = mCard:getPublicCard(uid,cardInfo.cdkey)
            if use then
                response.ret = -311
                return response
            end
        else
            response.ret = -304
            return response
        end
        
        if type(selfCardInfo) == 'table' and next(selfCardInfo) then
            if selfCardInfo.cdkey == card then
                response.ret = -305
            else
                response.ret = -311
            end
            
            return response
        end

        if cardInfo.type_r and (cardInfo.type_r ~= 0 or cardInfo.type_r ~= '0') then
            local type_r = mCard:getCardByReject(uid,card,cardInfo.type_r)
            if type_r then
                response.ret = -311
                return response
            end
        end
        
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
        local mUserinfo = uobjs.getModel('userinfo')

        local reward = nil
        if tonumber(cardInfo.bag) > 0 and tonumber(cardInfo.bag) < 1000 then
            reward = giftCfg[tonumber(cardInfo.bag)]
        elseif cardInfo.content then
            reward = {}
            --扩展字段content 传过来的物品json串默认不带前缀props_ ,加上发奖
            local giftReward = json.decode(cardInfo.content)
            for kReward, vNum in pairs(giftReward) do 
                local idparams = string.split(kReward,'_')
                if #idparams > 1 then
                    reward[idparams[1].."_"..idparams[2]] = vNum
                else
                    reward["props_" .. kReward] = vNum
                end
            end
            response.data.giftbagget.cardInfo = {title=cardInfo.title, desc=cardInfo.desc}
            cardInfo.content = nil
            cardInfo.desc = nil
            cardInfo.title = nil
        end

        -- 序列号无对应的奖品，请联系管理员
        if not reward then
            response.ret = -308
            return response
        end

        local ret = takeReward(uid,reward)
        if cardType == 3 and ret then
            local infostorage = uobjs.getModel('infostorage')
            local cdkeyInfo = infostorage.getInfo('cdkey')
            cdkeyInfo[cardInfo.cdkey] = cardInfo.et
            infostorage.setInfo('cdkey',cdkeyInfo)
        end

        local s = 'failed'

        local db = getDbo()
        db.conn:setautocommit(false)

        if ret and uobjs.save() then
            if cardType ~= 3 then
                cardInfo.uid = uid
                cardInfo.zoneid = zoneid
                cardInfo.status = 1

                if giftCategoryBag then
                cardInfo.bag = giftCategoryBag
                end
                
                mCard:set(cardInfo)
            else
                cardInfo.uid = 0
                cardInfo.zoneid = zoneid
                cardInfo.status = 1
                mCard:setPublic(cardInfo)
            end
        end

        if db.conn:commit() then
            response.ret = 0
            response.data.giftbagget.reward = formatReward(reward);
            response.msg = 'Success'
            s = 'Success'

            postdata = {
                uid = uid,
                card=card,
                zoneid = zoneid,
                s = s,
            }

            postdata = formPostData(postdata)

            if cardType ~= 3 then
                if sysDebug() then ptb:p(giftCenterUrl .. 'use?'..postdata) end
                http.request(giftCenterUrl.. 'use',postdata)
            end
        end
        
        return response
    else
        -- print('new api')
        local public_url = getConfig("config.z".. zoneid ..".giftCenterUrl")
        -- 向礼包中心获取礼包信息---------------------------------------
        local cardInfo  -- 礼包信息
        local postData = {
            cdkey = card,
            game_user_id = uid,
            game_zone_id = zoneid,
            os = systemos,
            sub_app_id = appid,
        }

        postData = http_build_query(postData)

        local http = require("socket.http")
        http.TIMEOUT= 3    
        local respbody,code = http.request(public_url..'getpublic',postData)

        -- 调试信息
        if sysDebug() then
            ptb:p(public_url..'getpublic'..'?'..(postData or ''))
        end

        if tonumber(code) == 200 then     
            local result = json.decode(respbody)
            if sysDebug() then
                print('respbody')
                ptb:p(respbody)
            end
            if type(result) ~= 'table' then
                writeLog('alliance_fetch failed:' .. (postData or 'no postData') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'giftFaild')
                response.ret = -3041
                return response
            end

            if tonumber(result.ret) ~= 0 then
                response.ret = tonumber(result.ret)
                return response
            end

            cardInfo = result.data.card 
        else
            writeLog(code..'alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'giftFaild')
            response.ret = -307
            return response
        end

        -- 检查服内是否可用
        local cardType = tonumber(cardInfo.type) or 0
        local cardBag = cardInfo.bag or 0
        local saelfCardInfo

        local mCard = require "model.card"

        if cardType == 1 then
            selfCardInfo = mCard:getCardByType(uid,cardType,cardBag,card)
        elseif cardType == 2 then
            selfCardInfo = mCard:get(card)
        elseif cardType == 3 then
            selfCardInfo = {}
            local use = mCard:getPublicCard2(uid,cardInfo.cdkey)
            if use then
                response.ret = -311
                return response
            end
        else
            response.ret = -3042
            return response
        end
        
        if type(selfCardInfo) == 'table' and next(selfCardInfo) then
            if selfCardInfo.cdkey == card then
                response.ret = -305
            else
                response.ret = -311
            end
            
            return response
        end
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
        local mBag = uobjs.getModel('bag')
        local mUserinfo = uobjs.getModel('userinfo')    
        local reward = {}
        local giftReward = json.decode(cardInfo.content)
        for kReward, vNum in pairs(giftReward) do 
            local idparams = string.split(kReward,'_')
            if #idparams > 1 then
                reward[idparams[1].."_"..idparams[2]] = vNum
            else
                reward["props_" .. kReward] = vNum
            end
        end

        cardInfo.content = nil
        cardInfo.desc = nil
        cardInfo.title = nil

        -- 序列号无对应的奖品，请联系管理员
        if not reward then
            response.ret = -308
            return response
        end
        
        local ret = takeReward(uid,reward)
        if cardType == 3 and ret then
            local infostorage = uobjs.getModel('infostorage')
            local cdkeyInfo = infostorage.getInfo('cdkey2')
            cdkeyInfo[cardInfo.cdkey] = cardInfo.et
            infostorage.setInfo('cdkey2',cdkeyInfo)
        end
        
        local s = 'failed'

        local db = getDbo()
        db.conn:setautocommit(false)

        if uobjs.save() then
            if cardType ~= 3 then
                local useCardInfo = {
                    uid = uid,
                    cdkey = card,
                    type = cardType,
                    zoneid = zoneid,
                    status = 1,
                    st = 1,
                    et = 1,
                    bag = cardBag,
                }

                mCard:set(useCardInfo)
            else
                cardInfo.uid = 0
                cardInfo.zoneid = zoneid
                cardInfo.status = 1
                mCard:setPublic(cardInfo)
            end
        end

        if db.conn:commit() then
            response.ret = 0
            response.data.giftbagget.reward = formatReward(reward);
            response.msg = 'Success'

            local postData = {
                cdkey = card,
                game_user_id = uid,
                game_zone_id = zoneid,
                os = systemos,
                status = 1,
                sub_app_id = appid,
            }

            postData = http_build_query(postData)

            if sysDebug() then ptb:p(public_url..'updatepublic?'..postData) end
            
            http.request(public_url..'updatepublic',postData)
        end
        
        return response
    end
    
    return response
end
