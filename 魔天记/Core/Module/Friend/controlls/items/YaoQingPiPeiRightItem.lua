require "Core.Module.Common.UIItem"


YaoQingPiPeiRightItem = class("YaoQingPiPeiRightItem", UIItem);


YaoQingPiPeiRightItem.MESSAGE_YAOQINGPIPEIRIGHTITEM_SELECTED_CHANGE = "MESSAGE_YAOQINGPIPEIRIGHTITEM_SELECTED_CHANGE";

YaoQingPiPeiRightItem.currSelect = nil;

function YaoQingPiPeiRightItem:New()
    self = { };
    setmetatable(self, { __index = YaoQingPiPeiRightItem });
    return self
end
 

function YaoQingPiPeiRightItem:UpdateItem(data)
    self.data = data

     self:SetData(data)
end

function YaoQingPiPeiRightItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.lv_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "lv_txt");

    self:SetData(data)
end



function YaoQingPiPeiRightItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


-- { num = - 1 }
function YaoQingPiPeiRightItem:SetData(data)

    self.data = data;

    local num = data.num;

    if num == -1 then
        self.lv_txt.text = "";
    else
        self.lv_txt.text = GetLvDes1(num);
    end

end




function YaoQingPiPeiRightItem:_Dispose()



    self.gameObject = nil;


end