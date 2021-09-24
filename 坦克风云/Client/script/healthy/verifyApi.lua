require "luascript/script/healthy/healthyApi"
--实名认证
verifyApi = {
    name = nil, --玩家真实姓名
    idCard = nil, --真实身份信息
    token = nil, --access_token返回的相关信息，作为后端实名认证校验用
}

--认证功能是否开启，国内判断开关，国外不开
function verifyApi:isOpen()
    if base.vfy == 1 then
        return true
    end
    return false
end

--是否实名认证
function verifyApi:isVerified()
    --后端返回玩家认证信息即可认为已认证
    if self.name and self.name ~= "" and self.idCard and self.idCard ~= "" then
        return true
    end
    return false
end

--设置实名后的信息
function verifyApi:setVerifiedInfo(name, idCard)
    self.name, self.idCard = name, idCard
end

--获取实名认证信息
function verifyApi:getVerifiedInfo()
    return self.name, self.idCard
end

--是否成年
--return true：已成年，false 未成年 0：已满18岁，1：16-18岁，2：8-16岁，3：未满8周岁
function verifyApi:isAdult()
    --实名认证功能没有开默认已成年
    if self:isOpen() == false then
        return true, 0
    end
    --没有实名的话按未满8岁处理
    if self:isVerified() == false then
        return false, 3
    end
    local dt = G_getDate(base.serverTime)
    local date = tonumber(dt.year..string.format("%02d", dt.month)..string.format("%02d", dt.day))
    local birthday = tonumber(string.sub(self.idCard, 7, 14)) --取出出生日期
    local playerAge = date - birthday
    if playerAge >= 180000 then --已满18岁
        return true, 0
    elseif playerAge >= 160000 then --已满16岁
        return false, 1
    elseif playerAge >= 80000 then --已满8岁
        return false, 2
    end
    return false, 3 --未满8岁
end

--实名认证接口
function verifyApi:userVerify(name, idCard, callback)
    --认证所需信息不全时直接返回
    if self.token == nil or next(self.token) == nil then
        do return end
    end
    local realName = HttpRequestHelper:URLEncode(name)
    local verifyUrl = serverCfg.baseUrl.."realcertification.php"
    local params = "username="..self.token.username.."&uid="..self.token.uid.."&loginTs="..self.token.loginTs.."&token="..self.token.access_token.."&id="..idCard.."&name="..realName.."&zoneid="..base.curZoneID
    
    local function verifyCallback(data)
        if data and data ~= "" then
            sData = G_Json.decode(data)
            if sData.ret == 0 and sData.data then
                self.name = sData.data.name
                self.idCard = sData.data.id
                G_showTipsDialog("已认证成功！")
                if callback then callback() end
                self.showed = nil
            else
                G_showTipsDialog("认证信息有误！")
            end
        end
        base:cancleNetWait()
    end
    G_sendHttpAsynRequest(verifyUrl, params, verifyCallback, 2)
    base:setNetWait()
end

--getaccess_token 返回的数据记录，用于实名时后台校验
function verifyApi:setToken(loginTs, access_token, uid, uname)
    self.token = {loginTs = loginTs, access_token = access_token, uid = uid, username = uname}
end

--验证姓名合法性
function verifyApi:checkName(name)
    if name == nil or name == "" then
        return false
    end
    local len = G_utfstrlen(name)
    if len < 2 or len > 10 then -- 名字长度2~5位
        return false
    end
    local len2 = string.len(name)
    if (len * 3) ~= len2 then -- 一个汉字占3个字符
        return false
    end
    return true
end

--验证身份证信息合法性
function verifyApi:checkIDCard(idCard)
    if idCard == nil or idCard == "" then
        return false
    end
    local len = string.len(idCard)
    if(len ~= 18)then --号码长度不够
        return false
    end
    local addressCode = string.sub(idCard, 1, 6) --地址码
    if string.find(addressCode, "^[1-9]%d%d%d%d%d") == nil then --地址码长6位，以数字1-9开头，后5位为0-9的数字
        return false
    end
    local yearCode = string.sub(idCard, 7, 10) --年份
    if string.find(yearCode, "19%d%d") == nil and string.find(yearCode, "20%d%d") == nil then --年份长4位，以数字19或20开头，剩余两位为0-9的数字
        return false
    end
    local monthCode = string.sub(idCard, 11, 12) --月份
    if string.find(monthCode, "(0[1-9])") == nil and string.find(monthCode, "(1[0-2])") == nil then --月份长2位，第一位数字为0，第二位数字为1-9，或者第一位数字为1，第二位数字为0-2
        return false
    end
    local day = tonumber(string.sub(idCard, 13, 14)) --日期
    if day == nil then --日期码2位数字
        return false
    end
    local month = tonumber(monthCode)
    if month == 2 then --2月份,判断是28天还是29天
        local year = tonumber(yearCode)
        if ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0) and day > 29 then --闰年，日期不能超过29
            return false
        elseif day > 28 then --不是闰年日期不能超过28
            return false
        end
    else
        local m = {[1] = 31, [3] = 31, [5] = 31, [7] = 31, [8] = 31, [10] = 31, [12] = 31}
        if m[month] then
            if day > m[month] then
                return false
            end
        elseif day > 30 then
            return false
        end
    end
    local indexCode = string.sub(idCard, 15, 17) --顺序码
    if string.find(indexCode, "%d%d%d") == nil then --顺序码长3位 全为数字
        return false
    end
    local checkCode = string.sub(idCard, 18) --校验码
    if string.find(checkCode, "[0-9Xx]") == nil then --校验码长1位，可以是数字，字母x或字母X
        return false
    end
    return true
end

--弹出实名认证面板
function verifyApi:checkVerifyShow()
    --游客不用实名认证
    if healthyApi:isUserGuest() == true then
        do return end
    end
    if self:isOpen() == false or self:isVerified() == true or self.showed == true then
        do return end
    end
    if F_stayMainUI() == false then --实名认证面板在游戏主基地页面展示
        do return end
    end
    require "luascript/script/game/scene/gamedialog/realnameSmallDialog"
    local sd = realnameSmallDialog:new()
    sd:init(4)
    self.showed = true
end

function verifyApi:clear()
    self.name = nil
    self.idCard = nil
    self.token = nil
    self.showed = nil
    self.pop = nil
end
