--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianRefresh.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	八仙过海刷新npc界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


Game_BaXianRefresh = class("Game_BaXianRefresh")
Game_BaXianRefresh.__index = Game_BaXianRefresh

MAX_RefreshNpc = 5--可选择npc数目

function Game_BaXianRefresh:ctor()

end

--刷新按钮响应
local function onClick_Button_Refresh()
    -- local vipLevelData_ = g_DataMgr:getCsvConfig("VipLevel") 
    -- local costYB = vipLevelData_[g_VIPBase:getCvsVipLevel()]["RefreshNpcCost"]
	-- local costYB = g_VIPBase:getVipLevelData("RefreshNpcCost")
    --检查是否是最高品质
    local Wday = g_GetServerWday()
    if gWeekNpc[Wday][5] == g_BaXianGuoHaiSystem.RefreshNpcInfo.curNpcId then
        g_ShowSysTips({text=_T("当前已经是最高品质了")})
        return
    end
	
	local costYB = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_RefreshNpcCost)
	
    if g_BaXianGuoHaiSystem.RefreshNpcInfo.RemainFreeRefresh <= 0 then
        if not g_CheckYuanBaoConfirm(costYB, _T("刷新神仙需要花费") .. costYB .. _T("元宝，您的元宝不够是否前往充值？")) then
            return
        end

        local function onClickConfirm()
			local wndInstance = g_WndMgr:getWnd("Game_BaXianRefresh")
			if wndInstance then
				wndInstance:RefreshNpc()
			end
	    end
	    g_ClientMsgTips:showConfirm(_T("是否花费") .. costYB .. _T("元宝刷新1次神仙？"), onClickConfirm, nil)
        return
    end
	
    local wndInstance = g_WndMgr:getWnd("Game_BaXianRefresh")
	if wndInstance then
		wndInstance:RefreshNpc()
	end
end

local function onClick_Button_KaiShiHuSong()
	
	local function onClick_Confirm()
		g_WndMgr:showWnd("Game_BaXianPray")
	end
	
	local function onClick_Cancel()
		g_BaXianGuoHaiSystem:ReqConvoyNpc()
		g_WndMgr:closeWnd("Game_BaXianRefresh")
	end
	
	if g_GetNoticeNum_BaXianPray() > 0 then
		g_ClientMsgTips:showConfirm(_T("您今天没有祭拜道祖，是否先祭拜获得收益加成？"), onClick_Confirm, onClick_Cancel)
	else
		g_BaXianGuoHaiSystem:ReqConvoyNpc()
		g_WndMgr:closeWnd("Game_BaXianRefresh")
	end
end

function Game_BaXianRefresh:initWnd()

    -- 初始化控件
    self.Label_Name = tolua.cast(self.rootWidget:getChildAllByName("Label_Name"), "Label")

    self.Label_NeedTime = tolua.cast(self.rootWidget:getChildAllByName("Label_NeedTime"), "Label")
    self.Label_CoinsReward = tolua.cast(self.rootWidget:getChildAllByName("Label_CoinsReward"), "Label")
    self.Label_PrestageReward = tolua.cast(self.rootWidget:getChildAllByName("Label_PrestageReward"), "Label")
    self.Label_ProtectValue = tolua.cast(self.rootWidget:getChildAllByName("Label_ProtectValue"), "Label")

    self.Button_Refresh = tolua.cast(self.rootWidget:getChildAllByName("Button_Refresh"), "Button")
    self.Button_KaiShiHuSong = tolua.cast(self.rootWidget:getChildAllByName("Button_KaiShiHuSong"), "Button")

    g_SetBtnWithGuideCheck(self.Button_Refresh, 1, onClick_Button_Refresh, true)
    g_SetBtnWithGuideCheck(self.Button_KaiShiHuSong, 1,onClick_Button_KaiShiHuSong, true, nil, nil, nil)

    self.Button_Npc = {}
    for i = 1, MAX_RefreshNpc do --初始化5个npc按钮,注册响应时间
        self.Button_Npc[i] = tolua.cast(self.rootWidget:getChildAllByName("Button_Npc" .. i), "Button")
		g_SetBtnWithPressingEvent(self.Button_Npc[i], 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
    end 

    --刷新送花所需参数
    self.runCnt = 0
    self.curRefreshNpcIndex = 1
    self.TmpRefreshId = 0
    self.AnimTimerId = nil

    --注册UI消息响应FormMsg_BXGH_RefreshNpc
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_RefreshNpc, handler(self, self.UIMsg_RefreshNpc))

    return true
