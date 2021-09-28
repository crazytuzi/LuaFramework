ZhongZhiCangKuProCtr = class("ZhongZhiCangKuProCtr");

ZhongZhiCangKuProCtr.currSelect = nil;

function ZhongZhiCangKuProCtr:New()
    self = { };
    setmetatable(self, { __index = ZhongZhiCangKuProCtr });
    return self
end


function ZhongZhiCangKuProCtr:Init(gameObject)
    self.gameObject = gameObject;


    self.bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "bg");
    self.select_bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "select_bg");

    self.pro_name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "pro_name_txt");
    self.pro_num_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "pro_num_txt");

    self.product1 = UIUtil.GetChildByName(self.gameObject, "Transform", "product1");

    self.productCtrs = ProductCtrl:New();
    self.productCtrs:Init(self.product1, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);
    self.productCtrs:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self.productCtrs._numLabel.gameObject:SetActive(false);

     self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
   
end

function ZhongZhiCangKuProCtr:_OnClickBtn()
  
  if ZhongZhiCangKuProCtr.currSelect ~= nil then
     ZhongZhiCangKuProCtr.currSelect.select_bg.gameObject:SetActive(false);
  end

  ZhongZhiCangKuProCtr.currSelect = self;
  ZhongZhiCangKuProCtr.currSelect.select_bg.gameObject:SetActive(true);

end

function ZhongZhiCangKuProCtr:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


function ZhongZhiCangKuProCtr:SetData(data)

    if data == nil then
        self:SetActive(false);
    else

        local spId = data.spId;
        local am = data.am;
        self.id = data.id;
       self.spId = data.spId;
       self.am = am;

        local products = ProductInfo:New();
        products:Init( { spId = spId + 0, am = 1 });
        self.productCtrs:SetData(products);

        self.pro_name_txt.text = products:GetName();
        self.pro_num_txt.text = LanguageMgr.Get("Yaoyuan/ZhongZhiCangKuProCtr/label1",{n=am}); --"数量:" .. am;

    end


end




function ZhongZhiCangKuProCtr:Dispose()
    
     UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self.gameObject = nil;


    self.bg =  nil;
    self.select_bg =  nil;

    self.pro_name_txt =  nil;
    self.pro_num_txt =  nil;

    self.product1 =  nil;

    self.productCtrs:Dispose()
    self.productCtrs =  nil;

end