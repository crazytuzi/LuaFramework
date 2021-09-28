require "Core.Manager.Item.EquipDataManager"

GuajiSetEqCtr = class("GuajiSetEqCtr");
-- 装备格子容器管理器
GuajiSetEqCtr.currSelected = nil;

GuajiSetEqCtr.MESSAGE_GJEQ_SELECTED_CHANGE = "MESSAGE_GJEQ_SELECTED_CHANGE";

function GuajiSetEqCtr:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function GuajiSetEqCtr:Init(gameObject, i)

    self.gameObject = gameObject
    self.kind = i;

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self.icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");

    self.numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");
    self.nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameTxt");


    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


    self.icon_select.gameObject:SetActive(false);

    self:UpData()

end


function GuajiSetEqCtr:UpData()
    self.equip_lv_data = EquipLvDataManager.getItem(self.kind);
    self.slv = self.equip_lv_data["slv"];

    local productInfo = EquipDataManager.GetProductByIdx(self.equip_lv_data.idx - 1);
    if productInfo ~= nil then
        productInfo.slv = self.slv;
    end

    self:SetProduct(productInfo);


    -- 检测 默认选择 对象

    if self.kind == AutoFightManager.strengthen_eq_kind then

        GuajiSetEqCtr.currSelected = self;
        GuajiSetEqCtr.currSelected.icon_select.gameObject:SetActive(true);

    end

end


function GuajiSetEqCtr:SetProduct(productInfo)

    self._productInfo = productInfo;
    if self._productInfo ~= nil then

        ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());
        self._icon.gameObject:SetActive(true);

        local quality = self._productInfo:GetQuality();

        self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);

        self._icon_quality.gameObject:SetActive(true);

        self.numLabel.text = "" .. self._productInfo.slv;


        self.nameTxt.text = ColorDataManager.GetColorTextByQuality(quality, self._productInfo:GetName());
    else
        self._icon.gameObject:SetActive(false);
        self.numLabel.text = "";
        self.nameTxt.text = "";
        self._icon_quality.gameObject:SetActive(false);

    end

end


function GuajiSetEqCtr:_OnClickBtn()

    SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_STRENGTH_EQ_SELECT, self.kind);

    if self._productInfo ~= nil then
        if GuajiSetEqCtr.currSelected ~= nil then

            GuajiSetEqCtr.currSelected.icon_select.gameObject:SetActive(false);
        end
        GuajiSetEqCtr.currSelected = self;
        GuajiSetEqCtr.currSelected.icon_select.gameObject:SetActive(true);

        MessageManager.Dispatch(GuajiSetEqCtr, GuajiSetEqCtr.MESSAGE_GJEQ_SELECTED_CHANGE, self._productInfo);

        ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTEQSETPANEL);
    end

end

function GuajiSetEqCtr:Dispose()

    if self._onClickBtn ~= nil then

        UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClickBtn = nil;
    end


    self.gameObject = nil;
    self.kind = nil;

    self._icon = nil;
    self._icon_quality = nil;
    self.icon_select = nil;

    self.numLabel = nil;
    self.nameTxt = nil;


    self._onClickBtn = nil;


end