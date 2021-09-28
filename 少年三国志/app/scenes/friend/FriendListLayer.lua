
local FriendListCell = require("app.scenes.friend.FriendListCell")

local FriendListLayer = class("FriendListLayer", UFCCSNormalLayer)

require("app.cfg.role_info")

function FriendListLayer.create(...)
    return require("app.scenes.friend.FriendListLayer").new("ui_layout/friend_FriendListLayer.json", ...)
end

function FriendListLayer:ctor(...)
    -- __Log("----------------------"..G_Me.userData.id.." "..G_Me.userData.name)

    self.super.ctor(self, ...)
    
    self._listview = nil
    self._friends = {}
    self._black = {}
    self._views = {}
    self._inited = {}
    self._checked = nil
    self._label_FriendNumber = self:getLabelByName("Label_num")
    -- self._label_FriendNumber:createStroke(Colors.strokeBrown, 1)
    self._label_FriendNumber2 = self:getLabelByName("Label_num_2")
    -- self._label_FriendNumber2:createStroke(Colors.strokeBrown, 1)
    self._label_presentGet = self:getLabelByName("Label_num_0")
    -- self._label_presentGet:createStroke(Colors.strokeBrown, 1)

    self._nonePanel = self:getPanelByName("Panel_none")
    self._nonePanel:setVisible(false)

    self:getLabelByName("Label_friend1"):setText(G_lang:get("LANG_FRIEND_NOFRIEND1"))
    self:getLabelByName("Label_friend2"):setText(G_lang:get("LANG_FRIEND_NOFRIEND2"))

    self:registerWidgetClickEvent("Image_qipao", function ( ... )
        local sug = require("app.scenes.friend.FriendSugListLayer").create()   
        uf_sceneManager:getCurScene():addChild(sug)
    end)

    -- local listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_test"), LISTVIEW_DIR_VERTICAL)
    -- listView:setCreateCellHandler(function ( list, index)
    --     return require("app.scenes.friend.FriendListCell").new(list, index)
    -- end)
    -- listView:setUpdateCellHandler(function ( list, index, cell)
    --     if  index < #self._friend then
    --        cell:updateData(list, index,self._friend[index+1]) 
    --     end
    -- end)
    -- listView:initChildWithDataLength( 0)
    -- self._llist = listView
    
    self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)

    -- self._views["CheckBox_friend"]:setUpdateCellHandler(function ( list, index, cell)
    --     local fl = G_Me.friendData:getFriendList();
    --     if cell ~= nil and index < table.getn(fl) then
    --         local f = fl[index+1]
    --         cell:updateData(list, index, f)
    --     end
    -- end)
        
    self:registerBtnClickEvent("Button_add", function(widget) 
        self:_addFriend()
        end)
    self:registerBtnClickEvent("Button_return", function(widget) 
        self:onBackKeyEvent()
        end)
    self:registerBtnClickEvent("Button_add_0", function(widget) 
        local CheckFunc = require("app.scenes.common.CheckFunc")
        if CheckFunc.checkSpiritFromFriend() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_FULL"))
            return
        end
        if #self:_getData("CheckBox_tili") == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_NONE"))
            return
        end
        if G_Me.friendData:getPresentLeft() == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_DONE"))
            return
        end
        G_HandlersManager.friendHandler:sendReceivePresent(0)
        end)
    self:registerBtnClickEvent("Button_sug", function(widget) 
        local sug = require("app.scenes.friend.FriendSugListLayer").create()   
        uf_sceneManager:getCurScene():addChild(sug)
        end)
    
    -- self:_createListView()
end

function FriendListLayer:onBackKeyEvent( ... )
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())

    return true
end

function FriendListLayer:_addFriend()
    if role_info.get(G_Me.userData.level).max_friend_num == #self._friends then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR4"))
        return
    end
    self:addChild(require("app.scenes.friend.FriendAddLayer").new("ui_layout/friend_FriendAddLayer.json"))
end

