-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会宝库主界面 后端 国辉 策划 松岳
-- <br/>Create: 2019年9月4日 
GuildmarketplaceMainWindow = GuildmarketplaceMainWindow or BaseClass(BaseView)

local controller = GuildmarketplaceController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor
local math_random = math.random
local math_randomseed = math.randomseed

function GuildmarketplaceMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildmarketplace", "guildmarketplace"), type = ResourcesType.plist}
    }
    self.layout_name = "guildmarketplace/guildmarketplace_main_window"

    self.tab_list = {}

    --self.dic_marketplace_id[id] = data
    self.dic_marketplace_id = {}

    --self.dic_list_data[index] = {data1, data2}
    self.dic_list_data = {}

    --限购信息 -- self.dic_limit_buy[base_id] = count
    self.dic_limit_buy = {}

    --记录放入的信息.. 放入界面用
    self.record_put_message = {}
    --信息列表
    self.message_label_list = {}
    self.role_vo = RoleController:getInstance():getRoleVo()

    --勇者凭证id
    self.guild_change_item_id = 36
    local config = Config.GuildMarketplaceData.data_const.guild_change_item_id
    if config then
        self.guild_change_item_id = config.val
    end

    --action_1间隔时间
    self.chat_Interval_time = 5
    local config = Config.GuildMarketplaceData.data_const.chat_Interval_time
    if config then
        self.chat_Interval_time = config.val
    end
    --action_1跳转action_2间隔时间    
    self.change_action_time = 5
    local config = Config.GuildMarketplaceData.data_const.change_action_time
    if config then
        self.change_action_time = config.val
    end
    --action_2保持时间    
    self.action_keep_time1 = 5
    local config = Config.GuildMarketplaceData.data_const.action_keep_time1
    if config then
        self.action_keep_time1 = config.val
    end
    --action_3保持时间    
    self.action_keep_time2 = 5
    local config = Config.GuildMarketplaceData.data_const.action_keep_time2
    if config then
        self.action_keep_time2 = config.val
    end

    --动作1 和动作2 的时间步伐
    self.action_time_step_1 = 0
    self.action_time_step_2 = 0
end

function GuildmarketplaceMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildmarketplace", "guildmarketplace_bg", false)
    self.item_load_bg = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load_bg) 


    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    self.close_btn = self.container:getChildByName("close_btn")
    self.look_btn = self.container:getChildByName("look_btn")

    self.top_panel = self.container:getChildByName("top_panel")


    self.record_img = self.top_panel:getChildByName("record_img")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildmarketplace", "guildmarketplace_record_bg", false)
    self.item_load_record_bg = loadSpriteTextureFromCDN(self.record_img, bg_res, ResourcesType.single, self.item_load_record_bg)

    self.chat_img = self.top_panel:getChildByName("chat_img")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildmarketplace", "guildmarketplace_chat_bg", false)
    self.item_load_chat_bg = loadSpriteTextureFromCDN(self.chat_img, bg_res, ResourcesType.single, self.item_load_chat_bg) 

    self.chat_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(358, 76),nil,nil,170)
    self.top_panel:addChild(self.chat_label)
    self.chat_label:setString(TI18N("欢迎光临"))

    self.record_info_btn = createRichLabel(22, cc.c4b(0x15,0x7e,0x22,0xff), cc.p(0.5, 0.5), cc.p(306, -148))
    self.record_info_btn:setString(string_format("<div href=xxx>%s</div>", TI18N("查看详情")))
    self.record_info_btn:addTouchLinkListener(function(type, value, sender, pos)
        controller:openGuildmarketplaceRecordInfoPanel(true, {message_data = self.message_data})
    end, { "click", "href" })
    self.top_panel:addChild(self.record_info_btn)

    --看板娘node
    self.spine_btn = self.top_panel:getChildByName("spine_btn") --看板娘触摸范围

    self.spine_node = self.top_panel:getChildByName("spine_node")
    self.spine_node:setPosition(547, -287)
    self.role_spine = createEffectSpine("E24126",cc.p(0,0),cc.p(0.5, 0.5), true, PlayerAction.action_1)
    self.spine_node:addChild(self.role_spine)
    self:initSpineTime()

    self.lay_bg = self.top_panel:getChildByName("lay_bg")
    self.lay_srollview = self.top_panel:getChildByName("lay_srollview")
    self.tab_container = self.top_panel:getChildByName("tab_container")

    local tab_name_list = {
        [1] = TI18N("碎片"),
        [2] = TI18N("装备"),
        [3] = TI18N("符文"),
        [4] = TI18N("道具"),
    }
    self.tab_index_type = {
        [1] = GuildmarketplaceConst.BagType.eHero,
        [2] = GuildmarketplaceConst.BagType.eEquips,
        [3] = GuildmarketplaceConst.BagType.eSpecial,
        [4] = GuildmarketplaceConst.BagType.eProps,
    }
    self.tab_type_index = {}
    for k,v in pairs(self.tab_index_type) do
        self.tab_type_index[v] = k
    end

    for i=1,4 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_img')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('normal_img')
            object.label = tab_btn:getChildByName("label")
            object.label:setTextColor(cc.c4b(0x64,0x32,0x23,0xff))
            if tab_name_list[i] then
                object.label:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end
    
    self.put_btn = self.top_panel:getChildByName("put_btn")
    self.put_btn_label = self.put_btn:getChildByName("label")
    self.put_btn_label:setString(TI18N("放入物品"))

    self.top_panel:getChildByName("record_title"):setString(TI18N("交易记录"))

    -- 拥有道具
    self.item_bg = self.top_panel:getChildByName("item_bg")
    self.item_icon = self.item_bg:getChildByName("icon")
    self.item_count = self.item_bg:getChildByName("count")

    local config = Config.ItemData.data_get_data(self.guild_change_item_id)
    if config then
        local head_icon = PathTool.getItemRes(config.icon, false)
        loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE)
    end


    self.sprite_img = self.top_panel:getChildByName("sprite_img")
    self.sprite_img2 = self.top_panel:getChildByName("sprite_img2")

    --信息的scroll
    self.message_size = cc.size(300, 110)
    self.message_scroll_view = createScrollView(self.message_size.width, self.message_size.height, 38, -136, self.top_panel, ScrollViewDir.vertical) 
    -- self.message_scroll_view:setName("message_scroll_view")
    self:adaptationScreen()
