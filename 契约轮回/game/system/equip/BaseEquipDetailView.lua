--
-- @Author: chk
-- @Date:   2018-09-18 18:02:20
--
BaseEquipDetailView = BaseEquipDetailView or class("BaseEquipDetailView", BaseWidget)
local BaseEquipDetailView = BaseEquipDetailView

function BaseEquipDetailView:ctor(parent_node, layer)
    -- self.abName = "equip"
    -- self.assetName = "EquipDetailView"
    -- self.layer = layer

    -- self:InitData()
    -- EquipDetailView.super.Load(self)
    self.height = 0
    self.btnWidth = 0
    self.rectTra = nil
    self.isBeastEquip = false;
    self.isToemsEquip = false;
end

function BaseEquipDetailView:dctor()
    if self.iconStor == nil then
        self.iconStor:destroy()
    end

    if self.suitItemSettor ~= nil then
        self.suitItemSettor:destroy()
    end

    if self.iconStor ~= nil then
        self.iconStor:destroy()
    end

    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end

    if self.baseAttrStr ~= nil then
        self.baseAttrStr:destroy()
    end
    self.baseAttrStr = nil

    if self.bestAttrStr ~= nil then
        self.bestAttrStr:destroy()
    end
    self.bestAttrStr = nil

    if self.stoneItemSettor ~= nil then
        self.stoneItemSettor:destroy()
    end
    self.stoneItemSettor = nil

    if self.validDayStr then
        self.validDayStr:destroy()
    end
    self.validDayStr = nil

    self.equipItem = nil
    self.events = {}

    if self.delete_scheld_id ~= nil then
        GlobalSchedule:Stop(self.delete_scheld_id)
    end

    self.model = nil;
end

function BaseEquipDetailView:InitData()
    self.model = EquipModel:GetInstance()
    self.maxScrollViewHeight = 356
    self.minScrollViewHeight = 280
    self.maxViewHeight = 535
    self.scrollViewRectTra = nil
    self.bgRectTra = nil
    self.viewRectTra = nil
    self.parentRectTra = nil
    self.attContainRectTra = nil
    self.events = {}
    self.iconStor = nil
    self.click_bg_close = true
    self.use_background = true
    self.need_load_end = false
    self.has_equip_com = false
    self.equipItem = nil
    self.baseAttrStr = nil
    self.bestAttrStr = nil
    self.validDayStr = nil
    self.equipItem = nil
end

function BaseEquipDetailView:SetViewPosition()
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
            x = x - self.viewRectTra.sizeDelta.x - parentWidth * 2 - 20
        else
            x = x - self.viewRectTra.sizeDelta.x - parentWidth
        end
    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end

function BaseEquipDetailView:SetData(data)

end

function BaseEquipDetailView:LoadCallBack()
    self.nodes = {
        "q_bg",
        "bg",
        "mask",
        "fram",
        "nameTxt",
        "icon",
        "had_put_on",
        "wearLV/wareValue",
        "compositeScore/comScoreValue",
        "equipScore/scoreContain/scoreValue",
        "equipScore/scoreContain/upArrow",
        "equipScore/scoreContain/downArrow",
        "careerInfo/careerCon",
        "careerInfo/careerCon/equipPos",
        "careerInfo/careerCon/career",
        "ScrollView",
        "ScrollView/Viewport/Content",

        "btnContain",
        "btnContain/ExchangeBtn",
        "btnContain/DonateBtn",
        "btnContain/strongBtn",
        "btnContain/putOffBtn",
        "btnContain/mountStoneBtn",
        "btnContain/destroyBtn",
        "btnContain/takeOutBtn",
        "btnContain/storeBtn",
        "btnContain/sellBtn",
        "btnContain/putOnBtn",
        "btnContain/takeOffBtn",
        "btnContain/upShelfBtn",
        "btnContain/combineBtn",
        "valueTemp",
    }

    self:GetChildren(self.nodes)
    self:GetRectTransform()

    SetVisible(self.putOffBtn.gameObject, false)

    self:SetOrderByParentMax()
end

