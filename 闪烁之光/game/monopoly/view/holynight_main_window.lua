---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/17 15:46:08
-- @description: 圣夜奇境主界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_isnert = table.insert

HolynightMainWindow = HolynightMainWindow or BaseClass(BaseView)

function HolynightMainWindow:__init()
    self.is_full_screen = true
	self.view_tag = ViewMgrTag.WIN_TAG
	self.win_type = WinType.Full
    self.layout_name = "monopoly/holynight_main_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("monopoly", "monopolyenter"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("monopoly","monopoly_enter_bg_1",true), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("monopoly","monopoly_enter_bg_2"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("monopoly/build","build_1"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("monopoly/build","build_2"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("monopoly/build","build_3"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("monopoly/build","build_4"), type = ResourcesType.single},
    }

    self.role_vo = RoleController:getInstance():getRoleVo()
    self.monopoly_item_list = {} -- 大富翁关卡列表
end

function HolynightMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("monopoly","monopoly_enter_bg_1",true), LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
    end
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    local build_bg = self.main_container:getChildByName("build_bg")
    loadSpriteTexture(build_bg, PathTool.getPlistImgForDownLoad("monopoly","monopoly_enter_bg_2"), LOADTEXT_TYPE)

    local top_panel = self.main_container:getChildByName("top_panel")
    self.btn_rule = top_panel:getChildByName("btn_rule")
    self.atk_txt = top_panel:getChildByName("atk_txt")
    self.hp_txt = top_panel:getChildByName("hp_txt")
    self.candy_txt = top_panel:getChildByName("candy_txt")
    self.time_txt = top_panel:getChildByName("time_txt")
    self.candy_sp = top_panel:getChildByName("candy_sp")
    self.candy_sp:setScale(0.5)
    
    self.gold_item_bid = 0 -- 糖果bid
    self.gold_item_name = "" -- 糖果名称
    local gold_cfg = Config.MonopolyMapsData.data_const["monopoly_gold_id"]
    if gold_cfg then
        self.gold_item_bid = gold_cfg.val
        local gold_item_cfg = Config.ItemData.data_get_data(self.gold_item_bid)
        if gold_item_cfg then
            self.gold_item_name = gold_item_cfg.name
            local item_res = PathTool.getItemRes(gold_item_cfg.icon)
            loadSpriteTexture(self.candy_sp, item_res, LOADTEXT_TYPE)
        end
    end

    self.shop_btn = self.main_container:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("圣夜商店"))

    local bottom_panel = self.main_container:getChildByName("bottom_panel")
    bottom_panel:getChildByName("award_title"):setString(TI18N("奖励预览"))
    self.close_btn = bottom_panel:getChildByName("close_btn")
    self.image_boss = bottom_panel:getChildByName("image_boss")
    self.boss_txt = self.image_boss:getChildByName("boss_txt")

    local award_list = bottom_panel:getChildByName("award_list")
    local scroll_view_size = award_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.8,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.8,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.8
    }
    self.award_scrollview = CommonScrollViewLayout.new(award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)

    -- 适配
    local top_off = display.getTop(self.main_container)
	local bottom_off = display.getBottom(self.main_container)
	top_panel:setPositionY(top_off - 158)
	bottom_panel:setPositionY(bottom_off)
end

function HolynightMainWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.btn_rule, function (param,sender, event_type)
        local rule_cfg = Config.MonopolyMapsData.data_const["monopoly_rule_1"]
        if rule_cfg then
            TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
        end
    end, true, 1, nil, 0.8)
    registerButtonEventListener(self.image_boss, handler(self, self.onClickBossBtn), true)
    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true)

    -- 活动基础数据
    self:addGlobalEvent(MonopolyEvent.Update_Monopoly_Base_Data_Event, function ()
        self:setData()
    end)

    -- buff数据
    self:addGlobalEvent(MonopolyEvent.Update_Buff_Data_Event, function ()
        self:updateBuffData()
    end)

    -- boss击杀数
    self:addGlobalEvent(MonopolyEvent.Update_Boss_Num_Event, function (  )
        self:updateBossNumData()
    end)

    -- 道具数量变化
	if not self.role_assets_event and self.role_vo then
        self.role_assets_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and id == self.gold_item_bid and self.role_vo then 
                self:updateBuffData()
            end
        end)
    end
