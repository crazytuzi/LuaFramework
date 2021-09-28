--按品质出售

local BagYiJianLayer = class("BagYiJianLayer",UFCCSModelLayer)

--注意添加json文件
--[[
    _type  因为宝物最低品级是蓝色,所以去掉白色和绿色
]]
function BagYiJianLayer.create(_checkFunc01,_checkFunc02,_checkFunc03,_checkFunc04,_type)
	local layer = nil
    if _type == G_Goods.TYPE_TREASURE then
        layer = BagYiJianLayer.new("ui_layout/bag_BagPinJiChuShou02.json",Colors.modelColor,_type,_checkFunc01,_checkFunc02,_checkFunc03,_checkFunc04,isTreasure)
    elseif _type == G_Goods.TYPE_EQUIPMENT then
        layer = BagYiJianLayer.new("ui_layout/bag_BagPinJiChuShou03.json",Colors.modelColor,_type,_checkFunc01,_checkFunc02,_checkFunc03,_checkFunc04)
    elseif _type == G_Goods.TYPE_FRAGMENT then
        layer = BagYiJianLayer.new("ui_layout/bag_BagPinJiChuShou04.json",Colors.modelColor,_type,_checkFunc01,_checkFunc02,_checkFunc03,_checkFunc04)
    else
        layer = BagYiJianLayer.new("ui_layout/bag_BagPinJiChuShou.json",Colors.modelColor,_type,_checkFunc01,_checkFunc02,_checkFunc03,_checkFunc04)
    end
	layer:adapterLayer()
	return layer
end

--适配写在这里
function BagYiJianLayer:adapterLayer()
    self:adapterWidgetHeight("","","",0,0)
end

function BagYiJianLayer:ctor(json,color,type,_checkFunc01,_checkFunc02,_checkFunc03,_checkFunc04,...)
	self._checkFunc01 = _checkFunc01 
	self._checkFunc02 = _checkFunc02 
	self._checkFunc03 = _checkFunc03
    self._checkFunc04 = _checkFunc04 
    self._type = type

	self.super.ctor(self,...)
	self:_initWidgets()
    self:_createStroke()
	self:_initBtnEvent()
    self:showAtCenter(true)
end

function BagYiJianLayer:_initWidgets(star01Num,star02Num,star03Num,star04Num)
    self._checkBoxBai = self:getCheckBoxByName("CheckBox_bai")
    self._checkBoxLv = self:getCheckBoxByName("CheckBox_lv")
    self._checkBoxLan = self:getCheckBoxByName("CheckBox_lan")
    self._checkBoxZi = self:getCheckBoxByName("CheckBox_zi")
end

function BagYiJianLayer:_createStroke()
    local whiteLabel = self:getLabelByName("Label_whiteTag")
    if whiteLabel then
        whiteLabel:createStroke(Colors.strokeBrown,1)
    end
    local greenLabel = self:getLabelByName("Label_greenTag")
    if greenLabel then
        greenLabel:createStroke(Colors.strokeBrown,1)
    end
    local blueLabel = self:getLabelByName("Label_blueTag")
    if blueLabel then
        blueLabel:createStroke(Colors.strokeBrown,1)
    end
    local purpleLabel = self:getLabelByName("Label_purpleTag")
    if purpleLabel then
        purpleLabel:createStroke(Colors.strokeBrown, 1)
    end
end

function BagYiJianLayer:_initBtnEvent()
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_ok",function()
        self:animationToClose()
    end)

    self:registerBtnClickEvent("Button_bai",function()
        local state = self._checkBoxBai:getSelectedState()
        if self._checkFunc01 then 
            state = self._checkFunc01(not state) 
            self._checkBoxBai:setSelectedState(state)
        end
    end)

    self:registerBtnClickEvent("Button_lv",function()
        local state = self._checkBoxLv:getSelectedState()
        if self._checkFunc02 then 
            state = self._checkFunc02(not state) 
            self._checkBoxLv:setSelectedState(state)    
        end
    end)

    self:registerBtnClickEvent("Button_lan",function()
        local state = self._checkBoxLan:getSelectedState()
        if self._checkFunc03 then 
            state = self._checkFunc03(not state) 
            self._checkBoxLan:setSelectedState(state)
        end
    end)

    self:registerBtnClickEvent("Button_zi", function (  )
        local state = self._checkBoxZi:getSelectedState()
        if self._checkFunc04 then
            state = self._checkFunc04(not state)
            self._checkBoxZi:setSelectedState(state)
        end
    end)
end

function BagYiJianLayer:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end
return BagYiJianLayer
	
