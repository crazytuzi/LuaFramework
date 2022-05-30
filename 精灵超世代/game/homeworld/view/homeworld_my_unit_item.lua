--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-28 10:16:50
-- @description    : 
		-- 我的家具item
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

HomeworldMyUnitItem = class("HomeworldMyUnitItem", function()
    return ccui.Widget:create()
end)

function HomeworldMyUnitItem:ctor()
	self:configUI()
	self:register_event()
end

function HomeworldMyUnitItem:configUI(  )
	self.size = cc.size(155, 172)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("homeworld/homeworld_my_unit_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self.container:setSwallowTouches(false)

    self.sp_icon = container:getChildByName("sp_icon")
    self.sp_icon:setScale(0.75)
    self.sell_btn = container:getChildByName("sell_btn")
    self.image_tips = container:getChildByName("image_tips")
    self.image_tips:getChildByName("label"):setString(TI18N("已装饰所有"))

    self.name_txt = container:getChildByName("name_txt")
    self.num_txt = container:getChildByName("num_txt")
end

function HomeworldMyUnitItem:register_event(  )
    registerButtonEventListener(self.container, function (  )
        if self.data.have_num <= 0 then return end
        if self.click_callback and self.data then
            self.click_callback(self.data.base_id)
        end
    end, true, nil, nil, nil, 0.5, true)

    registerButtonEventListener(self.sell_btn, function (  )
        if not self.data then return end
        local can_sell_num = 0
        if self.data.have_num > self.data.bag_num then
            can_sell_num = self.data.bag_num
        else
            can_sell_num = self.data.have_num
        end
        if can_sell_num <= 0 then
            message(TI18N("没有可出售的家具"))
            return
        end
        if self.data.have_num > 0 then
            BackpackController:getInstance():openItemSellPanel(true, self.data, BackPackConst.Bag_Code.HOME, 2)
        end
    end, true)
end

-- data:good_vo
function HomeworldMyUnitItem:setData( data )
    if data ~= nil then
        self.data = data
        self.unit_cfg = Config.HomeData.data_home_unit(data.base_id)

        -- 引导需要
        self.container:setName("guide_my_unit_" .. data.base_id)

        self:refreshItemInfo()
    end
end

function HomeworldMyUnitItem:refreshItemInfo(  )
    if not self.data or not self.unit_cfg then return end

    -- 图标
    if self.unit_cfg.icon and (not self.cur_res_icon or self.cur_res_icon ~= self.unit_cfg.icon) then
        local res_path = PathTool.getFurnitureNormalRes(self.unit_cfg.icon)
        self.cur_res_icon = self.unit_cfg.icon
        loadSpriteTexture(self.sp_icon, res_path, LOADTEXT_TYPE)
    end

    -- 名称
    self.name_txt:setString(self.unit_cfg.name)
    local item_config = Config.ItemData.data_get_data(self.unit_cfg.bid)
    if item_config then
        --self.name_txt:setTextColor(BackPackConst.getBlackQualityColorC4B(item_config.quality))
        self.name_txt:enableOutline(BackPackConst.getBlackQualityColorC4B(item_config.quality),2)
    end

    -- 数量
    self:updateUnitNum()
end

-- 更新数量显示
function HomeworldMyUnitItem:updateUnitNum(  )
    if not self.data then return end

    local bag_num = self.data.bag_num
    local diff_num = self.data.have_num - bag_num
    if diff_num > 0 then
        self.num_txt:setString(_string_format(TI18N("数量:%d+%d"), bag_num, diff_num))
    else
        self.num_txt:setString(_string_format(TI18N("数量:%d"), self.data.have_num))
    end
    self.image_tips:setVisible(self.data.have_num == 0)
end

function HomeworldMyUnitItem:addCallBack( callback )
	self.click_callback = callback
end

function HomeworldMyUnitItem:suspendAllActions(  )

end

function HomeworldMyUnitItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end