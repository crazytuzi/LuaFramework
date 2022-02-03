--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月2日
-- @description    : 
        -- 公会宝库记录信息
---------------------------------
GuildmarketplaceRecordInfoPanel = GuildmarketplaceRecordInfoPanel or BaseClass(BaseView)

local controller = GuildmarketplaceController:getInstance()
local model = controller:getModel()

local string_format = string.format
local table_insert = table.insert

function GuildmarketplaceRecordInfoPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        
    }
    self.layout_name = "guildmarketplace/guildmarketplace_record_info_panel"


    self.record_item_list = {} --日志列表
end

function GuildmarketplaceRecordInfoPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("交易记录"))

    self.close_btn = main_panel:getChildByName("close_btn")
    
    self.bg = self.main_container:getChildByName("bg")

    self.img_day_bg = self.main_container:getChildByName("img_day_bg")
    self.txt_cur_day = self.main_container:getChildByName("txt_cur_day")
    self.txt_cur_day:setString("")

    local background_size = self.bg:getContentSize()
    self.scroll_view_size = cc.size(background_size.width, background_size.height - 10)
    self.scroll_view_height = self.scroll_view_size.height
    self.scroll_view = createScrollView(self.scroll_view_size.width, self.scroll_view_size.height, 0, 5, self.bg, ccui.ScrollViewDir.vertical)
    self.scroll_container = self.scroll_view:getInnerContainer() 
end

function GuildmarketplaceRecordInfoPanel:register_event(  )
    registerButtonEventListener(self.background, function() controller:openGuildmarketplaceRecordInfoPanel(false) end,false, 2)
    registerButtonEventListener(self.close_btn, function() controller:openGuildmarketplaceRecordInfoPanel(false) end ,true, 2)

        --记录信息刷新
    self:addGlobalEvent(GuildmarketplaceEvent.GUILD_MARKET_PLACE_MESSAGE_EVENT, function(scdata)
        if not scdata then return end
        self.message_data = scdata
        self:updateNoticeList()
    end)

end


function GuildmarketplaceRecordInfoPanel:openRootWnd(setting)
    local setting = setting or {}

    self.message_data = setting.message_data 
    if not self.message_data then
        return
    end
    self:updateNoticeList()
end

--初始化数据 分好天数
function GuildmarketplaceRecordInfoPanel:initData()
    self.day_message_list = {}
    local dic_day_list = {}
    table.sort(self.message_data.board_list,  function(a, b) return a.unixtime > b.unixtime end)
    local cur_key = nil
    local message_list = nil
    
    for i,v in ipairs(self.message_data.board_list) do
        v.key_time = TimeTool.getMD3(v.unixtime) --日期格式 06-08
        if cur_key == nil or cur_key ~= v.key_time then
            if message_list then
                table_insert(self.day_message_list, message_list)
            end
            cur_key = v.key_time
            message_list = {}
        end
        if v.type == GuildmarketplaceConst.RewardRecordType.ePlay or  --玩家操作类型 
           v.type == GuildmarketplaceConst.RewardRecordType.eSystem then --2公会宝库系统(针对过期的)
            local reward_list = v.reward_list
            v.reward_list = nil
            for i,reward in ipairs(reward_list) do
                local data = DeepCopy(v)
                data.reward_list = {reward}
                table_insert(message_list, data)
            end
            v.reward_list = reward_list
        else
            table_insert(message_list, v)
        end

    end

    table_insert(self.day_message_list, message_list)
end

--刷新公告列表
function GuildmarketplaceRecordInfoPanel:updateNoticeList(index)
    if not self.message_data then
        return
    end
    self:initData()
    if not self.day_message_list then return end

    if next(self.day_message_list) == nil then
        commonShowEmptyIcon(self.bg , true, {text = TI18N("暂无记录信息")})
        self.txt_cur_day:setString(TimeTool.getMD3(os.time()))
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
    else
        commonShowEmptyIcon(self.bg, false)
        self.img_day_bg:setVisible(false)
        self.txt_cur_day:setString("")
        if self.scroll_view then
            self.scroll_view:setVisible(true)
        end
    end

    if self.record_item_list and next(self.record_item_list) ~= nil then
        for _,item in pairs(self.record_item_list) do
            item:setVisible(false)
        end
        local con_size = cc.size(self.scroll_view_size.width, self.scroll_view_size.height)
        self.scroll_view:setInnerContainerSize(con_size)
        self.scroll_view:jumpToTop()
    end

    local height = 0
    local last_y = 0
    local dealey = 1
    for i,v in ipairs(self.day_message_list) do
        delayRun(self.scroll_view, dealey / display.DEFAULT_FPS,function ()
            local item = self.record_item_list[i]
            if item == nil then
                item = GuildRecordItem.new()
                self.scroll_container:addChild(item)
                self.record_item_list[i] = item
            end
            item:setVisible(true)
            item:setData(v)

            local pos_y = self.scroll_view_height - last_y
            item:setPosition(cc.p(5, pos_y))
            

            item:addEndCallback(function()
                last_y = last_y + item.total_height
                height = height + item.total_height
                if height > self.scroll_view_size.height then
                    self:adjustScrollViewSize(height)
                end
            end)
            
        end)
        dealey = dealey + #v + 2
    end
end