function BaseEquipDetailView:AddEvent()
    SetVisible(self.destroyBtn, false)
    if not self.isCompare then
        self:AddClickCloseBtn()
        self:SetViewPosition()
    else
        SetVisible(self.mask.gameObject, false)
    end

    if not self.isCompare then
        self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
        --self.events[#self.events + 1] = GlobalEvent:AddListener(FactionEvent.DestroyEquipSucess, handler(self, self.DealDestroyEquip))
    end

    if self.is_not_operate then
        SetVisible(self.btnContain.gameObject, false)
        return
    end
    SetVisible(self.combineBtn , false);
    if FactionModel.Instance.isEchEquip then
        SetVisible(self.storeBtn, false)
        SetVisible(self.sellBtn, false)
        SetVisible(self.putOnBtn, false)
        SetVisible(self.takeOffBtn, false)
        SetVisible(self.strongBtn, false)
        SetVisible(self.mountStoneBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.upShelfBtn, false)
        SetVisible(self.DonateBtn, false)

        local function call_back()
            FactionWareController.Instance:RequestExchEquip(self.equipItem.uid)
        end
        AddClickEvent(self.ExchangeBtn.gameObject, call_back)
    elseif FactionModel.Instance.isDonateEquip then
        SetVisible(self.storeBtn, false)
        SetVisible(self.sellBtn, false)
        SetVisible(self.putOnBtn, false)
        SetVisible(self.takeOffBtn, false)
        SetVisible(self.strongBtn, false)
        SetVisible(self.mountStoneBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.upShelfBtn, false)
        SetVisible(self.ExchangeBtn, false)

        local function call_back()
            FactionWareController.Instance:RequestDonateEquip(self.equipItem.uid)
        end
        AddClickEvent(self.DonateBtn.gameObject, call_back)
    elseif MarketModel:GetInstance().isOpenUpShelfMarket or MarketModel:GetInstance().isOpenMarket then
        --打开了上架
        SetVisible(self.storeBtn, false)
        SetVisible(self.sellBtn, false)
        SetVisible(self.putOnBtn, false)
        SetVisible(self.takeOffBtn, false)
        SetVisible(self.strongBtn, false)
        SetVisible(self.mountStoneBtn, false)
        SetVisible(self.DonateBtn, false)
        SetVisible(self.ExchangeBtn, false)
        if MarketModel:GetInstance().isOpenMarket then
            SetVisible(self.upShelfBtn, false)
        end
        --if MarketModel:GetInstance().UpShelfItemList['']then
        --
        --end


        SetVisible(self.takeOutBtn, false)
        local function call_back()
            GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn, 1)
            MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.upShelfBtn.gameObject, call_back)
    elseif self.isBeastEquip then
        --神兽装备
        SetVisible(self.storeBtn, false)
        if not self.isNotOperate then
            SetVisible(self.sellBtn, true)
            SetVisible(self.combineBtn , true);
            SetVisible(self.putOnBtn, true)
            SetVisible(self.takeOffBtn, false)
        else
            SetVisible(self.sellBtn, false)
            SetVisible(self.combineBtn , false);
            SetVisible(self.putOnBtn, false)
            SetVisible(self.putOffBtn.gameObject, true)

        end

        SetVisible(self.takeOffBtn, false);
        SetVisible(self.strongBtn, false)
        SetVisible(self.mountStoneBtn, false)
        SetVisible(self.DonateBtn, false)
        SetVisible(self.ExchangeBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.upShelfBtn, false)
        local function call_back()
            --Notify.ShowText("出售");
            local itemConfig = Config.db_item[self.equipItem.id];
            local param = {}
            local kv = { key = self.equipItem.uid, value = 1 };
            table.insert(param, kv);
            local fun = function()
                GoodsController.Instance:RequestSellItems(param);
            end
            if itemConfig.color >= enum.COLOR.COLOR_RED then
                Dialog.ShowTwo("Tip", "You are going to sell a rare beast gear, sale?", "Confirm", fun, nil, "Cancel");
            else
                GoodsController.Instance:RequestSellItems(param);
            end


            --GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,1)
            --MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.sellBtn.gameObject, call_back)

        local function putoff_fun()
            --Notify.ShowText("卸下");
            local equipConfig = Config.db_beast_equip[self.equipItem.id];
            BeastCtrl:GetInstance():RequestEquipUnLoad(BeastModel:GetInstance().currentBeastEquip, equipConfig.slot);
            --GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,1)
            --MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.putOffBtn.gameObject, putoff_fun)

        local function equip_fun()
            --Notify.ShowText("装备");
            BeastCtrl:GetInstance():RequestEquipLoad(BeastModel:GetInstance().currentBeastEquip, self.equipItem.uid);
            --GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,1)
            --MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.putOnBtn.gameObject, equip_fun)
    elseif self.isToemsEquip then
        SetVisible(self.storeBtn, false)
        if not self.isNotOperate then
            SetVisible(self.sellBtn, true)
            SetVisible(self.combineBtn , true);
            SetVisible(self.putOnBtn, true)
            SetVisible(self.takeOffBtn, false)
        else
            SetVisible(self.sellBtn, false)
            SetVisible(self.combineBtn , false);
            SetVisible(self.putOnBtn, false)
            SetVisible(self.putOffBtn.gameObject, true)

        end

        SetVisible(self.takeOffBtn, false);
        SetVisible(self.strongBtn, false)
        SetVisible(self.mountStoneBtn, false)
        SetVisible(self.DonateBtn, false)
        SetVisible(self.ExchangeBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.takeOutBtn, false)
        SetVisible(self.upShelfBtn, false)
        local function call_back()
            --Notify.ShowText("出售");
            local itemConfig = Config.db_item[self.equipItem.id];
            local param = {}
            local kv = { key = self.equipItem.uid, value = 1 };
            table.insert(param, kv);
            local fun = function()
                GoodsController.Instance:RequestSellItems(param);
            end
            if itemConfig.color >= enum.COLOR.COLOR_RED then
                Dialog.ShowTwo(ToemsModel.text.tips, ToemsModel.text.des, ToemsModel.text.Ok, fun, nil, ToemsModel.text.center);
            else
                GoodsController.Instance:RequestSellItems(param);
            end


            --GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,1)
            --MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.sellBtn.gameObject, call_back)

        local function putoff_fun()
            --Notify.ShowText("卸下");
            local equipConfig = Config.db_totems_equip[self.equipItem.id];
            ToemsController:GetInstance():RequesEquipUnloadInfo(ToemsModel:GetInstance().currentBeastEquip, equipConfig.slot);
            --GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,1)
            --MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.putOffBtn.gameObject, putoff_fun)

        local function equip_fun()
            --Notify.ShowText("装备");
            ToemsController:GetInstance():RequesEquipLoadInfo(ToemsModel:GetInstance().currentBeastEquip, self.equipItem.uid);
            --GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,1)
            --MarketModel.GetInstance().selectItem = self.equipItem
            self:destroy()
        end
        AddClickEvent(self.putOnBtn.gameObject, equip_fun)
    else
        SetVisible(self.DonateBtn, false)
        SetVisible(self.ExchangeBtn, false)

        local equipConfig = Config.db_equip[self.equipItem.id]
        local putOnEquip = EquipModel.Instance.putOnedEquipList[equipConfig.slot]
        SetVisible(self.upShelfBtn, false)
        if putOnEquip ~= nil and self.equipItem.uid == putOnEquip.uid then
            --SetVisible(self.strongBtn.gameObject,true)
            SetVisible(self.mountStoneBtn, false)
            SetVisible(self.storeBtn, false)
            SetVisible(self.sellBtn, false)
            SetVisible(self.putOnBtn, false)
            SetVisible(self.takeOffBtn, false)
            SetVisible(self.takeOutBtn, false)
            --SetVisible(self.destroyBtn,false)

            local function call_back()
                --GlobalEvent:Brocast(EquipEvent.ShowEquipUpPanel,1))
                OpenLink(120, 1, 1, true)
                EquipStrongModel.GetInstance().select_equip = self.equipItem
                self:destroy()
            end

            AddClickEvent(self.strongBtn.gameObject, call_back)

            local function call_back()
                --GlobalEvent:Brocast(EquipEvent.ShowEquipUpPanel,2)
                OpenLink(120, 1, 2, true)
                EquipMountStoneModel.GetInstance().select_equip = self.equipItem
                self:destroy()
            end
            AddClickEvent(self.mountStoneBtn.gameObject, call_back)

            if equipConfig.slot == EquipModel.Instance.emoSlot then
                --小恶魔，要卸下
                SetVisible(self.mountStoneBtn.gameObject, false)
                SetVisible(self.strongBtn.gameObject, false)
                SetVisible(self.putOffBtn.gameObject, true)

                local function call_back()
                    EquipController.Instance:RequestPutOff(equipConfig.slot)
                end
                AddClickEvent(self.putOffBtn.gameObject, call_back)
            else


                if OpenTipModel.Instance:IsOpenSystem(120, 1) then
                    SetVisible(self.mountStoneBtn.gameObject, true)
                    SetVisible(self.strongBtn.gameObject, true)
                else
                    SetVisible(self.strongBtn.gameObject, false)
                    SetVisible(self.mountStoneBtn.gameObject, false)
                end

            end
            return
        else
            SetVisible(self.strongBtn, false)
            SetVisible(self.mountStoneBtn.gameObject, false)
        end

        if self.equipItem.bag == BagModel.wareHouseId or self.equipItem.bag == BagModel.stHouseId then
            --SetVisible(self.destroyBtn,false)
            SetVisible(self.storeBtn, false)
            SetVisible(self.sellBtn, false)
            SetVisible(self.putOnBtn, false)
            SetVisible(self.takeOffBtn, false)
            SetVisible(self.strongBtn, false)
            --取出道具
            local function call_back(target, x, y)
                GoodsController.Instance:RequestTakeOut(self.equipItem.uid, 1)
            end
            AddClickEvent(self.takeOutBtn.gameObject, call_back)
        elseif self.equipItem.bag == BagModel.bagId then

            if GoodsModel.GetInstance().isOpenWarePanel == true then
                --打开了仓库，只有储存按钮
                --SetVisible(self.destroyBtn,false)
                SetVisible(self.sellBtn, false)
                SetVisible(self.putOnBtn, false)
                SetVisible(self.takeOutBtn, false)
                --SetVisible(self.strongBtn,false)
                --存储道具
                local function call_back(target, x, y)
                    GoodsController.Instance:RequestStoreItem(self.equipItem.uid, self.equipItem.num)
                end
                AddClickEvent(self.storeBtn.gameObject, call_back)
            else
                if not EquipModel.Instance:GetEquipIsMapCareer(self.equipItem.id) then
                    --判断是否可穿戴
                    SetVisible(self.putOnBtn.gameObject, false)
                else
                    SetVisible(self.putOnBtn.gameObject, true)
                end

                SetVisible(self.takeOutBtn, false)
                SetVisible(self.storeBtn.gameObject, false)

                local function call_back(target, x, y)
                    --出售道具
                    local param = {}
                    local kv = { key = self.equipItem.uid, value = 1 }
                    table.insert(param, kv)
                    GoodsController.Instance:RequestSellItems(param)
                end

                AddClickEvent(self.sellBtn.gameObject, call_back)

                --local function call_back(target,x,y)         --丢弃(销毁)道具
                --	GoodsController.Instance:RequestChuckItem(self.equipItem.uid,1)
                --end
                --AddClickEvent(self.destroyBtn.gameObject,call_back)

                local function call_back(target, x, y)
                    local equipCfg = Config.db_equip[self.equipItem.id]
                    local itemConfig = Config.db_item[self.equipItem.id]
                    local roleInfoModel = RoleInfoModel:GetInstance():GetMainRoleData()
                    if itemConfig.level > roleInfoModel.level then
                        Notify.ShowText(string.format(ConfigLanguage.Equip.NeedLVToPutOn, itemConfig.level))
                    elseif equipCfg.wake > roleInfoModel.wake then
                        Notify.ShowText(string.format(ConfigLanguage.Equip.NeedWakeToPutOn, equipCfg.wake))
                    else
                        local putOnEquip = EquipModel.Instance.putOnedEquipList[equipConfig.slot]
                        --强化是否要提示
                        local less = false
                        local tips = {}
                        local titles = {}

                        if putOnEquip ~= nil and equipConfig.slot ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
                            local putOnEquipCfg = Config.db_equip[putOnEquip.id]
                            local putOnItemCfg = Config.db_item[putOnEquip.id]
                            local suitLvCfg = Config.db_equip_suite_level[2]
                            local activeLV1 = EquipSuitModel.Instance:GetActiveByEquip(putOnEquipCfg.slot, 1)
                            local activeLV2 = EquipSuitModel.Instance:GetActiveByEquip(putOnEquipCfg.slot, 2)

                            --[[if activeLV2 then
                                --激活了2级套装
                                if EquipSuitModel.Instance:GetCanBuildMaxSuitLv(self.equipItem.id) <= 1 then
                                    --穿上的小于等于1
                                    table.insert(tips, ConfigLanguage.Equip.PutOnEquipSuitTip)
                                    table.insert(titles, ConfigLanguage.Mix.Tips)
                                end
                            elseif activeLV1 then
                                if EquipSuitModel.Instance:GetCanBuildMaxSuitLv(self.equipItem.id) < 1 then
                                    table.insert(tips, ConfigLanguage.Equip.PutOnEquipSuitTip)
                                    table.insert(titles, ConfigLanguage.Mix.Tips)
                                end
                            end--]]
                            if activeLV1 or activeLV2 then
                                if equipCfg.order ~= putOnEquipCfg.order or equipCfg.star ~= putOnEquipCfg.star or putOnItemCfg.color ~= itemConfig.color then
                                    table.insert(tips, ConfigLanguage.Equip.PutOnEquipSuitTip)
                                    table.insert(titles, ConfigLanguage.Mix.Tips)
                                end
                            end

                            local strong_limit_key = equipConfig.slot .. "@" .. equipConfig.order .. "@" .. itemConfig.color

                            local equipLV = putOnEquip.equip.stren_lv + putOnEquip.equip.stren_phase * 9
                            if equipLV > Config.db_equip_strength_limit[strong_limit_key].max_phase * 9 then
                                less = true
                            end
                        end
                        if less then
                            local itemConfig = Config.db_item[self.equipItem.id]
                            local strong_limit_key = equipConfig.slot .. "@" .. equipConfig.order .. "@" .. itemConfig.color

                            local strong_str = string.format("%s%s%s%s", Config.db_equip_strength_limit[strong_limit_key].max_phase - 1,
                                    ConfigLanguage.Equip.Phase, 10, ConfigLanguage.Equip.LV)
                            local tipInfo = string.format(ConfigLanguage.Equip.PutOnEquipStrongTip, ColorUtil.GetColor(ColorUtil.ColorType.Green),
                                    strong_str, ColorUtil.GetColor(ColorUtil.ColorType.Green))
                            table.insert(tips, tipInfo)
                            table.insert(titles, ConfigLanguage.Equip.PutOnEquipStrongTipTitle)
                        end

                        if not table.isempty(tips) then
                            Dialog.ShowTwoWithMultyClickOK(titles, tips, ConfigLanguage.Mix.Confirm,
                                    handler(self, self.RequestPutOnEquip))
                        else
                            self:RequestPutOnEquip()
                        end
                    end
                end
                AddClickEvent(self.putOnBtn.gameObject, call_back)
            end

        end
    end
