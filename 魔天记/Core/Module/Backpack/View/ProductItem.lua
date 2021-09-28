require "Core.Module.Common.UIItem"
require "Core.Module.Common.ProductCtrl"
require "Core.Module.Backpack.data.BackPackCDData"

ProductItem = class("ProductItem", UIItem);

ProductItem.max_num = 5 * 5 * 5;

function ProductItem:New()
    self = { };
    setmetatable(self, { __index = ProductItem });
    return self
end
 
function ProductItem:UpdateItem(data)
    self.data = data

end

function ProductItem:Init(gameObject, data)
    self.data = data
    self.gameObject = gameObject

    self._productCtrl = nil;


    self:UpdateItem(self.data);

    self.pro = UIUtil.GetChildByName(self.gameObject, "Transform", "pro");

    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "sample/lockedBg");
    self.cdLockLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "sample/cdLockLabel");
    self.bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "sample/bg");
    self.lbg = UIUtil.GetChildByName(self.gameObject, "UISprite", "sample/lbg");



    self.cdLockLabel.gameObject:SetActive(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);



    ModuleManager.SendNotification(BackpackNotes.PRODUCTITEM_INIT, self);

    self:SetLock(false);

end

function ProductItem:SetIdx(v)
    self.idx = v;

end

function ProductItem:CheckLockCD()

    if BackPackBoxLockCDCtr.enble then

        if BackPackBoxLockCDCtr.bcd > 0 then
            local bs = BackpackDataManager._bsize + 1;

            if self.idx == bs then
                self.cdLockLabel.gameObject:SetActive(true);

                self:BagLockDJSTime();
                BackPackBoxLockCDCtr.SetDaoJiShiHandler(ProductItem.BagLockDJSTime, self);
            else
                self.cdLockLabel.gameObject:SetActive(false);
            end
        end
    else
        self.cdLockLabel.gameObject:SetActive(false);
    end



end

function ProductItem:BagLockDJSTime()

    local bs = BackpackDataManager._bsize + 1;

    if self.idx == bs then
        local tstr = GetTimeByStr(BackPackBoxLockCDCtr.bcd);
        self.cdLockLabel.text = tstr;
    else
        self.cdLockLabel.gameObject:SetActive(false);

    end





end

-- 更新 cd 
function ProductItem:ProductCDChange()

    FixedUpdateBeat:Remove(self.UpTime, self);

    if self._productCtrl ~= nil then
        self._productCtrl:SetCdActive(false);
    end

    if self.productInfo ~= nil then

        self.rt_sec = BackPackCDData.GetCD(self.productInfo);
        self.cf_cd = self.productInfo:GetCF_CD();

        self.cf_cd = BackPackCDData.CheckExtCd(self.cf_cd, self.productInfo:GetSpId());

        if self.rt_sec > 0 then

            ------------------------------------------------------------------------------

            self._productCtrl:SetCdActive(true);
            self._productCtrl:SetCDValue(self.rt_sec, self.cf_cd);

            FixedUpdateBeat:Add(self.UpTime, self)

            -------------------------------------------------------------------------
        end

    end


end



function ProductItem:UpTime()

    self.rt_sec = BackPackCDData.GetCD(self.productInfo);
    self.cf_cd = self.productInfo:GetCF_CD();

    self.cf_cd = BackPackCDData.CheckExtCd(self.cf_cd, self.productInfo:GetSpId());

    self._productCtrl:SetCDValue(self.rt_sec, self.cf_cd);

    if self.rt_sec < 10 then


        self._productCtrl:SetCdActive(false);
        FixedUpdateBeat:Remove(self.UpTime, self)
    end

end

function ProductItem:_OnClickBtn()
    if self.lock == true and self.idx ~= nil then
        ModuleManager.SendNotification(BackpackNotes.OPEN_UNLOCKTIP, self.idx);

    else
        if self._productCtrl ~= nil then
            self._productCtrl:_OnClickBtn();
        end
    end
end

function ProductItem:SetLock(v)
    self.lock = v;
    self._lockedBg.gameObject:SetActive(v);
    if v then
        self.bg.gameObject:SetActive(false);
        self.lbg.gameObject:SetActive(true);
    else
        self.bg.gameObject:SetActive(true);
        self.lbg.gameObject:SetActive(false);
    end

end

function ProductItem:CheckAndInitProductCtrl(productInfo)

    if productInfo ~= nil and self._productCtrl == nil then

        if self.itemGo ~= nil then
            Resourcer.Recycle(self.itemGo);
            self.itemGo = nil;
        end

        self.itemGo = UIUtil.GetUIGameObject(ResID.UI_PackBackItem);
        UIUtil.AddChild(self.gameObject.transform, self.itemGo.transform);

        self._productCtrl = ProductCtrl:New();
        self._productCtrl:Init(self.itemGo,
        { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true, true);
        self._productCtrl:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_BACKPACK);
        self._productCtrl.idx = self.idx;
    end

end

function ProductItem:SetData(productInfo)

    self.productInfo = productInfo;
    self:CheckAndInitProductCtrl(productInfo);

    if self._productCtrl ~= nil then
        self._productCtrl:SetData(productInfo);
    end

    self:CheckEqTips();
    self:ProductCDChange();



end


function ProductItem:CheckEqTips()




    if self._productCtrl ~= nil then
        ColorDataManager.UnSetGray(self._productCtrl._icon);
        self._productCtrl:SetFightTipIconActive(false);
    end

    if self.productInfo ~= nil then
        local ty = self.productInfo:GetType();

        if ProductManager.type_1 == ty then

            local isFitCareer = self.productInfo:IsFitMyCareer();
            local kind = self.productInfo:GetKind();
            local eqbagInfo = EquipDataManager.GetProductByKind(kind);

            if eqbagInfo == nil then

                if isFitCareer then
                    self._productCtrl:SetFightTipIconSrc("up");
                end
            else

                -- 对应装备栏里的总 战斗力
                local eq_bag_fight = eqbagInfo:GetFight();

                -- 背包中的 属性
                local bag_fight = self.productInfo:GetFight();

                if isFitCareer then

                    if bag_fight > eq_bag_fight then
                        self._productCtrl:SetFightTipIconSrc("up");
                    elseif bag_fight < eq_bag_fight then
                        self._productCtrl:SetFightTipIconSrc("down");
                    end

                end



            end


        end

    end


end

function ProductItem:_Dispose()

    FixedUpdateBeat:Remove(self.UpTime, self);

    if self.itemGo ~= nil then
        Resourcer.Recycle(self.itemGo);
        self.itemGo = nil;
    end

    UIUtil.GetComponent(self.gameObject.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;


    if self._productCtrl ~= nil then
        self._productCtrl:Dispose();
        self._productCtrl = nil;
    end

    self.data = nil;




    self.cdLockLabel = nil;

    self.bg = nil;
    self.lbg = nil;


end