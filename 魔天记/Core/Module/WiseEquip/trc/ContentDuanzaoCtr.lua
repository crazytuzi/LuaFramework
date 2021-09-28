

local ContentDuanzaoCtr = class("ContentDuanzaoCtr")

local WiseEquipDuanZaoItem = require "Core.Module.WiseEquip.trc.item.WiseEquipDuanZaoItem"
local LeftBtnItem = require "Core.Module.WiseEquip.trc.item.LeftBtnItem"

function ContentDuanzaoCtr:New()
    self = { };
    setmetatable(self, { __index = ContentDuanzaoCtr });

    return self;
end



function ContentDuanzaoCtr:Init(transform)

    self.transform = transform;

    self._btn_xianBing = UIUtil.GetChildByName(self.transform, "Transform", "btn_xianBing");
    self._btn_xuabBing = UIUtil.GetChildByName(self.transform, "Transform", "btn_xuabBing");


    self._btn_xianBingCtr = LeftBtnItem:New(self._btn_xianBing);
    self._btn_xuabBingCtr = LeftBtnItem:New(self._btn_xuabBing);

    self.rTitleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "title/rTitleTxt");
    self.txt_noEqTip = UIUtil.GetChildByName(self.transform, "UILabel", "txt_noEqTip");
    self.txt_useTip = UIUtil.GetChildByName(self.transform, "UILabel", "txt_useTip");

    local btns = UIUtil.GetComponentsInChildren(self.transform, "UIButton");


    self.item_len = 2;
    self.itemCtrs = { };
    for i = 1, self.item_len do
        local obj = UIUtil.GetChildByName(self.transform, "Transform", "item" .. i);
        self.itemCtrs[i] = WiseEquipDuanZaoItem:New();
        self.itemCtrs[i]:Init(obj)
    end


    self._roleParent = UIUtil.GetChildByName(self.transform, "Transform", "imgRole/heroCamera/trsRoleParent");


    local data = RoleModelCreater.CloneDress(PlayerManager.GetPlayerInfo(), true, true, false)
    self._uiHeroAnimationModel = UIHeroAnimationModel:New(data, self._roleParent)

    self._onClickBtn_xianBing = function(go) self:_OnClickBtn_xianBing(self) end
    UIUtil.GetComponent(self._btn_xianBing.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_xianBing);

    self._onClickBtn_xuabBing = function(go) self:_OnClickBtn_xuabBing(self) end
    UIUtil.GetComponent(self._btn_xuabBing.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_xuabBing);


    MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2003_RESULT, ContentDuanzaoCtr.DuanZaoSuccess, self);

end



function ContentDuanzaoCtr:SetData(eqIndex, selectEq)

    self.selectEq = selectEq;
    self:UpIndex(eqIndex, false)
    self:UpEq();


end

function ContentDuanzaoCtr:UpEq()


    self._btn_xianBingCtr:SetProduct(EquipDataManager.GetProductByKind(EquipDataManager.KIND_XIANBING));
    self._btn_xuabBingCtr:SetProduct(EquipDataManager.GetProductByKind(EquipDataManager.KIND_XUANBING));

end

function ContentDuanzaoCtr:UpIndex(eqIndex, doNotSetBt)
    self.eqIndex = eqIndex;

    if eqIndex == 1 then

        self:_OnClickBtn_xianBing()
    elseif eqIndex == 2 then

        self:_OnClickBtn_xuabBing()
    end
end




function ContentDuanzaoCtr:_OnClickBtn_xianBing()

    self.rTitleTxt.text = LanguageMgr.Get("WiseEquip/ContentDuanzaoCtr/label1");
    self.txt_noEqTip.text = LanguageMgr.Get("WiseEquip/ContentDuanzaoCtr/label3") .. LanguageMgr.Get("WiseEquip/ContentDuanzaoCtr/label1");
    self:UpRight(EquipDataManager.KIND_XIANBING)

    self._btn_xianBingCtr:SetSelect(true);
    self._btn_xuabBingCtr:SetSelect(false);
end

function ContentDuanzaoCtr:_OnClickBtn_xuabBing()
    self.rTitleTxt.text = LanguageMgr.Get("WiseEquip/ContentDuanzaoCtr/label2");
    self.txt_noEqTip.text = LanguageMgr.Get("WiseEquip/ContentDuanzaoCtr/label3") .. LanguageMgr.Get("WiseEquip/ContentDuanzaoCtr/label2");
    self:UpRight(EquipDataManager.KIND_XUANBING)

    self._btn_xianBingCtr:SetSelect(false);
    self._btn_xuabBingCtr:SetSelect(true);
end

function ContentDuanzaoCtr:UpRight(kind)
    self.left_select_kind = kind;

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    local att_keys = EquipDataManager.GetWiseEquipAttKeys(my_career, kind);

    local eqInfo = EquipDataManager.GetExtEquipByKind(kind);

    for i = 1, self.item_len do

        self.itemCtrs[i]:SetData(kind, eqInfo, att_keys[i])
    end

    if eqInfo == nil then
        self.txt_noEqTip.gameObject:SetActive(true);
        self.txt_useTip.gameObject:SetActive(false);
    else
        self.txt_noEqTip.gameObject:SetActive(false);
        self.txt_useTip.gameObject:SetActive(true);
    end




end

function ContentDuanzaoCtr:DuanZaoSuccess()


    self:UpRight(self.left_select_kind);

end

function ContentDuanzaoCtr:Show()
    self.transform.gameObject:SetActive(true);
end

function ContentDuanzaoCtr:Hide()
    self.transform.gameObject:SetActive(false);
end

function ContentDuanzaoCtr:Dispose()

    self.transform = nil;

    UIUtil.GetComponent(self._btn_xianBing.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btn_xuabBing.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

    MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2003_RESULT, ContentDuanzaoCtr.DuanZaoSuccess);

    self._uiHeroAnimationModel:Dispose()
    self._uiHeroAnimationModel = nil;

    self._btn_xianBingCtr:Dispose();
    self._btn_xuabBingCtr:Dispose();

    self._btn_xianBingCtr = nil;
    self._btn_xuabBingCtr = nil;


    for i = 1, self.item_len do
        self.itemCtrs[i]:Dispose()
    end

end


return ContentDuanzaoCtr;

