-- --------------------------------------------------------------------
-- 
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      阵容试炼主场景
-- <br/>Create: 2020-3-11
-- --------------------------------------------------------------------

EndlessTrailCampPanel = class("EndlessTrailCampPanel", function()
    return ccui.Widget:create()
end)
local ctrl = Endless_trailController:getInstance()
local model = ctrl:getModel()
local string_format = string.format

function EndlessTrailCampPanel:ctor()
    -- 今日已挑战或者今日没挑战的状态
    self.ack_status = 0
    self.rank_list = {}
    self.is_first_open = true  -- 首次打开界面标识
    self.is_first_send_23903 = true -- 是否首次请求23903
    self:configUI()
	self:register_event()
end


function EndlessTrailCampPanel:addToParent( status )
	status = status or false
    self:setVisible(status)
    if self.is_first_open == true then
        self.is_first_open = false
        self:setRankShow()
        self:updateBaseInfo()
    end

    if self.is_first_send_23903 == true then
        local data = model:getEndlessData()
        if data and data.select_type then
            self.is_first_send_23903 = false
            ctrl:send23903(data.select_type)
        end
    end

    if status == true then
        self:updateFirendRedPoint()
        self:updateGetBtnRedPoint()
        self:updateAckBtnRedPoint()
    end
end

function EndlessTrailCampPanel:configUI(...)
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_camp_panel"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)


	self.mainContainer = self.root_wnd:getChildByName("main_container")
    self.top_panel = self.mainContainer:getChildByName("top_panel")
    self.bottom_panel = self.mainContainer:getChildByName("bottom_panel")
    self.friend_btn = self.bottom_panel:getChildByName("friend_btn")
    self.firend_red_point = self.friend_btn:getChildByName("red_point")
    self.firend_red_point:setVisible(false)
    local label = self.friend_btn:getChildByName("label")
    label:setString(TI18N("好友助阵"))

    self.ack_btn = self.bottom_panel:getChildByName("ack_btn")
    self.ack_btn_label = self.ack_btn:getChildByName("label")
    self.ack_btn_label:setString(TI18N("开始挑战"))
    self.ack_btn_red_point = self.ack_btn:getChildByName("red_point") 

    self.tips_button = self.top_panel:getChildByName("tips_button")
    self.notice_btn = self.top_panel:getChildByName("notice_btn")
    
    self.rank_container = self.top_panel:getChildByName("rank_container")
    local rank_desc_label  = self.rank_container:getChildByName("rank_desc_label")
    rank_desc_label:setString(TI18N("排行榜"))
    --self.rank_info_btn = self.rank_container:getChildByName("rank_info_btn")

    self.rank_info_btn = createRichLabel(16, Config.ColorData.data_new_color4[17], cc.p(0.5, 0), cc.p(self.rank_container:getContentSize().width*0.5, 10),10,nil,130)
    self.rank_container:addChild(self.rank_info_btn)
    self.rank_info_btn:setString(TI18N("<div  href=detial>点击查看详情</div>"))
    self.rank_info_btn:addTouchLinkListener(function(type, value, sender, pos)
        ctrl:openEndlessRankView(true,Endless_trailEvent.type.rank,Endless_trailEvent.endless_type.light_dark)
    end, { "click", "href" })

    self.first_container = self.bottom_panel:getChildByName("first_container")
    self.get_btn = self.first_container:getChildByName("get_btn")
    self.get_btn:setVisible(false)
    local label = self.get_btn:getChildByName("label")
    label:setString(TI18N("领取"))
    label:enableOutline(Config.ColorData.data_color4[264],2)
    self.first_label = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(5, self.first_container:getContentSize().height -4),nil,nil,300)
    self.first_container:addChild(self.first_label)
    self.limit_label = createRichLabel(20, Config.ColorData.data_new_color4[11], cc.p(0, 0.5), cc.p(120, 56),nil,nil,180)
    self.limit_label:setVisible(false)
    self.first_container:addChild(self.limit_label)

    self.info_touch = self.first_container:getChildByName("info_touch")
    self.info_lab = createRichLabel(18, Config.ColorData.data_new_color4[12], cc.p(0.5, 0.5), cc.p(self.info_touch:getContentSize().width*0.5, self.info_touch:getContentSize().height*0.5),10,nil,130)

    self.info_touch:addChild(self.info_lab)
    self.info_lab:setString(TI18N("<div  href=detial>奖励详情</div>"))


    self.rank_reward_container = self.bottom_panel:getChildByName("rank_reward_container")
    self.rank_reward_container:getChildByName("my_title"):setString(TI18N("我的排名:"))
    self.my_rank_value = self.rank_reward_container:getChildByName("my_rank")
    self.rank_notice = self.rank_reward_container:getChildByName("rank_notice")
    self.rank_notice:setString(TI18N("暂无排行奖励"))


    self.my_round_container = self.bottom_panel:getChildByName("my_round_container")
    local text  = self.my_round_container:getChildByName("text")
    text:setString(TI18N("个人记录"))
    self.floor_round  = self.my_round_container:getChildByName("round_desc_label")
    --round_desc_label:setString(TI18N("个人记录"))

    --self.floor_round = CommonNum.new(23,nil, 0, 1, cc.p(0.5, 0))
    --self.my_round_container:addChild(self.floor_round)
    --self.floor_round:setPosition(150,34.5)
    --self.floor_round:setScale(0.9)

    self.friend_container = self.bottom_panel:getChildByName("friend_container")
    self.friend_container:getChildByName("label_1"):setString(TI18N("已选择:"))
    self.friend_power = self.friend_container:getChildByName("power")
    self.friend_head = PlayerHead.new(PlayerHead.type.circle)
    self.friend_head:setScale(0.4)
    self.friend_head:setPosition(100, 24)
    self.friend_container:addChild(self.friend_head)

    
    --一些文本
    self.friend_label = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5,0.5), cc.p(574,-21),nil,nil,250)
    self.bottom_panel:addChild(self.friend_label)

    self.from_label = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(180,100))
    self.bottom_panel:addChild(self.from_label)

    self.has_label = createRichLabel(22, Config.ColorData.data_new_color4[1], cc.p(0.5, 0.5), cc.p(358,-10))
    self.bottom_panel:addChild(self.has_label)

    self.can_reward_label = self.bottom_panel:getChildByName("can_reward_label")
    self.can_reward_label:setString(TI18N("（已获所有日常结算奖励）"))

    self.time_title = self.bottom_panel:getChildByName("time_title")
    self.time_title:setString(TI18N("剩余时间："))

    self.time_lab = self.bottom_panel:getChildByName("time_lab")

    local top_off = display.getTop(main_container)
	--self.top_panel:setPositionY(top_off - 237)
	local bottom_off = display.getBottom(main_container)
	--self.bottom_panel:setPositionY(bottom_off + 180)
