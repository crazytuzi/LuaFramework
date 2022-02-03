-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会战奖励界面
-- <br/>Create: 2019年9月23日 
GuildwarAwardWindow = GuildwarAwardWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function GuildwarAwardWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildmarketplacereward", "guildmarketplacereward"), type = ResourcesType.plist},
    }
    self.layout_name = "guildwar/guildwar_award_list_panel"
end

function GuildwarAwardWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.tips = self.main_panel:getChildByName("tips")

    self.gold_container = self.main_panel:getChildByName("gold_container")
    local gold_label = self.gold_container:getChildByName("gold_label")
    gold_label:setString(TI18N("固定掉落奖励"))
    self.gold_container:getChildByName("gold_content"):setString(TI18N("(取得胜利后，以下奖励必定会加入公会宝库)"))

    self.gold_container_1 = self.main_panel:getChildByName("gold_container_1")
    local gold_label_1= self.gold_container_1:getChildByName("gold_label_1")
    gold_label_1:setString(TI18N("随机掉落奖励"))
    self.gold_container_1:getChildByName("gold_content_1"):setString(TI18N("(取得胜利后，以下奖励可能会加入公会宝库)"))

    self.rank_container = self.main_panel:getChildByName("rank_container")
    local rank_label= self.rank_container:getChildByName("rank_label")
    rank_label:setString(TI18N("排名奖励"))

    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("玩法奖励"))
end

function GuildwarAwardWindow:register_event(  )
        registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
        registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), true, 2)
        
        if self.tips then  --规则说明
            self.tips:addTouchEventListener(function ( sender,event_type )
                if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                    if Config.GuildWarData.data_const.marketplace_rule then
                        local str = Config.GuildWarData.data_const.marketplace_rule.desc
                        TipsManager:getInstance():showCommonTips(str, sender:getTouchBeganPosition())
                    end
                end
            end)
        end
end

