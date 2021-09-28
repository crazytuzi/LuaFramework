
local DressMainLayer = class("DressMainLayer",UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"

function DressMainLayer.create(...)
    return require("app.scenes.dress.DressMainLayer").new("ui_layout/dress_MainLayer.json", ...)
end

--[[
    self._checkType 选中类型
    self._checkType = 1
    self._checkType = 2 
]]
function DressMainLayer:ctor(json,checkType,...)
    self._checkType = checkType and checkType or 1
    self._dressChooseLayer = nil
    self._listPanel = self:getPanelByName("Panel_list")
    self._dressListLayer = nil
    self._currentLayer = nil
    self._bg = self:getImageViewByName("ImageView_bg")
    self.super.ctor(self, ...)
    self:_initDressListView()
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self:registerBtnClickEvent("Button_back", function()
         self:onBackKeyEvent()
    end)
    -- self:getCheckBoxByName("CheckBox_list3"):setVisible(false)

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        self._bgEffect = EffectNode.new("effect_tqt", function(event, frameIndex)
                    end)  
        self._bgEffect:setPosition(ccp(0,0))
        self:getImageViewByName("ImageView_bg"):addNode(self._bgEffect)
        self._bgEffect:play()
    end

    if not G_Me.dressData:getDressCanStrength() then
        self:getCheckBoxByName("CheckBox_list3"):setVisible(false)
        self:getCheckBoxByName("CheckBox_list4"):setVisible(false)
        self:getCheckBoxByName("CheckBox_list2"):setPositionXY(self:getCheckBoxByName("CheckBox_list3"):getPosition())
    end
end

function DressMainLayer:onBackKeyEvent( ... )
    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.hero.HeroScene")
    end

    return true
end

function DressMainLayer:onLayerEnter()

end

function DressMainLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end

function DressMainLayer:_initTabs()
    self._tabs:add("CheckBox_list", self:getPanelByName("Panel_content1"), "Label_shizhuang") --delay load
    self._tabs:add("CheckBox_list2", self:getPanelByName("Panel_content2"), "Label_tujian")  -- delay load
    self._tabs:add("CheckBox_list3", self:getPanelByName("Panel_content3"), "Label_qianghua")  -- delay load
    self._tabs:add("CheckBox_list4", self:getPanelByName("Panel_content4"), "Label_chongzhu")  -- delay load

    local length = #G_Me.dressData:getDressList()
    local funLevelConst = require("app.const.FunctionLevelConst")
    local StrUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.DRESSSTRENGTH)

    self:getWidgetByName("CheckBox_list3"):setTouchEnabled(length>0 and StrUnlock)
    self:getWidgetByName("CheckBox_list4"):setTouchEnabled(length>0 and StrUnlock)

    -- local str = "CheckBox_list"
    -- if self._checkType == 1 then
    --     str = "CheckBox_list"
    -- elseif self._checkType == 2 then
    --     str = "CheckBox_list2"
    -- elseif self._checkType == 3 then
    --     str = "CheckBox_list3"
    -- else
    --     str = "CheckBox_list4"
    -- end
    -- self._tabs:checked(str)
    self:check(self._checkType)
end

function DressMainLayer:check(_checkType)
    local str = "CheckBox_list"
    if _checkType == 1 then
        str = "CheckBox_list"
    elseif _checkType == 2 then
        str = "CheckBox_list2"
    elseif _checkType == 3 then
        str = "CheckBox_list3"
    else
        str = "CheckBox_list4"
    end
    self._tabs:checked(str)
end


function DressMainLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_list" then
        self:_resetDressChooseView()
    elseif btnName == "CheckBox_list2" then
        self:_resetDressBookView()
    elseif btnName == "CheckBox_list3" then
        self:_resetDressStrengthView()
    elseif btnName == "CheckBox_list4" then
        self:_resetDressRebirthView()
    end
end

function DressMainLayer:_clickCallBack(id)
    if self._currentLayer then
        self._currentLayer:choosedDress(id)
    else
        __Log("no layer")
    end
end

-- function DressMainLayer:refreshShow()
--     if self._currentLayer then
--         self._currentLayer:refreshShow()
--     else
--         __Log("no layer")
--     end
-- end

function DressMainLayer:_setListClick(state)
    if self._dressListLayer then
        self._dressListLayer:setClickable(state)
    end
