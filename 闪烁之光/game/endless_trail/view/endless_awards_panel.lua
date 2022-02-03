-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼总奖励面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessAwardsPanel = class("EndlessAwardsPanel", function()
    return ccui.Layout:create()
end)

local table_sort = table.sort
local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel() 

function EndlessAwardsPanel:ctor(type)
    self.endless_type = type or Endless_trailEvent.endless_type.old
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_awards_panel"))

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
        item_class = EndlessAwardsItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 0,
        item_width = 614,
        item_height = 124,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(scroll_container, nil, nil, nil, size, setting)
    self:registerEvent()
end

function EndlessAwardsPanel:registerEvent()
end

function EndlessAwardsPanel:setNodeVisible(status)
	self:setVisible(status)
end 

function EndlessAwardsPanel:addToParent()
    local tmp_list = deepCopy(Config.EndlessData.data_rank_reward_data[self.endless_type])
    table_sort(tmp_list, SortTools.KeyLowerSorter("min"))
    for i,v in ipairs(tmp_list) do
        v.index = i
    end
    self.scroll_view:setData(tmp_list)
end

function EndlessAwardsPanel:updatePanelInfo(is_event)
end

function EndlessAwardsPanel:DeleteMe()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


EndlessAwardsItem = class("EndlessAwardsItem",function()
    return ccui.Layout:create()
end)

function EndlessAwardsItem:ctor()
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

    self.total_width = self.item_container:getContentSize().width

    self:registerEvent()
end

function EndlessAwardsItem:registerEvent()
end

function EndlessAwardsItem:setData(data)
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
        local sum = #data.items
        for i=sum,1,-1 do
            local v = data.items[i]
            item_config = Config.ItemData.data_get_data(v[1])
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

function EndlessAwardsItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end
