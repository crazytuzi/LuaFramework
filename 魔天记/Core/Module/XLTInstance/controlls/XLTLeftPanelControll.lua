require "Core.Module.XLTInstance.View.item.FBMLTItem"

XLTLeftPanelControll = class("XLTLeftPanelControll");

function XLTLeftPanelControll:New()
    self = { };
    setmetatable(self, { __index = XLTLeftPanelControll });
    return self
end


function XLTLeftPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    self.rankBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "rankBt");
    self.awardBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "awardBt");

  
    self.taCengPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "taCengPanel");
    self.subPanel = UIUtil.GetChildByName(self.taCengPanel, "Transform", "subPanel");
    self.subPanelSc = UIUtil.GetChildByName(self.taCengPanel, "UIScrollView", "subPanel");
    self.mScrollBar = UIUtil.GetChildByName(self.taCengPanel, "UIScrollBar", "mScrollBar");

    self.pointTopFat = UIUtil.GetChildByName(self.taCengPanel, "Transform", "pointTopFat");
    self.pointBottomFat = UIUtil.GetChildByName(self.taCengPanel, "Transform", "pointBottomFat");

    self.scTopY = self.pointTopFat.position.y;
    self.scBtY = self.pointBottomFat.position.y;

    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");
    self._table = UIUtil.GetChildByName(self.subPanel, "Transform", "table");

    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local n_bfCflist = { };

    local hasShowNeedLvTip = false;

    local len = table.getn(bfCflist);
    for i = 1, len do
        bfCflist[i].cheng = i;
        if my_lv < bfCflist[i].level then
            if not hasShowNeedLvTip then
                bfCflist[i].needShowLvTip = true;
                hasShowNeedLvTip = true;
            end
        end

        n_bfCflist[len - i + 1] = bfCflist[i];
    end


    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, FBMLTItem);
    self.product_phalanx:Build(len, 1, n_bfCflist);

    self._onClickrankBt = function(go) self:_OnClickrankBt(self) end
    UIUtil.GetComponent(self.rankBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickrankBt);

    self._onClickawardBt = function(go) self:_OnClickawardBt(self) end
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickawardBt);

    self.subPanelSc.onDragStarted = function(go) self:onDragStarted(self) end
    self.subPanelSc.onStoppedMoving = function(go) self:onStoppedMoving(self) end

    self:UpTime();

    MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, XLTLeftPanelControll.ChuanGuanAwardLog, self);



end

function XLTLeftPanelControll:_Opened()

    self.baseY = 11306;
    self.mScrollBar.value=0;
    Util.SetLocalPos(self._table, 0, self.baseY, 0)
    --    self._table.localPosition = Vector3.New(0, self.baseY, 0);
    self:UpTime();

    self.subPanelSc.gameObject:SetActive(false);
    self.subPanelSc.gameObject:SetActive(true);
end

function XLTLeftPanelControll:onDragStarted()
    FixedUpdateBeat:Remove(self.UpTime, self)
    FixedUpdateBeat:Add(self.UpTime, self)
end

function XLTLeftPanelControll:onStoppedMoving()
    FixedUpdateBeat:Remove(self.UpTime, self)
end

function XLTLeftPanelControll:UpTime()

    -- 检测 在试图里面的对象
    local _items = self.product_phalanx._items;
    local len = table.getn(_items);
    for i = 1, len do
        _items[i].itemLogic:UpDrawCallByYY(self.scBtY, self.scTopY);
    end



end

function XLTLeftPanelControll:_OnClickrankBt()

    ModuleManager.SendNotification(RankNotes.OPEN_RANKPANEL, RankConst.Type.TOWER);

end

function XLTLeftPanelControll:_OnClickawardBt()
    --ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTCHUANGGUANAWARDPANEL);
    ModuleManager.SendNotification(StarNotes.OPEN_STAR_SHOW_PANEL)
end


function XLTLeftPanelControll:Show()

    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
    local baseFb_id = bfCflist[1].id;
    local hasPass = InstanceDataManager.GetHasPassById(baseFb_id);

    FBMLTItem.curr_can_play_fb = nil;

    local _items = self.product_phalanx._items;
    local len = table.getn(_items);
    local select_i = 0;
    for i = 1, len do
        local obj = _items[i].itemLogic;
        obj:UpHassPass(hasPass, baseFb_id);

        if FBMLTItem.curr_can_play_fb == obj then
            select_i = len - i;
        end

    end

    if select_i == 0 and hasPass ~= nil then
        -- 检查是否 已经全通过了
        select_i = hasPass.s - 1;
    end



    if select_i > 3 then
        Util.SetLocalPos(self._table, 0, self.baseY - 75 *(select_i - 2), 0)

        --        self._table.localPosition = Vector3.New(0, self.baseY - 75 *(select_i - 2), 0);
        self:UpTime();
    end



    self.gameObject.gameObject:SetActive(false);
    self.gameObject.gameObject:SetActive(true);

    self.subPanelSc.gameObject:SetActive(false);
    self.subPanelSc.gameObject:SetActive(true);



end

function XLTLeftPanelControll:ChuanGuanAwardLog(data)

    

end

function XLTLeftPanelControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function XLTLeftPanelControll:Dispose()


    UIUtil.GetComponent(self.rankBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, XLTLeftPanelControll.ChuanGuanAwardLog);


    self._onClickrankBt = nil;
    self._onClickawardBt = nil;

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end


    self.subPanelSc.onDragStarted = nil;
    self.subPanelSc.onStoppedMoving = nil;

    FixedUpdateBeat:Remove(self.UpTime, self)

    self.gameObject = nil;

    self.rankBt = nil;
    self.awardBt = nil;


    self.taCengPanel = nil;
    self.subPanel = nil;
    self.subPanelSc = nil;
    self.mScrollBar = nil;

    self.pointTopFat = nil;
    self.pointBottomFat = nil;

    self._item_phalanx = nil;
    self._table = nil;

end