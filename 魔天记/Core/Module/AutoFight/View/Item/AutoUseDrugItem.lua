require "Core.Module.Common.UIItem"


AutoUseDrugItem = class("AutoUseDrugItem", UIItem);
AutoUseDrugItem.currSelect = nil;

AutoUseDrugItem.MESSAGE_PRODUCTS_SELECTED_CHANGE = "MESSAGE_PRODUCTS_SELECTED_CHANGE";

function AutoUseDrugItem:New()
    self = { };
    setmetatable(self, { __index = AutoUseDrugItem });
    return self
end
 

function AutoUseDrugItem:UpdateItem(data)
    self.data = data
end

function AutoUseDrugItem:Init(gameObject, data)

    self.gameObject = gameObject;


    self.nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameTxt");
    self.decTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "decTxt");


    self.select_bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "select_bg");

    self.product = UIUtil.GetChildByName(self.gameObject, "Transform", "product");
    self.ntipTxt = UIUtil.GetChildByName(self.product, "UILabel", "ntipTxt");

    self.productCtrs = ProductCtrl:New();
    self.productCtrs:Init(self.product, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);



    self._onClickBt = function(go) self:_OnClickBt(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBt);


    -- 数量不足
    self.select_bg.gameObject:SetActive(false);

    self:SetActive(true);
    self:SetData(data);

    self.productCtrs:SetOnClickBtnHandler(nil)
    self.productCtrs:SetOnClickCallBack(AutoUseDrugItem._OnClickproductCtrs, self)

end

function AutoUseDrugItem:_OnClickproductCtrs(info)

    self:_OnClickBt();

end

function AutoUseDrugItem:_OnClickBt()

    if AutoUseDrugItem.currSelect ~= self then

        if AutoUseDrugItem.currSelect ~= nil then
            AutoUseDrugItem.currSelect.select_bg.gameObject:SetActive(false);
        end

        AutoUseDrugItem.currSelect = self;
        AutoUseDrugItem.currSelect.select_bg.gameObject:SetActive(true);
    end

    MessageManager.Dispatch(AutoUseDrugItem, AutoUseDrugItem.MESSAGE_PRODUCTS_SELECTED_CHANGE, self.data);

    SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_USE_DRUG, self.data);

    ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOUSEDRUGPANEL);
    
end


function AutoUseDrugItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function AutoUseDrugItem:SetData(data)

    self.data = data;

    local id = data.id;


    -- 需要 从背包中 获取 对应的 物品数量
    self.data.has_num = BackpackDataManager.GetProductTotalNumBySpid(id);

    self.pro_obj = ProductManager.GetProductInfoById(id, self.data.has_num);

    local q = self.pro_obj:GetQuality();

    self.nameTxt.text = ColorDataManager.GetColorTextByQuality(q, self.pro_obj:GetName());
    self.decTxt.text = self.pro_obj:GetDesc();

    self.productCtrs:SetData(self.pro_obj);

    if self.data.has_num <= 0 then
        ColorDataManager.SetGray(self.productCtrs._icon);
       -- ColorDataManager.SetGray(self.productCtrs._icon_quality);
        self.ntipTxt.gameObject:SetActive(true);
        self.productCtrs._numLabel.text = "[FF4B4B]0[-]"
    else
        self.ntipTxt.gameObject:SetActive(false);
    end

    if data.order == 0 then

        AutoUseDrugItem.currSelect = self;
        AutoUseDrugItem.currSelect.select_bg.gameObject:SetActive(true);
    elseif data.select_spId == id then
       self.select_bg.gameObject:SetActive(true);
    end 

end



function AutoUseDrugItem:_Dispose()

    self.productCtrs:Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBt = nil;

    self.gameObject = nil;


    self.nameTxt = nil;
    self.decTxt = nil;

    self.select_bg = nil;

    self.product = nil;
    self.ntipTxt = nil;

    self.productCtrs = nil;


end