end

--设置适配屏幕
function GuildmarketplaceMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    local left_x = display.getLeft(self.container)
    local right_x = display.getRight(self.container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    -- local bottom_panel_y = self.bottom_panel:getPositionY()
    -- self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

    local size = self.lay_bg:getContentSize()
    local height = (top_y - self.container_size.height) - bottom_y
    self.lay_bg:setContentSize(cc.size(size.width, size.height + height))
    local lay_size = self.lay_srollview:getContentSize()
    self.lay_srollview:setContentSize(cc.size(lay_size.width, lay_size.height + height))

    local _y = self.put_btn:getPositionY()
    self.put_btn:setPositionY(_y - height)
    _y = self.item_bg:getPositionY()
    self.item_bg:setPositionY(_y - height)
    _y = self.sprite_img:getPositionY()
    self.sprite_img:setPositionY(_y - height)
    _y = self.sprite_img2:getPositionY()
    self.sprite_img2:setPositionY(_y - height)
    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end


function GuildmarketplaceMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
   
    registerButtonEventListener(self.put_btn, handler(self, self.onClickPutBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.spine_btn, handler(self, self.onClickSpineBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.look_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    for _, tab in ipairs(self.tab_list) do
       registerButtonEventListener(tab.tab_btn, function() self:changeSelectedTab(tab.index) end ,false, 2) 
    end

    self:addGlobalEvent(GuildmarketplaceEvent.GUILD_MARKET_PLACE_ITEM_EVENT, function(scdata)
        if not scdata then return end
        self:setScdata(scdata)
    end)

    --记录信息刷新
    self:addGlobalEvent(GuildmarketplaceEvent.GUILD_MARKET_PLACE_MESSAGE_EVENT, function(scdata)
        if not scdata then return end
        self.message_data = scdata
        self:updateMessageInfo(scdata)
        GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_MESSAGE_EVENT2, self.message_data)
    end)


    --    --  增加物品的更新,红点
    -- self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, add_list)
    --     self:updateItemInfo()
    -- end)

    -- -- 删除一个物品更新,红点
    -- self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
    --     self:updateItemInfo()
    -- end)

    -- self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,change_list)
    --     self:updateItemInfo()
    -- end)

    -- 金币更新
    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
            if key == "brave_symbol" then 
                self:updateItemInfo()
            end
        end)
    end
