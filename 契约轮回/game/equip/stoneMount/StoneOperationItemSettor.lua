--
-- @Author: chk
-- @Date:   2018-10-06 19:21:11
--
StoneOperationItemSettor = StoneOperationItemSettor or class("StoneOperationItemSettor", BaseItem)
local StoneOperationItemSettor = StoneOperationItemSettor

function StoneOperationItemSettor:ctor(parent_node, layer)
    self.abName = "equip"
    self.assetName = "StoneOperationItem"
    self.layer = layer

    self.globalEvents = {}
    self.operation = nil              --1,升级宝石 ,2,直接镶嵌,3,跳到商场购买
    self.iconSettor = nil
    self.model = EquipMountStoneModel:GetInstance()
    StoneOperationItemSettor.super.Load(self)
end

function StoneOperationItemSettor:dctor()
    if self.iconSettor ~= nil then
        self.iconSettor:destroy()
    end
    self.iconSettor = nil

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end
    --self.model = nil
end

function StoneOperationItemSettor:LoadCallBack()
    self.nodes = {
        "icon",
        "value",

    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self.rectTransform = self.transform:GetComponent('RectTransform')

    if self.need_loaded_end then
        self:UpdateInfo(self.info, self.itemId, self.num, self.index)
    end
end

function StoneOperationItemSettor:AddEvent()
    AddClickEvent(self.transform.gameObject, handler(self, self.ClickOperation))
    --self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.UpdateNum,handler(self,self.DealUpdateNum))
end

function StoneOperationItemSettor:SetItemPosition()
    self.rectTransform.anchoredPosition = Vector2(0, -self.index * (self.rectTransform.sizeDelta.y + 10))
end

function StoneOperationItemSettor:SetData(data)

end

function StoneOperationItemSettor:ClickOperation()
    Jlprint('--Jl StoneOperationItemSettor.lua,line 60-- self.operation=', self.operation)
    if self.operation == 1 then
        local upType = self.model:GetUpLvType(self.itemId,self.model.cur_state)
        if upType == 1 then
            local stoneCfg
            local nextCfg
            if self.model.cur_state == self.model.states.gem then
                stoneCfg = Config.db_stone[self.itemId]
                nextCfg = Config.db_stone[stoneCfg.next_level_id]
            else
                stoneCfg = Config.db_spar[self.itemId]
                nextCfg = Config.db_spar[stoneCfg.next_level_id]
            end

            local function call_back()
                EquipController.Instance:RequestUpStone(self.model.operateSlot, self.model.operateHole, nextCfg.level)
                GlobalEvent:Brocast(EquipEvent.CloseStoneOperateView)
            end
            local stoneItemCfg = Config.db_item[self.itemId]
            local nextStoneItemCfg = Config.db_item[stoneCfg.id]
            Dialog.ShowTwo(ConfigLanguage.Mix.Tips, string.format(ConfigLanguage.Equip.UpStoneTip, stoneItemCfg.name,
                    stoneCfg.need_num, nextStoneItemCfg.name, stoneCfg.level + 1), ConfigLanguage.Mix.Confirm, call_back)

        else
            GlobalEvent:Brocast(EquipEvent.CloseStoneOperateView)
            lua_panelMgr:GetPanelOrCreate(EquipStoneUpPanel):Open(self.itemId, self.model.operateSlot, self.model.operateHole)
            --[[self.stoneUpView = EquipStoneUpView(self.model.stoneUpViewContain,"UI")
            self.stoneUpView:UpdateInfo(self.itemId,self.model.operateSlot,self.model.operateHole)--]]
        end
    elseif self.operation == 2 then
        EquipController.Instance:RequestMountStone(self.model.operateSlot, self.model.operateHole, self.itemId)
        GlobalEvent:Brocast(EquipEvent.CloseStoneOperateView)
    elseif self.operation == 3 then
        --跳转到商城

        --根据宝石或是晶石 跳转到对应商城页面
        if  self.model.cur_state == self.model.states.gem then
            local mall_item_id = ShopModel.GetInstance():GetMallIdByItemId(self.itemId)
            OpenLink(180, 1, 2, 4, mall_item_id)
        else
            local id = ShopModel.GetInstance():GetMallIdByItemId(101004)
            if self.model.operateSlot > 1005 then
                id = ShopModel.GetInstance():GetMallIdByItemId(102004)
            end
            OpenLink(180, 1, 1, 2,id)
        end

        GlobalEvent:Brocast(EquipEvent.CloseStoneOperateView)
    end
end

function StoneOperationItemSettor:DestroyByid(itemId)
    if self.itemId == itemId then
        self:destroy()
    end
end
function StoneOperationItemSettor:DealUpdateNum(itemId, num)
    if self.itemId == itemId and not self.iconSettor then
        self.iconSettor:UpdateNum(num)
    end
end

function StoneOperationItemSettor:UpdateInfo(info, itemId, num, index)
    self.info = info
    self.itemId = itemId
    self.num = num
    self.index = index

    if self.is_loaded then
        self.value:GetComponent('Text').text = info
        self.iconSettor = GoodsIconSettorTwo(self.icon)

        local param = {}
        param["item_id"] = itemId
        param["size"] = { x = 70, y = 70 }
        param["model"] = self.model
        param["num"] = num
        self.iconSettor:SetIcon(param)

        --self:SetItemPosition()
    else
        self.need_loaded_end = true

    end
end

function StoneOperationItemSettor:UpdateInfoUpLv(info, itemId, num, index)
    self.operation = 1
    self:UpdateInfo(info, itemId, num, index)
end

function StoneOperationItemSettor:UpdateInfoMount(info, itemId, num, index)
    self.operation = 2
    self:UpdateInfo(info, itemId, num, index)
end

function StoneOperationItemSettor:UpdateInfoJump(info, itemId, num, index)
    self.operation = 3
    self:UpdateInfo(info, itemId, num, index)
end