end

function EndlessTrailCampPanel:register_event( ... )
    registerButtonEventListener(self.get_btn, function()
        if self.first_data and self.base_data then
            ctrl:send23904(self.first_data.id,self.base_data.select_type)
        end
    end,true, 1)

    registerButtonEventListener(self.info_touch, function()
        if self.base_data then
            ctrl:openEndlessRewardWindow(true,self.base_data.select_type)
        end

    end,true, 1)

    --registerButtonEventListener(self.rank_info_btn, function()
    --    if self.base_data then
    --        ctrl:openEndlessRankView(true,Endless_trailEvent.type.rank,self.base_data.select_type)
    --    end
    --end,true, 1)

    registerButtonEventListener(self.tips_button, function()
        if  Config.EndlessData.data_explain and Config.EndlessData.data_explain[2] then
            MainuiController:getInstance():openCommonExplainView(true,  Config.EndlessData.data_explain[2], TI18N("玩法规则"))
        end
    end,true, 1)

    registerButtonEventListener(self.notice_btn, function()
        ctrl:openEndlessOpenTips(true) 
    end,true, 1)

    registerButtonEventListener(self.ack_btn, function()
        if self.base_data and self.base_data.type ~= 0 and self.base_data.type ~= self.base_data.select_type then
            message(TI18N("当日无法挑战"))
            return
        end

        local rolevo = RoleController:getInstance():getRoleVo()
        local open_config = Config.EndlessData.data_const.endless_new_limit
        local open_lev = Config.EndlessData.data_const.endless_new_limit_lev
        if self.base_data and rolevo and open_config and open_lev then
            if self.base_data.max_round < open_config.val and rolevo.lev < open_lev.val then
                message(string_format(TI18N("无尽试炼通关%d关且等级达到%d级后开启挑战"),open_config.val,open_lev.val))
                return
            elseif self.base_data.max_round < open_config.val then
                message(string_format(TI18N("无尽试炼通关%d关后开启挑战"),open_config.val))
                return
            elseif rolevo.lev < open_lev.val then
                message(string_format(TI18N("等级达到%d级后开启挑战"),open_lev.val))
                return
            end
        end


        local has_hire_list = model:getHasHirePartnerData() or {}
        local list = has_hire_list.list or {}
        local fun_form = PartnerConst.Fun_Form.EndLessWater
        if self.base_data then
            if self.base_data.select_type == Endless_trailEvent.endless_type.water then
                fun_form = PartnerConst.Fun_Form.EndLessWater
            elseif self.base_data.select_type == Endless_trailEvent.endless_type.fire then
                fun_form = PartnerConst.Fun_Form.EndLessFire
            elseif self.base_data.select_type == Endless_trailEvent.endless_type.wind then
                fun_form = PartnerConst.Fun_Form.EndLessWind
            elseif self.base_data.select_type == Endless_trailEvent.endless_type.light_dark then
                fun_form = PartnerConst.Fun_Form.EndLessLightDark
            end
        end
        
        if self.ack_status == 2 then
            CommonAlert.show(TI18N("本日已不可获得通关累计奖励，但依然可以继续挑战<div fontcolor=#289b14>首通奖励</div>和<div fontcolor=#289b14>排行榜排名</div>，是否确认继续挑战？"), TI18N("确定"), function() 
                HeroController:getInstance():openFormGoFightPanel(true, fun_form, {has_hire_list = list})
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            HeroController:getInstance():openFormGoFightPanel(true, fun_form, {has_hire_list = list})
        end
    end,true, 1)

    registerButtonEventListener(self.friend_btn, function()
        ctrl:openEndlessFriendHelpView(true)
    end,true, 1)

    if not self.update_base_event then
        self.update_base_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_BASE_DATA,function()
            if self.is_first_send_23903 == true then
                local data = model:getEndlessData()
                if data and data.select_type then
                    self.is_first_send_23903 = false
                    ctrl:send23903(data.select_type)
                end
            end
            self:updateBaseInfo()
        end)
    end
    if not self.update_first_event then
        self.update_first_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_FIRST_DATA,function()
            self:updateFirstItem()
        end)
    end
    if not self.send_partner_red_point_event then
        self.send_partner_red_point_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_REDPOINT_SENDPARTNER_DATA,function()
            self:updateFirendRedPoint()
        end)
    end
    if not self.update_red_first_event then
        self.update_red_first_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_REDPOINT_FIRST_DATA,function()
            self:updateGetBtnRedPoint()
        end)
    end
    if not self.update_red_reward_event then
        self.update_red_reward_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_REDPOINT_REWARD_DATA,function()
            self:updateAckBtnRedPoint()
        end)
    end

    if not self.update_rank_event then
        self.update_rank_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_RANK_DATA,function()
            self:updateRankData()
            -- 自己当前排名奖励
            self:updateRankItem()
        end)
    end
    
