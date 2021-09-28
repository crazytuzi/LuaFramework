--------------------------------------------------------------------------------------
-- 文件名: CNewPlayerGuid.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 李玉平
-- 日  期:    2014-6-5 11:10
-- 版  本:    1.0
-- 描  述:    新手引导界面
-- 应  用:
---------------------------------------------------------------------------------------

local CNewPlayerGuid = class("CNewPlayerGuid")
CNewPlayerGuid.__index = CNewPlayerGuid


g_IsGuideWidgetInLock = nil
g_bIsInGuiding = nil
g_nStartEctypeGuideIndex = 8

if g_Cfg.Platform == kTargetWindows then
	g_nForceGuideMaxID = 10--10	--新手引导强制引导id最大值
else
	g_nForceGuideMaxID = 10--10	--新手引导强制引导id最大值
end

function CNewPlayerGuid:showGuideClick(CSV_GuideSequence)
	self.curGuideWidget = nil
	
	if CSV_GuideSequence.GuideType == 4 then
		self:setGuideVisible(false)
	else
		self:setGuideVisible(true)
	end
	
	if CSV_GuideSequence.GuideType == 5 then
		self:setGuideVisible(false)
		if g_WndMgr:isVisible("Game_Home") then
			mainWnd.Image_MainHomeUIPNL:setVisible(false)
			mainWnd:showMainHomeZoomInAnimation()
			local function funcDialogueEndCall()
				mainWnd.Image_MainHomeUIPNL:setVisible(true)
				mainWnd:showMainHomeZoomOutAnimation()
				self.nCurrentGuideID = self.nNewGuideID
				self.nCurrentGuideIndex = self.nNewGuideIndex
				self:showCurrentGuideSequenceNode()
			end
			g_DialogueData:showDialogueSequence(CSV_GuideSequence.DialogueID, 1, funcDialogueEndCall)
		else
			local function funcDialogueEndCall()
				self.nCurrentGuideID = self.nNewGuideID
				self.nCurrentGuideIndex = self.nNewGuideIndex
				self:showCurrentGuideSequenceNode()
			end
			g_DialogueData:showDialogueSequence(CSV_GuideSequence.DialogueID, 1, funcDialogueEndCall)
		end
	end
	
	local strWndName = nil
	if CSV_GuideSequence.WndName ~= "" then --没有窗口名字
		local tbWndNameSuffix = string.split(CSV_GuideSequence.WndName, "|")
		local nMax = #tbWndNameSuffix
		if nMax > 1 then
			for i = 1, nMax do
				if g_WndMgr:getWnd(tbWndNameSuffix[i]) and g_WndMgr:isVisible(tbWndNameSuffix[i]) then
					strWndName = tbWndNameSuffix[i]
					break
				end
			end
		else
			strWndName = CSV_GuideSequence.WndName
		end
		
		cclog("============窗口名称=============="..strWndName)
		if CSV_GuideSequence.WidgetNameTree == "" then
			cclog("============控件路径为空==============")
			return
		end
		
		local wndInstance = g_WndMgr:getWnd(strWndName)
		self.lastWndInstance = wndInstance
		if not wndInstance then
			cclog("============窗口名称=============="..CSV_GuideSequence.WndName.."不存在,检查下配置")
			return
		end
		local tbWidget = string.split(CSV_GuideSequence.WidgetNameTree, ":")
		local widget = nil
		local widgetParent = wndInstance.rootWidget
		local nMax = #tbWidget
		for i = 1, nMax do
			if tbWidget[i] == "getFirstChild" then
				widget = widgetParent:getFirstChild()
				if widget then
					widgetParent = widget
					cclog("============控件名=============="..widgetParent:getName())
				else
					cclog("============控件找不到=============="..tbWidget[i])
					break
				end
			elseif tbWidget[i] == "getSecondChild" then
				local nFirstChildTag = widgetParent:getFirstChild():getTag()
				widget = widgetParent:getChildByTag(nFirstChildTag + 1)
				if widget then
					widgetParent = widget
					cclog("============控件名=============="..widgetParent:getName())
				else
					cclog("============控件找不到=============="..tbWidget[i])
					return
				end
			else
				widget = widgetParent:getChildByName(tbWidget[i])
				if widget then
					widgetParent = widget
					cclog("============控件名=============="..widgetParent:getName())
				else
					cclog("============控件找不到=============="..tbWidget[i])
					return
				end
			end
		end
		
		if not widget then
			cclog("============控件找不到引导流程中断跳过==============")
		end
		
		cclog("============最后面找到的控件=============="..widget:getName())
		self.curGuideWidget = widget
		self.strCurWidgetName = widget:getName()
		
		local nBegin1, nEnd1 = string.find(tbWidget[nMax], "Button_Building")
		if nBegin1 then
			mainWnd:centerBuildingPosition(self.curGuideWidget, nil)
		end
		
		if tbWidget[nMax] == "Image_ContainerCover" then
			mainWnd:showMainButtonOpenAction()
		end
		
		if CSV_GuideSequence.IsAddToParent == 4 then return end
		
		--显示NPCTip
		local armature, userAnimation = g_CreateCoCosAnimation("OnTouchGuide", nil, 2)
		if(CSV_GuideSequence.GuideType == 1)then
			self.nDragTouchLock = true
			userAnimation:playWithIndex(0)
		elseif(CSV_GuideSequence.GuideType == 2)then
			self.nDragTouchLock = false
			userAnimation:playWithIndex(1)
		elseif(CSV_GuideSequence.GuideType == 3)then
			self.nDragTouchLock = false
			userAnimation:playWithIndex(2)
		end
		self.lastArmature = armature
		
		if CSV_GuideSequence.IsAddToParent == 0 then
			armature:setPositionXY(CSV_GuideSequence.OffsetX, CSV_GuideSequence.OffsetY)
			self.curGuideWidget:addNode(armature, INT_MAX)
			if CSV_GuideSequence.NPCType == 5 or CSV_GuideSequence.NPCType == 6 then
				self.Image_NPCGuideTipPNL = tolua.cast(g_WidgetModel.Image_NPCGuideTipPNL:clone(), "ImageView")
				if CSV_GuideSequence.NPCType == 5 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(-150)
					Image_NPC:setScaleX(1)
				elseif CSV_GuideSequence.NPCType == 6 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(-30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(150)
					Image_NPC:setScaleX(-1)
				end
				self.curGuideWidget:addChild(self.Image_NPCGuideTipPNL, INT_MAX)
				self.Image_NPCGuideTipPNL:setPositionXY(CSV_GuideSequence.TipOffsetX, CSV_GuideSequence.TipOffsetY)
			end
		elseif CSV_GuideSequence.IsAddToParent == 1 then
			local tbPos = self.curGuideWidget:getPosition()
			armature:setPositionXY(tbPos.x + CSV_GuideSequence.OffsetX, tbPos.y + CSV_GuideSequence.OffsetY)
			self.curGuideWidget:getParent():addNode(armature, INT_MAX)
			if CSV_GuideSequence.NPCType == 5 or CSV_GuideSequence.NPCType == 6 then
				self.Image_NPCGuideTipPNL = tolua.cast(g_WidgetModel.Image_NPCGuideTipPNL:clone(), "ImageView")
				if CSV_GuideSequence.NPCType == 5 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(-150)
					Image_NPC:setScaleX(1)
				elseif CSV_GuideSequence.NPCType == 6 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(-30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(150)
					Image_NPC:setScaleX(-1)
				end
				self.curGuideWidget:getParent():addChild(self.Image_NPCGuideTipPNL, INT_MAX)
				self.Image_NPCGuideTipPNL:setPositionXY(tbPos.x + CSV_GuideSequence.TipOffsetX, tbPos.y + CSV_GuideSequence.TipOffsetY)
			end
		elseif CSV_GuideSequence.IsAddToParent == 2 then
			local tbWorldPos = self.curGuideWidget:getWorldPosition()
			local widgetRoot = self.lastWndInstance.rootWidget:getChildByName(tbWidget[1])
			local tbWorldPosRoot = widgetRoot:getWorldPosition()
			armature:setPositionXY((tbWorldPos.x - tbWorldPosRoot.x) + CSV_GuideSequence.OffsetX, (tbWorldPos.y - tbWorldPosRoot.y) + CSV_GuideSequence.OffsetY)
			widgetRoot:addNode(armature, INT_MAX)
			if CSV_GuideSequence.NPCType == 5 or CSV_GuideSequence.NPCType == 6 then
				self.Image_NPCGuideTipPNL = tolua.cast(g_WidgetModel.Image_NPCGuideTipPNL:clone(), "ImageView")
				if CSV_GuideSequence.NPCType == 5 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(-150)
					Image_NPC:setScaleX(1)
				elseif CSV_GuideSequence.NPCType == 6 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(-30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(150)
					Image_NPC:setScaleX(-1)
				end
				widgetRoot:addChild(self.Image_NPCGuideTipPNL, INT_MAX)
				self.Image_NPCGuideTipPNL:setPositionXY((tbWorldPos.x - tbWorldPosRoot.x) + CSV_GuideSequence.TipOffsetX, (tbWorldPos.y - tbWorldPosRoot.y) + CSV_GuideSequence.TipOffsetY)
			end
		elseif CSV_GuideSequence.IsAddToParent == 3 then
			local tbWorldPos = self.curGuideWidget:getWorldPosition()
			armature:setPositionXY(tbWorldPos.x + CSV_GuideSequence.OffsetX, tbWorldPos.y + CSV_GuideSequence.OffsetY)
			wndInstance.rootWidget:addNode(armature, INT_MAX)
			if CSV_GuideSequence.NPCType == 5 or CSV_GuideSequence.NPCType == 6 then
				self.Image_NPCGuideTipPNL = tolua.cast(g_WidgetModel.Image_NPCGuideTipPNL:clone(), "ImageView")
				if CSV_GuideSequence.NPCType == 5 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(-150)
					Image_NPC:setScaleX(1)
				elseif CSV_GuideSequence.NPCType == 6 then
					local Label_GuideTalk = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Label_GuideTalk"), "Label")
					local CCNode_GuideTalk = tolua.cast(Label_GuideTalk:getVirtualRenderer(), "CCLabelTTF")
					CCNode_GuideTalk:disableShadow(true)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_GuideTalk:setFontSize(19)
					end
					Label_GuideTalk:setText(CSV_GuideSequence.Context)
					Label_GuideTalk:setPositionX(-30)
					local Image_NPC = tolua.cast(self.Image_NPCGuideTipPNL:getChildByName("Image_NPC"), "ImageView")
					Image_NPC:setPositionX(150)
					Image_NPC:setScaleX(-1)
				end
				wndInstance.rootWidget:addChild(self.Image_NPCGuideTipPNL, INT_MAX)
				local tbWorldPos = self.curGuideWidget:getWorldPosition()
				self.Image_NPCGuideTipPNL:setPositionXY(tbWorldPos.x + CSV_GuideSequence.TipOffsetX, tbWorldPos.y + CSV_GuideSequence.TipOffsetY)
			end
		end
		
	else
		cclog("============窗口找不到=============="..CSV_GuideSequence.WndName)
		self:RemoveLastArmature()
		if self.lastWndInstance and self.Image_NPCGuideTipPNL and self.Image_NPCGuideTipPNL:isExsit() then
			self.Image_NPCGuideTipPNL:removeFromParentAndCleanup(true)
			self.Image_NPCGuideTipPNL = nil
		end
	end
end

function CNewPlayerGuid:RemoveLastArmature()
	if g_OnExitGame then
		if self.lastArmature and self.lastArmature:isExsit() then
			self.lastArmature:removeFromParentAndCleanup(true)
			self.lastArmature = nil
		end
	else
		if self.lastArmature then
			self.lastArmature:removeFromParentAndCleanup(true)
			self.lastArmature = nil
		end
	end
	
end

function CNewPlayerGuid:showGuide(CSV_GuideSequence, funcNpcEndCall)
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end
	
	if CSV_GuideSequence.IsForced == 1 then
		self.rootWidget:setTouchEnabled(true)
		self.rootWidget:setVisible(true)
	else
		self.rootWidget:setTouchEnabled(false)
		self.rootWidget:setVisible(false)
	end
	
	local Image_NPC = nil
	local nGuideContentX = 470
	if CSV_GuideSequence.NPCType == 0 then   --无需显示NPC
		self.Panel_NPCGuide:setVisible(false)
		if funcNpcEndCall then
			funcNpcEndCall()
		end
	elseif CSV_GuideSequence.NPCType == 1 then   --NPC在左边
		mainWnd.Image_MainHomeUIPNL:setVisible(false)
		self.Panel_NPCGuide:setVisible(true)
		self.Image_NPCLeft:setVisible(true)
		self.CCNode_Skeleton_L:setVisible(true)
		self.Image_NPCRight:setVisible(false)
		self.CCNode_Skeleton_R:setVisible(false)
		self.Image_Bottom:setVisible(true)
		self.Image_BottomBack:setVisible(true)
		self.Panel_NPCGuide:setBackGroundColorOpacity(0)
		Image_NPC = self.Image_NPCLeft
		Image_NPC:setPositionY(-75)
		nGuideContentX = 470
		if funcNpcEndCall then
			self.funcNpcEndCall = funcNpcEndCall
		end
	elseif CSV_GuideSequence.NPCType == 2 then   --NPC在右边
		mainWnd.Image_MainHomeUIPNL:setVisible(false)
		self.Panel_NPCGuide:setVisible(true)
		self.Image_NPCLeft:setVisible(false)
		self.CCNode_Skeleton_L:setVisible(false)
		self.Image_NPCRight:setVisible(true)
		self.CCNode_Skeleton_R:setVisible(true)
		self.Image_Bottom:setVisible(true)
		self.Image_BottomBack:setVisible(true)
		self.Panel_NPCGuide:setBackGroundColorOpacity(0)
		Image_NPC = self.Image_NPCRight
		Image_NPC:setPositionY(-75)
		nGuideContentX = -470
		if funcNpcEndCall then
			self.funcNpcEndCall = funcNpcEndCall
		end
	elseif CSV_GuideSequence.NPCType == 3 then   --NPC在左边
		mainWnd.Image_MainHomeUIPNL:setVisible(false)
		self.Panel_NPCGuide:setVisible(true)
		self.Image_NPCLeft:setVisible(true)
		self.CCNode_Skeleton_L:setVisible(true)
		self.Image_NPCRight:setVisible(false)
		self.CCNode_Skeleton_R:setVisible(false)
		self.Image_Bottom:setVisible(false)
		self.Image_BottomBack:setVisible(false)
		self.Panel_NPCGuide:setBackGroundColorOpacity(0)
		Image_NPC = self.Image_NPCLeft
		Image_NPC:setPositionY(-110)
		nGuideContentX = 470
		if funcNpcEndCall then
			self.funcNpcEndCall = funcNpcEndCall
		end
	elseif CSV_GuideSequence.NPCType == 4 then   --NPC在右边
		mainWnd.Image_MainHomeUIPNL:setVisible(false)
		self.Panel_NPCGuide:setVisible(true)
		self.Image_NPCLeft:setVisible(false)
		self.CCNode_Skeleton_L:setVisible(false)
		self.Image_NPCRight:setVisible(true)
		self.CCNode_Skeleton_R:setVisible(true)
		self.Image_Bottom:setVisible(false)
		self.Image_BottomBack:setVisible(false)
		self.Panel_NPCGuide:setBackGroundColorOpacity(0)
		Image_NPC = self.Image_NPCRight
		Image_NPC:setPositionY(-110)
		nGuideContentX = -470
		if funcNpcEndCall then
			self.funcNpcEndCall = funcNpcEndCall
		end
	elseif CSV_GuideSequence.NPCType == 5 then   --小NPC在左边
		self.Panel_NPCGuide:setVisible(false)
		if funcNpcEndCall then
			funcNpcEndCall()
		end
	elseif CSV_GuideSequence.NPCType == 6 then   --小NPC在右边
		self.Panel_NPCGuide:setVisible(false)
		if funcNpcEndCall then
			funcNpcEndCall()
		end
	elseif CSV_GuideSequence.NPCType == 7 then   --NPC在左边
		mainWnd.Image_MainHomeUIPNL:setVisible(false)
		self.Panel_NPCGuide:setVisible(true)
		self.Image_NPCLeft:setVisible(false)
		self.CCNode_Skeleton_R:setVisible(false)
		self.Image_NPCRight:setVisible(true)
		self.CCNode_Skeleton_R:setVisible(false)
		self.Image_Bottom:setVisible(false)
		self.Image_BottomBack:setVisible(false)
		self.Panel_NPCGuide:setBackGroundColorOpacity(0)
		Image_NPC = self.Image_NPCRight
		Image_NPC:setPositionY(-110)
		nGuideContentX = -380
		if funcNpcEndCall then
			self.funcNpcEndCall = funcNpcEndCall
		end
	end

	if Image_NPC then
		local ImageView_GuideContent = tolua.cast(Image_NPC:getChildByName("ImageView_GuideContent"), "ImageView")
		ImageView_GuideContent:setPositionX(nGuideContentX)
		local Label_GuideTips = tolua.cast(ImageView_GuideContent:getChildByName("Label_GuideTips"), "Label")
		Label_GuideTips:setText(CSV_GuideSequence.Context)
		local CCNode_GuideTips = tolua.cast(Label_GuideTips:getVirtualRenderer(), "CCLabelTTF")
		CCNode_GuideTips:disableShadow(true)
		
		if nNPCType == 1 then
			Label_GuideTips:setPositionX(5)
		elseif nNPCType == 2 then
			Label_GuideTips:setPositionX(-5)
		end
	end
	
	self:showGuideClick(CSV_GuideSequence)

	self:sendMsg(self.nCurrentGuideID, self.nCurrentGuideIndex)
	
	if self.nCurrentGuideID == self.nNewGuideID and self.nCurrentGuideIndex == self.nNewGuideIndex then
		self.nLastGuideID = self.nNewGuideID
		self.nLastGuideIndex = self.nNewGuideIndex
	end

	self:setNextGuideIndex()
end

function CNewPlayerGuid:setNextGuideIndex()
	if self.nCurrentGuideID == self.nNewGuideID and self.nCurrentGuideIndex == self.nNewGuideIndex then
		if self.tbResumeSequenceIndex and #self.tbResumeSequenceIndex > 0 then
			if self.nCurrentResumeIndex < #self.tbResumeSequenceIndex then
				self.nCurrentResumeIndex = self.nCurrentResumeIndex + 1
				self.nNewGuideIndex = self.tbResumeSequenceIndex[self.nCurrentResumeIndex]
			elseif self.nCurrentResumeIndex >= #self.tbResumeSequenceIndex then
				self.nNewGuideIndex = self.nNewGuideIndex + 1
				self.tbResumeSequenceIndex = nil
				self.nCurrentResumeIndex = nil
			end
		else
			self.nNewGuideIndex = self.nNewGuideIndex + 1
		end
	end
end

function CNewPlayerGuid:getNewGuideSequenceCsv()
	if self.nNewGuideID < g_nForceGuideMaxID then
		local CSV_Guide = g_DataMgr:getGuideCsv(self.nNewGuideID)
		if self.nNewGuideIndex <= #CSV_Guide then
			return g_DataMgr:getGuideSequenceCsv(self.nNewGuideID, self.nNewGuideIndex)
		else
			return g_DataMgr:getGuideSequenceCsv(self.nNewGuideID + 1, self.nNewGuideIndex - #CSV_Guide)
		end
	else
		local CSV_Guide = g_DataMgr:getGuideCsv(self.nNewGuideID)
		if self.nNewGuideIndex <= #CSV_Guide then
			return g_DataMgr:getGuideSequenceCsv(self.nNewGuideID, self.nNewGuideIndex)
		else
			return g_DataMgr:getGuideSequenceCsv(0, 0)
		end
	end
end

function CNewPlayerGuid:geLastGuideSequenceCsv()
	if self.nLastGuideID and self.nLastGuideIndex then
		return g_DataMgr:getGuideSequenceCsv(self.nLastGuideID, self.nLastGuideIndex)
	end
end

function CNewPlayerGuid:checkCurrentGuideSequenceNode(strShowGuideEvenType, szOwnerWidgetName)
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end
	local CSV_GuideSequence = self:getNewGuideSequenceCsv()
	if CSV_GuideSequence.GuideID <= 0 then return end
	if szOwnerWidgetName and szOwnerWidgetName ~= "" then
		if CSV_GuideSequence.EventOwnerWidget and CSV_GuideSequence.EventOwnerWidget ~= "" then
			local tbEventOwnerWidget = string.split(CSV_GuideSequence.EventOwnerWidget, "|")
			local nMax = #tbEventOwnerWidget
			local bIsOwnerWidgetQualified = false
			for i = 1, nMax do
				if tbEventOwnerWidget[i] == szOwnerWidgetName then
					cclog("========tbEventOwnerWidget[i]========"..tbEventOwnerWidget[i])
					bIsOwnerWidgetQualified = true
					break
				end
			end
			
			if bIsOwnerWidgetQualified == true then
				if strShowGuideEvenType == CSV_GuideSequence.ShowGuideEvenType1 then
					self.nCurrentGuideID = self.nNewGuideID
					self.nCurrentGuideIndex = self.nNewGuideIndex
					return true
				end
				
				if strShowGuideEvenType == CSV_GuideSequence.ShowGuideEvenType2 then
					self.nCurrentGuideID = self.nNewGuideID
					self.nCurrentGuideIndex = self.nNewGuideIndex
					return true
				end
			end
		end
	end
	
	local CSV_GuideSequenceLast = self:geLastGuideSequenceCsv()
	if CSV_GuideSequenceLast.GuideID <= 0 then return end
	if szOwnerWidgetName and szOwnerWidgetName ~= "" then
		if CSV_GuideSequenceLast.EventOwnerWidget and CSV_GuideSequenceLast.EventOwnerWidget ~= "" then
			local tbEventOwnerWidget = string.split(CSV_GuideSequenceLast.EventOwnerWidget, "|")
			local nMax = #tbEventOwnerWidget
			local bIsOwnerWidgetQualified = false
			for i = 1, nMax do
				if tbEventOwnerWidget[i] == szOwnerWidgetName then
					cclog("========tbEventOwnerWidget[i]========"..tbEventOwnerWidget[i])
					bIsOwnerWidgetQualified = true
					break
				end
			end
			
			if bIsOwnerWidgetQualified == true then
				if strShowGuideEvenType == CSV_GuideSequenceLast.ShowGuideEvenType1 then
					self.nCurrentGuideID = self.nLastGuideID
					self.nCurrentGuideIndex = self.nLastGuideIndex
					return true
				end
				
				if strShowGuideEvenType == CSV_GuideSequenceLast.ShowGuideEvenType2 then
					self.nCurrentGuideID = self.nLastGuideID
					self.nCurrentGuideIndex = self.nLastGuideIndex
					return true
				end
			end
		end
	end
	
	return false
end

function CNewPlayerGuid:checkLastClickWidgetQualify(szClickWidget)
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return false end
	if not self.curGuideWidget then return false end
	local CSV_GuideSequence = self:geLastGuideSequenceCsv()
	if CSV_GuideSequence.NoNeedToCheck == 1 then
		return true
	end

	if not szClickWidget or szClickWidget == "" then
		return false
	end

	if self.strCurWidgetName and self.strCurWidgetName == "" then
		return false
	end
	
	return szClickWidget == self.strCurWidgetName
end

function CNewPlayerGuid:checkIsInGuide()
	return self.nCurrentGuideID
end

--C++里面调用的函数
function g_CheckIsInGuide()
	if not g_PlayerGuide then return 0 end
	if not g_PlayerGuide.nCurrentGuideID then return 0 end
	if g_PlayerGuide.nCurrentGuideID  > g_nForceGuideMaxID then return 0 end
	if g_PlayerGuide.nCurrentGuideID == 3 and g_PlayerGuide.nCurrentGuideIndex == 3 then
		return 1
	elseif g_PlayerGuide.nCurrentGuideID == 7 and g_PlayerGuide.nCurrentGuideIndex == 3 then
		return 1
	end
	
	return 0
end

function CNewPlayerGuid:sendMsg(nGuideID, nGuideIndex)
	if self.nCurrentGuideID >= 1000 then return end
	
	if not g_Hero:checkSendGuideMsgQualify(nGuideID, nGuideIndex) then --发过一次不需要再次发送
		g_MsgMgr:requestNewPlayerGuide(nGuideID, nGuideIndex)
	end
end

function CNewPlayerGuid:showCurrentGuideSequenceNode(funcNpcEndCall, funcGuideEndCall)
	cclog("============当前进行的self.nCurrentGuideID=============="..self.nCurrentGuideID)
	cclog("============当前进行的self.nCurrentGuideIndex=============="..self.nCurrentGuideIndex)
	cclog("============当前进行的#self.CSV_Guide=============="..#self.CSV_Guide)
	
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end

	self:RemoveLastArmature()
	
	if self.lastWndInstance and self.Image_NPCGuideTipPNL and self.Image_NPCGuideTipPNL:isExsit() then
		self.Image_NPCGuideTipPNL:removeFromParentAndCleanup(true)
		self.Image_NPCGuideTipPNL = nil
	end
	
	local bIsSkin, nNewGuideID, nNewGuideIndex = self:checkNextLogic(self.nCurrentGuideID, self.nCurrentGuideIndex)
	if bIsSkin then
		self.nLastGuideID = nNewGuideID
		self.nLastGuideIndex = nNewGuideIndex
		self.nCurrentGuideID = nNewGuideID
		self.nCurrentGuideIndex = nNewGuideIndex
		self.nNewGuideID = nNewGuideID
		self.nNewGuideIndex = nNewGuideIndex
		self.tbResumeSequenceIndex = nil
		self.nRemainStartIndex = nil
		self:showCurrentGuideSequenceNode()
		return
	end
	
	if self.nCurrentGuideID < g_nForceGuideMaxID then
		if self.nCurrentGuideIndex < #self.CSV_Guide then
			self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
		elseif self.nCurrentGuideIndex == #self.CSV_Guide then
			self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
		else
			if self:setCurrentGuideSequence(self.nCurrentGuideID + 1) then
				self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
			else
				self:destroyGuide(funcGuideEndCall)
			end
		end
	elseif self.nCurrentGuideID == g_nForceGuideMaxID then
		if self.nCurrentGuideIndex < #self.CSV_Guide then
			self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
		elseif self.nCurrentGuideIndex >= #self.CSV_Guide then
			self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
			
			if funcGuideIDEndCall then
				funcGuideIDEndCall()
			end
			self:destroyGuide(funcGuideEndCall)
		end
	else	--功能开启的新手引导
		if self.nCurrentGuideIndex < #self.CSV_Guide then	
			self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
		elseif self.nCurrentGuideIndex >= #self.CSV_Guide then
			self:showGuide(self.CSV_Guide[self.nCurrentGuideIndex], funcNpcEndCall)
			
			if funcGuideIDEndCall then
				funcGuideIDEndCall()
			end
			self:destroyGuide(funcGuideEndCall)
		end
	end
	g_IsGuideWidgetInLock = nil
end

function CNewPlayerGuid:setGuideVisible(bShow)
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end
	if not self.nNewGuideID then return end
	self.rootWidget:setTouchEnabled(bShow)
end

function CNewPlayerGuid:destroyGuide(funcGuideEndCall)
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end
	
	self:RemoveLastArmature()
	
	if self.lastWndInstance and self.Image_NPCGuideTipPNL and self.Image_NPCGuideTipPNL:isExsit()then
		self.Image_NPCGuideTipPNL:removeFromParentAndCleanup(true)
		self.Image_NPCGuideTipPNL = nil
	end

	g_IsGuideWidgetInLock = nil
	self.CSV_Guide = nil
	
	self.nLastGuideID = nil
	self.nLastGuideIndex = nil
	self.nCurrentGuideID = nil
	self.nCurrentGuideIndex = nil
	self.nNewGuideID = nil
	self.nNewGuideIndex = nil
	
	if self.rootWidget and self.rootWidget:isExsit() then
		self.rootWidget:removeFromParentAndCleanup(true)
	end
	self.rootWidget = nil
	
	if self.rootLayer then
		g_pDirector:getRunningScene():removeChild(self.rootLayer, true)
	end
	self.rootLayer = nil
	
	g_MsgMgr:ignoreCheckWaitTime(false)
	g_bIsInGuiding = nil
	
	if funcGuideEndCall then
		funcGuideEndCall()
	end
end

--nType 1左边 2右边 其他不显示npc
function CNewPlayerGuid:setCurrentGuideSequence(nGuideID, nStartSquenceIndex)
	local nStartSquenceIndex = nStartSquenceIndex or 1

	local CSV_Guide = g_DataMgr:getGuideCsv(nGuideID)

	if CSV_Guide[0] then
		return nil
	end
	g_bIsInGuiding = true

	self.tbResumeSequenceIndex = {}
	if CSV_Guide[nStartSquenceIndex].ErrorGuideSequence == "Break" and nGuideID < g_nForceGuideMaxID then
		self.nNewGuideID = nGuideID + 1
		self.nNewGuideIndex = 1
		self.CSV_Guide = g_DataMgr:getGuideCsv(self.nNewGuideID)
	else
		local strErrorGuideSequence = CSV_Guide[nStartSquenceIndex].ErrorGuideSequence
		local tbErrorGuideSequence = string.split(strErrorGuideSequence, "_")
		if #tbErrorGuideSequence > 1 then
			local function addRemainGuideSequence(nRemainStartIndex)
				for nIndex = nRemainStartIndex, #CSV_Guide do
					table.insert(self.tbResumeSequenceIndex, nIndex)
				end
			end
			local nNumIndex = 0
			for nIndex = 1, #tbErrorGuideSequence do
				local strNum = tbErrorGuideSequence[nIndex]
				if strNum == "" then
					addRemainGuideSequence(nNumIndex + 1)
					break
				end
				nNumIndex = tonumber(strNum)
				table.insert(self.tbResumeSequenceIndex, nNumIndex)
			end
			self.nCurrentResumeIndex = 1
			self.nNewGuideIndex = self.tbResumeSequenceIndex[self.nCurrentResumeIndex]
		else
			self.nNewGuideIndex = nStartSquenceIndex
		end
		self.nNewGuideID = nGuideID
		self.CSV_Guide = CSV_Guide
	end
	
	self.nLastGuideID = 0
	self.nLastGuideIndex = 0
	self.nCurrentGuideID = self.nNewGuideID
	self.nCurrentGuideIndex = self.nNewGuideIndex

	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then
		self:initGuide()
	end
	
	g_MsgMgr:ignoreCheckWaitTime(true)
	
	return true
end

function CNewPlayerGuid:initGuide()
	self.rootWidget = GUIReader:shareReader():widgetFromJsonFile("Game_Guiding.json")
	self.rootWidget:setTouchEnabled(true)
	self.rootWidget:setVisible(true)

	self.rootLayer = TouchGroup:create()
	self.rootLayer:addWidget(self.rootWidget)

	CCDirector:sharedDirector():getRunningScene():addChild(self.rootLayer, INT_MAX)

	local function onClickArea(pSender, eventType)
		if eventType == ccs.TouchEventType.began then
			local tbClickPos = pSender:getTouchStartPos()
			local nCurrentGuideIndex = self.nCurrentGuideIndex
			local CSV_GuideSequence = self.CSV_Guide[nCurrentGuideIndex]
			if CSV_GuideSequence and CSV_GuideSequence.IsForced == 1 then
				local nClickAreaScale = CSV_GuideSequence.ClickAreaScale
				if nClickAreaScale > 0 then
					local nWidth = (self.curGuideWidget:getSize().width*nClickAreaScale/100)/2
					local nHeight = (self.curGuideWidget:getSize().height*nClickAreaScale/100)/2
					local nPosX = self.curGuideWidget:getWorldPosition().x
					local nPosY = self.curGuideWidget:getWorldPosition().y
					
					local nClickPosX = tbClickPos.x
					local nClickPosY = tbClickPos.y
					
					if math.abs(nClickPosX - nPosX) > nWidth then
						return
					end
					
					if math.abs(nClickPosY - nPosY) > nHeight then
						return
					end
				end
				if not self.curGuideWidget or not self.curGuideWidget:isExsit() or not self.curGuideWidget:hitTest(tbClickPos) then
					return
				end
			end
			
			local tbPos = CCDirector:sharedDirector():convertToGL(ccp(tbClickPos.x, tbClickPos.y))
			local CCTouch_Click = CCTouch:new()
			CCTouch_Click:setTouchInfo(0, tbPos.x, tbPos.y)
			g_WndMgr:getRootWidget():ccTouchBegan(CCTouch_Click, nil)
		elseif not self.nDragTouchLock and eventType ==ccs.TouchEventType.moved then
			local tbClickPos = pSender:getTouchMovePos()
			local nCurrentGuideIndex = self.nCurrentGuideIndex
			local CSV_GuideSequence = self.CSV_Guide[nCurrentGuideIndex]
			if CSV_GuideSequence and CSV_GuideSequence.IsForced == 1 then
				if not self.curGuideWidget or not self.curGuideWidget:isExsit() or not self.curGuideWidget:hitTest(tbClickPos) then
					return
				end
			end
			
			local tbPos = CCDirector:sharedDirector():convertToGL(ccp(tbClickPos.x, tbClickPos.y))
			local CCTouch_Click = CCTouch:new()
			CCTouch_Click:setTouchInfo(0, tbPos.x, tbPos.y)
			g_WndMgr:getRootWidget():ccTouchMoved(CCTouch_Click, nil)
			return 
		elseif eventType == ccs.TouchEventType.ended then
			local tbClickPos = pSender:getTouchEndPos()
			local nCurrentGuideIndex = self.nCurrentGuideIndex
			local CSV_GuideSequence = self.CSV_Guide[nCurrentGuideIndex]
			if CSV_GuideSequence and CSV_GuideSequence.IsForced == 1 then
				local nClickAreaScale = CSV_GuideSequence.ClickAreaScale
				if nClickAreaScale > 0 then
					local nWidth = (self.curGuideWidget:getSize().width*nClickAreaScale/100)/2
					local nHeight = (self.curGuideWidget:getSize().height*nClickAreaScale/100)/2
					local nPosX = self.curGuideWidget:getWorldPosition().x
					local nPosY = self.curGuideWidget:getWorldPosition().y
					
					local nClickPosX = tbClickPos.x
					local nClickPosY = tbClickPos.y
					
					if math.abs(nClickPosX - nPosX) > nWidth then
						return
					end
					
					if math.abs(nClickPosY - nPosY) > nHeight then
						return
					end
				end
				if not self.curGuideWidget or not self.curGuideWidget:isExsit() or not self.curGuideWidget:hitTest(tbClickPos) then
					return
				end
			end
			
			local tbPos = CCDirector:sharedDirector():convertToGL(ccp(tbClickPos.x, tbClickPos.y))
			local CCTouch_Click = CCTouch:new()
			CCTouch_Click:setTouchInfo(0, tbPos.x, tbPos.y)
			g_WndMgr:getRootWidget():ccTouchEnded(CCTouch_Click, nil)
		elseif eventType == ccs.TouchEventType.canceled then
			local tbClickPos = pSender:getTouchEndPos()
			local nCurrentGuideIndex = self.nCurrentGuideIndex
			local CSV_GuideSequence = nil
			 if nCurrentGuideIndex and self.CSV_Guide and self.CSV_Guide[nCurrentGuideIndex] then
			 	CSV_GuideSequence = self.CSV_Guide[nCurrentGuideIndex]
			 end

			if CSV_GuideSequence and CSV_GuideSequence.IsForced == 1 then
				local nClickAreaScale = CSV_GuideSequence.ClickAreaScale
				if nClickAreaScale > 0 then
					local nWidth = (self.curGuideWidget:getSize().width*nClickAreaScale/100)/2
					local nHeight = (self.curGuideWidget:getSize().height*nClickAreaScale/100)/2
					local nPosX = self.curGuideWidget:getWorldPosition().x
					local nPosY = self.curGuideWidget:getWorldPosition().y
					
					local nClickPosX = tbClickPos.x
					local nClickPosY = tbClickPos.y
					
					if math.abs(nClickPosX - nPosX) > nWidth then
						return
					end
					
					if math.abs(nClickPosY - nPosY) > nHeight then
						return
					end
				end
				if not self.curGuideWidget or not self.curGuideWidget:isExsit() or not self.curGuideWidget:hitTest(tbClickPos) then
					return
				end
			end
			
			local tbPos = CCDirector:sharedDirector():convertToGL(ccp(tbClickPos.x, tbClickPos.y))
			local CCTouch_Click = CCTouch:new()
			CCTouch_Click:setTouchInfo(0, tbPos.x, tbPos.y)
			g_WndMgr:getRootWidget():ccTouchCancelled(CCTouch_Click, nil)
		end
	end
	self.rootWidget:addTouchEventListener(onClickArea)

	self.Panel_NPCGuide = tolua.cast(self.rootWidget:getChildByName("Panel_NPCGuide"), "Layout")
	self.Image_NPCLeft = tolua.cast(self.Panel_NPCGuide:getChildByName("Image_NPCLeft"), "ImageView")
	self.CCNode_Skeleton_L = g_CocosSpineAnimation("XiaoXianTong", 1, true)
	self.Image_NPCLeft:removeAllNodes()
	self.Image_NPCLeft:loadTexture(getUIImg("Blank"))
	self.Image_NPCLeft:addNode(self.CCNode_Skeleton_L)
	g_runSpineAnimation(self.CCNode_Skeleton_L, "idle", true)
	
	self.Image_NPCRight = tolua.cast(self.Panel_NPCGuide:getChildByName("Image_NPCRight"), "ImageView")
	self.CCNode_Skeleton_R = g_CocosSpineAnimation("XiaoXianTong", 1, true)
	self.Image_NPCRight:removeAllNodes()
	self.Image_NPCRight:loadTexture(getUIImg("Blank"))
	self.Image_NPCRight:addNode(self.CCNode_Skeleton_R)
	self.CCNode_Skeleton_R:setScaleX(-1)
	g_runSpineAnimation(self.CCNode_Skeleton_R, "idle", true)
	
	self.Image_Bottom = tolua.cast(self.Panel_NPCGuide:getChildByName("Image_Bottom"), "ImageView")
	self.Image_BottomBack = tolua.cast(self.Panel_NPCGuide:getChildByName("Image_BottomBack"), "ImageView")

	local function onClickCloseNpc(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if g_IsGuideWidgetInLock then
			end
			if not g_IsGuideWidgetInLock then
				g_IsGuideWidgetInLock = true
				if self.funcNpcEndCall then
					self.Panel_NPCGuide:setVisible(false)
					mainWnd.Image_MainHomeUIPNL:setVisible(true)
					local function funcShowNextGuide()
						self.nCurrentGuideID = self.nNewGuideID
						self.nCurrentGuideIndex = self.nNewGuideIndex
						self:showCurrentGuideSequenceNode()
					end
					self.funcNpcEndCall(funcShowNextGuide)
					self.funcNpcEndCall = nil
				else
					self.Panel_NPCGuide:setVisible(false)
					mainWnd.Image_MainHomeUIPNL:setVisible(true)
					self.nCurrentGuideID = self.nNewGuideID
					self.nCurrentGuideIndex = self.nNewGuideIndex
					self:showCurrentGuideSequenceNode()
				end
			end
		end
	end
	self.Panel_NPCGuide:setTouchEnabled(true)
	self.Panel_NPCGuide:addTouchEventListener(onClickCloseNpc)
end

function CNewPlayerGuid:checkNextLogic(nGuideID, nGuideIndex)
	local CSV_GuideSequence = g_DataMgr:getGuideSequenceCsv(nGuideID, nGuideIndex)
	local strCheckNextLogic = CSV_GuideSequence.CheckNextLogic
	if strCheckNextLogic == "" then
		return false, CSV_GuideSequence.GuideID, CSV_GuideSequence.SequenceIndex
	end
	
	--递归判断没有办法继续跳转的最后一步引导
	local CSV_GuideSequenceNew = CSV_GuideSequence
	while true do
		if CSV_GuideSequenceNew.CheckNextLogic == "" then
			break
		else
			if self:checkNextLogicByStr(CSV_GuideSequenceNew.CheckNextLogic) then
				CSV_GuideSequenceNew = g_DataMgr:getGuideSequenceCsv(CSV_GuideSequenceNew.JumpNextGuideID, CSV_GuideSequenceNew.JumpNextGuideIndex)
			else
				break
			end
		end
	end

	if CSV_GuideSequenceNew.GuideID == CSV_GuideSequence.GuideID and CSV_GuideSequenceNew.SequenceIndex == CSV_GuideSequence.SequenceIndex then
		return false, CSV_GuideSequenceNew.GuideID, CSV_GuideSequenceNew.SequenceIndex
	else
		return true, CSV_GuideSequenceNew.GuideID, CSV_GuideSequenceNew.SequenceIndex
	end
end

function CNewPlayerGuid:checkNextLogicByStr(strCheckNextLogic)
	if strCheckNextLogic == "" then
		return false
	elseif strCheckNextLogic == "checkStarRewardBox1" then  --检查第一个星级宝箱是不是可以领
		if self:checkStarRewardBox1() then return true end
	elseif strCheckNextLogic == "checkStarRewardBox2" then  --检查第二个星级宝箱是不是可以领
		if self:checkStarRewardBox2() then return true end
	elseif strCheckNextLogic == "checkStarRewardBox3" then  --检查第三个星级宝箱是不是可以领
		if self:checkStarRewardBox3() then return true end
	end	
	return false
end

function CNewPlayerGuid:checkDataLogic(nGuideID, nGuideIndex)
	local CSV_GuideSequence = g_DataMgr:getGuideSequenceCsv(nGuideID, nGuideIndex)
	local strCheckDataLogic = CSV_GuideSequence.CheckDataLogic
	if strCheckDataLogic == "" then
		return CSV_GuideSequence.GuideID, CSV_GuideSequence.SequenceIndex
	end
	
	--递归判断没有办法继续跳转的最后一步引导
	while true do
		if CSV_GuideSequence.CheckDataLogic == "" then
			break
		else
			if self:checkDataLogicByStr(CSV_GuideSequence.CheckDataLogic) then
				CSV_GuideSequence = g_DataMgr:getGuideSequenceCsv(CSV_GuideSequence.JumpGuideID, CSV_GuideSequence.JumpGuideIndex)
			else
				break
			end
		end
	end
	
	return CSV_GuideSequence.GuideID, CSV_GuideSequence.SequenceIndex
end

function CNewPlayerGuid:checkDataLogicByStr(strCheckDataLogic)
	if strCheckDataLogic == "" then
		return false
	elseif strCheckDataLogic == "checkSummonLingEr" then  --检查是否已经召唤赵灵儿
		if self:checkSummonLingEr() then return true end
	elseif strCheckDataLogic == "checkSummonXiaoYao" then  --检查是不是已经召唤李逍遥了
		if self:checkSummonXiaoYao() then return true end
	elseif strCheckDataLogic == "checkShangZhenLingEr" then  --检查赵灵儿是不是已经上阵了
		if self:checkShangZhenLingEr() then return true end
	elseif strCheckDataLogic == "checkShangZhenXiaoYao" then  --检查是不是已经上阵李逍遥了
		if self:checkShangZhenXiaoYao() then return true end
	elseif strCheckDataLogic == "checkHasDuJie" then  --检查是不是已经渡劫了
		if self:checkHasDuJie() then return true end
	elseif strCheckDataLogic == "checkHasRealmUp" then  --检查是不是已经提升境界了
		if self:checkHasRealmUp() then return true end
	elseif strCheckDataLogic == "checkHasStrengthenEquip" then  --检查是不是已经强化装备了
		if self:checkHasStrengthenEquip() then return true end
	elseif strCheckDataLogic == "checkDanYao1" then  --检查主角第一个丹药是否已激活了
		if self:checkDanYao1() then return true end
	elseif strCheckDataLogic == "checkDanYao2" then  --检查主角第二个丹药是否已激活了
		if self:checkDanYao2() then return true end
	elseif strCheckDataLogic == "checkDanYao3" then  --检查主角第三个丹药是否已激活了
		if self:checkDanYao3() then return true end
	elseif strCheckDataLogic == "checkSkill1" then  --检查主角第一个技能是否已升级了
		if self:checkSkill1() then return true end
	elseif strCheckDataLogic == "checkSkill2" then  --检查主角第二个技能是否已升级了
		if self:checkSkill2() then return true end
	elseif strCheckDataLogic == "checkSkill3" then  --检查主角第三个技能是否已升级了
		if self:checkSkill3() then return true end
	elseif strCheckDataLogic == "checkEvolute" then  --检查主角是否已突破了
		if self:checkEvolute() then return true end
	elseif strCheckDataLogic == "checkStarUp" then  --检查主角是否已升星了
		if self:checkStarUp() then return true end
	elseif strCheckDataLogic == "checkSummonGuiXian" then  --检查幽冥鬼仙是否已召唤了
		if self:checkSummonGuiXian() then return true end
	elseif strCheckDataLogic == "checkShangZhenGuiXian" then  --检查幽冥鬼仙是否已上阵了
		if self:checkShangZhenGuiXian() then return true end
	elseif strCheckDataLogic == "checkLevelUpGuiXian" then  --检查幽冥鬼仙是否已升级了
		if self:checkLevelUpGuiXian() then return true end
	elseif strCheckDataLogic == "checkXianLingDao1" then  --检查是不是已经打过灵仙岛1
		if self:checkXianLingDao1() then return true end
	elseif strCheckDataLogic == "checkXianLingDao2" then  --检查是不是已经打过灵仙岛2
		if self:checkXianLingDao2() then return true end
	elseif strCheckDataLogic == "checkXianLingDao3" then  --检查是不是已经打过灵仙岛3
		if self:checkXianLingDao3() then return true end
	elseif strCheckDataLogic == "checkXianJianKeZhan1" then  --检查是不是已经打过仙剑客栈1
		if self:checkXianJianKeZhan1() then return true end
	elseif strCheckDataLogic == "checkXianJianKeZhan2" then  --检查是不是已经打过仙剑客栈2
		if self:checkXianJianKeZhan2() then return true end
	elseif strCheckDataLogic == "checkXianJianKeZhan3" then  --检查是不是已经打过仙剑客栈3
		if self:checkXianJianKeZhan3() then return true end
	elseif strCheckDataLogic == "checkShiLiPo1" then  --检查是不是已经打过十里坡1
		if self:checkShiLiPo1() then return true end
	elseif strCheckDataLogic == "checkShiLiPo2" then  --检查是不是已经打过十里坡2
		if self:checkShiLiPo2() then return true end
	elseif strCheckDataLogic == "checkShiLiPo3" then  --检查是不是已经打过十里坡3
		if self:checkShiLiPo3() then return true end
	elseif strCheckDataLogic == "checkStarRewardBox1" then  --检查第一个星级宝箱是不是可以领
		if self:checkStarRewardBox1() then return true end
	elseif strCheckDataLogic == "checkStarRewardBox2" then  --检查第二个星级宝箱是不是可以领
		if self:checkStarRewardBox2() then return true end
	elseif strCheckDataLogic == "checkStarRewardBox3" then  --检查第三个星级宝箱是不是可以领
		if self:checkStarRewardBox3() then return true end
	end
	
	return false
end

function CNewPlayerGuid:checkSummonLingEr()
	if g_Hero:getCardObjByCsvID(1019) then return true end
	return false
end

function CNewPlayerGuid:checkSummonXiaoYao()
	if g_Hero:getCardObjByCsvID(1011) then return true end
	return false
end

function CNewPlayerGuid:checkShangZhenLingEr()
	if g_Hero:getBattleCardByIndex(3) then return true end
	if g_Hero:checkCardIsInBattleByCsvID(1019) then return true end
	return false
end

function CNewPlayerGuid:checkShangZhenXiaoYao()
	if g_Hero:getBattleCardByIndex(2) then return true end
	if g_Hero:checkCardIsInBattleByCsvID(1011) then return true end
	return false
end

function CNewPlayerGuid:checkHasDuJie()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if not g_CheckCardCanDuJie(tbCardLeader) then return true end
	return false
end

function CNewPlayerGuid:checkHasRealmUp()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if not g_CheckCardCanRealmUp(tbCardLeader) then return true end
	return false
end

function CNewPlayerGuid:checkHasStrengthenEquip()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	local GameObj_Equip = tbCardLeader:getEquipTbByPos(1)
	if GameObj_Equip:getStrengthenLev() > 1 then return true end
	return false
end

function CNewPlayerGuid:checkDanYao1()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if tbCardLeader:getDanyaoLevel(1, 1) >= 1 then return true end
	return false
end

function CNewPlayerGuid:checkDanYao2()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if tbCardLeader:getDanyaoLevel(1, 3) >= 1 then return true end
	return false
end

function CNewPlayerGuid:checkDanYao3()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if tbCardLeader:getDanyaoLevel(1, 2) >= 1 then return true end
	return false
end

function CNewPlayerGuid:checkSkill1()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if tbCardLeader:getSkillLevel(1) > 1 then return true end
	if g_Hero:getItemNumByCsv(2011, 1) <= 0 then return true end
	if g_Hero:getItemNumByCsv(2012, 1) <= 0 then return true end
	if g_Hero:getItemNumByCsv(2013, 1) <= 0 then return true end
	
	return false
end

function CNewPlayerGuid:checkSkill2()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if tbCardLeader:getSkillLevel(2) > 1 then return true end
	if g_Hero:getItemNumByCsv(2014, 1) <= 0 then return true end
	if g_Hero:getItemNumByCsv(2015, 1) <= 0 then return true end
	if g_Hero:getItemNumByCsv(2016, 1) <= 0 then return true end
	return false
end

function CNewPlayerGuid:checkSkill3()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if tbCardLeader:getSkillLevel(3) > 1 then return true end
	if g_Hero:getItemNumByCsv(2017, 1) <= 0 then return true end
	if g_Hero:getItemNumByCsv(2018, 1) <= 0 then return true end
	if g_Hero:getItemNumByCsv(2019, 1) <= 0 then return true end
	return false
end

function CNewPlayerGuid:checkEvolute()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if not g_CheckCardEvolute(tbCardLeader) then return true end
	return false
end

function CNewPlayerGuid:checkStarUp()
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if not g_CheckCardStarUp(tbCardLeader) then return true end
	return false
end

function CNewPlayerGuid:checkShangZhenGuiXian()
	if g_Hero:getBattleCardByIndex(4) then return true end
	if g_Hero:checkCardIsInBattleByCsvID(3019) then return true end
	return false
end

function CNewPlayerGuid:checkLevelUpGuiXian()
	local GameObj_Card = g_Hero:getCardObjByCsvID(3019)
	if GameObj_Card and GameObj_Card:getLevel() > 1 then return true end
	
	--卡牌未升级检测材料数量
	if g_Hero:getItemNumByCsv(9, 1) >= 1 then return false end
	if g_Hero:getItemNumByCsv(9, 2) >= 1 then return false end
	if g_Hero:getItemNumByCsv(9, 3) >= 1 then return false end
	if g_Hero:getItemNumByCsv(9, 4) >= 1 then return false end
	if g_Hero:getItemNumByCsv(9, 5) >= 1 then return false end
	
	return true
end

function CNewPlayerGuid:checkXianLingDao1()
	if g_Hero:getFinalClearEctypeID() >= 1001 then return true end
	return false
end

function CNewPlayerGuid:checkXianLingDao2()
	if g_Hero:getFinalClearEctypeID() >= 1002 then return true end
	return false
end

function CNewPlayerGuid:checkXianLingDao3()
	if g_Hero:getFinalClearEctypeID() >= 1003 then return true end
	return false
end

function CNewPlayerGuid:checkXianJianKeZhan1()
	if g_Hero:getFinalClearEctypeID() >= 1004 then return true end
	return false
end

function CNewPlayerGuid:checkXianJianKeZhan2()
	if g_Hero:getFinalClearEctypeID() >= 1005 then return true end
	return false
end

function CNewPlayerGuid:checkXianJianKeZhan3()
	if g_Hero:getFinalClearEctypeID() >= 1006 then return true end
	return false
end

function CNewPlayerGuid:checkShiLiPo1()
	if g_Hero:getFinalClearEctypeID() >= 2001 then return true end
	return false
end

function CNewPlayerGuid:checkShiLiPo2()
	if g_Hero:getFinalClearEctypeID() >= 2002 then return true end
	return false
end

function CNewPlayerGuid:checkShiLiPo3()
	if g_Hero:getFinalClearEctypeID() >= 2003 then return true end
	return false
end

function CNewPlayerGuid:checkStarRewardBox1()
	local nBoxRewardState = g_EctypeListSystem:GetBoxRewardStatusByIndex(1, EctypeBoxReward._Left)
	if nBoxRewardState == RewardBoxStatus._CanNotObtain then
		return true
	elseif nBoxRewardState == RewardBoxStatus._CanObtainHasObtain then
		return true
	end
	return false
end

function CNewPlayerGuid:checkStarRewardBox2()
	local nBoxRewardState = g_EctypeListSystem:GetBoxRewardStatusByIndex(1, EctypeBoxReward._Middle)
	if nBoxRewardState == RewardBoxStatus._CanNotObtain then
		return true
	elseif nBoxRewardState == RewardBoxStatus._CanObtainHasObtain then
		return true
	end
	return false
end

function CNewPlayerGuid:checkStarRewardBox3()
	local nBoxRewardState = g_EctypeListSystem:GetBoxRewardStatusByIndex(1, EctypeBoxReward._Right)
	if nBoxRewardState == RewardBoxStatus._CanNotObtain then
		return true
	elseif nBoxRewardState == RewardBoxStatus._CanObtainHasObtain then
		return true
	end
	return false
end

function CNewPlayerGuid:checkHasOnboard4()
	local tbCardLeader = g_Hero:getBattleCardByIndex(4)
	if tbCardLeader then return true end
	return false
end

function CNewPlayerGuid:checkSummonGuiXian()
	if g_Hero:getCardObjByCsvID(3016) then return true end
	return false
end

function CNewPlayerGuid:checkHunPoGuiXian()
	local Obj_CardHunPo = g_Hero:getHunPoObj(3016)
	if Obj_CardHunPo then
		local CSV_CardHunPo = g_DataMgr:getCsvConfigByOneKey("CardHunPo", 3016)
		if Obj_CardHunPo.nNum and Obj_CardHunPo.nNum < CSV_CardHunPo.NeedNum then
			return true
		end
	else
		return true
	end
	return false
end

function CNewPlayerGuid:checkCanSummon()
	if g_Hero:getCardObjByCsvID(3016) then return false end
	local Obj_CardHunPo = g_Hero:getHunPoObj(3016)
	if Obj_CardHunPo then
		local CSV_CardHunPo = g_DataMgr:getCsvConfigByOneKey("CardHunPo", 3016)
		if Obj_CardHunPo.nNum and Obj_CardHunPo.nNum < CSV_CardHunPo.NeedNum then
			return false
		end
	end
	return true
end

function CNewPlayerGuid:checkCanShangZhen()
	if g_Hero:getBattleCardByIndex(4) then return false end
	if g_Hero:getHasSummonUnBattleCardListCount() <= 0 then return false end
	return true
end

local tbIsNotFirstGuide = {}
function CNewPlayerGuid:checkServerGuideState()
	local nGuideID = 0
	local nGuideIndex = 0
	if g_Hero:GetFirstOpState(macro_pb.FirstOpType_NORMAL_SUMMON) then --是否第一次普通召唤
		nGuideID = 1
		nGuideIndex = 2
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_HIGHT_SUMMON) then --是否第一次高级召唤
		nGuideID = 1
		nGuideIndex = 6
	elseif g_Hero:getFinalClearEctypeID() < 1001 then --是否第一次打灵仙岛1
		if not tbIsNotFirstGuide.Ectype1001 then
			tbIsNotFirstGuide.Ectype1001 = true
			nGuideID = 2
			nGuideIndex = 1
		else
			nGuideID = 2
			nGuideIndex = 2
		end
	elseif g_Hero:getFinalClearEctypeID() < 1002 then --是否第一次打灵仙岛2
		if not tbIsNotFirstGuide.Ectype1002 then
			tbIsNotFirstGuide.Ectype1002 = true
			nGuideID = 2
			nGuideIndex = 11
		else
			nGuideID = 2
			nGuideIndex = 12
		end
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_UpgrateSkill1) then --是否第一次突破
		if not tbIsNotFirstGuide.FirstOpType_UpgrateSkill1 then
			tbIsNotFirstGuide.FirstOpType_UpgrateSkill1 = true
			nGuideID = 3
			nGuideIndex = 4
		else
			nGuideID = 3
			nGuideIndex = 5
		end
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_UpgrateSkill2) then --是否第一次突破
		nGuideID = 3
		nGuideIndex = 7
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_UpgrateSkill3) then --是否第一次突破
		nGuideID = 3
		nGuideIndex = 9
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_BreachCard) then --是否第一次突破
		if not tbIsNotFirstGuide.FirstOpType_BreachCard then
			tbIsNotFirstGuide.FirstOpType_BreachCard = true
			nGuideID = 3
			nGuideIndex = 11
		else
			nGuideID = 3
			nGuideIndex = 12
		end
	elseif g_Hero:getFinalClearEctypeID() < 1003 then --是否第一次打仙剑客栈1
		if not tbIsNotFirstGuide.Ectype1003 then
			tbIsNotFirstGuide.Ectype1003 = true
			nGuideID = 4
			nGuideIndex = 1
		else
			nGuideID = 4
			nGuideIndex = 2
		end
	elseif g_Hero:getFinalClearEctypeID() < 1004 then --是否第一次打仙剑客栈2
		if not tbIsNotFirstGuide.Ectype1004 then
			tbIsNotFirstGuide.Ectype1004 = true
			nGuideID = 4
			nGuideIndex = 11
		else
			nGuideID = 4
			nGuideIndex = 12
		end
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_Strength)
		and g_Hero:GetFirstOpState(macro_pb.FirstOpType_OneKeyStrengthEquip)
		and g_Hero:GetFirstOpState(macro_pb.FirstOpType_OneKeyStrengthCardEquip)
	then --是否第一次装备强化
		if not tbIsNotFirstGuide.FirstOpType_Strength then
			tbIsNotFirstGuide.FirstOpType_Strength = true
			nGuideID = 5
			nGuideIndex = 7
		else
			nGuideID = 5
			nGuideIndex = 8
		end
	elseif g_Hero:getFinalClearEctypeID() < 1005 then --是否第一次打十里坡1
		if not tbIsNotFirstGuide.Ectype1005 then
			tbIsNotFirstGuide.Ectype1005 = true
			nGuideID = 6
			nGuideIndex = 1
		else
			nGuideID = 6
			nGuideIndex = 2
		end
	elseif g_Hero:getFinalClearEctypeID() < 1006 then --是否第一次打十里坡2
		if not tbIsNotFirstGuide.Ectype1006 then
			tbIsNotFirstGuide.Ectype1006 = true
			nGuideID = 6
			nGuideIndex = 11
		else
			nGuideID = 6
			nGuideIndex = 12
		end
	elseif g_EctypeListSystem:GetBoxRewardStatusByIndex(1, EctypeBoxReward._Left) == RewardBoxStatus._CanObtainNotObtain then
		if not tbIsNotFirstGuide.ChestLeft then
			tbIsNotFirstGuide.ChestLeft = true
			nGuideID = 6
			nGuideIndex = 19
		else
			nGuideID = 6
			nGuideIndex = 20
		end
	elseif g_EctypeListSystem:GetBoxRewardStatusByIndex(1, EctypeBoxReward._Middle) == RewardBoxStatus._CanObtainNotObtain then
		nGuideID = 6
		nGuideIndex = 23
	elseif g_EctypeListSystem:GetBoxRewardStatusByIndex(1, EctypeBoxReward._Right) == RewardBoxStatus._CanObtainNotObtain then
		nGuideID = 6
		nGuideIndex = 26
	elseif g_Hero:GetFirstOpState(macro_pb.firstoptype_hunpo_to_card) and self:checkCanSummon() then --是否第一次用魂魄召唤
		nGuideID = 7
		nGuideIndex = 1
	elseif g_Hero:GetFirstOpState(macro_pb.FirstOpType_ADD_ARRAY_NUM4) and self:checkCanShangZhen() then --是否第一次上阵四号位
		nGuideID = 8
		nGuideIndex = 1
	elseif g_Hero:getFinalClearEctypeID() < 2001 then --是否第一次打苏州城郊2
		if not tbIsNotFirstGuide.Ectype2001 then
			tbIsNotFirstGuide.Ectype2001 = true
			nGuideID = 9
			nGuideIndex = 3
		else
			nGuideID = 9
			nGuideIndex = 4
		end
	elseif g_Hero:getFinalClearEctypeID() < 2002 then --是否第一次打苏州城郊2
		if not tbIsNotFirstGuide.Ectype2002 then
			tbIsNotFirstGuide.Ectype2002 = true
			nGuideID = 9
			nGuideIndex = 12
		else
			nGuideID = 9
			nGuideIndex = 12
		end
	elseif g_Hero:getFinalClearEctypeID() < 3001 then --苏州城副本引导
		nGuideID = 10
		nGuideIndex = 1
	end
	
	return nGuideID, nGuideIndex
