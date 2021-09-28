

XMBossFuLiRightPanelControll = class("XMBossFuLiRightPanelControll");



function XMBossFuLiRightPanelControll:New()
    self = { };
    setmetatable(self, { __index = XMBossFuLiRightPanelControll });
    return self
end


function XMBossFuLiRightPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    local btns = UIUtil.GetComponentsInChildren(self.gameObject, "UIButton");


    self._btnFenPei = UIUtil.GetChildInComponents(btns, "btnFenPei");

    self["_onClicktxtnumIpnut1"] = function(go) self:_OnClicktxtnumIpnut1(self) end
    self["_onClicktxtnumIpnut2"] = function(go) self:_OnClicktxtnumIpnut2(self) end
    self["_onClicktxtnumIpnut3"] = function(go) self:_OnClicktxtnumIpnut3(self) end

    self["_onClickbtn_sub1"] = function(go) self:_OnClickbtn_sub1(self) end
    self["_onClickbtn_sub2"] = function(go) self:_OnClickbtn_sub2(self) end
    self["_onClickbtn_sub3"] = function(go) self:_OnClickbtn_sub3(self) end

    self["_onClickbtn_add1"] = function(go) self:_OnClickbtn_add1(self) end
    self["_onClickbtn_add2"] = function(go) self:_OnClickbtn_add2(self) end
    self["_onClickbtn_add3"] = function(go) self:_OnClickbtn_add3(self) end


    for i = 1, 3 do
        self["setNumPanel" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "setNumPanel" .. i);
        self["product" .. i] = UIUtil.GetChildByName(self["setNumPanel" .. i], "Transform", "product");

        self["btn_sub" .. i] = UIUtil.GetChildByName(self["setNumPanel" .. i], "UIButton", "btn_sub");
        self["btn_add" .. i] = UIUtil.GetChildByName(self["setNumPanel" .. i], "UIButton", "btn_add");

        self["txtnumIpnut" .. i] = UIUtil.GetChildByName(self["setNumPanel" .. i], "Transform", "txtnumIpnut");
        self["txtnumIpnutLabel" .. i] = UIUtil.GetChildByName(self["txtnumIpnut" .. i], "UILabel", "Label");

        -- self["setNumPanel" .. i].gameObject:SetActive(false);
        self["setNumProCtr" .. i] = ProductCtrl:New();
        self["setNumProCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);
        self["setNumProCtr" .. i].fShowNumTxt = true;
        self["setNumProCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

        if XMBossFuLiItem.Def_FuLi[i] ~= nil then

            local info = ProductManager.GetProductInfoById(XMBossFuLiItem.Def_FuLi[i], 0);
            self["setNumProCtr" .. i]:SetData(info);

            self["txtnumIpnutLabel" .. i].text = "0";

        else
            self["setNumPanel" .. i].gameObject:SetActive(false);
        end





        UIUtil.GetComponent(self["txtnumIpnut" .. i], "LuaUIEventListener"):RegisterDelegate("OnClick", self["_onClicktxtnumIpnut" .. i]);

        UIUtil.GetComponent(self["btn_sub" .. i], "LuaUIEventListener"):RegisterDelegate("OnClick", self["_onClickbtn_sub" .. i]);
        UIUtil.GetComponent(self["btn_add" .. i], "LuaUIEventListener"):RegisterDelegate("OnClick", self["_onClickbtn_add" .. i]);


    end

    self._onClickBtnFenPei = function(go) self:_OnClickBtnFenPei(self) end
    UIUtil.GetComponent(self._btnFenPei, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFenPei);

end


function XMBossFuLiRightPanelControll:_OnClickBtnFenPei()


    if XMBossFuLiItem.currSelected == nil or XMBossFuLiItem.currSelected.data == nil then

        MsgUtils.ShowTips("XMBoss/XMBossFuLiRightPanelControll/label1");
    else

        local target_data = XMBossFuLiItem.currSelected.data;
        local pid = target_data.id;


        local sl = { };
        local n1 = { };
        local index = 1;

        for i = 1, 3 do
            local txt_str = self["txtnumIpnutLabel" .. i].text;
            local num_v = txt_str + 0;
            if num_v > 0 then

                sl[index] = XMBossFuLiItem.Def_FuLi[i];
                n1[index] = num_v;
                index = index + 1;
            end
        end

        if index > 1 then
            XMBossProxy.XMBossFenPeiPro(pid, sl, n1);
        else

            MsgUtils.ShowTips("XMBoss/XMBossFuLiRightPanelControll/label2");
        end

    end

end


--[[
l:{[spId：道具ID，num：数量]...} 仓库物品
l:{[spId：道具ID，num：数量,t:类型（1：金宝箱2：银宝箱3：节日宝箱）]...} 仓库物品
]]
function XMBossFuLiRightPanelControll:SetData(list)

    self.list = list;
    local t_num = table.getn(self.list);
    for i = 1, t_num do
        local obj = list[i];
        local t = obj.t;

        self:SetNumPro(obj, t);

    end

end


--[[

]]
function XMBossFuLiRightPanelControll:SetHasData(obj)

    local t = obj.t;

    local t_num = table.getn(self.list);
    for i = 1, t_num do
        local tem = self.list[i];
        if tem.t == t then
            self.list[i] = obj;
            return;
        end
    end

end

function XMBossFuLiRightPanelControll:UpData(l)

    local t_num = table.getn(l);
    for i = 1, t_num do
        local obj = l[i];
        self:SetHasData(obj)
    end

    self:SetData(self.list);

    for i = 1, 3 do
        self["txtnumIpnutLabel" .. i].text = "0";
    end

end


function XMBossFuLiRightPanelControll:SetNumPro(obj, i)

    local gobj = self["setNumPanel" .. i];

    local info = ProductManager.GetProductInfoById(obj.spId, obj.num);
    self["setNumProCtr" .. i]:SetData(info);

    XMBossFuLiItem.Def_FuLi[i] = obj.spId;

    -- gobj.gameObject:SetActive(true);

end





function XMBossFuLiRightPanelControll:GetNumInHas(idx)
    local t_num = table.getn(self.list);

    for i = 1, t_num do
        local obj = self.list[i];
        if obj.t == idx then
            return obj.num;
        end
    end
    return 0;
end

function XMBossFuLiRightPanelControll:CheckCanBuy(num, i)

    num = num + 0;

    local hasNum = self:GetNumInHas(i);

    if num > hasNum then
        return false;
    end

    return true;

end

function XMBossFuLiRightPanelControll:TryShowNumInput(index)

    self.currSelectIndex = index;
    local res = { };
    res.hd = XMBossFuLiRightPanelControll.NumberKeyHandler;
    res.confirmHandler = XMBossFuLiRightPanelControll._ConfirmHandler;

    res.hd_target = self;
    res.x = 370;
    res.y = 0;
    res.label = self["txtnumIpnutLabel" .. index];

    ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function XMBossFuLiRightPanelControll:_ConfirmHandler(v)


    local hasNum = self:GetNumInHas(self.currSelectIndex);
    if hasNum == 0 then
        MsgUtils.ShowTips("XMBoss/XMBossFuLiRightPanelControll/label3");
        return;
    end

    local b = self:CheckCanBuy(v, self.currSelectIndex);

    if b then
        self["txtnumIpnutLabel" .. self.currSelectIndex].text = v;
    else

        local hasNum = self:GetNumInHas(self.currSelectIndex);
        self["txtnumIpnutLabel" .. self.currSelectIndex].text = hasNum .. "";
    end

end

function XMBossFuLiRightPanelControll:NumberKeyHandler(v)

    local hasNum = self:GetNumInHas(self.currSelectIndex);
    if hasNum == 0 then
        MsgUtils.ShowTips("XMBoss/XMBossFuLiRightPanelControll/label3");
        return;
    end

    self["txtnumIpnutLabel" .. self.currSelectIndex].text = v;

end


function XMBossFuLiRightPanelControll:AddNum(index)


    local hasNum = self:GetNumInHas(index);
    if hasNum == 0 then

        MsgUtils.ShowTips("XMBoss/XMBossFuLiRightPanelControll/label3");
        return;
    end

    local txt_str = self["txtnumIpnutLabel" .. index].text;
    local v = txt_str + 1;

    local b = self:CheckCanBuy(v, index);

    if b then
        self["txtnumIpnutLabel" .. index].text = v .. "";
    end

end

function XMBossFuLiRightPanelControll:SunNum(index)

    local hasNum = self:GetNumInHas(index);
    if hasNum == 0 then

        MsgUtils.ShowTips("XMBoss/XMBossFuLiRightPanelControll/label3");
        return;
    end

    local txt_str = self["txtnumIpnutLabel" .. index].text;
    local v = txt_str + 0;


    if v >= 1 then
        v = v - 1;
        self["txtnumIpnutLabel" .. index].text = v .. "";
    end

end


function XMBossFuLiRightPanelControll:_OnClicktxtnumIpnut1()


    self:TryShowNumInput(1);

end

function XMBossFuLiRightPanelControll:_OnClicktxtnumIpnut2()
    self:TryShowNumInput(2);

end

function XMBossFuLiRightPanelControll:_OnClicktxtnumIpnut3()
    self:TryShowNumInput(3);

end

function XMBossFuLiRightPanelControll:_OnClickbtn_sub1()
    self:SunNum(1);

end

function XMBossFuLiRightPanelControll:_OnClickbtn_sub2()
    self:SunNum(2);

end

function XMBossFuLiRightPanelControll:_OnClickbtn_sub3()
    self:SunNum(3);

end



function XMBossFuLiRightPanelControll:_OnClickbtn_add1()
    self:AddNum(1);

end

function XMBossFuLiRightPanelControll:_OnClickbtn_add2()
    self:AddNum(2);

end

function XMBossFuLiRightPanelControll:_OnClickbtn_add3()
    self:AddNum(3);

end

------------------

function XMBossFuLiRightPanelControll:Dispose()

    UIUtil.GetComponent(self._btnFenPei, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFenPei = nil;

    for i = 1, 3 do

        self["setNumProCtr" .. i]:Dispose()
        UIUtil.GetComponent(self["txtnumIpnut" .. i], "LuaUIEventListener"):RemoveDelegate("OnClick");
        UIUtil.GetComponent(self["btn_sub" .. i], "LuaUIEventListener"):RemoveDelegate("OnClick");
        UIUtil.GetComponent(self["btn_add" .. i], "LuaUIEventListener"):RemoveDelegate("OnClick");


        self["_onClicktxtnumIpnut" .. i] = nil;

        self["_onClickbtn_sub" .. i] = nil;

        self["_onClickbtn_add" .. i] = nil;

        self["setNumPanel" .. i] = nil;
        self["product" .. i] = nil;

        self["btn_sub" .. i] = nil;
        self["btn_add" .. i] = nil;

        self["txtnumIpnut" .. i] = nil;
        self["txtnumIpnutLabel" .. i] = nil;

    end

    self._btnFenPei = nil;

end