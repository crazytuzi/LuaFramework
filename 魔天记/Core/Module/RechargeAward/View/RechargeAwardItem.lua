require "Core.Module.Common.UIComponent"

local RechargeAwardItem = class("RechargeAwardItem",UIComponent);


function RechargeAwardItem:_Init()
	self:_InitReference();
	self:_InitListener();
end

function RechargeAwardItem:_InitReference()
	self._imgNum = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgNum");
	self._imgNum2 = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgNum2");
	self._imgNum3 = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgNum3");
	self._imgNum4 = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgNum4");
	self._btnok = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnok").gameObject;
	self._txtBtn = UIUtil.GetChildByName(self._btnok, "UILabel", "txtBtn");
    self.maxAwardNum = 5;
    self.cf = RechargRewardDataManager.GetListByType(RechargRewardDataManager.TYPE_FIRST_RECHARGE)
    for i = 1, self.maxAwardNum do
        self["product" .. i] = UIUtil.GetChildByName(self._gameObject, "Transform", "awards/product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end
end

function RechargeAwardItem:_InitListener()
	self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
	UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
	MessageManager.AddListener(RechargeAwardNotes, RechargeAwardNotes.RECHARGET_CHANGE
    , RechargeAwardItem._RechargetChange, self)
end

function RechargeAwardItem:SetConfig(c)
	SetNumForSprite({self._imgNum, self._imgNum2, self._imgNum3, self._imgNum4}, c.rewards_value)
    self.c = c
    self.id = c.id
    self:_SetState(RechargeAwardProxy.GetRechargeState(self.id))

    local awards = RechargeAwardProxy.GetRewards(c)
    for i = 1, self.maxAwardNum do
        --if self.awards[i] ~= nil then
            self["productCtr" .. i]:SetData(awards[i]);
        --end
    end    
end
function RechargeAwardItem:_SetState(s)
--Warning(tostring(self.st) ..'___' .. self.id .. '-' .. tostring(s))
    self.st = s --yyl:[{id:充值礼包id,s状态(0:可领取 1:已领取)}] nil未充值
    local str = ''
    if not s then
        str =  LanguageMgr.Get("RechargeAward/recharge",{ n = self.c.cost })
        if self.timeOver then self._btnok:SetActive(false) end
    elseif s == 0 then
        str = LanguageMgr.Get("FirstRechargeAward/label/1")
    elseif s == 1 then
        str = LanguageMgr.Get("RechargeAward/Geted")
        --self._btnok:SetActive(false)
    end
    self._txtBtn.text = str
end
function RechargeAwardItem:TimeClose()
    self.timeOver = true
    self:_SetState(self.st)
end


function RechargeAwardItem:_OnClickBtnok()
    --Warning(tostring(self.st))
	if self.st == 0 then
        RechargeAwardProxy.GetAward(self.id)
        --self:_SetState(1)
	    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	    self._onClickBtnok = nil;
    elseif not self.st then
      --  ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3, other = self.c.cost })
        ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3, other = self.c.cost});
    end
end
function RechargeAwardItem:_RechargetChange(d)
	if d.id == self.id then self:_SetState(d.s) end
end

function RechargeAwardItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
    for i = 1, self.maxAwardNum do
        self["product" .. i] = nil;
        self["productCtr" .. i]:Dispose()
        self["productCtr" .. i] = nil;
    end
end

function RechargeAwardItem:_DisposeListener()
	UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnok = nil;
	MessageManager.RemoveListener(RechargeAwardNotes, RechargeAwardNotes.RECHARGET_CHANGE
    , RechargeAwardItem._RechargetChange)
end

function RechargeAwardItem:_DisposeReference()
	self._btnok = nil;
	self._txtBtn = nil;
	self._imgNum = nil;
	self._imgNum2 = nil;
	self._imgNum3 = nil;
	self._imgNum4 = nil;
end
return RechargeAwardItem