end

--更新挑战按钮红点
function EndlessTrailCampPanel:updateAckBtnRedPoint()
    if self.ack_btn_red_point then
        local status = model:getIsGetAllRewardNew()
        if status == nil or ctrl:checkNewEndLessIsOpen() == false then
            status = false
        end
        self.ack_btn_red_point:setVisible(status)
    end
end

--更新领取按钮红点
function EndlessTrailCampPanel:updateGetBtnRedPoint()
    if self.get_btn and self.base_data then
        local status = model:getFirstGet(self.base_data.select_type)
        if status == nil then
            status = false
        end
        addRedPointToNodeByStatus( self.get_btn, status, 5, 5)
    end
end

--更新好友红点
function EndlessTrailCampPanel:updateFirendRedPoint()
    if self.firend_red_point and not tolua.isnull(self.firend_red_point) then
        local bool = model:getIsSendPartner()
        if bool == nil or ctrl:checkNewEndLessIsOpen() == false then
            bool = false
        end
        self.firend_red_point:setVisible(bool)
    end
end

function EndlessTrailCampPanel:setRankShow()
    if RankController:getInstance():checkRankIsShow() then
        self.rank_container:setVisible(true)
    else
        self.rank_container:setVisible(false)
    end
end

function EndlessTrailCampPanel:updateBaseInfo()
    local data = model:getEndlessData()
    self.base_data = data
    if self.base_data then
        --self.floor_round:setNum(data.new_max_round)
        self.floor_round:setString(data.new_max_round)

        self.from_label:setString(string.format(TI18N("从%s关开始"),data.new_current_round))

        self.has_label:setString(string.format(TI18N("今天已通关%s关"),data.new_day_pass_round))
        if data.new_day_pass_round == 0 then
            self.ack_btn_label:setString(TI18N("开始挑战"))
        else
            self.ack_btn_label:setString(TI18N("重新开始"))
        end

        if data.new_day_pass_round  ~= 0 and data.is_reward == TRUE then
            self.ack_status = 2
        else
            self.ack_status = 1
        end

        if data.is_employ == FALSE and next(data.list or {}) == nil then --没雇佣伙伴
            self.friend_label:setString(TI18N("选择一位好友的宝可梦帮助"))
            self.friend_container:setVisible(false)
            self.friend_label:setVisible(true)
        else
            if data.list and data.list[1] then
                local partner_data = data.list[1]
                self.friend_label:setVisible(false)
                self.friend_container:setVisible(true)
                self.friend_head:setHeadRes(partner_data.bid)
                self.friend_power:setString(partner_data.power)
            end
        end
        -- 达到上限
        if data.is_reward == TRUE and self.base_data.type ~= Endless_trailEvent.endless_type.old then
            self.can_reward_label:setVisible(true)
        else
            self.can_reward_label:setVisible(false)
        end

        self:updateRankData()
        -- 自己当前排名奖励
        self:updateRankItem()
        self:updateFirstItem()
        
        if ctrl:checkNewEndLessIsOpen() == true then
            self.time_lab:setVisible(true)
            self.time_title:setVisible(true)
            commonCountDownTime(self.time_lab, self.base_data.next_time, {callback = function(time) self:setTimeFormatString(time) end})    
        else
            self.time_lab:setVisible(false)
            self.time_title:setVisible(false)
        end
        

        if (self.base_data.type ~= 0 and self.base_data.type ~= self.base_data.select_type) or ctrl:checkNewEndLessIsOpen() == false then
            setChildUnEnabled(true,self.ack_btn)
            self.ack_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
        else
            setChildUnEnabled(false,self.ack_btn)
            self.ack_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
        end
    end
