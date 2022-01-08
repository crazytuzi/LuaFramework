--[[
******角色信息层*******

    -- by Stephen.tao
    -- 2013/12/11
]]

local TestLayer = class("TestLayer", BaseLayer)

--CREATE_SCENE_FUN(TestLayer)
CREATE_PANEL_FUN(TestLayer)


function TestLayer:ctor(data)
    self.super.ctor(self,data)
    self.index = 0
    self:init("lua.TestLayer")

end


function TestLayer:initUI(ui)
	self.super.initUI(self,ui)
    ui:setPosition(ccp(-480,0))
 	self.btn_click    = TFDirector:getChildByPath(ui, 'btn_click')
    self.txt_num      = TFDirector:getChildByPath(ui, 'txt_num')
    self.txt_id       = TFDirector:getChildByPath(ui, 'txt_id')
    self.btn_unequip  = TFDirector:getChildByPath(ui, 'btn_unequip')
    self.btn_equip    = TFDirector:getChildByPath(ui, 'btn_equip')
    self.btn_lost     = TFDirector:getChildByPath(ui, 'btn_lost')
    self.btn_add      = TFDirector:getChildByPath(ui, 'btn_add')
    self.btn_addRole  = TFDirector:getChildByPath(ui, 'btn_addRole')
    self.btn_close    = TFDirector:getChildByPath(ui, 'btn_close')
    self.fightBtn     = TFDirector:getChildByPath(ui, 'fightBtn')
    self.dazaoBtn     = TFDirector:getChildByPath(ui, 'dazaoBtn')
    self.pataBtn         = TFDirector:getChildByPath(ui, 'pataBtn')
    self.bangpaiBtn         = TFDirector:getChildByPath(ui, 'bangpaiBtn')
        self.payBtn         = TFDirector:getChildByPath(ui, 'payBtn')
        self.settingBtn         = TFDirector:getChildByPath(ui, 'settingBtn')

    self.btn_click.logic = self
    self.btn_unequip.logic = self
    self.btn_equip.logic = self
    self.btn_lost.logic = self
    self.btn_add.logic = self
    self.btn_addRole.logic = self
    self.payBtn.logic = self
    self.settingBtn.logic = self

end

function TestLayer.OnBtnClick(sender)
    local index = sender.logic.index
    local id = sender.logic.txt_id:getText()
    local num = sender.logic.txt_num:getText()

    if index >= 0 and index < 3 then
        if id == nil or num == nil or id == "" or num == "" then
            return
        end
        local loginMsg =            
        {
            index,
            id,
            num,
        }
        TFDirector:send(c2s.TEST_PACKAGE, loginMsg )
    elseif index == 4 then
         if id == nil then
            return
        end
        local Msg =            
        {
           id,
        }
        TFDirector:send(c2s.TEST_GET_PARTNER, Msg )
    end
end

function TestLayer:OnBtnClickhandle()
    if self == self.logic.btn_add then
        self.logic.index = 0
    elseif self == self.logic.btn_lost then
        self.logic.index = 1
    elseif self == self.logic.btn_equip then
        self.logic.index = 2
    elseif self == self.logic.btn_unequip then
        self.logic.index = 3
    elseif self == self.logic.btn_addRole then
        self.logic.index = 4
    end
end

function TestLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_click:addMEListener(TFWIDGET_CLICK, self.OnBtnClick)

    self.btn_unequip:addMEListener(TFWIDGET_CLICK, self.OnBtnClickhandle)
    self.btn_equip:addMEListener(TFWIDGET_CLICK, self.OnBtnClickhandle)
    self.btn_lost:addMEListener(TFWIDGET_CLICK, self.OnBtnClickhandle)
    self.btn_add:addMEListener(TFWIDGET_CLICK, self.OnBtnClickhandle)   
    self.btn_addRole:addMEListener(TFWIDGET_CLICK, self.OnBtnClickhandle)   
    self.btn_close:addMEListener(TFWIDGET_CLICK, function ()
        AlertManager:close()
    end) 
    self.btn_close:setClickAreaLength(100);
    
     self.dazaoBtn:addMEListener(TFWIDGET_CLICK, function ()
        EquipmentBuildManager:showBuildHomeLayer()
    end)  
     self.pataBtn:addMEListener(TFWIDGET_CLICK, function ()
        ClimbManager:showHomeLayer()
    end)  

     self.fightBtn:addMEListener(TFWIDGET_CLICK, function ()
        FightManager:TestFun()
        FightManager:BeginFight()
    end)  
     
    self.bangpaiBtn:addMEListener(TFWIDGET_CLICK, function ()
        GangManager:intoGang()
    end)  
    self.payBtn:addMEListener(TFWIDGET_CLICK, function ()
        PayManager:showPayLayer()
    end)  
    self.settingBtn:addMEListener(TFWIDGET_CLICK, function ()
        SettingManager:showSettingLayer()
    end)  
end


return TestLayer