end

-- 关闭
function GuildmarketplaceMainWindow:onClickCloseBtn(  )
    controller:openGuildmarketplaceMainWindow(false)
end
-- 打开规则说明
function GuildmarketplaceMainWindow:onClickRuleBtn(  )
    MainuiController:getInstance():openCommonExplainView(true, Config.GuildMarketplaceData.data_explain)
end

-- 放入
function GuildmarketplaceMainWindow:onClickPutBtn(  )
    if not self.message_data then return end
    controller:openGuildmarketplacePutItemWindow(true, {message_data = self.message_data})
end

-- 看板娘按钮
function GuildmarketplaceMainWindow:onClickSpineBtn(  )
    if self.is_keep_action_3 then return end

    self.is_keep_action_3 = true
    self.top_panel:stopAllActions()
    self.role_spine:setAnimation(0, PlayerAction.action_3, true)
    self:setChatByAction(3)
    delayRun(self.top_panel, self.action_keep_time2, function()
        self.is_keep_action_3 = false
        self:clearActionTime()
        self.action_time_step_1 = self.chat_Interval_time
        self.role_spine:setAnimation(0, PlayerAction.action_1, true)
        self:setChatByAction(1)
    end)
end

function GuildmarketplaceMainWindow:initSpineTime()
    self:clearActionTime()
    if self.time_ticket == nil then
        local _callback = function()
            if not self.role_spine then return end
            --在动作2动作3的时候
            if self.is_keep_action_2 or self.is_keep_action_3 then return end

            self.action_time_step_1 = self.action_time_step_1 + 1
            self.action_time_step_2 = self.action_time_step_2 + 1
            if self.action_time_step_2 >= self.change_action_time then
                --动作 1到动作2
                self.is_keep_action_2 = true
                self.top_panel:stopAllActions()
                self.role_spine:setAnimation(0, PlayerAction.action_2, true)
                self:setChatByAction(2)
                delayRun(self.top_panel, self.action_keep_time1, function()
                    self.is_keep_action_2 = false
                    self:clearActionTime()
                    self.action_time_step_1 = self.chat_Interval_time
                    self.role_spine:setAnimation(0, PlayerAction.action_1, true)
                    self:setChatByAction(1)
                end)
            elseif self.action_time_step_1 >=  self.chat_Interval_time then
                -- 动作1的间隔
                self:setChatByAction(1)
                self.action_time_step_1 = 0
            end
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 1)
    end
end
--设置聊天内容
function GuildmarketplaceMainWindow:setChatByAction(action_id)
    local config_list = Config.GuildMarketplaceData.data_landlady_info[action_id]
    if config_list then
        --总权重
        local max_weight = 0
        for i,v in ipairs(config_list) do
            max_weight = max_weight + v.weight
        end
        if max_weight <= 1 then return end
        --拿当前时间做种子..
        math_randomseed(os.time())
        --随机数
        local num = math_random(1, max_weight)
        local cur_weight = 0
        for i,v in ipairs(config_list) do
            --随机数落谁家
            if num > cur_weight and num <= (cur_weight + v.weight) then
                if self.chat_label then
                    self.chat_label:setString(v.content)
                end
                return 
            end
            cur_weight = cur_weight + v.weight
        end
    end
end

function GuildmarketplaceMainWindow:clearActionTime()
    self.action_time_step_1 = 0
    self.action_time_step_2 = 0
end

function GuildmarketplaceMainWindow:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

-- 切换标签页
function GuildmarketplaceMainWindow:changeSelectedTab(index, not_check)
    if not not_check and self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.label:setTextColor(cc.c4b(0x64,0x32,0x23,0xff))
        self.tab_object = nil
    end
    self.tab_index = index
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.label:setTextColor(cc.c4b(0x9b,0x43,0x09,0xff))
    end
    self.show_list = self.dic_list_data[index] or {}
    self:updateItemlist()
end


--@ setting.bag_type 公会仓库背包类型 参考 GuildmarketplaceConst.BagType
function GuildmarketplaceMainWindow:openRootWnd(setting)
    if not self.tab_index_type then return end
    local setting = setting or {}
    local bag_type = setting.bag_type or GuildmarketplaceConst.BagType.eHero
    self.tab_index = self.tab_type_index[bag_type] or 1

    controller:sender26900()
    controller:sender26903()

    self:updateItemInfo()
end

