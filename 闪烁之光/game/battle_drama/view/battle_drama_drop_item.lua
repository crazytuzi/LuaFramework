-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      主界面小地图
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaDropItem =
    class(
    'BattleDramaDropItem',
    function()
        return ccui.Layout:create()
    end
)
BattleDramaDropItem.WIDTH = 600
BattleDramaDropItem.HEIGHT = 168
function BattleDramaDropItem:ctor(is_bool, is_bools, size)
    self:retain()
    self.size = size or cc.size(BattleDramaDropItem.WIDTH, BattleDramaDropItem.HEIGHT)
    self:setContentSize(self.size)
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB('battledrama/battle_drama_drop_item'))
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName('root')
    self.name_label = self.container:getChildByName("name_label")
    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_list = {}
    self:registerEvent()
end

function BattleDramaDropItem:registerEvent()
end

function BattleDramaDropItem:setData(is_single,data)
    if is_single == true then
        self:updateItem(data)
        self.name_label:setString(TI18N("当前关卡"))
    else
        self.name_label:setString(data.name)
        self:updateItem(data.items)
    end
end

function BattleDramaDropItem:updateItem(data)
    if not data then
        return
    end
    local scale = 0.8
    local item = nil
    local item_width = BackPackItem.Width * scale * #data

    local total_width = #data * BackPackItem.Width * scale + #data * 10
    local max_width = math.max(self.item_scrollview:getContentSize().width, total_width)
    self.item_scrollview:setInnerContainerSize(cc.size(max_width, self.item_scrollview:getContentSize().height))
    --self.start_x = (self.item_scrollview:getContentSize().width - total_width) * 0.5
    self.start_x = 0
    for i, v in ipairs(data) do
        delayRun(self.item_scrollview,i / display.DEFAULT_FPS,function ()
            if not self.item_list[i] then
                item = BackPackItem.new(true, true)
                item:setAnchorPoint(0, 0.5)
                item:setScale(scale)
                self.item_scrollview:addChild(item)
                self.item_list[i] = item
            end
            item = self.item_list[i]
            if item then
                local _x = self.start_x + (i - 1) * (BackPackItem.Width * scale + 10) + 8
                item:setPosition(_x, self.item_scrollview:getContentSize().height / 2)
                local data = {bid = v[1], num = v[2]}
                item:setBaseData(v[1], v[2],true)
                item:setDefaultTip()
            end

        end)

    end

end

function BattleDramaDropItem:DeleteMe()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self:removeAllChildren()
    self:removeFromParent()
    self:release()
end
