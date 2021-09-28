--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianGuoHai.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	八仙过海护送界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--根据场景的高度320，将场景8等分，分别有0,40,80,120,160,200,240,280,320，9条水平线，每条水平线的间隔是40
BX_MESH_Width = 2560
BX_MESH_x = 0
BX_MESH_y = {0,40,80,120,160,200,240,280,320}

---------------------------------------------------------------------------------------
Game_BaXuanGuoHai = class("Game_BaXuanGuoHai")
Game_BaXuanGuoHai.__index = Game_BaXuanGuoHai

g_Game_BaXuanGuoHai = nil--八仙过海护送界面全局变量，在InitWnd初始化

function Game_BaXuanGuoHai:ctor()

end

--添加可打劫次数按钮响应
local function onClick_Button_AddResource(pSender, nTag)
    local alltimes = g_VIPBase:getVipLevelCntNum(VipType.VipBuyOpType_RobTimes)
    local CostYB = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_RobTimes)



    if alltimes == g_BaXianGuoHaiSystem.BuyRobTimes then
        g_ShowSysTips({text=_T("今日挑战购买次数已用完，升级vip可以增加购买次数！")})
        return
    end

    local function onClickConfirm()
        g_BaXianGuoHaiSystem:ReqBuyRobTimes()
	end
	g_ClientMsgTips:showConfirm(_T("是否花费") .. CostYB .._T("元宝购买挑战次数？"), onClickConfirm, nil)   
end

--开始护送按钮响应
local function onClick_Button_KaiShiHuSong()
    if g_BaXianGuoHaiSystem.State == g_BaXianGuoHaiSystem.enumState.BXGH_HS then
        g_ShowSysTips({text = _T("您已经处于护送中，请NPC到了再试哦")})
        return
    end

    if g_BaXianGuoHaiSystem.EscortTimes == 0 then
        g_ShowSysTips({text = _T("今日护送次数已经用完")})
        return
    end

    g_WndMgr:showWnd("Game_BaXianRefresh")
end

--老君显灵按钮响应
local function onClick_Button_LaoJunXianLing()
    g_WndMgr:showWnd("Game_BaXianPray")
end

--打劫列表按钮响应
local function onClick_Button_DaJieLieBiao()
	local function wndOpenFinishedCall()
	    g_BaXianGuoHaiSystem:ReqNpcInfoList(true)
	end

    g_WndMgr:showWnd("Game_BaXianDaJie", nil , wndOpenFinishedCall)    
end

--护送阵容按钮响应
local function onClick_Button_HuSongZhenRong()   
    g_WndMgr:showWnd("Game_PublicBuZhen", handler(g_BXGH_ZhenXing, g_BXGH_ZhenXing.OnShowWndCallBack))
end

--筛选目标按钮响应
local function onClick_Button_ShaiXuanMuBiao()
    g_WndMgr:showWnd("Game_BaXianFilter")
end

