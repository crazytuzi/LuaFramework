require "Core.Module.Common.UIItem"

SubLogin7RewardItem = class("SubLogin7RewardItem", UIItem);

SubLogin7RewardItem.MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE = "MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE";

SubLogin7RewardItem.currselect = nil;


function SubLogin7RewardItem:New()
    self = { };
    setmetatable(self, { __index = SubLogin7RewardItem });
    return self
end


function SubLogin7RewardItem:_Init()

    self.titleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "titleTxt");
    self.proNameTxt = UIUtil.GetChildByName(self.transform, "UILabel", "proNameTxt");

    self.product = UIUtil.GetChildByName(self.transform, "Transform", "product");

    self.bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self.select_bg = UIUtil.GetChildByName(self.transform, "Transform", "select_bg");
    self.tipIcon = UIUtil.GetChildByName(self.transform, "Transform", "tipIcon");

    self.productCtr = ProductCtrl:New();
    self.productCtr:Init(self.product, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)


    self.enterFrameRun = EnterFrameRun:New();

    self:UpdateItem(self.data);

    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self.transform.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self.select_bg.gameObject:SetActive(false);
    self.tipIcon.gameObject:SetActive(false);

end 


function SubLogin7RewardItem:UpdateItem(data)
    self.data = data;

    local nb = GetNumByCh(self.data.id);
    self.titleTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardItem/label1", { n = nb });

    self.bg.spriteName = "bg" .. self.data.base_map;


    local info = data.show;

    self.productCtr:SetData(info);

    local quality = info:GetQuality();
    self.proNameTxt.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName());

end

function SubLogin7RewardItem:UpInfo()

    self.data = Login7RewardManager.GetDataByIndex(self.data.id);

    local canGetAward = self.data.canGetAward;
    local hasGetAward = self.data.hasGetAward;

    if canGetAward and not hasGetAward then
        self.tipIcon.gameObject:SetActive(true);
    else
        self.tipIcon.gameObject:SetActive(false);
    end

end

function SubLogin7RewardItem:_OnClick()

    if SubLogin7RewardItem.currselect ~= nil then
        SubLogin7RewardItem.currselect:ChangeSample();
    end

    SubLogin7RewardItem.currselect = self;
    SubLogin7RewardItem.currselect:ChangeBig();

    MessageManager.Dispatch(SubLogin7RewardItem, SubLogin7RewardItem.MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE, self.data);
end


function SubLogin7RewardItem:ChangeBig()

    self:CreanEnterFramer();
    self.select_bg.gameObject:SetActive(true);

    self.enterFrameRun:AddHandler(SubLogin7RewardItem.ChangeSc, self, 1, { sc = 1.10 });
    self.enterFrameRun:AddHandler(SubLogin7RewardItem.ChangeSc, self, 1, { sc = 1.20 });

    self.enterFrameRun:Start()

end


function SubLogin7RewardItem:ChangeSample()

    self:CreanEnterFramer();
    self.select_bg.gameObject:SetActive(false);

    self.enterFrameRun:AddHandler(SubLogin7RewardItem.ChangeSc, self, 1, { sc = 1.10 });
    self.enterFrameRun:AddHandler(SubLogin7RewardItem.ChangeSc, self, 1, { sc = 1.00 });

    self.enterFrameRun:Start()

end

function SubLogin7RewardItem:ChangeSc(data)


    local sc = data.sc;
    self.bg.transform.localScale = Vector3.New(sc, sc, 1);
    self.select_bg.transform.localScale = Vector3.New(sc, sc, 1);


end


function SubLogin7RewardItem:CreanEnterFramer()
    self.enterFrameRun:Stop();
    self.enterFrameRun:Clean()
end

function SubLogin7RewardItem:_Dispose()

    UIUtil.GetComponent(self.transform.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;

    self.productCtr:Dispose();

    self:CreanEnterFramer();
    self.enterFrameRun = nil;
    SubLogin7RewardItem.currselect = nil;


    self.titleTxt = nil;
    self.proNameTxt = nil;

    self.product = nil;

    self.bg = nil;
    self.select_bg = nil;
    self.tipIcon = nil;

    self.productCtr = nil;

end



 