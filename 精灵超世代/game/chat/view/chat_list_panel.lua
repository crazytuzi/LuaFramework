--聊天滚动列表
--author:hp

ChatListPanel = ChatListPanel or class("ChatListPanel", function()
    return ccui.ScrollView:create()
end)

function ChatListPanel:ctor(size,root,is_priChat,show_model,channel)
    self.is_private_chat = is_priChat or false --是否是好友私聊情况
    self.root = root or self
    self.ctrl = ChatController:getInstance()
    self.sourceSize = size
    self.channel = channel
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)

    self.container = self:getInnerContainer()

    self:changeListModel(show_model or 1, true)
    self:setDirection(ccui.ScrollViewDir.vertical)
    self:setBounceEnabled(true)
    self:setClippingEnabled(true)
    self:setPropagateTouchEvents(true) 
    self:setScrollBarEnabled(false)
    self:createNewMessage()
    self:setInertiaScrollEnabled(false)
    self:initCtrl()
end

function ChatListPanel:initCtrl()
    self.stack_item = {}           --显示对象
    self.stack_max  = 20           --最多显示个数
    self.item_max = 7              --最多创建个数
    self.addNum  = 0               --添加个数
    self.minID   = 0               --最小ID
    self.maxID   = 0               --最大ID
    self.timeCD  = 0.3             --执行时间差
    self.is_init = false
    self.new_message_num = 0       --未读信息数量
    self.stack_pool = {} 

    -- 滚动检测
    self:addEventListenerScrollView(function(sender, event_type)
        if event_type == ccui.ScrollviewEventType.scrolling or event_type == ccui.ScrollviewEventType.bounceTop or event_type == ccui.ScrollviewEventType.bounceBottom then
            self:dynamicCheckItemVisible()
        elseif event_type == ccui.ScrollviewEventType.scrollToBottom then 
            self.new_message:setString("")
            self.msg_bg:setVisible(false)
            self:updateMsg()
        end
    end)
end

-- 数据源
function ChatListPanel:initData(data_list)
    self.data_list = data_list
    self:showMonkey(self.data_list:GetSize()==0)
end

-- 底部有新消息时的提示
function ChatListPanel:createNewMessage()
    local root = self.root
    self.msg_bg = ccui.Widget:create()
    self.msg_bg:setAnchorPoint(cc.p(0.5,0.5))
    self.msg_bg:setLocalZOrder(23)
    self.msg_bg:setPosition(cc.p(237, 20))
    self.msg_bg:setContentSize(cc.size(self.sourceSize.width,40))
    root:addChild(self.msg_bg)

    local res = PathTool.getResFrame("common", "common_1001")
    local arrow = createSprite(res, 315, self.msg_bg:getContentSize().height/2, self.msg_bg, cc.p(0,0.5), LOADTEXT_TYPE_PLIST)

    self.new_message = createRichLabel(20, Config.ColorData.data_color4[5], cc.p(0.5,0.5), cc.p(self.sourceSize.width/2,20), nil, nil, 400)
    self.new_message:setString("")
    self.msg_bg:addChild(self.new_message)
    self.msg_bg:setVisible(false)
end

-- 创建聊天数据，注:初始化调用
function ChatListPanel:createMsg(data_list, channel)
    if data_list == nil then return end
    self.channel = channel
    self.data_list = data_list
    local dataObj
    self.is_created = true
    self.init_h = self:getContentSize().height
    self:scrollToBottom(0, true)
    self:setVisible(true)
    self._start_list = data_list
    self.init_len = data_list:GetSize()
    self.init_height = 0
    local begin = 0
    if self.init_len > self.stack_max then
        begin = self.init_len - self.stack_max
    end
    for index=begin, self.init_len-1 do             
        delayRun(self, 0.01*(index), function ()
            if not self._start_list then return end
            local dataObj = self._start_list:Get(index)
            if not dataObj then return end
            
            if not self:checkItemIsShowById(dataObj.id) then
                local item, isPool = self:createItem(dataObj.id)
                item:setData(dataObj)

                if self.is_private_chat then
                    if index == 0 then
                        self.last_show_time = self._start_list:Get(0).talk_time or 0
                        item:setTiemVisible(true)
                    elseif index > 0 then
                        if not self.last_show_time then
                            self.last_show_time = self._start_list:Get(index).talk_time
                        end

                        local time_dis =  dataObj.talk_time - self.last_show_time 
                        if time_dis >= 60*5 then
                            self.last_show_time = dataObj.talk_time
                            ChatController:getInstance():getModel():setLastShowTime(self.last_show_time)
                            item:setTiemVisible(true)
                        else
                            item:setTiemVisible(false)
                        end
                        if index == self.init_len-1 then
                            self.last_show_time = dataObj.talk_time
                        end
                    end
                end

                self.init_height = self.init_height + item:getItemRealSize().height
                item:setPosition(0, self.init_height)
                if self.init_height >= self.init_h or isPool then
                    self:adjustItemPos()
                end
            end
            if index == self.init_len-1 then
                self.is_init = true
                self:updateMsg()
                GlobalEvent:getInstance():Fire(ChatEvent.EndCallBack)
            end
        end)
    end

    self:jumpToBottom()
    self:showMonkey(self.init_len==0)
