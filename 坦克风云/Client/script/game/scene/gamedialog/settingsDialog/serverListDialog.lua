--服务器列表面板
serverListDialog = commonDialog:new()

function serverListDialog:new(parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.recentLoginTab = {}
    self.allServers = {}
    self.countryTv = nil
    self.selectedCountry = nil
    self.countryTab = {}
    --self.selectedBtn=nil
    self.countryLabel = nil
    self.bgSprieTab = {}
    self.iconBgTab = {}
    self.dialogOpened = 0
    self.pageNum = 0 --显示的页数
    self.perPageNum = 40 --一页显示数量
    self.serverPageList = nil --分页显示服务器列表
    self.kyServerList = {}
    self.pageRowTb = {} --每一页的服务器数量
    self.pageShowServerList = {} --每一页显示的服务器列表
    self.selectPage = 1 --当前选中那一页
    self.hasMs = false --是否有怀旧服
    self.parent = parent
    return nc
end

function serverListDialog:getShowByPage()
    if self.showPageFlag == nil then
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
        self.showPageFlag = flag
    end
    return self.showPageFlag
end
function serverListDialog:getServerPageList()
    if self.serverPageList == nil then
        self.serverPageList = {}
        local allCfg = G_clone(serverCfg.allserver)
        local allserver = {}
        --分页只对一种语言有效
        for k, v in pairs(allCfg) do
            allserver = v
        end
        local isYueyu = false
        self.hasMs = false
        if allserver then
            --越狱快用601服想要单独处理，拉出一个页签来
        	local memoryServerList = {}
            local kyServerNum,memoryServerNum = 0,0
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
            end
            local function sortFunc(a, b)
                if a and a.sortIdx and b and b.sortIdx then
                    return a.sortIdx < b.sortIdx
                end
            end
            table.sort(allserver, sortFunc)
            table.sort(self.kyServerList, sortFunc)
            table.sort(memoryServerList, sortFunc)
            local totalNum = SizeOfTable(allserver) - kyServerNum - memoryServerNum
            for k, v in pairs(allserver) do
                local pageNum = math.ceil(totalNum / self.perPageNum)
                local page = math.ceil(k / self.perPageNum)
                local index = pageNum - page + 1
                if(v.isKy ~= true and tonumber(v.MS) ~= 1)then
                    if self.serverPageList[index] == nil then
                        self.serverPageList[index] = {}
                    end
                    table.insert(self.serverPageList[index], v)
                end
            end
            if self.hasMs == true then --怀旧服显示置顶
            	table.insert(self.serverPageList,1,{})
            	self.serverPageList[1] = memoryServerList
            end
            self.customServerNum = totalNum
        end
    end
    return self.serverPageList
end

--设置或修改每个Tab页签
function serverListDialog:resetTab()
    
    local index = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        
        if index == 0 then
            tabBtnItem:setPosition(self.bgSize.width / 2 - tabBtnItem:getContentSize().width / 2, self.bgSize.height - tabBtnItem:getContentSize().height * 1.5)
        elseif index == 1 then
            tabBtnItem:setPosition(self.bgSize.width / 2 + tabBtnItem:getContentSize().width / 2, self.bgSize.height - tabBtnItem:getContentSize().height * 1.5)
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
end

--设置对话框里的tableView
function serverListDialog:initTableView()
    spriteController:addPlist("public/GlobalBtn.plist")
    spriteController:addTexture("public/GlobalBtn.png")
    if G_getServerCfgFromHttp ~= nil then
        G_getServerCfgFromHttp(true)
    end
    
    --====检查有无重复和无效的服务器=====
    local tmpLgTb = {}
    local tmpRectLg
    local flag = false
    local allCachedData = {}
    for i = 1, 100 do
        tmpRectLg = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_rectLoginSvr..i))
        if tmpRectLg ~= "" then
            if tmpLgTb[tmpRectLg] ~= nil then
                -- CCUserDefault:sharedUserDefault():setStringForKey(tostring(G_local_rectLoginSvr..i),"")
                flag = true
            else
                local data = Split(tmpRectLg, ",")
                local k1, k2 = data[1], data[2]
                if serverCfg:checkServerValid(k1, k2) == false then --当前有效的登陆过的服务器
                    flag = true
                else
                    tmpLgTb[tmpRectLg] = tmpRectLg
                    table.insert(allCachedData, tmpRectLg)
                end
            end
        end
    end
    if(flag)then
        local count = #allCachedData
        for k, v in pairs(allCachedData) do
            CCUserDefault:sharedUserDefault():setStringForKey(tostring(G_local_rectLoginSvr..k), v)
        end
        CCUserDefault:sharedUserDefault():flush()
    end
    --====================
    
    self.recentLogin = {} --最近登陆的服务器
    for k, v in pairs(allCachedData) do
        local cachedData = Split(v, ",")
        local k1, k2 = cachedData[1], cachedData[2]
        table.insert(self.recentLogin, 1, {k1 = k1, k2 = k2})
    end
    
    local serverData = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_lastLoginSvr))
    if serverData ~= nil then
        self.selectedCountry = Split(serverData, ",")[1]
        if self.allServers[self.selectedCountry] == nil then
            self.selectedCountry = nil
        end
    end
    --[[
self.allServers=serverCfg.allserver --所有的服务器
    local ctable={}
    for k,v in pairs(serverCfg.allserver) do
        if self.selectedCountry==nil or self.selectedCountry=="" then
            self.selectedCountry=k --当前选择的国家
        end
        table.insert(ctable,k)
    end
self.countryTab=ctable  --国家  
]]
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 200), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(25, 30))
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function serverListDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        if self.selectedTabIndex == 0 then
            -- if G_getCurChoseLanguage()=="ru"then
            -- return SizeOfTable(self.recentLogin)
            -- else
            return math.ceil(SizeOfTable(self.recentLogin) / 2)
            --end
        elseif self.selectedTabIndex == 1 then
            if self:getShowByPage() == true then
                if self.pageRowTb[self.selectPage] == nil then
                    local num = 0
                    local serverPageList = self:getServerPageList()
                    local pageList = serverPageList[self.selectPage]
                    if pageList then
                        if G_getCurChoseLanguage() == "ru"then
                            num = SizeOfTable(pageList)
                        else
                            num = math.ceil(SizeOfTable(pageList) / 2)
                        end
                    elseif(#self.kyServerList > 0)then
                        num = math.ceil(#self.kyServerList / 2)
                    end
                    self.pageRowTb[self.selectPage] = num
                end
                return self.pageRowTb[self.selectPage]
            else
                if self.pageRowTb[self.selectedCountry] == nil then
                    local num = 0
                    if G_getCurChoseLanguage() == "ru"then
                        num = SizeOfTable(self.allServers[self.selectedCountry])
                    else
                        num = math.ceil(SizeOfTable(self.allServers[self.selectedCountry]) / 2)
                    end
                    self.pageRowTb[self.selectedCountry] = num
                end
                return self.pageRowTb[self.selectedCountry]
            end
            return 0
        end
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(400, 120)
        if G_isApplyVersion() == true then
            tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 10, 120)
        end
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local showServer
        if self.selectedTabIndex == 0 then
            showServer = self.recentLogin
            local function clickHandler(tag, object)
                if self and self.tv and self.tv:getIsScrolled() == true then
                    do return end
                end
                PlayEffect(audioCfg.mouseClick)
                
                if base.lastSelectedServer ~= nil then
                    local loginServer = Split(base.lastSelectedServer, ",")
                    if loginServer[1] == showServer[tag].k1 and loginServer[2] == showServer[tag].k2 then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alreadyLogin"), true, self.layerNum + 1)
                        do return end
                    end
                end
                if loginScene.isShowing == true then --先打开登陆页面
                    print("当前选择是", showServer[tag].k1..","..showServer[tag].k2)
                    loginScene:setSelectServer(showServer[tag].k1..","..showServer[tag].k2)
                    self:close()
                else
                    self:close(false)
                    if self.parent and self.parent.close then
                        self.parent:close(false)
                        self.parent = nil
                    end
                    loginScene:setSelectServer(showServer[tag].k1..","..showServer[tag].k2)
                    local svrCfg = serverCfg.allserver[showServer[tag].k1]
                    local cselSvr
                    for kk, vv in pairs(svrCfg) do
                        if vv.name == showServer[tag].k2 then
                            cselSvr = vv
                        end
                    end
                    if G_curPlatName() == "8" then
                        PlatformManage:shared():loginOut()
                    end
                    if G_curPlatName() == "66" then
                        PlatformManage:shared():switchAccount();
                    end
                    base:changeServer(cselSvr.ip, cselSvr.port)
                end
            end
            local rowNum = 2
            -- if G_getCurChoseLanguage()=="ru" then
            -- rowNum =1
            -- end
            for i = 1, rowNum do
                if showServer[idx * rowNum + i] then
                    local serverName = GetServerName(showServer[idx * rowNum + i].k2)
                    local buttonItem = GetButtonItem("ServerBgBtn.png", "ServerBgBtn_Down.png", "ServerBgBtn.png", clickHandler, idx * rowNum + i)
                    local buttonMenu = CCMenu:createWithItem(buttonItem)
                    --buttonMenu:setPosition(ccp(i*(buttonItem:getContentSize().width+22)-40,120/2))
                    if rowNum == 2 then
                        buttonMenu:setPosition(ccp(i * (buttonItem:getContentSize().width + 180) - 115, 120 / 2))
                    elseif rowNum == 1 then
                        buttonMenu:setPosition(ccp(300, 120 / 2))
                    end
                    buttonMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    --buttonMenu:setScaleX(0.8)
                    cell:addChild(buttonMenu)
                    
                    --local serverNameLabel=GetTTFLabel(serverName,25)
                    
                    local lbWidth = 0
                    local tempLb = GetTTFLabel(serverName, 25)
                    local serverNameLabel = GetTTFLabelWrap(serverName, 25, CCSizeMake(250, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                    
                    if tempLb:getContentSize().width < 250 then
                        lbWidth = tempLb:getContentSize().width
                    else
                        lbWidth = 250
                    end
                    
                    local capInSet = CCRect(42, 26, 10, 10)
                    local function cellClick(hd, fn, idx)
                    end
                    local serverTxtSp = LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png", capInSet, cellClick)
                    serverTxtSp:setContentSize(CCSizeMake(lbWidth + 20, serverNameLabel:getContentSize().height + 20))
                    serverTxtSp:ignoreAnchorPointForPosition(false)
                    serverTxtSp:setAnchorPoint(ccp(0.5, 0.5))
                    --serverTxtSp:setTag(1000+idx)
                    serverTxtSp:setIsSallow(false)
                    serverTxtSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    serverTxtSp:setPosition(getCenterPoint(buttonItem))
                    buttonItem:addChild(serverTxtSp, 1)
                    
                    serverNameLabel:setPosition(getCenterPoint(serverTxtSp))
                    serverTxtSp:addChild(serverNameLabel, 1)
                end
            end
        elseif self.selectedTabIndex == 1 then
           if self:getShowByPage() == true then
                if self.pageShowServerList[self.selectPage] == nil then
                    local serverList = {}
                    local serverPageList = self:getServerPageList()
                    local pageList = serverPageList[self.selectPage]
                    if pageList then
                        for index = #pageList, 1, -1 do
                            table.insert(serverList, pageList[index])
                        end
                    elseif(#self.kyServerList > 0)then
                        for i = #self.kyServerList, 1, -1 do
                            table.insert(serverList, self.kyServerList[i])
                        end
                    end
                    self.pageShowServerList[self.selectPage] = serverList
                end
                showServer = self.pageShowServerList[self.selectPage]
            else
                if self.pageShowServerList[self.selectedCountry] == nil then
                    local serverList = {}
                    local tmpSvrTb = self.allServers[self.selectedCountry]
                    for idx = #tmpSvrTb, 1, -1 do
                        table.insert(serverList, tmpSvrTb[idx])
                    end
                    self.pageShowServerList[self.selectedCountry] = serverList
                end
                showServer = self.pageShowServerList[self.selectedCountry]
            end
            
            local function clickHandler1(tag, object)
                if self and self.tv and self.tv:getIsScrolled() == true then
                    do return end
                end
                PlayEffect(audioCfg.mouseClick)
                
                if base.lastSelectedServer ~= nil then
                    local loginServer = Split(base.lastSelectedServer, ",")
                    if loginServer[1] == self.selectedCountry and loginServer[2] == showServer[tag].name then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alreadyLogin"), true, self.layerNum + 1)
                        do return end
                    end
                end
                local hasExistInRecent = false
                for kk, vv in pairs(self.recentLogin) do
                    if vv.k1 == self.selectedCountry and vv.k2 == showServer[tag].name then
                        hasExistInRecent = true
                    end
                end
                if hasExistInRecent == false then
                    CCUserDefault:sharedUserDefault():setStringForKey(G_local_rectLoginSvr..(SizeOfTable(self.recentLogin) + 1), self.selectedCountry..","..showServer[tag].name)
                end
                if loginScene.isShowing == true then --先打开登陆页面
                    loginScene:setSelectServer(self.selectedCountry..","..showServer[tag].name)
                    self:close()
                else
                    self:close(false)
                    if self.parent and self.parent.close then
                        self.parent:close(false)
                        self.parent = nil
                    end
                    loginScene:setSelectServer(self.selectedCountry..","..showServer[tag].name)
                    if G_curPlatName() == "8" then
                        PlatformManage:shared():loginOut()
                    end
                    base:changeServer(showServer[tag].ip, showServer[tag].port)
                end
                
            end
            local rowNum1 = 2
            if G_getCurChoseLanguage() == "ru" then
                rowNum1 = 1
            end
            for i = 1, rowNum1 do
                if showServer[idx * rowNum1 + i] then
                    local serverName1 = GetServerName(showServer[idx * rowNum1 + i].name)
                    local buttonItem1 = GetButtonItem("ServerBgBtn.png", "ServerBgBtn_Down.png", "ServerBgBtn.png", clickHandler1, idx * rowNum1 + i)
                    local buttonMenu1 = CCMenu:createWithItem(buttonItem1)
                    --buttonMenu1:setPosition(ccp(i*(buttonItem1:getContentSize().width+16)-33,120/2))
                    buttonMenu1:setPosition(ccp(i * (buttonItem1:getContentSize().width + 125) - 102, 120 / 2))
                    if rowNum1 == 2 then
                        if G_isApplyVersion() == true then
                            buttonMenu1:setPosition(ccp(i * (buttonItem1:getContentSize().width + 180) - 115, 120 / 2))
                        else
                            buttonMenu1:setPosition(ccp(i * (buttonItem1:getContentSize().width + 125) - 102, 120 / 2))
                        end
                    elseif rowNum1 == 1 then
                        if G_isApplyVersion() == true then
                            buttonMenu1:setPosition(ccp(300, 120 / 2))
                        else
                            buttonMenu1:setPosition(ccp(220, 120 / 2))
                        end
                    end
                    
                    buttonMenu1:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    --buttonMenu1:setScaleX(0.8)
                    cell:addChild(buttonMenu1)
                    --[[local lbWidth = 0
   local tempLb = GetTTFLabel(serverName1,25)
   local serverNameLabel1=GetTTFLabelWrap(serverName1,25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
 
   if tempLb:getContentSize().width<180 then
   lbWidth = tempLb:getContentSize().width
   else
   lbWidth = 180
   end
]]
                    local serverNameLabel1 = GetTTFLabel(serverName1, 25)
                    
                    local capInSet = CCRect(42, 26, 10, 10)
                    local function cellClick(hd, fn, idx)
                    end
                    local serverTxtSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png", capInSet, cellClick)
                    serverTxtSp1:setContentSize(CCSizeMake(serverNameLabel1:getContentSize().width + 20, serverNameLabel1:getContentSize().height + 20))
                    serverTxtSp1:ignoreAnchorPointForPosition(false)
                    serverTxtSp1:setAnchorPoint(ccp(0.5, 0.5))
                    --serverTxtSp1:setTag(1000+idx)
                    serverTxtSp1:setIsSallow(false)
                    serverTxtSp1:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    serverTxtSp1:setPosition(getCenterPoint(buttonItem1))
                    buttonItem1:addChild(serverTxtSp1, 1)
                    
                    serverNameLabel1:setPosition(getCenterPoint(serverTxtSp1))
                    serverTxtSp1:addChild(serverNameLabel1, 1)
                end
            end
            
        end
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

--点击tab页签 idx:索引
function serverListDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    if idx == 1 then
        if G_getServerCfgFromHttp ~= nil then
            G_getServerCfgFromHttp(true)
            self.allServers = G_clone(serverCfg.allserver) --所有的服务器
            --合服后按旧服务器排序
            if self.allServers then
                for c, allserver in pairs(self.allServers) do
                    if allserver and SizeOfTable(allserver) > 0 then
                        for k, v in pairs(allserver) do
                            if v.oldzoneid and tonumber(v.oldzoneid) and tonumber(v.oldzoneid) > 0 then
                                allserver[k].sortIdx = tonumber(v.oldzoneid)
                            elseif v.zoneid then
                                allserver[k].sortIdx = tonumber(v.zoneid)
                            end
                            --部分平台存在迁移服务器，迁移服务器的id以600开头，一般放到最下面
                            if(allserver[k].sortIdx >= 600 and allserver[k].sortIdx < 700)then
                                allserver[k].sortIdx = allserver[k].sortIdx - 700
                            end
                        end
                        local function sortFunc(a, b)
                            if a and a.sortIdx and b and b.sortIdx then
                                return a.sortIdx < b.sortIdx
                            end
                        end
                        table.sort(self.allServers[c], sortFunc)
                    end
                end
            end
            local ctable = {}
            for k, v in pairs(serverCfg.allserver) do
                if self.selectedCountry == nil or self.selectedCountry == "" then
                    self.selectedCountry = k --当前选择的国家
                end
                table.insert(ctable, k)
            end
            self.countryTab = ctable --国家
        end
    end
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            self.tv:reloadData()
            self:doUserHandler()
        else
            v:setEnabled(true)
        end
    end
    
    if self.selectedTabIndex == 1 then
        local function click(hd, fn, idx)
        end
        for i = 1, 3 do
            if self.bgSprieTab[i] then
                self.bgSprieTab[i]:setVisible(true)
            else
                local bgSprie
                if i == 1 then
                    bgSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), click)
                    bgSprie:setContentSize(CCSizeMake(140, self.bgLayer:getContentSize().height - 200))
                    bgSprie:setPosition(ccp(30, 40))
                    
                elseif i == 2 then
                    bgSprie = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), click)
                    bgSprie:setContentSize(CCSizeMake(440, 80))
                    bgSprie:setPosition(ccp(170, self.bgLayer:getContentSize().height - 240))
                elseif i == 3 then
                    bgSprie = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png", CCRect(20, 20, 10, 10), click)
                    bgSprie:setContentSize(CCSizeMake(440, self.bgLayer:getContentSize().height - 280))
                    bgSprie:setPosition(ccp(170, 40))
                    if G_isApplyVersion() == true then
                        bgSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, self.bgLayer:getContentSize().height - 200))
                        bgSprie:setPosition(ccp(30, 40))
                    end
                end
                bgSprie:ignoreAnchorPointForPosition(false)
                bgSprie:setIsSallow(false)
                bgSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                bgSprie:setAnchorPoint(ccp(0, 0))
                self.bgLayer:addChild(bgSprie, 1)
                
                table.insert(self.bgSprieTab, i, bgSprie)
            end
        end
        
        local function ctvCallBack(...)
            return self:ctvEventHandler(...)
        end
        local hd = LuaEventHandler:createHandler(ctvCallBack)
        self.countryTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(150, self.bgLayer:getContentSize().height - 230), nil)
        self.countryTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        self.countryTv:setPosition(ccp(35, 60))
        self.bgLayer:addChild(self.countryTv, 2)
        self.countryTv:setMaxDisToBottomOrTop(120)
        --[[
self.tv:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-150,self.bgLayer:getContentSize().height-600))
self.tv:setPosition(ccp(172,60))
]]
        
        self.bgLayer:removeChild(self.tv, true)
        self.tv = nil
        local tvWidth, tvHeight = self.bgLayer:getContentSize().width - 150, self.bgLayer:getContentSize().height - 310
        if G_isApplyVersion() == true then
            tvWidth, tvHeight = self.bgLayer:getContentSize().width - 60, self.bgLayer:getContentSize().height - 230
        end
        local function callBack(...)
            return self:eventHandler(...)
        end
        local hd = LuaEventHandler:createHandler(callBack)
        self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
        self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        if G_isApplyVersion() == true then
            self.tv:setPosition(25, 60)
        else
            self.tv:setPosition(ccp(167, 60))
        end
        self.bgLayer:addChild(self.tv, 2)
        self.tv:setMaxDisToBottomOrTop(120)
        
        if self.countryLabel == nil then
            local languageStr = platCfg.platCfgLanDesc[self.selectedCountry]
            if(G_curPlatName() == "14" or G_curPlatName() == "androidkunlun" or G_curPlatName() == "androidkunlunz")then
                languageStr = "Global"
            elseif((G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" or G_curPlatName() == "0") and self.selectedCountry == "de")then
                languageStr = "EU"
            end
            if languageStr ~= nil then
                self.countryLabel = GetTTFLabel(languageStr, 30)
                self.countryLabel:setPosition(ccp(390, self.bgLayer:getContentSize().height - 200))
                self.bgLayer:addChild(self.countryLabel, 2)
            end
        else
            self.countryLabel:setVisible(true)
        end
        --以下程序 根据用户设备当前选择的语言 设置默认选择服
        if SizeOfTable(serverCfg.allserver) > 1 then
            local str = G_getOSCurrentLanguage() --获取设备当前选择的语言
            if platCfg.platCfgDeviceLangToGameLang[str] ~= nil then
                str = platCfg.platCfgDeviceLangToGameLang[str]
                if G_curPlatName() == "efunandroiddny" or G_curPlatName() == "4" or G_curPlatName() == "47" then
                    str = "en"
                end
            end
            if serverCfg.allserver[str] ~= nil then --默认的语言有配置服务器
                if self.dialogOpened == 0 then
                    self:changeCountry(str)
                end
                self.dialogOpened = 1
                
            end
            --以上程序 根据用户设备当前选择的语言 设置默认选择服
            
        end
        -- self:changeCountry("tw")
    else
        self.bgLayer:removeChild(self.tv, true)
        self.tv = nil
        local function callBack(...)
            return self:eventHandler(...)
        end
        local hd = LuaEventHandler:createHandler(callBack)
        self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 210), nil)
        self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        self.tv:setPosition(ccp(25, 40))
        self.bgLayer:addChild(self.tv, 2)
        self.tv:setMaxDisToBottomOrTop(120)
        
        if self.countryLabel then
            self.countryLabel:setVisible(false)
        end
        if self.iconBgTab ~= nil then
            if SizeOfTable(self.iconBgTab) > 0 then
                for k, v in pairs(self.iconBgTab) do
                    self.iconBgTab[k] = nil
                end
            end
        end
        self.iconBgTab = {}
        if self.countryTv then
            self.bgLayer:removeChild(self.countryTv, true)
            self.countryTv = nil
            
            --[[
self.tv:setPosition(ccp(30,40))
self.tv:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-210))
]]
        end
        for i = 1, 3 do
            if self.bgSprieTab[i] then
                self.bgSprieTab[i]:setVisible(false)
            end
        end
    end
    if G_isApplyVersion() == true then --审核版本去掉国家显示列表
        if self.countryTv then
            self.countryTv:setVisible(false)
            self.countryTv:setPositionX(99999)
        end
        if self.bgSprieTab[2] and self.countryLabel then
            self.bgSprieTab[1]:setVisible(false)
            self.bgSprieTab[2]:setVisible(false)
            self.countryLabel:setVisible(false)
        end
    end
