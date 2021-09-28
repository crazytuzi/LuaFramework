require "Core.Module.Common.UIItem"


ProductGetMsgPanelItem = UIItem:New();
 
function ProductGetMsgPanelItem:UpdateItem(data)
    self.data = data
end

function ProductGetMsgPanelItem:Init(gameObject, data)

    self.data = data
    self.gameObject = gameObject
    self:UpdateItem(self.data);
    self._gettoGet_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "gettoGet_bt");

    self:SetData(data);
    self._gettoGet_btHandler = function(go) self:_GettoGet_btHandler(self) end
    UIUtil.GetComponent(self._gettoGet_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._gettoGet_btHandler);

end


function ProductGetMsgPanelItem:SetData(infoData)


    local drassLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "drassLabel");

  
    drassLabel.text =  infoData.label1.. "[77ff47]"..infoData.label2.."[-]";

    local btLabel = UIUtil.GetChildByName(self._gettoGet_bt, "UILabel", "Label");
    btLabel.text = infoData.buttonLabel;
end


function ProductGetMsgPanelItem:_GettoGet_btHandler()

end

function ProductGetMsgPanelItem:_Dispose()
    self.gameObject = nil;
    self.data = nil;
    
    UIUtil.GetComponent(self._gettoGet_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._gettoGet_bt = nil;
    self._gettoGet_btHandler = nil;

end