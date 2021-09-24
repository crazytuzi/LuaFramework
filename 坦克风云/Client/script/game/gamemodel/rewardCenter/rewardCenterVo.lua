rewardCenterVo={}
function rewardCenterVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.flag=1--领取标记，1是可以领取，2是已经领取，3已经过期
    self.testid=0
    return nc
end

-- data：json数据，testid，测试id,没实际作用
function rewardCenterVo:initWithData(data,testid)
    if testid then
        self.testid=testid
    end

    -- 奖励的id
	if self.id == nil then
        self.id = 0
    end
    if data.id ~= nil then
        self.id = data.id
    end
    -- 奖励类型 {ac = '活动',sys = '系统',ed = '轮回','gm' = '管理工具'}
    -- sw超级武器,pw跨平台战
	if self.rtype == nil then
        self.rtype = ""
    end
    if data.type ~= nil then
        self.rtype = data.type
    end
    -- 用户id
	if self.uid == nil then
        self.uid = 0
    end
    if data.uid ~= nil then
        self.uid = data.uid
    end
    -- 类型为gm时，为纯文字,直接显示，ac：表示活动id， 其他类型为英文
	if self.title == nil then
        self.title = ""
    end
    if data.title ~= nil then
        self.title = data.title
    end
    -- 领取开始时间
	if self.st == nil then
        self.st = 0
    end
    if data.st ~= nil then
        self.st = tonumber(data.st)
    end
    -- 领取过期时间
	if self.et == nil then
        self.et = 0
    end
    if data.et ~= nil then
        self.et = tonumber(data.et)
    end
    -- 描述，table 类型 内容根据type不同而变化
	if self.info == nil then
        self.info = {}
    end
    if data.info ~= nil then--不是json格式，所以需要特殊处理
        self.info = G_Json.decode(data.info)
    end
    -- 奖励列表
	if self.reward == nil then
        self.reward = {}
    end
    if data.reward ~= nil then
        self.reward = data.reward
    end
    -- r:默认代表是排行的意思，具体根据实际活动或者功能来确定
	if self.r == nil then
        self.r = 0
    end
    if self.info ~= nil and self.info.r~=nil then
        self.r = tonumber(self.info.r)
    end
    -- v:ac中代表活动版本，其他系统或者gm中，暂时不会用到
    if self.v == nil then
        self.v = 0
    end
    if self.info ~= nil and self.info.v~=nil then
        self.v = tonumber(self.info.v)
    end
    -- G_dayin(self.info)
end

function rewardCenterVo:getId()
    return self.id
end

-- 设置过期时间
function rewardCenterVo:setFlag(flag)
    self.flag=flag
end

-- 是否已经过期
function rewardCenterVo:isExpire()
    if base.serverTime>tonumber(self.et) then
        return true
    end
    return false
end

-- 活动奖励标题
function rewardCenterVo:getRewardTitleStr()
    -- cn2.lua中先不添加
    -- rewardCenterType_GM="系统奖励",
    -- rewardCenterType_SYS="系统奖励",
    local title = ""
    if self.rtype=="sys" then
        title = getlocal("rewardCenterType_SYS")
    elseif self.rtype=="gm" then
        title = self.title
    elseif self.rtype=="ac" then
  
        if self.title=="kzhd" then
            title = getlocal("activity_reward",{getlocal("activity_"..self.title.."_title")})
        else
            title = getlocal("activity_"..self.title.."_title")
        end
        if self.title == "ttjj" then
            title = getlocal("activity_"..self.title.."_rewardCenter")
        end
        if self.title == "hljb" or self.title == "hryx" then
            title = getlocal("activity_"..self.title.."_rc_title")
        end

        if self.title == "czhk1" or self.title == "czhk2" or self.title == "czhk" then
            title = getlocal("activity_czhk_rc_title")
        end
        
        if self.title =="znjl" and self.info.v and tonumber(self.info.v) == 2 then
            title = getlocal("active_znsd_title")
        end
        if string.sub(self.title,1,4) == "xcjh"  then
            -- 新春聚惠特殊处理
            if self.v == 2 then
                title = getlocal("activity_xcjh_title_v2")
            else
                title = getlocal("activity_"..string.sub(self.title,1,4).."_title")
            end
        end
    elseif self.rtype=="exewar" then --跨服联合演习
        local key = Split(self.title,"_")[1]
        title = getlocal("rewardcenter_"..self.rtype.."_"..key.."_title")
    else
        -- 通用的标题格式：rewardcenter_self.rtype_self.title_title
        title = getlocal("rewardcenter_"..self.rtype.."_"..self.title.."_title")
    end
    return title
end

