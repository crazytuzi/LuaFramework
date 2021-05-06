local CEquipFubenDetailView = class("CEquipFubenDetailView", CViewBase)

function CEquipFubenDetailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/equipfuben/EquipFubenDetailView.prefab", cb)
	self.m_ExtendClose = "Black"
	--self.m_GroupName = "main"
	self.m_DepthType = "Login"  --层次
	self.m_OpenEffect = "Scale"
end

function CEquipFubenDetailView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_BackBtn = self:NewUI(4, CButton)
	self.m_DetailBox = self:NewUI(5, CBox)
	self.m_FbListBox = self:NewUI(6, CBox)
	self.m_TitleLabel = self:NewUI(7, CLabel)
	self.m_InfoPart = self:NewUI(8, CChapterWealthInfoPart)
	UITools.ResizeToRootSize(self.m_Container)

	self.m_DetailBox.m_ItemSprite = self.m_DetailBox:NewUI(1, CSprite)
	self.m_DetailBox.m_EquipTipsLabel = self.m_DetailBox:NewUI(2, CLabel)
	self.m_DetailBox.m_NameLabel = self.m_DetailBox:NewUI(3, CLabel)
	self.m_DetailBox.m_WipeBtn = self.m_DetailBox:NewUI(4, CButton)
	self.m_DetailBox.m_PassItemBox = self.m_DetailBox:NewUI(5, CItemTipsBox)
	self.m_DetailBox.m_EnterBtn = self.m_DetailBox:NewUI(6, CButton)
	self.m_DetailBox.m_AwardGrid = self.m_DetailBox:NewUI(7, CGrid)
	self.m_DetailBox.m_AwardCloneBox = self.m_DetailBox:NewUI(8, CItemTipsBox)
	self.m_DetailBox.m_ProgressSprite = self.m_DetailBox:NewUI(9, CSlider)

	self.m_DetailBox.m_FirstPassTitleLabel = self.m_DetailBox:NewUI(10, CLabel)
	self.m_DetailBox.m_FirstPassBox = self.m_DetailBox:NewUI(12, CBox)
	self.m_DetailBox.m_FirstPassItemGrid = self.m_DetailBox:NewUI(13, CGrid)
	self.m_DetailBox.m_FirstPassItemCloneBox = self.m_DetailBox:NewUI(14, CItemTipsBox)
	self.m_DetailBox.m_ProgressLabel = self.m_DetailBox:NewUI(15, CLabel)
	self.m_DetailBox.m_LevelLavel = self.m_DetailBox:NewUI(16, CLabel)
	self.m_DetailBox.m_MainPersonTexture = self.m_DetailBox:NewUI(17, CTexture)
	self.m_DetailBox.m_AddTimeBtn = self.m_DetailBox:NewUI(18, CButton)
	self.m_DetailBox.m_SubPersonTexture = self.m_DetailBox:NewUI(19, CTexture)
	self.m_DetailBox.m_ProgressBtn = self.m_DetailBox:NewUI(20, CButton)
	self.m_DetailBox.m_TipsLevelLabebl = self.m_DetailBox:NewUI(21, CLabel)
	self.m_DetailBox.m_ProgressBtn.m_IgnoreCheckEffect = true

	self.m_FbListBox.m_FbScrollView = self.m_FbListBox:NewUI(1, CScrollView)
	self.m_FbListBox.m_FbGrid = self.m_FbListBox:NewUI(2, CGrid)
	self.m_FbListBox.m_FbCloneBox = self.m_FbListBox:NewUI(3, CBox)

	g_GuideCtrl:AddGuideUI("equipfuben_detail_enter_btn", self.m_DetailBox.m_EnterBtn)

	self.m_FubenId = nil
	self.m_CurPassFloor = nil
	self.m_SelectIndex = nil
	self.m_MaxFloor = 0
	self.m_Energy = 0
	self.m_LeftWipeTime = 0

	self:InitContent()
end