end

function CNewPlayerGuid:showNextEctypeGuide1()
	local nGuideID = 0
	local nGuideIndex = 0

	if g_Hero:getFinalClearEctypeID() > 1006 and g_Hero:getFinalClearEctypeID() < 2006 then --苏州城副本引导
		nGuideID = 10
		nGuideIndex = 1
	end
	
	if g_Hero:getFinalClearEctypeID() >= 2006 and g_Hero:getFinalClearEctypeID() < 3008 then --林家堡副本引导
		nGuideID = 12
		nGuideIndex = 1
	end
	
	if g_Hero:getFinalClearEctypeID() >= 3008 and g_Hero:getFinalClearEctypeID() < 4008 then --白河镇副本引导
		nGuideID = 14
		nGuideIndex = 1
	end
	
	if g_Hero:getFinalClearEctypeID() >= 4008 and g_Hero:getFinalClearEctypeID() < 5001 then --黑水镇副本引导
		nGuideID = 16
		nGuideIndex = 1
	end
	
	return nGuideID, nGuideIndex
end

function CNewPlayerGuid:showNextEctypeGuide2(nCurrentMapBaseCsvID)
	local nGuideID = 0
	local nGuideIndex = 0
	local nCurrentMapBaseCsvID = nCurrentMapBaseCsvID or 0
	
	local nFinalClearEctypeID = g_Hero:getFinalClearEctypeID()
	local nFinalMapBaseCsvID = math.floor(nFinalClearEctypeID/1000)
	
	if nCurrentMapBaseCsvID < nFinalMapBaseCsvID then
		return nGuideID, nGuideIndex
	end
	
	if nFinalClearEctypeID > 1006 and nFinalClearEctypeID < 2006 then --苏州城副本引导
		nGuideID = 11
		nGuideIndex = 1
	end
	
	if nFinalClearEctypeID > 2006 and nFinalClearEctypeID < 3008 then --林家堡副本引导
		nGuideID = 13
		nGuideIndex = 1
	end
	
	if nFinalClearEctypeID > 3008 and nFinalClearEctypeID < 4008 then --白河镇副本引导
		nGuideID = 15
		nGuideIndex = 1
	end
	
	return nGuideID, nGuideIndex
end


------------------创建对象
g_PlayerGuide = CNewPlayerGuid.new()