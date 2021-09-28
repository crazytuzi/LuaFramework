--------------------------------------------------------------------------------------
-- 文件名:	HF_LoginOrRegister.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-03-28 18:24
-- 版  本:	1.0
-- 描  述:	选择服务器界面
-- 应  用:  
---------------------------------------------------------------------------------------
local SelectFalg = 
{
    SelectFalg_Local = 1000, --本地最后一次的
    --服务器列表获得
    SelectFalg_ServerList   = 2000 --规则 服务器列表的item 每个是在这个基础上加一
}


local CheckBox_SererGroupItem_Current = nil;--保存选择的大区对象
local rootWidget = nil

local function onClickServer(pSender,eventType)
	if eventType == ccs.TouchEventType.ended then
		local nServerID = pSender:getTag()
        local goto = true
        if nServerID == SelectFalg.SelectFalg_Local then --上次登录的服务器

        else
            local nindex = nServerID - SelectFalg.SelectFalg_ServerList
           goto = g_ServerList:SelectServerAndConnect(nindex)

        end
        
        if goto then
            --更新登入界面的服务器列表
            setLoginServer(nServerID)

            rootWidget:removeFromParentAndCleanup(true)
            CheckBox_SererGroupItem_Current = nil
            rootWidget = nil
        end
	end
end

local function showMyServer(latelyAreaID)
    local Image_MyServerPNL = rootWidget:getChildByName("Image_MyServerPNL")
    Image_MyServerPNL:setVisible(true)

    local Image_ServerListPNL = rootWidget:getChildByName("Image_ServerListPNL")
    Image_ServerListPNL:setVisible(false)

	local Image_LastServerPNL = Image_MyServerPNL:getChildByName("Image_LastServerPNL")
    local Button_LastServer = Image_LastServerPNL:getChildByName("Button_LastServer")

    --获取本地最后一次登入的服务器 
    --判断条件说明  因为端口获得的事整型 相对 IP 跟 名称 更好理解 而且 他的默认值就是 0xffffffff
    if g_ServerList:GetLocalPort() ~= -2147483648 then
        Button_LastServer:setVisible(true)
        Button_LastServer:setTouchEnabled(true)
        Button_LastServer:addTouchEventListener(onClickServer)
        Button_LastServer:setTag(SelectFalg.SelectFalg_Local)
        local Label_AttachmentTip = tolua.cast(Button_LastServer:getChildByName("Label_AttachmentTip"),"Label")
        Label_AttachmentTip:setText(g_ServerList:GetLocalName()) 
    else
        Button_LastServer:setVisible(false)
    end

    local AtlasLabel_ServerStatus = tolua.cast(Button_LastServer:getChildByName("AtlasLabel_ServerStatus"), "LabelAtlas")
    AtlasLabel_ServerStatus:setValue(g_ServerList:GetLocalState())

    local Image_NewFlag = tolua.cast(Button_LastServer:getChildByName("Image_NewFlag"), "ImageView")
    if Image_NewFlag then
     Image_NewFlag:setVisible(g_ServerList:GetLocalServerStatus_isNewServer())
    end

    --暂时没有实现
	local Image_MyServerListPNL = Image_MyServerPNL:getChildByName("Image_MyServerListPNL")
    local ListView_MyServerList = tolua.cast(Image_MyServerListPNL:getChildByName("ListView_MyServerList"), "ListViewEx")
    local LuaListView_MyServerList = Class_LuaListView:new()
    LuaListView_MyServerList:setListView(ListView_MyServerList)
	local Image_MyServerRowPNL = ListView_MyServerList:getChildByName("Image_MyServerRowPNL") 
    LuaListView_MyServerList:setModel(Image_MyServerRowPNL)
    local function updateMyServerList(Image_MyServerRowPNL, nIndex)
  
    end
    LuaListView_MyServerList:setUpdateFunc(updateMyServerList)
    LuaListView_MyServerList:updateItems(0)
