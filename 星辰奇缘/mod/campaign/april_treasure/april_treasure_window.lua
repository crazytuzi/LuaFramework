-- @author 111
-- @date 2018年3月13日,星期二

AprilTreasureWindow = AprilTreasureWindow or BaseClass(BaseWindow)

function AprilTreasureWindow:__init(model)
    self.model = model
    self.name = "AprilTreasureWindow"
    self.windowId = WindowConfig.WinID.AprilTreasure_win
    self.cacheMode = CacheMode.Visible
    self.resList = {
         {file = AssetConfig.aprilTreasure_win, type = AssetType.Main}
         ,{file = AssetConfig.apriltreasureBg, type = AssetType.Main}
         ,{file = AssetConfig.apriltreasure_Texture, type = AssetType.Dep}
         ,{file = AssetConfig.fashion_selection_show_big2, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.SetDataFunc = function(data)
        self:OnDrawReturn(data)
        self:SetSpecialData(data)
        self:SetTurnRewardpoint(data)
    end

    self.SetFirstDataFunc = function(data)
        self:SetSpecialData(data)
        self:SetRolePos(data)
        self:SetTurnRewardpoint(data)
    end

    self.SetEventIdFunc = function(num)
        self:SetEvent(num)
    end

    -- self.checkQuest = function(list)
    --     self:checkQuest(list)
    -- end

    self.SetLuckyNumFunc = function()
        self:UpdateLuckyNum()
    end

    self._onUpdateItem = function()
        self:OnUpdateItem()
    end

    self._OnUpdateRecord = function()
        self:OnUpdateRecord()
    end

    self.LengthX = 57
    self.LengthY = 33
    self.roleOffsetY = 48

    self.GridNum = 36

    --self.luckyDiceFun = function() self:DoluckyDice() end

    self.ItemPosByY = { }
    -- typeId 1是道具 2是货币 3是移动格 4是幸运骰子 5是事件格
    self.OriginItemPos = {
        {x = 0, y = 0, index = 1,typeId = 1, itemId = 20000 },
        {x = 0, y = 1, index = 2,typeId = 2 },
        {x = 0, y = 2, index = 3,typeId = 1, itemId = 20000 },
        {x = 0, y = 3, index = 4,typeId = 1, itemId = 20000 },
        {x = 1, y = 3.5, index = 5,typeId = 2 },

        {x = 1, y = 4.5, index = 6,typeId = 1, itemId = 20000 },
        {x = 0, y = 5, index = 7,typeId = 1, itemId = 20000 },
        {x = 0, y = 6, index = 8,typeId = 3 },
        {x = 1, y = 6.5, index = 9,typeId = 1, itemId = 20000 },
        {x = 2, y = 6, index = 10,typeId = 2 },

        {x = 3, y = 5.5, index = 11,typeId = 1, itemId = 20000 },
        {x = 3, y = 4.5, index = 12,typeId = 1, itemId = 20000 },
        {x = 3, y = 3.5, index = 13,typeId = 3 },
        {x = 4, y = 3, index = 14,typeId = 1, itemId = 20000 },
        {x = 5, y = 3.5, index = 15,typeId = 2 },

        {x = 5, y = 4.5, index = 16,typeId = 1, itemId = 20000 },
        {x = 5, y = 5.5, index = 17,typeId = 1, itemId = 20000 },
        {x = 5, y = 6.5, index = 18,typeId = 4 },
        {x = 6, y = 7, index = 19,typeId = 1, itemId = 20000 },
        {x = 7, y = 6.5, index = 20,typeId = 3 },

        {x = 7, y = 5.5, index = 21,typeId = 1, itemId = 20000 },
        {x = 7, y = 4.5, index = 22,typeId = 1, itemId = 20000 },
        {x = 7, y = 3.5, index = 23,typeId = 2 },
        {x = 7, y = 2.5, index = 24,typeId = 1, itemId = 20000 },
        {x = 6, y = 2, index = 25,typeId = 1, itemId = 20000 },

        {x = 6, y = 1, index = 26,typeId = 2 },
        {x = 7, y = 0.5, index = 27,typeId = 1, itemId = 20000 },
        {x = 7, y = -0.5, index = 28,typeId = 3 },
        {x = 6, y = -1, index = 29,typeId = 1, itemId = 20000 },
        {x = 5, y = -1.5, index = 30,typeId = 1, itemId = 20000 },

        {x = 4, y = -1, index = 31,typeId = 4 },
        {x = 4, y = 0, index = 32,typeId = 1, itemId = 20000 },
        {x = 3, y = 0.5, index = 33,typeId = 4 },
        {x = 2, y = 0, index = 34,typeId = 1, itemId = 20000 },
        {x = 1, y = -0.5, index = 35,typeId = 2 },
    }

    self.descMove = {TI18N("随机前进1-6格，或后退1-3格")}
    self.luckyDiceDesc = {TI18N("获得一个幸运骰子，使用后可自选任意前进步数1-6格")}

    self.CurrentIndex = 1     --人物的位置（当前格子）

    self.FreeLuckyDiceNum = 1   --可使用幸运骰子数

    self.Moving = false   --正在移动中。。。（对于 移动格 很重要的）

    self.moveDirection = 0   --(-1为退后  1为前进)


    self.timerId = { }   --定时器表
    self.tweenId = { }   --动画 表


    self.TargetGridId = -1

    --self.IsDraw = -1    --( 0 为普通抽奖  1-6 为幸运骰子 )

    self.GridEffect = { }   --格子特效
end

function AprilTreasureWindow:__delete()
    self:OnHide()

    if self.menu_3_effect ~= nil then
        self.menu_3_effect:DeleteMe()
        self.menu_3_effect = nil
    end

    if self.RewardEffect ~= nil then
        self.RewardEffect:DeleteMe()
        self.RewardEffect = nil
    end

    if self.msgBox ~= nil then
        self.msgBox:DeleteMe()
        self.msgBox = nil
    end

    if self.luckyMoveEffect ~= nil then
        self.luckyMoveEffect:DeleteMe()
        self.luckyMoveEffect = nil
    end

    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end

    if self.TargetDiceImage ~= nil then
        BaseUtils.ReleaseImage(self.TargetDiceImage)
        self.TargetDiceImage = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AprilTreasureWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.aprilTreasure_win))
    self.gameObject.name = "AprilTreasureWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject,self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.mainCon = self.transform:Find("MainCon")

    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.apriltreasureBg))
    UIUtils.AddBigbg(self.mainCon:Find("Bg/BigBg"), bigbg)

    self.msgContainer = self.mainCon:Find("RightCon/Record/Scroll/Container")
    self.msgItem = self.mainCon:Find("RightCon/Record/Scroll/Cloner").gameObject
    self.msgItem:SetActive(false)

    self.DiceBottomBg = self.mainCon:Find("RightCon/BottomArea/DiceBottomBg"):GetComponent(Image)
    self.DiceBottomBg.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big2,"FashionSelectionBottom")

    --左下角菜单
    --WindowManager.Instance:OpenWindowById(WindowConfig.WinID.AprilReward_win)
    self.menu_1 = self.mainCon:Find("MenuPanel/Menu1")
    self.menu_1:GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.AprilReward_win) end)
    if self.RewardEffect == nil then   --20256
        self.RewardEffect = BaseUtils.ShowEffect(20256, self.menu_1.gameObject.transform, Vector3(0.8, 0.8, 1), Vector3(0, 0, -100))
        self.RewardEffect:SetActive(false)
    end

    self.menu_2 = self.mainCon:Find("MenuPanel/Menu2")
    self.menu_2:GetComponent(Button).onClick:AddListener(function() self:DoluckyDice() end)

    self.menu_3 = self.mainCon:Find("MenuPanel/Menu3")
    if self.menu_3_effect == nil then
        self.menu_3_effect = BaseUtils.ShowEffect(20256, self.menu_3.gameObject.transform, Vector3(0.8, 0.8, 1), Vector3(0, 0, -100))
    end
    self.menu_3.gameObject:SetActive(false)
    self.menu_3:GetComponent(Button).onClick:AddListener(function()
        for k,v in pairs(QuestManager.Instance.questTab) do
            if v.sec_type == QuestEumn.TaskType.april_treasure then
                self.model.questId = v.id
                break
            end
        end
        self:ShowNoticePanel()

     end)
     --WindowManager.Instance:CloseWindow(self)

    self.DrawDice = self.transform:Find("MainCon/RightCon/BottomArea/Dice"):GetComponent(Button)
    self.DrawDice.onClick:AddListener(function() self:OnDrawDice() end)  --self:OnDrawDice()

    self.item1 = self.transform:Find("MainCon/Container/Item_1")
    self.item1.gameObject:SetActive(false)
    self.item2 = self.transform:Find("MainCon/Container/Item_2")
    self.item2.gameObject:SetActive(false)
    self.item3 = self.transform:Find("MainCon/Container/Item_3")
    self.item3.gameObject:SetActive(false)
    self.item4 = self.transform:Find("MainCon/Container/Item_4")
    self.item4.gameObject:SetActive(false)

    self.role = self.transform:Find("MainCon/Container/Role")
    self.role.gameObject:SetActive(false)
    self.headSlot = HeadSlot.New()
    NumberpadPanel.AddUIChild(self.role.transform:Find("Head/Image"), self.headSlot.gameObject)
    self.headSlot:SetAll(RoleManager.Instance.RoleData, {isSmall = true})

    self.container = self.transform:Find("MainCon/Container")

    self.luckyArea = self.container:Find("luckyArea")

    self.diceEffectArea = self.transform:Find("MainCon/DiceEffect")
    self.diceEffectArea.anchoredPosition = Vector2(-252,-200)
    self.TargetDiceImage = self.diceEffectArea:Find("ShowDiceNum"):GetComponent(Image)
    self.TargetDiceImage.transform.gameObject:SetActive(false)

    self.mainCon:Find("RightCon/SortData").transform.anchoredPosition = Vector2(0,7.25)

    self.remainTime = self.mainCon:Find("RightCon/SortData/RemainTime/Time"):GetComponent(Text)
    self.turnNum = self.mainCon:Find("RightCon/SortData/Turn/TurnNum"):GetComponent(Text)
    self.Score = self.mainCon:Find("RightCon/SortData/Score/ScoreNum"):GetComponent(Text)
    self.mainCon:Find("RightCon/SortData/Score").gameObject:SetActive(false)
    self.LuckyNum = self.mainCon:Find("MenuPanel/Menu2/Bg/num"):GetComponent(Text)
    self.DelayDrawTimes = self.mainCon:Find("RightCon/BottomArea/DelayTimes/ScoreNum"):GetComponent(Text)

    self.noticeBtn = self.mainCon:Find("RightCon/BottomArea/NoticeButton"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = self.tipsText})
        end)

    self:SetGridPos()
