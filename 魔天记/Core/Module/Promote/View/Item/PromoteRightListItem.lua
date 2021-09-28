require "Core.Module.Common.UIItem"

PromoteRightListItem = UIItem:New();

function PromoteRightListItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "imgIcon");
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "txtTitle");
    self._txtValue1 = UIUtil.GetChildByName(self.transform, "UILabel", "txtValue1");
    self._txtValue2 = UIUtil.GetChildByName(self.transform, "UILabel", "txtValue2");


    self._btnGo = UIUtil.GetChildByName(self.transform, "UIButton", "btnGo");
    self._onClickGoHandler = function(go) self:_OnClickGoHandler(self) end
    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickGoHandler);

    self._starsTransform = UIUtil.GetChildByName(self.transform, "Transform", "stars");
    self:_InitStar(self._starsTransform)

    self:UpdateItem(self.data);
end

function PromoteRightListItem:_InitStar(transform)
    local stars = { };
    if (transform) then
        for i = 1, 5 do
            local imgStar = UIUtil.GetChildByName(transform, "UISprite", "imgStar" .. i);
            stars[i] = imgStar
        end
    end
    self._stars = stars;
end

function PromoteRightListItem:_Dispose()
    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickGoHandler = nil;
    self._btnGo = nil

    self._imgIcon = nil;
    self._txtTitle = nil;
    self._txtValue1 = nil;
    self._txtValue2 = nil;

    for i, v in pairs(self._stars) do
        self._stars[i] = nil;
    end
    self._stars = nil;
    self._starsTransform = nil
end

function PromoteRightListItem:_OnClickGoHandler()
    if (self.data) then
        local base = self.data.base;
        if (base and base.interface > 0) then
            MessageManager.Dispatch(PromoteNotes, PromoteNotes.EVENT_CALL_INTERFACE, base.interface)
        end
    end
end

function PromoteRightListItem:_GetAllAttrsByKind(id)
    if (id == 1) then
        -- 1.装备加成属性
        local ls = { };
        local attr = { };
        -- 现在只需要基础属性
        ls[1] = EquipDataManager.GetMyEquipsAllAttrs();
        --  ls[2] = RefineDataManager.GetAllRefine();
        -- ls[3] = StrongExpDataManager.GetAllQiangHuaAtt();
        for i, v in pairs(ls) do
            if (v) then
                for ii, vv in pairs(v) do
                    if (attr[ii] == nil) then
                        attr[ii] = vv
                    else
                        attr[ii] = attr[ii] + vv
                    end
                end
            end
        end
        return attr
    elseif (id == 2) then
        -- 2.境界
        return RealmManager.GetAllAttrs()
    elseif (id == 3) then
        -- 3.宠物阵法
        local ls = { };
        local attr = { };

        ls[1] = PetManager.GetPetAdvanceAttr();
        ls[2] = PetManager.GetPetFashionAttr()

        for i, v in pairs(ls) do
            if (v) then
                for ii, vv in pairs(v) do
                    if (attr[ii] == nil) then
                        attr[ii] = vv
                    else
                        attr[ii] = attr[ii] + vv
                    end
                end
            end
        end
        return attr;


    elseif (id == 4) then
        -- 4.灵药加成属性
        return LingYaoDataManager.TryAllHasAtt()
    elseif (id == 5) then
        -- 5.法宝加成属性

        local ls = { };
        local attr = { };

        ls[1] = NewTrumpManager.GetAllAttrs();
        ls[2] = NewTrumpManager.GetMobaoAllAttrs();

        for i, v in pairs(ls) do
            if (v) then
                for ii, vv in pairs(v) do
                    if (attr[ii] == nil) then
                        attr[ii] = vv
                    else
                        attr[ii] = attr[ii] + vv
                    end
                end
            end
        end
        return attr

    elseif (id == 6) then
        -- 6.坐骑加成属性

        local ls = { };
        local attr = { };

        ls[1] = RideManager.GetAllRideProperty();
        ls[2] = RideManager.GetRideFeedAttr();

        for i, v in pairs(ls) do
            if (v) then
                for ii, vv in pairs(v) do
                    if (attr[ii] == nil) then
                        attr[ii] = vv
                    else
                        attr[ii] = attr[ii] + vv
                    end
                end
            end
        end
        return attr


    elseif (id == 7) then
        -- 7.翅膀加成属性
        local ls = { };
        local attr = { };

        ls[1] = WingManager.GetCurrentWingData();
        ls[2] = WingManager.GetAllFashionAttr();

        for i, v in pairs(ls) do
            if (v) then
                for ii, vv in pairs(v) do
                    if (attr[ii] == nil) then
                        attr[ii] = vv
                    else
                        attr[ii] = attr[ii] + vv
                    end
                end
            end
        end
        return attr;

    elseif (id == 9) then
        -- 阵图养成
        return FormationManager.GetAllAttrs();

    elseif (id == 10) then
        -- 命星系统
        return StarManager.GetAllAttrs();

    elseif (id == 11) then
        -- 装备附灵
        return StrongExpDataManager.GetAllQiangHuaAtt();

    elseif (id == 12) then
        -- 宝石
        return GemDataManager.GetAllAttrs();

    elseif (id == 13) then
        -- 装备精炼
        return RefineDataManager.GetAllRefine();

    elseif (id == 14) then
        -- 装备精炼
        return NewEquipStrongManager.GetAllEquipStrongAttr();

    elseif (id == 15) then
        -- 属性为仙器的附魔属性与注魂属性的总战力
         local ls = { };
        local attr = { };

        ls[1] = EquipDataManager.GetMyWiseEquipsAllAttrs();
        ls[2] = EquipDataManager.GetAllEuipsFoMoAttrs();

        for i, v in pairs(ls) do
            if (v) then
                for ii, vv in pairs(v) do
                    if (attr[ii] == nil) then
                        attr[ii] = vv
                    else
                        attr[ii] = attr[ii] + vv
                    end
                end
            end
        end
        return attr;

    else
        log(" not find  data  id " .. id);

    end
    return nil;
