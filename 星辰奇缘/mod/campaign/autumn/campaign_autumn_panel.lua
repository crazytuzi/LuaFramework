CampaignAutumnPanel = CampaignAutumnPanel or BaseClass(BasePanel)

function CampaignAutumnPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "CampaignAutumnPanel"

    self.resList = {
        {file = AssetConfig.campaign_autumn_panel, type = AssetType.Main}
        ,{file = AssetConfig.campaignautumn_bigbg, type = AssetType.Main}
        ,{file = AssetConfig.campaign_autumn_texture,type = AssetType.Dep}
        ,{file = AssetConfig.heads,type = AssetType.Dep}
        ,{file = AssetConfig.big_reward,type = AssetType.Dep}
        ,{file = AssetConfig.big_reward_flash,type = AssetType.Dep}
        ,{file = AssetConfig.big_reward_bg,type = AssetType.Dep}
        ,{file = AssetConfig.open_server_luckymoney2,type = AssetType.Dep}
    }
-----

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.extra = {inbag = false, nobutton = true}

    self.itemList = {}
    self.itemEffectList = {}

    self.nowPrice = 0
    self.minPrice = 0
    self.rewardId = 1
    self.rewardItemId = 0
    self.friendItemList = {}
    self.isOpen = false
    self.refreshListener = function() self:UpdateData() end
end

function CampaignAutumnPanel:OnInitCompleted()

end

function CampaignAutumnPanel:__delete()
    self:OnHide()
    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

     if self.secondEffect ~= nil then
        self.secondEffect:DeleteMe()
        self.secondEffect = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.myEffTimerId ~= nil then
        LuaTimer.Delete(self.myEffTimerId)
        self.myEffTimerId = nil
    end
    self:AssetClearAll()
end

function CampaignAutumnPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaign_autumn_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent,self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.bigBg = t:Find("Bg/BackGroundBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaignautumn_bigbg))
    UIUtils.AddBigbg(self.bigBg, bigObj)

    self.leftRewardBtn = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/LeftReward"):GetComponent(Button)
    self.rightRewardBtn = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/RightReward"):GetComponent(Button)


    self.leftRewardBgImg = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg"):GetComponent(Image)
    self.leftRewardBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.big_reward_bg,"BigRewardBg")

    self.rightRewardBgImg = self.transform:Find("Bg/BigRewardContainer/RightRewardBg"):GetComponent(Image)
    self.rightRewardBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.big_reward_bg,"BigRewardBg")

    self.leftRewardFlashImg = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/LeftFlash")
    self.firstEffect = BibleRewardPanel.ShowEffect(20425, self.leftRewardFlashImg .transform, Vector3.one, Vector3(0,-71, -10))
    self.firstEffect:SetActive(true)

    self.rightRewardFlashImg = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/RightFlash")
    self.secondEffect = BibleRewardPanel.ShowEffect(20425, self.rightRewardFlashImg.transform, Vector3.one, Vector3(0,-71, -10))
    self.secondEffect:SetActive(true)


    self.leftAssetText = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/LeftAssetText"):GetComponent(Text)

    self.leftNowAssetText = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/RightAssetText"):GetComponent(Text)
    self.rightNowAssetText = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/RightAssetText"):GetComponent(Text)

    self.originalPriceText = self.transform:Find("Bg/AssetBg/OriginalPrice"):GetComponent(Text)
    self.originalPriceText.transform.anchoredPosition = Vector2(-9.8,0)

    self.noticeText = self.transform:Find("Bg/NoticeText")

    self.assetBg = self.transform:Find("Bg/AssetBg"):GetComponent(Button)
    self.assetBg.onClick:AddListener(function() self:ApplyNoticeBtn() end)
    self.assetBg.transform.anchoredPosition = Vector2(-229.9,-148.3)

    self.noticeBtn = self.transform:Find("Bg/Notice"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() self:ApplyNoticeBtn() end)

    self.sliderText = self.transform:Find("Bg/Slider/Handle Slide Area/Handle/TalkIcon/Text"):GetComponent(Text)
    self.sliderButton = self.transform:Find("Bg/Slider/Handle Slide Area/Handle/TalkIcon"):GetComponent(Button)
    self.sliderButton.onClick:AddListener(function() self:ApplyNoticeBtn() end)

    self.leftRewardImg = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/LeftReward"):GetComponent(Image)
    self.leftRewardImg.gameObject:SetActive(false)
    self.leftRewardDisCountTr = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/DisCountImg")
    self.leftRewardDisCountText = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/DisCountImg/Text"):GetComponent(Text)
    self.rightRewardImg = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/RightReward"):GetComponent(Image)
    self.rightRewardImg.gameObject:SetActive(false)


    self.leftRewardBtn.onClick:AddListener(function() self:ApplyLeftRewardBtn() end)
    self.rightRewardBtn.onClick:AddListener(function() self:ApplyRightRewardBtn() end)

    self.leftDataText = self.transform:Find("Bg/LeftTextBg/LeftText"):GetComponent(Text)
    self.rightDataText = self.transform:Find("Bg/RightTextBg/RightText"):GetComponent(Text)

    self.leftNumText = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/NumBg/NumText"):GetComponent(Text)
    self.rightNumText = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/NumBg/NumText"):GetComponent(Text)

    self.leftNameText = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/CostText"):GetComponent(Text)
    self.rightNameText = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/CostText"):GetComponent(Text)

    self.leftNameImg = self.transform:Find("Bg/BigRewardContainer/LeftRewardBg/NameImg"):GetComponent(Image)
    self.rightNameImg = self.transform:Find("Bg/BigRewardContainer/RightRewardBg/NameImg"):GetComponent(Image)


    self.itemContainerTr = t:Find("Bg/RectScroll/Container")
    self.tabLayout = LuaBoxLayout.New(self.itemContainerTr.gameObject, {axis = BoxLayoutAxis.X, spacing = 0,border = 1})

    self.scrollRect = self.transform:Find("Bg/RectScroll"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)

    self.buyButton = t:Find("Bg/BuyButton"):GetComponent(Button)
    self.buyButton.onClick:AddListener(function() self:ApplyBuyButton() end)
    self.buyImage = t:Find("Bg/BuyButton"):GetComponent(Image)
    self.buyText = t:Find("Bg/BuyButton/Text"):GetComponent(Text)


    self.helpButton = t:Find("Bg/HelpButton"):GetComponent(Button)
    self.helpButton.onClick:AddListener(function() self:ApplyHelpButton() end)
    self.helpImage = t:Find("Bg/HelpButton"):GetComponent(Image)
    self.helpText = t:Find("Bg/HelpButton/Text"):GetComponent(Text)

    self.friendButton = t:Find("Bg/FriendButton"):GetComponent(Button)
    self.friendButton.onClick:AddListener(function() self:ApplyFriendButton() end)

    self.slider = t:Find("Bg/Slider"):GetComponent(Slider)
     -- self.sliderText = t:Find("Main/LuckDrawBtn/Slider/Text"):GetComponent(Text)
    self.reqHelp = t:Find("Bg/Reqhelp")
    self.reqHelp.transform.localPosition = Vector3(self.reqHelp.transform.localPosition.x,self.reqHelp.transform.localPosition.y,-40)
    self.reqHelp.transform.anchoredPosition = Vector2(1,65)
    self.reqHelp.gameObject:SetActive(false)

    self.guildHelpBtn = t:Find("Bg/Reqhelp/Guildhelp"):GetComponent(Button)
    self.guildHelpBtn.onClick:AddListener(function() self:ApplyGuildHelpButton() end)

    self.friendHelpBtn = t:Find("Bg/Reqhelp/Friendhelp"):GetComponent(Button)
    self.friendHelpBtn.onClick:AddListener(function() self:ApplyFriendHelpButton() end)

    self.reqHelpMaskBtn = t:Find("Bg/ReqHelpMaskPanel"):GetComponent(Button)
    self.reqHelpMaskBtn.gameObject:SetActive(false)
    self.reqHelpMaskBtn.onClick:AddListener(function() self:OnclickCloseReqHelpButton() end)

    self.leftAssetBg = t:Find("Bg/AssetBg/AssetImg")
    self.leftAssetBg.transform.sizeDelta = Vector2(29,29)



    self.friendObj = self.transform:Find("Bg/FriendCon").gameObject
    self.friendObj.transform.localPosition = Vector3(self.friendObj.transform.localPosition.x, self.friendObj.transform.localPosition.y,-40)
    self.friendcon = self.transform:Find("Bg/FriendCon/Mask/Con")
    self.frienditem = self.transform:Find("Bg/FriendCon/Mask/friendItem")
    self.frienditem.gameObject:SetActive(false)
    self.friendObj:SetActive(false)
    self.friendConMaskPanel = self.transform:Find("Bg/FriendConMaskPanel").gameObject
    self.friendConMaskPanel:GetComponent(Button).onClick:AddListener(function ()
        self:OnclickCloseFriendHelpButton()
    end)

    self.noFriendText = self.transform:Find("Bg/FriendCon/Mask/noFriendText")

    self.sendHelpButton = self.transform:Find("Bg/FriendCon/Sendbtn"):GetComponent(Button)
    self.sendHelpButton.onClick:AddListener(function () self:SendHelp() end)
    self:OnOpen()
