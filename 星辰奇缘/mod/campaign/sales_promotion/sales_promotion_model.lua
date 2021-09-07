SalesPromotionModel = SalesPromotionModel or BaseClass(BaseModel)

function SalesPromotionModel:__init()
end

function SalesPromotionModel:__delete()
end

function SalesPromotionModel:SetData(data)
    if data ~= nil then
        self.item_id = data.item_id
        self.name = data.name
        self.price = data.price
        self.num = data.num
        self.rewardList = data.spec_effect
        self.title = data.content_name
        --self.present_id = data.present_id
        self.promotion = data.promotion
        self.purchased_num = data.purchased_num
    end
end