serverMgr = {
    serverPageList = {},
    pageShowServerList = {},
    kyServerList = {},
}

--获取所有服务器的列表
function serverMgr:getServerList()
    
end

function serverMgr:init()
    if self.f_init ~= true then
        self:isPageShow()
        self.serverPageList = {}
        local allserver = {}
        local svrcfg = G_clone(serverCfg.allserver)
        for k, v in pairs(svrcfg) do
            allserver = v
        end
        if self.f_pageShow == true then
            self.hasMs = false
            self.perPageNum = 20
            local isYueyu = false
            if allserver and next(allserver) then
                --越狱快用601服想要单独处理，拉出一个页签来
                local memoryServerList = {}
                local kyServerNum, memoryServerNum,totalNum = 0, 0,0
                if(string.find(serverCfg.svrCfgUrl, "tank-fl-yueyu.raysns.com", 1, true) ~= nil or string.find(serverCfg.svrCfgUrl, "tank-ky-cn.raysns.com", 1, true) ~= nil)then
                    self.kyServerList = {}
                    isYueyu = true
                end
                for k, v in pairs(allserver) do
                    local zoneid
                    if v.oldzoneid and tonumber(v.oldzoneid) and tonumber(v.oldzoneid) > 0 then
                        allserver[k].sortIdx = tonumber(v.oldzoneid)
                        zoneid = tonumber(v.oldzoneid)
                    elseif v.zoneid then
                        allserver[k].sortIdx = tonumber(v.zoneid)
                        zoneid = tonumber(v.zoneid)
                    end
                    if(isYueyu and zoneid and zoneid > 600 and zoneid <= 1000)then
                        v.sortIdx = zoneid
                        v.isKy = true
                        table.insert(self.kyServerList, v)
                        kyServerNum = kyServerNum + 1
                    end
                    if tonumber(v.MS) == 1 then
                        self.hasMs = true
                        table.insert(memoryServerList, v)
                        memoryServerNum = memoryServerNum + 1
                    end
                    totalNum = totalNum + 1
                    v.name = GetServerName(v.name)
                end
                local function sortFunc(a, b)
                    if a and a.sortIdx and b and b.sortIdx then
                        return a.sortIdx < b.sortIdx
                    end
                end
                table.sort(allserver, sortFunc)
                if self.kyServerList and next(self.kyServerList) then
                    table.sort(self.kyServerList, sortFunc)
                end
                table.sort(memoryServerList, sortFunc)
                totalNum = totalNum - kyServerNum - memoryServerNum
                for k, v in pairs(allserver) do
                    self.pageNum = math.ceil(totalNum / self.perPageNum)
                    local page = math.ceil(k / self.perPageNum)
                    local index = self.pageNum - page + 1
                    if(v.isKy ~= true and tonumber(v.MS) ~= 1)then
                        if self.serverPageList[index] == nil then
                            self.serverPageList[index] = {}
                        end
                        table.insert(self.serverPageList[index], v)
                    end
                end
                if self.hasMs == true then --怀旧服显示置顶
                    table.insert(self.serverPageList, 1, {})
                    self.serverPageList[1] = memoryServerList
                    self.pageNum = self.pageNum + 1
                end
                self.formalServerNum = totalNum
                self.kyServerNum = kyServerNum
                if SizeOfTable(self.kyServerList) > 0 then
                    self.pageNum = self.pageNum + 1
                end
                self.f_init = true
            end
        else
            self.country = {"cn", "de", "in", "en", "tw", "thai"}
            for k, v in pairs(self.country) do
                self.pageShowServerList[k] = allserver[v]
            end
            self.pageNum = SizeOfTable(self.country)
            self.f_init = true
        end
    end
end

--是否已分页形式显示服务器列表
function serverMgr:isPageShow()
    if self.f_pageShow == nil then
        local flag = false
        if SizeOfTable(serverCfg.allserver) == 1 then
            for k, v in pairs(serverCfg.allserver) do
                if(#v >= 100)then
                    flag = true
                    do break end
                end
            end
        end
        if platCfg.platCfgShowServerListByPage[G_curPlatName()] then
            if SizeOfTable(serverCfg.allserver) == 1 then
                flag = true
            end
        end
        self.f_pageShow = flag
    end
    return self.f_pageShow
end

function serverMgr:hasMemoryServer()
    return self.hasMs
end

function serverMgr:getServerListByPage(page)
    self:init()
    if self.pageShowServerList[page] == nil then
        local serverList = {}
        local pageList = self.serverPageList[page]
        if pageList then
            for index = #pageList, 1, -1 do
                table.insert(serverList, pageList[index])
            end
        elseif(#self.kyServerList > 0)then
            for i = #self.kyServerList, 1, -1 do
                table.insert(serverList, self.kyServerList[i])
            end
        end
        self.pageShowServerList[page] = serverList
    end
    return self.pageShowServerList[page]
end

function serverMgr:getPageNum()
    return self.pageNum
end

function serverMgr:getPageStr(pageIdx)
    local pageStr = ""
    if self.f_pageShow == true then
        if self.hasMs == true and pageIdx == 1 then
            pageStr = getlocal("memoryServerName")
        elseif(self.kyServerNum and self.kyServerNum > 0 and pageIdx == self.pageNum)then
            pageStr = "KY01-"..self.kyServerNum
        else
            local minNum = self.perPageNum * (self.pageNum - pageIdx) + 1
            local maxNum = self.perPageNum * (self.pageNum - pageIdx + 1)
            if self.formalServerNum > 0 and maxNum > self.formalServerNum then
                maxNum = self.formalServerNum
            end
            pageStr = minNum.."-"..maxNum
        end
    else
        local svr = {"213", "207", "204", "206", "223", "208"}
        pageStr = svr[pageIdx]
    end
    return pageStr
end

function serverMgr:clear()
    self.f_pageShow = nil
    self.hasMs = nil
    self.f_init = nil
    self.serverPageList = {}
    self.pageShowServerList = {}
    self.kyServerList = nil
    self.formalServerNum = 0
    self.kyServerNum = 0
    self.pageNum = 0
end
