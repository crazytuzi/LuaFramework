--------------------------------------------
-- @Author  : lc
-- @Editor  : lc
-- @Date    : 2019-10-15
-- @description    : 
		-- 合服活动积分奖励界面
---------------------------------
local _controller = ActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format
local _base_val = Config.HolidayMergeGoalData.data_const["base_max_score"].val/1000 --基础积分

MergeAimRewardPanel = MergeAimRewardPanel or BaseClass(BaseView)


function MergeAimRewardPanel:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "seven_goal/seven_goal_adventure_lev_reward"
end

function MergeAimRewardPanel:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
    main_container:getChildByName("Text_1"):setString(TI18N("活动奖励"))
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = MergeAimRewardItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 608,               -- 单元的尺寸width
        item_height = 167,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.award_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)

    self.btn_close = main_container:getChildByName("btn_close")
end

function MergeAimRewardPanel:register_event(  )
	registerButtonEventListener(self.btn_close, function ( )
		_controller:openMergeAimRewardPanel(false)
	end, true)

    if not self.merge_info_event then
        self.merge_info_event = GlobalEvent:getInstance():Bind(ActionEvent.Merge_Aim_Event,function(data)
            if not data then return end
                self.data = data
                self:setData(data)
        end)
    end    

end

function MergeAimRewardPanel:openRootWnd()  --哪些已经领取了得
    ActionController:getInstance():sender27300() -- 
end

function MergeAimRewardPanel:setData(data)
	local item_data = {}
	for k,value in ipairs(Config.HolidayMergeGoalData.data_score_award) do
		local data1 = {}
		data1.sys_config = value
        data1.reward_config = data
		_table_insert(item_data, data1)
	end
    if self.award_scrollview then
	   self.award_scrollview:setData(item_data)
    end
    

end

function MergeAimRewardPanel:close_callback(  )
	if self.award_scrollview then
		self.award_scrollview:DeleteMe()
		self.award_scrollview = nil
	end
	_controller:openMergeAimRewardPanel(false)
end


---------------------------@ item
MergeAimRewardItem = class("MergeAimRewardItem", function()
    return ccui.Widget:create()
end)

function MergeAimRewardItem:ctor()
	self:configUI()
	self:register_event()
end

function MergeAimRewardItem:configUI(  )
	self.size = cc.size(608,167)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("seven_goal/seven_goal_adventure_lev_reward_item"))
    self:addChild(self.root_wnd)
    local main_container = self.root_wnd:getChildByName("main_container")
    self.title_name = main_container:getChildByName("title_name")
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get_label = self.btn_get:getChildByName("Text_1")
    self.btn_get_label:setString(TI18N("领取"))
    self.has_spr = main_container:getChildByName("has_spr")
    self.has_spr:setVisible(false)
    self.num_txt = main_container:getChildByName("num_txt")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80  ,                   -- 缩放
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    --self.item_scrollview:jumpToMove(cc.p(-167,0), 0.6)  --自动移动到当前等级
end

function MergeAimRewardItem:setData( item_data )
	if not item_data then return end
	local sys_config = item_data.sys_config  --配表数据
    local reward_config = {}
    if item_data.reward_config == nil then return end
    reward_config = item_data.reward_config  --获取的数据
	self.award_id = sys_config.id
    
    self:setCount(sys_config,reward_config)  --设置各项积分
    self:setReward_icon(sys_config) --设置奖励

	
    self.status = true
    self.isGray = false
    if self.award_id > reward_config.lev then
        self.status = true
        self.isGray = true
    elseif self.award_id == reward_config.lev  then
        if reward_config.score < reward_config.max_score then
            self.status = true
            self.isGray = true
        else
            if reward_config.score >= reward_config.max_score then
                reward_config.score = reward_config.max_score
                for k,v in pairs(reward_config.reward) do
                    if v.id == self.award_id then  --当前为已领取奖励  显示已完成
                        self.status = false
                    end
                end 
            end
        end
    elseif self.award_id < reward_config.lev then
        if #reward_config.reward == 0 then  --没有领取过奖励  
            self.status = true 
            self.isGray = false
        else
            for k,v in pairs(reward_config.reward) do
                if v.id == self.award_id then  --当前为已领取奖励  显示已完成
                    self.status = false
                end
            end
        end
        
    end
    self:setStatus()
	
end
function MergeAimRewardItem:setStatus()
    self.btn_get:setVisible(self.status == true)  --  true 可领取  false 已完成
    self.has_spr:setVisible(self.status == false)  --已经领取过  就显示
    self:setGray(self.isGray)
end

--置灰操作
function MergeAimRewardItem:setGray( bool )
    if self.btn_get:isVisible() == true then
        setChildUnEnabled(bool, self.btn_get)
        self.btn_get:setTouchEnabled(not bool)
        if bool == true then
            self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
        else
            self.btn_get_label:enableOutline(Config.ColorData.data_color4[264], 2)
        end
    end
end

--设置积分
function MergeAimRewardItem:setCount( sys_config, reward_config )  --设置积分
    if reward_config == nil then return end
    local count = sys_config.count
    local count1 = 0
    local count2 = 0
    if self.award_id == 1 then
        count1 = sys_config.count
    else
        count1 =   Config.HolidayMergeGoalData.data_score_award[self.award_id-1].count * 100
    end
    if reward_config.lev <= 1 then
        count2 =   0
    else
        count2 =   Config.HolidayMergeGoalData.data_score_award[reward_config.lev -1].count * 100
    end

    if self.award_id < reward_config.lev then
        self.num_txt:setString(_string_format("(%d/%d)", sys_config.count* tonumber(_base_val), sys_config.count* tonumber(_base_val)))
    elseif self.award_id == reward_config.lev then
        self.num_txt:setString(_string_format("(%d/%d)", reward_config.score + count2, sys_config.count* tonumber(_base_val)))
    else
        self.num_txt:setString(_string_format("(%d/%d)", reward_config.score + count2, sys_config.count* tonumber(_base_val)))
    end

    self.title_name:setString(_string_format(TI18N("积分累计达到%d"), sys_config.count * tonumber(_base_val)))
    self.num_txt:setVisible(true)
end

--设置奖励
function MergeAimRewardItem:setReward_icon( sys_config )
    local award_list = {}
    for i,v in ipairs(sys_config.award) do
        local item_data = deepCopy(Config.ItemData.data_get_data(v[1]))
        if item_data then
            item_data.quantity = v[2]
            _table_insert(award_list, item_data)
        end
    end
    if #award_list > 4 then
        self.item_scrollview:setClickEnabled(true)
    else
        self.item_scrollview:setClickEnabled(false)
    end
    self.item_scrollview:setData(award_list)
    self.item_scrollview:addEndCallBack(function()
        local item_list = self.item_scrollview:getItemList()
        for k,v in pairs(item_list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end


function MergeAimRewardItem:register_event( )
	registerButtonEventListener(self.btn_get, handler(self, self.onClickGetBtn), true)
    if not self.merge_item_event then
        self.event = GlobalEvent:getInstance():Bind(ActionEvent.Merge_Box_Status_Event,function(data)
            if not data then return end
            if data.flag == 1 then
                self.status = false
            end
        end)
    end
end

--
function MergeAimRewardItem:onClickGetBtn(  )
	if self.award_id then
        local data = {}
        local data_1 = {}
        data.id = self.award_id
        table.insert(data_1,data)
		_controller:sender27301(data_1)
	end
end

function MergeAimRewardItem:DeleteMe(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
    if self.merge_item_event then
        GlobalEvent:getInstance():UnBind(self.merge_item_event)
        self.merge_item_event = nil
    end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end