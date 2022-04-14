---
--- Created by  Administrator
--- DateTime: 2019/2/20 16:29
---
SelectServerModel = SelectServerModel or class("SelectServerModel", BaseModel)
local SelectServerModel = SelectServerModel

function SelectServerModel:ctor()
    SelectServerModel.Instance = self
    self:Reset()

end

--- 初始化或重置
function SelectServerModel:Reset()
    self.servers = {}
    self.sortServers = {} --排序好的服务器
    self.recent = {}
    self.serverData = {}
    self.curSer = nil
end

function SelectServerModel:GetInstance()
    if SelectServerModel.Instance == nil then
        SelectServerModel()
    end
    return SelectServerModel.Instance
end

function SelectServerModel:SpiltServerList(list)
    dump(list)
    self.serverData = list
    self.sortServers = {}
    self.sortServers[1] = {}
    self.sortServers[2] = {}
    self.servers = list.servers
    self.recent = list.recent
    if not table.isempty(self.recent) then
        table.sort(self.recent, function(a,b)
           return a.login > b.login
        end)
    end
    --dump(self.recent)
    local len = #list.servers   --服务器个数
    for i = #list.servers ,1,-1  do
        local num1,num2 = math.modf(i / 100)
        local leftItemNum = 0
        if num2 > 0 then
            leftItemNum = num1 + 3
        else
            leftItemNum = num1 + 2
        end
        self.sortServers[leftItemNum] = self.sortServers[leftItemNum] or {}
        table.insert(self.sortServers[leftItemNum],list.servers[i])
        if list.servers[i].flag == 2 then
            table.insert(self.sortServers[1],list.servers[i])
        end
        local isLatelySer,latelyTab = self:IsLatelySer(list.servers[i].sid)
        if isLatelySer then
            table.insert(self.sortServers[2],list.servers[i])
        end
    end
    if table.isempty(self.recent) then  --没有服务器有角色信息
        self.curSer = self.servers[#self.servers]
    else
        self.curSer = self:GetLateSerMaxTime() or self.servers[#self.servers]
    end
end

--得到推荐服务器
function SelectServerModel:GetRecommendSer()
    local tab = {}
    for i = 1, #self.servers do
        if self.servers.flag == 2 then  --推荐
            table.insert(tab,self.servers[i])
        end
    end
    return tab
end



---是否是最近登陆过的服务器
function SelectServerModel:IsLatelySer(sid)
    local latelyTab = {}
    for i = 1, #self.recent do
        if sid == self.recent[i].sid then
            latelyTab = self.recent[i]
            return true , latelyTab
        end
    end
    return false,latelyTab
    --if table.isempty(self.recent) then
    --    return false,nil
    --end
    --local latelyTab = {}
    --if sid == self.recent[1].sid then
    --    latelyTab = self.recent[1]
    --    return true , latelyTab
    --end
    --return false,latelyTab
end

function SelectServerModel:GetLateSerMaxTime()
    --if table.isempty(self.recent) then
    --    return false,nil
    --end
    --local latelyTab = {}
    --if ser.sid == self.recent[1].sid then
    --    latelyTab = self.recent[1]
    --    return true , latelyTab
    --end
    --return false,latelyTab

    for i, v in pairs(self.sortServers[2]) do
        if v.sid == self.recent[1].sid  then
            return v
        end
    end
    return nil
end



function SelectServerModel:GetServerData()
    return self.serverData
end

function SelectServerModel:GetGamechanState()
    local state = 0
    if self.serverData.gamechan_state == 1 then
        state = 1
    end
    return state
end


function SelectServerModel:GetServerState(server)
    --self.serverData
    local flag = 0
    local data = self.serverData
    if data.gamechan_state == 1  then
        flag = server.flag
    end
    return flag
end