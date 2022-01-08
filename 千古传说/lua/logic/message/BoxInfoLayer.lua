--[[
******礼包信息层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local BoxInfoLayer = class("BoxInfoLayer", BaseLayer)

--CREATE_SCENE_FUN(BoxInfoLayer)
CREATE_PANEL_FUN(BoxInfoLayer)


function BoxInfoLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.message.BoxInfoLayer")
end


function BoxInfoLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_open         = TFDirector:getChildByPath(ui, 'btn_open')
    self.txt_name         = TFDirector:getChildByPath(ui, 'txt_name')
    self.img_quality      = TFDirector:getChildByPath(ui, 'img_quality')
    self.img_icon         = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_info         = TFDirector:getChildByPath(ui, 'txt_info')
    self.bg_item          = {}
    self.txt_itemname     = {}
    self.txt_num          = {}

    for i=1,4 do
        local str = "bg_item_"..i
        self.bg_item[i]         = TFDirector:getChildByPath(ui, str)
        str = "txt_name_"..i
        self.txt_itemname[i]    = TFDirector:getChildByPath(ui, str)
        str = "txt_num_"..i
        self.txt_num[i]         = TFDirector:getChildByPath(ui, str)
    end

    self.btn_open.logic       = self
end

function BoxInfoLayer:removeUI()
	self.super.removeUI(self)
    self.itemid = nil
    self.btn_open         = nil
    self.txt_name         = nil
    self.img_quality      = nil
    self.img_icon         = nil
    self.txt_info         = nil
    self.bg_item          = nil
    self.txt_itemname     = nil
    self.txt_num          = nil
end

function BoxInfoLayer:setItemid( itemid )
    self.itemId = itemid
    local baseItem = ItemData:objectByID(self.itemId)

    self.img_icon:setTexture(baseItem:GetPath())
    self.img_quality:setTexture(GetColorIconByQuality(baseItem.quality))

    self.txt_name:setText(baseItem.name)
    -- self.txt_name:setColor(GetColorByQuality(baseItem.quality))
    self.txt_info:setText(baseItem.details)
--包含物品处理a

end

function BoxInfoLayer.onOpenBtnClickHandle(sender)

    AlertManager:close(AlertManager.TWEEN_1);
end


function BoxInfoLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_open:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOpenBtnClickHandle),1)
end


return BoxInfoLayer
