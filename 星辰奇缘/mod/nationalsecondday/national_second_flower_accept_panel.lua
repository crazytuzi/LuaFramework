-- @author zyh(花花转盘)
-- @date 2017年9月19日
NationalSecondFlowerAcceptPanel = NationalSecondFlowerAcceptPanel or BaseClass(BasePanel)

function NationalSecondFlowerAcceptPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "NationalSecondFlowerAcceptPanel"

    self.resList = {
        {file = AssetConfig.nationalsecond_accept_panel, type = AssetType.Main}
         ,{file = AssetConfig.nationalsecond_accept_bg,type = AssetType.Main}
        ,{file = AssetConfig.nationalsecond_accept_texture,type = AssetType.Dep}
    }
-----

    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.extra = {inbag = false, nobutton = true}
    self.possibleReward = nil

    self.rotationTimeId = nil
    self.rewardIndex = nil
    self.rewardLength = nil
    self.nowIndex = 0
    self.nationalsecondflowerrewardpanel = nil

    self.isEnd = true
    self.tabItemList = {}
    self.activeTabItemList = {}
    self.boxObjList = {}
    self.isInit = false
    self.chooseDay = 0
    self.campId = nil
    self.selectItem = nil
    self.circlePoint = Vector3(1,-79.2,0)
    self.isShow = false
    self.isShowEffect = true

    self.isEffectBtn = true

    self.cond_desc = ""

    self.refreshListener = function() self:RefreshItemList() end
    self.startRotationListener = function(index) self:ShowEffectPanel() end
    self.showRotationListener = function(data) self:ShowRotationReward(data) end
    self.openNationalRewardListener = function() self:OpenNationSecondPanel() end
    self.getBoxRewardListener = function(data) self:ApplyGetBox(data) end
    self.getBoxOtherRewardListener = function(data) self:GetReward(data) end
    self.assetChangeListener = function() self:RefreshSum() end
end

function NationalSecondFlowerAcceptPanel:OnInitCompleted()

end

function NationalSecondFlowerAcceptPanel:__delete()
    self:RemoveListeners()

    self:EndTime()
    if self.nationSecondPanel ~= nil then
        self.nationSecondPanel:DeleteMe()
        self.nationSecondPanel = nil
    end

    if self.nationalTipsPanel ~= nil then
        self.nationalTipsPanel:DeleteMe()
        self.nationalTipsPanel = nil
    end

    if self.nationalShowPanel ~= nil then
        self.nationalShowPanel:DeleteMe()
        self.nationalShowPanel = nil
    end

    if self.isEnd == false then
      self.isEnd = true
    end


    if self.signRewardEffect ~= nil then
        self.signRewardEffect:DeleteMe()
        self.signRewardEffect = nil
    end

    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end

    if self.bufferTimeId ~= nil then
        LuaTimer.Delete(self.bufferTimeId)
        self.bufferTimeId = nil
    end

    if self.stopDelayTimeId ~= nil then
      LuaTimer.Delete(self.stopDelayTimeId)
      self.stopDelayTimeId = nil
   end

   if self.firstEffect ~= nil then
            self.firstEffect:DeleteMe()
            self.firstEffect = nil
    end

    if self.secondEffect ~= nil then
            self.secondEffect:DeleteMe()
            self.secondEffect = nil
    end

    if self.rewardEffect ~= nil then
            self.rewardEffect:DeleteMe()
            self.rewardEffect = nil
    end

    if self.itemSlotList ~= nil then
        for k,v in pairs(self.itemSlotList) do
            v:DeleteMe()
        end
        self.itemSlotList = {}
    end
    self:AssetClearAll()
end

function NationalSecondFlowerAcceptPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationalsecond_accept_panel))
    self.gameObject.name = self.name

    UIUtils.AddUIChild(self.parent,self.gameObject)
    local t = self.gameObject.transform
    self.transform = t
    self.gameObject:SetActive(false)
    self.mainTr = t:Find("Main")
    self.itemContainerTr = t:Find("Main/ItemContainer")
    self.middleButton = t:Find("Main/LuckDrawBtn"):GetComponent(Button)
    self.middleButton.onClick:AddListener(function() self:ApplyMiddleButton() end)
    self.middleButtonText = t:Find("Main/LuckDrawBtn/Text"):GetComponent(Text)
    self.middleButtonIcon = t:Find("Main/LuckDrawBtn/Image")

    self.middleButtonImage = t:Find("Main/LuckDrawBtn"):GetComponent(Image)


    self.middleText = t:Find("Main/LuckDrawBtn/Text"):GetComponent(Text)
    self.middleIcon = t:Find("Main/LuckDrawBtn/Image")

    self.bottomText = t:Find("Main/BottomBg/Text"):GetComponent(Text)
    self.bottomImg = t:Find("Main/BottomBg/Image"):GetComponent(Image)
    self.bottomButton = t:Find("Main/BottomBg"):GetComponent(Button)


    self.rewardBtn = t:Find("Main/RewardBtn"):GetComponent(Button)
    t:Find("Main/RewardBtn"):GetComponent(Image).enabled = true
    t:Find("Main/RewardBtn"):GetComponent(Image).color = Color(1,1,1,0)

    self.giveBtn = t:Find("Main/GiveButton"):GetComponent(Button)
    self.giveBtn.onClick:AddListener(function() self:ApplyGiveBtn() end)

    self.assetNumText = t:Find("Main/AssetBg/Text"):GetComponent(Text)
    self.bigBg = t:Find("Main/BigBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationalsecond_accept_bg))

    self.noticeText = t:Find("Main/NoticeTextBg/Text"):GetComponent(Text)
    self.luckDrawBtnRedPoint = t:Find("Main/LuckDrawBtn/Notify")

     self.slider = t:Find("Main/LuckDrawBtn/Slider"):GetComponent(Slider)
     self.sliderText = t:Find("Main/LuckDrawBtn/Slider/Text"):GetComponent(Text)

    UIUtils.AddBigbg(self.bigBg, bigObj)
    self.noticeBtn = t:Find("Main/Notice"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.cond_desc}})
    end)

    self.clickBtn = t:Find("Main/ClickBtn"):GetComponent(Button)
    self.clickBtn.onUp:AddListener(function() self:ApplyUpButton() end)
    self.clickBtn.onDown:AddListener(function() self:ApplyClickButton() end)

    self.redPoint = t:Find("Main/GiveButton/Notify")
    self.redPoint.gameObject:SetActive(false)

    self.clockText = t:Find("Main/clockBg/Text"):GetComponent(Text)

    self.assetAddBtn = t:Find("Main/AssetBg"):GetComponent(Button)
    local itemData = ItemData.New()
    itemData:SetBase(DataItem.data_get[90048])
    self.assetAddBtn.onClick:AddListener(function()  TipsManager.Instance:ShowItem({gameObject = self.assetAddBtn.gameObject, itemData = itemData, extra = {nobutton = false, inbag = false}}) end)

    local itemData2  = ItemData.New()
    itemData2:SetBase(DataItem.data_get[23285])
    self.bottomButton.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.bottomButton.gameObject, itemData = itemData2, extra = {nobutton = false, inbag = false}}) end)
    for i = 1,9 do
        local itemObj = self.itemContainerTr:GetChild(i - 1).gameObject
        local itemSlot = NationalSecondFlowerAcceptItem.New(itemObj,nil,i,self,self.itemContainerTr)
        self.itemSlotList[i] = itemSlot
    end


    self.effectPanel = t.transform:Find("Main/EffectPanel")
    t.transform:Find("Main/EffectPanel/Main").transform.anchoredPosition = Vector2(25,6)
    self.effectPanel:Find("Main"):GetComponent(Button).onClick:AddListener(function()
            self:ClickEffectPanel()
        end)
    self.effectPanel.gameObject:SetActive(false)

    self:OnOpen()
 end

