require "Core.Module.Common.Panel"

require "Core.Manager.Item.RechargRewardDataManager"

FirstRechargeAwardPanel = class("FirstRechargeAwardPanel", Panel);
function FirstRechargeAwardPanel:New()
    self = { };
    setmetatable(self, { __index = FirstRechargeAwardPanel });
    return self
end


function FirstRechargeAwardPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function FirstRechargeAwardPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._btnok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnok");

    self._btnokLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnok/Label");

    --self.hasGetAwardTip = UIUtil.GetChildByName(self._trsContent, "UILabel", "hasGetAwardTip");

    self.maxAwardNum = 5;

    self.cf = RechargRewardDataManager.GetListByType(RechargRewardDataManager.TYPE_FIRST_RECHARGE)

    for i = 1, self.maxAwardNum do
        self["product" .. i] = UIUtil.GetChildByName(self._trsContent, "Transform", "awards/product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    end

    self._trsFr1 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDesc/fr1");
    self._trsFr2 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDesc/fr2");

    self._careerWeapons = {};
    for k,v in pairs(PlayerManager.CareerType) do
        self._careerWeapons[v] = UIUtil.GetChildByName(self._trsFr1, "Transform", "trsWeapon/"..v);
    end

    MessageManager.AddListener(VIPManager, VIPManager.VipChange, FirstRechargeAwardPanel.VipDataChange, self);
    MessageManager.AddListener(FirstRechargeAwardProxy, FirstRechargeAwardProxy.MESSAGE_GETAWARD_COMPLETE, FirstRechargeAwardPanel.GetAwardComplete, self);

    self:VipDataChange();
    ModuleManager.SendNotification(FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGE_ALERT_PANEL);
end

function FirstRechargeAwardPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    self._onClickBtnok = function(go) self:_OnClickBtnok(self) end
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnok);
end

function FirstRechargeAwardPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGEAWARDPANEL);
end

function FirstRechargeAwardPanel:_OnClickBtnok()
    local flag = VIPManager.GetFirstStatus(); 
    if flag == 0  then
        --ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3 })
        ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
    elseif flag == 1  then
         FirstRechargeAwardProxy.TryGetFirstRechargeAward();
    end
end

function FirstRechargeAwardPanel:_Opened()
    
end

function FirstRechargeAwardPanel:GetAwardComplete()
    self:VipDataChange();
end

function FirstRechargeAwardPanel:VipDataChange()
    
    local flag = VIPManager.GetFirstStatus(); 

    local cfg = nil;
    local cfgId = 0;
    -- if flag < 2 then
        if not self.inited then
            self.inited  = true
            local kind = PlayerManager.GetPlayerKind();
            --kind = ({101000,102000,103000,104000 })[math.random (1,4)]
            for k,v in pairs(self._careerWeapons) do
                v.gameObject:SetActive(k == kind);
            end
            self._tPath = 'arm/' .. kind
            local t = UIUtil.GetChildByName(self._trsFr1, "UITexture", "trsWeapon/"..kind)
            t.mainTexture = UIUtil.GetTexture(self._tPath)
            self._effect = UIUtil.GetUIEffect("ui_" .. kind, t.transform, nil)
            UIUtil.ScaleParticleSystem(t.gameObject, true)
        end
        cfgId = 1;
        self._trsFr1.gameObject:SetActive(true);
        self._trsFr2.gameObject:SetActive(false);
    -- else
    --     cfgId = 1000;
    --     self._trsFr1.gameObject:SetActive(false);
    --     self._trsFr2.gameObject:SetActive(true);
    -- end

    for i, v in ipairs(self.cf) do
        if v.id == cfgId then
            cfg = v;
            break;
        end
    end


    self.awards = ConfigManager.Clone(cfg.reward);

    --新增职业奖励
    local cItem = TaskUtils.GetCareerAward(cfg.career_award);
    if cItem then
        table.insert(self.awards, 1, cItem);
    end

    for i = 1, self.maxAwardNum do
        --if self.awards[i] ~= nil then
            self["productCtr" .. i]:SetData(self.awards[i]);
        --end
    end

    log(flag)
    if flag == 0   then
        --未充值
        self._btnokLabel.text = LanguageMgr.Get("FirstRechargeAward/label/" .. flag);
    elseif flag == 1   then
        self._btnokLabel.text = LanguageMgr.Get("FirstRechargeAward/label/1");
    end

    --self.hasGetAwardTip.gameObject:SetActive(flag == 4);
    self._btnok.gameObject:SetActive(flag < 2);

end

function FirstRechargeAwardPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self._btnClose = nil;
    self._btnok = nil;

    self._btnokLabel = nil;

    self.hasGetAwardTip = nil;

    self.cf = nil;
    self.awards = nil;


    for i = 1, self.maxAwardNum do
        self["product" .. i] = nil;
        self["productCtr" .. i]:Dispose()
        self["productCtr" .. i] = nil;
    end
    if self._tPath then UIUtil.RecycleTexture(self._tPath) self._tPath = nil end
    Resourcer.Recycle(self._effect, false)
end

function FirstRechargeAwardPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    UIUtil.GetComponent(self._btnok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnok = nil;

    MessageManager.RemoveListener(VIPManager, VIPManager.VipChange, FirstRechargeAwardPanel.VipDataChange);
    MessageManager.RemoveListener(FirstRechargeAwardProxy, FirstRechargeAwardProxy.MESSAGE_GETAWARD_COMPLETE, FirstRechargeAwardPanel.GetAwardComplete);
end

function FirstRechargeAwardPanel:_DisposeReference()
    self._btnClose = nil;
    self._btnok = nil;
end
