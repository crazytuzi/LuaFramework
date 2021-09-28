local EquipQualityEffect = require "Core.Module.Common.EquipQualityEffect"

ProductCtrl = { };

ProductCtrl.TYPE_NONE = nil;
ProductCtrl.TYPE_FROM_BACKPACK = 1;
ProductCtrl.TYPE_FROM_EQUIPS = 2;
ProductCtrl.TYPE_FROM_OTHER = 3;  -- 其他 容器
ProductCtrl.TYPE_FROM_OTHER_PLAYER = 4; -- 其他玩家身上
ProductCtrl.TYPE_FROM_SALELIST = 5; -- 寄售


ProductCtrl.IconType_circle = 11;-- 图标类型  圆形
ProductCtrl.IconType_rectangle = 12; -- 矩形

function ProductCtrl:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

--        ext_data.hasLocke  是否有 加锁 图片
--  _icon ext_data.use_sprite  是否使用 UISprite
--        ext_data.iconType
function ProductCtrl:Init(gameObject, ext_data, show_num, hasUnUseBg)

    self.gameObject = gameObject
    self.ext_data = ext_data;
    self.show_num = show_num;
    self.fShowNumTxt = false;
    -- 强制显示数量文本
    self.hasUnUseBg = hasUnUseBg;

    if show_num == nil then
        self.show_num = true;
    end

    self._eqQualityspecEffect = EquipQualityEffect:New();

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");


    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self._numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");

    if self.hasUnUseBg then
        self.unUseBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "unUseBg");
        self.unUseBg.gameObject:SetActive(false);
    end

    self.bukeyongIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "bukeyongIcon");
    self.fightTipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "fightTipIcon");

    self.bind_icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "bind_icon");

    
    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "lockedBg"); 
        

    if self.bukeyongIcon then
        self.bukeyongIcon.gameObject:SetActive(false);
    end

    self._uiEffect = UIUtil.GetChildByName(self.gameObject, "UISprite", "uiEffect");
    if self._uiEffect ~= nil then
        self._uiEffect.gameObject:SetActive(false);
    end

    self.cdIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "cdIcon");
    self.cdLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "cdLabel");

    self:SetLock(false);
    self:SetBind_iconActive(false);
    self:SetFightTipIconActive(false);
    self:SetData(nil);

end

function ProductCtrl:SetLock(v)
    if self._lockedBg ~= nil then
        self.lock = v;
        self._lockedBg.gameObject:SetActive(v);
    end
    self.locked = v
end
function ProductCtrl:GetLocked()
    return self.locked
end

function ProductCtrl:SetBind_iconActive(v)
    if self.bind_icon ~= nil then
        self.bind_icon.gameObject:SetActive(v);
    end

end

function ProductCtrl:SetCdActive(v)
    if self.cdIcon ~= nil then
        self.cdIcon.gameObject:SetActive(v);
    end
    if self.cdLabel ~= nil then
        self.cdLabel.gameObject:SetActive(v);
    end
end

function ProductCtrl:SetCDValue(curr_cd, total_cd)
    if self.cdIcon ~= nil then
        self.cdIcon.fillAmount = curr_cd / total_cd;
    end
    if self.cdLabel ~= nil then
        self.cdLabel.text = "" .. math.floor(curr_cd / 1000);
    end
end

function ProductCtrl:SetFightTipIconActive(v)
    if self.fightTipIcon ~= nil then
        self.fightTipIcon.gameObject:SetActive(v);
    end
end

function ProductCtrl:SetFightTipIconSrc(src)
    if self.fightTipIcon ~= nil then
        self.fightTipIcon.spriteName = src;
        self.fightTipIcon.gameObject:SetActive(true);
    end
end

function ProductCtrl:SetOnClickBtnHandler(_type)
    self._type = _type;
    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
end

function ProductCtrl:SetOnClickCallBack(cb, cb_target)
    self.cb = cb;
    self.cb_target = cb_target;
end

