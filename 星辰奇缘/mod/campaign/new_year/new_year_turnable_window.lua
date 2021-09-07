-- @author p
-- @date 2018年1月20日,星期六
-- 钻石转盘

NewYearTurnableWindow = NewYearTurnableWindow or BaseClass(BaseWindow)

function NewYearTurnableWindow:__init(model)
    self.model = model
    self.name = "NewYearTurnableWindow"
    self.windowId = WindowConfig.WinID.new_year_turnable_window
    self.cacheMode = CacheMode.Visible
    self.resList = {
         {file = AssetConfig.new_year_turnable_window, type = AssetType.Main}
         ,{file = AssetConfig.open_beta_textures, type = AssetType.Dep}
         --,{file = AssetConfig.turnpalte_bg1, type = AssetType.Main}
         ,{file = AssetConfig.new_year_turn_bg, type = AssetType.Main}
         ,{file = AssetConfig.new_year_turn_titlei18n, type = AssetType.Main}
        --  ,{file = AssetConfig.new_year_turnablebigbg, type = AssetType.Main}
         ,{file = AssetConfig.turnable_turnableitembg1, type = AssetType.Dep}
         ,{file = AssetConfig.turnable_turnablebtn, type = AssetType.Dep}
         ,{file = AssetConfig.turnable_turnablebg, type = AssetType.Dep}
        --  ,{file = AssetConfig.turnable_recordtitlebg, type = AssetType.Dep}
         ,{file = AssetConfig.turnable_jackpotbottombg, type = AssetType.Dep}
         ,{file = AssetConfig.turnable_jackpotbg, type = AssetType.Dep}
         ,{file = AssetConfig.turnable_texture, type = AssetType.Dep}
         ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
         ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemList = { }     --奖励item列表
    self.iconList = { }     --奖励图标列表
    self.BtnList = { }      --奖励button列表

    self.BuyCompletedFunc = function(item_type_id)
        self:StopNormalRotation(item_type_id)
    end

     self.SetDataFunc = function(cur_gold)
        self:SetGoldCallBack(cur_gold)
    end

    self.BuyFailureFunc = function()
        self:QuickStop()
    end

    --self.ItemChangeListener = function()
        --LuaTimer.Add(1200, function() self:SetItemChange() end)
    --end

    self.freeTime = 0

    self.currentDrawType = 1    --当前抽奖类型  0  1  10

    self.rewardLength = 8
    self.startTimer = 180 / self.rewardLength
    self.nowIndex = 0

    self.itemSlotList = { }

    self.startTag = 0  --收到协议后前面转圈索引

    self.isRotating = false

    self.consumeId = nil

    self.StatusId = 0

    
end

function NewYearTurnableWindow:__delete()
    self.OnHideEvent:Fire()

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    if self.timerId5 ~= nil then
        LuaTimer.Delete(self.timerId5)
        self.timerId5 = nil
    end
    if self.timerId6 ~= nil then
        LuaTimer.Delete(self.timerId6)
        self.timerId6 = nil
    end
    if self.timerId7 ~= nil then
        LuaTimer.Delete(self.timerId7)
        self.timerId7 = nil
    end

    if self.timeId8 ~= nil then
        LuaTimer.Delete(self.timeId8)
        self.timeId8 = nil
    end

    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end

    if self.SecondslowId ~= nil then
        LuaTimer.Delete(self.SecondslowId)
        self.SecondslowId = nil
    end

    if self.bufferId ~= nil then
        LuaTimer.Delete(self.bufferId)
        self.bufferId = nil
    end
    if self.stopDelayTimeId ~= nil then
        LuaTimer.Delete(self.stopDelayTimeId)
        self.stopDelayTimeId = nil
    end

    if self.msgBox ~= nil then
        self.msgBox:DeleteMe()
        self.msgBox = nil
    end

    if self.buttonEffect ~= nil then
        self.buttonEffect:DeleteMe()
        self.buttonEffect = nil
    end

    if self.Turneffect ~= nil then
        self.Turneffect:DeleteMe()
        self.Turneffect = nil
    end

    if self.Turnplate ~= nil then
        BaseUtils.ReleaseImage(self.Turnplate)
    end
    if self.TurnplateBg ~= nil then
        BaseUtils.ReleaseImage(self.TurnplateBg)
    end
    if self.TopBgLeft ~= nil then
        BaseUtils.ReleaseImage(self.TopBgLeft)
    end
    if self.TopBgRight ~= nil then
        BaseUtils.ReleaseImage(self.TopBgRight)
    end
    if self.JackpotBg ~= nil then
        BaseUtils.ReleaseImage(self.JackpotBg)
    end
    if self.JackpotBottomBg ~= nil then
        BaseUtils.ReleaseImage(self.JackpotBottomBg)
    end
    if self.JackpotGo ~= nil then
        BaseUtils.ReleaseImage(self.JackpotGo)
    end
    if self.RecordBg ~= nil then
        BaseUtils.ReleaseImage(self.RecordBg)
    end
    if self.Turnplateitem ~= nil then
        BaseUtils.ReleaseImage(self.Turnplateitem)
    end

    if self.iconloader1 ~= nil then
        self.iconloader1:DeleteMe()
        self.iconloader1 = nil
    end

    if self.iconloader2 ~= nil then
        self.iconloader2:DeleteMe()
        self.iconloader2 = nil
    end

    if self.iconloader3 ~= nil then
        self.iconloader3:DeleteMe()
        self.iconloader3 = nil
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end



    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewYearTurnableWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_turnable_window))
    self.gameObject.name = "NewYearTurnableWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject,self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.mainTrans = self.transform:Find("MainCon")
    self.titleBg = self.mainTrans:Find("TitleBg/Image"):GetComponent(Image)  --顶部标题
    -- self.titleBg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LaborGloryTitleTI18N") 
    -- self.titleBg:SetNativeSize()
    
    self.TurnplateBg = self.mainTrans:Find("TurnplateBg"):GetComponent(Image)
    self.TurnplateBg.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_turnablebg, "turnableBg")
    --self.TurnplateBg.gameObject:SetActive(false)
    self.TurnplateGo = self.mainTrans:Find("Turnplate")
    self.Turnplate = self.mainTrans:Find("Turnplate"):GetComponent(Image)
    self.Turnplate.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_turnableitembg1, "turnableItemBg3")
    --UIUtils.AddBigbg(self.Turnplate, GameObject.Instantiate(self:GetPrefab(AssetConfig.turnpalte_bg1)))
    --self.TurnplateImage = self.Turnplate:GetComponent(Image)
    self.drawBtn = self.TurnplateGo:Find("Btn"):GetComponent(Button)
    self.drawBtn.onClick:AddListener( function() self:OnTurn(1) end)

    self.TurnplateGo:Find("Btn"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_turnablebtn,"turnabledrawBtn")

    self.Turnplateitem = self.mainTrans:Find("Turnplate/Btn/bigConsume"):GetComponent(Image)
    self.Turnplateitem.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"BigConsume")

    -- self.TurnplateBtn = self.mainTrans:Find("Turnplate/bigConsumebutton"):GetComponent( Button)

    -- self.TurnplateBtn.onClick:AddListener( function() self:OnTurn(1) end)

    self.draw = self.mainTrans:Find("Turnplate/Btn/draw"):GetComponent(Image)

    self.bgTitle = self.mainTrans:Find("BigTitle")
    self.bgImg = self.mainTrans:Find("BgImg")
    --UIUtils.AddBigbg(self.bigbg, GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_turnablebigbg)))
    UIUtils.AddBigbg(self.bgTitle, GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_turn_bg)))
    UIUtils.AddBigbg(self.bgImg, GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_turn_titlei18n)))

    local itemContainer = self.mainTrans:Find("Container")
    itemContainer.gameObject:SetActive(true)
    for i =1,itemContainer.childCount do
        --self.itemList[i] = itemContainer:GetChild(i - 1)
        local item = itemContainer:GetChild(i - 1)
        local trunItem = NewYearTurnableItem.New(item.gameObject,nil,i,self, itemContainer)
        self.itemSlotList[i] = trunItem
        self.iconList[i] = item:Find("Icon"):GetComponent(Image)
        self.BtnList[i] = item:GetComponent(Button)
    end

    -- self.SingleStatus = self.mainTrans:Find("SingleDraw")
    -- self.SingleDrawBtn = self.mainTrans:Find("SingleDraw"):GetComponent(Button)
    -- self.SingleDrawImage = self.mainTrans:Find("SingleDraw/Image"):GetComponent(Image)
    -- self.SingleDrawDia = self.mainTrans:Find("SingleDraw/Dia")
    -- if self.iconloader1 == nil then
    --     self.iconloader1 = SingleIconLoader.New(self.SingleDrawDia.gameObject)
    -- end
    -- self.iconloader1:SetSprite(SingleIconType.Item, self.consumeId)

    -- self.SingleDrawBtn.onClick:AddListener( function() self:OnTurn(1) end)



    self.TenStatus = self.mainTrans:Find("TenDraw")
    self.TenDrawBtn = self.mainTrans:Find("TenDraw"):GetComponent(Button)
    --self.TenDrawImage = self.mainTrans:Find("TenDraw/Image"):GetComponent(Image)
    self.TenDrawBtn.onClick:AddListener( function() self:OnTurn(10) end)
    if self.iconloader2 == nil then
        self.iconloader2 = SingleIconLoader.New(self.TenStatus:Find("Dia").gameObject)
    end
    

    self.JackpotBg = self.mainTrans:Find("JackPotBg"):GetComponent(Image)
    self.JackpotBg.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_jackpotbg,"JackpotBg2")
    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.mainTrans:Find("JackPotBg"))
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(2, 18, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.effectTopObj = BaseEffectView.New({effectId = 20198, time = nil, callback = fun})

    self.JackpotGo = self.mainTrans:Find("JackPotBg/Image"):GetComponent(Image)
    self.JackpotGo.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"JackpotItem2")

    self.JackpotBottomBg = self.mainTrans:Find("JackPotBg/BottomBg"):GetComponent(Image)
    self.JackpotBottomBg.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_jackpotbottombg,"JackpotBottomBg2")


    self.mainTrans:Find("JackPotBg/Image").anchoredPosition = Vector2(-4, -21)
    self.mainTrans:Find("JackPotBg/Image").localScale = Vector3(1, 1, 1)
    self.mainTrans:Find("JackPotBg/Image").sizeDelta = Vector2(260, 164)

    self.JackpotNum = self.mainTrans:Find("JackPotBg/BottomBg/JackPotText/JackPotNum"):GetComponent(Text)
    self.JackpotNum.transform.anchoredPosition = Vector2(67, 0)
    self.JackpotNum.transform.sizeDelta = Vector2(70, 23)
    self.mainTrans:Find("JackPotBg/BottomBg/JackPotText/Dia").anchoredPosition = Vector2(115, 0)
    --计时
    self.remainTime = self.mainTrans:Find("RemainTimeTitle"):GetComponent(Text)
    self.remainTime.transform.sizeDelta = Vector2(153,30)
    self.remainTime.transform.anchoredPosition = Vector2(260,135)

    self.noticeButton = self.mainTrans:Find("NoticeButton"):GetComponent(Button)

    self.ownNum = self.mainTrans:Find("OwnText/OwnNum"):GetComponent(Text)

    self.Effect = self.mainTrans:Find("MoveEffect")

    local btn = self.mainTrans:Find("OwnText").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = nil, itemData = self.baseData}) end)

    self.ownImage = self.mainTrans:Find("OwnText/Dia"):GetComponent(Image)
    if self.iconloader3 == nil then
        self.iconloader3 = SingleIconLoader.New(self.ownImage.gameObject)
    end
    --self.RecordBg = self.mainTrans:Find("Record/TitleBg"):GetComponent(Image)
    --self.RecordBg.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_recordtitlebg,"RecordTitleBg")

