 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      神界冒险UI版本的矿井主界面  后端子乔 策划 松岩
-- <br/>2019年7月15日
--
-- --------------------------------------------------------------------
AdventureMineWindow = AdventureMineWindow or BaseClass(BaseView) 

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove
local math_floor = math.floor
local game_net = GameNet:getInstance()
local role_vo =  RoleController:getInstance():getRoleVo()


function AdventureMineWindow:__init()
    self.is_full_screen = true
    self.view_tag = ViewMgrTag.WIN_TAG 
    self.win_type = WinType.Full
    self.layout_name = "adventure/adventure_mine_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("adventure", "adventurewindow"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("adventure", "adventuremine"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("quest", "quest"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/adventure", "adventure_mine_bg", true), type = ResourcesType.single},
    }
    self.had_register = false
    --宝箱对象
    self.box_list = nil

    --矿脉 Config.AdventureMineData.data_mine_data 表数据
    self.dic_mine_data = {}

    --矿脉对象
    self.mine_item_list = {}

    --刷新间隔时间
    self.update_all_mine_time = 5


    --收费次数
    local config = Config.AdventureMineData.data_const.diamond_attack
    if config then
        self.max_buy_count = config.val
    else
        self.max_buy_count = 3    
    end

    --免费次数
    local config = Config.AdventureMineData.data_const.free_attack
    if config then
        self.max_free_count = config.val
    else
        self.max_free_count = 10
    end
    
end

function AdventureMineWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/adventure", "adventure_mine_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.top_container = self.root_wnd:getChildByName("top_container")

    self.title_container = self.top_container:getChildByName("title_container")
    self:playEnterAnimatianByObj(self.title_container, 1)
    self.top_title = self.title_container:getChildByName("label")       -- 层数标题

    self.title_background = self.title_container:getChildByName("title") 

    self.explain_btn = self.top_container:getChildByName("explain_btn")     -- 玩法说明按钮
    self.explain_btn:getChildByName("label"):setString(TI18N("玩法说明"))

    self.record_btn = self.top_container:getChildByName("record_btn")     -- 防守记录
    self.record_btn:getChildByName("label"):setString(TI18N("防守记录"))

    self.bottom_container = self.root_wnd:getChildByName("bottom_container")

    self.return_btn = self.bottom_container:getChildByName("return_btn")

    self.moon_btn = self.bottom_container:getChildByName("moon_btn")
    self.moon_btn:getChildByName("label"):setString(TI18N("水晶秘境"))
    self.gotoadventure_btn = self.bottom_container:getChildByName("gotoadventure_btn")
    self.gotoadventure_btn:getChildByName("label"):setString(TI18N("继续冒险"))


    self.my_mine_btn = self.bottom_container:getChildByName("my_mine_btn")
    self.my_mine_btn:getChildByName("my_mine_label"):setString(TI18N("我的灵矿"))

    self.bottom_container:getChildByName("reward_label"):setString(TI18N("挑战奖励:"))
    self.challenged_count_label = self.bottom_container:getChildByName("change_num")

    self.bottom_container:getChildByName("end_time_title"):setString(TI18N("冒险重置"))
    self.end_time_value = self.bottom_container:getChildByName("end_time_value")

    self.occupy_count = createRichLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0,0.5), cc.p(20, 340), 6, nil, 900)
    self.bottom_container:addChild(self.occupy_count)


    local buy_panel = self.bottom_container:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("挑战次数:"))
    self.buy_count_label = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")
    -- self.buy_tips = createRichLabel(20, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(0,-16), nil, nil, 600)
    self.buy_tips = createRichLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(0,-16), nil, nil, 600)
    buy_panel:addChild(self.buy_tips)

    self.list_conatiner = self.bottom_container:getChildByName("list_conatiner")

    --进度条
    local progress_container = self.bottom_container:getChildByName("progress_container")
    self.progress = progress_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    local progress_container_size = progress_container:getContentSize()

    local box_reward_list = Config.AdventureMineData.data_box_reward
    if box_reward_list and next(box_reward_list) ~= nil then
        self.box_list = {}
        table_sort( box_reward_list, function(a, b) return a.num < b.num end )
        local max_num = box_reward_list[#box_reward_list].num
        self.max_num = max_num
        local len = progress_container_size.width/ max_num
        for i,config in ipairs(box_reward_list) do
            local box_item = {}
            local x = len * config.num - 5
            local res_id = PathTool.getEffectRes(config.effect_id or 110)
            local box = createEffectSpine(res_id, cc.p( x, 8), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            progress_container:addChild(box)
            box_item.box = box
            box_item.lable = createLabel(22, cc.c4b(0x64,0x32,0x23,0xff), nil, x, -10, config.num, progress_container, nil, cc.p(0.5,0.5))

            box_item.btn = createButton(progress_container,"", x, progress_container_size.height * 0.5, cc.size(52, 70), PathTool.getResFrame("common", "common_99998"))
            box_item.btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:onClickBoxBtn(config, sender:getTouchBeganPosition())
                end
            end)
            box_item.config = config
            local pos = progress_container:convertToWorldSpace(cc.p(x,progress_container_size.height * 0.5))
            local newpos = self.root_wnd:convertToNodeSpace(pos)
            box_item.pos = newpos
            self.box_list[config.num] = box_item
        end
    end

    self.cell_container = self.root_wnd:getChildByName("cell_container")
    self.cell_container_size = self.cell_container:getContentSize()
end

function AdventureMineWindow:register_event()
    registerButtonEventListener(self.return_btn, function() controller:openAdventureMineWindow(false) end, true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.my_mine_btn, function() controller:openAdventureMineMyInfoPanel(true) end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.buy_btn, function() self:onBuyBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.explain_btn, function(param,sender, event_type) 
        -- local config =  Config.AdventureMineData.data_const.mine_des
        -- if config then
        --     TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        -- end
        MainuiController:getInstance():openCommonExplainView(true, Config.AdventureMineData.data_explain, TI18N("玩法规则"))
    end ,true, 1)

    --防守记录
    registerButtonEventListener(self.record_btn, function() 
        controller:openAdventureMineFightRecordPanel(true)
    end ,true, 1)
    
    registerButtonEventListener(self.moon_btn, function()
        controller:openAdventureMineLayerPanel(true, {floor = self.floor_id})  
    end, true, 1, nil, 0.9)

    registerButtonEventListener(self.gotoadventure_btn, function() self:onGotoAdventure() end, true, 1, nil, 0.9)
    
    --矿脉基本信息列表
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BASE_INFO_EVENT, function(data)
        if not data then return end
        if self.is_show_open_effect then
            self.is_show_open_effect = false
            self:playEnterEffect(true)
        end
        self.update_all_mine_step = self.update_all_mine_time
        self:updateMineList(data)

        model:setMineCountRedpoint(false)
        if self.open_setting then
            self:gotoAdventureFloorRoom(self.open_setting)
            self.open_setting = nil
        end
    end)
    --宝箱列表
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BOX_LIST_EVENT, function(data)
    --     if not data then return end
    --     self:updateBoxInfo(data)
    -- end)
    --领取宝箱返回
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECEIVE_BOX_EVENT, function(data)
    --     if not data then return end
    --     if self.dic_receive_num then
    --         self.dic_receive_num[data.num] = true
    --     end
    --     self:updateBoxInfoByNum(data.num, 3)
    -- end)
    --购买次数
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BUY_COUNT_EVENT, function(data)
    --     if not data then return end
    --     self:updateBuyInfo(data)
    -- end)
    --红点
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECORD_RED_POINT_EVENT, function(data)
    --     self:checkRedpoint()
    -- end)
end

function AdventureMineWindow:gotoAdventureFloorRoom(open_setting)
    if not self.mine_list then return end
    if not open_setting then return end
    local setting = {}
    setting.floor = self.floor_id
    setting.room_id = open_setting.room_id or 0

    local cur_data = nil
    for i,v in pairs(self.mine_list) do
        if v.room_id  == setting.room_id then
            cur_data = v
            break
        end
    end
    if not cur_data then return end

    if cur_data.rid == 0 then
        --表示未被占领是中立怪
        setting.show_type = 0
        controller:openAdventureMineFightPanel(true, setting)
    elseif role_vo and role_vo.rid == cur_data.rid and role_vo.srv_id == cur_data.srv_id then
        --自己的
        setting.show_type = 2
        controller:openAdventureMineFightPanel(true, setting)
    else
        --别人的
        setting.show_type = 1
        controller:openAdventureMineFightPanel(true, setting)
    end
end