end

function AprilTreasureWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AprilTreasureWindow:OnOpen()
    self.mark = true
    self:AddListeners()
    AprilTreasureManager.Instance:send20450()
    AprilTreasureManager.Instance:send20449()
    self.Moving = false
    
    if self.openArgs ~= nil then
        self.campId = self.openArgs.campId
    end
    self.tipsText = {DataCampaign.data_list[self.campId].content}

    self.lossItemId = DataCampaign.data_list[self.campId].loss_items[1][1]  --touzi
    self.baseData = DataItem.data_get[self.lossItemId]


    if self.DrawDice ~= nil then
        self.DrawDice.transform.anchoredPosition = Vector2(0, 27)
        self.DrawDice.gameObject:SetActive(true)
    end
    if self.TargetDiceImage ~= nil then
        self.TargetDiceImage.transform.gameObject:SetActive(false)
    end

    self.TargetGridId = -1

    --骰子上下浮动
    if self.diceTimer == nil then
        self.diceTimer = LuaTimer.Add(0, 20, function() self:FloatSlot() end)
    end

    --self:SetRolePos(0)
    --self.IsDraw = -1
    self:CalculateTime()
    self:OnUpdateItem()
    self:checkDataQuest()
end

function AprilTreasureWindow:OnHide()
    self:RemoveListeners()

    if self.diceTimer ~= nil then
        LuaTimer.Delete(self.diceTimer)
        self.diceTimer = nil
    end

    if self.Moving == true then
        self.Moving = false
        AprilTreasureManager.Instance:send20447(1)
    end

    if self.TargetGridId ~= -1 then
        self.model.CurrPos = self.TargetGridId
    end

    for k,v in pairs(self.timerId) do
        LuaTimer.Delete(v)
        v = nil
    end
    self.timerId = {}

    for k,v in pairs(self.tweenId) do
        Tween.Instance:Cancel(v)
        v = nil
    end
    self.tweenId = {}

    if self.luckyMoveEffect ~= nil then
        self.luckyMoveEffect:SetActive(false)
    end

    if self.TargetDiceImage ~= nil then
        self.TargetDiceImage.transform.gameObject:SetActive(false)
        BaseUtils.ReleaseImage(self.TargetDiceImage)
    end