end

function NewYearTurnableWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewYearTurnableWindow:OnOpen()
    self:AddListeners()
    self.isRotating = false
    self.StatusId = 0

    self:ShowButtonEffect()

    if self.timerId7 == nil then
        self.timerId7 = LuaTimer.Add(0,30000, function() NewYearTurnableManager.Instance:send20419() end)
    end

    if self.openArgs ~= nil then
        self.campId = self.openArgs.campId
    end

    self.consumeId = DataCampaign.data_list[self.campId].loss_items[1][1]
    self.consumeIconId = DataItem.data_get[self.consumeId].icon
    self.baseData = DataItem.data_get[self.consumeId]
    self.iconloader2:SetSprite(SingleIconType.Item, self.consumeIconId)
    self.iconloader3:SetSprite(SingleIconType.Item, self.consumeIconId)


    if self.msgBox == nil then
        self.msgBox = NewYearTurnableMsg.New(self.mainTrans:Find("Record/Scroll/Container"), self.mainTrans:Find("Record/Scroll/Cloner").gameObject)
    end
    self.noticeButton.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.noticeButton.gameObject, itemData = {self.model.NoticeTips}}) end)

    self:SetData()    --设置简单属性

    self:LoadRewardOnTurn()

    self:CalculateTime()
end

