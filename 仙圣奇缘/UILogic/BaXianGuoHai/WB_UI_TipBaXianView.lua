--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_TipBaXianView.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	八仙过海npc信息界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


Game_TipBaXianView = class("Game_TipBaXianView")
Game_TipBaXianView.__index = Game_TipBaXianView

function Game_TipBaXianView:ctor()

end

local function onClick_Button_View(pSend, nTag)
    --g_ShowSysTips({text = "-------------查看玩家信息 --------------"})
	local wndInstance = g_WndMgr:getWnd("Game_TipBaXianView")
	if wndInstance then
		g_MsgMgr:requestViewPlayer(wndInstance.Image_Icon:getTag())
	end
end

local function onClick_Button_LanJie(pSend, nTag)
    --g_ShowSysTips({text = "-------------拦劫--------------"})
    local wndInstance = g_WndMgr:getWnd("Game_TipBaXianView")
    if wndInstance and wndInstance.Image_Icon then
        if wndInstance.Image_Icon:isExsit() then g_BaXianGuoHaiSystem:RequestBaXianStartRob(wndInstance.Image_Icon:getTag()) else wndInstance.Image_Icon =nil end
    end
    g_WndMgr:closeWnd("Game_TipBaXianView")
end


function Game_TipBaXianView:initWnd()

    --初始化控件
    self.Label_MasterName = tolua.cast(self.rootWidget:getChildAllByName("Label_MasterName"), "Label")
    self.Label_MasterLevel = tolua.cast(self.rootWidget:getChildAllByName("Label_MasterLevel"), "Label")
    self.Label_CanBeRobbedNum = tolua.cast(self.rootWidget:getChildAllByName("Label_CanBeRobbedNum"), "Label")
    self.Label_RobMoney = tolua.cast(self.rootWidget:getChildAllByName("Label_RobMoney"), "Label")
    self.Label_RobPrestige = tolua.cast(self.rootWidget:getChildAllByName("Label_RobPrestige"), "Label")
    self.Image_Icon = tolua.cast(self.rootWidget:getChildAllByName("Image_Icon"), "ImageView")
    self.Image_StarLevel = tolua.cast(self.rootWidget:getChildAllByName("Image_StarLevel"), "ImageView")

    self.Button_LanJie = tolua.cast(self.rootWidget:getChildAllByName("Button_LanJie"), "Button")
    self.Button_View = tolua.cast(self.rootWidget:getChildAllByName("Button_View"), "Button")

    g_SetBtn(self.rootWidget, "Button_LanJie", onClick_Button_LanJie, true)--筛选目标按钮响应
    g_SetBtn(self.rootWidget, "Button_View", onClick_Button_View, true)--开始护送按钮响应

    --注册UI消息响应
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_showNpcInfoView, handler(self, self.UIMsg_showNpcInfoView))

    return true
end

function Game_TipBaXianView:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_showNpcInfoView)
end

function Game_TipBaXianView:openWnd()

end

function Game_TipBaXianView:closeWnd()
    local var = 0;
end