end

function CampaignAutumnPanel:ApplyBuyButton()
    local strData = ""

    if self.rewardId == 1 then
        strData = string.format("直接消耗<color='#00ff00'>%s</color>钻石购买<color='#00ff00'>%s</color>礼包，是否购买？",self.nowPrice,self.leftNameText.text,self.nowPrice)
    elseif self.rewardId == 2 then
        strData = string.format("是否确认花费<color='#00ff00'>%s</color>钻石购买？",self.nowPrice)
    end
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = strData
    confirmData.sureSecond = -1
    confirmData.cancelSecond = -1
    if self.rewardId == 1 then
        confirmData.sureLabel = TI18N("一键购买")
        confirmData.cancelLabel = TI18N("继续砍价")
    elseif self.rewardId == 2 then
        confirmData.sureLabel = TI18N("购买")
        confirmData.cancelLabel = TI18N("取消")
    end

        confirmData.sureCallback = function()
          -- self.initConfirm = true
          -- self.frozen:OnClick()
            CampaignAutumnManager.Instance:Send20403(self.rewardItemId)
        end

    if self.rewardId == 1 then
      confirmData.cancelCallback = function()
          -- self.initConfirm = true
          -- self.frozen:OnClick()
          self:ApplyHelpButton()
      end
    end

      NoticeManager.Instance:ConfirmTips(confirmData)
end

function CampaignAutumnPanel:SendHelp()
    if RoleManager.Instance.RoleData.lev >=30 then
        -- local sendData = string.format(TI18N("亲爱的{string_2,#b031d5,%s},我想和你共同激活同心锁哟~{magpiefestival_1,点击接受邀请,%s,%s,%s}"), RoleManager.Instance.RoleData.name,RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
        if self.lastSelectFirendData ~= nil then
            local sendData = string.format(TI18N("我发起了%s-%s砍价求助,快来助我一臂之力吧{face_1,3}{bargain_1,点击帮助,%s,%s,%s,%s,%s}"), self.CampTitle, self.cutRewardName,RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id,RoleManager.Instance.RoleData.name,self.campId)
            FriendManager.Instance:SendMsg(self.lastSelectFirendData.id,self.lastSelectFirendData.platform,self.lastSelectFirendData.zone_id,sendData)
            local data = {id = self.lastSelectFirendData.id,platform = self.lastSelectFirendData.platform,zone_id = self.lastSelectFirendData.zone_id,classes = self.lastSelectFirendData.classes,lev = self.lastSelectFirendData.lev,sex = self.lastSelectFirendData.sex,name = self.lastSelectFirendData.name}
            FriendManager.Instance:TalkToUnknowMan(data)
        end
    else
        NoticeManager.Instance:FloatTipsByString("<color='#ffff00'>30级</color>以上才能参与，努力升级吧{face_1,3}")
    end
end
function CampaignAutumnPanel:ApplyGuildHelpButton()
    if GuildManager.Instance.model:check_has_join_guild() then
        -- local sendData = string.format(TI18N("我发起了%s-%s砍价求助,快来助我一臂之力吧{face_1,3}{bargain_1,点击帮助,%s,%s,%s,%s,%s}"), self.CampTitle, self.cutRewardName,RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id,RoleManager.Instance.RoleData.name,self.campId)
        local sendData = string.format(TI18N("我参与了砍价活动,快来助我一臂之力吧{face_1,3}{bargain_1,点击帮助,%s,%s,%s,%s,%s}"), RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id,RoleManager.Instance.RoleData.name,self.campId)
        ChatManager.Instance:SendMsg(4,sendData)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
    self:OnclickCloseReqHelpButton()
end

function CampaignAutumnPanel:ApplyFriendHelpButton()
    self:ShowOnLineFriendList()
    self:OnclickCloseReqHelpButton()
end

function CampaignAutumnPanel:ApplyNoticeBtn()
     TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData ={
            TI18N("1.<color='#ffff00'>进度条上的金额</color>表示已经成功砍价后<color='#ffff00'>实时售价</color>"),
            TI18N("2.若<color='#ffff00'>进度条为满</color>则表示已达到礼包<color='#7FFF00'>超值优惠折扣</color>"),
            TI18N("3.每位好友每天都可以砍价一次，邀请好友越多，礼包价格越优惠！"),
            --TI18N("4.购买可砍价的礼包后，将会获得<color='#7FFF00'>与购买金额同数量</color>的<color='#ffff00'>元旦礼券</color>"),
            TI18N("4.进度条为满时仍可继续呼朋唤友砍价，砍到底价为止")
            }})
