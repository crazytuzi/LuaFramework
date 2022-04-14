FactionEscortModel = FactionEscortModel or class("FactionEscortModel",BaseBagModel)

function FactionEscortModel:ctor()
    FactionEscortModel.Instance = self


    self:Reset()
   -- self:StartCountDown()
end

function FactionEscortModel:Test()
    
end

function FactionEscortModel:Reset()

    self.isEscorting = false --是否在护送中
    self.progress = 0 --护送进度
    self.isDouble = false --是否在双倍时间内
    self.isLong = false -- 是否达到龙级
    self.startDoubleTime  = nil
    self.endDoubleTime = nil
    self.itemQua = 0
    self.escortCount = 0
    self.refreshCount = 0
    self.escortEndTime = 0 --护送结束时间
    self.escortResTime = 0 --护送剩余时间

    self.buyBox = false
    self.lvBox = false
end

function FactionEscortModel.GetInstance()
    if FactionEscortModel.Instance == nil then
        FactionEscortModel()
    end
    return FactionEscortModel.Instance
end


function FactionEscortModel:dctor()
    if self.timeDown then
        GlobalSchedule:Stop(self.timeDown)
        self.timeDown = nil
    end
end




function FactionEscortModel:IsShowEscort()
	local role = RoleInfoModel.GetInstance():GetMainRoleData()
	if role.level < 130 then
		return false
	end
	local db = Config.db_escort[1]
	local aTimes = db.attend
	if aTimes - self.escortCount <=  0 then
		return false
	end
	return  true
	--self.todayTimes.text = string.format("今天次数：<color=#%s>%s/%s</color>","2E870F",aTimes - self.model.escortCount,aTimes)
	
end

function FactionEscortModel:StartCountDown()
    self.timeDown = GlobalSchedule:Start(handler(self, self.StartTimeConutDown),1.0)
end
function FactionEscortModel:StartTimeConutDown()
    local curTime = TimeManager:GetServerTime()
    curTime = curTime + 1
    --local sysKey = "400".."@".."1"
    --local sysdb = Config.db_sysopen[sysKey]
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    if role.level < 130 then
        return
    end
    --if self:CheckIsDouble(curTime) and self.isDouble == false then  --在双倍时间
    --    self.isDouble = true
    --
    --   -- GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"escort",true,300,curTime,self.endDoubleTime)
    --
    --end
    --if  self:CheckIsDouble(curTime) == false and self.isDouble == true then
    --    self.isDouble = false
    --   -- GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"escort",false,curTime,self.endDoubleTime)
    --end
end

--检查是否在双倍时间内
function FactionEscortModel:CheckIsDouble()
    local db1 = Config.db_activity[10101]  --护送中午
    local tab = String2Table(db1.time)
  --  local db2 = Config.db_activity[10102]  --晚上
  --  local startTime1 = String2Table(db1.start_time)
  --  local endTime1 =  String2Table(db1.stop_time)
  --  local startTime2 = String2Table(db2.start_time)
  --  local endTime2=  String2Table(db2.stop_time)
    local startTime1 = tab[1][1]
    local endTime1 = tab[1][2]
    local startTime2 = tab[2][1]
    local endTime2=  tab[2][2]
    local sTime1 =  TimeManager:GetStampByHMS(startTime1[1],startTime1[2],startTime1[3]) --开始时间
    local eTime1 =  TimeManager:GetStampByHMS(endTime1[1],endTime1[2],endTime1[3]) --结束时间
    local sTime2 =  TimeManager:GetStampByHMS(startTime2[1],startTime2[2],startTime2[3]) --开始时间
    local eTime2 =  TimeManager:GetStampByHMS(endTime2[1],endTime2[2],endTime2[3]) --结束时间
    if TimeManager:GetServerTime() > tonumber(sTime1) and  TimeManager:GetServerTime() < tonumber(eTime1) then
                 self.startDoubleTime = sTime
                 self.endDoubleTime = eTime
                 return true
    end
    if TimeManager:GetServerTime() > tonumber(sTime2) and  TimeManager:GetServerTime() < tonumber(eTime2) then
        self.startDoubleTime = sTime
        self.endDoubleTime = eTime
        return true
    end
    return false
end
--是否是护送NPC
function FactionEscortModel:IsEscortNpc(npcId)
    --local sysKey = "400".."@".."1"
    --local sysdb = Config.db_sysopen[sysKey]
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    if role.level < 130 then
        return false
    end
    local db = Config.db_escort_road
    local npcDB = Config.db_npc
    local startId = db[1].start
    local secondId = db[1].second
    local endId = db[1].end_npc
   -- print2(startId,secondId,endId)
   -- if self.isEscorting then  -- 护送中
   --
   -- else
   --
   -- end
    if npcId == startId and not self.isEscorting  then
        GlobalEvent:Brocast(FactionEscortEvent.FactionEscortNpcPanel,npcId,1)
        return true
    end
    if npcId == secondId and self.isEscorting and self.progress == 0 then  --中间使者，护送中点击才有作用  之后要加进度限制
        GlobalEvent:Brocast(FactionEscortEvent.FactionEscortNpcPanel,npcId,2)
        return true
    end

    if npcId == endId and self.isEscorting and self.progress == 1  then   --交任务Npc 护送中点击才有作用  之后要加进度限制
        GlobalEvent:Brocast(FactionEscortEvent.FactionEscortNpcPanel,npcId,3)
        return true
    end
    return false
