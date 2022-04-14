---
--- Created by  Administrator
--- DateTime: 2019/4/1 19:15
---
AchieveModel = AchieveModel or class("AchieveModel", BaseBagModel)
local AchieveModel = AchieveModel

function AchieveModel:ctor()
    AchieveModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function AchieveModel:Reset()
    self.achieveList = {}
    self.stateList = {}
end

function AchieveModel:GetInstance()
    if AchieveModel.Instance == nil then
        AchieveModel()
    end
    return AchieveModel.Instance
end

function AchieveModel:GetChievesTab(data)
    for i = 1, #data.achieves do
        local id  = data.achieves[i].id
        self.achieveList[id] = data.achieves[i]
    end
    --if table.isempty(self.achieveList) then
    --    self.achieveList = data.achieves
    --    return
    --end
    --for i = 1, #data.achieves do
    --    local id = data.achieves[i].id
    --    for j = 1, #self.achieveList do
    --        if self.achieveList[j].id == id then
    --            self.achieveList[j] = data.achieves[i]
    --        else
    --            table.insert(self.achieveList,data.achieves[i])
    --        end
    --    end
    --    --self.stateList[i] = data.achieves
    --end
   -- dump(self.achieveList)
end


--function AchieveModel:GetAchieveInfo(data)
--    local itemList = data.achieves
--    for i, v in pairs(itemList) do
--
--    end
--end

function AchieveModel:GetAchieveByGroupAndPage(group,page)
    local cfg = Config.db_achieve
    local items = {}
    local index = 0
    for i, item in pairs(cfg) do
        if item.group == group and item.page == page then
            index = index + 1
            local tab = {}
            tab["id"] = item.id
            tab["num"] = 0
            local state =  self:SwitchState(3)
            tab["state"] = state
          --  table.insert(items,tab)
            items[index] = tab
        end
    end
    if not table.isempty(self.achieveList) then
        for i, v in pairs(self.achieveList) do
            if Config.db_achieve[v.id].group == group and Config.db_achieve[v.id].page == page  then
                for j = 1, #items do
                    if v.id == items[j].id then
                        local tab = {}
                        tab["id"] = v.id
                        tab["num"] = v.num
                        local state = self:SwitchState(v.state)
                        tab["state"] = state
                        items[j] = tab
                    end
                end
            end
        end
    end
    table.sort(items,
    function (a,b)
       -- return a.id < b.id
        local r
        if a.state == b.state then
            r = a.id < b.id
        else
            r = a.state < b.state
        end
        return r
    end)
    return items
end
function AchieveModel:GetAchieveTab(group,page)
    local cfg = Config.db_achieve
    local items = {}
    local index = 0
    for i, v in pairs(cfg) do
        if v.group == group and v.page == page then
            index = index + 1
            local tab = {}
            tab["id"] = v.id
            tab["num"] = 0
            tab["state"] = 3
            --  table.insert(items,tab)
            items[index] = tab
        end
    end
    return items
end

function AchieveModel:SwitchState(state)
    local num = 0
    if state == 1 then
        num = 1
    elseif state == 2 then
        num = 3
    else
        num = 2
    end
    return num
end

function AchieveModel:GetCumulativeTab()
    
end

--
function AchieveModel:GetAllPointByGroup(group)
    local cfg = Config.db_achieve
    local point = 0
    for i, v in pairs(cfg) do
        if  v.group ~= 1 then
            if v.group == group then
                point = point + v.point
            end
        end
    end
    return point
end

function AchieveModel:GetOnePointByGroup(group)
    local point = 0
    for i, v in pairs(self.achieveList) do
        local cfg = Config.db_achieve[v.id]
        if v.state == 2 or v.state == 1 then --已经领取了
            if cfg.group ~= 1  then
                if cfg.group == group then
                    point = point + cfg.point
                end
            end
        end
    end
    return point
end

function AchieveModel:GetAllPoint()
    local cfg = Config.db_achieve
    local index = 0
    for i, v in pairs(cfg) do
        if v.group ~= 1 then
            index = index + v.point
        end
    end
    return index
end
function AchieveModel:GetCurPoint()
    local point = 0
    for i, v in pairs(self.achieveList) do
        local cfg = Config.db_achieve[v.id]
        if cfg.group ~= 1 then
            if v.state == 2 or v.state == 1 then
                point = point + cfg.point
            end
        end
    end
    return point
end

--获取每个小类的成就数量
function AchieveModel:GetTypeNums(group,page)
    local cfg = Config.db_achieve
    local index = 0
    for i, v in pairs(cfg) do
        if v.group == group and v.page == page then
            index = index + 1
        end
    end
    return index
end
--每个小类已领的数量
function AchieveModel:GetTypeReceiveNums(group,page)
    local index = 0
    for i, v in pairs(self.achieveList) do
        local cfg = Config.db_achieve[v.id]
        if cfg.group == group and cfg.page == page then
            if v.state == 2 then
                index = index + 1
            end
        end
    end
    return index
end

function AchieveModel:CheckRedPointByGroup(group)
    local isRed = false
    for i, v in pairs(self.achieveList) do
        if v.state == 1 then
            local groupId = Config.db_achieve[i].group
            if groupId == group then
                isRed = true
                break
            end
        end
    end
    return isRed
end

function AchieveModel:CheckRedPoint(group,page)
    local isRed = false
    for i, v in pairs(self.achieveList) do
        if v.state == 1 then
            local groupId = Config.db_achieve[i].group
            local pageId = Config.db_achieve[i].page
            if group == groupId and page == pageId then
                isRed = true
                break
            end
        end
    end
    return isRed
end

function AchieveModel:GetGroupAndPage()
    local group = 1
    local page = 1
   -- pairsByKey
   -- for i = 1, #groupCfg do
   --     for j = 1, #pageCfg do
   --         local groupId = groupCfg[i].id
   --         if groupId == pageCfg[j].group then
   --             local items =  self:GetAchieveByGroupAndPage(groupId,pageCfg[j].id)
   --             for z = 1, #items do
   --                 if items[z].state == 1 then
   --                     group = groupId
   --                     page = pageCfg[j].id
   --                     return group ,page
   --                 end
   --             end
   --         end
   --     end
   -- end
   -- if table.isempty(self.achieveList) then
   --     return group,page
   -- end
    local cfg = table.pairsByKey(self.achieveList)
    for i, v in cfg do
        if v.state == 1 then
            local cf = Config.db_achieve[i]
            group = cf.group
            page = cf.page
            break
        end
    end
    return group,page
end

--当前页是否有奖励
function AchieveModel:isRewardByGroupAndPage(group,page)
    local isReward = false
    local items = self:GetAchieveByGroupAndPage(group,page)
    for i = 1, #items do
        if items[i].state == 1 then
            isReward = true
            break
        end
    end
    return isReward

end