end

function BaseEquipDetailView:AddClickCloseBtn()
    if self.click_bg_close then
        local tcher = self.gameObject:AddComponent(typeof(Toucher))
        tcher:SetClickEvent(handler(self, self.OnTouchenBengin))
    else
        SetVisible(self.mask.gameObject, false)
    end
end

function BaseEquipDetailView:DeleteClickClose()
    if self.update_sched_id ~= nil then
        GlobalSchedule:Stop(self.update_sched_id)
        self.update_sched_id = nil
        self:destroy()
    end
end

function BaseEquipDetailView:OnTouchenBengin(x, y)
    local pos = self.transform.position
    local bg_x = ScreenWidth / 2 + pos.x * 100
    local bg_y = pos.y * 100 + ScreenHeight / 2

    local xw = bg_x + self.bgRectTra.sizeDelta.x
    local yw = bg_y - self.bgRectTra.sizeDelta.y

    if not self.is_not_operate then
        xw = xw + self.btnWidth
    end

    if not (x >= bg_x and x <= xw and yw <= y and bg_y >= y) then
        self:destroy()
    end
end

function BaseEquipDetailView:ShowScoreUpArrow(upShow, downShow)
    local showDownArrow = not upShow
    if downShow ~= nil then
        showDownArrow = downShow
    end
    SetVisible(self.upArrow.gameObject, upShow)
    SetVisible(self.downArrow.gameObject, showDownArrow)
    SetLocalPositionX(self.upArrow, self.scoreValueTxt.preferredWidth)
    SetLocalPositionX(self.downArrow, self.scoreValueTxt.preferredWidth)
