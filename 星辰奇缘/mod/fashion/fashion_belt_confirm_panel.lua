FashionBeltConfirmPanel  =  FashionBeltConfirmPanel or BaseClass(BasePanel)

function FashionBeltConfirmPanel:__init(model)
    self.name  =  "FashionBeltConfirmPanel"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.fashion_belt_confirm_win, type  =  AssetType.Main}
    }

    return self
end


function FashionBeltConfirmPanel:__delete()

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function FashionBeltConfirmPanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_belt_confirm_win))
    self.gameObject.name  =  "FashionBeltConfirmPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.MainCon = self.transform:FindChild("Main")

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseFashionBeltConfirmUI() end)

    self.CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseBtn.onClick:AddListener(function () self.model:CloseFashionBeltConfirmUI()  end)

    self.MidCon = self.MainCon:FindChild("Content")
    self.MainTxst = self.MidCon:FindChild("Text"):GetComponent(Text)
    self.TxtDesc = self.MidCon:FindChild("TxtBottom"):GetComponent(Text)

    self.MainTxst.text = ""
    self.TxtDesc.text = ""

    self.TxtDesc_top_msg = MsgItemExt.New(self.MainTxst, 322, 18, 23)

    self.SureButton = self.MainCon:FindChild("SureButton"):GetComponent(Button)
    self.CancelButton = self.MainCon:FindChild("CancelButton"):GetComponent(Button)

    self.SureButton_txt = self.SureButton.transform:FindChild("Text"):GetComponent(Text)

    self.SureButton.onClick:AddListener(function () self:on_click_sure()  end)
    self.CancelButton.onClick:AddListener(function () self:on_click_cancel()  end)

    self:update_info_content()
end

--更新面板内容
function FashionBeltConfirmPanel:update_info_content()
    if self.model.belt_type == 1 then
        --购买
        self.SureButton_txt.text = TI18N("购买")
        local str = ""
        local time_str = ""
        local name_str = ""
        local price_str = ""
        local cfg_data_waist = nil
        local cfg_data_dress = nil
        if self.model:check_is_belt_data(self.model.current_waist_data) and self.model:check_is_base_data(self.model.current_head_dress_data) then
            --选择一件
            cfg_data_waist = DataFashion.data_buy[self.model.current_waist_data.base_id]
            time_str = self:trans_time(cfg_data_waist)
            name_str = string.format("[%s]", self.model.current_waist_data.name)
            price_str = tostring(cfg_data_waist.price)
        elseif self.model:check_is_belt_data(self.model.current_head_dress_data) and self.model:check_is_base_data(self.model.current_waist_data) then
            --选择一件
            cfg_data_dress = DataFashion.data_buy[self.model.current_head_dress_data.base_id]
            time_str = self:trans_time(cfg_data_dress)
            name_str = string.format("[%s]", self.model.current_head_dress_data.name)
            price_str = tostring(cfg_data_dress.price)
        elseif self.model:check_is_belt_data(self.model.current_head_dress_data) and self.model:check_is_belt_data(self.model.current_waist_data) then
            --选择两件
            if self.model.current_head_dress_data.active == 0 and self.model.current_waist_data.active == 0 then
                cfg_data_waist = DataFashion.data_buy[self.model.current_waist_data.base_id]
                cfg_data_dress = DataFashion.data_buy[self.model.current_head_dress_data.base_id]
                time_str = self:trans_time(cfg_data_waist, cfg_data_dress)
                name_str = string.format("[%s]，[%s]", self.model.current_head_dress_data.name, self.model.current_waist_data.name)
                local price = cfg_data_waist.price + cfg_data_dress.price
                price_str = tostring(price)
            elseif self.model.current_head_dress_data.active == 0 then
                cfg_data_dress = DataFashion.data_buy[self.model.current_head_dress_data.base_id]
                time_str = self:trans_time(cfg_data_dress)
                name_str = string.format("[%s]", self.model.current_head_dress_data.name)
                price_str = tostring(cfg_data_dress.price)
            elseif self.model.current_waist_data.active == 0 then
                cfg_data_waist = DataFashion.data_buy[self.model.current_waist_data.base_id]
                time_str = self:trans_time(cfg_data_waist)
                name_str = string.format("[%s]", self.model.current_waist_data.name)
                price_str = tostring(cfg_data_waist.price)
            end
        end
        str = string.format("%s<color='#ffff00'>%s</color>{assets_2,90002}%s<color='#2fc823'>%s</color>%s<color='#ffff00'>%s</color>%s", TI18N("确定花费"), price_str, TI18N("购买"), name_str, TI18N("的"), time_str, TI18N("能量使用期吗？"))


        self.TxtDesc_top_msg:SetData(str)
        self.TxtDesc.text = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("注："), time_str, TI18N("后能量将消散，想要继续使用可以补充能量"))
    elseif self.model.belt_type == 2 then

        self.SureButton_txt.text = TI18N("充能")
        local str = ""
        local time_str = ""
        local name_str = ""
        local price_str = ""
        local cfg_data_waist = nil
        local cfg_data_dress = nil
        if self.model:check_is_belt_data(self.model.current_waist_data) and self.model:check_is_base_data(self.model.current_head_dress_data) then
            --选择一件
            cfg_data_waist = DataFashion.data_buy[self.model.current_waist_data.base_id]
            time_str = self:trans_time(cfg_data_waist)
            name_str = string.format("[%s]", self.model.current_waist_data.name)
            price_str = tostring(cfg_data_waist.price)
        elseif self.model:check_is_belt_data(self.model.current_head_dress_data) and self.model:check_is_base_data(self.model.current_waist_data) then
            --选择一件
            cfg_data_dress = DataFashion.data_buy[self.model.current_head_dress_data.base_id]
            time_str = self:trans_time(cfg_data_dress)
            name_str = string.format("[%s]", self.model.current_head_dress_data.name)
            price_str = tostring(cfg_data_dress.price)
        elseif self.model:check_is_belt_data(self.model.current_head_dress_data) and self.model:check_is_belt_data(self.model.current_waist_data) then
            --选择两件
            cfg_data_waist = DataFashion.data_buy[self.model.current_waist_data.base_id]
            cfg_data_dress = DataFashion.data_buy[self.model.current_head_dress_data.base_id]
            time_str = self:trans_time(cfg_data_waist, cfg_data_dress)
            name_str = string.format("[%s]，[%s]", self.model.current_head_dress_data.name, self.model.current_waist_data.name)
            local price = cfg_data_waist.price + cfg_data_dress.price
            price_str = tostring(price)
        end
        str = string.format("%s<color='#ffff00'>%s</color>{assets_2,90002}%s<color='#2fc823'>%s</color>%s<color='#ffff00'>%s</color>%s", TI18N("确定花费"), price_str, TI18N("对"), name_str, TI18N("的充满使用"), time_str, TI18N("的能量吗？"))


        self.TxtDesc_top_msg:SetData(str)
        self.TxtDesc.text = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("注："), time_str, TI18N("后能量将消散，想要继续使用可以补充能量"))
    end
