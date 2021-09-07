-- @author hze
-- @date #2019/05/24#
-- @消息提示确认框(有消耗物品)
--data参数 {content 文字内容,id 物品id, needNum 需要数量, protoId 用途来源协议号}

NoticeConfirmCostPanel = NoticeConfirmCostPanel or BaseClass(BasePanel)

function NoticeConfirmCostPanel:__init(model)
    self.model = model
    self.path = "prefabs/ui/notice/noticeconfirmcostpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
    }

    self.sureCall = nil
    self.cancelCall = nil

    self.defaultWidth = 421
    self.defaultHeight = 245
    self.contentRectMinHeight = 25

    self.on_item_update = function() self:UpdateItem() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
end

function NoticeConfirmCostPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    if self.sureButton ~= nil then 
        self.sureButton:DeleteMe()
    end

    if self.contentTxt ~= nil then 
        self.contentTxt:DeleteMe()
    end 
end

function NoticeConfirmCostPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))

    self.transform = self.gameObject.transform
    self.gameObject.name = "NoticeConfirmCostPanel"
    -- UIUtils.AddUIChild(self.model.noticeCanvas, self.gameObject)
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.transform, self.gameObject)
    -- UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.gameObject:SetActive(false)

    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button)
    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)
    self.contentRect = self.transform:Find("Main/Content"):GetComponent(RectTransform)
    self.contentTxt_go = self.transform:Find("Main/Content/DescText"):GetComponent(Text)
    self.contentTxt = MsgItemExt.New(self.contentTxt_go, 325, 18, 21)
    self.contentTxtRect = self.contentTxt_go.gameObject:GetComponent(RectTransform)

    self.itemslot = ItemSlot.New()
    -- self.itemslot:SetNotips()
    UIUtils.AddUIChild(self.transform:Find("Main/Content/ItemSlot"), self.itemslot.gameObject)

    self.slotNameTxt =  self.transform:Find("Main/Content/Text"):GetComponent(Text)

    self.costNum = self.transform:Find("Main/CostNum"):GetComponent(Text)
    self.costIcon = self.transform:Find("Main/CostIcon"):GetComponent(Image)

    self.priceCall = function(prices)
        local data = nil
        for _, value in pairs(prices) do
            data = value
        end
        if data == nil then
            self.costNum.gameObject:SetActive(false)
            self.costIcon.gameObject:SetActive(false)
            return
        end

        local allprice = data.allprice
        local price_str = ""
        if allprice >= 0 then
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], allprice)
        else
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], - allprice)
        end
        self.costNum.text = price_str
        self.costIcon:GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets])
    
        self.costNum.gameObject:SetActive(true)
        self.costIcon.gameObject:SetActive(true)
    end

    self.cancelObj = self.transform:Find("Main/CancelButton").gameObject
    self.cancelBtn = self.cancelObj:GetComponent(Button)

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    


    self.cancelBtn.onClick:AddListener(function() self:ClickCancel() end)
    self.closeBtn.onClick:AddListener(function() self:Clear() end)
    self.panelBtn.onClick:AddListener(function() self:Clear() end)

    self:ClearMainAsset()
end

function NoticeConfirmCostPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NoticeConfirmCostPanel:OnOpen()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)

    self.data = self.openArgs
    self:SetData(self.data)
end

--data参数 {content 文字内容,id 物品id, needNum 需要数量, sureCall 点击回调}
function NoticeConfirmCostPanel:SetData()
    self:Reset()

    local data = self.data
    -- BaseUtils.dump(data,"noticeconfirmcostpanel")

    self.sureButton = BuyButton.New(self.transform:Find("Main/SureButton"), TI18N("确定"), data.noGold)
    self.sureButton:Set_btn_img("DefaultButton3")
    self.sureButton.key = "NoticeConfirmCostButton"
    self.sureButton.protoId = data.protoId
    self.sureButton:Show()

    local itemdata = ItemData.New()
    itemdata:SetBase(DataItem.data_get[data.id])
    self.itemslot:SetAll(itemdata, {nobutton = true})

    self.slotNameTxt.text = itemdata.name

    self.contentTxt:SetData(data.content)

    self.sureCall = data.sureCall
    self.cancelCall = data.cancelCall
    self.closeCall = data.closeCall 

    self:UpdateItem()
    
    self:Layout()

    self.gameObject:SetActive(true)
end

function NoticeConfirmCostPanel:UpdateItem()
    local data = self.data

    self.itemslot:SetNum(BackpackManager.Instance:GetItemCount(data.id), data.needNum)
    
    local buylist = {[data.id] = {need = data.needNum}}
    if self.sureButton ~= nil then 
        self.sureButton:Layout(buylist, function() self:ClickSure() end, self.priceCall , {antofreeze = false})
    end
end

function NoticeConfirmCostPanel:Layout()
    local height = self.contentTxt.selfHeight

    if height > self.contentRectMinHeight then 
        self.contentRectMinHeight =  height + 5
    end

    self.mainRect.sizeDelta = Vector2(self.defaultWidth, self.defaultHeight + self.contentRectMinHeight)
end

function NoticeConfirmCostPanel:ClickSure()
    if self.sureCall ~= nil then
        self.sureCall()
    end
    self:Clear()
end

function NoticeConfirmCostPanel:ClickCancel()
    if self.cancelCall ~= nil then
        self.cancelCall()
    end
    self:Clear()
end

function NoticeConfirmCostPanel:Clear()
    self:Hiden()
    self:Reset()

    if self.closeCall ~= nil then
        self.closeCall()
    end
end

function NoticeConfirmCostPanel:Reset()
    self.sureCall = nil
    self.cancelCall = nil
    self.closeCall = nil

    if self.sureButton ~= nil then 
        self.sureButton:DeleteMe()
        self.sureButton = nil
    end 
end