end

function BaseEquipDetailView:CompareEquipScore()
    if self.isCompare then
        local putOnEquip = EquipModel.Instance:GetPutonEquipMap(self.equipItem.id)
        if putOnEquip.uid ~= self.equipItem.uid then
            local w = self.scoreValueTxt.preferredWidth
            local difScore = self.equipItem.score - putOnEquip.score
            if difScore > 0 then
                self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                        ColorUtil.GetColor(ColorUtil.ColorType.Green), self.equipItem.score)

                self:ShowScoreUpArrow(true)
            elseif difScore < 0 then
                self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                        ColorUtil.GetColor(ColorUtil.ColorType.Red), self.equipItem.score)

                self:ShowScoreUpArrow(false)
            else
                self.scoreValueTxt.text = self.equipItem.score
                self:ShowScoreUpArrow(false, false)
            end
        else
            self.scoreValueTxt.text = self.equipItem.score
            self:ShowScoreUpArrow(false, false)
        end
    else
        local putOnEquip = EquipModel.Instance:GetPutonEquipMap(self.equipItem.id)
        if putOnEquip ~= nil and putOnEquip.uid == self.equipItem.uid then
            self.scoreValueTxt.text = self.equipItem.score
            self:ShowScoreUpArrow(false, false)
        else
            self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                    ColorUtil.GetColor(ColorUtil.ColorType.Green), self.equipItem.score)

            self:ShowScoreUpArrow(true)
        end

    end
end

function BaseEquipDetailView:CompareEquipScoreByEquipId()
    local score = EquipModel.Instance:GetEquipScore(self.item_id)
    if self.isCompare then
        local putOnEquip = EquipModel.Instance:GetPutonEquipMap(self.item_id)
        if putOnEquip.uid ~= self.item_id then

            local difScore = score - putOnEquip.score
            if difScore > 0 then
                self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                        ColorUtil.GetColor(ColorUtil.ColorType.Green), score)
                self:ShowScoreUpArrow(true)
            elseif difScore < 0 then
                self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                        ColorUtil.GetColor(ColorUtil.ColorType.Red), score)
                self:ShowScoreUpArrow(false)
            else
                self.scoreValueTxt.text = score .. ""
                self:ShowScoreUpArrow(false, false)
            end

        end
    else

        self.scoreValueTxt.text = score .. ""
    end
end

function BaseEquipDetailView:DealCreateAttEnd()
    self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x, self.height)
    if self.contentRectTra.sizeDelta.y > self.minScrollViewHeight and self.contentRectTra.sizeDelta.y < self.maxScrollViewHeight then
        self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.height)
    elseif self.height >= self.maxScrollViewHeight then
        self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.maxScrollViewHeight)
    else
        self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.minScrollViewHeight)
    end

    local y = self.scrollViewRectTra.sizeDelta.y + 170
    if y > self.maxViewHeight then
        y = self.maxViewHeight
    end
    self.viewRectTra.sizeDelta = Vector2(self.viewRectTra.sizeDelta.x, y)
    self.bgRectTra.sizeDelta = self.viewRectTra.sizeDelta
    --self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x,self.height)
    --if not has_equip_com then
    --	self.viewRectTra.anchoredPosition = Vector2(0,self.viewRectTra.sizeDelta.y / 2)
    --end

    --self.attContenSizeFilter.enabled = false
    --self.attContenSizeFilter.enabled = true
    --self:SetViewPosition()
end

function BaseEquipDetailView:DealDestroyEquip(uid)
    if self.equipItem.uid == uid then
        self:destroy()
    end
end

function BaseEquipDetailView:DelItem(bagId, uid)
    if self.equipItem.uid == uid then
        self:destroy()
    end