end
function CampaignAutumnPanel:ShowOnLineFriendList()
    self.friendConMaskPanel:SetActive(true)
    self.friendObj:SetActive(true)
    for i=1,#self.friendItemList do
        self.friendItemList[i].gameObject:SetActive(false)
    end
    local friend_scrollRect = self.friendcon.parent:GetComponent(ScrollRect)
    for i,v in ipairs(FriendManager.Instance.online_friend_List) do
        local frienditem = self.friendItemList[i]
        if frienditem == nil then
            frienditem = GameObject.Instantiate(self.frienditem.gameObject)
            frienditem.transform:SetParent(self.friendcon)
            frienditem.transform.localScale = Vector3.one

            self.friendItemList[i] = frienditem
        end

        frienditem:SetActive(true)
        local key = BaseUtils.Key(v.classes,v.sex)
        frienditem.transform:Find("Slot/icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, key)
        frienditem.transform:Find("Slot/icon").gameObject:SetActive(true)
        if v.sex > 0 then
            frienditem.transform:Find("male").gameObject:SetActive(true)
        else
            frienditem.transform:Find("male").gameObject:SetActive(false)
        end
        frienditem.transform:Find("classes"):GetComponent(Text).text = KvData.classes_name[v.classes]
        frienditem.transform:Find("name"):GetComponent(Text).text = v.name
        frienditem.transform:GetComponent(Button).onClick:AddListener(function ()
            self:SelectFriend(frienditem, v)
            -- if self.helper ~= nil and #self.helper > 0 and self.selectitemgoid ~= nil and self.selectitemgoid.data.id ~= nil then
            --     self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            -- else
            --     self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            -- end
        end)
        if i == 1 then
            self:SelectFriend(frienditem, v)
        end
    end
    if #FriendManager.Instance.online_friend_List < 1 then
        self.noFriendText.gameObject:SetActive(true)
    end
end

function CampaignAutumnPanel:SelectFriend(frienditem, data)
    if self.lastSelectFriend ~= nil then
        self.lastSelectFriend.transform:Find("select").gameObject:SetActive(false)
    end
    self.lastSelectFriend = frienditem
    self.lastSelectFriend.transform:Find("select").gameObject:SetActive(true)
    self.lastSelectFirendData = data
    -- BaseUtils.dump(data,"SelectFriend ==")
end


function CampaignAutumnPanel:OnclickCloseReqHelpButton()
    self.reqHelpMaskBtn.gameObject:SetActive(false)
    self.reqHelp.gameObject:SetActive(false)
end

function CampaignAutumnPanel:OnclickCloseFriendHelpButton()
    self.friendObj:SetActive(false)
    self.friendConMaskPanel:SetActive(false)
end

function CampaignAutumnPanel:ApplyLeftRewardBtn()
    self.rewardId = 1
    self:OnRectScroll({x = 0})
    self.itemContainerTr.transform.anchoredPosition = Vector2(0,-2)

    self.rightRewardFlashImg.gameObject:SetActive(false)
    self.leftRewardFlashImg.gameObject:SetActive(true)


    self:UpdateData()
end

function CampaignAutumnPanel:ApplyRightRewardBtn()
    self.rewardId = 2
    self.itemContainerTr.transform.anchoredPosition = Vector2(0,-2)
    self.rightRewardFlashImg.gameObject:SetActive(true)
    self.leftRewardFlashImg.gameObject:SetActive(false)
    self:UpdateData()
end


function CampaignAutumnPanel:OnOpen()
    self.isOpen = false
    CampaignRedPointManager.Instance.campaignAutumnIsOpen = true
    CampaignManager.Instance.model:CheckCondType()
    self:AddListeners()
    self:ApplyLeftRewardBtn()
    self.itemContainerTr.transform.anchoredPosition = Vector2(0,-2)
    CampaignAutumnManager.Instance:Send20400(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)

    self.CampTitle = DataCampaign.data_list[self.campId].content

end

function CampaignAutumnPanel:ApplyHelpButton()
    if self.nowPrice <= self.minPrice then
        NoticeManager.Instance:FloatTipsByString("太牛了，竟然砍到了最低价，赶紧出手吧！{face_1,54}")
    else
        self.reqHelp.gameObject:SetActive(true)
        self.reqHelpMaskBtn.gameObject:SetActive(true)
    end
end

function CampaignAutumnPanel:ApplyFriendButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_autumn_friend_window)
end

