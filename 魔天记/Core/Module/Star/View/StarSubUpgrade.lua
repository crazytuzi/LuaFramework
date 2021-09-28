require "Core.Module.Common.UIComponent"

local StarSubUpgrade = class("StarSubUpgrade",UIComponent);
local PosMin = 0
local PosMax = 7
function StarSubUpgrade:New(trs)
	self = { };
	setmetatable(self, { __index =StarSubUpgrade });
    if trs then self:Init(trs) end
	return self
end


function StarSubUpgrade:_Init()
	self:_InitReference();
	self:_InitListener();
end

function StarSubUpgrade:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtNextStar = UIUtil.GetChildInComponents(txts, "txtNextStar");
	self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
	self._txtAtts = UIUtil.GetChildInComponents(txts, "txtAtts");
	self._txtUpgradeAtts = UIUtil.GetChildInComponents(txts, "txtUpgradeAtts");
	self._txtUpgradeNeed = UIUtil.GetChildInComponents(txts, "txtUpgradeNeed");
	self._txtFight = UIUtil.GetChildInComponents(txts, "txtFight");
	local imgs = UIUtil.GetComponentsInChildren(self._gameObject, "UISprite");
	self._imgQuality = UIUtil.GetChildInComponents(imgs, "imgQuality");
	self._imgIcon = UIUtil.GetChildInComponents(imgs, "imgIcon");
	self._imgChangeTip = UIUtil.GetChildInComponents(imgs, "imgChangeTip");
	self._imgUpgradeTip = UIUtil.GetChildInComponents(imgs, "imgUpgradeTip");
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UIButton");
	self._btnChange = UIUtil.GetChildInComponents(btns, "btnChange");
	self._btnUpgrade = UIUtil.GetChildInComponents(btns, "btnUpgrade");
	self._trsLelf = UIUtil.GetChildByName(self._gameObject, "Transform", "trsLelf");
	self._trsNoSelect = UIUtil.GetChildByName(self._gameObject, "Transform", "trsNoSelect");
	self._trsFullPos = UIUtil.GetChildByName(self._gameObject, "Transform", "trsFullPos");
	self._btnShow = UIUtil.GetChildByName(self._gameObject, "UITexture", "btnShow");
	self._btnGoStar = UIUtil.GetChildInComponents(btns, "btnGoStar");
	self._trsUpgradeEff = UIUtil.GetChildByName(self._gameObject, "Transform", "stars/trsUpgradeEff").gameObject;
    self:InitStars()
end

function StarSubUpgrade:InitStars()
    self.items = {}
    for i = PosMin, PosMax do
        local itemTrs = UIUtil.GetChildByName(self._gameObject, "Transform", "stars/item" .. (i + 1))
        local item = ProductCtrl:New()
        item:Init(itemTrs,{ hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_circle})
        item:SetOnClickBtnHandler(ProductCtrl.TYPE_NONE)
        item:SetOnClickCallBack(StarSubUpgrade._OnItemsClick,self)
        item:SetNotProductClickHander(StarSubUpgrade._OnNotItemsClick,self)
        item.starIdx = i
        table.insert(self.items, item)
    end
end

function StarSubUpgrade:_InitListener()
	self:_AddBtnListen(self._btnChange.gameObject)
	self:_AddBtnListen(self._btnUpgrade.gameObject)
	self:_AddBtnListen(self._btnShow.gameObject)
	self:_AddBtnListen(self._btnGoStar.gameObject)
    MessageManager.AddListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubUpgrade.UpdatePanel, self)
    MessageManager.AddListener(StarNotes, StarNotes.STAR_UPGRADE, StarSubUpgrade.Upgrade, self)
end

function StarSubUpgrade:_OnBtnsClick(go)
	if go == self._btnChange.gameObject  then
		self:_OnClickBtnChange()
	elseif go == self._btnUpgrade.gameObject then
		self:_OnClickBtnUpgrade()
	elseif go == self._btnShow.gameObject then
		self:_OnClickBtnShow()
	elseif go == self._btnGoStar.gameObject then
		self:_OnClick_btnGoStar()
	end
end

function StarSubUpgrade:_OnClickBtnChange()
    local d = self.ceq
	ModuleManager.SendNotification(StarNotes.OPEN_STAR_BAG_PANEL, { idx = self.idx,
        id = d.id, kind = d.kind, quality = d.quality })
end

function StarSubUpgrade:_OnClick_btnGoStar()
	ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTINSTANCE_PANEL)
end

function StarSubUpgrade:_OnClickBtnUpgrade()
	StarProxy.SendUpdate(self.ceq.id)
    UISoundManager.PlayUISound(UISoundManager.ui_gem)
end

function StarSubUpgrade:_OnClickBtnShow()
	ModuleManager.SendNotification(StarNotes.OPEN_STAR_SHOW_PANEL)
end

function StarSubUpgrade:_OnItemsClick(info, pc)
	if info then 
       if pc.starIdx == self.idx then return end
        self:_SelectItem(pc.starIdx)
    end
end
function StarSubUpgrade:_OnNotItemsClick( pc)
    if pc:GetOpened() then
        ModuleManager.SendNotification(StarNotes.OPEN_STAR_BAG_PANEL, {idx = pc.starIdx })
    end
end

function StarSubUpgrade:Upgrade()
    if not self.currentItem then return end
    self._trsUpgradeEff:SetActive(false)
    self._trsUpgradeEff:SetActive(true)
    Util.SetLocalPos(self._trsUpgradeEff, 
        self.currentItem.gameObject.transform.localPosition)
    self._txtFight.text = StarManager.GetPower()
end