--记录信息刷新
function GuildmarketplaceMainWindow:updateMessageInfo(scdata)
    if not scdata then return end

    local board_list = scdata.board_list
    if next(board_list) == nil then
        commonShowEmptyIcon(self.message_scroll_view, true, {font_size = 16,scale = 0.4, offset_y = 50, text = TI18N("暂无记录信息")})
        return
    else
        commonShowEmptyIcon(self.message_scroll_view, false)
    end
    table_sort(board_list, function(a, b) return a.unixtime > b.unixtime end)

    local lable_data_list = {}
    local count = 1
    local max_count = 10
    for i,v in ipairs(board_list) do 
        if v.type == GuildmarketplaceConst.RewardRecordType.ePlay then ----玩家操作类型 
            for i,reward in ipairs(v.reward_list) do
                local item_config = Config.ItemData.data_get_data(reward.base_id)
                if item_config then
                    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                    if v.operation == 1 then --放入
                        local str = string_format(TI18N(" %s放入<div fontcolor=%s>%sx%s</div>"), v.name, color, item_config.name, reward.num)
                        table_insert(lable_data_list, str)
                        count = count + 1
                        if count > max_count then break end
                    elseif v.operation == 2 then --兑换
                        local str = string_format(TI18N(" %s兑换<div fontcolor=%s>%sx%s</div>"), v.name, color, item_config.name, reward.num)
                        table_insert(lable_data_list, str)
                        count = count + 1
                        if count > max_count then break end
                    end
                end
            end
        elseif v.type == GuildmarketplaceConst.RewardRecordType.eSystem then --2公会宝库系统(针对过期的)
             for i,reward in ipairs(v.reward_list) do
                local item_config = Config.ItemData.data_get_data(reward.base_id)
                if item_config then
                    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                    if v.operation == 3 then --过期
                        local str = string_format(TI18N(" <div fontcolor=%s>%sx%s</div>已过期下架"), color, item_config.name, reward.num)
                        table_insert(lable_data_list, str)
                        count = count + 1
                        if count > max_count then break end
                    end
                end
            end
        else --剩下是其他玩法放入的
            if v.operation == 1 then --放入
                local str = model:getStrByType(v.type, v.name)
                for i,reward in ipairs(v.reward_list) do
                    local item_config = Config.ItemData.data_get_data(reward.base_id)
                    if item_config then
                        local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                        local str1 = string_format(" \n <div fontcolor=%s>%sx%s</div>", color, item_config.name, reward.num)
                        str = str .. str1
                    end
                end
                table_insert(lable_data_list, str)
                count = count + 1
                if count > max_count then break end
            end
        end
        if count > max_count then break end
    end

    self.message_scroll_view:stopAllActions()

    for i,v in ipairs(self.message_label_list) do
        v:setPositionY(-1000)
    end

    local total_height = 0
    local place_y = 5
    self.message_scroll_view:setInnerContainerSize(cc.size(self.message_size.width, self.message_size.height))
    for i,v in ipairs(lable_data_list) do
        if i <= 5 and self.message_label_list[i] then
            self.message_label_list[i]:setString(v)
            local size = self.message_label_list[i]:getContentSize()
            local old_height = total_height
            total_height = total_height + size.height + place_y
            self.message_label_list[i]:setPositionY(self.message_size.height - old_height) 
        else
            delayRun(self.message_scroll_view,  i / display.DEFAULT_FPS, function()
                if self.message_label_list[i] == nil then
                    self.message_label_list[i] = createRichLabel(18, cc.c4b(0x86,0x4f,0x35,0xff), cc.p(0,1), cc.p(0, 0), 4, nil, 300)
                    self.message_scroll_view:addChild(self.message_label_list[i])
                end
                self.message_label_list[i]:setString(v)
                local size = self.message_label_list[i]:getContentSize()
                local old_height = total_height
                total_height = total_height + size.height + place_y

                if total_height <= self.message_size.height then
                    self.message_label_list[i]:setPositionY(self.message_size.height - old_height) 
                else
                    self.message_scroll_view:setInnerContainerSize(cc.size(self.message_size.width, total_height))
                    old_height = 0 
                    for k = 1, i do
                        if self.message_label_list[k] then
                            self.message_label_list[k]:setPositionY(total_height - old_height)
                            local size = self.message_label_list[k]:getContentSize()
                            old_height = old_height + size.height + place_y
                        end
                    end
                end
            end)
        end
    end
