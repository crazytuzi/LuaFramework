require "Core.Module.Common.UIItem"

SubItem4Item = class("SubItem4Item", UIItem);



function SubItem4Item:New()
    self = { };
    setmetatable(self, { __index = SubItem4Item });
    return self
end


function SubItem4Item:_Init()

    self.hasdoIcon = UIUtil.GetChildByName(self.transform, "UISprite", "hasdoIcon");

    self.awardBt = UIUtil.GetChildByName(self.transform, "UIButton", "awardBt");
    self.titleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "titleTxt");
    self.elseRechargeTxt = UIUtil.GetChildByName(self.transform, "UILabel", "elseRechargeTxt");

    self.productMaxNum = 5;
    self.productTfs = { };
    self.productCtrs = { };

    for i = 1, self.productMaxNum do
        self.productTfs[i] = UIUtil.GetChildByName(self.transform, "Transform", "product" .. i);

        self.productCtrs[i] = ProductCtrl:New();
        self.productCtrs[i]:Init(self.productTfs[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
        self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
        self.productCtrs[i]:SetActive(false);
    end


    self._onClickAwardBt = function(go) self:_OnClickAwardBt() end
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAwardBt);


    self.hasdoIcon.gameObject:SetActive(false);
    self.awardBt.gameObject:SetActive(false);
    self.elseRechargeTxt.gameObject:SetActive(false);




    self:UpdateItem(self.data)
end 


function SubItem4Item:UpdateItem(data)
    self.data = data;

    self.titleTxt.text = LanguageMgr.Get("ActivityGifts/SubItem4Item/label1", { n = self.data.param2 });
    local rewards = self.data.reward;

    local reward_num = table.getn(rewards);
    for i = 1, reward_num do
        self.productCtrs[i]:SetData(rewards[i]);
        self.productCtrs[i]:SetActive(true);
    end


    local canGetAward = self.data.canGetAward;
    local hasGetAward = self.data.hasGetAward;

    local c = 0;
    local h = 0;

    if canGetAward then
        c = 1;
    end

    if hasGetAward then
        h = 1;
    end

    -- log("id " .. self.data.id .. " canGetAward" .. c .. " hasGetAward " .. h);
    self.elseRechargeTxt.gameObject:SetActive(false);

    if canGetAward and not hasGetAward then
        -- 可以领取奖励但还没领取
        self.hasdoIcon.gameObject:SetActive(false);
        self.awardBt.gameObject:SetActive(true);
        self.elseRechargeTxt.gameObject:SetActive(false);
    elseif hasGetAward then
        -- 可以领取奖励但已经领取
        self.hasdoIcon.gameObject:SetActive(true);
        self.awardBt.gameObject:SetActive(false);
        self.elseRechargeTxt.gameObject:SetActive(false);

    elseif not canGetAward then

        -- 不能领取
        local pre_id = self.data.id - 1;

        local obj = RechargRewardDataManager.GetListByTypeID(self.data.type, pre_id);
        
        if RechargRewardDataManager.total_recharge > 0 then

            if obj ~= nil then

                if obj.canGetAward then
                    self.hasdoIcon.gameObject:SetActive(false);
                    self.awardBt.gameObject:SetActive(false);
                    self.elseRechargeTxt.gameObject:SetActive(true);
                    self.elseRechargeTxt.text = RechargRewardDataManager.total_recharge .. "/" .. self.data.param2;
                    SubItem4Item.hasSetT = true;
                else
                
                    if not SubItem4Item.hasSetT and RechargRewardDataManager.total_recharge > 0 then

                        self.hasdoIcon.gameObject:SetActive(false);
                        self.awardBt.gameObject:SetActive(false);
                        self.elseRechargeTxt.gameObject:SetActive(true);
                        self.elseRechargeTxt.text = RechargRewardDataManager.total_recharge .. "/" .. self.data.param2;
                       
                        SubItem4Item.hasSetT = true;
                    else
                    end
                end

            elseif not SubItem4Item.hasSetT and  not hasGetAward and RechargRewardDataManager.total_recharge > 0 then

                self.hasdoIcon.gameObject:SetActive(false);
                self.awardBt.gameObject:SetActive(false);
                self.elseRechargeTxt.gameObject:SetActive(true);
                self.elseRechargeTxt.text = RechargRewardDataManager.total_recharge .. "/" .. self.data.param2;
                SubItem4Item.hasSetT = true;
            end

        end


    end



end


function SubItem4Item:DataChange()
    if (self.data) then

        local td = RechargRewardDataManager.GetListByTypeID(RechargRewardDataManager.TYPE_TOTAL_RECHARGE, self.data.id)
        self:UpdateItem(td);
    end

end

function SubItem4Item:_OnClickAwardBt()

    ActivityGiftsProxy.GetTotalRechageAward(self.data.id);
end

function SubItem4Item:_Dispose()


    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickAwardBt = nil;

    for i = 1, self.productMaxNum do

        self.productCtrs[i]:Dispose();
        self.productCtrs[i] = nil;
    end


    self.hasdoIcon = nil;

    self.awardBt = nil;
    self.titleTxt = nil;
    self.elseRechargeTxt = nil;


    self.productTfs = nil;
    self.productCtrs = nil;

    self._onClickAwardBt = nil;

end



 