end

function AprilTreasureWindow:AddListeners()
    self:RemoveListeners()
    AprilTreasureManager.Instance.OnAprilDataUpdate:AddListener(self.SetDataFunc)
    AprilTreasureManager.Instance.OnFirstDataUpdate:AddListener(self.SetFirstDataFunc)
    AprilTreasureManager.Instance.OnEventIdUpdate:AddListener(self.SetEventIdFunc)
    AprilTreasureManager.Instance.OnLuckyNumUpdate:AddListener(self.SetLuckyNumFunc)
    AprilTreasureManager.Instance.OnRecordUpdate:AddListener(self._OnUpdateRecord)
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkQuest)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._onUpdateItem)

end

function AprilTreasureWindow:RemoveListeners()
    AprilTreasureManager.Instance.OnAprilDataUpdate:RemoveListener(self.SetDataFunc)
    AprilTreasureManager.Instance.OnFirstDataUpdate:RemoveListener(self.SetFirstDataFunc)
    AprilTreasureManager.Instance.OnEventIdUpdate:RemoveListener(self.SetEventIdFunc)
    AprilTreasureManager.Instance.OnLuckyNumUpdate:RemoveListener(self.SetLuckyNumFunc)
    AprilTreasureManager.Instance.OnRecordUpdate:RemoveListener(self._OnUpdateRecord)
    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkQuest)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._onUpdateItem)
end

function AprilTreasureWindow:SetRolePos(data)
    --self.CurrentIndex = data.grid_index           --  当前格子数
    self.CurrentIndex = self.model.CurrPos
    local x = self.ItemPos[self.CurrentIndex + 1].x
    local y = self.ItemPos[self.CurrentIndex + 1].y + self.roleOffsetY
    self.role.localPosition = Vector3(x, y, 0)
    self.role:SetSiblingIndex(50)
    self.role.gameObject:SetActive(true)