end

--处理销毁装备
function BaseEquipDetailView:DealDestroyEquip(id)
    if id == self.equipItem.uid then
        self:destroy()
    end
end

function BaseEquipDetailView:GetRectTransform()
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')
    self.scrollViewRectTra = self.ScrollView:GetComponent('RectTransform')
    self.attContainRectTra = self.Content:GetComponent('RectTransform')
    self.attContenSizeFilter = self.Content:GetComponent('ContentSizeFitter')
    self.scoreValueTxt = self.scoreValue:GetComponent("Text")
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    self.TextTempText = self.valueTemp:GetComponent('Text')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
end

function BaseEquipDetailView:OpenCallBack()
    self:UpdateView()
end

function BaseEquipDetailView:UpdateView()

end

function BaseEquipDetailView:CloseCallBack()

end

function BaseEquipDetailView:RequestPutOnEquip()
    EquipController.Instance:RequestPutOnEquip(self.equipItem.uid)
end

function BaseEquipDetailView:SetEquipInfo(data, isCompare)
    self.isCompare = isCompare
    self.equipItem = data
    self:AddEvent()

    if self.is_loaded then
        local itemConfig = Config.db_item[data.id]
        local equipConfig;
        if self.isBeastEquip then
            equipConfig = Config.db_beast_equip[data.id];
        elseif self.isToemsEquip then
            equipConfig = Config.db_totems_equip[data.id];
        else
            equipConfig = Config.db_equip[data.id]
        end
        if equipConfig == nil then
            local a = 3
        end
        if equipConfig.slot == EquipModel.Instance.emoSlot then
            self.minScrollViewHeight = 150
        end

        if data.uid == 0 then
            SetVisible(self.btnContain.gameObject, false)
            self.btnWidth = 0
            --elseif self.isBeastEquip then
            --    SetVisible(self.btnContain.gameObject, true)
        elseif not self.is_not_operate then
            SetVisible(self.btnContain.gameObject, true)
        end

        local putOnEquip = EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot]
        if putOnEquip ~= nil then
            self.has_equip_com = true
        else
            self.has_equip_com = false
        end

        local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
        if roleData.level < itemConfig.level then
            self.wareValue:GetComponent('Text').text = string.format("<color=#%s>%s</color>",
                    ColorUtil.GetColor(ColorUtil.ColorType.Red), itemConfig.level)
        else
            self.wareValue:GetComponent('Text').text = itemConfig.level
        end



        --是比较的话，
        if self.isCompare then
            if putOnEquip ~= nil and putOnEquip.uid == data.uid then
                --是否身上的装备
                SetVisible(self.btnContain.gameObject, false)
            elseif self.equipItem.uid ~= 0 then
                --装备uid不为0，在背包(上一段判断了身上了)
                SetVisible(self.btnContain.gameObject, true)
            else
                SetVisible(self.btnContain.gameObject, false)
            end
        end

        self:UpdateName(itemConfig.name, itemConfig.color, data.id)
        --self:UpdateStar(equipConfig.star)
        self:UpdateQualityBg(itemConfig.color)
        self:UpdateIcon(data)
        self:UpdateSlot(equipConfig.slot)
        self:UpdateCareer(equipConfig.career, equipConfig.id, equipConfig.wake)
        self:UpdateBaseAttr(data)
        self:UpdateTheBestAttr(data.equip)
        if not self.isBeastEquip and not self.isToemsEquip then
            self:CompareEquipScore()
        end

        if equipConfig.slot == EquipModel.Instance.emoSlot then
            --小恶魔
            self:UpdateValidDate(data.etime)
        else
            self:UpdateStone()
        end

        if not self.isBeastEquip and not self.isToemsEquip then
            self:UpdateSuit();
        end

        self:DealCreateAttEnd()
        self.need_load_end = false

        GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)

        if putOnEquip ~= nil and putOnEquip.uid == data.uid then
            SetVisible(self.had_put_on.gameObject, true)

            local pos = self.transform.position
            local bg_x = ScreenWidth / 2 + pos.x * 100
            local bg_y = pos.y * 100 + ScreenHeight / 2

            local xw = bg_x + self.bgRectTra.sizeDelta.x * 2
            local yw = bg_y - self.bgRectTra.sizeDelta.y

            xw = xw + 120

            local param = {}
            param["bg_x"] = bg_x
            param["bg_y"] = bg_y
            param["xw"] = xw
            param["yw"] = yw

            GlobalEvent:Brocast(EquipEvent.BrocastSetViewPosition, param)
        else
            SetVisible(self.had_put_on.gameObject, false)
        end

    else

        self.need_load_end = true
    end
end

function BaseEquipDetailView:Update()
    if Input.GetMouseButtonUp(0) then
        self.delete_scheld_id = GlobalSchedule:StartOnce(handler(self, self.DeleteClickClose), Time.deltaTime)
    elseif Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Ended then
        self.delete_scheld_id = GlobalSchedule:StartOnce(handler(self, self.DeleteClickClose), Time.deltaTime)
    end
end

function BaseEquipDetailView:UpdateInfoNotOperate(data, isCompare)
    self.is_not_operate = true
    self:SetEquipInfo(data, isCompare)
end

function BaseEquipDetailView:UpdateInfo(data, isCompare)
    self:SetEquipInfo(data, isCompare)
end

