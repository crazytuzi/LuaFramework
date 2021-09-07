-- @author pwj
-- @date 2018年2月26日,星期一

ArborDayShakePanel = ArborDayShakePanel or BaseClass(BasePanel)

function ArborDayShakePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ArborDayShakePanel"

    self.resList = {
         {file = AssetConfig.arborDayShake_panel, type = AssetType.Main}
         ,{file = AssetConfig.ArborDayBg, type = AssetType.Main}
         ,{file = AssetConfig.arborDayShake_texture, type = AssetType.Dep}
         ,{file = AssetConfig.logobg, type = AssetType.Dep}
         ,{file = AssetConfig.logotitleI18N, type = AssetType.Dep}
         ,{file = AssetConfig.ArborDayShakeBg, type = AssetType.Dep}
         ,{file = AssetConfig.ArborDayShakeShader, type = AssetType.Dep}
         ,{file = AssetConfig.childbirth_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.timeFormatString1 = TI18N("%s小时%s分%s秒")
    self.timeFormatString2 = TI18N("%s分%s秒")
    self.timeFormatString3 = TI18N("%s秒")
    self.timeFormatString4 = TI18N("今日活动已结束")

    --self.targetMomont = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2], day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}

    self.rewardList = { }
    self.rewardNums = {}   --协议返回的三个位置

    self.LuaTweenList = {{}, {}, {}}       --timer列表
    self.shakeColumnNum = 8

    self.topIndex = {1, 1, 1}
    self.cspacing = 16

    self.DrawReturnFunc = function(items)
        self:OnDrawReturn(items)
    end

    --self.clickSelf = function() self:ReWriteClickSelf() end

    self.firstTimes = {1,1,1}

    self.columnTag = {0,0,0}

    --self.rewardIdsList = {{}, {}, {}}   --右侧展示奖励(三列)

    self.rewardsIndexs = { }   --收到协议后计算出的索引位置

    self.slowTimes = {0,0,0}   --减速时的计数器
    --self.slowDelayTime = {0.19,0,0}   --减速时的时间间隔
    self.slowDown = {false, false, false}  --三列是否减速标志

    self.part = 1

    self.RightRewardItem = {{}, {}, {}}
    self.lastAllIndex = {2, 2, 2}

    self.rotating = false  --是否正在抽奖

    self.ShowDoStop = false  --是否展示转动结束（进入面板会自动转动展示）

    self.BeforeTopIndex = {}  --记录展示停止时topindex的值

    self.DrawType = 0    --抽奖类型   0为默认值 (1  10)

    self.RightYY = 0

    self.lossItemId = 70192

    self.effect = { }   --左侧道具特效

    self.IsStopScroll = false



end

