--[[
******修炼场-修炼完成*******

	-- by quanhuan
	-- 2016/1/8
	
]]

local PracticeResult = class("PracticeResult",BaseLayer)

function PracticeResult:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.PracticeResult")
end

function PracticeResult:initUI( ui )

	self.super.initUI(self, ui)

	self.img_xiaoguo = TFDirector:getChildByPath(ui, 'img_xiaoguo')
	self.img_head = TFDirector:getChildByPath(ui, 'img_touxiang')
	self.headFrame = TFDirector:getChildByPath(ui, 'btn_icon')
	self.headFrame:setTouchEnabled(false)
	self.img_zhiye = TFDirector:getChildByPath(ui, 'img_zhiye')
	self.txt_name = TFDirector:getChildByPath(ui, 'txt_name')
	local skillNameNode = TFDirector:getChildByPath(ui, 'img_lv')
	self.levelName = TFDirector:getChildByPath(skillNameNode, 'lb')
	self.levelOld = TFDirector:getChildByPath(skillNameNode, 'txt_old')
	self.levelNew = TFDirector:getChildByPath(skillNameNode, 'txt_new')

	local skillPowerNode = TFDirector:getChildByPath(ui, 'img_jn')
	self.powerName = TFDirector:getChildByPath(skillPowerNode, 'lb')
	self.powerOld = TFDirector:getChildByPath(skillPowerNode, 'txt_old')
	self.powerNew = TFDirector:getChildByPath(skillPowerNode, 'txt_new')

	self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
	
	local resPath = "effect/ui/level_up_light.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("level_up_light_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(480+30,800))
    self:addChild(effect,98)
    effect:playByIndex(0, -1, -1, 1)
end


function PracticeResult:removeUI()
	self.super.removeUI(self)
end

function PracticeResult:onShow()
    self.super.onShow(self)

    if self.isFirstIn then
    	self.isFirstIn = false
    	self.ui:runAnimation("Action0",1)
    end
end

function PracticeResult:registerEvents()

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

function PracticeResult:removeEvents()

    self.super.removeEvents(self)

    self.registerEventCallFlag = nil  
end

function PracticeResult:dispose()
	self.super.dispose(self)
end

function PracticeResult:setData( attributeType,gmId )
	local cardRole = CardRoleManager:getRoleByGmid(gmId)
	local currLevel = 0
    if cardRole then  
        currLevel = cardRole:getFactionPracticeLevelByType(attributeType)
        -- currLevel = currLevel + 1 
    else
    	print('cannot find cardRole gmId = ',gmId)
    	return
    end
    print("currLevel = ", currLevel)
    local oldData = GuildPracticeData:getPracticeInfoByTypeAndLevel(attributeType, currLevel-1,cardRole.outline)
    local newData = GuildPracticeData:getPracticeInfoByTypeAndLevel(attributeType, currLevel,cardRole.outline)

    self.img_xiaoguo:setTexture('ui_new/faction/xiulian/'..newData.title_icon..'.png')
	self.img_head:setTexture(cardRole:getHeadPath())
	self.headFrame:setVisible(true)
    self.headFrame:setTextureNormal(GetColorRoadIconByQuality(cardRole.quality))
    self.img_zhiye:setTexture("ui_new/fight/zhiye_".. cardRole.outline ..".png")

	self.txt_name:setText(cardRole.name)	
	--self.levelName:setText('修炼等级')
    self.levelName:setText(localizable.practiceResult_level)
	self.levelOld:setText(currLevel-1)
	self.levelNew:setText(newData.level)

	local powerOld = {}
	if oldData then
		powerOld = oldData:getAttributeValue()
	end
	local powerNew = newData:getAttributeValue()
	local currValue = 0
    local nextValue = 0
    if powerNew.percent then
    	local oldvalue = powerOld.value or 0
        currValue = math.floor(oldvalue/100)
        currValue = math.abs(currValue)
        currValue = currValue .. '%'
        nextValue = math.floor(powerNew.value/100)
        nextValue = math.abs(nextValue)
        nextValue = nextValue .. '%'
    else
    	local oldvalue = powerOld.value or 0
        currValue = oldvalue
        currValue = math.abs(currValue)
        nextValue = powerNew.value
        nextValue = math.abs(nextValue)
    end
	self.powerName:setText(newData.title)
	self.powerOld:setText(currValue)
	self.powerNew:setText(nextValue)

	self.isFirstIn = true
end


return PracticeResult
