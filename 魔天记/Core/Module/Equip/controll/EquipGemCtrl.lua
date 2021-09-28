require "Core.Module.Equip.Item.EquipGemItem";

local EquipGemDisType = {
    embed = 1;-- 镶嵌
    pick = 2;-- 摘取
    punch = 3;-- 开孔
    lock = 4;
}

EquipGemCtrl = class("EquipGemCtrl")
function EquipGemCtrl:New()
    self = { };
    setmetatable(self, { __index = EquipGemCtrl });
    return self;
end

EquipGemCtrl.PUNCH_ITEM = 500004;



local insert = table.insert
local _sortfunc = table.sort 

function EquipGemCtrl:Init(transform, getEqTipPanel)
    self.currSelectKind = 1;
    self.transform = transform;
    self.gameObject = self.transform.gameObject;
    self.tipPanel = getEqTipPanel;
    self:_InitReference();
    self:_InitListener();
end


function EquipGemCtrl:_InitReference()
    -----------------
    self.rightPanel = UIUtil.GetChildByName(self.transform, "Transform", "rightPanel");

    self.panel1 = self.tipPanel;

    self.panel3 = UIUtil.GetChildByName(self.rightPanel, "Transform", "panel3");
    -----------------
    self._trsGemList = UIUtil.GetChildByName(self.panel3, "Transform", "trsGemList");
    --self._trsGemPunch = UIUtil.GetChildByName(self.panel3, "Transform", "trsGemPunch");

    self.eq_select = UIUtil.GetChildByName(self.rightPanel, "Transform", "panel3/eq_select");

    self.eq_selectCtr = SelectEquipPanelCtrl:New();
    self.eq_selectCtr:Init(self.eq_select.gameObject, 1, false);



    -- local equipGo = UIUtil.GetChildByName(self.panel3, "Transform", "eq_select");
    -- self.equipItem = PropsItem:New();
    -- self.equipItem:Init(equipGo.gameObject, nil);
    self._txtEquipName = UIUtil.GetChildByName(self.panel3, "UILabel", "txtEquipName");
    self._txtGemName = UIUtil.GetChildByName(self.panel3, "UILabel", "txtGemName");
    self._txtGemName2 = UIUtil.GetChildByName(self.panel3, "UILabel", "txtGemName2");

    local btns = UIUtil.GetComponentsInChildren(self.transform, "UIButton");
    self._btnZhaiqu = UIUtil.GetChildInComponents(btns, "btnZhaiqu");
    self._btnShengji = UIUtil.GetChildInComponents(btns, "btnShengji");
    self._btnXiangqian = UIUtil.GetChildInComponents(btns, "btnXiangQian");
    self._btnPunch = UIUtil.GetChildInComponents(btns, "btnPunch");
    self._btnCancel = UIUtil.GetChildInComponents(btns, "btnCancel");
    self._btnCompose = UIUtil.GetChildInComponents(btns, "btnCompose");

    self.currSelectKind = 1;
    --self:InitGemContent();
    self:InitGemSlot();
    self:InitGemList();

end

function EquipGemCtrl:_InitListener()
    self._onClickBtnZhaiqu = function(go) self:_OnClickBtnZhaiqu() end
    UIUtil.GetComponent(self._btnZhaiqu, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnZhaiqu);
    self._onClickBtnShengji = function(go) self:_OnClickBtnShengji() end
    UIUtil.GetComponent(self._btnShengji, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnShengji);
    self._onClickBtnXiangqian = function(go) self:_OnClickBtnXiangqian() end
    UIUtil.GetComponent(self._btnXiangqian, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnXiangqian);
    self._onClickBtnPunch = function(go) self:_OnClickBtnPunch() end
    UIUtil.GetComponent(self._btnPunch, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPunch);
    self._onClickBtnPunchCancel = function(go) self:_OnClickBtnPunchCancel() end
    UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPunchCancel);
    self._onClickBtnComp = function(go) self:_OnClickBtnComp() end
    UIUtil.GetComponent(self._btnCompose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComp);

    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_GEM_SELECT, self.OnGemItemClick, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_GEM_SLOT_CHG, self.OnGemSlotChg, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_GEM_CHG, self.OnGemChg, self);
    --MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, self.ProductsChange, self);
end

function EquipGemCtrl:Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self.eq_selectCtr:Dispose()
    self.eq_selectCtr = nil;

end

function EquipGemCtrl:_DisposeListener()
    UIUtil.GetComponent(self._btnZhaiqu, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnShengji, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnXiangqian, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnPunch, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnCompose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_GEM_SELECT, self.OnGemItemClick, self);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_GEM_SLOT_CHG, self.OnGemSlotChg, self);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_GEM_CHG, self.OnGemChg, self);
    --MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, self.ProductsChange, self);
