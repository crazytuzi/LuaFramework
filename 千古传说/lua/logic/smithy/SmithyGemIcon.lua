--[[
******装备精练icon*******

	-- by Stephen.tao
	-- 2014/4/14
]]

local SmithyGemIcon = class("SmithyGemIcon", BaseLayer)

function SmithyGemIcon:ctor(type)
    self.super.ctor(self)
    self.type = type
    self:init("lua.uiconfig_mango_new.smithy.SmithySetgemIcon")
end

function SmithyGemIcon:initUI(ui)
	self.super.initUI(self,ui)

    self.img_bg    = TFDirector:getChildByPath(ui, 'img_bg')
    self.img_quality    = TFDirector:getChildByPath(ui, 'img_quality')
	self.txt_name   	= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_icon 	    = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_num        = TFDirector:getChildByPath(ui, 'txt_gem_num')
    self.txt_attr       = TFDirector:getChildByPath(ui, 'txt_attr')
    self.txt_attr_val   = TFDirector:getChildByPath(ui, 'txt_num')

    self.img_selected_fg   = TFDirector:getChildByPath(ui, 'img_selected_fg')

    self.img_bg.logic = self

    --显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
end

function SmithyGemIcon:removeUI()
    self.super.removeUI(self)
end

function SmithyGemIcon:setLogic( layer )
    self.logic = layer
end

function SmithyGemIcon:setGemid( id )
    self.id = id
    self:refreshUI()
end

function SmithyGemIcon:refreshUI()
    if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        if self.type and self.type == 1 then
            CommonManager:removeRedPoint(self)
        end
        return false
    end

    local gem = BagManager:getItemById(self.id)
    if gem == nil  then
        print("gem not found : ",self.id)
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        if self.type and self.type == 1 then
            CommonManager:removeRedPoint(self)
        end
        return false
    end

    self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

    self.txt_name:setText(gem.name)
    self.txt_num:setText(gem.num)
    self.img_icon:setTexture(gem:GetPath())
    self.img_quality:setTexture(GetColorIconByQuality(gem.quality))
    local gemAttr = GemData:objectByID(gem.id)
    local attributekind , attributenum = gemAttr:getAttribute()
    self.txt_attr:setText(AttributeTypeStr[attributekind])
    self.txt_attr_val:setText("+" .. attributenum)

    if self.logic and self.logic.selectId and self.logic.selectId == self.id then
        self:setSelected(true)
    else
        self:setSelected(false)
    end

    if self.type and self.type == 1 then
        local visiable = EquipmentManager:isGemEnough(self.id)
        CommonManager:updateWidgetState(self,EquipmentManager.Function_Gem_Merge, visiable,ccp(self:getSize().width/2,self:getSize().height/2))
    end
    --self.img_bg:addMEListener(TFWIDGET_CLICK, self.iconClickHandle)

end

--[[
    设置是否显示选中图片
]]
function SmithyGemIcon:setSelected(selected)
    self.img_selected_fg:setVisible(selected)
end

function SmithyGemIcon.iconClickHandle(sender)
    print("SmithyGemIcon.iconClickHandle : ")
	local self = sender.logic
	self.logic:iconBtnClick(self)
end

function SmithyGemIcon:registerEvents()
    print("SmithyGemIcon.registerEvents : ")
	self.super.registerEvents(self)

    self.img_bg:addMEListener(TFWIDGET_CLICK, SmithyGemIcon.iconClickHandle)

    self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            local gem = BagManager:getItemById(self.id)
            self.txt_num:setText(gem.num)
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
end

function SmithyGemIcon:removeEvents()
    print("SmithyGemIcon.removeEvents : ")
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    --self.img_bg:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)
end

function SmithyGemIcon:getEffectPosition()
    local _parent = self.img_icon:getParent()
    local position = _parent:convertToWorldSpaceAR(self.img_icon:getPosition())
    --position.x = position.x - rootPos.x
    --position.y = position.y - rootPos.y
    return position
end
return SmithyGemIcon
