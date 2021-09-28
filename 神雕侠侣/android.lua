LuaAndroid={}

LuaAndroid.serverid = 0

------------------------------------------------------------
-- 这个是腾讯的支付
------------------------------------------------------------
function LuaAndroid.startBuy(goodid, goodnum)
	local luaj = require "luaj"
	local ret, openid, openkey, pay_token, pf, pfkey
	ret, openid    = luaj.callStaticMethod("com.tencent.tmgp.sdxl.PlatformTencent", "getopenid", nil, "()Ljava/lang/String;")
	ret, openkey   = luaj.callStaticMethod("com.tencent.tmgp.sdxl.PlatformTencent", "getopenkey", nil, "()Ljava/lang/String;")
	ret, pay_token = luaj.callStaticMethod("com.tencent.tmgp.sdxl.PlatformTencent", "getpay_token", nil, "()Ljava/lang/String;")
	ret, pf        = luaj.callStaticMethod("com.tencent.tmgp.sdxl.PlatformTencent", "getpf", nil, "()Ljava/lang/String;")
	ret, pfkey     = luaj.callStaticMethod("com.tencent.tmgp.sdxl.PlatformTencent", "getpfkey", nil, "()Ljava/lang/String;")
	LogErr("openid -----> " .. openid)
	LogErr("openkey ----> " .. openkey)
	LogErr("pay_token --> " .. pay_token)
	LogErr("pf ---------> " .. pf)
	LogErr("pfkey ------> " .. pfkey)
	local value = openid .. "#" .. openkey .. "#" .. pay_token .. "#" .. pf .. "#" .. pfkey
	LogErr("value = " .. value)

	local CConfirmCharge = require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"
	local req = CConfirmCharge.Create()
	req.goodid = goodid
	req.goodnum = goodnum
	req.extra = value
	LuaProtocolManager.getInstance():send(req)
end
------------------------------------------------------------
------------------------------------------------------------

------------------------------------------------------------
-- 这里是Efun联运App01的支付，使用网页充值
------------------------------------------------------------
function LuaAndroid.TwApp01buy()
	-- 使用json向传入需要的信息
    local json = '{'
    .. '"roleId":"'
    .. tostring(GetDataManager():GetMainCharacterID())
    .. '",'
    .. '"roleName":"'
    .. GetDataManager():GetMainCharacterName()
    .. '",'
    .. '"roleGrade":"'
    .. tostring(GetDataManager():GetMainCharacterLevel())
    .. '",'
    .. '"serverid":"'
    .. tostring(LuaAndroid.serverid)
    .. '"}'

    -- 调用Java中的SDK充值接口
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
        local lauj = require "luaj"
        luaj.callStaticMethod("com.efun.ensd.ucube.PlatformTwApp01", "purchase2", {json}, nil)
        return
    end


end
------------------------------------------------------------
------------------------------------------------------------


------------------------------------------------------------
-- 这里是Efun联运360的支付，使用网页充值
------------------------------------------------------------
function LuaAndroid.Tw360buy()
	-- 使用json向传入需要的信息
    local json = '{'
    .. '"roleId":"'
    .. tostring(GetDataManager():GetMainCharacterID())
    .. '",'
    .. '"roleName":"'
    .. GetDataManager():GetMainCharacterName()
    .. '",'
    .. '"roleGrade":"'
    .. tostring(GetDataManager():GetMainCharacterLevel())
    .. '",'
    .. '"serverid":"'
    .. tostring(LuaAndroid.serverid)
    .. '"}'

    -- 调用Java中的SDK充值接口
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "tw36" then
        local lauj = require "luaj"
        luaj.callStaticMethod("com.wanmei.mini.condor.tw360.PlatformTw360", "purchase2", {json}, nil)
        return
    end


end
------------------------------------------------------------

return LuaAndroid
