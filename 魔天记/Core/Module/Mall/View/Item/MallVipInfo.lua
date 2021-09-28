require "Core.Module.Common.UIComponent"

local MallVipInfo = class("MallVipInfo", UIComponent);
function MallVipInfo:New(trs)
    self = { };
    setmetatable(self, { __index = MallVipInfo });
    if (trs) then  self:Init(trs)  end
    return self
end


function MallVipInfo:_Init()
    self:_InitReference();
    self:_InitListener();
end

function MallVipInfo:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
	self._txtDes = UIUtil.GetChildInComponents(txts, "txtDes");
    self._txtPress = UIUtil.GetChildInComponents(txts, "txtPress")
 	self._txtTime = UIUtil.GetChildInComponents(txts, "txtTime");
 	self._trsOver = UIUtil.GetChildByName(self._gameObject, "Transform", "trsOver");
 	self._trsUsed = UIUtil.GetChildByName(self._gameObject, "Transform", "trsUsed");
--    local ts = UIUtil.GetComponentsInChildren(self._gameObject, "UITexture")
--    self._imgPress = UIUtil.GetChildInComponents(ts, "imgPress")
 	self._slider = UIUtil.GetChildByName(self._gameObject, "UITexture", "vipPres/imgPress");
    MessageManager.AddListener(VIPManager, VIPManager.VipChange, MallVipInfo.InitData, self);
end

function MallVipInfo:InitData()
    local level = VIPManager.GetSelfVIPLevel()
    self._txtLevel.text = VIPManager.GetVIPShowLevel() .. ""
    --local nextMoney = VIPManager.GetNextLevelMoney(level)
    --if nextMoney > 0 then
    --if VIPManager.GetConfigByLevel(level + 1) then
        --local lim = VIPManager.GetMyNextLevelMoney()
        --self._txtDes.text = LanguageMgr.Get("Mall/Charge/again") .. lim .. LanguageMgr.Get("Mall/Charge/give")
        --self._txtLevel2.text = level + 1 .. ""
        --self._imgPress.fillAmount = (nextMoney - lim) / nextMoney
        --self._txtPress.text = (nextMoney - lim) .. "/" .. nextMoney
        local exp = math.floor(VIPManager.GetVIPExp() / 100)
        local nexp = math.floor(VIPManager.GetMyNextExp(VIPManager.GetSelfVIPLevel2()) / 100)
        if exp > nexp then exp = nexp end
        self._slider.fillAmount = exp / nexp
        self._txtPress.text = exp .. "/" .. nexp
    --else
        --self._imgPress.fillAmount = 1
       -- self._slider.fillAmount = 1
       -- self._txtPress.text = ""
        --UIUtil.GetChildByName(self._gameObject, "Transform", "trsNextVip").gameObject:SetActive(false)
        --UIUtil.GetChildByName(self._gameObject, "Transform", "txtfull").gameObject:SetActive(true)
    --end
    local dt = VIPManager.GetVIPDownTime()
    if dt > 0 then
        self._trsOver.gameObject:SetActive(false)
        self._trsUsed.gameObject:SetActive(true)
        if not self.timer then
            self.timer = Timer.New(function() self:UpdateTime() end, 1, -1)
            self.timer:Start()
        end
        self:UpdateTime()
    else
        self._trsOver.gameObject:SetActive(true)
        self._trsUsed.gameObject:SetActive(false)
    end
end
local FiveYear = 5 * 365 * 24 * 60 * 60 -- 5ÄêÎªÓÀ¾Ã
local ever = '[00ff00]' .. LanguageMgr.Get("time/permanent")
function MallVipInfo:UpdateTime()
    local dt = VIPManager.GetVIPDownTime()
    self._txtTime.text = dt >= FiveYear and ever or TimeTranslateSecond(dt, 10)
    if dt <= 0 then
        self.timer:Stop()
        self.timer = nil
        self:InitData()
    end
end

function MallVipInfo:_InitListener()
    
end

function MallVipInfo:_Dispose()
    MessageManager.RemoveListener(VIPManager, VIPManager.VipChange, MallVipInfo.InitData)
    --Warning(tostring(self.timer) .. tostring(self._txtTime))
    if self.timer then self.timer:Stop() self.timer = nil end
    self:_DisposeReference();
end

function MallVipInfo:_DisposeReference()
end

return MallVipInfo