end

function EquipGemCtrl:_DisposeReference()
    self._onClickBtnZhaiqu = nil;
    self._onClickBtnShengji = nil;
    self._onClickBtnXiangqian = nil;
    self._onClickBtnPunch = nil;
    self._onClickBtnPunchCancel = nil;
    self._onClickBtnComp = nil;

    self._gemList:Dispose();
    self._gemList = nil;

    for i, v in ipairs(self.gemSlots) do
        v:Dispose();
    end

    self.curEquip = nil;
    self.panel1 = nil;
    self.panel2 = nil;
    self.panel3 = nil;
    self.currSelectCtr = nil;
    self.equipSlot = nil;

    if (self.product_phalanx) then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end
    if (self.product_pd_phalanx) then
        self.product_pd_phalanx:Dispose();
        self.product_pd_phalanx = nil;
    end
end

-----------------------------------------

function EquipGemCtrl:EqPanelClickHandler(eqPanelControll)
    local kind = eqPanelControll.kind;
    self:LeftSelectIndex(kind);
end

function EquipGemCtrl:LeftSelectIndex(kind)
    self.currSelectKind = kind;
    local selectCtr = nil;
    for i = 1, 8 do
        if i == kind then
            selectCtr = self.eqPanelControlls[i];
            selectCtr:Selected(true);
        else
            self.eqPanelControlls[i]:Selected(false);
        end
    end
    self:CheckSelectCtr(selectCtr, kind);
end

function EquipGemCtrl:CheckSelectCtr(selectCtr, kind)

    self.currSelectCtr = selectCtr;

    if selectCtr ~= nil then

        if selectCtr._productInfo == nil then
            -- 装备栏没有装备  ,需要 到背包中 找对应的 可穿戴的装备， 如果 有，那么现实  穿戴 界面， 如果没有， 那么显示 装备获取来源 界面
            local me = HeroController:GetInstance();
            local heroInfo = me.info;

            local bag_equips = BackpackDataManager.GetFixMyEqByTypeAndKind(1, kind, heroInfo.kind);
            local t_num = table.getn(bag_equips);

            if t_num > 0 then
                -- 背包 里有对应的装备
                SetUIEnable(self.panel1, false);
                MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW);
                self.panel3.gameObject:SetActive(false);
                self:UpPanel2(bag_equips);
            else
                -- 背包里没有找到对应的装备
                SetUIEnable(self.panel1, true);
                MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
                self.panel3.gameObject:SetActive(false);
            end

        else
            SetUIEnable(self.panel1, false);
           MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
            self.panel3.gameObject:SetActive(true);
            self:UpPanel3()

            self.eq_selectCtr:SetProduct(selectCtr._productInfo)


        end

    end


end

function EquipGemCtrl:Updata(select_kind)
    for i = 1, 8 do
        local qx = EquipLvDataManager.getItem(i);
        self.eqPanelControlls[i]:SetData(qx, "slv");
    end
    self:LeftSelectIndex(select_kind);
end


-- 通过战力排序 和 品质  2  重排序
function EquipGemCtrl:sortByFightAndQuality(item)
    _sortfunc(item, function(a, b)

        if a:GetFight() == b:GetFight() then
            return a:GetQuality() > b:GetQuality()
        else
            return a:GetFight() > b:GetFight()
        end

    end )
    -- 从大到小排
    return item;
end

--[[
   1、按照装备战斗力进行排序，战斗力高的装备排在最前
   2、装备的战斗力相同时，按照装备的品质从低到高进行排序，装备品质从高到低分别为：白、绿、蓝、紫、金、红
   ]]
function EquipGemCtrl:GetEqBySort(bag_equips)

    return self:sortByFightAndQuality(bag_equips);
end

function EquipGemCtrl:UpPanel2(bag_equips)

    local eqs = self:GetEqBySort(bag_equips);
   
    MessageManager.Dispatch(EquipNotes,EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA,eqs);
end
-----------------------------------------
--[[
function EquipGemCtrl:InitGemContent()

    self.txtPunchDesc1 = UIUtil.GetChildByName(self._trsGemPunch, "UILabel", "txtPunchDesc1");
    self.txtPunchDesc2 = UIUtil.GetChildByName(self._trsGemPunch, "UILabel", "txtPunchDesc2");

    self.txtPunchDesc1.text = LanguageMgr.Get("equip/gem/punch/desc/1", { id = self.PUNCH_ITEM }, true);
    self:UpdatePunchItem();
end

function EquipGemCtrl:UpdatePunchItem()
    local itemNum = BackpackDataManager.GetProductTotalNumBySpid(self.PUNCH_ITEM);
    self.txtPunchDesc2.text = LanguageMgr.Get("equip/gem/punch/desc/2", { id = self.PUNCH_ITEM, num = itemNum }, true);
end
]]

