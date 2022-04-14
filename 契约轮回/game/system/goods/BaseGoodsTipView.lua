--
-- @Author: chk
-- @Date:   2018-09-01 23:15:27
--
BaseGoodsTipView = BaseGoodsTipView or class("BaseGoodsTipView", BaseWidget)
local BaseGoodsTipView = BaseGoodsTipView

function BaseGoodsTipView:ctor(parent_node, layer)
    -- self.abName = "111111111111111"
    -- self.assetName = "BaseGoodsTipView"
    -- self.layer = layer

    -- self.model = 2222222222222end:GetInstance()
    -- BaseGoodsTipView.super.Load(self)
    self:InitData()
end

function BaseGoodsTipView:dctor()

    if self.iconStor ~= nil then
        self.iconStor:destroy()
    end


    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end
    self.events = {}

    if self.iconStor ~= nil then
        self.iconStor:destroy()
    end

    for i, v in pairs(self.atts) do
        v:destroy()
    end
    self.atts = {}

    if self.jumpItemSettor ~= nil then
        self.jumpItemSettor:destroy()
        self.jumpItemSettor = nil
    end

    self.operates = {}

    if self.delete_scheld_id ~= nil then
        GlobalSchedule:Stop(self.delete_scheld_id)
    end
end

function BaseGoodsTipView:InitData()
    self.model = GoodsModel:GetInstance()
    self.goodsItem = nil
    self.btnWidth = 0
    self.maxScrollViewHeight = 236
    self.minScrollViewHeight = 60
    self.maxViewHeight = 535
    self.scrollViewRectTra = nil
    self.attContainRectTra = nil
    self.bgRectTra = nil
    self.viewRectTra = nil
    self.parentRectTra = nil
    self.events = {}
    self.iconStor = nil
    self.need_load_end = nil
    self.click_bg_close = true
    self.atts = {}
    self.operates = {}         -- 操作，比如出售之类的
    self.jumpSettors = {}

    self.height = 0
end

