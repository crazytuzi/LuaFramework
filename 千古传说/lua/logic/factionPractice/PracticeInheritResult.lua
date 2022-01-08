--[[
******修炼场-传承完成*******

	-- by quanhuan
	-- 2016/1/12
	
]]

local PracticeInheritResult = class("PracticeInheritResult",BaseLayer)

function PracticeInheritResult:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.PracticeInheritResult")
end

function PracticeInheritResult:initUI( ui )
    --A 传承给 B 
	self.super.initUI(self, ui)

    self.roleA = {}
    local roleNodeA = TFDirector:getChildByPath(ui, 'img_namebg1')
    self.roleA.btnHeadFrame = TFDirector:getChildByPath(roleNodeA, 'btn_icon')
    self.roleA.imgHead = TFDirector:getChildByPath(roleNodeA, 'img_touxiang')
    self.roleA.imgZhiYe = TFDirector:getChildByPath(roleNodeA, 'img_zhiye')
    self.roleA.txtName = TFDirector:getChildByPath(roleNodeA, 'txt_name')
    
    self.roleB = {}
    local roleNodeB = TFDirector:getChildByPath(ui, 'img_namebg2')
    self.roleB.btnHeadFrame = TFDirector:getChildByPath(roleNodeB, 'btn_icon')
    self.roleB.imgHead = TFDirector:getChildByPath(roleNodeB, 'img_touxiang')
    self.roleB.imgZhiYe = TFDirector:getChildByPath(roleNodeB, 'img_zhiye')
    self.roleB.txtName = TFDirector:getChildByPath(roleNodeB, 'txt_name')

    local imgLvNode = TFDirector:getChildByPath(ui, 'img_lv')
    self.txtLevel = TFDirector:getChildByPath(imgLvNode, 'lb')
    self.oldLevel = TFDirector:getChildByPath(imgLvNode, 'txt_old')
    self.newLevel = TFDirector:getChildByPath(imgLvNode, 'txt_new')
    
    local imgAttrNode = TFDirector:getChildByPath(ui, 'img_jn')
    self.txtAttr = TFDirector:getChildByPath(imgAttrNode, 'lb')
    self.oldAttrValue = TFDirector:getChildByPath(imgAttrNode, 'txt_old')
    self.newAttrValue = TFDirector:getChildByPath(imgAttrNode, 'txt_new')


	self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
	
	local resPath = "effect/ui/level_up_light.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("level_up_light_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(480+30,800))
    self:addChild(effect,98)
    effect:playByIndex(0, -1, -1, 1)
end


function PracticeInheritResult:removeUI()
	self.super.removeUI(self)
end

function PracticeInheritResult:onShow()
    self.super.onShow(self)

    if self.isFirstIn then
    	self.isFirstIn = false
    	self.ui:runAnimation("Action0",1)
    end
end

function PracticeInheritResult:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

	self.btn_close:addMEListener(TFWIDGET_CLICK, 
    audioClickfun(function() 
        AlertManager:close()
    end),1)
	self.ui:setTouchEnabled(true)
	self.ui:addMEListener(TFWIDGET_CLICK, 
    	audioClickfun(function()
        if self.skipEffect == nil then
            self.ui:updateToFrame("Action0", 100)
            self.skipEffect = true
        end
    end),1) 

    self.registerEventCallFlag = true

end

function PracticeInheritResult:removeEvents()

    self.super.removeEvents(self)
    if self.parentLayer then
        self.parentLayer.canTouch = true
    end
    self.registerEventCallFlag = nil  
end

function PracticeInheritResult:dispose()
	self.super.dispose(self)
end

function PracticeInheritResult:setData( msg,layer )
    self.parentLayer = layer
	local cardRoleA = CardRoleManager:getRoleByGmid(msg.roleA)
    local cardRoleB = CardRoleManager:getRoleByGmid(msg.roleB)
    print('msg = ',msg)
    if cardRoleA == nil then  
        print('cannot find cardRole gmIdA = ',msg.roleA)
        return
    end
    if cardRoleB == nil then  
        print('cannot find cardRole gmIdB = ',msg.roleB)
        return
    end
    local attributeType = msg.inheritanceType or 1
    local oldLevel = msg.levelB or 0
    local newLevel = msg.levelA or 1


    self.roleA.btnHeadFrame:setTextureNormal(GetColorRoadIconByQuality(cardRoleA.quality))
    self.roleA.imgHead:setTexture(cardRoleA:getHeadPath())
    self.roleA.imgZhiYe:setTexture("ui_new/fight/zhiye_".. cardRoleA.outline ..".png")
    self.roleA.txtName:setText(cardRoleA.name)
    
    self.roleB.btnHeadFrame:setTextureNormal(GetColorRoadIconByQuality(cardRoleB.quality))
    self.roleB.imgHead:setTexture(cardRoleB:getHeadPath())
    self.roleB.imgZhiYe:setTexture("ui_new/fight/zhiye_".. cardRoleB.outline ..".png")
    self.roleB.txtName:setText(cardRoleB.name)

    local attrDataNew = GuildPracticeData:getPracticeInfoByTypeAndLevel(attributeType, newLevel,cardRoleB.outline)
    local attrValueNew = attrDataNew:getAttributeValue() or {}
    local attrDataOld = GuildPracticeData:getPracticeInfoByTypeAndLevel(attributeType, oldLevel,cardRoleB.outline)
    local attrValueOld = {}
    if attrDataOld then
        attrValueOld = attrDataOld:getAttributeValue() or {}
    end
    local oldValue = attrValueOld.value or 0
    local newValue = attrValueNew.value or 0
    newValue = math.abs(tonumber(newValue))
    oldValue = math.abs(tonumber(oldValue))
    if attrValueNew.percent then
        newValue = math.floor(newValue/100)
        newValue = newValue .. '%'

        oldValue = math.floor(oldValue/100)
        oldValue = oldValue .. '%'
    end


    --self.txtLevel:setText(attrDataNew.title..'等级')
    self.txtLevel:setText(stringUtils.format(localizable.practiceInResult_level,attrDataNew.title))
    self.oldLevel:setText(oldLevel)
    self.newLevel:setText(newLevel)

    --self.txtAttr:setText(attrDataNew.title..'属性')
    self.txtAttr:setText(stringUtils.format(localizable.practiceInResult_attr,attrDataNew.title))
    self.oldAttrValue:setText(oldValue)
    self.newAttrValue:setText(newValue)

	self.isFirstIn = true
end


return PracticeInheritResult
