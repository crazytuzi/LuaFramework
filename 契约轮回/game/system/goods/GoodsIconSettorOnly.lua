--
-- @Author: chk
-- @Date:   2018-09-18 10:21:42
--
GoodsIconSettorOnly = GoodsIconSettorOnly or class("GoodsIconSettorOnly",BaseIconSettor)
local GoodsIconSettorOnly = GoodsIconSettorOnly

function GoodsIconSettorOnly:ctor(parent_node,layer)
	self.abName = "goods"
	self.assetName = "GoodsIcon"
	self.layer = layer

    GoodsIconSettorOnly.super.Load(self)
end

function GoodsIconSettorOnly:dctor()
end

function GoodsIconSettorOnly:LoadCallBack()
    GoodsIconSettorOnly.super.LoadCallBack(self)
end

function GoodsIconSettorOnly:AddEvent()

end

--itemId 物品配置表id
--num  数量
function GoodsIconSettorOnly:UpdateIconByItemId(itemId,num)
    if self.is_loaded then
        self.need_load_end = false

        local _config = Config.db_item[itemId]
        if _config ~= nil then
            self:UpdateIconImage(_config.icon)
            self:UpdateQuality(_config.color)
            if _config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                local equipConfig = Config.db_equip[itemId]

                if equipConfig ~= nil then
                    self:UpdateStar(equipConfig.star)
                    self:UpdateStep(equipConfig.order)
                end
            else
                self:UpdateNum(num)
                SetVisible(self.starContain,false)
            end
        end

        self.need_load_end = false
    else
        --self.detailViewContain = detailViewContain
        --self.clickEvent = ClickGoodsIconEvent.Click.DIRECT_SHOW_CFG
        self.itemId = itemId
        self.num = num
        self.need_load_end = true
    end
end
