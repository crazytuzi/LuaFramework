--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_TipBaXianView.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:   公共布阵设置界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_PublicBuZhen = class("Game_PublicBuZhen")
Game_PublicBuZhen.__index = Game_PublicBuZhen

--布阵UI全局变量
gUI_PublicBuzhen = nil
g_ListView_ZhenFa_Index = 1
function Game_PublicBuZhen:ctor()

    --阵形一个格子数据结构
    --[[ZhenXinInfo_Cell = {
	    Cell_index = 1,		-- 真心格子，从1开始
	    Card_index = 0		-- 卡牌在存的6个格子列表的索引，从0~5
    }]]

    --阵形数据结构
    self.ZF_info = {
	    zhen_fa_id = 1,		-- 阵型ID
	    card_list = {}      -- 上阵卡牌的格子信息，（ZhenXinInfo_Cell）
    }

    --是否打开界面后第一次刷新
    self.bFirstUpdata = true;
end

local L_BuZhenCard_mode = nil--缓存布阵卡牌头像控件

local function sortQiShuZhenfaCsv(CSV_QiShuZhenfaA, CSV_QiShuZhenfaB)
	return CSV_QiShuZhenfaA.SortRank < CSV_QiShuZhenfaB.SortRank
end

function Game_PublicBuZhen:getQiShuZhenfaInSort(nSortRank)
	if not g_TableQiShuZhenfaCsvInSort then
		g_TableQiShuZhenfaCsvInSort = {}
		for k, v in pairs (ConfigMgr.QiShuZhenfa) do
			table.insert(g_TableQiShuZhenfaCsvInSort, v)
		end
		table.sort(g_TableQiShuZhenfaCsvInSort, sortQiShuZhenfaCsv)
	end
	
	local nSortRank = nSortRank or 0
	
    local tbCsv = g_TableQiShuZhenfaCsvInSort[nSortRank]
    if not tbCsv then
		cclog("===Game_PublicBuZhen:getQiShuZhenfaInSort error ==="..nSortRank)
		return ConfigMgr.QiShuZhenfa_[0]
	end
	return tbCsv
end

function Game_PublicBuZhen:initWnd()
    g_ListView_ZhenFa_Index = 1
	
    --初始化控件
    self.Label_TeamStrength = tolua.cast(self.rootWidget:getChildAllByName("Label_TeamStrength"), "Label")
    self.Label_Initialtive = tolua.cast(self.rootWidget:getChildAllByName("Label_Initialtive"), "Label")
    self.ListView_ZhenFa = tolua.cast(self.rootWidget:getChildAllByName("ListView_ZhenFa"), "ListViewEx")
    self.Button_StartBattle = tolua.cast(self.rootWidget:getChildAllByName("Button_StartBattle"), "Button") 
    self.Button_Confirm = tolua.cast(self.rootWidget:getChildAllByName("Button_Confirm"), "Button") 

    self.Button_BuZhenPos = {}
    for i = 1, 12 do
        self.Button_BuZhenPos[i] = tolua.cast(self.rootWidget:getChildAllByName("Button_BuZhenPos" .. i), "Button") 
        self.Button_BuZhenPos[i]:setTag(i)
		self.Button_BuZhenPos[i]:setTouchEnabled(true)
		self.Button_BuZhenPos[i]:addTouchEventListener(handler(self, self.OnBtnTouchEvent_BuZhenPos))
    end
    --卡牌按钮模版
    if L_BuZhenCard_mode == nil then 
        L_BuZhenCard_mode = tolua.cast(self.Button_BuZhenPos[1]:getChildAllByName("Image_BuZhenCard"), "ImageView"):clone()
        L_BuZhenCard_mode:retain()
    end
    self.Image_BuZhenCard_mode = L_BuZhenCard_mode


    --创建拖动窗口，先隐藏
    self.Image_move = tolua.cast(self.Image_BuZhenCard_mode:clone(), "ImageView")
    g_WndMgr:addChild(self.Image_move)
    self.Image_move:setVisible(false)
    local tmp = self.Image_move:getTag()

    gUI_PublicBuzhen = self
    return true
end

function Game_PublicBuZhen:releaseWnd()
    g_WndMgr:removeChild(self.Image_move, true)
    gUI_PublicBuzhen = nil
end