end

--更新聊天数据
function ChatListPanel:updateMsg()
    if not self.data_list then return end
    local len = self.data_list:GetSize()
    local begin = 0
    if len > self.stack_max then
        begin = len - self.stack_max
    end
    for index=begin,len-1 do
        local dataObj = self.data_list:Get(index)
        if not self:checkItemIsShowById(dataObj.id) then         
            local item, isPool = self:createItem(dataObj.id)
            item:setData(dataObj)

            if self.is_private_chat then 
                if index == 0 then
                    self.last_show_time = self.last_show_time or dataObj.talk_time or 0
                    item:setTiemVisible(true)
                elseif index > 0 then
                    if not self.last_show_time then
                        self.last_show_time = dataObj.talk_time or 0
                    end
                    local time_dis =  dataObj.talk_time - self.last_show_time
                    if time_dis >= 60*5 then
                        self.last_show_time = dataObj.talk_time
                        item:setTiemVisible(true)
                    else
                        item:setTiemVisible(false)
                    end
                    if index == len-1 then
                        self.last_speak_time = dataObj.talk_time --打开窗口最后交谈的时间
                    end
                end
            end
        end
        self.new_message_num = self.new_message_num-1
        if self.new_message_num <=0 then
            self.new_message_num  = 0
        end
    end
    
    self.new_message:setString("")
    self.msg_bg:setVisible(false)
    self:adjustItemPos()

    self:showMonkey(len==0)
end

-- 调整位置
function ChatListPanel:adjustItemPos()
    local tempHeight, realHeight = 0, 0

    for key,item in pairs(self.stack_item) do 
        if not tolua.isnull(item) then 
            realHeight = realHeight + item:getItemRealSize().height
        end
    end
    --print("======realHeight===",self.sourceSize.height, realHeight,self:getInnerContainerSize().height)
    local scrollRealHeight = self:getContentSize().height
    realHeight = math.max(scrollRealHeight, realHeight)
    self:setInnerContainerSize(cc.size(self:getContentSize().width, realHeight))
    self:jumpToBottom()
    self.realHeight = self:getInnerContainerSize().height
    local length = #self.stack_item  
    local item, id
    self.minID = 0
    self.maxID = 0
    for i=1, length do
        local item_pos_y = 0
        if realHeight <= scrollRealHeight then
            item = self.stack_item[i]            
            item:setPosition(0, realHeight-tempHeight)  
            tempHeight = tempHeight + item:getItemRealSize().height
        else 
            item = self.stack_item[length-i+1]
            tempHeight = tempHeight + item:getItemRealSize().height
            item:setPosition(0, tempHeight) 
        end
        id = item:getId() or 0
        if id > self.maxID then
            self.maxID = id
        elseif id < self.minID then
            self.minID = id
        end
    end
    self:dynamicCheckItemVisible()
end

-- item 在显示区域之外则不渲染
function ChatListPanel:dynamicCheckItemVisible(  )
    self.stack_item = self.stack_item or {}
    local panel_size = self:getContentSize()
    local container_pos_y = self.container:getPositionY()
    local container_pos_y_abs = math.abs(container_pos_y)
    for k,item in pairs(self.stack_item) do
        local item_pos_y = item:getPositionY()
        if item_pos_y < container_pos_y_abs or (item_pos_y-item:getItemRealSize().height) > (container_pos_y_abs+panel_size.height) then
            item:setVisible(false)
        else
            item:setVisible(true)
        end
    end
