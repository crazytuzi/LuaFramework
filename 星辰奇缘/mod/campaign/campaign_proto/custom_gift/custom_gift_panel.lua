-- @author hze
-- @date #19/08/30#
-- @礼包定制活动

CustomGiftPanel = CustomGiftPanel or BaseClass(BasePanel)

function CustomGiftPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.custom_gift_panel, type = AssetType.Main},
        {file = AssetConfig.custom_gift_panel_big_bg, type = AssetType.Main},
        {file = AssetConfig.custom_gift_panel_bg, type = AssetType.Main},
        {file = AssetConfig.custom_gift_textures, type = AssetType.Dep},
    }
    -- self.model = model
    self.parent = parent
    self.mgr = CampaignProtoManager.Instance
    self.model = self.mgr.model     --model为CampaignProtoModel

    self.dayFormat = TI18N("剩\n<color='#fff000'>%s</color>\n天")
    self.timesFormat = TI18N("限购：<color='#fff000'>%s</color>/%s")

    self.itemList = {}

    self.giftList = {}
    self.gridList = {}
    self.selectList = {}

    self.selectReward = {}

    self.indexTOgiftId = {}

    self.lastSelectIndex = nil  --当前礼包当前框选中第几个奖励

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.reloadListener = function() self:ReloadData() end
end

function CustomGiftPanel:__delete()
    self.OnHideEvent:Fire()

    if self.giftList then
        for _, v in ipairs(self.giftList) do
            if v.nameIconloader then
                v.nameIconloader:DeleteMe()
            end
            if v.imgIconloader then
                v.imgIconloader:DeleteMe()
            end
        end
    end

    if self.gridList then
        for _, v in ipairs(self.gridList) do
            if v.slot then 
                v.slot:DeleteMe()
            end
        end
    end

    if self.extraSlot then 
        self.extraSlot:DeleteMe()
    end

    if self.customBtnTxt then 
        self.customBtnTxt:DeleteMe()
    end 

    if self.allBtnTxt then 
        self.allBtnTxt:DeleteMe()
    end 

    self:AssetClearAll()
end

function CustomGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.custom_gift_panel))
    self.gameObject.name = "CustomGiftPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform:Find("Main")

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.custom_gift_panel_big_bg)))
    UIUtils.AddBigbg(t:Find("BgTitle/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.custom_gift_panel_bg)))

    self.timeTxt = t:Find("BgTitle/TimeTxt"):GetComponent(Text)

    local container = t:Find("Container")
    for i = 1, 3 do
        local tab = {}
        tab.transform = container:GetChild(i - 1)
        tab.dayTxt = tab.transform:Find("Tag/Text"):GetComponent(Text)
        tab.timesTxt = tab.transform:Find("Times"):GetComponent(Text)
        tab.nameIconloader = SingleIconLoader.New(tab.transform:Find("Name").gameObject)
        tab.imgIconloader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
        tab.active = tab.transform:Find("Active").gameObject
        tab.inactive = tab.transform:Find("InActive").gameObject
        tab.btn = tab.transform:GetComponent(Button)
        tab.btn.onClick:AddListener(function() self:OnGiftClick(i) end)
        self.giftList[i] = tab
    end

    local grid = t:Find("Reward/Items/Grid")
    for i = 1, 4 do
        local tab = {}
        tab.transform = grid:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.slot = ItemSlot.New()
        tab.slot:SetNotips()
        tab.slot:ShowAddBtn(true)
        tab.slot:SetAddCallback(nil)
        tab.transform:GetComponent(Button).onClick:AddListener(function() self:OnAddRewardClick(i) end)
        UIUtils.AddUIChild(tab.gameObject, tab.slot.gameObject)
        self.gridList[i] = tab
    end

    self.extraSlot = ItemSlot.New()
    UIUtils.AddUIChild(t:Find("Reward/Extra/Slot").gameObject, self.extraSlot.gameObject)

    self.customBtn = t:Find("CustomButton"):GetComponent(Button)
    self.allBtn = t:Find("AllButton"):GetComponent(Button)
    self.previewBtn = t:Find("PreviewButton"):GetComponent(Button)

    self.customBtn.onClick:AddListener(function() self:OnBuyClick(1) end)
    self.allBtn.onClick:AddListener(function() self:OnBuyClick(2) end)
    self.previewBtn.onClick:AddListener(function() self.model:OpenCustomGiftRewardPanel(self.vo.cfg.id) end)

    self.customBtnImg = self.customBtn:GetComponent(Image)
    self.allBtnImg = self.allBtn:GetComponent(Image)

    self.customBtnTxt = MsgItemExt.New(t:Find("CustomButton/Text"):GetComponent(Text), 100, 18, 22)
    self.allBtnTxt = MsgItemExt.New(t:Find("AllButton/Text"):GetComponent(Text), 100, 18, 22)

    -- self.customBtnTxt = t:Find("CustomButton/Text"):GetComponent(Text)
    -- self.allBtnTxt = t:Find("AllButton/Text"):GetComponent(Text)

    self.selectPanel = t:Find("SelectPanel")
    self.selectPanel:Find("Mask"):GetComponent(Button).onClick:AddListener(function() self.selectPanel.gameObject:SetActive(false) end)
    self.selectMain = self.selectPanel:Find("SelectMain")
    self.priceTxt1 = self.selectMain:Find("slogan1/Text1"):GetComponent(Text)
    self.priceTxt2 = self.selectMain:Find("slogan2/Text1"):GetComponent(Text)
    self.slogan2Txt2 = self.selectMain:Find("slogan2/Text2"):GetComponent(Text)
    
    local selectContainer = self.selectMain:Find("Container")
    for i = 1, 3 do
        local tab = {}
        tab.transform = selectContainer:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.iconloader = SingleIconLoader.New(tab.transform:Find("Slot/Icon").gameObject)
        tab.numBgObj = tab.transform:Find("Slot/NumBg").gameObject
        tab.numTxt = tab.transform:Find("Slot/NumBg/Num"):GetComponent(Text)
        tab.btn = tab.transform:Find("Slot"):GetComponent(Button)
        tab.markBtn = tab.transform:Find("Circle"):GetComponent(Button)
        -- tab.markBtn.onClick:AddListener(function() self:OnSelectItemClick(i) end)
        tab.markObj = tab.transform:Find("Circle/GreenTick").gameObject
        self.selectList[i] = tab
    end

    local tipsBtn = t:Find("TipsButton"):GetComponent(Button)
    tipsBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = tipsBtn.gameObject, itemData = self.tipsData}) end)
