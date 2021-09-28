require "Core.Module.Common.UIItem"

SubInLineItem = class("SubInLineItem", UIItem);

SubInLineItem.hasShowTime = false;

function SubInLineItem:New()
    self = { };
    setmetatable(self, { __index = SubInLineItem });
    return self
end


function SubInLineItem:_Init()

    self.hasdoIcon = UIUtil.GetChildByName(self.transform, "UISprite", "hasdoIcon");

    self.awardBt = UIUtil.GetChildByName(self.transform, "UIButton", "awardBt");
    self.titleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "titleTxt");
    self.valueTxt = UIUtil.GetChildByName(self.transform, "UILabel", "valueTxt");

    self.elseTimeTxe = UIUtil.GetChildByName(self.transform, "UILabel", "elseTimeTxe");

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
    self.elseTimeTxe.gameObject:SetActive(false);

    self.CanGetAward = false;


    self:UpdateItem(self.data)
end 

-- 修改方案  http://192.168.0.8:3000/issues/2792
function SubInLineItem:UpdateItem(data)
    self.data = data;

    self:StopTime();

    self.CanGetAward = false;

    if (self.data) then

        local rewards = self.data.rewards;
        local reward_num = table.getn(rewards);
        for i = 1, reward_num do
            self.productCtrs[i]:SetData(rewards[i]);
            self.productCtrs[i]:SetActive(true);
        end

        self.titleTxt.text = LanguageMgr.Get("SignIn/SubInLineItem/label2");
        self.valueTxt.text = "" .. self.data.online;

        local type = self.data.type;

        if type == OnlineRewardManager.TYPE_CAN_NOT_GET_AWARD then

            self.hasdoIcon.gameObject:SetActive(false);
            self.awardBt.gameObject:SetActive(false);
            self.elseTimeTxe.gameObject:SetActive(false);

        elseif type == OnlineRewardManager.TYPE_HAS_GET_AWARD then

            self.hasdoIcon.gameObject:SetActive(true);
            self.awardBt.gameObject:SetActive(false);
            self.elseTimeTxe.gameObject:SetActive(false);


        elseif type == OnlineRewardManager.TYPE_CAN_GET_AWARD then

            self.hasdoIcon.gameObject:SetActive(false);


            if self.data.elseTime > 0 then

                if not SubInLineItem.hasShowTime then

                    -- 需要倒计时
                    self.elseTimeTxe.gameObject:SetActive(true);
                    self.awardBt.gameObject:SetActive(false);
                    self:UpElseTime();

                    ---------------------------------------------------------------------------------
                    self._sec_timer = Timer.New( function()

                        self.data.elseTime = self.data.elseTime - 1;
                        self:UpElseTime();

                        if self.data.elseTime < 0 then

                            self.awardBt.gameObject:SetActive(true);
                            self.elseTimeTxe.gameObject:SetActive(false);

                            self:StopTime();

                            self.CanGetAward = true;
                            OnlineRewardManager.isCanGetInLineAward = true;
                            ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);

                             SignInProxy.TryGetInLineInfo();

                        end

                    end , 1, self.data.elseTime + 1, false);

                    self._sec_timer:Start();

                    SubInLineItem.hasShowTime = true;
                end


                -----------------------------------------------------------------------------------
            else
                -- 直接可以 领取奖励
                self.elseTimeTxe.gameObject:SetActive(false);
                self.awardBt.gameObject:SetActive(true);
                self.CanGetAward = true;
                OnlineRewardManager.isCanGetInLineAward = true;
                ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);
            end

        end


    end
end

function SubInLineItem:StopTime()
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
end


function SubInLineItem:UpElseTime()

    local timeStr = GetTimeByStr1(self.data.elseTime);

    self.elseTimeTxe.text = LanguageMgr.Get("SignIn/SubInLineItem/label1", { n = timeStr });

end


function SubInLineItem:DataChange()
    if (self.data) then

        local td = OnlineRewardManager.GetDataById(self.data.id);
        self:UpdateItem(td);
    end

end



function SubInLineItem:_OnClickAwardBt()

    SignInProxy.TryGetInLineAward(self.data.id)
end

function SubInLineItem:_Dispose()


    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickAwardBt = nil;

    for i = 1, self.productMaxNum do

        self.productCtrs[i]:Dispose();
        self.productCtrs[i] = nil;
        self.productTfs[i] = nil;
    end

    self:StopTime();


    self.hasdoIcon = nil;

    self.awardBt = nil;
    self.titleTxt = nil;
    self.elseTimeTxe = nil;


end



 