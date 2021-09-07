-- @author pwj
-- @date 2018年2月26日,星期一

ArborDayRewardWin = ArborDayRewardWin or BaseClass(BaseWindow)

function ArborDayRewardWin:__init(model)
    self.model = model
    self.name = "ArborDayRewardWin"
    self.windowId = WindowConfig.WinID.ArborDay_Reward_Win
    self.resList = {
        {file = AssetConfig.arborDayReward_win,type = AssetType.Main}
        ,{file = AssetConfig.arborDayShake_texture, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.returnReward = { }

    self.rewardList = { }
    self.rewardInList = { }
    self.drawEffectList = { }

    self.TweenId = 0
    self.TweenTimer = {}
    self.ContainerTweenTimer = {}

    self.Effect = { }    ---扫光特效

    self.NormalEffect = { }  --itemslot常用特效
end

function ArborDayRewardWin:__delete()
    self.OnHideEvent:Fire()

    if self.TweenTimer ~= nil then
        for i,v in pairs(self.TweenTimer) do
            Tween.Instance:Cancel(v)
            v = nil
        end
        self.TweenTimer = nil
    end

    if self.ContainerTweenTimer ~= nil then
        for i,v in pairs(self.ContainerTweenTimer) do
            Tween.Instance:Cancel(v)
            v = nil
        end
        self.ContainerTweenTimer = nil
    end

    if self.Effect ~= nil then
        for i,v in pairs(self.Effect) do
            self.Effect[i]:DeleteMe()
            self.Effect[i] = nil
        end
        self.Effect = nil
    end

    if self.NormalEffect ~= nil then
        for i,v in pairs(self.NormalEffect) do
            self.NormalEffect[i]:DeleteMe()
            self.NormalEffect[i] = nil
        end
        self.NormalEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ArborDayRewardWin:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arborDayReward_win))
    self.gameObject.name = "ArborDayRewardWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject,self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_secondarytopwin, {74,941,946})
        end)
    --CampaignManager.Instance.model:OpenSecondaryWindow()


    self.sureBtn = self.transform:FindChild("MainCon/Btn"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_secondarytopwin, {89,1124,1129}) end)

    --self.littleContainer = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/Item/RectScroll/Container")

    self.bigContainer = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")

    self.BigItem = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/Item")
    self.BigItem.gameObject:SetActive(false)
    --self.littleLuaBox = LuaBoxLayout.New(self.littleContainer,{axis = BoxLayoutAxis.X, cspacing = 0, border = 10})

    self.scrollRect = self.transform:Find("MainCon/FashionScrollRect"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function()
        self:OnRectScroll()
    end)

    self.bigLuaBox = LuaBoxLayout.New(self.bigContainer,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 1})
    for i = 1,10 do
        if self.rewardList[i] == nil then
            local tab = {}
            local go = GameObject.Instantiate(self.BigItem.gameObject)
            tab.gameObject = go
            --tab.transform = go.transform
            tab.slot = { }
            for k =1, 4 do
                tab.slot[k] =ItemSlot.New(go.transform:Find("ItemSlot"..k).gameObject)
            end
            tab.logo = go.transform:Find("Logo")
            tab.rightPoint = go.transform:Find("RightPoint")
            tab.Times = go.transform:Find("TimesNum/Text"):GetComponent(Text)

            tab.rightPoint.gameObject:SetActive(false)
            tab.logo.gameObject:SetActive(false)
            tab.slot[4].gameObject:SetActive(false)

            self.rewardList[i] = tab
        end
        self.bigLuaBox:AddCell(self.rewardList[i].gameObject)
    end
end

function ArborDayRewardWin:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ArborDayRewardWin:OnOpen()
    self:AddListeners()
    self.TweenId = 0
    self:SetData()
    --LuaTimer.Add(2000,function() self:BeforeMove() end)
    self:BeforeMove()
end

