--[[
交易 常量
2015年3月30日12:26:44
haohu
]]

_G.DealConsts = {};

--交易状态
DealConsts.State_None    = 0; --空闲		000
DealConsts.State_Start   = 1; --交易状态	001
DealConsts.State_Lock    = 2; --锁定状态	010
DealConsts.State_Confirm = 4; --确认状态	100

--用户的交易操作
DealConsts.Oper_Lock    = 1; --锁定
DealConsts.Oper_Unlock  = -1; --取消锁定
DealConsts.Oper_Confirm = 2; --确认交易
DealConsts.Oper_Cancel  = -2; --取消交易

--对方是否同意交易
DealConsts.Reply_Yes = 0; --同意
DealConsts.Reply_No = -1; --拒绝

--菜单操作
DealConsts.MOper_OffShelves = 1; --卸下

--所有操作
DealConsts.AllOper = { DealConsts.MOper_OffShelves };

--交易金钱n毫秒无输入动作后发送服务器
DealConsts.MoneySendDelay = 500;

--获取操作的名字
function DealConsts:GetOperName(oper)
    if oper == DealConsts.MOper_OffShelves then
        return StrConfig["deal4"];
    end
end

DealConsts.NumSlots = 6;