function ArborDayShakePanel:__delete()
    self.OnHideEvent:Fire()

    if self.msgBox ~= nil then
        self.msgBox:DeleteMe()
        self.msgBox = nil
    end
    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end

    if self.timerId4 ~= nil then
        LuaTimer.Delete(self.timerId4)
        self.timerId4 = nil
    end

    if self.timerId5 ~= nil then
        LuaTimer.Delete(self.timerId5)
        self.timerId5 = nil
    end

    if self.HideEffectTimer ~= nil then
        LuaTimer.Delete(self.HideEffectTimer)
        self.HideEffectTimer = nil
    end

    if self.flashEffect ~= nil then
        self.flashEffect:DeleteMe()
        self.flashEffect = nil
    end

    if self.SaoflashEffect ~= nil then
        self.SaoflashEffect:DeleteMe()
        self.SaoflashEffect = nil
    end
    if self.OwnShowEffect ~= nil then
        self.OwnShowEffect:DeleteMe()
        self.OwnShowEffect = nil
    end

    if self.effect ~= nil then
        for _,v in pairs (self.effect) do
            v:DeleteMe()
            v = nil
        end
    end

    if self.shakeList ~= nil then
        for i = 1,3 do
            for j =1, self.shakeColumnNum do
                if self.shakeList[i][j] ~= nil then
                    self.shakeList[i][j]:DeleteMe()
                end
            end
        end
        self.shakeList = nil
    end

    for i = 1,3 do
        for j = 1, self.shakeColumnNum do
            if self.LuaTweenList[i][j] ~= nil then
                Tween.Instance:Cancel(self.LuaTweenList[i][j])
                self.LuaTweenList[i][j] = nil
            end
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ArborDayShakePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arborDayShake_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.bg = self.transform:Find("Main/Background")
    UIUtils.AddBigbg(self.bg, GameObject.Instantiate(self:GetPrefab(AssetConfig.ArborDayBg)))


    self.remainTimeDesc = t:Find("Main/DelayTime"):GetComponent(Text)
    self.remainTime = t:Find("Main/DelayTime/Time"):GetComponent(Text)

    self.dateText = t:Find("Main/DataTime/Text"):GetComponent(Text)

    self.exchangeBtn = t:Find("Main/ExchangeBtn"):GetComponent(Button)
    self.exchangeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {1130}) end)

    self.NoticeBtn = t:Find("Main/ShakeArea/Notice/NoticeImg"):GetComponent(Button)
    self.NoticeBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.NoticeBtn.gameObject, itemData = {DataCampaign.data_list[self.campId].cond_desc}}) end)

    self.ArborDayShakeBg = t:Find("Main/ShakeArea"):GetComponent(Image)
    self.ArborDayShakeBg.sprite = self.assetWrapper:GetSprite(AssetConfig.ArborDayShakeBg, "ArborDayShakeAreaBgI18N")

    self.showEffectArea = t:Find("Main/ShakeArea/ShowArea")
    self.ArborDayShowBg = t:Find("Main/ShakeArea/ShowArea/Image"):GetComponent(Image)
    self.ArborDayShowBg.sprite = self.assetWrapper:GetSprite(AssetConfig.ArborDayShakeShader, "ArborDayShakeshader")

    self.logoBg = t:Find("Main/ShakeArea/LogoBg"):GetComponent(Image)
    self.logoBg.sprite = self.assetWrapper:GetSprite(AssetConfig.logobg, "ArborDaylogoBg")
    self.logotitleI18N = t:Find("Main/ShakeArea/LogoBg/LogoI18n"):GetComponent(Image)
    self.logotitleI18N.sprite = self.assetWrapper:GetSprite(AssetConfig.logotitleI18N, "ArborDaylogoTI18N")

    self.singleDraw = t:Find("Main/ShakeArea/SingleDraw"):GetComponent(CustomButton)
    self.singleDrawImage = t:Find("Main/ShakeArea/SingleDraw/Image"):GetComponent(Image)
    self.singleDrawBg = t:Find("Main/ShakeArea/SingleDraw"):GetComponent(Image)
    self.singleDraw.onClick:AddListener(function() self:OnDrawBtn(1) end)
    self.singleDraw.onDown:AddListener(function() self:OnSingleBtnDown() end)
    self.singleDraw.onUp:AddListener(function() self:OnSingleBtnUp() end)

    self.tenDraw = t:Find("Main/ShakeArea/TenDraw"):GetComponent(CustomButton)
    self.tenDrawImage = t:Find("Main/ShakeArea/TenDraw/Image"):GetComponent(Image)
    self.tenDrawBg = t:Find("Main/ShakeArea/TenDraw"):GetComponent(Image)
    self.tenDraw.onClick:AddListener(function() self:OnDrawBtn(10) end)
    self.tenDraw.onDown:AddListener(function() self:OnTenBtnDown() end)
    self.tenDraw.onUp:AddListener(function() self:OnTenBtnUp() end)



    self.ownNum = t:Find("Main/ShakeArea/OwnNum"):GetComponent(Text)
    self.slotMachineScore = t:Find("Main/Point/PointNum"):GetComponent(Text)

    --设位置
    t:Find("Main/Point").anchoredPosition = Vector2(-272, -151)
    t:Find("Main/DelayTime").anchoredPosition = Vector2(-312, -181)
    t:Find("Main/ExchangeBtn").anchoredPosition = Vector2(-107, -166)

    self.rewardItem = t:Find("Main/RewardScroll/Item").gameObject
    self.rewardItem:SetActive(false)

    self.msgContainer = t:Find("Main/Record/Scroll/Container")
    self.msgItem = t:Find("Main/Record/Scroll/Cloner").gameObject
    self.msgItem:SetActive(false)

    self.rewardContainer = t:Find("Main/RewardScroll/Container")
    self.rewardLuaBox = LuaBoxLayout.New(self.rewardContainer,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    local AllleftRewardData = DataCampSlotMachine.data_column
    local leftRewardData = { }
    for i,v in pairs(AllleftRewardData) do
        if v.is_effect == 1 then
            table.insert(leftRewardData, v)
        end
    end
    for i = 1,#leftRewardData do
        if self.rewardList[i] == nil then
            local tab = {}
            local go = GameObject.Instantiate(self.rewardItem)
            tab.gameObject = go
            tab.solt_one = ItemSlot.New(go.transform:Find("ItemSlot1").gameObject)
            tab.solt_two = ItemSlot.New(go.transform:Find("ItemSlot2").gameObject)
            tab.solt_three = ItemSlot.New(go.transform:Find("ItemSlot3").gameObject)
            tab.solt_four = ItemSlot.New(go.transform:Find("ItemSlot4").gameObject)
            self.rewardList[i] = tab
        end
        self.rewardLuaBox:AddCell(self.rewardList[i].gameObject)
    end

    self.shakelistContainer1 = t:Find("Main/ShakeArea/ShowArea/Scroll1/Container")
    self.shakelistLuaBox_One = LuaBoxLayout.New(self.shakelistContainer1,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 16})

    self.shakelistContainer2 = t:Find("Main/ShakeArea/ShowArea/Scroll2/Container")
    self.shakelistLuaBox_Two = LuaBoxLayout.New(self.shakelistContainer2,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 16})

    self.shakelistContainer3 = t:Find("Main/ShakeArea/ShowArea/Scroll3/Container")
    self.shakelistLuaBox_Three = LuaBoxLayout.New(self.shakelistContainer3,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 16})

    self.scrollRect = self.transform:Find("Main/RewardScroll"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function()
        self:OnRectScroll()
    end)