function BaseGoodsTipView:LoadCallBack()
    self.nodes = {
        "mask",
        "bg",
        "q_bg",
        "fram",
        "nameTxt",
        "icon",
        "lv/lvValue",
        "type/typeValue",
        "ScrollView",
        "ScrollView/Viewport/Content",

        "btnContain",
        "btnContain/exchangeBtn",
        "btnContain/batchExchangeBtn",
        "btnContain/useBtn",
        "btnContain/sellBtn",
        "btnContain/storeBtn",
        "btnContain/takeOutBtn",
        "btnContain/destroyBtn",
        "btnContain/upShelfBtn",
        "valueTemp",
    }
    self:GetChildren(self.nodes)
    self:GetRectTransform()

    SetLocalScale(self.transform, 1, 1, 1)

    --if self.item_id ~= nil then
    --	--self.events[#self.events+1] = GlobalEvent:AddListener(GoodsEvent.CreateAttEnd,handler(self,self.DealCreateAttEnd))
    --	self:UpdateInfoByItemId(self.item_id)
    --elseif 	self.goodsItem ~= nil then
    --	self:AddEvent()
    --	self:UpdateInfo(self.goodsItem)
    --end
    --
    --self:SetViewPosition()
    self:SetOrderByParentMax()
end

function BaseGoodsTipView:AddEvent()
    if MarketModel:GetInstance().isOpenUpShelfMarket or MarketModel:GetInstance().isOpenMarket then
        --打开了上架
        SetVisible(self.useBtn, false)
        SetVisible(self.sellBtn, false)
        SetVisible(self.storeBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.destroyBtn, false)
        SetVisible(self.exchangeBtn, false)
        SetVisible(self.batchExchangeBtn, false)
        --if MarketModel:GetInstance().UpShelfItemList['']then
        --
        --end
        local function call_back()
            GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn, 1)
            MarketModel.GetInstance().selectItem = self.goodsItem
            self:destroy()
        end
        AddClickEvent(self.upShelfBtn.gameObject, call_back)
    else
        SetVisible(self.upShelfBtn, false)
        SetVisible(self.exchangeBtn, false)
        SetVisible(self.batchExchangeBtn, false)

        if self.goodsItem.bag == BagModel.bagId then
            SetVisible(self.takeOutBtn.gameObject, false)
            if GoodsModel.GetInstance().isOpenWarePanel then
                --打开了仓库
                SetVisible(self.sellBtn.gameObject, false)
                SetVisible(self.useBtn.gameObject, false)
                SetVisible(self.destroyBtn.gameObject, false)

                local function call_back(target, x, y)
                    --存储道具
                    GoodsController.Instance:RequestStoreItem(self.goodsItem.uid, self.goodsItem.num)
                end
                AddClickEvent(self.storeBtn.gameObject, call_back)
            else
                SetVisible(self.storeBtn.gameObject, false)


                --丢弃(销毁)道具
                local function call_back(target, x, y)
                    local itemBase = BagModel.GetInstance():GetItemByUid(self.goodsItem.uid)
                    GoodsController.Instance:RequestChuckItem(self.goodsItem.uid, itemBase.num)
                end
                AddClickEvent(self.destroyBtn.gameObject, call_back)


                --出售道具
                local function call_back(target, x, y)
                    --只有背包才会有物品出售
                    local itemBase = BagModel.GetInstance():GetItemByUid(self.goodsItem.uid)
                    local param = {}
                    local kv = { key = self.goodsItem.uid, value = itemBase.num }
                    table.insert(param, kv)
                    GoodsController.Instance:RequestSellItems(param)
                end
                AddClickEvent(self.sellBtn.gameObject, call_back)

                local itemConfig = Config.db_item[self.goodsItem.id]
                if itemConfig.usage == 1 then
                    local function call_back(target, x, y)
                        BagModel.Instance:Brocast(BagEvent.UseGoods, self.goodsItem)
                        self:destroy()
                        --lua_panelMgr:GetPanelOrCreate(BatchUsePanel):Open(self.goodsDetail)
                        --GoodsController.Instance:RequestUseItem(self.goodsItem.uid,1)
                    end
                    AddClickEvent(self.useBtn.gameObject, call_back)
                elseif itemConfig.usage == 2 then
                    local jumpTbl = string.split(itemConfig.jump, "@")
                    if table.nums(jumpTbl) >= 2 then
                        local function call_back()
                            if table.nums(jumpTbl) >= 2 then
                                UnpackLinkConfig(jumpTbl[1]..'@'..jumpTbl[2])
                                self:destroy()
                            end
                        end
                        AddClickEvent(self.useBtn.gameObject, call_back)
                    else
                        SetVisible(self.useBtn.gameObject, false)
                    end

                else
                    SetVisible(self.useBtn.gameObject, false)
                end
            end
        elseif self.goodsItem.bag == BagModel.wareHouseId or self.goodsItem.bag == BagModel.stHouseId then
            SetVisible(self.sellBtn.gameObject, false)
            SetVisible(self.storeBtn.gameObject, false)
            SetVisible(self.useBtn.gameObject, false)
            SetVisible(self.destroyBtn.gameObject, false)
            SetVisible(self.exchangeBtn, false)
            SetVisible(self.batchExchangeBtn, false)

            --取出道具
            local function call_back(target, x, y)
                GoodsController.Instance:RequestTakeOut(self.goodsItem.uid, self.goodsItem.num)
            end
            AddClickEvent(self.takeOutBtn.gameObject, call_back)
        end
    end

    self:AddClickCloseBtn()

    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.Destroy, handler(self, self.DealDestroyGoods))
    --self.events[#self.events+1] = GlobalEvent:AddListener(GoodsEvent.CreateAttEnd,handler(self,self.DealCreateAttEnd))
end

function BaseGoodsTipView:AddClickCloseBtn()
    if self.click_bg_close then
        local tcher = self.gameObject:AddComponent(typeof(Toucher))
        tcher:SetClickEvent(handler(self,self.OnTouchenBengin))
    end
end

function BaseGoodsTipView:DeleteClickClose()
    if self.update_sched_id ~= nil then
        GlobalSchedule:Stop(self.update_sched_id)
        self.update_sched_id = nil
        self:destroy()
    end
end

function BaseGoodsTipView:DealCreateAttEnd()
    if self.height > self.minScrollViewHeight and self.height < self.maxScrollViewHeight then
        self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.height)
    elseif self.height >= self.maxScrollViewHeight then
        self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.height)
    else
        self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.minScrollViewHeight)
    end
    local y = self.scrollViewRectTra.sizeDelta.y + 170
    if y > self.maxViewHeight then
        y = self.maxViewHeight
    end

    self.viewRectTra.sizeDelta = Vector2(self.viewRectTra.sizeDelta.x, y)
    self.bgRectTra.sizeDelta = self.viewRectTra.sizeDelta

    self:SetViewPosition()
end

function BaseGoodsTipView:GetRectTransform()
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')
    self.scrollViewRectTra = self.ScrollView:GetComponent('RectTransform')
    self.attContainRectTra = self.Content:GetComponent('RectTransform')
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    self.valueTempTxt = self.valueTemp:GetComponent('Text')

    SetLocalPosition(self.transform, -10000, 0)
    --self.viewRectTra.anchoredPosition = Vector2(-10000,0)
