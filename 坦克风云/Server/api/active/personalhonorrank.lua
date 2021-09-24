function api_active_personalhonorrank(request)
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


     local mUseractive = uobjs.getModel('useractive')

     --setHonorsRanking(uid,100)
     local userinfo = uobjs.getModel('userinfo')
     
   
     local list =mUseractive.getpersonalHonor()


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

            --table.insert(uitem,Muserinfo.uid)
            table.insert(uitem,Muserinfo.nickname)
            table.insert(uitem,Muserinfo.level)
            table.insert(uitem,v.rank)
            table.insert(uitem,v.score)
            
            table.insert(ranklist,uitem)
            if userid==uid then
                myrank=v.rank
            end
        end        
    end

    local item = {}
    --table.insert(item,userinfo.uid)
    table.insert(item,userinfo.nickname)
    table.insert(item,userinfo.level)
    table.insert(item,myrank)
    table.insert(item,mUseractive.info.personalHonor.t)
    response.myranking = item
    response.ret=0
    response.ranklist=ranklist 
    response.msg = 'Success'
    return response 

end