function ProductCtrl:SetOnPressCallBack(cb, cb_target)
    self.press_cb = cb;
    self.press_cb_target = cb_target;

    self._onPressBtnItem = function(go, isPress) self:_OnPressBtn(isPress) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnPress", self._onPressBtnItem);


end

function ProductCtrl:_OnPressBtn(isPress)

    if self.press_cb ~= nil then
        if self.press_cb_target ~= nil then
            self.press_cb(self.press_cb_target, isPress, self._productInfo, self);
        else
            self.press_cb(isPress, self._productInfo, self);
        end
    end
end

function ProductCtrl:SetNotProductClickHander(cb, cb_target)
    self.n_cb = cb;
    self.n_cb_target = cb_target;
end



function ProductCtrl:GetType()
    return self._type;
end

function ProductCtrl:GetProductInfo()
    return self._productInfo;
end



function ProductCtrl:UpdateOpen(f)
    if not(self.btn_open) then
        self.btn_open = UIUtil.GetChildByName(self.gameObject, "Transform", "open")
    end
    if (self.btn_open) then
        self.btn_open.gameObject:SetActive(f)
    end
    self.opened = f
end

function ProductCtrl:UpdateSelect(f)
    if not(self.selecter) then
        self.selecter = UIUtil.GetChildByName(self.gameObject, "Transform", "select")
    end
    if (self.selecter) then
        self.selecter.gameObject:SetActive(f)
    end
    self.selected = f
end
function ProductCtrl:GetSelected()
    return self.selected
end
function ProductCtrl:GetOpened()
    return self.opened
end

function ProductCtrl:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ProductCtrl:SetData(productInfo)
    self._productInfo = productInfo;

    if self.bukeyongIcon then
        self.bukeyongIcon.gameObject:SetActive(false);
    end



    self:TryCheckEqQualityspecEffect(self._productInfo)

    if self._productInfo ~= nil then
        local quality = self._productInfo:GetQuality();

        if self.ext_data ~= nil then

           

            if self.ext_data.use_sprite then

                ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());

                if self.ext_data.iconType == ProductCtrl.IconType_circle then
                    self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);

                elseif self.ext_data.iconType == ProductCtrl.IconType_rectangle then
                    self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
                end

            end

        else

            self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
        end


        self._icon.gameObject:SetActive(true);
        self._icon_quality.gameObject:SetActive(true);
        if (self._numLabel) then
            local am = self._productInfo:GetAm();

            if am and(am > 1) then
                self._numLabel.text = am .. "";
            else
                self._numLabel.text = "";
            end

            if self.fShowNumTxt then
                self._numLabel.text = am .. "";
            end

        end

        local ib = self._productInfo:IsBind();
        self:SetBind_iconActive(ib);

    else
        self._icon.gameObject:SetActive(false);
        self:SetBind_iconActive(false);
        if (self._numLabel) then
            self._numLabel.text = "";
        end
        self._icon_quality.gameObject:SetActive(false);

    end

    if not self.show_num then
        if (self._numLabel) then
            self._numLabel.text = "";
        end
    end

    if self.unUseBg ~= nil then
        self.unUseBg.gameObject:SetActive(false);
        if self._productInfo ~= nil then

            local ty = self._productInfo:GetType();
            if ProductManager.type_1 == ty then

                local re_v = tonumber(self._productInfo:GetReq_lev());

                local my_info = HeroController:GetInstance().info;
                local my_lv = tonumber(my_info.level);

                local isFitCareer = self._productInfo:IsFitMyCareer();


                if not isFitCareer or(my_lv < re_v) then
                    --   ColorDataManager.SetGray(self._productCtrl._icon);
                    self.unUseBg.gameObject:SetActive(true);
                else
                    self.unUseBg.gameObject:SetActive(false);
                end


                if self.bukeyongIcon then

                    if not isFitCareer then
                        self.bukeyongIcon.gameObject:SetActive(true);
                    end

                end


            end

        end


    end


