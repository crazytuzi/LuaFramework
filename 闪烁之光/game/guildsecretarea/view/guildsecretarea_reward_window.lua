-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会秘境奖励展示界面
-- <br/>Create: 2019年9月19日 
GuildsecretareaRewardWindow = GuildsecretareaRewardWindow or BaseClass(BaseView)

local controller = GuildsecretareaController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function GuildsecretareaRewardWindow:__init()
    self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildmarketplacereward", "guildmarketplacereward"), type = ResourcesType.plist},
    }
    self.layout_name = "guildsecretarea/guildsecretarea_reward_window"
end

function GuildsecretareaRewardWindow:open_callback(  )
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
    gold_label:setString(TI18N("领主固定掉落奖励"))
    self.gold_container:getChildByName("gold_content"):setString(TI18N("(以下奖励必定会加入公会宝库)"))

    self.gold_container_1 = self.main_panel:getChildByName("gold_container_1")
    local gold_label_1= self.gold_container_1:getChildByName("gold_label_1")
    gold_label_1:setString(TI18N("领主随机掉落奖励"))
    self.gold_container_1:getChildByName("gold_content_1"):setString(TI18N("(以下奖励可能会加入公会宝库)"))

    self.fight_container = self.main_panel:getChildByName("fight_container")
    local fight_label= self.fight_container:getChildByName("fight_label")
    fight_label:setString(TI18N("挑战奖励"))

    self.rank_container = self.main_panel:getChildByName("rank_container")
    local rank_label= self.rank_container:getChildByName("rank_label")
    rank_label:setString(TI18N("排名奖励"))

    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("玩法奖励"))
    
    self.notice = self.main_panel:getChildByName("notice")
    self.notice:setVisible(true)
end

function GuildsecretareaRewardWindow:register_event(  )
        registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
        registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), true, 2)
        
        if self.tips then  --规则说明
            self.tips:addTouchEventListener(function ( sender,event_type )
                if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                    if Config.GuildSecretAreaData.data_const then
                        local str = Config.GuildSecretAreaData.data_const.treasure_rule.desc
                        TipsManager:getInstance():showCommonTips(str, sender:getTouchBeganPosition())
                    end
                end
            end)
        end
end

function GuildsecretareaRewardWindow:openRootWnd(boss_id)
    if not boss_id then return end
    self.boss_id = boss_id 
    self:setReward_random(self.boss_id) --设置随机奖励
    self:setReward_regular(self.boss_id)  -- 设置固定奖励
    self:setReward_Challenge(self.boss_id) --设置挑战奖励
    self:showRankInfo(self.boss_id)
end

--设置随机奖励
function GuildsecretareaRewardWindow:setReward_random(boss_id)
    local data_list = Config.GuildSecretAreaData.data_chapter_reward(boss_id).marketplace_rand_reward
    self.gold_scroll_size_1 = self.gold_container_1:getContentSize()
    local setting,list = self:setRewardSetting(data_list)
    self.gold_scrollview_1  = createScrollView(self.gold_scroll_size_1.width, self.gold_scroll_size_1.height, 0, 0, self.gold_container_1, ScrollViewDir.horizontal) 
    self.scroll_list_1 = commonShowSingleRowItemList(self.gold_scrollview_1, self.scroll_list_1, list, setting)
end

--设置固定奖励
function GuildsecretareaRewardWindow:setReward_regular(boss_id)
    local data_list = Config.GuildSecretAreaData.data_chapter_reward(boss_id).marketplace_reward
    self.gold_scroll_size = self.gold_container:getContentSize()
    local setting,list = self:setRewardSetting(data_list)
    self.gold_scrollview = createScrollView(self.gold_scroll_size.width, self.gold_scroll_size.height, 0, 0, self.gold_container, ScrollViewDir.horizontal) 
    self.scroll_list = commonShowSingleRowItemList(self.gold_scrollview, self.scroll_list, list, setting)

end

--设置挑战奖励
function GuildsecretareaRewardWindow:setReward_Challenge(boss_id)
    local data_list_fight = Config.GuildSecretAreaData.data_chapter_reward(boss_id).change_reward
    self.fight_scroll_size = self.fight_container:getContentSize()
    local setting,list = self:setRewardSetting(data_list_fight)
    self.fight_scrollview  = createScrollView(self.fight_scroll_size.width, self.fight_scroll_size.height, 0, 0, self.fight_container, ScrollViewDir.horizontal) 
    self.scroll_list_fight = commonShowSingleRowItemList(self.fight_scrollview, self.scroll_list_fight, list, setting)
end

function GuildsecretareaRewardWindow:setRewardSetting( data )
    local setting = {}
    setting.scale = 0.9
    setting.space_x = 15
    setting.is_center = false
    setting.max_count = 5
    local data_list1 = {}
    if data then
        for k, v in pairs(data) do
            table_insert(data_list1, {v[1], v[2]})
        end
    end
    return setting,data_list1
end

--排名情况
function GuildsecretareaRewardWindow:showRankInfo(boss_id)
    local data = Config.GuildSecretAreaData.data_rank_reward[boss_id]
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
        
        local tmp_list = data
        table_sort( tmp_list, function(a,b) return a.min < b.min end )
            for i,v in ipairs(tmp_list) do
                v.index = i
            end
        self.rank_scrollview:setData(tmp_list)
    end
end


-- 关闭
function GuildsecretareaRewardWindow:onClickCloseBtn()
    controller:openGuildsecretareaRewardWindow(false)
end

function GuildsecretareaRewardWindow:close_callback()
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
    controller:openGuildsecretareaRewardWindow(false)
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
