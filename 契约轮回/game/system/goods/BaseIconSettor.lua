--
-- @Author: chk
-- @Date:   2018-09-17 20:03:14
--
BaseIconSettor = BaseIconSettor or class("BaseIconSettor", BaseWidget)
local this = BaseIconSettor

function BaseIconSettor:ctor(parent_node, layer)
    self.goodsDetailView = nil
    self.stoneDetailView = nil
    self.equipDetailView = nil
    self.globalEvents = {}
    self.goodsItem = nil
    self.itemId = nil
    self.itemNum = 0
    self.need_load_end = false
    self.clickEvent = ClickGoodsIconEvent.Click.NONE
end

function BaseIconSettor:dctor()
    for k, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end
    self.globalEvents = {}

    if self.goodsDetailView ~= nil then
        self.goodsDetailView:destroy()
    end
    self.goodsDetailView = nil

    if self.stoneDetailView ~= nil then
        self.stoneDetailView:destroy()
    end
    self.stoneDetailView = nil

    if self.equipDetailView ~= nil then
        self.equipDetailView:destroy()
    end
    self.equipDetailView = nil
    self.loadcallback = nil;

    if self.UpdateNumEvent then
        GlobalEvent:RemoveListener(self.UpdateNumEvent);
    end
    self.UpdateNumEvent = nil;
end

function BaseIconSettor:LoadNow(loadcallback)
    self.abName = "system"
    self.assetName = "GoodsIcon"
    --self.layer = LayerManager.BuiltinLayer.UI;

    self.loadcallback = loadcallback;
    BaseIconSettor.super.Load(self)
end

function BaseIconSettor:LoadCallBack()
    self.nodes = {
        "touch",
        "bindIcon",
        "step",
        "quality",
        "icon",
        "starContain",
        "num",
        "countBG",
        "countBG/count",
    }
    self:GetChildren(self.nodes)
    self.touch_img = GetImage(self.touch)
    self:AddEvent()

    self.countTxt = self.count:GetComponent('Text')
    -- self.selfRectTra = self.gameObject:GetComponent('RectTransform')
    -- self.selfRectTra.anchoredPosition = Vector2(0, 0)

    self:SetPosition(0, 0)

    if self.need_load_end then
        if self.goodsItem ~= nil then
            if self.clickEvent ~= nil then
                self:UpdateIconClick(self.goodsItem, self.numCount, self.goodsSize)
            else
                self:UpdateIcon(self.goodsItem, self.numCount, self.goodsSize)
            end

        elseif self.itemId ~= nil then
            if self.clickEvent ~= nil and self.clickEvent ~= ClickGoodsIconEvent.Click.NONE then
                self:UpdateIconByItemIdClick(self.itemId, self.numCount, self.goodsSize)
            else
                self:UpdateIconByItemId(self.itemId, self.numCount, self.goodsSize)
            end

        end
    end
    if self.loadcallback then
        self.loadcallback(self);
    end
end

function BaseIconSettor:SetPosition(x, y)
    if self.is_loaded then
        SetAnchoredPosition(self.transform, x, y)
    else
        self.position = Vector3(x, y, 0)
    end
end

function BaseIconSettor:AddEvent()
    local function call_back(target, x, y)
        self:ClickCallBack()

        if self.out_call_back ~= nil then
            self:out_call_back(self)
        end
    end
    AddClickEvent(self.touch.gameObject, call_back)

    --self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail,handler(self,self.DealGoodsDetailInfo) )
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail, handler(self, self.DealEquipUpdate))
    self.UpdateNumEvent =  GlobalEvent:AddListener(GoodsEvent.UpdateNum, handler(self, self.DealUpdateNumByUid));
    --self.globalEvents[#self.globalEvents + 1] =
    --self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.UpdateGoodsNum,handler(self,self.DealUpdateNum))
end

function BaseIconSettor:RemoveUpdateNumEvent()
    if self.UpdateNumEvent then
        GlobalEvent:RemoveListener(self.UpdateNumEvent);
    end
    self.UpdateNumEvent = nil;
end

function BaseIconSettor:AddClickIconEvent(clickEvent)

end