function Game_BaXuanGuoHai:initWnd()

    self.Label_RobTimes = tolua.cast(self.rootWidget:getChildAllByName("Label_RobTimes"), "Label")--打劫次数Label
    self.Label_EscortTimes = tolua.cast(self.rootWidget:getChildAllByName("Label_EscortTimes"), "Label")--护送次数Label
    
    self.Label_RemainTimeLB = tolua.cast(self.rootWidget:getChildAllByName("Label_RemainTimeLB"), "Label")--护送剩余时间Label
    self.Label_RemainTimeLB = tolua.cast(self.Label_RemainTimeLB:getChildAllByName("Label_RemainTimeLB"), "Label")--护送剩余时间Label

    self.ListView_EnemyList = tolua.cast(self.rootWidget:getChildAllByName("ListView_EnemyList"), "ListView")--仇人ListView
    self.Item_EnemyList = g_WidgetModel.Panel_Enemy--tolua.cast(self.rootWidget:getChildAllByName("Panel_Enemy"), "Layout")--仇人ListViewItem模版
    self.Image_Mesh = tolua.cast(self.rootWidget:getChildAllByName("Image_Mesh"), "ImageView")--护送网格
    self.Item_Mesh = tolua.cast(self.rootWidget:getChildAllByName("Button_NPC"), "Button")--护送网格Item模版
    self.Item_MeshAry = {}

    self.Button_KaiShiHuSong = tolua.cast(self.rootWidget:getChildAllByName("Button_KaiShiHuSong"), "Button")--护送网格Item模版

    self.Image_CoolTime = tolua.cast(self.rootWidget:getChildAllByName("Image_CoolTime"), "ImageView")--打劫cd面板
    self.Label_CoolTime = tolua.cast(self.Image_CoolTime:getChildAllByName("Label_CoolTime"), "Label")--打劫cd时间显示
    self.Image_CoolTime:setTouchEnabled(true)
    self.Image_CoolTime:addTouchEventListener(handler(self, self.OnTouchImage_CoolTime))
    self.Image_CoolTime:setVisible(false)
	
	local Label_RobTimesLB = tolua.cast(self.rootWidget:getChildByName("Label_RobTimesLB"), "Label")--打劫次数Label
	local Button_AddResource	= tolua.cast(Label_RobTimesLB:getChildByName("Button_AddResource"), "Button")

	g_SetBtnWithEvent(Button_AddResource, 1, onClick_Button_AddResource, true) --开始护送按钮响应

	
	local Image_BtnPNL = tolua.cast(self.rootWidget:getChildByName("Image_BtnPNL"), "ImageView")
    local Button_LaoJunXianLing	= tolua.cast(Image_BtnPNL:getChildByName("Button_LaoJunXianLing"), "Button")
	g_SetBtnWithPressImage(Button_LaoJunXianLing, 1, onClick_Button_LaoJunXianLing, true) --老君显灵按钮响应
	
	local Button_DaJieLieBiao	= tolua.cast(Image_BtnPNL:getChildByName("Button_DaJieLieBiao"), "Button")
	g_SetBtnWithPressImage(Button_DaJieLieBiao, 1, onClick_Button_DaJieLieBiao, true) --打劫列表按钮响应
	
	local Button_HuSongZhenRong	= tolua.cast(Image_BtnPNL:getChildByName("Button_HuSongZhenRong"), "Button")
	g_SetBtnWithPressImage(Button_HuSongZhenRong, 1, onClick_Button_HuSongZhenRong, true) --护送阵容按钮响应
	
	local Button_ShaiXuanMuBiao	= tolua.cast(Image_BtnPNL:getChildByName("Button_ShaiXuanMuBiao"), "Button")
	g_SetBtnWithPressImage(Button_ShaiXuanMuBiao, 1, onClick_Button_ShaiXuanMuBiao, true) --筛选目标按钮响应
	
	local Button_KaiShiHuSong	= tolua.cast(Image_BtnPNL:getChildByName("Button_KaiShiHuSong"), "Button")
	g_SetBtnWithEvent(Button_KaiShiHuSong, 1, onClick_Button_KaiShiHuSong, true) --开始护送按钮响应

    --设置仇人列表Item模版
    self.ListView_EnemyList:setItemModel(self.Item_EnemyList)
    self.ListView_EnemyList:removeAllItems()
    self.Item_Mesh:setVisible(false)

    --滚动控件
    self.ScrollView_Mesh = tolua.cast(self.rootWidget:getChildAllByName("ScrollView_Mesh"), "ScrollView")--滚动控件
    --self.ScrollView_Mesh:setInnerContainerSize(CCSize(2769,720))
	self.ScrollView_Mesh:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	self.ScrollView_Mesh:setTouchEnabled(true)
	self.ScrollView_Mesh:setAlphaTouchEnable(true)

    --注册UI消息响应
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_UpdataView, handler(self, self.UIMsg_UpdataView))
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_UpdataRobTimes, handler(self, self.UIMsg_UpdataRobTimes))
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_AddNpc, handler(self, self.UIMsg_AddNpc))
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_DecNpc, handler(self, self.UIMsg_DecNpc))
    g_FormMsgSystem:RegisterFormMsg(FormMsg_BXGH_Updata_DaJieCD, handler(self, self.Updata_DaJieCD))

    --打劫cd相关设置
    self:Updata_DaJieCD()

    --定时器级数
    self.timerID = g_Timer:pushLoopTimer(1, handler(self, self.OnTimer))

    g_Game_BaXuanGuoHai = self
	
	local Button_BaXianGuide = tolua.cast(self.rootWidget:getChildByName("Button_BaXianGuide"), "Button")
	g_RegisterGuideTipButton(Button_BaXianGuide, nil)
	
	local Image_Scene = tolua.cast(self.ScrollView_Mesh:getChildByName("Image_Scene"), "ImageView")
	local Image_Background1 = tolua.cast(Image_Scene:getChildByName("Image_Background1"), "ImageView")
	Image_Background1:loadTexture(getSceneImg("BaXianGuoHai"))
	local Image_Background2 = tolua.cast(Image_Scene:getChildByName("Image_Background2"), "ImageView")
	Image_Background2:loadTexture(getSceneImg("BaXianGuoHai"))

    return true
