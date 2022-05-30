---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/17 15:46:08
-- @description: 圣夜奇境 奖励一览界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()

MonopolyRankAwardPanel = class("MonopolyRankAwardPanel",function()
    return ccui.Layout:create()
end)

function MonopolyRankAwardPanel:ctor()
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
        item_class = MonopolyRankAwardsItem,
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

function MonopolyRankAwardPanel:registerEvent()
end

function MonopolyRankAwardPanel:setNodeVisible(status)
	self:setVisible(status)
end

function MonopolyRankAwardPanel:addToParent()
    local tmp_list = deepCopy(Config.MonopolyDungeonsData.data_award)
    for i,v in ipairs(tmp_list) do
        v.index = i
    end
    self.scroll_view:setData(tmp_list)
end

function MonopolyRankAwardPanel:DeleteMe()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end

------------------------@ item
MonopolyRankAwardsItem = class("MonopolyRankAwardsItem",function()
    return ccui.Layout:create()
end)

function MonopolyRankAwardsItem:ctor()
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

function MonopolyRankAwardsItem:registerEvent()
end

function MonopolyRankAwardsItem:setData(data)
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

function MonopolyRankAwardsItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end