-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      神界冒险UI版本的主UI
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureMainWindow = AdventureMainWindow or BaseClass(BaseView) 

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local adventure_event = Config.AdventureData.data_adventure_event 
local table_insert = table.insert
local table_remove = table.remove
local game_net = GameNet:getInstance()
local floor_config = Config.AdventureData.data_floor_reward 

function AdventureMainWindow:__init()
	self.is_full_screen = true
	self.view_tag = ViewMgrTag.WIN_TAG 
	self.win_type = WinType.Full
	self.index = 2 
	self.layout_name = "adventure/adventure_main_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("adventure", "adventurewindow"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_111",true), type = ResourcesType.single },
	}
    self.had_register = false
    self.have_show_over = false
    self.box_effect = nil
    self.cur_box_status = nil
    self.skill_list = {}
    self.hero_list = {}
    self.room_skill_list = {}
    self.collect_effect_list ={}

    self.fly_cache_item_list = {}
    self.fly_item_list = {}
end

function AdventureMainWindow:open_callback()
	self.cell_container = self.root_wnd:getChildByName("cell_container")
    local scroll_view_size = self.cell_container:getContentSize()
    local setting = {
        item_class = AdventureCellItem,
        start_x = 10,
        space_x = -1,
        -- start_y = 134,
        start_y = 71,
        space_y = -1,
        item_width = 142,
        item_height = 126,
        row = 5,
        col = 5,
        once_num = 5
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.cell_container, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.bottom, scroll_view_size, setting)
    self.item_scrollview:setClickEnabled(false)

    self.top_container = self.root_wnd:getChildByName("top_container")
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_111",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())
    -- self.top_back_ground = self.top_container:getChildByName("background")
    -- self.top_back_ground:setScale(display.getMaxScale())			-- 层数不一样显示可能不一样

    self.title_container = self.top_container:getChildByName("title_container")
    self.top_title = self.title_container:getChildByName("label")		-- 层数标题
    -- self.title_background = self.title_container:getChildByName("title")

    self.explain_btn = self.top_container:getChildByName("explain_btn")		-- 玩法说明按钮
    self.rank_btn = self.top_container:getChildByName("rank_btn")
    self.explain_btn:getChildByName("label"):setString(TI18N("玩法说明"))
    self.rank_btn:getChildByName("label"):setString(TI18N("排行"))

    self.bottom_container = self.root_wnd:getChildByName("bottom_container")
    -- self.bottom_back_ground = self.bottom_container:getChildByName("background")
    -- self.bottom_back_ground:setScale(display.getMaxScale())			-- 层数不一样 显示就不一样

    self.return_btn = self.bottom_container:getChildByName("return_btn")

    self.list_conatiner = self.bottom_container:getChildByName("list_conatiner")

    local base_config = Config.AdventureData.data_skill_data 
    for i=1,3 do
        local buff_node = self.bottom_container:getChildByName("buff_"..i)
        if buff_node then
            local object = {}
            object.node = buff_node
            object.index = i
            object.num = buff_node:getChildByName("num")
            object.num:setString(0)
            object.label = buff_node:getChildByName("label")
            object.num_value = 0
            object.use_count = 0
            self.skill_list[i] = object
            local config = base_config[i]
            if config then
                object.config = config
                object.label:setString(config.name)
            end
        end
    end
    self.shop = self.bottom_container:getChildByName("shop")
    self.shop:getChildByName("label"):setString(TI18N("冒险商店"))
    -- self.mine_btn = self.bottom_container:getChildByName("mine_btn")
    -- self.mine_btn:getChildByName("label"):setString(TI18N("水晶秘境"))

    self.btn_box = self.bottom_container:getChildByName("btn_box")
    self.btn_box_label = self.btn_box:getChildByName("Text_1")
    self.btn_box_label:setString("")
    self.btn_box_label:setLocalZOrder(10)    
    self.btn_box:getChildByName("Text_2"):setString(TI18N("击杀守卫"))
    self.buff_container = self.bottom_container:getChildByName("buff_container")
    self.holiday_buff = self.bottom_container:getChildByName("holiday_buff")
    self.holiday_buff:setVisible(false)

    self.bottom_container:getChildByName("end_time_title"):setString(TI18N("冒险重置"))
    self.end_time_value = self.bottom_container:getChildByName("end_time_value")
end