end

function Game_BaXuanGuoHai:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_UpdataView)
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_UpdataRobTimes)
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_AddNpc)
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_DecNpc)
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_BXGH_Updata_DaJieCD)
    g_Timer:destroyTimerByID(self.timerID)
    for k,v in pairs( self.Item_MeshAry) do
        v:removeFromParent()
    end
    self.Item_MeshAry = {}
    g_Game_BaXuanGuoHai = nil
end

function Game_BaXuanGuoHai:openWnd()
	local Image_BtnPNL = tolua.cast(self.rootWidget:getChildByName("Image_BtnPNL"), "ImageView")
    local Button_LaoJunXianLing	= tolua.cast(Image_BtnPNL:getChildByName("Button_LaoJunXianLing"), "Button")
	g_SetBubbleNotify(Button_LaoJunXianLing, g_GetNoticeNum_BaXianPray(), 50, 75)
    g_BaXianGuoHaiSystem:ResetRemainTime()
end

function Game_BaXuanGuoHai:closeWnd()
    local Image_Scene = tolua.cast(self.ScrollView_Mesh:getChildByName("Image_Scene"), "ImageView")
	local Image_Background1 = tolua.cast(Image_Scene:getChildByName("Image_Background1"), "ImageView")
	Image_Background1:loadTexture(getUIImg("Blank"))
	local Image_Background2 = tolua.cast(Image_Scene:getChildByName("Image_Background2"), "ImageView")
	Image_Background2:loadTexture(getUIImg("Blank"))
end

--清除打劫时间
function Game_BaXuanGuoHai:OnTouchImage_CoolTime(pSender,eventType)
    if eventType ~= ccs.TouchEventType.ended then return end

    local CostYB = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_BaxianRobCD)
    if not g_CheckYuanBaoConfirm(CostYB, _T("清除挑战冷却需要花费") .. CostYB .. _T("元宝，您的元宝不够是否前往充值？")) then
        return
    end

    local function onClickConfirm()
		gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_BaXianGuoHai_cd, 1, CostYB)	
		
        g_BaXianGuoHaiSystem:ReqClearRobCD()
	end
	g_ClientMsgTips:showConfirm(_T("是否花费") .. CostYB .._T("元宝清除挑战冷却时间？"), onClickConfirm, nil) 
end

--点击仇人列表Item响应
local function onClick_Button_Enemy(pSender, nTag)
    g_BaXianGuoHaiSystem:ReqNpcInfo(nTag)