end

function AprilTreasureWindow:SetGridPos()
    self.OriginItemPos = {}
    for i=0, #DataZillionaireData.data_get_grid do
        self.OriginItemPos[i+1] = DataZillionaireData.data_get_grid[i]
    end

    if self.OriginItemPos ~= nil then
        for i = 1, #self.OriginItemPos do
            if self.ItemPosByY[i] == nil then
                local tab = { }
                tab.x = tonumber(self.OriginItemPos[i].grid_x) * self.LengthX -185
                tab.y = tonumber(self.OriginItemPos[i].grid_y) * self.LengthY -115
                tab.index = self.OriginItemPos[i].index + 1
                tab.typeId = self.OriginItemPos[i].grid_type
                tab.itemId = self.OriginItemPos[i].item_id
                self.ItemPosByY[i] = tab
            end
        end
    end

    --BaseUtils.dump(self.OriginItemPos,"self.OriginItemPos:")
    --BaseUtils.dump(self.ItemPosByY,"self.ItemPosByY:")
    table.sort(self.ItemPosByY, function(a, b)
        if a.y ~= b.y then
            return a.y > b.y
        else
            return false
        end
    end)
    --BaseUtils.dump(self.ItemPosByY,"self.ItemPosByY:")   --通过y轴排序的
    --按y轴设置子物体保证遮挡
    for i = 1, #self.OriginItemPos do
        if self.ItemPosByY[i] ~= nil then
            local go = nil
            go = GameObject.Instantiate(self.transform:Find("MainCon/Container/Item_"..self.ItemPosByY[i].typeId).gameObject)

            local customBtn = go.transform:GetComponent(CustomButton)
            customBtn.onClick:RemoveAllListeners()
            if self.ItemPosByY[i].typeId == 1 then
                local itemdata = ItemData.New()
                itemdata:SetBase(BackpackManager.Instance:GetItemBase(self.ItemPosByY[i].itemId))
                customBtn.onClick:AddListener(function()
                    TipsManager.Instance:ShowItem({gameObject = go, itemData = itemdata, extra = { nobutton = true } })
                 end)

            elseif self.ItemPosByY[i].typeId == 2 then
                customBtn.onClick:AddListener(function()
                    TipsManager.Instance:ShowText({gameObject = go, itemData = self.luckyDiceDesc})
                 end)
                -- customBtn.onClick:AddListener(function()
                --     TipsManager.Instance:ShowText({gameObject = go, itemData ={TI18N("金币银币多多多~")} })
                --  end)
            elseif self.ItemPosByY[i].typeId == 3 then
                customBtn.onClick:AddListener(function()
                    TipsManager.Instance:ShowText({gameObject = go, itemData ={TI18N("神秘惊喜一触即发！")} })
                 end)
            elseif self.ItemPosByY[i].typeId == 4 then
                customBtn.onClick:AddListener(function()
                    TipsManager.Instance:ShowText({gameObject = go, itemData = self.descMove})

                 end)
            end
            local GridEventData = DataZillionaireData.data_get_grid
            if GridEventData[self.ItemPosByY[i].index - 1].grid_type == 1 then
                local img = go.transform:Find("Img"):GetComponent(Image)
                local shader = go.transform:Find("Shader")
                img.gameObject:SetActive(true)
                self.headLoader = SingleIconLoader.New(img.gameObject)
                self.headLoader:SetSprite(SingleIconType.Item,DataItem.data_get[GridEventData[self.ItemPosByY[i].index - 1].item_id].icon)
                shader.gameObject:SetActive(true)

            end
            --BaseUtils.dump(GridEventData,"GridEventData:")
            if GridEventData[self.ItemPosByY[i].index - 1].is_effect == 1 then
                -- go.transform:Find("Img"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(source_id))
                local selected = go.transform:Find("Selected")
                selected.gameObject:SetActive(true)
                if self.GridEffect[i] == nil then
                    self.GridEffect[i] = BibleRewardPanel.ShowEffect(20266, selected, Vector3(0.7, 0.8, 1), Vector3(0, 40, -400))
                else
                    self.GridEffect[i]:SetActive(false)
                    self.GridEffect[i]:SetActive(true)
                end
            end

            go.transform:SetParent(self.container)
            go.transform.anchorMax = Vector2(0, 0)
            go.transform.anchorMin = Vector2(0, 0)
            go.transform.localPosition = Vector3(self.ItemPosByY[i].x, self.ItemPosByY[i].y, 0)
            --go.transform.localPosition = Vector3(tab.x, tab.y, 0)
            go.transform.localScale = Vector3(1, 1, 1)
            go:SetActive(true)
            self.ItemPosByY[i].item = go
        end
    end

    self.ItemPos = BaseUtils.copytab(self.ItemPosByY)
    table.sort(self.ItemPos, function(a, b)
        if a.index ~= b.index then
            return a.index < b.index
        else
            return false
        end
    end)
    --BaseUtils.dump(self.ItemPos,"self.ItemPos:")

