--------------------------------------------------------------------------------------
-- 文件名:	Game_BaXianDajie.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	八仙过海打劫对象列表界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


Game_BaXianDaJie= class("Game_BaXianDaJie")
Game_BaXianDaJie.__index = Game_BaXianDaJie

g_ListView_Npc_Index = 1
function Game_BaXianDaJie:ctor()

end

function Game_BaXianDaJie:initWnd()

    self.NpcViewListData = {} --存储玩家id，用来索引逻辑层
    self.NpcRemainTimeAry = {} --存储倒计时控件，用于定时器里更新控件
    g_ListView_Npc_Index = 1
    self.listView = nil



    --注册UI消息响应
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_UpdataNpcList, handler(self, self.UIMsg_UpdataNpcList))
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_DecNpc_DaJie, handler(self, self.UIMsg_DecNpc_DaJie))

    self.timerID = g_Timer:pushLoopTimer(1, handler(self, self.OnTimer))
    return true
end

function Game_BaXianDaJie:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_UpdataNpcList)
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_DecNpc_DaJie)
    g_Timer:destroyTimerByID(self.timerID)
end

function Game_BaXianDaJie:openWnd()
    self.ListView_Npc = tolua.cast(self.rootWidget:getChildAllByName("ListView_Npc"), "ListViewEx")--打劫对象列表
    --self.Item_Npc = tolua.cast(self.ListView_Npc:getChildAllByName("Panel_NpcItem"), "Layout")--打劫对象列表Item模版
    self:registerListViewEvent()
    g_BaXianGuoHaiSystem:ResetRemainTime()
end

function Game_BaXianDaJie:closeWnd() 
	self.ListView_Npc:updateItems(0)
	self.NpcViewListData = nil
end

function Game_BaXianDaJie:registerListViewEvent()
    --if self.ListView_Npc == nil or self.Item_Npc == nil then return end
    if self.ListView_Npc == nil then return end
    local listView = Class_LuaListView:new()
    
    local function updateFunction(widget, nIndex)
        self:setListViewItem(widget, nIndex)
    end
	local function onAdjustListView(widget, nIndex)
		g_ListView_Npc_Index = nIndex
    end
    listView:setUpdateFunc(updateFunction)
    listView:setAdjustFunc(onAdjustListView)
    listView:setModel(g_WidgetModel.Panel_NpcItem)
    listView:setListView(self.ListView_Npc)
    self.ListView_Npc = listView
end

local function onClick_Button_DaJie(pSend, nTag)
    --g_ShowSysTips({text = "-----拦劫----" .. nTag})
    g_BaXianGuoHaiSystem:RequestBaXianStartRob(nTag)
    
end

local function onClick_Button_NpcItem(pSend, nTag)
    --g_ShowSysTips({text = "-----查看玩家信息 ----" .. nTag})
    g_MsgMgr:requestViewPlayer(nTag)
end

