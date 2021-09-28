

GiftItem = class("GiftItem");

function GiftItem:New()
    self = { };
    setmetatable(self, { __index = GiftItem });
    return self
end


function GiftItem:Init(gameObject, index)
    self.gameObject = gameObject;
    self.index = index;

    self.box = UIUtil.GetChildByName(self.gameObject, "Transform", "box");
    self.boxIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "box");

    self.hasGetIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "hasGetIcon");

    self.efIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "efIcon");
    self.starNumTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "starNumTxt");

    self.hasGetIcon.gameObject:SetActive(false);

    self._onbox = function(go) self:_Onbox(self) end
    UIUtil.GetComponent(self.box, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onbox);

end


function GiftItem:_Onbox()

    local getobj = { index = self.index, t = self.fb_type, k = self.fb_kind };

    ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCEAWARDPANEL, { id = self.box_id, star = self.star_num, doType = self.doType, getobj = getobj });
end

-- 12_502001
function GiftItem:SetData(data, fb_type, fb_kind, starTotal)

  

    local info = string.split(data, "_");

    self.star_num = info[1] + 0;
    self.box_id = info[2] + 0;

    self.fb_type = fb_type;
    self.fb_kind = fb_kind;
    self.starTotal = starTotal;

    local boxinfo = ProductManager.GetProductById(self.box_id);

    ProductManager.SetIconSprite(self.boxIcon, boxinfo.icon_id);

    self.starNumTxt.text = "X" .. self.star_num;

     self.hasGetIcon.gameObject:SetActive(false);
     ColorDataManager.UnSetGray(self.boxIcon);


    if self.star_num <= self.starTotal then

        local hasGet = InstanceDataManager.GetHasGetBoxLog(fb_type, fb_kind, self.index);

        if hasGet then
            self.efIcon.gameObject:SetActive(false);
            self.doType = InstanceAwardPanel.doType_3;
            -- 已经获取了
            ProductManager.SetIconSprite(self.boxIcon, boxinfo.icon_id .. "_1");

             self.hasGetIcon.gameObject:SetActive(true);

        else
            self.efIcon.gameObject:SetActive(true);
            self.doType = InstanceAwardPanel.doType_1;
            -- 可以获取
        end

    else
        self.efIcon.gameObject:SetActive(false);
        self.doType = InstanceAwardPanel.doType_2;

        ColorDataManager.SetGray(self.boxIcon);
        -- 不可以获取
    end


end

function GiftItem:Show()


    self.gameObject.gameObject:SetActive(true);
end

function GiftItem:Hide()


    self.gameObject.gameObject:SetActive(false);
end

function GiftItem:Dispose()

    UIUtil.GetComponent(self.box, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onbox = nil;


    self.gameObject = nil;
    self.index = nil;

    self.box = nil;
    self.boxIcon = nil;

    self.efIcon = nil;
    self.starNumTxt = nil;

end