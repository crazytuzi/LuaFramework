--[[
******装备精练icon*******

	-- by Stephen.tao
	-- 2014/4/14
]]

local EquipmentStarUpIcon = class("EquipmentStarUpIcon", BaseLayer)

function EquipmentStarUpIcon:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.smithy.EquipmentStarUpIcon")
end

function EquipmentStarUpIcon:initUI(ui)
	self.super.initUI(self,ui)

	self.img_quality 	= TFDirector:getChildByPath(ui, 'img_quality')
	self.img_icon 	    = TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_level 	    = TFDirector:getChildByPath(ui, 'txt_level')
    self.img_choice     = TFDirector:getChildByPath(ui, 'Image_choose')
    self.img_gem = {}
    self.img_gembg = {}
    for i=1,EquipmentManager.kGemMergeTargetNum do
        self.img_gem[i]            = TFDirector:getChildByPath(ui, 'img_gem'..i)
        self.img_gembg[i]          = TFDirector:getChildByPath(ui, 'img_gembg'..i)
    end
    self.img_icon.logic = self
    self.image_star = {}
    for i=1,5 do
        local str = "Image_star"..i
        self.image_star[i]       = TFDirector:getChildByPath(ui, str)
    end

    --显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')

    self.btn_Del                = TFDirector:getChildByPath(ui, 'btn_chongzhi')
    self.txt_num                = TFDirector:getChildByPath(ui, 'txt_num')
    self.txt_plus                = TFDirector:getChildByPath(ui, 'txt_plus')

end

function EquipmentStarUpIcon:removeUI()
    self.super.removeUI(self)

    self.img_quality    = nil
    self.img_icon       = nil
    self.txt_level      = nil
    self.image_star     = nil
    self.img_choice     = nil
    self.gmid           = nil
    self.toolId         = nil
end

function EquipmentStarUpIcon:refreshUI()
    if not self.gmid then
        print("is mepty display .",self.gmid)
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return false
    end

    self.txt_num:setVisible(false)
    self.btn_Del:setVisible(false)

    local equip = EquipmentManager:getEquipByGmid(self.gmid)
    if equip == nil  then
        print("equipment not found .",self.gmid)
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        self:drawTool()

        return false
    end


    self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)
    self.txt_level:setVisible(true)
    self.img_icon:setTexture(equip:GetTextrue())
    self.img_quality:setTexture(GetColorIconByQuality(equip.quality))

    EquipmentManager:BindEffectOnEquip(self.img_quality, equip)
    
    --self.txt_level:setText(equip.level.."级")
    self.txt_level:setText(stringUtils.format(localizable.common_LV ,equip.level))
    for i=1,5 do
        if i <= equip:getStar() then
            self.image_star[i]:setVisible(true)
        else
            self.image_star[i]:setVisible(false)
        end
    end
    for i=1,EquipmentManager.kGemMergeTargetNum do
        if equip:getGemPos(i) then
            self.img_gembg[i]:setVisible(true)
            local item = ItemData:objectByID(equip:getGemPos(i))
            if item then
                self.img_gem[i]:setTexture(item:GetPath())
            end
        else
            self.img_gembg[i]:setVisible(false)
        end
    end
    -- if self.logic.dogfood[self.gmid] then
    if self.logic.dogfood[self.gmid] then
        self.img_choice:setVisible(true)
    else
        self.img_choice:setVisible(false)
    end

    self.txt_plus:setVisible(true)
    --置灰
    self:updateIconState()
    
    self.img_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconClickHandle),1)
end

--置灰
function EquipmentStarUpIcon:updateIconState()
    if self.logic.dogfood[self.gmid] then
        self.panel_info:setGrayEnabled(false)
        self.img_icon:setTouchEnabled(true)
        return
    end
    local totalPercent = self.logic:getTotalPercent()
    if totalPercent >= 100 then
        self.panel_info:setGrayEnabled(true)
        self.img_icon:setTouchEnabled(false)
    else
        self.panel_info:setGrayEnabled(false)
        self.img_icon:setTouchEnabled(true)
    end
end

function EquipmentStarUpIcon:setLogic( layer )
    self.logic = layer
end

function EquipmentStarUpIcon:setEquipGmid( gmid )
    self.gmid = gmid
    self:refreshUI()
end

function EquipmentStarUpIcon:setChoice( b )
    self:updateIconState()
end

function EquipmentStarUpIcon.IconClickHandle(sender)
	local self = sender.logic

    if self.gmid >= 1048576 then
	   self.logic:IconBtnClick_Equip(self.gmid,self)
    else
       self.logic:IconBtnClick_Tool(self.gmid,self,true)
    end
end

function EquipmentStarUpIcon.OnclikDelButton(sender)
    local self = sender.logic

    self.logic:IconBtnClick_Tool(self.gmid, self, false)
end

function EquipmentStarUpIcon:registerEvents()
	self.super.registerEvents(self)

end

function EquipmentStarUpIcon:drawTool()

    local equip = BagManager:getItemById(self.gmid)

    if equip == nil then
        return
    end

    local totalNum = equip.num


    self.btn_Del.logic = self

    self.txt_num:setVisible(true)

    self.panel_empty:setVisible(false)
    self.txt_level:setVisible(false)
    self.panel_info:setVisible(true)
    
    self.img_icon:setTexture(equip:GetTextrue())
    self.img_quality:setTexture(GetColorIconByQuality(equip.quality))
    --self.txt_level:setText(equip.level.."级")
    self.txt_level:setText(stringUtils.format(localizable.common_LV, equip.level))
    for i=1,5 do
        self.image_star[i]:setVisible(false)
    end

    for i=1,EquipmentManager.kGemMergeTargetNum do
        self.img_gembg[i]:setVisible(false)
    end

    self.img_choice:setVisible(false)
    if self.logic.dogfood[self.gmid] then
        self.btn_Del:setVisible(true)
        self.txt_num:setText(self.logic.dogfood[self.gmid] .. "/" .. totalNum)
    else
        self.btn_Del:setVisible(false)
        self.txt_num:setText(totalNum)
    end

    self.txt_plus:setVisible(false)

    --置灰
    self:updateIconState()
    
    self.img_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconClickHandle),1)
    self.btn_Del:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikDelButton),1)
end

return EquipmentStarUpIcon