end

function ArborDayShakePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ArborDayShakePanel:OnOpen()
    --1
    ArborDayShakeManager.Instance:send20440()
    self:RemoveListeners()
    ArborDayShakeManager.Instance.onDrawReturn:AddListener(self.DrawReturnFunc)
    self.lossItemId = DataCampaign.data_list[self.campId].loss_items[1][1]
    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local y = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
    self.dailyStart = os.time{year = y, month = m, day = d, hour = 19, min = 0, sec = 0}
    self.dailyEnd = os.time{year = y, month = m, day = d, hour = 23, min = 0, sec = 0}

    self.shakelistLuaBox_One:ReSet()
    self.shakelistLuaBox_Two:ReSet()
    self.shakelistLuaBox_Three:ReSet()
    self.rewardLuaBox:ReSet()

    self.shakeList = {{}, {}, {}}       --三列数据
    self.topIndex = {1, 1, 1}
    self.rotating = false  --是否正在抽奖
    self.timerId2 = LuaTimer.Add(1000, 3000, function() self:ShowBeforeRoll() end)
    self.rewardsIndexs = {4, 1, 2}
    self.IsStopScroll = false
    self.slowDown = {false, false, false}  --三列是否减速标志
    self.shakeColumnNum = 8

    for i = 1 ,3 do
        self.slowTimes[i] = 0
        self.columnTag[i] = 0
    end
    self.firstTimes = {1, 1, 1}
    self.RightYY = 0


    self:SetConsumeNum()
    self.DrawType = 0
    self:SetLeftRewardData()
    self:SetRightRewardData()
    self:CalculateTime()
    if self.msgBox == nil then
        self.msgBox = ArborDayShakeMsg.New(self.msgContainer, self.msgItem)
        self.msgBox.container.anchoredPosition = Vector2(0,0)
    end
    self.HideEffectTimer = LuaTimer.Add(300,function() self:OnRectScroll() end)
end

function ArborDayShakePanel:OnSingleBtnDown()
    self.singleDrawImage.gameObject:SetActive(false)
    --BtnPressI18N
    self.singleDrawBg.sprite = self.assetWrapper:GetSprite(AssetConfig.arborDayShake_texture, "BtnPressI18N")
end

function ArborDayShakePanel:OnSingleBtnUp()
    self.singleDrawImage.gameObject:SetActive(true)
    self.singleDrawBg.sprite = self.assetWrapper:GetSprite(AssetConfig.arborDayShake_texture, "DrawBtn")
end


function ArborDayShakePanel:OnTenBtnDown()
    self.tenDrawImage.gameObject:SetActive(false)
    --BtnPress2I18N
    self.tenDrawBg.sprite = self.assetWrapper:GetSprite(AssetConfig.arborDayShake_texture, "BtnPress2I18N")
end

