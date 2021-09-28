ProductSelectCtrl = class("ProductSelectCtrl");

function ProductSelectCtrl:New()
    self = { };
    setmetatable(self, { __index = ProductSelectCtrl });
    return self
end


function ProductSelectCtrl:Init(gameObject)
    self.gameObject = gameObject;

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "quality");


    self.nametxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nametxt");
    self.leveltxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "leveltxt");
    self.typetxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "typetxt");
    self.desctxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "desctxt");

end


function ProductSelectCtrl:SetInfo(info)

    local procf = ProductManager.GetProductById(info.product_id);

    local quality = procf.quality;
    local icon_id = procf.icon_id;
    local lev = procf.req_lev;
    local desc = procf.desc;
    local type = procf.type;


    ProductManager.SetIconSprite(self.icon, icon_id);
   -- self.quality.spriteName = ProductManager.GetQulitySpriteName(quality);
     self.quality.color = ColorDataManager.GetColorByQuality(quality);
    self.nametxt.text = procf.name;
    self.leveltxt.text = LanguageMgr.Get("tshop/ProductSelectCtrl/lv") .. lev;
    self.typetxt.text = LanguageMgr.Get("tshop/ProductSelectCtrl/type") .. ProductInfo.GetPTypeName(type);
    self.desctxt.text = "" .. desc;

    
end



function ProductSelectCtrl:Dispose()

    self.gameObject = nil;

    self.icon  = nil;
    self.quality  = nil;


    self.nametxt  = nil;
    self.leveltxt  = nil;
    self.typetxt  = nil;
    self.desctxt  = nil;

end