function NationalSecondFlowerAcceptPanel:ApplyUpButton()
    if self.itemSlotList ~= nil and self.itemSlotList[self.selectIndex] ~= nil then
        if self.selectItem ~= nil then
            self.selectItem:ApplyButton(false)
            self.selectItem.isBig = false
            self.selectItem:IsFlash()
        end

        self.selectItem = self.itemSlotList[self.selectIndex]
        if self.selectItem ~= nil then
            self.selectItem:ApplyButton(true)
            self.selectItem.gameObject.transform:SetSiblingIndex(self.selectItem.gameObject.transform.parent.childCount - 1)
        end

        if self.nationalShowPanel == nil then
            self.nationalShowPanel = NationalSecondFlowerShowPanel.New(self,self.gameObject.transform)
        end
        self.nationalShowPanel:Show({[1] = self.selectIndex})

    end

end

function NationalSecondFlowerAcceptPanel:ApplyClickButton()
     if self.isInit == false or self.isEnd == false then
        return
    end
    local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1, self.gameObject.transform.position.z) --执行改变位置
    local pos = self.mainTr.transform:InverseTransformPoint(ctx.UICamera:ScreenToWorldPoint(curScreenSpace))
    local nowNormal = pos - self.circlePoint
    local direction = Vector3.Cross(Vector3.up,nowNormal)
    local angle = Vector3.Angle(Vector3.up,nowNormal)
    self.selectIndex = 0
    local distance = (pos - self.circlePoint).magnitude;


    if distance > 107.7 and distance < 255.7 then
        if angle < 11.25 then
            self.selectIndex = 5
            if self.itemSlotList[self.selectIndex] ~= nil then
                self.itemSlotList[self.selectIndex]:ApplyBig(true)
            end
        else
            if direction.z > 0 then
                self.selectIndex = 5 - math.ceil((angle - 11.25) / 22.25)
                if self.itemSlotList[self.selectIndex] ~= nil then
                    self.itemSlotList[self.selectIndex]:ApplyBig(true)
                end
            elseif direction.z < 0 then
                self.selectIndex = 5 + math.ceil((angle - 11.25) / 22.25)
                if self.itemSlotList[self.selectIndex] ~= nil then
                    self.itemSlotList[self.selectIndex]:ApplyBig(true)
                end
            end

        end

    end


end
function NationalSecondFlowerAcceptPanel:ShowEffect(t)
    if t == false then
        self.isShowEffect = false

        if self.secondEffect ~= nil then
            self.secondEffect:SetActive(false)
        end

        if self.firstEffect ~= nil then
            self.firstEffect:SetActive(false)
        end
    else
        self.isShowEffect = true
        if NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 1 and #NationalSecondManager.Instance.flowerGiveData >= 9 then
            if self.secondEffect == nil then
                self.secondEffect = BibleRewardPanel.ShowEffect(20420, self.rewardBtn.gameObject.transform, Vector3(0.65,0.65,1), Vector3(0,0, -50))
            end
            self.secondEffect:SetActive(true)

            if self.firstEffect ~= nil then
                self.firstEffect:SetActive(false)
            end
        else
            if self.firstEffect == nil then
                self.firstEffect = BibleRewardPanel.ShowEffect(20419, self.rewardBtn.gameObject.transform, Vector3(0.65,0.65,1), Vector3(0,0, -50))
            end
            self.firstEffect:SetActive(true)

            if self.secondEffect ~= nil then
                self.secondEffect:SetActive(false)
            end
        end
    end
end

function NationalSecondFlowerAcceptPanel:OnOpen()

    self.cond_desc = DataCampaign.data_list[self.campId].cond_desc

    self:AddListeners()
    NationalSecondManager.Instance:Send17890()


    -- self:CalculateTime()
end


function NationalSecondFlowerAcceptPanel:AddListeners()
    NationalSecondManager.Instance.OnUpdateFlowerData:AddListener(self.refreshListener)
    NationalSecondManager.Instance.OnUpdateFlowerBegin:AddListener(self.startRotationListener)
    NationalSecondManager.Instance.OnUpdateFlowerEnd:AddListener(self.showRotationListener)
    NationalSecondManager.Instance.OnUpdateBoxData:AddListener(self.openNationalRewardListener)
    NationalSecondManager.Instance.OnUpdateGetBox:AddListener(self.getBoxRewardListener)
    NationalSecondManager.Instance.OnUpdateGetOtherBox:AddListener(self.getBoxOtherRewardListener)

    EventMgr.Instance:AddListener(event_name.role_asset_change,self.assetChangeListener)