function GuildwarAwardWindow:openRootWnd()
    local power = model:getAvgPower()
    local config_list = Config.GuildWarData.data_marketplace_reward
    if not config_list then return end
    local cur_config 
    for i,v in ipairs(config_list) do 
        if power >= v. power_low and power < v.power_high then
            cur_config = v
            break
        end
    end
    if cur_config == nil then
        cur_config = config_list[#config_list]
    end

    local rand_reward = cur_config.rand_reward
    local reward = cur_config.reward

    self:setReward_regular(reward) --设置固定奖励 
    self:setReward_random(rand_reward)  -- 设置随机奖励
    self:showRankInfo()
end

--设置固定奖励 
function GuildwarAwardWindow:setReward_regular(list)
    self.gold_scroll_size = self.gold_container:getContentSize()
    local setting = {}
    setting.scale = 0.9
    setting.space_x = 15
    setting.is_center = false
    setting.max_count = 5
    local data_list1 = {}
    if list then
        for k, v in pairs(list) do
            table_insert(data_list1, {v[1], v[2]})
        end
    end
    self.gold_scrollview  = createScrollView(self.gold_scroll_size.width, self.gold_scroll_size.height, 0, 0, self.gold_container, ScrollViewDir.horizontal) 
    self.scroll_list = commonShowSingleRowItemList(self.gold_scrollview, self.scroll_list, data_list1, setting)
end

--设置随机奖励
function GuildwarAwardWindow:setReward_random(data_list)
    self.gold_scroll_size_1 = self.gold_container_1:getContentSize()
    local setting = {}
    setting.scale = 0.9
    setting.space_x = 15
    setting.is_center = false
    setting.max_count = 5
    local data_list1 = {}
    if data_list then
        for k, v in pairs(data_list) do
            table_insert(data_list1, {v[1], v[2]})
        end
    end
    self.gold_scrollview_1  = createScrollView(self.gold_scroll_size_1.width, self.gold_scroll_size_1.height, 0, 0, self.gold_container_1, ScrollViewDir.horizontal) 
    self.scroll_list_1 = commonShowSingleRowItemList(self.gold_scrollview_1, self.scroll_list_1, data_list1, setting)

end

function GuildwarAwardWindow:showRankInfo(  )
    local award_data = self:getGuildWarAwardData()
    for i,data in ipairs(award_data) do
        local pre_num = 1
        if award_data[i-1] then
            pre_num = award_data[i-1].num+1
        end
        data.min = pre_num
        data.max = data.num
        data.reward = data.award
        data.index = i
    end

    self.rank_scrollview_size = self.rank_container:getContentSize()
    if not self.rank_scrollview then
        local setting = {
            item_class = GuildsecretareaRankRewardItem,
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 4,
            item_width = 600,
            item_height = 110,
            row = 0,
            col = 1,
            scale = 1
        }
        self.rank_scrollview = CommonScrollViewLayout.new(self.rank_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.rank_scrollview_size, setting)
        
        self.rank_scrollview:setData(award_data)
    end
end

function GuildwarAwardWindow:getGuildWarAwardData(  )
    local award_data = {}
    for k,v in pairs(Config.GuildWarData.data_award) do
        local temp_data = DeepCopy(v)
        table.insert(award_data, temp_data)
    end

    local function sortFunc( objA, objB )
        return objA.num < objB.num
    end
    table.sort(award_data, sortFunc)
    return award_data
end


-- 关闭
function GuildwarAwardWindow:onClickCloseBtn()
    controller:openGuildWarAwardWindow(false)
end

function GuildwarAwardWindow:close_callback()
    if self.scroll_list then
        for i,v in pairs(self.scroll_list) do
            v:DeleteMe()
        end
        self.scroll_list = nil
    end
    if self.scroll_list_1 then
        for i,v in pairs(self.scroll_list_1) do
            v:DeleteMe()
        end
        self.scroll_list_1 = nil
    end
    if self.scroll_list_fight then
        for i,v in pairs(self.scroll_list_fight) do
            v:DeleteMe()
        end
        self.scroll_list_fight = nil
    end
    controller:openGuildWarAwardWindow(false)
end

-- --------------------------------------------------------------------
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @description:
--      排行奖励
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildsecretareaRankRewardItem = class("GuildsecretareaRankRewardItem", function()
    return ccui.Layout:create()
end)

function GuildsecretareaRankRewardItem:ctor()
    self.item_list = {}
    
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildsecretarea/guildsecretarea_reward_rank_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    
    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)
    
    self.rank_img = self.root_wnd:getChildByName("rank_img")
    self.rank_label = self.root_wnd:getChildByName("rank_label")
    self.item_container = self.root_wnd:getChildByName("item_container")
    
    self.total_width = self.item_container:getContentSize().width
    
    self:registerEvent()
end

function GuildsecretareaRankRewardItem:registerEvent()
end

function GuildsecretareaRankRewardItem:setData(data)
    if data ~= nil then
        if data.index ~= nil then
            if data.index <= 3 then
                self.rank_label:setVisible(false)
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.index))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            else
                self.rank_img:setVisible(false)
                self.rank_label:setVisible(true)
                self.rank_label:setString(string.format("%s~%s", data.min, data.max))
                if data.max == 999 then
                    self.rank_label:setString(string.format("%s+", data.min))
                end
            end
        end

        self.item_container_size = self.item_container:getContentSize()

        local setting = {}
        setting.scale = 0.7
        setting.space_x = 15
        setting.is_center = false
        setting.max_count = 2
        local item_list = {}
        if data.reward then
            for k, v in pairs(data.reward) do
                table_insert(item_list, {v[1], v[2]})
            end
        end
        self.item_scrollview  = createScrollView(self.item_container_size.width, self.item_container_size.height, 0, 0, self.item_container, ScrollViewDir.horizontal) 
        self.scroll_list_item = commonShowSingleRowItemList(self.item_scrollview, self.scroll_list_item, item_list, setting)
        
    end
end

function GuildsecretareaRankRewardItem:DeleteMe()

   if self.scroll_list_item then
        for i,v in pairs(self.scroll_list_item) do
            v:DeleteMe()
        end
        self.scroll_list_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end 