end

function GuildmarketplaceMainWindow:createLabelData(str)
    if self.test_lable == nil then
        self.test_lable = createRichLabel(18, cc.c4b(0x86,0x4f,0x35,0xff), cc.p(0,1), cc.p(-1000,0), 4, nil, 300)
        self.top_panel:addChild(self.test_lable)
    end
    str = str or ""
    self.test_lable:setString(str)
    local size = self.test_lable:getContentSize()
    return {str = str, height = size.height}
end

function GuildmarketplaceMainWindow:updateItemInfo()
    if not self.guild_change_item_id then return end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.guild_change_item_id) or 0
    self.item_count:setString(MoneyTool.GetMoneyString(count))
end

function GuildmarketplaceMainWindow:setScdata(scdata)
    local item_list = scdata.item_list
    
    local dic_tab_index = {}
    local new_index = self.tab_index
    local is_must_update = false
    for i,v in ipairs(item_list) do
        if self.dic_marketplace_id[v.id] then
            --如果是更新只会是修改这两个字段
            if v.end_time then
                table_sort(v.end_time, function(a, b) return a.end_unixtime < b.end_unixtime end)
                self.dic_marketplace_id[v.id].end_time = v.end_time
            end
            if self.dic_marketplace_id[v.id].market_item_config then
                new_index = self.tab_type_index[self.dic_marketplace_id[v.id].market_item_config.type] or self.tab_index
            end
            self.dic_marketplace_id[v.id].quantity = v.num --(后面我只会用 quantity )
            if v.num == 0 then
                self.dic_marketplace_id[v.id]:DeleteMe()
                self.dic_marketplace_id[v.id] = nil
                --有删除
                is_must_update = true
            end

        else
            local config = Config.GuildMarketplaceData.data_item_info(v.base_id)
            if config then
                v.market_item_config = config
                v.quantity = v.num     -- 转义成背包一样的字段(后面我只会用 quantity )
                v.extra_attr = v.extra -- 转义成背包一样的字段
                table_sort(v.end_time, function(a, b) return a.end_unixtime < b.end_unixtime end)
                local goodsvo = GoodsVo.New()
                goodsvo:initAttrData(v)
                self.dic_marketplace_id[v.id] = goodsvo
                --有新增
                is_must_update = true
                if self.is_init then
                    new_index = self.tab_type_index[self.dic_marketplace_id[v.id].market_item_config.type] or self.tab_index
                else
                    local index = self.tab_type_index[self.dic_marketplace_id[v.id].market_item_config.type] or self.tab_index
                    dic_tab_index[index] = true
                end
            end
        end
    end

    --限购信息
    if scdata.day_buy then
        for i,v in ipairs(scdata.day_buy) do
            self.dic_limit_buy[v.base_id] = v.num
        end
    end
    -- --初始化第一次肯定是更新
    if  not self.is_init then
        self.is_init = true
        is_must_update = true
        if next(dic_tab_index) ~= nil then
            if dic_tab_index[self.tab_index] == nil then
                for i,v in ipairs(self.tab_index_type) do
                    if dic_tab_index[i] then
                        self.tab_index = i
                        new_index = self.tab_index
                        break
                    end
                end
            end
            
        end
    end

    if is_must_update then 
        self.dic_list_data = {}
        for i=1,4 do
           self.dic_list_data[i] = {}
        end

        for k,v in pairs(self.dic_marketplace_id) do
            if v.config then
                local index = self.tab_type_index[v.market_item_config.type]
                if self.dic_list_data[index]  then
                    table_insert(self.dic_list_data[index], v)
                end
            end
        end
        --排序
        for i,v in pairs(self.dic_list_data) do
            local sort_func
            local _type = self.tab_index_type[i]
            if _type == GuildmarketplaceConst.BagType.eHero then --碎片
                sort_func = SortTools.tableCommonSorter({{"quality", true},{"lev", false},{"base_id", false}})
            elseif _type == GuildmarketplaceConst.BagType.eEquips then --装备
                sort_func = SortTools.tableUpperSorter({"quality", "eqm_star"})
            elseif _type == GuildmarketplaceConst.BagType.eSpecial then --符文
                sort_func = function ( objA, objB ) return objA.quality > objB.quality end
            elseif _type == GuildmarketplaceConst.BagType.eProps then --道具
                sort_func = SortTools.tableUpperSorter({"quality", "sort", "base_id"})
            end
            if sort_func then
                table_sort(v, sort_func)
            end
        end
        self:changeSelectedTab(new_index, true)
    else
        --没有增删 那么刷新当前..
        if new_index ~= self.tab_index then
            self:changeSelectedTab(new_index, true)  
        else
            if self.scrollview_list then
                self.scrollview_list:resetCurrentItems()
            end
        end
    end
