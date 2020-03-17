--[[
交易逻辑控制
liuyingshuai
2014年10月23日
]]

_G.DealController = setmetatable( {}, {__index = IController} )
DealController.name = "DealController";

function DealController:Create()
    MsgManager:RegisterCallBack( MsgType.SC_ExchangeResp, self, self.OnDealStart );
    MsgManager:RegisterCallBack( MsgType.SC_ExchangeInvite, self, self.OnDealInvite );
    MsgManager:RegisterCallBack( MsgType.SC_ExchangeItemList, self, self.OnDealConentRsv );
    MsgManager:RegisterCallBack( MsgType.SC_ExchangeHandle, self, self.OnDealOper );
end

function DealController:BeforeEnterCross()
    UIDeal:Hide()
end

function DealController:OnEnterGame()
    DealModel:Init();
end

-------------------------------------------response--------------------------------------------


-- 请求交易返回结果
function DealController:OnDealStart(msg)
    DealModel:SetMyState( DealConsts.State_Start ); 
    DealModel:SetHisState( DealConsts.State_Start ); 
    DealModel:SetHisInfo( msg.roleID, msg.roleName, msg.level );
    UIDeal:Show();
    UIBag:Show();
end

--  被邀请交易
function DealController:OnDealInvite(msg)
    local roleID = msg.roleID
    if SetSystemModel:GetIsDeal() then -- 如果系统设置不可交易, 直接返回拒绝消息;
        self:ReplyInvite ( roleID, DealConsts.Reply_No );
        return;
    end
    -- 打开确认面板
    local cancelFunc = function()
        self:ReplyInvite ( roleID, DealConsts.Reply_No );
    end
    local confirmFunc = function()
        self:ReplyInvite( roleID, DealConsts.Reply_Yes );
    end
    local content = string.format( StrConfig['deal1'], msg.roleName );
    UIConfirm:Open( content, confirmFunc, cancelFunc, StrConfig['confirmName4'], StrConfig['confirmName5'] );
end

-- 交易物品列表
function DealController:OnDealConentRsv(msg)
    --新卓越属性，特殊处理
    for i,ao in ipairs(msg.ItemList) do 
        for p,vo in  ipairs(ao.newSuperList) do 
            if vo.id > 0  and vo.wash == 0 then 
                local cfg = t_zhuoyueshuxing[vo.id];
                vo.wash = cfg and cfg.val or 0;
            end;    
        end;
    end;
    --
    local roleID   = msg.roleID;
    local money    = msg.gold;
    local itemList = msg.ItemList;
    if roleID == MainPlayerController:GetRoleID() then
        DealModel:SetMyMoney( money );
        for _, vo in pairs( itemList ) do
            -- vo结构:
            -- tid         count           pos         strenLvl   
            -- strenVal    attrAddLvl      gropuId   groupId2 	group2Level   superNum    superList  
            vo.pos = vo.pos + 1; -- client从1开始，server从0开始
            local pos = vo.pos;
            if vo.tid == 0 then
                DealModel:PullOffShelves( pos );
            else
                DealModel:PutOnShelves( pos, vo );
            end
        end
    else
        DealModel:SetHisMoney( money );
        for _, vo in pairs( itemList ) do
            vo.pos = vo.pos + 1; -- client从1开始，server从0开始
            local pos = vo.pos;
            if vo.tid == 0 then
                DealModel:HePullOffShelves( pos );
            else
                DealModel:HePutOnShelves( pos, vo );
            end
        end
    end
end


