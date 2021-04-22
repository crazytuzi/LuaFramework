
local QUIDialog = import(".QUIDialog")
local QUIDialogChooseServer = class("QUIDialogChooseServer", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetChooseServerItem = import("..widgets.QUIWidgetChooseServerItem")
local QUIWidgetChooseServerGroupItem = import("..widgets.QUIWidgetChooseServerGroupItem")

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QScrollView = import("...views.QScrollView")
local QListView = import("...views.QListView")

function QUIDialogChooseServer:ctor(options)
    local ccbFile = "ccb/Dialog_ChooseServer.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerSuggestServer", callback = handler(self, self._onTriggerSuggestServer)},
    }

    QUIDialogChooseServer.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    
    if type(options.servers) ~= "table" then
        options.servers = {}
    end

    if type(options.loginHistory) ~= "table" then
        options.loginHistory = {}
    end

    if type(options.defaultServer) ~= "table" then
        options.defaultServer = {}
    end

    print("服务器列表。。。")
    printTable(options)

    self._callback = options.callback;
    self._servers = options.servers
    self._loginHistory = {}
    self._oldLoginHistory = #options.loginHistory

    -- 推荐服务器
    for k,v in pairs(self._servers) do
        if v.status == 2 then
            self._suggestNewServer = v
            break
        end
    end
    
    if not self._suggestNewServer then
        self._suggestNewServer = options.defaultServer
    end

    for _, v in pairs(options.loginHistory) do
        table.insert(self._loginHistory, v)
    end

    if #self._loginHistory == 0 and self._suggestNewServer.name then
        table.insert(self._loginHistory,self._suggestNewServer)
    end

    for _, v in pairs(self._loginHistory) do
        if self._suggestNewServer.zoneId == v.zoneId and self._suggestNewServer.serverId == v.serverId then
            self._suggestNewServer = v
            break
        end
    end
    
    table.sort(self._loginHistory, function ( a,b )
            local aLoginTime = tonumber(a.loginTime)
            local bLoginTime = tonumber(b.loginTime)
            if aLoginTime and bLoginTime then
                return aLoginTime > bLoginTime
            elseif not aLoginTime then
                return false
            else
                return true
            end
        end)
  
    self._ccbOwner.btnSuggestServer:setEnabled(false)
    self._ccbOwner.suggestServerState:setVisible(true)
    self._ccbOwner.otherServerListParent:setVisible(false)
    self._ccbOwner.node_open_soon:setVisible(false)

    self:initLoginHistory()
    self:initSuggestServer()
    self:initOpenSoonServer()
    self:initServerGroupList()
end

