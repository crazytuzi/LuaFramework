-- --------------------------------------------------------------------
-- @author: whjing@shiyuegame.com(必填, 创建模块的人员)
-- @description:
--      众神战排名奖励的标签面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GodBattleRankRewardPanel = GodBattleRankRewardPanel or BaseClass()

function GodBattleRankRewardPanel:__init(parent)
    self.is_init = false
    self.parent = parent
    self:createRootWnd()
    self:registerEvent()
end

function GodBattleRankRewardPanel:createRootWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("godbattle/godbattle_rank_rewards_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end
    self.container = self.root_wnd:getChildByName("container")
    self.item = self.root_wnd:getChildByName("item")
    self.scroll_container = self.container:getChildByName("scroll_container")
    local size = self.scroll_container:getContentSize()
    local setting = {
        item_class = GodBattleRankRewardItem,
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
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, nil, nil, nil, size, setting)
end

function GodBattleRankRewardPanel:registerEvent()
end

function GodBattleRankRewardPanel:addToParent(status)
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
    local model = GodbattleController:getInstance():getModel()
    local self_info = model:getSelfInfo()
    if status == true and self_info then
        self.scroll_view:setData(Config.ZsWarData.data_rank_rewards[self_info.group], nil, nil, self.item)
    end
end

function GodBattleRankRewardPanel:__datale()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil
end

-- --------------------------------------------------------------------
-- @author: whjing@shiyuegame.com(必填, 创建模块的人员)
-- @description:
--      众神战排名奖励的标签面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------


GodBattleRankRewardItem = class("GodBattleRankRewardItem", function()
    return ccui.Layout:create()
end)

function GodBattleRankRewardItem:ctor()
    self.item_list = {}
end

function GodBattleRankRewardItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

        self.label = self.root_wnd:getChildByName("rank_label")
        self.item_container = self.root_wnd:getChildByName("item_container")
        self.total_width = self.item_container:getContentSize().width

		self:registerEvent()
    end
end

function GodBattleRankRewardItem:registerEvent()
end

function GodBattleRankRewardItem:setData(data)
    if data ~= nil then
        self.label:setString(data.desc)
        local item_config = nil
        local index = 1
        local item = nil
        local scale = 0.8
        local off = 10
        local _x, _y = 0, 55
        local sum = #data.items
        for i, v in pairs(self.item_list) do
            v:setVisible(false)
        end
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
                item:setVisible(true)
                item:setBaseData(v[1],v[2])
                index = index + 1
            end
        end
    end
end

function GodBattleRankRewardItem:suspendAllActions()
end

function GodBattleRankRewardItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end
