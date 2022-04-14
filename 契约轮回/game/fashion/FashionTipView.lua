FashionTipView = FashionTipView or class("FashionTipView", BaseModelTipView)
local this = FashionTipView

function FashionTipView:ctor(parent_node, layer)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)

    self.abName = "fashion"
    self.assetName = "FashionTipView"
    self.layer = layer

    --self.model = EquipModel:GetInstance()
    self.btnSettors = {}
    self.events = {}
    self.click_bg_close = true
    self.height = 0
    self.item_list = {}
    FashionTipView.super.Load(self)
end

function FashionTipView:dctor()
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
    if self.role_model then
        self.role_model:destroy()
        self.role_model = nil
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

function FashionTipView:LoadCallBack()
    self.nodes = {
        "model_parent", "power", "ScrollView/Viewport/Content", "valueTemp", "btns",
        "model_parent/name", "bg", "model_parent/model_bg", "ScrollView",

        --后面新加的
        "item_type_label", "isown", "model_parent/namebg", "item_level_label",
        "item_level", "item_type", "ownText", "title", "title2", "icon","scroll_des/Viewport/des_content/item_des",
    }
    self:GetChildren(self.nodes)
    self.valueTempTxt = GetText(self.valueTemp)
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')
    self.modelbgRectTra = self.model_bg:GetComponent('RectTransform')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
    self.scrollViewRectTra = self.ScrollView:GetComponent('RectTransform')
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

function FashionTipView:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function FashionTipView:SetData(data)

end



--param包含参数
--cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
--p_item 服务器给的，服务器没给，只传cfg就好
--operate_param --操作参数
function FashionTipView:ShowTip(param)
    self.cfg = param["cfg"]

    self.item_cfg = Config.db_item[self.cfg.id]
    self.goods_item = param["p_item"]
    self.operate_param = param["operate_param"]
    self.model = param["model"]
    self.uid = self.goods_item ~= nil and self.goods_item.uid or nil
    self.item_id = self.item_cfg.id
end

function FashionTipView:UpdateView()
    if type(self.operate_param) then
        self:AddOperateBtns()
    end

    self:SetSth();
    self:SetAttr()
    self:SetUseway(self.item_cfg.useway .. "\n")
    self:SetJump(self.item_cfg.gainway, self.item_cfg.gainwayitem)
    self:SetViewPosition()
    self:ShowModel()
    self:SetNameBg(self.item_cfg.color)
    self:DealCreateAttEnd()
end

function FashionTipView:SetNameBg(quality)
    lua_resMgr:SetImageTexture(self, self.namebg, "equip_image", "equip_q_bg_" .. quality, true)
end

function FashionTipView:SetSth()
    if self.item_cfg and self.cfg then
        self.name.text = self.cfg.name;
        self.item_type.text = enumName.ITEM_STYPE[self.item_cfg.stype] or "";
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

function FashionTipView:ShowModel()
    local cfg = self.cfg
    local gender = RoleInfoModel.GetInstance():GetSex()
    local tip_key = cfg.tip_key
    local fashioncfg = Config.db_fashion[tip_key]
    local max_star = fashioncfg.max_star

    local model = 0
    if gender == 1 then
        model = fashioncfg.man_model
    else
        model = fashioncfg.girl_model
    end
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local data = {}
    data = clone(role)
    local config = {}
    if fashioncfg.type_id == 1 then
        data.figure['fashion_clothes'] = {}
        data.figure["fashion_clothes"].model = model
        data.figure["fashion_clothes"].show = true
        if not data.figure.fashion_head then
            data.figure.fashion_head = {}
            data.figure.fashion_head.model = role.gender == 2 and 12001 or 11001
            data.figure.fashion_head.show = true
        end
        if not data.figure.weapon then
            data.figure.weapon = {}
            data.figure.weapon.model = role.gender == 2 and 12001 or 11001
            data.figure.weapon.show = true
        end
    elseif fashioncfg.type_id == 2 then
        data.figure.fashion_head = {}
        data.figure.fashion_head.model = model
        data.figure.fashion_head.show = true
        if not data.figure.weapon then
            data.figure.weapon = {}
            data.figure.weapon.model = role.gender == 2 and 12001 or 11001
            data.figure.weapon.show = true
        end
    elseif fashioncfg.type_id == 3 then
        --dump(data.figure, "<color=#6ce19b>LoadRoleModel   LoadRoleModel  LoadRoleModel  LoadRoleModel</color>")
        data.figure.weapon = {}
        data.figure.weapon.model = model
        data.figure.weapon.show = true
        if not data.figure.fashion_head then
            data.figure.fashion_head = {}
            data.figure.fashion_head.model = role.gender == 2 and 12001 or 11001
            data.figure.fashion_head.show = true
        end
    end
    config.yPos = -78;
    self.role_model = UIRoleCamera(self.model_parent, nil, data, 4, nil, nil, config)
end

function FashionTipView:SetUseway(useway)
    if useway ~= "\n" and not string.isempty(useway) then
        self.valueTempTxt.text = useway

        local att = { title = ConfigLanguage.Goods.UseWay, info = useway, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 24
    end
end

function FashionTipView:SetAttr()
    local cfg = self.cfg
    local tip_key = cfg.tip_key
    local fashioncfg = Config.db_fashion[tip_key]
    --local max_star = fashioncfg.max_star
    local pfashion = FashionModel:GetInstance():GetFashionInfoById(fashioncfg.id)
    local star = 0
    local key = string.format("%s@%s", fashioncfg.id, star)
    local fashionstarcfg = Config.db_fashion_star[key]
    local next_fashionstarcfg
    local next_baseArrt = {}
    local ownFlag = false;
    if pfashion then
        local next_key = string.format("%s@%s", fashioncfg.id, star + 1)
        next_fashionstarcfg = Config.db_fashion_star[next_key]
        if next_fashionstarcfg then
            next_baseArrt = EquipModel.GetInstance():FormatAttr(next_fashionstarcfg.attrib or "")
            ownFlag = true;
        end
    end
    local baseAttr = String2Table(fashionstarcfg.attrib)
    if not table.isempty(baseAttr) then
        local height = 0
        local index = 1
        for k, v in pairs(baseAttr) do
            local item = ComTipAttrItem(self.Content)
            item:SetData(v[1], v[2], index, next_baseArrt[v[1]])
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
    self.height = self.height + 20
    self.power.text = GetPowerByConfigList(baseAttr, {})
end


--跳转
function FashionTipView:SetJump(jump, icon)
    if not string.isempty(jump) and jump ~= "{}" then
        local height = 110
        self.jumpItemSettor = GoodsJumpItemSettor(self.Content)
        self.jumpItemSettor:CreateJumpItems(jump, self.height, icon)

        self.height = self.height + height
    end
end
