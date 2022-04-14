MountTipView = MountTipView or class("MountTipView", BaseModelTipView)
local this = MountTipView

function MountTipView:ctor(parent_node, layer)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)

    self.abName = "mount"
    self.assetName = "MountTipView"
    self.layer = layer

    --self.model = EquipModel:GetInstance()
    self.btnSettors = {}
    self.events = {}
    self.click_bg_close = true
    self.height = 0
    self.item_list = {}
    MountTipView.super.Load(self)
end

function MountTipView:dctor()
    if self.jumpItemSettor ~= nil then
        self.jumpItemSettor:destroy()
    end
    for i = 1, #self.btnSettors do
        self.btnSettors[i]:destroy()
    end
    self.btnSettors = nil

    if self.baseAttrStr then
        self.baseAttrStr:destroy()
        self.baseAttrStr = nil
    end

    if self.rareAttrStr then
        self.rareAttrStr:destroy()
        self.rareAttrStr = nil
    end
    if self.uimodel then
        self.uimodel:destroy()
        self.uimodel = nil
    end
    GlobalEvent:RemoveTabListener(self.events)
    self.events = nil
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = nil

    if self.goodicon then
        self.goodicon:destroy()
    end
    self.goodicon = nil
end

function MountTipView:LoadCallBack()
    self.nodes = {
        "model_parent", "power", "ScrollView/Viewport/Content", "valueTemp", "btns",
        "model_parent/name", "bg", "model_parent/model_bg", "ScrollView",

        --后面新加的
        "item_type_label", "isown", "model_parent/namebg", "item_level_label",
        "item_level", "item_type", "ownText", "title", "title2", "icon","Scroll View/Viewport/item_des",
    }
    self:GetChildren(self.nodes)
    self.valueTempTxt = GetText(self.valueTemp)
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')
    self.modelbgRectTra = self.model_bg:GetComponent('RectTransform')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
    self.scrollViewRectTra = self.ScrollView:GetComponent('RectTransform')
    self.title = GetText(self.title);
    self.name = GetText(self.name)
    self.power = GetText(self.power)

    self.item_type = GetText(self.item_type);
    self.item_level = GetText(self.item_level);
    self.item_des = GetText(self.item_des);
    self.title = GetText(self.title);
    self.title2 = GetText(self.title2);
    self.ownText = GetText(self.ownText);
    self.namebg = GetImage(self.namebg)
    self.ownText.text = "";--已拥有  <color=#3AB50E>1</color>


    self:AddEvent()
    self:AddClickCloseBtn()
    self:UpdateView()
    self:SetOrderByParentMax()
end

function MountTipView:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function MountTipView:SetData(data)

end



--param包含参数
--cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
--p_item 服务器给的，服务器没给，只传cfg就好
--operate_param --操作参数
function MountTipView:ShowTip(param)
    self.cfg = param["cfg"]
    self.stype = param["stype"];
    self.item_cfg = Config.db_item[self.cfg.id]
    self.goods_item = param["p_item"]
    self.operate_param = param["operate_param"]
    self.model = param["model"]
    self.uid = self.goods_item ~= nil and self.goods_item.uid or nil
    self.item_id = self.item_cfg.id
end

function MountTipView:UpdateView()
    if type(self.operate_param) then
        self:AddOperateBtns()
    end

    self:SetSth();
    self:SetAttr()
    self:SetUseway(self.item_cfg.useway .. "\n")
    --self:SetJump(self.item_cfg.gainway, self.item_cfg.gainwayitem)
    self:SetViewPosition()
    self:ShowModel()
    self:SetNameBg(self.item_cfg.color)
    self:DealCreateAttEnd()
end

function MountTipView:SetNameBg(quality)
    lua_resMgr:SetImageTexture(self, self.namebg, "equip_image", "equip_q_bg_" .. quality, true)
end