end

--点击网格NPCItem响应
local function onClick_Button_NPC(pSender, nTag)
    if nTag == g_MsgMgr:getUin() then
        g_ShowSysTips({text = _T("干啥？你还想挑战自己吗？")})
        return
    end

    --g_WndMgr:showWnd("Game_TipBaXianView")
    g_BaXianGuoHaiSystem:ReqNpcInfo(nTag)
end

--增加一个npc
function Game_BaXuanGuoHai:UIMsg_AddNpc(Npcbrief)
    local tmpItem = tolua.cast(self.Item_Mesh:clone(), "Button")
    tmpItem:setAlphaTouchEnable(true)
    local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(Npcbrief.NpcID)
    local strPath = getImgByPath("BaXianGuoHai", tbCsvBase.Icon)
    tmpItem:setTag(Npcbrief.playerID)
    tmpItem:loadTextures( strPath, strPath, strPath )
	
	local Image_Check = tolua.cast(tmpItem:getChildAllByName("Image_Check"), "ImageView")
    Image_Check:loadTexture(strPath)
	
    local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(Npcbrief.NpcID)
	
	local Image_Mask = tolua.cast(tmpItem:getChildAllByName("Image_Mask"), "ImageView")
    Image_Mask:loadTexture(getImgByPath("BaXianGuoHai", tbCsvBase.Icon .. "_Check"))
    Image_Mask:setVisible(false)

    --设置位置
    local x = Npcbrief.RemainTime*BX_MESH_Width/Npcbrief.Total_Time
    local Zoder = math.random(1,9)
    local y = BX_MESH_y[Zoder]
    tmpItem:setPosition(ccp(x,y))
    g_SetBtnWithPressImage(tmpItem, tmpItem:getTag(), onClick_Button_NPC, true, 1)
    self.Image_Mesh:addChild(tmpItem, 10-Zoder, Npcbrief.playerID)
    tmpItem:setVisible(g_BaXianGuoHaiSystem.MyNpcAryLv[Npcbrief.NpcID].bShow == 1)
    self.Item_MeshAry[tmpItem:getTag()] = tmpItem

    --仇人列表
    if Npcbrief.bEnemyFlag == 1 then
        local tmpItem = self.Item_EnemyList:clone()
        tmpItem:setTag(Npcbrief.playerID)

        local tmpImageView = tolua.cast(tmpItem:getChildAllByName("Image_Icon"), "ImageView")
        local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(Npcbrief.NpcID)
        local strPath = getImgByPath("BaXianGuoHai", tbCsvBase.Icon)
        tmpImageView:loadTexture( strPath) 
        
        local tmpBtn = tolua.cast(tmpItem:getChildAllByName("Button_Enemy"), "Button")
        g_SetBtnWithPressImage(tmpBtn, tmpItem:getTag(), onClick_Button_Enemy,true, 1)
        self.ListView_EnemyList:pushBackCustomItem(tmpItem) 
    end

    --有可能自己开始护送
    if Npcbrief.playerID  == g_MsgMgr:getUin() then
        g_SetBlendFuncWidget(Image_Mask, 4)
        Image_Mask:setVisible(true)
        tmpItem:setTouchEnabled(false)

        --local b = g_BaXianGuoHaiSystem.State == g_BaXianGuoHaiSystem.enumState.BXGH_HS
        --self.Button_KaiShiHuSong:setTouchEnabled(not b)
        --g_SetBtnBright(self.Button_KaiShiHuSong, not b)

        self.Label_EscortTimes:setText(g_BaXianGuoHaiSystem.EscortTimes)
        self.Label_EscortTimes:setColor(ccc3(0,255,0))
        if g_BaXianGuoHaiSystem.EscortTimes == 0 then
            self.Label_EscortTimes:setColor(ccc3(255,0,0))
        end
    end
end

