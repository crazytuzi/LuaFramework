--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2020-02-06
-- @description    : 
		-- 情人节(活动)主界面
---------------------------------
local _controller = ActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

ActionSweetPanel = class("ActionSweetPanel", function()
    return ccui.Widget:create()
end)

function ActionSweetPanel:ctor(bid)
    self.holiday_bid = bid or ActionRankCommonType.sweet
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionsweet", "actionsweet"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("actionsweet","txt_cn_actionsweet_bg", true), type = ResourcesType.single},
	}

    self._init_flag = false

	self.resources_load = ResourcesLoad.New(true)
	self.resources_load:addAllList(self.res_list, function()
		self:loadResListCompleted()
	end)
end

function ActionSweetPanel:loadResListCompleted(  )
    self:configUI()
	self:registerEvent()
    _controller:sender28500() -- 请求基础数据
    RankController:getInstance():send_12900(RankConstant.RankType.sweet, 1, 3) -- 请求前三名数据
	self._init_flag = true
    self:updateItemNum()
end

function ActionSweetPanel:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("actionsweet/action_sweet_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    local image_bg = main_container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getPlistImgForDownLoad("actionsweet","txt_cn_actionsweet_bg", true), LOADTEXT_TYPE)

    self.btn_rule = main_container:getChildByName("btn_rule")
    self.btn_shop = main_container:getChildByName("btn_shop")
    self.btn_shop:getChildByName("label"):setString(TI18N("积分币商店"))
    self.btn_task = main_container:getChildByName("btn_task")
    self.btn_task:getChildByName("label"):setString(TI18N("情人节任务"))
    self.btn_award = main_container:getChildByName("btn_award")

    self.check_rank_txt = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(613, 621))
    self.check_rank_txt:setString(_string_format("<div fontcolor=#c44144 href=xxx>%s</div>", TI18N("点击查看更多")))
    self.check_rank_txt:addTouchLinkListener(function(type, value, sender, pos)
        self:onClickRankBtn()
    end, { "click", "href" })
    main_container:addChild(self.check_rank_txt)

    self.time_txt = main_container:getChildByName("time_txt")
    self.lev_txt = main_container:getChildByName("lev_txt")
    self.my_score_txt = main_container:getChildByName("my_score_txt")

    main_container:getChildByName("rank_title"):setString(TI18N("积分榜"))
    self.rank_object_list = {}
    for i=1,3 do
        local object = {}
        object.rank_name_txt = main_container:getChildByName("rank_name_" .. i)
        object.rank_name_txt:setString(TI18N("虚位以待"))
        object.rank_score_txt = main_container:getChildByName("rank_score_" .. i)
        object.rank_score_txt:setString(0)
        _table_insert(self.rank_object_list, object)
    end

    self.progress = main_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.progress_val = main_container:getChildByName("progress_val")

    self.item_object_list = {}
    for i=1,3 do
        local item_icon = main_container:getChildByName("item_icon_" .. i)
        if item_icon then
            local object = {}
            object.item_btn = item_icon
            object.item_num_txt = item_icon:getChildByName("num_txt")
            object.item_name_txt = item_icon:getChildByName("name_txt")
            object.item_use_txt = item_icon:getChildByName("use_txt")
            object.add_item_btn = item_icon:getChildByName("add_item_btn")
            local item_bid
            local score_val = 0
    		if i == 1 and Config.HolidayValentinesData.data_const["holiday_item1"] then
                item_bid = Config.HolidayValentinesData.data_const["holiday_item1"].val
                score_val = Config.HolidayValentinesData.data_const["holiday_score1"].val
    		elseif i == 2 and Config.HolidayValentinesData.data_const["holiday_item2"] then
                item_bid = Config.HolidayValentinesData.data_const["holiday_item2"].val
                score_val = Config.HolidayValentinesData.data_const["holiday_score2"].val
            elseif Config.HolidayValentinesData.data_const["holiday_item3"] then
                item_bid = Config.HolidayValentinesData.data_const["holiday_item3"].val
                score_val = Config.HolidayValentinesData.data_const["holiday_score3"].val
            end
            object.item_use_txt:setString("+" .. score_val)
            object.item_use_txt:setVisible(true)
    		local item_cfg = Config.ItemData.data_get_data(item_bid)
    		if item_cfg then
                object.item_bid = item_bid
                local item_res = PathTool.getItemRes(item_cfg.icon)
                item_icon:loadTexture(item_res, LOADTEXT_TYPE)
                object.item_name_txt:setString(item_cfg.name)
            end
            _table_insert(self.item_object_list, object)
        end
    end

    main_container:getChildByName("tips_txt"):setString(TI18N("长按可连续捐赠"))