end

function HolynightMainWindow:onClickCloseBtn()
    _controller:openHolynightMainWindow(false)
end

-- 点击奇境boss
function HolynightMainWindow:onClickBossBtn()
    MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyBoss)
end

function HolynightMainWindow:onClickShopBtn(  )
    MallController:getInstance():openMallActionWindow(true, 993040)
end

function HolynightMainWindow:openRootWnd(sub_type)
    self.open_sub_type = sub_type
    _controller:sender27400()
    _controller:sender27504()
    _controller:sender27505()
    self:updateAwardList()
end

function HolynightMainWindow:updateAwardList()
    local award_cfg = Config.MonopolyMapsData.data_const["monopoly_gift"]
    if award_cfg then
        local award_list = {}
        for k,v in pairs(award_cfg.val) do
            local bid = v[1]
            local num = v[2]
            local vo = deepCopy(Config.ItemData.data_get_data(bid))
            if vo then
                vo.quantity = num
                _table_isnert(award_list,vo)
            end
        end
        self.award_scrollview:setData(award_list)
        self.award_scrollview:addEndCallBack(
            function()
                local list = self.award_scrollview:getItemList()
                for k, v in pairs(list) do
                    v:setDefaultTip(true)
                end
            end
        )
    end
end

function HolynightMainWindow:updateBuffData()
    local buff_data = _model:getMonopolyBuffData()
    local atk_buff_val = 0
    local hp_buff_val = 0
    for k,v in pairs(buff_data) do
        if v.buff_id == 1 then
            atk_buff_val = v.val
        elseif v.buff_id == 2 then
            hp_buff_val = v.val
        end
    end
    self.atk_txt:setString(_string_format(TI18N("攻击+%d"), atk_buff_val))
    self.hp_txt:setString(_string_format(TI18N("血量+%d"), hp_buff_val))
    
    local have_num = self.role_vo:getActionAssetsNumByBid(self.gold_item_bid)
    self.candy_txt:setString(_string_format(TI18N("%s:%d"), self.gold_item_name, have_num))
end

function HolynightMainWindow:updateBossNumData(  )
    if not self.boss_txt then return end
    local boss_num_data = _model:getMonopolyBossNumData()
    local kill_num = boss_num_data.kill_num or 0
    local all_num = boss_num_data.all_num or 0
    self.boss_txt:setString(_string_format(TI18N("奇境BOSS:%d/%d"), kill_num, all_num))    
end

function HolynightMainWindow:setData()
    self:updateHolyEndTime()

    -- 关卡列表
    self.customs_data = _model:getMonopolyBaseInfo()
    table.sort(self.customs_data, SortTools.KeyLowerSorter("id"))

    for i, item in pairs(self.monopoly_item_list) do
        item:setVisible(false)
    end
    for i = 1, 4 do
        delayRun(self.main_container, i / display.DEFAULT_FPS, function ()
            local item = self.monopoly_item_list[i]
            if not item then
                local pos_node = self.main_container:getChildByName("pos_node_" .. i)
                item = HolynightMainItem.new()
                pos_node:addChild(item)
                self.monopoly_item_list[i] = item
            end
            item:setVisible(true)
            local data = self.customs_data[i]
            item:setData(data)
            if i == 4 then
                self:loadMonopolyItemEnd()
            end
        end) 
    end
end

function HolynightMainWindow:loadMonopolyItemEnd()
    if self.open_sub_type then
        if self.open_sub_type == MonopolyConst.Sub_Type.Boss then
            self:onClickBossBtn()
        else
            local item = self.monopoly_item_list[self.open_sub_type]
            if item then
                item:onClickItem()
            end
        end
        self.open_sub_type = nil
    end
end

-- 更新剩余时间显示
function HolynightMainWindow:updateHolyEndTime()
    local end_time = _model:getMonopolyEndTime()
    local cur_time = GameNet:getInstance():getTime()
    local less_time = end_time - cur_time
    self:setLessTime(less_time)
end