function ArborDayShakePanel:OnTenBtnUp()
    self.tenDrawImage.gameObject:SetActive(true)
        self.tenDrawBg.sprite = self.assetWrapper:GetSprite(AssetConfig.arborDayShake_texture, "DrawBtn")
end

function ArborDayShakePanel:OnHide()
    self:RemoveListeners()

    if self.DrawType ~= 0 then
        ArborDayShakeManager.Instance:send20435()
        self.DrawType = 0
    end

    if self.shakeList ~= nil then
        for i = 1,3 do
            for j =1, self.shakeColumnNum do
                if self.shakeList[i][j] ~= nil then
                    self.shakeList[i][j]:DeleteMe()
                end
            end
        end
        self.shakeList = nil
    end

    for i = 1,3 do
        for j = 1, self.shakeColumnNum do
            if self.LuaTweenList[i][j] ~= nil then
                Tween.Instance:Cancel(self.LuaTweenList[i][j])
                self.LuaTweenList[i][j] = nil
            end
        end
    end

    if self.msgBox ~= nil then
        self.msgBox:DeleteMe()
        self.msgBox = nil
    end

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end

    if self.timerId4 ~= nil then
        LuaTimer.Delete(self.timerId4)
        self.timerId4 = nil
    end

    if self.timerId5 ~= nil then
        LuaTimer.Delete(self.timerId5)
        self.timerId5 = nil
    end

    if self.flashEffect ~= nil then
        self.flashEffect:DeleteMe()
        self.flashEffect = nil
    end
    if self.OwnShowEffect ~= nil then
        self.OwnShowEffect:DeleteMe()
        self.OwnShowEffect = nil
    end
    if self.SaoflashEffect ~= nil then
        self.SaoflashEffect:DeleteMe()
        self.SaoflashEffect = nil
    end
    if self.HideEffectTimer ~= nil then
        LuaTimer.Delete(self.HideEffectTimer)
        self.HideEffectTimer = nil
    end

    if self.effect ~= nil then
        for _,v in pairs (self.effect) do
            v:DeleteMe()
            v = nil
        end
    end
end

function ArborDayShakePanel:RemoveListeners()
    ArborDayShakeManager.Instance.onDrawReturn:RemoveListener(self.DrawReturnFunc)
end

function ArborDayShakePanel:SetConsumeNum()
    --BaseUtils.dump(RoleManager.Instance.RoleData,"RoleManager.Instance.RoleData")
    self.ownNum.text = BackpackManager.Instance:GetItemCount(self.lossItemId)
    self.slotMachineScore.text = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.slot_machine)
end

