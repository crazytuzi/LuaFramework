-- 战斗逻辑
function api_userwar_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
        over={},
    }
    

    
    local battleDebug = true
    local userwarlogLib = require "lib.userwarlog"
    ---------------------------------------------------------------------
    -- init
    local ts = os.time()
    --writeLog(ts,'userwarbattlelist')
    local userWarCfg=getConfig("userWarCfg")
    local userwarnew = require "model.userwarnew"
    local bid = userwarnew.getWarId()
    local round =userwarnew.getRound(bid)
    local db = getDbo()
    local redis = getRedis()
    local key="z"..getZoneId()..".userwar.userwar"..round
    db.conn:setautocommit(false)

    if round>userWarCfg.roundMax then
          --userwarnew.push(bid,round,warning)
          response.round = round
          response.ret = 0
          response.msg = 'Success'
          response.data.over=1
          return response
    end
    
    --writeLog('------------------------ '..round..' st ------------------------','getCacheObj')

    -- 先处理爆炸 并算出下一回合的预警信息 保存用作给每个人的推送数据
    -- 防止同一回合调用多次导致结果出问题
    if redis:incr(key) > 1 then
        redis:expire(key,120)
        response.msg = round..'is battle over not again'
        response.data.round = round
        response.ret = -102
        return response
    end
    redis:expire(key,120)
    local warning = userwarnew.boom(bid,round)
    userwarnew.noSelect(bid,round)
    
    -- 设置状态算回合数
    local function setStatus(data,round)
        data.status=tonumber(data.status)+1
        data.energy=userWarCfg.energyMax
        data.troops={}
        -- 亡者
        if data.status==1 then
            data.round1=round-1
            if data.round1>0 then
              data.point1=tonumber(data.point1)+data.round1*userWarCfg.survivalPoint
              data.point=data.point+data.round1*userWarCfg.survivalPoint
              data.addpoint(data.round1*userWarCfg.survivalPoint,2,tonumber(data.round1))
            end
            userwarnew.sendTheLastOfUsReward(bid,data.uid,round-1)
            userwarnew.addAllSurvivalNum(bid,-1)
        else --死亡
            data.round2=round-tonumber(data.round1)
            userwarnew.usergameover(bid,data.uid,round)
            data.binfo={}
        end
        
        return data
    end
    -- 开始处理地块逻辑
    local map = userwarnew.getMap(bid)
    --writeLog('battle st:'..os.time(),'lua_pross')
    for y_index,y_value in pairs(map) do
        for x_index,x_value in pairs(y_value) do
            -- 2已爆炸的地块不处理
            if x_value[1] and tonumber(x_value[1]) ~= 2 then
                -- 取地块上的战斗列表
                local lid = x_index..'-'..y_index
                local attlist=userwarnew.getbattlelist(bid,lid,round)
                --writeLog('api_userwar_battle'..round..lid..'LIST'..json.encode(attlist),'userwarbattlelist')
                local rcount=0
                local count=0
                if #attlist>1 then
                    count=math.floor(#attlist/2)*2
                    for i=1,count,2 do
                        local zuid= attlist[i] 
                        local uid = attlist[i+1] 
                        local zobjs = getCacheObjs(zuid,1,'battle')
                        local zuserdata = zobjs.getModel('userwar')
                        local uobjs = getCacheObjs(uid,1,'battle')
                        local userdata = uobjs.getModel('userwar')
                        rcount=i+2
                        -- 同时存在
                        if zuserdata and userdata and  zuid~=uid then
                          local zstatus=tonumber(zuserdata.status)
                          local status=tonumber(userdata.status)
                          -- 都是亡者是不能攻打的
                          if (status==zstatus and status==1) or zstatus>1  then
                            rcount=rcount-2
                            break
                          end
                          local delbuff=nil
                          if zstatus==1 then
                              delbuff=userWarCfg.delbuff
                          end

                          local ztroops=zuserdata.info.troops
                          if type(zuserdata.troops)=='table' and next(zuserdata.troops) then
                              ztroops=zuserdata.troops
                          end
                          local troops=userdata.info.troops
                          if type(userdata.troops)=='table' and next(userdata.troops) then
                              troops=userdata.troops
                          end
                          local report,aSurviveTroops,dSurviveTroops,battleAttSeq,seqPoint,aDieTroops,dDieTroops=userwarnew.battlePlayer(zuserdata.binfo,userdata.binfo,ztroops,troops,delbuff,zuserdata.buff,userdata.buff,zuserdata.level,userdata.level,zuserdata.name,userdata.name,zstatus)
                          local zpoint=0
                          local mpoint=0
                          local zsubtype=4
                          local msubtype=4
                          local zenergy=0
                          local uenergy=0
                          if  next(dSurviveTroops) and  next(aSurviveTroops) then
                                zpoint=0
                                mpoint=0
                                msubtype=2
                                zsubtype=2
                                report.w=0
                                userdata.troops=dSurviveTroops
                                zuserdata.troops=aSurviveTroops
                          end
                          -- 不是平局要加谁胜利的积分
                          if report.w~=0 then
                            if report.w==1 then
                              zsubtype=1
                              -- 如果是亡者返回n%的兵
                              if zstatus==1 then
                                  for k,v in pairs (aSurviveTroops) do
                                      if type(v)=='table' and next(v) then
                                          aSurviveTroops[k]={v[1],v[2]+math.floor((zuserdata.info.troops[k][2]-v[2])*userWarCfg.delbuff.win)}
                                      else
                                        if type(zuserdata.info.troops[k])=='table' and next(zuserdata.info.troops[k]) then
                                          aSurviveTroops[k]={zuserdata.info.troops[k][1],math.floor(zuserdata.info.troops[k][2]*userWarCfg.delbuff.win)}
                                        end
                                      end
                                  end
                                  --加积分和行动力
                                  zpoint=userWarCfg.point[1]
                                  
                              else     
                                  zpoint=userWarCfg.point[2]
                              end
                              zenergy=userWarCfg.energy
                              zuserdata.energy=tonumber(zuserdata.energy)+zenergy
                              if zuserdata.energy>userWarCfg.energyMax then
                                zuserdata.energy=userWarCfg.energyMax
                              end

                              zuserdata.troops=aSurviveTroops
                              setStatus(userdata,round)
                              userwarnew.setSurvivalNum(bid,lid,-1)
                              userwarnew.setZombieNum(bid,lid,1)
                            else
                              -- 对方是生者要加行动力
                              if zstatus~=1 then
                                  uenergy=userWarCfg.energy
                                  userdata.energy=tonumber(userdata.energy)+uenergy
                                  if userdata.energy>userWarCfg.energyMax then
                                    userdata.energy=userWarCfg.energyMax
                                  end
                                  userwarnew.setSurvivalNum(bid,lid,-1)
                                  userwarnew.setZombieNum(bid,lid,1)
                              end
                              mpoint=userWarCfg.point[2]
                              msubtype=1
                              userdata.troops=dSurviveTroops
                              setStatus(zuserdata,round)
                              if  tonumber(zuserdata.status)>=2  then
                                userwarnew.setZombieNum(bid,lid,-1)
                              end

                            end
                          else
                           report.w=-1  
                          end
                                       

                          --插入事件加上积分
                          if zpoint>0 then
                              if zstatus==1 then
                                  zuserdata.point2=tonumber(zuserdata.point2)+zpoint
                              else
                                  zuserdata.point1=tonumber(zuserdata.point1)+zpoint
                              end
                              
                              zuserdata.addpoint(zpoint,3,tonumber(round))
                              zuserdata.point=tonumber(zuserdata.point)+zpoint
                          end
                          if mpoint>0 then 
                            
                            userdata.addpoint(mpoint,3,tonumber(round))
                            userdata.point1=tonumber(userdata.point1)+mpoint
                            userdata.point=tonumber(userdata.point)+mpoint
                          end
    
                          local logenergy=0
                          if tonumber(userdata.energy)<=0 then
                              logenergy=1
                              setStatus(userdata,round)
                          end
                          local zlogenergy=0
                          if tonumber(zuserdata.energy)<=0 then
                              zlogenergy=1
                              setStatus(zuserdata,round)
                          end
                         
                         
                          --userwarnew.setUserDataToCache(bid,zuserdata)
                          userwarlogLib:setEvent(zuid,bid,3,zuserdata.status,2,0,zpoint,zsubtype,0,{userdata.name,zlogenergy,zenergy,zstatus},round,report)
                          

          
                          --userwarnew.setUserDataToCache(bid,userdata)
                          userwarlogLib:setEvent(uid,bid,3,userdata.status,2,0,mpoint,msubtype,0,{zuserdata.name,logenergy,uenergy,status},round,report)
                          zobjs.save()
                          uobjs.save()
                          

                        end
                    end
                    -- 未匹配到的插个事件
                    if rcount < #attlist then
                      for i=rcount,#attlist do
                          local uobjs = getCacheObjs(attlist[i],1,'battle')
                          local userdata = uobjs.getModel('userwar')
                          if tonumber(userdata.status)<2 then
                            local zlogenergy=0
                            local oldstatus =userdata.status
                            if tonumber(userdata.energy)<=0 then
                                zlogenergy=1
                                setStatus(userdata,round)
                                uobjs.save()
                            end
                            userwarlogLib:setEvent(attlist[i],bid,3,userdata.status,2,0,0,3,0,{"",zlogenergy,0,oldstatus},round,nil)
                          end
                      end
                    end
                else
                    if next(attlist) then
                      for i=1,#attlist do
                          local uobjs = getCacheObjs(attlist[i],1,'battle')
                          local userdata = uobjs.getModel('userwar')
                          if tonumber(userdata.status)<2 then
                            local zlogenergy=0
                            local oldstatus=userdata.status
                            if tonumber(userdata.energy)<=0 then
                                zlogenergy=1
                                setStatus(userdata,round)
                                uobjs.save()
                            end
                            userwarlogLib:setEvent(attlist[i],bid,3,userdata.status,2,0,0,3,0,{"",zlogenergy,0,oldstatus},round,nil)
                          end
                      end
                    end 
                end
            end
        end
    end
    --writeLog('battle et:'..os.time(),'lua_pross')


    if tonumber(round) >=tonumber(userWarCfg.roundMax) then
        userwarnew.gameover(bid)
    end
    
    userwarnew.push(bid,round,warning)
    userwarlogLib:Commint(round,"battle")
    db.conn:commit() 
    
    --writeLog('------------------------ '..round..' et ------------------------','getCacheObj')
    response.round = round
    response.ret = 0
    response.msg = 'Success'
    return response
end