end

local function showServerList(nGroupID)
    local Image_MyServerPNL = rootWidget:getChildByName("Image_MyServerPNL")
    Image_MyServerPNL:setVisible(false)

    local Image_ServerListPNL = rootWidget:getChildByName("Image_ServerListPNL")
    Image_ServerListPNL:setVisible(true)

    local ListView_ServerList = tolua.cast(Image_ServerListPNL:getChildByName("ListView_ServerList"), "ListViewEx")
    local LuaListView_ServerList = Class_LuaListView:new()
    LuaListView_ServerList:setListView(ListView_ServerList)
	local Image_ServerRowPNL = ListView_ServerList:getChildByName("Image_ServerRowPNL") 
    LuaListView_ServerList:setModel(Image_ServerRowPNL)

	local imgScrollSlider = LuaListView_ServerList:getScrollSlider()
    g_tbScrollSliderXY = g_tbScrollSliderXY or {}
	if not g_tbScrollSliderXY.LuaListView_ServerList_X then
		g_tbScrollSliderXY.LuaListView_ServerList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_ServerList_X - 3)
	
    local function updateServerList(Image_ServerRowPNL, nRowIndex)
        for i =1, 2 do
            local Button_ServerItem = tolua.cast(Image_ServerRowPNL:getChildByName("Button_ServerItem"..i), "Button")

            local nIndex = (nRowIndex-1)*2 +i
            local name = g_ServerList:GetServerName(nIndex)

            if name ~= "no name" then
     --            if nIndex == 1 then
					-- local Image_NewFlag = tolua.cast(Button_ServerItem:getChildByName("Image_NewFlag"), "ImageView")
					-- if Image_NewFlag then
					-- 	Image_NewFlag:setVisible(true)
					-- end
					-- local AtlasLabel_ServerStatus = tolua.cast(Button_ServerItem:getChildByName("AtlasLabel_ServerStatus"), "LabelAtlas")
					-- AtlasLabel_ServerStatus:setValue(g_ServerList:GetServeState(nIndex, true))
     --            else
					-- local Image_NewFlag = tolua.cast(Button_ServerItem:getChildByName("Image_NewFlag"), "ImageView")
					-- if Image_NewFlag then
					-- 	Image_NewFlag:setVisible(false)
					-- end
					-- local AtlasLabel_ServerStatus = tolua.cast(Button_ServerItem:getChildByName("AtlasLabel_ServerStatus"), "LabelAtlas")
					-- AtlasLabel_ServerStatus:setValue(g_ServerList:GetServeState(nIndex))
     --            end

                    local Image_NewFlag = tolua.cast(Button_ServerItem:getChildByName("Image_NewFlag"), "ImageView")
                    if Image_NewFlag then
                        Image_NewFlag:setVisible(g_ServerList:GetStatus_isNewServer(nIndex))
                    end
                    local AtlasLabel_ServerStatus = tolua.cast(Button_ServerItem:getChildByName("AtlasLabel_ServerStatus"), "LabelAtlas")
                    AtlasLabel_ServerStatus:setValue(g_ServerList:GetServeState(nIndex))
				
				 Button_ServerItem:loadTextures(getUIImg("ListItem_Mail_Check"),getUIImg("ListItem_Mail_Check_Press"),getUIImg("ListItem_Mail_Check"))

                Button_ServerItem:setTouchEnabled(true)
                Button_ServerItem:addTouchEventListener(onClickServer)
                Button_ServerItem:setTag(SelectFalg.SelectFalg_ServerList+nIndex)
                Button_ServerItem:setVisible(true)

                local Label_AttachmentTip = tolua.cast(Button_ServerItem:getChildByName("Label_AttachmentTip"),"Label")
                Label_AttachmentTip:setText(g_ServerList:GetServerName(nIndex)) 
            else
                Button_ServerItem:setVisible(false)
            end
        end
    end
    LuaListView_ServerList:setUpdateFunc(updateServerList)

    local nCount =  0
    if g_ServerList:GetServerListCount() ~=0 and g_ServerList:GetServerListCount()%2 == 0 then --偶数
        nCount = math.floor(g_ServerList:GetServerListCount()/2)
    elseif g_ServerList:GetServerListCount()%2 == 1 then --基数
        nCount = math.floor(g_ServerList:GetServerListCount()/2)+1
    end
    LuaListView_ServerList:updateItems(nCount)