end

function CustomGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CustomGiftPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.updateCustomGiftEvent:AddListener(self.reloadListener)

    self.campaignData = DataCampaign.data_list[self.campId]

    self.tipsData = {self.campaignData.cond_desc}
    self.timeTxt.text = self.model:GetCampaignTimeStr(self.campId)

    self.model.customgift_lastkey = self.model.customgift_key  --用于判断红点
    self.mgr:Send20491()
    -- self:ReloadData()
end

function CustomGiftPanel:OnHide()
    self:RemoveListeners()
end

function CustomGiftPanel:RemoveListeners()
    self.mgr.updateCustomGiftEvent:RemoveListener(self.reloadListener)
end

function CustomGiftPanel:OnBuyClick(type)
    if self.vo.limit_status == 1 then 
        NoticeManager.Instance:FloatTipsByString(TI18N("该礼包已经售罄啦{face_1,3}"))
        return
    end
    if type == 1 then 
        local id = self.vo.cfg.id
        local list = {}
        for i = 1, self.vo.cfg.count do
            local _, index = self.model:GetSelectRewardById(id, i)
            if index ~= nil then 
                local indexTab = {}
                indexTab.index = index
                table.insert(list, indexTab)
            end
        end

        if #list == self.vo.cfg.count then 
            local dat = NoticeConfirmData.New()
            dat.type = ConfirmData.Style.Normal
            dat.content = string.format(TI18N("是否确认花费%s{assets_2, 90002}购买定制礼包？"), self.vo.cfg.custom_loss[1][2])
            dat.cancelLabel = TI18N("再选选")
            dat.sureCallback = function() self.mgr:Send20492(id, list) end
            NoticeManager.Instance:ConfirmTips(dat)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择奖励后再进行购买哟{face_1,3}"))
        end
    else
        local dat = NoticeConfirmData.New()
        dat.type = ConfirmData.Style.Normal
        dat.content = string.format(TI18N("是否确认花费%s{assets_2, 90002}购买所有奖励？"), self.vo.cfg.all_loss[1][2])
        dat.cancelLabel = TI18N("再选选")
        dat.sureCallback = function()
            self.mgr:Send20492(self.vo.cfg.id, {})
        end
        NoticeManager.Instance:ConfirmTips(dat)
    end
end

