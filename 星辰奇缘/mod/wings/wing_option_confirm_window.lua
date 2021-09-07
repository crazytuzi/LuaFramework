WingOptionConfirmWindow  =  WingOptionConfirmWindow or BaseClass(BasePanel)

function WingOptionConfirmWindow:__init(model)
    self.name  =  "WingOptionConfirmWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.wing_option_confirm_window, type  =  AssetType.Main}
    }


    self.skillItemList = {}

    return self
end


function WingOptionConfirmWindow:__delete()
    if self.skillItemList ~= nil then
        for _,v in pairs(self.skillItemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.skillItemList = nil
    end

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function WingOptionConfirmWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_option_confirm_window))
    self.gameObject.name  =  "WingOptionConfirmWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -100)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseOptionConfirmPanel() end)


    self.MainCon = self.transform:FindChild("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseOptionConfirmPanel() end)


    self.TxtDesc = self.MainCon:FindChild("TxtDesc"):GetComponent(Text)

    self.TxtDesc_msg = MsgItemExt.New(self.TxtDesc, 335, 16, 23)

    self.TxtOption = self.MainCon:FindChild("TxtOption"):GetComponent(Text)

    self.BtnSure = self.MainCon:FindChild("BtnSure"):GetComponent(Button)
    self.BtnCancel = self.MainCon:FindChild("BtnCancel"):GetComponent(Button)

    self.BtnSure.onClick:AddListener(function() WingsManager.Instance:Send11609(WingsManager.Instance.target_option)  end)
    self.BtnCancel.onClick:AddListener(function() self.model:CloseOptionConfirmPanel()  end)

    self.SkillCon = self.MainCon:FindChild("SkillCon")
    for i=1,4 do
        self.skillItemList[i] = WingSkillItem.New(self.model, self.SkillCon:Find("SkillItem"..i).gameObject)
        self.skillItemList[i]:SetAddClick(false)
    end





    local prefix = ""
    if WingsManager.Instance.target_option == 1 then
        prefix = TI18N("方案一")
    elseif WingsManager.Instance.target_option == 2 then
        prefix = TI18N("方案二")
    elseif WingsManager.Instance.target_option == 3 then
        prefix = TI18N("方案三")
    end
    self.TxtOption.text = string.format("%s%s", prefix, TI18N("技能："))

    local time = WingsManager.Instance.change_times+1
    time = time > 10 and 10 or time
    local cost = DataWing.data_switch_cost[time].coin

    local str = TI18N("今天<color='#ffff00'>首次</color>切换技能，不用消耗任何货币~确定要切换吗？")

    if cost > 0 then
        str = string.format(TI18N("今天第<color='#ffff00'>%s</color>次切换技能，需要消耗<color='#ffff00'>%s</color>{assets_2,90000}，确定要切换到<color='#ffff00'>%s</color>吗？"), time, cost, prefix)
    end

    if time > 10 then
        if cost > 0 then
            str = string.format(TI18N("今天切换次数超过<color='#ffff00'>10次</color>，需要消耗<color='#ffff00'>%s</color>{assets_2,90000}，确定要切换到<color='#ffff00'>%s</color>吗？"), cost, prefix)
        end
    end

    self.TxtDesc_msg:SetData(str)

    local skill_data = nil
    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == WingsManager.Instance.target_option then
            skill_data = WingsManager.Instance.plan_data[i].skills
            break
        end
    end

    if skill_data == nil then
        skill_data = {}
    end

    for i=1,4 do
        local tab = skill_data[i]
        if tab == nil then
            tab = {}
        end
        self.skillItemList[i].assetWrapper = self.assetWrapper
        self.skillItemList[i]:update_my_self(tab, i)
    end

    if #WingsManager.Instance.break_skills > 0 then
        self.skillItemList[4].assetWrapper = self.assetWrapper
        self.skillItemList[4]:update_my_self(WingsManager.Instance.break_skills[1], 4)
    end
end