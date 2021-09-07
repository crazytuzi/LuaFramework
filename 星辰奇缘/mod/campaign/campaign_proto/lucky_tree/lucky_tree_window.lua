-- @author hze
-- @date #2019/05/28#
--幸运树-摇一下活动

LuckyTreeWindow = LuckyTreeWindow or BaseClass(BaseWindow)

function LuckyTreeWindow:__init(model)
    self.model = model
    self.name = "LuckyTreeWindow"

    self.windowId = WindowConfig.WinID.LuckyTreeWindow

    self.resList = {
        {file = AssetConfig.lucky_tree_window, type = AssetType.Main}
        ,{file = AssetConfig.lucky_tree_bg, type = AssetType.Main}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
        ,{file = AssetConfig.luckytreetextures, type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
    }

    self.itemList = {}

    self.totalTime = 2000

    self.udpateDataListener = function() 
        if self.model.getItemMark then 
            self:UpdateData() 
        end
    end
    self.rotationTimerListener = function(item_id) self:RotationTimer(item_id) end
    self.obtainedListener = function() self:Obtained() end

    self.timeFormatString =
    {
        TI18N("剩余：<color='%s'>%s天%s小时%s分</color>"),
        TI18N("剩余：<color='%s'>%s时%s分</color>"),
        TI18N("剩余：<color='%s'>%s分</color>"),
        TI18N("剩余：<color='%s'>%s秒</color>"),
        TI18N("活动已结束"),
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function LuckyTreeWindow:__delete()
    self.OnHideEvent:Fire()

    BaseUtils.ReleaseImage(self.btn.transform:GetComponent(Image))

    for _, item in ipairs(self.itemList) do
        if item ~= nil then 
            item:DeleteMe()
        end
    end

    if self.costImgloader ~= nil then
        self.costImgloader:DeleteMe()
        self.costImgloader = nil
    end

    if self.timerId ~= nil then 
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
    end

    if self.rotationTimerId ~= nil then
        LuaTimer.Delete(self.rotationTimerId)
        self.rotationTimerId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LuckyTreeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lucky_tree_window))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
    UIUtils.AddBigbg(self.transform:Find("Main/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.lucky_tree_bg)))

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)


    self.itemContainer = self.transform:Find("Main/ItemContainer")

    self.campaignTimeTxt = self.transform:Find("Main/Time/Text"):GetComponent(Text)

    self.costImgloader = SingleIconLoader.New(self.transform:Find("Main/Dialog2/Image").gameObject)
    self.costNumTxt = self.transform:Find("Main/Dialog2/Text"):GetComponent(Text)

    self.btn = self.transform:Find("Main/Button"):GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClick() end)

    self.noticeBtn = self.transform:Find("Main/Notice").gameObject:GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campaignData.content}}) end)

    self.numTxt = self.transform:Find("Main/HaveNumTxt"):GetComponent(Text)
    self.transform:Find("Main/Notice/Text"):GetComponent(Text).text = TI18N("每次抽奖消耗的松果会随着摇一摇次数增加而增加")

    self.effectTrans = self.itemContainer:Find("Effect")
end

function LuckyTreeWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LuckyTreeWindow:OnOpen()
    self:RemoveListeners()
    CampaignProtoManager.Instance.luckytreeUpdateEvent:Add(self.udpateDataListener)
    CampaignProtoManager.Instance.lucktreeGetEvent:Add(self.rotationTimerListener)
    -- CampaignProtoManager.Instance.lucktreeObtainedEvent:Add(self.obtainedListener)

    
    self.model.getItemMark = true
    if self.openArgs ~= nil and self.openArgs.campId ~= nil then 
        self.model.luckytreeCampId = self.openArgs.campId
        self.campId = self.model.luckytreeCampId
        self.campaignData = DataCampaign.data_list[self.openArgs.campId]
    end
    self.campId = self.model.luckytreeCampId

    self.transform:Find("Main/Title"):GetChild(1):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, CampaignManager.GetTitleNameByCampaignId(self.campId))
    self.transform:Find("Main/Title"):GetChild(1):GetComponent(Image):SetNativeSize()

    self:OnTimeListener()
    
    CampaignProtoManager.Instance:Send20482()
    PlayerPrefs.SetInt(BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, CampaignProtoManager.Instance.LuckyTreeTag),BaseUtils.BASE_TIME)
