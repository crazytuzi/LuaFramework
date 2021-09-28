require "Core.Module.Common.UIItem"

SubSevenDayItem = class("SubSevenDayItem", UIItem);



function SubSevenDayItem:New()
    self = { };
    setmetatable(self, { __index = SubSevenDayItem });
    return self
end


function SubSevenDayItem:_Init()


    self.hasdoIcon = UIUtil.GetChildByName(self.transform, "UISprite", "hasdoIcon");

    self.awardBt = UIUtil.GetChildByName(self.transform, "UIButton", "awardBt");

    self.lvtxt = UIUtil.GetChildByName(self.transform, "UILabel", "lvtxt");
    self.lvtxt_gray = UIUtil.GetChildByName(self.transform, "UILabel", "lvtxt_gray");

    self.lvtip = UIUtil.GetChildByName(self.transform, "UISprite", "lvtip");

    self.productMaxNum = 4;
    self.productTfs = { };
    self.productCtrs = { };

    for i = 1, self.productMaxNum do
        self.productTfs[i] = UIUtil.GetChildByName(self.transform, "Transform", "product" .. i);

        self.productCtrs[i] = ProductCtrl:New();
        self.productCtrs[i]:Init(self.productTfs[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
        self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
        self.productCtrs[i]:SetActive(false);

    end

    self.hasdoIcon.gameObject:SetActive(false);
    self.awardBt.gameObject:SetActive(false);


    self._onClickAwardBt = function(go) self:_OnClickAwardBt() end
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAwardBt);


    self:UpdateItem(self.data)
end 

--[[
['id'] = 7,
		['req_lev'] = 52,
		['days'] = 10,
		['reward'] = {'500001_1','500002_1'}
]]
function SubSevenDayItem:UpdateItem(data)
    self.data = data;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    self.lvtxt.text = LanguageMgr.Get("SignIn/SubSevenDayItem/label1", { n = self.data.req_lev });
    self.lvtxt_gray.text = LanguageMgr.Get("SignIn/SubSevenDayItem/label1", { n = self.data.req_lev });

    if my_lv >= self.data.req_lev then


        ColorDataManager.UnSetGray(self.lvtip);

        self.lvtxt.gameObject:SetActive(true);
        self.lvtxt_gray.gameObject:SetActive(false);

    else

        self.lvtxt.gameObject:SetActive(false);
        self.lvtxt_gray.gameObject:SetActive(true);

        ColorDataManager.SetGray(self.lvtip);

    end



    local reward = self.data.reward;
    local reward_num = table.getn(reward);

    for i = 1, self.productMaxNum do
        self.productCtrs[i]:SetActive(false);
    end

    for i = 1, reward_num do
        local arr = ConfigSplit(reward[i]);
        local id = tonumber(arr[1]);
        local num = tonumber(arr[2]);

        local info = ProductInfo:New();
        info:Init( { spId = id, am = num });

        self.productCtrs[i]:SetData(info);
        self.productCtrs[i]:SetActive(true);
    end

    self:SetState();
end


SubSevenDayItem.needTip = false;

function SubSevenDayItem:SetState()


    if self.data ~= nil then
        local f = self.data.f;

        if f == 0 then
            self.hasdoIcon.gameObject:SetActive(false);
            self.awardBt.gameObject:SetActive(false);

        elseif f == 1 then
            self.hasdoIcon.gameObject:SetActive(false);
            self.awardBt.gameObject:SetActive(true);
            SubSevenDayItem.needTip = true;

        elseif f == 2 then
            self.hasdoIcon.gameObject:SetActive(true);
            self.awardBt.gameObject:SetActive(false);
        end

    end

end

function SubSevenDayItem:_OnClickAwardBt()

    SignInProxy.GetChongJiAwards(self.data.id);
end



function SubSevenDayItem:_Dispose()

    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickAwardBt = nil;

    for i = 1, self.productMaxNum do
        self.productCtrs[i]:Dispose();
    end

end



 