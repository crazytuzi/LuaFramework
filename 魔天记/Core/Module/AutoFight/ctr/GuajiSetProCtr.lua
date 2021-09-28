require "Core.Manager.Item.EquipDataManager"

GuajiSetProCtr = class("GuajiSetProCtr");


-- 装备格子容器管理器

function GuajiSetProCtr:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function GuajiSetProCtr:Init(gameObject, type)

    self.gameObject = gameObject;
    self.type = type;

    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "lockedBg").gameObject;
    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self._numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");
    self._icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");

     self.ntipTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "ntipTxt");

    self:SetLock(false);
    self:Selected(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

end



function GuajiSetProCtr:Selected(v)
    self._icon_select.gameObject:SetActive(v);
end

function GuajiSetProCtr:SetLock(v)
    self.lock = v;
    self._lockedBg:SetActive(v);
end



function GuajiSetProCtr:SetProduct(productInfo)

    self._productInfo = productInfo;
    if self._productInfo ~= nil then

        ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());

        self._icon.gameObject:SetActive(true);

        local quality = self._productInfo:GetQuality();
       -- self._icon_quality.spriteName = ProductManager.GetQulitySpriteName(quality);
       self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
        self._icon_quality.gameObject:SetActive(true);

        local am = self._productInfo:GetAm();

        if am > 1 then
            self._numLabel.text = "" .. am;
        else
            self._numLabel.text = "";
        end

        if am <= 0 then
            ColorDataManager.SetGray(self._icon);
          --  ColorDataManager.SetGray(self._icon_quality);
             self.ntipTxt.gameObject:SetActive(true);
             self._numLabel.text = "[FF4B4B]0[-]";

        else
            ColorDataManager.UnSetGray(self._icon);
         --   ColorDataManager.UnSetGray(self._icon_quality);
            self.ntipTxt.gameObject:SetActive(false);

        end

        self:SetLock(false);

    else
        self._icon.gameObject:SetActive(false);
        self._numLabel.text = "";
        self._icon_quality.gameObject:SetActive(false);
        self.ntipTxt.gameObject:SetActive(false);
        self:SetLock(true);

    end

end

function GuajiSetProCtr:_OnClickBtn()
    
    if self._productInfo ~= nil then
       ModuleManager.SendNotification(AutoFightNotes.OPEN_AUTOUSEDRUGPANEL, {type=self.type,select_spId=self._productInfo.spId});
    else
      ModuleManager.SendNotification(AutoFightNotes.OPEN_AUTOUSEDRUGPANEL, {type=self.type});
    end 

   

end

function GuajiSetProCtr:Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickBtn = nil;

    self.gameObject = nil;
    self._lockedBg = nil;
    self._icon = nil;
    self._icon_quality = nil;
    self._numLabel = nil;
    self._icon_select = nil;

    self._selectHandler = nil;
end