function NewYearTurnableWindow:OnHide()
    self:RemoveListeners()
    self.isRotating = false
    if self.flashEffect ~= nil then
        self.flashEffect:SetActive(false)
    end
    if self.StatusId == 1 then
        NewYearTurnableManager.Instance:send20420(self.currentDrawType)
        self.StatusId = 0
    end

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    if self.timerId5 ~= nil then
        LuaTimer.Delete(self.timerId5)
        self.timerId5 = nil
    end

    if self.timerId6 ~= nil then
        LuaTimer.Delete(self.timerId6)
        self.timerId6 = nil
    end

    if self.timerId7 ~= nil then
        LuaTimer.Delete(self.timerId7)
        self.timerId7 = nil
    end

    if self.timeId8 ~= nil then
        LuaTimer.Delete(self.timeId8)
        self.timeId8 = nil
    end


    if self.msgBox ~= nil then
        self.msgBox:DeleteMe()
        self.msgBox = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    if self.Turneffect ~= nil then
        self.Turneffect:DeleteMe()
        self.Turneffect = nil
    end

    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end

    if self.SecondslowId ~= nil then
        LuaTimer.Delete(self.SecondslowId)
        self.SecondslowId = nil
    end

    if self.bufferId ~= nil then
        LuaTimer.Delete(self.bufferId)
        self.bufferId = nil
    end
    if self.stopDelayTimeId ~= nil then
        LuaTimer.Delete(self.stopDelayTimeId)
        self.stopDelayTimeId = nil
    end
