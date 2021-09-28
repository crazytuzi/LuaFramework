--------------------------------------------------------------------------------------
-- 文件名: GFunc_CheckList.lua
-- 版  权:  (C)深圳美天互动科技有限公司
-- 创建人: 陆奎安
-- 日  期:  2013-3-7 9:37
-- 版  本:  1.0
-- 描  述:  通用ListView控件设置函数
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

local Game_CheckList
g_CheckListIndex = 0 

function initListModel(ListView_CheckList, tbCheckList, strSubTitle, onPressed_Option)
	if not ListView_CheckList then
		return 
	end
	
	ListView_CheckList:removeAllChildren()
	ListView_CheckList:removeAllItems()
	
	local Image_CheckListPNL = tolua.cast(Game_CheckList:getChildByName("Image_CheckListPNL"),"ImageView")
	
	local Label_OptionTitle = tolua.cast(Image_CheckListPNL:getChildByName("Label_OptionTitle"),"Label")
	if strSubTitle then
	  Label_OptionTitle:setText(strSubTitle)
	end
	
	local PageView_CheckList = tolua.cast(Image_CheckListPNL:getChildByName("PageView_CheckList"), "PageView")
	for k, v in ipairs(tbCheckList) do
		local Button_CheckListItem = tolua.cast(ListView_CheckList:pushBackDefaultItem(),"Button")
		Button_CheckListItem:setTag(k)
		
		local function onPressed_Button_CheckListItem(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				local nTag = pSender:getTag()
				if type(v) == "table" then
					g_CheckListIndex = g_CheckListIndex *100 + nTag
					local nNextPageIndex = PageView_CheckList:getCurPageIndex() + 1
					local Panel_CheckList = tolua.cast(PageView_CheckList:getPage(nNextPageIndex),"Layout")
					local ListView_CheckList = tolua.cast(Panel_CheckList:getChildByName("ListView_CheckList"),"ListView")
					initListModel(ListView_CheckList, v.Option, v.Title, onPressed_Option)
					PageView_CheckList:scrollToPage(nNextPageIndex)
				else
					g_CheckListIndex = g_CheckListIndex *100 + nTag
					Game_CheckList:removeFromParentAndCleanup(true)
					if onPressed_Option then
						onPressed_Option()
					end
				end
			end
		end 
		
		local LabelBMFont_ItemName = tolua.cast(Button_CheckListItem:getChildByName("Label_ItemName"),"Label")
		local Image_Expand = tolua.cast(Button_CheckListItem:getChildByName("Image_Expand"),"ImageView")
		if type(v) == "table" then
			LabelBMFont_ItemName:setText(v.Title)
			Image_Expand:setVisible(true)
			Button_CheckListItem:addTouchEventListener(onPressed_Button_CheckListItem)
		else
			LabelBMFont_ItemName:setText(v)
			Image_Expand:setVisible(false)
			Button_CheckListItem:addTouchEventListener(onPressed_Button_CheckListItem)
		end
		Button_CheckListItem:setTouchEnabled(true)
	end
end

---参数(label类型, 类似g_province，和需要的总页数)
function initGame_CheckList(tbCheckList, nPageNum, strTitle, onPressed_Option)
	local Image_CheckListPNL = tolua.cast(Game_CheckList:getChildByName("Image_CheckListPNL"),"ImageView")
	local PageView_CheckList = tolua.cast(Image_CheckListPNL:getChildByName("PageView_CheckList"),"PageView")
	local Panel_CheckList = tolua.cast(PageView_CheckList:getChildByName("Panel_CheckList"),"Layout")
	local ListView_CheckList = tolua.cast(Panel_CheckList:getChildByName("ListView_CheckList"),"ListView")
	local Button_CheckListItem = tolua.cast(ListView_CheckList:getChildByName("Button_CheckListItem"),"Button")
   
	local Label_OptionTitle = tolua.cast(Image_CheckListPNL:getChildByName("Label_OptionTitle"), "Label")
	if strTitle == nil then
		strTitle = _T("请选择选项")
	end
	Label_OptionTitle:setText(strTitle)

	PageView_CheckList:setTouchEnabled(false)
  	PageView_CheckList:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)
  	PageView_CheckList:removeAllPages()
  	PageView_CheckList:addPage(Panel_CheckList)
	
	local function initLiseView(listView, itemModel, nTag)
    	listView:setInnerContainerSize(listView:getSize())
    	listView:setTouchEnabled(true)
   		listView:setBounceEnabled(false)
    	listView:setItemModel(itemModel)
    	listView:removeAllChildren()
    	listView:setTag(nTag)
    	listView:setDirection(SCROLLVIEW_DIR_VERTICAL)
	end
	initLiseView(ListView_CheckList, Button_CheckListItem, 1)
  	initListModel(ListView_CheckList, tbCheckList, nil, onPressed_Option)

    if nPageNum and nPageNum >= 2 then
        for nPageIndex = 2, nPageNum do
			local Panel_CheckList = Panel_CheckList:clone()
			local ListView_CheckList = tolua.cast(Panel_CheckList:getChildByName("ListView_CheckList"), "ListView")
			local Button_CheckListItem = tolua.cast(ListView_CheckList:getChildByName("Button_CheckListItem"),"Button")
			initLiseView(ListView_CheckList, Button_CheckListItem, nPageIndex)
			PageView_CheckList:addPage(tolua.cast(Panel_CheckList, "Layout"))
		end
    end
  	local Panel_CheckList = Layout:create()
    PageView_CheckList:addPage(tolua.cast(Panel_CheckList,"Layout"))