end

--列表
function GuildmarketplaceMainWindow:updateItemlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 622,                -- 单元的尺寸width
            item_height = 220,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.scrollview_list:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true)
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GuildmarketplaceMainWindow:createNewCell(width, height)
    local cell = GuildmarketplaceItem.new(width, height, self)
    return cell
end

--获取数据数量
function GuildmarketplaceMainWindow:numberOfCells()
    if not self.show_list then return 0 end
    return math_ceil(#self.show_list/4)
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GuildmarketplaceMainWindow:updateCellByIndex(cell, index)
    -- cell.index = index
    local data1 = self.show_list[(index - 1) * 4 + 1] 
    local data2 = self.show_list[(index - 1) * 4 + 2] 
    local data3 = self.show_list[(index - 1) * 4 + 3] 
    local data4 = self.show_list[(index - 1) * 4 + 4]

    cell:setData(data1, data2, data3, data4)
end


function GuildmarketplaceMainWindow:close_callback(  )
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if self.item_load_record_bg then
        self.item_load_record_bg:DeleteMe()
    end
    self.item_load_record_bg = nil

    if self.item_load_chat_bg then
        self.item_load_chat_bg:DeleteMe()
    end
    self.item_load_chat_bg = nil

    if self.item_load1 then
        self.item_load1:DeleteMe()
    end
    self.item_load1 = nil

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
    end
    self.scrollview_list = nil

    if self.dic_marketplace_id then
        for k,v in pairs(self.dic_marketplace_id) do
            v:DeleteMe()
        end
        self.dic_marketplace_id = nil
    end

    self:clearTimeTicket()

    controller:openGuildmarketplaceMainWindow(false)
end

-- 子项
GuildmarketplaceItem = class("GuildmarketplaceItem", function()
    return ccui.Widget:create()
end)

function GuildmarketplaceItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function GuildmarketplaceItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("guildmarketplace/guildmarketplace_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_img = self.main_container:getChildByName("title_img")
    self.title_name = self.main_container:getChildByName("title_name")

    self.item_load_list = {}
    self.item_list = {}
    for i=1,4 do
        local item_bg = self.main_container:getChildByName("item_bg_"..i)
        self.item_list[i] = {}
        self.item_list[i].item_btn = item_bg
        self.item_list[i].item_btn:setSwallowTouches(false)
        local item_node = item_bg:getChildByName("item_node")
        self.item_list[i].item = BackPackItem.new(true, true, false, 0.8)
        -- self.item_list[i].item:setSwallowTouches(false)
        -- self.item_list[i].item:setDefaultTip()
        self.item_list[i].item:addBtnCallBack(function()
            self:onClickTipsBtn(i)
        end)

        item_node:addChild(self.item_list[i].item)
        -- self.item_list[i].lock_img = item_bg:getChildByName("lock_img")
        self.item_list[i].time_out_img = item_bg:getChildByName("time_out_img")
        self.item_list[i].cost_icon = item_bg:getChildByName("cost_icon")
        self.item_list[i].cost_count = item_bg:getChildByName("cost_count")
        self.item_list[i].have_count = item_bg:getChildByName("have_count") --库存

        self.item_list[i].have_count:setString("")
        self.item_list[i].time_out_img:setVisible(false)
        self.item_list[i].cost_count:setString("")
     end 
end

function GuildmarketplaceItem:register_event( )
    for i,v in ipairs(self.item_list) do
        registerButtonEventListener(v.item_btn, function() self:onClickItemBtn(i) end, false, 1, nil, nil, nil, true)
    end
end


function GuildmarketplaceItem:onClickTipsBtn(index)
    --打开物品tips
    local data = self["data"..index]
    if data then
        if data.market_item_config.day_buy and data.market_item_config.day_buy ~= 0 then 
            --已购买数量
            local count = self.parent.dic_limit_buy[data.base_id] or 0
            --未购买数量
            data.limit_day = count
            if data.limit_day < 0 then
                data.limit_day = 0
            end
            data.limit_total_num = data.market_item_config.day_buy
        end

        if BackPackConst.checkIsEquip(data.config.type) then
            data.is_market_place = true
            HeroController:getInstance():openEquipTips(true, data)
        elseif data.config.type == BackPackConst.item_type.ARTIFACTCHIPS then
            local setting = {}
            setting.is_market_place = true
            HeroController:getInstance():openArtifactTipsWindow(true, data, PartnerConst.ArtifactTips.buy, 0,1,false,setting)
        else
            TipsManager:showGoodsTips(data,false,0, {is_market_place = true})     
        end
    end
end

function GuildmarketplaceItem:onClickItemBtn(index)
    local data = self["data"..index]
    if data then
        local setting = {}
        setting.goods_id = data.id
        setting.item_id = data.base_id
        setting.item_count = data.market_item_config.radio

        local have_count = math_floor(data.quantity/data.market_item_config.radio)
        setting.limit_num = have_count

        if data.market_item_config and next(data.market_item_config.price) ~= nil then
            setting.price_item_id = data.market_item_config.price[1][1] or 1
            setting.price = data.market_item_config.price[1][2] or 1
        else
            setting.price_item_id = 1
            setting.price = 20
        end

        if self.parent.guild_change_item_id == setting.price_item_id then
            local count = BackpackController:getInstance():getModel():getItemNumByBid(self.parent.guild_change_item_id) or 0
            local num = math.floor(count/setting.price)
            if num <= 0 then
                num = 1
            end
            setting.limit_num = num
            if setting.limit_num > have_count then
                setting.limit_num = have_count
            end
        end
        if next(data.end_time) ~= nil then
            setting.less_time = data.end_time[1].end_unixtime
            setting.less_count = data.end_time[1].end_num
        end

         if data.market_item_config.day_buy and data.market_item_config.day_buy ~= 0 then 
            --已购买数量
            local count = self.parent.dic_limit_buy[data.base_id] or 0
            --未购买数量
            setting.limit_day = count
            if setting.limit_day < 0 then
                setting.limit_day = 0
            end
            setting.limit_total_num = data.market_item_config.day_buy
        end
        controller:openGuildmarketplaceBuyItemPanel(true, setting, 1)
    end
end

function GuildmarketplaceItem:setData(data1, data2, data3, data4)
    self.data1 = data1
    self.data2 = data2
    self.data3 = data3
    self.data4 = data4

    for i,item in ipairs(self.item_list) do
        local data = self["data"..i]
        if data then
            item.item_btn:setVisible(true)
            local have_count = math_floor(data.quantity/data.market_item_config.radio)
            item.have_count:setString(TI18N("库存:")..have_count)
            item.item:setBaseData(data.base_id, data.market_item_config.radio)
            if data.market_item_config.day_buy and data.market_item_config.day_buy ~= 0 then 
                item.item:showLeftBiaoQian(true, TI18N("限购"))
            else
                item.item:showLeftBiaoQian(false)
            end

            --单价
            if next(data.market_item_config.price) ~= nil then
                local item_id = data.market_item_config.price[1][1] or 1
                local count = data.market_item_config.price[1][2] or 1
                if item.record_cost_item_id == nil or item.record_cost_item_id ~= item_id then
                    item.record_cost_item_id = item_id
                    local config = Config.ItemData.data_get_data(item_id)
                    if config then
                        local head_icon = PathTool.getItemRes(config.icon, false)
                        loadSpriteTexture(item.cost_icon, head_icon, LOADTEXT_TYPE)
                    end
                end
                item.cost_count:setString(count)
            end
        else
            item.item_btn:setVisible(false)
        end
    end
    -- self:updateItemTimeInfo()
end

--更新道具的时间信息
function GuildmarketplaceItem:updateItemTimeInfo()
    for i,item in ipairs(self.item_list) do
        local data = self["data"..i]
        if data then
            if next(data.end_time) ~= nil then
                local less_time = data.end_time[1].end_unixtime
                local time = less_time - GameNet:getInstance():getTime()
                if time <= 0 then
                    item.time_out_img:setVisible(true)
                else
                    item.time_out_img:setVisible(false)
                end
            else
                item.time_out_img:setVisible(false)
            end
        else
            item.time_out_img:setVisible(false)
        end
    end
end

function GuildmarketplaceItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end

