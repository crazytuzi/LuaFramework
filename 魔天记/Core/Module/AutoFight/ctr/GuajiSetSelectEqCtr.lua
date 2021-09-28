require "Core.Manager.Item.EquipDataManager"

GuajiSetSelectEqCtr = class("GuajiSetSelectEqCtr");
-- 装备格子容器管理器

function GuajiSetSelectEqCtr:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function GuajiSetSelectEqCtr:Init(gameObject)

    self.gameObject = gameObject

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self.lockedBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "lockedBg");

    self.eqNameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "eqNameTxt");
    self.qianghuaTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "qianghuaTxt");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

end



function GuajiSetSelectEqCtr:SetProduct(productInfo)

    self._productInfo = productInfo;
    if self._productInfo ~= nil then

        ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());
        self._icon.gameObject:SetActive(true);

        local quality = self._productInfo:GetQuality();

        self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);

        self._icon_quality.gameObject:SetActive(true);


        self.eqNameTxt.text = ColorDataManager.GetColorTextByQuality(quality, self._productInfo:GetName()) ;
        self.qianghuaTxt.text = LanguageMgr.Get("AutoFight/GuajiSetSelectEqCtr/label1") .. self._productInfo.slv;

        self.lockedBg.gameObject:SetActive(false);

    else
        self._icon.gameObject:SetActive(false);
        self.eqNameTxt.text = "";
        self.qianghuaTxt.text = "";
        self._icon_quality.gameObject:SetActive(false);
        self.lockedBg.gameObject:SetActive(true);


    end

end



function GuajiSetSelectEqCtr:_OnClickBtn()

    ModuleManager.SendNotification(AutoFightNotes.OPEN_AUTOFIGHTEQSETPANEL);

end


function GuajiSetSelectEqCtr:Dispose()

    if self._onClickBtn ~= nil then

        UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClickBtn = nil;
    end

     self.gameObject = nil;

    self._icon = nil;
    self._icon_quality = nil;
    self.lockedBg = nil;

    self.eqNameTxt = nil;
    self.qianghuaTxt = nil;

    self._onClickBtn =nil;

end