end

function AprilTreasureWindow:UpdateLuckyNum()
    self.LuckyNum.text = TI18N(self.model.FreeLuckyDice - 1)
end


--任务状态改变时 调用
function AprilTreasureWindow:checkQuest()

end

--打开面板检测是否有奖励可领取 并显示红点
function AprilTreasureWindow:SetTurnRewardpoint(data)
    local isRed = false
    local currTimes = data.ring_times  --已轮回次数
    local ReceivedTurnTimes = data.ring_rewards
    local turnTotal = {1, 3, 6, 10}
    local index = 0
    for i,v in pairs(turnTotal) do
        if currTimes >= v then
            index = i
        end
    end
    if #ReceivedTurnTimes < index then
        isRed = true
    end

    if self.RewardEffect ~= nil then
        self.RewardEffect:SetActive(isRed)
    end
end
--面板打开时设置任务相关
function AprilTreasureWindow:checkDataQuest()
    -- local data = DataQuest.data_get[83698]
    -- local questData = QuestManager.Instance:GetQuest(data.id)

    local questData = nil
    for k,v in pairs(QuestManager.Instance.questTab) do
        if v.sec_type == 33 then
            questData = v
        end
    end

    if questData ~= nil and questData.finish == 1 then
        --领取了 未完成
        self.menu_3.gameObject:SetActive(true)
    else
        self.menu_3.gameObject:SetActive(false)
    end


end


function AprilTreasureWindow:SetSpecialData(data)
    self.turnNum.text = TI18N(data.ring_times)
    self.Score.text = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.zillionaire_sc) --寻宝积分
    self.LuckyNum.text = TI18N(data.lucky_dice)
end

--菜单二点击事件
function AprilTreasureWindow:DoluckyDice()
    self.FreeLuckyDiceNum = self.model.FreeLuckyDice
    if self.FreeLuckyDiceNum > 0 then
        if self.luckyPanel == nil then
            self.luckyPanel = AprilLuckyDicePanel.New(self.model, self.transform,self)
        end
        self.luckyPanel:Show()
    else
        --临时代码
        NoticeManager.Instance:FloatTipsByString("没有足够的幸运骰子哦~")
    end
end


function AprilTreasureWindow:OnLuckyReturn(index)
    --print("行走"..index.."步")

    local hasGuild = false
    for k,v in pairs(QuestManager.Instance.questTab) do
        if v.sec_type == QuestEumn.TaskType.april_treasure then
            self.model.questId = v.id
            hasGuild = true
            break
        end
    end
    if hasGuild == true then
        NoticeManager.Instance:FloatTipsByString("请先完成事件，再使用幸运骰子哟{face_1,3}")
        self:ShowNoticePanel()
        return
    end
    local num = index
    AprilTreasureManager.Instance:send20446(num)
    self.LuckyNum.text = TI18N(self.model.FreeLuckyDice - 1)

end

--投骰子
function AprilTreasureWindow:OnDrawDice()
    local hasGuild = false
    for k,v in pairs(QuestManager.Instance.questTab) do
        if v.sec_type == QuestEumn.TaskType.april_treasure then
            self.model.questId = v.id
            hasGuild = true
            break
        end
    end
    if hasGuild == true then
        NoticeManager.Instance:FloatTipsByString("请先完成事件，再使用幸运骰子哟{face_1,3}")

        self:ShowNoticePanel()

        return
    end

    --如果未达上限 且 消耗道具足够
    if BackpackManager.Instance:GetItemCount(self.lossItemId) >= 1 then
        --发协议啦
        -- if self.Moving == true then
        --     NoticeManager.Instance:FloatTipsByString("正在移动中,请稍后再进行抽奖")
        --     return
        -- end
        AprilTreasureManager.Instance:send20445()
        --self.IsDraw = 0
    else
        NoticeManager.Instance:FloatTipsByString("道具不足，无法进行抽奖哟")
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = self.baseData})
    end
end

