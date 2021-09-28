


LingYaoHeChengRightPanelCtr = class("LingYaoHeChengRightPanelCtr");

function LingYaoHeChengRightPanelCtr:New()
    self = { };
    setmetatable(self, { __index = LingYaoHeChengRightPanelCtr });
    return self
end

function LingYaoHeChengRightPanelCtr:Init(gameObject)

    self.gameObject = gameObject;

    self.completeBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "completeBt");

    self.btn_sub = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_sub");
    self.btn_add = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_add");

    self.proPanel_target = UIUtil.GetChildByName(self.gameObject, "Transform", "proPanel_target");
    self.proPanel1 = UIUtil.GetChildByName(self.gameObject, "Transform", "proPanel1");
   -- self.proPanel2 = UIUtil.GetChildByName(self.gameObject, "Transform", "proPanel2");

    self.proNumTxt1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "proNumTxt1");
    self.proNumTxt2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "proNumTxt2");
    self.attAddxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "attAddxt");

    self.txtnumIpnut = UIUtil.GetChildByName(self.gameObject, "Transform", "txtnumIpnut");
    self.txtnumIpnutLabel = UIUtil.GetChildByName(self.txtnumIpnut, "UILabel", "Label");

    self.proPanel_targetCtr = ProductCtrl:New();
    self.proPanel_targetCtr:Init(self.proPanel_target, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);

    self.proPanel1Ctr = ProductCtrl:New();
    self.proPanel1Ctr:Init(self.proPanel1, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);

    --[[
    self.proPanel2Ctr = ProductCtrl:New();
    self.proPanel2Ctr:Init(self.proPanel2, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);
    ]]
    self.proPanel_targetCtr:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    self.proPanel1Ctr:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    --self.proPanel2Ctr:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self._onClickCompleteBt = function(go) self:_OnClickCompleteBt(self) end
    UIUtil.GetComponent(self.completeBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCompleteBt);

    self._onClickbtn_sub = function(go) self:_OnClickbtn_sub(self) end
    UIUtil.GetComponent(self.btn_sub, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_sub);

    self._onClickbtn_add = function(go) self:_OnClickbtn_add(self) end
    UIUtil.GetComponent(self.btn_add, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_add);

    self._onClicktxtnumIpnut = function(go) self:_OnClicktxtnumIpnut(self) end
    UIUtil.GetComponent(self.txtnumIpnut, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClicktxtnumIpnut);

    self.txtnumIpnutLabel.text = "1";

    --  这里有问题
    MessageManager.AddListener(LingYaoHeProItem, LingYaoHeProItem.MESSAGE_PRODUCTS_SELECTED_CHANGE, LingYaoHeChengRightPanelCtr.SelectedChange, self);

    self.canComNum = 0;

end

function LingYaoHeChengRightPanelCtr:_OnClicktxtnumIpnut()

    local res = { };
    res.hd = LingYaoHeChengRightPanelCtr.NumberKeyHandler;
    res.confirmHandler = LingYaoHeChengRightPanelCtr._ConfirmHandler;

    res.hd_target = self;

    res.x = 370;
    res.y = 0;
    res.label = self.txtnumIpnutLabel;
    ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function LingYaoHeChengRightPanelCtr:_ConfirmHandler(v)

    if self.currSelectTarget == nil then
        return;
    end

   --  log("-------------LingYaoHeChengRightPanelCtr:_ConfirmHandler------------- " .. v);

    if v == "0" then
        v = 1;
    end

    self.txtnumIpnutLabel.text = "" .. v;

    --[[
    local txt_str = self.txtnumIpnutLabel.text;
    local tem = txt_str + 0;


    local b = self:CheckCanBuy(tem);

    local res = nil;

    if b then
        res = tem;
    else
        res = txt_str;
        if res == "" then
            res = "1";
        end
    end

    self.txtnumIpnutLabel.text = res;
    ]]

    self:SelectedChange(self.currSelectTarget, false)

end

function LingYaoHeChengRightPanelCtr:_OnClickbtn_sub()

    if self.currSelectTarget == nil then
        return;
    end

    --[[
    local tem_str = self.txtnumIpnutLabel.text;
    tem_str = tem_str - 1;
    if tem_str < 1 then
        tem_str = 1;
    end
    ]]
     local tem_str = 1;
    self.txtnumIpnutLabel.text = tem_str .. "";

    self:SelectedChange(self.currSelectTarget, false)

end

-- 获取 最大数量
function LingYaoHeChengRightPanelCtr:_OnClickbtn_add()

    if self.currSelectTarget == nil then
        return;
    end

    local tem_str = 9999999999;

    self.txtnumIpnutLabel.text = tem_str .. "";

    self:SelectedChange(self.currSelectTarget, false)
end


function LingYaoHeChengRightPanelCtr:NumberKeyHandler(v)

    local res = v .. "";
    self.txtnumIpnutLabel.text = res;

