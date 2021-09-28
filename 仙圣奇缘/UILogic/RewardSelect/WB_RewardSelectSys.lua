--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianGuoHai.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:  奖励选择逻辑
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

RewardSelectSys = class("RewardSelectSys")
RewardSelectSys.__index = RewardSelectSys

function RewardSelectSys:ctor()
    self.RewardItemID = 0       --使用的奖励礼包或者物品id
    self.MustSelcetCnt  = 0     --必须选择的奖励数量
    self.GetRewardCnt = 0       --使用奖励礼包或者物品的数量

    self.RewardList = {}        --奖励物品列表
 
end

function RewardSelectSys:ShowRewardSelectWnd(GameObj, inGetRewardCnt)
    self:ctor()--清空数据

    local itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",GameObj:getCsvID(), GameObj:getStarLevel())
    if itemBase.DropPackType ~= 2 then --2  是可选择掉落礼包或者物品
        --g_ClientMsgTips:showMsgConfirm(_T("当前适用物品不是可选奖励物品"))
        cclog("当前适用物品不是可选奖励物品")
        return
    end

    --读取数据 
    self.RewardItemID = GameObj:getServerId()       --使用的奖励礼包或者物品id
    self.GetRewardCnt = inGetRewardCnt       --使用奖励礼包或者物品的数量
    self.MustSelcetCnt = g_DataMgr:getCsvConfig_FirstKeyData("DropSelectPack", itemBase.DropID ).SelectNum

    local rewardListTemp = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSelectPack", itemBase.DropID )
    for k,v in pairs( rewardListTemp) do
        local tbDrop = {}
        tbDrop.DropItemType = v.DropType --道具
        tbDrop.DropItemStarLevel = v.DropItemStarLevel
        tbDrop.DropItemID = v.DropItemID
        tbDrop.DropItemNum = v.DropItemNum
        tbDrop.bSelect = false
        self.RewardList[k] = tbDrop
    end
    
    --显示窗口
    g_WndMgr:showWnd("Game_RewardSelectBox")
end

--切换奖励选项的选择状态，返回新状态
function RewardSelectSys:SendUseSelectItemRequest()
    local rootMsg = zone_pb.UseSelectItemRequest()
	rootMsg.item_id = self.RewardItemID

	local itemInfo = zone_pb.UseItemInfo()
	itemInfo.use_num = self.GetRewardCnt
    --itemInfo.object_id =0-------------------这个参数看来没有用
    table.insert(rootMsg.use_item_info,itemInfo)

    for k,v in pairs( self.RewardList) do
        if v.bSelect == true then 
            table.insert(rootMsg.item_idx_list,k)
        end
    end

	g_MsgMgr:sendMsg(msgid_pb.MSGID_USE_SELECT_ITEM_REQUEST,rootMsg)
end

function RewardSelectSys:getSelectItemCnt()
    local selcnt = 0
    for k,v in pairs( self.RewardList) do
        if v.bSelect == true then selcnt = selcnt + 1 end
    end
    return selcnt
end

--切换奖励选项的选择状态，返回新状态
function RewardSelectSys:changeRewardItemSelect(iIndex)
    local tbDropItem = self.RewardList[iIndex]
    if tbDropItem == nil then return nil end

    local bSeclet = nil

    if tbDropItem.bSelect == true then 
        tbDropItem.bSelect = false 
        bSeclet =  false
    else
        if self.MustSelcetCnt == 1 then
            for k,v in pairs( self.RewardList) do
                v.bSelect = false
            end
            tbDropItem.bSelect = true
            bSeclet =  true
        else
            if self:getSelectItemCnt() >= self.MustSelcetCnt then
                bSeclet =  false
            else
                tbDropItem.bSelect = true 
                bSeclet =  true
            end
        end
    end
    cclog(tostring(self.RewardList))
    return bSeclet
end
-----------------------------------------------------------------------
g_RewardSelectSys = RewardSelectSys.new()