--减少一个npc
function Game_BaXuanGuoHai:UIMsg_DecNpc(tbMsg)
    if self.Item_MeshAry[tbMsg] then
        if self.Item_MeshAry[tbMsg]:isExsit() then 
            self.Item_MeshAry[tbMsg]:removeFromParent()
        end
        self.Item_MeshAry[tbMsg] = nil
    end

    --仇人列表
    local ItemAry = self.ListView_EnemyList:getItems()

    for i = 0, ItemAry:count()-1 do
        local item = tolua.cast(ItemAry:objectAtIndex(i), "Layout")
        if item and item:getTag() ==  tbMsg then
            self.ListView_EnemyList:removeItem(i)
            break
        end
    end


    --有可能是自己结束了
    if tbMsg  == g_MsgMgr:getUin() then
        --有可能自己开始护送
        --local b = g_BaXianGuoHaiSystem.State == g_BaXianGuoHaiSystem.enumState.BXGH_HS
        --self.Button_KaiShiHuSong:setTouchEnabled(not b)
        --g_SetBtnBright(self.Button_KaiShiHuSong, not b)
    end
end

--刷新打劫次数
function Game_BaXuanGuoHai:UIMsg_UpdataRobTimes()
    self.Label_RobTimes:setText(g_BaXianGuoHaiSystem.RobTimes)
    self.Label_RobTimes:setColor(ccc3(0,255,0))
    if g_BaXianGuoHaiSystem.RobTimes == 0 then
        self.Label_RobTimes:setColor(ccc3(255,0,0))
    end
	
	local Label_RobTimesLB = tolua.cast(self.rootWidget:getChildAllByName("Label_RobTimesLB"), "Label")
    local Label_RobTimesMax = tolua.cast(Label_RobTimesLB:getChildAllByName("Label_RobTimesMax"), "Label")
    g_AdjustWidgetsPosition({self.Label_RobTimes, Label_RobTimesMax},0)
end

--刷新打劫次数
function Game_BaXuanGuoHai:Updata_DaJieCD()
    local ret = g_BaXianGuoHaiSystem:GetDaJieCD()
    if ret ~= 0 then
        self.Image_CoolTime:setVisible(true)
        self.Label_CoolTime:setText(string.format("%02d:%02d",  (ret%3600)/60-0.5, ret%60))
    else
        self.Image_CoolTime:setVisible(false)
    end
end

--刷新整个界面
function Game_BaXuanGuoHai:UIMsg_UpdataView()
    
    --local b = g_BaXianGuoHaiSystem.State == g_BaXianGuoHaiSystem.enumState.BXGH_HS
    --self.Button_KaiShiHuSong:setTouchEnabled(not b)
    --g_SetBtnBright(self.Button_KaiShiHuSong, not b)

    --剩余打劫次数
    self.Label_RobTimes:setText(g_BaXianGuoHaiSystem.RobTimes)
    self.Label_RobTimes:setColor(ccc3(0,255,0))
    if g_BaXianGuoHaiSystem.RobTimes == 0 then
        self.Label_RobTimes:setColor(ccc3(255,0,0))
    end
    --剩余护送次数
    self.Label_EscortTimes:setText(g_BaXianGuoHaiSystem.EscortTimes)
    self.Label_EscortTimes:setColor(ccc3(0,255,0))
    if g_BaXianGuoHaiSystem.EscortTimes == 0 then
        self.Label_EscortTimes:setColor(ccc3(255,0,0))
    end
    --剩余护送时间
    local RemainTime = g_BaXianGuoHaiSystem.Total_Time - g_BaXianGuoHaiSystem.RemainTime;
    if RemainTime ~= 0 then
        self.Label_RemainTimeLB:setText(string.format("%02d:%02d:%02d", RemainTime/3600-0.5, (RemainTime%3600)/60-0.5, RemainTime%60))
    else
        self.Label_RemainTimeLB:setText("")
    end
 
    --护送网格
    for k,v in pairs( self.Item_MeshAry) do
        v:removeFromParent()
    end
    self.Item_MeshAry = {}
    for k, v in pairs(g_BaXianGuoHaiSystem.NpcListbrief) do
        self:UIMsg_AddNpc(v)
    end