function EquipGemCtrl:InitGemSlot()
    self.curEquip = nil;
    local gemSlots = { };
    self.onGemSlotClicks = { };
    for i = 1, 4 do
        local slotTr = UIUtil.GetChildByName(self.panel3, "Transform", "gemSlot" .. i);
        gemSlots[i] = EquipGemItem:New();
        gemSlots[i].pos = i;
        gemSlots[i]:Init(slotTr.gameObject);
        self.onGemSlotClicks[i] = function(slot)
            self:OnGemSlotClick(slot);
        end
        gemSlots[i]:SetOnClickHandler(self.onGemSlotClicks[i]);
    end
    self.gemSlots = gemSlots;
end

function EquipGemCtrl:InitGemList()
    self._gemPhalanx = UIUtil.GetChildByName(self.panel3, "LuaAsynPhalanx", "gem_phalanx", true);
    self._gemList = Phalanx:New();
    self._gemList:Init(self._gemPhalanx, EquipGemItem);

end

-- 入口
function EquipGemCtrl:UpPanel3()
    self.equipSlot = self.currSelectCtr;
    local equip = self.equipSlot._productInfo;
    if (self.curEquip ~= equip) then
        self.curSlot = nil;
    end
    self.curEquip = equip;
    self:UpdateEquipSlot();
end

function EquipGemCtrl:UpPanel4()
    self.panel3.gameObject:SetActive(false);
    self.panel4.gameObject:SetActive(true);
end

-- 更新装备孔数据
function EquipGemCtrl:UpdateEquipSlot()
    -- self.equipItem:UpdateItem(self.curEquip);
    -- self.equipItem:Selected(false);
    local info = self.curEquip;
    self._txtEquipName.text = ColorDataManager.GetColorTextByQuality(info:GetQuality(), info:GetName());
    self:UpdateGemSlot();
end

function EquipGemCtrl:UpdateGemSlot()

    self.equipGemType = { };
    -- 已装备的宝石类型
    local slotNum = VIPManager.GetMyGemSlotNum();

    self.equipSlot:UpdateGem();
    local lastZero = 0;
    local tmp = GemDataManager.GetSlotData(self.equipSlot.kind);
    for i = 4, 1, -1 do
        local gemId = tmp[i] or -1;
        if (gemId > 0) then
            local gem = ProductInfo:New();
            gem:Init( { spId = tmp[i], am = 1 });
            insert(self.equipGemType, gem:GetKind());
            self.gemSlots[i]:UpdateItem(gem);
        else
            self.gemSlots[i]:UpdateItem(nil);

            --根据vip显示锁
            if i > slotNum then
                gemId = -1;
            else
                gemId = 0;
            end
        end
        
        if (gemId < 0) then
            self.gemSlots[i]:SetLock(true);
        else
            self.gemSlots[i]:SetLock(false);
        end
        -- 写入宝石数据
        self.gemSlots[i].gemId = gemId;
        if (gemId == 0) then
            lastZero = i;
        end
    end

    -- 如果没有选宝石孔,选第一个
    if self.curSlot == nil then
        if (lastZero ~= 0) then
            self:OnGemSlotClick(self.gemSlots[lastZero]);
        else
            self:OnGemSlotClick(self.gemSlots[1]);
        end
    else
        -- 当前有宝石且有空镶嵌位
        if self.curSlot.gemId ~= 0 and lastZero ~= 0 then
            self:OnGemSlotClick(self.gemSlots[lastZero])
        else
            self:UpdateContent();
        end
    end
end

function EquipGemCtrl:OnGemSlotClick(slot)
    if (self.curSlot ~= slot) then
        local lastData = nil;

        if self.curSlot then
            lastData = self.curSlot.gemId;
        end

        self.curSlot = slot;
        for i = 1, 4 do
            self.gemSlots[i]:Selected(slot.pos == i);
        end

        if (lastData ~= slot.gemId) then
            self:UpdateContent();
        end
    elseif (slot.gemId < 0) then
        self._txtGemName.text = "";
        self:ShowContentCtl(EquipGemDisType.lock);
    end
end

