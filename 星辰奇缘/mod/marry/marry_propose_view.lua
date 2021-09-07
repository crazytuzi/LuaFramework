Marry_ProposeView = Marry_ProposeView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_ProposeView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_propose_window
    self.name = "Marry_ProposeView"
    self.resList = {
        {file = AssetConfig.marry_propose_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.targetText = nil
    self.itemSolt = nil
    self.Button = nil
    self.input_field = nil

    self.targetData = nil

    -- self.buttonscript = nil
    -----------------------------------------
end

function Marry_ProposeView:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end

    -- if self.buttonscript ~= nil then
    --     self.buttonscript:DeleteMe()
    --     self.buttonscript = nil
    -- end
    self:ClearDepAsset()
end

function Marry_ProposeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_propose_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.targetText = self.transform:Find("Main/Panel/TargetItem/Text"):GetComponent(Text)

    self.input_field = self.transform:FindChild("Main/Panel/InputCon/InputField"):GetComponent(InputField)
    self.input_field.textComponent = self.input_field.gameObject.transform:FindChild("Text"):GetComponent(Text)
    self.input_field.lineType = InputField.LineType.MultiLineSubmit
    self.input_field.characterLimit = 30
    self.input_field.text = TI18N("爱是我，爱是你，爱是肯定句，谁也不能阻挡我，永远守护你！嫁给我吧！")

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/Panel/Item").gameObject, self.itemSolt.gameObject)

    local btn = nil
    btn = self.transform:Find("Main/Panel/TargetItem")
    btn:GetComponent(Button).onClick:AddListener(function() self:selectTarget() end)

    btn = self.transform:Find("Main/Panel/Button")
    btn:GetComponent(Button).onClick:AddListener(function() self:ButtonClick() end)
    -- self.buttonscript = BuyButton.New(btn, "求 婚", WindowConfig.WinID.marry_propose_window)
    -- self.buttonscript:Show()

    self:Update()
end

function Marry_ProposeView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_propose_window)
end

function Marry_ProposeView:Update()
	local itembase = BackpackManager.Instance:GetItemBase(20044)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = BackpackManager.Instance:GetItemCount(20044)
    itemData.need = 1
    self.itemSolt:SetAll(itemData)

    -- self.buttonscript:Layout({[20044] = {need = 1}}, function() self:ButtonClick() end, nil, { antofreeze = false })

    if TeamManager.Instance.teamNumber == 2 then
        for key, value in pairs(TeamManager.Instance.memberTab) do
            local uid = BaseUtils.Key(value.rid, value.platform, value.zone_id)
            if FriendManager.Instance.friend_List[uid] ~= nil and FriendManager.Instance.friend_List[uid].intimacy >= 999 then
                self:updateTarger(FriendManager.Instance.friend_List[uid])
            end
        end
    end
end

function Marry_ProposeView:selectTarget()
	local callBack = function(_, friendData) self:updateTarger(friendData) end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack, 2 })
end

function Marry_ProposeView:updateTarger(friendData)
    self.targetData = friendData
    self.targetText.text = tostring(friendData.name)
end

function Marry_ProposeView:ButtonClick()
    if self.targetData ~= nil then
        local targetTeamData = TeamManager.Instance.memberTab[BaseUtils.get_unique_roleid(self.targetData.id, self.targetData.zone_id, self.targetData.platform)]
        if TeamManager.Instance.teamNumber == 2 and targetTeamData ~= nil and targetTeamData.status ~= RoleEumn.TeamStatus.Away and targetTeamData.status ~= RoleEumn.TeamStatus.Offline then
            if self.targetData.intimacy >= 999 then
                if BackpackManager.Instance:GetItemCount(20044) > 0 then
                    local confirmData = NoticeConfirmData.New()
                    confirmData.type = ConfirmData.Style.Normal
                    confirmData.content = string.format(TI18N("您正在向<color='#ffff00'>[%s]</color>结缘申请，是否继续？"), self.targetData.name)
                    confirmData.sureLabel = TI18N("确定")
                    confirmData.cancelLabel = TI18N("取消")
                    confirmData.sureCallback = function()
                            local str = self.input_field.text
                            MarryManager.Instance:Send15000(self.targetData.id, self.targetData.platform, self.targetData.zone_id, str)

                            self:Close()
                        end
                    NoticeManager.Instance:ConfirmTips(confirmData)
                else
                    local itemdata = ItemData.New()
                    itemdata:SetBase(BackpackManager.Instance:GetItemBase(20044))
                    TipsManager.Instance:ShowItem({["gameObject"] = self.transform:FindChild("Main/Panel/Button").gameObject, ["itemData"] = itemdata})

                    NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("双方达到999亲密度才能结缘申请哦"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请先与结缘申请对象2人组队才能进行结缘申请"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有选中结缘申请对象，请先选择"))
    end
end