end

function Game_BaXianRefresh:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_RefreshNpc)
end

function Game_BaXianRefresh:openWnd()
    --根据当前星期几，初始化npc类型
    local Wday = g_GetServerWday()

    local tmpImageMask= nil
    local strPath = nil
    local curNpcIndex = 1
    for k,v in pairs(gWeekNpc[Wday]) do
        local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(v)
        strPath = getImgByPath("BaXianGuoHai", tbCsvBase.Icon)
        self.Button_Npc[k]:loadTextures( strPath, strPath, strPath)
        self.Button_Npc[k]:setTag(v)

        tmpImageMask = tolua.cast(self.Button_Npc[k]:getChildAllByName("Image_Check"), "ImageView")
        tmpImageMask:loadTexture(getImgByPath("BaXianGuoHai", tbCsvBase.Icon .. "_Check"))
        tmpImageMask:setVisible(false)
        g_SetBlendFuncWidget(tmpImageMask, 4)

        if v ==  g_BaXianGuoHaiSystem.RefreshNpcInfo.curNpcId then
            curNpcIndex = k
        end
    end

    --选中NPC
    self:SelectNpc(curNpcIndex)

    
    --设置刷新按钮状态
    self:ChangeRefreshState(g_BaXianGuoHaiSystem.RefreshNpcInfo.RemainFreeRefresh > 0 )

    --设置概率文本控件
    local Label_Tip = tolua.cast(self.Button_Refresh:getChildAllByName("Label_Tip"), "Label")
    local text = string.format(_T("%d次内必出最高档次神仙"), g_DataMgr:getGlobalCfgCsv("baxianguohai_refresh_max_count"))
    Label_Tip:setText(text)
end

function Game_BaXianRefresh:closeWnd()
    g_Timer:destroyTimerByID(self.AnimTimerId)
end

--切换刷新按钮状态呢
function Game_BaXianRefresh:ChangeRefreshState(bfree)
    local BitmapLabel_FuncName = tolua.cast(self.Button_Refresh:getChildAllByName("BitmapLabel_FuncName"), "LabelBMFont")
    local Image_NeedYuanBao = tolua.cast(self.Button_Refresh:getChildAllByName("Image_NeedYuanBao"), "ImageView")
    local BitmapLabel_NeedYuanBao = tolua.cast(self.Button_Refresh:getChildAllByName("BitmapLabel_NeedYuanBao"), "LabelBMFont")
    BitmapLabel_FuncName:setVisible(bfree)
    Image_NeedYuanBao:setVisible(not bfree)

    if bfree == false then 
        -- local costYB = g_VIPBase:getVipLevelData("RefreshNpcCost")
		local costYB = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_RefreshNpcCost)
        BitmapLabel_NeedYuanBao:setText(tostring(costYB))
    end
end

--确认刷新后调用
function Game_BaXianRefresh:RefreshNpc()
    self.TmpRefreshId = nil
    self.runCnt = 0
    self.curRefreshNpcIndex = g_BaXianGuoHaiSystem.RefreshNpcInfo.curNpcId

    self.AnimTimerId = g_Timer:pushLoopTimer(0.05, handler(self, self.OnTimer))
    g_BaXianGuoHaiSystem:ReqRefreshNpc()
end