function CustomGiftPanel:OnGiftClick(index, isProto)
    if not isProto and index == self.lastIndex then
        return
    end

    if self.lastIndex and self.giftList[self.lastIndex] ~= nil then
        self.giftList[self.lastIndex].active:SetActive(false)
        self.giftList[self.lastIndex].inactive:SetActive(true)
    end
    if self.giftList[index] then
        self.giftList[index].active:SetActive(true)
        self.giftList[index].inactive:SetActive(false)
    end
    self.lastIndex = index

    for i, v in pairs(self.data) do
        if v.cfg.pos == index then
        end
    end

    local select_gift_id = self.indexTOgiftId[index]
    self.vo = self.data[select_gift_id]

    self:UpdateSelf()
end

function CustomGiftPanel:OnAddRewardClick(index)
    -- print("第几个槽：" .. index)
    -- if self.lastSelectIndex then 
    --     print("第几个奖励" .. self.lastSelectIndex)
    -- end
    --选中效果
    if self.lastGridIndex and self.gridList[self.lastGridIndex] then 
        self.gridList[self.lastGridIndex].slot:ShowSelect(false)
    end
    if self.gridList[index] then 
        self.gridList[index].slot:ShowSelect(true)
    end
    self.lastGridIndex = index

    --打开界面
    self.selectPanel.gameObject:SetActive(true)
    self.selectMain.anchoredPosition = Vector2(74 * (index -1), 40)

    --该槽奖励的价格
    self.priceTxt1.text = self.vo.cfg.custom_loss[1][2]
    self.priceTxt2.text = self.vo.cfg.all_loss[1][2]

    --第几个槽的所有奖励信息
    -- print("礼包id：" .. self.vo.cfg.id)
    local data = self.model:GetCustomGiftByIdPos(self.vo.cfg.id, index)
    BaseUtils.dump(data, "该槽可获的奖励")
    local count = 0
    for i, v in ipairs(data) do
        local item = self.selectList[i]
        item.gameObject:SetActive(true)

        local itemVo = ItemData.New()
        itemVo:SetBase(DataItem.data_get[v.item_id])
        item.iconloader:SetSprite(SingleIconType.Item, itemVo.icon)
        item.numBgObj:SetActive(v.item_num > 1)
        item.numTxt.text = self:FormatNum(v.item_num)
        item.btn.onClick:RemoveAllListeners()
        item.btn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = item.btn.gameObject, itemData = itemVo, extra = {nobutton = true}}) end)

        item.markBtn.onClick:RemoveAllListeners()
        item.markBtn.onClick:AddListener(function() self:OnSelectItemClick(i, index, itemVo) end)

        if v.effect ~= 0 and v.effect ~= nil then 
            if item.effect == nil then 
                item.effect = BaseUtils.ShowEffect(v.effect, item.btn.transform, Vector3.one, Vector3(0, 0, -500))
            else
                item.effect:SetActive(true)
            end
        else
            if item.effect ~= nil then
                item.effect:SetActive(false)
            end
        end
        itemVo.effectId = v.effect
        itemVo.index = v.index
        itemVo.item_num = v.item_num

        item.markObj:SetActive((((self.model.selectReward[self.vo.cfg.id] or {})[index] or {})[i] or {}).select == true)
        count = count + 1
    end
    self.slogan2Txt2.text = string.format(TI18N("每个槽位获得所有%s种奖励"), count)
    for i = count + 1, 3 do
        local item = self.selectList[i]
        if item then
            item.gameObject:SetActive(false)
        end
    end
end

function CustomGiftPanel:OnSelectItemClick(index, parentIndex, itemVo)
    if self.lastSelectIndex and self.selectList[self.lastSelectIndex] then 
        self.selectList[self.lastSelectIndex].markObj:SetActive(false)
    end

    if self.selectList[index] then 
        self.selectList[index].markObj:SetActive(true)
    end

    --TODO:保存已经勾选好的奖励数据
    local selectData = (self.model.selectReward[self.vo.cfg.id] or {})[parentIndex] or {}
    if self.lastSelectIndex and selectData[self.lastSelectIndex] then 
        selectData[self.lastSelectIndex].select = false
    end
    selectData[index] = selectData[index] or {}
    selectData[index].select = true
    selectData[index].itemVo = itemVo

    self.model.selectReward[self.vo.cfg.id] = self.model.selectReward[self.vo.cfg.id] or {}
    self.model.selectReward[self.vo.cfg.id][parentIndex] = selectData

    -- BaseUtils.dump(selectData, "选中的奖励")

    --TODO:更新外部奖励框数据
    self:UpdateSingleRewardList(parentIndex, index)

    self.lastSelectIndex = index
end