end

function NewYearTurnableWindow:AddListeners()
    self:RemoveListeners()
    NewYearTurnableManager.Instance.OnDrawSuccess:AddListener(self.BuyCompletedFunc)
    NewYearTurnableManager.Instance.OnDrawFailure:AddListener(self.BuyCompletedFunc)
    NewYearTurnableManager.Instance.OnGoldUpdate:AddListener(self.SetDataFunc)
    --EventMgr.Instance:AddListener(event_name.backpack_item_change, self.ItemChangeListener)
end

function NewYearTurnableWindow:RemoveListeners()
    NewYearTurnableManager.Instance.OnDrawSuccess:RemoveListener(self.BuyCompletedFunc)
    NewYearTurnableManager.Instance.OnDrawFailure:RemoveListener(self.BuyCompletedFunc)
    NewYearTurnableManager.Instance.OnGoldUpdate:RemoveListener(self.SetDataFunc)
    --EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.ItemChangeListener)
end

function NewYearTurnableWindow:OnClose()

end


function NewYearTurnableWindow:SetGoldCallBack(cur_Gold)
    self.JackpotNum.text = TI18N(cur_Gold)
end
--打开面板初始化
function NewYearTurnableWindow:SetData()

    self.freeTime = self.model.freeTime
    self.JackpotNum.text = TI18N(self.model.currentGold)
    self.ownNum.text = BackpackManager.Instance:GetItemCount(self.consumeId)
    if self.freeTime == 0 then
        self.draw.transform.anchoredPosition = Vector2(2,-30)
        self.draw.transform.sizeDelta = Vector2(72,36)
        self.draw.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"SingleDraw")
    elseif self.freeTime == 1 then
        self.draw.transform.anchoredPosition = Vector2(2,-26)
        self.draw.transform.sizeDelta = Vector2(100,37)
        self.draw.sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"FreeDraw")
    end

    if BackpackManager.Instance:GetItemCount(self.consumeId) >= 10 then
        self.TenStatus.gameObject:SetActive(true)
    else
        self.TenStatus.gameObject:SetActive(false)
    end
    --获奖记录
