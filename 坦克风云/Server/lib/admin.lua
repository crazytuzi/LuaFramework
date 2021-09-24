--获取用户信息
function getMemberInfo(uid)
    local uobjs     		= getUserObjs(uid)
    local mUserinfo 		= uobjs.getModel('userinfo')

    local result = mUserinfo.toArray(true)

    result["zoneId"]         = getZoneId() -- 区服
    
    if next(mUserinfo.mc) and mUserinfo.mc[1] > getClientTs() then
        result["isBuyCard"] = "yes"  --是否购买月卡
        result["monthCardEt"] = mUserinfo.mc[1]
    else
        result["isBuyCard"]      = "no"
        result["monthCardEt"] = 0
    end
    
	return result
end

--修改用户昵称
function update_nickname_by_id(id,name)
    local db = getDbo()
    local data = db:getAllRows("select id from userinfo where nickname = :name and uid != :id",{name = name,id = id})
    if not data then
        return {}
    end
    return data
end

--根据用户名称查找uid
function get_id_by_name(name)
    local db = getDbo()
    local data = db:getAllRows("select uid from userinfo where nickname = '"..name.."'")
    if not data then
        data = db:getAllRows("select uid from userinfo where nickname like '%"..name.."%'")
    end
    if not data then
        return {}
    end
    return data
end

--根据用户id查找消费信息
function getpaynum_by_id(id)
    local db = getDbo()
    local data = db:getAllRows("select count(*) as pay_num,sum(cost) as pay_total from tradelog where userid = :id and cost>0",{id = id})
    if not data then
        return {}
    end
    return data
end

--本服所有用户的消费情况
function getuserpay_acc()
    local db = getDbo()
    local data = db:getAllRows("select userid,count(*) as pay_num,sum(cost) as pay_total from tradelog where cost>0 group by userid")
    if not data then
        return {}
    end
    return data
end


    

