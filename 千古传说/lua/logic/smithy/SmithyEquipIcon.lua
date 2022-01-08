--[[
******铁匠铺装备按钮*******
	-- by david.dai
	-- 2014/4/14
]]

local SmithyEquipIcon = class("SmithyEquipIcon", BaseLayer)

function SmithyEquipIcon:ctor(gmId)
    self.super.ctor(self,gmId)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.SmithyEquipIcon")

end

function SmithyEquipIcon:initUI(ui)
	self.super.initUI(self,ui)

	self.img_quality 	    = TFDirector:getChildByPath(ui, 'img_quality')
	self.img_icon 	        = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name')
    self.lbl_power          = TFDirector:getChildByPath(ui, 'lbl_power')
    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
	self.txt_intensify_lv 	= TFDirector:getChildByPath(ui, 'txt_intensify_lv')
    self.img_gem = {}
    self.img_gembg = {}
    for i=1,EquipmentManager.kGemMergeTargetNum do
        self.img_gem[i]            = TFDirector:getChildByPath(ui, 'img_gem'..i)
        self.img_gembg[i]          = TFDirector:getChildByPath(ui, 'img_gembg'..i)
    end
    self.bg                 = TFDirector:getChildByPath(ui, 'bg')

    --提示性控件
    self.img_improve        = TFDirector:getChildByPath(ui, 'img_improve')
    self.img_equiped        = TFDirector:getChildByPath(ui, 'img_equiped')
    self.txt_equiped_name   = TFDirector:getChildByPath(ui, 'txt_equiped_name')
    
    --星级，目前设定为屏蔽不显示
    self.panel_star         = TFDirector:getChildByPath(ui, 'panel_star')
    --self.panel_star:setVisible(false)
    self.img_star = {}
    for i=1,EquipmentManager.kMaxStarLevel do
        local str           = "img_star_"..i
	   self.img_star[i]     = TFDirector:getChildByPath(ui, str)
    end

    self.bg.logic = self

    --显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')

    --选择标识
    self.panel_select = TFDirector:getChildByPath(ui, 'panel_select')
    self.Image_select = TFDirector:getChildByPath(ui, 'Image_select')
end

function SmithyEquipIcon:removeUI()
    self.super.removeUI(self)
end

function SmithyEquipIcon:setLogic( layer )
    self.logic = layer
end

function SmithyEquipIcon:setSmritiLogic(layer)
    self.smritiLogic = layer
end

function SmithyEquipIcon:setEquipGmId( gmId )
    self.gmId = gmId
    self:refreshUI()

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    EquipmentManager:BindEffectOnEquip(self.img_quality, equip)
end

function SmithyEquipIcon:refreshUI()
    if not self.gmId then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return
    end

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return
    end

    self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

    self.img_icon:setTexture(equip:GetTextrue())
    self.img_quality:setTexture(GetColorIconByQuality(equip.quality))

    --local attr , num = equip:getBaseAttribute():getAttributeByIndex(1)
    --if attr then
    --    self.lbl_power:setText(AttributeTypeStr[attr])
    --    self.txt_power:setText("+"..num)
    --end

    self.txt_name:setText(equip.name)

    --字符D为图片+
    self.txt_power:setText(equip:getpower())

    self.txt_intensify_lv:setText("+"..equip.level)

    --装备于谁
    if equip.equip ~= nil and equip.equip ~= 0 then 
        local role = CardRoleManager:getRoleById(equip.equip)
        if role then
            self.txt_equiped_name:setVisible(true)
            self.img_equiped:setVisible(true)
            if role.isMainPlayer then
                print("fuck ...... " ,MainPlayer.verticalName)
                self.txt_equiped_name:setText(MainPlayer.verticalName)
            else
                self.txt_equiped_name:setText(role.name)
            end
            -- self.txt_equiped_name:setText(role.name)
        else
            self.img_equiped:setVisible(false)
        end
    else
        self.img_equiped:setVisible(false)
    end

    if equip.level < MainPlayer:getLevel() * 3 then
        self.img_improve:setVisible(false)
    else
        self.img_improve:setVisible(false)
    end

    local star = equip:getStar()
    for i=1,EquipmentManager.kMaxStarLevel do
        if i <= star then
            self.img_star[i]:setVisible(true)
        else
            self.img_star[i]:setVisible(false)
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
    self.bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconClickHandle))

end

function SmithyEquipIcon:setStarByFailPercent()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return
    end
    if equip.failPercent and equip.failPercent ~= 0 then
        return
    end
    local star = equip:getStar()
    -- print("star = ", star)
    -- print("self.img_star = ", self.img_star)
    if star > 0 then
        self.img_star[star]:setVisible(false)
    end
end

function SmithyEquipIcon.iconClickHandle(sender)
	local self = sender.logic

    local level = FunctionOpenConfigure:getOpenLevel(800)
    if level then
        local teamLev = MainPlayer:getLevel()
        if level > teamLev then
            --toastMessage("团队等级达到"..level.."级开启装备")
            toastMessage(stringUtils.format(localizable.smithy_EquipIcon_open,level))
            return
        end
    end
    if self.logic ~= nil then 
	    self.logic:openOperationLayer(self.gmId)
    end

    if self.smritiLogic ~= nil then
        --装备
        self.smritiLogic:setSelectId(self.gmId)
        print("smritiLogic")
    end
end

function SmithyEquipIcon:registerEvents()
	self.super.registerEvents(self)
end

function SmithyEquipIcon:removeEvents()
    self.bg:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)
end

function SmithyEquipIcon:setDuigouVisiable( enable )
    if enable then
        self.panel_select:setVisible(true)
        self.Image_select:setVisible(true)
    else
        self.panel_select:setVisible(false)
        self.Image_select:setVisible(false)
    end        
end


function SmithyEquipIcon:getDuigouVisiable()
    return self.panel_select:isVisible()
end

function SmithyEquipIcon:getEquipGmId()
    return self.gmId
end



return SmithyEquipIcon
