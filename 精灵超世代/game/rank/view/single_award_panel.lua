--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年4月26日
-- @description    : 
        -- 排行榜奖励界面
---------------------------------
SingleAwardPanel = class("SingleAwardPanel",function()
    return ccui.Layout:create()
end)

-- local _controller = RankController:getInstance()
-- local _model = _controller:getModel()

function SingleAwardPanel:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_awards_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5 - 20)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    local rank_title = container:getChildByName("rank_title")
    rank_title:setString(TI18N("排名"))
    local award_title = container:getChildByName("award_title")
    award_title:setString(TI18N("奖励"))

    self.scroll_container = container:getChildByName("scroll_container")
    self:registerEvent()
end

function SingleAwardPanel:registerEvent()
end

function SingleAwardPanel:setNodeVisible(status)
    self:setVisible(status)
end

function SingleAwardPanel:updateScrollList()
    if not self.show_list then return end
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {font_size = 22,scale = 1, text = TI18N("暂无奖励信息")})
        return
    end

    if not self.scroll_view then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 4,                  -- 第一个单元的X起点
            space_x = 4,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 614,               -- 单元的尺寸width
            item_height = 124,              -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    self.scroll_view:reloadData()
end
--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function SingleAwardPanel:createNewCell(width, height)
    local cell = SingleAwardsItem.new(self.rank_type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function SingleAwardPanel:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function SingleAwardPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if cell_data then
        local max_index = self:numberOfCells()
        cell:setData(cell_data, index, index == max_index)
    end

end

function SingleAwardPanel:addToParent(setting)
    -- 窗体打开只请求一次，不是标签显示
    if self.show_list == nil then
        self.setting = setting or {}
        self.rank_type = self.setting.rank_type or RankConstant.RankType.element
        self.show_list = self:getConfigByRankType(self.rank_type)
        self:updateScrollList()
    end
end

function SingleAwardPanel:getConfigByRankType(rank_type)
    local list = {}
    if rank_type == RankConstant.RankType.element then --元素神殿
        list = Config.ElementTempleData.data_award
        table.sort(list, function(a,b) return a.min < b.min end)
    elseif rank_type == RankConstant.RankType.sandybeach_boss_fight then --沙滩争夺战
        list = Config.HolidayBossData.data_rank_info
        table.sort(list, function(a,b) return a.min < b.min end)
    elseif self.rank_type == RankConstant.RankType.guild_secretarea then --公会秘境
        local boss_id = self.setting.boss_id
        list = Config.GuildSecretAreaData.data_rank_reward[boss_id] or {}
        table.sort(list, function(a,b) return a.min < b.min end)
    elseif self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰竞技场
        list = Config.ArenaPeakChampionData.data_rank_reward
        table.sort(list, function(a,b) return a.min < b.min end)
    elseif self.rank_type == RankConstant.RankType.year_monster then --年兽
        config_list = Config.HolidayNianData.data_rank_reward
        local table_insert = table.insert
        for i,v in ipairs(config_list) do
            table_insert(list, {min = v.rank_high, max = v.rank_low, awards = v.reward})
        end
        table.sort(list, function(a,b) return a.min < b.min end) 
    elseif rank_type == RankConstant.RankType.sweet then --甜蜜大作战
        list = Config.HolidayValentinesData.data_rank_award or {}
        table.sort(list, function(a,b) return a.rank1 < b.rank2 end)
    else
        print("排行类型为: ",rank_type)
    end
    return list
end

function SingleAwardPanel:DeleteMe()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end

------------------------@ item
SingleAwardsItem = class("SingleAwardsItem",function()
    return ccui.Layout:create()
end)

function SingleAwardsItem:ctor(rank_type)
    self.item_list = {}

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_awards_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.rank_img = self.root_wnd:getChildByName("rank_img")
    self.rank_label = self.root_wnd:getChildByName("rank_label")
    self.item_container = self.root_wnd:getChildByName("item_container")

    local size = cc.size(344, 110)
    self.scroll_view = createScrollView(size.width, size.height, 252, 7, self.root_wnd, ScrollViewDir.horizontal ) 
    -- self.scroll_container = self.scroll_view:getInnerContainer() 


    self.total_width = self.item_container:getContentSize().width
    self.rank_type = rank_type
    self:registerEvent()
end

function SingleAwardsItem:registerEvent()
end

--@is_last 是否最后一个
function SingleAwardsItem:setData(data, index, is_last)
    if data ~= nil then
        data.index = index
        if data.index ~= nil then
            if data.index <= 3 then
                self.rank_label:setVisible(false)
                if data.rank == 0 then
                    self.rank_img:setVisible(false)
                else
                    -- local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.index))
                    local res_id = PathTool.getResFrame("common", RankConstant.RankIconRes[data.index])
                    if self.rank_res_id ~= res_id then
                        self.rank_res_id = res_id
                        loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                    end
                    self.rank_img:setVisible(true)
                end
            else
                self.rank_img:setVisible(false)
                self.rank_label:setVisible(true)
                
                --和策划协商如果最后一个是999的.显示 名次+ --by lwc
                if is_last and data.max == 999 then 
                    self.rank_label:setString(string.format("%s+", data.min or data.rank1))
                else
                    local rank1 = data.min or data.rank1
                    local rank2 = data.max or data.rank2
                    if rank1 < rank2 then
                        self.rank_label:setString(string.format("%s~%s", rank1, rank2))
                    else
                        self.rank_label:setString(string.format("%s", rank1))
                    end
                end
            end 
        end
        --无奈兼容各自排行命名..
        local data_list = data.items or data.reward or data.awards or data.award
        local setting = {}
        setting.scale = 0.8
        setting.max_count = 3
        -- setting.is_center = true
        -- setting.show_effect_id = true
        self.item_list = commonShowSingleRowItemList(self.scroll_view, self.item_list, data_list, setting)
    end
end

function SingleAwardsItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end