end


function NationalSecondFlowerAcceptPanel:RemoveListeners()
    NationalSecondManager.Instance.OnUpdateFlowerData:RemoveListener(self.refreshListener)
    NationalSecondManager.Instance.OnUpdateFlowerBegin:RemoveListener(self.startRotationListener)
    NationalSecondManager.Instance.OnUpdateFlowerEnd:RemoveListener(self.showRotationListener)
    NationalSecondManager.Instance.OnUpdateBoxData:RemoveListener(self.openNationalRewardListener)
    NationalSecondManager.Instance.OnUpdateGetBox:RemoveListener(self.getBoxRewardListener)
    NationalSecondManager.Instance.OnUpdateGetOtherBox:RemoveListener(self.getBoxOtherRewardListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change,self.assetChangeListener)
end


function NationalSecondFlowerAcceptPanel:ReloadItemSlotData()
    for i,v in ipairs(self.itemSlotList) do
        v:ShowEffect(false)
    end
end

function NationalSecondFlowerAcceptPanel:OnHide()
    self:RemoveListeners()
    self:EndTime()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.effiTween ~= nil then
        Tween.Instance:Cancel(self.effiTween)
        self.effiTween = nil
    end

    if self.itemSlotList ~= nil then
        for k,v in pairs(self.itemSlotList) do
            -- v:ShowFlashMoreEffect(false)
            v:ShowSelectBg(false)
        end
    end

   if self.bufferTimeId ~= nil then
        LuaTimer.Delete(self.bufferTimeId)
        self.bufferTimeId = nil
    end

   if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
   end

   if self.stopDelayTimeId ~= nil then
      LuaTimer.Delete(self.stopDelayTimeId)
      self.stopDelayTimeId = nil
   end


   if self.isEnd == false then
      self.isEnd = true
       -- NationalSecondManager.Instance:Send17884()
   end
end


function NationalSecondFlowerAcceptPanel:ApplyMiddleButton()

    --     if self.selectItem ~= nil then
    --         self.selectItem:ApplyButton(false)
    --     end
    --     NationalSecondManager.Instance:Send17891()
    -- end


    if self.isEnd == true and self.isInit == true then
        if RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.sunshine) < NationalSecondManager.Instance.flowerAcceptData.roll_cost then
            local itemData = ItemData.New()
            itemData:SetBase(DataItem.data_get[90048])
            TipsManager.Instance:ShowItem({gameObject = self.middleButton.gameObject, itemData = itemData, extra = {nobutton = false, inbag = false}})
        end
        NationalSecondManager.Instance:Send17891()
    end
end


function NationalSecondFlowerAcceptPanel:ApplyRewardBtn()

    if self.rewardEffect == nil then
        self.rewardEffect = BibleRewardPanel.ShowEffect(20422,self.rewardBtn.transform,Vector3(1,1, 1),Vector3(0,0,-50))
    end
    self.rewardEffect:SetActive(false)
    self.rewardEffect:SetActive(true)


    if self.isEnd == true and self.isInit == true then
        NationalSecondManager.Instance:Send17895()
    end
end

function NationalSecondFlowerAcceptPanel:OpenNationSecondPanel()


    if self.nationSecondPanel == nil then
        self.nationSecondPanel = NationalSecondFlowerRewardPanel.New(self,self.gameObject.transform)
    end
    if NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 0 then
        self.nationSecondPanel:Show({2})
    elseif NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 1 then
        self.nationSecondPanel:Show({1})
    end
end

function NationalSecondFlowerAcceptPanel:StartRotationTimer(index)
    self.animationTimes = 0
    self.rewardLength = #self.activateItemList
    self.startTimer = 350 / self.rewardLength
    for i,v in ipairs(self.activateItemList) do
        if self.itemSlotList[index] == v then
            self.rewardIndex = i
        end
    end
    self:RotationTimer()