function MountTipView:SetSth()
    if self.item_cfg and self.cfg then
        self.name.text = self.cfg.name;
        self.item_type.text =  self.item_cfg.type_desc --enumName.ITEM_STYPE[self.item_cfg.stype] or "";
        self.item_level.text = tostring(self.item_cfg.level or 0);
        self.item_des.text = tostring(self.item_cfg.desc);

        self.goodicon = GoodsIconSettorTwo(self.icon.transform);
        local param = {}
        --param["model"] = self.model;
        param["item_id"] = self.cfg.id;
        --param["num"] = num1;
        --param["can_click"] = true;
        param["bind"] = true;
        param["size"] = { x = 80, y = 80 }
        self.goodicon:SetIcon(param);
    end
end
function MountTipView:ShowModel()
    local cfg = self.cfg
    local gender = RoleInfoModel.GetInstance():GetSex()
    local tip_key = cfg.tip_key
    --local fashioncfg = Config.db_fashion[tip_key]
    --local max_star = fashioncfg.max_star
    --
    --local model = 0
    --if gender == 1 then
    --    model = fashioncfg.man_model
    --else
    --    model = fashioncfg.girl_model
    --end
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    --local data = {}
    --data = clone(role)
    --local config = {}

    local tip_key_tab = String2Table(tip_key);
    local morphConfig = self:GetMorphConfig(Config.db_mount_morph, tip_key);
    local modelRes = 0;
    local config = {};
    config.rotate = { x = 0, y = 180, z = 0 };
    config.offset = { x = 4000, y = 0, z = 0 };
    config.cameraPos = { x = -4000, y = 3000, z = 0 };
    config.far = 20;
    if self.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH then
        morphConfig = self:GetMorphConfig(Config.db_mount_morph, tip_key);
        modelRes = "model_mount_" .. morphConfig.res;
        config.rotate = { x = 0, y = 135, z = 0 };
        config.offset = { x = -2000, y = 2970, z = 0 };
        config.scale = { x = 80, y = 80, z = 80 };
        self.title.text = "Mount description";
        self.title2.text = "Mount attribute";
        config.istouch = true;
        config.carmera_size = 3
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH then
        tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
        morphConfig = Config.db_wing_morph[tonumber(tip_key)];
        modelRes = morphConfig.res;
        config.offset = { x = -2000, y = 3110, z = 0 };
        config.scale = { x = 70, y = 70, z = 70 };
        self.title.text = "Wing description";
        self.title2.text = "Wing attribute";
        config.istouch = true;
        if morphConfig and morphConfig.angle then
            config.rotate.y = morphConfig.angle
        end
	elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH then
	--	tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
		morphConfig = Config.db_baby_wing_morph[tonumber(tip_key)];
		modelRes = morphConfig.res;
		local scale = morphConfig.ratio * 5
		config.offset = { x = -2000, y = 3110, z = 0 };
		config.scale = { x = scale, y = scale, z = scale };
		self.title.text = "Wing description";
		self.title2.text = "Wing attribute";
		config.istouch = true;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH then
        morphConfig = Config.db_talis_morph[tonumber(tip_key)];
        modelRes = morphConfig.res;
        config.offset = { x = -2000, y = 3080, z = 0 };
        self.title.text = "Relic description";
        self.title2.text = "Relic attribute";
        config.istouch = true;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH then
        morphConfig = Config.db_weapon_morph[tonumber(tip_key)];
        modelRes = morphConfig.res;
        config.rotate = { x = 0, y = 180, z = 0 };
        config.offset = { x = -2000, y = 3110, z = 0 };
        self.title.text = "Artifact description";
        self.title2.text = "Artifact attribute";
        config.istouch = true;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH then
        --tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
        morphConfig = self:GetMorphConfig(Config.db_offhand_morph, tip_key);
        modelRes = "model_hand_" .. morphConfig.res;
        config.rotate = { x = 0, y = 0, z = 0 };
        config.offset = { x = -2000, y = 3110, z = 0 };
        config.trans_x = 400
        config.trans_y = 400
        config.trans_offset = {y=-58}
        config.carmera_size = 2
        self.title.text = "Off-hand description";
        self.title2.text = "Off-hand attribute";
        config.istouch = true;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH then
        morphConfig = self:GetMorphConfig(Config.db_god_morph, tip_key);
        modelRes = "model_soul_" .. morphConfig.res;
        --config.rotate = { x = morphConfig.ratio, y = morphConfig.ratio, z = morphConfig.ratio };
        config.offset = { x = -2000, y = 3050, z = 0 };
        config.scale = { x = morphConfig.ratio * 0.8, y = morphConfig.ratio * 0.8, z = morphConfig.ratio * 0.8 };
        self.title.text = "Avatar description";
        self.title2.text = "Avatar attribute";
        config.istouch = false;
    end

    self.uimodel = UIMountCamera(self.model_parent.transform, nil, modelRes, self.stype, nil, config.istouch);
    self.uimodel:SetConfig(config)
    --self.role_model = UIRoleCamera(self.model_parent, nil, data, 4, nil, nil, config)

    --self.uimodel = UIMountModel(self.model_parent.transform, modelRes, handler(self, self.LoadModelCallBack));
