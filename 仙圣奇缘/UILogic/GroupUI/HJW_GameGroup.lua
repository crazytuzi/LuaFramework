--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameGroup.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-04-01
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派主界面
---------------------------------------------------------------------------------------

Game_Group = class("Game_Group")
Game_Group.__index = Game_Group

TB_FUNC_TYPE_NAME = {
	GroupPNL = 1,
	GroupBuildingPNL = 2,
	GroupActivityPNL = 3,
	GroupRankPNL = 4,
	GroupLogPNL = 5,
}


function Game_Group:initWnd()
	--帮派建筑
	--万宝楼
	local chooseType = g_Guild:getLastChooseType(1)
	local chooseTimeat = g_Guild:getLastChooseTimeat(1)
	if chooseTimeat ~= 0 then 
		if SecondsToTable( g_GetServerTime() - (chooseTimeat)  ).hour >= 24 then
			 g_Guild:setLastChooseTimeat(1, 0)
			 g_Guild:setLastChooseType(1, 0)
		end
	end
	--书画院
	local chooseType = g_Guild:getLastChooseType(2)
	local chooseTimeat = g_Guild:getLastChooseTimeat(2)
	if chooseTimeat ~= 0 then 
		if SecondsToTable( g_GetServerTime() - (chooseTimeat)  ).hour >= 24 then
			 g_Guild:setLastChooseTimeat(2, 0)
			 g_Guild:setLastChooseType(2, 0)
		end
	end
end

function Game_Group:openWnd()	
	
	--帮派公告
	self:groupNotice()

	if g_bReturn  then    
		if self.nCurIndex == 3 then
			self.groupfunc_[self.nCurIndex]:refresh()
		end
	else
		self.tbButton_FunctionItem = {}
		--请求帮派成员信息
		g_Guild:requestGuildMemListRequest()
		
		self.tbPNL = {
			"Image_GroupPNL",
			"Image_GroupBuildingPNL",
			"Image_GroupActivityPNL",
			"Image_GroupRankPNL",
			"Image_GroupLogPNL",
		}
		self.tbFunctionName = {
			_T("帮派信息"),
			_T("帮派建设"),
			_T("帮派活动"),
			_T("帮派排名"),
			_T("帮派日志"),
		}
		self.tbFunction = {
			GroupPNL.new(),
			GroupBuildingPNL.new(),
			GroupActivityPNL.new(),
			GroupRankPNL.new(),
			GroupLogPNL.new(),
		}	
		self.groupfunc_ = {}
		for i = 1,#self.tbFunction do 
			if self.tbFunction[i] then 
			table.insert(self.groupfunc_,self.tbFunction[i])
			end
		end
	
		self:ListViewFunction()
		self:setVisiblePnl()
		self:adjustOverFunc(self.LuaListView:getChildByIndex(0), 1)
		
		--刷新一次聊天信息
		self.groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:groupChatView()
		
	end
	
	self:setGroupRequestNotice(self.nCurIndex)
end

function Game_Group:closeWnd()
	self.tbFunctionName = nil
	self.tbFunction = nil
	self.groupfunc_ = nil
	self.tbPNL = nil

	--add by zgj
	GroupChat:destroy()

end


--帮派公告
function Game_Group:groupNotice()
	local Image_NoticePNL = tolua.cast(self.rootWidget:getChildByName("Image_NoticePNL"), "ImageView")
	local Label_NoticeLB = tolua.cast(Image_NoticePNL:getChildByName("Label_NoticeLB"), "Label")
	local ScrollView_Notice = tolua.cast(Image_NoticePNL:getChildByName("ScrollView_Notice"), "ScrollView")
	local Label_Notice = tolua.cast(ScrollView_Notice:getChildByName("Label_Notice"), "Label")
	Label_Notice:setText(g_stringSize_insert(g_Guild:getGuildAnnouncement(),"\n",24,300))
	local nHeight = math.max(Label_Notice:getSize().height + 40, 130)
	ScrollView_Notice:setInnerContainerSize(CCSize(300, nHeight))
	Label_Notice:setPositionXY(5, nHeight)
end

--功能模块选择
function Game_Group:ListViewFunction()

	local Image_FunctionPNL = tolua.cast(self.rootWidget:getChildByName("Image_FunctionPNL"), "ImageView")
	local ListView_Function = tolua.cast(Image_FunctionPNL:getChildByName("ListView_Function"), "ListViewEx")
	local Panel_FunctionItem1 = tolua.cast(ListView_Function:getChildByName("Panel_FunctionItem1"), "Layout")
	
	local function updateListViewItem(Panel_FunctionItem1, nIndex)	
		local Button_FunctionItem = tolua.cast(Panel_FunctionItem1:getChildByName("Button_FunctionItem"), "Button")
		local BitmapLabel_FuncName = tolua.cast(Button_FunctionItem:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setText(self.tbFunctionName[nIndex])
		local function onGroupManageMent(pSender,eventType)
			if eventType == ccs.TouchEventType.ended then	
				self.LuaListView:scrollToTop()--pSender:getParent()
			end
		end
		Button_FunctionItem:setTouchEnabled(true)	
		Button_FunctionItem:addTouchEventListener(onGroupManageMent)
		Button_FunctionItem:setTag(nIndex)
		Button_FunctionItem:loadTextures(getUIImg("ListItem_Mail"),getUIImg("ListItem_Mail_Check_Press"),getUIImg("ListItem_Mail"))

		table.insert(self.tbButton_FunctionItem, Button_FunctionItem)
		--打点
		self:setGroupRequestNotice(nIndex)
	end

	local function adjustFunc(Panel_FunctionItem1, index)
		self:adjustItem(Panel_FunctionItem1, index)
	end
	self.LuaListView = registerListViewEvent(ListView_Function, Panel_FunctionItem1, updateListViewItem, nil, adjustFunc)
	self.LuaListView:updateItems(#self.tbFunctionName)
	self.LuaListView:setAdjustOverFunc(handler(self, self.adjustOverFunc))
end

function Game_Group:adjustItem(Panel_FunctionItem1, index)
	if self.curButton and self.curButton:isExsit() then
		self.curButton:loadTextures(getUIImg("ListItem_Mail"),getUIImg("ListItem_Mail_Check"),getUIImg("ListItem_Mail"))
	end
	local Button_FunctionItem = tolua.cast(Panel_FunctionItem1:getChildByName("Button_FunctionItem"), "Button")
	Button_FunctionItem:loadTextures(getUIImg("ListItem_Mail_Check_Press"),getUIImg("ListItem_Mail_Check"),getUIImg("ListItem_Mail_Check_Press"))
	self.curButton = Button_FunctionItem


end
function Game_Group:adjustOverFunc(Panel_FunctionItem1, index)
	self.nCurIndex = index
	if self.groupfunc_[index] then 
		self:setVisiblePnl()
		self.groupfunc_[index]:init(self.rootWidget)
	end
end

function Game_Group:setVisiblePnl()
	for i = 1, #self.tbPNL do 
		local pnl = tolua.cast(self.rootWidget:getChildByName(self.tbPNL[i]), "ImageView")
		pnl:setVisible(false)
	end
end


function Game_Group:setGroupRequestNotice(nType)
	if nType == TB_FUNC_TYPE_NAME.GroupBuildingPNL or
		nType == TB_FUNC_TYPE_NAME.GroupActivityPNL then 
		--打点
		if self.groupfunc_[nType].getBubble then 
			g_SetBubbleNotify(self.tbButton_FunctionItem[nType], self.groupfunc_[nType]:getBubble(), 120, 20)
		end
	end
end
