-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      聊天界面装备展示
-- <br/>Create: 2018-05-22
-- --------------------------------------------------------------------

RefEquipUI = RefEquipUI or BaseClass()

local partner_model = HeroController:getInstance():getModel()
local table_insert = table.insert
local controller = RefController:getInstance()

function RefEquipUI:__init(parent)
    self.parent = parent
    self:createRootWnd()
end

function RefEquipUI:createRootWnd()
    self.size = self.parent:getContentSize()

	local setting = {
        item_class = RefEquipUIItem,
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

function RefEquipUI:setVisible(bool)
    if not tolua.isnull(self.scroll_view) then
        self.scroll_view:setVisible(bool)
    end
end

function RefEquipUI:setData()
    local partner_list = partner_model:getHeroList()

    local target_list = {}
    for k,vo in pairs(partner_list) do
        for _,v in pairs(vo.eqm_list) do -- 身上装备
            table_insert(target_list, {id=vo.partner_id, item=v})
        end
        for _,v in pairs(vo.artifact_list) do   -- 身上神器
            table_insert(target_list, {id=vo.partner_id, item=v})
        end
    end
    self.scroll_view:setData(target_list, call_back)
end

function RefEquipUI:__delete()
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
RefEquipUIItem = class("RefEquipUIItem", function()
	return ccui.Layout:create()
end)

function RefEquipUIItem:ctor()
    self.item_name = ""

    self.size = cc.size(96,96)
    self:setContentSize(self.size)
    self:setAnchorPoint(0.5,0.5)

    self.backpack_item = BackPackItem.new(false, true, false, 0.8)
    self.backpack_item:setPosition(48, 48)
    self:addChild(self.backpack_item)
    
    self:registerEvent()
end

function RefEquipUIItem:registerEvent()
    self.backpack_item:addCallBack(function() 
        if self.data and self.data.item and self.data.id then
            if BackPackConst.checkIsEquip(self.item_data.config.type) then 
                HeroController:getInstance():openEquipTips(true, self.item_data, PartnerConst.EqmTips.other)
                controller:send10535(4, self.data.item.id, self.data.id, 2)
            elseif BackPackConst.checkIsArtifact(self.item_data.config.type) then
                HeroController:getInstance():openArtifactTipsWindow(true, self.item_data, PartnerConst.ArtifactTips.normal)
                controller:send10535(2, self.data.item.id, self.data.id, 2)
            end
        end
    end)
end

function RefEquipUIItem:setData(data)
    self.data = data
    if data then
        self.item_data = data.item
        self.backpack_item:setData(self.item_data)
    end
end

function RefEquipUIItem:suspendAllActions()
end

function RefEquipUIItem:DeleteMe()
    if self.backpack_item then
        self.backpack_item:DeleteMe()
    end
    self.backpack_item = nil
	self:removeAllChildren()
	self:removeFromParent()
end 