function CampaignAutumnPanel:UpdateData()
    if CampaignAutumnManager.Instance.campaignData == nil then
        return
    end

    if self.myEffTimerId ~= nil then
        LuaTimer.Delete(self.myEffTimerId)
        self.myEffTimerId = nil
    end

    --self.tabLayout:ReSize()
    if self.tabLayout ~= nil then
        self.tabLayout:ReSet()
    end
    --BaseUtils.dump(CampaignAutumnManager.Instance.campaignData.price_info,"CampaignAutumnManager.Instance.campaignData.price_info:")
    for k,v in pairs(CampaignAutumnManager.Instance.campaignData.price_info) do
        if self.rewardId == v.type then
            self.myNum = #v.gift_info
            self.nowPrice = v.price
            self.minPrice = v.min_price
            self.itemContainerTr.transform.sizeDelta = Vector2((#v.gift_info) * (69)+ 2 ,78)

            self.scrollRect.movementType = ScrollRect.MovementType.Elastic
            self.scrollRect.onValueChanged:AddListener(function(value)
                self:OnRectScroll(value)
            end)

            for i2,v2 in ipairs(v.gift_info) do
                if self.itemList[i2] == nil then
                    local item = ItemSlot.New()
                    self.itemList[i2] = item
                end

                local myData = DataItem.data_get[v2.item_id2]
                local itemdata = ItemData.New()
                itemdata:SetBase(myData)
                self.itemList[i2]:SetAll(itemdata,self.extra)
                self.itemList[i2]:SetNum(v2.num2)
                self.itemList[i2].gameObject:SetActive(true)
                self.tabLayout:AddCell(self.itemList[i2].gameObject)

                if v2.spec_effects == 1 then
                    if self.itemEffectList[i2] == nil then
                        self.itemEffectList[i2] = BibleRewardPanel.ShowEffect(20223, self.itemList[i2].transform, Vector3.one, Vector3(32, 0, -10))
                    end
                    self.itemEffectList[i2]:SetActive(true)
                else
                    if self.itemEffectList[i2] ~= nil then
                        self.itemEffectList[i2]:SetActive(false)
                    end
                end

            end



            self.rewardItemId = v.item_id


            self.sliderText.text = v.price
            self.originalPriceText.text = v.old_price



            if v.type == 1 then
                  if v.price >v.change_price[1].change_price then
                    self.buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                    self.buyText.color = ColorHelper.DefaultButton2
                    self.buyText.text = "土豪现在就买"
                    self.slider.value = 1 - (v.price - v.change_price[1].change_price)/(v.old_price - v.change_price[1].change_price)
                        if self.myEffTimerId ~= nil then
                            LuaTimer.Delete(self.myEffTimerId)
                            self.myEffTimerId = nil
                        end
                else
                    self.buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    self.buyText.color = ColorHelper.DefaultButton3
                    self.buyText.text = "一键购买"
                    self.slider.value = 1
                    if self.myEffTimerId == nil then
                        self.myEffTimerId = LuaTimer.Add(1000, 3000, function()
                             self.buyImage.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                            Tween.Instance:Scale(self.buyImage.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
                        end)
                    end
                end
                if self.effTimerId ~= nil then
                    LuaTimer.Delete(self.effTimerId)
                    self.effTimerId = nil
                end

                if self.effTimerId == nil then
                    self.effTimerId = LuaTimer.Add(1000, 3000, function()
                        self.rightRewardBtn.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                        Tween.Instance:Scale(self.rightRewardBtn.gameObject, Vector3(1,1,1), 1.4, function() end, LeanTweenType.easeOutElastic)
                    end)
                end


                self.slider.gameObject:SetActive(true)
                self.assetBg.gameObject:SetActive(true)
                self.noticeBtn.gameObject:SetActive(true)
                self.noticeText.gameObject:SetActive(false)
                self.buyButton.transform.anchoredPosition = Vector2(-177,-198)

            elseif v.type == 2 then
                 if self.effTimerId ~= nil then
                    LuaTimer.Delete(self.effTimerId)
                    self.effTimerId = nil
                end

                if self.effTimerId == nil then
                    self.effTimerId = LuaTimer.Add(1000, 3000, function()
                        self.leftRewardBtn.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                        Tween.Instance:Scale(self.leftRewardBtn.gameObject, Vector3(1,1,1), 1.4, function() end, LeanTweenType.easeOutElastic)
                    end)
                end
                self.slider.gameObject:SetActive(false)
                self.assetBg.gameObject:SetActive(false)
                self.noticeText.gameObject:SetActive(true)
                self.noticeBtn.gameObject:SetActive(false)
                self.buyButton.transform.anchoredPosition = Vector2(1,-198)
                self.buyText.text = "一键购买"
                self.buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.buyText.color = ColorHelper.DefaultButton3

            end

            if v.buy_already < v.buy_limit then

                self.buyButton.onClick:AddListener(function() self:ApplyBuyButton() end)
                 self.helpButton.onClick:AddListener(function() self:ApplyHelpButton() end)
                self.helpImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.helpText.color = ColorHelper.DefaultButton3
            else
                self.buyButton.onClick:RemoveAllListeners()
                self.helpButton.onClick:RemoveAllListeners()
                self.buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.helpImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.buyText.color = ColorHelper.DefaultButton4
                self.helpText.color = ColorHelper.DefaultButton4
            end

            if #v.gift_info < #self.itemList then
                for i3=#v.gift_info + 1,#self.itemList do
                    self.itemList[i3].gameObject:SetActive(false)
                    if self.itemEffectList[i3] ~= nil then
                        self.itemEffectList[i3]:SetActive(false)
                    end
                end
            end
        end

        local CutPriceData = CampCutPriceData.data_get_gift_info[v.item_id]
        if v.type == 1 then

            self.leftAssetText.text = string.format("原价：%s",v.old_price)
            self.leftNowAssetText.text = v.price
            self.leftDataText.text = string.format("剩<color='#ffff00'>%s</color>天",CampaignAutumnManager.Instance.campaignData.rest_day)
            self.leftNameText.text = DataItem.data_get[v.item_id].name
            self.cutRewardName = DataItem.data_get[v.item_id].name
            if v.buy_already < v.buy_limit then
                self.leftNumText.text = string.format("限购<color='#ffff00'>%s</color>个",v.buy_limit)
            else
                self.leftNumText.text = "已售罄"
            end
            --local id = DataItem.data_get[v.item_id].icon
            -- self.leftRewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,"Item" .. id)
            -- self.leftNameImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,"Name" .. id)
            self.leftRewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,tostring(CutPriceData.res_id))
            self.leftNameImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,tostring(CutPriceData.text_id))
            self.leftNameImg:SetNativeSize()
            if v.price >= v.old_price then
                self.leftRewardDisCountTr.gameObject:SetActive(false)
            else
                self.leftRewardDisCountText.text =math.floor((v.price/v.old_price)*10) .. "折"
                self.leftRewardDisCountTr.gameObject:SetActive(true)
            end
            if v.buy_already >= v.buy_limit and self.isOpen == false then
                self.isOpen = true
                self:ApplyRightRewardBtn()
            end
            self.leftRewardImg.gameObject:SetActive(true)
        elseif v.type == 2 then
            self.rightNowAssetText.text = v.old_price
            self.rightDataText.text = "剩<color='#ffff00'>1</color>天"
            self.rightNameText.text = DataItem.data_get[v.item_id].name
            if v.buy_already < v.buy_limit then
                self.rightNumText.text = string.format("每日限购<color='#ffff00'>%s</color>个",v.buy_limit)
            else
               self.rightNumText.text  = "已售罄"
            end
            --(新增的图片名加3)
            local id = DataItem.data_get[v.item_id].icon
            -- self.rightRewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,"Item" .. id)
            self.rightRewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,tostring(CutPriceData.res_id))
            self.rightRewardImg.gameObject:SetActive(true)
            id = id + 3
            self.rightNameImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,tostring(CutPriceData.text_id))
            -- self.rightNameImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,"Name" .. id)
            self.rightNameImg:SetNativeSize()
        end

    end

    if self.rewardId == 1 then

        self.helpButton.gameObject:SetActive(true)
        self.friendButton.gameObject:SetActive(true)
    elseif self.rewardId == 2 then
        self.helpButton.gameObject:SetActive(false)
        self.friendButton.gameObject:SetActive(false)
    end
