
local QualityUpResultLayer = class("QualityUpResultLayer", BaseLayer)

function QualityUpResultLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.climb.ShengpinResult")

end

function QualityUpResultLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.panel_info = TFDirector:getChildByPath(ui,"panel_info")
	self.img_quality = TFDirector:getChildByPath(ui,"img_quality")
	self.img_icon = TFDirector:getChildByPath(ui,"img_icon")
	self.img_quality:setZOrder(2)
end

function QualityUpResultLayer:removeUI()
	self.super.removeUI(self)
end

function QualityUpResultLayer:dispose()

end

function QualityUpResultLayer:onShow()
	-- self:refreshUI()
end

function QualityUpResultLayer:playEffect(cardRole)
	self.cardRole = cardRole

	self.img_quality:setTexture(GetColorIconByQuality(self.cardRole.quality - 1))
	self.img_icon:setTexture(self.cardRole:getIconPath());
	local change_effect = self:addEffect("qualityUp_icon_change",10)
	change_effect:playByIndex(0, -1, -1, 0)
	local temp = 0
	change_effect:addMEListener(TFARMATURE_UPDATE,function()
        temp = temp + 1
        if temp == 32 then
			self.img_quality:setTexture(GetColorIconByQuality(self.cardRole.quality))
			local buttom_effect = self:addEffect("qualityUp_icon_buttom",1)
			local up_effect = self:addEffect("qualityUp_icon_up",10)
			buttom_effect:playByIndex(0, -1, -1, 1)
			up_effect:playByIndex(0, -1, -1, 1)
        end
    end)
end

function QualityUpResultLayer:addEffect( effect_name ,zorder)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/"..effect_name..".xml")
    local effect = TFArmature:create(effect_name.."_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setZOrder(zorder)
    effect:setPosition(ccp(70,70))
    self.panel_info:addChild(effect )
    return effect
end

function QualityUpResultLayer:registerEvents()
	self.super.registerEvents(self)

end

function QualityUpResultLayer:removeEvents()
    self.super.removeEvents(self)
  	self.btn_starup:removeMEListener(TFWIDGET_CLICK)
    self.RoleStarUpResultCallBack = nil
end


return QualityUpResultLayer