function QUIDialogChooseServer:initServerGroupList(  )
    local normalServer = {}
    local hotBloodServer = {} 
    local otherServer = {} 

    for k ,v in pairs(self._servers) do
        for _, v1 in pairs(self._loginHistory) do
            if v1.zoneId == v.zoneId and v1.serverId == v.serverId then
                self._servers[k] = v1
                break
            end
        end
    end

    for k,v in pairs(self._servers) do
        v.index = tonumber(string.sub(v.zoneId, 6, string.len(v.zoneId)))
        string.gsub(v.name,".-(%d+)%D-$",function ( index )
            -- body
            v.zoneIndex = tonumber(index)
        end)

        -- if v.is_hot_blood then
        --     table.insert(hotBloodServer,v)
        -- else
        if v.index then
            table.insert(normalServer,v)
        else
            table.insert(otherServer,v)
        end
    end

    table.sort(normalServer, function(a, b)
            return a.index < b.index
        end)

    self._groupServerData = {}
    local temp = {}
    local tempData = {}
    local totalCount = #normalServer
    for k,v in pairs(normalServer) do
        table.insert(tempData,v)
        if k % 10 == 0 or totalCount == k then
            local lastIndex = (totalCount == k and totalCount%10 ~= 0) and  (totalCount%10) or 10
            local name = string.format("%d区-%d区", tempData[1].index, tempData[lastIndex].index)
            if CHANNEL_RES.gameOpId == "3004" then
                if tempData[1].index < 675 and tempData[lastIndex].index > 675 then
                    name = string.format("%d区-霸服%d服", tempData[1].index, tempData[lastIndex].zoneIndex)
                elseif tempData[1].index > 675 then
                    name = string.format("霸服%d服-%d服", tempData[1].zoneIndex, tempData[lastIndex].zoneIndex)
                else
                    name = string.format("%d区-%d区", tempData[1].index, tempData[lastIndex].index)
                end
            end

            table.insert(temp,name)
            table.insert(temp,tempData)
            table.insert(self._groupServerData,1,temp)
            temp = {}
            tempData = {}
        end
    end
    
    temp = {}
    tempData = {}
    totalCount = #hotBloodServer
    for k,v in pairs(hotBloodServer) do
        table.insert(tempData,v)
        if k % 10 == 0 or k == totalCount then
            local name = string.format("超级服%d",math.ceil(k/10))
            table.insert(temp,name)
            table.insert(temp,tempData)
            table.insert(self._groupServerData,temp)
            temp = {}
            tempData = {}
        end
    end

    temp = {}
    tempData = {}
    totalCount = #otherServer
    for k,v in pairs(otherServer) do
        table.insert(tempData,v)
        if k % 10 == 0 or k == totalCount then
            local name = string.format("其他%d",math.ceil(k/10))
            table.insert(temp,name)
            table.insert(temp,tempData)
            table.insert(self._groupServerData,temp)
            temp = {}
            tempData = {}
        end
    end

    --创建 list
    local function clickBtnGroupItemHandler( x, y, touchNode, listView )
        if self._curServerGroupIndex then
            local lastIndex = self._curServerGroupIndex
            local lastItem = listView:getItemByIndex(lastIndex)
            if lastItem then
                lastItem:setSelected(true)
            end
        else
            self._ccbOwner.btnSuggestServer:setEnabled(true)
            self._ccbOwner.suggestServerState:setVisible(false)
            self._ccbOwner.otherServerListParent:setVisible(true)
        end
        local touchIndex = listView:getCurTouchIndex()
        local item = listView:getItemByIndex(touchIndex)
        if item then
            item:setSelected(false)
        end
        self._curServerGroupIndex = touchIndex
        self:refreshOtherServerList()
    end


    local cfg = {
        renderItemCallBack = function( list, index, info )
            local isCacheNode = true
            local item = list:getItemFromCache()
            if not item then
                item = QUIWidgetChooseServerGroupItem.new()
                isCacheNode = false
            end
            
            if self._curServerGroupIndex and self._curServerGroupIndex == index then
                item:setSelected(false)
            else
                item:setSelected(true)
            end
            local tempInfo = {}
            tempInfo.index = index
            tempInfo.name = self._groupServerData[index][1]

            item:setInfo(tempInfo)
            info.item = item
            info.size = item:getContentSize()
            list:registerBtnHandler(index,"btnGroupItem", clickBtnGroupItemHandler)
            return isCacheNode
        end,
        spaceY = 6,
        enableShadow = false,
        totalNumber =#self._groupServerData,
    }

    self._serverGroupList = QListView.new(self._ccbOwner.serverGroupListParent,cfg)
end