end

function ActionSweetPanel:registerEvent(  )
    registerButtonEventListener(self.btn_shop, handler(self, self.onClickShopBtn), true)
    registerButtonEventListener(self.btn_task, handler(self, self.onClickTaskBtn), true)
    registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)
    registerButtonEventListener(self.btn_award, handler(self, self.onClickAwardBtn), true)

    for i,object in ipairs(self.item_object_list) do
		if object.add_item_btn then
			registerButtonEventListener(object.add_item_btn, function ()
				self:onClickAddItemBtn(i)
			end, true)
        end
        if object.item_btn then
            -- 长按连续捐赠
            object.item_btn:addTouchEventListener(function ( sender, event_type )
                --customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.began then
                    if self.clickTimer then
                        GlobalTimeTicket:getInstance():remove(self.clickTimer)
                        self.clickTimer = nil
                    end
                    self.clickTimer = GlobalTimeTicket:getInstance():add(function()
                        self:onClickPutItemBtn(i)
                    end, 0.3)
                elseif event_type == ccui.TouchEventType.ended then
                    if self.clickTimer then
                        GlobalTimeTicket:getInstance():remove(self.clickTimer)
                        self.clickTimer = nil
                    end
                    self:onClickPutItemBtn(i)
                elseif  event_type == ccui.TouchEventType.canceled then
                    if self.clickTimer then
                        GlobalTimeTicket:getInstance():remove(self.clickTimer)
                        self.clickTimer = nil
                    end
                end
            end)
        end
    end
    
    -- 甜蜜大作战数据
    if not self.get_sweet_data_event then
        self.get_sweet_data_event = GlobalEvent:getInstance():Bind(ActionEvent.Update_Sweet_Data_Event, function ()
            self:setData()
        end)
    end

    -- 捐献成功
    --[[ if not self.put_success_event then
        self.put_success_event = GlobalEvent:getInstance():Bind(ActionEvent.Sweet_Put_Success_Event, function (id)
            self:showScoreTxtAniById(id)
        end)
    end ]]

    -- 积分前三名数据
    if not self.get_rank_data_event then
        self.get_rank_data_event = GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_Rank_data, function (data)
            self:setRankData(data)
        end)
    end

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateItemNum(data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateItemNum(data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateItemNum(data_list)
        end)
    end
end

-- 规则说明
function ActionSweetPanel:onClickRuleBtn( param, sender, event_type )
    local rule_cfg = Config.HolidayValentinesData.data_const["holiday_rule"]
    if rule_cfg then
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    end
end

-- 打开排行榜
function ActionSweetPanel:onClickRankBtn( )
    local setting = {}
    setting.rank_type = RankConstant.RankType.sweet
    setting.title_name = TI18N("排行榜")
    setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
    RankController:getInstance():openSingleRankMainWindow(true, setting, RankConstant.Rank_Type.Rank)
end

-- 打开积分商店
function ActionSweetPanel:onClickShopBtn( )
    MallController:getInstance():openMallActionWindow(true, self.holiday_bid)
end

-- 跳转情人节任务
function ActionSweetPanel:onClickTaskBtn( )
    if Config.HolidayValentinesData.data_const["holiday_quester"] then
        local bid = Config.HolidayValentinesData.data_const["holiday_quester"].val
        local action_ctrl = ActionController:getInstance()
        local tab_vo = action_ctrl:getActionSubTabVo(bid)
        if tab_vo and action_ctrl.action_operate and action_ctrl.action_operate.tab_list[tab_vo.bid] then
            action_ctrl.action_operate:handleSelectedTab(action_ctrl.action_operate.tab_list[tab_vo.bid])
        else
            message(TI18N("前往的活动已结束哦"))
        end
    end
end

-- 奖励预览
function ActionSweetPanel:onClickAwardBtn( )
    _controller:openActionSweetAwardWindow(true)
end

-- 点击获取道具
function ActionSweetPanel:onClickAddItemBtn( )
    if Config.HolidayValentinesData.data_const["item_gain"] then
        local bid = Config.HolidayValentinesData.data_const["item_gain"].val
        local action_ctrl = ActionController:getInstance()
        local tab_vo = action_ctrl:getActionSubTabVo(bid)
        if tab_vo and action_ctrl.action_operate and action_ctrl.action_operate.tab_list[tab_vo.bid] then
            action_ctrl.action_operate:handleSelectedTab(action_ctrl.action_operate.tab_list[tab_vo.bid])
        else
            message(TI18N("前往的活动已结束哦"))
        end
    end
end

-- 点击捐献道具
function ActionSweetPanel:onClickPutItemBtn( index )
    local cur_time = os.clock()
    if self.last_click_time and (cur_time - self.last_click_time) < 0.3 then
        return
    end
    local object = self.item_object_list[index]
    if not object then return end

    _controller:sender28502(object.item_bid, 1)

    self.last_click_time = cur_time
end

-- 显示捐献成功获得积分的动画
--[[ function ActionSweetPanel:showScoreTxtAniById( id )
    local item_use_txt
    for k,v in pairs(self.item_object_list) do
        if v.item_bid == id then
            item_use_txt = v.item_use_txt
            break
        end
    end
    if not item_use_txt then return end

    if item_use_txt then
        item_use_txt:stopAllActions()
        item_use_txt:setVisible(true)
        item_use_txt:setPositionY(100)
        local act_1 = cc.MoveBy:create(0.3, cc.p(0, 15))
        local call_back = function (  )
            item_use_txt:setVisible(fasle)
        end
        item_use_txt:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
    end
end ]]

function ActionSweetPanel:updateItemNum( data_list )
    if data_list then
        for k,v in pairs(data_list) do
            for _,object in pairs(self.item_object_list) do
                if v.base_id and object.item_bid and v.base_id == object.item_bid and object.item_num_txt then
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(object.item_bid)
                    object.item_num_txt:setString(have_num)
                    break
                end
            end
        end
    else
        for k,object in pairs(self.item_object_list) do
            if object.item_bid and object.item_num_txt then
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(object.item_bid)
                object.item_num_txt:setString(have_num)
            end
        end
    end
end

function ActionSweetPanel:setVisibleStatus( bool )
	bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
        _controller:sender28500() -- 请求基础数据
    end
end

function ActionSweetPanel:setData(  )
    local sweet_data = _model:getSweetData()
    if not sweet_data then return end

    -- 活动时间
    local less_time = sweet_data.end_time or 0
    commonCountDownTime(self.time_txt, less_time, {time_title = TI18N("剩余时间:")})

    -- 奖励等级
    local cur_lev = sweet_data.lev or 0
    self.lev_txt:setString(cur_lev .. TI18N("级"))

    -- 当前进度
    local cur_percent = (sweet_data.score / sweet_data.max_score)*100
    self.progress:setPercent(cur_percent)
    self.progress_val:setString(sweet_data.score .. "/" .. sweet_data.max_score)

    -- 我的积分
    local my_score = sweet_data.my_score or 0
    self.my_score_txt:setString(TI18N("我的积分:") .. my_score)

    -- 宝箱特效状态
    if not tolua.isnull(self.btn_award) and self.box_effect == nil then
        self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(20, 18), cc.p(0, 0), true, PlayerAction.action_1)
        self.btn_award:addChild(self.box_effect)
    end
    if self.box_effect then
        local action_name
        if _model:getSweetAwardStatus() then -- 有奖励可领取
            action_name = PlayerAction.action_2
        else
            action_name = PlayerAction.action_1
        end
        if not self.cur_act_name or self.cur_act_name ~= action_name then
            self.cur_act_name = action_name
            self.box_effect:setToSetupPose()
            self.box_effect:setAnimation(0, action_name, true)
        end
    end