function Game_PublicBuZhen:openWnd(tbData)
    self.bFirstUpdata = true;
    --new阵法list
	local Panel_ZhenFaItem = tolua.cast(g_WidgetModel.Panel_ZhenFaItem:clone(), "Layout")
	
    local listView = Class_LuaListView:new()
    listView:setModel(Panel_ZhenFaItem)
    local function onAdjustListView(widget, nSortRank)
		g_ListView_ZhenFa_Index = nSortRank
    end
    listView:setAdjustFunc(onAdjustListView)
    listView:setUpdateFunc(handler(self, self.updateListViewItem))
    listView:setListView(self.ListView_ZhenFa)

    --调用打开布阵串口的逻辑系统的showwnd回调，
    if tbData then tbData(self.rootWidget) end
    
end

function Game_PublicBuZhen:closeWnd()
    
end

function Game_PublicBuZhen:UpdataBuZhenView(ZF_info_in)
    self.ZF_info.zhen_fa_id = ZF_info_in.zhen_fa_id
    for i = 1, #ZF_info_in.card_list  do
        table.insert(self.ZF_info.card_list, 
        {Cell_index = ZF_info_in.card_list[i].Cell_index, 
         Card_index = ZF_info_in.card_list[i].Card_index})
    end

    self:serializeToUI()
end

--------------------------内部函数------------------------------
function Game_PublicBuZhen:getCurZhenFaIndex()
    local iIndex = nil 
    local nZhenFaNum = #g_DataMgr:getCsvConfig("QiShuZhenfa")
    for i = 1 , nZhenFaNum do 
        local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(i)
        if self.ZF_info.zhen_fa_id == CSV_ZhenFaInSort.ZhenFaID then
            iIndex = i
        end
    end
    return iIndex or 1
end

--把阵型数据序列化给UI
function Game_PublicBuZhen:serializeToUI()
--if true then return end
    if self.ZF_info == nil then return end
    --先把阵心列表排个序
    local function compZhenxin(a, b)
        return a.Cell_index < b.Cell_index
    end
    table.sort(self.ZF_info.card_list, compZhenxin)

    --清空所有阵形按钮
    for i = 1, 12 do
        local ImageCard = tolua.cast(self.Button_BuZhenPos[i]:getChildAllByName("Image_BuZhenCard"), "ImageView") 
        if ImageCard == nil then 
            ImageCard = self.Image_BuZhenCard_mode:clone()
		    self.Button_BuZhenPos[i]:addChild(ImageCard)
		    ImageCard:setName("Image_BuZhenCard") 
            ImageCard:setTag(-1)--  -1表示没放卡牌
        end
        ImageCard:setVisible(false)
        self.Button_BuZhenPos[i]:setBright(self:zhenFaIndex(tbClientToServerPosConvert[i]) ~= nil)
    end

	local TeamStrength = 0--战力
	local Initialtive = 0--先攻

    --轮循上阵卡牌，设置阵形UI，并累计计算战力和先攻值
    local tbCard = nil
    local PosBtn = nil
    local firstIndex = 0
	local firstIndexReplace = 5

	for k, v in pairs(self.ZF_info.card_list) do
        tbCard = g_Hero:getBattleCardByIndex(v.Card_index)
        
        --找出卡牌对应的按钮
        if v.Cell_index <= 5 then --大于5的是后补位置
            local tbCsv = g_DataMgr:getQiShuZhenfaCsv(self.ZF_info.zhen_fa_id, v.Cell_index)
            PosBtn =  self.Button_BuZhenPos[tbServerToClientPosConvert[tbCsv.BuZhenPosIndex]]
        else 
            PosBtn =  self.Button_BuZhenPos[tbServerToClientPosConvert[v.Cell_index + 4]] --(加4换算成按钮的pos)
        end
        
        if not tbCard or not PosBtn then 
            cclog("Game_PublicBuZhen:serializeToUI==卡牌或按钮为空==" .. v.Card_index)
            return
        end

        --设置按钮信息
        PosBtn:setBright(true)
        local Image_BuZhenCard = tolua.cast(PosBtn:getChildAllByName("Image_BuZhenCard"), "ImageView")
        if not Image_BuZhenCard then --判断是否已经添加了Image_BuZhenCard，没有就添加
		    Image_BuZhenCard = self.Image_BuZhenCard_mode:clone()
		    PosBtn:addChild(Image_BuZhenCard)
		    Image_BuZhenCard:setName("Image_BuZhenCard")
        end
        Image_BuZhenCard:setVisible(true)
        Image_BuZhenCard:setTag(v.Card_index)
        --边框颜色
        local Image_Frame = tolua.cast(Image_BuZhenCard:getChildAllByName("Image_Frame"), "ImageView")
        Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
        --卡牌头像
		local Image_Icon = tolua.cast(Image_BuZhenCard:getChildAllByName("Image_Icon"), "ImageView")
        Image_Icon:loadTexture(getIconImg(tbCard:getCsvBase().SpineAnimation))
        --卡牌星级
		local Image_StarLevel = tolua.cast(Image_BuZhenCard:getChildAllByName("Image_StarLevel"), "ImageView")
		Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
        --卡牌先手值
		local AtlasLabel_AttackOrder = tolua.cast(Image_BuZhenCard:getChildAllByName("AtlasLabel_AttackOrder"), "LabelAtlas")
        local tmp = 1
		if v.Cell_index > 5 then
            firstIndexReplace = firstIndexReplace + 1
            tmp = firstIndexReplace
		else
            firstIndex = firstIndex + 1
            tmp = firstIndex
		end
        AtlasLabel_AttackOrder:setValue(tmp) --显示卡牌为第几手
        AtlasLabel_AttackOrder:setTag(tmp) --控件保存先手值，供之后拖动的时候用

        --累计战力和先攻值		
		Initialtive = Initialtive + tbCard:getAttackPower()
		TeamStrength = TeamStrength + tbCard:getCardStrength()   
	end

	self.Label_TeamStrength:setText(TeamStrength)
	self.Label_Initialtive:setText(Initialtive) 

    --阵法
	local nZhenFaNum = #g_DataMgr:getCsvConfig("QiShuZhenfa")
    self.ListView_ZhenFa:removeAllChildren()
    local iCurIndex = 1
    if self.bFirstUpdata == true then
        iCurIndex =    self:getCurZhenFaIndex()
        self.bFirstUpdata = false
    else
	    g_ListView_ZhenFa_Index = g_ListView_ZhenFa_Index or 1
        iCurIndex = g_ListView_ZhenFa_Index
    end
	self.ListView_ZhenFa:updateItems(nZhenFaNum,iCurIndex)
	
