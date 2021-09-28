require "Core.Module.Equip.Item.SQTableButton"
require "Core.Module.Equip.Item.EqInBagPageItem"

LeftPanelControll = class("LeftPanelControll")
function LeftPanelControll:New()
    self = { };
    setmetatable(self, { __index = LeftPanelControll });
    return self;
end


function LeftPanelControll:Init(gameObject, handler, hd_target)

    EquipDataManager.hasFistOpen = false;
    self.hasInit = false;

    self.gameObject = gameObject;
    local eqPanelControlls = { };

    local txts = UIUtil.GetComponentsInChildren(gameObject, "UILabel");
    self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");

    for i = 1, 8 do
        self["eqPanel" .. i] = UIUtil.GetChildByName(gameObject, "Transform", "eq_" .. i);
        eqPanelControlls[i] = EquipPanelCtrl:New();
        eqPanelControlls[i]:Init(self["eqPanel" .. i].gameObject, i, { iconType = ProductCtrl.IconType_circle });
        eqPanelControlls[i]:SetOnClickBtnHandler(handler, hd_target);
    end
    self.eqPanelControlls = eqPanelControlls;

    self.extEqPanelControlls = { };
    for i = 1, 2 do
        local eq_gameObject = UIUtil.GetChildByName(gameObject, "extEq_" .. i).gameObject;
        self.extEqPanelControlls[i] = ProductCtrl:New();
        self.extEqPanelControlls[i]:Init(eq_gameObject, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_circle });
        self.extEqPanelControlls[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end


    local trss = UIUtil.GetComponentsInChildren(gameObject, "Transform");
    local _roleParent = UIUtil.GetChildInComponents(trss, "trsRoleParent");

    local data = RoleModelCreater.CloneDress(PlayerManager.GetPlayerInfo(), true, true, false)
    self._uiHeroAnimationModel = UIHeroAnimationModel:New(data, _roleParent)

    self.hasInit = true;

    MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE, self.UpExtEquip, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_UPLEFTEQSDATA, self.UpLeftEqs, self);

    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_ADDEQINBAGPRODUCTITEM, self.AddEqInBagProductItem, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_PRODUCTITEMCLICKHANDLER, self.productItemClickHandler, self);


    self:UpExtEquip();
    self:UpFightPower();
end

function LeftPanelControll:UpExtEquip()

    local extEqinfo1 = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx1);
    local extEqinfo2 = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx2);

    self.extEqPanelControlls[1]:SetData(extEqinfo1);
    self.extEqPanelControlls[2]:SetData(extEqinfo2);

end

function LeftPanelControll:UpFightPower()

    self._txtPower.text = PlayerManager.GetSelfFightPower() .. "";
end

function LeftPanelControll:GetSelectKind()
    local selectCtr = nil;

    for i = 1, 8 do
        selectCtr = self.eqPanelControlls[i];
        if selectCtr.selected then
            return i;
        end
    end
    return 1;
end

function LeftPanelControll:CheckSelect(kind)

    local selectCtr = nil;

    for i = 1, 8 do
        if i == kind then
            selectCtr = self.eqPanelControlls[i];
            selectCtr:Selected(true);
        else
            self.eqPanelControlls[i]:Selected(false);
        end
    end

end


function LeftPanelControll:PageChange(args)

    local str_len = string.len(args);
    local page_id = string.sub(args, str_len, -1);
    page_id = page_id + 0;

    if self.currPage_id ~= page_id then
        self.currPage_id = page_id;
        self:ShowPageIcon(page_id);
    end
end




function LeftPanelControll:AddEqInBagProductItem(productItem)

    if self.EqInBagProducts == nil then
        self.EqInBagProducts = { };
        self.EqInBagProductsIndex = 1;
    end

    self.EqInBagProducts[self.EqInBagProductsIndex] = productItem;
    self.EqInBagProductsIndex = self.EqInBagProductsIndex + 1;

end

function LeftPanelControll:productItemClickHandler()

    self:UpEqInBagProductsSelect();

end


function LeftPanelControll:UpEqInBagProductsSelect()
    -- 这里 可以多选， 所以 需要 检测两个 释放可以 选择
    local len = self.EqInBagProductsIndex - 1;

    for i = 1, len do
        local tem = self.EqInBagProducts[i];
        tem:CheckCanSelect();
    end
end

function LeftPanelControll:UpLeftEqs()

    for i = 1, 8 do
        local qx = EquipLvDataManager.getItem(i);
        self.eqPanelControlls[i]:SetShowGem(false);
        self.eqPanelControlls[i]:SetShowStar(false);
        self.eqPanelControlls[i]:SetData(qx, "suit_lev");
    end

end



function LeftPanelControll:ShowForOther()


    for i = 1, 8 do
        self["eqPanel" .. i].gameObject:SetActive(true);
    end

end



function LeftPanelControll:CheckAndSetNpointV(resuleData)
    for i = 1, 8 do
        local tem_ctr = self.eqPanelControlls[i];
        tem_ctr:SetNpointV(resuleData[i]);
    end
end




function LeftPanelControll:TrySetDefulSelect()

    if self.currSelect == nil then

        self.eqPanelControlls[1]:_OnClickBtn();
        self.currSelect = self.eqPanelControlls[1];
    end
end



function LeftPanelControll:UpEqBagForNewEquipStrong()
    for i = 1, 8 do
        self:UpEqBagForNewEquipStrongByKind(i)
    end

end

function LeftPanelControll:UpEqBagForNewEquipStrongByKind(kind)
    local data = NewEquipStrongManager.GetEquipStrongDataByIdx(kind);
    self.eqPanelControlls[kind]:SetDataForNewEquipStrong(data, kind);
end

function LeftPanelControll:Dispose()

    for i = 1, 8 do
        self.eqPanelControlls[i]:Dispose();
        self.eqPanelControlls[i] = nil;
        self["eqPanel" .. i] = nil;
    end

    for i = 1, 2 do
        self.extEqPanelControlls[i]:Dispose();
    end

    MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE, self.UpExtEquip, false);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_UPLEFTEQSDATA, self.UpLeftEqs, self);

    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_ADDEQINBAGPRODUCTITEM, self.AddEqInBagProductItem, self);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_PRODUCTITEMCLICKHANDLER, self.productItemClickHandler, self);


    self._uiHeroAnimationModel:Dispose()
    self._uiHeroAnimationModel = nil;


    EquipDataManager.hasFistOpen = true;
    self.hasInit = false;

    ModuleManager.SendNotification(EquipNotes.MES_CLOSE_EQUIPMAINPANELL);

    self.currSelect = nil;

    self.gameObject = nil;
    self.eqPanelControlls = nil;


end 