end

--将读取的数据设置到轮盘上的itemslot
function NewYearTurnableWindow:LoadRewardOnTurn()
    --local DiaList = { }
    for i, v in ipairs(self.model.sortRewardList) do
        self.itemSlotList[i]:SetData(v[1].icon,i)
        self.BtnList[i].onClick:RemoveAllListeners()
        self.BtnList[i].onClick:AddListener( function()
            TipsManager.Instance:ShowItem( { gameObject = self.itemSlotList[i].gameObject, itemData = DataItem.data_get[tonumber(v[1].icon)], extra = { nobutton = true, inbag = false } })
        end )
    end
    -- BaseUtils.dump(DiaList,"DiaList######")
    -- for i,v in ipairs(DiaList) do
    --     self.itemSlotList[v[1].group_id]:SetData(v[1].icon,v[1].group_id,i)
    -- end
end

--转轮盘  发协议
function NewYearTurnableWindow:OnTurn(num)
    if self.isRotating == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在抽奖中... 请稍后再试"))
        return
    end
    self.freeTime = self.model.freeTime
    local number = num

    --判断抽奖币是否大于某值
    if number == 1 then
        if BackpackManager.Instance:GetCurrentGirdNum() <= 0 then
           NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理后再进行抽奖"))
           return
        else
            if self.freeTime == 0 then
                -- if self.model.MaxTime <= self.model.todayDrawTime then
                --     NoticeManager.Instance:FloatTipsByString("今日抽奖次数已满，请明天再来吧")
                --     return
                -- end
                if BackpackManager.Instance:GetItemCount(self.consumeId) >= number then
                    --发协议啦  延时
                    self.currentDrawType = 1
                    self:HideButtonEffect()
                    self.StatusId = 1
                    if self.timerId5 ~= nil then
                        LuaTimer.Delete(self.timerId5)
                        self.timerId5 = nil
                    end
                    self.timerId5 = LuaTimer.Add(3600, function()
                        NewYearTurnableManager.Instance:send20420(number)
                        self.StatusId = 0
                    end)

                    -- print("抽一次")
                    --self:StartRotationTime()
                    self:BeforeStartRotate()
                else
                    NoticeManager.Instance:FloatTipsByString("道具不足，无法进行抽奖哟")
                    TipsManager.Instance:ShowItem({gameObject = nil, itemData = self.baseData})
                end
            elseif self.freeTime == 1 then
                self.currentDrawType = 0
                self:HideButtonEffect()
                self.StatusId = 1
                if self.timerId5 ~= nil then
                    LuaTimer.Delete(self.timerId5)
                    self.timerId5 = nil
                end
                self.timerId5 = LuaTimer.Add(3600, function() NewYearTurnableManager.Instance:send20420(number - 1)
                    self.StatusId = 0
                end)
                -- print("免费抽一次")
                --self:StartRotationTime()
                self:BeforeStartRotate()
            end
        end
    elseif number == 10 then
        -- if self.model.todayDrawTime > 10 then
        --     NoticeManager.Instance:FloatTipsByString("今日抽奖次数不足十次哦")
        --     return
        -- end
        if BackpackManager.Instance:GetCurrentGirdNum() < 10 then
           NoticeManager.Instance:FloatTipsByString(TI18N("背包空间不足，请整理后再进行抽奖"))
           return
        else
            if BackpackManager.Instance:GetItemCount(self.consumeId) >= number then
                --发协议啦  延时
                self.currentDrawType = 10
                self:HideButtonEffect()
                self.StatusId = 1
                if self.timerId5 ~= nil then
                    LuaTimer.Delete(self.timerId5)
                    self.timerId5 = nil
                end
                self.timerId5 = LuaTimer.Add(3600, function() NewYearTurnableManager.Instance:send20420(number)
                    self.StatusId = 0
                end)
                -- print("抽十次")
                --self:StartRotationTime()
                self:BeforeStartRotate()
            else
                NoticeManager.Instance:FloatTipsByString("道具不足，无法进行抽奖哟")
                TipsManager.Instance:ShowItem({gameObject = nil, itemData = self.baseData})
            end
        end
    end