end

function g_ShowCheckListWnd(tbCheckList, nPageNum, strTitle, onPressed_Option, onPressed_Cancel)
	Game_CheckList = GUIReader:shareReader():widgetFromJsonFile("Game_CheckList.json")
	g_WndMgr.rootWndMgrLayer:addWidget(Game_CheckList) 
	Game_CheckList:setZOrder(INT_MAX)

	g_CheckListIndex = 0

	local Image_CheckListPNL = tolua.cast(Game_CheckList:getChildByName("Image_CheckListPNL"),"ImageView")
	Image_CheckListPNL:setTouchEnabled(true)

	initGame_CheckList(tbCheckList, nPageNum, strTitle, onPressed_Option)
	
	local Button_Return = tolua.cast(Image_CheckListPNL:getChildByName("Button_Return"),"Button")
	local function onPressed_Button_Return(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local Image_CheckListPNL = tolua.cast(Game_CheckList:getChildByName("Image_CheckListPNL"),"ImageView")
			local PageView_CheckList = tolua.cast(Image_CheckListPNL:getChildByName("PageView_CheckList"),"PageView")
			local nCurrentPageIndex = PageView_CheckList:getCurPageIndex()
			if nCurrentPageIndex == 0 then
				Game_CheckList:removeFromParent()
				if onPressed_Cancel then
					onPressed_Cancel()
				end
			else 
				local Panel_CheckList = PageView_CheckList:getPage(nCurrentPageIndex)
				local ListView_CheckList = tolua.cast(Panel_CheckList:getChildByName("ListView_CheckList"), "ListView")
				if ListView_CheckList then
					ListView_CheckList:removeAllItems()
				end
				g_CheckListIndex = math.floor(g_CheckListIndex/100)
				PageView_CheckList:scrollToPage(nCurrentPageIndex - 1)
			end
		end
	end 
	Button_Return:setTouchEnabled(true)
    Button_Return:addTouchEventListener(onPressed_Button_Return)

	--点击屏幕返回
    local function onTouch_Game_CheckList(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			g_playSoundEffect("Sound/ButtonClick.mp3")
			onPressed_Button_Return(Button_Return, eventType)
        end
    end
	Game_CheckList:setVisible(true)
	Game_CheckList:setTouchEnabled(true)
    Game_CheckList:addTouchEventListener(onTouch_Game_CheckList)
end