function CEquipFubenDetailView.InitContent(self)
	self.m_FbListBox.m_FbCloneBox:SetActive(false)
	self.m_DetailBox.m_AwardCloneBox:SetActive(false)
	self.m_DetailBox.m_FirstPassItemCloneBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCustomClose"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClose"))		
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFubenEvent"))	
end

function CEquipFubenDetailView.OnCustomClose(self)
	self:OnClose()	
end

function CEquipFubenDetailView.OnEnterFuben(self )
	if self.m_SelectIndex and self.m_FubenId then
		if not g_ActivityCtrl:ActivityBlockContrl("equipfuben") then
			return
		end

		if g_AttrCtrl.energy < self.m_Energy then
			self.OnShowEnergyTip()
			return
		end

		local fubenBaseInfo = data.equipfubendata.FUBEN[self.m_FubenId]						--副本基本信息
		local enterId = self.m_FubenId * 1000 + self.m_SelectIndex
		local data = g_EquipFubenCtrl.m_FubenInfoList[self.m_FubenId]						--副本玩家数据信息
		g_EquipFubenCtrl:CtrlC2GSEnterEquiFB(enterId)

		local path = string.format("equipfuben_cachefloor_%d", self.m_FubenId)
		IOTools.SetRoleData(path, self.m_SelectIndex)
		path = string.format("equipfuben_cachefloor", self.m_FubenId)
		IOTools.SetRoleData(path, self.m_FubenId)
		g_EquipFubenCtrl.m_ReOpenEquip = true
		--g_EquipFubenCtrl.m_AutoEnterFb = true
		-- if data.left == data.max and data.max and data.max > 0 then
		-- 	local args = 
		-- 	{
		-- 		msg = string.format("是否进行%s·%s战斗", fubenBaseInfo.type, g_EquipFubenCtrl:CountConvert(self.m_SelectIndex)),
		-- 		okCallback = function ( )
		-- 			g_EquipFubenCtrl:CtrlC2GSEnterEquiFB(enterId)
		-- 		end,
		-- 		cancelCallback = function ()
		-- 		end,
		-- 		okStr = "是",
		-- 		cancelStr = "否",
		-- 		forceConfirm = true,
		-- 	}
		-- 	g_WindowTipCtrl:SetWindowConfirm(args)
		-- else
		-- 	g_EquipFubenCtrl:CtrlC2GSEnterEquiFB(enterId)				
		-- end
	end	
end

function CEquipFubenDetailView.OnWipeFuben(self, isMaxStarPass)
	if isMaxStarPass then
		local PassInfo = self.m_CurPassFloor[self.m_SelectIndex]			
		CEquipFuBenSweepView:ShowView(function (oView)
			oView:SetData(self.m_FubenId * 1000 + self.m_SelectIndex, PassInfo.sweep_cost, self.m_Energy, self.m_LeftWipeTime)
		end)
	else
		g_NotifyCtrl:FloatMsg("三星开启扫荡功能")
	end
end

function CEquipFubenDetailView.OnAddTime(self, fubenId)
	local time = g_EquipFubenCtrl:GetFubenCanBuyTime(fubenId)
	CEquipFubenAddTimeView:ShowView(function (oView)
		oView:SetData(fubenId, 1, 1, time)
	end)
end

