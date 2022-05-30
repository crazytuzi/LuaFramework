-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      活动限时boss
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ActionLimitBossPanel = class("ActionLimitBossPanel", function()
    return ccui.Widget:create()
end)

local string_format = string.format

function ActionLimitBossPanel:ctor(bid,type)
	self.holiday_bid = bid
	self.type = type
    self.ctrl = ActionController:getInstance()
	self.can_get = 0
	self.item_list = {}
    self.chapter_list = {}
    self.page_num = 5
    self.page_max = 2
    self.max_id = 10
	self:configUI()
	self:register_event()
end

function ActionLimitBossPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_boss_panel"))
	self.root_wnd:setPosition(-40,-120)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:getChildByName("time_title"):setString(TI18N("剩余时间:"))
    self.power_title = main_container:getChildByName("power_title")
    self.power_title:setString(TI18N("最低通关战力:"))
    main_container:getChildByName("get_title"):setString(TI18N("通\n关\n奖\n励"))
    self.recommend_power_title = main_container:getChildByName("recommend_power_title")
    self.recommend_power_title:setString(TI18N("通关推荐战力:"))

    self.background = main_container:getChildByName("background")
    self.resources_load = createResourcesLoad(PathTool.getPlistImgForDownLoad("bigbg","bigbg_48", true), ResourcesType.single, function() 
        loadSpriteTexture(self.background, PathTool.getPlistImgForDownLoad("bigbg","bigbg_48", true), LOADTEXT_TYPE)
    end, nil, true)

    self.vedio_btn = main_container:getChildByName("vedio_btn")             -- 通关奖励
    self.vedio_btn:getChildByName("label"):setString(TI18N("通关录像"))

    self.time_val = main_container:getChildByName("time_val")               -- 剩余时间
    self.power_value = main_container:getChildByName("power_value")         -- 最低战力
    self.recommend_power_value = main_container:getChildByName("recommend_power_value")         -- 推荐战力
    self.chapter = main_container:getChildByName("chapter")                 -- 第几关
    self.challenge_btn = main_container:getChildByName("challenge_btn")     -- 挑战按钮
    self.challenge_btn_label = self.challenge_btn:getChildByName("label")
    self.challenge_btn_label:setString(TI18N("挑战"))
    self.pass_icon = main_container:getChildByName("pass_icon")             -- 通关图标
    self.pass_icon:setLocalZOrder(10)
    -- self.challenge_btn:setVisible(false)

    self.bubble_container = main_container:getChildByName("bubble_container")       -- 气泡
    self.bubble_container:setLocalZOrder(10)
    self.bubble_desc = createRichLabel(18, 175, cc.p(0, 1), cc.p(7, 75), nil, nil, 188)
    self.bubble_container:addChild(self.bubble_desc)

    local progress_container = main_container:getChildByName("progress_container")
    self.progress = progress_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)

    for i=1,5 do
        local chapter = main_container:getChildByName("chapter_"..i)
        if chapter then
            local label = chapter:getChildByName("label")
            local normal = chapter:getChildByName("normal")
            local select = chapter:getChildByName("select")
            local item = BackPackItem.new(false, true, false, 0.8, false, false)
            item:setPosition(chapter:getPositionX(), 848)
            item:addBtnCallBack(function(vo) 
                self:selectedChapterItem(i)
            end)
            main_container:addChild(item)
            local object = {}
            object.label = label
            object.normal = normal
            object.select = select
            object.item = item
            object.chapter_index = i                -- 当前下表
            object.chapter_id = i                   -- 当前章节id

            self.chapter_list[i] = object
        end
    end

    self.left_btn = main_container:getChildByName("left_btn")
    self.right_btn = main_container:getChildByName("right_btn")

    self.main_container = main_container
end