end

--function MountTipView:LoadModelCallBack()
--    if self.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH then
--        SetLocalPosition(self.uimodel.transform, -2108, -44, 394)
--        local v3 = self.uimodel.transform.localScale;
--        SetLocalScale(self.uimodel.transform, 100, 100, 100);
--        SetLocalRotation(self.uimodel.transform, 0, 180, 0);
--        --self.uimodel:AddAnimation({ "show", "idle2" }, false, "idle2", 0)
--        --self.uimodel.animator:CrossFade("idle2", 0)
--    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH then
--        SetLocalPosition(self.uimodel.transform, -2108, -61, 367)
--        local v3 = self.uimodel.transform.localScale;
--        SetLocalScale(self.uimodel.transform, 100, 100, 100);
--        SetLocalRotation(self.uimodel.transform, 0, 180, 0);
--        self.uimodel:AddAnimation({ "show", "idle" }, false, "idle", 0)
--    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH then
--        SetLocalPosition(self.uimodel.transform, -2108, -46, 210)
--        local v3 = self.uimodel.transform.localScale;
--        SetLocalScale(self.uimodel.transform, 100, 100, 100);
--        SetLocalRotation(self.uimodel.transform, 5.5, 180, -1.3);
--        self.uimodel:AddAnimation({ "show", "idle" }, false, "idle", 0)
--    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH then
--        SetLocalPosition(self.uimodel.transform, -2108, -46, 210)
--        local v3 = self.uimodel.transform.localScale;
--        SetLocalScale(self.uimodel.transform, 100, 100, 100);
--        SetLocalRotation(self.uimodel.transform, 5.5, 180, -1.3);
--        self.uimodel:AddAnimation({ "show", "idle2" }, false, "idle", 0)
--    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH then
--        SetLocalPosition(self.uimodel.transform, -2108, -46, 210)
--        local v3 = self.uimodel.transform.localScale;
--        SetLocalScale(self.uimodel.transform, 100, 100, 100);
--        SetLocalRotation(self.uimodel.transform, 5.5, 180, -1.3);
--        --self.uimodel:AddAnimation({ "show", "idle" }, false, "idle", 0)
--    end
--end

