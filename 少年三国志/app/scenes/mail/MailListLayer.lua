
local MailListLayer = class ("MailListLayer", UFCCSNormalLayer)


function MailListLayer.create(...)   
    return MailListLayer.new("ui_layout/mail_MailListLayer.json", ...) 
end

function MailListLayer:ctor(json,checkType,...)
    self._checkType = checkType and checkType or 1
    self.super.ctor(self, ...)
    
    self._tabs = nil
    self._views = {}
    
    
end


function MailListLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_alllist", "Panel_nav", "", 10, 0)
    self:_initViews()
end

function MailListLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_PLAYINFO, self._onPlayerInfoRsp, self)
    self._pager = require("app.scenes.mail.MailPager").new(handler(self, self._onDataReady))
end

function MailListLayer:_onPlayerInfoRsp(data)
    if data.ret == 1 then
        local player = data.friend
        require("app.scenes.friend.FriendMailInputLayer").showInputLayer(self, "", 
                player.name, 
                player.mainrole, function ( text, send )
                if send then 
                    G_HandlersManager.friendHandler:sendMail(text,player.id)
                    -- self:close()
                end
            end)
    end
end

function MailListLayer:onLayerExit()
    self._pager:clear()
end

function MailListLayer:_initViews()

    -- 创建4个listview, 并跟4个按钮绑定成tabs
    if self._tabs == nil then
        self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
        self:_createTab("Panel_list_all", "CheckBox_all","Label_all2")
        self:_createTab("Panel_list_system", "CheckBox_system","Label_system2")
        self:_createTab("Panel_list_battle", "CheckBox_battle","Label_battle2")
        self:_createTab("Panel_list_social", "CheckBox_social","Label_social2")

        self:registerBtnClickEvent("Button_back", function()
            self:onBackKeyEvent()
        end)
    end
    if self._checkType == 1 then
        self._tabs:checked("CheckBox_all")
    elseif self._checkType == 2 then
        self._tabs:checked("CheckBox_system")
    elseif self._checkType == 3 then
        self._tabs:checked("CheckBox_battle")
    elseif self._checkType == 4 then
        self._tabs:checked("CheckBox_social")
    end
end

function MailListLayer:onBackKeyEvent( ... )
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())

    return true
end

---销毁函数
function MailListLayer:onLayerUnload( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

--创建tab
function MailListLayer:_createTab(panelName, btnName,labelName)
    self._views[btnName] = CCSListViewEx:createWithPanel(self:getPanelByName(panelName), LISTVIEW_DIR_VERTICAL)
    self._tabs:add(btnName, self._views[btnName],labelName)
    self:_initTabHandler(btnName)
end

--初始化tab的listview
function MailListLayer:_initTabHandler(btnName)
    local listView = self._views[btnName] 
    listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.mail.MailCell").new(list, index)
    end)
    listView:setUpdateCellHandler(function ( list, index, cell)
        if  index < #self._listData then
           cell:updateData(self._listData[index+1]) 
        end
    end)
    listView:setSelectCellHandler(function ( cell, index )
        -- __Log("index:%d", index)
    end)
    listView:initChildWithDataLength( 0)
    listView:setSpaceBorder(0,30)

    --todo 如果想控制这个按钮在没有更多数据的时候不要显示怎么办?
    local postfix = CCSItemCellBase:create("ui_layout/mail_MailMoreCell.json")
    postfix:getLabelByName("Label_more"):setText(G_lang:get("LANG_MAIL_MORE"))
    postfix:registerBtnClickEvent("Button_more", function ( widget )
        __LogTag("ldx", "onClick")
    	self._pager:getList()
    end)
    listView:setPostfixCell(postfix)
    listView:setShowMoreEnable(true)

    listView:setShowMoreHandler(function ( list, topLeft, bottomRight )
            __Log("topLeft:%d, bottomRight:%d", topLeft and 1 or 0, bottomRight and 1 or 0)
            if bottomRight then
                if self._pager:hasNextPage() then
                    self._pager:getList()
                end
            end
        end)

end




--数据准备完毕,开始显示
function MailListLayer:_onDataReady(listData)

    self._listData = listData

    local btnName = self._tabs:getCurrentTabName()     
    local listView = self._views[btnName] 
    
        
    local startIndex = self._pager:getLength() - self._pager:getPageRows() 
    if startIndex < 0 then
        startIndex = 0
    end
    listView:reloadWithLength( self._pager:getLength(), startIndex)
    
    if self._pager:hasNextPage() then
        listView:setShowPostfix(true)
    else
        listView:setShowPostfix(false)
    end
    

    if self._pager:getCurrentPage() == 1 then
       listView:refreshWithStart()
    end
end

--选中了某个tab
function MailListLayer:onCheckCallback(btnName)
    __LogTag("ldx", btnName)
    
    local tag = 0
    if btnName == "CheckBox_all" then
        tag = 0
    elseif btnName == "CheckBox_system" then
        tag = 1
    elseif btnName == "CheckBox_battle" then
        tag = 2
    elseif btnName == "CheckBox_social" then
        tag = 3
    end
    --初始化pager
  

    self._pager:setTag(tag)
    
    self._pager:getList()
 
end


return MailListLayer