function ArborDayRewardWin:OnHide()
    self:RemoveListeners()
    if self.TimerId ~= nil then
        LuaTimer.Delete(self.TimerId)
        self.TimerId = nil
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end

    -- if self.rewardList ~= nil then
    --     for i,v in pairs(self.rewardList) do
    --         v.gameObject:DeleteMe()
    --         v = nil
    --     end
    --     self.rewardList = nil
    -- end
    if self.TweenTimer ~= nil then
        for i,v in pairs(self.TweenTimer) do
            Tween.Instance:Cancel(v)
            v = nil
        end
        self.TweenTimer = nil
    end

    if self.ContainerTweenTimer ~= nil then
        for i,v in pairs(self.ContainerTweenTimer) do
            Tween.Instance:Cancel(v)
            v = nil
        end
        self.ContainerTweenTimer = nil
    end

    if self.Effect ~= nil then
        for i,v in pairs(self.Effect) do
            self.Effect[i]:DeleteMe()
            self.Effect[i] = nil
        end
        self.Effect = nil
    end

    if self.NormalEffect ~= nil then
        for i,v in pairs(self.NormalEffect) do
            self.NormalEffect[i]:DeleteMe()
            self.NormalEffect[i] = nil
        end
        self.NormalEffect = nil
    end
end

function ArborDayRewardWin:AddListeners()
    self:RemoveListeners()
end

function ArborDayRewardWin:RemoveListeners()
end

function ArborDayRewardWin:OnClose()
end

