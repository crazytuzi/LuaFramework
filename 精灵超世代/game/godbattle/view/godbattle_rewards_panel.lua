-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      众神战场奖励的标签面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GodBattleRewardsPanel = GodBattleRewardsPanel or BaseClass()

function GodBattleRewardsPanel:__init(parent)
    self.is_init = false 
    self.parent = parent
    self:createRoorWnd()
	self:registerEvent()
end

function GodBattleRewardsPanel:createRoorWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("godbattle/godbattle_rewards_panel"))

    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end
    self.root_wnd:getChildByName("kill_num_label"):setString(TI18N("今日击败玩家:"))
    self.root_wnd:getChildByName("challenge_num_label"):setString(TI18N("今日挑战次数:"))
    self.list_view = self.root_wnd:getChildByName("list_view")
    self.kill_num = self.root_wnd:getChildByName("kill_num")
    self.challenge_num = self.root_wnd:getChildByName("challenge_num")
    self.item = self.root_wnd:getChildByName("item")

    local size = self.list_view:getContentSize()
    local setting = {
        item_class = GodBattleRewardsItem,
        start_x = 3,
        space_x = 0,
        start_y = 3,
        space_y = 0,
        item_width = 616,
        item_height = 134,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)
end

function GodBattleRewardsPanel:registerEvent()
    -- 更新守卫信息
    if self.update_reward_event == nil then
        self.update_reward_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateCombatAwards, function(type, num)
            if self.list == nil then return end
            for i, v in pairs(self.list) do
                if v.type == type and v.num == num then
                    v.status = 3
                end
            end
            local sort_func = SortTools.tableLowerSorter({"status", "num"})
            self.scroll_view:resetAddPosition(self.list, sort_func)
        end)
    end
end

function GodBattleRewardsPanel:addToParent(status)
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
    local model = GodbattleController:getInstance():getModel()
    local self_info = model:getSelfInfo()
    local reward_info = model:getRewardInfo()
    if status == true and self_info and reward_info then
        self.kill_num:setString(self_info.win)
        self.challenge_num:setString(self_info.cnum)
        local list = {}
        for i, v in pairs(Config.ZsWarData.data_num_rewards[self_info.group]) do 
            local data = deepCopy(v)
            data.status = 2
            if data.type == 1 then
                if reward_info.win_list[data.num] then
                    data.status = 3
                elseif data.num <= self_info.win then
                    data.status = 1
                end
            else
                if reward_info.cnum_list[data.num] then
                    data.status = 3
                elseif data.num <= self_info.cnum then
                    data.status = 1
                end
            end
            table.insert(list, data)
        end
        local sort_func = SortTools.tableLowerSorter({"status", "num"})
        table.sort(list, sort_func)
        self.scroll_view:setData(list, nil, nil, self.item)
        self.list = list
    end
end

function GodBattleRewardsPanel:__delete()
    if self.update_reward_event then
        GlobalEvent:getInstance():UnBind(self.update_reward_event)
        self.update_reward_event = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛每日活跃度单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GodBattleRewardsItem = class("GodBattleRewardsItem", function()
	return ccui.Layout:create()
end)

function GodBattleRewardsItem:ctor()
end

function GodBattleRewardsItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

        self.finish_img = self.root_wnd:getChildByName("finish_img")
        self.get_btn = self.root_wnd:getChildByName("get_btn")
        self.get_btn_label = self.get_btn:getChildByName("label")
        self.get_btn_label:setString(TI18N("未达成"))
        self.get_btn:setTouchEnabled(false)

        self.item = BackPackItem.new(false, true, false, 0.9, false, true) 
        self.item:setPosition(64, 68)
        self.root_wnd:addChild(self.item)

        self.desc = createRichLabel(24,175,cc.p(0,0.5),cc.p(124,64))
        self.root_wnd:addChild(self.desc)
        self.desc:setString(TI18N("今日挑战3次"))
		
		self:registerEvent()
	end
end

function GodBattleRewardsItem:registerEvent()
	self.get_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
                GodbattleController:getInstance():requestGetCombatReward(self.data.type, self.data.num)
			end
		end
	end)
end

function GodBattleRewardsItem:setData(data)
	self.data = data
	if data then
        self.item:setBaseData(data.items[1][1], data.items[1][2])
        if data.status == 3 then
            self.get_btn_label:setString(TI18N("已领取"))
            self.get_btn:setTouchEnabled(false)
            self.get_btn_label:disableEffect()
            setChildUnEnabled(true, self.get_btn)
        elseif data.status == 1 then
            self.get_btn:setTouchEnabled(true)
            setChildUnEnabled(false, self.get_btn)
            self.get_btn_label:setString(TI18N("领取"))
        else
            self.get_btn_label:setString(TI18N("未达成"))
            self.get_btn_label:disableEffect()
            self.get_btn:setTouchEnabled(false)
            setChildUnEnabled(true, self.get_btn)
        end
        if data.type == 1 then
            self.desc:setString(string.format(TI18N("今日胜利%s次"), data.num))
        else
            self.desc:setString(string.format(TI18N("今日挑战%s次"), data.num))
        end
	end
end

function GodBattleRewardsItem:suspendAllActions()
end

function GodBattleRewardsItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 
