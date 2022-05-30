--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-07 11:40:56
-- @description    : 
		-- 圣殿奖励界面
---------------------------------
WeeklyAwardPanel = class("WeeklyAwardPanel",function()
    return ccui.Layout:create()
end)

local _controller = WeeklyActivitiesController:getInstance()
local _model = _controller:getModel()

function WeeklyAwardPanel:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/hippocrene_award_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    local rank_title = container:getChildByName("rank_title")
    rank_title:setString(TI18N("排名"))
    local award_title = container:getChildByName("award_title")
    award_title:setString(TI18N("奖励"))

    local scroll_container = container:getChildByName("scroll_container")
    local size = scroll_container:getContentSize()
    local setting = {
        item_class = WeeklyAwardItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 0,
        item_width = 614,
        item_height = 124,
        row = 0,
        col = 1,
        need_dynamic = false
    }
    self.scroll_view = CommonScrollViewLayout.new(scroll_container, nil, nil, nil, size, setting)
    self:registerEvent()
end

function WeeklyAwardPanel:registerEvent()
end

function WeeklyAwardPanel:setNodeVisible(status)
	self:setVisible(status)
end

function WeeklyAwardPanel:addToParent()
    local tmp_list =  _controller:getRandListData()
    for i,v in ipairs(tmp_list) do
        v.index = i
    end

    --dump(tmp_list, "-------------------->>")
    self.scroll_view:setData(tmp_list)
end

function WeeklyAwardPanel:DeleteMe()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    self:removeFromParent()
end

------------------------@ item
WeeklyAwardItem = class("WeeklyAwardItem",function()
    return ccui.Layout:create()
end)

function WeeklyAwardItem:ctor()
    self.item_list = {}

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/hippocrene_awards_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.rank_img       = self.root_wnd:getChildByName("rank_img")
    self.rank_label     = self.root_wnd:getChildByName("rank_label")
    self.item_container = self.root_wnd:getChildByName("item_container")
    self.total_width    = self.item_container:getContentSize().width

    self:registerEvent()
end

function WeeklyAwardItem:registerEvent()
end

function WeeklyAwardItem:setData(data)
    if data ~= nil then
        if data.index ~= nil then
            if data.index <= 3 then
                self.rank_label:setVisible(false)
                if data.rank == 0 then
                    self.rank_img:setVisible(false)
                else
                    local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.index))
                    if self.rank_res_id ~= res_id then
                        self.rank_res_id = res_id
                        loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                    end
                    self.rank_img:setVisible(true)
                end
            else 
                self.rank_img:setVisible(false)
                self.rank_label:setVisible(true)
                self.rank_label:setString(string.format("%s~%s", data.min, data.max))
            end 
        end
        local item_config = nil
        local index = 1
        local item = nil
        local scale = 0.8
        local off = 10
        local _x, _y = 0, 55
        local sum = #data.reward
        for i=1,sum do
            local v = data.reward[i]
            --dump(v, "88888888-------------->")
            item_config = Config.ItemData.data_get_data(v[1])
            --dump(item_config, "---------------------物品详情")
            --if v[1] == 50016 then 
            --    dump(item_config, "---------------------物品详情")
            --end
            if item_config then
                if self.item_list[index] == nil then
                    item = BackPackItem.new(false, true, false, scale, false, true) 
                    _x = self.total_width - ( (index-1)*(BackPackItem.Width*scale+off) + BackPackItem.Width*0.5*scale )
                    item:setPosition(_x, _y)
                    self.item_container:addChild(item)
                    self.item_list[index] = item
                end
                item = self.item_list[index]
                item:setBaseData(v[1],v[2])
                index = index + 1
            end
        end
    end
end

function WeeklyAwardItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end