end

--转动之前 播放抽奖币特效
function NewYearTurnableWindow:BeforeStartRotate()
    self.isRotating = true     --正在转动
    local t = Vector3(123, -41, -400)
    if self.currentDrawType == 0 or self.currentDrawType == 1 then
        self.Effect.localPosition = t
    elseif self.currentDrawType == 10 then
        self.Effect.localPosition = self.TenStatus.localPosition
    end
    if self.flashEffect == nil then
       self.flashEffect = BibleRewardPanel.ShowEffect(20447, self.Effect, Vector3(1, 1, 1),Vector3(0, 0, -400))
    end
    self.flashEffect:SetActive(true)

    self.tweenId = Tween.Instance:MoveLocal(self.Effect.gameObject, t, 0.5, function()
            if self.tweenId ~= nil then
                Tween.Instance:Cancel(self.tweenId)
                self.tweenId = nil
            end
        end).id
    --self.timeId7 = LuaTimer.Add(0, 100, function() self:Loop() end)

    self.timeId8 = LuaTimer.Add(3000, function()
        self.timeId8 = nil
        if self.flashEffect ~= nil then
            self.flashEffect:SetActive(false)
        end
        self:StartRotationTime()
    end)
end

function NewYearTurnableWindow:Loop()
    local t = Vector3(123, -41, -400)
    self.tweenId = Tween.Instance:MoveLocal(self.flashEffect.transform, t, 0.5, function()
            if self.tweenId ~= nil then
                Tween.Instance:Cancel(self.tweenId)
                self.tweenId = nil
            end
        end).id
end


--点击按钮 开始转动
function NewYearTurnableWindow:StartRotationTime()
    self:ShowTurnEffect()
    self.animationTimes = 0
    self.rotationTimeId = LuaTimer.Add(0,self.startTimer, function()
        self:ChangeItemSelect()
    end)
    --取随机数,确保种子每次不一样
    --math.randomseed(tostring(os.time()):reverse():sub(1,6))
    --self.addNum = math.random(10,12)
end

function NewYearTurnableWindow:ChangeItemSelect()

    if self.animationTimes < self.rewardLength * 5 then   --最大限制 5圈
        self.animationTimes = self.animationTimes + 1
        self.nowIndex = self.animationTimes % (self.rewardLength)
        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end

        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end

        if self.itemSlotList[self.nowIndex] ~= nil then   --1 2 3 4 5 6 7 8 1 ..
            self.itemSlotList[self.nowIndex]:ShowFlashEffect(true)
        end

        if self.itemSlotList[lastEffectIndex] ~= nil then --0 1 2 3 4 5 6 7 8 ..
            self.itemSlotList[lastEffectIndex]:ShowFlashEffect(false)
        end
    end
