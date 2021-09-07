RushTopPanel = RushTopPanel or BaseClass(BasePanel)

function RushTopPanel:__init(model)
    self.model = model
    self.Mgr = RushTopManager.Instance
    self.resList = {
        {file = AssetConfig.rushtoppanel, type = AssetType.Main},
        {file = AssetConfig.rushtop_texture, type = AssetType.Dep},
    }

    self.refreshbtn = function ()
        self:IsShowButton()
    end

    self.refreshgold = function ()
        self:SetGold()
        self:SetCard()
    end

    self.refreshcard = function ()
        self:SetCard()
    end

    self.refreshleft = function ()
        self:SetLeft()
    end

    self.setdamaku = function ()
        self:SetDamaku()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RushTopPanel:__delete()
    self.OnHideEvent:Fire()

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    self.main = nil
end



function RushTopPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rushtoppanel))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView, self.gameObject)
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(333, 80, 0)
    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main) end)
    self.button.gameObject:SetActive(false)

    if self.effect == nil then
        self.effect = BaseUtils.ShowEffect(20119, self.button.transform, Vector3(1,1,1), Vector3(0,10,-1000))
        self.effect:SetActive(true)
    end



    self.transform:Find("Damaku"):GetComponent(Button).onClick:AddListener(function() self:OpenDamaku() end)
    self.transform:Find("NoDamaku"):GetComponent(Button).onClick:AddListener(function() self:ShowCloseDamaku() end)

    self.transform:Find("Damaku"):GetComponent(RectTransform).anchoredPosition = Vector2(292, 92)
    self.transform:Find("NoDamaku"):GetComponent(RectTransform).anchoredPosition = Vector2(350, 92)

    self.damakubtn = self.transform:Find("NoDamaku"):GetComponent(Image)
    self.damakuimg = self.transform:Find("NoDamaku/Icon").gameObject


    local top = self.transform:Find("Top")

    top:GetComponent(RectTransform).anchoredPosition = Vector2(-380,-106)

    self.left = top:Find("Left/left"):GetComponent(Text)
    self.left.text = TI18N("刷新中")
    self.pool = top:Find("Pool/pool"):GetComponent(Text)
    self.card = top:Find("Relive/relive"):GetComponent(Text)
    self.leftobj = top:Find("Left").gameObject
    self.pooltrans = top:Find("Pool"):GetComponent(RectTransform)
    self.cardtrans =  top:Find("Relive"):GetComponent(RectTransform)

    self.pool.gameObject:GetComponent(RectTransform).localPosition = Vector2(-7.5,-9.8)
    self.poolicon = GameObject.Instantiate(top:Find("Pool/Image")):GetComponent(RectTransform)
    self.poolicon.transform:SetParent(top:Find("Pool"))
    self.poolicon.localScale = Vector3(0.8,0.8,1)
    self.poolicon.sizeDelta = Vector2(22,22)


    top:Find("Pool"):GetComponent(Button).onClick:AddListener(function ()
        self.Mgr.model:OpenDescPanel()
    end)

    top:Find("Relive"):GetComponent(Button).onClick:AddListener(function ()
        if self.model.rules ~= nil then
            local base_data = DataItem.data_get[self.model.rules.revive[1].r_base_id]
            local info = { itemData = base_data, gameObject = top:Find("Relive").gameObject }
            TipsManager.Instance:ShowItem(info)
        end
    end)

end


function RushTopPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RushTopPanel:OnOpen()
    self:AddListeners()
    self:SetData()

end


function RushTopPanel:OnHide()
    self:RemoveListeners()
end

function RushTopPanel:RemoveListeners()
    RushTopManager.Instance.on20421:RemoveListener(self.refreshgold)
    RushTopManager.Instance.on20422:RemoveListener(self.refreshbtn)
    RushTopManager.Instance.on20425:RemoveListener(self.refreshbtn)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.refreshcard)
    RushTopManager.Instance.on20425:RemoveListener(self.refreshleft)
    RushTopManager.Instance.on20427:RemoveListener(self.refreshleft)
    RushTopManager.Instance.on20433:RemoveListener(self.refreshleft)
    RushTopManager.Instance.on20431:RemoveListener(self.setdamaku)