end

function BaseGoodsTipView:GetOperates()
    local index = 1
    self.operates[index] = "Destroy"
    if self.goodsItem.bag == BagModel.bagId then
        --在背包中，存储
        index = index + 1
        self.operates[index] = "Store"
    elseif self.goodsItem.bag == BagModel.wareHouseId then
        index = index + 1
        self.operates[index] = "TakeOut"
    end

    local itemConfig = Config.db_item[self.goodsItem.id]
    if itemConfig.price > 0 then
        index = index + 1
        self.operates[index] = "Sell"
    end

    if itemConfig.usage > 0 then
        index = index + 1
        self.operates[index] = "Use"
    end

end
--动态加载操作按钮
function BaseGoodsTipView:DynamicAddBtns()
    for i, v in pairs() do

    end
end

--处理销毁道具
function BaseGoodsTipView:DealDestroyGoods(item)
    if item.uid == self.goodsItem.uid then

    end
end

function BaseGoodsTipView:DelItem(bagId, uid)
    if self.goodsItem.uid == uid then
        self:destroy()
    end
end

function BaseGoodsTipView:OnTouchenBengin(x,y)
    local pos = self.transform.position
    local bg_x = ScreenWidth / 2 + pos.x * 100
    local bg_y = pos.y * 100 + ScreenHeight / 2

    local xw = bg_x + self.bgRectTra.sizeDelta.x
    local yw = bg_y - self.bgRectTra.sizeDelta.y


    xw = xw + self.btnWidth

    if not (x >= bg_x and  x <= xw and yw <= y and bg_y >= y) then
        self:destroy()
    end
end


function BaseGoodsTipView:OpenCallBack()
    self:UpdateView()
end

function BaseGoodsTipView:Update()
    if Input.GetMouseButtonUp(0) then
        self.delete_scheld_id = GlobalSchedule:StartOnce(handler(self, self.DeleteClickClose), Time.deltaTime)
        --self:DeleteClickClose()
    elseif Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Ended then
        self.delete_scheld_id = GlobalSchedule:StartOnce(handler(self, self.DeleteClickClose), Time.deltaTime)
    end
end

function BaseGoodsTipView:UpdateView()

end

function BaseGoodsTipView:CloseCallBack()

end

function BaseGoodsTipView:UpdateQualityBg(quality)
    local qualityImg = self.q_bg:GetComponent('Image')
    lua_resMgr:SetImageTexture(self, qualityImg, "equip_image", "equip_q_bg_" .. quality, true)
end


function BaseGoodsTipView:UpdateInfoByItemId(itemId)
    self.item_id = itemId
    --if self.is_loaded then
    self:AddClickCloseBtn()

    if FactionModel.Instance.isEchEquip and FactionModel.Instance:GetGoodsCanExchange(itemId) then
        SetVisible(self.useBtn, false)
        SetVisible(self.sellBtn, false)
        SetVisible(self.storeBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.destroyBtn, false)
        SetVisible(self.upShelfBtn, false)

        SetVisible(self.exchangeBtn, true)
        SetVisible(self.batchExchangeBtn, true)

        local function call_back()
            FactionWareController.Instance:RequestExchBuy(self.item_id, 1)
        end
        AddClickEvent(self.exchangeBtn.gameObject, call_back)

        local function call_back()
            FactionModel.Instance:Brocast(FactionEvent.OpenBatchExchangeView, self.item_id)
            self:destroy()
        end
        AddClickEvent(self.batchExchangeBtn.gameObject, call_back)
    else
        SetVisible(self.btnContain.gameObject, false)
        self.btnWidth = 0
    end

    local itemConfig = Config.db_item[itemId]
    local desc = itemConfig.desc
    if itemConfig.stype == enum.ITEM_STYPE.ITEM_STYPE_EXP3 then
        local arr = String2Table(itemConfig.effect)
        local exp = math.floor(arr[1] * RoleInfoModel:GetInstance():GetRoleValue("level") + 0.5)
        exp = math.max(exp, arr[2])
        desc = string.format(desc, exp)
    end
    self.nameTxt:GetComponent('Text').text = itemConfig.name
    self.lvValue:GetComponent('Text').text = itemConfig.level
    self.typeValue:GetComponent('Text').text = itemConfig.type_desc
    self:UpdateIconByItemId(itemId)
    self:UpdateDes(desc .. "\n")
    self:UpdateUseway(itemConfig.useway .. "\n")
    self:UpdateJump(itemConfig.gainway)

    self.need_load_end = false

    self:DealCreateAttEnd()
    --GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)
    --else
    --	self.item_id  = itemId
    --	self.need_load_end = true
    --end