end

function LingYaoHeChengRightPanelCtr:CheckCanBuy(num)

    num = num + 0;
    if num > self.canComNum then
        return false;
    end
    return true;
end


function LingYaoHeChengRightPanelCtr:_OnClickCompleteBt()

    local num_v = self.txtnumIpnutLabel.text + 0;

    if self.canComNum > 0 then
        local spId = self.currSelectdata.id;
        LingYaoProxy.TryComLingYao(spId, num_v)

    else

        MsgUtils.ShowTips("LingYao/LingYaoHeChengRightPanelCtr/label1");
    end
end



function LingYaoHeChengRightPanelCtr:SelectedChange(target, needReset)

    if needReset == true then
        self.txtnumIpnutLabel.text = "1";
    end

    self.currSelectTarget = target;
    self.currSelectdata = target.data;

    local spId = self.currSelectdata.id;
    local selectInfo = ProductManager.GetProductInfoById(spId, 1);
    local elixirCf = LingYaoDataManager.Get_elixirCf(spId);

    self.proPanel_targetCtr:SetData(selectInfo)


    self.attAddxt.text = elixirCf.att_des;

    -------------------------------------------------------
    local syn_material = elixirCf.syn_material;

    local canComNum1 = self:SetNeedmaterial(syn_material, 1);
   -- local canComNum2 = self:SetNeedmaterial(syn_material, 2);


    -------------------  设置 可 合成 最大数量  ----------------------------------
    --[[
    if canComNum1 > canComNum2 then
        self.canComNum = canComNum2;
    else
        self.canComNum = canComNum1;
    end
    ]]
    self.canComNum = canComNum1;

    if self.canComNum < 1 then
        self.canComNum = 1;
    end

    local temam = self.txtnumIpnutLabel.text + 0;

    if temam > self.canComNum then
        self.txtnumIpnutLabel.text = "" .. self.canComNum;
    end

    -- 更新上限
    self:SetNeedmaterial(syn_material, 1);
   -- self:SetNeedmaterial(syn_material, 2);

end

function LingYaoHeChengRightPanelCtr:SetNeedmaterial(list, index)

    local str = list[index];
    local infoArr = ConfigSplit(str);
    local spId = infoArr[1] + 0;

    local num_v = self.txtnumIpnutLabel.text + 0;

    local am = infoArr[2] + 0;
    local pam = num_v * am;

    local pinfo = ProductManager.GetProductInfoById(spId, 1);
    local total_num_in_bag = BackpackDataManager.GetProductTotalNumBySpid(spId);

    self["proPanel" .. index .. "Ctr"]:SetData(pinfo);

    local proNumTxt = self["proNumTxt" .. index];

    if total_num_in_bag >= pam then
        proNumTxt.text = "[77ff47]" .. total_num_in_bag .. "/" .. pam .. "[-]";
    else
        proNumTxt.text = "[ff4b4b]" .. total_num_in_bag .. "/" .. pam .. "[-]";
    end

    local canCompMaxNum = math.floor(total_num_in_bag / am);

    return canCompMaxNum;

end

function LingYaoHeChengRightPanelCtr:UpInfos()
   
   if self.currSelectTarget ~= nil then
     self:SelectedChange(self.currSelectTarget, false);
   end
    

end


function LingYaoHeChengRightPanelCtr:Show()

    self.gameObject.gameObject:SetActive(true);
end

function LingYaoHeChengRightPanelCtr:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function LingYaoHeChengRightPanelCtr:Dispose()

    MessageManager.RemoveListener(LingYaoHeProItem, LingYaoHeProItem.MESSAGE_PRODUCTS_SELECTED_CHANGE, LingYaoHeChengRightPanelCtr.SelectedChange);

    UIUtil.GetComponent(self.completeBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickCompleteBt = nil;


    UIUtil.GetComponent(self.btn_sub, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btn_add, "LuaUIEventListener"):RemoveDelegate("OnClick");


    UIUtil.GetComponent(self.txtnumIpnut, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.proPanel_targetCtr:Dispose();

    self.proPanel1Ctr:Dispose();

   -- self.proPanel2Ctr:Dispose();


    self._onClickbtn_sub = nil;
    self._onClickbtn_add = nil;
    self._onClicktxtnumIpnut = nil;

    self.gameObject = nil;



    self.completeBt =  nil;

    self.btn_sub =  nil;
    self.btn_add = nil;

    self.proPanel_target =  nil;
    self.proPanel1 =  nil;
   -- self.proPanel2 =  nil;

    self.proNumTxt1 =  nil;
    self.proNumTxt2 =  nil;
    self.attAddxt =  nil;

    self.txtnumIpnut =  nil;
    self.txtnumIpnutLabel =  nil;

    self.proPanel_targetCtr = nil;

    self.proPanel1Ctr =nil;

    --self.proPanel2Ctr = nil;


end