--设置左边奖励数据
function ArborDayShakePanel:SetLeftRewardData()
    --self.rewardList[i]  --每行四个solt存放
    local AllleftRewardData = DataCampSlotMachine.data_column
    local leftRewardData = { }
    for i,v in pairs(AllleftRewardData) do
        if v.is_effect == 1 then
            table.insert(leftRewardData, v)
        end
    end
    if leftRewardData ~= nil then
        for i = 1, #leftRewardData do
            local itemData1 = ItemData.New()
            itemData1:SetBase(DataItem.data_get[leftRewardData[i].item_id1])
            self.rewardList[i].solt_one:SetAll(itemData1, {inbag = false, nobutton = true})
            --self.rewardList[i].solt_one:SetNum(data.num)
            local itemData2 = ItemData.New()
            itemData2:SetBase(DataItem.data_get[leftRewardData[i].item_id2])
            self.rewardList[i].solt_two:SetAll(itemData2, {inbag = false, nobutton = true})

            local itemData3 = ItemData.New()
            itemData3:SetBase(DataItem.data_get[leftRewardData[i].item_id3])
            self.rewardList[i].solt_three:SetAll(itemData3, {inbag = false, nobutton = true})

            local itemData4 = ItemData.New()
            itemData4:SetBase(DataItem.data_get[leftRewardData[i].reward[1][1]])
            self.rewardList[i].solt_four:SetAll(itemData4, {inbag = false, nobutton = true})
            self.rewardList[i].solt_four:SetNum(leftRewardData[i].reward[1][2])
            if leftRewardData[i].is_effect == 1 then
                if self.effect[i] == nil then
                    self.effect[i] = BibleRewardPanel.ShowEffect(20223, self.rewardList[i].solt_four.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
                end
                self.effect[i]:SetActive(true)
            end
        end
    end
end

function ArborDayShakePanel:SetRightRewardData()
    local rightRewardList = DataCampSlotMachine.data_reward

    if rightRewardList ~= nil then
        for _,v in pairs(rightRewardList) do
            if v.index == 1 then
                table.insert(self.RightRewardItem[1], v)
            elseif v.index == 2 then
                table.insert(self.RightRewardItem[2], v)
            elseif v.index == 3 then
                table.insert(self.RightRewardItem[3], v)
            end
        end
        --BaseUtils.dump(self.RightRewardItem, "self.RightRewardItem")
        for i = 1,3 do
            for j =1, self.shakeColumnNum do
                if self.shakeList[i][j] == nil then
                    local itemslot = ItemSlot.New()
                    local info = ItemData.New()
                    local base = DataItem.data_get[self.RightRewardItem[i][(i-1) * self.shakeColumnNum + j].item_id]
                    info:SetBase(base)
                    itemslot:SetAll(info, {inbag = false, nobutton = true})
                    itemslot.button.onClick:RemoveAllListeners()
                    --self.clickSelf
                    itemslot.button.onClick:AddListener(function() self:ReWriteClickSelf(itemslot) end)
                    self.shakeList[i][j] = itemslot
                end
                if i == 1 then
                    self.shakelistLuaBox_One:AddCell(self.shakeList[i][j].gameObject)
                elseif i == 2 then
                    self.shakelistLuaBox_Two:AddCell(self.shakeList[i][j].gameObject)
                elseif i == 3 then
                    self.shakelistLuaBox_Three:AddCell(self.shakeList[i][j].gameObject)
                end
            end
        end
    end
end

--抽奖按钮按下
function ArborDayShakePanel:OnDrawBtn(i)
    -- if Application.platform ~= RuntimePlatform.IPhonePlayer and Application.platform ~= RuntimePlatform.Android then
    -- end
    --if BaseUtils.BASE_TIME >= self.dailyStart and BaseUtils.BASE_TIME < self.dailyEnd then
        if self.rotating == true then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在抽奖中，请稍后再进行抽奖~"))
            return
        end
        self.DrawType = i
        if self.DrawType == 1 then
            if BackpackManager.Instance:GetCurrentGirdNum() <= 0 then
               NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理后再进行抽奖"))
               return
            else
                if BackpackManager.Instance:GetItemCount(self.lossItemId) >= i then
                    ArborDayShakeManager.Instance:send20434(i)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("抽奖道具不足，前往获取吧"))
                    TipsManager.Instance:ShowItem({gameObject = nil, itemData = DataItem.data_get[self.lossItemId]})
                end
            end
        elseif self.DrawType == 10 then
            -- if BackpackManager.Instance:GetCurrentGirdNum() <= 10 then
            --    NoticeManager.Instance:FloatTipsByString(TI18N("背包空间不足，请整理后再进行抽奖"))
            --    return
            -- else
                if BackpackManager.Instance:GetItemCount(self.lossItemId) >= i then
                    ArborDayShakeManager.Instance:send20434(i)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("抽奖道具不足，前往获取吧"))
                     TipsManager.Instance:ShowItem({gameObject = nil, itemData = DataItem.data_get[self.lossItemId]})
                end
            -- end
        end
    -- else
    --     NoticeManager.Instance:FloatTipsByString(TI18N("还没有到活动时间~"))
    --     return
    -- end

end

function ArborDayShakePanel:IsPlayOwnEffect(data)
    self.model.DrawEffectList = { }
    local isShow = false
    if data ~= nil then
        for i,v in pairs(data) do
            for j,k in pairs(DataCampSlotMachine.data_column) do
                if v.items[1].item_id == k.item_id1 and v.items[2].item_id == k.item_id2 and v.items[3].item_id == k.item_id3 then
                    self.model.DrawEffectList[i] = k.reward[1][1]
                    isShow = true
                    break
                end
            end
            if self.model.DrawEffectList[i] == nil then
                self.model.DrawEffectList[i] = 0
            end
        end
        return isShow
    end
end