function BaseEquipDetailView:UpdateInfoByEquipId(itemId, isCompare)
    self.isCompare = isCompare
    self.item_id = itemId
    self.btnWidth = 0

    if self.is_loaded then
        if not self.isCompare then
            self:AddClickCloseBtn()
            self:SetViewPosition()
        else
            SetVisible(self.mask.gameObject, false)
        end

        local itemConfig = Config.db_item[itemId]
        local equipConfig = Config.db_equip[itemId]
        if equipConfig.slot == EquipModel.Instance.emoSlot then
            self.minScrollViewHeight = 150
        end
        SetVisible(self.btnContain.gameObject, false)
        SetVisible(self.had_put_on.gameObject, false)
        --self.nameTxt:GetComponent('Text').text = itemConfig.name
        self.wareValue:GetComponent('Text').text = itemConfig.level
        self.scoreValueTxt.text = EquipModel.Instance:GetEquipScore(itemId)

        self:UpdateName(itemConfig.name, itemConfig.color)
        self:UpdateQualityBg(itemConfig.color)
        self:UpdateIconByItemId(itemId)
        --self:UpdateStar(equipConfig.star)
        self:UpdateSlot(equipConfig.slot)
        self:UpdateCareer(equipConfig.career, equipConfig.id, equipConfig.wake)
        self:UpdateBaseAttrByItemId(equipConfig.base)
        self:UpdateBestAttrByItemId(equipConfig.rare2, itemConfig.color)
        self:CompareEquipScoreByEquipId()
        if equipConfig.slot == EquipModel.Instance.emoSlot then
            --小恶魔
            self:UpdateValidDateWithCfg(itemConfig.expire)
        else
            self:UpdateStone()
        end

        --self:DealCreateAttEnd()
        self:DealCreateAttEnd()
        self.need_load_end = false


        --GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)
    else

        self.need_load_end = true
    end
end

function BaseEquipDetailView:UpdateIconImage(itemId)
    local param = {}
    param["model"] = BagModel.GetInstance()
    param["item_id"] = itemId
    param["size"] = { x = 72, y = 72 }
    if self.iconStor == nil then
        self.iconStor = GoodsIconSettorTwo(self.icon)
    end

    self.iconStor:SetIcon(param)


    --local iconImg = self.icon:GetComponent('Image')
    --local abName = GoodIconUtil.GetInstance():GetABNameById(icon)
    --abName = "iconasset/" .. abName
    --lua_resMgr:SetImageTexture(self, iconImg, abName, tostring(icon), true, nil, false)
end

function BaseEquipDetailView:UpdateName(name, quality, equipId)
    local suitName = ""
    if equipId and EquipModel.Instance:GetEquipIsOn(equipId) then
        local equipCfg = Config.db_equip[equipId]
        local activeLV2 = EquipSuitModel.Instance:GetActiveByEquip(equipCfg.slot, 2)
        local activeLv1 = EquipSuitModel.Instance:GetActiveByEquip(equipCfg.slot, 1)

        if activeLV2 then
            suitName = "[" .. EquipSuitModel.Instance.suitTypeName[2] .. "]"
        elseif activeLv1 then
            suitName = "[" .. EquipSuitModel.Instance.suitTypeName[1] .. "]"
        end
    end
    self.nameTxt:GetComponent('Text').text = suitName .. name
end

function BaseEquipDetailView:UpdateQualityBg(quality)
    local qualityImg = self.q_bg:GetComponent('Image')
    lua_resMgr:SetImageTexture(self, qualityImg, "equip_image", "equip_q_bg_" .. quality, true)
end

-- data     p_item
function BaseEquipDetailView:UpdateIcon(data)
    --local _config = Config.db_item[data.id]
    self:UpdateIconImage(data.id)
end

function BaseEquipDetailView:UpdateIconByItemId(itemId)
    if self.iconStor ~= nil then
        self.iconStor:destroy()
    end

    local _config = Config.db_item[itemId]
    self:UpdateIconImage(_config.icon)
    --self.iconStor = GoodsIconSettor(self.icon,"UI")
    --self.iconStor:UpdateIconByItemId(itemId)
end

function BaseEquipDetailView:UpdateCareer(careerStr, equipId, equipWake)
    if careerStr ~= nil then
        local careerInfo = ""
        local careerCfg = {}
        if careerStr == "0" then
            table.insert(careerCfg, 1)
            table.insert(careerCfg, 2)
        else
            careerCfg = String2Table(careerStr)
        end
        for k, v in pairs(careerCfg) do
            local wakeCfg = EquipModel.Instance:GetEquipWakeCfg(v, equipWake)
            if wakeCfg ~= nil then
                if EquipModel.Instance:GetMapCrntCareer(v, equipId) then
                    careerInfo = careerInfo .. wakeCfg.name .. "\n"
                else
                    careerInfo = careerInfo .. string.format("<color=#%s>%s</color>", EquipModel.Instance.notMapCarrerColor,
                            wakeCfg.name .. "\n")
                end
            end

        end

        self.career:GetComponent('Text').text = careerInfo

        if table.nums(careerCfg) == 1 then
            self.careerConRectTra = self.careerCon:GetComponent('RectTransform')
            SetAnchoredPosition(self.careerCon, self.careerConRectTra.anchoredPosition.x, 11)
            --self.careerConRectTra.anchoredPosition = Vector2(self.careerConRectTra.anchoredPosition.x,11)

        end
    end
end

--更新部位
function BaseEquipDetailView:UpdateSlot(slot)
    local key = enum.ITEM_TYPE.ITEM_TYPE_EQUIP .. "@" .. slot
    if Config.db_item_type[key] ~= nil then
        local stype = Config.db_item_type[key].stype
        self.equipPos:GetComponent('Text').text = enumName.ITEM_STYPE[stype]
    end
end