--选中了某个tab
function FriendListLayer:onCheckCallback(btnName)
    if not self._inited[btnName] then
        self._views[btnName]:initChildWithDataLength(#self:_getData(btnName))
    end
    self._inited[btnName] = 1
    self._checked = btnName
    self:_onRefresh()
    if btnName == "CheckBox_add" then
        G_HandlersManager.friendHandler:sendFriendAddInfo()
    end
    if self._checked == "CheckBox_friend" then 
        if #self:_getData("CheckBox_friend") == 0 then
            self._nonePanel:setVisible(true)
        else
            self._nonePanel:setVisible(false)
        end
    else
        self._nonePanel:setVisible(false)
    end
end

--创建tab
function FriendListLayer:_createTab(panelName, btnName,labelName,panelName2)
    self._views[btnName] = CCSListViewEx:createWithPanel(self:getPanelByName(panelName2), LISTVIEW_DIR_VERTICAL)
    self._tabs:add(btnName, self:getPanelByName(panelName),labelName)
    self:_initTabHandler(btnName)
end


--初始化tab的listview
function FriendListLayer:_initTabHandler(btnName)
    local listView = self._views[btnName] 
    listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.friend.FriendListCell").new(list, index)
    end)
    listView:setUpdateCellHandler(function ( list, index, cell)
        local data = self:_getData(btnName)
        if  index < #data then
           cell:updateData(list, index,data[index+1],btnName) 
        end
    end)
    listView:initChildWithDataLength( 0)

    -- --todo 如果想控制这个按钮在没有更多数据的时候不要显示怎么办?
    -- local postfix = CCSItemCellBase:create("ui_layout/mail_MailMoreCell.json")
    -- postfix:getLabelByName("Label_more"):setText(G_lang:get("LANG_MAIL_MORE"))
    -- postfix:registerBtnClickEvent("Button_more", function ( widget )
    --     __LogTag("ldx", "onClick")
    --     self._pager:getList()
    -- end)
    -- listView:setPostfixCell(postfix)

end

function FriendListLayer:onLayerEnter()
    self.super:onLayerEnter()
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_LIST, self._onFriendListRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_PRESENT_GIVE, self._onGivePresentRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_PRESENT_RECEIVE, self._onReceivePresentRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_REFRESH, self._onRefreshList, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_DELETE, self._onDelete, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_INFO, self._onCount, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_CONFIRM, self._onConfirm, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_REQUEST_LIST, self._onFriendAddListRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD_NOTIFY, self._onFriendAddNotifyRsp, self)
     
    G_HandlersManager.friendHandler:sendFriendList()
    G_HandlersManager.friendHandler:sendFriendsInfo()
    -- G_HandlersManager.friendHandler:sendFriendAddInfo()
    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then 
    --     local img = self:getImageViewByName("Image_12")
    --     if img then
    --         img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --     end
    -- end

    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_12"))
end

function FriendListLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function FriendListLayer:_getData(btnName)
    if btnName == "CheckBox_friend" then
        self._friends = G_Me.friendData:getFriendList()
        return self._friends
    elseif btnName == "CheckBox_tili" then
        self._friends = G_Me.friendData:getPresentFriendList()
        return self._friends
    elseif btnName == "CheckBox_black" then
        self._black = G_Me.friendData:getBlackList()
        return self._black
    else
        self._add = G_Me.friendData:getAddList()
        return self._add
    end
    return self._friends
end

function FriendListLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_content", "Panel_checkbox", "", 10, 0)
    self:adapterWidgetHeight("Panel_tiliList", "Panel_checkbox", "Panel_bot_0", 10, 0)
    self:adapterWidgetHeight("Panel_friendList", "Panel_checkbox", "Panel_bot", 10, 0)

    self:_createTab("Panel_friend", "CheckBox_friend","Label_friend","Panel_friendList")
    self:_createTab("Panel_tili", "CheckBox_tili","Label_tili","Panel_tiliList")
    self:_createTab("Panel_black", "CheckBox_black","Label_black","Panel_black")
    self:_createTab("Panel_add", "CheckBox_add","Label_add","Panel_add")
    self._tabs:checked("CheckBox_friend")
    
end

-- function FriendListLayer:_createListView( )
--     self._listview = CCSListViewEx:createWithPanel(self:getPanelByName("ListView_Friends"), LISTVIEW_DIR_VERTICAL)
--     --self._listview:setItemsMargin(20)
--     self._listview:setCreateCellHandler(function ( list, index)
--         return FriendListCell.new(list, index)
--     end)
--     self._listview:setUpdateCellHandler(function ( list, index, cell)
--         local fl = G_Me.friendData:getFriendList();
--         if cell ~= nil and index < table.getn(fl) then
--             local f = fl[index+1]
--             cell:updateData(list, index, f)
--         end
--     end)
    
    
--     --self._listview:initChildWithDataLength(0)
-- end