--协议返回 --表现
function ArborDayShakePanel:OnDrawReturn(data)
    --print("协议返回啦")
    self.ownMsg = nil
    local ShowFun = self:IsPlayOwnEffect(data)
    if ShowFun == true then
        if self.timerId4 ~= nil then
            LuaTimer.Delete(self.timerId4)
            self.timerId4 = nil
        end
        self.timerId4 = LuaTimer.Add(3000, function()
            if self.OwnShowEffect == nil then
               self.OwnShowEffect = BibleRewardPanel.ShowEffect(30223, self.transform:Find("Main"), Vector3(0.85, 1, 1),Vector3(0, 0, -400))
            else
                self.OwnShowEffect:SetActive(false)
            end
            self.OwnShowEffect:SetActive(true)
        end)
        local itemId = 0
        for i = 1, #self.model.DrawEffectList do
            if self.model.DrawEffectList[i] ~= 0 then
                itemId = self.model.DrawEffectList[i]
                break
            end
        end
        if itemId ~= 0 then
            local ownMsg = string.format("恭喜{role_2, %s}额外获得{item_2, %d, 0, %d},可喜可贺!", RoleManager.Instance.RoleData.name, itemId, 1 )
            ArborDayShakeManager.Instance.onMsgEvent:Fire(ownMsg)
        end
    end
    local items = data[1].items
    if items ~= nil and items ~= 0 then
        self.rewardNums = { }
        for i,v in ipairs(items) do
            table.insert(self.rewardNums,v.item_id)
        end
        if self.timerId2 ~= nil then
            LuaTimer.Delete(self.timerId2)
            self.timerId2 = nil
        end
    elseif items == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("抽奖失败,请稍后再试"))
    end
    self.rotating = true
    local yy = self.shakeList[1][self.topIndex[1] % self.shakeColumnNum + 1 ].transform.anchoredPosition.y
    yy = math.ceil(yy)
    self.RightYY = 80 - (yy % 80)     --抽奖时剩余长度 (-80.17%80) = 79.83
    self.BeforeTopIndex = {}
    if self.RightYY ~= 0 then
        for i,v in pairs(self.topIndex) do
            self.BeforeTopIndex[i] = v % self.shakeColumnNum + 1
        end
    end
    --print(self.RightYY.."self.RightYY!!!!!!!!!!!!!!!!!!!!!!!!")
    for i =1, 3 do
        self:TweenItems(i)
    end

    if self.flashEffect == nil then
        self.flashEffect = BibleRewardPanel.ShowEffect(20458, self.showEffectArea, Vector3(0.85, 1, 1),Vector3(0, 38, -400))
    else
        self.flashEffect:SetActive(false)
    end
    self.flashEffect:SetActive(true)
end

function ArborDayShakePanel:ShowBeforeRoll()
    for i =1, 3 do
        for j =1, self.shakeColumnNum do
            if self.shakeList ~= nil then
                local anchor = self.shakeList[i][j].transform.anchoredPosition
                local y = anchor.y
                if self.LuaTweenList[i][j] ~= nil then
                    Tween.Instance:Cancel(self.LuaTweenList[i][j])
                    self.LuaTweenList[i][j] = nil
                end
                self.LuaTweenList[i][j] = Tween.Instance:ValueChange(y, y + 80, 2, function() self:SetPosition1(i)  end, LeanTweenType.linear, function(value) self.shakeList[i][j].transform.anchoredPosition = Vector2(anchor.x, value) end).id
            end
        end
    end
end

function ArborDayShakePanel:ReplaceImage(i)
    --BaseUtils.dump(self.BeforeTopIndex,"self.BeforeTopIndex@@@@@@@@@@@@@@@@@")
    --BaseUtils.dump(self.rewardNums,"self.rewardNums")
    local info = ItemData.New()
    local base = DataItem.data_get[self.rewardNums[i]]
    info:SetBase(base)
    --(self.topIndex[i] - 2) % self.shakeColumnNum + 1
    self.shakeList[i][self.BeforeTopIndex[i] % self.shakeColumnNum + 1]:SetAll(info, {inbag = false, nobutton = true})
end

