-- --------------------------------------------------------------------
-- 
-- 
-- @author: liwenchuagn@syg.com(必填, 创建模块的人员)
-- @editor: liwenchuang@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      召唤卷列表item
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PartnerSummonGoods = class("PartnerSummonGoods",function ()
    return  ccui.Widget:create()
end)

PartnerSummonGoods.HEIGHT = 46
PartnerSummonGoods.WIDTH = 140

function PartnerSummonGoods:ctor(index)
    self.index = index or 0
    self.size = cc.size(PartnerSummonGoods.WIDTH,PartnerSummonGoods.HEIGHT)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("partnersummon/partnersummon_goods"))
    self:addChild(self.root_wnd)
    self.item_icon_common = self.root_wnd:getChildByName("item_icon_common")    
    self.common_num_label = self.root_wnd:getChildByName("common_num_label")

    self.touch_container = self.root_wnd:getChildByName("touch_container")
    self.touch_container:setSwallowTouches(false)
    self:registerEvent()
end


function PartnerSummonGoods:registerEvent()
    self.touch_container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.item_id then
                TipsManager:getInstance():showGoodsTips(self.item_id)
            end
        end
    end)
end

function PartnerSummonGoods:setData(i,item_id)
    if item_id then
        self.item_id = item_id
        self.index = i
        local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_id)
        local icon = Config.ItemData.data_get_data(item_id).icon
        self.item_icon_common:loadTexture(PathTool.getItemRes(icon), LOADTEXT_TYPE)
        self.common_num_label:setString(num)
    end
end

--删掉的时候关闭
function PartnerSummonGoods:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