function StarSubUpgrade:UpdatePanel()
	local ceng = StarManager.GetStarCeng()
    local nceng = StarManager.GetNextStarCeng(ceng)
    if nceng > 0 then
        self._txtNextStar.gameObject:SetActive(true)
        self._trsFullPos.gameObject:SetActive(false)
        self._txtNextStar.text = LanguageMgr.Get("StarPanel/upgrade/ceng", { n = nceng })
    else
        self._txtNextStar.gameObject:SetActive(false)
        self._trsFullPos.gameObject:SetActive(true)
    end
    local eqs = StarManager.equip
    local eqLen = #eqs
    local tds = StarManager.GetStarUpgradeTips()
    for i = PosMin, PosMax do
        local ind = i + 1
        local item = self.items[ind]
        local opened = StarManager.GetOpenById(ind, ceng)
        item:SetLock(not opened)
        if opened then
            local info = nil
            local eq = StarManager.GetDataBydIdx(i)
            if eq then                
                info = ProductInfo:New()
                info:Init({ spId = eq.spId })
                item:SetData(info)
                local lev = (eq.level and eq.level or info:GetLevel())
                local nl = ColorDataManager.GetColorText(ColorDataManager.GetColorByQuality(info:GetQuality()),
    LanguageMgr.Get("StarPanel/lev", { n = lev }))
                item:UpAm(nl)
                if i > 0 then
                    local line = UIUtil.GetChildByName(self._gameObject, "Transform", "stars/line" .. (i))
                    line.gameObject:SetActive(true)
                end
	            local tsp = UIUtil.GetChildByName(self._gameObject, "UISprite", "stars/upTips" .. ind)
                tsp.enabled = table.contains(tds, i)
            end
            item:UpdateOpen(not eq)
        else
            item:UpdateOpen(false)
        end

    end
    self:_SelectItem(self.idx or PosMin)
    self._txtFight.text = StarManager.GetPower()
end

function StarSubUpgrade:_SelectItem(idx)
    idx = idx or self.idx
	local eq = StarManager.GetDataBydIdx(idx)
    if eq then
        self._trsNoSelect.gameObject:SetActive(false)
        self._trsLelf.gameObject:SetActive(true)
        self.ceq = eq
        if self.currentItem then self.currentItem:UpdateSelect(false) end
        self.idx = idx
        self.currentItem = self.items[idx + 1] 
        self.currentItem:UpdateSelect(true)
    else
        self._trsNoSelect.gameObject:SetActive(true)
        self._trsLelf.gameObject:SetActive(false)
        return
    end
    local pinfo = ProductManager.GetProductById(eq.spId)
    local lev = (eq.level and eq.level or pinfo.lev)
    local quality = pinfo.quality
    self._txtLevel.text = ColorDataManager.GetColorText(ColorDataManager.GetColorByQuality(quality),
    LanguageMgr.Get("StarPanel/upgrade/lev", { n = pinfo.name, l = lev }))
    local ac =  StarManager.GetAttConfig(quality, lev)
    local as = StarManager.GetAttForConfig(pinfo.kind, ac, true)
    local propertyData = as:GetPropertyAndDes()
    local ps1 = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[1].property .. propertyData[1].sign)
    local ps2 = ''
    if propertyData[2] then
        ps2 = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[2].property .. propertyData[2].sign)
    end
    self._txtAtts.text = ps1 .. '\n' ..ps2
    self._imgQuality.color = ColorDataManager.GetColorByQuality(quality)
    ProductManager.SetIconSprite(self._imgIcon, pinfo.icon_id)

    local ac2 = StarManager.GetAttConfig(quality, lev + 1)
    --Warning(tostring(ac2) .. tostring(quality) .. tostring(lev + 1))
    if ac2 then        
        local as2 = StarManager.GetAttForConfig(pinfo.kind, ac2, true)
        local propertyData2 = as2:GetPropertyAndDes()
        ps1 = propertyData[1].des .. "+" .. propertyData[1].property
            .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " --> +" .. propertyData2[1].property .. propertyData[1].sign)
        ps2 = propertyData[2] and propertyData[2].des .. "+" .. propertyData[2].property
            .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " --> +" .. propertyData2[2].property .. propertyData[2].sign)
            or ''
        --Warning(tostring(ps1) .. tostring(ps1) )
        self._txtUpgradeAtts.text = ps1 .. '\n' ..ps2
    else
        self._txtUpgradeAtts.text = LanguageMgr.Get("StarPanel/fullLev")
    end
    local coin = StarManager.GetCoin()
    self._txtUpgradeNeed.text = (coin >= ac.up_exp and '' or '[ff0000]') .. coin .. '/' .. ac.up_exp
    self._imgChangeTip.enabled = StarManager.HasBetter(pinfo.kind, quality)
    self._imgUpgradeTip.enabled = StarManager.HasUpgrade(eq)
end

function StarSubUpgrade:_Dispose()
	self:_DisposeReference();
    MessageManager.RemoveListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubUpgrade.UpdatePanel, self);
    MessageManager.RemoveListener(StarNotes, StarNotes.STAR_UPGRADE, StarSubUpgrade.Upgrade, self)
end

function StarSubUpgrade:_DisposeReference()
	self._btnChange = nil;
	self._btnUpgrade = nil;
	self._txtNextStar = nil;
	self._txtLevel = nil;
	self._txtAtts = nil;
	self._txtUpgradeAtts = nil;
	self._txtUpgradeNeed = nil;
	self._imgQuality = nil;
	self._imgIcon = nil;
	self._trsLelf = nil;
	self._trsNoSelect = nil;
end
return StarSubUpgrade