function EquipGemCtrl:UpdateContent()
    local isLock = self.curSlot.gemId < 0;
    if isLock then
        -- 显示开孔
        self._txtGemName.text = "";
        self:ShowContentCtl(EquipGemDisType.lock);
    else
        local gem = self.curSlot:GetData();
        -- 显示列表
        if gem then
            local attrStr = "";
            local attr = GemDataManager.GetGemAttr(gem.spId);
            for k, v in pairs(attr) do
                attrStr = attrStr .. " " .. LanguageMgr.Get("attr/" .. k) .. " +" .. v;
            end

            local gemContent = LanguageMgr.GetColor(gem:GetQuality(), gem:GetName()) .. attrStr;
            self._txtGemName.text = gemContent;

            self:ShowContentCtl(EquipGemDisType.pick);
        else
            self._txtGemName.text = "";
            self:ShowContentCtl(EquipGemDisType.embed);
        end
        self:UpdateGemList();
    end
end

function EquipGemCtrl:PreSort(list)
    self.sortCache = { };
    for i, v in ipairs(list) do
        self.sortCache[v.spId] = i;
    end
end

function EquipGemCtrl:OnGemSort(a, b)
    local tmpA = false;
    local tmpB = false;
    local ak = a:GetKind();
    local bk = b:GetKind();
    for k, v in pairs(self.equipGemType) do
        if v == ak then
            tmpA = true;
        end

        if v == bk then
            tmpB = true;
        end
    end
    if (tmpA == tmpB) then
        return self.sortCache[a.spId] < self.sortCache[b.spId];
    end
    return not tmpA;
end

function EquipGemCtrl:OnGemSlotChg()
    if (self.gameObject and self.gameObject.activeSelf) then
        self:UpdateGemSlot();
    end
end

function EquipGemCtrl:OnGemChg()
    if (self.gameObject and self.gameObject.activeSelf) then
        for i, v in ipairs(self.gemSlots) do
            v:UpdateIcon();
        end
        self:UpdateGemList();
    end
end

function EquipGemCtrl:ProductsChange(args)
    --self:UpdatePunchItem();
end

-- 更新宝石列表数据
function EquipGemCtrl:UpdateGemList(force)
    if self.equipSlot == nil then
        return;
    end

    local cfg = self.curEquip:GetBaseConfig();
    -- 当前可装备的宝石类型
    local etype = cfg.gemtype;
    local list = GemDataManager.GetGemList(etype);
    self:PreSort(list);

    self.onGemSort = function(a, b)
        return self:OnGemSort(a, b);
    end

    _sortfunc(list, self.onGemSort);
    local count = table.getn(list);
    if (count > 0) then
        self._gemList:Build(math.ceil(count / 4), 4, list);

        local lastGem = nil;
        --[[
        if self.curGem ~= nil then
            for i,v in ipairs(list) do
                if(v.id == self.curGem.id) then
                    lastGem = v;
                    break;
                end
            end
        end
        ]]
        if lastGem then
            self:SetGemSelect(lastGem);
        else
            self:SetGemSelect(list[1]);
        end

    else
        self:SetGemSelect(nil);
        self._gemList:Build(1, 1, { });
    end
end

function EquipGemCtrl:OnGemItemClick(curItem)
    if (self.gameObject and self.gameObject.activeSelf) then
        self:SetGemSelect(curItem.data);
    end
end

function EquipGemCtrl:SetGemSelect(data)
    self.curGem = data;
    if data then
        local count = table.getn(self._gemList._items);
        for i = 1, count do
            local item = self._gemList._items[i].itemLogic;
            item:Selected(data == item.data);
        end

        local attrStr = "";
        local attr = GemDataManager.GetGemAttr(data.spId);
        for k, v in pairs(attr) do
            attrStr = attrStr .. " " .. LanguageMgr.Get("attr/" .. k) .. " +" .. v;
        end

        local gemContent = LanguageMgr.GetColor(data:GetQuality(), data:GetName()) .. attrStr;
        self._txtGemName2.text = gemContent;
    else
        self._txtGemName2.text = "";
    end

end

