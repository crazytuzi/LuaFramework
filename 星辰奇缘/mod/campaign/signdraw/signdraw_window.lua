-- @author hze
-- @date #2018/02/27#
--签到抽奖活动

SignDrawWindow = SignDrawWindow or BaseClass(BaseWindow)

function SignDrawWindow:__init(model)
    self.model = model
    self.name = "SignDrawWindow"
    -- self.cacheMode = CacheMode.Visible

    self.isRotating = false

    self.windowId = WindowConfig.WinID.signdrawwindow

    self.resList = {
        {file = AssetConfig.signdraw_window, type = AssetType.Main}
        ,{file = AssetConfig.signdraw_bg1, type = AssetConfig.Main}
        ,{file = AssetConfig.signdraw_bg2, type = AssetConfig.Main}
        ,{file = AssetConfig.signdraw_bg3, type = AssetConfig.Main}
        ,{file = AssetConfig.signdraw_bg4, type = AssetConfig.Main}
        ,{file = AssetConfig.signdraw_textures, type = AssetType.Dep}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        ,{ file = AssetConfig.open_beta_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.signdraw_bgtexti18n, type = AssetType.Dep }
    }

    self.itemList = {}  --图标列表
    self.btnList = {}   --按钮列表

    self.loaders = {}   --加载图标
    self.numList = {}   --加载数字


    self.questList = {}  --任务列表

    --总奖励个数
    self.totalnum = 8

    --半径大小
    self.outradius = 115
    self.inneradius = 60

    --已旋转总角度
    self.outCount = 0
    self.inCount = 0

    --旋转速度(角度)
    self.outSpeed = 20
    self.innerSpeed = 25

    --已获得奖励id和数目
    self.item_baseid = 0
    self.item_num = 0

    --基数
    self.item_basenum = 1

    --第几个奖励和第几个数目
    self.index = 1
    self.num = 1

    --是否已经抽奖
    self.isSendBool = false

    --特效表
    self.effectList = {}

    self.timeFormatString =
    {
        TI18N("活动剩余时间：<color='%s'>%s天%s小时%s分</color>"),
        TI18N("活动剩余时间：<color='%s'>%s时%s分</color>"),
        TI18N("活动剩余时间：<color='%s'>%s分</color>"),
        TI18N("活动剩余时间：<color='%s'>%s秒</color>"),
        TI18N("活动已结束"),
        TI18N("活动剩余时间：<color='%s'>%s天</color>")
    }


    self._backpackListener = function() self:SetExhcangeNum() end
    self._signcompleted = function(data) self:SignCompletedStatus(data.flag) end

    self._update_quest = function() self:LoadQuestItem() end
    self._update_reward = function() self:LoadRewardItemIconAndNum() end

    self._doslow =  function(data) self:GetIndex(data) end


    -- self._Update = function(reward_item_data)
    --     if reward_item_data ~= nil thens
    --         self:Go()
    --         self:GetIndex(reward_item_data.id)
    --     end
    -- end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SignDrawWindow:__delete()
    self.OnHideEvent:Fire()

    if self.Turneffect ~= nil then
        self.Turneffect:DeleteMe()
        self.Turneffect = nil
    end

    for _,v in pairs (self.effectList) do
        if v ~= nil then
            v:DeleteMe()
            v = nil
        end
    end

    --释放消耗物品
    if self.imgLoaderOne ~= nil then
        self.imgLoaderOne:DeleteMe()
        self.imgLoaderOne = nil
    end

    --释放抽奖奖励物品
    for k, v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil


    --释放小转盘
    BaseUtils.ReleaseImage(self.gameObject.transform:Find("Main/DrawArea/Turnplate2"):GetComponent(Image))
    BaseUtils.ReleaseImage(self.gameObject.transform:Find("Main/DrawArea/Turnplate"):GetComponent(Image))

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function SignDrawWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.signdraw_window))
    self.gameObject.name = self.name

    local Main = self.gameObject.transform:Find("Main")
    Main.localScale = Vector3(0.97,0.97,0.97)
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
    UIUtils.AddBigbg(Main:Find("PanelHead"), GameObject.Instantiate(self:GetPrefab(AssetConfig.signdraw_bg1)))

    Main:Find("PanelTextHead").anchoredPosition = Vector2(-24,-36)
    UIUtils.AddBigbg(Main:Find("PanelTextHead"), GameObject.Instantiate(self:GetPrefab(AssetConfig.signdraw_bgtexti18n)))

    UIUtils.AddBigbg(Main:Find("DrawArea/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.signdraw_bg2)))
    UIUtils.AddBigbg(Main:Find("DrawArea/Bg2"), GameObject.Instantiate(self:GetPrefab(AssetConfig.signdraw_bg2)))
    Main:Find("DrawArea/Turnplate"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.signdraw_bg3, "signdraw_bg3")
    Main:Find("DrawArea/Turnplate2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.signdraw_bg4, "singdrawinnerbg")

    self.titleImg = Main:Find("Title/ImageTxt"):GetComponent(Image)

    self.closeBtn = Main:Find("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.templateItem = Main:Find("TemplateItem").gameObject
    self.templateItem:SetActive(false)

    self.scroll =  Main:Find("Mask"):GetComponent(ScrollRect)
    self.questContainer = self.scroll.transform:Find("Container")

    self.layout = LuaBoxLayout.New(self.questContainer,{axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})


    --抽奖区域---
    self.drawArea = Main:Find("DrawArea")
    --大转盘
    self.drawTurnPlate = Main:Find("DrawArea/Turnplate")
    --小转盘
    self.drawTurnPlate2 = Main:Find("DrawArea/Turnplate2")

    self.drawContainer = self.drawArea:Find("Container")
    self.numContainer = self.drawArea:Find("NumContainer")

    --设置穿透
    self.drawArea:Find("Pointer").gameObject:AddComponent(CanvasGroup).blocksRaycasts = false

    --notice
    Main:Find("Notice"):GetComponent(Button).onClick:AddListener( function() TipsManager.Instance.model:OpenChancewindow(209) end)

    --抽奖消耗品
    self.imgLoaderOne = SingleIconLoader.New(Main:Find("Own/gain").gameObject)

    --奖励物品
    for i = 1,self.totalnum do
        self.itemList[i] = self.drawContainer.transform:GetChild(i - 1)
        self.btnList[i] = self.itemList[i]:GetComponent(Button)
        self.numList[i] = self.numContainer.transform:GetChild(i - 1)
    end

    --设置位置
    self:SetItemsPosition(1,0)
    self:SetItemsPosition(2,0)

    self.turnBtn = self.drawArea:Find("DrawBtn"):GetComponent(Button)
    self.turnBtn.onClick:AddListener( function() self:OnTurn() end)


end

function SignDrawWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SignDrawWindow:OnOpen()
    self.model.markHide = false
    self:RemoveListeners()

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._backpackListener)

    SignDrawManager.Instance.OnUpdateSignStatus:Add(self._signcompleted)
    SignDrawManager.Instance.OnUpdateQuestList:Add(self._update_quest)
    SignDrawManager.Instance.OnUpdateRewardList:Add(self._update_reward)
    SignDrawManager.Instance.OnUpdateDraw:Add(self._doslow)

    self.model.lastArgs = self.openArgs or self.model.lastArgs
    self.campId = self.model.lastArgs.campId

    -- BaseUtils.dump(self.campId,"活动ID:")
    self.campaignData_cli = DataCampaign.data_list[self.campId]
    self.exchangeBaseId = self.campaignData_cli.loss_items[1][1]
    self.exchangeBaseId = self.exchangeBaseId 

    --标题设置
    self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, CampaignManager.GetTitleNameByCampaignId(self.campId)) 
    self.titleImg:SetNativeSize()

    -- self:LoadRewardItemIconAndNum()
    -- self:LoadQuestItem()

    --界面数据初始化,请求页面数据
    SignDrawManager.Instance:Send20438()
    SignDrawManager.Instance:Send20439()

    self.innerStatus = true   --小转盘数字特效开关

    self:OnTimeListener()
    self:SetExhcangeNum()




end

function SignDrawWindow:OnHide()

    self:RemoveListeners()

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    self.model.markHide = true

    if not self.isSendBool and self.isRotating then
        SignDrawManager.Instance:Send20437()
        self.isSendBool = true
        self.isRotating = false
        NoticeManager.Instance:FloatTipsByString(string.format("{assets_2,%d}%s<color='#b031d5'>[%s]</color>",self.exchangeBaseId,TI18N("消耗"),DataItem.data_get[self.exchangeBaseId].name))
    end

    if self.isSendBool and self.isRotating then 
        if self.item_baseid ~= nil and DataItem.data_get[self.item_baseid] ~= nil and DataItem.data_get[self.item_baseid].name ~= nil and self.item_num ~= nil and self.item_basenum ~= nil then 
            NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#b031d5'>[%sx%d]</color>",TI18N("获得"),DataItem.data_get[self.item_baseid].name,self.item_num*self.item_basenum))
        end
    end
end

function SignDrawWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._backpackListener)
    --删除签到事件
    SignDrawManager.Instance.OnUpdateSignStatus:Remove(self._signcompleted)
    SignDrawManager.Instance.OnUpdateQuestList:Remove(self._update_quest)
    SignDrawManager.Instance.OnUpdateRewardList:Remove(self._updte_reward)
    SignDrawManager.Instance.OnUpdateDraw:Remove(self._doslow)

end



function SignDrawWindow:SetItemsPosition(ringType,theta)
    local sin = math.sin
    local cos = math.cos
    local pi = math.pi
    theta = - theta

    if ringType == 1 then
        for i, v in ipairs(self.itemList) do
            v.anchoredPosition = Vector2(self.outradius * cos(2 * pi *(i - 1) / self.totalnum + theta), self.outradius * sin(2 * pi *(i - 1) / self.totalnum + theta))
        end
    elseif ringType ==2 then
        for i, v in ipairs(self.numList) do
            v.anchoredPosition = Vector2(self.inneradius * cos(2 * pi *(i - 1) / self.totalnum + theta), self.inneradius * sin(2 * pi *(i - 1) / self.totalnum + theta))
        end
    end
end





function SignDrawWindow:SetTurnplatePosition(ringType,theta)
    theta = - theta
    if self.drawTurnPlate == nil or self.drawTurnPlate == nil then return end

    if ringType == 1 then
        self.drawTurnPlate.transform.rotation = Quaternion.Euler(0, 0, theta)
    elseif ringType == 2 then
        self.drawTurnPlate2.transform.rotation = Quaternion.Euler(0, 0, theta)
    end
end

function SignDrawWindow:OnTurn()
    -- if self.timerId ~= nil then
    --     return
    -- end
    -- end
    if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 0 then
        if not self.isRotating then
            self:ShowTurnEffect()
            --关闭按钮特效
            local ID = self.turnBtn:GetInstanceID()
            if self.effectList[ID] ~= nil then
                self.effectList[ID]:SetActive(false)
            end
            --测试转
            self:Go()
            LuaTimer.Add(1000, function()
                if not self.isSendBool then
                    SignDrawManager.Instance:Send20437()
                    self.isSendBool = true
                    NoticeManager.Instance:FloatTipsByString(string.format("{assets_2,%d}%s<color='#b031d5'>[%s]</color>",self.exchangeBaseId,TI18N("消耗"),DataItem.data_get[self.exchangeBaseId].name))
                end
            end)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("正在抽奖"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("抽奖道具不足，快去做任务获取吧{face_1,18}"))
    end

end


function SignDrawWindow:GetIndex(data)
        local index = nil
        local num = nil
        self.item_baseid = data.result[1].base_id
        self.item_num = data.result[1].num
        self.item_basenum = data.result[1].base_num

        if next(data) and data.flag == 1 then
            for i, v in pairs(self.rewardItems) do
                if v.base_id == data.result[1].base_id then
                    index = i
                    break
                end
            end

            for i, v in ipairs(self.numbers) do
                if v.num == data.result[1].num then
                    num = i
                    break
                end
            end
            self:DoSlowDown(index,num)
        else
            NoticeManager.Instance:FloatTipsByString(data.msg)
            self:DoSlowDown(BaseUtils.BASE_TIME % 8 + 1,BaseUtils.BASE_TIME % 8 + 1)
        end
end

function SignDrawWindow:DoSlowDown(index,num)
    self.index = index
    self.num = num
    index = index - 3
    num = num - 3
    if self.timerId1 ~= nil then
        self.doSlowDown = true
        if index > 4 then
            self.outtargetTheta = 45 * index + 360 * 2
        else
            self.outtargetTheta = 45 * index + 360 * 3
        end

        if num > 4 then
            self.intargetTheta = 45 * num + 360 * 2
        else
            self.intargetTheta = 45 * num + 360 * 3
        end

        self.outdistance = self.outtargetTheta - self.outCount
        self.indistance = self.intargetTheta - self.inCount
    end
end


function SignDrawWindow:Go()
    --self.turnBtn.transform:GetComponent(TransitionButton).enabled = false

    self.isRotating = true
    self.doSlowDown = false

    if self.timerId1 == nil then
        self.timerId1 = LuaTimer.Add(0, 10, function() self:DoRotation() end)
    end


end

function SignDrawWindow:DoRotation()
    if self.doSlowDown then
        --物品转盘
        if self.outCount < self.outtargetTheta then
            self.outCount = self.outCount + self.outSpeed *(self.outtargetTheta - self.outCount) * 1.2 / self.outdistance + 0.2
        else
            --删除旋转定时器
            if self.timerId1 ~= nil then
                LuaTimer.Delete(self.timerId1)
                self.timerId1 = nil
            end

            --打开奖励面板
            LuaTimer.Add(800,function() self:RewardPanel() end)

            --奖励上浮提示
            if self.item_baseid ~= nil and DataItem.data_get[self.item_baseid] ~= nil and DataItem.data_get[self.item_baseid].name ~= nil  and self.item_num ~= nil and self.item_basenum ~= nil then
                NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#b031d5'>[%sx%d]</color>",TI18N("获得"),DataItem.data_get[self.item_baseid].name,self.item_num*self.item_basenum))
            end

            --播放中奖物品特效
            local ID =  self.itemList[self.index]:GetInstanceID()
            if self.effectList[ID] == nil then
                self.effectList[ID] = BibleRewardPanel.ShowEffect(20466, self.itemList[self.index].transform, Vector3(1, 1, 1), Vector3(0, -145, -400))
            else
                self.effectList[ID]:SetActive(false)
                self.effectList[ID]:SetActive(true)
            end

            self.isRotating = false
            self.isSendBool = false

            self.innerStatus = true
        end

        --数字转盘
        if self.inCount < self.intargetTheta then
            self.inCount = self.inCount + self.innerSpeed *(self.intargetTheta - self.inCount) * 1.2 / self.indistance + 0.2
        else
            --定时器未删除之前只作一次数字特效效果
            if self.isRotating and self.innerStatus then

                local ID =  self.numList[self.num]:GetInstanceID()
                if self.effectList[ID] == nil then
                    self.effectList[ID] = BibleRewardPanel.ShowEffect(20467, self.numList[self.num].transform, Vector3(0.5, 0.5, 1), Vector3(0, -40, -400))
                else
                    self.effectList[ID]:SetActive(false)
                    self.effectList[ID]:SetActive(true)
                end
                self.innerStatus = false
            end
        end
    else
        self.outCount =(self.outCount + self.outSpeed) % 360
        self.inCount =(self.inCount + self.innerSpeed) % 360
    end

    --设置位置
    self:SetTurnplatePosition(1,self.outCount)
    self:SetTurnplatePosition(2,self.inCount)

    self:SetItemsPosition(1,self.outCount * math.pi / 180)
    self:SetItemsPosition(2,self.inCount * math.pi / 180)

end


function SignDrawWindow:LoadRewardItemIconAndNum()
    self.rewardItems = self.model.rewardData.reward
    self.numbers = self.model.rewardData.number or {}

    for i, v in ipairs(self.rewardItems) do
        self.itemList[i].gameObject:SetActive(true)
        local obj = self.itemList[i]:Find("Icon").gameObject
        self:SetQuestSprite(0,DataItem.data_get[v.base_id].icon,obj.transform:GetComponent(Image))

        --角标设置
        if v.base_num == 1 then
            self.itemList[i]:Find("Num").gameObject:SetActive(false)
            self.itemList[i]:Find("NumBg").gameObject:SetActive(false)
        end
        self.itemList[i]:Find("Num"):GetComponent(Text).text = v.base_num

        if v.is_effect == 1 then
            local ID = self.itemList[i]:GetInstanceID()
            if self.effectList[ID] == nil then
                self.effectList[ID] = BibleRewardPanel.ShowEffect(20443, self.itemList[i].transform, Vector3(0.8, 0.8, 1), Vector3(0, 0, -400))
            end
        end

        self.btnList[i].onClick:RemoveAllListeners()
        self.btnList[i].onClick:AddListener( function()
            TipsManager.Instance:ShowItem( { gameObject = self.itemList[i].gameObject, itemData = DataItem.data_get[v.base_id], extra = { nobutton = true, inbag = false } })
        end )
    end

    for i, v in ipairs(self.numbers) do
        self:SetQuestSprite(2,string.format("num_%s",v.num),self.numList[i]:GetComponent(Image))
    end
end

function SignDrawWindow:LoadQuestItem()

    self.layout:ReSet()
     --签到任务特殊处理
    self.signItem = self.gameObject.transform:Find("Main/Mask/Container/SignItem")
    -- self:SetQuestSprite(1,1026,self.signItem.transform:Find("HeadBg/Image"):GetComponent(Image))
    self.signItem.transform:Find("Name"):GetComponent(Text).text = TI18N("我要签到")

    self:SetQuestSprite(0,DataItem.data_get[self.exchangeBaseId].icon,self.signItem.transform:Find("Times/gain"):GetComponent(Image))
    self.signItem.transform:Find("Times/num"):GetComponent(Text).text = self.model.sign.reward[1].sign_num
    self:SignCompletedStatus(self.model.sign.sign_status == 1)
    self.signItem.transform:Find("SpecailButton"):GetComponent(Button).onClick:RemoveAllListeners()
    self.signItem.transform:Find("SpecailButton"):GetComponent(Button).onClick:AddListener(function() self:SignBtn()  end)
    self.layout:AddCell(self.signItem.gameObject)

    --根据任务sort整理排序任务列表
    self.QuestItems = {}
    for i,v in ipairs (self.model.questList) do
        self.QuestItems[v.quest_sort] = v
    end

    for i,v in ipairs(self.QuestItems) do
        if self.questList[i] == nil then
            local obj = GameObject.Instantiate(self.templateItem)
            self.questList[i] = obj
        end
        --设置任务图标
        self:SetQuestSprite(1,v.icon,self.questList[i].transform:Find("HeadBg/Image"):GetComponent(Image))
        self.questList[i].transform:Find("Name"):GetComponent(Text).text = DataQuest.data_get[v.quest_id].name
        --设置任务可获得物品图标
        self:SetQuestSprite(0,DataItem.data_get[v.reward[1].base_id].icon,self.questList[i].transform:Find("Times/gain"):GetComponent(Image))
        self.questList[i].transform:Find("Times/num"):GetComponent(Text).text = string.format("%d",v.reward[1].num)
        --处理按钮状态

        self:SignQuestBtnStatus(v.quest_status,i)
        --任务进度
        self.questList[i].transform:Find("ActTimes"):GetComponent(Text).text = string.format(TI18N("%d/%d"),v.value,v.target_val)

        --消耗金币任务特殊处理
        if v.quest_id == 83698 then
            self.questList[i].transform:Find("ActTimes").sizeDelta = Vector2(120,23)
            if v.value > 100 then
                self.questList[i].transform:Find("ActTimes").anchoredPosition = Vector2(90,-16)
            else
                self.questList[i].transform:Find("ActTimes").anchoredPosition = Vector2(99.5,-16)
            end
        end

        --任务前往按钮
        self.questList[i].transform:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
        self.questList[i].transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
            local questData = QuestManager.Instance:GetQuest(v.quest_id)
            if questData == nil then
                NoticeManager.Instance:FloatTipsByString(TI18N("你已经领取过了"))
            else
                QuestManager.Instance:DoQuest(questData)
                -- --重新获取按钮状态
                SignDrawManager.Instance:Send20439()
            end
        end)

        self.layout:AddCell(self.questList[i])
    end
