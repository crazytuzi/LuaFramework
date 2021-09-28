local FunctionLevelConst = require "app.const.FunctionLevelConst"
local BagConst = require("app.const.BagConst")
local BianShenSettingLayer = class("BianShenSettingLayer", UFCCSModelLayer)

function BianShenSettingLayer.create(parent,...)
	return BianShenSettingLayer.new("ui_layout/bianshen_SettingLayer.json", Colors.modelColor,parent, ...)
end

function BianShenSettingLayer:ctor(json, param,parent, ...)
    self._parent = parent
	self._timer = nil 
	self._checkBoxOpen = self:getCheckBoxByName("CheckBox_show")
	self.super.ctor(self, json, param, ...)
	self:_init()

end

function BianShenSettingLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
end

function BianShenSettingLayer:onLayerLoad()
    self:registerKeypadEvent(true)
end

function BianShenSettingLayer:onBackKeyEvent()
    self:_onCloseWindow()
    return true
end

function BianShenSettingLayer:_init()
	
	self._checkBoxOpen:setSelectedState(not G_Me.userData:getClothOpen())
	self:registerBtnClickEvent("CheckBox_show", function (  )
		self:_onCheckboxClick()
    end)

	self:registerBtnClickEvent("Button_close1", handler(self, self._onCloseWindow))
    self:registerBtnClickEvent("Button_close2", handler(self, self._onCloseWindow))

    -- 处理倒计时问题
    if self.updateTimeHandler then 
        self:updateTimeHandler()
    end
    if not self._timer then 
        self._timer = GlobalFunc.addTimer(1, function()  
            if self.updateTimeHandler then 
                self:updateTimeHandler()
            end 
        end)
    end 
end

function BianShenSettingLayer:updateTimeHandler( )
    self:getLabelByName("Label_time"):setText(
        G_Me.userData:getDiffTimeString(G_Me.userData:getClothTime() ))
    if G_Me.userData:getClothTime() <= 0 then 
        self:_onCloseWindow()
    end 
end

function BianShenSettingLayer:_onCheckboxClick()
    local state = self._checkBoxOpen:getSelectedState()
    self._checkBoxOpen:setSelectedState(state)
    G_HandlersManager.dressHandler:sendClothSwitch(state)
end

function BianShenSettingLayer:_onCloseWindow()
    if self._parent then 
        self._parent:_updatePageWithIndex(0)
        self._parent:showWidgetByName("Button_bianshen",G_Me.userData:getClothTime() > 0)
        local heroImage = self._parent:getImageViewByName("ImageView_MainHero")
        if heroImage then 
            heroImage:loadTexture(G_Path.getKnightIcon(G_Me.dressData:getDressedPic()), UI_TEX_TYPE_LOCAL)
        end
    end 
    
	if self._timer then
        GlobalFunc.removeTimer(self._timer)
    end
	self:animationToClose()
end

return BianShenSettingLayer