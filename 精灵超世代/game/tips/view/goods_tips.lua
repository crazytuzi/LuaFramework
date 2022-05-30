
-- User: cloud
-- Date: 2017.2.21
-- [[文件功能：物品的tips部分]]
GoodsTips = GoodsTips or BaseClass(GoodsBaseTips)
function GoodsTips:__init()
    self:initMainContainer()
end

function GoodsTips:initMainContainer()
    local win_size = cc.size(SCREEN_WIDTH, display.height)
    --父容器
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(win_size)
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setSwallowTouches(false)

    --主界面容器
    self.main_container = ccui.Widget:create()
    self.main_container:setTouchEnabled(true)
    self.main_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.main_container:setContentSize(cc.size(self.WIDHT, self.WIDTH))
    self.main_container:setPosition(cc.p(win_size.width/2, win_size.height/2))
    self:getRootWnd():addChild(self.main_container)
end

--[[设置物品的数据vo
-- @param vo 数据vo部分
-- @param is_tabBar 判断是否要侧边栏
-- @param get_num(特殊参数，用于显示可领取的个数)
-- @is_pack_num 是否显示背包物品数量
-- ]]
function GoodsTips:setDataVo(vo, is_tabBar, is_role, roleVo, get_num, is_pack_num,partner_id)
    if vo == nil or vo.base_id == nil or Config.ItemData.data_get_data(vo.base_id) == nil then
        return
    end
    self.goods_vo = vo
    self.is_tabBar = is_tabBar or false
    self.is_role = is_role
    self.roleVo = roleVo
    self.get_num = get_num
    self.is_pack_num = is_pack_num or true
    --设置数据
    GoodsBaseTips.setDataVo(self, vo, self.is_tabBar, get_num, self.is_pack_num,partner_id)
    self:registerEvents()
    self:open()

    self:setCascadeOpacityEnabled(self.root_wnd, true)
end

--根据物品的bid来设置物品的tips部分
function GoodsTips:setDataByBid(item_bid, get_num,partner_id)
    local config 
    -- if is_partner then
    --     config = Config.PartnerData.data_partner[get_num]
    --     config.base_id = config.bid
    -- else
        config = Config.ItemData.data_get_data(item_bid)
        config.base_id = config.id
    --end
    self:setDataVo(config, false, nil , nil, get_num,nil,partner_id)
end


function GoodsTips:registerEvents()
    -- 使用成功事件
    self.use_success_event = GlobalEvent:getInstance():Bind(BackpackEvent.USE_GOODS_SUCCESS,function(item_bid)
--        self:close()
        if self.goods_vo and item_bid == self.goods_vo.bid then
            local item_vo = BackPackCtrl:getInstance():getData():getBackPackItemById(self.goods_vo.id)
            if item_vo and item_vo.quantity > 0 then
                self:updateGoodsNum(item_vo)
            else
                self:close()
            end
        end
    end)

    self.root_wnd:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:close()
        end
    end)
end


function GoodsTips:getRootWnd()
    return self.root_wnd
end

function GoodsTips:open()
    --移除
    doRemoveFromParent(self:getRootWnd())
    --加入
    if not self:getRootWnd():getParent() then
    	local parent = ViewManager:getInstance():getLayerByTag( ViewMgrTag.MSG_TAG )
        parent:addChild(self:getRootWnd())
        self:setCommonUIZOrder(self:getRootWnd())
    end
end


function GoodsTips:unRegisterEvent()

    if self.use_success_event then
        GlobalEvent:getInstance():UnBind(self.use_success_event)
        self.use_success_event = nil
    end
end

function GoodsTips:__close()
    --移除
    doRemoveFromParent(self:getRootWnd())

    self.use_btn = nil
    self.change_desc_label = nil
end


function GoodsTips:close()
    if tolua.isnull(self:getRootWnd()) then return end
    self:unRegisterEvent()
    self:__close()

end


function GoodsTips:setCascadeOpacityEnabled(parent, bool)
    local cascadeOpacityEnabled, opacityEnabled

    opacityEnabled = function(parent, bool)
        local desc = parent:getDescription()
        if string.find(desc, "Layout") or string.find(desc, "Widget") then
            parent:setCascadeOpacityEnabled(bool)
        end
    end

    cascadeOpacityEnabled =  function (parent, bool)
        if parent:getChildrenCount() > 0 then
            opacityEnabled(parent, bool)
            local children = parent:getChildren()
            for k, v in pairs(children) do
                cascadeOpacityEnabled(v, bool)
            end
        else
            opacityEnabled(parent, bool)
        end
    end
    cascadeOpacityEnabled(parent, bool)
end

function GoodsTips:setTouchEnabled( value )
--    self.root_wnd:setTouchEnabled(value)
end