function BaseEquipDetailView:UpdateSuit()
    if not EquipSuitModel.Instance:GetCanBuildSuit(self.equipItem) or not self.model:GetEquipIsOn(self.equipItem.id) then
        self:DealCreateAttEnd()
        return
    end

    local showSuitLv = EquipSuitModel.Instance:GetShowSuitLvByEquip(self.equipItem)
    local itemCfg = Config.db_item[self.equipItem.id]
    local equipCfg = Config.db_equip[self.equipItem.id]
    local suitCount = EquipSuitModel.Instance:GetActiveSuitCount(equipCfg.slot, equipCfg.order, showSuitLv)
    local suitCfg = EquipSuitModel.Instance:GetSuitConfig(equipCfg.slot, equipCfg.order, showSuitLv)
    local attrsTb = String2Table(suitCfg.attribs)

    if table.isempty(attrsTb) then
        return
    end

    local suitCfg = EquipSuitModel.Instance:GetSuitConfig(equipCfg.slot, equipCfg.order, showSuitLv)

    local titleInfo = ""
    if not table.isempty(suitCfg) then

        local activeLV2 = EquipSuitModel.Instance:GetActiveByEquip(equipCfg.slot, 2)
        local activeLv1 = EquipSuitModel.Instance:GetActiveByEquip(equipCfg.slot, 1)

        if not (activeLV2 or activeLv1) then
            return
        end
        local totalCount = EquipSuitModel.Instance:GetSuitCount(equipCfg.slot, equipCfg.order, showSuitLv)
        local hasCount = EquipSuitModel.Instance:GetActiveSuitCount(equipCfg.slot, equipCfg.order, showSuitLv)

        --if hasCount <= 0 then
        --	return
        --end

        titleInfo = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Orange),
                "【" .. EquipSuitModel.Instance.suitTypeName[showSuitLv] .. "】" .. EquipSuitModel.Instance.suitTypeName[showSuitLv] .. "·" .. suitCfg.title)
        local countInfo = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Yellow),
                "(" .. hasCount .. "/" .. totalCount .. ")")
        titleInfo = titleInfo .. countInfo
    end

    local attrInfoTbl = {}
    local height = 0
    for i, v in pairs(attrsTb) do
        local active = false
        if suitCount >= v[1] then
            active = true
        end

        local attrInfo = ""
        local countInfo = ""
        local attrCount = table.nums(v[2])
        local crntCount = 1
        for ii, vv in pairs(v[2]) do
            if active then
                countInfo = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Orange),
                        string.format("【" .. ConfigLanguage.Equip.Piece .. "】", v[1]))
                attrInfo = attrInfo .. string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Yellow),
                        enumName.ATTR[vv[1]])

                attrInfo = attrInfo .. string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),
                        "  " .. EquipModel.Instance:GetAttrTypeInfo(vv[1], vv[2]))
            else
                countInfo = string.format("<color=#8E8E8E>%s</color>", string.format("【" .. ConfigLanguage.Equip.Piece .. "】", v[1]))
                attrInfo = attrInfo .. string.format("<color=#8E8E8E>%s</color>", enumName.ATTR[vv[1]] ..
                        "  " .. EquipModel.Instance:GetAttrTypeInfo(vv[1], vv[2]))
            end

            if crntCount < attrCount then
                attrInfo = attrInfo .. "\n"
            end

            crntCount = crntCount + 1

        end

        self.TextTempText.text = attrInfo
        height = height + self.TextTempText.preferredHeight + 10
        table.insert(attrInfoTbl, { active = active, count = countInfo, value = attrInfo })


    end

    height = height + 14 + 25
    --self.height = height
    if self.suitItemSettor == nil then
        self.suitItemSettor = EquipSuitInfoItemSettor(self.Content)
    end

    if self.equipItem ~= nil then
        self.suitItemSettor:UpdateInfo({ title = titleInfo, attrInfos = attrInfoTbl, posY = self.height, itemHeight = height })
    end

    self.height = self.height + height
    self:DealCreateAttEnd()
end

function BaseEquipDetailView:UpdateStone()
    local equipCfg = nil
    if self.stoneItemSettor == nil then
        self.stoneItemSettor = EquipStoneInfoItemSettor(self.Content)
        local stones = {}
        local posY = self.height
        local itemHeight = 0
        if self.equipItem ~= nil then
            if self.isBeastEquip then
                equipCfg = Config.db_beast_equip[self.equipItem.id];
            elseif self.isToemsEquip then
                equipCfg = Config.db_totems_equip[self.equipItem.id];
            else
                equipCfg = Config.db_equip[self.equipItem.id]
            end

            stones = self.equipItem.equip.stones

            --self.stoneItemSettor:UpdateStoneInfo(self.equipItem.equip.stones,equipCfg.slot)
            local stonesNum = table.nums(self.equipItem.equip.stones)

            itemHeight = stonesNum * 52 + (6 - stonesNum) * 22 + 22 + 20
            self.height = self.height + itemHeight
            --self.height = self.height + stonesNum * 52
            --self.height = self.height + (6-stonesNum) * 22
            --self.height = self.height + 22 + 20
        else
            equipCfg = Config.db_equip[self.item_id]
            --self.stoneItemSettor:UpdateStoneInfo({},equipCfg.slot)

            itemHeight = 6 * 22 + 22 + 20
            self.height = self.height + itemHeight
            --self.height = self.height + 6 * 22
            --self.height = self.height + 22 + 20
        end

        self.stoneItemSettor:UpdateStoneInfo(stones, equipCfg.slot, posY, itemHeight)
    end


end

function BaseEquipDetailView:UpdateBaseAttrByItemId(baseAttr)
    local attrInfo = ""
    local baseAttrTbl = String2Table(baseAttr)
    self.baseAttrStr = EquipAttrItemSettor(self.Content)
    for k, v in pairs(baseAttrTbl) do
        local valueInfo = EquipModel.Instance:GetAttrTypeInfo(v[1], v[2])
        attrInfo = attrInfo .. enumName.ATTR[v[1]] .. ":   " .. valueInfo

        attrInfo = attrInfo .. "\n"
    end

    local equipConfig = Config.db_equip[self.item_id]
    if equipConfig.slot == EquipModel.Instance.emoSlot then
        self.baseAttrStr:SetMinHeight(120)

        local itemCfg = Config.db_item[self.item_id]
        attrInfo = attrInfo .. itemCfg.desc .. "\n"
    end

    self.TextTempText.text = attrInfo
    local height = self.TextTempText.preferredHeight + 25 + 10
    self.baseAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BaseAttr, info = attrInfo, posY = self.height,
                                 itemHeight = height })

    self.height = self.height + height
end

function BaseEquipDetailView:UpdateBestAttrByItemId(bestAttr, color)
    local attrInfo = ""
    local bestAttrTbl = String2Table(bestAttr)
    local attrNums = table.nums(bestAttrTbl)
    if attrNums <= 0 then
        return
    end

    self.bestAttrStr = EquipAttrItemSettor(self.Content)
    for k, v in pairs(bestAttrTbl) do
        local valueInfo = EquipModel.Instance:GetAttrTypeInfo(v[1], v[2])
        attrInfo = attrInfo .. "[" .. ConfigLanguage.Mix.Recommend .. "] ", enumName.ATTR[v[1]] .. ":   ", valueInfo

        attrInfo = attrInfo .. "\n"
    end

    local rare_num = self.model:GetRareNum(color)
    local title = ConfigLanguage.AttrTypeName.BestAttr .. "(" .. string.format(ConfigLanguage.Equip.RandGetAttr,
            rare_num) .. ")"

    self.TextTempText.text = attrInfo
    local height = 0
    if self.TextTempText.preferredHeight <= 96 then
        height = 96
    else
        height = self.TextTempText.preferredHeight
    end
    height = height + 25 + 10
    self.bestAttrStr:SetMinHeight(96)
    self.bestAttrStr:UpdatInfo({ title = title, info = attrInfo, posY = self.height, itemHeight = height })


    --if self.TextTempText.preferredHeight <= 96 then
    --	self.height = self.height + 96
    --else
    --	self.height = self.height + self.TextTempText.preferredHeight
    --end

    self.height = self.height + height