function ArborDayShakePanel:TweenItems(i)
    if self.rotating == true then
        if self.slowDown[i] == false then
            if self.firstTimes[i] > ((i + 2) * self.shakeColumnNum  + 6) * self.part then
                self:ReplaceImage(i)
                self.slowDown[i] = true
                self.slowTimes[i] = 1
            end
        else
            if self.slowTimes[i] > 2 * self.part  then
                self.slowDown[i] = false    --第一列减速转完啦
                self.firstTimes[i] = 1     --第一列的计数重置
                local rotateCompleted = true
                for k = 1 ,3 do
                    if self.slowDown[k] == true then
                        rotateCompleted = false
                    end
                end
                if rotateCompleted == true then
                    if self.flashEffect ~= nil then
                        self.flashEffect:SetActive(false)
                    end
                    self:RotateCompleted()   --旋转完成
                end
                return
            end
        end

        for j =1, self.shakeColumnNum do
            local anchor = self.shakeList[i][j].transform.anchoredPosition
            local y = anchor.y
            if self.LuaTweenList[i][j] ~= nil then
                Tween.Instance:Cancel(self.LuaTweenList[i][j])
                self.LuaTweenList[i][j] = nil
            end
            --(2*i + 13)/100
            --(i+4)*0.01
            --(i + 9)/(1000 * self.part)
            self.LuaTweenList[i][j] = Tween.Instance:ValueChange(y, y + (80/self.part) + self.RightYY/((i + 3) *8), 0.05 + ((self.slowTimes[i] * self.slowTimes[i]) % 3)/2 + (self.slowTimes[i] * 0.05), function() self:SetPosition(i)  end, LeanTweenType.linear, function(value) self.shakeList[i][j].transform.anchoredPosition = Vector2(anchor.x, value) end).id
            --
            --math.pow(2, self.slowTimes[i])
        end
    end
end

function ArborDayShakePanel:RotateCompleted()
    ArborDayShakeManager.Instance:send20435()
    self.lastAllIndex = { }
    self.lastAllIndex = self.rewardsIndexs   --记录上一次停的位置
    for i = 1 ,3 do
        self.slowTimes[i] = 0
        self.columnTag[i] = 0
    end
    self.firstTimes = {1, 1, 1}
    self.RightYY = 0

    if self.SaoflashEffect == nil then
        self.SaoflashEffect = BibleRewardPanel.ShowEffect(20457, self.showEffectArea, Vector3(0.85, 1, 1),Vector3(0, 0, -400))
    else
        self.SaoflashEffect:SetActive(false)
    end
    self.SaoflashEffect:SetActive(true)

    self.timerId5 = LuaTimer.Add(1500,function()
        self.timerId5 = nil
        self.rotating = false   --转圈完成
        if self.DrawType == 1 then
            if next(self.model.returnRewardlist) ~= nil then

                local rewardData = { }
                rewardData.item_list = {}
                for i,v in pairs(self.model.returnRewardlist[1].items) do
                    rewardData.item_list[i] = {}
                    rewardData.item_list[i].item_id = v.item_id
                    rewardData.item_list[i].bind = 0
                    rewardData.item_list[i].number = v.item_num
                    rewardData.item_list[i].type = 1
                end
                rewardData.isChange = false
                rewardData.desc = TI18N("<color='#FDEE00'>[皇冠][月亮][星星]</color>将转化为<color='#FDEE00'>阳光积分</color>")

                if self.model.DrawEffectList[1] ~= 0 then
                    rewardData.isChange = true
                    rewardData.item_list[4] = {}
                    rewardData.item_list[4].type = 3

                    rewardData.item_list[5] = {}
                    rewardData.item_list[5].item_id = self.model.DrawEffectList[1]
                    rewardData.item_list[5].bind = 0
                    rewardData.item_list[5].number = 1
                    rewardData.item_list[5].type = 1
                    rewardData.desc = TI18N("恭喜获得<color='#FDEE00>极品奖励</color>")
                end

                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.itemsavegetwindow,rewardData)
                self.model.returnRewardlist = { }
            end

            self.timerId2 = nil
            self.timerId2 = LuaTimer.Add(1500, 3000, function() self:ShowBeforeRoll() end)
            self.DrawType = 0
        elseif self.DrawType == 10 then
            --用面板显示所有东东
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ArborDay_Reward_Win)
            self.DrawType = 0
        end
    end)

    self.timerId3 = LuaTimer.Add(2000,function()
        self.timerId3 = nil
        self:SetConsumeNum()
    end)


end

function ArborDayShakePanel:CountNum(i)

    self.columnTag[i] = self.columnTag[i] + 1
    if self.columnTag[i] == self.shakeColumnNum then
        self.columnTag[i] = 0
        if self.slowDown[i] == false then
            self.firstTimes[i] = self.firstTimes[i] + 1
        else
            self.slowTimes[i] = self.slowTimes[i] + 1
        end
        self:TweenItems(i)
    end
end

