MainuiTraceRushTop = MainuiTraceRushTop or BaseClass(BaseTracePanel)

function MainuiTraceRushTop:__init(main)
    self.main = main

    self.Mgr = RushTopManager.Instance
    self.model = self.Mgr.model

    self.resList = {
        {file = AssetConfig.rushtopcontent, type = AssetType.Main},
        {file = AssetConfig.rushtop_texture, type = AssetType.Dep},
    }

    self.isOnToggle = false

    self.refresh = function ()
        self:SetData()
    end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceRushTop:__delete()
    self.OnHideEvent:Fire()

    if self.itemSlot1 ~= nil then
        self.itemSlot1:DeleteMe()
        self.itemSlot1 = nil
    end
    if self.itemSlot2 ~= nil then
        self.itemSlot2:DeleteMe()
        self.itemSlot2 = nil
    end
    if self.itemData1 ~= nil then
        self.itemData1:DeleteMe()
        self.itemData1 = nil
    end
    if self.itemData2 ~= nil then
        self.itemData2:DeleteMe()
        self.itemData2 = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.main = nil
end



function MainuiTraceRushTop:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rushtopcontent))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(-10, 61, 0)
    local t = self.transform:Find("Panel")
    self.exitButton = t:Find("ExitButton"):GetComponent(Button)
    self.exitButton.onClick:AddListener(function()
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("是否要退出<color='#ffff00'>冲顶答题</color>？")
        confirmData.sureCallback = function() self.Mgr:Send20424(2) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end)

    self.descButton = t:Find("Desc"):GetComponent(Button)
    self.descButton.onClick:AddListener(function()
        self.Mgr.model:OpenDescPanel()
    end)

    local top = t:Find("Main/Top")
    local bot = t:Find("Main/Bottom")

    self.toggleBtn = bot:Find("Toggle"):GetComponent(Button)
    self.toggleTickObj = bot:Find("Toggle/Bg/Tick").gameObject
    self.toggleBtn.onClick:AddListener(function() self:OnToggle() end)

    self.ttext1 = top:Find("Text1"):GetComponent(Text)
    self.ttext2 = top:Find("Text2"):GetComponent(Text)
    self.ttext3 = top:Find("Text3"):GetComponent(Text)
    self.ttext4 = top:Find("Text4"):GetComponent(Text)
    self.ttext5 = top:Find("Text5"):GetComponent(Text)
    self.clock = top:Find("clock").gameObject
    self.gold = top:Find("gold").gameObject

    self.goldicon = GameObject.Instantiate(self.gold):GetComponent(RectTransform)
    self.goldicon.transform:SetParent(self.ttext3.transform)
    self.goldicon.localScale = Vector3(1,1,1)
    self.goldicon.sizeDelta = Vector2(20,20)


    self.btext1 = bot:Find("Text1"):GetComponent(Text)
    self.btext2 = bot:Find("Text2"):GetComponent(Text)

    bot:Find("Text2"):GetComponent(RectTransform).anchoredPosition = Vector2(0.3,16)

    self.entercard = bot:Find("entercard")
    self.relivecard = bot:Find("relivecard")

    self.itemSlot1 = ItemSlot.New()
    UIUtils.AddUIChild(self.entercard, self.itemSlot1.gameObject)
    local itemBaseData = BackpackManager.Instance:GetItemBase(26013)
    self.itemData1 = ItemData.New()
    self.itemData1:SetBase(itemBaseData)
    self.itemData1.need = 1

    self.itemSlot2 = ItemSlot.New()
    UIUtils.AddUIChild(self.relivecard, self.itemSlot2.gameObject)
    local itemBaseData = BackpackManager.Instance:GetItemBase(26014)
    self.itemData2 = ItemData.New()
    self.itemData2:SetBase(itemBaseData)
    self.itemData2.need = 1

end


function MainuiTraceRushTop:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceRushTop:OnOpen()
    self:AddListeners()
    self:SetData()
    local limitrolenum = SceneManager.Instance.sceneElementsModel.LimitRoleNum
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(limitrolenum)
    self.isOnToggle = limitrolenum
    self.toggleTickObj:SetActive(limitrolenum)
end


function MainuiTraceRushTop:OnHide()
    self:RemoveListeners()
end

function MainuiTraceRushTop:RemoveListeners()
    RushTopManager.Instance.on20421:RemoveListener(self.refresh)
    RushTopManager.Instance.on20422:RemoveListener(self.refresh)
    RushTopManager.Instance.on20425:RemoveListener(self.refresh)
    RushTopManager.Instance.on20428:RemoveListener(self.refresh)
    RushTopManager.Instance.on20429:RemoveListener(self.refresh)
    RushTopManager.Instance.on20433:RemoveListener(self.refresh)

    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.refresh)
end

function MainuiTraceRushTop:AddListeners()
    self:RemoveListeners()
    RushTopManager.Instance.on20421:AddListener(self.refresh)
    RushTopManager.Instance.on20422:AddListener(self.refresh)
    RushTopManager.Instance.on20425:AddListener(self.refresh)
    RushTopManager.Instance.on20428:AddListener(self.refresh)
    RushTopManager.Instance.on20429:AddListener(self.refresh)
    RushTopManager.Instance.on20433:AddListener(self.refresh)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.refresh)
end

