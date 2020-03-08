if not MODULE_GAMESERVER then
	Activity.QueQiaoXiangHuiAct = Activity.QueQiaoXiangHuiAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("QueQiaoXiangHuiAct") or Activity.QueQiaoXiangHuiAct

tbAct.nJoinLevel = 20   --最低参与等级
tbAct.nDialogNpcId = 2371 --参与活动npc
tbAct.nMapTemplateId = 8009	--地图id
tbAct.nPutItemId = 9449  --鹊之灵
tbAct.tbPutNpcTempIds = {3199, 3199, 3199, 3200, 3199, 3199, 3199, 3201} --摆放喜鹊，按次序指定npc id
tbAct.tbCenterPos = {7077, 11079}  --桥中间坐标，拥抱位置
tbAct.tbFireworks = {   --烟花
    {9266, 0, 0},    --effect id，x坐标，y坐标
}

tbAct.tbScoreSetting = {    --评价数值
    tbCount = { --数量维度
        {19, 40},   --数量上限（含），得分
        {35, 50},
        {41, 60},
        {47, 80},
        {53, 90},
        {60, 100},
    },
    tbArea = {  --广度维度
        {184000, 40},   --面积上限（含），得分
        {414000, 60},
        {563500, 80},
        {736000, 90},
        {2000000, 100},
    },
    tbBalance = {   --均匀维度
        {10, 100}, --均匀系数（含），得分
        {35, 90},
        {200, 80},
        {800, 50},
        {2000, 40},
    },
}

tbAct.tbScoreRates = {  --摆放评分占比
    nCount = 0.5,   --数量占比
    nArea = 0.2,    --面积占比
    nBalance = 0.3, --均匀占比
}

tbAct.tbScoreRewards = {    --积分发奖                  
    {50, { {"item", 9456, 1}}},--积分上限（含），奖励列表
    {60, { {"item", 9455, 1}}},
    {70, { {"item", 9454, 1}}},
    {80, { {"item", 9453, 1}}},
    {90, { {"item", 9452, 1}}},
    {100, { {"item", 9451, 1}}},
}

tbAct.tbBoarder = { --摆放区边界
    6050, 7755, --x, 左右
    11565, 10950, --y, 上下
}

if MODULE_GAMECLIENT then
    function tbAct:ClearData()
        self.bReady = nil
        self.bSubmitted = nil
        self:OnReadyChange(false)
    end

    function tbAct:OnReadyChange(bReady)	
        self.bReady = bReady
        local szUiName = "HomeScreenTask"
        if Ui:WindowVisible(szUiName) ~= 1 then
            return
        end
        Ui(szUiName):UpdateQiXiBtn()
    end

    function tbAct:OnSubmitted()
        self.bSubmitted = true
        local szUiName = "HomeScreenTask"
        if Ui:WindowVisible(szUiName) ~= 1 then
            return
        end
        Ui(szUiName):UpdateQiXiBtn()
    end
end