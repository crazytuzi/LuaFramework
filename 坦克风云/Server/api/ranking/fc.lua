function api_ranking_fc(request)
    local response = {}
    response.data={}
    
    local page = tonumber(request.params.page) or 1
    if page < 1 then page = 1 end
    if page > 5 then page = 5 end
    
    if page == 1 then
        local item = {}
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local userinfo = uobjs.getModel('userinfo')

        table.insert(item,userinfo.uid)
        table.insert(item,userinfo.nickname)
        table.insert(item,userinfo.level)
        table.insert(item,getMyFcRanking(uid))
        table.insert(item,userinfo.fc)
        table.insert(item,userinfo.pic)

        response.data.myranking = item
    end
    
    local list = {}
    for k,v in pairs(getFcRanking(page)) do
        local uid = tonumber(v.uid)
        if uid>0 then
            local uobjs = getUserObjs(uid,true)
            local userinfo = uobjs.getModel('userinfo')
            local item = {}

            table.insert(item,userinfo.uid)
            table.insert(item,userinfo.nickname)
            table.insert(item,userinfo.level)
            table.insert(item,v.rank)
            table.insert(item,v.score)
            table.insert(item,userinfo.pic)
            table.insert(item,userinfo.rank)
            
            table.insert(list,item)
        end        
    end
    response.data.ranking = list
    response.ret = 0	    
    response.msg = 'Success'
    
    return response
end