--继续冒险
function AdventureMineWindow:onGotoAdventure()
    local base_data = model:getAdventureBaseData()
    if base_data  then 
        if base_data.id and base_data.id == base_data.current_id then
            if Config.AdventureMineData.data_floor_data[base_data.current_id] then
                --当最大层 和当前一致的时候.说明是在矿脉层 需要触发到下一层的操作
                controller:setMustChangeWindow()
                controller:send20620(13, AdventureEvenHandleType.handle, {}) 
            end
        else
            controller:requestEnterAdventure(true)    
        end
    else
        controller:requestEnterAdventure(true)
    end
end

function AdventureMineWindow:checkRedpoint()
    if model:isMineRecordRedpoint() then
        addRedPointToNodeByStatus(self.my_mine_btn, true, 5, 5)
        addRedPointToNodeByStatus(self.record_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.my_mine_btn, false, 5, 5)
        addRedPointToNodeByStatus(self.record_btn, false, 5, 5)
    end
end

function AdventureMineWindow:onBuyBtn(is_fight)
    if not self.max_buy_count then return end
    if not self.buy_count then return end
    if self.buy_count >= self.max_buy_count then
        if is_fight then
            message(TI18N("已达到今日挑战次数上限"))
        else
            message(TI18N("购买次数已达上限"))
        end
        return
    end

    local item_id =  Config.ItemData.data_assets_label2id.gold 
    local count =  50
    local config = Config.AdventureMineData.data_const.diamond_cost
    if config then
        count = config.val
    end
    local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
    local str
    if is_fight then
        str = string_format(TI18N("挑战次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count, config.val)
    else
        str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count, config.val)
    end
     
    local call_back = function()
        self.is_send_fight = is_fight
        controller:send20655()
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    
end
--config : Config.AdventureMineData.data_box_reward
function AdventureMineWindow:onClickBoxBtn(config, pos)
    if not self.box_list  then return end
    if not self.dic_receive_num  then return end
    if not self.had_combat_num  then return end

    if self.dic_receive_num[config.num] then --已领取
        self:showRewardItems(config.items, pos, config.num)
    else
        if self.had_combat_num >= config.num then --可领取
            --发协议领取
            controller:send20648(config.num)
        else --未激活
            self:showRewardItems(config.items, pos, config.num)
        end
    end
end
--抄过来的
function AdventureMineWindow:showRewardItems(data, pos, touch_pos)
    local size = self.root_wnd:getContentSize()
    if not self.tips_layer then
        self.tips_layer = ccui.Layout:create()
        self.tips_layer:setContentSize(size)
        self.root_wnd:addChild(self.tips_layer)
        self.tips_layer:setTouchEnabled(true)
        registerButtonEventListener(self.tips_layer, function()
            self.tips_bg:removeFromParent()
            self.tips_bg = nil
            self.tips_layer:removeFromParent()
            self.tips_layer = nil
        end,false, 1)
    end
    
    local list = {}
    if not self.tips_bg then
        self.tips_bg = createImage(self.tips_layer, PathTool.getResFrame("common","common_1056"), size.width*0.5, 100, cc.p(0,0), true, 10, true)
        self.tips_bg:setTouchEnabled(true)
    end
    if self.tips_bg then
        self.tips_bg:setContentSize(cc.size(BackPackItem.Width*#data+50,BackPackItem.Height+50))
        local ccp = cc.p(0.5,0)
        if self.tips_bg:getContentSize().width * 0.5 + pos.x >= 720 then
            ccp = cc.p(0.86,0)
        end
        self.tips_bg:setAnchorPoint(ccp)
        self.tips_bg:setPosition(self.box_list[touch_pos].pos.x, self.box_list[touch_pos].pos.y + 30)
    end
    local size = self.tips_bg:getContentSize()
    local x =  25 + BackPackItem.Width * 0.5
    for i,v in pairs(data) do
        if not list[i] then
            list[i] = BackPackItem.new(nil,true,nil,0.8)
            list[i]:setAnchorPoint(cc.p(0.5,0.5))
            self.tips_bg:addChild(list[i])
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(x + (i-1) * BackPackItem.Width, 100))
            list[i]:setDefaultTip()
            
            self.text_num = createLabel(22,cc.c4b(0xff,0xee,0xdd,0xff),nil,60,-25,"",list[i],nil, cc.p(0.5,0.5))
            self.text_num:setString("x"..v[2])
        else
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(x + (i-1) * BackPackItem.Width, 100))
            self.text_num:setString("x"..v[2])
        end
    end
end
--setting.is_show_open_effect 是否显示打开特效
--很多地方 floor_id 其实就是floor 
function AdventureMineWindow:openRootWnd(setting)
   if tolua.isnull(self.root_wnd) then return end
    local  setting = setting or {}
    self.is_show_open_effect = setting.is_show_open_effect or false
    self.floor_id = setting.floor_id
    self.open_setting = setting.open_setting
    self.base_data = model:getAdventureBaseData()
    if not self.base_data then return end 
    if not self.floor_id then return end

    self.base_data.current_id = self.floor_id
    self:sendUpdateMineData(1)
    controller:send20647()
    self:checkRedpoint()
    
    self:updateBaseData()
end

--发送更新矿脉数据
function AdventureMineWindow:sendUpdateMineData(is_notice)
    if self.floor_id then
        controller:send20640(self.floor_id, is_notice)
    end
end

--更新矿井列表信息
function AdventureMineWindow:updateMineList(data)
    if not self.cell_container then return end

    self.floor_id = data.floor
   
    self:updateBuyInfo(data)
    model:setMineOccupyCount(data.occupy_count)
    local max_cout = model:getMineLockCount() or 0
    self.occupy_count:setString(string_format(TI18N("当前占领：<div fontcolor=#14ff32>%s/%s</div>"), data.occupy_count ,max_cout))

    self.mine_list = {}
    
    for i,v in ipairs(self.mine_item_list) do
        v:setVisible(false)
    end
    for i,v in ipairs(data.list) do
        self.mine_list[v.room_id] = v
    end
    
    local index = 1

    local col = 5
    local space_x = 10
    local item_width = (self.cell_container_size.width - space_x *2)/col
    local item_height = 132

    local start_x = space_x + item_width * 0.5 
    local start_y = self.cell_container_size.height - item_height * 0.5

    for k,v in pairs(self.mine_list) do
        if self.mine_item_list[index] == nil then
            self.mine_item_list[index] = AdventureMineItem.new(self)
            self.cell_container:addChild(self.mine_item_list[index])
        else
            self.mine_item_list[index]:setVisible(true)
        end

        local _row = math_floor((k-1)/5)
        local _col = (k-1)%5
        local x = start_x + _col * item_width
        local y = start_y - (_row * item_height)
        self.mine_item_list[index]:setPosition(x, y)
        self.mine_item_list[index]:setData(v, _col)

        index = index + 1
    end
end

--更新购买次数
function AdventureMineWindow:updateBuyInfo( data )
    if not data then return end
    if not self.buy_count_label then return end
    if not self.buy_tips then return end
    self.buy_count = data.buy_count --已购次数
    model:setMineBuyCount(self.buy_count)
    model:setChallengeCount(data.count)
    self.buy_count_label:setString(string_format(TI18N("%s/%s"), data.count or 0, self.max_free_count))
    local count = self.max_buy_count - self.buy_count
    if count < 0 then count = 0 end
    self.buy_tips:setString(string_format(TI18N("(剩余购买次数：<div fontcolor=#14ff32>%s</div>)"), count))
end


--==============================--
--desc:基础数据变化的时候,可能层数变化,这个时候就需要重新设置风格之类的了
--time:2018-10-13 10:54:11
--@return 
--==============================--
function AdventureMineWindow:updateBaseData()
    if not self.floor_id then return end
    local config = Config.AdventureMineData.data_floor_data[self.floor_id]
    if config then
        self.top_title:setString(config.name)
    else
        self.top_title:setString(TI18N("公共灵矿1层"))
    end
    self:updateEndTime()
end

--更新宝箱信息
function AdventureMineWindow:updateBoxInfo(data)
    if not self.box_list then return end
    if not self.max_num then return end

    self.had_combat_num = data.had_combat_num or 0

    self.challenged_count_label:setString(string_format(TI18N("(挑战%s次)"), self.had_combat_num))
    self.progress:setPercent(self.had_combat_num * 100/ self.max_num)

    self.dic_receive_num = {}
    for i,v in ipairs(data.num_list) do
        self.dic_receive_num[v.num] = true
    end

    for k,v in pairs(self.box_list) do
        if v.config  then
            if self.dic_receive_num[v.config.num] then --已领取
                self:updateBoxInfoByNum(v.config.num, 3)
            else
                if self.had_combat_num >= v.config.num then
                    self:updateBoxInfoByNum(v.config.num, 2)    
                else
                    self:updateBoxInfoByNum(v.config.num, 1)    
                end
            end
        end
    end

end

--@status 1,未激活 2 ,已激活 3 已领取
function AdventureMineWindow:updateBoxInfoByNum(num, status)
    if not self.box_list then return end
    if self.box_list[num] and self.box_list[num].box then
        if status == 1 then
            self.box_list[num].box:setAnimation(0, PlayerAction.action_1, true)
        elseif status == 2 then
            self.box_list[num].box:setAnimation(0, PlayerAction.action_2, true)
        else
            self.box_list[num].box:setAnimation(0, PlayerAction.action_3, true)
        end
    end
end

--==============================--
--desc:更新重置事件
--time:2019-01-25 09:32:36
--@return 
--==============================--
function AdventureMineWindow:updateEndTime()
    if self.base_data == nil then return end
    if self.timeticket == nil then
        self.update_all_mine_step = self.update_all_mine_time
        self:countDownEndTime()
        self.timeticket = GlobalTimeTicket:getInstance():add(function()
            self:countDownEndTime()
        end, 1)
    end
end

--==============================--
--desc:计时器
--time:2019-01-25 09:32:43
--@return 
--==============================--
function AdventureMineWindow:countDownEndTime()
    if self.base_data == nil then
        self:clearEneTime()
        return
    end
    local end_time = self.base_data.end_time - game_net:getTime()
    if end_time <= 0 then
        end_time = 0
        self:clearEneTime()
    end
    self.end_time_value:setString(TimeTool.GetTimeFormat(end_time))
    self.update_all_mine_step = self.update_all_mine_step - 1
    if self.update_all_mine_step == 0 then
        self.update_all_mine_step = self.update_all_mine_time
        self:sendUpdateMineData()
    end
end

--==============================--
--desc:清理计时器
--time:2019-01-25 09:32:50
--@return 
--==============================--
function AdventureMineWindow:clearEneTime()
    if self.timeticket then
        GlobalTimeTicket:getInstance():remove(self.timeticket)
        self.timeticket = nil
    end
end 


function AdventureMineWindow:playEnterEffect(status)
    if not status then
        if self.enter_effect then
            self.enter_effect:removeFromParent()
            self.enter_effect = nil
        end
    else
        if self.enter_effect == nil then
            self.enter_effect = createEffectSpine(PathTool.getEffectRes(157), cc.p(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.root_wnd:addChild(self.enter_effect, 1)
        end
        
        local function animationCompleteFunc()
            self.enter_effect:setVisible(false)
        end

        self.enter_effect:setVisible(true)
        self.enter_effect:setAnimation(0, PlayerAction.action_1, false) 
        if self.had_register == false then
            if self.enter_effect then
                self.had_register = true
                self.enter_effect:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
            end
        end
    end
end




function AdventureMineWindow:close_callback()
    -- BattleController:getInstance():openBattleView(false)
    -- -- -- 还原就的战斗ui类型
    -- MainuiController:getInstance():resetUIFightType()

    self:clearEneTime()
    self:playEnterEffect(false)

    controller:openAdventureMineWindow(false)
end

-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      地块的单例,包含了事件等
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureMineItem = class("AdventureMineItem", function()
    return ccui.Layout:create()
end) 

function AdventureMineItem:ctor(parents)
    --父类
    self.parents = parents

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("adventure/adventure_mine_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.icon = self.container:getChildByName("icon")
    self.namebg = self.container:getChildByName("namebg")
    self.serve_name = self.container:getChildByName("serve_name")
    self.name = self.container:getChildByName("name")
    self.mark_img = self.container:getChildByName("mark_img")
    self.level = self.container:getChildByName("level")
    self.level_bg = self.container:getChildByName("level_bg")
    self.head_img = self.container:getChildByName("head_img")

    self.head_item = PlayerHead.new(PlayerHead.type.circle)
    self.head_item:setScale(0.65)
    self.container:addChild(self.head_item)
    self:registerEvent()
end

function AdventureMineItem:registerEvent()
    self.container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.data then return end
            if not self.parents then return end
            local setting = {}
            setting.floor = self.parents.floor_id
            setting.room_id = self.data.room_id
            if self.data.rid == 0 then
                --表示未被占领是中立怪
                setting.show_type = 0
                controller:openAdventureMineFightPanel(true, setting)
            elseif role_vo and role_vo.rid == self.data.rid and role_vo.srv_id == self.data.srv_id then
                --自己的
                setting.show_type = 2
                controller:openAdventureMineFightPanel(true, setting)
            else
                --别人的
                setting.show_type = 1
                controller:openAdventureMineFightPanel(true, setting)
            end
        end
    end)
end
--@data 结构参考 20640 list 结构
function AdventureMineItem:setData(data, pos)
    if not data then return end

    self.data = data
    self.config = Config.AdventureMineData.data_mine_data(data.mine_id)
    if not self.config then return end
    --背景
    local res_id = self.config.res_id 
    if res_id == nil or res_id == "" then
        res_id = 1001
    end
    local res = PathTool.getPlistImgForDownLoad("adventure/mine_icon", res_id, false)
    if self.record_res == nil or self.record_res ~= res then
        self.record_res = res
        self.item_load = loadSpriteTextureFromCDN(self.icon, res, ResourcesType.single, self.item_load) 
    end
    self.level:setString(self.config.star or 0)
    if self.data.rid == 0 then
        --表示未被占领是中立怪
        self.mark_img:setVisible(false)
        self.serve_name:setVisible(false)
        -- self.level:setVisible(true)
        -- self.level_bg:setVisible(true)
        self.head_img:setVisible(false)
        self.head_item:setVisible(false)

        -- self.level:setString(data.lev)
        self.name:setPositionY(20)
        self.name:setString(data.name)
        self.name:setColor(cc.c4b(0xff,0xff,0xff,0xff))
    elseif role_vo and role_vo.rid == data.rid and role_vo.srv_id == data.srv_id then
        self.mark_img:setVisible(true)
        self.serve_name:setVisible(false)
        -- self.level:setVisible(false)
        -- self.level_bg:setVisible(false)
        self.head_img:setVisible(false)
        self.head_item:setVisible(false)

        self.name:setPositionY(20)
        self.name:setString(TI18N("我的灵矿"))
        self.name:setColor(cc.c4b(0x14,0xff,0x32,0xff))
    else
        self.mark_img:setVisible(false)
        self.serve_name:setVisible(true)
        -- self.level:setVisible(false)
        -- self.level_bg:setVisible(false)
        
        -- self.level:setString(data.lev)
        local svr_name = getServerName(data.srv_id) or TI18N("异域")
        self.name:setPositionY(10)
        self.serve_name:setString(string_format("[%s]",svr_name))
        self.name:setString(data.name)
        self.serve_name:setColor(cc.c4b(0xff,0x8b,0x7f,0xff))
        self.name:setColor(cc.c4b(0xff,0x8b,0x7f,0xff))

        self.head_img:setVisible(true)
        self.head_item:setVisible(true)

        self.head_item:setHeadRes(self.data.face, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
        self.head_item:setLev(self.data.lev or 0)
        if pos and pos == 4 then
            --说明在最右边
            self.head_item:setPosition(5, 90)
            self.head_img:setPosition(20, 60)
            self.head_img:setScaleX(-1)
        else
            self.head_item:setPosition(135, 90)
            self.head_img:setPosition(118, 60)
            self.head_img:setScaleX(1)
        end
    end
    if pos then
        self:setZOrder(5-pos)
    end
    if data.status == 2 then --"状态 0正常 1战斗中 2保护期"}
        self:showEffect(true)
        self:fightStatus(false)
    elseif data.status == 1 then
        self:fightStatus(true)
        self:showEffect(false)
    else
        self:showEffect(false)
        self:fightStatus(false)
    end
end

--- 当前战斗状态
function AdventureMineItem:fightStatus(status)
    if status == false then
        if self.fight_effect then
            self.fight_effect:setVisible(false)
            self.fight_effect:removeFromParent()
            self.fight_effect = nil
        end
    else
        if self.fight_effect == nil then
            self.fight_effect = createEffectSpine( PathTool.getEffectRes(186), cc.p(70,118), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.fight_effect:setScale(1)
            self:addChild(self.fight_effect, 10)
        end
    end
end

--显示保护特效
function AdventureMineItem:showEffect(bool, effect_id)
    if bool == true then
        if self.play_effect == nil then
            self.play_effect = createEffectSpine("E23014", cc.p(73,55), cc.p(0.5, 0.5), true, PlayerAction.action)
            self:addChild(self.play_effect, 1)
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

function AdventureMineItem:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    self:showEffect(false)
    self:fightStatus(false)
end