end

--更新基础属性
function BaseEquipDetailView:UpdateBaseAttr(equipItem)
    local baseAttr = EquipModel.GetInstance():TranslateAttr(equipItem.equip.base)
    if not table.isempty(baseAttr) then
        local equipCfg;
        if self.isBeastEquip then
            equipCfg = Config.db_beast_equip[equipItem.id]
        elseif self.isToemsEquip then
            equipCfg = Config.db_totems_equip[equipItem.id]
        else
            equipCfg = Config.db_equip[equipItem.id]
        end
        local streng_key = equipCfg.slot .. "@" .. equipItem.equip.stren_phase .. "@" .. equipItem.equip.stren_lv
        local equipStrongCfg = Config.db_equip_strength[streng_key]

        self.baseAttrStr = EquipTwoAttrItemSettor(self.Content)
        local attrInfo = ""
        local strongAttrInfo = ""
        for k, v in pairs(baseAttr) do
            local valueInfo = EquipModel.Instance:GetAttrTypeInfo(k, v)
            attrInfo = attrInfo .. enumName.ATTR[k] .. ":   " .. valueInfo
            if equipStrongCfg ~= nil then
                local strongVlu = EquipStrongModel:GetAttStrongValue(k, equipStrongCfg)
                local valueInfo = EquipModel.Instance:GetAttrTypeInfo(k, strongVlu)
                if strongVlu > 0 then
                    strongAttrInfo = strongAttrInfo .. ConfigLanguage.Equip.Strong .. valueInfo .. "\n"
                end
            end

            attrInfo = attrInfo .. "\n"
        end

        --local equipConfig = Config.db_equip[equipItem.id]
        if equipCfg.slot == EquipModel.Instance.emoSlot then
            self.baseAttrStr:SetMinHeight(120)

            local itemCfg = Config.db_item[equipItem.id]
            attrInfo = attrInfo .. itemCfg.desc .. "\n"
        end

        self.TextTempText.text = attrInfo
        local height = self.TextTempText.preferredHeight + 25 + 10
        self.baseAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BaseAttr, info1 = attrInfo, info2 = strongAttrInfo,
                                     posY = self.height, itemHeight = height })

        self.height = self.height + height
        --self.height = self.height + 25 + 10
    end
end

--更新极品属性
function BaseEquipDetailView:UpdateTheBestAttr(data)
    local rare3Attr = EquipModel.GetInstance():TranslateAttr(data.rare3)
    local rare2Attr = EquipModel.GetInstance():TranslateAttr(data.rare2)
    local rare1Attr = EquipModel.GetInstance():TranslateAttr(data.rare1)
    local attrInfo = ""
    if not table.isempty(rare3Attr) then

        self.bestAttrStr = EquipAttrItemSettor(self.Content)

        for k, v in pairs(rare3Attr) do
            local valueInfo = EquipModel.Instance:GetAttrTypeInfo(k, v)
            attrInfo = attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "\n"
        end
    end

    if not table.isempty(rare2Attr) then
        if self.bestAttrStr == nil then
            self.bestAttrStr = EquipAttrItemSettor(self.Content)
        else
            --attrInfo = attrInfo .. "\n"
        end

        for k, v in pairs(rare2Attr) do
            local valueInfo = EquipModel.Instance:GetAttrTypeInfo(k, v)
            attrInfo = attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "\n"
        end
    end

    if not table.isempty(rare1Attr) then
        if self.bestAttrStr == nil then
            self.bestAttrStr = EquipAttrItemSettor(self.Content)
        else
            --attrInfo = attrInfo .. "\n"
        end

        for k, v in pairs(rare1Attr) do
            local valueInfo = EquipModel.Instance:GetAttrTypeInfo(k, v)
            attrInfo = attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "\n"
        end
    end

    if self.bestAttrStr ~= nil then
        self.TextTempText.text = attrInfo
        local height = 0
        if self.TextTempText.preferredHeight <= 96 then
            height = 96
        else
            height = self.TextTempText.preferredHeight
        end
        height = height + 25 + 10
        self.bestAttrStr:SetMinHeight(96)
        self.bestAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BestAttr, info = attrInfo, posY = self.height,
                                     itemHeight = height })

        --if self.TextTempText.preferredHeight <= 96 then
        --	self.height = self.height + 96
        --else
        --	self.height = self.height + self.TextTempText.preferredHeight
        --end

        self.height = self.height + height
    end
end

function BaseEquipDetailView:UpdateValidDate(time)
    if time <= 0 then
        return
    end

    self.TextTempText.text = EquipModel.Instance:GetEquipDifTime(time, TimeManager.Instance:GetServerTime()) .. "\n"
    local height = self.TextTempText.preferredHeight + 25 + 10

    if self.validDayStr == nil then
        self.validDayStr = EquipAttrItemSettor(self.Content)
    end
    self.validDayStr:UpdatInfo({ title = ConfigLanguage.Mix.ValidDay, info = self.TextTempText.text, posY = self.height,
                                 itemHeight = height })

    self.height = self.height + height
end

function BaseEquipDetailView:UpdateValidDateWithCfg(time)
    if time <= 0 then
        return
    end

    self.TextTempText.text = EquipModel.Instance:SplicingDifTime(0, time) .. "\n"
    local height = self.TextTempText.preferredHeight + 25 + 10

    if self.validDayStr == nil then
        self.validDayStr = EquipAttrItemSettor(self.Content)
    end
    self.validDayStr:UpdatInfo({ title = ConfigLanguage.Mix.ValidDay, info = self.TextTempText.text, posY = self.height,
                                 itemHeight = height })

    self.height = self.height + height
end

