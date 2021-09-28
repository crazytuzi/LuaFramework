require "Core.Module.Common.UIItem"


YaoYuanLogItem = class("YaoYuanLogItem", UIItem);

function YaoYuanLogItem:New()
    self = { };
    setmetatable(self, { __index = YaoYuanLogItem });
    return self
end
 

function YaoYuanLogItem:UpdateItem(data)
    self.data = data
end

function YaoYuanLogItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.label = UIUtil.GetChildByName(self.gameObject, "UILabel", "label");

   self:SetData(data)

end




function YaoYuanLogItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function YaoYuanLogItem:SetData(data)

    self.data = data;
    local passTime = data.passTime;
   local taffter = GetAffterTimeByStr(passTime);
    self.label.text = "[ffc320]"..taffter.."[-] "..data.msg;

end


function YaoYuanLogItem:_Dispose()
    self.gameObject = nil;
     
    self.label = nil;


end