function AprilTreasureWindow:OnDrawReturn(data)

    self.Moving = true

    self.TargetGridId = data.grid_index
    if self.TargetGridId == -1 then return end

    local moveNum = self.TargetGridId - self.model.CurrPos
    -- --print(moveNum.."")
    if math.abs(moveNum) > 6 then
        if moveNum < 0 then
            moveNum = moveNum + self.GridNum
        elseif moveNum > 0 then
            moveNum = moveNum - self.GridNum
        end
    end
    -- --print("移动格子:"..moveNum.."步")

    if AprilTreasureManager.Instance.rollpMark then
        self.DrawDice.gameObject:SetActive(false)
        --先播特效
        local TargetEffectPos = Vector3(0, 0, 0)   --目标位置
        if self.diceMoveEffect == nil then
            self.diceMoveEffect = BibleRewardPanel.ShowEffect(20474, self.diceEffectArea, Vector3(1, 1, 1), Vector3(0, 0, -400))
        else
            self.diceMoveEffect:SetActive(false)
            self.diceMoveEffect:SetActive(true)
        end
        if self.tweenId[5] ~= nil then
            Tween.Instance:Cancel(self.tweenId[5])
            self.tweenId[5] = nil
        end
        --self.tweenId[1] = Tween.Instance:MoveLocal(self.role.gameObject, Move_one, 0.3, function()  end, LeanTweenType.easeOutQuart).id

        if AprilTreasureManager.Instance.luckyRollpMark then
            self.DrawDice.gameObject:SetActive(true)
            self.diceEffectArea.localPosition = Vector3(-184, -216, 0)
            self.tweenId[5] = Tween.Instance:MoveLocal(self.diceEffectArea.gameObject, TargetEffectPos, 0.5, function()
                    --显示 设置点数
                    self.TargetDiceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.apriltreasure_Texture, string.format("Dice%s", math.abs(moveNum)))--..math.abs(moveNum)
                    self.TargetDiceImage.transform.gameObject:SetActive(true)
                end, LeanTweenType.linear).id
        else
            self.diceEffectArea.localPosition = Vector3(261, -98, 0)
            self.tweenId[5] = Tween.Instance:MoveLocal(self.diceEffectArea.gameObject, TargetEffectPos, 0.5, function()
                    --显示 设置点数
                    self.TargetDiceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.apriltreasure_Texture, string.format("Dice%s", math.abs(moveNum)))--..math.abs(moveNum)
                    self.TargetDiceImage.transform.gameObject:SetActive(true)
                end, LeanTweenType.linear).id
        end

        if self.timerId[5] ~= nil then
            LuaTimer.Delete(self.timerId[5])
            self.timerId[5] = nil
        end
        self.timerId[5] = LuaTimer.Add(1000,function()
            if self.diceMoveEffect ~= nil then
                self.diceMoveEffect:SetActive(false)
            end
            self.TargetDiceImage.transform.gameObject:SetActive(false)
            self.DrawDice.gameObject:SetActive(true)
        end)
    end
    AprilTreasureManager.Instance.rollpMark = false
    AprilTreasureManager.Instance.luckyRollpMark = false

    if self.timerId[4] ~= nil then
        LuaTimer.Delete(self.timerId[4])
        self.timerId[4] = nil
    end
    self.timerId[4] = LuaTimer.Add(800,function()
        -- --print(self.model.CurrPos.."self.model.CurrPos")
        local currIndex = self.model.CurrPos    --本次移动初始位置
        -- --print("本次移动初始位置"..currIndex)
        local tempIndex = 0
        self.movePos = moveNum                 --本次移动的步数
        self:RoleMove(currIndex, tempIndex)

        self.model.CurrPos = self.TargetGridId

        self.TargetGridId = -1
    end)
end

