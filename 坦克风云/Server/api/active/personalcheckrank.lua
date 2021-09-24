function api_active_personalcheckrank(request)

    local response = {
        ret=-1,
        data={},
        msg="error",
    }

    local uid =request.uid

    if uid==nil then
        response.ret=-102
        return response
    end


    local uobjs = getUserObjs(uid,true)
      uobjs.load({"useractive","userinfo"})

      --setChallengeRanking(1013309,123)
    --setChallengeRanking(1013042,126)
     local mUseractive = uobjs.getModel('useractive')

     local list=mUseractive.getpersonalCheckPoint()

    local userinfo = uobjs.getModel('userinfo')
    local challenge = uobjs.getModel('challenge')   
    
    --ptb:p(mUseractive)
    --ptb:e(list)
    local ranklist = {}
    local myrank = 0
    for k,v in pairs(list) do
        --print(v.uid,k,v);    
        local userid = tonumber(v.uid)
        --print(userid)
        if userid>0  and userid~=nil then
            local uobjs = getUserObjs(userid,true)
            local Muserinfo = uobjs.getModel('userinfo')
            local uitem = {}

            
            table.insert(uitem,Muserinfo.nickname)
            table.insert(uitem,Muserinfo.level)
            table.insert(uitem,v.rank)
            table.insert(uitem,v.score)
            table.insert(uitem,Muserinfo.uid)
            table.insert(ranklist,uitem)
            if userid==uid then
                myrank=v.rank
            end
        end        
    end


   -- setChallengeRanking(uid,75)

    local item = {}
    
    --ptb:p(mUseractive.info.personalCheckPoint.t)
    table.insert(item,userinfo.nickname)
    table.insert(item,userinfo.level)
    table.insert(item,myrank)
    table.insert(item,mUseractive.info.personalCheckPoint.t)
    table.insert(item,userinfo.uid)
    response.myranking = item
    --response.data.ranking = list
    response.ret=0
    response.ranklist=ranklist 
    response.msg = 'Success'
    return response 
end