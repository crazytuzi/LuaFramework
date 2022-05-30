-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
NewFirstChargeController = NewFirstChargeController or BaseClass(BaseController)

function NewFirstChargeController:config()
    self.model = NewFirstChargeModel.New(self)
end

function NewFirstChargeController:getModel()
    return self.model
end

function NewFirstChargeController:registerEvents()

end

function NewFirstChargeController:registerProtocals()
    self:RegisterProtocal(21000, "handle21000")
    self:RegisterProtocal(21001, "handle21001")

    self:RegisterProtocal(21012, "handle21012")
    self:RegisterProtocal(21013, "handle21013")
    self:RegisterProtocal(21014, "handle21014")
    self:RegisterProtocal(21015, "handle21015")
    self:RegisterProtocal(21030, "handle21030")
    self:RegisterProtocal(21031, "handle21031")
    self:RegisterProtocal(21032, "handle21032")
    self:RegisterProtocal(21033, "handle21033")
    
end

function NewFirstChargeController:openNewFirstChargeView(bool)
    if bool == true then
        --根据主城图标来判断首充进入哪一个界面
        local first_icon2 = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.first_charge_new2)
        if first_icon2 then
            if not self.new_first_charge_window then
                self.new_first_charge_window = NewFirstChargeWindow2.New()
            end
        end
        local first_icon3 = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.first_charge_new3)
        if first_icon3 then
            if not self.new_first_charge_window then
                self.new_first_charge_window = NewFirstChargeWindow3.New()
            end
        end

        local first_icon = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.first_charge_new1)
        if first_icon then
            if not self.new_first_charge_window then
                self.new_first_charge_window = NewFirstChargeWindow1.New()
            end
        end
        local first_icon1 = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.first_charge_new)
        if first_icon1 then
            if not self.new_first_charge_window then
                self.new_first_charge_window = NewFirstChargeWindow.New()
            end
        end
        ---*******************************************

        if not self.new_first_charge_window then return end

        local role_vo = RoleController:getInstance():getRoleVo()
        local index = 1
        if role_vo.vip_exp ~= 0 then
            index = 2
        end

        if self.new_first_get_data then
            --首充是否可以领取
            local first_status = false
            for i=1,3 do
                if self.new_first_get_data[i] and self.new_first_get_data[i].status == 1 then
                    first_status = true
                    index = 1
                    break
                end
            end
            --累充是否可以领取
            local total_status = false
            for i=4,6 do
                if self.new_first_get_data[i] and self.new_first_get_data[i].status == 1 then
                    total_status = true
                    index = 2
                    break
                end
            end
            if first_status == true and total_status == true then
                index = 1
            end
        end

        self.new_first_charge_window:open(index)
    else
        if self.new_first_charge_window then 
            self.new_first_charge_window:close()
            self.new_first_charge_window = nil
        end
    end
end

--首充礼包信息（耶梦加得）
function NewFirstChargeController:sender21000()
    self:SendProtocal(21000, {})
end
function NewFirstChargeController:handle21000(data)
    self.new_first_get_data = data.first_gift --首充是否可领取的数据
    self.model:setFirstBtnNewStatus(data.first_gift)
    GlobalEvent:getInstance():Fire(NewFirstChargeEvent.New_First_Charge_Event,data)
end
--领取首冲礼包（耶梦加得）
function NewFirstChargeController:sender21001(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(21001, protocal)
end
function NewFirstChargeController:handle21001(data)
    message(data.msg)
end
-- 信息(3选1)
function NewFirstChargeController:sender21012()
    self:SendProtocal(21012,{})
end
function NewFirstChargeController:handle21012(data)
    self.new_first_get_data = data.first_gift --首充是否可领取的数据
    self.model:setFirstBtnStatus(data.first_gift)
    GlobalEvent:getInstance():Fire(NewFirstChargeEvent.New_First_Charge_Event,data)
end
--领取
function NewFirstChargeController:sender21013(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(21013,proto)
end
function NewFirstChargeController:handle21013(data)
    message(data.msg)
end
--自选宝可梦
function NewFirstChargeController:sender21014(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(21014,proto)
end
function NewFirstChargeController:handle21014(data)
    message(data.msg)
end

-- 每日礼包红点
function NewFirstChargeController:handle21015( data )
    if data.open_id and next(data.open_id) ~= nil then
        WelfareController:getInstance():getModel():updateDailyGiftRedStatus(true)
    end
end

--首充礼包信息（利维坦）
function NewFirstChargeController:sender21030()
    self:SendProtocal(21030, {})
end
function NewFirstChargeController:handle21030(data)
    self.new_first_get_data = data.first_gift --首充是否可领取的数据
    self.model:setFirstBtnNewStatus2(data.first_gift)
    GlobalEvent:getInstance():Fire(NewFirstChargeEvent.New_First_Charge_Event,data)
end
--领取首冲礼包（利维坦）
function NewFirstChargeController:sender21031(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(21031, protocal)
end
function NewFirstChargeController:handle21031(data)
    message(data.msg)
end

--首充礼包信息（6元耶梦加得，100元利维坦）
function NewFirstChargeController:sender21032()
    self:SendProtocal(21032, {})
end
function NewFirstChargeController:handle21032(data)
    self.new_first_get_data = data.first_gift --首充是否可领取的数据
    self.model:setFirstBtnNewStatus3(data.first_gift)
    GlobalEvent:getInstance():Fire(NewFirstChargeEvent.New_First_Charge_Event,data)
end
--领取首冲礼包（6元耶梦加得，100元利维坦）
function NewFirstChargeController:sender21033(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(21033, protocal)
end
function NewFirstChargeController:handle21033(data)
    message(data.msg)
end

function NewFirstChargeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end