function AdventureMainWindow:register_event()
	registerButtonEventListener(self.return_btn, function()
        controller:openAdventureMainWindow(false)
		-- MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene)
	end, true, 2)
	
	registerButtonEventListener(self.explain_btn, function()
		MainuiController:getInstance():openCommonExplainView(true, Config.AdventureData.data_explain, TI18N("玩法规则"))
	end, true, 1)
	
	registerButtonEventListener(self.rank_btn, function()
        RankController:getInstance():openRankView(true, RankConstant.RankType.adventure) 
	end, true, 1)
	
	registerButtonEventListener(self.buff_container, function(param, sender, event_type)
		local buff_list = model:getBuffData()
        local holiday_buff_list = model:getHolidayBuffData()
        if (buff_list == nil or next(buff_list) == nil) and (holiday_buff_list == nil or next(holiday_buff_list) == nil) then
            message(TI18N("暂无属性加成"))
        else
            TipsManager:getInstance():showAdventureBuffTips(buff_list, sender:getTouchBeganPosition(), holiday_buff_list) 
        end
	end, true, 1)
	
	for k, v in pairs(self.skill_list) do
		if v.node then
			registerButtonEventListener(v.node, function(index)
                self:handleSkillChoose(index)
			end, true, 1, v.index)
		end
	end	
    registerButtonEventListener(self.shop, function()
        controller:openAdventrueShopWindow(true)
    end, true, 1)

	-- registerButtonEventListener(self.mine_btn, function()
    --     controller:openAdventureMineLayerPanel(true)
	-- end, true, 1)
	
	self:addGlobalEvent(AdventureEvent.Update_Room_Info, function()
		self:playEnterEffect(true)
		self:updateRoomData()
	end)
	
	self:addGlobalEvent(AdventureEvent.Update_Single_Room_Info, function(data)
		self:updateRoomData(true)
	end)
	
	self:addGlobalEvent(AdventureEvent.Update_Room_Base_Info, function()
		self:updateBaseData()
	end)
	
	self:addGlobalEvent(AdventureEvent.Update_Buff_Info, function()
		self:updateBuffData()
        self:updateHolidayBuffTips()
	end)
	
	self:addGlobalEvent(AdventureEvent.UpdateSkillInfo, function(data)
		self:updateSkillData(data)
	end)
	
	self:addGlobalEvent(AdventureEvent.UpdateAdventureForm, function()
		self:updateHeroList()
	end)

    self:addGlobalEvent(AdventureEvent.UpdateAdventureSelectHero, function()
        self:changeSelectHero()
    end)

    self:addGlobalEvent(AdventureEvent.GetSkillForEffectAction, function(id, skill_id) 
        self:playSkillEffectAction(id, skill_id)
    end)

    self:addGlobalEvent(AdventureEvent.UpdateBoxTeskEvent,function(data)
        self:updateBoxTeskList(data)
    end)

    --红点事件
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECORD_RED_POINT_EVENT,function(data)
    --     self:updateMineBtnRedpoint()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BOX_LIST_EVENT,function(data)
    --     self:updateMineBtnRedpoint()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECEIVE_BOX_EVENT,function(data)
    --     self:updateMineBtnRedpoint()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_CHALLEAGE_RED_POINT_EVENT,function(data)
    --     self:updateMineBtnRedpoint()
    -- end)

    registerButtonEventListener(self.btn_box, function()
        if self.box_tesk_data and self.box_tesk_data.kill_mon then
            -- 有奖励可领时，点击宝箱直接全部领完
            if self.cur_box_status and self.cur_box_status == 1 then
                controller:send20635(0)
            else
                controller:openAdventureBoxRewardView(true,self.box_tesk_data.kill_mon)
            end
        end
    end,false,1)
end

function AdventureMainWindow:updateMineBtnRedpoint()
    -- local status = model:checkRedPoint(true)
    -- addRedPointToNodeByStatus(self.mine_btn, status, -18, -18)
end

function AdventureMainWindow:openRootWnd()
    controller:send20602()
    controller:send20609()
    controller:send20634()

    self:updateBuffData()
    self:updateBaseData()
    self:updateHeroList()
    self:updateHolidayBuffTips()

    model:updateRedStatus(false)
    -- self:updateMineBtnRedpoint()
    model:setAdventureFightReturnTag(true)
end
--更新宝箱的任务
function AdventureMainWindow:getNextLevelNumber(list,length,cur_count)
    if list[length] == nil then return 1 end
    local num = 0
    if cur_count >= list[length].count then
        num = list[length].id
    else
        for i,v in pairs(list) do
            local cur_id = v.id
            cur_id = cur_id + 1
            if cur_id >= length then
                cur_id = length
            end
            if cur_count >= v.count and cur_count <= list[cur_id].count then
                num = v.id
                break
            end
        end
        num = num + 1
        if num >= length then
           num = length
        end
    end
    return num
end

function AdventureMainWindow:updateBoxTeskList(data)
    if data == nil then return end
    local box_list = Config.AdventureData.data_round_reward_list
    local length = Config.AdventureData.data_round_reward_list_length
    self.box_tesk_data = data

    local kill_mon = self.box_tesk_data.kill_mon or 0
    local status_index = 0
    for i,v in pairs(data.list) do
        if v.status == 1 then
            status_index = 1 --可领取的时候
            break
        end
    end
    --判断是否全部领取完毕
    local is_all_get = false
    if status_index == 0 then
        for i,v in pairs(data.list) do
            if v.status == 0 then
                is_all_get = true
                break
            end
        end
        if is_all_get == false then
            status_index = 2
        end
    end
    local index = self:getNextLevelNumber(box_list,length,kill_mon)

    if status_index == 2 then
        local str = TI18N("已领取")
        self.btn_box_label:setString(str)
    else
        local str = string_format(TI18N("%d/%d"),kill_mon,box_list[index].count)
        self.btn_box_label:setString(str)
    end

    if self.cur_box_status ~= status_index then
        self.cur_box_status = status_index
        --宝箱状态
        local action = PlayerAction.action_1
        if status_index == 1 then
            action = PlayerAction.action_2
        elseif status_index == 2 then
            action = PlayerAction.action_3
        end

        if self.box_effect then
            self.box_effect:clearTracks()
            self.box_effect:removeFromParent()
            self.box_effect = nil
        end
        if not tolua.isnull(self.btn_box) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(self.btn_box:getContentSize().width * 0.5, self.btn_box:getContentSize().height * 0.5-20), cc.p(0, 0), true, action)
            self.btn_box:addChild(self.box_effect)
        end
    end