-- y 变化之后判断是否需要改变位置
function ArborDayShakePanel:SetPosition(i)
        if self.shakeList[i][self.topIndex[i]].transform.anchoredPosition.y >= 60 then
            local y = self.shakeList[i][(self.topIndex[i] - 2) % self.shakeColumnNum + 1].transform.anchoredPosition.y
            local h = self.shakeList[i][(self.topIndex[i] - 2) % self.shakeColumnNum + 1].transform.sizeDelta.y + self.cspacing
            self.shakeList[i][self.topIndex[i]].transform.anchoredPosition = Vector2(0, y - h)
            self.topIndex[i] = self.topIndex[i] % self.shakeColumnNum + 1
            --print("第"..i.."列topindex为"..self.topIndex[i])
        end
        self:CountNum(i)
end
function ArborDayShakePanel:SetPosition1(i)
    if self.shakeList[i][self.topIndex[i]].transform.anchoredPosition.y >= 60 then
        local y = self.shakeList[i][(self.topIndex[i] - 2) % self.shakeColumnNum + 1].transform.anchoredPosition.y
        local h = self.shakeList[i][(self.topIndex[i] - 2) % self.shakeColumnNum + 1].transform.sizeDelta.y + self.cspacing
        self.shakeList[i][self.topIndex[i]].transform.anchoredPosition = Vector2(0, y - h)
        self.topIndex[i] = self.topIndex[i] % self.shakeColumnNum + 1
        --print("第"..i.."列topindex为"..self.topIndex[i])
    end
end

function ArborDayShakePanel:OnRectScroll(value)
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

        if v.solt_four.transform:FindChild("Effect") ~= nil then
            v.solt_four.transform:FindChild("Effect").gameObject:SetActive(state)
        end
    end
end

function ArborDayShakePanel:ReWriteClickSelf(itemslot)
    itemslot:ClickSelf()
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
    self.timerId2 = LuaTimer.Add(4000, 3000, function() self:ShowBeforeRoll() end)
end


function ArborDayShakePanel:CalculateTime()

    local baseData = DataCampaign.data_list[self.campId]
    self.dateText.text = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"), baseData.cli_start_time[1][1], baseData.cli_start_time[1][2], baseData.cli_start_time[1][3], baseData.cli_end_time[1][1], baseData.cli_end_time[1][2], baseData.cli_end_time[1][3])

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    self.timerId1 = LuaTimer.Add(0,500,function() self:OnTimeListener() end)
end

function ArborDayShakePanel:OnTimeListener()
    local d = nil
    local h = nil
    local m = nil
    local s = nil

    local time1 = 0
    local time2 = 0
    if BaseUtils.BASE_TIME < self.dailyStart then
        time1 = self.dailyStart
    else
        time2 = self.dailyEnd
    end
    if BaseUtils.BASE_TIME < time1 then
        self.remainTimeDesc.text = TI18N("距活动开启:")
        d,h,m,s = BaseUtils.time_gap_to_timer(time1 - BaseUtils.BASE_TIME)
        if d ~= 0 then
            self.remainTime.text = string.format(self.timeFormatString1, tostring(d * 24 + h), tostring(m), tostring(s))
        elseif h ~= 0 then
            self.remainTime.text = string.format(self.timeFormatString1, tostring(h), tostring(m), tostring(s))
        elseif m ~= 0 then
            self.remainTime.text = string.format(self.timeFormatString2, tostring(m), tostring(s))
        else
            self.remainTime.text = string.format(self.timeFormatString3, tostring(s))
        end
    elseif BaseUtils.BASE_TIME < time2 and BaseUtils.BASE_TIME >= time1 then
        self.remainTimeDesc.text = TI18N("距活动结束:")
        d,h,m,s = BaseUtils.time_gap_to_timer(time2 - BaseUtils.BASE_TIME)
        if d ~= 0 then
            self.remainTime.text = string.format(self.timeFormatString1, tostring(d * 24 + h), tostring(m), tostring(s))
        elseif h ~= 0 then
            self.remainTime.text = string.format(self.timeFormatString1, tostring(h), tostring(m), tostring(s))
        elseif m ~= 0 then
            self.remainTime.text = string.format(self.timeFormatString2, tostring(m), tostring(s))
        else
            self.remainTime.text = string.format(self.timeFormatString3, tostring(s))
        end
    else
        self.remainTimeDesc.text = TI18N("活动剩余时间:")
        self.remainTime.text = self.timeFormatString4
    end
end

