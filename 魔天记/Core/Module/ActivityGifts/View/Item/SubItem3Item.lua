require "Core.Module.Common.UIItem"

SubItem3Item = class("SubItem3Item", UIItem);



function SubItem3Item:New()
    self = { };
    setmetatable(self, { __index = SubItem3Item });
    return self
end


function SubItem3Item:_Init()

    



    self:UpdateItem(self.data)
end 


function SubItem3Item:UpdateItem(data)
    self.data = data;

   





end




function SubItem3Item:_Dispose()


  

end



 