function AprilTreasureWindow:RoleMove(currIndex, tempIndex)

    local currIndex = currIndex    --本次移动时的初始位置  递增（或递减）
    if tempIndex < math.abs(self.movePos) then
        -- --print("走一步~")
        if self.tweenId[1] ~= nil then
            Tween.Instance:Cancel(self.tweenId[1])
            self.tweenId[1] = nil
        end
        if self.tweenId[2] ~= nil then
            Tween.Instance:Cancel(self.tweenId[2])
            self.tweenId[2] = nil
        end
        if self.movePos >= 0 then
            --print(currIndex.."currIndex")
            -- local Move_one = Vector3((self.ItemPos[(currIndex + 1) % 35 + 1].x + self.ItemPos[currIndex + 1].x)/2 , (self.ItemPos[(currIndex + 1) % 35 + 1].y + self.ItemPos[currIndex + 1].y)/2 + self.roleOffsetY + 2, 0)
            local Move_one = Vector3(self:GetPosX_Step1(self.ItemPos[(currIndex + 1) % self.GridNum + 1].x, self.ItemPos[currIndex + 1].x) , (self.ItemPos[(currIndex + 1) % self.GridNum + 1].y + self.ItemPos[currIndex + 1].y)/2 + self.roleOffsetY + 2, 0)
            self.tweenId[1] = Tween.Instance:MoveLocal(self.role.gameObject, Move_one, 0.1, function()  end, LeanTweenType.easeOutQuart).id
            if self.timerId[1] ~= nil then
                LuaTimer.Delete(self.timerId[1])
                self.timerId[1] = nil
            end

            self.timerId[1] = LuaTimer.Add(100,function()
                local Move_two = Vector3(self.ItemPos[(currIndex + 1) % self.GridNum + 1].x, self.ItemPos[(currIndex + 1) % self.GridNum + 1].y + self.roleOffsetY, 0)
                self.tweenId[2] = Tween.Instance:MoveLocal(self.role.gameObject, Move_two, 0.1, function()  self:RoleMove((currIndex + 1) % self.GridNum, tempIndex + 1) end, LeanTweenType.easeInQuart).id
            end)
        elseif self.movePos < 0 then
            --print(currIndex.."currIndex")
            local temp = currIndex
            if temp == 0 then temp = self.GridNum end
            -- local Move_one = Vector3((self.ItemPos[(currIndex + 1)].x + self.ItemPos[temp].x)/2 , (self.ItemPos[(currIndex + 1)].y + self.ItemPos[temp].y)/2 + self.roleOffsetY + 2, 0)
            local Move_one = Vector3(self:GetPosX_Step1(self.ItemPos[(currIndex + 1)].x, self.ItemPos[temp].x), (self.ItemPos[(currIndex + 1)].y + self.ItemPos[temp].y)/2 + self.roleOffsetY + 2, 0)
            self.tweenId[1] = Tween.Instance:MoveLocal(self.role.gameObject, Move_one, 0.1, function()  end, LeanTweenType.easeOutQuart).id
            if self.timerId[1] ~= nil then
                LuaTimer.Delete(self.timerId[1])
                self.timerId[1] = nil
            end

            self.timerId[1] = LuaTimer.Add(100,function()
                local Move_two = Vector3(self.ItemPos[temp].x, self.ItemPos[temp].y + self.roleOffsetY, 0)
                self.tweenId[2] = Tween.Instance:MoveLocal(self.role.gameObject, Move_two, 0.1, function()  self:RoleMove((currIndex - 1) % self.GridNum, tempIndex + 1) end, LeanTweenType.easeInQuart).id
            end)
        end

        --石墩上下移动
        if self.timerId[2] ~= nil then
            LuaTimer.Delete(self.timerId[2])
            self.timerId[2] = nil
        end

        local stoneIndex = currIndex + 1
        if self.movePos < 0 then
            stoneIndex = currIndex - 1
        end
        self.timerId[2] = LuaTimer.Add(190,function()
            local currGo = self.ItemPos[(stoneIndex % self.GridNum + 1)].item
            local currGoY = currGo.transform.localPosition.y
            currGo.transform.localPosition = currGo.transform.localPosition - Vector3(0, 10, 0)
            if self.tweenId[3] ~= nil then
                Tween.Instance:Cancel(self.tweenId[3])
                self.tweenId[3] = nil
            end
            self.tweenId[3] = Tween.Instance:MoveLocalY(currGo, currGoY, 0.3,nil,LeanTweenType.easeOutQuart).id
        end)
    else
        --移动完了   --待优化  需考虑提前关闭面板等操作
        AprilTreasureManager.Instance:send20447(1)   --运动完了,告诉服务端
        self.Moving = false
        self.movePos = 0
        self:checkDataQuest()
        return
    end
end
--根据事件id设置动作
function AprilTreasureWindow:SetEvent(eventId)

    --print("eventId"..eventId)

    --local CurrEvent = eventId
    local CurrEventType = DataZillionaireData.data_get_event[eventId].event_type
    if CurrEventType == "npc_talk" then
        --人物对话
        local npcId = DataZillionaireData.data_get_event[eventId].npc
        local npcMsg = DataZillionaireData.data_get_event[eventId].npc_msg
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[npcId])
        extra.base.buttons = {}
        extra.base.plot_talk = TI18N(npcMsg)
        --MainUIManager.Instance.dialogModel:SetTimeoutClose(500)
        MainUIManager.Instance.dialogModel:Open(DataUnit.data_unit[npcId], extra, true)
        MainUIManager.Instance.dialogModel:SetAnywayCallback(function()
            local reward = { }
            reward.item_list = {}
            for i,v in pairs(DataZillionaireData.data_get_event[eventId].rewards) do
                local item = { }
                item.item_id = v[1]
                item.val = v[2]
                table.insert(reward.item_list, item)
            end
            --reward.item_list = self.model.CurrReward
            if reward ~= nil then
                self.model:OpenGiftShow(reward)
                --self.model.CurrReward = { }
            end
        end)

    elseif CurrEventType == "quest" then
        --任务
        local hasGuild = false
        for k,v in pairs(QuestManager.Instance.questTab) do
            if v.sec_type == QuestEumn.TaskType.april_treasure then
                self.model.questId = v.id
                hasGuild = true
                break
            end
        end
        if hasGuild == true then
            self:ShowNoticePanel()
        end
    elseif CurrEventType == "lucky_dice" then
        --幸运骰子   播放从格子到menu_2的动画
        --Vector3(self.ItemPos[self.model.CurrPos + 1].x, self.ItemPos[self.model.CurrPos + 1].y + self.roleOffsetY, -400)
        --print("幸运骰子")
        local TargetEffectPos = Vector3(-150, -240, 0)   --目标位置
        if self.luckyMoveEffect == nil then
            self.luckyMoveEffect = BibleRewardPanel.ShowEffect(20471, self.luckyArea, Vector3(1, 1, 1), Vector3(0, 0, -400))
        else
            self.luckyMoveEffect:SetActive(false)
            self.luckyMoveEffect:SetActive(true)
        end
        if self.tweenId[4] ~= nil then
            Tween.Instance:Cancel(self.tweenId[4])
            self.tweenId[4] = nil
        end
        self.luckyArea.localPosition = Vector3(self.ItemPos[self.model.CurrPos + 1].x, self.ItemPos[self.model.CurrPos + 1].y + self.roleOffsetY, 0)
        self.tweenId[4] = Tween.Instance:MoveLocal(self.luckyArea.gameObject, TargetEffectPos, 1.0, function()
                self.luckyMoveEffect:SetActive(false)
                self.LuckyNum.text = TI18N(self.model.FreeLuckyDice)
                self.luckyArea.localPosition = Vector3(0, 0, 0)
            end).id

    elseif CurrEventType == "item" then
        --道具 银币
        local reward = { }
        reward.item_list = self.model.CurrReward
        if reward ~= nil then
            self.model:OpenGiftShow(reward)
            self.model.CurrReward = { }
        end
    end
