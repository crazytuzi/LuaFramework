--[[
    精要分解界面的精要icon
]]

local JingyaoIcon = class("JingyaoIcon", BaseLayer)

function JingyaoIcon:ctor(id)
    self.super.ctor(self, id)
    self.id = id
    self.num = 0
    self.maxNum = 0
    self:init("lua.uiconfig_mango_new.tianshu.JingYaoIcon")
end

function JingyaoIcon:initUI(ui)
	self.super.initUI(self, ui)

    --空白panel
    self.panel_empty = TFDirector:getChildByPath(ui, "panel_empty")
    --info panel
    self.panel_info = TFDirector:getChildByPath(ui, "panel_info")

    --点击按钮
    self.btn_icon = TFDirector:getChildByPath(ui, "btn_icon")
    self.btn_icon.logic = self
    --品质图标
	self.img_quality = TFDirector:getChildByPath(ui, 'img_quality')
    --精要icon图标
	self.img_icon  = TFDirector:getChildByPath(ui, 'img_icon')
    --名字
    self.txt_name = TFDirector:getChildByPath(ui, 'txt_name')
    --数量
    self.txt_num = TFDirector:getChildByPath(ui, "txt_num")

    --重置按钮
    self.btn_chongzhi = TFDirector:getChildByPath(ui, "btn_chongzhi")
    self.btn_chongzhi.logic = self

    self.txt_num1 = TFDirector:getChildByPath(ui, "txt_num1")
    self.txt_num2 = TFDirector:getChildByPath(ui, "txt_num2")

    self.img_selected = TFDirector:getChildByPath(ui, "img_xuanzhong")
    self.btn_hecheng = TFDirector:getChildByPath(ui, "btn_hec")
end

function JingyaoIcon:removeUI()
    self.super.removeUI(self)

    self.id = nil
    self.num = 0
    self.maxNum = 0

    if self.timerId then
        TFDirector:removeTimer(self.timerId)
        self.timerId = nil
    end
end

function JingyaoIcon:setLogic( layer )
    self.logic = layer
end

function JingyaoIcon:setId(id)
    self.id = id
    self:refreshUI()
end

function JingyaoIcon:refreshUI()
    self.img_selected:setVisible(false)
    self.btn_hecheng:setVisible(false)

    if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return
    end

    self.txt_num:setVisible(true)
    self.txt_num1:setVisible(false)
    self.txt_num2:setVisible(false)

    self.item = BagManager:getItemById(self.id)
    if self.item == nil  then
        print("jingyao item not found : ", self.id)
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return
    end

    self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

    self.img_icon:setTexture(self.item:GetTextrue())
    self.img_quality:setTexture(GetColorIconByQuality(self.item.quality))
    self.txt_name:setText(self.item.name)

    if self.item.num and self.item.num ~= 0 then
        self.txt_num:setVisible(true)
        self.txt_num:setText(self.item.num)
        self.maxNum = self.item.num
    else
        self.txt_num:setVisible(false)       
    end
    self.btn_chongzhi:setVisible(false)
    --self:changeNum(0)
    --[[
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
    ]]
end

function JingyaoIcon:changeNum(num)
    if num <= 0 then
        num = 0
    end
    self.num = num
    if num == 0 then
        self.txt_num:setVisible(true)
        self.txt_num:setText(self.maxNum)
        self.btn_chongzhi:setVisible(false)
    else
        self.txt_num:setVisible(true)
        self.btn_chongzhi:setVisible(true)
        self.txt_num:setText(self.num .. "/" .. self.maxNum)
        self.btn_chongzhi:setVisible(true)
    end

    self.btn_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconBtnClickHandle))

    self.btn_icon:addMEListener(TFWIDGET_TOUCHBEGAN, self.IconBtnTouchBeganHandle)
    self.btn_icon:addMEListener(TFWIDGET_TOUCHMOVED, self.IconBtnTouchMovedHandle)
    self.btn_icon:addMEListener(TFWIDGET_TOUCHENDED, self.IconBtnTouchEndedHandle)

    self.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DelBtnClickHandle))

    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHBEGAN, self.DelBtnTouchBeganHandle)
    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHMOVED, self.DelBtnTouchMovedHandle)
    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHENDED, self.DelBtnTouchEndedHandle)