end

local function onClickSelectArea(pSender, eventType)
    if eventType == ccs.CheckBoxEventType.selected then
        if pSender:getTag() == CheckBox_SererGroupItem_Current:getTag() then
            return
        end
		CheckBox_SererGroupItem_Current:setSelectedState(false)
        CheckBox_SererGroupItem_Current = tolua.cast(pSender, "CheckBox")

        local nTag = pSender:getTag()
        if nTag == 0 then
            local latelyAreaID = CCUserDefault:sharedUserDefault():getIntegerForKey("nCsvID", 0)
            showMyServer(latelyAreaID)
        else
            showServerList(nTag)
        end
    else
        if pSender:getTag() == CheckBox_SererGroupItem_Current:getTag() then
           CheckBox_SererGroupItem_Current:setSelectedState(true)
        end
    end
end

local function initLeftArea()
    if rootWidget == nil then return end

	local Image_ServerGroupListPNL = rootWidget:getChildByName("Image_ServerGroupListPNL")
	
    local latelyAreaID = CCUserDefault:sharedUserDefault():getIntegerForKey("nCsvID", 0)
    local CheckBox_SererGroupItemMy = tolua.cast(Image_ServerGroupListPNL:getChildByName("CheckBox_SererGroupItemMy"), "CheckBox")
    if false then -- g_ServerList:GetLocalPort() ~= -2147483648 then
        CheckBox_SererGroupItemMy:setSelectedState(true)
        CheckBox_SererGroupItem_Current = CheckBox_SererGroupItemMy
        showMyServer(latelyAreaID)
    else
        CheckBox_SererGroupItemMy:setSelectedState(false)
    end
    CheckBox_SererGroupItemMy:setTag(0)
    CheckBox_SererGroupItemMy:setTouchEnabled(true)
    CheckBox_SererGroupItemMy:addEventListenerCheckBox(onClickSelectArea)

    local tbServer = g_DataMgr:getSeverInfoCsvByPlatform()
	local Panel_ServerGroupList = tolua.cast(Image_ServerGroupListPNL:getChildByName("Panel_ServerGroupList"), "Layout")
    local ListView_ServerGroupList = tolua.cast(Panel_ServerGroupList:getChildByName("ListView_ServerGroupList"), "ListViewEx")
    local LuaListView_ServerGroupList = Class_LuaListView:new()
    LuaListView_ServerGroupList:setListView(ListView_ServerGroupList)
	local CheckBox_SererGroupItem = ListView_ServerGroupList:getChildByName("CheckBox_SererGroupItem") 
    LuaListView_ServerGroupList:setModel(CheckBox_SererGroupItem)
    local function updateServerGroupList(CheckBox_SererGroupItem, nIndex)
        local CheckBox_SererGroupItem = tolua.cast(CheckBox_SererGroupItem, "CheckBox")
        local nCurIndex = 1--nMaxCount-nIndex+1
        local CheckBox_SererGroupItemMy = tolua.cast(Image_ServerGroupListPNL:getChildByName("CheckBox_SererGroupItemMy"), "CheckBox")
        if  CheckBox_SererGroupItem_Current ~= CheckBox_SererGroupItemMy  then
            CheckBox_SererGroupItem:setSelectedState(true)
            CheckBox_SererGroupItem_Current = CheckBox_SererGroupItem
            showServerList(nCurIndex)
        else
            CheckBox_SererGroupItem:setSelectedState(false)   
        end

        CheckBox_SererGroupItem:setTouchEnabled(true)
	    CheckBox_SererGroupItem:addEventListenerCheckBox(onClickSelectArea)
        CheckBox_SererGroupItem:setTag(nCurIndex)
        local Label_GroupName = tolua.cast(CheckBox_SererGroupItem:getChildByName("Label_GroupName"),"Label")
        Label_GroupName:setText(_T("所有服务器"))--string.format("安卓%03d--%03d区", 10*(nCurIndex-1)+1, 10*nCurIndex + 1)
    end
    LuaListView_ServerGroupList:setUpdateFunc(updateServerGroupList)
    LuaListView_ServerGroupList:updateItems(1)