end

function NewYearTurnableWindow:StopNormalRotation(index)
    -- print(index.."reward索引：")
    -- print(self.animationTimes.."当前转圈圈数：")

    local temp = self.animationTimes % self.rewardLength
    if temp == 0 then temp = 8 end
    local delayRotationTimes = self.rewardLength - temp + index

    -- print(delayRotationTimes.."delayRotationTimes:")

    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end
    self.SecondslowId = LuaTimer.Add(0,self.startTimer, function()
        self:BeforeSlowRotate(delayRotationTimes)
    end)
end

function NewYearTurnableWindow:BeforeSlowRotate(beforeslowTime)
    local beforeslowTime = beforeslowTime
    if self.startTag < beforeslowTime then
        self.startTag = self.startTag + 1
        self.animationTimes = self.animationTimes + 1
        self.nowIndex = self.animationTimes % (self.rewardLength)
        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end
        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end
        if self.itemSlotList[self.nowIndex] ~= nil then
            self.itemSlotList[self.nowIndex]:ShowFlashEffect(true)
        end
        if self.itemSlotList[lastEffectIndex] ~= nil then
            self.itemSlotList[lastEffectIndex]:ShowFlashEffect(false)
        end
    else
        if self.SecondslowId ~= nil then
            LuaTimer.Delete(self.SecondslowId)
            self.SecondslowId = nil
        end
        self.startTag = 0
        self.lastTweenIndex = 0
        self.disIndex = self.rewardLength
        self:DoSlowRotate()
    end
end

function NewYearTurnableWindow:DoSlowRotate()

    if self.disIndex >= 1 then
        if self.disIndex >= 1 then
            self.disIndex = self.disIndex - 1
            self.lastTweenIndex = self.lastTweenIndex + 1
            self.animationTimes = self.animationTimes + 1
            self.nowIndex = self.animationTimes % (self.rewardLength)
        end

        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end

        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end

        if self.itemSlotList[self.nowIndex] ~= nil then
            self.itemSlotList[self.nowIndex]:ShowFlashEffect(true)
        end

        if self.itemSlotList[lastEffectIndex] ~= nil then
            self.itemSlotList[lastEffectIndex]:ShowFlashEffect(false)
        end

        if self.disIndex < 1 then
            self:TweenEnd()
            return
        end

        self.time = self.startTimer + math.pow((self.rewardLength - self.disIndex), 3.2)
        self.bufferId = LuaTimer.Add(self.time, function()
            self.bufferId = nil
            self:DoSlowRotate()
        end)
    end
end


function NewYearTurnableWindow:ValueChange2()
    -- print(self.disIndex.."self.disIndex：")

    if self.disIndex >= 1 then               --addNum:慢下来时转动的圈数

        if self.disIndex >= 1 then
            self.disIndex = self.disIndex - 1
            self.lastTweenIndex = self.lastTweenIndex + 1        --1
            self.animationTimes = self.animationTimes + 1        --28
            self.nowIndex = self.animationTimes % (self.rewardLength)    --4   接着以前的转的来的（self.animationTimes一直增大）
        end


        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end

        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end

        if self.itemSlotList[self.nowIndex] ~= nil then
            self.itemSlotList[self.nowIndex]:ShowFlashEffect(true)
        end

        if self.itemSlotList[lastEffectIndex] ~= nil then
            self.itemSlotList[lastEffectIndex]:ShowFlashEffect(false)
        end

        if self.disIndex < 1 then
            self:TweenEnd()
            return
        end
        -- print(self.lastTweenIndex.."self.lastTweenIndex#####")
        --self.time = math.pow(self.lastTweenIndex,2.53) + self.startTimer
        self.time = self.startTimer + 30 * self.lastTweenIndex
        self.bufferId = LuaTimer.Add(self.time, function()
            self.bufferId = nil
            self:ValueChange2()
        end)
    end