function FriendListLayer:_onFriendListRsp(data)
    -- dump(data)
    if data then
        if rawget(data, "friend") ~= nil then
            self._friends = data.friend
        else
            self._friends = {}
        end
        if rawget(data, "black") ~= nil then
            self._black = data.black
        else
            self._black = {}
        end
        local maxFri = role_info.get(G_Me.userData.level).max_friend_num
        self._label_FriendNumber:setText(G_lang:get("LANG_FRIEND_NUM"))
        self._label_FriendNumber2:setText(#self:_getData("CheckBox_friend").."/"..maxFri)
        self._views["CheckBox_friend"]:initChildWithDataLength(#self:_getData("CheckBox_friend"))
        self:showWidgetByName("Image_composeTips1",self:_showTiLi())
        if #self:_getData("CheckBox_friend") == 0 then
            self._nonePanel:setVisible(true)
        else
            self._nonePanel:setVisible(false)
        end
    else
        local maxFri = role_info.get(G_Me.userData.level).max_friend_num
        self._label_FriendNumber:setText(G_lang:get("LANG_FRIEND_NUM"))
        self._label_FriendNumber2:setText("0".."/"..maxFri)
        self._views["CheckBox_friend"]:initChildWithDataLength(0)
        self._nonePanel:setVisible(true)
    end
end

function FriendListLayer:_onGivePresentRsp(data)
    if data.ret == 1 then
        -- self:_onRefresh()
        self._views["CheckBox_friend"]:refreshAllCell()
        if self._checked == "CheckBox_friend" then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_SUCCESS"))
        elseif self._checked == "CheckBox_tili" then
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_RECEIVE2"))
        end
    end  

end

function FriendListLayer:_onReceivePresentRsp(data)
    if data.ret == 1 then
        self:_onRefresh()
        -- if not data.present then
        --     G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_RECEIVE1"))
        -- end
        if rawget(data, "present") ~= nil then
            if not data.present then
                G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_RECEIVE1"))
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_RECEIVE2"))
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_RECEIVE3",{times=#data.id}))
        end

    else
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_ERROR"))
    end
end


function FriendListLayer:_onRefreshList()
    G_HandlersManager.friendHandler:sendFriendList()
end

function FriendListLayer:_onDelete()
    self:_onRefresh()
end

function FriendListLayer:_onRefresh()
    if self._views["CheckBox_friend"] then
        self._views["CheckBox_friend"]:reloadWithLength(#self:_getData("CheckBox_friend"),self._views["CheckBox_friend"]:getShowStart())
        self._views["CheckBox_friend"]:refreshAllCell()
    end
    if self._views["CheckBox_tili"] then
        self._views["CheckBox_tili"]:reloadWithLength(#self:_getData("CheckBox_tili"),self._views["CheckBox_tili"]:getShowStart())
        self._views["CheckBox_tili"]:refreshAllCell()
    end
    if self._views["CheckBox_black"] then
        self._views["CheckBox_black"]:reloadWithLength(#self:_getData("CheckBox_black"),self._views["CheckBox_black"]:getShowStart())
        self._views["CheckBox_black"]:refreshAllCell()
    end
    if self._views["CheckBox_add"] then
        self._views["CheckBox_add"]:reloadWithLength(#self:_getData("CheckBox_add"),self._views["CheckBox_add"]:getShowStart())
        self._views["CheckBox_add"]:refreshAllCell()
    end

    -- if #self:_getData("CheckBox_friend") == 0 then
    --     self._nonePanel:setVisible(true)
    -- else
    --     self._nonePanel:setVisible(false)
    -- end
    if self._checked == "CheckBox_friend" then 
        if #self:_getData("CheckBox_friend") == 0 then
            self._nonePanel:setVisible(true)
        else
            self._nonePanel:setVisible(false)
        end
    else
        self._nonePanel:setVisible(false)
    end

    local maxFri = role_info.get(G_Me.userData.level).max_friend_num
    self._label_FriendNumber:setText(G_lang:get("LANG_FRIEND_NUM"))
    self._label_FriendNumber2:setText(#self:_getData("CheckBox_friend").."/"..maxFri)

    self:showWidgetByName("Image_composeTips1",self:_showTiLi())

    self:_onCount()
end

function FriendListLayer:_showTiLi()
    local list = self:_getData("CheckBox_tili")
    if #list > 0 and G_Me.friendData:getPresentLeft() > 0 then
        return true
    end
    return false
    -- return true
end

function FriendListLayer:_onCount(data)
    self._label_presentGet:setText(
        G_lang:get("LANG_FRIEND_PRESENTGET",{times=G_Me.friendData:getPresentLeft()}))
    self:showWidgetByName("Image_composeTips3",G_Me.friendData:getNewFriend())
end

function FriendListLayer:_onReqList(data)
    -- dump(data)
end

function FriendListLayer:_onConfirm(data)
    self:_onRefresh()
end

function FriendListLayer:_onFriendAddNotifyRsp(data)
    self:_onRefresh()
end

function FriendListLayer:_onFriendAddListRsp(data)
    if self._views["CheckBox_add"] then
        self._views["CheckBox_add"]:reloadWithLength(#self:_getData("CheckBox_add"))
        self._views["CheckBox_add"]:refreshAllCell()
    end
end


return FriendListLayer

