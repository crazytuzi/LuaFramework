-- 获取世界大战的信息

function api_admin_getworldwarinfo(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local db = getDbo()
    
    local result = db:getRow("select * from  serverbattlecfg  where  type=3 order by et  desc limit 1 ")
    if not result then
        return response
    end
    local bid="b"..result.bid
    local data = db:getAllRows("select uid,info,pointlog from  wcrossinfo where  info like '%"..bid.."%'  and pointlog like '%tank%' ")
    if data then
        response.data.user={}
        for k,v in pairs (data) do
            local pointlog=json.decode(v.pointlog)
            local info=json.decode(v.info)
            local point=info.point or 0
            local troops={}
            if pointlog['del'] and pointlog['del'][bid] and  pointlog['del'][bid]['tank'] then
                for pk,pv in pairs(pointlog['del'][bid]['tank'] or {}) do
                    for ak , av in pairs(pv.d or {}) do
                        troops[ak]= (troops[ak] or 0)+(av[1]-av[2])
                    end
                end
            end
            if next(troops) then
                          -- uid  部队消耗  获得的总积分，参加的大赛  =0无记录，等级 ，vip，军团名字，玩家名字 
                local tmp={v.uid,troops,point,info.join or 0,}
                local userinfo = db:getRow("select level,vip,nickname,alliancename from  userinfo  where uid=:uid ",{uid=v.uid})
                if userinfo then
                    table.insert(tmp,userinfo.level)
                    table.insert(tmp,userinfo.vip)
                    table.insert(tmp,userinfo.alliancename)
                    table.insert(tmp,userinfo.nickname)
                end
                table.insert(response.data.user,tmp)
            end
        end
        response.data.bid=bid
    end     
    
    return response
end