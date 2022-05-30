-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      聊天那边的用于道具展示的面板
-- <br/>Create: 2018-05-22
-- --------------------------------------------------------------------

RefItemUI = RefItemUI or BaseClass()

local backpack_model = BackpackController:getInstance():getModel()
local controller = RefController:getInstance()

function RefItemUI:__init(parent)
    self.parent = parent
    self:createRootWnd()
end

function RefItemUI:createRootWnd()
    self.size = self.parent:getContentSize()

	local setting = {
        item_class = RefItemUIItem,
        start_x = 4,
        space_x = 14,
        start_y = 0,
        space_y = 10,
        item_width = 96,
        item_height = 96,
        row = 5,
        col = 5,
        once_num = 1,
        need_dynamic = true
	}
	self.scroll_view = CommonScrollViewLayout.new(self.parent, cc.p(8,8), nil, nil, cc.size(self.size.width-16, self.size.height-16), setting)

    -- 设置数据
    self:setData()
end

function RefItemUI:setVisible(bool)
    if not tolua.isnull(self.scroll_view) then
        self.scroll_view:setVisible(bool)
    end
end

function RefItemUI:setData()
    local target_list = backpack_model:getItemListForShare()

    self.scroll_view:setData(target_list, call_back)
end

function RefItemUI:__delete()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      表情单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
RefItemUIItem = class("RefItemUIItem", function()
	return ccui.Layout:create()
end)

function RefItemUIItem:ctor()
    self.item_name = ""

    self.size = cc.size(96,96)
    self:setContentSize(self.size)
    self:setAnchorPoint(0.5,0.5)

    self.backpack_item = BackPackItem.new(false, true, false, 0.8)
    self.backpack_item:setPosition(48, 48)
    self:addChild(self.backpack_item)
    
    self:registerEvent()
end

function RefItemUIItem:registerEvent()
    self.backpack_item:addCallBack(function() 
        if self.data and self.data.config then
            if BackPackConst.checkIsEquip(self.data.config.type) then                                                          -- 装备
                HeroController:getInstance():openEquipTips(true, self.data, PartnerConst.EqmTips.other)
            elseif BackPackConst.checkIsArtifact(self.data.config.type) then                                                   -- 神器
                HeroController:getInstance():openArtifactTipsWindow(true, self.data, PartnerConst.ArtifactTips.normal)
            else
                TipsManager:getInstance():showGoodsTips(self.data) 
            end
            controller:send10535(1, self.data.id, 0, 1)
        end
    end)
end

function RefItemUIItem:setData(data)
    self.data = data
    if data then
        self.backpack_item:setData(data)
    end
end

function RefItemUIItem:suspendAllActions()
end

function RefItemUIItem:DeleteMe()
    if self.backpack_item then
        self.backpack_item:DeleteMe()
    end
    self.backpack_item = nil
	self:removeAllChildren()
	self:removeFromParent()
end 