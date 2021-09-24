function G_isLongLanguage()
    if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" and G_getCurChoseLanguage() ~= "ja" and G_getCurChoseLanguage() ~= "ko" then
        return true
    else
        return false
    end
end

--设置多语言文字大小 bigSize国内字号 smallSize长文字的字号 langType只有这个语言的时候修改
function G_getLS(bigSize, smallSize, langType)
    --如果有过滤语言
    if langType then
        if G_getCurChoseLanguage() == langType then
            return smallSize
        else
            return bigSize
        end
    end
    --如果没有过滤语言，默认所有长的语言
    if G_isLongLanguage() == true then
        return smallSize
    else
        return bigSize
    end
end

function G_is5x(num1, num2)
    local phoneType = G_getIphoneType()
    if phoneType == G_iphone5 or phoneType == G_iphoneX then
        return num1
    end
    return num2
end

--n个图标居中对齐，获得起始坐标
function G_getCenterSx(totalW, iconW, len, midW)
    return (totalW - (iconW + midW) * (len - 1)) * 0.5
end

--加奖励
--rewardList：前端执行FormatItem后的奖励列表
--sr : 是服务端传接口操作后返回的奖励数据。用于判断后端是否在本次同步奖励数据，如果同步前端无需再对奖励做处理。
function G_takeReward(rewardList, sr)
    if rewardList == nil or type(rewardList) ~= "table" then
        do return end
    end
    for k, v in pairs(rewardList) do
        local srFlag = false
        if v.type == "h" and v.eType == "s" then --将领魂魄需要判断是否需要转换
            if sr and sr.hero then
                if sr.bag == nil then --没有返背包数据的话得判断是否需要转换铁十字勋章
                    local hid = heroCfg.soul2hero[v.key]
                    if hid and heroVoApi:heroHonorIsOpen() == true and heroVoApi:getIsHonored(hid) == true then
                        local pid = heroCfg.getSkillItem
                        local id = (tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id, tonumber(v.num))
                    end
                end
            else --如果后端没有返魂魄数据则直接加魂魄，该方法内部有转铁十字勋章的处理
                heroVoApi:addSoul(v.key, tonumber(v.num))
            end
            srFlag = true
        else
            if sr == nil then
                G_addPlayerAward(v.type, v.key, v.id, v.num)
            else
                if (v.type == "p" and sr.bag) or (v.type == "o" and sr.troops and sr.troops.troops) or (v.type == "e" and sr.accessory) then
                    srFlag = true
                end
            end
        end
        if srFlag == false then --如果服务器没有返回对应模块的最新数据则前端自己加奖励
            if v.type == "e" then --配件碎片和材料
                G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
            else
                G_addPlayerAward(v.type, v.key, v.id, v.num)
            end
        end
    end
end

--是否是线上测试服
function G_isTestServer()
    if tonumber(base.curZoneID) == 1000 or tonumber(base.curZoneID) == 1200 then
        return true
    end
    return false
end

--对精灵做翻转操作
--sprite：需要翻转的精灵，flip：翻转的参数，isChild：是否是子节点
function G_setSpriteFlip(sprite, flip, isChild)
    --对节点进行翻转操作
    if flip.x == true then
        sprite:setFlipX(not sprite:isFlipX())
    end
    if flip.y == true then
        sprite:setFlipY(not sprite:isFlipY())
    end
    if flip.x == true or flip.y == true then
        local ro = sprite:getRotation()
        if ro ~= 0 then
            sprite:setRotation(-ro)
        end
    end
    if isChild == true then --如果是子节点，需要调整相对父节点的坐标
        local parent = tolua.cast(sprite:getParent(), "CCSprite")
        if parent then
            if flip.x == true then
                sprite:setPositionX(parent:getContentSize().width - sprite:getPositionX())
            end
            if flip.y == true then
                sprite:setPositionX(parent:getContentSize().height - sprite:getPositionY())
            end
        end
    end
    --取出子节点递归进行翻转操作
    local childArray = sprite:getChildren()
    if childArray and tolua.cast(childArray, "CCArray") then
        local childCount = childArray:count()
        for k = 0, childCount - 1 do
            local obj = tolua.cast(childArray:objectAtIndex(k), "CCSprite")
            if obj then
                G_setSpriteFlip(obj, flip, true)
            end
        end
    end
end

--对精灵做颜色变化动作
function G_playSpriteTint(sprite, duration, color3b, isAnim, playSelf)
    if playSelf == true and tolua.cast(sprite, "CCSprite") then
        if isAnim == true then
            local tintTo = CCTintTo:create(duration, color3b.r, color3b.g, color3b.b)
            sprite:runAction(tintTo)
        else
            sprite:setColor(ccc3(color3b.r, color3b.g, color3b.b))
        end
    end
    local childArray = sprite:getChildren()
    if childArray and tolua.cast(childArray, "CCArray") then
        local childCount = childArray:count()
        for k = 0, childCount - 1 do
            local obj = tolua.cast(childArray:objectAtIndex(k), "CCSprite")
            if obj then
                G_playSpriteTint(obj, duration, color3b, isAnim, true)
            end
        end
    end
end

function G_getDeviceid()
    if base.deviceID ~= nil and base.deviceID ~="" then
        return base.deviceID
    end
    local tmpTb = {}
    tmpTb["action"] = "getDeviceID"
    tmpTb["parms"] = {}
    local cjson = G_Json.encode(tmpTb)
    local deviceid = G_accessCPlusFunction(cjson)
    if G_isIOS() == true then
        if deviceid == nil or deviceid == "" then
            deviceid = deviceHelper:getUserName()
            if deviceid == "" then
                deviceid = deviceHelper:guid()
                deviceid = "IOS_"..deviceid
                deviceHelper:setUserName(deviceid..",") --存入机器
            else
                deviceid = Split(deviceid, ",")[1]
            end
        else
            deviceid = "IOS_"..deviceid
        end
        
    else
        deviceid = "AND_"..deviceid
    end
    base.deviceID = deviceid
    return deviceid
end