function CEquipFubenDetailView.SetContent(self, fubenId, floor, maxFloor)
	self.m_FubenId = fubenId
	self.m_CurPassFloor = floor
	self.m_MaxFloor = maxFloor
	self:RefresAll()
	
	local curIndex = (self.m_MaxFloor + 1)
	local path = string.format("equipfuben_cachefloor_%d", fubenId)
	local tData = IOTools.GetRoleData(path)
	if tData and type(tData) == "number" then
		curIndex = tData
	end

	local floorList = g_EquipFubenCtrl:GetFbListBaseInfoByFubenId(fubenId)
	if curIndex > #floorList then
		curIndex = #floorList
	end
	self:SelectFuben(curIndex)

	local t = 
	{
		[1] = {main = "Texture/EquipFuben/bg_sjdha_boss.png", sub = "Texture/EquipFuben/bg_sjdha_bg_1.png"},
		[2] = {main = "Texture/EquipFuben/bg_bhdqj_boss.png", sub = "Texture/EquipFuben/bg_bhdqj_bg_1.png"},
		[3] = {main = "Texture/EquipFuben/bg_xrdjg_boss.png", sub = "Texture/EquipFuben/bg_xrdjg_bg_1.png"},
	}

	self.m_DetailBox.m_MainPersonTexture:LoadPath(t[self.m_FubenId].main)
	self.m_DetailBox.m_SubPersonTexture:LoadPath(t[self.m_FubenId].sub)

	self.m_TipsBtn:AddHelpTipClick(string.format("equipfuben_%d", self.m_FubenId))


	if g_ActivityCtrl.m_AutoEnter then
		if g_AttrCtrl.energy > self.m_Energy then
			self:DelayCall(3, "OnEnterFuben")
		else
			g_ActivityCtrl.m_AutoEnter = false
		end
	end	
end

function CEquipFubenDetailView.RefresAll(self)	
	if self.m_FubenId then		
		self:RefreshFubenList()
		self:RefreshDetailBox()
	end
end

function CEquipFubenDetailView.RefreshFubenList(self)
	if not self.m_FubenId then
		return 
	end

	local fubenList = g_EquipFubenCtrl:GetFbListBaseInfoByFubenId(self.m_FubenId)
	local baseInfo = data.equipfubendata.FUBEN[self.m_FubenId]
	local playerData = g_EquipFubenCtrl.m_FubenInfoList[self.m_FubenId]		

	if baseInfo and fubenList and next(fubenList) then
		self.m_TitleLabel:SetText(baseInfo.type)
		for i = 1, #fubenList do
			local oBox = self.m_FbListBox.m_FbCloneBox:Clone()
			local d = fubenList[i]
			oBox:SetActive(true)
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_SelectSprite = oBox:NewUI(2, CSprite)
			oBox.m_StarGrid = oBox:NewUI(3, CGrid)
			oBox.m_StarClone = oBox:NewUI(4, CBox)
			oBox.m_ItemGrid = oBox:NewUI(5, CGrid)
			oBox.m_ItemCloneBox = oBox:NewUI(6, CItemTipsBox)
			oBox.m_MaskSprite = oBox:NewUI(7, CSprite)
			oBox.m_LevelLabel = oBox:NewUI(8, CLabel)
			oBox.m_CountLabel = oBox:NewUI(9, CLabel)
			oBox.m_SelectSprite:SetActive(false)
			oBox.m_ItemCloneBox:SetActive(false)
			oBox.m_IgnoreCheckEffect = true

			oBox:AddUIEvent("click", callback(self, "SelectFuben", i))
			oBox.m_NameLabel:SetText(string.format("%s", baseInfo.type))
			oBox.m_LevelLabel:SetText(string.format("%s层", g_EquipFubenCtrl:CountConvert(i)))
			oBox.m_CountLabel:SetText(playerData.tili_cost)
			local w = oBox.m_NameLabel:GetWidth()
			local p = oBox.m_NameLabel:GetLocalPos()
			oBox.m_LevelLabel:SetLocalPos(Vector3.New(p.x + w + 55, p.y + 2, p.z))

			oBox.m_StarGrid:InitChild(function (obj, index)
				local oStar = CBox.New(obj)
				oStar.m_StarSprite = oStar:NewUI(1, CSprite)
				oStar.m_StarSprite:SetActive(false)
				oBox.m_StarGrid.m_StarTable  = oBox.m_StarGrid.m_StarTable or {}
				oBox.m_StarGrid.m_StarTable[index] = oStar.m_StarSprite
				return oStar
			end)
			local maybeReward = g_EquipFubenCtrl:DecodeReward(d.maybe_reward)
			for k = 1, #maybeReward do				
				local oItemBox = oBox.m_ItemCloneBox:Clone()
				local config = {isLocal = true,}

				oItemBox:SetItemData(maybeReward[k].sid, maybeReward[k].amount, nil, config)
				oItemBox:SetActive(true)
				oBox.m_ItemGrid:AddChild(oItemBox)				
			end
			oBox.m_ItemGrid:Reposition()
			oBox:DelEffect("RedDot")
			if self.m_MaxFloor + 1 >= i then
				oBox.m_CountLabel:SetActive(true)
				oBox.m_MaskSprite:SetActive(false)	
				if #self.m_CurPassFloor >= i then
					local PassInfo = self.m_CurPassFloor[i]
					
					local config = g_EquipFubenCtrl:GetConfigByFloor(PassInfo.floor)
					local star = PassInfo.star or 0
					local sum_star = PassInfo.sum_star or 0
					if star > 0 then
						for i = 1, star do
							if oBox.m_StarGrid.m_StarTable[i] then
								oBox.m_StarGrid.m_StarTable[i]:SetActive(true)
							end
						end
					end	
					if sum_star >= config.star then
						oBox:AddEffect("RedDot")
					end						
				end
			else
				oBox.m_CountLabel:SetActive(false)
				oBox.m_MaskSprite:SetActive(true)	
			end			
			self.m_FbListBox.m_FbGrid:AddChild(oBox)
		end
	end