end

--点击购买按钮
function FashionBeltConfirmPanel:on_click_sure()
    local _head_ornament = 0
    local _head_time_id = 0
    local _belt_ornament = 0
    local  _belt_time_id = 0
    if self.model.current_waist_data ~= nil and self.model.current_head_dress_data ~= nil and ((self.model.current_waist_data.active == 0 and self.model.current_head_dress_data.active == 0) or (self.model.current_waist_data.active == 1 and self.model.current_head_dress_data.active == 1)) then
        --两个都未激活或者两个都已激活
        if self.model:check_is_belt_data(self.model.current_head_dress_data) then
            _head_ornament = self.model.current_head_dress_data.base_id
            _head_time_id = DataFashion.data_buy[_head_ornament].time_id
        end
        if self.model:check_is_belt_data(self.model.current_waist_data) then
            _belt_ornament = self.model.current_waist_data.base_id
            _belt_time_id = DataFashion.data_buy[_belt_ornament].time_id
        end
        FashionManager.Instance:request13203(_head_ornament, _head_time_id, _belt_ornament, _belt_time_id)
    else
        --有其中一件未激活，则走单件购买流程
        if self.model.current_waist_data ~= nil and self.model.current_waist_data.active == 0 then
            local _belt_ornament = 0
            local  _belt_time_id = 0
            if self.model:check_is_belt_data(self.model.current_waist_data) then
                _belt_ornament = self.model.current_waist_data.base_id
                _belt_time_id = DataFashion.data_buy[_belt_ornament].time_id
            end
            FashionManager.Instance:request13203(0, 0, _belt_ornament, _belt_time_id)
        elseif self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data.active == 0 then
            local _head_ornament = 0
            local  _head_time_id = 0
            if self.model:check_is_belt_data(self.model.current_head_dress_data) then
                _head_ornament = self.model.current_head_dress_data.base_id
                _head_time_id = DataFashion.data_buy[_head_ornament].time_id
            end
            FashionManager.Instance:request13203(_head_ornament, _head_time_id, 0, 0)
        end
    end
end

--点击取消按钮
function FashionBeltConfirmPanel:on_click_cancel()
    self.model:CloseFashionBeltConfirmUI()
end

--转换时间
function FashionBeltConfirmPanel:trans_time(cfg_data_1, cfg_data_2)
    local time = 0
    local time_str = ""
    if cfg_data_1 ~= nil then
        time = DataFashion.data_time[cfg_data_1.time_id].expire_time[1]
    end
    if cfg_data_2 ~= nil then
        if time < DataFashion.data_time[cfg_data_2.time_id].expire_time[1] then
            time = DataFashion.data_time[cfg_data_2.time_id].expire_time[1]
        end
    end

    --将time转成时间格式
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(time*60)
    if my_date > 0 then
        time_str = string.format("%s%s", my_date, TI18N("天"))
    elseif my_hour > 0 then
        time_str = string.format("%s%s", my_hour, TI18N("小时"))
    elseif my_minute > 0 then
        time_str = string.format("%s%s", my_minute, TI18N("分钟"))
    elseif my_second > 0 then
        time_str = string.format("%s%s", my_second, TI18N("秒"))
    end
    return time_str
end