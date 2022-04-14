BuyMarketGoodsItem = BuyMarketGoodsItem or class("BuyMarketGoodsItem",BaseItem)
local BuyMarketGoodsItem = BuyMarketGoodsItem

function BuyMarketGoodsItem:ctor(parent_node,layer)
    self.abName = "market"
    self.assetName = "BuyMarketGoodsItem"
    self.layer = layer
    self.parentPanel = parent_node;
    self.Events = {}
    self.model = MarketModel:GetInstance()

    BuyMarketGoodsItem.super.Load(self)
end
function BuyMarketGoodsItem:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end
    GlobalEvent:RemoveTabListener(self.Events)
    if self.buyPanel then
        self.buyPanel:destroy()
    end
end

function BuyMarketGoodsItem:LoadCallBack()
    self.nodes =
    {
        "name",
        "scoreParent/score",
        "scoreParent/upArraw",
        "scoreParent/downArraw",
        "level",
        "unitPicImg/unitPic",
        "AllPicImg/allPic",
        "unitPicImg",
        "AllPicImg",
        "icon",
        "bg",
        "click",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.name = GetText(self.name)
    self.score = GetText(self.score)
    self.level = GetText(self.level)
    self.unitPic= GetText(self.unitPic)
    self.allPic = GetText(self.allPic)
    self.unitPicImg = GetImage(self.unitPicImg)
    self.AllPicImg = GetImage(self.AllPicImg)
   -- self.mBtn = GetButton(self.bg)
    self:InitUI()
    self:AddEvent()
    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.unitPicImg, iconName, true)
    GoodIconUtil:CreateIcon(self, self.AllPicImg, iconName, true)
end

function BuyMarketGoodsItem:SetData(data,type,isSearch)
    self.data = data
    local itemId = self.data.id
    if isSearch then
        self.type =  self.model:GetCanUpShelfItemByItemID(itemId).type
    else
        self.type = type
    end
    self.isSearch = isSearch
    self.uid = self.data.uid
    self.lv = Config.db_item[itemId].level
    self.pic = self.data.price
    self.totalPic = tonumber(self.pic)*tonumber(self.data.num)
    if self.is_loaded then
        self:InitUI()
    end
end
function BuyMarketGoodsItem:InitUI()
    local itemId = self.data.id
   -- logError(itemId)
    self.model:GetCanUpShelfItemByItemID(itemId)
    local colorNum = Config.db_item[itemId].color
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[itemId].name)
    self.name.text = str
    self.unitPic.text = self.data.price
    local all = tonumber(self.data.price) * tonumber(self.data.num)
    self.allPic.text = tostring(all)
    if  self.model:CheckIsEquip(self.type) then   --是装备
        self.level.text = Config.db_equip[itemId].order.."Stage"
        self.score.text = "Gear Ratings:"..self.data.score
        local putOnEquip = EquipModel.Instance:GetPutonEquipMap(self.data.id)
        if putOnEquip ~= nil then
            if putOnEquip.score > self.data.score then
                self:SetScore(false)
            else
                if putOnEquip.score == self.data.score then
                    self:SetScore(true,true)
                else
                    self:SetScore(true)
                end

            end
        else
            self:SetScore(true)
        end
        SetLocalPosition(self.name.transform,-210,12)
        SetVisible(self.score.gameObject,true)
    else
        local show = self.model:CheckIsShowOrder(self.type)
        if show == 1 then
            SetVisible(self.downArraw,false)
            SetVisible(self.upArraw,false)
            SetLocalPosition(self.name.transform,-210,-6)
            local showOrder = Config.db_pet[itemId].order_show
            if showOrder == 0 then
                self.level.text = "Events"
            else
                self.level.text = showOrder .."Stage"
            end

            SetVisible(self.score.gameObject,false)
        else
            SetVisible(self.downArraw,false)
            SetVisible(self.upArraw,false)
            SetLocalPosition(self.name.transform,-210,-6)
            self.level.text = Config.db_item[itemId].level.."Level"
            SetVisible(self.score.gameObject,false)
        end

    end
    self:CreateIcon()

end

function BuyMarketGoodsItem:SetScore(isUp,allHide)
    if allHide then
        SetVisible(self.upArraw,false)
        SetVisible(self.downArraw,false)
        return
    end
    if isUp then
        SetVisible(self.upArraw,true)
        SetVisible(self.downArraw,false)
    else
        SetVisible(self.downArraw,true)
        SetVisible(self.upArraw,false)
    end
    SetLocalPositionX(self.upArraw,self.score.preferredWidth)
    SetLocalPositionX(self.downArraw,self.score.preferredWidth)
end

function BuyMarketGoodsItem:AddEvent()
    local function call_back()
        self.model.selectGoodItem = self.data
        MarketController:GetInstance():RequeseGoodInfo(self.data.uid)
    end
    AddClickEvent(self.click.gameObject, call_back)

    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketBuyItemData, handler(self, self.BuyItemData))
     self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateGoodData, handler(self, self.UpdateGood)) --物品详情
     self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateTwoGoodData, handler(self, self.UpdateTwoGood)) --物品详情
     self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateThreeGoodData, handler(self, self.UpdateThreeGood)) --物品详情
end



function BuyMarketGoodsItem:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end

    local param = {}
    param["model"] = self.model
    param["item_id"] = self.data.id
    param["num"] = self.data.num
    param["bind"] = 2

    --宠物装备的配置表特殊处理
    local item_cfg = Config.db_item[self.data.id]
	if item_cfg and item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
		local cfg = Config.db_pet_equip[self.data.id .. "@" .. self.data.misc.stren_phase]
		param["cfg"] = cfg
	end


    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.data.id,self.data.num)
end

function BuyMarketGoodsItem:UpdateGood(data)
    if self.model.selectGoodItem == self.data then
        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["mType"] = 1
        param["isUp"] = false
        param["is_compare"] = true
        self.buyPanel = BuyMarketBuyPanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
end

function BuyMarketGoodsItem:UpdateTwoGood(data)
    if self.model.selectGoodItem == self.data then
        local bag = data.item.bag
        if bag == BagModel.Pet then --宠物
            local pos = self.transform.position
            local view = PetShowTipView()
            view:SetData(data.item,PetModel.TipType.buyMarket,pos,nil,nil)
            view:SetBuyInfo(data.item.id,data.item)
            return
        end

        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["mType"] = 1
        param["isUp"] = false
        self.buyPanel = BuyMarketBuyTowPanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
end

function BuyMarketGoodsItem:UpdateThreeGood(data)
    if self.model.selectGoodItem == self.data then
        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["mType"] = 1
        param["isUp"] = false
        param["is_compare"] = true
        self.buyPanel = BuyMarketBuyThreePanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
end


function BuyMarketGoodsItem:BuyItemData()
    if self.buyPanel then
        self.buyPanel:destroy()
    end
end