end
--==============================--
--desc:更新自己伙伴信息
--time:2019-01-24 05:07:37
--@return 
--==============================--
function AdventureMainWindow:updateHeroList()
    local hero_list = model:getFormList()
    local partner_id = model:getSelectPartnerID() 
    for i,v in ipairs(hero_list) do
        local function clickback(cell, data)
            self:selectHeroItem(cell, data)
        end
        if self.hero_list[i] == nil then
            self.hero_list[i] = HeroExhibitionItem.new(0.9, true, 0, false) 
            self.hero_list[i]:setPosition(90 + (i - 1)* 135, 260)
            self.hero_list[i]:addCallBack(clickback)
            self.bottom_container:addChild(self.hero_list[i])
        end
        local hero_item = self.hero_list[i]
        self:updateHeroInfo(hero_item, v)

        -- 默认选中一个
        if not self.select_cell and partner_id ~= 0 then
            if v.partner_id == partner_id then
                self:selectHeroItem(hero_item, v)
            end
        end
    end
end

--==============================--
--desc:外部事件更改选中
--time:2019-01-24 07:20:46
--@return 
--==============================--
function AdventureMainWindow:changeSelectHero()
    local partner_id = model:getSelectPartnerID()
    if partner_id == 0 then return end

    local cell = nil
    for k,v in pairs(self.hero_list) do
        local data = v:getData()
        if data and data.partner_id == partner_id then
            cell = v
            break
        end
    end
    if cell then
        self:selectHeroItem(cell, cell:getData(), true)
    end
end

--==============================--
--desc:设置当前选中的
--time:2019-01-24 07:20:59
--@cell:
--@data:
--@return 
--==============================--
function AdventureMainWindow:selectHeroItem(cell, data, not_req)
    if data.now_hp == 0 then
        message(TI18N("死亡宝可梦无法选择"))
        return
    end
    if self.select_cell == cell then return end
    if self.select_cell then
        self.select_cell:setSelected(false)
        self.select_cell = nil
    end
    self.select_cell = cell
    self.select_cell:setSelected(true) 
    -- 请求储存
    if not not_req then
        controller:requestSelectPartner(data.partner_id)
    end
end

--==============================--
--desc:外部设置额外信息
--time:2019-01-24 06:04:06
--@item:
--@data:
--@return 
--==============================--
function AdventureMainWindow:updateHeroInfo(item, data)
    if item == nil then return end
    item:setData(data)
    local hp_per = data.now_hp / data.hp
    item:showProgressbar(hp_per * 100)
    if hp_per == 0 then
        item:showStrTips(true, TI18N("已阵亡")) 
        item:setSelected(false)
    else
        item:showStrTips(false) 
    end
end

--==============================--
--desc:更新技能信息
--time:2019-01-24 05:05:47
--@data:
--@return 
--==============================--
function AdventureMainWindow:updateSkillData(data_list)
    if data_list then
        for i,v in ipairs(data_list) do
            local object = self.skill_list[v.bid]
            if object then
                object.num_value = v.num
                object.use_count = v.use_count
                object.num:setString(v.num)
            end
        end
    end
end

--==============================--
--desc:buff效果
--time:2018-10-13 10:55:23
--@return 
--==============================--
function AdventureMainWindow:updateBuffData()
    
end

-- 更新活动buff加成标识
function AdventureMainWindow:updateHolidayBuffTips(  )
    local buff_data = model:getHolidayBuffData()
    if not buff_data or next(buff_data) == nil then
        self.holiday_buff:setVisible(false)
    else
        self.holiday_buff:setVisible(true)
    end
end

--==============================--
--desc:基础数据变化的时候,可能层数变化,这个时候就需要重新设置风格之类的了
--time:2018-10-13 10:54:11
--@return 
--==============================--
function AdventureMainWindow:updateBaseData()
    self.base_data = model:getAdventureBaseData()
    if self.base_data == nil then return end

    local base_data = self.base_data
    self:changeBackgroundResources(base_data.map_id)

    base_data.current_id = base_data.id
    -- 设置层的名字
    if self.name_layer ~= base_data.id then
        self.name_layer = base_data.id
        local name_config = Config.AdventureData.data_floor_reward[base_data.id]
        if name_config then
            self.top_title:setString(name_config.name)
        end
    end

    -- 设置倒计时
    self:updateEndTime()
end

--==============================--
--desc:更新重置事件
--time:2019-01-25 09:32:36
--@return 
--==============================--
function AdventureMainWindow:updateEndTime()
	if self.base_data == nil then return end
	if self.timeticket == nil then
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
function AdventureMainWindow:countDownEndTime()
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
end