end

function RushTopPanel:AddListeners()
    self:RemoveListeners()
    RushTopManager.Instance.on20421:AddListener(self.refreshgold)
    RushTopManager.Instance.on20422:AddListener(self.refreshbtn)
    RushTopManager.Instance.on20425:AddListener(self.refreshbtn)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.refreshcard)
    RushTopManager.Instance.on20425:AddListener(self.refreshleft)
    RushTopManager.Instance.on20427:AddListener(self.refreshleft)
    RushTopManager.Instance.on20433:AddListener(self.refreshleft)
    RushTopManager.Instance.on20431:AddListener(self.setdamaku)
end

function RushTopPanel:SetData()
    self:IsShowButton()
    self:SetGold()
    self:SetCard()
    self:SetLeft()
    self:SetDamaku()
end

function RushTopPanel:IsShowButton()
    if RushTopManager.Instance.model.status == RushTopEnum.State.Ready or RushTopManager.Instance.model.curquestion == nil then
        --or (RushTopManager.Instance.model.curquestion ~= nil and RushTopManager.Instance.model.curquestion.question_index == 0)
        self.button.gameObject:SetActive(false)
        self.leftobj.gameObject:SetActive(false)
        self.pooltrans.anchoredPosition = Vector2(-65,0)
        self.cardtrans.anchoredPosition = Vector2(65,0)
    else
        self.button.gameObject:SetActive(true)
        self.leftobj.gameObject:SetActive(true)
        self.pooltrans.anchoredPosition = Vector2(-90,0)
        self.cardtrans.anchoredPosition = Vector2(90,0)
    end
end

function RushTopPanel:SetGold()
    if RushTopManager.Instance.model.rules ~= nil and RushTopManager.Instance.model.rules.gold_item[1].g_num ~= nil then
        self.pool.text = RushTopManager.Instance.model.rules.gold_item[1].g_num
        self.poolicon.localPosition = Vector2(self.pool.preferredWidth/2 + 2.5,-9.8)
    end
end

function RushTopPanel:SetCard()
    if RushTopManager.Instance.model.rules ~= nil and RushTopManager.Instance.model.rules.revive[1].r_base_id ~= nil then
       self.card.text = BackpackManager.Instance:GetItemCount(RushTopManager.Instance.model.rules.revive[1].r_base_id)
    end
end

function RushTopPanel:SetLeft()
    if RushTopManager.Instance.model.leftplayer ~= nil then
       self.left.text =  RushTopManager.Instance.model.leftplayer
    elseif RushTopManager.Instance.model.curquestion ~= nil then
        self.left.text =  RushTopManager.Instance.model.curquestion.role_num
    else
        self.left.text = TI18N("")
    end
end


function RushTopPanel:ShowCloseDamaku()
    -- self.model:OpenDamakuSetting()
    RushTopManager.Instance:Send20431(2, 1 - self.model.playerInfo.ply_barrage)
end

function RushTopPanel:OpenDamaku()
    self.damakuCallback = self.damakuCallback or function(msg)
        if self.model.playerInfo.barrage_time < BaseUtils.BASE_TIME then
            self.Mgr:Send20430(msg)
            ChatManager.Instance:Send(10400, {channel = MsgEumn.ChatChannel.Scene, msg = msg})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("您刚刚发送过弹幕，请稍后再试"))
        end
    end
    DanmakuManager.Instance.model:OpenPanel({sendCall = self.damakuCallback})
end


function RushTopPanel:SetDamaku()
    if self.model.playerInfo == nil then
        return
    end
    if self.model.playerInfo.ply_barrage == 0 then
        self.damakubtn.sprite = self.assetWrapper:GetSprite(AssetConfig.rushtop_texture,"unsendbtn")
        self.damakuimg:SetActive(false)
    elseif self.model.playerInfo.ply_barrage == 1 then
        self.damakubtn.sprite = self.assetWrapper:GetSprite(AssetConfig.rushtop_texture,"setbtn")
        self.damakuimg:SetActive(true)
    end
end