end

function NewYearTurnableWindow:TweenEnd()
    self.stopDelayTimeId = LuaTimer.Add(300,function() self.stopDelayTimeId = nil self:FlashItem() end)
end

function NewYearTurnableWindow:FlashItem()
    self.itemSlotList[self.nowIndex]:ShowFlashEffect(false)
    self.itemSlotList[self.nowIndex]:ShowBlockEffect(false)
    self.itemSlotList[self.nowIndex]:ShowBlockEffect(true)
    self.endActiveEffect = self.itemSlotList[self.nowIndex]
    self.rewardTimer = LuaTimer.Add(1000, function()
        self.rewardTimer = nil
        self.isRotating = false
        if next(self.model.DrawRewardList) ~= nil then
            local rewardData = { }
            rewardData.item_list = self.model.DrawRewardList
            self.model:OpenGiftShow(rewardData)
            self.model.DrawRewardList = { }
        end

        if self.endActiveEffect ~= nil then
            self.endActiveEffect:ShowBlockEffect(false)
        end

        self.timerId6 = LuaTimer.Add(1000, function()
            self.timerId6 = nil
            self:SetData()
            self:ShowButtonEffect()
            self:HideTurnEffect()
        end)
    end)
end

--抽奖失败，让转盘停下来并弹出提示
function NewYearTurnableWindow:QuickStop()
    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end
    self.isRotating = false
    self:SetData()
    NoticeManager.Instance:FloatTipsByString("抽奖失败了呢，请稍后再试~{face_1 ,22}")
end

function NewYearTurnableWindow:ShowTurnEffect()
    if self.Turneffect == nil then
        self.Turneffect = BibleRewardPanel.ShowEffect(20175, self.TurnplateGo:Find("Btn"), Vector3(0.95, 0.95, 1), Vector3(0, 0, -400))
    else
        self.Turneffect:SetActive(false)
        self.Turneffect:SetActive(true)
    end
end

function NewYearTurnableWindow:HideTurnEffect()
    if self.Turneffect ~= nil then
        self.Turneffect:SetActive(false)
    end
end


function NewYearTurnableWindow:ShowButtonEffect()
    if self.buttonEffect == nil then
        self.buttonEffect = BibleRewardPanel.ShowEffect(20121, self.TurnplateGo:Find("Btn"), Vector3(2, 2, 1), Vector3(0, 0, -400))
    else
        self.buttonEffect:SetActive(true)
    end
end

function NewYearTurnableWindow:HideButtonEffect()
    if self.buttonEffect ~= nil then
        self.buttonEffect:SetActive(false)
    end
end

function NewYearTurnableWindow:CalculateTime()
    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    self.timerId1 = LuaTimer.Add(0,1000,function() self:ShowDelayTime() end)
end

function NewYearTurnableWindow:ShowDelayTime()

    local nowTime = BaseUtils.BASE_TIME
    local beginTimeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[self.campId].cli_end_time[1]

    local beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    local endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    if nowTime > beginTime and nowTime < endTime then
        local h = math.floor((endTime - nowTime) / 3600)
        local mm = math.floor(((endTime - nowTime) - (h * 3600)) / 60)
        local ss = math.floor((endTime - nowTime) - (h * 3600) - (mm * 60))
        --<color='#ffff00'>找不到该文件</color>
        if h >= 24 then
            self.remainTime.text = TI18N("<color='#ffffff'>活动剩余:</color>"..math.floor(h/24).."天")
        else
            if h >= 0 and h <= 9 then
                h = "0"..h
            end
            if mm >= 0 and mm <= 9 then
                mm = "0"..mm
            end
            if ss >= 0 and ss <= 9 then
                ss = "0"..ss
            end
            self.remainTime.text = TI18N("<color='#ffffff'>活动剩余:</color>"..h ..":"..mm ..":"..ss)
        end
    else
        self.remainTime.text = TI18N("<color='#ffffff'>活动未开启</color>")
    end
end


