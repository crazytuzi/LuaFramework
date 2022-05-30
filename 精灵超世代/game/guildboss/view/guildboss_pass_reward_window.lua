-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      首通奖励面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossPassRewardWindow = GuildBossPassRewardWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()

function GuildBossPassRewardWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.title_str = TI18N("首通奖励")
	self.is_full_screen = false
end

function GuildBossPassRewardWindow:open_callback()
    local size = cc.size(608, 775)
    self.main_view = createImage(self.container, PathTool.getResFrame("common", "common_1034"), 18, 15, cc.p(0, 0), true, 1, true)
    self.main_view:setContentSize(size)
end

function GuildBossPassRewardWindow:register_event()
    if self.update_first_pass_event == nil then
        self.update_first_pass_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateFirstPassReward, function()
        local listReward = model:getFirstPassRewardList()
            if self.scroll_view then
                self.scroll_view:setData(listReward)
            end
        end)
    end
end

function GuildBossPassRewardWindow:openRootWnd()
    if self.scroll_view == nil then         -- 保证只做一次创建，其他状态通过事件处理
        local list_size = self.main_view:getContentSize()
        local list_setting = {
            item_class = GuildBossPassRewardItem,
            start_x = 4,
            space_x = 4,
            start_y = 4,
            space_y = - 3,
            item_width = 600,
            item_height = 135,
            row = 0,
            col = 1,
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewLayout.new(self.main_view, nil, nil, nil, list_size, list_setting)
        local listReward = model:getFirstPassRewardList()
        if self.scroll_view then
            self.scroll_view:setData(listReward)
        end
    end
end


function GuildBossPassRewardWindow:close_callback()
    if self.update_first_pass_event then
        GlobalEvent:getInstance():UnBind(self.update_first_pass_event)
        self.update_first_pass_event = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    controller:openGuildBossPassRewardWindow(false)
end
-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      章节首通奖励单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossPassRewardItem = class("GuildBossPassRewardItem", function()
	return ccui.Layout:create()
end)
function GuildBossPassRewardItem:ctor()
    self.item_list = {}

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_pass_reward_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.chatpter_value = container:getChildByName("chatpter_value")
    self.chatpter_desc = container:getChildByName("chatpter_desc")

    self.btn_container = container:getChildByName("btn_container")
    self._redPoint = self.btn_container:getChildByName("redPoint")
    self.reward_btn = self.btn_container:getChildByName("reward_btn")
    self.reward_btn_label = self.reward_btn:getChildByName("label") 
    self.reward_btn_label:setString(TI18N("领取"))

    self.pass_reward = container:getChildByName("pass_reward")
    self.container = container
    self:registerEvent()
end

function GuildBossPassRewardItem:registerEvent()
    self.reward_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:send21321(self.data.fid)
        end
    end) 
end

function GuildBossPassRewardItem:setData(data)
    if not data then return end
    self.data = data
    self:firstReward()
end

local firstPassReward = Config.GuildDunData.data_chapter_reward
function GuildBossPassRewardItem:firstReward()
    local scale = 0.8
    local num = #firstPassReward[self.data.fid].reward_list
    if num >= 3 then num = 3 end
    for i=1, num do
        if not self.item_list[i] then
            local item = BackPackItem.new(false, true, false, scale, false)
            item:setAnchorPoint(0, 0.5)
            item:setSwallowTouches(false)
            self.container:addChild(item)
            self.item_list[i] = item
        end
        item = self.item_list[i]
        if item then
            item:setPosition(140+(i - 1)*(BackPackItem.Width*scale+5), 67)
            item:setBaseData(firstPassReward[self.data.fid].reward_list[i][1], firstPassReward[self.data.fid].reward_list[i][2])
            item:setDefaultTip()
        end
    end

    if self.data.status == 0 then
        self.reward_btn_label:setString(TI18N("未达成"))
        setChildUnEnabled(true, self.reward_btn)
        self.reward_btn:setVisible(true)
        self.reward_btn:setTouchEnabled(false)
        self._redPoint:setVisible(false)
        self.pass_reward:setVisible(false)

        self.reward_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    elseif self.data.status == 1 then
        self.reward_btn_label:setString(TI18N("领取"))
        -- self.reward_btn_label:enableOutline(cc.c3b(71,132,37), 2)

        setChildUnEnabled(false, self.reward_btn)
        self.reward_btn:setVisible(true)
        self.reward_btn:setTouchEnabled(true)
        self._redPoint:setVisible(true)
        self.pass_reward:setVisible(false)
    elseif self.data.status == 2 then
        self.reward_btn:setVisible(false)
        self._redPoint:setVisible(false)
        self.pass_reward:setVisible(true)
    end
    self.chatpter_value:setString(firstPassReward[self.data.fid].chapter_name)
    self.chatpter_desc:setString(firstPassReward[self.data.fid].chapter_desc)
end

function GuildBossPassRewardItem:DeleteMe()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
	self:removeAllChildren()
end 