end

function AprilTreasureWindow:ShowNoticePanel()

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Sure
    data.content = ""
    if #DataQuest.data_get[self.model.questId].progress > 0 then
        local str = DataQuest.data_get[self.model.questId].progress[1].desc
        str = string.gsub(str, "%[", "")
        str = string.gsub(str, "%]", "")
        data.content = str
    end
    data.sureLabel = TI18N("前往")
    data.sureCallback = function()
        --去到对应的频道
        if self.model.questId == 83698 or self.model.questId == 83700 then
            WindowManager.Instance:CloseCurrentWindow()
            ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.Guild})
            if self.timerId[6] ~= nil then
                LuaTimer.Delete(self.timerId[6])
                self.timerId[6] = nil
            end
            self.timerId[6] = LuaTimer.Add(500,function()
                if ChatManager.Instance.model.chatWindow ~= nil then
                    ChatManager.Instance.model.chatWindow:AppendInput(DataZillionaireData.data_get_task[self.model.questId].task_msg)
                end
            end)

        else
            WindowManager.Instance:CloseCurrentWindow()
            ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.World})
            if self.timerId[6] ~= nil then
                LuaTimer.Delete(self.timerId[6])
                self.timerId[6] = nil
            end
            self.timerId[6] = LuaTimer.Add(500,function()
                if ChatManager.Instance.model.chatWindow ~= nil then
                    ChatManager.Instance.model.chatWindow:AppendInput(DataZillionaireData.data_get_task[self.model.questId].task_msg)
                end
            end)

        end
        QuestManager.Instance:DoQuest(QuestManager.Instance:GetQuest(self.model.questId))
        if self.menu_3.gameObject.activeSelf == false then
            self.menu_3.gameObject:SetActive(true)
        end
    end
    NoticeManager.Instance:ConfirmTips(data)
end















function AprilTreasureWindow:CalculateTime()
    if self.timerId[3] ~= nil then
        LuaTimer.Delete(self.timerId[3])
        self.timerId[3] = nil
    end

    self.timerId[3] = LuaTimer.Add(0,1000,function() self:ShowDelayTime() end)
end

function AprilTreasureWindow:ShowDelayTime()

    local nowTime = BaseUtils.BASE_TIME
    local beginTimeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[self.campId].cli_end_time[1]

    local beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    local endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    if nowTime > beginTime and nowTime < endTime then
        local h = math.floor((endTime - nowTime) / 3600)
        local mm = math.floor(((endTime - nowTime) - (h * 3600)) / 60)
        local ss = math.floor((endTime - nowTime) - (h * 3600) - (mm * 60))
        if h >= 0 and h <= 9 then
            h = "0"..h
        end
        if mm >= 0 and mm <= 9 then
            mm = "0"..mm
        end
        if ss >= 0 and ss <= 9 then
            ss = "0"..ss
        end
        self.remainTime.text = TI18N(h .."时"..mm .."分"..ss.."秒")
    else
        self.remainTime.text = TI18N("活动未开启")
    end
end

function AprilTreasureWindow:OnUpdateItem()
    self.DelayDrawTimes.text = BackpackManager.Instance:GetItemCount(self.lossItemId)   -- 剩余的骰子数量
end

function AprilTreasureWindow:OnUpdateRecord()
    if self.msgBox == nil then
        self.msgBox = CustomRecordMsg.New(AprilTreasureManager.Instance, self.msgContainer, self.msgItem, 210)
        self.msgBox.container.anchoredPosition = Vector2(0,0)
    end

    AprilTreasureManager.Instance.onMsgEvent:RemoveListener(self._OnUpdateRecord)
end

-- x1下一格子，x2当前格子
function AprilTreasureWindow:GetPosX_Step1(x1, x2)
    if x1 == x2 then
        return x1
    elseif x1 > x2 then
        return (x1 - x2) * 0.7 + x2
    elseif x1 < x2 then
        return (x2 - x1) * 0.3 + x1
    end
end

function AprilTreasureWindow:FloatSlot()
    self.counter = (self.counter or 0) + 1
    self.DrawDice.transform.anchoredPosition = Vector2(0, 32 + 8 * math.sin(self.counter / 9))
end