end

function serverListDialog:ctvEventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
    	if self.ctvNum == nil then
    		local num = 0
	        if self:getShowByPage() == true then
	            local serverPageList = self:getServerPageList()
	            num = SizeOfTable(serverPageList)
	            if(#self.kyServerList > 0)then
	                num = num + 1
	            end
	        else
	            num = SizeOfTable(self.countryTab)
	        end
	        self.ctvNum = num
    	end
        
        return self.ctvNum
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(150, 120)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        if self:getShowByPage() == true then
            local function nilFunc()
            end
            local normalBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), nilFunc)
            normalBg:setContentSize(CCSizeMake(118, 94))
            normalBg:ignoreAnchorPointForPosition(false)
            normalBg:setAnchorPoint(ccp(0.5, 0.5))
            normalBg:setPosition(ccp(60, 60))
            cell:addChild(normalBg)
            
            local function changeHandler(object, name, tag)
                if self and self.countryTv and self.countryTv:getIsScrolled() == true then
                    do return end
                end
                
                if self.selectPage ~= tag then
                    PlayEffect(audioCfg.mouseClick)
                    
                    if self.iconBgTab ~= nil then
                        for k, v in pairs(self.iconBgTab) do
                            if self.iconBgTab[k] ~= nil then
                                if k == tag then
                                    self.iconBgTab[k]:setVisible(true)
                                else
                                    self.iconBgTab[k]:setVisible(false)
                                end
                            end
                        end
                    end
                    self.selectPage = tag
                    self.tv:reloadData()
                    self:doUserHandler()
                end
            end
            local iconBg = LuaCCSprite:createWithSpriteFrameName("LanguageSelectBtn.png", changeHandler)
            iconBg:setPosition(ccp(65, 60))
            iconBg:setTag(idx + 1)
            iconBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(iconBg, 1)
            table.insert(self.iconBgTab, idx + 1, iconBg)
            iconBg:setVisible(false)
            
            local serverPageList = self:getServerPageList()
            local pageNum = SizeOfTable(serverPageList)
            if(#self.kyServerList > 0 and idx == pageNum)then
                local maxNum = #self.kyServerList
                local serverNumLb = GetTTFLabel("KY01-"..maxNum, 25)
                serverNumLb:setAnchorPoint(ccp(0.5, 0.5))
                serverNumLb:setPosition(ccp(60, 60))
                cell:addChild(serverNumLb, 3)
            else
                local minNum = self.perPageNum * (pageNum - (idx + 1)) + 1
                local maxNum = self.perPageNum * (pageNum - (idx + 1) + 1)
                if self.customServerNum > 0 and maxNum > self.customServerNum then
                    maxNum = self.customServerNum
                end
                local serverNumStr = minNum.."-"..maxNum
                if self.hasMs == true and idx == 0 then
                	serverNumStr = getlocal("memoryServerName")
                end
                local serverNumLb = GetTTFLabel(serverNumStr, 25)
                serverNumLb:setAnchorPoint(ccp(0.5, 0.5))
                -- serverNumLb:setColor(G_ColorYellowPro)
                serverNumLb:setPosition(ccp(60, 60))
                cell:addChild(serverNumLb, 3)
            end
            if self.selectPage == idx + 1 then
                iconBg:setVisible(true)
            end
        else
            local countryIcon
            if self.countryTab[idx + 1] ~= nil then
                countryIcon = platCfg.platCfgLanBtn[self.countryTab[idx + 1]]
            end
            if countryIcon == nil then
                do return cell end
            end
            if((G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" or G_curPlatName() == "0") and self.countryTab[idx + 1] == "de")then
                countryIcon = "europeBtn.png"
            end
            
            local function clickHandler2(tag, object)
                if self and self.countryTv and self.countryTv:getIsScrolled() == true then
                    do return end
                end
                PlayEffect(audioCfg.mouseClick)
                --if self.selectedBtn then
                --self.selectedBtn:setScaleX(0.6)
                --end
                if self.iconBgTab ~= nil then
                    for k, v in pairs(self.iconBgTab) do
                        if self.iconBgTab[k] ~= nil then
                            if k == tag then
                                self.iconBgTab[k]:setVisible(true)
                            else
                                self.iconBgTab[k]:setVisible(false)
                            end
                        end
                    end
                end
                
                local cName = self.countryTab[tag]
                if self.countryLabel then
                    local languageStr = platCfg.platCfgLanDesc[cName]
                    if(G_curPlatName() == "14" or G_curPlatName() == "androidkunlun" or G_curPlatName() == "androidkunlunz")then
                        languageStr = "Global"
                    end
                    if languageStr ~= nil then
                        self.countryLabel:setString(languageStr)
                    else
                        self.countryLabel:setString(cName)
                    end
                end
                self.selectedCountry = cName
                self.tv:reloadData()
                self:doUserHandler()
            end
            
            local iconBg = CCSprite:createWithSpriteFrameName("LanguageSelectBtn.png")
            iconBg:setPosition(ccp(65, 60))
            cell:addChild(iconBg, 1)
            table.insert(self.iconBgTab, idx + 1, iconBg)
            iconBg:setVisible(false)
            
            --local buttonItem2=GetButtonItem(countryIcon,countryIcon,countryIcon,clickHandler2,idx+1,self.countryTab[idx+1],30)
            local buttonItem2 = GetButtonItem(countryIcon, countryIcon, countryIcon, clickHandler2, idx + 1, nil, nil)
            local buttonMenu2 = CCMenu:createWithItem(buttonItem2)
            buttonMenu2:setPosition(ccp(58, 60))
            buttonMenu2:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(buttonMenu2, 2)
            
            if self.countryTab[idx + 1] == self.selectedCountry then
                --buttonItem2:setScaleX(0.8)
                --self.selectedBtn=buttonItem2
                iconBg:setVisible(true)
            else
                --buttonItem2:setScaleX(0.6)
            end
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

--切换国家接口
function serverListDialog:changeCountry(name)
    local tag
    if name and self.countryTab then
        for k, v in pairs(self.countryTab) do
            if v == name then
                tag = k
            end
        end
    end
    if tag == nil then
        do return end
    end
    if self.iconBgTab ~= nil then
        for k, v in pairs(self.iconBgTab) do
            if self.iconBgTab[k] ~= nil then
                if k == tag then
                    self.iconBgTab[k]:setVisible(true)
                else
                    self.iconBgTab[k]:setVisible(false)
                end
            end
        end
    end
    
    local cName = self.countryTab[tag]
    if cName == nil then
        do return end
    end
    if self.countryLabel then
        local languageStr = platCfg.platCfgLanDesc[cName]
        if(G_curPlatName() == "14" or G_curPlatName() == "androidkunlun" or G_curPlatName() == "androidkunlunz")then
            languageStr = "Global"
        end
        if languageStr ~= nil then
            self.countryLabel:setString(languageStr)
        else
            self.countryLabel:setString(cName)
        end
    end
    self.selectedCountry = cName
    self.tv:reloadData()
    self:doUserHandler()
end

function serverListDialog:doUserHandler()
    
end

function serverListDialog:dispose()
    spriteController:removePlist("public/GlobalBtn.plist")
    spriteController:removeTexture("public/GlobalBtn.png")
    self.serverPageList = {}
    self.recentLoginTab = nil
    self.allServers = nil
    self.countryTv = nil
    self.selectedCountry = nil
    self.countryTab = nil
    --self.selectedBtn=nil
    self.countryLabel = nil
    self.bgSprieTab = nil
    self.iconBgTab = nil
    self.dialogOpened = 0
    self.pageNum = 0 --显示的页数
    self.perPageNum = 40 --一页显示数量
    self.selectPage = 1 --当前选中那一页
    self.pageRowTb = {}
    self.pageShowServerList = {}
    self.ctvNum = nil
    self.hasMs = nil
    self.showPageFlag = nil
    self = nil
end
