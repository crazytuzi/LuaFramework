---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/11/01 14:43:33
-- @description: 事件触发的战斗怪物信息界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()

MonopolyMasterInfoWindow = MonopolyMasterInfoWindow or BaseClass(BaseView)

function MonopolyMasterInfoWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "monopoly/monopoly_master_info_window"
    self.text_name_list = {
        {"win_title", "万圣大挑战"},
        {"reward_title", "随机获得以下奖励"},
        {"enemy_title", "敌方阵容"},
        {"tips_txt", "战斗失败也能获取少量奖励"},
    }
end

function MonopolyMasterInfoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    self.btn_fight = self.main_container:getChildByName("btn_fight")
    self.btn_fight:getChildByName("label"):setString(TI18N("开战"))
    self.name_txt = self.main_container:getChildByName("name_txt")
    self.atk_txt = self.main_container:getChildByName("atk_txt")
    self.reward_panel = self.main_container:getChildByName("reward_panel")
    self.enemy_panel = self.main_container:getChildByName("enemy_panel")

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setPosition(175, 545)
    self.main_container:addChild(self.role_head)
    
    self.award_item_list = {} -- 奖励列表

    -- 阵容
    local scroll_view_size = self.enemy_panel:getContentSize()
    local setting = {
        item_class = HeroExhibitionItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 18,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = HeroExhibitionItem.Width*0.85,               -- 单元的尺寸width
        item_height = HeroExhibitionItem.Height*0.85,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        scale = 0.85
    }
    self.enemy_scrollview = CommonScrollViewLayout.new(self.enemy_panel, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.enemy_scrollview:setClickEnabled(false)
end

function MonopolyMasterInfoWindow:register_event()
    registerButtonEventListener(self.btn_fight, handler(self, self.onClickFightBtn), true)

    --  阵容数据
    self:addGlobalEvent(MonopolyEvent.Get_Master_Data_Event, function (data)
        self:setData(data)
    end)
end

-- 点击出战
function MonopolyMasterInfoWindow:onClickFightBtn()
    if self.evt_type == MonopolyConst.Event_Type.Trap then
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Monopoly_Evt)
    elseif self.evt_type == MonopolyConst.Event_Type.Boss then
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Monopoly_Evt)
    end
    _controller:openMonopolyMasterInfoWindow(false)
end

-- evt_type:事件类型
function MonopolyMasterInfoWindow:openRootWnd(evt_type, step_id)
    self.evt_type = evt_type or MonopolyConst.Event_Type.Trap
    self.step_id = step_id or 1

    _controller:sender27410(self.step_id)
    self:setAwardList()
end

function MonopolyMasterInfoWindow:setAwardList()
    if next(self.award_item_list) ~= nil then return end
    local award_cfg = {}
    if self.evt_type == MonopolyConst.Event_Type.Trap then
        award_cfg = Config.MonopolyMapsData.data_const["monopoly_event_trap_rewardshow"]
    elseif self.evt_type == MonopolyConst.Event_Type.Boss then
        award_cfg = Config.MonopolyMapsData.data_const["monopoly_event_boss_rewardshow"]
    end
    if award_cfg and award_cfg.val then
        local con_size = self.reward_panel:getContentSize()
        local space = 20
        local start_x = con_size.width*0.5 - (#award_cfg.val-1)*((space+BackPackItem.Width*0.9)*0.5)
        for i, bid in ipairs(award_cfg.val or {}) do
            local item_node = BackPackItem.new(true, true, nil, 0.9, nil, true)
            item_node:setBaseData(bid)
            item_node:setPosition(start_x+(i-1)*(space+BackPackItem.Width*0.9), con_size.height*0.5)
            self.reward_panel:addChild(item_node)
            self.award_item_list[i] = item_node
        end
    end
end

function MonopolyMasterInfoWindow:setData(data)
    if not data then return end
    self.data = data

    self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    self.role_head:setLev(data.lev)

    self.name_txt:setString(data.name or "")
    self.atk_txt:setString(data.power or 0)

    -- 阵容
    local extendData = {scale = 0.85, can_click = false}
    self.enemy_scrollview:setData(data.guards or {}, nil, nil, extendData)
end

function MonopolyMasterInfoWindow:close_callback()
    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
    for k,item in pairs(self.award_item_list) do
        item:DeleteMe()
        item = nil
    end
    if self.enemy_scrollview then
        self.enemy_scrollview:DeleteMe()
        self.enemy_scrollview = nil
    end
    _controller:openMonopolyMasterInfoWindow(false)
end