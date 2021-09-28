require "Core.Module.Common.UIItem"


ProductDressPanelItem = UIItem:New();
ProductDressPanelItem.index = 1;
 
function ProductDressPanelItem:UpdateItem(data)
    self.data = data
    self:SetData(data);
end

function ProductDressPanelItem:Init(gameObject, data)

    self.data = data
    self.gameObject = gameObject
    self.index = ProductDressPanelItem.index;
    ProductDressPanelItem.index = ProductDressPanelItem.index + 1;


    self.eqPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "eqPanel");
    self.eq_name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "eq_name_txt");

    self._gettoGet_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "gettoGet_bt");


    self.eqPanelControll = EquipPanelCtrl:New();
    self.eqPanelControll:Init(self.eqPanel.gameObject, 1, { iconType = ProductCtrl.IconType_rectangle });


    self._gettoGet_btHandler = function(go) self:_GettoGet_btHandler(self) end
    UIUtil.GetComponent(self._gettoGet_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._gettoGet_btHandler);

    self:UpdateItem(data);
end



function ProductDressPanelItem:SetData(infoData)

    self.infoData = infoData;
    self.eqPanelControll:SetProduct(infoData);
    -- self.eq_name_txt.text = infoData:GetName();

    local quality = infoData:GetQuality();
    self.eq_name_txt.text = ColorDataManager.GetColorTextByQuality(quality, infoData:GetName());

    self.gameObject.gameObject:SetActive(true);

end
   
function ProductDressPanelItem:_GettoGet_btHandler()


    local pid = HeroController.GetInstance().id;
    local info = self.infoData;
    local p = { };
    p.id1 = info:GetId();
    p.pt1 = pid;
    p.st1 = info:GetSt();

    -- 需要寻找对应的装备栏容器
    local kind = info:GetKind();
    local targetPro = EquipDataManager.GetProductByKind(kind);
    --

    p.id2 = nil;
    if targetPro ~= nil then
        p.id2 = targetPro:GetId();
    end

    p.pt2 = pid;
    p.st2 = ProductManager.ST_TYPE_IN_EQUIPBAG;
    p.idx = kind - 1;

    EquipProxy.TryMove_Product(p, ProductDressPanelItem.index)
    SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_DRESS)
end


function ProductDressPanelItem:SetActive(v)
    self.gameObject:SetActive(v);
end

function ProductDressPanelItem:_Dispose()
    self.gameObject = nil;
    self.data = nil;


    self.eqPanel = nil;
    self.eq_name_txt = nil;

    self.eqPanelControll:Dispose()
    self.eqPanelControll = nil;


    UIUtil.GetComponent(self._gettoGet_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._gettoGet_bt = nil;
    self._gettoGet_btHandler = nil;

end