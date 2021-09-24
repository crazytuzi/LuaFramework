-- 战报列表

function api_areawar_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid=tonumber(request.uid)
    local battlelogLib=require "lib.battlelog"
    local id = request.params.id or 0
    local aid = request.params.aid or 0
    local method = request.params.type or 1
    local list =battlelogLib:areaLogGetList(uid,id,method,aid)
    --data={{attuid=1000103,defuid=1000101,btype='a1',attname="test1",defname="test11",attaid=1164,defaid=0,attaname="Nnmmbb",defaname="test1",win=1,occupy=1,report='{"aey":[[26940,[0,0,0,21]],[0,{}]],"lostShip":{"attacker":{"a10044":0},"defenser":true},"report":{"w":1,"t":[[["a10014",200],["a10023",200],["a10004",200],["a10023",200],["a10014",200],["a10014",200]],[["a10044",915],["a10044",915],["a10044",915],["a10044",915],["a10044",915],["a10044",915]]],"h":[{},["h39-1-2","h27-1-1","h29-1-1","h31-1-1"]],"p":[["elite_challenge_name_1",15,0,1000],["yoyo",69,1,1010]],"d":[["2465936-0","4931872-0-1"],["0","0"],["2383725-0","2804382-0"],["0","0","0"],["2797721-0","2797721-0"]]},"hh":0}'}}
    --local ret=battlelogLib:areaLogSend(data)
    --ptb:e(ret)
    if list then
        local data={}
        for k,v  in pairs(list) do
            --ptb:e(v)  --id    建筑类型  攻击方     防守方      攻击军团名字   防守军团名字  胜利   占领    时间
            local tmp={v.id,v.btype,v.attname,v.defname,v.attaname,v.defaname,v.win,v.occupy,v.updated_at}
            table.insert( data, tmp )
        end
        response.data.areawarlog = data
    end
    response.ret = 0
    response.msg = 'Success'

    return response
end