end


function SignDrawWindow:OnTimeListener()
    local d = nil
    local h = nil
    local m = nil
    local s = nil

    local timeText = self.gameObject.transform:Find("Main/CampaignTime"):GetComponent("Text")
    local targetMomont = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2], day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}

    if BaseUtils.BASE_TIME < targetMomont then
        d,h,m,s = BaseUtils.time_gap_to_timer(targetMomont - BaseUtils.BASE_TIME)

        if d ~= 0 then
            timeText.text = string.format(self.timeFormatString[6], "#ffff00", tostring(d + 1))
        --     timeText.text = string.format(self.timeFormatString[1], "#e8faff", tostring(d), tostring(h), tostring(m))
        elseif h ~= 0 then
            timeText.text = string.format(self.timeFormatString[2], "#ffff00", tostring(h), tostring(m))
        elseif m ~= 0 then
            timeText.text = string.format(self.timeFormatString[3], "#ffff00", tostring(m))
        else
            timeText.text = string.format(self.timeFormatString[4], "#ffff00", tostring(s))
        end
    else
        timeText.text = self.timeFormatString[5]
    end
end


function SignDrawWindow:SetExhcangeNum()
    if self.imgLoaderOne == nil then return end
    
    self.imgLoaderOne:SetSprite(SingleIconType.Item, DataItem.data_get[self.exchangeBaseId].icon)
    local num = BackpackManager.Instance:GetItemCount(self.exchangeBaseId)
    local textCount = self.gameObject.transform:Find("Main/Own/num"):GetComponent(Text)
    if num < 1 then
        textCount.text = string.format("<color='#ffff00'>%s</color>", tostring(num))
    else
        textCount.text = string.format("<color='#ffff00'>%s</color>", tostring(num))
    end

    --每次抽奖币获得时（打开面板时）打开特效
    self:ShowDrawBtn()
