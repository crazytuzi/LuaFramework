-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      掉落信息查看面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattlDramaDropTipsWindow = class("BattlDramaDropTipsWindow", function()
    return ccui.Widget:create()
end)

local controller = BattleDramaController:getInstance() 
local model = BattleDramaController:getInstance():getModel()

function BattlDramaDropTipsWindow:ctor(max_dun_id)
    self.max_dun_id = max_dun_id or model:getDramaData().max_dun_id
    self.item_list = {}
    self:open_callback()
end
function BattlDramaDropTipsWindow:open_callback()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("battledrama/battle_drama_drop_view"))
	self.root_wnd:setPosition(58,260)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("root")
    self.item_scroolview = self.main_container:getChildByName("item_scrollview")
    self.item_scroolview:setScrollBarEnabled(false)

    self.empty_bg = self.main_container:getChildByName('empty_bg')
    self.empty_bg:setVisible(true)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), LOADTEXT_TYPE)

    self.desc_label = self.empty_bg:getChildByName('desc_label')
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N('暂无记录'))

    if self.max_dun_id and Config.DungeonData.data_drama_dungeon_info(self.max_dun_id) then
        local data = Config.DungeonData.data_drama_dungeon_info(self.max_dun_id)
        if data then
            self:updateItemReward(data.hook_show_items)
        end
    end
end

function BattlDramaDropTipsWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
            end
        end)
    end
end

function BattlDramaDropTipsWindow:updateItemReward(data)
    if not data then return end
    self.empty_bg:setVisible(false)
    self.cur_item = BattleDramaDropItem.new()
    self.cur_item:setData(true,data)
    self.cur_item:setPosition(8,491)
    self.main_container:addChild(self.cur_item)
    local base_data =model:getDramaData()
    if base_data then
        local list = model:getShowDescRewad(base_data.max_dun_id)
        if list and next(list or {}) ~= nil then
            local item = nil
            local item_height = BattleDramaDropItem.HEIGHT * #list
            local total_height = #list * BattleDramaDropItem.HEIGHT * #data
            local max_height = math.max(self.item_scroolview:getContentSize().height, item_height)
            self.item_scroolview:setInnerContainerSize(cc.size(self.item_scroolview:getContentSize().width,max_height))
            for i, v in ipairs(list) do
                delayRun(self.item_scroolview, i / display.DEFAULT_FPS, function()
                    if not self.item_list[i] then
                        item = BattleDramaDropItem.new()
                        item:setAnchorPoint(0.5,1)
                        item:setScale(1)
                        self.item_scroolview:addChild(item)
                        self.item_list[i] = item
                    end
                    item = self.item_list[i]
                    if item then
                        item:setData(false,v)
                        item:setPosition(self.item_scroolview:getContentSize().width/2+1,max_height - (BattleDramaDropItem.HEIGHT+5) * (i-1) )
                    end
                end)
            end
        end
    end
end

function BattlDramaDropTipsWindow:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function BattlDramaDropTipsWindow:DeleteMe()
    if self.cur_item then
        self.cur_item:DeleteMe()
        self.cur_item = nil
    end
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i,v in ipairs(self.item_list) do
            if v then
                v:DeleteMe()
                v = nil
            end
        end
    end
    self.item_list = {}
end