end
function NationalSecondFlowerAcceptPanel:RotationTimer()
    if #self.activateItemList > 1 then
        math.randomseed(tostring(os.time()):reverse():sub(1,6))
        self.addNum = math.random(10,12)
        local targetRewardIndex = self.rewardIndex % self.rewardLength
        if self.rewardIndex > 0 and targetRewardIndex == 0 then
            targetRewardIndex = 8
        end

        self.tweenStartIndex = ((self.rewardIndex + self.rewardLength*10) - self.addNum) % (self.rewardLength)

        self.rotationTimeId = LuaTimer.Add(0,self.startTimer, function()
               self:ChangeItemSelect()
       end)
    else
        return
    end
end

function NationalSecondFlowerAcceptPanel:RefreshItemList()
    self.activateItemList = self.itemSlotList
    -- BaseUtils.dump(NationalSecondManager.Instance.flowerAcceptData.flowers_info,"花语数据66666666666666666666666666666666")
    for i,v in ipairs(NationalSecondManager.Instance.flowerAcceptData.flowers_info) do
        if self.itemSlotList[i] then
            self.itemSlotList[i]:SetSlot(v.id,self.extra,v.num)
            if v.num > 0 then
                self.itemSlotList[i]:IsFlash(true)
            else
                self.itemSlotList[i]:IsFlash(false)
            end
            self.itemSlotList[i]:ApplyButton(false)
            self.itemSlotList[i]:ShowSelectBg(false)
        end
    end

    if NationalSecondManager.Instance.flowerAcceptData.login_reward_state == 0 then
        self.middleButton.onClick:RemoveAllListeners()
        self.middleButton.onClick:AddListener(function() self:ApplyMiddleButton() end)
        -- self.middleButtonText.text = string.format("%s点亮",NationalSecondManager.Instance.flowerAcceptData.roll_cost)
        -- self.middleButtonText.color = ColorHelper.DefaultButton3
        -- self.middleButtonIcon.transform.anchoredPosition = Vector2(-41.6,0)
        -- self.middleButtonText.transform.anchoredPosition = Vector2(10.5,0)
        -- self.middleButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"DefaultButton3")
        self.middleButtonImage.color = Color(1,1,1,0)

        self.slider.gameObject:SetActive(true)
        self.slider.enabled = false
        self.slider.value = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.sunshine)/100
        self.sliderText.text = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.sunshine)
        self.middleText.gameObject:SetActive(false)
        self.middleIcon.gameObject:SetActive(false)
        self.bottomText.text = string.format("每%s阳光值可开启",NationalSecondManager.Instance.flowerAcceptData.roll_cost)
        self.bottomText.transform.anchoredPosition = Vector2(11,-6)
        self.bottomImg.gameObject:SetActive(true)
        self.luckDrawBtnRedPoint.gameObject:SetActive(false)

        if RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.sunshine) >= 100 then
            -- self.luckDrawBtnRedPoint.gameObject:SetActive(true)
            if self.signRewardEffect == nil then
                self.signRewardEffect = BibleRewardPanel.ShowEffect(20424,self.middleButton.transform,Vector3(0.75,0.75, 1),Vector3(0,0,-400))
            end
            self.signRewardEffect:SetActive(true)

            if self.effTimerId == nil then
                self.effTimerId = LuaTimer.Add(0,1800, function()
                   self.middleButton.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                   if self.effiTween == nil then
                       self.effiTween = Tween.Instance:Scale(self.middleButton.gameObject, Vector3(1,1,1), 1.2, function() self.effiTween = nil end, LeanTweenType.easeOutElastic).id
                    end
                end)
            end
            self.middleButton.transform:GetComponent(TransitionButton).enabled = true

        else
            if self.signRewardEffect ~= nil then
                self.signRewardEffect:SetActive(false)
            end

            self.middleButton.transform:GetComponent(TransitionButton).enabled = false
        end
    elseif NationalSecondManager.Instance.flowerAcceptData.login_reward_state == 1 then
        self.middleButton.onClick:RemoveAllListeners()
        self.middleButton.onClick:AddListener(function() self:ApplyLoginButton() end)
        self.middleButtonText.text = "登录领取"
         self.middleButtonText.color = ColorHelper.DefaultButton2
        self.middleButtonIcon.transform.anchoredPosition = Vector2(43.3,0)
        self.middleButtonText.transform.anchoredPosition = Vector2(-11.1,0)
        self.middleButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"DefaultButton2")

        self.middleText.gameObject:SetActive(true)
        self.middleIcon.gameObject:SetActive(true)

         self.bottomText.text = "每天首次登陆可领取"
         self.bottomText.transform.anchoredPosition = Vector2(23.3,-5.5)
         self.bottomImg.gameObject:SetActive(false)

        self.luckDrawBtnRedPoint.gameObject:SetActive(true)
        self.slider.gameObject:SetActive(false)

        if self.signRewardEffect ~= nil then
            self.signRewardEffect:SetActive(false)
        end
        self.middleButtonImage.color = Color(1,1,1,1)
        self.middleButton.transform:GetComponent(TransitionButton).enabled = true
    end

    self.rewardBtn.onClick:RemoveAllListeners()
    if NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 0 then
        self.rewardBtn.onClick:AddListener(function() self:ApplyRewardBtn() end)
        self.noticeText.text = "赠人玫瑰手留余香，剩下的花语请赠送好友吧"

    elseif NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 1 then
        -- if RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.sunshine) >= NationalSecondManager.Instance.flowerAcceptData.roll_cost then
        if #NationalSecondManager.Instance.flowerGiveData >= 9 then
            self.rewardBtn.onClick:AddListener(function() NationalSecondManager.Instance:Send17894() end)
            self.noticeText.text = "恭喜集齐缤纷花语，请领取奖励"

        else
            self.noticeText.text = string.format("集齐<color='#13fc60'>9种</color>花语获得芬芳宝箱,进度：<color='#13fc60'>%s/9</color>",#NationalSecondManager.Instance.flowerGiveData)
            self.rewardBtn.onClick:AddListener(function() self:ApplyRewardBtn() end)
        end
    end
    if self.isShowEffect == true then
        if NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 1 and #NationalSecondManager.Instance.flowerGiveData >= 9 then
            if self.secondEffect == nil then
                self.secondEffect = BibleRewardPanel.ShowEffect(20420, self.rewardBtn.gameObject.transform, Vector3(0.65,0.65,1), Vector3(0,0, -50))
            end
            self.secondEffect:SetActive(true)

            if self.firstEffect ~= nil then
                self.firstEffect:SetActive(false)
            end


        else
            if self.firstEffect == nil then
                self.firstEffect = BibleRewardPanel.ShowEffect(20419, self.rewardBtn.gameObject.transform, Vector3(0.65,0.65,1), Vector3(0,0, -50))
            end
            self.firstEffect:SetActive(true)

             if self.secondEffect ~= nil then
                self.secondEffect:SetActive(false)
            end
        end
    end

    if NationalSecondManager.Instance.flowerAcceptData.send_red_dot == 0 then
        self.redPoint.gameObject:SetActive(false)
    elseif NationalSecondManager.Instance.flowerAcceptData.send_red_dot == 1 then
        self.redPoint.gameObject:SetActive(true)
    end
    self:RefreshSum()
    self.isInit = true
    self.gameObject:SetActive(true)
end

function NationalSecondFlowerAcceptPanel:RefreshSum()


end

function NationalSecondFlowerAcceptPanel:ApplyGetBox(data)
    local data = {[1] = {id = data.base_id,num = data.num}}
    self.isShow = true
    self:GetReward(data,false)
end


function NationalSecondFlowerAcceptPanel:ApplyLoginButton()
    if self.isEnd == true and self.isInit == true then
        NationalSecondManager.Instance:Send17893()
    end
end

function NationalSecondFlowerAcceptPanel:ChangeItemSelect()
    if self.animationTimes < self.rewardLength* 3 + self.tweenStartIndex then
        self.animationTimes = self.animationTimes + 1
        self.nowIndex = self.animationTimes % (self.rewardLength)
        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end

        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end

        if self.activateItemList[self.nowIndex] ~= nil then
            self.activateItemList[self.nowIndex]:ShowSelectBg(true)
        end

        if self.activateItemList[lastEffectIndex] ~= nil then
            self.activateItemList[lastEffectIndex]:ShowSelectBg(false)
        end
    else
        if self.rotationTimeId ~= nil then
            LuaTimer.Delete(self.rotationTimeId)
            self.rotationTimeId = nil
        end
        local tweenTime = self.startTimer
        self.lastTweenIndex = 0
        self.bufferTimeId = LuaTimer.Add(self.startTimer, function()
               self.bufferTimeId = nil
               self:ValueChange()
       end)
   end

end

function NationalSecondFlowerAcceptPanel:ValueChange()

    if self.addNum >= 1 then

        if self.addNum >=1 then
            self.addNum = self.addNum - 1
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



        if self.activateItemList[self.nowIndex] ~= nil then
            self.activateItemList[self.nowIndex]:ShowSelectBg(true)
        end

        if self.activateItemList[lastEffectIndex] ~= nil then
            self.activateItemList[lastEffectIndex]:ShowSelectBg(false)
        end

         if self.addNum < 1 then
            self:TweenEnd()
            return
        end


        local time = math.pow(self.lastTweenIndex,2.53) + self.startTimer
        self.bufferId = LuaTimer.Add(time, function()
                   self.bufferId = nil
                   self:ValueChange()
        end)



    end

end

function NationalSecondFlowerAcceptPanel:TweenEnd()
    self.endTimes = 4
    self.stopDelayTimeId = LuaTimer.Add(400,120,function()  self:FlashItem() end)
end

function NationalSecondFlowerAcceptPanel:FlashItem()
    if self.endTimes > 0 then

        local t = self.activateItemList[self.nowIndex]:GetSelectBg()
        self.activateItemList[self.nowIndex]:ShowSelectBg(not t)
        -- self.activateItemList[self.nowIndex]:ShowFlashMoreEffect(false)
        -- self.activateItemList[self.nowIndex]:ShowFlashMoreEffect(true)
        self.endActiveEffect = self.activateItemList[self.nowIndex]
        self.endTimes = self.endTimes - 1
    else

        if self.stopDelayTimeId ~= nil then
            LuaTimer.Delete(self.stopDelayTimeId)
            self.stopDelayTimeId = nil
        end

    end
end


function NationalSecondFlowerAcceptPanel:ShowRotationReward(data)
    self.stopDelayTimeId = LuaTimer.Add(100,function() self.stopDelayTimeId = nil self:GetReward(data,true) end)
end

function NationalSecondFlowerAcceptPanel:GetReward(data,isBox)
    self.effectPanel.gameObject:SetActive(false)
    self.myData = {}
    if isBox == true then
        self:GetRewardData(data)
    elseif isBox == false then
        self.myData.item_list = data
    end

    self.isEffectBtn = true
    if self.activateItemList[self.nowIndex] ~= nil then
        self.activateItemList[self.nowIndex]:ShowSelectBg(false)
    end

    local deleteCallBack = function() self:DeleteCallBack() end


    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(nil,deleteCallBack,true)
    end

    self.giftShow:Show(self.myData)
end

function NationalSecondFlowerAcceptPanel:GetRewardData(data)
    self.myData.item_list = {}
    for k,v in pairs(data.item_list) do
        table.insert(self.myData.item_list,v)
    end

    for k,v in pairs(data.gift_list) do
        table.insert(self.myData.item_list,v)
    end
end
function NationalSecondFlowerAcceptPanel:SecondCallBack(table)
    if table.countTime <= 0 then
       table:DeleteMe()
    else
       table.confirmText.text = "确定" .. string.format("(%ss)", tostring(table.countTime))
    end
end



function NationalSecondFlowerAcceptPanel:DeleteCallBack()

    if self.isShow == true then
        self.isShow = false
        self:ApplyRewardBtn()
    end
    if self.endActiveEffect ~= nil then
        -- self.endActiveEffect:ShowFlashMoreEffect(false)
    end
    self.giftShow = nil
    self.isEnd = true
end

function NationalSecondFlowerAcceptPanel:CalculateTime()
    self:EndTime()
    local baseTime = BaseUtils.BASE_TIME
    local h = tonumber(os.date("%H", baseTime))
    local m = tonumber(os.date("%M", baseTime))
    local s = tonumber(os.date("%S", baseTime))

    self.timestamp = 86400 -(h*3600 + m*60 + s)

    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function NationalSecondFlowerAcceptPanel:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        self.clockText.text = h .. "时" .. mm .. "分" .. ss .. "秒"
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function NationalSecondFlowerAcceptPanel:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function NationalSecondFlowerAcceptPanel:ApplyGiveBtn()
     if #NationalSecondManager.Instance.flowerGiveFriendData <=0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前<color='#ffff00'>没有可赠送的花语</color>，快努力收集吧{face_1,18}"))
    else
        if self.isEnd == true and self.isInit == true then
            NationalSecondManager.Instance:Send17898()
            if self.nationalTipsPanel == nil then
                self.nationalTipsPanel = NationalSecondFlowerTipsPanel.New(self,self.gameObject.transform)
            end
            self.nationalTipsPanel:Show()
        end
    end
end

function NationalSecondFlowerAcceptPanel:ShowEffectPanel(index)
    self.isEnd = false
    self.effectPanel.gameObject:SetActive(true)

    if self.effect_1 ~= nil then
        self.effect_1:SetActive(false)
    end

    if self.effect_3 ~= nil then
        self.effect_3:SetActive(false)
    end

    if self.effect_1 == nil then
        self.effect_1 = BibleRewardPanel.ShowEffect(20423, self.effectPanel:Find("Main").gameObject.transform, Vector3(0.65,0.65,1), Vector3(100,-176, -400))
    end
    self.effect_1:SetActive(true)

    self.effectTime = BaseUtils.BASE_TIME
end

function NationalSecondFlowerAcceptPanel:ClickEffectPanel()

    if BaseUtils.BASE_TIME - self.effectTime > 0 then
       if self.isEffectBtn == true then
            self.isEffectBtn = false
            if self.effect_3 == nil then
                if self.effect_13 == nil then
                    self.effect_3 = BibleRewardPanel.ShowEffect(20018,self.effectPanel:Find("Main").gameObject.transform, Vector3(0.65,0.65,1), Vector3(8,-30, -50))
                end
                self.effect_3:SetActive(true)

            else
                self.effect_3:SetActive(false)
                self.effect_3:SetActive(true)


            end
            self.timerId = LuaTimer.Add(700, function() self:HideEffectPanel() end)
        end
    end
end

function NationalSecondFlowerAcceptPanel:HideEffectPanel()
    self.effectPanel.gameObject:SetActive(false)
    NationalSecondManager.Instance:Send17892()
end

-- function NationalSecondFlowerAcceptPanel:GetReward(rewardList)

--      self.nowBeautifulId = 1
--     if self.possibleReward == nil then
--         self.possibleReward = SevenLoginTipsPanel.New(self)
--     end

--     if self.beatifulId ~= nil then
--         LuaTimer.Delete(self.beatifulId)
--         self.beatifulId = nil
--     end

--     local callBack = function(height) self:CallBack(self.possibleReward,height) end
--     local timeCallBack = function() self:SecondCallBack(self.possibleReward) end
--     local deleteCallBack = function() self:DeleteCallBack() end


--      self.possibleReward:Show({rewardList,5,{[5] = false},"",{0,0,200/255},{0,1000,timeCallBack},callBack,deleteCallBack})

--      self.nowBeautifulId = 1
--      self.falshNum = 4
--      self.nowItemId = 0
--      self.hasNextRewardLength = 1
--      self.targetRewardId = 0
--      self.hasArriveTarget = true
--      self:Vector3(0, 32, -400)(true)
--      self.isEnd = true
-- end





