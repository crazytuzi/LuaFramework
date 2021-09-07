MainuiTraceTrial = MainuiTraceTrial or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiTraceTrial:__init(main)
    self.main = main
    self.isInit = false
    self.currId = nil
    self.task_item = nil
    self.base_taskData = nil

    self.resList = {
        {file = AssetConfig.trial_content, type = AssetType.Main}
    }

    self._Update = function() self:Update() end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceTrial:__delete()
    self.OnHideEvent:Fire()
end

function MainuiTraceTrial:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.trial_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.container = self.transform:FindChild("Content/Container").gameObject
	self.order_text = self.transform:FindChild("Content/Level/Text"):GetComponent(Text)
	self.status_text = self.transform:FindChild("Content/Text/Text"):GetComponent(Text)
	self.taskitem_object = self.transform:FindChild("Content/taskItem").gameObject
	self.directitem_object = self.transform:FindChild("Content/DirectItem").gameObject
	self.rewarditem_object = self.transform:FindChild("Content/RewardItem").gameObject

    self.exitbtn = self.transform:Find("GiveUP/Button")
    self.exitbtn:GetComponent(Button).onClick:AddListener(function() TrialManager.Instance:Send13104() end)
   	self.transform:FindChild("Content"):GetComponent(Button).onClick:AddListener(function() self:goto_trial_unit() end)
    self.isInit = true
end

function MainuiTraceTrial:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.trial_update, self._Update)

    self:Update()
end

function MainuiTraceTrial:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceTrial:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.trial_update, self._Update)
end

function MainuiTraceTrial:OnHide()
    self:RemoveListeners()
end

function MainuiTraceTrial:Update()
	local trialModel = TrialManager.Instance.model
    if trialModel.mode ~= 0 then
        for i = 1, self.container.transform.childCount do
            GameObject.Destroy(self.container.transform:GetChild(i - 1).gameObject)
        end

        local data = DataTrial.data_trial_data[trialModel.order]
        if data == nil then return end

        -- 试炼关数
        -- trial_info.transform:FindChild("Content/Level/Image1"):GetComponent(Image).sprite
        --     = ctx.ResourcesManager:GetSprite(config.resources.number_icon_str, "Str2_di")
        -- trial_info.transform:FindChild("Content/Level/Image2"):GetComponent(Image).sprite
        --     = ctx.ResourcesManager:GetSprite(config.resources.number_icon_str, "Str2_guang")

        local order = trialModel.order
        if order < trialModel.direct_order then
            order = trialModel.direct_order
        end
        order = tonumber(DataTrial.data_trial_data[order].order_desc)
        self.order_text.text = string.format(TI18N("第%s关"), order)
        -- local number1 = trial_info.transform:FindChild("Content/Level/Number/Number1"):GetComponent(Image)
        -- local number2 = trial_info.transform:FindChild("Content/Level/Number/Number2"):GetComponent(Image)
        -- if order < 10 then
        --     number2.gameObject:SetActive(false)
        --     number1.sprite = ctx.ResourcesManager:GetSprite(config.resources.number_icon_11, string.format("Num11_%s", order))
        -- else
        --     number2.gameObject:SetActive(true)
        --     number1.sprite = ctx.ResourcesManager:GetSprite(config.resources.number_icon_11, string.format("Num11_%s", math.floor(order/10)))
        --     number2.sprite = ctx.ResourcesManager:GetSprite(config.resources.number_icon_11, string.format("Num11_%s", math.floor(order%10)))
        -- end

        -- 试炼状态
        if data.type == 1 then
            self.status_text.text = TI18N("过关条件")
        elseif data.type == 2 then
            if trialModel.direct_order > trialModel.order then
                self.status_text.text = TI18N("连破达成！")
            else
                self.status_text.text = TI18N("成功过关！")
            end
        end
        -- 试炼条件
        self:addtrialitem(data)
    end
end

function MainuiTraceTrial:addtrialitem(data)
	local trialModel = TrialManager.Instance.model
    if data.type == 1 then
        local item = GameObject.Instantiate(self.taskitem_object)
        UIUtils.AddUIChild(self.container, item)
        if trialModel.trial_unit ~= nil then
            item.transform:FindChild("mobnameText"):GetComponent(Text).text = trialModel.trial_unit.name
        end
        item = GameObject.Instantiate(self.directitem_object)
		UIUtils.AddUIChild(self.container, item)
        item.transform:FindChild("Text"):GetComponent(Text).text = data.ext_desc

        if (trialModel.mode == 1 and trialModel.max_order_easy < #DataTrial.data_trial_data)
            or (trialModel.mode == 2 and trialModel.max_order_hard < #DataTrial.data_trial_data) then
            item:SetActive(false)
        end
        -- item.transform:FindChild("mobnameText"):GetComponent(Text).text = data.ext_desc2
    elseif data.type == 2 then
        local item = GameObject.Instantiate(self.rewarditem_object)
		UIUtils.AddUIChild(self.container, item)
        item.transform:FindChild("mobnameText"):GetComponent(Text).text = data.desc
        if trialModel.direct_order > trialModel.order then
            for i = trialModel.order+1, trialModel.direct_order do
                data = DataTrial.data_trial_data[i]
                if data.type == 2 then
                    item = GameObject.Instantiate(self.rewarditem_object)
					UIUtils.AddUIChild(self.container, item)
                    item.transform:FindChild("mobnameText"):GetComponent(Text).text = data.desc
                    item.transform:FindChild("Text").gameObject:SetActive(false)
                end
            end
        end
    end
end

function MainuiTraceTrial:goto_trial_unit()
    local trial_unit = TrialManager.Instance.model.trial_unit
    if trial_unit then
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(BaseUtils.get_unique_npcid(trial_unit.id, trial_unit.battle_id))
    end
end