--[[
交易界面
liuyingshuai
2014年10月23日
]]

_G.UIDeal = BaseSlotPanel:new("UIDeal");

function UIDeal:Create()
    self:AddSWF("dealPanel.swf", true, "center");
end

function UIDeal:OnLoaded( objSwf )
    objSwf.maskL.visible = false;
    objSwf.maskR._visible = false;
    objSwf.listL.slotRollOver   = function(e) self:OnHisItemRollOver(e); end
    objSwf.listR.slotRollOver   = function(e) self:OnMyItemRollOver(e); end
    objSwf.listL.slotRollOut    = function() self:OnItemRollOut(); end
    objSwf.listR.slotRollOut    = function() self:OnItemRollOut(); end
    objSwf.btnClose.click       = function() self:OnBtnCloseClick(); end
    objSwf.btnLock.click        = function() self:OnBtnLockClick(); end
    objSwf.btnLock.rollOver     = function() self:OnBtnLockOver(); end
    objSwf.btnLock.rollOut      = function() self:OnBtnLockOut(); end
    objSwf.btnConfirm.click     = function() self:OnBtnConfirmClick(); end
    objSwf.btnCancel.click      = function() self:OnBtnCancelClick(); end
    objSwf.goldInput.textChange = function() self:OnMoneyInput(); end
    objSwf.goldInput.restrict   = "0-9\\\\";
    objSwf.txtDealTitle.text    = StrConfig['deal9'];
    --初始化格子
    for i = 1, DealConsts.NumSlots do
        local item = objSwf["itemR" .. i];
        local slot = item.itemSlot;
        if slot then
            local slotItem = BaseItemSlot:new(slot);
            self:AddSlotItem( slotItem, i );
        end
    end
end

function UIDeal:OnDelete()
	self:RemoveAllSlotItem();
end

function UIDeal:GetWidth()
    return 529;
end

function UIDeal:GetHeight()
    return 657;
end

function UIDeal:IsTween()
    return true;
end

function UIDeal:GetPanelType()
    return 0;
end

function UIDeal:IsShowSound()
    return true;
end


function UIDeal:OnShow()
    self:UpdateShow();
end

function UIDeal:UpdateShow()
    self:ShowMyMoney();
    self:ShowHisMoney();
    self:ShowHisItems();
    self:ShowMyItems();
    self:ShowMyLockState();
    self:ShowHisLockState();
    self:ShowHisInfo();
    self:UpdateBtns();
end

function UIDeal:OnHide(name)
    self:StopInputTimer();
    DealController:CancelDeal()
end

function UIDeal:ShowMyMoney()
    local objSwf = self.objSwf;
    if not objSwf then return end
    objSwf.goldInput.text = DealModel:GetMyMoney();
end

function UIDeal:ShowHisMoney()
    local objSwf = self.objSwf;
    if not objSwf then return end
    objSwf.txtMoney.text = DealModel:GetHisMoney();
end

function UIDeal:ShowMyItems()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local list = objSwf.listR;
    local items = DealModel:GetMyItemList();
    UIDeal:ShowItems(list, items)
end

function UIDeal:ShowHisItems()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local list = objSwf.listL;
    local items = DealModel:GetHisItemList();
    UIDeal:ShowItems(list, items)
end

function UIDeal:ShowMyLockState()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local effect = objSwf.maskEffectR;
    objSwf.maskR._visible = DealModel:IsLocked();
end

function UIDeal:ShowHisLockState()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local effect = objSwf.maskEffectL;
    objSwf.maskL._visible = DealModel:IsHeLocked();
end

function UIDeal:ShowHisInfo()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local info = DealModel:GetHisInfo();
    objSwf.txtName.text = info.name;
    objSwf.txtLvl.text = "LV." .. info.level;
end

function UIDeal:UpdateBtns()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local locked = DealModel:IsLocked();
    local allLocked = locked and DealModel:IsHeLocked();
    local confirmed = DealModel:IsConfirmed();
    objSwf.btnLock.disabled = confirmed;
    objSwf.btnLock.label = locked and StrConfig['deal3'] or StrConfig['deal2'];
    objSwf.btnConfirm.disabled = not allLocked or confirmed;
end

-- @param uiList:ScrollingList
-- @param items:DealModel中主玩家或者对方的交易物品列表
function UIDeal:ShowItems(uiList, items)
    uiList.dataProvider:cleanUp();
    for pos, item in pairs(items) do
        uiList.dataProvider:push( item:GetUIData() );
    end
    uiList:invalidateData();
end


------------------------------按钮事件，输入框事件处理----------------------------------------

--点击关闭面板
function UIDeal:OnBtnCloseClick()
    self:Hide();
end

--点击锁定按钮
function UIDeal:OnBtnLockClick()
    if DealModel:IsLocked() then
        DealController:UnlockPanel();
    else
        DealController:LockPanel();
    end
end

--悬浮锁定按钮
function UIDeal:OnBtnLockOver()
    TipsManager:ShowBtnTips( StrConfig["deal7"] );
end

--滑离锁定按钮
function UIDeal:OnBtnLockOut()
    TipsManager:Hide();
end

--点击交易按钮
function UIDeal:OnBtnConfirmClick()
    DealController:ConfirmDeal();
end