function ArborDayRewardWin:SetData()
    for i = 1, 10 do
        self.rewardList[i].gameObject.transform.anchoredPosition = Vector2(-384, self.rewardList[i].gameObject.transform.anchoredPosition.y)
        self.rewardList[i].gameObject:SetActive(false)
    end

    self.returnReward = self.model.returnRewardlist
    --BaseUtils.dump(self.returnReward,"self.returnReward")
    self.drawEffectList = self.model.DrawEffectList
    if next(self.returnReward) ~= nil then
        -- for i,v in pairs (self.returnReward) do
        --     if self.drawEffectList[i] ~= nil then
        --         local singleReward = v.items
        --         for j,k in pairs(singleReward) do
        --             local info = ItemData.New()
        --             local base = DataItem.data_get[k.item_id]
        --             info:SetBase(base)
        --             self.rewardList[i].slot[j]:SetAll(info, {inbag = false, nobutton = true})
        --         end
        --         if self.drawEffectList[i] == 0 then
        --             self.rewardList[i].rightPoint.gameObject:SetActive(false)
        --             self.rewardList[i].logo.gameObject:SetActive(false)
        --             --weizhi
        --             self.rewardList[i].slot[4].gameObject:SetActive(false)
        --         else
        --             self.rewardList[i].rightPoint.gameObject:SetActive(true)
        --             self.rewardList[i].logo.gameObject:SetActive(true)
        --             local info2 = ItemData.New()
        --             local base2 = DataItem.data_get[self.drawEffectList[i]]
        --             info2:SetBase(base2)
        --             self.rewardList[i].slot[4]:SetAll(info2, {inbag = false, nobutton = true})
        --             self.rewardList[i].slot[4].gameObject:SetActive(true)
        --         end
        --         self.rewardList[i].Times.text = string.format(TI18N("第%s次抽奖"),BaseUtils.NumToChn(i))
        --     end

        -- end


        for i = 1,10 do
            if self.drawEffectList[i] ~= nil then
                local singleReward = self.returnReward[i].items
                for j,k in pairs(singleReward) do
                    local info = ItemData.New()
                    local base = DataItem.data_get[k.item_id]
                    info:SetBase(base)
                    self.rewardList[i].slot[j]:SetAll(info, {inbag = false, nobutton = true})
                end
                if self.drawEffectList[i] == 0 then
                    self.rewardList[i].rightPoint.gameObject:SetActive(false)
                    self.rewardList[i].logo.gameObject:SetActive(false)
                    --weizhi
                    self.rewardList[i].slot[4].gameObject:SetActive(false)
                else
                    self.rewardList[i].rightPoint.gameObject:SetActive(true)
                    self.rewardList[i].logo.gameObject:SetActive(true)
                    local info2 = ItemData.New()
                    local base2 = DataItem.data_get[self.drawEffectList[i]]
                    info2:SetBase(base2)
                    self.rewardList[i].slot[4]:SetAll(info2, {inbag = false, nobutton = true})

                    if self.NormalEffect[i] == nil then
                        self.NormalEffect[i] = BibleRewardPanel.ShowEffect(20223, self.rewardList[i].slot[4].gameObject.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
                    end

                    self.NormalEffect[i]:SetActive(true)

                    self.rewardList[i].slot[4].gameObject:SetActive(true)
                end
                self.rewardList[i].Times.text = string.format(TI18N("第%s次抽奖"),BaseUtils.NumToChn(i))
            end

        end
    end
end



function ArborDayRewardWin:BeforeMove()
    self.TimerId = LuaTimer.Add(0,400,function() self:SlowMove() end)
end

function ArborDayRewardWin:SlowMove()
    self.TweenId = self.TweenId + 1
    if self.TweenId > 10 then
        if self.TimerId ~= nil then
            LuaTimer.Delete(self.TimerId)
            self.TimerId = nil
        end
        return
    end
    if self.rewardList[self.TweenId].gameObject ~= nil then
        self.rewardList[self.TweenId].gameObject:SetActive(true)
        local x = self.rewardList[self.TweenId].gameObject.transform.anchoredPosition.x
        self.TweenTimer[self.TweenId] = Tween.Instance:ValueChange(x, x + 385, 0.3, function() self:ContainerTween()  end, LeanTweenType.easeOutQuart, function(value) self.rewardList[self.TweenId].gameObject.transform.anchoredPosition = Vector2(value, self.rewardList[self.TweenId].gameObject.transform.anchoredPosition.y) end).id

        if self.Effect[self.TweenId] == nil then
           self.Effect[self.TweenId] = BibleRewardPanel.ShowEffect(20465, self.rewardList[self.TweenId].gameObject.transform, Vector3(1, 1, 1),Vector3(200, -39, -400))
        end
        self.Effect[self.TweenId]:SetActive(true)
        self.timerId2 = LuaTimer.Add(220, function() self.Effect[self.TweenId]:SetActive(false) end)
    end
end

function ArborDayRewardWin:ContainerTween()

    if self.drawEffectList[self.TweenId] ~= 0 then
        self.rewardList[self.TweenId].slot[4].gameObject.transform.localScale = Vector3(1.2,1.1,1)
        Tween.Instance:Scale(self.rewardList[self.TweenId].slot[4].gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    end
    if self.TweenId > 2 and self.TweenId < 10 then
        local containerY = self.bigContainer.anchoredPosition.y
        self.ContainerTweenTimer[self.TweenId] = Tween.Instance:ValueChange(containerY, containerY + 79, 0.1, function() self:PlayEffect()  end, LeanTweenType.linear, function(value) self.bigContainer.anchoredPosition = Vector2(self.bigContainer.anchoredPosition.x, value) end).id
    end


    --查看是否需要播放相应动画特效
end

function ArborDayRewardWin:PlayEffect()

end


function ArborDayRewardWin:OnRectScroll(value)
    local container = self.scrollRect.content

    local top = -container.anchoredPosition.y
    local bottom = top - self.scrollRect.transform.sizeDelta.y

    for k,v in pairs(self.rewardList) do
        local ay = v.gameObject.transform.anchoredPosition.y
        local sy = v.gameObject.transform.sizeDelta.y
        local state = nil
        if ay > top or ay - sy < bottom then
            state = false
        else
            state = true
        end

        if v.slot[4].transform:FindChild("Effect") ~= nil then
            v.slot[4].transform:FindChild("Effect").gameObject:SetActive(state)
        end
    end
end