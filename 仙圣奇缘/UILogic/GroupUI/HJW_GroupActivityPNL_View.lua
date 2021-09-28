--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupActivityPNL_View.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-11-20
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派活动
---------------------------------------------------------------------------------------

GroupActivityPNL = class("GroupActivityPNL")
GroupActivityPNL.__index = GroupActivityPNL

function GroupActivityPNL:setPanelItem(panel, nIndex)
	local Button = panel:getChildByName("Button_GroupActivityItem")
	local Label_Name = tolua.cast(Button:getChildByName("Label_Name"), "Label")
	Label_Name:setText(self.tbItemList[nIndex]["Name"])
	local Label_Desc = tolua.cast(Button:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(self.tbItemList[nIndex]["Desc"])
	local Image_Icon = tolua.cast(Button:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getImgByPath(self.tbItemList[nIndex]["IconPath"], self.tbItemList[nIndex]["Icon"]))
	local Button_View = tolua.cast(Button:getChildByName("Button_View"), "Button")
	
	local Image_LockerPNL = tolua.cast(Button:getChildByName("Image_LockerPNL"), "ImageView")
	g_SetBlendFuncWidget(Image_LockerPNL, 1)
	
	local function onClick(pSender, nTag)
		g_WndMgr:openWnd(self.tbItemList[nIndex]["BtnEvent"])
	end
	
	local Button_View = tolua.cast(Button:getChildByName("Button_View"), "Button")
	local Label_DetailDesc = tolua.cast(Button:getChildByName("Label_DetailDesc"), "Label")
	if g_Guild:getUserGuildLevel() < self.tbItemList[nIndex]["NeedGuidLevel"] then
		
		Label_DetailDesc:setText( string.format( _T("帮派等级达到%d级解锁"), self.tbItemList[nIndex]["NeedGuidLevel"] ) )
		Image_LockerPNL:setVisible(true)
		Image_Icon:setColor(ccc3(100,100,100))
		Label_DetailDesc:setVisible(true)
		g_SetBtnWithEvent(Button_View, nIndex, onClick, false)
		g_SetBtnWithEvent(Button, nIndex, onClick, false)
	else
		Label_DetailDesc:setText(_T("提升帮派等级可提高活动的奖励"))
		Image_LockerPNL:setVisible(false)
		Image_Icon:setColor(ccc3(255,255,255))
		Label_DetailDesc:setVisible(false)
		g_SetBtnWithEvent(Button_View, nIndex, onClick, true)
		g_SetBtnWithEvent(Button, nIndex, onClick, true)
	end

	local Label_ActivityNum = tolua.cast(Button:getChildByName("Label_ActivityNum"), "Label")
	local Label_ActivityNumMax = tolua.cast(Label_ActivityNum:getChildByName("Label_ActivityNumMax"), "Label")
	Label_ActivityNumMax:setText("/"..self.tbItemList[nIndex]["MaxTimes"])

	local Label_ActivityNum = tolua.cast(Button:getChildByName("Label_ActivityNum"), "Label")
	local nNum = 0
	if macro_pb.GAT_JI_XING_GAO_ZHAO == nIndex then
		nNum = g_Hero:getDailyNoticeByType(macro_pb.DT_JiXing)
	elseif macro_pb.GAT_WORLD_BOSS == nIndex then
		nNum = g_Hero:getDailyNoticeByType(macro_pb.DT_GUILD_WORLD_BOSS)
	elseif macro_pb.GAT_SCENE_BOSS == nIndex and g_Guild:getUserGuildLevel() >= self.tbItemList[nIndex]["NeedGuidLevel"] then
		nNum = 1 - g_Hero:getBubbleNotify(macro_pb.NT_GuildSceneBoss)
	end
	Label_ActivityNum:setText(tostring(nNum))
	if nNum < self.tbItemList[nIndex]["MaxTimes"] then
		Label_ActivityNum:setColor(ccc3(0,255,0))
	else
		Label_ActivityNum:setColor(ccc3(255,0,0))
	end
	Label_ActivityNumMax:setPositionX(Label_ActivityNum:getSize().width)
end

function GroupActivityPNL:init(widget)
	-- self.widget = widget
	local Image_GroupActivityPNL = tolua.cast(widget:getChildByName("Image_GroupActivityPNL"), "ImageView")
	Image_GroupActivityPNL:setVisible(true)

	self.ListView_GroupActivity = tolua.cast(Image_GroupActivityPNL:getChildByName("ListView_GroupActivity"), "ListViewEx")
	self.ListView_GroupActivity:setVisible(true)
	local Panel_GroupActivityItem = self.ListView_GroupActivity:getChildByName("Panel_GroupActivityItem")
	registerListViewEvent(self.ListView_GroupActivity, Panel_GroupActivityItem, handler(self, self.setPanelItem))

	self.tbItemList = self.tbItemList or g_DataMgr:getCsvConfig("GuildActivity")
	self.ListView_GroupActivity:updateItems(#self.tbItemList)
end

function GroupActivityPNL:refresh()
	self.ListView_GroupActivity:updateItems(#self.tbItemList)
end

function GroupActivityPNL:getBubble()
	self.tbItemList = self.tbItemList or g_DataMgr:getCsvConfig("GuildActivity")
	local total = 0
	for k,v in ipairs(self.tbItemList) do
		if g_Guild:getUserGuildLevel() >= v.NeedGuidLevel then
			total = total + v.MaxTimes
		end
	end
	total = total - g_Hero:getDailyNoticeByType(macro_pb.DT_JiXing) -  g_Hero:getDailyNoticeByType(macro_pb.DT_GUILD_WORLD_BOSS)
	if g_Guild:getUserGuildLevel() >= self.tbItemList[macro_pb.GAT_SCENE_BOSS]["NeedGuidLevel"] then
		total = total - (1 - g_Hero:getBubbleNotify(macro_pb.NT_GuildSceneBoss))
	end
	if g_Hero:getBubbleNotify(macro_pb.NT_GuildWorldBoss) == 0 and g_Guild:getUserGuildLevel() >= self.tbItemList[macro_pb.GAT_WORLD_BOSS]["NeedGuidLevel"] then
		total = total - self.tbItemList[macro_pb.GAT_WORLD_BOSS]["MaxTimes"] + g_Hero:getDailyNoticeByType(macro_pb.DT_GUILD_WORLD_BOSS)
	end
	return total
end