--==============================--
--desc:清理计时器
--time:2019-01-25 09:32:50
--@return 
--==============================--
function AdventureMainWindow:clearEneTime()
	if self.timeticket then
		GlobalTimeTicket:getInstance():remove(self.timeticket)
		self.timeticket = nil
	end
end 

--==============================--
--desc:切换地图
--time:2018-10-13 10:51:31
--@layer:
--@return 
--==============================--
function AdventureMainWindow:changeBackgroundResources(layer)
    -- if layer == nil then return end
    -- if self.layer == layer then return end
    -- self.layer = layer
    -- local layer_config = Config.AdventureData.data_map[layer]
    -- if layer_config then
    --     local background_path = "resource/adventure/background/"..layer_config.res_id
    --     if self.background_path == background_path then return end
    --     self.background_path = background_path 

    --     local res_list = {}
    --     table_insert(res_list, {path=self.background_path.."/bottom.png", type = ResourcesType.single})
    --     table_insert(res_list, {path=self.background_path.."/title.png", type = ResourcesType.single})
    --     table_insert(res_list, {path=self.background_path.."/top.png", type = ResourcesType.single})
    --     if self.style_resources_load then
    --         self.style_resources_load:DeleteMe()
    --         self.style_resources_load  = nil
    --     end
    --     self.style_resources_load = ResourcesLoad.New()
    --     self.style_resources_load:addAllList(res_list, function()
    --         self:changeStyle()
    --     end)
    -- end
end

--==============================--
--desc:背景资源需要变化的时候改变的
--time:2018-10-13 11:15:38
--@return 
--==============================--
function AdventureMainWindow:changeStyle()
    if self.background_path == nil then return end
    local top_path = self.background_path .. "/top.png"
    loadSpriteTexture(self.top_back_ground, top_path, LOADTEXT_TYPE)

    local bottom_path = self.background_path .. "/bottom.png"
    loadSpriteTexture(self.bottom_back_ground, bottom_path, LOADTEXT_TYPE) 

    local title_path = self.background_path .. "/title.png"
    loadSpriteTexture(self.title_background, title_path, LOADTEXT_TYPE)
end

function AdventureMainWindow:playEnterEffect(status)
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
            -- 每轮首次进入冒险，如果有buff则弹窗提示
            local last_adventure_num = model:getLastAdventureNum()
            if Config.AdventureData.data_buff[last_adventure_num] then
                local msg = Config.AdventureData.data_buff[last_adventure_num].desc
                CommonAlert.show(msg, TI18N("确定"), nil, nil, nil, CommonAlert.type.rich)
            end
            model:setLastAdventureNum(99)
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

function AdventureMainWindow:updateRoomData(is_update)
    local room_list = model:getRoomList()    
	local function click_callback(item)
		self:clickCellItem(item)
	end
    is_update = is_update or false
	self.item_scrollview:setData(room_list, click_callback, nil, is_update)
end

--3S后没有返回自动清理
function AdventureMainWindow:touchTimeOverdue()
    if self.time_overdue_ticket == nil then
        self.time_overdue_ticket = GlobalTimeTicket:getInstance():add(function()
            self:clearOverdueTime()
            model:setAdventureFightReturnTag(true)
        end,10)
    end
end
function AdventureMainWindow:clearOverdueTime()
    if self.time_overdue_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_overdue_ticket)
        self.time_overdue_ticket = nil
    end
end
--==============================--
--desc:点击房间处理
--time:2018-10-15 10:44:24
--@item:
--@return 
--==============================--
function AdventureMainWindow:clickCellItem(item)
    local fight_status = model:getAdventureFightReturnTag()
    if fight_status == false then
        message(TI18N("战斗结算中，请稍后再试~~~~~"))
        return
    else
        self:clearOverdueTime()
    end
    self:touchTimeOverdue()

    if item == nil or item.data == nil then return end
    if self.base_data == nil or self.base_data.id == nil then return end
    local data = item.data
    local config = data.config
    if data.status == AdventureConst.status.can_open then
        if config and config.evt_type == AdventureEvent.EventType.mysterious then
            self:playSpecialEffect(item, "E23013", function(id) 
                controller:send20608(id)
            end) 
        else
            controller:send20608(data.id)
        end
    elseif data.status == AdventureConst.status.lock then
        message(TI18N("击败附近守卫后可探索该区域"))
    elseif config then
        if data.status == AdventureConst.status.open then            
            if config.evt_type == AdventureEvent.EventType.effect and next(config.handle_type) ~= nil then -- 特效类的事件
                controller:send20620(data.id, AdventureEvenHandleType.handle, {}) 
            elseif config.evt_type == AdventureEvent.EventType.buff then
                controller:send20620(data.id, AdventureEvenHandleType.handle, {})
            elseif config.evt_type == AdventureEvent.EventType.skill then               -- 技能,这个时候把这个位置记录出来吧
                self.room_skill_list[data.id] = item
                controller:send20620(data.id, AdventureEvenHandleType.handle, {})
            else
                controller:openWindowByConfig(data)
            end
        elseif config.evt_type == AdventureEvent.EventType.shop then
            controller:openWindowByConfig(data)
        else
            if config.evt_type == AdventureEvent.EventType.next and data.status == AdventureConst.status.over and self.base_data then
                if item.is_last_floor == true then
                    message(TI18N("已达冒险最顶层,请等待冒险重置"))
                    return
                end
                self:gotoNextFloor(data.id)
            end
        end
    end
