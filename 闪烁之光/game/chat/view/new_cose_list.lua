--聊天滚动列表
--author:hp

NewCoseList = NewCoseList or class("NewCoseList", function()
    return ccui.ScrollView:create()
end)

function NewCoseList:ctor(size,root,is_priChat)
    self.is_private_chat = is_priChat or false --是否是好友私聊情况
    self.root = root or self
    self.ctrl = ChatController:getInstance()
    self.sourceSize = size or cc.size(100, 100)
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)

    self:setContentSize(self.sourceSize)
    self:setInnerContainerSize(self.sourceSize)
    self:setDirection(ccui.ScrollViewDir.vertical)
    self:setBounceEnabled(true)
    self:setClippingEnabled(true)
    self:setPropagateTouchEvents(true) 
    self:setScrollBarEnabled(false)
    -- self:setItemsMargin(20)
    self:createNewMessage()
    self:setInertiaScrollEnabled(true)
    self:initCtrl()
    -- showLayoutRect(self)
end

function NewCoseList:initCtrl()
    self.stack_item = {}           --显示对象
    self.stack_max  = 40           --最多显示个数
    self.addNum  = 0               --添加个数
    self.minID   = 0               --最小ID
    self.maxID   = 0               --最大ID
    self.timeCD  = 0.3             --执行时间差
    self.is_init = false
    self.new_message_num = 0       --未读信息数量
    self.is_show_vip = true       -- 是否显示vip
    self.is_bottom = true
    self.scrolling_flag = false

    -- 滚动检测
    self:addEventListenerScrollView(function(sender, event_type)
        if event_type == ccui.ScrollviewEventType.autoscrollEnded then
            self.scrolling_flag = false
        end
        if event_type == ccui.ScrollviewEventType.scrollToBottom then
            self.new_message:setString("")
            self.msg_bg:setVisible(false)
            self.is_bottom = true
            if self.scrolling_flag == false then -- 避免一次滑动执行多次
                self.scrolling_flag = true
                self:updateMsg()
            end
        else
            self:dynamicCheckItemVisible()
            if event_type == ccui.ScrollviewEventType.bounceBottom then
                self.new_message:setString("")
                self.msg_bg:setVisible(false)
                self.is_bottom = true
                if self.scrolling_flag == false then -- 避免一次滑动执行多次
                    self.scrolling_flag = true
                    self:updateMsg()
                end
            elseif event_type == ccui.ScrollviewEventType.scrolling or event_type == ccui.ScrollviewEventType.bounceTop then
                self.is_bottom = false
            end
        end
    end)

    -- -- 触摸处理
    -- self:addTouchEventListener(function(sender, event_type)
    --     if event_type == ccui.TouchEventType.began or event_type == ccui.TouchEventType.moved then
    --         --self.is_locked = true
    --         self.factory:pause()
    --     else
    --         --self.is_locked = nil
    --         if self:isInitRunning() then return end
    --         self.factory:launch()
    --     end
    -- end)
end

-- 数据源
function NewCoseList:initData(data_list)
    self.data_list = data_list
    if not self:checkChatIsOpen() then
        local close_tips = ""
        if self.channel == ChatConst.Channel.Province then
            close_tips = TI18N("角色35级可见该频道聊天内容")
        end
        self:showMonkey(true, close_tips)
    else
        self:showMonkey(self.data_list:GetSize()==0)
    end
end