end

function SignDrawWindow:ShowTurnEffect()
    if self.Turneffect == nil then
        self.Turneffect = BibleRewardPanel.ShowEffect(20456, self.turnBtn.transform, Vector3(0.95, 0.95, 1), Vector3(0, 0, -400))
    else
        self.Turneffect:SetActive(false)
        self.Turneffect:SetActive(true)
    end
end


function SignDrawWindow:SetQuestSprite(type,iconid, img)
    local sprite = nil
    local SetNativeSize = false
    if type == 0 then
        local id = img.gameObject:GetInstanceID()
        if self.loaders[id] == nil then
            self.loaders[id] = SingleIconLoader.New(img.gameObject)
        end
        self.loaders[id]:SetSprite(SingleIconType.Item, iconid)
        return
    elseif type == 1 then
        sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, tostring(iconid))
    elseif type == 2 then
        sprite = self.assetWrapper:GetSprite(AssetConfig.signdraw_textures, tostring(iconid))
        SetNativeSize = true
    end
    img.sprite = sprite
    if SetNativeSize then
        img:SetNativeSize()
    end
    img.gameObject:SetActive(true)
end


function SignDrawWindow:SignBtn()
    if BackpackManager.Instance:GetCurrentGirdNum() == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理后再进行签到获得奖励"))
    else
        -- 发送签到协议
        SignDrawManager.Instance:Send20436()
    end
