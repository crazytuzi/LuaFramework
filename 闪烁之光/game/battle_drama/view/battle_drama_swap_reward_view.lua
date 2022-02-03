-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      剧情副本扫荡奖励副本
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattlDramaSwapRewardWindow = BattlDramaSwapRewardWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()

function BattlDramaSwapRewardWindow:__init()
    self.win_type = WinType.Mini
    self.layout_name = "battledrama/battle_drama_swap_reward_view"
    self.space = 40
    self.col = 4
    self.cache_list = {}
    self.can_close = false
    self.view_tag = ViewMgrTag.MSG_TAG
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.effect_cache_list = {}
    self.is_csb_action = true
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), type = ResourcesType.single },
    }
end

function BattlDramaSwapRewardWindow:open_callback()
    local backpanel = self.root_wnd:getChildByName("backpanel")
    backpanel:setScale(display.getMaxScale())
    self.background = backpanel:getChildByName("background")

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.back_panel = self.main_container:getChildByName("back_panel")
    self.back_panel:setScale(display.getMaxScale())
    self.image_top_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), self.back_panel:getContentSize().width / 2, self.back_panel:getContentSize().height, LOADTEXT_TYPE, self.back_panel)
    self.image_top_bg:setAnchorPoint(cc.p(0.5, 1))
    self.image_top_bg:setContentSize(cc.size(SCREEN_WIDTH + 100, 252.5))
    self.image_bottom_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), self.back_panel:getContentSize().width / 2, 0, LOADTEXT_TYPE, self.back_panel)
    self.image_bottom_bg:setContentSize(cc.size(SCREEN_WIDTH + 100, 252.5))
    self.image_bottom_bg:setScaleY(-1)
    self.image_bottom_bg:setAnchorPoint(cc.p(0.5, 1))

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:setTitleText(TI18N("确定"))
    local title = self.comfirm_btn:getTitleRenderer()
    title:enableOutline(cc.c4b(196, 90, 20, 255), 2)

    self.scroll_view = self.main_container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_view:setSwallowTouches(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height

    local titlepanel = self.root_wnd:getChildByName("titlepanel")
    titlepanel:setPositionY(self.back_panel:getContentSize().height + self.back_panel:getPositionY() + titlepanel:getContentSize().height / 2)--display.getTop(self.root_wnd)

    self.time_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(self.main_container:getContentSize().width / 2 + 5, 35), nil, nil, 1000)
    self.time_label:setString(TI18N("10秒后关闭"))
    self.main_container:addChild(self.time_label)

    self.title_container = titlepanel:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
end

function BattlDramaSwapRewardWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.can_close == true then
                controller:openDramSwapRewardView(false)
            end
        end
    end)
    if self.comfirm_btn then
        self.comfirm_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.can_close == true then
                    controller:openDramSwapRewardView(false)
                end
            end
        end)
    end
end

function BattlDramaSwapRewardWindow:openRootWnd(data)
    self:handleEffect(true)
    self.data = data
    self:updateData()
end

function BattlDramaSwapRewardWindow:updateData()
    if self.data then
       local sum = #self.data.items
        local col = 4
        -- 算出最多多少行
        self.row = math.ceil(sum / col)
        self.space = 10
        local max_height = self.space + (self.space + BackPackItem.Height) * self.row
        self.max_height = math.max(max_height, self.scroll_view:getContentSize().height)
        self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view:getContentSize().width, self.max_height))

        if sum >= col then
            sum = col
        end
        local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
        self.start_x = (self.scroll_view:getContentSize().width - total_width) * 0.5

        -- 只有一行的话
        if self.row == 1 then
            self.start_y = self.max_height * 0.5
        else
            self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5
        end
        for i, v in ipairs(self.data.items) do
            local item = BackPackItem.new(true,true)
            --item:setScale(1.3)
            item:setBaseData(v.bid, v.num)
            --item:showName(true)
            local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
            local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space)
            item:setPosition(cc.p(_x, _y))
            self.scroll_view:addChild(item)
            self.cache_list[i] = item
        end
        --self:ItemAciton()

        GlobalTimeTicket:getInstance():add(function()
            self.can_close = true
            self:updateTimer()
        end, 0.5, 1)
    end
end

function BattlDramaSwapRewardWindow:ItemAciton()
    if self.cache_list then
        local show_num = 0
        for i, v in pairs(self.cache_list) do
            if v then
                delayRun(self.root_wnd, 0.1 * (i - 1), function()
                    v:setVisible(true)
                    v:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(function()
                        show_num = show_num + 1
                        if show_num >= tableLen(self.cache_list) then
                            --self:updateTimer()
                        end
                    end)))
                end)
            end
        end
    end
end

function BattlDramaSwapRewardWindow:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        local str = new_time .. TI18N("秒后关闭")
        if self.time_label and not tolua.isnull(self.time_label) then
            self.time_label:setString(str)
        end
        if new_time <= 0 then
            controller:openDramSwapRewardView(false) 
            GlobalTimeTicket:getInstance():remove("close_swap_reward")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back, 1, 0, "close_swap_reward")
end

function BattlDramaSwapRewardWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_3)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function BattlDramaSwapRewardWindow:close_callback()
    self.render_list = {}
    for i, v in ipairs(self.cache_list) do
        if v and v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.cache_list = {}
    self:handleEffect(false)
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    controller:openDramSwapRewardView(false)
end
