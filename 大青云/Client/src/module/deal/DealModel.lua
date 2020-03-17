--[[
交易 Model
haohu
2015年3月30日11:03:29
]]

_G.DealModel = Module:new();

-- 初始化
function DealModel:Init()
    self.myItems  = {};
    self.hisItems = {};
    for pos = 1, DealConsts.NumSlots do
        self.myItems[pos]  = DealItemVO:new(pos);
        self.hisItems[pos] = DealItemVO:new(pos);
    end
    self.myState  = DealConsts.State_None;
    self.hisState = DealConsts.State_None;
    self.myMoney  = 0;
    self.hisMoney = 0;
    self.hisInfo  = nil;
end

-----------------------------------------主玩家交易信息------------------------------------------
DealModel.myItems = nil;
DealModel.myState = nil;
DealModel.myMoney = nil;

--获取我的交易栏中的所有物品
function DealModel:GetMyItemList()
    return self.myItems;
end

--获取我的交易栏中对应位置的物品
function DealModel:GetMyItem(pos)
    return self.myItems[pos];
end

--获取自己交易状态
function DealModel:GetMyState()
    return self.myState;
end

--设置自己交易状态
function DealModel:SetMyState(state)
    if self.myState ~= state then
        self.myState = state
        self:sendNotification( NotifyConsts.DealMeState );
    end
end

function DealModel:AddMyState(state)
    local newState = bit.bor( self.myState, state );
    self:SetMyState( newState );
end

function DealModel:RemoveMyState(state)
    local newState = bit.band( self.myState, bit.bnot(state) );
    self:SetMyState( newState );
end

--自己放入物品
function DealModel:PutOnShelves(pos, vo)
    local itemVO = self.myItems[pos];
    if not itemVO then return end
    itemVO:InitByVO( vo );
    self:sendNotification( NotifyConsts.DealMeItem, pos );
end

--自己收回物品
function DealModel:PullOffShelves(pos)
    local itemVO = self.myItems[pos];
    if not itemVO then return end
    itemVO:Clear();
    self:sendNotification( NotifyConsts.DealMeItem, pos );
end

function DealModel:GetMyMoney()
    return self.myMoney;
end

--自己的金钱改变
function DealModel:SetMyMoney(money)
    if self.myMoney ~= money then
        self.myMoney = money;
        self:sendNotification( NotifyConsts.DealMeMoney, money );
    end
end

-----------------------------------------对方交易信息------------------------------------------

DealModel.hisItems = nil;
DealModel.hisState = nil;
DealModel.hisMoney = nil;
DealModel.hisInfo  = nil;


--获取对方的交易栏中的所有物品
function DealModel:GetHisItemList()
    return self.hisItems;
end

--获取对方的交易栏中对应位置的物品
function DealModel:GetHisItem(pos)
    return self.hisItems[pos];
end

--获取对方交易状态
function DealModel:GetHisState()
    return self.hisState;
end

--设置对方交易状态
function DealModel:SetHisState(state)
    if self.hisState ~= state then
        self.hisState = state
        self:sendNotification( NotifyConsts.DealHeState );
    end
end

function DealModel:AddHisState(state)
    local newState = bit.bor( self.hisState, state );
    self:SetHisState( newState );
end

function DealModel:RemoveHisState(state)
    local newState = bit.band( self.hisState, bit.bnot(state) );
    self:SetHisState( newState );
end

--对方放入物品
function DealModel:HePutOnShelves(pos, vo)
    local itemVO = self.hisItems[pos];
    if not itemVO then return end
    itemVO:InitByVO( vo );
    self:sendNotification( NotifyConsts.DealHeItem, pos );
end

--对方收回物品
function DealModel:HePullOffShelves(pos)
    local itemVO = self.hisItems[pos];
    if not itemVO then return end
    itemVO:Clear();
    self:sendNotification( NotifyConsts.DealHeItem, pos );
end

function DealModel:GetHisMoney()
    return self.hisMoney;
end

--对方的金钱改变
function DealModel:SetHisMoney(money)
    if self.hisMoney ~= money then
        self.hisMoney = money;
        self:sendNotification( NotifyConsts.DealHeMoney, money );
    end
end

-- 获取对方信息
function DealModel:GetHisInfo()
    return self.hisInfo;
end

-- 对方信息
function DealModel:SetHisInfo( id, name, level )
    if not self.hisInfo then
        self.hisInfo = {}
    end
    self.hisInfo.id    = id;
    self.hisInfo.name  = name;
    self.hisInfo.level = level;
    self:sendNotification( NotifyConsts.DealHeInfo );
end

---------------------------------------------------------------------------------------------


-- --当前是否正在交易状态
-- function DealModel:IsInDeal()
--    return self:StateContain( self.myState, DealConsts.State_Start );
-- end

--当前是否正在锁定状态
function DealModel:IsLocked()
    return self:StateContain( self.myState, DealConsts.State_Lock );
end

--对方是否正在锁定状态
function DealModel:IsHeLocked()
    return self:StateContain( self.hisState, DealConsts.State_Lock );
end

--当前是否已经确认了交易
function DealModel:IsConfirmed()
    return self:StateContain( self.myState, DealConsts.State_Confirm );
end

-- --对方是否正在交易状态
-- function DealModel:IsHeInDeal()
--     return self:StateContain( self.hisState, DealConsts.State_Start );
-- end

-- --对方是否已经确认了交易
-- function DealModel:IsHeConfirmed()
--     return self:StateContain( self.hisState, DealConsts.State_Confirm );
-- end

--当前状态（currstate）中是否包含一种状态（state）
function DealModel:StateContain( currstate, state )
    return bit.band( currstate, state ) == state;
end