end

function FactionEscortModel:IsMaxLv()  --是否到达最高等级
    if self.itemQua == 4 then
        return true
    end
    return false
end

function FactionEscortModel:GetEscQua()
    local level  = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local key = self.itemQua.."@"..level
    local cfg = Config.db_escort_product[key]
    if not cfg  or  self.isEscorting == false then
        return nil
    end
    return self.itemQua,cfg.name
end

function FactionEscortModel:DoubleStartText()
    local db1 = Config.db_activity[10101]  --护送中午
    local tab = String2Table(db1.time)
  --  local db2 = Config.db_activity[10102]  --晚上
  --  local startTime1 = String2Table(db1.start_time)
 --   local startTime2 = String2Table(db2.start_time)
    local startTime1 = tab[1][1]
    local startTime2 = tab[2][1]
    local str1 = tostring(startTime1[1])
    local str2 = tostring(startTime1[2])
    local str3 = tostring(startTime2[1])
    local str4 = tostring(startTime2[2])
    if str1 == "0" then
        str1 = "00"
    end
    if str2 == "0" then
        str2 = "00"
    end
    if str3 == "0" then
        str3 = "00"
    end
    if str4 == "0" then
        str4 = "00"
    end
    return str1,str2,str3,str4
end

function FactionEscortModel:DoubleEndText()
    local db1 = Config.db_activity[10101]  --护送中午
    local tab = String2Table(db1.time)
    --local db2 = Config.db_activity[10102]  --晚上
    --local endTime1 = String2Table(db1.stop_time)
    --local endTime2 = String2Table(db2.stop_time)
    local endTime1 = tab[1][2]
    local endTime2 = tab[2][2]
    local str1 = tostring(endTime1[1])
    local str2 = tostring(endTime1[2])
    local str3 = tostring(endTime2[1])
    local str4 = tostring(endTime2[2])
    if str1 == "0" then
        str1 = "00"
    end
    if str2 == "0" then
        str2 = "00"
    end
    if str3 == "0" then
        str3 = "00"
    end
    if str4 == "0" then
        str4 = "00"
    end
    return str1,str2,str3,str4
end

function FactionEscortModel:GoNpc()
    -- if self.isEscorting then
    --     local db = Config.db_escort_road
    --     local npcDB = Config.db_npc
    --     local main_role = SceneManager:GetInstance():GetMainRole()
    --     local start_pos = main_role:GetPosition()
    --     -- local sceneID = npcDB[start].scene
    --     if self.progress == 0 then  --未到中间使者
    --         local second = db[1].second
    --         local sceneId = npcDB[second].scene
    --         local endPos =  SceneConfigManager:GetInstance():GetNpcPosition(sceneId,second)
    --         function callback()
    --             local npc_object = SceneManager:GetInstance():GetObject(second)
    --             if npc_object then
    --                 npc_object:OnClick()
    --             end
    --         end
    --         OperationManager:GetInstance():TryMoveToPosition(sceneId,start_pos,endPos,callback)
    --     else
    --         local endId = db[1].end_npc
    --         local sceneId = npcDB[endId].scene
    --         local endPos =  SceneConfigManager:GetInstance():GetNpcPosition(sceneId,endId)
    --         function callback()
    --             local npc_object = SceneManager:GetInstance():GetObject(endId)
    --             if npc_object then
    --                 npc_object:OnClick()
    --             end
    --         end
    --         OperationManager:GetInstance():TryMoveToPosition(sceneId,start_pos,endPos,callback)
    --     end
    -- end
    local npc_id = self:GetNpc()
    if npc_id then
        SceneManager:GetInstance():FindNpc(npc_id)
    end
end

function FactionEscortModel:GetNpc()
    if not self.isEscorting then
        return nil
    end
    local cf = Config.db_escort_road[1]
    return self.progress == 0 and cf.second or cf.end_npc
end

function FactionEscortModel:UpdateBuff()
    local buff = Config.db_buff[130140011]
    if buff then

    end
end

function FactionEscortModel:GetQuaByBuff(buffs)
    local escort_lv_tab = {
        [130150011] = 1,
        [130150012] = 2,
        [130150013] = 3,
        [130150014] = 4,
    }
    for i, v in pairs(buffs) do
        if escort_lv_tab[v.id] then
            return escort_lv_tab[v.id]
        end
    end
    return nil

end