end
    

function LuckyTreeWindow:OnHide()
    self:RemoveListeners()

    CampaignProtoManager.Instance:Send20484()
end

function LuckyTreeWindow:RemoveListeners()
    CampaignProtoManager.Instance.luckytreeUpdateEvent:Remove(self.udpateDataListener)
    CampaignProtoManager.Instance.lucktreeGetEvent:Remove(self.rotationTimerListener)
    -- CampaignProtoManager.Instance.lucktreeObtainedEvent:Remove(self.obtainedListener)
end

function LuckyTreeWindow:UpdateData()
    self.data = self.model.luckytreeData
    local list = self.data.list
    for index, dat in ipairs(list) do
        local item = self.itemList[dat.site]
        if item == nil then 
            item = LuckyTreeItem.New(self.itemContainer:Find(string.format("Item%s", index)), self)
        end
        item:SetVal(dat)
        self.itemList[dat.site] = item
    end

    local costItemId = self.data.cost_item
    self.costImgloader:SetSprite(SingleIconType.Item, DataItem.data_get[costItemId].icon)

    self.costNumTxt.text = string.format("x%s", self.data.num)

    if self.data.finishFlag then
        self.btn.transform:Find("Text"):GetComponent(Text).text = TI18N("已获得")
        self.btn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end

    if #list > 0 then 
        self.itemContainer.gameObject:SetActive(true)
        self.transform:Find("Main/Dialog2").gameObject:SetActive(true)
        self.transform:Find("Main/Time").gameObject:SetActive(true)
    end

    self.numTxt.text = BackpackManager.Instance:GetItemCount(self.data.cost_item)
end


function LuckyTreeWindow:OnTimeListener()
    if self.timerId ~= nil then 
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    local d = nil
    local h = nil
    local m = nil
    local s = nil

    local targetMomont = os.time{year = self.campaignData.cli_end_time[1][1], month = self.campaignData.cli_end_time[1][2], day = self.campaignData.cli_end_time[1][3], hour = self.campaignData.cli_end_time[1][4], min = self.campaignData.cli_end_time[1][5], sec = self.campaignData.cli_end_time[1][6]}

    local timeLoop = function()  
        if BaseUtils.BASE_TIME < targetMomont then
            d,h,m,s = BaseUtils.time_gap_to_timer(targetMomont - BaseUtils.BASE_TIME)
    
            if d ~= 0 then
                self.campaignTimeTxt.text = string.format(self.timeFormatString[1], "#e8faff", tostring(d), tostring(h), tostring(m))
            elseif h ~= 0 then
                self.campaignTimeTxt.text = string.format(self.timeFormatString[2], "#ffffff", tostring(h), tostring(m))
            elseif m ~= 0 then
                self.campaignTimeTxt.text = string.format(self.timeFormatString[3], "#ffffff", tostring(m))
            else
                self.campaignTimeTxt.text = string.format(self.timeFormatString[4], "#ffffff", tostring(s))
            end
        else
            self.campaignTimeTxt.text = self.timeFormatString[5]
        end
    end

    self.timerId = LuaTimer.Add(0, 1000, timeLoop)
end

function LuckyTreeWindow:OnClick()
    if not self.model.getItemMark then return end
    if not self.data then return end

    local costItemId = self.data.cost_item
    local itemData = DataItem.data_get[costItemId]

    local have_num = BackpackManager.Instance:GetItemCount(costItemId)
    local need_num = self.data.num

    local str_name = ColorHelper.color_item_name(itemData.quality, itemData.name)

    if self.data.finishFlag then 
        NoticeManager.Instance:FloatTipsByString(TI18N("已全部获取"))
    else
        if have_num < need_num then 
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = string.format(TI18N("当前拥有的%s不足，是否确认花费<color='#fff000'>%s</color>{assets_2, 90002}补足，并摇一下幸运树？"), str_name, self.data.exchang_val * (need_num - have_num))
            confirmData.sureLabel = TI18N("确 定")
            confirmData.cancelLabel = TI18N("取 消")
            confirmData.sureCallback = function() 
                self.model.getItemMark = false
                CampaignProtoManager.Instance:Send20483() 
            end
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            self.model.getItemMark = false
            CampaignProtoManager.Instance:Send20483()
        end
    end