function Game_BaXianDaJie:setListViewItem(widget, nIndex)
    if widget == nil then return end

    local NpcItemInfo = g_BaXianGuoHaiSystem.NpcListdetailed[self.NpcViewListData[nIndex]]
    if NpcItemInfo == nil then 
        cclog("打劫列表获取玩家Npc信息失败")
        return 
    end

	--设置控件内容    
    local tmpWidget = nil
    --仇人标识
    tmpWidget = tolua.cast(widget:getChildAllByName("Image_EnemyFlag"), "ImageView")
    tmpWidget:setVisible(NpcItemInfo.bEnemyFlag == 1)
    --玩家名字
    tmpWidget = tolua.cast(widget:getChildAllByName("Label_MasterName"), "Label")
    tmpWidget:setText(getFormatSuffixLevel(NpcItemInfo.PlayerName, g_GetCardEvoluteSuffixByEvoLev(NpcItemInfo.PlayerBreakLv)))
    g_SetCardNameColorByEvoluteLev(tmpWidget, NpcItemInfo.PlayerBreakLv)
    --玩家星级
    tmpWidget = tolua.cast(widget:getChildAllByName("Image_StarLevel"), "ImageView")
    tmpWidget:loadTexture(getIconStarLev(NpcItemInfo.PlayerStarLv))
    --玩家级别
    tmpWidget = tolua.cast(widget:getChildAllByName("Label_MasterLevel"), "Label")
    tmpWidget:setText(_T("Lv.")..NpcItemInfo.PlayerLv)
    --Npc图标
    local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(NpcItemInfo.NpcID)
    local strPath = getImgByPath("BaXianGuoHai", tbCsvBase.Icon)
    tmpWidget = tolua.cast(widget:getChildAllByName("Image_Npc"), "ImageView")
    tmpWidget:loadTexture( strPath)
    --可被拦劫次数
    local Label_CanBeRobbedNum = tolua.cast(widget:getChildAllByName("Label_CanBeRobbedNum"), "Label")
    Label_CanBeRobbedNum:setText(NpcItemInfo.OnlyBeRobTimes)
    if NpcItemInfo.OnlyBeRobTimes ~=0 then
        Label_CanBeRobbedNum:setColor(ccc3(0,255,0))
    else
        Label_CanBeRobbedNum:setColor(ccc3(255,0,0))
        tmpWidget = tolua.cast(widget:getChildAllByName("Button_DaJie"), "Button")
        g_SetBtnBright(tmpWidget, false)
        tmpWidget:setTouchEnabled(false)
    end
    --剩余时间
    local Label_RemainTime = tolua.cast(widget:getChildAllByName("Label_CountDown"), "Label")
    TmpTick = NpcItemInfo.Total_Time - NpcItemInfo.RemainTime
    Label_RemainTime:setText( string.format("%02d:%02d:%02d", TmpTick/3600-0.5, (TmpTick%3600)/60-0.5, TmpTick%60))
    self.NpcRemainTimeAry[NpcItemInfo.playerID] = Label_RemainTime
    --获得铜钱数
    local Label_RobMoney = tolua.cast(widget:getChildAllByName("Label_RobCoinsReward"), "Label")
    Label_RobMoney:setText(NpcItemInfo.RobMoney)
    --获得声望
    local Label_RobPrestige = tolua.cast(widget:getChildAllByName("Label_RobPretigeReward"), "Label")
    Label_RobPrestige:setText(NpcItemInfo.RobPrestige)
    

--调整控件位置居中
    local tmpWidth = 0
    local FatherWidth = widget:getSize().width
    --剩余打劫次数居中
    tmpWidth = tmpWidth + Label_CanBeRobbedNum:getSize().width
    local Label_CanBeRobbedNumMax =  tolua.cast(widget:getChildAllByName("Label_CanBeRobbedNumMax"), "Label")
    tmpWidth = tmpWidth + Label_CanBeRobbedNumMax:getSize().width
    local Label_CanBeRobbedNumLB =  tolua.cast(widget:getChildAllByName("Label_CanBeRobbedNumLB"), "Label")
    tmpWidth = tmpWidth + Label_CanBeRobbedNumLB:getSize().width
    Label_CanBeRobbedNum:setPositionX(Label_CanBeRobbedNumLB:getSize().width+2)
    g_AdjustWidgetsPosition({Label_CanBeRobbedNum, Label_CanBeRobbedNumMax},2)
    Label_CanBeRobbedNumLB:setPositionX(-tmpWidth/2)
    --剩余时间居中
    tmpWidth = 0
    tmpWidth = tmpWidth + Label_RemainTime:getSize().width
    local tmpLabel =  tolua.cast(widget:getChildAllByName("Label_CountDownLB"), "Label")
    tmpWidth = tmpWidth + tmpLabel:getSize().width
    Label_RemainTime:setPositionX(tmpLabel:getSize().width+2)
    tmpLabel:setPositionX(-tmpWidth/2)
    --铜钱居中
    tmpWidth = 0
    tmpWidth = tmpWidth + Label_RobMoney:getSize().width
    tmpLabel =  tolua.cast(widget:getChildAllByName("Label_RobCoinsRewardLB"), "Label")
    tmpWidth = tmpWidth + tmpLabel:getSize().width
    Label_RobMoney:setPositionX(tmpLabel:getSize().width+2)
    tmpLabel:setPositionX(-tmpWidth/2)
    --声望居中
    tmpWidth = 0
    tmpWidth = tmpWidth + Label_RobPrestige:getSize().width
    tmpLabel =  tolua.cast(widget:getChildAllByName("Label_RobPretigeRewardLB"), "Label")
    tmpWidth = tmpWidth + tmpLabel:getSize().width
    Label_RobPrestige:setPositionX(tmpLabel:getSize().width+2)
    tmpLabel:setPositionX(-tmpWidth/2)

