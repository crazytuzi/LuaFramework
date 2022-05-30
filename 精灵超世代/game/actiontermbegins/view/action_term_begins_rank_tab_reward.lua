-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--       排行榜页签 奖励排行
-- <br/> 2019年8月22日
-- --------------------------------------------------------------------
ActiontermbeginsRankTabReward = class("ActiontermbeginsRankTabReward", function()
    return ccui.Widget:create()
end)

local controller = ActiontermbeginsController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

local math_floor = math.floor

function ActiontermbeginsRankTabReward:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ActiontermbeginsRankTabReward:config()

end

function ActiontermbeginsRankTabReward:layoutUI()
    local csbPath = PathTool.getTargetCSB("actiontermbegins/action_term_begins_rank_tab_reward")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()
    self.bg = self.main_container:getChildByName("bg")
    

    self.item_list = self.main_container:getChildByName("item_list")
    local range_label = self.main_container:getChildByName("range_label")
    range_label:setString(TI18N("名次"))
    local reward_label = self.main_container:getChildByName("reward_label")
    reward_label:setString(TI18N("奖励"))

    self.my_rank = self.main_container:getChildByName("my_rank")
    self.award_title = self.my_rank:getChildByName("award_title")
    self.award_title:setString(TI18N("保持排名可获得奖励:"))
    local rank_title = self.my_rank:getChildByName("rank_title")
    rank_title:setString(TI18N("我的排名:"))
    self.rank_label = self.my_rank:getChildByName("rank_label")
    self.good_con = self.my_rank:getChildByName("good_con")

    local good_con_size = self.good_con:getContentSize()
    self.good_con_size = good_con_size
    self.item_scroll_view = createScrollView(good_con_size.width, good_con_size.height, 0, 0, self.good_con, ccui.ScrollViewDir.horizontal) 
    self.item_scroll_view:setAnchorPoint(cc.p(0, 0))
    self.item_scroll_view:setInnerContainerSize(cc.size(good_con_size.width, good_con_size.height))
    self.item_scroll_view:setSwallowTouches(false)
end

--事件
function ActiontermbeginsRankTabReward:registerEvents()
    -- registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
    --     if self.parent and self.parent.is_move_effect then return end
    --     local config = Config.ResonateData.data_const.rule_tips
    --     if config then
    --         TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    --     end
    -- end ,true, 2, nil, 0.8)

    -- for i,v in ipairs(self.item_lay_list) do
    --     registerButtonEventListener(v.btn, function() self:onClickHeroBtn(i)  end ,false, 2)
    -- end

    -- --打开布阵事件
    -- if not self.boss_form_event then 
    --     self.boss_form_event = GlobalEvent:getInstance():Bind(ActiontermbeginsEvent.TERM_BEGINS_BOSS_FORM_EVENT, function()
    --         HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.TermBeginsBoss) 
    --     end)
    -- end
end

function ActiontermbeginsRankTabReward:setData()
    if not self.parent then return end

    if self.parent.rank_type == RankConstant.RankType.termbegins then
        if not self.is_init then
            self.is_init = true
            if self.parent.scdata then
                self:setScdata(self.parent.scdata)         
            end
        end
    end
end

function ActiontermbeginsRankTabReward:setScdata(data)
    if not self.parent then return end
    self.rank_type = self.parent.rank_type or RankConstant.RankType.termbegins
    local is_hide_my_rank = true 
    if self.parent.rank_type == RankConstant.RankType.termbegins then
        is_hide_my_rank = false
        self.rank = data.rank_per
        self.reward = model:getRankRewardByRank(self.rank)
    else
        is_hide_my_rank = true
    end
    if is_hide_my_rank then
        self.my_rank:setVisible(false)
        self.bg_size = self.bg:getContentSize()
        self.bg:setContentSize(cc.size(self.bg_size.width ,805))
        local scroll_view_size = self.item_list:getContentSize()
        self.item_list:setContentSize(cc.size(scroll_view_size.width, 734))
    else
        self:initMyRank()
    end
    self.show_list = self:getConfigByRankType(self.rank_type)
    self:updateList()
end

function ActiontermbeginsRankTabReward:getConfigByRankType(rank_type)
    local list = {}
    if rank_type == RankConstant.RankType.element then --元素神殿
        list = Config.ElementTempleData.data_award
        table.sort(list, function(a,b) return a.min < b.min end)
    elseif rank_type == RankConstant.RankType.sandybeach_boss_fight then --沙滩争夺战
        list = Config.HolidayBossData.data_rank_info
        table.sort(list, function(a,b) return a.min < b.min end)
    elseif rank_type == RankConstant.RankType.termbegins then --开学季活动奖励
        list = Config.HolidayTermBeginsData.data_rank_reward
        table.sort(list, function(a,b) return a.rank1 < b.rank1 end)
    end
    return list
    -- body