--点击取消按钮
function UIDeal:OnBtnCancelClick()
    DealController:CancelDeal();
end

--金币输入
function UIDeal:OnMoneyInput()
    self:DoMoneyInput();
end

local timerKey = nil;
function UIDeal:DoMoneyInput()
    local objSwf = self.objSwf;
    if not objSwf then return; end
    DealController:UnlockPanel();
    local inputMoney = tonumber( objSwf.goldInput.text ) or 0; -- 输入的钱
    local myMoney = DealModel:GetMyMoney();
    local totalMoney = MainPlayerModel.humanDetailInfo.eaUnBindGold + myMoney;
    if inputMoney > totalMoney then
        objSwf.goldInput.text = totalMoney;
        self:DoMoneyInput();
        FloatManager:AddCenter( StrConfig['deal8'] );
        return;
    end
    ------------------延时同步到服务器---------------
    self:PostponeInput(inputMoney);
end

function UIDeal:PostponeInput( inputMoney )
    self:StopInputTimer();
    local func = function()
        DealController:InputMoney( inputMoney );
        self:StopInputTimer();
    end
    timerKey = TimerManager:RegisterTimer( func, DealConsts.MoneySendDelay, 1 );
end

function UIDeal:StopInputTimer()
    if timerKey then
        TimerManager:UnRegisterTimer( timerKey );
        timerKey = nil;
    end
end

function UIDeal:OnHisItemRollOver(e)
    local data = e.item;
    local hasItem = data.hasItem;
    if not hasItem then return end
    local pos = data.pos;
    local dealItemVO = DealModel:GetHisItem(pos);
    local itemTipsVO = dealItemVO:GetTipsVO();
	if not itemTipsVO then return; end
    TipsManager:ShowTips( itemTipsVO.tipsType, itemTipsVO, itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown );
end

function UIDeal:OnMyItemRollOver(e)
    local data = e.item;
    local hasItem = data.hasItem;
    if not hasItem then return end
    local pos = data.pos;
    local dealItemVO = DealModel:GetMyItem(pos);
    local itemTipsVO = dealItemVO:GetTipsVO();
	if not itemTipsVO then return; end
    TipsManager:ShowTips( itemTipsVO.tipsType, itemTipsVO, itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown );
end

function UIDeal:OnItemRollOut()
    TipsManager:Hide();
end

------------------------------------------------------拖拽处理----------------------------------------

--开始拖拽item
function UIDeal:OnItemDragBegin(item)
    TipsManager:Hide();
    UIDealOper:Hide();
end

--结束拖拽item
function UIDeal:OnItemDragEnd(item)
    --鼠标当前位置
    local mousePos = UIManager:GetMousePos();
    local x1, y1 = self:GetPos("UIDeal");
    local x2, y2 = x1 + self:GetWidth(), y1 + self:GetHeight();
    if mousePos.x > x1 and mousePos.x < x2 and mousePos.y > y1 and mousePos.y < y2 then
        return;
    end
    local itemData = item:GetData();
    if itemData then
        DealController:PullOffShelves(itemData.pos);
    end
end

--正在拖拽item
function UIDeal:OnItemDragIn( fromData, toData )
    if fromData.bindState == BagConsts.Bind_Bind then
         --提示绑定物品无法交易
        FloatManager:AddCenter( StrConfig["deal5"] );
    else
        DealController:PutOnShelvesByPos( fromData.pos, toData.pos );
    end
end

--点击Item
function UIDeal:OnItemClick(item)
    --显示功能菜单
    TipsManager:Hide();
    local itemData = item:GetData();
    if not itemData.hasItem then
        UIDealOper:Hide();
        return;
    end
    UIDealOper:Open( item.mc, itemData.pos );
end

--右键点击Item
function UIDeal:OnItemRClick(item)
    TipsManager:Hide();
    UIDealOper:Hide();
    local itemData = item:GetData();
    if not itemData.hasItem then
        return;
    end
    DealController:PullOffShelves( itemData.pos );
end

--获取接受的拖入类型
function UIDeal:GetDragAcceptType()
    return BagConsts.AllDragType;
end


----------------------------------------------  消息处理  ---------------------------------------------

function UIDeal:ListNotificationInterests()
    return {
        NotifyConsts.DealMeState,
        NotifyConsts.DealMeItem,
        NotifyConsts.DealMeMoney,
        NotifyConsts.DealHeState,
        NotifyConsts.DealHeItem,
        NotifyConsts.DealHeMoney,
        NotifyConsts.DealHeInfo
    };
end

function UIDeal:HandleNotification(name,body)
    if name == NotifyConsts.DealMeState then
        self:OnStateChange();
    elseif name == NotifyConsts.DealHeState then
        self:OnStateChange();
    elseif name == NotifyConsts.DealHeInfo then
        self:ShowHisInfo();
    elseif name == NotifyConsts.DealHeItem then
        self:ShowHisItems();
    elseif name == NotifyConsts.DealHeMoney then
        self:ShowHisMoney();
    elseif name == NotifyConsts.DealMeItem then
        self:ShowMyItems();
    elseif name == NotifyConsts.DealMeMoney then
        self:ShowMyMoney();
    end
end

function UIDeal:OnStateChange()
    self:ShowMyLockState();
    self:ShowHisLockState()
    self:UpdateBtns();
end