end

--未读信息栏显隐
function ChatListPanel:showNewMessage(bool)
    if self.msg_bg then
        self.msg_bg:setVisible(bool)
    end
end

--创建聊天组件
function ChatListPanel:createItem(id)
    self:onScrollDelete()
    local is_pool = false
    local item = table.remove(self.stack_pool, 1)
    if not item then
        local width = self.sourceSize.width
        item = MainChatUiMsg.new(width, nil, width, self.channel)
        if self.is_private_chat then
            item:setTiemVisible(true)
        end
        self:addChild(item)
    else
        item:setVisible(true)
        is_pool = true
    end
    item:setId(id)
    self.stack_item[#self.stack_item+1] = item
    return item, is_pool
end

-- 检测删除聊天内容
function ChatListPanel:onScrollDelete()
    if #self.stack_item >= self.stack_max then
        local del_item = table.remove(self.stack_item, 1)
        del_item:setVisible(false)
        table.insert(self.stack_pool, del_item)
    end
end

-- 依据id检测对应的消息是否正在显示
function ChatListPanel:checkItemIsShowById( id )
    local isShow = false
    for k,item in pairs(self.stack_item) do
        if item and item:getId() == id then
            isShow = true
            break
        end
    end
    return isShow
end

-- 显示猴子
function ChatListPanel:showMonkey(bool)
    --[[if bool and self.channel==ChatConst.Channel.Gang and not RoleController:getInstance():getRoleVo():isHasGuild() then
       bool = false
    end 
    if not self.no_people then
            --没人说话
        local res = PathTool.getEmptyMark()
        self.no_img = createImage(self, res, self:getContentSize().width/2, self:getContentSize().height/2, cc.p(0.5,0.5), false, 1, false)
        self.no_img:setScale(1.2)
        self.no_people =  createLabel(24,Config.ColorData.data_color4[66],nil,self:getContentSize().width/2, self:getContentSize().height/2-90,TI18N("暂时没有人说话"),self)
        self.no_people:setAnchorPoint(cc.p(0.5,0.5))
    end
    self.no_people:setVisible(bool)
    self.no_img:setVisible(bool)--]]
end

-- 删除并缓存对象
function ChatListPanel:removeListItems()
    self:setVisible(false)
    self.minID   = 0
    self.maxID   = 0
end

-- 重新初始化
function ChatListPanel:reset()
    self:removeListItems()
    if self.stack_item and next(self.stack_item)~=nil then
        for k, v in pairs(self.stack_item) do
            if v and v["DeleteMe"]then
                v:DeleteMe()
            end
        end
    end
    self.stack_item = {}           --显示对象
    self.addNum  = 0               --添加个数
    self.minID   = 0
    self.maxID   = 0
    self:setInnerContainerSize(self.sourceSize)
    self:stopAllActions()
    self:removeAllChildren()
    self.monkey = nil
    self.no_people = nil
end

-- 控制显/隐
function ChatListPanel:SetEnabled(bool)
    self:setVisible(bool)
    self:setClippingEnabled(bool)
    if not bool then
        self:removeListItems()
    end
end

-- 判断是否同一个频道
function ChatListPanel:isSame(channel)
    return self.channel == channel
end

-- 改变显示模式
function ChatListPanel:changeListModel( showModel, isInit )
    local cur_view_type = MainuiController:getInstance():getMainChatBoxCurViewType()
    local chat_panel_heights = ChatConst.ChatPanelHeight[cur_view_type]
    self.show_model = showModel
    local newHeight = chat_panel_heights[showModel]
    if self.channel == ChatConst.Channel.Friend then
        newHeight = self.sourceSize.height
    end
    self:setContentSize(cc.size(self.sourceSize.width, newHeight))
    self:setInnerContainerSize(cc.size(self.sourceSize.width, newHeight))

    if not isInit then
        self:adjustItemPos()
    else
        self:dynamicCheckItemVisible()
    end
end