function BaseIconSettor:ClickCallBack(clickEvent)
    clickEvent = clickEvent or self.clickEvent
    if not clickEvent then
        return
    end
    if clickEvent == ClickGoodsIconEvent.Click.REQUEST_INFO then
        if self.pos == 1 then
            --身上的装备
            local equipConfig = Config.db_equip[self.goodsItem.id]
            GoodsController.Instance:RequestItemInfo(self.pos, equipConfig.slot)
        else
            GoodsController.Instance:RequestItemInfo(self.pos, self.goodsItem.uid)
        end
    elseif clickEvent == ClickGoodsIconEvent.Click.BEAST_SHOW then
        self.equipDetailView = EquipDetailView(self.transform);
        self.equipDetailView.isBeastEquip = true;
        self.equipDetailView.isNotOperate = true;
        --if self.is_not_operate then
        --    self.equipDetailView:UpdateInfoNotOperate(self.goodsItem)
        --else
        self.equipDetailView.is_not_operate = false;
        self.equipDetailView:UpdateInfo(self.goodsItem)
        --end
    elseif clickEvent == ClickGoodsIconEvent.Click.DIRECT_SHOW then
        local itemConfig = Config.db_item[self.goodsItem.id]
        if itemConfig ~= nil then
            if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                local equipCfg = Config.db_equip[self.goodsItem.id]
                local bagId = BagModel.Instance:GetBagIdByUid(self.goodsItem.uid)
                if bagId ~= 0 and equipCfg and EquipModel.Instance.putOnedEquipDetailList[equipCfg.slot] ~= nil then
                    EquipModel.GetInstance().outEquipItem = self.goodsItem
                    lua_panelMgr:GetPanelOrCreate(EquipPanel):Open()
                else
                    self.equipDetailView = EquipDetailView(self.transform)
                    if self.is_not_operate then
                        self.equipDetailView:UpdateInfoNotOperate(self.goodsItem)
                    else
                        self.equipDetailView:UpdateInfo(self.goodsItem)
                    end
                end
            elseif itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_STONE or itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_STONE2 then
                self.stoneDetailView = StoneDetailView(self.transform)
                self.stoneDetailView:UpdateInfo(self.goodsItem)

            else
                self.goodsDetailView = GoodsDetailView(self.transform)
                self.goodsDetailView:UpdateInfo(self.goodsItem)
            end
        end
    elseif clickEvent == ClickGoodsIconEvent.Click.DIRECT_SHOW_CFG and self.itemIdWithClick ~= nil then
        local itemConfig = Config.db_item[self.itemIdWithClick]
        if itemConfig ~= nil then
            if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                local equipCfg = Config.db_equip[self.itemIdWithClick]
                if EquipModel.Instance.putOnedEquipDetailList[equipCfg.slot] ~= nil then
                    EquipModel.GetInstance().outEquipItemId = self.itemIdWithClick
                    lua_panelMgr:GetPanelOrCreate(EquipPanel):Open()
                else
                    self.equipDetailView = EquipDetailView(self.transform)
                    self.equipDetailView:UpdateInfoByEquipId(self.itemIdWithClick)
                end
            elseif itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_STONE or itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_STONE2 then
                self.stoneDetailView = StoneDetailView(self.transform)
                self.stoneDetailView:UpdateInfoByItemId(self.itemIdWithClick)
            else
                self.goodsDetailView = GoodsDetailView(self.transform)
                self.goodsDetailView:UpdateInfoByItemId(self.itemIdWithClick)
            end
        end
    end
end

function BaseIconSettor:DealUpdateNumByUid(bagId, uid, num)
    if self.goodsItem ~= nil and self.goodsItem.uid == uid and self.is_loaded then
        self:UpdateNum(num)
    end
end

function BaseIconSettor:DealUpdateNum(itemId)
    local itemCfg = Config.db_item[itemId]
    if itemCfg.type ~= enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        if self.goodsItem ~= nil and self.goodsItem.id == itemId then
            local num = BagModel.Instance:GetItemNumByItemID(itemId)
            self:UpdateNum(num)
        elseif self.itemId ~= nil and self.itemId == itemId then
            local num = BagModel.Instance:GetItemNumByItemID(itemId)
            self:UpdateNum(num)
        end
    end
end

function BaseIconSettor:DealEquipUpdate(equipDetail)
    if self.goodsItem ~= nil and self.goodsItem.uid == equipDetail.uid then
        self.goodsItem = equipDetail
    end
end

