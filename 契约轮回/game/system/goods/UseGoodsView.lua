--
-- @Author: chk
-- @Date:   2018-11-12 14:18:41
--
UseGoodsView = UseGoodsView or class("UseGoodsView", BasePanel)
local UseGoodsView = UseGoodsView

function UseGoodsView:ctor()
    self.abName = "system"
    self.assetName = "UseGoodsView"
    self.layer = "Top"

    self.sche_id = nil
    self.count = 5
    self.global_events = {}
    self.view_index = 0
    -- self.model = 2222222222222end:GetInstance()
    self.model = BagModel.GetInstance()
end

function UseGoodsView:dctor()
    if self.iconSettor ~= nil then
        self.iconSettor:destroy()
    end

    if self.goodsDetail then
        self.model.usegoodsviews[self.goodsDetail.uid] = nil
    end
    self.model = nil
    if self.sche_id ~= nil then
        GlobalSchedule:Stop(self.sche_id)
    end
    if self.effect then
        self.effect:destroy()
    end

    for i = 1, #self.global_events do
        GlobalEvent:RemoveListener(self.global_events[i])
    end
    GlobalEvent:Brocast(BagEvent.DesUseGoodsView, self.view_index)
end



function UseGoodsView:LoadCallBack()
    self.nodes = {
        "CloseBtn",
        "nameTxt",
        "icon",
        "useBtn",
        "useBtn/Text",
        "bg",
        "fram",
        "line",
        "time",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    self.nameTxtTxt = self.nameTxt:GetComponent('Text')
    self.itemRectTra = self.transform:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')
    self.frameRectTra = self.fram:GetComponent('RectTransform')
    self.lineRectTra = self.line:GetComponent('RectTransform')
    self.timeTxt = self.time:GetComponent('Text')

    if (self.goodsDetail) then
        self:RefreshInfo()
    end

    if self.effect then
        self.effect:destroy()
    end
    self.effect = UIEffect(self.useBtn, 10121, false, self.layer)
    self.effect:SetConfig({pos = { x = 61, y = -20, z = 0 }})

end

function UseGoodsView:AddEvent()
    local function call_back()
        self:destroy()
    end
    AddClickEvent(self.CloseBtn.gameObject, call_back)

    local function call_back()
        local itemCfg = Config.db_item[self.goodsDetail.id]
        if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
            EquipModel.GetInstance().operateEquipItem = self.goodsDetail
            EquipController.GetInstance():RequestPutOnEquip2()
            GlobalSchedule:Stop(self.sche_id)
        else
            if itemCfg.usage == 1 then
                BagModel.GetInstance():Brocast(BagEvent.UseGoods, self.goodsDetail)
            elseif itemCfg.usage == 2 then
                local jumpTbl = String2Table(itemCfg.jump)
                OpenLink(unpack(jumpTbl))
            end
        end
        self:destroy()
    end
    AddClickEvent(self.useBtn.gameObject, call_back)

    local function call_back(bag_id, k, v)
        if self.goodsDetail.uid == k and v < self.old_num then
            return self:destroy()
        end
        if self.goodsDetail.uid == k and v > 1 then
            self.param["num"] = v
            self.iconSettor:SetIcon(self.param)
            self.old_num = v
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)

    local function call_back()
        local item = BagModel.GetInstance():GetItemByUid(self.goodsDetail.uid)
        if not item or item.num == 0 then
            self:destroy()
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function call_back(bag_id, uid)
        if self.goodsDetail.uid == uid then
            self:destroy()
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
end

function UseGoodsView:SetData(data)

end

function UseGoodsView:AutoPutOn()
    if self.count == 0 then
        EquipModel.GetInstance().operateEquipItem = self.goodsDetail
        EquipController.GetInstance():RequestPutOnEquip2()
        GlobalSchedule:Stop(self.sche_id)
        self:destroy()
    else
        self.count = self.count - 1
        self.timeTxt.text = string.format(ConfigLanguage.Equip.AutoPutOn, self.count)
    end
end

function UseGoodsView:UpdateInfo(goodsDetail, view_index)
    self.goodsDetail = goodsDetail
    self.old_num = goodsDetail.num
    self.view_index = view_index
    if self.model.usegoodsviews[goodsDetail.uid] then
        return
    end
    self.model.usegoodsviews[goodsDetail.uid] = true
    if (self.is_loaded) then
        self:RefreshInfo()
    end
    UseGoodsView.super.Open(self)
end

function UseGoodsView:RefreshInfo()
    local goodsDetail = self.goodsDetail
    local itemCfg = Config.db_item[goodsDetail.id]
    self.nameTxtTxt.text = string.format("<color=#%s>%s</color>",
            ColorUtil.GetColor(itemCfg.color), itemCfg.name)
    local param = {}
    self.param = param

    if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        param["cfg"] = Config.db_equip[goodsDetail.id]
        param["show_up_tip"] = true
        param["up_tip_action"] = true
        param["p_item"] = goodsDetail

        GetText(self.Text).text = ConfigLanguage.Equip.PutOn

        --local putOnEquip = BagModel.Instance:GetPutOn(itemCfg.id)
        if param["cfg"].order < 5 then
            self.bgRectTra.sizeDelta = Vector2(self.bgRectTra.sizeDelta.x, self.bgRectTra.sizeDelta.y + 30)
            self.frameRectTra.sizeDelta = Vector2(self.frameRectTra.sizeDelta.x, self.frameRectTra.sizeDelta.y + 30)

            self.timeTxt.text = string.format(ConfigLanguage.Equip.AutoPutOn, self.count)
            self.sche_id = GlobalSchedule:Start(handler(self, self.AutoPutOn), 1, 600)
        end
    else
        param["cfg"] = itemCfg
        if goodsDetail.num then
            param["num"] = goodsDetail.num
        end
        param["p_item"] = goodsDetail
    end
    if not self.iconSettor then
        self.iconSettor = GoodsIconSettorTwo(self.icon)
    end
    self.iconSettor:SetIcon(param)

    local x = ScreenWidth - self.bgRectTra.sizeDelta.x - 100
    local y = -ScreenHeight + self.bgRectTra.sizeDelta.y + 150
    self.itemRectTra.anchoredPosition = Vector2(x, y)
    if not self.sche_id then
        local function call_back()
            self:destroy()
        end
        self.sche_id = GlobalSchedule:StartOnce(call_back, 15)
    end
end