end

-- 前三名排行数据
function ActionSweetPanel:setRankData( data )
    if not data or not data.rank_list then return end

    local function getRankDataByIndex( index )
        for k,v in pairs(data.rank_list) do
            if v.idx == index then
                return v
            end
        end
    end
    
    for i=1,3 do
        local object = self.rank_object_list[i]
        local rank_data = getRankDataByIndex(i)
        if rank_data then
            object.rank_name_txt:setString(rank_data.name)
            object.rank_score_txt:setString(rank_data.val1)
        else
            object.rank_name_txt:setString(TI18N("虚位以待"))
            object.rank_score_txt:setString(0)
        end
    end
end

function ActionSweetPanel:DeleteMe( )
    if self.get_sweet_data_event then
        GlobalEvent:getInstance():UnBind(self.get_sweet_data_event)
        self.get_sweet_data_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
    if self.get_rank_data_event then
        GlobalEvent:getInstance():UnBind(self.get_rank_data_event)
        self.get_rank_data_event = nil
    end
    --[[ if self.put_success_event then
        GlobalEvent:getInstance():UnBind(self.put_success_event)
        self.put_success_event = nil
    end ]]
    if self.clickTimer then
        GlobalTimeTicket:getInstance():remove(self.clickTimer)
        self.clickTimer = nil
    end
    for k,object in pairs(self.item_object_list) do
        if object.item_use_txt then
            object.item_use_txt:stopAllActions()
        end
    end
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
end