end



function ProductCtrl:UpAm(amStr)
    if (self._numLabel) then
        self._numLabel.text = amStr .. "";
    end
end

function ProductCtrl.GetEquipAllAtt(pinfo, needExtAtt)

    local res = BaseAttrInfo:New();
    res:Add(pinfo.att_configData);
    -- 设置基础属性
    local kind = pinfo:GetKind();
    local career = pinfo:Get_career();

    if needExtAtt then
        -- 再装备栏里面的, 需要添加 强化，精练，宝石镶嵌 属性
        local eqlv = EquipLvDataManager.getItem(kind);
        -- 附灵属性
        if eqlv ~= nil then
            local slv = eqlv.slv;
            if slv > 0 then
                local qhAtt = StrongExpDataManager.GetExtStrongAtt(pinfo, slv);

                res:Add(qhAtt);
            end

            -- 精炼属性
            local refine_lev = eqlv.rlv;
            if eqlv ~= nil then
                if refine_lev > 0 then
                    local refine_att = RefineDataManager.GetRefine_item(kind, career, refine_lev);

                    res:Add(refine_att);
                end
            end
        end

        local neqstrong = NewEquipStrongManager.GetEquipStrongAttrByIdx1(kind - 1);
        if neqstrong ~= nil then
            res:Add(neqstrong);
        end

        -- 宝石镶嵌属性
        local gemAtt = GemDataManager.GetSlotGemAttr(kind);
        res:Add(gemAtt);


    end

    -- 装备神器属性 神器已经移除
    -- local star = pinfo:GetStar();
    -- if star > 0 then
    --     local sq_att = MouldingDataManager.Get_star_level_attr(career, kind, star);

    --     res:Add(sq_att);
    -- end

    return res;


end

--[[id  物品配置表 的 id
ptype  -->  ProductCtrl.TYPE_FROM_OTHER
am 物品数量
]]
-- hdl 添加st  用于其他地方显示装备的数据
function ProductCtrl.ShowProductTip(id, ptype, am, st)
    local info = ProductInfo:New();
    info:Init( { spId = id, am = am, st = st })
    ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = info, type = ptype });
end

function ProductCtrl.ShowProductTipByInfo(info, _type)
    if info ~= nil then
        if info:GetAm() > 0 then
            if _type ~= nil then
                ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = info, type = _type });
            end
        end

    end
end

function ProductCtrl:_OnClickBtn()
    if self._productInfo ~= nil then
        if self._productInfo:GetAm() > 0 then
            if self._type ~= nil then
                ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self._productInfo, type = self._type });
            end

            if self.cb ~= nil then
                if self.cb_target ~= nil then
                    self.cb(self.cb_target, self._productInfo, self);
                else
                    self.cb(self._productInfo, self);
                end
            end
            return
        end
    end
    -- 当 没有物品 而且被点击 的时候 调度
    if self.n_cb ~= nil then
        if self.n_cb_target ~= nil then
            self.n_cb(self.n_cb_target, self);
        else
            self.n_cb();
        end
    end
end

function ProductCtrl:TryCheckEqQualityspecEffect(info)

    self._eqQualityspecEffect:StopEffect();

    if info ~= nil then
        local quality = info:GetQuality();
        local type = info:GetType();

        if self._uiEffect == nil then
            self._eqQualityspecEffect:TryCheckEquipQualityEffect(self.gameObject.transform, self._icon, type, quality);
        else
            self._eqQualityspecEffect:TryCheckEquipQualityEffectForUISprite(self._uiEffect, type, quality);
        end


    end

end

function ProductCtrl:Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnPress");
    self._onPressBtnItem = nil;



    if (self._eqQualityspecEffect) then
        self._eqQualityspecEffect:Dispose()
        self._eqQualityspecEffect = nil
    end

    self.gameObject = nil


    self._icon = nil
    self._icon_quality = nil;

    self._numLabel = nil;

    self.cb_target = nil;
    self.cb = nil;

end