end

function JingyaoIcon:registerEvents()
	self.super.registerEvents(self)
    
    self.btn_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconBtnClickHandle))

    self.btn_icon:addMEListener(TFWIDGET_TOUCHBEGAN, self.IconBtnTouchBeganHandle)
    self.btn_icon:addMEListener(TFWIDGET_TOUCHMOVED, self.IconBtnTouchMovedHandle)
    self.btn_icon:addMEListener(TFWIDGET_TOUCHENDED, self.IconBtnTouchEndedHandle)

    self.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DelBtnClickHandle))

    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHBEGAN, self.DelBtnTouchBeganHandle)
    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHMOVED, self.DelBtnTouchMovedHandle)
    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHENDED, self.DelBtnTouchEndedHandle)
end

function JingyaoIcon:removeEvents()
    self.super.removeEvents(self)
end

function JingyaoIcon:getId()
    return self.id
end

--点击icon
function JingyaoIcon.IconBtnClickHandle(sender)
    local self = sender.logic
    print("{{{{{{{", self.num, self.maxNum)
    --[[
    if self.num >= self.maxNum then
        return
    end
    ]]
    self.logic:addToFenjieList(self.id, self, 1)
end

--点击icon上的减号小按钮
function JingyaoIcon.DelBtnClickHandle(sender)
    local self = sender.logic
    if self.num == 0 then
        return
    end

    self.logic:delAtFenjieList(self.id, self)
end

--icon touchBegan
function JingyaoIcon.IconBtnTouchBeganHandle(sender)
    local self = sender.logic

    local times = 1
    local num_addSpeed = 1
    local num_add = 1
    local function onLongTouch()
        if self.num >= self.maxNum then
            self.num = self.maxNum
            return
        end

        if num_add + self.num >= self.maxNum then
            num_add = self.maxNum - self.num
        end
        
        self.logic:addToFenjieList(self.id, self, num_add)
        TFDirector:removeTimer(self.longAddTouchTimerId)

        if num_addSpeed == 3 then
            num_addSpeed = 0
            num_add = num_add + 1
        else
            num_addSpeed = num_addSpeed + 1
        end
        
        local speed = 1
        if times < 6 then
            self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch)
        else
            self.longAddTouchTimerId = TFDirector:addTimer(50, 1, nil, onLongTouch)
        end
        times = times + 1
    end

    self.longAddTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch)
end

function JingyaoIcon.IconBtnTouchMovedHandle(sender)
    local self = sender.logic

    local v = ccpSub(sender:getTouchStartPos(), sender:getTouchMovePos())
    if v.y > 15 or v.y < -15 then
        TFDirector:removeTimer(self.longAddTouchTimerId)
    end
end

function JingyaoIcon.IconBtnTouchEndedHandle(sender)
    local self = sender.logic
    if self.longAddTouchTimerId then
        TFDirector:removeTimer(self.longAddTouchTimerId)
        self.longAddTouchTimerId = nil
    end
end

function JingyaoIcon.DelBtnTouchBeganHandle(sender)
    local self = sender.logic

    if self.type ~= 1 then
        local times = 1

        local function onLongTouch()
            if self.num == 0 then
                return
            end

            self.logic:delAtFenjieList(self.id, self)
            TFDirector:removeTimer(self.longDelTouchTimerId)

            if times < 6 then
                self.longDelTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch)
            else
                self.longDelTouchTimerId = TFDirector:addTimer(50, 1, nil, onLongTouch) 
            end
            times = times + 1
        end
        self.longDelTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch)
    end
end

function JingyaoIcon.DelBtnTouchMovedHandle(sender)
    local self = sender.logic
    TFDirector:removeTimer(self.longDelTouchTimerId)
end

function JingyaoIcon.DelBtnTouchEndedHandle(sender)
    local self = sender.logic
    if self.longDelTouchTimerId then
        TFDirector:removeTimer(self.longDelTouchTimerId)
        self.longDelTouchTimerId = nil
    end
end

return JingyaoIcon