end

--==============================--
--desc:播放特殊资源
--time:2019-01-26 08:21:26
--@effect_name:
--@callback:
--@return 
--==============================--
function AdventureMainWindow:playSpecialEffect(item, effect_name, callback)
    if tolua.isnull(item) or item.data == nil then return end
    item:changeBossEffectStatus(callback, PlayerAction.action_1)
end

--==============================--
--desc:播放采集类的特效
--time:2019-02-18 04:04:22
--@item:
--@callback:
--@return 
--==============================--
function AdventureMainWindow:playCollectEffect(item, callback)
	if tolua.isnull(item) then return end
    if item.data == nil or item.data.config == nil or item.data.config.handle_type == nil then return end
    if self.collect_effect_list[item.data.id] then      -- 正在播放
        return
    end
    local data = item.data
    local handle_type = item.data.config.handle_type
    if handle_type == nil or handle_type[1] == nil or next(handle_type[1]) == nil then
        callback(data)
        return
    end
    local effect_res = handle_type[1][1]        -- 采集特效资源
    local effect_desc = handle_type[1][2]       -- 采集描述
    local finish_func = function()              -- 特效播放完成
        if not tolua.isnull(item) then
	        item:setOtherDesc(false)
        end
        if not tolua.isnull(self.root_wnd) then
            local tmp_spine = self.collect_effect_list[data.id]
            if tmp_spine then
                tmp_spine:runAction(cc.RemoveSelf:create(true)) 
                self.collect_effect_list[data.id] = nil
            end
        end
        callback(data)
    end

    local world_pos = item:convertToWorldSpace(cc.p(0, 0))
    local node_pos = self.root_wnd:convertToNodeSpace(world_pos)    
    local spine = createEffectSpine(effect_res,cc.p(node_pos.x+71, node_pos.y+45), cc.p(0.5,0.5), false, PlayerAction.action, finish_func)
    spine:setTimeScale(1.3)
    self.root_wnd:addChild(spine)
    self.collect_effect_list[data.id] = spine
    if effect_desc ~= "" then
        item:setOtherDesc(true, effect_desc)
    end
end 

--==============================--
--desc:3个技能处理
--time:2019-01-24 09:53:07
--@index:
--@return 
--==============================--
function AdventureMainWindow:handleSkillChoose(index)
    if index == nil then return end
    local object = self.skill_list[index]
    if object == nil or object.config == nil then return end
    if index == 1 then
        self:openChooseHP(object.config, object.num_value, object.use_count)
    elseif index == 2 then
        self:openShotKill(object.config, object.num_value, object.use_count)
    elseif index == 3 then
        controller:send20607(index, 0) 
    end
end

--==============================--
--desc:显示气血
--time:2019-01-24 09:56:40
--@return 
--==============================--
function AdventureMainWindow:openChooseHP(config, num_value, use_count)
    -- 这里需要判断一下 如果当前伙伴全部死了.就不要打开了
    if model:allHeroIsDie() == true then
        message(TI18N("没有可使用宝可梦"))
        return
    end
    controller:openAdventureUseHPWindow(true, {config=config, num=num_value, use_count=use_count})
end

--==============================--
--desc:显示一击必杀
--time:2019-01-24 09:57:07
--@return 
--==============================--
function AdventureMainWindow:openShotKill(config, num_value, use_count)
    controller:openAdventureShotKillWindow(true,  {config=config, num=num_value, use_count=use_count})
end

--==============================--
--desc:去往下一层
--time:2018-10-15 11:50:00
--@config:
--@return 
--==============================--
function AdventureMainWindow:gotoNextFloor(id)
    if self.goto_next_alert then return end

    local function cancel_callback()
        self.goto_next_alert = nil
    end
    id = id or 0
    local function confirm_callback()
        controller:send20620(id, AdventureEvenHandleType.handle, {}) 
        self.goto_next_alert = nil

        -- if id == 13 and self.base_data and self.base_data.id then --13 表示是传送门
        --     local new_id = self.base_data.id + 1
        --     local config = Config.AdventureMineData.data_floor_data[new_id]
        --     if config then --表示下一层是矿脉层
        --         controller:requestEnterAdventureMine(new_id)
        --     end
        -- end
    end

    local desc = TI18N("进入下一层后，将无法返回该层，是否进入？") 
    local room_list = model:getRoomList() 
    if room_list then
        for k,v in pairs(room_list) do
            if v.status == AdventureConst.status.can_open then
                desc = TI18N("本层还有未探索区域，此时进入下一层可能会错过事件奖励，是否继续？")
                break
            end
        end
    end

    self.goto_next_alert = CommonAlert.show(desc,TI18N("确定"),confirm_callback,TI18N("取消"),cancel_callback)
end

---引导需要
function AdventureMainWindow:getAlert()
    if self.goto_next_alert then
        return self.goto_next_alert
    end
end