end


function CampaignAutumnPanel:AddListeners()
    CampaignAutumnManager.Instance.onRefreshData:AddListener(self.refreshListener)
end


function CampaignAutumnPanel:RemoveListeners()
    CampaignAutumnManager.Instance.onRefreshData:RemoveListener(self.refreshListener)
end



function CampaignAutumnPanel:OnHide()
    self:RemoveListeners()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    CampaignAutumnManager.Instance:Send20401(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
end

function CampaignAutumnPanel:OnRectScroll(value)
    if self.myNum == nil then
        return
    end
    -- local Right = (1 - value.x)*(self.scrollRect.content.sizeDelta.x - 512)
    -- -- local Right = Left + 416 + 128
    -- print(self.myNum)
    -- for i=1,self.myNum do
    --     local ax = self.itemList[i].transform.anchoredPosition.x
    --     local sx = self.itemList[i].transform.sizeDelta.x

    --     if ax + sx > Right or ax < Left then
    --         self.itemList[i].gameObject:SetActive(false)
    --     else
    --         self.itemList[i].gameObject:SetActive(true)
    --     end
    -- end


    local left = -self.scrollRect.content.anchoredPosition.x
    local right = left + self.scrollRect.transform.sizeDelta.x

    for k,v in pairs(self.itemList) do
        local ax = v.transform.anchoredPosition.x
        local sx = v.transform.sizeDelta.x
        local state = nil
        if ax < left or ax + sx > right then
            state = false
        else
            state = true
        end

        if v.transform:FindChild("Effect") ~= nil then
            v.transform:FindChild("Effect").gameObject:SetActive(state)
        end
    end

    -- local Left = (value.x-1)*(self.scrollRect.content.sizeDelta.x - 416) + 172.5 - 62 -65
    -- local Right = Left + 416 + 128
    -- for i=1,self.myNum do
    --     local ax = self.itemList[i].transform.anchoredPosition.x
    --     local sx = self.itemList[i].transform.sizeDelta.x

    --     if ax + sx > Right or ax < Left then
    --         self.itemList[i].gameObject:SetActive(false)
    --     else
    --         self.itemList[i].gameObject:SetActive(true)
    --     end
    --     local bx = self.itemContainerTr.transform.anchoredPosition.x+self.itemList[i].transform.anchoredPosition.x
    --     if bx <= -206 then
    --        if self.itemList[i].transform:FindChild("Effect") ~= nil then
    --            self.itemList[i].transform:FindChild("Effect").gameObject:SetActive(false)
    --        end
    --     else
    --        if self.itemList[i].transform:FindChild("Effect") ~= nil then
    --            self.itemList[i].transform:FindChild("Effect").gameObject:SetActive(true)
    --        end
    --     end
    -- end
end