-- 返回交易操作
function DealController:OnDealOper(msg)
    local oper   = msg.type;
    if oper == DealConsts.Oper_Cancel then --取消交易
        DealModel:Init();
        UIDeal:Hide(); --关闭面板
        return;
    end
    local roleID = msg.roleID;
    if roleID == MainPlayerController:GetRoleID() then
        if oper == DealConsts.Oper_Lock then --锁定
            DealModel:AddMyState( DealConsts.State_Lock );
        elseif oper == DealConsts.Oper_Unlock then --取消锁定
            DealModel:RemoveMyState( DealConsts.State_Lock ); -- 取消锁定
            DealModel:RemoveMyState( DealConsts.State_Confirm ); -- 取消锁定同时取消确认交易状态
        elseif oper == DealConsts.Oper_Confirm then --确认交易
            DealModel:AddMyState( DealConsts.State_Confirm );
        end
    else
        if oper == DealConsts.Oper_Lock then--锁定
            DealModel:AddHisState( DealConsts.State_Lock );
        elseif oper == DealConsts.Oper_Unlock then --取消锁定
            DealModel:RemoveHisState( DealConsts.State_Lock );
        elseif oper == DealConsts.Oper_Confirm then --确认交易
            DealModel:AddHisState( DealConsts.State_Confirm );
        end
    end
end

-------------------------------------------request--------------------------------------------

--向一个玩家发交易请求
function DealController:InviteDeal(roleID)
    local func = FuncManager:GetFunc( FuncConsts.Deal )
    if not func then return end
    if func:GetState() ~= FuncConsts.State_Open then
        local tips = FuncManager:GetFuncUnOpenTips( FuncConsts.Deal )
        if tips ~= "" then
            FloatManager:AddNormal(tips)
        end
        return
    end
    --
    local msg = ReqExchangeMsg:new();
    msg.roleID = roleID;
    MsgManager:Send(msg);
end

--告诉服务器我是否同意对方的交易请求
function DealController:ReplyInvite( roleID, agree )
    local msg = ReqExchangeInviteRtMsg:new();
    msg.roleID     = roleID;
    msg.resultCode = agree;
    MsgManager:Send(msg);
end

--放入或收回物品，输入金币的值改变
function DealController:ChangeDealContent( bagPos, containerID, gold )
    local msg = ReqExchangeMoveItemMsg:new();
    msg.bagPos      = bagPos;
    msg.containerID = containerID - 1; --前台索引是1开始的，与后台不同
    msg.gold        = gold;
    MsgManager:Send(msg);
end

--发一个操作类型给服务器1:锁定 -1:取消锁定 2:确认交易 -2:取消交易
function DealController:OperDeal(type)
    local msg = ReqExchangeHandleMsg:new();
    msg.type = type;
    MsgManager:Send(msg);
end

---------------------------以下为面向交易界面的操作----------------------------

--输入金币
function DealController:InputMoney( money )
    self:UnlockPanel();
    self:ChangeDealContent( -1, -1, money );
end

--拖入物品
function DealController:PutOnShelvesByPos( bagPos, dealPos )
    self:UnlockPanel();
    self:ChangeDealContent( bagPos, dealPos, DealModel:GetMyMoney() );
end

--背包右键把物品放过来，这里先查找空格放入
function DealController:PutOnShelves(itemData)
    if itemData.bindState == BagConsts.Bind_Bind then
        FloatManager:AddCenter( StrConfig["deal5"] ); -- 绑定物品无法交易
        return;
    end
    for pos = 1, DealConsts.NumSlots do
        local item = DealModel:GetMyItem(pos);
        if not item.hasItem then
            self:PutOnShelvesByPos( itemData.pos, pos );
            return;
        end
    end
    FloatManager:AddCenter( StrConfig["deal6"] ); --弹出提示交易格已经满了
end

--拖回物品
function DealController:PullOffShelves(dealPos)
    self:UnlockPanel();
    self:ChangeDealContent( -1, dealPos, DealModel:GetMyMoney() );
end

--锁定
function DealController:LockPanel()
    if not DealModel:IsLocked() then
        self:OperDeal( DealConsts.Oper_Lock );
    end
end

--解锁
function DealController:UnlockPanel()
    if DealModel:IsLocked() then
        self:OperDeal( DealConsts.Oper_Unlock );
    end
end

--确认交易
function DealController:ConfirmDeal()
    self:OperDeal( DealConsts.Oper_Confirm );
end

--取消交易
function DealController:CancelDeal()
    self:OperDeal( DealConsts.Oper_Cancel );
end