end


function LuckyTreeWindow:RotationTimer(item_id)
    self.get_item_id = item_id
    local activateList = self.data.unObtained_list
    table.sort( activateList, function(a,b) return a.site < b.site end)

    local length = self.data.unObtainedLength

    local target_index = 1
    for index, v in ipairs(activateList) do
        if v.item_id == self.get_item_id then 
            target_index = index
        end
    end

    local single_time = self.totalTime / (3 * length + target_index)

    for _,item in ipairs(self.itemList) do
        item:SetSelectEffectActive(false)
    end

    for _,v in ipairs(activateList) do
        self.itemList[v.site]:Shake(true)
    end

    local index = 1
    local total_index = 3 * length + target_index

    ----方案一
    -- if self.rotationTweenId ~= nil then
    --     Tween.Instance:Cancel(self.rotationTweenId)
    --     self.rotationTweenId = nil
    -- end

    -- self.rotationTweenId = Tween.Instance:ValueChange(1, total_index, 4 * (length /12), function()
    --         Tween.Instance:Cancel(self.rotationTweenId)
    --         self.rotationTweenId = nil
    --         self:Obtained()
    --     end, LeanTweenType.easeOutQuad, function(value)

    --         local delta = value / total_index

    --         if delta >= index / total_index then
    --             local index_tmp = (index -1) % length + 1
    --             local site = activateList[index_tmp].site
    --             if self.last_site ~= site then 
    --                 if self.itemList[self.last_site] ~= nil then 
    --                     self.itemList[self.last_site]:SetSelectEffectActive(false)
    --                 end
    --                 self.itemList[site]:SetSelectEffectActive(true)
    --                 self.last_site = site
    --             end
    --             index = index + 1
    --         end
    -- end).id

    --方案二
    if self.rotationTimerId ~= nil then
        LuaTimer.Delete(self.rotationTimerId)
        self.rotationTimerId = nil
    end

    local count = 1
    local a = ((target_index + 6) * length) /(total_index * total_index - 9 * length *length)
    local b = 6 * length - ( a * 9 * length * length)

    -- local a = 0.8
    -- local b = 50

    local fun = function()
        if index <= total_index then 
            local delta = false
            if index < 3 * length then 
                if count == index * 2 then 
                    delta = true
                end
            else
                if count == math.ceil( index * index * a + b ) then
                    delta = true
                end
            end


            if delta then 
                local index_tmp = (index -1) % length + 1
                local site = activateList[index_tmp].site
                if self.last_site ~= site then 
                    if self.itemList[self.last_site] ~= nil then 
                        self.itemList[self.last_site]:SetSelectEffectActive(false)
                    end
                    self.itemList[site]:SetSelectEffectActive(true)
                    self.last_site = site
                end
                index = index + 1
            end
            count = count + 1
        else
            if self.rotationTimerId ~= nil then
                LuaTimer.Delete(self.rotationTimerId)
                self.rotationTimerId = nil
            end
            self:Obtained()
        end
    end
    self.rotationTimerId = LuaTimer.Add(0, 30, fun)


    self.numTxt.text = BackpackManager.Instance:GetItemCount(self.data.cost_item)
end

function LuckyTreeWindow:Obtained()
    for _,item in ipairs(self.itemList) do
        item:Shake(false)
    end
     
    CampaignProtoManager.Instance:Send20484()

    self.itemList[self.last_site]:SetSelectEffectActive(true)   --防止出错 

    if self.effect == nil then 
        self.effect = BaseUtils.ShowEffect(20525, self.effectTrans, Vector3.one, Vector3(0, 0, -300))
    end
    self.effectTrans.anchoredPosition = self.itemList[self.last_site].transform.anchoredPosition
    self.effect:SetActive(false)
    self.effect:SetActive(true)

    LuaTimer.Add(1000, function() 
        local returnTempList = { }
        returnTempList[1] = {base_id = self.get_item_id ,num = 1}
        local rewardData = { }
        rewardData.item_list = returnTempList
        BackpackManager.Instance.mainModel:OpenGiftShow(rewardData)
    end)

    self:UpdateData()
end








