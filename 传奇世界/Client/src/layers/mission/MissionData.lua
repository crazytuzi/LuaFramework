--[[ 任务数据存储  ]]--
DATA_Mission = {}
local MRoleStuct = require("src/layers/role/RoleStruct")
local _data = nil
local upcallbaces = nil         --数据更新回调
local taskParent = nil          --任务基础层
local roletype = nil            --当前角色类型
local isAutoPath = false        --是否自动寻路

DATA_Mission.RewardTaskTypeEnum =
{
    JUINOR_TASK = 1,        -- 普通悬赏
    SENIOR_TASK = 2,        -- 高级悬赏
    EXTREME_TASK = 3,       -- 至尊悬赏

    MY_TASK = 4             -- 我的悬赏
}

local charAt = function(value, position)
    if value and position and position > 0 then
        local b = string.byte(value, position, position + 1)
        return b and string.char(b) or b
    end
end

local parseTaskTarget = function(str, cur_task , _isMonster )
    local targets = {}
    local targetStr = stringsplit(str, ";")
    for key , v in pairs(targetStr) do
        local target = {}
        target.isAutoFight = false

        if charAt(v, 1) == "@" then
            target.isAutoFight = true
            v = string.sub(v, 2, #v)
        end

        local tgStr = stringsplit(v, "_")

        local ids = stringsplit( tgStr[1] , ",") 
        target.ID = tonumber(ids[1])
        target.count = tonumber(tgStr[2])
        target.cur_num = 0
        if cur_task == 1 then
            target.cur_num = 0
        else
            --当前任务之前的任务全部完成
            target.cur_num = target.count
        end

        local isInsert = false
        if _isMonster then
          --怪物数据
            if #tgStr < 2 then
                error( "mission task error -- q_end_need_killmonster = " .. str )
            else
                isInsert = true
                local recode = getConfigItemByKey( "monsterUpdate" , "q_id", tonumber( tgStr[ math.random( 3 , #tgStr ) ] ) )
                target.mapID = recode.q_mapid
                target.pos = { { x = recode.q_center_x , y = recode.q_center_y } }
            end
        else
          --采集物    
          isInsert = true    
          target.mapID = tonumber(tgStr[3])
          target.pos = {}
          local pos_num = (#tgStr - 3)/2

          for j = 1, pos_num do
              target.pos[j] = { x = tgStr[j*2+2], y = tgStr[j*2+3] }
          end
        end

        if isInsert then
            table.insert(targets, target)
        end
    end

    return targets
end

DATA_Mission.__parseTaskTarget = function(v, b , _isMonster ) return parseTaskTarget(v, b , _isMonster )  end

local parseCollectTarget = function(str , isRuning )
-- 任务表字段q_done_event是一个特殊任务的配置字段，没有就配0
-- 字段参数是根据下划线"_"来分隔，比如q_done_event='22_1_20025'，第一个参数表示任务类型，22是使用物品，后面的参数根据具体类型具体定义，
-- 比如1表使用数量，20025表示物品ID，下面根据类型给出具体参数定义：
-- 1   装备强化     强化等级
-- 2   装备传承
-- 5   装备熔炼    次数
-- 6   技能升级     等级
-- 8   光翼进阶    次数
-- 10  每日签到 
-- 11  完成日常任务   次数
-- 13  参加竞技场   次数  是否要赢（填1要求赢）
-- 14  参加副本(完成)    副本类型（1屠龙2通天塔3公主4多人6新屠龙）  次数
-- 15  添加好友    好友数量
-- 16  创建队伍     次数
-- 17  送花  次数
-- 18  击杀世界BOSS    次数
-- 19  完成一次抽奖  次数
-- 20  在商城购买1次元宝道具 次数
-- 21  在商城购买1次礼金道具 次数
-- 22  使用物品     数量 物品ID1   物品ID2 物品ID3 物品ID4(多选)
-- 23  升级  等级
-- 25  日常任务奖励升星    次数
-- 26  领取活跃度奖励     活跃度奖励ID1 活跃度奖励ID2 活跃度奖励ID3(多选)
-- 28  穿戴称号    战士称号ID 法师称号ID 道士称号ID（根据职业自动选）
-- 29  收集某种物品(不消耗)     物品数量 物品ID
-- 30  使用技能    次数  战士技能ID 法师技能ID 道士技能ID（根据职业自动选）
-- 32  提交某个物品(消耗)  物品数量 物品ID
-- 33  装备洗炼     次数
-- 34  发布悬赏任务  次数
-- 35  接取悬赏任务   次数
-- 36  完成悬赏任务  次数
-- 37  完成狩猎任务  指定环
-- 38  参加副本（只参加） 副本类型（1屠龙2通天塔3公主4多人6新屠龙）   次数
-- 39  膜拜  次数
-- 40  升级勋章    次数
-- 41  购买神秘商店物品    次数
-- 42  开启神秘商店的格子   次数
-- 43  祝福武器    次数
-- 44  加入行会
-- 45  击杀玩家    次数
-- 46  运镖  次数
-- 47  劫镖  次数
-- 48  升级高级技能  次数
-- 49  仙翁赐酒    次数
-- 50  挖矿  次数
-- 51  参加焰火屠魔  次数

--新加任务类型
-- 53  对NPC使用道具任务 (53_npcid_propid   )
-- 54  触发式单人杀怪任务( 54_monsterid_freshid_monstermapid  )
-- 55  变身对话任务( 55_buffid )   要配置endnpc
-- 56  个人护送任务( 同镖车规则 56_pathid )
-- 57  对怪物使用道具任务(到目标物NPC或怪物坐标点 开始使用)  ( 57_monsterid_propid_freshid )
-- 58  无效定义(后台代码已删除)
-- 59  物品合成(合成次数_物品ID（填0表示任何物品）)
-- 60  悬赏任务 领取奖励
-- 61  模拟攻杀


    local targets = {}
    local targetStr = stringsplit(str, ";")

    --无参
    local params0 = {["2"] = true , ["10"] = true , ["44"] = true ,["61"] = true }        
    --1个参数(代表数量 次数  环数等 )
    local oneTimeParams = {
                            ["1"] = true , ["5"] = true, ["6"] = true, ["8"] = true, ["11"] = true, ["13"] = true, ["15"] = true, ["16"] = true, ["17"] = true, 
                            ["18"] = true, ["19"] = true, ["20"] = true, ["21"] = true, ["23"] = true, ["25"] = true, ["33"] = true, ["34"] = true, ["35"] = true, 
                            ["36"] = true, ["37"] = true, ["39"] = true, ["40"] = true, ["41"] = true, ["42"] = true, ["43"] = true, ["45"] = true, 
                            ["46"] = true, ["47"] = true, ["48"] = true, ["49"] = true, ["50"] = true, ["51"] = true, ["60"] = true, 
                            }
    --特殊的
    local specialParams = { ["14"] = true, ["22"] = true,  ["26"] = true, ["28"] = true, ["29"] = true, 
                            ["30"] = true, ["32"] = true, ["38"] = true, ["53"] = true, ["54"] = true,
                            ["55"] = true,["57"] = true, ["56"] = true,["59"] = true,}
    --不需要解析的
    local notDefined = {["3"] = true, ["4"] = true, ["7"] = true, ["9"] = true, ["12"] = true, ["24"] = true, ["27"] = true, ["31"] = true, }

    local function unifiedData( tgStr , target )
        target.ID = tonumber(tgStr[2])
        local cfg = getConfigItemByKey("monster", "q_id")[ target.ID ]
        target.name = cfg.q_name
        target.isAutoFight = true
        local cfg = getConfigItemByKey("monsterUpdate", "q_id")[ tonumber(tgStr[3]) ]
        target.mapID = cfg.q_mapid
        target.pos = { { x = cfg.q_center_x , y = cfg.q_center_y } } 
        target.count = 1
        target.cur_num = ( isRuning == 1 and target.count or 0 )
    end
    for key , v in pairs(targetStr) do

        local target = {}
        target.isAutoFight = false
        local tgStr = stringsplit(v, "_")
        target.s_id = tonumber(tgStr[1])

        if params0[ tgStr[1] .. ""] then
            target.count = 1
            target.cur_num = ( isRuning == 1 and target.count or 0 )
        elseif oneTimeParams[ tgStr[1] .. ""] then
            target.count = tonumber(tgStr[2])
            target.cur_num = ( isRuning == 1 and target.count or 0 )
        elseif specialParams[ tgStr[1] .. ""] then
            if tgStr[1] == "29" or tgStr[1] == "32" then
                target.ID = tonumber(tgStr[3])
                target.count = tonumber(tgStr[2])

                local pack = MPackManager:getPack(MPackStruct.eBag);
                target.cur_num = pack:countByProtoId(target.ID);
                if target.cur_num > target.count then
                    target.cur_num = target.count;
                end
                local MPropOp = require "src/config/propOp";
                target["roleName"] = MPropOp.name(target.ID);
            elseif tgStr[1] == "14" or tgStr[1] == "38" then
                target.fbType = tonumber(tgStr[2])
                target.count = tonumber(tgStr[3])
                target.cur_num = ( isRuning == 1 and target.count or 0 )
            elseif tgStr[1] == "22" then
                target.count = tonumber(tgStr[2])
                target.ID = tonumber(tgStr[3])
                target.count = 1
                target.cur_num = ( isRuning == 1 and target.count or 0 )
            elseif tgStr[1] == "26" then
                target.awrdsIdx = tonumber(tgStr[2])
                target.count = 1
                target.cur_num = ( isRuning == 1 and target.count or 0 )
            elseif tgStr[1] == "28" then
                target.titleID = tonumber(tgStr[2])
                target.count = 1
                target.cur_num = ( isRuning == 1 and target.count or 0 )
            elseif tgStr[1] == "30" then
                target.count = tonumber(tgStr[2])
                target.cur_num = ( isRuning == 1 and target.count or 0 )
                target.skillID = tonumber(tgStr[3])
            elseif tgStr[1] == "53" then
                --对NPC使用道具任务
                target.usePropType = 2
                target.ID = tonumber(tgStr[2])
                local cfg = getConfigItemByKey("NPC", "q_id" , target.ID )
                target.name = cfg.q_name
                target.isAutoFight = true
                target.mapID = cfg.q_map
                target.pos = { { x = cfg.q_x , y = cfg.q_y } } 
                target.count = 1
                target.cur_num = ( isRuning == 1 and target.count or 0 )
                target.usePropid = tonumber(tgStr[3])
            elseif tgStr[1] == "54" then
                --击杀特定怪
                unifiedData( tgStr , target )
            elseif tgStr[1] == "55" or tgStr[1] == "56" then
                --变身移动                
                target.count = 1
                target.cur_num = ( isRuning == 1 and target.count or 0 )
            elseif tgStr[1] == "57" then
                --对怪物使用道具
                unifiedData( tgStr , target )
                target.usePropType = 1
                target.usePropid = tonumber(tgStr[4])
            elseif tgStr[1] == "59" then
                --物品合成
                target.count = tgStr[2]
                target.usePropid = tonumber(tgStr[3])
                target.cur_num = ( isRuning == 1 and target.count or 0 )
            end
        end
        table.insert(targets, target)
    end

    return targets
end

DATA_Mission.__parseCollectTarget = function(v, b) return parseCollectTarget(v, b)  end

--格式化奖励数据
local formatAwardData = function( tempData )
  if not tempData then  print("invalid task data") return end
  local awardData = { 
                    q_rewards_exp = tempData.q_rewards_exp and { id = 444444 , num = tempData.q_rewards_exp } or nil ,       --任务奖励经验
                    q_rewards_coin = tempData.q_rewards_coin  and { id = 999998 , num = tempData.q_rewards_coin } or nil ,  --任务奖励铜钱
                    q_rewards_bdgold = tempData.q_rewards_bdgold  and { id = 999999 , num = tempData.q_rewards_bdgold } or nil , --任务奖励绑金
                    q_rewards_zq = tempData.q_rewards_zq  and { id = 777777 , num = tempData.q_rewards_zq } or nil ,  --任务奖励真气
                    lijin = tempData.q_rewards_bindYuanBao  and { showBind = true , isBind = true , id = 888888 , num = tempData.q_rewards_bindYuanBao } or nil ,  --绑定元宝
                    q_rewards_exploit = nil  , --"功勋暂无" 
                    q_rewards_prestige = nil , --"声望暂无"
                    q_rewards_goods = tempData.q_rewards_goods ,--任务奖励物品序列（!(不绑定)物品ID_数量_性别要求_职业要求_强化等级_附加属性类型1|附加属性比例,附加属性类型2|附加属性比例;任务奖励物品序列（物品ID_数量_性别要求_强化等级_附加属性类型1|附加属性比例,附加属性类型2|附加属性比例）
                  }

         local function parseRewardGoods( str )
              local goods , strengs = { } , {}
              local goodstr = stringsplit(str,";")
              -- str = "1100_5_0;id_num_roletype;"

              for key , value in pairs( goodstr ) do

                  local gdStr = stringsplit( value , "_")
                  gdStr[3] = tonumber( gdStr[3] or 0 )   --职业表现
                  gdStr[4] = tonumber( gdStr[4] or 0 )   --性别表现( 1男2女)
                  gdStr[5] = tonumber( gdStr[5] or 0 )   --强化等级表现

                  if gdStr[3] == 0 or gdStr[3] == MRoleStuct:getAttr(ROLE_SCHOOL) then --0为全职业 过滤职业
                  	if gdStr[4] == 0 or gdStr[4] == MRoleStuct:getAttr(PLAYER_SEX) then --0为全性别 过滤性别
	                      if goods[ gdStr[1] .. "" ] then
	                        goods[ gdStr[1] .. "" ] = goods[ gdStr[1] .. "" ] + tonumber(gdStr[2])
	                      else
	                        goods[ gdStr[1] .. "" ] = tonumber(gdStr[2])
	                      end
	                      strengs[ gdStr[1] .. "" ] = tonumber(gdStr[5])   --强化等级
                  	end
                  end

              end

              -- goods = { id = num , id = num } 

              local tempTable = {}
              for key , value in pairs( goods ) do
              	local strentValue = nil 
              	if strengs[ key ] or strengs[ key ] ~= 0 then
              		strentValue = strengs[ key ]
              	end
                tempTable[ #tempTable + 1 ] = { id = tonumber( key ) , num = value , streng = strentValue , }
              end

              return tempTable
          end


  tempData.awrds = {}
  for key , v in pairs( awardData ) do
      if key == "q_rewards_goods" then
          local tempTable = parseRewardGoods( v )
          for i = 1 , #tempTable do
            if tempTable[i].num and tempTable[i].num > 1 then 
              tempTable[i].showBind = true 
              tempTable[i].isBind = true 
              if tempTable[i].id == 777777 then tempTable[i].isBind = false end --声望不绑定
            end
            table.insert( tempData.awrds , tempTable[i] )
          end
      else
          table.insert( tempData.awrds , v )
      end

  end
  return tempData.awrds
end
DATA_Mission.__formatAwardData = function(v) return formatAwardData(v)  end

--格式化怪物数据
local function formatMonsterData( _monster , isCurTask )
      local tempValue = parseTaskTarget( _monster , isCurTask , true )
      for key , v in pairs( tempValue ) do
          local cfgItem = getConfigItemByKey("monster", "q_id")[ v.ID ]
          v.master_degree = cfgItem.q_lvl or 10
          v.name = cfgItem.q_name or game.getStrByKey( "not_configured" )
          v.roleName = cfgItem.q_name or game.getStrByKey( "not_configured" )
          v.monster_type = cfgItem.q_type
      end
     return tempValue[1]   --这里只支持单个怪物
end

local function paseEveryOtherEvent(_tempData)
    local ret = {}
    local event_type = "0"
    local doneEvent = _tempData["q_done_event"]

    if not doneEvent then 
        return event_type,ret 
    end 
    if doneEvent and tonumber(doneEvent) ~= 0 then
        local tgStr = stringsplit(doneEvent, "_")
        event_type =  doneEvent --tonumber(tgStr[1])
        
        if tonumber(tgStr[1]) == 29 then
            local itemData = getConfigItemByKeys("propCfg" , "q_id")[ tonumber(tgStr[2])]
            ret.id = tonumber(tgStr[2]) 
            ret.num = tonumber(tgStr[3])
            ret.name = itemData["q_name"]
        end
        ret.type = tonumber(tgStr[1])
    end

    return event_type,ret
end








function DATA_Mission:init()
    --保证只被初始化一次
    if not _data then
        _data = {}
        taskParent = nil
        upcallbaces = {}
        _data[ "plotCfg" ] = {}
        _data["newTask"] = nil      --当前最新任务
        _data[ "every" ] = nil      --日常任务
        _data[ "branch" ] = nil      --密令任务
        _data["rewardTask"] = nil   --新悬赏任务
        _data[ "tempFindPathData" ] = nil     --寻路数据
        _data["share"] = nil        -- 共享任务
        _data["lastTarget"] = nil		-- 共享任务
        isAutoPath = false
		    

		-- 禁止共享队伍多次
        self.m_isRecvShareTask = false;

        _data[ "branchPropID" ] = {}      --密令任务用到的道具
        local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )
        for k , v in pairs( cfg ) do
            if v.q_item then
              _data[ "branchPropID" ][ v.q_item .. "" ] = true
            end
        end

    end
end

function DATA_Mission:clearData()
  _data = nil
  DATA_Mission.no_tip_need_shoes = 0 -- 重置飞行靴提示
  DATA_Mission.no_tip_sharetask_monster = 0 -- 藏宝任务守卫怪提示
  DATA_Mission.plotFindPath = nil
  DATA_Mission.hunterFindPath = nil
  
end

function DATA_Mission:setParent( _layer )
    taskParent = _layer 
    roletype = MRoleStuct:getAttr( ROLE_SCHOOL )
end
function DATA_Mission:getParent()
    return taskParent
end
function DATA_Mission:setAutoPath( _bool )
  isAutoPath = _bool
end
function DATA_Mission:getAutoPath( _bool )
  return isAutoPath and(not DATA_Mission.isStopFind)
end
--设置
function DATA_Mission:setCallback( key , _fun )
    upcallbaces[ key ] = _fun
end
--获取
function DATA_Mission:getCallback( key )
    return upcallbaces[ key ] or nil
end
--计算finish值 
function DATA_Mission:countFinish( tempData , isCurTask )
  local finishValue = nil -- finished 1 等级不够 2进行中 3可交付 4 完成 5(对话没有接取时 原定义为不会出现的 )
  if isCurTask then

          if tempData.targetType ~= 1 then
                    if tempData.targetData and tempData.targetData.cur_num then
                        tempData.targetData.count =  tempData.targetData.count or 1
                    end
                    if tempData.targetData.cur_num >= tempData.targetData.count then
                        if tempData.q_finsh_type == 2 then
                            finishValue = 6   --非自动完成目标完成，但未付
                        else
                            finishValue = 4   --已完成
                        end
                    else
                        if tempData.targetType == 5 then
                            local pack = MPackManager:getPack(MPackStruct.eBag);
                            tempData.targetData.cur_num = pack:countByProtoId(tempData.targetData.ID);
                            if tempData.targetData.cur_num >= tempData.targetData.count then
                                tempData.cur_num = tempData.targetData.count;
                                finishValue = 6   --非自动完成目标完成，但未付
                            else
                                finishValue = 2   --进行中
                            end
                        else
                            finishValue = 2   --进行中
                        end
                    end
          else
                finishValue = 5     --对话
          end

  else
      if _data["newTask"] then

            if tempData.q_taskid and _data["newTask"].q_taskid then
                if tempData.q_taskid == _data["newTask"].q_taskid then
                  --任务进行中  不同任务类型  提示语不同
                  if tempData.targetType == 1 then
                      finishValue = 5
                  else
                      finishValue = 2 
                  end
                else
                  if tempData.q_taskid > _data["newTask"].q_taskid then
                      finishValue = 5                      --未完成(这个类型不会展示出来的，考虑拓展性 写出来的，)
                  else
                       finishValue = 4                       --已完成
                  end
                end
            end

      end

  end

  return finishValue
end


--设置最后寻路地址
function DATA_Mission:setLastFind( tempData )
  if _data ~= nil then
    _data[ "lastAddr" ] = tempData
  else
    print("\n DATA_Mission:setLastFind error: _data is nil!");
  end
end
function DATA_Mission:getLastFind()
  return _data[ "lastAddr" ] or nil
end

--更新剧情任务数据
function DATA_Mission:upPlotData( tempData )
    local itemCfg  = getConfigItemByKeys( "TaskDB" , { "q_chapter" , "q_taskid" } , { tempData["chapterID"] , tempData["taskID"] } )
    if itemCfg == nil then
        error("error chapterID = ".. tempData["chapterID"]..",taskID =" .. tempData["taskID"] )
        return
    end
    if tempData.isBan then 
      -- if  MRoleStruct:getAttr(ROLE_LEVEL) < _data[ "newTask" ]["q_accept_needmingrade"] then
          -- _data[ "newTask" ].finished = 1
      -- end
      itemCfg.isBan = true
    else
        itemCfg.isBan = nil
    end

    _data[ "newTask" ] = DATA_Mission:formatTaskData( itemCfg  , tempData[ "isNew" ] or 1 )
    if tempData["targetState"] then
        _data[ "newTask" ]["targetData"]["cur_num"] = tempData["targetState"][1] or 0
    end

    _data[ "newTask" ].finished = DATA_Mission:countFinish( _data[ "newTask" ] , true )

    if TOPBTNMG then TOPBTNMG:showMG( "Dictionary" , _data[ "newTask" ].q_taskid ~= 10000 ) end


    if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end --刷新界面回调
end

--获取剧情数据前台格式化后的数据
function DATA_Mission:getPlotData()
    local newTask = DATA_Mission:getLastTaskData()
    local lastChapter , taskID = newTask.q_chapter , newTask.q_taskid
    local cfgData = getConfigItemByKeys( "TaskDB" , { "q_chapter" , "q_taskid" }  )
    local tempCfg = {}
    for i , v in ipairs( cfgData ) do
      if i <= lastChapter then
        tempCfg[i] = { }
        for n , m in pairs( v ) do
          local speakTab = getConfigItemByKey( "NPCSpeak" , "q_id" )[ m.q_speakID ] or {}
          if n < taskID then
            m.q_task_desc = speakTab["q_task_done"]  or game.getStrByKey( "not_configured" ) 
            tempCfg[i][#tempCfg[i] + 1] = DATA_Mission:formatTaskData( m )
          elseif n == taskID then
              --当前最新任务
              tempCfg[i][#tempCfg[i] + 1] = _data[ "newTask" ] 
              local spC = { "q_task_accept"  , "q_task_accept" , "q_task_accept" , "q_task_done" , "q_task_accept" , "q_task_done"}
              _data[ "newTask" ].q_task_desc = speakTab[ spC[ _data[ "newTask" ].finished ] ]
          end
        end
      end
    end

    for key , value in pairs( tempCfg ) do
        table.sort( value , function( a , b ) return a.q_taskid < b.q_taskid end  )
    end
    _data[ "plotCfg" ] = tempCfg

  return _data["plotCfg"]
end
--获取最新任务数据
function DATA_Mission:getLastTaskData()
  return _data and _data[ "newTask" ] or nil
end

--检测指定_id采集物是否存在于正在进行的任务中
function DATA_Mission:checkCollection( _id )
    local isExist = false
    local ids = {}
    local curTask = _data[ "newTask" ] or nil
    if curTask and curTask.targetData and curTask.finished == 2 and curTask["targetType"] == 2 then
        ids[ curTask.targetData.ID .. "" ] = true 
    end

    curTask = _data[ "every" ] or nil
    if curTask and curTask.targetData and curTask.finished ~= 4 and curTask["targetType"] == 2 then
        ids[ curTask.targetData.ID .. "" ] = true 
    end

    curTask = DATA_Mission:GetRewardTaskData()
    if curTask then
        curTask = curTask["hadTask"]
        if curTask and curTask["targetData"] and curTask["targetType"] == 2 and curTask.finished == 2 then
            ids[ curTask.targetData.ID .. "" ] = true 
        end
    end

    curTask = DATA_Mission:getBranchData()
    if curTask and curTask["list"] then 
        for k , v in pairs( curTask["list"] ) do
            if v.targetData and v.targetType == 2 and v.isRuning and  not v.isEnd then
                ids[ v.targetData.ID .. "" ] = true
            end
        end
    end

    if _id and ids[ _id .. "" ] then
        isExist = true
    end

    return isExist
end

--获取最新任务怪
function DATA_Mission:getTaskMonsterID()
  local curTask = _data[ "newTask" ] or nil
  local monster_id = nil
  if curTask and curTask.targetData and curTask.finished == 2 then
      monster_id = curTask.targetData.ID
  end
  if not monster_id then
    curTask = _data[ "every" ] or nil
      if curTask and curTask.targetData and curTask.finished ~= 4 then
        monster_id = curTask.targetData.ID
    end
  end
    if not monster_id then
        curTask = DATA_Mission:GetRewardTaskData()
        if curTask then
            curTask = curTask["hadTask"]
            -- 修正
            if curTask and curTask["targetData"] and curTask["targetType"] == 3 then
                monster_id = curTask.targetData.ID
            end
        end
    end
    if not monster_id then
        curTask = DATA_Mission:getBranchData()
        if curTask and  curTask["list"] then 
            for k , v in pairs( curTask["list"] ) do
                if v.targetData and v.targetType == 3 and v.finished == 2 then
                    monster_id = v.targetData.ID
                end
            end
        end
    end

  return monster_id
end

function DATA_Mission:getData( key )
  return _data[ key ] or nil 
end




--格式化剧情单个数据
function DATA_Mission:formatTaskData( _tempData , isRuning )
    if not _tempData then  return nil end
    local tempData = {}
    for key , v in pairs( _tempData ) do
        tempData[key] = v 
    end

    formatAwardData( tempData )
    local isBan = false
    if tempData.isBan then isBan = true end

    tempData.targetType = 1               --默认对话任务
    if tempData.q_end_need_goods then tempData.targetType = 2 end         --收集任务
    if tempData.q_end_need_killmonster then tempData.targetType = 3 end   --杀怪任务
    local q_done_event = 0
    if tempData.q_done_event then
        q_done_event = tonumber( stringsplit( tempData.q_done_event , "_" )[1] )
        if q_done_event and q_done_event ~= 0  then  -- 收集任务
            tempData.targetType = 5        
        end
    end

    if tempData.q_endnpc then
        local npcCfg = getConfigItemByKey( "NPC", "q_id" )[ tempData.q_endnpc ] or {}
        tempData.NpcName = npcCfg["q_name"] or ""
        tempData.NpcBodyRes  = npcCfg["q_boby"] or ""
    end


    if isBan and tempData.q_startnpc then
        tempData.targetType = 1
        local npcCfg = getConfigItemByKey( "NPC", "q_id" )[ tempData.q_startnpc ]
        tempData.NpcName = npcCfg["q_name"]
        tempData.NpcBodyRes  = npcCfg["q_boby"]
    end



    if tempData.targetType == 1  then
        local isOther = tempData.q_done_event and tonumber( tempData.q_done_event ) ~= 0 

        if not isOther then
            local npcCfg = getConfigItemByKey( "NPC", "q_id" )[ isBan and tempData.q_startnpc or  tempData.q_endnpc ]
            if npcCfg then
                tempData.targetData = { roleName = npcCfg["q_name"] , replyName = npcCfg["q_name"]  }
                tempData.targetData.pos = { { x = npcCfg.q_x , y = npcCfg.q_y } }
                tempData.targetData.mapID = npcCfg.q_map
            end
        else
            if isBan and  ( q_done_event == 54 or q_done_event == 53 ) then
              --特殊类型任务数据异常兼容
              local tmp = parseCollectTarget(tempData.q_done_event , 0 )
              tempData.targetData = tmp[1]
            else
              tempData.targetData = { roleName = "other" , replyName = "other" , pos = {0 , 0 } , mapID = 0 }
            end

        end

    elseif tempData.targetType == 2  then
        local _temp = parseTaskTarget( tempData.q_end_need_goods , isRuning or 0 )
        _temp = _temp[1]        --当前支持同时采集一种物品

        local name = getConfigItemByKey( "NPC" , "q_id" , _temp.ID , "q_name" )
        if type(name) == "table"  then name = game.getStrByKey( "not_configured" ) end
        _temp["roleName"] = name
        _temp["replyName"] = getConfigItemByKey("NPC", "q_id" , isBan and tempData.q_startnpc or  tempData.q_endnpc , "q_name")

        tempData.targetData = _temp
    elseif tempData.targetType == 3  then
        local _temp = parseTaskTarget( tempData.q_end_need_killmonster , isRuning or 0 , true )
        tempData.targetData  = _temp[1] --当前只支持同时击杀一种怪物
        tempData.targetData[ "roleName" ]  = getConfigItemByKey( "monster" , "q_id" , tempData.targetData.ID , "q_name" ) 
    elseif tempData.targetType == 5 then
        local tmp = parseCollectTarget(tempData.q_done_event , isRuning )
        tempData.targetData = tmp[1]
    end
    
    if tempData.q_word and tempData["targetData"] then
        tempData["targetData"]["name"] = tempData.q_word
        tempData["targetData"]["roleName"] = tempData.q_word
    end

  tempData.finished = DATA_Mission:countFinish( tempData )


  return tempData
end



--设置是否开始等待触发弹出日常
function DATA_Mission:getEveryTipNode( _node )
  return _data["everyTip"]
end
function DATA_Mission:setEveryTipNode( _node )
  _data["everyTip"] = _node
end
function DATA_Mission:setEveryWaitFun( _fun )
  _data["waitFun"] = _fun
end
function DATA_Mission:getEveryWaitFun()
  return _data["waitFun"]
end

--返回上一环日常任务数据
function DATA_Mission:getPreEveryData()
  return _data[ "preEveryData" ]
end
--更新日常任务
function DATA_Mission:upEveryData( _tempData )

  if _tempData.turnNum == 1 then
    _data[ "preEveryData" ] = nil
  else
    _data[ "preEveryData" ] = {}
    if _data[ "every" ] then
      for key , v in pairs( _data[ "every" ] ) do
        _data[ "preEveryData" ][key] = v 
      end
    end

  end

    if not _data[ "every" ] then _data[ "every" ] = {} end
    _data[ "every" ] =  _tempData
    local cfg = getConfigItemByKeys( "dtaskDB" , "q_taskid" )[ _tempData.id ]
    if not  cfg then
      return
    end
    _data["every"]["name"] = cfg["q_name"] or game.getStrByKey( "not_configured" )
    _data[ "every" ][ "desc" ] = cfg["q_task_desc"]
    _data[ "every" ][ "targetType" ] = 3
    
    if cfg.q_end_need_killmonster then
        _data[ "every" ][ "targetData" ] = formatMonsterData( cfg["q_end_need_killmonster"] , 0 )
    end
    if cfg.q_end_need_goods then
        _data[ "every" ][ "targetType" ] = 2 
        local _temp = parseTaskTarget( cfg["q_end_need_goods"] , 0 )
        _data[ "every" ][ "targetData" ]  = _temp[1] --当前只支持同时采集一种物品
        _data[ "every" ][ "targetData" ]["roleName"]  = getConfigItemByKey( "NPC" , "q_id" , _data[ "every" ]["targetData"].ID  , "q_name" ) 
        _data[ "every" ][ "targetData" ]["name"]  = getConfigItemByKey( "NPC" , "q_id" , _data[ "every" ]["targetData"].ID  , "q_name" ) 
    end
    if _data.every.targetData then
      _data[ "every" ][ "targetData" ].q_map_name = getConfigItemByKey("MapInfo", "q_map_id")[ _data[ "every" ][ "targetData" ].mapID ].q_map_name
    else
      _data[ "every" ][ "targetData" ] = {}
    end
    _data[ "every" ][ "targetData" ].cur_num = ( #_tempData.taskstate == 0 and 0 or _tempData.taskstate[1] )
    _data[ "every" ][ "targetData" ].count = _data[ "every" ][ "targetData" ].count or 0    

    

    _data["every"]["q_done_event"], _data["every"]["extern"] = paseEveryOtherEvent( cfg )

    if _data["every"]["extern"] then _data["every"]["extern"]["cur_num"] = ( #_tempData.taskstate == 0 and 0 or _tempData.taskstate[1] ) end


  
    --任务额外奖励
    _data[ "every" ][ "extraReward" ] = formatAwardData( getConfigItemByKeys( "dReward" ,  { "q_levelMin" , "q_levelMax" } , { cfg.q_recieveLeveMin , cfg.q_recieveLeveMax } ) )
    --日常任务奖励

    _data[ "every" ][ "rewardCfg" ] = getConfigItemByKeys( "dRewardStar" ,  "q_id" )[ _tempData.rewardid ]
    _data[ "every" ][ "reward" ] = formatAwardData( _data[ "every" ][ "rewardCfg" ] )
    _data[ "every" ][ "q_downStarNeedMoney" ] = cfg.q_downStarNeedMoney


    if upcallbaces[ "every_refresh" ] then upcallbaces[ "every_refresh" ]() end --刷新界面回调
    if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end --刷新界面回调

end

--返回日常数据
function DATA_Mission:getEveryData()
   return _data[ "every" ] or nil
end

--返回日常数据
function DATA_Mission:cleanEveryData()
  _data[ "every" ] = nil
end

--日常任务升降星
function DATA_Mission:changeEveryStar( _type )
    if _type == 1 then
      _data[ "every" ][ "starlv" ] = 1 
      --local cur_num = _data[ "every" ][ "targetData" ].cur_num
      
      local cfg = getConfigItemByKeys( "dtaskDB" , "q_taskid" )[ _data[ "every" ].id ]
      _data[ "every" ][ "targetData" ] = formatMonsterData( cfg["q_end_need_killmonster"]  , 0 )
      --_data[ "every" ][ "targetData" ].q_map_name = getConfigItemByKey("MapInfo", "q_map_id")[ _data[ "every" ][ "targetData" ].mapID ].q_map_name
      --_data[ "every" ][ "targetData" ].cur_num = cur_num
      --_data[ "every" ][ "targetType" ] = 3

    else
      local tempCfg = getConfigItemByKey( "dRewardStar" )
      for i = 1 , #tempCfg do
          if tempCfg[i].q_levelMin == _data[ "every" ][ "rewardCfg" ].q_levelMin and tempCfg[i].q_levelMax == _data[ "every" ][ "rewardCfg" ].q_levelMax and tempCfg[i].q_starLevel == 5 then
            _data[ "every" ][ "rewardCfg" ] = tempCfg[i]
            --local cur_num = _data[ "every" ][ "targetData" ].cur_num
            _data[ "every" ][ "reward" ] = formatAwardData( _data[ "every" ][ "rewardCfg" ] )
            -- _data[ "every" ][ "targetData" ].q_map_name = getConfigItemByKey("MapInfo", "q_map_id")[ _data[ "every" ][ "targetData" ].mapID ].q_map_name
            -- _data[ "every" ][ "targetData" ].cur_num = cur_num
            -- _data[ "every" ][ "targetType" ] = 3
          end
      end
    end
    
    if upcallbaces[ "every_refresh" ] then upcallbaces[ "every_refresh" ]() end --刷新界面回调
    if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end         --刷新界面回调
    if upcallbaces[ "popup_up_star" ] then upcallbaces[ "popup_up_star" ]() end --日常弹出界面回调

end

--更新指定key的值
function DATA_Mission:changeKeyValue( key ,  value )
    local over_every = nil
    if key == "turnNum" then
      --更新轮次
        _data[ "every" ][ "turnNum" ] = value
        _data[ "every" ][ "targetData" ]["cur_num"] = _data[ "every" ][ "targetData" ]["count"]
        over_every = (value  == __TASK:getEveryNum() )
        _data[ "every" ][ "overEvery" ]  = over_every

        if over_every then
            if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end --刷新界面回调
            _data[ "every" ]["isOverLogin"] = true
        end

    elseif key == "KillNum" then
        --更新击杀个数
        if _data[ "every" ][ "targetData" ] then 
            _data[ "every" ][ "targetData" ]["cur_num"] = value
        end
        if _data[ "every" ][ "extern"]  then
            _data[ "every" ][ "extern"]["cur_num"] = value
        end
        if _data[ "every" ]["q_done_event"] and tonumber(_data[ "every" ]["q_done_event"]) == 0 then
            __TASK:showTip( _data[ "every" ] )
        end
    end



    if upcallbaces[ "every_refresh" ] then upcallbaces[ "every_refresh" ](over_every) end --刷新界面回调
    if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end --刷新界面回调
end


--设置当前寻路的任务类型
function DATA_Mission:setTempFindPath(  _tempData )
    -- _data 会被置空
    if _data ~= nil then
        _data[ "tempFindPathData" ] = _tempData
    else
        print("\n error: _data is nil!");
    end
end
function  DATA_Mission:getTempFindPath( )
    local tag = nil
    if _data and _data[ "tempFindPathData" ] then
        tag = _data[ "tempFindPathData" ]
    end
    return tag
end




-- 判断：当前是否有某种目标的主线在
function DATA_Mission:IsMainTaskHadByTarget(tar)
    if _data["newTask"] then
        -- 清空缓存的数据
        resetConfigItems();
        local tarStr = tar .. "_1";
        local taskId = getConfigItemByKey("TaskDB", "q_done_event", tarStr, "q_taskid");
        -- 清空缓存的数据
        resetConfigItems();
        if taskId then
            return (taskId == _data["newTask"].q_taskid);
        end
    end

    return false;
end

-- 当前是否需要构造假的可接悬赏任务
function DATA_Mission:IsNeedNullRewardTask()
    if _data["rewardTask"] == nil or _data["rewardTask"]["hadTask"] == nil then
        local commConst = require("src/config/CommDef");
        return self:IsMainTaskHadByTarget(commConst.TASK_TARGET_ACCEPT_REWARD_TASK);
    end

    return false;
end

-- 构造一个假的可接悬赏任务
function DATA_Mission:MakeNullRewardTask()
    local acceptableData = {};

    acceptableData.blueLeftNum = 5;
    acceptableData.purpleLeftNum = 5;
    acceptableData.extremeLeftNum = 1;

    acceptableData.taskList = {};

    acceptableData.taskList[1] = {};

    local commConst = require("src/config/CommDef");

    acceptableData.taskList[1].taskguid = 0;                                -- 唯一ID
    acceptableData.taskList[1].ownername = game.getStrByKey("system");      -- 发布者名字
    acceptableData.taskList[1].expiretime = 30*60;                          -- 过期时间(到期时的秒数)
    acceptableData.taskList[1].taskrank = 2;                                -- 1 蓝色, 2 紫色, 3 至尊
    acceptableData.taskList[1].taskid = commConst.REWARD_TASK_ID_NULL;      -- 任务ID
    acceptableData.taskList[1].receiveNum = 0;                              -- 任务被接取次数
    acceptableData.taskList[1].newTag = 1;                                  -- 1. new 标记

    self:FormatAcceptRewardTasks(acceptableData);
end


-- 格式化自己接取的一个新悬赏任务
function DATA_Mission:FormatHadRewardTask(tmpData)
    if tmpData == nil then return end

    if _data["rewardTask"] == nil then
        _data["rewardTask"] = {};
        _data["rewardTask"].acceptLeftBlueNum = 0;
        _data["rewardTask"].acceptLeftPurpleNum = 0;
        _data["rewardTask"].acceptLeftExtremeNum = 0;
        _data["rewardTask"].publishLeftNum = 0;
        _data["rewardTask"].publishExtremeLeftNum = 0;
    end

    _data["rewardTask"]["hadTask"] = {};
    local curData = _data["rewardTask"]["hadTask"];
    local cfg = getConfigItemByKey("rewardTaskCfg", "q_taskid");

    for k, v in pairs(tmpData) do
        curData[k] = v;
    end

    -- 配置表
    local itemCfg = cfg[curData.id]
    if itemCfg ~= nil then
        local tmpTb = self:formatTaskData( itemCfg , true );
        for k, v in pairs(tmpTb) do
            curData[k] = v
        end
        
        if tmpData["targetState"] then
            curData["targetData"]["cur_num"] = curData["targetState"][1] or 0
        end


        if curData.q_task_desc == nil and curData.q_task_done then 
            curData.q_task_desc = curData.q_task_done
        end

        curData.finished = self:countFinish( curData , true );
    end

    -- 刷新界面回调
    if upcallbaces["main_flag"] ~= nil then
        upcallbaces["main_flag"]();
    end

    -- 弹出界面
    if tmpData.isNew == 1 then
        __TASK:playTaskEffect(1)
		AudioEnginer.playEffect("sounds/uiMusic/ui_accept.mp3",false)

        local rewardData = self:GetRewardTaskData() and self:GetRewardTaskData()["hadTask"];
		-- 未死亡，并且非收集类任务立即自动寻路
		if  G_ROLE_MAIN:getHP() > 0 and rewardData ~= nil and rewardData.targetType ~= 5 then
			__TASK:findPath(rewardData)
		end

        __TASK:popupLayout("rewardTask");

        --刷新界面回调
        if upcallbaces[ "rewardTaskSelfLayer" ] then
            upcallbaces[ "rewardTaskSelfLayer" ](5);
        end
    end

    if upcallbaces["rewardTaskFlag"] ~= nil then
        upcallbaces["rewardTaskFlag"](2);
    end
end

-- 完成0， 放弃1
function DATA_Mission:FinishRewardTask(state)
    if _data["rewardTask"] ~= nil then
        _data["rewardTask"]["hadTask"] = nil;
    end

    self.isStopFind = true
    self:setAutoPath(false);
    if game.getAutoStatus() == AUTO_ATTACK then
		  game.setAutoStatus(0)
    end

    -- 刷新界面回调
    if upcallbaces["main_flag"] ~= nil then
        upcallbaces["main_flag"]();
    end
    if upcallbaces["rewardTaskFlag"] ~= nil then
        upcallbaces["rewardTaskFlag"](state);
    end
end

-- 更新新悬赏任务的状态
function DATA_Mission:UpdateRewardStatus(taskid , state)
    local curData = _data["rewardTask"] and _data["rewardTask"]["hadTask"];
    if curData ~= nil and state ~= nil and #state > 0 then
        -- 更新击杀个数
        if curData[ "targetData" ] then 
            curData[ "targetData" ].cur_num = state[1];

            curData.finished = self:countFinish( curData, true )

            __TASK:showTip( curData );

            if curData.finished == 6 then
                __TASK:findPath( curData );
            end
      	end
    end

    -- 刷新界面回调
    if upcallbaces["main_flag"] ~= nil then
        upcallbaces["main_flag"]();
    end
    if upcallbaces["rewardTaskFlag"] ~= nil then
        upcallbaces["rewardTaskFlag"](2);
    end
end

function DATA_Mission:UpdateCollectTask()
    local tempData = self:GetRewardTaskData() and self:GetRewardTaskData()["hadTask"];
    if tempData ~= nil then
        if tempData.targetType == 5 then
            local pack = MPackManager:getPack(MPackStruct.eBag);
            tempData.targetData.cur_num = pack:countByProtoId(tempData.targetData.ID);
            if tempData.targetData.cur_num > tempData.targetData.count then
                tempData.targetData.cur_num = tempData.targetData.count;
            end
            tempData.finished = self:countFinish(tempData, true);

            -- 刷新界面回调
            if upcallbaces["main_flag"] ~= nil then
                upcallbaces["main_flag"]();
            end
            if upcallbaces["rewardTaskFlag"] ~= nil then
                upcallbaces["rewardTaskFlag"](2);
            end
        end
    end
end

-- 格式化自己发布的新悬赏任务
function DATA_Mission:FormatRewardTaskData(tmpData)
    if tmpData == nil then return end

    if _data["rewardTask"] == nil then
        _data["rewardTask"] = {};
        _data["rewardTask"].acceptLeftBlueNum = 0;
        _data["rewardTask"].acceptLeftPurpleNum = 0;
        _data["rewardTask"].acceptLeftExtremeNum = 0;
        _data["rewardTask"].publishLeftNum = 0;
        _data["rewardTask"].publishExtremeLeftNum = 0;
    end

    if tmpData.taskList ~= nil then
         _data["rewardTask"].publishLeftNum = tmpData.pubNum;
         _data["rewardTask"].publishExtremeLeftNum = tmpData.pubExtreNum;

        -- 刷新数据
        _data["rewardTask"]["listData"] = {}
        local cfg = getConfigItemByKey("rewardTaskCfg", "q_taskid")

        -- 服务器每一份数据
        for i=1, #tmpData.taskList do
            local curData = tmpData.taskList[i]
            _data["rewardTask"]["listData"][i] = {}
            local single = _data["rewardTask"]["listData"][i]

            for k, v in pairs(curData) do
                single[k] = v
            end

            -- 配置表
            local cfgData = cfg[curData.taskid]
            if cfgData ~= nil then
                local tmpTb = self:formatTaskData( cfgData , true );
                for k, v in pairs(tmpTb) do
                    single[k] = v
                    if k == "awrds" then
                        if v ~= nil then -- 2倍奖励
                            for i=1, #single[k] do
                                single[k][i].num = single[k][i].num*2;
                            end
                        end  
                    end
                end
                single.finished = self:countFinish( single, true );
            else    -- 服务器数据错误 舍弃
                _data["rewardTask"]["listData"][i] = nil;
                break;
            end
        end
    end

    --刷新界面回调
    if upcallbaces[ "rewardTaskSelfLayer" ] then
        upcallbaces[ "rewardTaskSelfLayer" ](4)
    end
end

-- 直接从缓存中加载可接取的新悬赏任务
function DATA_Mission:RefreshAcceptRewardTasks()
    upcallbaces["rewardTaskSelfLayer"](6)
end

-- 格式化可接取的新悬赏任务
function DATA_Mission:FormatAcceptRewardTasks(tmpData)
    if tmpData == nil then return end

    if _data["rewardTask"] == nil then
        _data["rewardTask"] = {};
        _data["rewardTask"].acceptLeftBlueNum = 0;
        _data["rewardTask"].acceptLeftPurpleNum = 0;
        _data["rewardTask"].acceptLeftExtremeNum = 0;
        _data["rewardTask"].publishLeftNum = 0;
        _data["rewardTask"].publishExtremeLeftNum = 0;
    end

    if tmpData.taskList ~= nil then
        _data["rewardTask"].acceptLeftBlueNum = tmpData.blueLeftNum;
        _data["rewardTask"].acceptLeftPurpleNum = tmpData.purpleLeftNum;
        _data["rewardTask"].acceptLeftExtremeNum = tmpData.extremeLeftNum;
        _data["rewardTask"]["juinor"] = {};
        _data["rewardTask"]["senior"] = {};
        _data["rewardTask"]["extreme"] = {};
        local cfg = getConfigItemByKey("rewardTaskCfg", "q_taskid");
        for i=1, #tmpData.taskList do
            while true do
                local curData = tmpData.taskList[i];
                local tmpTable = curData.taskrank == 1 and _data["rewardTask"]["juinor"] or (curData.taskrank == 2 and _data["rewardTask"]["senior"] or _data["rewardTask"]["extreme"])
                local currentTopIndex = #tmpTable + 1
                tmpTable[currentTopIndex] = {};
                local single = tmpTable[currentTopIndex];
                for k, v in pairs(curData) do
                    single[k] = v
                end
                -- 配置表
                local cfgData = cfg[curData.taskid]
                if cfgData ~= nil then
                    local tmpTb = self:formatTaskData( cfgData , true );
                    for k, v in pairs(tmpTb) do
                        single[k] = v
                    end
                    single.finished = self:countFinish( single, true );
                end
                break
            end
        end
    end

    --刷新界面回调
    if upcallbaces["rewardTaskSelfLayer"] then
        upcallbaces["rewardTaskSelfLayer"](1);
    end
end

-- 任务倒计时处理
function DATA_Mission:RewardTaskCountdown()
    if _data ~= nil and _data["rewardTask"] ~= nil then
        local rewardTaskUpdate = function(tmpTable)
            if tmpTable ~= nil then
                local iNum = tablenums(tmpTable);
                if iNum > 0 then
                    for i = 1, iNum do
                        if tmpTable[i].expiretime ~= nil then
                            if tmpTable[i].expiretime >= 0 then
                                tmpTable[i].expiretime = tmpTable[i].expiretime - 1;
                            end
                        end
                    end
                end
            end
        end

        -- 自己发布的任务倒计时
        rewardTaskUpdate(_data["rewardTask"]["listData"]);

        -- 当前可接取的任务倒计时
        rewardTaskUpdate(_data["rewardTask"]["juinor"]);
        rewardTaskUpdate(_data["rewardTask"]["senior"]);
        rewardTaskUpdate(_data["rewardTask"]["extreme"]);
    end
end

-- 我的悬赏任务全局计时
function DATA_Mission:MyAcceptedRewardTaskCountdown()
    if _data ~= nil and _data["rewardTask"] ~= nil then
        -- 自己接取的任务 独占倒计时
        if _data["rewardTask"]["hadTask"] then
            if _data["rewardTask"]["hadTask"].guardExpiredTime ~= nil then
                if _data["rewardTask"]["hadTask"].guardExpiredTime > 0 then
                    _data["rewardTask"]["hadTask"].guardExpiredTime = _data["rewardTask"]["hadTask"].guardExpiredTime - 1;
                end
            end
        end
    end
end

-- 获取新悬赏数据
function DATA_Mission:GetRewardTaskData()
    return ((_data and _data["rewardTask"]) or nil)
end

--检测是否是仙翼
function DATA_Mission:chechWing( _temp )
  local targetType = 1 
  if _temp and _temp.q_type then
    targetType = _temp.q_type
  end
  return targetType 
end

--最新的密令任务
function DATA_Mission:getLastBranch( str )
    local curData = nil
    if _data and _data[ "branch" ] then
        -- local length = #_data[ "branch" ]["list"]
        -- if length>0 then
        --     curData = _data[ "branch" ]["list"][length]
        -- end
        if str == "wing" then
          curData = _data[ "branch" ]["wing"]
        else
          curData = _data[ "branch" ]["newTask"]
        end
    end
    return curData
end


--获取仙翼密令
function DATA_Mission:getTaskWing( )
    local curData = nil
    if _data[ "branch" ] then
        curData = _data[ "branch" ]["wing"]
    end
    return curData
end
--所有密令或者指定id的密令
function DATA_Mission:getBranchData( _id )
    local tempData = _data[ "branch" ]

    if _id then
        local tagIdx = _data[ "branch" ]["idIdx"][_id]
        if tagIdx then
            local tagData = _data[ "branch" ]["list"]
            if not tagData then
               tagData = _data[ "branch" ]["history"]
            end
            return tagData
        end
    end

    return tempData
end

--等级变化更新
function DATA_Mission:checkBranchData()
    -- local role_level = MRoleStruct:getAttr(ROLE_LEVEL)
    -- local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )
    -- for key , v in pairs( cfg ) do 
    --     if role_level >= v.q_accept_needmingrade then
    --         DATA_Mission:upBranchData( { noRefresh = true , id = v.q_taskid } )
    --     end
    -- end

    -- if upcallbaces[ "branch_refresh" ] then upcallbaces[ "branch_refresh" ]() end --刷新界面回调
    -- if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end --刷新界面回调
end

--更新密令任务
function DATA_Mission:upBranchData( _tempData )
    if not _data[ "branch" ] then
       _data[ "branch" ] = { idIdx = {} , list = {} , history = {} , newTask = nil , wing = nil }
    end

    local idx = _data[ "branch" ]["idIdx"][ _tempData.id .. "" ]
    local isOne = false
    local pathStr = "list"
    if not idx then
        if _tempData.isComplete then
            pathStr = "history" 
        end
        idx = #_data[ "branch" ][pathStr] + 1
        _data[ "branch" ]["idIdx"][ _tempData.id .. "" ] = idx
        isOne = true
    end

    local curData =  _data[ "branch" ][ pathStr ][idx]


    if isOne == true then
         --初始化

        local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ _tempData["id"] ]
        _data[ "branch" ][ pathStr ][idx] = DATA_Mission:formatTaskData( cfg , 1 )
        curData = _data[ "branch" ][ pathStr ][idx]

        if cfg == nil then
            _data[ "branch" ] = nil      --密令任务数据异常 防御            
            return 
        end

        curData.name = cfg["q_name"] or game.getStrByKey( "not_configured" )
        curData.desc = ""
        
        local npcSpeakCfg = getConfigItemByKey( "NPCSpeak" , "q_id" )[ curData.q_speakID ]
        if npcSpeakCfg then
            if _tempData.isComplete then
                curData.desc = npcSpeakCfg["q_task_done"] or ""
            else
                curData.desc = npcSpeakCfg["q_task_accept"] or ""
            end
        end
    end



    if _tempData.isAdd then
        --新加任务放到最新的位置
        local tagIdx = _data[ "branch" ]["idIdx"][ _tempData.id .. "" ]
        table.insert( _data[ "branch" ]["list"] , table.remove( _data[ "branch" ]["list"] ,tagIdx ) ) 
        local listNum =  #_data[ "branch" ]["list"]
        for i = 1 , listNum do
            local id = _data[ "branch" ]["list"][i]["q_taskid"]
            _data[ "branch" ]["idIdx"][ id .. "" ] = i
        end
    end

    --更新
    if _tempData.targetState then
        curData.isBegin = nil
        curData.isRuning = true   --区分是否接取了
        if curData["targetData"] and curData["targetData"]["cur_num"] then
            curData["targetData"]["cur_num"] = _tempData["targetState"][1] or 0
            if curData["targetData"]["cur_num"] == curData["targetData"]["count"] then
                curData.isEnd = true
            end
        end

        if DATA_Mission:chechWing( curData ) == 1 then
          _data[ "branch" ]["newTask"] = curData
        else
          _data[ "branch" ]["wing"] = curData
        end
    end

    --不管其它地方 taskState 任务状态变化 修改描述文字
    if _tempData.taskState then
        local npcCfg = getConfigItemByKey( "NPCSpeak" , "q_id" )[ curData.q_speakID ]
        if npcCfg then
            local state = _tempData.taskState[1]     
            curData.desc  = npcCfg[ state == 3 and "q_task_done" or "q_task_accept"  ]

        end

        if _tempData.taskState[1] == 2 then
            curData.isEnd = true
            curData.finished = 3
        end

        if DATA_Mission:chechWing( curData ) == 1 then
          _data[ "branch" ]["newTask"] = curData
        else
          _data[ "branch" ]["wing"] = curData
        end
    end

    local function resetIndex()
        _data[ "branch" ]["idIdx"] = {}
        for  i = 1 , #_data[ "branch" ]["list"] do
        	local v = _data[ "branch" ]["list"][i]
        	_data[ "branch" ]["idIdx"][ v.q_taskid .. "" ] = i
        end
        for  i = 1 , #_data[ "branch" ]["history"] do
        	local v = _data[ "branch" ]["history"][i]
        	_data[ "branch" ]["idIdx"][ v.q_taskid .. "" ] = i
        end
    end



    if _tempData.isFinished then

        --完成一个任务list数据变成history
        curData.isBegin = nil
        curData.isEnd = true
        local tagIdx = _data[ "branch" ]["idIdx"][ _tempData.id .. "" ]
        table.insert( _data[ "branch" ]["history"] , table.remove( _data[ "branch" ]["list"] ,tagIdx ) ) 
        tagIdx =  #_data[ "branch" ]["history"]
        _data[ "branch" ]["idIdx"][ _tempData.id .. "" ] = tagIdx

        --当前这个ID任务已经调入历史记录中 ， 取list中最后一个list任务做为最新任务（目的 刷新主界面左侧标签）
        -- local allIdx = #_data[ "branch" ]["list"]
        -- _data[ "branch" ]["newTask"] = _data[ "branch" ]["list"][allIdx] 

        local windTask = nil
        local branchTask = nil
        for k , v in ipairs( _data[ "branch" ]["list"] ) do
          if DATA_Mission:chechWing( v ) == 1 then
            branchTask = v
          else
            windTask = v
          end
        end
        _data[ "branch" ]["wing"] = windTask 
        _data[ "branch" ]["newTask"] = branchTask 
        
        resetIndex()
    end

    if _tempData.isFull then
      --预防后台特殊任务 不正常推送进度数据
      curData["targetData"] = curData["targetData"] or {}
      curData["targetData"].count = curData["targetData"].count or 1
      curData["targetData"].cur_num = curData["targetData"].count
    end

    if upcallbaces[ "branch_refresh" ] then upcallbaces[ "branch_refresh" ]() end --刷新界面回调
    if upcallbaces[ "main_flag" ] then upcallbaces[ "main_flag" ]() end --刷新界面回调
end

function DATA_Mission:setFindPath( _bool )
    if __TASK then
        __TASK.hunterFindPath = _bool
    end
    DATA_Mission.plotFindPath = true
end


function DATA_Mission:setShareData(_tempData)
	if not _data then
		return
	end

	_data["share"] = _tempData

	if _tempData == nil then
		return
	end

	-------------------------------------------------------

	local task_id = _tempData.id

	_data["share"].name = "task name"
	_data["share"].targetData = {}
	_data["share"].targetData.count = #_tempData.targetState
	_data["share"].targetData.cur_num = 0



	local taskdb_item = getConfigItemByKey("SharedTaskDB", "q_taskid", task_id);
	if taskdb_item then
		_data["share"].name = taskdb_item.q_name
		_data["share"].desc = taskdb_item.q_task_desc
        _data["share"].q_rank = taskdb_item.q_rank;

		local monsters = '{' .. taskdb_item.q_monsters .. '}'
		monsters = string.gsub(monsters, '%[', '%{')
		monsters = string.gsub(monsters, '%]', '%}')
		monsters = unserialize(monsters)

		_data["share"].posData = {}
        local taskTargetPos = _tempData.taskTargetPos
        if monsters then
		    for i = 1, #monsters do
			    _data["share"].posData[i] = {}
                _data["share"].posData[i].ID = monsters[i][1]
			    _data["share"].posData[i].map_id = taskTargetPos[i].mapid
			    _data["share"].posData[i].x = taskTargetPos[i].x
			    _data["share"].posData[i].y = taskTargetPos[i].y
		    end
        end

		---------------------------------------------------------

		_data["share"].targetCount = {}
		local cur_num = 0
		for i = 1, #_tempData.targetState do
			_data["share"].targetCount[i] = monsters[i][2]
			if _tempData.targetState[i] >= monsters[i][2] then
				cur_num = cur_num + 1
			end
		end
		_data["share"].targetData.cur_num = cur_num
	end

	-------------------------------------------------------

	if upcallbaces["share_refresh"] then upcallbaces["share_refresh"]() end		-- 刷新界面回调
	if upcallbaces["main_flag"] then upcallbaces["main_flag"]() end				-- 刷新界面回调
    if upcallbaces["map_checkDig"] then upcallbaces["map_checkDig"]() end	    -- 共享任务有可能是挖宝任务，需要检查是否弹出挖宝按钮回调
end

function DATA_Mission:getShareData()
	if not _data then
		return nil
	else
		return _data["share"]
	end
end

function DATA_Mission:updateShareData(task_id, state_data)
	if not _data then
		return
	end

	if not _data["share"] then
		return
	end

	for i = 1, #state_data do
		if _data["share"]["targetState"][i] == state_data[i] - 1 and state_data[i] == _data["share"].targetCount[i] then
			local map_id = _data["share"].posData[i].map_id
			local map_name = getConfigItemByKey("MapInfo", "q_map_id", map_id, "q_map_name")
			local hint_text = string.format(game.getStrByKey("treasure_monster_killed"), map_name)
			TIPS({type = 1, str = hint_text})

			if G_MAINSCENE then
				G_MAINSCENE:removeTaskDigIcon(map_id)
			end
		end

		_data["share"]["targetState"][i] = state_data[i]
	end

	-------------------------------------------------------


	if _data["share"].targetCount then
		local cur_num = 0
		for i = 1, #state_data do
			if state_data[i] >= _data["share"].targetCount[i] then
				cur_num = cur_num + 1
			end
		end
		_data["share"].targetData.cur_num = cur_num
	else
		local taskdb_item = getConfigItemByKey("SharedTaskDB", "q_taskid", task_id);
		if taskdb_item then
			_data["share"].name = taskdb_item.q_name
			_data["share"].desc = taskdb_item.q_task_desc

			local monsters = '{' .. taskdb_item.q_monsters .. '}'
			monsters = string.gsub(monsters, '%[', '%{')
			monsters = string.gsub(monsters, '%]', '%}')
			monsters = unserialize(monsters)

			---------------------------------------------------------

			_data["share"].targetCount = {}
			local cur_num = 0
			for i = 1, #state_data do
				_data["share"].targetCount[i] = monsters[i][2]
				if state_data[i] >= monsters[i][2] then
					cur_num = cur_num + 1
				end
			end
			_data["share"].targetData.cur_num = cur_num
		end
	end


	if upcallbaces["main_flag"] then upcallbaces["main_flag"]() end				-- 刷新界面回调
end

function DATA_Mission:deleteShareData(task_id)
	if not _data then
		return
	end

	if not _data["share"] then
		return
	end

--	if _data["share"].id ~= task_id then
--		return
--	end

	-------------------------------------------------------

	_data["share"] = nil

	if upcallbaces["main_flag"] then upcallbaces["main_flag"]() end				-- 刷新界面回调

	-------------------------------------------------------

	if G_MAINSCENE then
		G_MAINSCENE:removeTaskDigIcon()
	end

	if DATA_Mission then
		if DATA_Mission:getParent() then
			if DATA_Mission:getParent().refreshData then
				DATA_Mission:getParent():refreshData(2)
			end
		end
	end
end

function DATA_Mission:setShareData_Times(count_cur, count_max)

	local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
	if ILevel == nil or ILevel < 30 then
		return
	end

	if count_cur < count_max then
		if DATA_Battle then
			DATA_Battle:setRedData("teamTreasure", true, false)
		end


--		local buttonFunc = function()
--			__GotoTarget({ru = "a162"})
--		end

--		if G_MAINSCENE then
--			G_MAINSCENE:createActivityIconData({priority= 20,
--    							btnResName  = "res/mainui/subbtns/teamTreasure.png",
--    							btnResLab   = game.getStrByKey("treasure_ancient"),
--    							btnCallBack = buttonFunc,
--    							btnRemoveTime = 30,
--    							btnZorder = 100})
--		end
	end

end

--设置任务最后追踪的怪物或采集物（ 主线 ，有效的昭令，密令，共享 ），目标不包含对话的NPC
function DATA_Mission:setLastTarget( _tempData )
-- LUA-print] - "<var>" = {
-- LUA-print] -     "taskType" = 6
-- LUA-print] -     "id"    = 10151
-- LUA-print] -     "mapid" = 3100
-- LUA-print] -     "pos" = {
-- LUA-print] -         "x" = "128"
-- LUA-print] -         "y" = "93"
-- LUA-print] -     }
-- LUA-print] - }
  if _data then
    _data["lastTarget"] = _tempData
  end
end

function DATA_Mission:getLastTarget()
    return _data["lastTarget"]
end

--检测使用任务目标(这个方法对任务53无效了，但不确定对57是否还有用，先留着，等配置了57类型的任务，再确定是否删除16.7.8)
function DATA_Mission:checkUseTag( flag , _id )
    local isUseTag = false 

    -- local plotData = DATA_Mission:getLastTaskData()
    -- local tag = plotData.targetData
    -- if tag and tag.usePropType and tag.usePropType == flag and _id == tag.ID then
    --     -- isUseTag = true
    --     -- if __TASK then __TASK:findPath( plotData ) end
    -- end

    return isUseTag
end


function DATA_Mission:ClearShareTask()
    local data = self:getShareData();
    if data and data.flag == 0 then -- 队员的共享任务
        if __TASK then
			__TASK:popupLayout("plot")
		end

        self:deleteShareData(0)
	    print("[MissionNetMsg:ClearShareTask]")
    end
end

--返回密令用到的道具
function DATA_Mission:getBranchPropID()
  return _data[ "branchPropID" ] 
end

return DATA_Mission