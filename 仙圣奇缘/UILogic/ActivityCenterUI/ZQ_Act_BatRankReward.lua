--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	2016-4-19
-- 版  本:	2.0.19
-- 描  述:  战斗力排行榜福利
-- 应  用:  
---------------------------------------------------------------------------------------
Act_BatRankReward = class("Act_BatRankReward",Act_Template)
Act_BatRankReward.__index = Act_Template

function Act_BatRankReward:updateStatus()
    if not self.tbMissions or not g_act:getActCurNumByID(self.nActivetyID) then
        --活动不存在或者活动已经结束
		return false
	end
    local rank_again = false
    --判断当前任务的状态是否已经更新
    for i,v in pairs(self.tbMissions) do
        if self.tbMissions_old[i] ~= v then
            rank_again = true
            self.tbMissions_old[i] = v
        end
    end
    
    local curDay = g_act:getActCurNumByID(self.nActivetyID)[1]        -- 获取当天是活动的第几天
    if rank_again or (self.curNum ~= curDay) then --任务状态已经更新，更新listView
        self.curNum = curDay
        self.tbItemList = self.tbItemLists[self.curNum] -- 战斗力排行榜活动每日奖励不一样
        self:sortAndUpdate()
    end
end

function Act_BatRankReward:setButtonState(buttonItem, state)
	local button_GetReward = tolua.cast(buttonItem:getChildByName("Button_GetReward"), "Button")
    local bitmapLabel_buttonName = tolua.cast(button_GetReward:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	if ActState.INVALID == state then --已领取
        bitmapLabel_buttonName:setText(_T("已领取"))
		button_GetReward:setTouchEnabled(false)
		button_GetReward:setBright(false)
	elseif ActState.DOING == state then --未领取
        bitmapLabel_buttonName:setText(_T("领取"))
		button_GetReward:setTouchEnabled(false)
		button_GetReward:setBright(false)
	elseif ActState.FINISHED == state then --可领取
        bitmapLabel_buttonName:setText(_T("领取"))
		button_GetReward:setTouchEnabled(true)
		button_GetReward:setBright(true)
	end
end

--活动是否有效
function Act_BatRankReward:isEnable(id)
    self.nActivetyID = id
    if g_act:getActCurNumByID(self.nActivetyID) then
        self.curNum = g_act:getActCurNumByID(self.nActivetyID)[1] or 1
    else
        self.curNum = 1
    end
    
    return self.super.isEnable(self, id)
end

--初始化
function Act_BatRankReward:init(panel, tbItemList)
    if not panel then
		return 
	end
    self.tbItemLists = tbItemList
    for i,v in pairs(self.tbItemLists) do
        for j,k in pairs(v) do
            k.ID = k.Rank
        end
    end
	self.super.init(self, panel, self.tbItemLists[self.curNum])
end

--更新每个列表项的状态，并且更新每项奖励的得奖人昵称
function Act_BatRankReward:setPanelItem(widget,index)
    self.super.setPanelItem(self, widget, index)
	local buttonItem = tolua.cast(widget:getChildByName("Button_Activety"), "Button")
	local label_PlayerName = tolua.cast(buttonItem:getChildByName("Label_PlayerName"), "Label")
    local name = g_act:getFightRankListByIndex(self.tbItemList[index].Rank)
    if not name then
        name = ""
    end
    label_PlayerName:setText(name)
end