function QUIDialogChooseServer:refreshOtherServerList(  )
    -- body
    if not self._groupServerData and not self._curServerGroupIndex then
        return
    end
    if not self._otherServerItems then
        self._otherServerItems = {}
        local ox1 = 0
        local oy = 0
        local ox2 = 336
        local dy = 96
        local data = self._groupServerData[self._curServerGroupIndex][2]
        for k = 1,10 do
            local info = data[k]
            local item = self:createChooseServerItem(info)
            if not info then
                item:setVisible(false)
            end
            if k%2 == 0 then
                item:setPosition(ccp(ox2,oy - math.floor((k-1)/2) * dy))
            else
                item:setPosition(ccp(ox1,oy - math.floor((k-1)/2) * dy))
            end
            table.insert(self._otherServerItems,item)
            self._ccbOwner.otherServerListParent:addChild(item)
        end
        
    else
        local data = self._groupServerData[self._curServerGroupIndex][2]
        for k,v in pairs(self._otherServerItems) do
            local info = data[k]
            if not info then
                v:setVisible(false)
            else
                v:setVisible(true)
                v:setInfo(info)
            end 
        end

    end
end

function QUIDialogChooseServer:createChooseServerItem( iteminfo,options )
    -- body
    local item = QUIWidgetChooseServerItem.new(options)
    item:setInfo(iteminfo)
    item:addEventListener(QUIWidgetChooseServerItem.EVENT_SELECT, handler(self, self._onChooseServer))
    return item
end

function QUIDialogChooseServer:initLoginHistory( )
    -- body
    local loginHistory = {}
    for i, v in pairs(self._loginHistory) do
        table.insert(loginHistory, v)
        if i >= 4 then
            break
        end
    end
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local item = list:getItemFromCache()
            if not item then
                item = QUIWidgetChooseServerItem.new()
                item:addEventListener(QUIWidgetChooseServerItem.EVENT_SELECT, handler(self, self._onChooseServer))
                isCacheNode = false
            end
            item:setInfo(loginHistory[index])
            info.item = item
            info.size = item:getContentSize()

            list:registerBtnHandler(index,"btnChooseServer", "_onTriggerChoose" )
            return isCacheNode
        end,
        enableShadow = false,
        multiItems = 2,
        -- spaceY = 12,
        -- spaceX = 12,
        totalNumber = #loginHistory,
    }  
    self._loginHistoryList = QListView.new(self._ccbOwner.historyListParent,cfg)
end

function QUIDialogChooseServer:initSuggestServer( )
    -- body
    if not self._suggestNewServer.name then
        return
    end
    local item = self:createChooseServerItem(self._suggestNewServer,{})
    self._ccbOwner.suggestListParent:addChild(item)
end

function QUIDialogChooseServer:initOpenSoonServer( )
    -- body
    local openServer = remote.openSoonServer
    if not openServer or self._oldLoginHistory > 0 or FinalSDK.isHx() then
        return
    end
    local item = self:createChooseServerItem(openServer,{})
    self._ccbOwner.openSoonListParent:addChild(item)
    self._ccbOwner.node_open_soon:setVisible(true)
end


function QUIDialogChooseServer:_onChooseServer(event)
    if self._isMoving == true then  return end
    remote.defaultServerInfo = event.serverInfo
    if self._callback then
        self._callback(event.serverInfo)
    end
    app:sendGameEvent(GAME_EVENTS.GAME_EVENT_SELECT_SERVER)
    self:close()
end

function QUIDialogChooseServer:viewDidAppear()
    QUIDialogChooseServer.super.viewDidAppear(self)
end

function QUIDialogChooseServer:viewWillDisappear()
    QUIDialogChooseServer.super.viewWillDisappear(self)
end

function QUIDialogChooseServer:close(  )
    -- body
    self:playEffectOut()
end


function QUIDialogChooseServer:_onTriggerClose(event)
    self:close()
end

function QUIDialogChooseServer:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogChooseServer:_onTriggerSuggestServer(event)
    -- body
    self._ccbOwner.btnSuggestServer:setEnabled(false)
    self._ccbOwner.suggestServerState:setVisible(true)
    self._ccbOwner.otherServerListParent:setVisible(false)
    if self._curServerGroupIndex then
        local lastItem = self._serverGroupList:getItemByIndex(self._curServerGroupIndex)
        if lastItem then
            lastItem:setSelected(true)
        end
    end
    self._curServerGroupIndex = nil
end

return QUIDialogChooseServer