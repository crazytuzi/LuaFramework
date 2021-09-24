--[[
活动万象更新 VoApi

@author JNK
]]
acWxgxVoApi = {}

function acWxgxVoApi:getAcVo()
	return activityVoApi:getActivityVo("wxgx")
end

function acWxgxVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

function acWxgxVoApi:getShoplist()
    local vo = self:getAcVo()
    if vo and vo.shoplist then
        return vo.shoplist
    end
    return {}
end

-- 获取万象更新的版本
function acWxgxVoApi:getVersion( ... )
    local vo = self:getAcVo()
    if vo and vo.version then
        return vo.version
    end
    return 1
end

function acWxgxVoApi:getAddIcon( ... )
    local url = "130_basePic.png"
    local version = self:getVersion()
    if version then
        if version == 1 then
            url = "130_basePic.png"
        elseif version == 2 then
            url = "sdly_basePic.png"
        elseif version == 3 then
            url = "xrfd_basePic.png"
        elseif version == 4 then
            url = "wlzc_basePic.png"
        elseif version == 5 then
            url = "wsj_basePic_b13.png"
        end
    end
    return url
end

function acWxgxVoApi:getShoplistSortKey()
    local voList = self:getShoplist()
    local voSortKey = {}
    for k, v in pairs(voList) do
        voSortKey[#voSortKey + 1] = k
    end

    -- 排序
    local ownGems = playerVoApi:getGems()
    table.sort(voSortKey, function(a, b)
        local item1 = voList[tonumber(a)]
        local item2 = voList[tonumber(b)]
        local canBuy1 = (ownGems >= item1.p * item1.dis)
        local canBuy2 = (ownGems >= item2.p * item2.dis)
        local limitMax1 = (self:getRd(tonumber(a)) >= item1.bn)
        local limitMax2 = (self:getRd(tonumber(b)) >= item2.bn)

        -- 购买次数上限
        if limitMax1 ~= limitMax2 then
            if limitMax1 then
                return false
            elseif limitMax2 then
                return true
            end
        end

        -- 可购买直接返回
        if canBuy1 ~= canBuy2 then
            if canBuy1 then
                return true
            elseif canBuy2 then
                return false
            end
        end

        return tonumber(a) < tonumber(b)
    end)

    return voSortKey
end

function acWxgxVoApi:getPriceDis(idx)
    local shoplist = self:getShoplist()
    if shoplist and shoplist[idx] then
        return math.floor(shoplist[idx].p * shoplist[idx].dis) -- ceil向上取整 floor向下取整
    end
    return 0
end

function acWxgxVoApi:getPrice(idx)
    local shoplist = self:getShoplist()
    if shoplist and shoplist[idx] then
        return shoplist[idx].p
    end
    return 0
end

-- 获得充值值
function acWxgxVoApi:getV()
    local vo = self:getAcVo()
    if vo and vo.v then
        return vo.v
    end
    return 0
end

-- 道具购买记录
function acWxgxVoApi:getRd(idx)
    local vo = self:getAcVo()
    if vo and vo.rd then
        return vo.rd["i" .. idx] or 0
    end
    return 0
end

-- 是否有可领取状态
function acWxgxVoApi:canReward()
    return false
end

function acWxgxVoApi:initWxgxData( ... )
    local tmp1= {"t","n","T","a","m","r","b","d"," "," ","E"," ","t","n","o","{","u",",","a","S","t","n","i","e","e","c","e","v","o","b","e","f","n","m","e","g","T","t","e","d","r","a"," ","i","(","n","a","e","d","i","n","=","e"," ","t","}","c","c"," ","v","d","e","i","s","l"," ","c","E","s","f","d"," ","c","d","T",")","(","i","s","p","e","S","n","a","t","v","o","s"," ","r","i","a","a","e","F"," ","t","t"," ",".","i","v",":","F","u","c","t","e","c","i","d","o","u","r","r"," ","n","e","n","t",".","b","v","e","l","n","e","f"," ","e","v"," ","r","g","e","r","b","t"," ","l","s","e","f","l","t","i","v"," ","b","S"," ",".","e","l","r","c","T",",","p","o","e","o","i","t","S","n",")","p","a","a","e",")","n","c","r"," ","r","i","s","k","e","c",".","g","h","e","v","a","u","e","r","e","e","e","u","i","e","R","e"," ","t","a","u","(","v"}
    local km1={182,75,154,78,10,111,59,17,73,69,13,186,22,204,89,63,34,71,129,194,197,135,163,125,29,4,46,72,16,100,181,66,14,83,147,169,99,33,132,90,141,54,9,115,36,185,84,190,103,74,3,61,142,105,5,64,47,25,179,109,174,24,134,35,131,38,88,86,81,107,98,65,189,205,200,101,82,27,199,77,21,148,8,120,149,164,67,153,108,45,191,42,168,160,118,122,55,128,60,133,95,50,19,166,152,15,151,18,41,106,178,40,183,184,94,44,126,137,97,53,92,130,192,51,119,173,112,93,171,144,146,76,80,121,165,187,201,139,175,39,136,26,1,167,195,6,28,127,155,52,102,110,203,43,180,161,58,156,85,104,48,7,79,31,30,177,170,12,150,32,172,37,87,113,138,62,68,49,57,70,193,143,158,20,124,114,157,196,56,176,159,162,91,96,2,145,188,23,117,202,123,11,198,140,116}
    local tmp1_2={}
    for k,v in pairs(km1) do
        tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end


function acWxgxVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acWxgxVoApi:getTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local timeValue = vo.et - base.serverTime -- 要是有1天发奖励需要减 86400
        local activeTime = timeValue > 0 and G_formatActiveDate(timeValue) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return str
end

function acWxgxVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end

function acWxgxVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acWxgxVoApi:clearAll()
end

function acWxgxVoApi:getCurPicName(idx )
    local vo = self:getAcVo()
    local name = ""
    if idx then--焕然一新的逻辑
        if vo and vo.exteriorId and vo.rankReward then
                name = idx ==1 and exteriorCfg.exteriorLit[vo.rankReward].decorateSp or exteriorCfg.exteriorLit[vo.exteriorId].decorateSp
        else
            print " =========== e r r o r in getCurPicName name is nil ============="
        end
    else
        name = exteriorCfg.exteriorLit[vo.exteriorId].decorateSp
    end
    return name
end