end

function PromoteRightListItem:_CalculatePower(typeid, kindid)
    -- log("typeid " .. typeid .. " kindid " .. kindid);
    local power = 0;
    if (typeid == 1) then

        if (kindid ~= 8) then
            local attrs = self:_GetAllAttrsByKind(kindid);
            if (attrs) then
                -- power = power + FightPowerManager.CalculatePower(attrs, kindid == 2 or kindid == 6);
                --[[
                local ep = 0;
                if kindid == 5 then
                   ep= NewTrumpManager.GetMobaoPower();
                end
                ]]



                power = CalculatePower(attrs, kindid == 2 or kindid == 6);
            end
        else
            power = SkillManager.GetSkillPower();
        end
    end
    return power;
end

function PromoteRightListItem:SetSelected(val)
    if (val ~= nil) then
        if (self.isSelected ~= val) then
            self.isSelected = val
            self:Refresh();
        end
    end
end

function PromoteRightListItem:Refresh()
    if (self._imgSelect) then
        self._imgSelect.gameObject:SetActive(self.isSelected);
    end
end

function PromoteRightListItem:UpdateItem(data)
    self.data = data;

    -- log("-------PromoteRightListItem:UpdateItem-----------------");
    --- PrintTable(self.data);

    if (self._txtTitle) then
        if (data) then
            local base = data.base;
            local level = data.level;
            self._imgIcon.spriteName = base.icon;
            self._imgIcon:MakePixelPerfect();
            self._txtTitle.text = base.kind_name;
            if (base.max_star > 0) then
                self._txtValue1.text = "[bccbff]" .. base.kind_des .. "[-]";
                self._txtValue2.text = "";
                self._starsTransform.gameObject:SetActive(true);
                for i = 1, 5 do
                    local star = self._stars[i];
                    if (star) then
                        star.gameObject:SetActive(i <= base.max_star);
                    end
                end
            else
                local power = self:_CalculatePower(base.type_id, base.kind_id)
                if (power < level.rec_fighting) then
                    -- 1红色、2绿色
                    self._txtValue1.text = "[bccbff]当前战力：[-]" .. "[ff4b4b]" .. power .. "[-]";
                    self._txtValue2.text = "[bccbff]推荐战力：[-]" .. "[77ff47]" .. level.rec_fighting .. "[-]";
                elseif (power >= level.rec_fighting and power < level.str_fighting) then
                    -- 1绿色、2黄色
                    self._txtValue1.text = "[bccbff]当前战力：[-]" .. "[77ff47]" .. power .. "[-]";
                    self._txtValue2.text = "[bccbff]更强战力：[-]" .. "[ffc320]" .. level.str_fighting .. "[-]";
                else
                    -- 1黄色
                    self._txtValue1.text = "[bccbff]当前战力：[-]" .. "[ffc320]" .. power .. "[-]";
                    self._txtValue2.text = "";
                end
                self._starsTransform.gameObject:SetActive(false);
            end
            self._btnGo.gameObject:SetActive(base.interface > 0);
        else
            self._txtTitle.text = "";

            self._btnGo.gameObject:SetActive(false);
        end
    end
end