function NewCoseList:checkChatIsOpen(  )
    local is_open = true
    if self.channel and self.channel == ChatConst.Channel.Province then
        local province_config = Config.MiscData.data_const["province_level"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo or not province_config or role_vo.lev < province_config.val then
            is_open = false
        end
    end
    return is_open
end

function NewCoseList:createNewMessage()
    local msg_bg_size = cc.size(400, 43)
    self.msg_bg = createImage(self.root, PathTool.getResFrame("mainui", "mainui_2006"), 357, 112, cc.p(0.5, 0.5), true, 23, true)
    self.msg_bg:setCapInsets(cc.rect(17,30,1,4))
    self.msg_bg:setContentSize(msg_bg_size)
    self.msg_bg:setTouchEnabled(true)
    registerButtonEventListener(self.msg_bg, function (  )
        self:updateMsg(true)
    end, true)

    self.new_message = createRichLabel(20, cc.c4b(254,231,188,255), cc.p(0.5,0.5), cc.p(msg_bg_size.width/2, msg_bg_size.height/2), nil, nil, 400)
    self.new_message:setString("")
    self.msg_bg:addChild(self.new_message)
    self.msg_bg:setVisible(false)

    --self:showAtNotice(true)
end

-- 创建聊天数据，注:初始化调用
function NewCoseList:createMsg(data_list, channel)
    if data_list == nil then return end
    self.channel = channel
    self.data_list = data_list
    --Debug.info(data_list)
    local dataObj
    self.is_created = true
    self.init_h = self:getContentSize().height
    -- self:setInnerContainerSize(cc.size(self:getContentSize().width, self.init_h))
    self:scrollToBottom(0, true)
    self:setVisible(true)
    self.msg_bg:setVisible(false)
    self:deleteNotExitItem()
    self.new_message_num = 0
    self.is_bottom = true
    self._start_list = data_list
    self.init_len = data_list:GetSize()
    self.init_height = 0
    -- self.is_init = false
    --for index=self.init_len-1,0,-1 do 
   --local min = math.max(0,self.init_len-15)
    for index=0, self.init_len-1 do             
        -- delayRun(self, 0.05*(self.init_len-index-1), function ()
        delayRun(self, 0.01*(index), function ()
            if not self._start_list then return end
            local dataObj = self._start_list:Get(index)
            if not dataObj then return end
            local item = self.stack_item[dataObj.id]
            
            if not item then
               -- if self.is_init == true then
               --  self:removeAllChildren()
               --  self.stack_item = {}
               -- end
                item = self:createItem(dataObj.id)
                item:setData(dataObj, self.select_index==1)

                if self.is_private_chat then
                    if index == 0 then
                        self.last_show_time = self._start_list:Get(0).talk_time or 0
                        item:setTiemVisible(true)
                    elseif index > 0 then
                        if not self.last_show_time then
                            self.last_show_time = self._start_list:Get(index).talk_time
                            -- print("=======last_show_time================",self.last_show_time,index)
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

                self.stack_item[dataObj.id] = item
                self.addNum = self.addNum + 1
                self.init_height = self.init_height + item.root_wnd:getContentSize().height
                item:setPosition(0, self.init_height)
                --[[if self.init_height >= self.init_h then
                    self:adjustItemPos()
                end--]]
            end
            if index == self.init_len-1 then
                self.is_init = true
                self.is_bottom = true
                self:updateMsg()
                GlobalEvent:getInstance():Fire(ChatEvent.EndCallBack)
            end
        end)
    end

    self:jumpToBottom()
    self:adjustItemPos()
    --self:showMonkey(self.init_len==0)
    if not self:checkChatIsOpen() then
        local close_tips = ""
        if self.channel == ChatConst.Channel.Province then
            close_tips = TI18N("角色35级可见该频道聊天内容")
        end
        self:showMonkey(true, close_tips)
    else
        self:showMonkey(self.init_len==0)
    end
end
--更新聊天数据
function NewCoseList:updateMsg(force)
    if not self.data_list then return end
    if not force and not self.is_show_monkey and self.is_bottom == false then
        if self:isShowNewMsgChannel(self.channel) == true then
            self.msg_bg:setVisible(true)
            self.new_message_num = self.new_message_num+1
            self.new_message:setString(string.format("<div click='xxx' outline=2,#000000>%s条未读信息  </div><img src='%s'/>",self.new_message_num, PathTool.getResFrame("mainui","mainui_2007")))
            return
        end
        --message("有信息来啦")
    end
    self:deleteNotExitItem()
    local len = self.data_list:GetSize()
    local num = self.new_message_num
    local begin = len-num-1
    if begin <=0 then
        begin = 0
    end
    for index=begin,len-1 do 
        local dataObj = self.data_list:Get(index)
        if not self.stack_item[dataObj.id] then            
            local item = self:createItem(dataObj.id)
            item:setData(dataObj, self.select_index==1)

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
            self.stack_item[dataObj.id] = item
            self.addNum = self.addNum + 1
        end
        self.new_message_num = self.new_message_num-1
        if self.new_message_num <=0 then
            self.new_message_num  = 0
        end
    end
    
    self.new_message:setString("")
    self.msg_bg:setVisible(false)
    self:adjustItemPos()

    --self:showMonkey(len==0)
    if not self:checkChatIsOpen() then
        local close_tips = ""
        if self.channel == ChatConst.Channel.Province then
            close_tips = TI18N("角色35级可见该频道聊天内容")
        end
        self:showMonkey(true, close_tips)
    else
        self:showMonkey(len==0)
    end
end

function NewCoseList:deleteNotExitItem(  )
    if not self.data_list then return end
    local len = self.data_list:GetSize()

    local key_table = {} 
    for key,_ in pairs(self.stack_item) do  
        table.insert(key_table,key)  
    end
    if #key_table > 0 then
        table.sort(key_table)
        for i=#key_table,1,-1 do
            local id = key_table[i]
            local item = self.stack_item[id]
            local is_have = false
            for index=0,len-1 do
                local dataObj = self.data_list:Get(index)
                if dataObj.id == id then
                    is_have = true
                    break
                end
            end
            if is_have == false then
                self.addNum = self.addNum - 1
                item:removeAllChildren()
                item:removeFromParent()
                self.stack_item[id] = nil
            end
        end
    end
end

-- 调整位置
function NewCoseList:adjustItemPos()
    local tempHeight, realHeight = 0, 0
    --对key进行排序
    local key_table = {}
    for key,item in pairs(self.stack_item) do 
        if not tolua.isnull(item.root_wnd) and item.root_wnd:isVisible() then 
            table.insert(key_table,key)
            realHeight = realHeight + item.root_wnd:getContentSize().height
        end
    end
    --print("======realHeight===",self.sourceSize.height, realHeight,self:getInnerContainerSize().height)
    realHeight = math.max(self.sourceSize.height, realHeight)
    self:setTouchEnabled(realHeight>self.sourceSize.height)
    self:setInnerContainerSize(cc.size(self:getContentSize().width, realHeight))  
    if realHeight >= self.sourceSize.height and self:getInnerContainerSize().height <= realHeight then    
        self:jumpToBottom()
    end
    self.realHeight = self:getInnerContainerSize().height
    table.sort(key_table)
    local length = #key_table  
    local item, id
    self.minID = 0
    self.maxID = 0
    for i=1, length do
        if realHeight <= self.sourceSize.height then
            item = self.stack_item[key_table[i]]            
            item:setPosition(0, realHeight-tempHeight)  
            tempHeight = tempHeight + item.root_wnd:getContentSize().height  
        else 
            item = self.stack_item[key_table[length-i+1]]
            tempHeight = tempHeight + item.root_wnd:getContentSize().height
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
function NewCoseList:dynamicCheckItemVisible(  )
    self.stack_item = self.stack_item or {}
    local panel_size = self:getContentSize()
    local container = self:getInnerContainer()
    local container_pos_y = container:getPositionY()
    local container_pos_y_abs = math.abs(container_pos_y)
    for k,item in pairs(self.stack_item) do
        local item_pos_y = item:getPositionY()
        if (container_pos_y < 0 and item_pos_y < container_pos_y_abs) or (item_pos_y-item:getItemRealSize().height) > (container_pos_y_abs+panel_size.height) then
            item:setVisible(false)
        else
            item:setVisible(true)
        end
    end
end

--未读信息栏显隐
function NewCoseList:showNewMessage(bool)
    if self.msg_bg then
        self.msg_bg:setVisible(bool)
    end
end
--创建聊天组件
function NewCoseList:createItem(id)
    self:onScrollDelete()
    local item, is_pool
    item = self.stack_item[id]
    if not item then
        local width = self.sourceSize.width
        item = ChatMsg.new(width)
        if self.is_private_chat then
            item:setTiemVisible(true)
        end
        item:setId(id)
        self:addChild(item)
        self.stack_item[id] = item
    else
        item:setVisible(true)
        is_pool = true
    end
    -- self:forceDoLayout()--刷新列表数据及位置
    -- self:jumpToBottom()
    return item, is_pool
end

-- 检测删除聊天内容
function NewCoseList:onScrollDelete()
    if self.addNum >= self.stack_max then
        local key_table = {}
        local tar_table = {}  
        for key,_ in pairs(self.stack_item) do  
            table.insert(key_table,key)  
        end  
        table.sort(key_table)
        if #key_table > 0 then
            local key_str = key_table[1]
            local del_item = self.stack_item[key_str]
            self.addNum = self.addNum - 1
            del_item:removeAllChildren()
            del_item:removeFromParent()
            self.stack_item[key_str] = nil
        end
    end
end

-- 显示猴子
function NewCoseList:showMonkey(bool, close_tips)
    if bool and self.channel==ChatConst.Channel.Gang and not RoleController:getInstance():getRoleVo():isHasGuild() then
       bool = false
    end 
    if not self.no_people then
            --没人说话
        local res = PathTool.getEmptyMark()
        self.no_img = createImage(self, res, self:getContentSize().width/2, self:getContentSize().height/2, cc.p(0.5,0.5), false, 1, false)
        self.no_img:setScale(1.2)
        self.no_people =  createLabel(26,cc.c4b(0x7a,0x60,0x41,0xff),nil,self:getContentSize().width/2, self:getContentSize().height/2-90,close_tips or TI18N("暂时没有人说话"),self)
        self.no_people:setAnchorPoint(cc.p(0.5,0.5))
    end
    self.no_people:setVisible(bool)
    self.no_img:setVisible(bool)
    self.is_show_monkey = bool
    if bool == true then
        self.is_bottom = true
        self.new_message_num = 0
        self.msg_bg:setVisible(false)
    end
end

-- 删除并缓存对象
function NewCoseList:removeListItems()
    -- for k, v in pairs(self.stack_item) do
    --     if v then
    --         v:setVisible(false)
    --     end
    -- end
    self:setVisible(false)
    self.minID   = 0
    self.maxID   = 0
end

-- 重新初始化
function NewCoseList:reset()
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
    self.no_img = nil
    self.no_people = nil
    --self:showMonkey(true)
end

-- 控制显/隐
function NewCoseList:SetEnabled(bool)
    self:setClippingEnabled(bool)
    self:setVisible(bool)
    if not bool then
        self:removeListItems()
    end
end

-- 判断是否同一个频道
function NewCoseList:isSame(channel)
    return self.channel == channel
end

-- 判断是否是聊天频道#
function NewCoseList:isShowNewMsgChannel(channel)
    if channel==ChatConst.Channel.Gang
        or channel==ChatConst.Channel.World
        or channel == ChatConst.Channel.Province
        or channel == ChatConst.Channel.Cross then
        return true
    end
    return false
end