function Game_BaXianRefresh:SelectNpc(Index)
    if self.Button_Npc[Index] == nil then return end
    if self.Button_Npc[Index]:isExsit() == false then self.Button_Npc[Index] = nil return end

    --设置npc发光
    local tmpImageMask = nil
    for k,v in pairs(self.Button_Npc) do
		if v and v:isExsit() then
			tmpImageMask = tolua.cast(v:getChildAllByName("Image_Check"), "ImageView")
			if Index == k then
				tmpImageMask:setVisible(true)
                v:setColor(ccc3(255,255,255))
			else
				tmpImageMask:setVisible(false)
                v:setColor(ccc3(150,150,150))
			end
		end
    end
    
    --设置npc信息
    local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(self.Button_Npc[Index]:getTag())
    local tbCsvlv = g_DataMgr:getBXGH_NpcLvCsv(self.Button_Npc[Index]:getTag(), g_BaXianGuoHaiSystem.MyNpcAryLv[self.Button_Npc[Index]:getTag()].lv)

    local nCoinsReward, nPrestigeReward, nConvoyTime = g_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(self.Button_Npc[Index]:getTag())

    self.Label_Name:setText(_T("【") .. tbCsvBase.Name.._T("】"))
    self.Label_NeedTime:setText(nConvoyTime .. _T("分钟"))
    self.Label_CoinsReward:setText(nCoinsReward)
    self.Label_PrestageReward:setText(nPrestigeReward)
    self.Label_ProtectValue:setText(string.format(_T("生命和战力+%d"),tbCsvBase.BuffValue*100/10000 ) .. "%")

end

function Game_BaXianRefresh:UIMsg_RefreshNpc(tbMsg)
    self.TmpRefreshId = tbMsg

    --设置刷新按钮状态
    self:ChangeRefreshState(g_BaXianGuoHaiSystem.RefreshNpcInfo.RemainFreeRefresh > 0 )
end

function Game_BaXianRefresh:OnTimer()

    --根据总的执行次数计算跳动间隔。实现减慢速度
    self.runCnt = self.runCnt + 1
    local bNext = false
    if self.runCnt < 30 then
        bNext = self.runCnt%1 == 0
    elseif self.runCnt >= 30 and self.runCnt<45 then
        bNext = self.runCnt%2 == 0
    elseif self.runCnt >= 45   then
        bNext = self.runCnt%3 == 0
    end

    if bNext then
        self.curRefreshNpcIndex = self.curRefreshNpcIndex + 1
        if self.curRefreshNpcIndex > 5 then self.curRefreshNpcIndex = 1 end
        self:SelectNpc(self.curRefreshNpcIndex)
    end

    --结束动画
    if self.TmpRefreshId and  self.Button_Npc[self.curRefreshNpcIndex]:getTag() ==  self.TmpRefreshId and self.runCnt >= 60 then
        self.TmpRefreshId = nil
        self.runCnt = 0
        self.curRefreshNpcIndex = 1
        g_Timer:destroyTimerByID(self.AnimTimerId)
		self.AnimTimerId = nil
        g_MsgNetWorkWarning:closeNetWorkWarning()
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_BaXianRefresh") then
			cclog("=================ActionEventEnd====================")
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
    end
end

function Game_BaXianRefresh:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_BaXianRefreshPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianRefreshPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_BaXianRefreshPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BaXianRefresh:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_BaXianRefreshPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianRefreshPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_BaXianRefreshPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end


function Game_BaXianRefresh:ModifyWnd_viet_VIET()
    local wnd_P = tolua.cast(self.rootWidget:getChildAllByName("Label_NeedTimeLB"), "Label")
    local wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_NeedTime"), "Label")
    wnd_C:setPositionX(wnd_P:getSize().width*wnd_P:getScaleX() + 1)

    wnd_P = tolua.cast(self.rootWidget:getChildAllByName("Label_CoinsRewardLB"), "Label")
    wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_CoinsReward"), "Label")
    wnd_C:setPositionX(wnd_P:getSize().width*wnd_P:getScaleX() + 1)

    wnd_P = tolua.cast(self.rootWidget:getChildAllByName("Label_PrestageRewardLB"), "Label")
    wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_PrestageReward"), "Label")
    wnd_C:setPositionX(wnd_P:getSize().width*wnd_P:getScaleX() + 1)

    wnd_P = tolua.cast(self.rootWidget:getChildAllByName("Label_ProtectValueLB"), "Label")
    wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_ProtectValue"), "Label")
    wnd_C:setPositionX(wnd_P:getSize().width*wnd_P:getScaleX() + 1)

    wnd_P = tolua.cast(self.rootWidget:getChildAllByName("Label_Tip"), "Label")
    wnd_P:setPositionX(-50)
end