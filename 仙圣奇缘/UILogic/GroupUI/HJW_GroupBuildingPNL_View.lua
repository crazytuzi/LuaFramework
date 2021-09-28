--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupBuildingPNL_View.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-11-20
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派建设
---------------------------------------------------------------------------------------

GroupBuildingPNL = class("GroupBuildingPNL")
GroupBuildingPNL.__index = GroupBuildingPNL

function GroupBuildingPNL:setPanelItem(panel, nIndex)
	local Button = panel:getChildByName("Button_GroupBuildingItem")
	local Label_Name = tolua.cast(Button:getChildByName("Label_Name"), "Label")
	Label_Name:setText(self.tbItemList[nIndex]["Name"])
	local Label_Desc = tolua.cast(Button:getChildByName("Label_Desc"), "Label")
	
	
	local txt = self.tbItemList[nIndex]["Desc"]
	if self.tbItemList[nIndex].BuildingID == 1 then 
		local energy = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel()).EnergyReward
		
		local buildLevel = g_Guild:getUserGuildLevel() + 1
		local flag = false
		local Next_CSV_tbMsg = g_DataMgr:getCsvConfigByOneKey("GuildLevel", buildLevel)
		if  Next_CSV_tbMsg.MemberLimit == 0 then
			buildLevel =  g_Guild:getUserGuildLevel()
			flag = true
		end
		
		local nextEnergy = g_DataMgr:getCsvConfigByOneKey("GuildLevel",buildLevel).EnergyReward
		txt = _T("当前每天可以领取")..energy.._T("体力").."\n".._T("下一等级每天可以领取")..nextEnergy.._T("体力")
		if flag then 
			txt = _T("当前每天可以领取")..energy.._T("体力").."\n".._T("已满级")
		end
	
	end
	Label_Desc:setText(txt)
	
	local Image_Icon = tolua.cast(Button:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getImgByPath(self.tbItemList[nIndex]["IconPath"], self.tbItemList[nIndex]["Icon"]))
	
	local Image_LockerPNL = tolua.cast(Button:getChildByName("Image_LockerPNL"), "ImageView")
	g_SetBlendFuncWidget(Image_LockerPNL, 1)
	
	local function onClick(pSender, nTag)
	
		local Button_View = tolua.cast(pSender:getChildByName("Button_View"), "Button")
		if Button_View then 
			self.ButtonViewObj_ = Button_View
		else
			self.ButtonViewObj_ = pSender
		end
		
		if self.tbItemList[nIndex].BuildingID == 1 then 
			-- local energy = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel()).EnergyReward
			-- echoj("静心斋领体力",energy)
			if g_Guild:getBuildTimeatList(macro_pb.GuildBuildType_Jingxinzai) > 0 then 
				return
			end
			g_BuildingElement:requestGuildBuildingRecvTili()
			
			self.ButtonViewObj_:setTouchEnabled(false)	

			self.ButtonViewObj_:setBright(false)
	
		else
			local buildName = self.tbItemList[nIndex]["BtnEvent"]
			local param = {
				buildName = buildName ,
				buildType = nIndex,
			}
			g_WndMgr:showWnd(buildName,param)
		end
	end
	
	local Button_View = tolua.cast(Button:getChildByName("Button_View"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_View:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText(self.tbItemList[nIndex]["BtnName"])
	
	self:setGroupBuildingNotice(nIndex ,Button_View)
	-- table.insert(self.btnView, Button_View)
	
	
	local Label_DetailDesc = tolua.cast(Button:getChildByName("Label_DetailDesc"), "Label")
	if g_Guild:getUserGuildLevel() < self.tbItemList[nIndex]["NeedGuidLevel"] then
		
		Label_DetailDesc:setText(string.format(_T("帮派等级达到%d级解锁"), self.tbItemList[nIndex]["NeedGuidLevel"]))
		Image_LockerPNL:setVisible(true)
		Image_Icon:setColor(ccc3(100,100,100))
		Label_DetailDesc:setVisible(true)
		g_SetBtnWithEvent(Button_View, nIndex, onClick, false)
		g_SetBtnWithEvent(Button, nIndex, onClick, false)
	else
		Label_DetailDesc:setText(string.format(_T("帮派等级达到%d级解锁"), self.tbItemList[nIndex]["NeedGuidLevel"]))
		Image_LockerPNL:setVisible(false)
		Image_Icon:setColor(ccc3(255,255,255))
		Label_DetailDesc:setVisible(false)
		local flag = true
		if self.tbItemList[nIndex].BuildingID == 1 then 
			if g_Guild:getBuildTimeatList(macro_pb.GuildBuildType_Jingxinzai) > 0 then 
				flag = false
			end
		end
		
		--静心斋领体力是否已经领取过了
		g_SetBtnWithEvent(Button_View, nIndex, onClick, flag )
		g_SetBtnWithEvent(Button, nIndex, onClick, true)
	end
end

function GroupBuildingPNL:init(widget)

	-- self.btnView =  {}
	self.ButtonViewObj_ = nil
	local Image_GroupBuildingPNL = tolua.cast(widget:getChildByName("Image_GroupBuildingPNL"), "ImageView")
	Image_GroupBuildingPNL:setVisible(true)
		
	
	local Button_EnterJiHuiSuo = tolua.cast(Image_GroupBuildingPNL:getChildByName("Button_EnterJiHuiSuo"), "Button")
	local function onBuilding(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			--帮派领地	
			g_WndMgr:openWnd("Game_JiHuiSuo")
		end
	end
	Button_EnterJiHuiSuo:setTouchEnabled(true)	
	Button_EnterJiHuiSuo:addTouchEventListener(onBuilding)
	
	self.ListView_GroupBuilding = tolua.cast(Image_GroupBuildingPNL:getChildByName("ListView_GroupBuilding"), "ListViewEx")
	self.ListView_GroupBuilding:setVisible(true)
	local Panel_GroupBuildingItem = self.ListView_GroupBuilding:getChildByName("Panel_GroupBuildingItem")
	registerListViewEvent(self.ListView_GroupBuilding, Panel_GroupBuildingItem, handler(self, self.setPanelItem))

	self.tbItemList = g_DataMgr:getCsvConfig("GuildBuilding")
	self.ListView_GroupBuilding:updateItems(#self.tbItemList)
	
end

-- function GroupBuildingPNL:refresh()
	-- self.ListView_GroupBuilding:updateItems(#self.tbItemList)
-- end

-- GuildBuildType_Jingxinzai = 1;			// 静心斋
-- GuildBuildType_Wanbaolou = 2;			// 万宝楼
-- GuildBuildType_Shuhuayuan = 3;			// 书画院
-- GuildBuildType_Lianshenta = 4;			// 炼神塔
-- GuildBuildType_Jingangtang = 5;			// 金刚堂
-- GuildBuildType_Shenbingdian = 6;		// 神兵殿
function GroupBuildingPNL:setGroupBuildingNotice(nIndex, btn)
	local num = 0
	if nIndex == macro_pb.GuildBuildType_Jingxinzai then
		-- 静心斋
		num = g_GetNoticeNum_GroupJinXinZhai() 
	elseif nIndex == macro_pb.GuildBuildType_Wanbaolou then 
		--万宝楼
		 num = g_GetNoticeNum_GroupWanBaoLou()
	elseif nIndex == macro_pb.GuildBuildType_Shuhuayuan then 
		-- 书画院
		 num = g_GetNoticeNum_GroupShuHuaYuan()
	elseif nIndex == macro_pb.GuildBuildType_Lianshenta then 
		-- 炼神塔
		 num = g_GetNoticeNum_GroupSkillBuild(nIndex)
	elseif nIndex == macro_pb.GuildBuildType_Jingangtang then 
		--金刚堂
		 num = g_GetNoticeNum_GroupSkillBuild(nIndex)
	elseif nIndex == macro_pb.GuildBuildType_Shenbingdian then 
		-- 神兵殿
		 num = g_GetNoticeNum_GroupSkillBuild(nIndex)
	end
	g_SetBubbleNotify(btn, num, 80, 20)
end

function GroupBuildingPNL:getBubble()
	local num = g_GetNoticeNum_GroupJinXinZhai() +  g_GetNoticeNum_GroupWanBaoLou()
		+ g_GetNoticeNum_GroupShuHuaYuan() + g_GetNoticeNum_GroupSkillBuild(macro_pb.GuildBuildType_Lianshenta)
		+  g_GetNoticeNum_GroupSkillBuild(macro_pb.GuildBuildType_Jingangtang) + g_GetNoticeNum_GroupSkillBuild( macro_pb.GuildBuildType_Shenbingdian)
	return num
end

function GroupBuildingPNL:refreshBtnView()

	if self.ButtonViewObj_ and self.ButtonViewObj_:isExsit() then 
		self:setGroupBuildingNotice(self.ButtonViewObj_:getTag(), self.ButtonViewObj_)
	end
end