function BaseIconSettor:SetIconInfo(item, num, size, clickEvent)
    self.clickEvent = clickEvent
    self.goodsItem = item
    self.numCount = num
    self.goodsSize = size

    if self.is_loaded then
        --self.transform:GetComponent('Toggle').enable = self.active_toggle

        self.need_load_end = false

        self.goodsItem = item
        self.numCount = num

        local _config = Config.db_item[item.id]
        if _config ~= nil then
            self:UpdateIconImage(_config.icon)
            self:UpdateQuality(_config.color)
            self:UpdateBind(item.bind)
            if _config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                local equipConfig = Config.db_equip[item.id];

                if equipConfig ~= nil then
                    self.slot = equipConfig.slot
                    self:UpdateSizeEquip(size)
                    self:UpdateNum(nil)
                    self:UpdateStar(equipConfig.star)
                    self:UpdateStep(equipConfig.order .. "j")
                end
            elseif Config.db_beast_equip[item.id] then
                local equipConfig = Config.db_beast_equip[item.id];

                if equipConfig ~= nil then
                    self.slot = equipConfig.slot
                    if self.slot ~= 0 then
                        self:UpdateSizeEquip(size)
                    end

                    self:UpdateNum(nil)
                    self:UpdateStar(equipConfig.star)
                end
            else
                self:UpdateSize(size)
                self:UpdateStep("")
                self:UpdateNum(num)
                SetVisible(self.starContain, false)
            end
        end

        --self:AddClickIconEvent(clickEvent)
        self.need_load_end = false
    else

        self.need_load_end = true
    end
end


--更新物品icon，      不带点击
--item               p_item_base/p_Item
--click              点击事件 见 ClickGoodsIconEvent
--pos                背包/仓库/部位
function BaseIconSettor:UpdateIcon(item, num, size, out_call_back, active_toggle)
    self.active_toggle = active_toggle
    self.out_call_back = out_call_back
    self:SetIconInfo(item, num, size)
end

--更新物品icon，      带点击，没操作
function BaseIconSettor:UpdateIconClickNotOperate(item, num, size, clickEvent)
    self.is_not_operate = true
    clickEvent = clickEvent or ClickGoodsIconEvent.Click.DIRECT_SHOW;
    self:SetIconInfo(item, num, size, clickEvent)
end

function BaseIconSettor:UpdateIconClick(item, num, size)
    self:SetIconInfo(item, num, size, ClickGoodsIconEvent.Click.DIRECT_SHOW)
end

--function BaseIconSettor:UpdateBeastIconClick(item, num, size)
--    self:SetIconInfo(item, num, size, ClickGoodsIconEvent.Click.BEAST_SHOW)
--end
--直接显示tips
function BaseIconSettor:ShowDetailNow(p_item)
    self.goodsItem = p_item;
    local itemConfig = Config.db_item[self.goodsItem.id]
    if itemConfig ~= nil then
        if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
            self.equipDetailView = EquipDetailView(self.transform)
            self.equipDetailView.isBeastEquip = true;
            if self.is_not_operate then
                self.equipDetailView:UpdateInfoNotOperate(self.goodsItem)
            else
                self.equipDetailView:UpdateInfo(self.goodsItem)
            end
        elseif itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP  then
            self.equipDetailView = EquipDetailView(self.transform)
            self.equipDetailView.isToemsEquip = true;
            if self.is_not_operate then
                self.equipDetailView:UpdateInfoNotOperate(self.goodsItem)
            else
                self.equipDetailView:UpdateInfo(self.goodsItem)
            end
        end
    end
end

function BaseIconSettor:SetIconInfoById(itemId, num, size, clickEvent)
    self.goodsSize = size
    self.itemId = itemId
    self.clickEvent = clickEvent
    self.numCount = num

    if self.is_loaded then
        self.need_load_end = false

        self.itemIdWithClick = itemId
        self.numCount = num

        local _config = Config.db_item[itemId]
        if _config ~= nil then
            local icon = _config.icon
            local iconTbl = LuaString2Table("{" .. icon .. "}")

            if type(iconTbl) == "table" then
                local _sex = self.sex
                if _sex == nil then
                    local roleData = RoleInfoModel.Instance:GetMainRoleData()
                    _sex = roleData.sex
                    self.sex = _sex
                end

                if iconTbl[self.sex] ~= nil then
                    icon = iconTbl[self.sex]
                else
                    for i, v in pairs(iconTbl) do
                        icon = v
                        break
                    end
                end
            end


            self:UpdateIconImage(icon)
            self:UpdateQuality(_config.color)

            if _config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                local equipConfig = Config.db_equip[itemId]

                if equipConfig ~= nil then
                    self:UpdateSizeEquip(size)
                    self:UpdateNum(nil)
                    self:UpdateStar(equipConfig.star)
                    self:UpdateStep(equipConfig.order .. "j")
                end
            else
                self:UpdateSize(size)
                self:UpdateStep("")
                self:UpdateNum(num)
                SetVisible(self.starContain, false)
            end
        end

        --self:AddClickIconEvent(self.clickEvent)
        self.need_load_end = false
    else

        self.need_load_end = true
    end
