-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛的数据控制
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionModel = ArenaChampionModel or BaseClass()

function ArenaChampionModel:__init()
    self.arena_champion_red_list = {}
end 

--==============================--
--desc:更新冠军赛基础信息数据
--time:2018-08-03 06:03:18
--@data:
--@return 
--==============================--
function ArenaChampionModel:updateChampionBaseInfo(data)
    self.base_info = data

    -- if (step == 0 or step == 1) and step_status == 0 then
    --         print("冠军赛未开始")
    -- elseif rank == 0 then
    --         print("没有资格")
    -- else 
    --     print("展示PK信息")
    -- end
    -- 如果收到 50 
    -- if flag == 0 then
    --     print("不需要重新请求当前UI数据")
    -- elseif flag == 1 then
    --     print("重新请求当前UI数据信息")
    -- elseif flag == 2 then
    --     print("重新请求当前UI数据信息, 如果是PK信息界面，数据返回后判断阶段和回合是否相同进入观战")
    -- end

    -- , {uint32, start_time,			"赛季开始时间(unixtime)"}
    -- , {uint32, end_time,			"赛季结束时间(unixtime)"}
    -- , {uint8, step,				"赛程阶段(0:未,1:选拔赛,32:32强,4:4强)"}
    -- , {uint8, step_status,			"阶段状态(0:未到时间 1:进行中 2:结束)"}
    -- , {uint32, step_status_time,	"阶段距离开始/结束时间(unixtime)"}
    -- , {uint8, round,				"回合"}
    -- , {uint8, round_status,		"回合状态(1:准备 2:竞猜 3:对战)"}
    -- , {uint8, round_status_time,	"回合状态时间"}
    -- , {uint8, flag,				"是否更新当前UI信息(0:不需要 1:需要 2:更新UI并请求观看录像)"} 
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionBaseInfoEvent, data)
end

--==============================--
--desc:红点状态
--time:2018-07-24 10:06:06
--@type:
--@status:
--@return 
--==============================--
-- function ArenaChampionModel:updateArenaRedStatus(type, status)
-- 	local _status = self.arena_champion_red_list[type]
-- 	if _status == status then return end
-- 	self.arena_champion_red_list[type] = status
-- 	-- 更新场景红点状态
-- 	MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.arena, {bid = type, status = status})
-- 	-- 事件用于同步更新公会主ui的红点
-- 	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateArenaRedStatus, type, status)
-- end 

--==============================--
--desc:基础数据
--time:2018-08-03 06:05:00
--@return 
--==============================--
function ArenaChampionModel:getBaseInfo()
    return self.base_info
end

--==============================--
--desc:个人基础信息
--time:2018-08-03 06:19:51
--@return 
--==============================--
function ArenaChampionModel:getRoleInfo()
    return self.role_info 
end

--==============================--
--desc:获取我的竞赛状态
--time:2018-08-04 10:50:29
--@return 
--==============================--
function ArenaChampionModel:getMyMatchStatus()
    if self.base_info and self.role_info then
        if self.base_info.step == ArenaConst.champion_step.unopened then
            return ArenaConst.champion_my_status.unopened
        elseif self.base_info.step == ArenaConst.champion_step.score and self.base_info.step_status == ArenaConst.champion_step_status.unopened then
            return ArenaConst.champion_my_status.unopened
        elseif self.role_info.rank == 0 then
            return ArenaConst.champion_my_status.unjoin
        else
            return ArenaConst.champion_my_status.in_match
        end 
    end
    return ArenaConst.champion_my_status.unopened
end

--==============================--
--desc:设置个人的基础信息
--time:2018-08-03 06:19:19
--@data:
--@return 
--==============================--
function ArenaChampionModel:setRoleInfo(data)
    self.role_info = data
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionRoleInfoEvent, data)
end