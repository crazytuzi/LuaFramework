-- 配件改造
function  api_accessory_refineaccessory(request)
    local response = {
          ret=-1,
          msg='error',
          data = {},
    }


    local uid = request.uid

    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    local use =math.abs(tonumber(request.params.use) or 0)
    local aid =request.params.aid
      --use=2

    if uid == nil  then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('ec') == 0 then
          response.ret = -9000
          return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')

    local mUseractive = uobjs.getModel('useractive')
    local acname = "accessoryEvolution"

    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测存在不用使用保级符
    if activStatus == 1 then
        use =0
    end
    local access={}
    if aid~=nil then
        local accessid,info=mAccessory.getAccessoryId(aid)
        access=info
    else
        info=mAccessory.getUsedAccessory(t,p)
        access=info
    end
    
    if  not next(access) then
      response.ret = -9005
      return response
    end
    -- access 1配件id   2  强化等级  3精炼等级

    local accessid = access[1]
    local qlevel   = access[2]
    local level    = access[3]
    local succ     = access[4]

    local kafkaLog = {
        {desc="配件改造前",value={accessid,qlevel,level}},
    }

    if(level+1>mUserinfo.level)then
      response.ret = -9010
      return response
    end

    local accessconfig = getConfig("accessory.aCfg."..accessid)
    if not next(accessconfig) then
      response.ret =-9002  
      return response
    end

    --配件位置
    local part = tonumber(accessconfig['part'])
    --配件品质
    local quality = accessconfig['quality']

    local smeltMaxRank =getConfig("accessory.smeltMaxRank")
    level=level+1

    if level>(smeltMaxRank[quality] or 0) then
      response.ret = -9021
      return response
    end
    
    --精炼要减掉的等级
    local smeltReduceLv =getConfig("accessory.smeltReduceLv")

    local smeltPropNum='smeltPropNum'
    smeltPropNum=smeltPropNum..quality
    --print(smeltPropNum)
    local resource =  getConfig("accessory."..smeltPropNum)

    if type(resource[level]) ~='table' then
        response.ret =-9011  
        return response
    end


    local flag = false
    local p5 = 0
    for k,v in pairs(resource[level])do 
      local propid = tostring(k)
      local count   = tonumber(v)
      if propid~='p5' then
        local ret=mAccessory.useProp(propid,count)

        if not ret then
          flag=true
        end

      else
        p5=count
      end
    
    end

    if flag  then
      response.ret =-9012  
        return response
    end
  
    if level>0 and use>0 then
      local ret=mAccessory.useProp('p5',p5)
      if not ret then
        response.ret=-9013
        return response
      end

    else
      if activStatus ~= 1 then
        qlevel=qlevel-smeltReduceLv 
        if qlevel<0 then
          qlevel=0
        end
      end
    end
    local ret = false
    response.data.accessory={}
    
    if aid~=nil then
        local rest,info=mAccessory.updateInFoAccessoryLevel(aid,qlevel,level,succ)
          ret=rest
            response.data.accessory.info={}
            response.data.accessory.info[aid]=info

            table.insert(kafkaLog,{desc="后(id,强化,改造)",value={info[1],info[2],info[3]}})
        else
            local rest,info=mAccessory.updateUsedAccessoryLevel(t,p,qlevel,level,succ)
            ret=rest
            response.data.accessory.used={}
            response.data.accessory.used[t]={}
            response.data.accessory.used[t][p]=info

            table.insert(kafkaLog,{desc="后(id,强化,改造)",value={info[1],info[2],info[3]}})
    end
    
    table.insert(kafkaLog,{desc="品质",value=quality})
  
    -- kafkaLog
    regKfkLogs(uid,'accessory',{
            addition=kafkaLog
        }
    ) 

    --local ret,info=mAccessory.updateUsedAccessoryLevel(t,p,qlevel,level)

    if ret then

          -- stats ---------------------------------------
          -- 强化次数
          regStats('accessory_daily',{item= 'refineNum.' .. (accessid or ''),num=1})
          --强化人数
          if getWeeTs() ~= getWeeTs(mAccessory.refine_at) then
              regStats('accessory_daily',{item= 'refineUser.' .. (accessid or ''),num=1})
          end
          -- stats ---------------------------------------

            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave()
            mAccessory.refine_at=getClientTs()
            if uobjs.save() then 
                processEventsAfterSave()
               
                response.data.accessory.props={}
                response.data.accessory.props=mAccessory.props
                response.ret = 0        
                response.msg = 'Success'
                return response
            else

                response.ret = -1
                response.msg = "save failed"
                return response
            end
            else 
                response.ret=-1   
                return response
        end 

    









end