-- 获取奖励描述
function rewardCenterVo:getRewardDescStr()
    -- cn2.lua中先不添加
    -- rewardCenter_ac_common_desc="恭喜您在【{1}】中，获得了第{2}名，特发以下奖励：",
    local desc = ""
    if self.rtype=="gm" then
        if self.info.desc then
            desc = self.info.desc
        end
    elseif self.rtype=="ac" then
        -- todo   根据具体的活动，来做判断
        if self.title=="" then--如果某个活动比较特殊，可以在这里特殊处理下
        elseif self.title=="gwkhd" then
            local total = self.info["gear"]
            desc = getlocal("activity_gwkhd_rc_desc",{total})
        elseif self.title=="gwkha" then
            local cost = self.info["cost"]
            local needday = self.info["needday"]
            if cost==1 then
                desc = getlocal("activity_gwkha_rc_desc1",{needday})
            else
                desc = getlocal("activity_gwkha_rc_desc2",{needday,cost})
            end
        elseif string.sub(self.title,1,4) == "xcjh" then
            -- 新春聚惠特殊处理
            local acName = ""
            if self.v == 2 then
                acName = getlocal("activity_xcjh_title_v2")
            else
                acName = getlocal("activity_"..string.sub(self.title,1,4).."_title")
            end
            if self.r then
                rank=self.r
                local num = 5
                local index = num - rank +1
                local rankStr = getlocal("reward_title_"..index)

                desc=getlocal("rewardCenter_xcjh_desc",{acName,rankStr})
            end
        else
            -- 这里是走通用活动排名的
            local acName = getlocal("activity_"..self.title.."_title")    
            local rank = 1
            if self.r > 0 then
                rank=self.r
                desc=getlocal("rewardCenter_ac_common_desc",{acName,rank})
            else
                if self.title == "smcjt" or self.title == "smcjp" then
                    require "luascript/script/game/gamemodel/activity/acSmcjVo"
                    require "luascript/script/game/gamemodel/activity/acSmcjVoApi"
                elseif self.title == "hljb" then
                    require "luascript/script/game/gamemodel/activity/acHljbVo"
                    require "luascript/script/game/gamemodel/activity/acHljbVoApi"
                end

                if self.info.action and self.title=="kzhd" then
                    desc=getlocal("activity_kzhd_reward_des",{getlocal("new_task_type_" .. self.info.action)})
                elseif self.info.n and self.title=="kfcz_day" or self.title=="jtxlh" then
                    desc=getlocal("activity_"..self.title.."_rc_desc",{self.info.n})
                elseif self.title == "hljb" then
                    desc=getlocal("activity_"..self.title.."_rc_desc",{self.info.point})
                elseif self.title == "smcjt" then
                    local id = self.info.currDay
                    local idx = acSmcjVoApi:getTaskIdx(id,self.info.tkey )
                    local tId = self.info.tid
                    taskData = acSmcjVoApi:getDailyTaskList(id)

                    local curTaskKey = self.info.tkey--acSmcjVoApi:getTaskKey(self.id,idx)
                    local curTaskUseIdx = SizeOfTable(taskData["t"..idx])
                    local needNum = taskData["t"..idx][curTaskUseIdx].needNum
                    local curFinshNum = taskData["t"..idx][tId].needNum
                    local key = self.info.tkey == "gb" and  "gba" or self.info.tkey
                    local score = self.info.point or 0
                    local insideDesc = getlocal("activity_chunjiepansheng_"..key.."_title", {curFinshNum,needNum})
                    if key == "hy" or key == "hya" then
                        insideDesc = getlocal("activity_smcz_hy_title", {curFinshNum, needNum})
                    end
                    desc = getlocal("activity_smcjt_desc",{insideDesc , score})

                elseif self.title == "smcjp" then
                    local socreCurNeed = acSmcjVoApi:getScoreReward(tonumber(self.info.pid)).needScore
                    desc=getlocal("activity_"..self.title.."_desc",{socreCurNeed})
                elseif self.title == "smcjg" then
                    local goldNum = self.info.gnum
                    desc=getlocal("activity_"..self.title.."_desc",{goldNum})
                elseif self.title == "czhk1" or self.title == "czhk2" or self.title == "czhk" then
                    if self.info.d then
                        desc = getlocal("activity_czhk_rc2",{self.info.d,self.info.n})
                    else
                        desc = getlocal("activity_czhk_rc1",{self.info.n})
                    end
                elseif self.title =="znjl" and self.info.v and tonumber(self.info.v) == 2 then
                    desc = getlocal("activity_znsd_rc_desc")
                else
                    desc=getlocal("activity_"..self.title.."_rc_desc")
                    if self.title == "ttjj" then
                        desc=getlocal("activity_"..self.title.."_desc",{self.reward.u.gems})
                    elseif self.title=="ydcz" then
                        desc=getlocal("activity_"..self.title.."_rc_desc",{getlocal("month_name"..(self.info.month or 1)),(self.info.recharge or 0)})
                    end
                end   
                
            end
        end
    --usw是异元战场，self.r是生存回合数
    elseif self.rtype=="sky" or self.rtype=="usw" then
        desc = getlocal("rewardcenter_"..self.rtype.."_"..self.title.."_desc",{self.r})  
    elseif self.rtype == "lt" then
        -- 限时任务积分奖励
        if self.title == "npoint" or self.title == "hpoint" then
            desc = getlocal("rewardcenter_"..self.rtype.."_"..self.title.."_desc",{self.info.point})
        -- 限时挑战排行榜奖励
        else
            desc = getlocal("rewardcenter_"..self.rtype.."_"..self.title.."_desc",{self.info.rank})
        end  
    elseif self.rtype=="rf" then
        desc = getlocal("rewardcenter_"..self.rtype.."_"..self.title.."_desc",{self.info.lvl})
    elseif self.rtype=="exewar" then --跨服联合演习
        local key = Split(self.title,"_")[1]
        local args = {}
        if key == "rank" then
            args = {self.info.rank}
        end
        desc = getlocal("rewardcenter_"..self.rtype.."_"..key.."_desc",args)
    else
         -- 通用的描述格式：rewardcenter_self.rtype_self.title_desc
        desc = getlocal("rewardcenter_"..self.rtype.."_"..self.title.."_desc")
    end
    return desc
end

-- 奖励发放的时间描述
function rewardCenterVo:getSendRewardTimeStr()
    if G_isGermany()==true then
       return  G_getDataTimeStr(self.st,nil,nil,true)
    else
       return  G_getDataTimeStr(self.st)
    end
end

-- 奖励过期的描述
function rewardCenterVo:getExpireTimeStr()
    if G_isGermany()==true then
        return  G_getDataTimeStr(self.et,nil,nil,true)
    else
        return  G_getDataTimeStr(self.et)
    end
end


function rewardCenterVo:getIdStr( ... )
    local arr = self.id
end