function Game_TipBaXianView:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_PNL = tolua.cast(self.rootWidget:getChildByName("Image_TipBaXianViewPNL"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_PNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_TipBaXianView:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_PNL = tolua.cast(self.rootWidget:getChildByName("Image_TipBaXianViewPNL"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_PNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

--显示Npc信息窗口消息响应
function Game_TipBaXianView:UIMsg_showNpcInfoView(tbMsg)
    
    --设置控件内容
    self.Label_MasterName:setText(getFormatSuffixLevel(tbMsg.PlayerName, g_GetCardEvoluteSuffixByEvoLev(tbMsg.PlayerBreakLv)))
    g_SetCardNameColorByEvoluteLev(self.Label_MasterName, tbMsg.PlayerBreakLv)

    self.Label_MasterLevel:setText(_T("Lv.")..tbMsg.PlayerLv)

    local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(tbMsg.NpcID)
    local strPath = getImgByPath("BaXianGuoHai", tbCsvBase.Icon)
    self.Image_Icon:loadTexture( strPath) 
    self.Image_Icon:setTag(tbMsg.playerID)

    self.Label_CanBeRobbedNum:setText(tbMsg.OnlyBeRobTimes)
    if tbMsg.OnlyBeRobTimes ~=0  then
        self.Label_CanBeRobbedNum:setColor(ccc3(0,255,0))
        --self.Button_LanJie:setTag(tbMsg.playerID)
    else
        self.Label_CanBeRobbedNum:setColor(ccc3(255,0,0))
        self.Button_LanJie:setTouchEnabled(false)
        g_SetBtnBright(self.Button_LanJie, false)
    end

    --self.Button_View:setTag(tbMsg.playerID)

    self.Label_RobMoney:setText(tbMsg.RobMoney)
    self.Label_RobPrestige:setText(tbMsg.RobPrestige)
    self.Image_StarLevel:loadTexture(getIconStarLev(tbMsg.PlayerStarLv))

--调整控件位置居中
    local tmpWidth = 0
    local FatherWidth = tolua.cast(self.rootWidget:getChildAllByName("Image_TipBaXianViewPNL"), "ImageView"):getSize().width
    --剩余打劫次数居中
    tmpWidth = tmpWidth + self.Label_CanBeRobbedNum:getSize().width
    local Label_CanBeRobbedNumMax =  tolua.cast(self.rootWidget:getChildAllByName("Label_CanBeRobbedNumMax"), "Label")
    tmpWidth = tmpWidth + Label_CanBeRobbedNumMax:getSize().width
    local Label_CanBeRobbedNumLB =  tolua.cast(self.rootWidget:getChildAllByName("Label_CanBeRobbedNumLB"), "Label")
    tmpWidth = tmpWidth + Label_CanBeRobbedNumLB:getSize().width
    self.Label_CanBeRobbedNum:setPositionX(Label_CanBeRobbedNumLB:getSize().width+2)
    g_AdjustWidgetsPosition({self.Label_CanBeRobbedNum, Label_CanBeRobbedNumMax},2)
    Label_CanBeRobbedNumLB:setPositionX(-tmpWidth/2)
    --铜钱居中
    tmpWidth = 0
    tmpWidth = tmpWidth + self.Label_RobMoney:getSize().width
    local tmpLabel =  tolua.cast(self.rootWidget:getChildAllByName("Label_RobMoneyLB"), "Label")
    tmpWidth = tmpWidth + tmpLabel:getSize().width
    self.Label_RobMoney:setPositionX(tmpLabel:getSize().width+2)
    tmpLabel:setPositionX(-tmpWidth/2)
    --声望居中
    tmpWidth = 0
    tmpWidth = tmpWidth + self.Label_RobPrestige:getSize().width
    tmpLabel =  tolua.cast(self.rootWidget:getChildAllByName("Label_RobPrestigeLB"), "Label")
    tmpWidth = tmpWidth + tmpLabel:getSize().width
    self.Label_RobPrestige:setPositionX(tmpLabel:getSize().width+2)
    tmpLabel:setPositionX(-tmpWidth/2)
end

function Game_TipBaXianView:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipBaXianViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipBaXianViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipBaXianViewPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_TipBaXianView:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipBaXianViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipBaXianViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipBaXianViewPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

function Game_TipBaXianView:ModifyWnd_viet_VIET()
    local Image_TipBaXianViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipBaXianViewPNL"), "ImageView")
----------------------------
    local Label_CanBeRobbedNumLB = tolua.cast(Image_TipBaXianViewPNL:getChildByName("Label_CanBeRobbedNumLB"), "Label")
    Label_CanBeRobbedNumLB:setFontSize(18)

    local Label_CanBeRobbedNum = tolua.cast(Label_CanBeRobbedNumLB:getChildByName("Label_CanBeRobbedNum"), "Label")
    Label_CanBeRobbedNum:setFontSize(18)

    local Label_CanBeRobbedNumMax = tolua.cast(Label_CanBeRobbedNumLB:getChildByName("Label_CanBeRobbedNumMax"), "Label")
    Label_CanBeRobbedNumMax:setFontSize(18)
-----------------------------
    local Label_RobMoneyLB = tolua.cast(Image_TipBaXianViewPNL:getChildByName("Label_RobMoneyLB"), "Label")
    Label_RobMoneyLB:setFontSize(18)

    local Label_RobMoney = tolua.cast(Label_RobMoneyLB:getChildByName("Label_RobMoney"), "Label")
    Label_RobMoney:setFontSize(18)
-----------------------------
    local Label_RobPrestigeLB = tolua.cast(Image_TipBaXianViewPNL:getChildByName("Label_RobPrestigeLB"), "Label")
    Label_RobPrestigeLB:setFontSize(18)

    local Label_RobPrestige = tolua.cast(Label_RobPrestigeLB:getChildByName("Label_RobPrestige"), "Label")
    Label_RobPrestige:setFontSize(18)

    local Label_Tip = tolua.cast(Image_TipBaXianViewPNL:getChildByName("Label_Tip"), "Label")
    Label_Tip:setFontSize(16)
    Label_Tip:setText(g_stringSize_insert(Label_Tip:getStringValue() , '\n', 16, 300) )

end