end

function CEquipFubenDetailView.RefreshDetailBox(self)
	if not self.m_FubenId or not self.m_SelectIndex then
		return 
	end

	local fubenBaseInfo = data.equipfubendata.FUBEN[self.m_FubenId]						--副本基本信息
	local fubenDes = string.split(fubenBaseInfo.fuben_des, "|")							--副本基本描述
	local fubenList = g_EquipFubenCtrl:GetFbListBaseInfoByFubenId(self.m_FubenId)		--副本层信息列表
	local floorBaseInfo = fubenList[self.m_SelectIndex]									--选中层信息
	local playerData = g_EquipFubenCtrl.m_FubenInfoList[self.m_FubenId]						--副本玩家数据信息
	local config = g_EquipFubenCtrl:GetConfigByFloor(floorBaseInfo.id)					--副本该层的配置信息
	local passInfo = {floor = floorBaseInfo.id, star = 0, sum_star = 0,}				--副本该层的通关信息
	local baseRewardInfo  = g_EquipFubenCtrl:GetBasePassReward(floorBaseInfo.id)		--该层副本的基本通关奖励
	if self.m_SelectIndex <= #self.m_CurPassFloor then
		passInfo = self.m_CurPassFloor[self.m_SelectIndex]
	end

	if fubenDes[2] then
		self.m_DetailBox.m_EquipTipsLabel:SetText(fubenDes[2])
	end

	local maybeReward = g_EquipFubenCtrl:DecodeReward(floorBaseInfo.maybe_reward)
	for i = 1, #maybeReward do
		local oAwardBox = self.m_DetailBox.m_AwardGrid:GetChild(i)
		if not oAwardBox then
			oAwardBox = self.m_DetailBox.m_AwardCloneBox:Clone()			
			self.m_DetailBox.m_AwardGrid:AddChild(oAwardBox)
		end
		oAwardBox:SetActive(true)
		local config = {isLocal = true,}
		oAwardBox:SetItemData(maybeReward[i].sid, maybeReward[i].amount, nil, config)
	end
	if self.m_DetailBox.m_AwardGrid:GetCount() > #maybeReward then
		for i = #maybeReward, self.m_DetailBox.m_AwardGrid:GetCount() do
			local oAwardBox = self.m_DetailBox.m_AwardGrid:GetChild(i)
			if oAwardBox then
				oAwardBox:SetActive(false)
			end
		end
	end
	self.m_DetailBox.m_AwardGrid:Reposition()	

	self.m_DetailBox.m_NameLabel:SetText(string.format("%s", fubenBaseInfo.type))
	self.m_DetailBox.m_LevelLavel:SetText(string.format("%s层", g_EquipFubenCtrl:CountConvert(self.m_SelectIndex)))	
	self.m_Energy = playerData.tili_cost

	if baseRewardInfo and next(baseRewardInfo) then
		local sid = tonumber(baseRewardInfo.sid)
		local count = baseRewardInfo.amount	
		local config = {isLocal = true,}
		self.m_DetailBox.m_PassItemBox:SetItemData(sid, count, nil, config)			
	end
	
	self.m_DetailBox.m_ProgressSprite:SetValue(passInfo.sum_star / config.star)	
	self.m_DetailBox.m_ProgressLabel:SetText(string.format("%d/%d", passInfo.sum_star, config.star))

	self.m_DetailBox.m_FirstPassBox:SetLocalPos(Vector3.New(-238 + 10  + 73 * #maybeReward ,  -218, 0))
	self.m_DetailBox.m_FirstPassBox:SetActive(true)
	if passInfo.star == 0 then
		--首次通关奖励显示
		self.m_DetailBox.m_FirstPassTitleLabel:SetText("首次通关奖励")
		local firstPassReward = g_EquipFubenCtrl:DecodeReward(floorBaseInfo.first_pass_reward)
		for k = 1, #firstPassReward do
			local oFirstBox = self.m_DetailBox.m_FirstPassItemGrid:GetChild(k)
			if not oFirstBox then
				oFirstBox = self.m_DetailBox.m_FirstPassItemCloneBox:Clone()			
				self.m_DetailBox.m_FirstPassItemGrid:AddChild(oFirstBox)
			end
			oFirstBox:SetActive(true)
			local config = {isLocal = true,}
			oFirstBox:SetItemData(firstPassReward[k].sid, firstPassReward[k].amount, nil, config)
		end
	else
		--满星奖励提示
		self.m_DetailBox.m_FirstPassTitleLabel:SetText("满星选取装备")
		local str = data.equipfubendata.FLOOR[floorBaseInfo.id].vip_reward_select
		local list = g_EquipFubenCtrl:DecodeReward(str)
		if list and next(list) then
			for k = 1, #list do
				local oFirstBox = self.m_DetailBox.m_FirstPassItemGrid:GetChild(k)
				if not oFirstBox then
					oFirstBox = self.m_DetailBox.m_FirstPassItemCloneBox:Clone()			
					self.m_DetailBox.m_FirstPassItemGrid:AddChild(oFirstBox)
				end
				oFirstBox:SetActive(true)
				local config = {isLocal = true,}
				oFirstBox:SetItemData(list[k].sid, list[k].amount, nil, config)
			end
		end		
	end

	local level = (self.m_SelectIndex + 2) * 10
	self.m_DetailBox.m_TipsLevelLabebl:SetText(string.format("%d级装备", level))

	if g_EquipFubenCtrl:GetFubenCanBuyTime(self.m_FubenId) > 0 then
		--暂时都隐藏添加次数按钮
		--self.m_DetailBox.m_AddTimeBtn:SetActive(true)
		self.m_DetailBox.m_AddTimeBtn:SetActive(false)
	else
		self.m_DetailBox.m_AddTimeBtn:SetActive(false)
	end
	if passInfo.sum_star >= config.star then
		self.m_DetailBox.m_ProgressBtn:AddEffect("circle")
	else
		self.m_DetailBox.m_ProgressBtn:DelEffect("circle")
	end

	self.m_LeftWipeTime = math.ceil((config.star - passInfo.sum_star) / 3)	
	local oView = CEquipFuBenSweepView:GetView()
	if oView then
		oView:SetLeftTime(self.m_LeftWipeTime) 
	end
	self.m_DetailBox.m_ProgressBtn:AddUIEvent("click", callback(self, "OnSelectVipReward", passInfo.floor, passInfo.sum_star, config.star))
	self.m_DetailBox.m_EnterBtn:AddUIEvent("click", callback(self, "OnEnterFuben"))
	self.m_DetailBox.m_WipeBtn:AddUIEvent("click", callback(self, "OnWipeFuben", passInfo.star == 3))
	self.m_DetailBox.m_WipeBtn:SetGrey(passInfo.star ~= 3)
	self.m_DetailBox.m_AddTimeBtn:AddUIEvent("click", callback(self, "OnAddTime", self.m_FubenId))
end

function CEquipFubenDetailView.SelectFuben(self, index)
	if self.m_SelectIndex ~= index then		
		if self.m_MaxFloor + 1 < index then
			g_NotifyCtrl:FloatMsg("请先通关上一副本")
			return
		end
		if self.m_SelectIndex then
			local oBox = self.m_FbListBox.m_FbGrid:GetChild(self.m_SelectIndex)
			oBox.m_SelectSprite:SetActive(false)
		end

		self.m_SelectIndex = index 
		local oBox = self.m_FbListBox.m_FbGrid:GetChild(self.m_SelectIndex)
		oBox.m_SelectSprite:SetActive(true)
		self:RefreshDetailBox()
	end
end

function CEquipFubenDetailView.OnCtrlEquipFubenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.UpdateInfo then
		self:RefreshDetailBox()
	end
end

function CEquipFubenDetailView.OnSelectVipReward(self, floor, sumStar, configStar)
	if sumStar < configStar then
		g_NotifyCtrl:FloatMsg("未达到满星")
		return
	end
	local str = data.equipfubendata.FLOOR[floor].vip_reward_select
	if str then
		local list = g_EquipFubenCtrl:DecodeReward(str)
		local sidList = {}
		for i, v in ipairs(list) do
			table.insert(sidList, v.sid)
		end
		if sidList and next(sidList) then
			CItemTipsPackageSelectView:ShowView(function (oView)
				oView:SetEquipItem(sidList, floor)
			end)

			-- local config = {floor = floor}
			-- CForgeCompositeEquipSelectView:ShowView(function (oView)
			-- 	oView:SetContent(sidList, CForgeCompositeEquipSelectView.UIType.EquipFbVipReward, config)
			-- end)
		end
	end
end

function CEquipFubenDetailView.SelectVipRewardRefresh(self, fubenId, floor, maxFloor)
	self.m_FubenId = fubenId
	self.m_CurPassFloor = floor
	self.m_MaxFloor = maxFloor
	self:RefreshDetailBox()
	self:RefreshListRedDot()
	--刷新列表奖励时，让服务器请求主界面的信息
 	g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain()
end

function CEquipFubenDetailView.RefreshListRedDot(self)
	local fubenList = g_EquipFubenCtrl:GetFbListBaseInfoByFubenId(self.m_FubenId)
	local baseInfo = data.equipfubendata.FUBEN[self.m_FubenId]
	if baseInfo and fubenList and next(fubenList) then
		for i = 1, #fubenList do
			local oBox = self.m_FbListBox.m_FbGrid:GetChild(i)
			if oBox then
				oBox:DelEffect("RedDot")
				if self.m_MaxFloor + 1 >= i then
					if #self.m_CurPassFloor >= i then
						local PassInfo = self.m_CurPassFloor[i]					
						local config = g_EquipFubenCtrl:GetConfigByFloor(PassInfo.floor)
						local sum_star = PassInfo.sum_star or 0					
						if sum_star >= config.star then
							oBox:AddEffect("RedDot")
						end						
					end
				end		
			end	
		end
	end
end

function CEquipFubenDetailView.OnShowEnergyTip(self)
	if g_WelfareCtrl:IsFreeEnergyRedDot() then
		local windowConfirmInfo = {
			msg = "有未领取的体力，是否前往领取？",
			title = "提示",
			okCallback = function () 
				g_WelfareCtrl:ForceSelect(define.Welfare.ID.FreeEnergy)
			end,
			cancelCallback = function ()
				g_NpcShopCtrl:ShowGold2EnergyView()
			end,
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_NpcShopCtrl:ShowGold2EnergyView()
	end
end

return CEquipFubenDetailView