function GuildmarketplaceRecordInfoPanel:adjustScrollViewSize(height)
    local max_height = math.max(height, self.scroll_view_size.height)
    local container_size = cc.size(self.scroll_view_size.width, max_height)
    self.scroll_view_height = container_size.height
    self.scroll_view:setInnerContainerSize(container_size)
    if height >= self.scroll_view_size.height then
        self.scroll_view:setTouchEnabled(true)
    end
    local last_y = 0
    for _,item in ipairs(self.record_item_list) do
        local pos_y = self.scroll_view_height - last_y
        item:setPosition(cc.p(5, pos_y))
        last_y = last_y + item.total_height
    end
end

function GuildmarketplaceRecordInfoPanel:close_callback()
    for k,v in pairs(self.record_item_list) do
        v:DeleteMe()
        v = nil
    end

    self.scroll_view:stopAllActions()
    controller:openGuildmarketplaceRecordInfoPanel(false)
end

-- -------------------------------------------------------------------
-- @author: zj@qqg.com
-- @description: 记录子项
-- --------------------------------------------------------------------
GuildRecordItem = class("GuildRecordItem", function()
    return ccui.Layout:create()
end)

function GuildRecordItem:ctor()
    self.size = cc.size(610, 200)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0, 1))
    self.total_height = self.size.height
    self:layoutUI()
    self.is_init = true
    self.label_list = {} --文本数据列表
end

function GuildRecordItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    self.img_time_bg = createImage(self.container, PathTool.getResFrame("common","common_90025"), 0, self.size.height, cc.p(0, 1), true, 1, true)
    self.img_time_bg:setContentSize(cc.size(self.size.width, 44))

    self.day_label = createRichLabel(24, cc.c4b(0xff,0xf2,0xc7,0xff), cc.p(0, 0.5), cc.p(11, 22))
    self.day_label:setString("")
    self.img_time_bg:addChild(self.day_label)
end

function GuildRecordItem:addEndCallback(callback)
    self.callback = callback
end

function GuildRecordItem:setData(message_list)
    self.message_list = message_list

    for k,list in pairs(self.label_list) do
        if list.item then
            list.item:setVisible(false)
        end
    end

    if message_list and next(message_list) ~= nil then
        self.total_height = 50
        local line_space = 6
        --设置日期
        self.day_label:setString(message_list[1].key_time)
        local temp_height = 0
        for k,v in ipairs(message_list) do
            delayRun(self.container, k / display.DEFAULT_FPS,function ()
                local list = self.label_list[k]
                if not list then
                    list = self:createOneNotice()
                    self.label_list[k] = list
                end
                if list.item then
                    local time, str = self:getMessageStrByData(v)
                    list.item:setVisible(true)
                    list.time_label:setString(time)
                    list.content_label:setString(str)
                    list.height = list.content_label:getContentSize().height
                    list.item:setPosition(cc.p(10, 150 - temp_height))
                    temp_height = temp_height + list.height + line_space
                    self.total_height = self.total_height + list.height + line_space
                    if k == #message_list and self.callback then
                        self.callback()
                    end
                end
            end)
        end
    end
end

--初始化信息内容
function GuildRecordItem:getMessageStrByData(v)
    local str = ""
    if v.type == GuildmarketplaceConst.RewardRecordType.ePlay then ----玩家操作类型 
        for i,reward in ipairs(v.reward_list) do
            local item_config = Config.ItemData.data_get_data(reward.base_id)
            if item_config then
                local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                if v.operation == 1 then --放入
                    str = string_format(TI18N(" <div fontcolor=#249003>%s</div>放入<div fontcolor=%s>%sx%s</div>"), v.name, color, item_config.name, reward.num)
                elseif v.operation == 2 then --兑换
                    str = string_format(TI18N(" <div fontcolor=#249003>%s</div>兑换<div fontcolor=%s>%sx%s</div>"), v.name, color, item_config.name, reward.num)
                end
            end
        end
    elseif v.type == GuildmarketplaceConst.RewardRecordType.eSystem then --2公会宝库系统(针对过期的)
         for i,reward in ipairs(v.reward_list) do
            local item_config = Config.ItemData.data_get_data(reward.base_id)
            if item_config then
                local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                if v.operation == 3 then --过期
                    str = string_format(TI18N(" <div fontcolor=%s>%sx%s</div>已过期下架"), color, item_config.name, reward.num)
                end
            end
        end
    else --剩下是其他玩法放入的
        if v.operation == 1 then --放入
            str = model:getStrByType(v.type, v.name)

            for i,reward in ipairs(v.reward_list) do
                local item_config = Config.ItemData.data_get_data(reward.base_id)
                if item_config then
                    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                    local str1 = string_format("\n <div fontcolor=%s>%sx%s</div>", color, item_config.name, reward.num)
                    str = str .. str1
                end
            end
        end
    end
    return TimeTool.getHM(v.unixtime), str
end

function GuildRecordItem:createOneNotice()
    local layout = ccui.Layout:create()
    local size = cc.size(560, 30)
    layout:setAnchorPoint(cc.p(0, 1))
    layout:setContentSize(size)
    self.container:addChild(layout)

    local time_label = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(10, size.height))
    layout:addChild(time_label)

    local content_label = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(80, size.height), 5, 0, 500)
    layout:addChild(content_label)

    local list = {}
    list.item = layout
    list.time_label = time_label
    list.content_label = content_label
    list.height = size.height
    return list
end

function GuildRecordItem:DeleteMe()
    self.container:stopAllActions()
    self:removeAllChildren()
    self:removeFromParent()
end 