function ActionLimitBossPanel:register_event()
	if not self.update_action_even_event  then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
        	if data.bid == self.holiday_bid then
                self:setData(data)
            end
        end) 
    end
    self.challenge_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.selected_object == nil then return end
            self.ctrl:cs16604(self.holiday_bid, self.selected_object.chapter_id, 0)
        end
    end)
    self.vedio_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.replay_id == nil or self.replay_id == 0 then
                message(TI18N("还没人能通过本关哦，会是你吗"))
            else
                playButtonSound2()
                BattleController:getInstance():csRecordBattle(self.replay_id or 0)
            end
        end
    end)
    self.left_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.cur_page and self.cur_page <= 1 then return end
            local page = self.cur_page - 1
            self:changeCurPage(page)
        end
    end)
    self.right_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.cur_page and self.cur_page >= self.page_max then return end
            local page = self.cur_page + 1
            self:changeCurPage(page)
        end 
    end)
end

function ActionLimitBossPanel:changeCurPage(page, index)
    if self.cur_page and self.cur_page == page and index == nil then return end
    self.cur_page = page
    setChildUnEnabled(page==1, self.left_btn)
    setChildUnEnabled(page==self.page_max, self.right_btn)
    self.left_btn:setTouchEnabled(page ~= 1)
    self.right_btn:setTouchEnabled(page ~= self.page_max)
    self:updatePageChapterTab()
    self.chapter_id = nil
    self:selectedChapterItem(index or 1)-- 默认选中第一个
end

    -- 设置上面关卡显示物品和名字
function ActionLimitBossPanel:updatePageChapterTab()
    if self.data == nil then return end
    local min_index = (self.cur_page - 1) * self.page_num + 1
    local max_index = math.min(self.cur_page * self.page_num, self.max_id)
    self.progress:setPercent(math.min(self.data.finish - min_index + 1) * 100 /self.page_num)

    for i=min_index, max_index do
        local object_index = (i - 1) % self.page_num + 1
        local object = self.chapter_list[object_index]
        if object then
            object.chapter_id = i

            if object.label then
                object.label:setString(string_format(TI18N("第%s关"), i))
            end

            local camp = self.data.aim_list[i]
            if object.item and camp then
                local boss_icon_item = keyfind('aim_args_key', ActionExtType.BossIcon, camp.aim_args) or {}
                object.item:setBaseData(boss_icon_item.aim_args_val or 0)
                object.item:setExtendDesc(true, nil, 1, 2)
            end
        end
    end
end

function ActionLimitBossPanel:selectedChapterItem(index)
    if index == nil then return end
    local object = self.chapter_list[index]
    if object == nil or object.item == nil then return end
    local chapter_id = object.chapter_id
    if self.selected_object and self.chapter_id == chapter_id then return end
    if self.selected_object then
        if self.selected_object.item then
            self.selected_object.item:setSelected(false)
        end
        self.selected_object.label:setTextColor(Config.ColorData.data_color4[175])
        self.selected_object.normal:setVisible(true)
        self.selected_object.select:setVisible(false)
    end
    self.chapter_id = chapter_id
    self.selected_object = object

    if self.selected_object.item then
        self.selected_object.item:setSelected(true)
    end
    self.selected_object.label:setTextColor(cc.c4b(0x07,0x47,0x79,0xff))
    self.selected_object.normal:setVisible(false)
    self.selected_object.select:setVisible(true)
    self.chapter:setString(string_format(TI18N("第%s关"), chapter_id))
    

    if self.data == nil then return end
    local camp = self.data.aim_list[chapter_id]
    if camp == nil then return end
    local bossid_item = keyfind('aim_args_key', ActionExtType.BossId, camp.aim_args) or {}
    local boss_power_item = keyfind('aim_args_key', ActionExtType.BossMinPower, camp.aim_args) or {}
    local boss_recommend_power_item = keyfind('aim_args_key', ActionExtType.BossRecommendPower, camp.aim_args) or {}
    local boss_replayId_item = keyfind('aim_args_key', ActionExtType.BossReplayId, camp.aim_args) or {}
    self:createMonsterModel(bossid_item.aim_args_val)
    self:createItemList(camp.item_list)
    if boss_power_item.aim_args_val == 0 then
        self.power_value:setString(TI18N("暂无"))
    else
        self.power_value:setString(boss_power_item.aim_args_val)
    end
    self.recommend_power_value:setString(boss_recommend_power_item.aim_args_val)
    self.replay_id = boss_replayId_item.aim_args_val
    self.bubble_desc:setString(camp.aim_str)
    if camp.status == 2 then
        self.pass_icon:setVisible(true)
        self.challenge_btn_label:disableEffect()
        self.challenge_btn:setTouchEnabled(false)
        setChildUnEnabled(true, self.challenge_btn) 

    else
        self.pass_icon:setVisible(false)
		self.challenge_btn_label:enableOutline(Config.ColorData.data_color4[183]) 
		setChildUnEnabled(false, self.challenge_btn) 
        self.challenge_btn:setTouchEnabled(true)
    end