end

--阵法列表的Item刷新函数
function Game_PublicBuZhen:updateListViewItem(widget, nSortRank)
    --读取阵法数据
	local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(nSortRank)
    --当前玩家阵法等级
	local nZhenFaLevel = g_Hero:getZhenFaLevel(CSV_ZhenFaInSort.ZhenFaID)
	local openLev = tonumber(CSV_ZhenFaInSort.OpenLevel)--阵法开启等级

	local Button_ZhenFaItem = tolua.cast(widget:getChildAllByName("Button_ZhenFaItem"), "Button")
	Button_ZhenFaItem:setTag(nSortRank)

    --阵法名字
	local Label_ZhenFaName = tolua.cast(Button_ZhenFaItem:getChildAllByName("Label_ZhenFaName"), "Label")
	Label_ZhenFaName:setText(CSV_ZhenFaInSort.ZhenFaName.._T("Lv.")..nZhenFaLevel)
	--阵法属性
	local Label_ZhenFaProp = tolua.cast(Button_ZhenFaItem:getChildAllByName("Label_ZhenFaProp"), "Label")
	Label_ZhenFaProp:setText(g_Hero:getZhenFaPropString(CSV_ZhenFaInSort.ZhenFaID))
	--checkbox状态
	local CheckBox_SelectFlag = tolua.cast(Button_ZhenFaItem:getChildAllByName("CheckBox_SelectFlag"), "CheckBox")
	CheckBox_SelectFlag:setTouchEnabled(false)
	if self.ZF_info.zhen_fa_id == CSV_ZhenFaInSort.ZhenFaID then
		CheckBox_SelectFlag:setSelectedState(true)
	else
		CheckBox_SelectFlag:setSelectedState(false)
	end
    --阵法ICON按钮
    local Button_ZhenFaIcon = tolua.cast(Button_ZhenFaItem:getChildAllByName("Button_ZhenFaIcon"), "Button")
	local BitmapLabel_OpenLevel = tolua.cast(Button_ZhenFaIcon:getChildAllByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local Image_ZhenFaIcon = tolua.cast(Button_ZhenFaIcon:getChildAllByName("Image_ZhenFaIcon"), "ImageView")

    BitmapLabel_OpenLevel:setVisible(true)
    Button_ZhenFaItem:setTouchEnabled(false)

	if openLev > tonumber(g_Hero:getMasterCardLevel()) then	
		local str = getUIImg("Frame_Qishu_Locker")
		Image_ZhenFaIcon:loadTexture(str)
		BitmapLabel_OpenLevel:setText(openLev)       
	else
		local str = getIconImg("Qishu_ZhenFa"..CSV_ZhenFaInSort.ZhenFaID)
		Image_ZhenFaIcon:loadTexture(str)
        BitmapLabel_OpenLevel:setVisible(false)
        Button_ZhenFaItem:setTouchEnabled(true)
	end

	Button_ZhenFaItem:addTouchEventListener(handler(self, self.onClickZhenFaListBtn))
end

function Game_PublicBuZhen:onClickZhenFaListBtn(pSender, eventType)
    --如果不是触摸结束事件 或者 点击按钮的阵法ID 是当前阵法iD就返回
	local nSortRank = pSender:getTag()
	local CSV_ZhenFaInSort = self:getQiShuZhenfaInSort(nSortRank)
	if eventType ~= ccs.TouchEventType.ended or CSV_ZhenFaInSort.ZhenFaID ==  self.ZF_info.zhen_fa_id then return end

    local Btn_ZhenFaItem = nil;
    local Chk_SelectFlag = nil;
    local cnt = self.ListView_ZhenFa:getChildrenCount()
    for i = 0,  self.ListView_ZhenFa:getChildrenCount() do
         Btn_ZhenFaItem = self.ListView_ZhenFa:getChildByIndex(i)
         if Btn_ZhenFaItem then
             Chk_SelectFlag = tolua.cast(Btn_ZhenFaItem:getChildAllByName("CheckBox_SelectFlag"), "CheckBox")
             Chk_SelectFlag:setSelectedState(false)
         end
    end    

    Chk_SelectFlag = tolua.cast(pSender:getChildAllByName("CheckBox_SelectFlag"), "CheckBox")
    Chk_SelectFlag:setSelectedState(true)

    self.ZF_info.zhen_fa_id = CSV_ZhenFaInSort.ZhenFaID
    --更新UI
    self:serializeToUI()
end

----------------------------------------
--------------------拖动处理--------------
----------------------------------------
moveToObj = 0--拖动的目标按钮序号，began时为当前按钮，，move时更新为经过的按钮，，end是更新为当前按钮
function Game_PublicBuZhen:zhenFaIndex(nIndex)
	local tbZhenFa = g_DataMgr:getCsvConfig_SecondKeyTableData("QiShuZhenfa",self.ZF_info.zhen_fa_id)
	local nPos = nIndex
	if nPos >  9 then return nPos - 10 + 6 end
	for i=1, #tbZhenFa do
		if tbZhenFa[i].BuZhenPosIndex == nPos then
			return tbZhenFa[i].ZhenXinID
		end
	end
end

--设置拖动按钮的信息
function Game_PublicBuZhen:Imagemove(Widget, Card_index)
    local tbCard = g_Hero:getBattleCardByIndex(Card_index)

    if tbCard == nil then return false end
    --边框颜色
    local Image_Frame = tolua.cast(self.Image_move:getChildAllByName("Image_Frame"), "ImageView")
    Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
    --卡牌头像
	local Image_Icon = tolua.cast(self.Image_move:getChildAllByName("Image_Icon"), "ImageView")
    Image_Icon:loadTexture(getIconImg(tbCard:getCsvBase().SpineAnimation))
    --卡牌星级
	local Image_StarLevel = tolua.cast(self.Image_move:getChildAllByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
    --卡牌先手值
	local AtlasLabel_AttackOrder = tolua.cast(self.Image_move:getChildAllByName("AtlasLabel_AttackOrder"), "LabelAtlas")
    local tmpAttckOrder = tolua.cast(Widget:getChildAllByName("AtlasLabel_AttackOrder"), "LabelAtlas")
	AtlasLabel_AttackOrder:setValue(tmpAttckOrder:getTag()) --显示替补卡牌为第几手

    return true
end

--检查阵心是不是队长
function Game_PublicBuZhen:IsZhenXinBeCaptain(ZhenXin)
    if ZhenXin == nil then return false end
    for k, v in pairs(self.ZF_info.card_list) do
        if self:zhenFaIndex(ZhenXin) == v.Cell_index then
            return v.Card_index == 1
        end
    end
    return false
end

--交换阵心数据
function Game_PublicBuZhen:SwapZhenxinData(_begin, _end)
    local Idx = 1
    for i=1, #self.ZF_info.card_list do
        if self.ZF_info.card_list[Idx].Cell_index == _begin then self.ZF_info.card_list[Idx].Cell_index = _end Idx=Idx+1 end
        if Idx>#self.ZF_info.card_list then break end
        if self.ZF_info.card_list[Idx].Cell_index == _end then self.ZF_info.card_list[Idx].Cell_index = _begin  end
        Idx=Idx+1
        if Idx>#self.ZF_info.card_list then break end
    end  
    self:serializeToUI()
end

---触碰响应
function Game_PublicBuZhen:OnBtnTouchEvent_BuZhenPos(pSender,eventType)
	if eventType == ccs.TouchEventType.began then
		local tmpWidget = pSender:getChildAllByName("Image_BuZhenCard")		
		--移动小伙伴的时候
		if tmpWidget and  tmpWidget:getTag() ~= -1 then
			local wndInstance = g_WndMgr:getWnd("Game_PublicBuZhen")
			if wndInstance then
				if wndInstance:Imagemove(tmpWidget, tmpWidget:getTag()) == false then return end
				local nPos = pSender:getTouchStartPos()
				
				wndInstance.Image_move:setPosition(ccp(nPos.x, nPos.y))
				wndInstance.Image_move:setTag( tbClientToServerPosConvert[pSender:getTag()])
				wndInstance.Image_move:setVisible(true)
				--tmpWidget:removeFromParent()
				tmpWidget:setVisible(false)
				tmpWidget:setTag(-1)
				moveToObj = pSender:getTag()
			end
		end
	elseif eventType == ccs.TouchEventType.ended or eventType == ccs.TouchEventType.canceled then
		local wndInstance = g_WndMgr:getWnd("Game_PublicBuZhen")
		if wndInstance then
			if moveToObj == 0 then 
				wndInstance.Image_move:setVisible(false) 
				return 
			end
			local BtnBeginIndex = pSender:getTag()	--开始的按钮序号
			local BtnEndIndex = wndInstance.Button_BuZhenPos[moveToObj]:getTag()  --结束的按钮序号

			local ZhenXinBegin = wndInstance:zhenFaIndex(wndInstance.Image_move:getTag()) --开始的阵心序号
			local ZhenXinEnd = wndInstance:zhenFaIndex(tbClientToServerPosConvert[moveToObj])

			if ( (BtnBeginIndex > 9 and wndInstance:IsZhenXinBeCaptain(tbClientToServerPosConvert[moveToObj])) or
				 (BtnEndIndex > 9 and wndInstance:IsZhenXinBeCaptain( wndInstance.Image_move:getTag())) ) then        
				 g_ClientMsgTips:showMsgConfirm(_T("队长不能成为替补！"))
				 wndInstance:serializeToUI()
				 wndInstance.Image_move:setVisible(false)
				 moveToObj = 0
				 return
			end
			wndInstance:SwapZhenxinData(ZhenXinBegin, ZhenXinEnd)
			wndInstance.Image_move:setVisible(false)
			moveToObj = 0
		end
	elseif eventType == ccs.TouchEventType.moved then
		local wndInstance = g_WndMgr:getWnd("Game_PublicBuZhen")
		if wndInstance then
			if moveToObj == 0 then return end
			local nPos = pSender:getTouchMovePos()
			wndInstance.Image_move:setPosition(ccp(nPos.x, nPos.y))
			wndInstance.Button_BuZhenPos[moveToObj]:setBrightStyle(BRIGHT_NORMAL)
			for i = 1, 12 do--检测在哪个按钮上
				if(wndInstance.Button_BuZhenPos[i] ~= nil and wndInstance.Button_BuZhenPos[i]:hitTest(nPos) and wndInstance:zhenFaIndex(tbClientToServerPosConvert[i]) ~= nil) then
					wndInstance.Button_BuZhenPos[i]:setBrightStyle(BRIGHT_HIGHLIGHT)
					moveToObj = wndInstance.Button_BuZhenPos[i]:getTag()
					break 
				end
			end
		end
	end
end


function Game_PublicBuZhen:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_BattleBuZhenPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_PublicBuZhen:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_BattleBuZhenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_BattleBuZhenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_BattleBuZhenPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

function Game_PublicBuZhen:ModifyWnd_viet_VIET()
    local Image_TeamStrength = tolua.cast(self.rootWidget:getChildAllByName("Image_TeamStrength"), "ImageView")
    local Label_TeamStrength = tolua.cast(Image_TeamStrength:getChildAllByName("Label_TeamStrength"), "Label")
    Label_TeamStrength:setPositionX(Image_TeamStrength:getSize().width*Image_TeamStrength:getScaleX() + 1)


    local Image_Initialtive = tolua.cast(self.rootWidget:getChildAllByName("Image_Initialtive"), "ImageView")
    local Label_Initialtive = tolua.cast(Image_Initialtive:getChildAllByName("Label_Initialtive"), "Label")
    g_AdjustWidgetsPosition({Image_Initialtive, Label_Initialtive},1)
end