function api_user_getnewranklist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }   

    local uid = request.uid

    local cuuturt =getWeeTs()+10800

    local ts  = getClientTs()

    if ts< cuuturt then

        cuuturt=cuuturt-24*3600
    end
    local dayrankkey = "z"..getZoneId()..".dayUserNewRank.All.100"..cuuturt

    local redis = getRedis()
    local list=redis:get(dayrankkey)
    list      =json.decode(list)

    local cuuturt =getWeeTs()+10800
    local ranklist={}
    local myranking = nil   --自己的数据
    local myuid = uid
    local rankCfg =getConfig("rankCfg")
    if type(list)=='table' and next(list) then

        for k,v in pairs(list) do
            if k>100 then
                break
            end
            local uid =tonumber(v.uid)
            local uobjs = getUserObjs(uid,true)
            local Muserinfo = uobjs.getModel('userinfo')
            local score = tonumber(v.score)
            -- if Muserinfo.rp > rankCfg.minPoint then
            --     score = rankCfg.minPoint+math.floor((score-rankCfg.minPoint)*math.pow((1-rankCfg.pointDecrease),1))
            -- end
            if myuid == uid then
               myranking = {Muserinfo.nickname, Muserinfo.level, score, Muserinfo.uid, k, Muserinfo.fc, Muserinfo.pic, Muserinfo.rank} 
            end               
            local item = {Muserinfo.nickname,Muserinfo.level, score, Muserinfo.uid, k, Muserinfo.fc, Muserinfo.pic, Muserinfo.rank}
            table.insert(ranklist,item)
        end 
       

    end

    response.ret=0
    response.ranklist=ranklist
    response.myranking=myranking
    response.msg ='Success'
    return response

end