end

function ActionLimitBossPanel:setVisibleStatus(status)
    self:setVisible(status)
    if status == true and self.data == nil then
        -- 先设置到第一页
    	ActionController:getInstance():cs16603( self.holiday_bid)

        -- 这个需要判断一下
        self:changeCurPage(1)

        -- 保存上一个ui战斗类型
        self.last_ui_fight_type = MainuiController:getInstance():getUIFightType()
        -- 看看要不要拉进战斗
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LimitBoss)
    end
end

-- 数据设置更新
function ActionLimitBossPanel:setData(data)
    -- Debug.info(data)
    if self.data == nil then
        self.max_id = #data.aim_list
        self.page_max = math.ceil(self.max_id / self.page_num)
    end
    self.data = data
    self.time_val:setString(TimeTool.GetTimeFormatDayII(data.remain_sec or 0))

    local chapter_id = math.min(data.finish + 1, self.max_id)
    local page = math.ceil(chapter_id / self.page_num)
    local index = (chapter_id - 1) % self.page_num + 1
    -- Debug.info("=========>", chapter_id, page, index)
    self:changeCurPage(page, index)
end

--- 创建怪物模型
function ActionLimitBossPanel:createMonsterModel(id)
    if self.monster_model_id == id then return end
    self.monster_model_id = id
    if self.monster then
        self.monster:DeleteMe()
        self.monster = nil
    end
    self.monster = BaseRole.new(BaseRole.type.unit, id)
    self.monster:setAnimation(0, PlayerAction.show, true)
    self.monster:setCascade(true)
    self.monster:setPosition(360, 474)
    self.monster:setAnchorPoint(cc.p(0.5, 0.5))
    self.main_container:addChild(self.monster)

    self.bubble_container:setVisible(true)
end

--- 创建奖励物品
function ActionLimitBossPanel:createItemList(list)
    if list == nil or next(list) == nil then return end
    for i, item in ipairs(self.item_list) do
        item:suspendAllActions()
        item:setVisible(false)
    end

    local item = nil
    local scale = 0.9
    local off = 16
    local _x, _y = 0, 152
    local sum = #list
    local item_conf = nil
    local total_width = sum * BackPackItem.Width * scale + (sum - 1) * off
    local start_x = 150
    local index = 1

    for i, v in ipairs(list) do
        if v.bid and v.num then
            local bid = v.bid
            local num = v.num
            item_conf = Config.ItemData.data_get_data(bid)
            if item_conf then
                item = self.item_list[index]
                if item == nil then
                    item = BackPackItem.new(false, true, false, scale, false, true)
                    table.insert(self.item_list, item)
                    self.main_container:addChild(item)
                end
                _x = start_x + (BackPackItem.Width * scale + off) * (index-1) + BackPackItem.Width*scale*0.5
                item:setBaseData(bid, num)
                item:setDefaultTip(true,false)
                item:setPosition(_x, _y)
                item:setVisible(true)
                index = index + 1
            end
        end
    end 
end

function ActionLimitBossPanel:DeleteMe()
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end

    for i, item in ipairs(self.item_list) do
        item:DeleteMe()
    end
    self.item_list = nil

    if self.monster then
        self.monster:DeleteMe()
        self.monster = nil
    end

	if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    if self.last_ui_fight_type then
        MainuiController:getInstance():setUIFightType(self.last_ui_fight_type )
    end
end
