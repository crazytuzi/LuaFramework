RushTopSignUp = RushTopSignUp or BaseClass(BaseWindow)

function RushTopSignUp:__init(model)
    self.model = model
    self.Mgr = RushTopManager.Instance
    self.name = "RushTopSignUp"
    self.windowId = WindowConfig.WinID.rushtop_signup_window

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.rushtopsignup, type = AssetType.Main}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
    }

    self.setStatus = function ()
        self:SetStatus()
    end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RushTopSignUp:__delete()
    self.OnHideEvent:Fire()
    if self.titleExt ~= nil then
        self.titleExt:DeleteMe()
        self.titleExt = nil
    end
    if self.rewardExt ~= nil then
        self.rewardExt:DeleteMe()
        self.rewardExt = nil
    end
    -- if self.iconloader ~= nil then
    --     self.iconloader:DeleteMe()
    --     self.iconloader = nil
    -- end
    if self.ItemSlot ~= nil then
        self.ItemSlot:DeleteMe()
        self.ItemSlot = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end

    self:AssetClearAll()
end

function RushTopSignUp:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rushtopsignup))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")

    -- self.iconloader = SingleIconLoader.New(main:Find("Icon/Image").gameObject)
    -- self.iconloader:SetSprite(SingleIconType.MianUI, "379")
    main:Find("Icon/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon,"2069")
    self.titleExt = MsgItemExt.New(main:Find("Title"):GetComponent(Text), 300, 19, 22)
    self.titleExt:SetData(TI18N("<color='#00ff00'>冲顶答题</color>开始啦{face_1,36}"))
    self.rewardExt = MsgItemExt.New(main:Find("Reward"):GetComponent(Text), 300, 19, 22)

    self.rulesText = main:Find("Rules/Text"):GetComponent(Text)
    self.timeText = main:Find("Time"):GetComponent(Text)
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(main:Find("Card"), self.itemSlot.gameObject)
    self.itemData = ItemData.New()

    self.btn = main:Find("Button"):GetComponent(Button)
    self.btnImg = self.btn.gameObject:GetComponent(Image)
    self.btnText = main:Find("Button/Text"):GetComponent(Text)
    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function()
        if self.model.playerInfo == nil then
            return
        end
        if self.model.playerInfo.sign == 0 then
            if self.model.status < RushTopEnum.State.Answer then
                if BackpackManager.Instance:GetItemCount(26013) < 1 then
                    self.itemSlot:SureClick()
                else
                    RushTopManager.Instance:Send20423()
                end
            else
                RushTopManager.Instance:Send20424(1)
            end
        else
            if self.model.status >= RushTopEnum.State.Answer then
                RushTopManager.Instance:Send20424(1)
            else
                NoticeManager.Instance:FloatTipsByString("已经报名，记得准时参加哟~{face_1,10}")
            end
        end
    end)

    if self.model.rules ~= nil then
        self.rulesText.text = self.model.rules.rude
    end
end

function RushTopSignUp:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RushTopSignUp:OnOpen()
    self:RemoveListeners()
    -- BaseUtils.dump(self.openArgs, "时间戳")
    -- BaseUtils.dump(BaseUtils.BASE_TIME, "当前时间戳")
    self:AddListeners()
    self.Mgr:Send20429()
end

function RushTopSignUp:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function RushTopSignUp:AddListeners()
    self:RemoveListeners()
    self.Mgr.on20429:AddListener(self.setStatus)

end

function RushTopSignUp:RemoveListeners()
    self.Mgr.on20429:RemoveListener(self.setStatus)
end

function RushTopSignUp:SetStatus()
    if self.timerId == nil and self.openArgs~= nil and self.openArgs[1] ~= nil then
        self.timerId = LuaTimer.Add(0, 20, function() self:SetTime() end)
    end

    if self.model.rules ~= nil then
        self.rulesText.text = self.model.rules.rude
        self.rewardExt:SetData(string.format(TI18N("<color='#00ff00'>当前奖池</color>：<color='#ffff00'>%s</color>{assets_2,%s}"),self.model.rules.gold_item[1].g_num,self.model.rules.gold_item[1].g_base_id))

        if self.model.rules.ticket ~= nil then 
            if self.model.playerInfo.sign == 0 then
                local itemBaseData = BackpackManager.Instance:GetItemBase(self.model.rules.ticket[1].t_base_id)
                self.itemData:SetBase(itemBaseData)
                self.itemData.need = self.model.rules.ticket[1].t_num
                self.itemData.quantity = BackpackManager.Instance:GetItemCount(self.model.rules.ticket[1].t_base_id)
                self.itemSlot:SetAll(self.itemData)
                self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.btnText.color = ColorHelper.DefaultButton2
                if self.model.status == RushTopEnum.State.Answer then
                    self.btnText.text = TI18N("我要围观")
                else
                    self.btnText.text = TI18N("我要报名")
                end
            else
                local itemBaseData = BackpackManager.Instance:GetItemBase(self.model.rules.revive[1].r_base_id)
                self.itemData:SetBase(itemBaseData)
                self.itemData.need = 0 --self.model.rules.revive[1].r_num
                self.itemData.quantity = BackpackManager.Instance:GetItemCount(self.model.rules.revive[1].r_base_id)
                self.itemSlot:SetAll(self.itemData)
                self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.btnText.color = ColorHelper.DefaultButton3
                self.btnText.text = TI18N("报名成功")
            end
        end
    else
        self.rewardExt:SetData(TI18N("<color='#00ff00'>当前奖池</color>："))
    end
end

function RushTopSignUp:SetTime()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil  then
        local dis = self.openArgs[1] - BaseUtils.BASE_TIME
        local min = 0
        local sec = 0
        local hour = 0

        if dis > 0 then
            hour = math.floor(dis / 3600)
            min = math.floor((dis % 3600) / 60)
            sec = dis % 60
        end
        if min < 10 then
            min = string.format("0%s", min)
        end
        if sec < 10 then
            sec = string.format("0%s", sec)
        end

        if hour > 0 then
            if hour < 10 then
                hour = string.format("0%s", hour)
            end
            if self.model.status == RushTopEnum.State.Signup then
                self.timeText.text = string.format(TI18N("距离活动开启：%s:%s:%s"), hour, min, sec)
            elseif self.model.status == RushTopEnum.State.Ready then
                self.timeText.text = string.format(TI18N("距离答题开始：%s:%s:%s"), hour, min, sec)
            end
        else
            if self.model.status == RushTopEnum.State.Signup then
                self.timeText.text = string.format(TI18N("距离活动开启：%s:%s"), min, sec)
            elseif self.model.status == RushTopEnum.State.Ready then
                self.timeText.text = string.format(TI18N("距离答题开始：%s:%s"), min, sec)
            end
        end
    end
end