end

--更新物品icon，带点击
-- size  = {x = 0,y = 0}
function BaseIconSettor:UpdateIconByItemIdClick(itemId, num, size)
    self:SetIconInfoById(itemId, num, size, ClickGoodsIconEvent.Click.DIRECT_SHOW_CFG)
end

--更新物品icon，      不带点击
--itemId 配置表的id
-- size  = {x = 0,y = 0}
function BaseIconSettor:UpdateIconByItemId(itemId, num, size)
    self:SetIconInfoById(itemId, num, size)
end

function BaseIconSettor:UpdateSize(size)
    if not size then
        return
    end
    local set_w = type(size) == "table" and size.x or size
    local w = 54
    if set_w >= 94 then
        w = 94
    elseif set_w >= 76 then
        w = 76
    elseif set_w >= 60 then
        w = 60
        SetLocalScale(self.countBG.transform, 0.9, 0.9, 1)
        SetAnchoredPosition(self.countBG.transform, -67.61, 24.3)
    end
    -- self.selfRectTra.sizeDelta = Vector2(w, w)
    SetSizeDelta(self.transform, w, w)
end

function BaseIconSettor:UpdateSizeEquip(size)
    if not size then
        return
    end

    SetSizeDelta(self.transform, size.x, size.y)
end

function BaseIconSettor:UpdateBind(bind)
    SetVisible(self.bindIcon.gameObject, bind)
end

function BaseIconSettor:UpdateStep(step)
    self.step:GetComponent('Text').text = step
end

function BaseIconSettor:SetIconGray()
    local qualityImg = self.quality:GetComponent('Image')
    local iconImg = self.icon:GetComponent('Image')
    ShaderManager.GetInstance():SetImageGray(qualityImg)
    ShaderManager.GetInstance():SetImageGray(iconImg)
end

function BaseIconSettor:SetIconNormal()
    local qualityImg = self.quality:GetComponent('Image')
    local iconImg = self.icon:GetComponent('Image')
    ShaderManager.GetInstance():SetImageNormal(qualityImg)
    ShaderManager.GetInstance():SetImageNormal(iconImg)
end

function BaseIconSettor:UpdateIconImage(icon)
    if self.last_goods_icon == icon then
        return
    end
    self.last_goods_icon = icon
    local iconImg = self.icon:GetComponent('Image')
    GoodIconUtil.GetInstance():CreateIcon(self, iconImg, icon, true)
end

function BaseIconSettor:UpdateStar(star)
    SetVisible(self.starContain, true)
    local startCount = self.starContain.childCount
    for i = 0, startCount - 1 do
        if i < star then
            SetVisible(self.starContain:GetChild(i), true)
        else
            SetVisible(self.starContain:GetChild(i), false)
        end
    end
end

function BaseIconSettor:UpdateNum(num)
    --if self.num == nil then
    --    return
    --end

    Chkprint("num_____",num)
    if not self.is_loaded then
        return
    end
    if num == nil or num == 0 then
        num = ""
        SetVisible(self.countBG.gameObject, false)
    else
        SetVisible(self.countBG.gameObject, true)
    end

    self.countTxt:GetComponent('Text').text = tostring(num)
end

--更新品质
function BaseIconSettor:UpdateQuality(quality)
    local qualityImg = self.quality:GetComponent('Image')
    if self.last_quality == quality then
        return
    end
    self.last_quality = quality
    lua_resMgr:SetImageTexture(self, qualityImg, "common_image", "com_icon_bg_" .. quality, true,nil,false)
end

function BaseIconSettor:SetData(data)

end

function BaseIconSettor:SetTouchAvailible(flag)
    self.touch_img.raycastTarget = flag
end
