---------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupRankPNL_View.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-11-20
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派排名
---------------------------------------------------------------------------------------

GroupRankPNL = class("GroupRankPNL")
GroupRankPNL.__index = GroupRankPNL

g_LuaListView_GroupList_Index = 1

function GroupRankPNL:init(widget)
	if not widget then return end
	self.widget = widget

	g_Guild:setPageNum(0)
	g_Guild:setOffset(g_Guild:getDefaultPageNum())
	g_LuaListView_GroupList_Index = 1
	
	g_Guild:removeGuildListAll()
	g_Guild:GuildListRequest(0)

	local Image_GroupRankPNL = tolua.cast(widget:getChildByName("Image_GroupRankPNL"), "ImageView")
	Image_GroupRankPNL:setVisible(true)
	self:listViewShow()
	
end


function GroupRankPNL:listViewShow()
	if not self.widget then return end 
	local tbGuildList = g_Guild:getGuildListInfo()
	if not tbGuildList then return end
	
	local Image_GroupRankPNL = tolua.cast(self.widget:getChildByName("Image_GroupRankPNL"), "ImageView")

	local ListView_GroupRankList = tolua.cast(Image_GroupRankPNL:getChildByName("ListView_GroupRankList"),"ListViewEx")
	local Panel_GroupItem = tolua.cast(ListView_GroupRankList:getChildByName("Panel_GroupItem"),"Layout")
	
	local LuaListView_GroupList = Class_LuaListView:new()
    self.LuaListView_GroupList = LuaListView_GroupList
	local function updateListViewItem(Panel_GroupItem, nIndex)
		local tbGuildList = g_Guild:getGuildListInfo()
		local guildName = tbGuildList[nIndex].name
		local kingid = tbGuildList[nIndex].kingid
		local nLevel = tbGuildList[nIndex].level
		local kingName = tbGuildList[nIndex].king_name
		local kingBreachlv = tbGuildList[nIndex].king_breachlv
		local kingStar = tbGuildList[nIndex].king_star
		local kingCard = tbGuildList[nIndex].king_card
		local isReq = tbGuildList[nIndex].is_req
		
		local Button_GroupItem = tolua.cast(Panel_GroupItem:getChildByName("Button_GroupItem"),"Button")
		--帮派名称
		local Label_GroupName = tolua.cast(Button_GroupItem:getChildByName("Label_GroupName"),"Label")
		Label_GroupName:setText(guildName)
		--帮派等级
		local Label_GroupLevel = tolua.cast(Button_GroupItem:getChildByName("Label_GroupLevel"),"Label")
		Label_GroupLevel:setText(nLevel.._T("级"))
		-- Label_GroupLevel:setPositionX(Label_GroupName:getSize().width)
		g_AdjustWidgetsPosition({Label_GroupName, Label_GroupLevel},10)
		--帮主头像 
		--底框
		local Image_Head = tolua.cast(Button_GroupItem:getChildByName("Image_Head"),"ImageView")
		local Image_Icon = getCardIconImg(kingCard,kingStar)
		local kingUin = tbGuildList[nIndex].king_uin or 0
		local vip = tbGuildList[nIndex].vip or 0
		g_SetPlayerHead(Image_Head,{vip = vip,uin = kingUin,star = kingStar,breachlv = kingBreachlv,Image_Icon = Image_Icon},true)

		--帮主名称
		local Label_PresidentNameLB = tolua.cast(Button_GroupItem:getChildByName("Label_PresidentNameLB"),"Label")
		local Label_PresidentName = tolua.cast(Label_PresidentNameLB:getChildByName("Label_PresidentName"),"Label")
		local param = {
			name = kingName, breachLevel = kingBreachlv, lableObj = Label_PresidentName,
		}
		g_Guild:setLableByColor(param)
		
		Label_PresidentName:setPositionX(Label_PresidentNameLB:getSize().width)
		
		local function onBtnFuncRequest(pSender,eventType)
			if eventType == ccs.TouchEventType.ended then	
				g_WndMgr:showWnd("Game_GroupView",tbGuildList[nIndex])
			end
		end
		
		--按钮
		local Button_View = tolua.cast(Button_GroupItem:getChildByName("Button_View"),"Button")
		Button_View:setTouchEnabled(true)	
		Button_View:addTouchEventListener(onBtnFuncRequest)
		local BitmapLabel_FuncName = tolua.cast(Button_View:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	
		
		--帮派排名
		local LabelBMFont_Rank = tolua.cast(Button_GroupItem:getChildByName("LabelBMFont_Rank"),"LabelBMFont")
		if nIndex > 3 then
			LabelBMFont_Rank:setFntFile("Char/Char_AreanaRank2.fnt")
			LabelBMFont_Rank:setText(nIndex)
		else
			LabelBMFont_Rank:setFntFile("Char/Char_AreanaRank1.fnt")
			LabelBMFont_Rank:setText(nIndex)
		end
		--帮派成员 拥有多少人员/人员上限
		local Label_MemberCount = tolua.cast(Button_GroupItem:getChildByName("Label_MemberCount"),"Label")
		local cur_mem_num = tbGuildList[nIndex].cur_mem_num
		local max_mem_num = tbGuildList[nIndex].max_mem_num
		Label_MemberCount:setText(cur_mem_num.."/"..max_mem_num)
	end
	
	-- local c = 10
	-- 记录滑动到什么位置了
	local function onAdjustListView(Panel_GroupItem, nIndex)
		g_LuaListView_GroupList_Index = nIndex
		if nIndex == g_Guild:getOffset()  then 
			-- 向服务器请求
			g_Guild:addPageNum(1)
			g_Guild:GuildListRequest(g_Guild:getPageNum())
			g_Guild:addOffset(20)
		end
    end
    self.LuaListView_GroupList:setModel(Panel_GroupItem)
	self.LuaListView_GroupList:setAdjustFunc(onAdjustListView)
    self.LuaListView_GroupList:setUpdateFunc(updateListViewItem)
    self.LuaListView_GroupList:setListView(ListView_GroupRankList)
	g_LuaListView_GroupList_Index = g_LuaListView_GroupList_Index or 1
	self.LuaListView_GroupList:updateItems(#tbGuildList, g_LuaListView_GroupList_Index)
end