end

function BaseGoodsTipView:UpdateInfo(data)
    self.goodsItem = data
    --if self.is_loaded then
    if data.uid == 0 or data.bag == 0 then
        SetVisible(self.btnContain.gameObject, false)
        self.btnWidth = 0
    end
    local itemConfig = Config.db_item[data.id]
    local desc = itemConfig.desc
    if itemConfig.stype == enum.ITEM_STYPE.ITEM_STYPE_EXP3 then
        local arr = String2Table(itemConfig.effect)
        local level = RoleInfoModel:GetInstance():GetRoleValue("level")
        local exp = Config.db_role_level[level].exp
        exp = math.floor(arr[1] * exp + 0.5)
        exp = math.max(exp, arr[2])
        desc = string.format(desc, exp)
    end
    --self.nameTxt:GetComponent('Text').text = itemConfig.name
    self.lvValue:GetComponent('Text').text = itemConfig.level .. "_" .. itemConfig.id
    print2(itemConfig.id);
    self.typeValue:GetComponent('Text').text = itemConfig.type_desc
    self:UpdateName(itemConfig.name, itemConfig.color)
    self:UpdateIcon(data)
    self:UpdateDes(desc .. "\n")
    self:UpdateUseway(itemConfig.useway .. "\n")
    self:UpdateJump(itemConfig.gainway)
    self:UpdateQualityBg(itemConfig.color)
    self:DealCreateAttEnd()
    self.need_load_end = false

    self:AddEvent()
    --GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)
    --else
    --	self.goodsItem = data
    --	self.need_load_end = true
    --end
end

function BaseGoodsTipView:SetViewPosition()
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0
    if self.parentRectTra.anchorMin.x == 0.5 then
        spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2
        parentHeight = self.parentRectTra.sizeDelta.y / 2
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end

    --local parentRectTra = self.parent_node:GetComponent('RectTransform')
    local pos = self.parent_node.position
    local x = ScreenWidth / 2 + pos.x * 100 + parentWidth
    local y = pos.y * 100 - ScreenHeight / 2 - parentHeight
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    --判断是否超出右边界
    if ScreenWidth - (x + parentWidth + self.viewRectTra.sizeDelta.x) < self.btnWidth + 10 then
        --spanX = ScreenWidth - (x + self.viewRectTra.sizeDelta.x + self.btnWidth)
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = x - self.viewRectTra.sizeDelta.x - parentWidth * 2 - self.btnWidth - 20
        else
            x = x - self.viewRectTra.sizeDelta.x - parentWidth - self.btnWidth
        end

    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end

function BaseGoodsTipView:UpdateName(name, quality)
    self.nameTxt:GetComponent('Text').text = name
end

-- param  p_item
function BaseGoodsTipView:UpdateIcon(param)
    --self.iconStor = GoodsIconSettor(self.icon,"UI")
    --self.iconStor:UpdateIcon(param)

    self:UpdateIconByItemId(param.id)
end

function BaseGoodsTipView:UpdateIconByItemId(itemId)
    --local itemConfig = Config.db_item[itemId]
    local param = {}
    param["model"] = BagModel.GetInstance()
    param["item_id"] = itemId
    param["size"] = {x=72,y=72}
    if self.iconStor == nil then
        self.iconStor = GoodsIconSettorTwo(self.icon)
    end

    self.iconStor:SetIcon(param)
    --GoodIconUtil.Instance:CreateIcon(self, self.icon:GetComponent('Image'), itemConfig.icon, true)
    SetVisible(self.icon.gameObject, true)
end

function BaseGoodsTipView:UpdateUseway(useway)
    if useway ~= "\n" and not string.isempty(useway) then
        self.valueTempTxt.text = useway

        local att = { title = ConfigLanguage.Goods.UseWay, info = useway, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight + 25 + 10 }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 10
    end
end

function BaseGoodsTipView:UpdateDes(des)
    if des ~= "\n" and not string.isempty(des) then
        self.valueTempTxt.text = des

        local att = { title = ConfigLanguage.Goods.Des, info = des, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight + 25 + 10 }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 10
    end
end

function BaseGoodsTipView:UpdateJump(jump)
    if not string.isempty(jump) and jump ~= "{}" then
        local height = 94 + 25
        self.jumpItemSettor = GoodsJumpItemSettor(self.Content)
        self.jumpItemSettor:CreateJumpItems(jump, self.height)

        self.height = self.height + height
    end
end