--==============================--
--desc:获得技能播放飘逸效果
--time:2019-01-26 04:30:33
--@id:
--@skill_id:
--@return 
--==============================--
function AdventureMainWindow:playSkillEffectAction(id, skill_id) 
    if id == nil or skill_id == nil then return end
    local room_cell = self.room_skill_list[id]
    if room_cell == nil then return end
    local evt_img = room_cell:getEvtImg()
    if evt_img == nil then return end

    local object = self.skill_list[skill_id]
    if object == nil or tolua.isnull(object.node) then return end

    local size = evt_img:getContentSize()
    local world_pos = evt_img:convertToWorldSpace(cc.p(0, 0))
    local local_pos = self.root_wnd:convertToNodeSpace(world_pos)               -- 起始位置,需要算上偏移

    local target_world_pos = object.node:convertToWorldSpace(cc.p(0, 0))
    local target_local_pos = self.root_wnd:convertToNodeSpace(target_world_pos) 

    local skill_res_id = "adventurewindow_6"
    if skill_id == 2 then
        skill_res_id = "adventurewindow_7" 
    elseif skill_id == 3 then
        skill_res_id = "adventurewindow_8"
    end

    local start_x = local_pos.x + size.width * 0.5
    local start_y = local_pos.y + size.height * 0.5 

    local target_size = object.node:getContentSize()
    local target_x = target_local_pos.x + target_size.width * 0.5 
    local target_y = target_local_pos.y + target_size.height * 0.5 

    -- 创建单位,并且移动到指定点
    local item_res = PathTool.getResFrame("adventure", skill_res_id, false, "adventurewindow")
    local fly_object = nil
    if #self.fly_cache_item_list == 0 then
        fly_object = {}
        fly_object.item = createSprite(item_res, start_x,  start_y, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        fly_object.res_id = item_res
    else
        fly_object = table_remove(self.fly_cache_item_list, 1)
    end

    if fly_object.item and fly_object.res_id then
        fly_object.id = id
        fly_object.item:setScale(1.3)
        fly_object.item:setVisible(true)
        fly_object.item:setPosition(start_x, start_y)

        if fly_object.res_id ~= item_res then
            fly_object.res_id = item_res
            loadSpriteTexture(fly_object.item, item_res, LOADTEXT_TYPE_PLIST)
        end
        self.fly_item_list[id] = fly_object
        self:flySkillItemToTarget(fly_object, start_x, start_y, target_x, target_y)
    end
end

--==============================--
--desc:移动技能图标
--time:2019-01-26 05:27:34
--@object:
--@start_x:
--@start_y:
--@target_x:
--@target_y:
--@return 
--==============================--
function AdventureMainWindow:flySkillItemToTarget(object, start_x, start_y, target_x, target_y)
	if object == nil or tolua.isnull(object.item) then return end
	
	local bezier = {}
	local begin_pos = cc.p(start_x, start_y)
	table.insert(bezier, begin_pos)
	
	local end_pos = cc.p(target_x, target_y)

	local min_pos = cc.pMidpoint(begin_pos, end_pos)
	local off_y = 10
	local off_x = - 30
	local controll_pos = cc.p(min_pos.x + off_x, begin_pos.y - off_y)

	table.insert(bezier, controll_pos)
	table.insert(bezier, end_pos)
	
	local bezierTo = cc.BezierTo:create(1, bezier)
	local call_fun = cc.CallFunc:create(function()
		object.item:setVisible(false)
        self.fly_item_list[object.id] = nil
		table_insert(self.fly_cache_item_list, object)
	end)
	
	local seq = cc.Sequence:create(bezierTo, call_fun)
	local scale_to = cc.ScaleTo:create(1, 0.5)
	local spawn = cc.Spawn:create(scale_to, seq)
	object.item:runAction(spawn)
end 

function AdventureMainWindow:close_callback()
    self:clearOverdueTime()
    GlobalTimeTicket:getInstance():remove("AdventureMainWindow.play_effect_timeout") 

    -- BattleController:getInstance():openBattleView(false)
    -- -- 还原就的战斗ui类型
    -- MainuiController:getInstance():resetUIFightType()

    --移除掉缓动图标
    if self.fly_item_list then
        for k, object in pairs(self.fly_item_list) do
            if object.item then
                doStopAllActions(object.item)
                object.item:removeFromParent()
            end
        end
        self.fly_item_list = nil
    end
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    self:clearEneTime()
    for i,v in ipairs(self.hero_list) do
        v:DeleteMe()
    end
    self.hero_list = nil
    -- if self.style_resources_load then
    --     self.style_resources_load:DeleteMe()
    -- end
    -- self.style_resources_load = nil
    self:playEnterEffect(false)
	controller:openAdventureMainWindow(false)

     if self.is_wide_screen  then
        MainuiController:getInstance():setMainChatBoxCurViewType(ChatConst.ViewType.Normal) 
    end
end

-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      地块的单例,包含了事件等
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureCellItem = class("AdventureCellItem", function()
	return ccui.Layout:create()
end) 

function AdventureCellItem:ctor()
    self.cell_path = "resource/adventure/img/%s.png"
    self.evt_path = "resource/adventure/evt/%s.png"

    self.is_last_floor = false      -- 是否是最后一层

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("adventure/adventure_cell_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.background = self.container:getChildByName("background")
    self.cell = self.container:getChildByName("cell")
    self.evt_container = self.container:getChildByName("evt_container")
    self.lock = self.container:getChildByName("lock")

    self:registerEvent()
end

function AdventureCellItem:registerEvent()
	self.container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
			if self.data and self.call_back then
                -- 非下一关的over事件就不需要给点击回调了
                if self.data then
                    if self.data.config and self.data.status == AdventureConst.status.over then
                        if self.data.config.evt_type ~= AdventureEvent.EventType.next and self.data.config.evt_type ~= AdventureEvent.EventType.shop then
                            return
                        end
                    end
                end
				self.call_back(self)
			end
		end
	end)
end

function AdventureCellItem:addCallBack(call_back)
	self.call_back = call_back
end

function AdventureCellItem:setExtendData(is_update)
    self.is_update = is_update 
end

function AdventureCellItem:setData(data)
	self.data = data
    if data then
        self.is_last_floor = false

        local cell_key_str = getNorKey(data.lock, data.id, data.status, data.evt_id)
        if self.cell_key_str == cell_key_str then return end
        self.cell_key_str  = cell_key_str 

        -- 解锁的时候播放一个特效
        -- if self.is_update == true and data.status == AdventureConst.status.open and self.cell_cache_status == AdventureConst.status.can_open then
        --     playEffectOnce(PathTool.getEffectRes(603), 71, 45, self.container) 
        -- end
        -- self.cell_cache_status  = data.status

        -- 还原采集描述类
        self:setOtherDesc(false)

        -- 大红×状态
        -- self.lock:setVisible((data.lock == 1))

        -- 层级问题
        if self.cell_id ~= data.id then
            self.cell_id = data.id
            self:setLocalZOrder(25 - data.id)
            -- 引导需要
            self.container:setName("guide_adventure_cell_"..data.id)
        end
        -- 引导需要
        if self.guide_evt_id ~= data.evt_id and data.evt_id ~= 0 then
            self.guide_evt_id  = data.evt_id
            self.container:setTag(data.evt_id)
        end

        -- 设置当前事件样式显示
        self:updateEvtInfo()

        -- 地块的状态判断,以及资源的重载
        if data.status == AdventureConst.status.open or data.status == AdventureConst.status.over then
            self.cell:setVisible(false)
        elseif self.data.config and self.data.config.evt_type == AdventureEvent.EventType.mysterious then
            self.cell:setVisible(false)
        else
            self:createCellSytle()
        end
    end
end

--==============================--
--desc:创建地块样式
--time:2018-10-15 02:02:55
--@return 
--==============================--
function AdventureCellItem:createCellSytle()
    if self.data == nil then return end
    local data = self.data
    self.cell:setVisible(true)
    -- local cell_res = string_format(self.cell_path, data.res_id)
    local cell_res = string_format(self.cell_path, "1")
    if self.cell_res ~= cell_res then
        self.cell_res = cell_res
        self.cell_resources_load = createResourcesLoad(cell_res, ResourcesType.single, function() 
            if not tolua.isnull(self.cell) then
                loadSpriteTexture(self.cell, cell_res, LOADTEXT_TYPE) 
                self:setCellStatus()
            end
        end, self.cell_resources_load) 
    else
        self:setCellStatus()
    end
end

--==============================--
--desc:地块的状态,是暗调还是说亮起来可点
--time:2018-10-13 08:58:47
--@return 
--==============================--
function AdventureCellItem:setCellStatus()
    -- if self.data == nil then return end
    -- if self.cell_status == self.data.status then return end
    -- self.cell_status = self.data.status
    -- if self.data.status == AdventureConst.status.lock then
    --     setChildDarkShader(true, self.cell)
    -- elseif self.data.status == AdventureConst.status.can_open then
    --     setChildDarkShader(false, self.cell)
    -- end
end

--==============================--
--desc:清掉数据资源
--time:2018-10-13 12:02:59
--@return 
--==============================--
function AdventureCellItem:clearEvtResources()
    if self.event_img then
        doStopAllActions(self.event_img)
    end
    if self.head then
        self.head:DeleteMe()
    end
    self.head = nil
    if self.event_model then
        self.event_model:removeFromParent()
        self.event_model = nil
    end
    self.event_model_res = ""
end

--==============================--
--desc:事件的显示,加载不同事件资源
--time:2018-10-13 08:59:11
--@return 
--==============================--
function AdventureCellItem:updateEvtInfo()
	if self.data == nil then return end
	local evt_config = adventure_event(self.data.evt_id)
	self.data.config = evt_config   -- 储存配置

    -- 事件数据不存在或者事件资源显示数据不存在
    if evt_config == nil or evt_config.res_id == nil or evt_config.res_id[1] == nil then
        self:clearEvtResources()
        return
    end
    -- 如果是下一层事件,需要判断是不是还有下一层,否则不需要显示
    if evt_config.evt_type == AdventureEvent.EventType.next then
        local base_data = model:getAdventureBaseData()
        if base_data == nil or base_data.id == nil then 
            self:clearEvtResources() 
            return
        end
        local next_config = floor_config[base_data.id + 1]
        if next_config == nil and evt_config.evt_type == AdventureEvent.EventType.next then 
            self.is_last_floor = true
        end
    end
    -- 其他事件处理
	if self.data.status ~= AdventureConst.status.over or evt_config.evt_type == AdventureEvent.EventType.init 
        or evt_config.evt_type == AdventureEvent.EventType.next or evt_config.evt_type == AdventureEvent.EventType.block 
        or evt_config.evt_type == AdventureEvent.EventType.shop then
        self:createEvtShowInfo(evt_config)
	else
        self:clearEvtResources()
	end
end 

function AdventureCellItem:setOtherDesc(status, desc)
    if not status then
        if self.other_desc then
            self.other_desc:setVisible(false)
        end
    else
        if self.other_desc == nil then
            self.other_desc = createLabel(24,1, 2, 71, 60, desc, self.container,nil, cc.p(0.5, 0))
        end
        self.other_desc:setString(desc)
        self.other_desc:setVisible(true) 
    end
end

--==============================--
--desc:创建事件显示效果
--time:2018-10-13 07:18:27
--@evt_config:
--@return 
--==============================--
function AdventureCellItem:createEvtShowInfo(evt_config)
    if evt_config == nil then return end

    local res_data = evt_config.res_id[1]
    local res_type = res_data[1]    -- 1.图片资源(如果是怪物或者boss事件的,就创建特效) 2.特效资源
    local res_id = res_data[2]  -- 资源名字
    local is_shadow =(evt_config.shadow == 1)
    if res_type == nil or res_id == nil then return end
    -- 储存资源
    if self.event_model_res == getNorKey(res_type, res_id) then return end
    self:clearEvtResources()

    self.event_model_res = getNorKey(res_type, res_id)

     if res_type == 2 then
        self.event_model = createEffectSpine(res_id, cc.p(71, 68), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.evt_container:addChild(self.event_model)
    else
        if is_shadow == true then
            self.event_model = createSprite(PathTool.getResFrame("adventure", "adventurewindow_3", false, "adventurewindow"), 71, 30, self.evt_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            
            local event_path = string_format(self.evt_path, res_id)
            if AdventureEvent.isMonster(evt_config.evt_type) then
                if self.head == nil then
                    self.head = PlayerHead.new(PlayerHead.type.other, nil, nil, event_path, nil, false)
                    self.head:setHeadBgScale(1)
                    self.head:setPosition(35, 92)
                    self.event_model:addChild(self.head)
                end
                breatheShineAction4(self.head)
                self.head:setHeadRes(evt_config.face)
            else
                self.event_img = createSprite(nil, 35, 96, self.event_model, cc.p(0.5, 0.5))
                breatheShineAction4(self.event_img)
                self.event_resources_load = createResourcesLoad(event_path, ResourcesType.single, function()
                    if not tolua.isnull(self.event_img) then
                        loadSpriteTexture(self.event_img, event_path, LOADTEXT_TYPE)
                    end
                end, self.event_resources_load)
            end
        else
            self.event_model = createSprite(nil, 71, 2, self.evt_container, cc.p(0.5, 0))
            local event_path = string_format(self.evt_path, res_id)
            self.event_resources_load = createResourcesLoad(event_path, ResourcesType.single, function()
                if not tolua.isnull(self.event_model) then
                    loadSpriteTexture(self.event_model, event_path, LOADTEXT_TYPE)
                end
            end, self.event_resources_load)
        end
    end
end

--==============================--
--desc:摧毁BOSS雕像
--time:2019-01-26 09:03:11
--@callback:
--@action_name:
--@return 
--==============================--
function AdventureCellItem:changeBossEffectStatus(callback, action_name)
    if self.is_in_playing == true then return end
    if self.data == nil or self.data.config == nil then return end
    -- if self.event_model == nil then return end
    if tolua.isnull(self.event_model) then return end
    if self.data.config.evt_type == AdventureEvent.EventType.mysterious then
        self.is_in_playing = true
        self.event_model:setAnimation(0, action_name, false)
        delayRun(self.event_model, 1.5, function()
            self.is_in_playing = false
            callback(self.data.id)
        end)



        -- local finish_func = function( event)
        --     if event.animation == action_name then
        --         self.is_in_playing = false
        --         callback(self.data.id)
        --     end
        -- end
        -- if self.event_model.registerSpineEventHandler then
        --     self.is_in_playing = true
        --     self.event_model:registerSpineEventHandler(finish_func, sp.EventType.ANIMATION_COMPLETE)
        --     self.event_model:setToSetupPose()
        --     self.event_model:setAnimation(0, action_name, false)
        -- end
    end
end

--==============================--
--desc:获取事件图标,这个东西现在只有技能事件才需要,需要播放移动动作
--time:2019-01-26 05:00:42
--@return 
--==============================--
function AdventureCellItem:getEvtImg()
    return self.event_img
end

function AdventureCellItem:DeleteMe()
    if self.cell_resources_load then
        self.cell_resources_load:DeleteMe()
    end
    self.cell_resources_load = nil
    if self.event_resources_load then
        self.event_resources_load:DeleteMe()
    end
    self.event_resources_load = nil
end