end

function EndlessTrailCampPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_lab:setString(TimeTool.GetTimeFormatDayII(time))
    else
        self.time_lab:setString("")
    end
end
--[[
    @desc: 更新首通奖励
    author:{author}
    time:2018-08-16 10:17:14
    --@args: 
    @return:
]]
function EndlessTrailCampPanel:updateFirstItem()
    local data = nil
    if self.base_data then
        data = model:getFirstData(self.base_data.select_type)
    end
    
    if data and self.base_data and Config.EndlessData.data_first_data and Config.EndlessData.data_first_data[self.base_data.select_type] then
        self.first_data = data
        local first_data = Config.EndlessData.data_first_data[self.base_data.select_type][self.first_data.id]
        if self.first_data.id == 0 then
            local str = TI18N("【已领完所有首通奖励！ヾ(*・ω・)ノ゜】")
            self.limit_label:setString(str)
            self.limit_label:setVisible(true) 
            if self.item_scrollview then
                self.item_scrollview:setVisible(false)
            end
            self.get_btn:setVisible(false)
        else
            if first_data then
                if not self.item_scrollview then
                    local setting = {
                        item_class = BackPackItem,      -- 单元类
                        start_x = 0,                  -- 第一个单元的X起点
                        space_x = 10,                    -- x方向的间隔
                        start_y = 0,                    -- 第一个单元的Y起点
                        space_y = 0,                   -- y方向的间隔
                        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
                        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
                        row = 1,                        -- 行数，作用于水平滚动类型
                        col = 0,                         -- 列数，作用于垂直滚动类型
                        scale = 0.7
                    }
                    self.item_scrollview = CommonScrollViewLayout.new(self.first_container, cc.p(10,5) , ScrollViewDir.horizontal, ScrollViewStartPos.bottom, cc.size(110,85), setting)
                end
                local str = string.format(TI18N("首通奖励(第%s关)"),first_data.limit_id)
                self.first_label:setString(str)

                if self.first_data.status == 1 then
                    self.get_btn:setVisible(true)
                    self.limit_label:setVisible(false)
                else
                    str = string.format(TI18N("%s关后可领"), first_data.limit_id - self.base_data.new_max_round)
                    self.limit_label:setString(str)
                    self.limit_label:setVisible(true)
                    self.get_btn:setVisible(false)
                end
                local temp_list = {}
                for k, v in ipairs(first_data.items) do
                    local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
                    if vo then
                        vo.quantity = v[2]
                        table.insert(temp_list, vo)    
                    end
                end
                self.item_scrollview:setData(temp_list,nil,nil,{is_show_tips = true})
                self.item_scrollview:setVisible(true)
            end
        end
    end