end


function SignDrawWindow:SignCompletedStatus(status)
    --是否签到
    local ID = self.signItem.transform:Find("SpecailButton").gameObject:GetInstanceID()
    if status then
        self.signItem.transform:Find("SpecailButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.signItem.transform:Find("SpecailButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton4Str, TI18N("已签到"))
        -- self.signItem.transform:Find("SpecailButton/RedImage").gameObject:SetActive(false)

        if self.effectList[ID] ~= nil then
            self.effectList[ID]:SetActive(false)
        end
    else
        self.signItem.transform:Find("SpecailButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.signItem.transform:Find("SpecailButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("我要签到"))
        -- self.signItem.transform:Find("SpecailButton/RedImage").gameObject:SetActive(true)

        if self.effectList[ID] == nil then
            self.effectList[ID] = BibleRewardPanel.ShowEffect(20053, self.signItem.transform:Find("SpecailButton"), Vector3(1.6, 0.7, 1), Vector3(-55, -16, -400))
        end
    end

end

function SignDrawWindow:SignQuestBtnStatus(status,i)
    local ID = self.questList[i]:GetInstanceID()
    if status == 0 then
        self.questList[i].transform:Find("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.questList[i].transform:Find("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("前往"))
        -- self.questList[i].transform:Find("Button/RedImage").gameObject:SetActive(false)

        if self.effectList[ID] ~= nil then
            self.effectList[ID]:SetActive(false)
        end
    elseif status == 1 then
        self.questList[i].transform:Find("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.questList[i].transform:Find("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("领取"))
        -- self.questList[i].transform:Find("Button/RedImage").gameObject:SetActive(true)
        if self.effectList[ID] == nil then
            self.effectList[ID] = BibleRewardPanel.ShowEffect(20053, self.questList[i].transform:Find("Button"), Vector3(1.2, 0.6, 1), Vector3(-39, -10, -400))
        end
    elseif status == 2 then
        self.questList[i].transform:Find("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.questList[i].transform:Find("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton4Str, TI18N("已领取"))
        -- self.questList[i].transform:Find("Button/RedImage").gameObject:SetActive(false)

        if self.effectList[ID] ~= nil then
            self.effectList[ID]:SetActive(false)
        end
    end