--设置倒计时
function HolynightMainWindow:setLessTime(less_time)
    if tolua.isnull(self.time_txt) then
        return
    end
    local less_time = less_time or 0
    self.time_txt:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_txt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.time_txt:stopAllActions()
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function HolynightMainWindow:setTimeFormatString( time )
    if time > 0 then
        str = string.format(TI18N("活动结束: %s"),TimeTool.GetTimeFormatDay(time))
        self.time_txt:setString(str)
    else
        self.time_txt:setString("")
    end
end

function HolynightMainWindow:close_callback()
    self.time_txt:stopAllActions()
    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
    for k, item in pairs(self.monopoly_item_list) do
        item:DeleteMe()
        item = nil
    end
    if self.award_scrollview then
        self.award_scrollview:DeleteMe()
        self.award_scrollview = nil
    end
    _controller:openHolynightMainWindow(false)
end

-----------------------@ 子项
HolynightMainItem = class("HolynightMainItem", function()
    return ccui.Layout:create()
end)

function HolynightMainItem:ctor()
    self:configUI()
    self:registerEvent()

    self.is_lock = false
end

function HolynightMainItem:configUI()
    self.size = cc.size(150, 150)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("monopoly/holynight_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.image_bg = self.container:getChildByName("image_bg")
    self.image_bg:ignoreContentAdaptWithSize(true)
    self.name_bg = self.container:getChildByName("name_bg")
    self.lock_sp = self.container:getChildByName("lock_sp")
    self.name_txt = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(self.size.width*0.5, 0))
    self.container:addChild(self.name_txt)
end

function HolynightMainItem:registerEvent()
    registerButtonEventListener(self.image_bg, handler(self, self.onClickItem), true)
end

function HolynightMainItem:onClickItem()
    if not self.data then return end
    if self.is_lock then
        _controller:openMonopolyTips(true, self.data)
    else
        if self.data.id == 1 then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_1, self.data.id)
        elseif self.data.id == 2 then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_2, self.data.id)
        elseif self.data.id == 3 then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_3, self.data.id)
        elseif self.data.id == 4 then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_4, self.data.id)
        end
    end
end

function HolynightMainItem:setData(data)
    if not data then return end

    -- 关卡配置数据
    self.cfg_data = Config.MonopolyMapsData.data_customs[data.id]
    if not self.cfg_data then return end
    self.data = data
    self.is_lock = (data.lock == 1)

    -- 建筑图标
    if self.cfg_data.res_id and self.cfg_data.res_id ~= "" then
        local res_path = PathTool.getPlistImgForDownLoad("monopoly/build", self.cfg_data.res_id)
        self.image_bg:loadTexture(res_path, LOADTEXT_TYPE)
    end

    -- 名称ui偏移
    local pos_x, pos_y = 75, 0
    if data.id == 1 then
        pos_x, pos_y = 85, 95
    elseif data.id == 2 then
        pos_x, pos_y = 70, 5
    elseif data.id == 3 then
        pos_x, pos_y = 75, 15
    elseif data.id == 4 then
        pos_x, pos_y = 75, 55
    end
    self.name_txt:setPosition(pos_x, pos_y)
    self.lock_sp:setPosition(pos_x-75, pos_y)
    self.name_bg:setPosition(pos_x, pos_y)
    
    local dev_percent = 0
    if self.cfg_data.max_develop > 0 then
        dev_percent = (data.guild_develop or 0)/self.cfg_data.max_develop*100
    end
    if dev_percent > 100 then
        dev_percent = 100
    end
    if self.is_lock then
        self.name_txt:setString(TI18N(_string_format("<div fontcolor=#fffced outline=2,#330b03>%s</div>", self.cfg_data.name)))
    else
        self.name_txt:setString(TI18N(_string_format("<div fontcolor=#fffced outline=2,#330b03>%s</div><div fontcolor=#72ff5f outline=2,#330b03> %d%%</div>", self.cfg_data.name, dev_percent)))
    end
    self:updateLockState()
end

function HolynightMainItem:updateLockState()
    self.lock_sp:setVisible(self.is_lock == true)
    setChildUnEnabled(self.is_lock, self.image_bg)
    setChildUnEnabled(self.is_lock, self.name_bg)
end

function HolynightMainItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end