end

function ActiontermbeginsRankTabReward:initMyRank()
    if self.rank <= 0 then
        self.rank_label:setString(TI18N("未上榜"))
        self.rank_label:setTextColor(cc.c3b(169, 95 ,15))
        if self.parent.rank_type == RankConstant.RankType.termbegins then
            self.award_title:setString(TI18N("前1%可获得右边奖励:"))
        end
    else
        if self.parent.rank_type == RankConstant.RankType.termbegins then
            self.rank_label:setString(string_format(TI18N("前%s%%"), self.rank))
        else
            self.rank_label:setString(self.rank)
        end
        self.rank_label:setTextColor(cc.c3b(336, 144, 3))
    end
    if self.reward then
        local data_list = self.reward
        local setting = {}
        setting.scale = 0.8
        setting.max_count = 3
        setting.is_center = true
        -- setting.show_effect_id = 263
        self.packback_item_list = commonShowSingleRowItemList(self.item_scroll_view, self.packback_item_list, data_list, setting)
    end
    
end

function ActiontermbeginsRankTabReward:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.item_list:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 614,                -- 单元的尺寸width
            item_height = 138,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.item_list, true, {text = TI18N("暂无奖励数据")})
    else
        commonShowEmptyIcon(self.item_list, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActiontermbeginsRankTabReward:createNewCell(width, height)
   local cell = TermbeginsRewardItem.new(width, height, self.parent.rank_type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActiontermbeginsRankTabReward:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActiontermbeginsRankTabReward:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, index)
end


function ActiontermbeginsRankTabReward:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function ActiontermbeginsRankTabReward:DeleteMe()
    if self.boss_form_event then
        GlobalEvent:getInstance():UnBind(self.boss_form_event)
        self.boss_form_event = nil
    end
    if self.packback_item_list then
        for i,v in pairs(self.packback_item_list) do
            v:DeleteMe()
        end
        self.packback_item_list = nil
    end

    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    doStopAllActions(self.item_scrollview)
end


------------------------------@ item
TermbeginsRewardItem = class("TermbeginsRewardItem",function()
    return ccui.Layout:create()
end)

function TermbeginsRewardItem:ctor(width, height, rank_type)
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("actiontermbegins/action_term_begins_reward_item"))
    self.size = cc.size(width, height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.level_name = self.container:getChildByName("level_name")
    self.icon = self.container:getChildByName("icon")
    self.level_name2 = self.container:getChildByName("level_name2")

    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)

    self.rank_type = rank_type or 0
    self:registerEvent()
end

function TermbeginsRewardItem:registerEvent()

end

function TermbeginsRewardItem:setData(data, index)
       if data ~= nil then
        data.index = index
        local data_list = data.items

        if self.rank_type ==  RankConstant.RankType.termbegins then
            data_list = data.award
            --开学季特殊的显示
            if data.index == 1 then
                self.level_name:setString(string.format(TI18N("前%s%%"), data.rank2))    
            else
                self.level_name:setString(string.format(TI18N("前%s%%(不含)~%s%%"), data.rank1, data.rank2))    
            end
        else
            data_list = data.items
            if data.index <= 3 then
                self.level_name:setVisible(false)
                if data.rank == 0 then
                    self.icon:setVisible(false)
                else
                    local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.index))
                    if self.rank_res_id ~= res_id then
                        self.rank_res_id = res_id
                        loadSpriteTexture(self.icon, res_id, LOADTEXT_TYPE_PLIST)
                    end
                    self.icon:setVisible(true)
                end
            else
                self.icon:setVisible(false)
                self.level_name:setVisible(true)
                
                -- if is_last and self.rank_type == RankConstant.RankType.sandybeach_boss_fight then
                --     print("data.min, data.max.... ",data.min, data.max)
                --     self.level_name:setString(string.format("%s+", data.min))
                -- else
                    self.level_name:setString(string.format("%s~%s", data.min, data.max))    
                -- end
            end 
        end

        local setting = {}
        setting.scale = 0.8
        setting.max_count = 3
        -- setting.is_center = true
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    end
end

function TermbeginsRewardItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end