function MainuiTraceRushTop:SetData()
    if RushTopManager.Instance.model.status == RushTopEnum.State.Ready then
        self.toggleBtn.gameObject:SetActive(false)
        self.entercard.gameObject:SetActive(true)
        self.relivecard.gameObject:SetActive(true)
        self.itemData1.quantity = BackpackManager.Instance:GetItemCount(26013)
        self.itemSlot1:SetAll(self.itemData1)
        self.itemData2.quantity = BackpackManager.Instance:GetItemCount(26014)
        self.itemSlot2:SetAll(self.itemData2)
        self.btext1.gameObject:SetActive(true)
        self.btext2.gameObject:SetActive(false)
        self.btext1.text = TI18N("1.共计<color='#00ff00'>12道题目</color>，完全答对即可登顶成功，<color='#00ff00'>平分奖池钻石</color>\n2.赠送他人<color='#00ff00'>入场券</color>可获得<color='#00ff00'>复活卡</color>哟，当前拥有：")
        self.ttext1.gameObject:SetActive(true)
        self.ttext2.gameObject:SetActive(true)
        self.ttext3.gameObject:SetActive(true)
        self.ttext4.gameObject:SetActive(false)
        self.ttext5.gameObject:SetActive(false)
        self.gold.gameObject:SetActive(true)
        self.clock.gameObject:SetActive(true)

        self.ttext1.text = TI18N("准备阶段")
        if self.model.rules ~= nil then
            self.ttext3.text = string.format(TI18N("本期奖池:<color='#fff000'>%s</color>"),self.model.rules.gold_item[1].g_num)
            self.goldicon.anchoredPosition = Vector2(self.ttext3.preferredWidth-68,0)
        end
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 20, function() self:SetTime() end)
        end
    else
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end

        self.ttext1.gameObject:SetActive(true)
        self.ttext2.gameObject:SetActive(false)
        self.ttext3.gameObject:SetActive(false)
        self.ttext4.gameObject:SetActive(true)
        self.ttext5.gameObject:SetActive(true)
        self.gold.gameObject:SetActive(false)
        self.clock.gameObject:SetActive(false)
        self.ttext3.text = ""
        self.ttext2.text = ""
        self.toggleBtn.gameObject:SetActive(true)
        self.entercard.gameObject:SetActive(false)
        self.relivecard.gameObject:SetActive(false)
        self.btext1.gameObject:SetActive(false)
        self.btext2.gameObject:SetActive(true)
        self.btext2.text = TI18N("1.答对<color='#00ff00'>12题</color>可平分奖池奖金\n2.答题错误后可使用<color='#00ff00'>复活卡</color>\n3.每场最多使用<color='#00ff00'>3张</color>复活卡\n4.第12题<color='#00ff00'>决胜题</color>不能复活")
        self.ttext1.text = TI18N("答题阶段")
        if self.model.curquestion ~= nil and self.model.curquestion.question_index ~= 0 then
            self.ttext4.text = string.format(TI18N("第<color='#fff000'>%s</color>题"),self.model.curquestion.question_index)
        else
            self.ttext4.text = TI18N("待刷新")
        end

        if self.model.playerInfo ~= nil and self.model.curquestion ~= nil then
            if self.model.playerInfo.is_lost == 0 and self.model.playerInfo.sign == 1 then
                self.ttext5.text = TI18N("我的状态：参赛中")
            elseif self.model.playerInfo.is_lost == 1 and self.model.playerInfo.sign == 1 and self.model.playerInfo.index == self.model.curquestion.question_index - 1  then
                self.ttext5.text = TI18N("我的状态：可复活")
            else
                self.ttext5.text = TI18N("我的状态：围观中")
            end
        else
            self.ttext5.text = TI18N("我的状态：待刷新")
        end

    end


end


function MainuiTraceRushTop:SetTime()
    local dis = self.model.nexttime - BaseUtils.BASE_TIME
    local min = 0
    local sec = 0
    local hour = 0

    if dis > 0 then
        hour = math.floor(dis / 3600)
        min = math.floor((dis % 3600) / 60)
        sec = dis % 60
    else
        LuaTimer.Delete(self.timerId)
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
        self.ttext2.text = string.format(TI18N("即将开始 %s:%s:%s"), hour, min, sec)
    else
        self.ttext2.text = string.format(TI18N("即将开始 %s:%s"), min, sec)
    end
end

-- function MainuiTraceRushTop:IsShowButton()
--     if RushTopManager.Instance.model.status == RushTopEnum.State.Ready or RushTopManager.Instance.model.curquestion == nil then
--         self.button.gameObject:SetActive(false)
--     else
--         self.button.gameObject:SetActive(true)
--     end
-- end

-- function MainuiTraceRushTop:SetGold()
--     if RushTopManager.Instance.model.rules ~= nil and RushTopManager.Instance.model.rules.gold_item[1].g_num ~= nil then
--         self.pool.text = RushTopManager.Instance.model.rules.gold_item[1].g_num
--     end
-- end

-- function MainuiTraceRushTop:SetCard()
--     if RushTopManager.Instance.model.rules ~= nil and RushTopManager.Instance.model.rules.revive[1].r_base_id ~= nil then
--        self.card.text = BackpackManager.Instance:GetItemCount(RushTopManager.Instance.model.rules.revive[1].r_base_id)
--     end
-- end

function MainuiTraceRushTop:OnToggle()
    self.isOnToggle = not self.isOnToggle
    self.toggleTickObj:SetActive(self.isOnToggle)
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.isOnToggle)


end