function MountTipView:SetUseway(useway)
    if useway ~= "\n" and not string.isempty(useway) then
        self.valueTempTxt.text = useway

        local att = { title = ConfigLanguage.Goods.UseWay, info = useway, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 24
    end
end

function MountTipView:SetAttr()
    local cfg = self.cfg
    local tip_key = cfg.tip_key
    local tip_key_tab = String2Table(cfg.tip_key);

    local stypeTab = {
        [enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH] = enum.TRAIN.TRAIN_MOUNT, -- 坐骑幻化
        [enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH] = enum.TRAIN.TRAIN_WING, -- 翅膀幻化
        [enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH] = enum.TRAIN.TRAIN_TALIS, -- 法宝幻化
        [enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH] = enum.TRAIN.TRAIN_WEAPON, -- 神兵幻化
        [enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH] = enum.TRAIN.TRAIN_OFFHAND, -- 副手幻化
        [enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH] = enum.TRAIN.TRAIN_GOD, --神灵幻化
		[enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH] = enum.TRAIN.TRAIN_BABYWING, --宝宝翅膀
    }

    local morphConfig, starTab = self:GetMorphStarConfig(tip_key);
    local morphData = nil
    if self.stype ~= enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH then
        morphData = MountModel:GetInstance():GetMorphDataByType(stypeTab[self.stype], morphConfig.id);
    else
        morphData = GodModel:GetInstance():IsGodActive(morphConfig.id);
    end

    --local starTab = Config.db_mount_star;
    local max_star = 0;
    if morphData then
        max_star = morphData.star or 0;
    end
    local key = string.format("%s@%s", morphConfig.id, max_star)
    local morphstarConfig = starTab[key]
    local baseAttr = String2Table(morphstarConfig.attrs)
    local next_config;
    local next_attr = {};
    local ownFlag = false;
    if morphData then
        local next_key = string.format("%s@%s", morphConfig.id, max_star + 1)
        next_config = starTab[next_key]
        if next_config then
            ownFlag = true
            next_attr = EquipModel.GetInstance():FormatAttr(next_config.attrs or "")
        end
    end
    if not table.isempty(baseAttr) then
        local height = 0
        local index = 1
        for k, v in pairs(baseAttr) do
            local item = ComTipAttrItem(self.Content)
            item:SetData(v[1], v[2], index, next_attr[v[1]])
            self.item_list[index] = item
            index = index + 1
            local item_height = item:GetHeight()
            self.height = self.height + item_height
            SetAnchoredPosition(item.transform, 0, height)
            height = height - item_height
        end
    end
    if ownFlag then
        self.ownText.text = "Owned";--已拥有  <color=#3AB50E>1</color>
    else
        self.ownText.text = "Not owned";
    end
    self.height = self.height + 26
    self.power.text = GetPowerByConfigList(baseAttr, {})
end


--跳转
function MountTipView:SetJump(jump, icon)
    if not string.isempty(jump) and jump ~= "{}" then
        local height = 110
        self.jumpItemSettor = GoodsJumpItemSettor(self.Content)
        self.jumpItemSettor:CreateJumpItems(jump, self.height, icon)

        self.height = self.height + height
    end
end

function MountTipView:GetMorphStarConfig(tip_key)
    local morphConfig = nil;
    local starTab = nil;
    local role = RoleInfoModel.GetInstance():GetMainRoleData();
    local tip_key_tab = String2Table(tip_key);
    if self.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH then
        morphConfig = self:GetMorphConfig(Config.db_mount_morph, tip_key);
        starTab = Config.db_mount_star;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH then
        tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
        morphConfig = Config.db_wing_morph[tip_key];
        starTab = Config.db_wing_star;
	elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH then
		--tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
		morphConfig = self:GetMorphConfig(Config.db_baby_wing_morph, tip_key);
		starTab = Config.db_baby_wing_star;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH then
        morphConfig = self:GetMorphConfig(Config.db_talis_morph, tip_key);
        starTab = Config.db_talis_star;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH then
        morphConfig = self:GetMorphConfig(Config.db_weapon_morph, tip_key);
        starTab = Config.db_weapon_star;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH then
        --tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
        morphConfig = self:GetMorphConfig(Config.db_offhand_morph, tip_key);
        starTab = Config.db_offhand_star;
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH then
        --tip_key = role.gender == 2 and tip_key_tab[2] or tip_key_tab[1]
        morphConfig = Config.db_god_morph[tonumber(tip_key)];
        starTab = Config.db_god_star;
    end
    return morphConfig, starTab;
end

function MountTipView:GetMorphConfig(tab, tip_key)
    for k, v in pairs(tab) do
        if tostring(v.id) == tip_key then
            return v;
        end
    end
    return nil;
end