end

function showSelectServerWnd()
	rootWidget = GUIReader:shareReader():widgetFromJsonFileEx("Game_SelectServer1.json")
    if StartGameLayer == nil then return end
	StartGameLayer:addWidget(rootWidget)
	rootWidget:setTouchEnabled(true)	

	local function onClickReturn(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			rootWidget:removeFromParentAndCleanup(true)
			CheckBox_SererGroupItem_Current = nil
			rootWidget = nil

            g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_OpenServerForm)
		end
	end

	--关闭按钮
	local Button_Return = tolua.cast(rootWidget:getChildByName("Button_Return"), "Button")
	Button_Return:setTouchEnabled(true)
	Button_Return:addTouchEventListener(onClickReturn)

	initLeftArea()
    g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_OpenServerForm, function()
        -- body
        initLeftArea()
    end)
	
	local Image_ServerStatusPNL = tolua.cast(rootWidget:getChildByName("Image_ServerStatusPNL"), "ImageView")
	local AtlasLabel_ServerStatus1 = tolua.cast(Image_ServerStatusPNL:getChildByName("AtlasLabel_ServerStatus1"), "LabelAtlas")
	local Label_ServerStatus1 = tolua.cast(Image_ServerStatusPNL:getChildByName("Label_ServerStatus1"), "Label")
	local AtlasLabel_ServerStatus2 = tolua.cast(Image_ServerStatusPNL:getChildByName("AtlasLabel_ServerStatus2"), "LabelAtlas")
	local Label_ServerStatus2 = tolua.cast(Image_ServerStatusPNL:getChildByName("Label_ServerStatus2"), "Label")
	local AtlasLabel_ServerStatus3 = tolua.cast(Image_ServerStatusPNL:getChildByName("AtlasLabel_ServerStatus3"), "LabelAtlas")
	local Label_ServerStatus3 = tolua.cast(Image_ServerStatusPNL:getChildByName("Label_ServerStatus3"), "Label")
	local AtlasLabel_ServerStatus4 = tolua.cast(Image_ServerStatusPNL:getChildByName("AtlasLabel_ServerStatus4"), "LabelAtlas")
	local Label_ServerStatus4 = tolua.cast(Image_ServerStatusPNL:getChildByName("Label_ServerStatus4"), "Label")
	g_AdjustWidgetsPosition({AtlasLabel_ServerStatus1, Label_ServerStatus1}, 10)
	g_AdjustWidgetsPosition({Label_ServerStatus1, AtlasLabel_ServerStatus2}, 10)
	g_AdjustWidgetsPosition({AtlasLabel_ServerStatus2, Label_ServerStatus2}, 10)
	g_AdjustWidgetsPosition({Label_ServerStatus2, AtlasLabel_ServerStatus3}, 10)
	g_AdjustWidgetsPosition({AtlasLabel_ServerStatus3, Label_ServerStatus3}, 10)
	g_AdjustWidgetsPosition({Label_ServerStatus3, AtlasLabel_ServerStatus4}, 10)
	g_AdjustWidgetsPosition({AtlasLabel_ServerStatus4, Label_ServerStatus4}, 10)
end