require "Core.Module.Common.Panel"

local ItemMoveEffectPanel = class("ItemMoveEffectPanel", Panel);
function ItemMoveEffectPanel:New()
    self = { };
    setmetatable(self, { __index = ItemMoveEffectPanel });
    return self
end

function ItemMoveEffectPanel:IsFixDepth()
    return true;
end

function ItemMoveEffectPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ItemMoveEffectPanel:_InitReference()

    self.bgList = UIUtil.GetChildByName(self._trsContent, "Transform", "bgList");
    self.effFat = UIUtil.GetChildByName(self.bgList, "UISprite", "effFat");
    self.click = UIUtil.GetChildByName(self.bgList, "UISprite", "click");

    self.txt_name = UIUtil.GetChildByName(self.bgList, "UILabel", "txt_name");

    self.Product = UIUtil.GetChildByName(self._trsContent, "Transform", "Product");
    self.Skill = UIUtil.GetChildByName(self._trsContent, "Transform", "Skill");
    self.Skill_icon = UIUtil.GetChildByName(self.Skill, "UISprite", "imgIcon");

    self.Product.gameObject:SetActive(false);
    self.Skill.gameObject:SetActive(false);


    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(self.Product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });

    self._uiEffect = UIEffect:New()
    self._uiEffect:Init(self.bgList, self.effFat, 0, "ui_shine");
    self._uiEffect:Play();

    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self.click, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);

end

function ItemMoveEffectPanel:_InitListener()
end

function ItemMoveEffectPanel:SetData(data)

    if data == nil then
        self:SetActive(false)
        return;
    end

    self:SetActive(true)
    self.data = data;

    local fun = self.data.fun;
    if fun == ItemMoveManager.interface_ids.getProAndMoveToBt then

        self:SetPro(self.data.spid, self.data.am);
        self.txt_name.text = self.pro_info:GetName();

    elseif fun == ItemMoveManager.interface_ids.getNewSkillAndMoveToBt then

        self:SetSkill(self.data.skill_id);
        self.txt_name.text = self.sklCfg.name;

    end



end

function ItemMoveEffectPanel:_OnClickBtn_ok()

    self.bgList.gameObject:SetActive(false);
     self.numt = 10;
     UpdateBeat:Remove(self.OnUpdate, self)
     UpdateBeat:Add(self.OnUpdate, self)

end

function ItemMoveEffectPanel:OnUpdate()

    self.numt = self.numt - 1;
    if self.numt <= 0 then

        local fun = self.data.fun;
        if fun == ItemMoveManager.interface_ids.getProAndMoveToBt then
            self:GetProAndMoveToBt(self.data.spid, self.data.am, self.data.tf)

        elseif fun == ItemMoveManager.interface_ids.getNewSkillAndMoveToBt then
            self:GetSkillAndMoveToBt(self.data.skill_id, self.data.tf)
        end
        UpdateBeat:Remove(self.OnUpdate, self)
    end

end

function ItemMoveEffectPanel:SetSkill(skill_id)
    self.sklCfg = ConfigManager.GetSkillById(skill_id, 1);
    self.Skill_icon.spriteName = self.sklCfg.icon_id;
    self.Skill.gameObject:SetActive(true);
end

-- 17:59:39.525-914: S <-- cmd=0x502, data={"level":1,"skill_id":203170}
function ItemMoveEffectPanel:GetSkillAndMoveToBt(skill_id, tf)

    LuaDOTween.DOKill(self.Skill, false);

    self:SetSkill(skill_id);

    local targetPos = self._trsContent.transform:InverseTransformPoint(tf.position);
    local comfun = function() self:GetSkillAndMoveToBt_DoMoveEnd() end;
    LuaDOTween.OnComplete(LuaDOTween.DOLocalMove(self.Skill, targetPos, 1), comfun);
end

function ItemMoveEffectPanel:GetSkillAndMoveToBt_DoMoveEnd()

    self.Product.gameObject:SetActive(false);
    ModuleManager.SendNotification(ItemMoveEffectNotes.CLOSE_ITEMMOVEEFFECTPANEL);

end

function ItemMoveEffectPanel:SetPro(spid, am)
    self.pro_info = ProductManager.GetProductInfoById(spid, am)
    self._productCtrl:SetData(self.pro_info);
    self.Product.gameObject:SetActive(true);
    Util.SetLocalPos(self.Product, 0, 0, 0)
end

-- {fun=ItemMoveManager.interface_ids.getProAndMoveToBt,spid=spid,am=am,tf = tf}
function ItemMoveEffectPanel:GetProAndMoveToBt(spid, am, tf)

    LuaDOTween.DOKill(self.Product, false);

    self:SetPro(spid, am);

    local targetPos = self._trsContent.transform:InverseTransformPoint(tf.position);
    local comfun = function() self:GetProAndMoveToBt_DoMoveEnd() end;
    LuaDOTween.OnComplete(LuaDOTween.DOLocalMove(self.Product, targetPos, 1), comfun);
end

function ItemMoveEffectPanel:GetProAndMoveToBt_DoMoveEnd()

    self.Product.gameObject:SetActive(false);
    ModuleManager.SendNotification(ItemMoveEffectNotes.CLOSE_ITEMMOVEEFFECTPANEL);

end

function ItemMoveEffectPanel:_Dispose()
    self:_DisposeReference();
end

function ItemMoveEffectPanel:_DisposeReference()

    UIUtil.GetComponent(self.click, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;


    if (self._uiEffect) then
        self._uiEffect:Dispose()
        self._uiEffect = nil
    end

    UpdateBeat:Remove(self.OnUpdate, self)
    self._productCtrl:Dispose();
    self._productCtrl = nil;
end
return ItemMoveEffectPanel