end


function SignDrawWindow:TweenScale(index,num)

    -- self.tweenId1 = Tween.Instance:Scale(self.itemList[index].gameObject,
    --     Vector3(1.1,1.1,1.1), 0.2,
    --     function()
    --         self.tweenId1 = nil
    --         self.tweenId2 = Tween.Instance:Scale(self.itemList[index].gameObject,Vector3(1,1,1), 0.2,function() end, LeanTweenType.linear)
    --     end,
    --     LeanTweenType.easeOutElastic)

    self.numList[num].gameObject.transform.localScale = Vector3(1.7,1.7,1)
    self.tweenId = Tween.Instance:Scale(self.numList[num].gameObject, Vector3(1,1,1), 0.4, function() end, LeanTweenType.easeOutElastic).id

     -- self.tweenId3 = Tween.Instance:Scale(self.numList[num].gameObject,
     --    Vector3(1.7,1.7,1.7), 0.2,
     --    function()
     --        self.tweenId3 = nil
     --        print("aaaaaaaaaaaaaaa")
     --        self.tweenId4 = Tween.Instance:Scale(self.numList[num].gameObject,Vector3(1,1,1), 0.2,function()
     --            self.tweenId4 = nil
     --         end, LeanTweenType.linear)
     --    end,
     --    LeanTweenType.linear)
end


function SignDrawWindow:RewardPanel()
    local returnTempList = { }


    returnTempList[1] = {base_id = self.item_baseid ,num = self.item_num * self.item_basenum}
    local rewardData = { }
    rewardData.item_list = returnTempList
    self.model:OpenGiftShow(rewardData)
    self.model.returnRewardlist = { }

    -- body
end


function SignDrawWindow:ShowDrawBtn()
    --抽奖按钮特效
    if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 0 then
        local ID = self.turnBtn:GetInstanceID()
            if self.effectList[ID] == nil then
                self.effectList[ID] = BibleRewardPanel.ShowEffect(20121, self.turnBtn.transform, Vector3(1.3, 1.3, 1), Vector3(0, 13.5, -400))
            end
    end
end