end

--- 排名奖励
function EndlessTrailCampPanel:updateRankItem()
    if self.base_data == nil then return end
    if self.base_data.new_my_idx == nil then return end
    local config = nil

    if Config.EndlessData.data_rank_reward_data and Config.EndlessData.data_rank_reward_data[self.base_data.select_type] then
        for i,v in ipairs(Config.EndlessData.data_rank_reward_data[self.base_data.select_type]) do
            if self.base_data.new_my_idx >= v.min and self.base_data.new_my_idx <= v.max then
                config = v
                break
            end
        end
    end
    
    if config == nil then   -- 未上榜
        self.rank_notice:setVisible(true)
        if self.rank_item_scrollview then
            self.rank_item_scrollview:setVisible(false)
        end
        self.my_rank_value:setString(TI18N("无"))
    else
        self.rank_notice:setVisible(false)
        self.my_rank_value:setString(self.base_data.new_my_idx)
        local temp_list = {}
        for k, v in ipairs(config.items) do
            local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
            if vo then
                vo.quantity = v[2]
                table.insert(temp_list, vo)    
            end
        end

        if not self.rank_item_scrollview then
            local setting = {
                item_class = BackPackItem,
                start_x = 0,
                space_x = 10,
                start_y = 0,
                space_y = 0,
                item_width = BackPackItem.Width*0.7,
                item_height = BackPackItem.Height*0.7,
                row = 1,
                col = 0,
                scale = 0.7
            }
            self.rank_item_scrollview = CommonScrollViewLayout.new(self.rank_reward_container, cc.p(40,20) , ScrollViewDir.horizontal, ScrollViewStartPos.bottom, cc.size(195,85), setting)
        end

        self.rank_item_scrollview:setData(temp_list,nil,nil,{is_show_tips = true})
        self.rank_item_scrollview:setVisible(true)
    end
end

--[[
    @desc: 更新排行榜
    author:{author}
    time:2018-08-16 10:38:15
    --@args: 
    @return:
]]
function EndlessTrailCampPanel:updateRankData( ... )
    local rank_list = {}
    if self.base_data then
        rank_list = model:getRaknRoleTopThreeList(self.base_data.select_type)
    end
    
    if rank_list and next(rank_list or {}) ~= nil then
        for i, v in ipairs(rank_list) do
            if not self.rank_list[i] then
                local item = self:createSingleRankItem(i, v)
                self.rank_container:addChild(item)
                self.rank_list[i] = item
            end
            local item = self.rank_list[i]
            if item then
                item:setPosition(10, 188 - (i - 1) * item:getContentSize().height)
                item.label:setString(v.name)
                item.value:setString((v.val or 0)..TI18N("关"))
            end
        end
    end
end


--排行榜单项
function EndlessTrailCampPanel:createSingleRankItem(i, data)
    local container = ccui.Layout:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setContentSize(cc.size(180, 50))
    local sp = createSprite(PathTool.getResFrame("common", "common_rank_" .. i), 20, 40 / 2, container)
    sp:setScale(0.7)
    container.sp = sp
    local label = createLabel(16, Config.ColorData.data_new_color4[15], nil, 30, 25, "", container)
    label:setAnchorPoint(cc.p(0, 0.5))
    local value = createLabel(16, Config.ColorData.data_new_color4[15], nil, 30, 4, "", container)
    value:setAnchorPoint(cc.p(0, 0.5))
    container.label = label
    container.value = value
    return container
end



function EndlessTrailCampPanel:DeleteMe(...)
    doStopAllActions(self.time_lab)

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
   
    if self.rank_item_scrollview then
        self.rank_item_scrollview:DeleteMe()
        self.rank_item_scrollview = nil
    end
    if self.update_first_event then
        GlobalEvent:getInstance():UnBind(self.update_first_event)
        self.update_first_event = nil
    end
    if self.update_base_event then
        GlobalEvent:getInstance():UnBind(self.update_base_event)
        self.update_base_event = nil
    end
    if self.send_partner_red_point_event then
        GlobalEvent:getInstance():UnBind(self.send_partner_red_point_event)
        self.send_partner_red_point_event = nil
    end
    if self.update_red_first_event then
        GlobalEvent:getInstance():UnBind(self.update_red_first_event)
        self.update_red_first_event = nil
    end
    if self.update_red_reward_event then
        GlobalEvent:getInstance():UnBind(self.update_red_reward_event)
        self.update_red_reward_event = nil
    end
    if self.update_rank_event then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
    
end