end

function DressMainLayer:getChoosed()
    if self._dressListLayer then
        return self._dressListLayer:getChoosed()
    end
    return nil
end

function DressMainLayer:_updateList()
    if self._dressListLayer then
        self._dressListLayer:updateScrollView()
    else
        __Log("no dressList")
    end
end

function DressMainLayer:_initDressListView()
    if self._dressListLayer == nil then
        self._dressListLayer = require("app.scenes.dress.DressListLayer").create(self,self._clickCallBack)
        self._listPanel:addNode(self._dressListLayer)
    end 
end

function DressMainLayer:_resetDressChooseView()
    self._listPanel:setVisible(true)
    self._dressListLayer:setType(1)
    if self._dressChooseLayer == nil then
        self._dressChooseLayer = require("app.scenes.dress.DressChooseLayer").create(self)
        self:getPanelByName("Panel_content1"):addNode(self._dressChooseLayer)
        local size = self:getPanelByName("Panel_content1"):getContentSize()
        self._dressChooseLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._dressChooseLayer:adapterLayer()
    end 
    self._currentLayer = self._dressChooseLayer
    self._dressChooseLayer:reset()
end

function DressMainLayer:_resetDressBookView()
    self._listPanel:setVisible(false)
    if self._dressbookLayer == nil then
        self._dressbookLayer = require("app.scenes.dress.DressBookLayer").create()
        self:getPanelByName("Panel_content2"):addNode(self._dressbookLayer)
        local size = self:getPanelByName("Panel_content2"):getContentSize()
        self._dressbookLayer:adapterWithSize(CCSizeMake(size.width, size.height))
       self._dressbookLayer:adapterLayer()
    end 
    self._dressbookLayer:reset()
    self._currentLayer = self._dressbookLayer
end

function DressMainLayer:_resetDressStrengthView()
    self._listPanel:setVisible(true)
    self._dressListLayer:setType(2)
    if self._dressStrengthLayer == nil then
        self._dressStrengthLayer = require("app.scenes.dress.DressStrengthLayer").create(self)
        self:getPanelByName("Panel_content3"):addNode(self._dressStrengthLayer)
        local size = self:getPanelByName("Panel_content3"):getContentSize()
        self._dressStrengthLayer:adapterWithSize(CCSizeMake(size.width, size.height))
       self._dressStrengthLayer:adapterLayer()
    end 
    self._currentLayer = self._dressStrengthLayer
    self._dressStrengthLayer:reset()
end

function DressMainLayer:_resetDressRebirthView()
    self._listPanel:setVisible(true)
    self._dressListLayer:setType(2)
    if self._dressRebirthLayer == nil then
        self._dressRebirthLayer = require("app.scenes.dress.DressRebirthLayer").create(self)
        self:getPanelByName("Panel_content4"):addNode(self._dressRebirthLayer)
        local size = self:getPanelByName("Panel_content3"):getContentSize()
        self._dressRebirthLayer:adapterWithSize(CCSizeMake(size.width, size.height))
       self._dressRebirthLayer:adapterLayer()
    end 
    self._currentLayer = self._dressRebirthLayer
    self._dressRebirthLayer:reset()
end

function DressMainLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_content1", "Panel_checkbox", "", 14, 0)
    self:adapterWidgetHeight("Panel_content2", "Panel_checkbox", "", 14, 0)
    self:adapterWidgetHeight("Panel_content3", "Panel_checkbox", "", 14, 0)
    self:adapterWidgetHeight("Panel_content4", "Panel_checkbox", "", 14, 0)
    -- self:adapterWidgetHeight("Panel_bg", "Panel_checkbox", "", 0, 0)

    if self._dressChooseLayer ~= nil then
        self._dressChooseLayer:adapterLayer()
    end
    
    if self._handbookLayer ~= nil then
        self._handbookLayer:adapterLayer()
    end

    if self._dressStrengthLayer ~= nil then
        self._dressStrengthLayer:adapterLayer()
    end

    if self._dressRebirthLayer ~= nil then
        self._dressRebirthLayer:adapterLayer()
    end
    
    if self._tabs:getCurrentTabName() == "" then
       self:_initTabs() 
    end
    
end


function DressMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return DressMainLayer