end

--单个npc的设置
function Game_BaXuanGuoHai:OnNpcShowStateChange()

end

--Npc显示状态更新
function Game_BaXuanGuoHai:OnNpcShowStateChange()
    local npcID = nil
    for k,v  in pairs(self.Item_MeshAry) do
        npcID = g_BaXianGuoHaiSystem.NpcListbrief[k].NpcID
        if g_BaXianGuoHaiSystem.MyNpcAryLv[npcID] and npcID and g_BaXianGuoHaiSystem.NpcListbrief[k].playerID ~= g_MsgMgr:getUin() then
            v:setVisible(g_BaXianGuoHaiSystem.MyNpcAryLv[npcID].bShow == 1)
        end
    end
end

function Game_BaXuanGuoHai:OnTimer()
    self:Updata_DaJieCD()

    --跟新自己的剩余时间
    if g_BaXianGuoHaiSystem.State == g_BaXianGuoHaiSystem.enumState.BXGH_HS then
        TmpTick = g_BaXianGuoHaiSystem.Total_Time - g_BaXianGuoHaiSystem.RemainTime

        if TmpTick ~= 0 then
            self.Label_RemainTimeLB:setText(string.format("%02d:%02d:%02d", TmpTick/3600-0.5, (TmpTick%3600)/60-0.5, TmpTick%60))
        else
            self.Label_RemainTimeLB:setText("")
        end
    end
    --更新网格npc位置
    local x
    for k, v in pairs(g_BaXianGuoHaiSystem.NpcListbrief) do
        x= v.RemainTime*BX_MESH_Width/v.Total_Time
        if self.Item_MeshAry[v.playerID] then 
            self.Item_MeshAry[v.playerID]:setPositionX(x)
        end 
    end

end

function Game_BaXuanGuoHai:ModifyWnd_viet_VIET()
    local Label_RobTimesLB = tolua.cast(self.rootWidget:getChildAllByName("Label_RobTimesLB"), "Label")
    local Label_RobTimes = tolua.cast(Label_RobTimesLB:getChildAllByName("Label_RobTimes"), "Label")
    local Label_RobTimesMax = tolua.cast(Label_RobTimesLB:getChildAllByName("Label_RobTimesMax"), "Label")
    local Button_AddResource = tolua.cast(Label_RobTimesLB:getChildAllByName("Button_AddResource"), "Button")
    local ListView_EnemyList = tolua.cast(self.rootWidget:getChildAllByName("ListView_EnemyList"), "ListView")
    g_AdjustWidgetsPosition({Label_RobTimesLB, Label_RobTimes, Label_RobTimesMax, Button_AddResource, ListView_EnemyList},1)

    local Label_EscortTimesLB = tolua.cast(self.rootWidget:getChildAllByName("Label_EscortTimesLB"), "Label")
    local Label_EscortTimes = tolua.cast(Label_EscortTimesLB:getChildAllByName("Label_EscortTimes"), "Label")
    local Label_EscortTimesMax = tolua.cast(Label_EscortTimesLB:getChildAllByName("Label_EscortTimesMax"), "Label")
    g_AdjustWidgetsPosition({Label_EscortTimesLB, Label_EscortTimes, Label_EscortTimesMax},1)

    local Label_RemainTimeLB = tolua.cast(self.rootWidget:getChildAllByName("Label_RemainTimeLB"), "Label")
    local Label_RemainTimeLB_ = tolua.cast(Label_RemainTimeLB:getChildAllByName("Label_RemainTimeLB"), "Label")
    g_AdjustWidgetsPosition({Label_RemainTimeLB, Label_RemainTimeLB_},1)
end