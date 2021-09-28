require "Core.Module.Common.UIItem"

AttrItem = UIItem:New();
function AttrItem:_Init()
    self._txtDes = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtDes")
    self:UpdateItem(self.data);
end


function AttrItem:_Dispose()

end 

function AttrItem:UpdateItem(data)
    self.data = data
    if self.data then
        self._txtDes.text = self.data.des .. ": " .. self.data.property .. self.data.sign
    end
end

 

 