--注册按钮响应
    local tmpBtn = tolua.cast(widget:getChildAllByName("Button_DaJie"), "Button")
    tmpBtn:setTag(NpcItemInfo.playerID)
    g_SetBtnWithEvent(tmpBtn, NpcItemInfo.playerID, onClick_Button_DaJie, true)
    tmpBtn = tolua.cast(widget:getChildAllByName("Button_NpcItem"), "Button")
    tmpBtn:setTag(NpcItemInfo.playerID)
    g_SetBtnWithEvent(tmpBtn, NpcItemInfo.playerID, onClick_Button_NpcItem, true)


    widget:setTag(NpcItemInfo.playerID)

    local count = 0
    for k,v in pairs(g_BaXianGuoHaiSystem.NpcListdetailed) do count = count + 1 end
    
    if nIndex == count and count >= 20 then--一次服务器会下发20个，所以小于20的时候不用请求
		g_BaXianGuoHaiSystem:ReqNpcInfoList(false) 
	end
end

function Game_BaXianDaJie:UIMsg_DecNpc_DaJie(tbMsg)
    for i = 1, self.ListView_Npc:getChildrenCount() do
        local item = tolua.cast(self.ListView_Npc:getChildByIndex(i), "Layout")
        if itme ~= nil and itme:isExsit() and item:getTag() ==  tbMsg then
            self.ListView_Npc:getListView():removeItem(i)
            break
        end
    end
end

function Game_BaXianDaJie:UIMsg_UpdataNpcList(tbMsg)
    self.NpcRemainTimeAry = {}
    self.NpcViewListData = {}
    local i = 1;
    for k, v in pairs(tbMsg) do
        self.NpcViewListData[i] = v.playerID
        i=1+i
    end

    local l = #tbMsg
	g_ListView_Npc_Index = g_ListView_Npc_Index or 1
    self.ListView_Npc:updateItems(i-1, g_ListView_Npc_Index)
end

function Game_BaXianDaJie:OnTimer()
    local NpcItemInfo = nil
    for k, v in pairs( self.NpcRemainTimeAry) do
        NpcItemInfo = g_BaXianGuoHaiSystem.NpcListdetailed[k]
        if NpcItemInfo ~= nil then
            TmpTick = NpcItemInfo.Total_Time - NpcItemInfo.RemainTime
            if TmpTick < 0 then TmpTick = 0 end
            v:setText( string.format("%02d:%02d:%02d", TmpTick/3600-0.5, (TmpTick%3600)/60-0.5, TmpTick%60))
        end
    end
end

function Game_BaXianDaJie:ModifyWnd_viet_VIET()
    local Button_NpcItem = tolua.cast(g_WidgetModel.Panel_NpcItem:getChildByName("Button_NpcItem"), "Button")
----------------------------
    local Label_CanBeRobbedNumLB = tolua.cast(Button_NpcItem:getChildByName("Label_CanBeRobbedNumLB"), "Label")
    Label_CanBeRobbedNumLB:setFontSize(16)

    local Label_CanBeRobbedNum = tolua.cast(Label_CanBeRobbedNumLB:getChildByName("Label_CanBeRobbedNum"), "Label")
    Label_CanBeRobbedNum:setFontSize(16)

    local Label_CanBeRobbedNumMax = tolua.cast(Label_CanBeRobbedNumLB:getChildByName("Label_CanBeRobbedNumMax"), "Label")
    Label_CanBeRobbedNumMax:setFontSize(16)
-----------------------------
    local Label_CountDownLB = tolua.cast(Button_NpcItem:getChildByName("Label_CountDownLB"), "Label")
    Label_CountDownLB:setFontSize(16)

    local Label_CountDown = tolua.cast(Label_CountDownLB:getChildByName("Label_CountDown"), "Label")
    Label_CountDown:setFontSize(16)
    -----------------------------
    local Label_RobCoinsRewardLB = tolua.cast(Button_NpcItem:getChildByName("Label_RobCoinsRewardLB"), "Label")
    Label_RobCoinsRewardLB:setFontSize(16)

    local Label_RobCoinsReward = tolua.cast(Label_RobCoinsRewardLB:getChildByName("Label_RobCoinsReward"), "Label")
    Label_RobCoinsReward:setFontSize(16)
        -----------------------------
    local Label_RobPretigeRewardLB = tolua.cast(Button_NpcItem:getChildByName("Label_RobPretigeRewardLB"), "Label")
    Label_RobPretigeRewardLB:setFontSize(16)

    local Label_RobPretigeReward = tolua.cast(Label_RobPretigeRewardLB:getChildByName("Label_RobPretigeReward"), "Label")
    Label_RobPretigeReward:setFontSize(16)

end
-----------------------------------