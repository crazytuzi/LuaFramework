

---@classdef record_packages_config
local record_packages_config = {}
  
record_packages_config.package_name = "" --备注  
record_packages_config.memo = "" --包名  
record_packages_config.weixin_appkey = "" --weixin_appkey


packages_config = {
   _data = {
    [1] = {"com.youzu.android.snsgz","游族安卓","wx4b10053f9c141da9",},
    [2] = {"com.youzu.snsgz.qihoo360","360","wxc44866a2abc542a3",},
    [3] = {"com.youzu.snsgz.uc","uc","wxf3c68a51f7d68770",},
    [4] = {"com.youzu.snsgz.mi","小米","wx24479e4a57c5ea37",},
    [5] = {"com.youzu.snsgz.baidu.ad","百度","wxe7a6f11536aa8793",},
    [6] = {"com.snsgz.apk.nearme.gamecenter","oppo","wx3f1a79526e88e32e",},
    [7] = {"com.youzu.sanguohero.youzu.qa","游族安卓测试包","wxec3e866020c9722c",},
    [8] = {"com.youzu.snsgz.25PP","IOS pp助手","wx7902bdd1d98d3a89",},
    [9] = {"com.chiyou.snsgz.i4","爱思IOS","wx7692d005a88eb974",},
    [10] = {"com.youzu.snsgz.baidu","百度IOS","wxbd36daf56a4c5b3c",},
    [11] = {"com.youzu.snsgz.xy","xy助手","wx260841ef1a827c2d",},
    [12] = {"com.fwfw.shaoniansanguozhi.10001","爱苹果","wx798345a1c7d91a53",},
    [13] = {"com.youzu.snsgz.sky","itools","wx4f388d39e9fe21f0",},
    [14] = {"com.youzu.snsgz.ky","快用","wx4c81682d50d4db75",},
    [15] = {"com.tongbu.snsgz","同步推","wxe94a7cac44d75876",},
    [16] = {"com.uuzu.snsgz","苹果APPSTORE","wx0e59bcecab2c0f66",},
    [17] = {"com.snsgz.hm","海马","wx34d20257f6c5c9e3",},
    [18] = {"com.youzu.sanguohero.testp12","游族越狱","wx4736653042cb07e2",},
    [19] = {"com.youzu.sanguohero.qa","游族IOS测试包","wx885601e2d47d9b9e",},
    [20] = {"com.youzu.snsgz.vivo","VIVO","wx22e9f359d37bf872",},
    [21] = {"com.youzu.snsgz.lenovo","联想","wxd94180762e048dc1",},
    [22] = {"com.youzu.snsgz.anzhi","安智","wx60d5776b9a90deed",},
    [23] = {"com.youzu.snsgz.huawei","华为","wx08897acb3c0c841d",},
    [24] = {"com.youzu.snsgz.wandoujia","豌豆荚","wxe02024c6f119d798",},
    [25] = {"com.youzu.pptv","PPTV","wx378c7cdb758ba845",},
    [26] = {"com.youzu.snsgz.pps","pps","wx087bfd3233daf42f",},
    [27] = {"com.youzu.snsgz.dangle","当乐","wx9915e979e1994e9d",},
    [28] = {"com.youzu.snsgz.sy37","37玩","wx2648d856bae1c59b",},
    [29] = {"com.youzu.snsgz.sj49you","49游","wx3dea364b395f51ec",},
    [30] = {"com.youzu.snsgz.linyou","麟游","wxb5eb06b921ec4527",},
    [31] = {"com.youzu.snsgz.am","金立","wxf280b6efdc2b0d8a",},
    [32] = {"com.youzu.snsgz.coolpad","酷派","wxfe999c705f5da0bf",},
    [33] = {"com.youzu.snsgz.youku","优酷","wxaf4e853fbd55a9d5",},
    }
}



local __index_package_name = {
    ["com.chiyou.snsgz.i4"] = 9,
    ["com.fwfw.shaoniansanguozhi.10001"] = 12,
    ["com.snsgz.apk.nearme.gamecenter"] = 6,
    ["com.snsgz.hm"] = 17,
    ["com.tongbu.snsgz"] = 15,
    ["com.uuzu.snsgz"] = 16,
    ["com.youzu.android.snsgz"] = 1,
    ["com.youzu.pptv"] = 25,
    ["com.youzu.sanguohero.qa"] = 19,
    ["com.youzu.sanguohero.testp12"] = 18,
    ["com.youzu.sanguohero.youzu.qa"] = 7,
    ["com.youzu.snsgz.25PP"] = 8,
    ["com.youzu.snsgz.am"] = 31,
    ["com.youzu.snsgz.anzhi"] = 22,
    ["com.youzu.snsgz.baidu"] = 10,
    ["com.youzu.snsgz.baidu.ad"] = 5,
    ["com.youzu.snsgz.coolpad"] = 32,
    ["com.youzu.snsgz.dangle"] = 27,
    ["com.youzu.snsgz.huawei"] = 23,
    ["com.youzu.snsgz.ky"] = 14,
    ["com.youzu.snsgz.lenovo"] = 21,
    ["com.youzu.snsgz.linyou"] = 30,
    ["com.youzu.snsgz.mi"] = 4,
    ["com.youzu.snsgz.pps"] = 26,
    ["com.youzu.snsgz.qihoo360"] = 2,
    ["com.youzu.snsgz.sj49you"] = 29,
    ["com.youzu.snsgz.sky"] = 13,
    ["com.youzu.snsgz.sy37"] = 28,
    ["com.youzu.snsgz.uc"] = 3,
    ["com.youzu.snsgz.vivo"] = 20,
    ["com.youzu.snsgz.wandoujia"] = 24,
    ["com.youzu.snsgz.xy"] = 11,
    ["com.youzu.snsgz.youku"] = 33,

}

local __key_map = {
  package_name = 1,
  memo = 2,
  weixin_appkey = 3,

}



local m = { 
    __index = function(t, k) 
        assert(__key_map[k], "cannot find " .. k .. " in record_packages_config")
        
        
        return t._raw[__key_map[k]]
    end
}


function packages_config.getLength()
    return #packages_config._data
end



function packages_config.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_packages_config
function packages_config.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = packages_config._data[index]}, m)
    
end

---
--@return @class record_packages_config
function packages_config.get(package_name)
    
    return packages_config.indexOf(__index_package_name[package_name])
        
end



function packages_config.set(package_name, key, value)
    local record = packages_config.get(package_name)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end