--更新界面显示
function CustomGiftPanel:ReloadData()
    self.data = self.model.customGiftData
    -- BaseUtils.dump(self.data,"礼包数据")
    for id, vo in pairs(self.data) do
        local giftItem = self.giftList[vo.cfg.pos]
        giftItem.nameIconloader:SetSprite(SingleIconType.Other, vo.cfg.name)
        giftItem.imgIconloader:SetSprite(SingleIconType.Other, vo.cfg.icon)
        if vo.day <= 0 then 
            giftItem.dayTxt.text = TI18N("已过期")
        else
            giftItem.dayTxt.text = string.format(self.dayFormat, vo.day)
        end
        giftItem.timesTxt.text = string.format(self.timesFormat, vo.cfg.limit_times - vo.times, vo.cfg.limit_times)
        self.indexTOgiftId[vo.cfg.pos] = id
    end

    --额外奖励
    local extraData = DataCampGiftCustom.data_extra[1].reward
    local itemVo = ItemData.New()
    itemVo:SetBase(DataItem.data_get[extraData[1][1]])
    self.extraSlot:SetAll(itemVo, {nobutton = true})
    self.extraSlot:SetNum(extraData[1][2])

    --默认选中第一个
    self:OnGiftClick(self.lastIndex or 1, true)
end

function CustomGiftPanel:UpdateSelf()
    self:UpdateRewardList()
    self:UpdateButtonStatus()
end

--槽口,奖励序号
function CustomGiftPanel:UpdateSingleRewardList(index, subIndex)
    local grid = self.gridList[index]
    -- BaseUtils.dump(self.model.selectReward, "选中项奖励列表")
    -- print(subIndex)
    subIndex = subIndex or self.model:GetSelectRewardById(self.vo.cfg.id, index)

    if subIndex and (self.model.selectReward[self.vo.cfg.id][index] or {})[subIndex] then 
        local dat = (self.model.selectReward[self.vo.cfg.id][index] or {})[subIndex]

        -- print("子项：" .. subIndex)
        -- BaseUtils.dump(dat, "槽奖励")

        grid.slot:SetAll(dat.itemVo)
        grid.slot:SetNum(dat.itemVo.item_num)
        grid.slot:ShowAddBtn(false)
        grid.slot:ShowEffect(dat.itemVo.effectId ~= 0, dat.itemVo.effectId)
    else
        grid.slot:Default()
        grid.slot:ShowAddBtn(true)
        grid.slot:ShowEffect(false)
    end
end

function CustomGiftPanel:UpdateRewardList()
    local grid_num = self.vo.cfg.count
    for i = 1, 4 do
        if i <= grid_num then 
            self:UpdateSingleRewardList(i)
        else
            self.gridList[i].gameObject:SetActive(false)
        end
    end
end

function CustomGiftPanel:UpdateButtonStatus()
        --按钮状态
    if self.vo.limit_status == 1 then
        self.customBtnTxt:SetData(string.format(ColorHelper.DefaultButton4Str, TI18N("已售罄")))
        self.allBtnTxt:SetData(string.format(ColorHelper.DefaultButton4Str, TI18N("已售罄")))
        -- self.customBtnTxt.text = string.format(ColorHelper.DefaultButton4Str, TI18N("已售罄"))
        -- self.allBtnTxt.text = string.format(ColorHelper.DefaultButton4Str, TI18N("已售罄"))


        self.customBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.allBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    else
        self.customBtnTxt:SetData(string.format("<color='#906014'>%s</color>{assets_2,%s}", self.vo.cfg.custom_loss[1][2], self.vo.cfg.custom_loss[1][1]))
        self.allBtnTxt:SetData(string.format("<color='#906014'>%s</color>{assets_2,%s}", self.vo.cfg.all_loss[1][2], self.vo.cfg.all_loss[1][1]))


        self.customBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.allBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end
end


function CustomGiftPanel:FormatNum(val)
    if val >= 10000 and val < 100000 then
        local temp = math.floor(val / 10000)
        return string.format("%s%s", temp, TI18N("万"))
    elseif val >= 100000 and val < 1000000 then
        local temp = math.floor(val / 1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 1000000 and val < 10000000 then
        local temp = math.floor(val / 1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 10000000 and val < 100000000 then
        local temp = math.floor(val / 10000000)
        return string.format("%s%s", temp, TI18N("千万"))
    elseif val >= 100000000 and val < 1000000000 then
        local temp = math.floor(val / 10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    elseif val >= 1000000000 then
        local temp = math.floor(val / 10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    end
    return tostring(val)
end