function EquipGemCtrl:ShowContentCtl(type)
    self.displayType = type;
    if (type == EquipGemDisType.embed) then
        -- self._trsGemList.gameObject:SetActive(true);
        --self._trsGemPunch.gameObject:SetActive(false);
        self._btnZhaiqu.gameObject:SetActive(false);
        self._btnShengji.gameObject:SetActive(false);
        self._btnXiangqian.gameObject:SetActive(true);
        -- self._btnPunch.gameObject:SetActive(false);
    elseif (type == EquipGemDisType.pick) then
        -- self._trsGemList.gameObject:SetActive(true);
        --self._trsGemPunch.gameObject:SetActive(false);
        self._btnZhaiqu.gameObject:SetActive(true);
        self._btnShengji.gameObject:SetActive(true);
        self._btnXiangqian.gameObject:SetActive(false);
        -- self._btnPunch.gameObject:SetActive(false);
    elseif (type == EquipGemDisType.punch) then
        -- self._trsGemList.gameObject:SetActive(false);
        --self._trsGemPunch.gameObject:SetActive(true);
        -- self._btnZhaiqu.gameObject:SetActive(false);
        -- self._btnShengji.gameObject:SetActive(false);
        -- self._btnXiangqian.gameObject:SetActive(false);
        -- self._btnPunch.gameObject:SetActive(true);
    elseif (type == EquipGemDisType.lock) then
        self._btnZhaiqu.gameObject:SetActive(false);
        self._btnShengji.gameObject:SetActive(false);
        self._btnXiangqian.gameObject:SetActive(false);
    end
end

--[[
    self.curEquip 当前的装备     self.equipSlot.kind 装备位置
    self.curSlot 当前的孔. pos (1-4) gemId(-1, 0 ,gemid)
    self.curGem 当前选择的宝石
]]
function EquipGemCtrl:_OnClickBtnXiangqian()
    local kind = self.currSelectCtr.kind
    local pos = self.curSlot.pos;
    SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_INLAY)
    -- log("镶嵌".. kind .. " - " .. pos .. " " .. self.curGem.id);
    if self.curGem then
        EquipProxy.ReqGemEmbed(kind, pos, self.curGem.id);
    else
        MsgUtils.ShowTips("error/gem/embed/noGem");
    end

end

function EquipGemCtrl:_OnClickBtnZhaiqu()
    -- local kind = self.currSelectCtr.kind;
    -- local pos = self.curSlot.pos;
    -- EquipProxy.ReqGemPick(kind, pos);

    self:_OnClickBtnTihuan();
end

function EquipGemCtrl:_OnClickBtnTihuan()
    if self.curGem then
        local kind = self.currSelectCtr.kind;
        local pos = self.curSlot.pos;

        local embedId = self.curGem.spId;
        local embedCfg = ConfigManager.GetProductById(embedId);

        local toGemId = self.gemSlots[self.curSlot.pos].gemId;
        if embedId == toGemId then
            MsgUtils.ShowTips("error/gem/embed/same");
            return;
        end

        EquipProxy.ReqGemEmbed(kind, pos, self.curGem.id);
    end
end

function EquipGemCtrl:_OnClickBtnShengji()

    if self.curSlot and self.curSlot.gemId >= 0 then
        local gemId = self.curSlot.gemId;

        local gemCfg = ConfigManager.GetProductById(gemId);
        if gemCfg.lev >= GemDataManager.MAX_LEV then
            MsgUtils.ShowTips("equip/gem/maxLev");
            return;
        end

        local _confirmShengji = function()
            self:_ConfirmShengji()
        end

        local enough = GemDataManager.CanUpgrade(gemId);
        if enough then
            MsgUtils.ShowConfirm(self, "equip/gem/comfirmUpLv", { id = self.curSlot.gemId }, _confirmShengji);
        else
            local count = 2 - math.clamp(GemDataManager.GetGemNumById(gemId), 0, 2);
            local priceCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GEM_PRICE)[gemCfg.lev];
            price = priceCfg.gem_price * count;
            MsgUtils.UseBDGoldConfirm(price, self, "equip/gem/shengji/noNum", nil, _confirmShengji);
        end
    end
end

function EquipGemCtrl:_ConfirmShengji()
    local kind = self.currSelectCtr.kind;
    local pos = self.curSlot.pos;

    EquipProxy.ReqGemShengji(kind, pos);
end

function EquipGemCtrl:_OnClickBtnPunch()
    local itemId = self.PUNCH_ITEM;
    local num = BackpackDataManager.GetProductTotalNumBySpid(itemId);
    if num > 0 then
        local kind = self.currSelectCtr.kind
        local pos = self.curSlot.pos;
        local item = BackpackDataManager.GetProductBySpid(itemId);
        EquipProxy.ReqGemPunch(kind, pos, item.id);
    else
        MsgUtils.ShowTips("error/gem/punch");
    end
    --self._trsGemPunch.gameObject:SetActive(false);
end

function EquipGemCtrl:_OnClickBtnPunchCancel()
    --self._trsGemPunch.gameObject:SetActive(false);
end

function EquipGemCtrl:_OnClickBtnComp()
    ModuleManager.SendNotification(EquipNotes.OPEN_GEMCOMPOSEPANEL);
end

