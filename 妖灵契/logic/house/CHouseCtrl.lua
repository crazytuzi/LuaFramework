local CHouseCtrl = class("CHouseCtrl", CCtrlBase)
define.House = {
	Mode = 
	{
		Normal = 1,
		Upgrade = 2,
		Adorn = 3,
	},
	Event = {
		HouseInit = 1,
		FurnitureRefresh = 2,
		PartnerRefresh = 3,
		WarmRefresh = 4,
		TouchRefresh = 5,
		HouseItemAdd = 6,
		HouseItemDel = 7,
		HouseItemRefresh = 8,
		AdornRefresh = 9,
		GiveCntRefresh = 10,
		WorkDeskRefresh = 11,
		TalentRefresh = 12,
		FriendRefresh = 13,
		SetHouseInfo = 14,
		RefreshMainRedDot = 15,
		GivePartnerGift = 16,
		UpdateFriendWorkDesk = 17,
		OnRecieveHouseCoin = 18,
	},
	TaskStatus = {
		Lock = 1,
		Done = 2,
		Got = 3,
	},
	TrainStatus = {
		None = 0,
		Training = 1,
		TrainBack = 2,
		CanGet = 3,
	}
}

function CHouseCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CHouseCtrl.ResetCtrl(self)
	self.m_IsInHouse = false
	self.m_OwnerPid = 0
	if self.m_House then
		self.m_House:Destroy()
		self.m_House = nil
	end
	self.m_CameraPos = 1
	self.m_FurnitureInfos = {[0] = {}}
	self.m_PartnerInfos = {[0] = {}}
	self.m_AdornInfos = {}
	self.m_HouseItems = {}
	self.m_CurWarm = 0
	self.m_MaxWarm = 0
	self.m_CurTouchCnt = 0
	self.m_MaxTouchCnt = 10
	self.m_SuppleLoveTime = 0
	self.m_RemainGiveGiftCnt = 10
	self.m_MaxGiveGiftCnt = 10
	self.m_MaxTrainCnt = 1
	self.m_TalentLevel = {}
	self.m_TalentValue = {}
	self.m_GiftBuyCount = 0
	self.m_WorkDeskInfos = {}
	self.m_FaceToPartnerDic = nil
	self.m_FriendList = {}
	self.m_FriendDic = {}
	self.m_GotList = {}
	self.m_PushingCarema = false
	self.m_DefaultPartnerInfo = {
		type = 1001,
		love_level = 0,
		love_ship = 0,
		train_type = 0,
		train_time = 0,
		unchain_level = 0,
		coin = 0,
	}
	self.m_ShowFirstFriendEffect = false
end

function CHouseCtrl.RefreshFriend(self, lFriend)
	self.m_FriendList = {}
	self.m_FriendDic = {}
	local tempDic = {}
	for i,v in ipairs(lFriend) do
		self.m_FriendList[i] = self:CopyFriendData(v)
		self.m_FriendDic[v.frd_pid] = self.m_FriendList[i]
		local sortId = v.talent_level
		if v.desk_empty == 1 then
			sortId = sortId + 10000
		end
		if v.coin ~= 0 then
			sortId = sortId + 1000
		end
		tempDic[v.frd_pid] = sortId
	end

	local function sortFunc(v1, v2)
		return tempDic[v1.frd_pid] > tempDic[v2.frd_pid]
	end
	table.sort(self.m_FriendList, sortFunc)
	self:OnEvent(define.House.Event.FriendRefresh)
end

function CHouseCtrl.CopyFriendData(self, oData)
	local oTable = {
		frd_pid = oData.frd_pid,
		coin = oData.coin,
		talent_level = oData.talent_level,
		desk_empty = oData.desk_empty,
	}
	return oTable
end

function CHouseCtrl.OnRecieveHouseCoin(self, pid, status)
	if status == 0 then
		self.m_FriendDic[pid].coin = 0
	end
	self:OnEvent(define.House.Event.OnRecieveHouseCoin)
end


function CHouseCtrl.CanTouch(self)
	return not self.m_PushingCarema
end

function CHouseCtrl.SetPushing(self, bValue)
	self.m_PushingCarema = bValue
	g_HouseTouchCtrl:LockTouch(bValue)
end

function CHouseCtrl.GetFriendHouseData(self, pid)
	return self.m_FriendDic[pid]
end
------------------------------------------------------------------

function CHouseCtrl.EnterHouse(self)
	g_NotifyCtrl:ShowConnect("家具生成中...", 0.2)
	self.m_CameraPos = 1
	if self.m_House ~= nil then
		self.m_House:Destroy()
	end
	self.m_IsInHouse = true
	self.m_House = CHouse.New()

	g_ViewCtrl:CloseAll()
	CHouseMainView:ShowView()
	g_MapCtrl:Load(6000, 1)
	self:LoadCameraPos()
	-- g_CameraCtrl:AutoActive()
	if main.g_TestType ~= 0 then
		self:Test()
	end
end

function CHouseCtrl.SetHouseInfo(self, lFurnitures, lPartners, ownerPid)
	self.m_OwnerPid = ownerPid or g_AttrCtrl.pid
	self.m_FurnitureInfos[self.m_OwnerPid] = {}
	for _, v in ipairs(lFurnitures) do
		self.m_FurnitureInfos[self.m_OwnerPid][v.type] = self:CreateFurnitureInfo(v)
	end
	self.m_PartnerInfos[self.m_OwnerPid] = {}
	for _, v in ipairs(lPartners) do
		self.m_PartnerInfos[self.m_OwnerPid][v.type] = self:CreateParnterInfo(v)
	end
	self:OnEvent(define.House.Event.SetHouseInfo)
end

function CHouseCtrl.IsInFriendHouse(self)
	return self.m_OwnerPid ~= g_AttrCtrl.pid
end

function CHouseCtrl.SetMaxTrain(self, iMax)
	self.m_MaxTrainCnt = iMax
end

-- function CHouseCtrl.SetWarm(self, iCur, iMax)
-- 	self.m_CurWarm = iCur
-- 	self.m_MaxWarm = iMax
-- 	self:OnEvent(define.House.Event.WarmRefresh)
-- end

function CHouseCtrl.SetTouchCnt(self, iCur, iMax, iNext)
	if self.m_OwnerPid ~= g_AttrCtrl.pid then
		return
	end
	self.m_CurTouchCnt = iCur
	self.m_MaxTouchCnt = iMax
	self.m_SuppleLoveTime = iNext
	if self.m_TouchTimer ~= nil then
		Utils.DelTimer(self.m_TouchTimer)
		self.m_TouchTimer = nil
	end
	--红点计时
	if self.m_CurTouchCnt < self.m_MaxTouchCnt then
		self.m_TouchTimer = Utils.AddTimer(callback(self,"SetTouchCnt", iCur + 1, iMax, 3600), 0, iNext)
	end
	self:OnEvent(define.House.Event.TouchRefresh)
end

function CHouseCtrl.SetRemainGiveCnt(self, iCnt, iMax, iBuyCount)
	if self.m_OwnerPid ~= g_AttrCtrl.pid then
		return
	end
	self.m_GiftBuyCount = iBuyCount
	self.m_RemainGiveGiftCnt = iCnt
	self.m_MaxGiveGiftCnt = iMax
	self:OnEvent(define.House.Event.GiveCntRefresh)
end

function CHouseCtrl.SetTalent(self, iLevel, iValue, pid)
	local iPid = pid or self.m_OwnerPid
	self.m_TalentLevel[iPid] = iLevel
	self.m_TalentValue[iPid] = iValue
	self:OnEvent(define.House.Event.TalentRefresh)
end

function CHouseCtrl.GetTalentLevel(self, pid)
	local iPid = pid or self.m_OwnerPid
	return self.m_TalentLevel[iPid] or 0
end

function CHouseCtrl.GetTalentValue(self, pid)
	local iPid = pid or self.m_OwnerPid
	return self.m_TalentValue[iPid] or 0
end

function CHouseCtrl.SetFurnitureInfo(self, dInfo)
	dInfo = self:CreateFurnitureInfo(dInfo)
	if self.m_FurnitureInfos[self.m_OwnerPid] == nil then
		self.m_FurnitureInfos[self.m_OwnerPid] = {}
	end
	self.m_FurnitureInfos[self.m_OwnerPid][dInfo.type] = dInfo
	-- table.print(dInfo, "SetFurnitureInfo")
	self:OnEvent(define.House.Event.FurnitureRefresh, dInfo)
end

function CHouseCtrl.SetPartnerInfo(self, dInfo)
	dInfo = self:CreateParnterInfo(dInfo)
	if self.m_PartnerInfos[self.m_OwnerPid] == nil then
		self.m_PartnerInfos[self.m_OwnerPid] = {}
	end
	local dPartnerInfo = self.m_PartnerInfos[self.m_OwnerPid][dInfo.type]
	if dPartnerInfo and dPartnerInfo.m_RefreshTimer then
		Utils.DelTimer(dPartnerInfo.m_RefreshTimer)
		dPartnerInfo.m_RefreshTimer = nil
	end
	--红点计时
	if dInfo.train_type ~= 0 and dInfo.train_time > g_TimeCtrl:GetTimeS() then
		dInfo.m_RefreshTimer = Utils.AddTimer(function ()
			self:OnEvent(define.House.Event.PartnerRefresh, dInfo)
		end, 0, dInfo.train_time - g_TimeCtrl:GetTimeS())
	end

	self.m_PartnerInfos[self.m_OwnerPid][dInfo.type] = dInfo
	self:OnEvent(define.House.Event.PartnerRefresh, dInfo)
end

function CHouseCtrl.SetAdornInfo(self, dInfo)
	self.m_AdornInfos[dInfo.id] = dInfo
	self:OnEvent(define.House.Event.AdornRefresh, dInfo)
end

function CHouseCtrl.SetWorkDeskInfo(self, dInfo, pid)
	local iPid = pid or self.m_OwnerPid
	dInfo = self:CreateWorkDeskInfo(dInfo)
	if self.m_WorkDeskInfos[iPid] == nil then
		self.m_WorkDeskInfos[iPid] = {}
	end
	local workDeskInfo = self.m_WorkDeskInfos[iPid][dInfo.pos]
	if workDeskInfo and workDeskInfo.m_RefreshTimer then
		Utils.DelTimer(workDeskInfo.m_RefreshTimer)
		workDeskInfo.m_RefreshTimer = nil
	end
	self.m_WorkDeskInfos[iPid][dInfo.pos] = dInfo
	--红点计时
	if dInfo.status == 2 and iPid == self.m_OwnerPid then
		dInfo.m_RefreshTimer = Utils.AddTimer(function ()
			dInfo.status = 3
			self:OnEvent(define.House.Event.WorkDeskRefresh, dInfo.pos)
		end, 0, dInfo.talent_time + dInfo.create_time - g_TimeCtrl:GetTimeS())
	end
	self:OnEvent(define.House.Event.WorkDeskRefresh, dInfo.pos)
end

function CHouseCtrl.GetPartnerInfo(self, iType)
	return self.m_PartnerInfos[self.m_OwnerPid][iType]
end

function CHouseCtrl.GetPartnerInfos(self)
	return self.m_PartnerInfos[self.m_OwnerPid]
end

function CHouseCtrl.GetPartnerDataByFace(self, iFace)
	if self.m_FaceToPartnerDic == nil then
		self.m_FaceToPartnerDic = {}
		for k,v in pairs(data.housedata.HousePartner) do
			self.m_FaceToPartnerDic[tonumber(v.face)] = v
		end
	end
	return self.m_FaceToPartnerDic[iFace]
end

function CHouseCtrl.GetFurnitureInfo(self, iType)
	-- printc("self.m_OwnerPid: " .. self.m_OwnerPid)
	-- printc("iType: " .. iType)
	-- table.print(self.m_FurnitureInfos)
	return self.m_FurnitureInfos[self.m_OwnerPid][iType]
end

function CHouseCtrl.GetAdornInfo(self, id)
	return self.m_AdornInfos[id]
end

function CHouseCtrl.GetWorkDeskInfo(self, pos, pid)
	local iPid = pid or self.m_OwnerPid
	return self.m_WorkDeskInfos[iPid][pos]
end

function CHouseCtrl.CreateFurnitureInfo(self, v)
	local dDefault = {
		type = v.type,
		lock_status = v.lock_status,
		level = v.level,
		secs = v.secs,
		create_time = g_TimeCtrl:GetTimeS(),
	}
	return dDefault
end

function CHouseCtrl.CreateParnterInfo(self, v)
	local dDefault = {
		type = v.type,
		love_level = v.love_level,
		love_ship = v.love_ship,
		train_type = v.train_type,
		train_time = g_TimeCtrl:GetTimeS() + v.train_time,
		unchain_level = v.unchain_level or {},
		coin = v.coin,
	}
	if dDefault.train_type == nil or dDefault.train_type == 0 then
		dDefault.train_time = 0
	end
	return dDefault
end

function CHouseCtrl.CreateWorkDeskInfo(self, v)
	local dDefault = {
		pos = v.pos,
		lock_status = v.lock_status,
		status = v.status,
		talent_time = v.talent_time,
		frd_pid = v.frd_pid,
		create_time = g_TimeCtrl:GetTimeS(),
		item_sid = v.item_sid,
		speed_num = v.speed_num,
	}
	return dDefault
end


function CHouseCtrl.GetPartnerList(self)
	local list = table.dict2list(self.m_PartnerInfos[self.m_OwnerPid])
	table.sort(list, function(d1,d2) return d1.type < d2.type end)
	return list
end

function CHouseCtrl.LeaveHouse(self)
	if self:IsHouseOnly() then
		g_NotifyCtrl:FloatMsg("宅邸演示中,不能退出")
		return
	end
	nethouse.C2GSLeaveHouse()
	if self.m_House then
		self.m_House:Destroy()
		self.m_House = nil
	end
	self.m_IsInHouse = false
	g_DialogueAniCtrl:StopAllDialogueAni()
	g_ViewCtrl:CloseAll()
	CMainMenuView:ShowView()
	self:SetPushing(false)
end

function CHouseCtrl.IsInHouse(self)
	return self.m_IsInHouse
end

function CHouseCtrl.GetCurHouse(self)
	return self.m_House
end

function CHouseCtrl.LoadCameraPos(self)
	local dPos = self:GetCameraPos()
	local oCam = g_CameraCtrl:GetHouseCamera()
	oCam:SetPos(Vector3.New(dPos.pos.x, dPos.pos.y, dPos.pos.z))
	oCam:SetLocalEulerAngles(Vector3.New(dPos.rotate.x, dPos.rotate.y, dPos.rotate.z))
	local sRight = string.format("1_%s_Right", self.m_CameraPos)
	local dRightPos = data.cameradata.INFOS.house[sRight]
	if dRightPos then
		g_HouseTouchCtrl:SetRightAngle(dRightPos.rotate.y)
	else
		g_HouseTouchCtrl:SetRightAngle(nil)
	end
	local sLeft = string.format("1_%s_Left", self.m_CameraPos)
	local dLeftPos = data.cameradata.INFOS.house[sLeft]
	if dLeftPos then
		g_HouseTouchCtrl:SetLeftAngle(dLeftPos.rotate.y)
	else
		g_HouseTouchCtrl:SetLeftAngle(nil)
	end
	g_HouseCtrl:SetPushing(false)
end

function CHouseCtrl.GetCameraPos(self)
	local sType = string.format("1_%s", self.m_CameraPos)
	local dPos = data.cameradata.INFOS.house[sType]
	if not dPos then
		self.m_CameraPos = 1
		sType = string.format("1_%s", self.m_CameraPos)
		dPos = data.cameradata.INFOS.house[sType]
	end
	return dPos
end

function CHouseCtrl.GetTrainPos(self, iType)
	local pos = data.housedata.Train[iType].pos
	return Vector3.New(pos.x, pos.y, pos.z)
end


function CHouseCtrl.NextCameraPos(self)
	self.m_CameraPos = self.m_CameraPos + 1
	self:LoadCameraPos()
end

function CHouseCtrl.LoginItem(self, itemInfo)
	self.m_HouseItems = {}
	if self.m_OwnerPid == g_AttrCtrl.pid then
		for i, v in ipairs(itemInfo) do
			self.m_HouseItems[v.id] = v
		end
	end
end

function CHouseCtrl.AddHouseItem(self, dItem)
	if self.m_OwnerPid == g_AttrCtrl.pid then
		self.m_HouseItems[dItem.id] = dItem
		self:OnEvent(define.House.Event.HouseItemAdd, dItem)
	end
end

function CHouseCtrl.DelHouseItem(self, id)
	self.m_HouseItems[id] = nil
	self:OnEvent(define.House.Event.HouseItemDel, id)
end

function CHouseCtrl.RefreshHouseItemAmount(self, id, amount)
	local dItem = self.m_HouseItems[id]
	if dItem then
		dItem.amount = amount
		self.m_HouseItems[dItem.id] = dItem
		self:OnEvent(define.House.Event.GiftRerfesh, id)
	end
end

function CHouseCtrl.GetGiftList(self)
	local list = {}
	for _, v in pairs(self.m_HouseItems) do
		local dData = DataTools.GetItemData(v.sid, "HOUSE")

		if dData.giftable == 1 then
			table.insert(list, v)
		end
	end
	return list
end

function CHouseCtrl.GetHouseItemAmount(self, iShape)
	local iCnt = 0
	for k, v in pairs(self.m_HouseItems) do
		if v.sid == iShape then
			iCnt = iCnt + v.amount
		end
	end
	return iCnt
end

function CHouseCtrl.LookFurniture(self, oFurniture)
	if oFurniture then
		local vPos = oFurniture:GetValue("look_pos") or Vecotr3.zero
		vPos = oFurniture:GetPos() + vPos
		local oCam = g_CameraCtrl:GetHouseCamera()
		oCam:SetPos(vPos)
		oCam:LookAt(oFurniture.m_Transform, oFurniture:GetForward())
	else
		self:LoadCameraPos()
	end
end

function CHouseCtrl.Test(self)
	self.m_FurnitureInfos[0] = {
		[1] = {
			type = 1,
			lock_status = 1,
			level = 1,
			secs = 999,
		},
		[2] = {
			type = 2,
			lock_status = 1,
			level = 1,
			secs = 0,
		},
		[3] = {
			type = 3,
			lock_status = 1,
			level = 1,
			secs = 0,
		},
		[5] = {
			type = 5,
			lock_status = 1,
			level = 1,
			secs = 0,
		}
	}
	self.m_PartnerInfos[0] = {
		[1001] = {
			type = 1001,
			love_level = 1,
			love_ship = 10,
			train_type = 1,
			train_time = 3600,
			unchain_level = {},
		},
		[1002] = {
			type = 1002,
			love_level = 1,
			love_ship = 10,
			train_type = 1,
			train_time = 3600,
			unchain_level = {},
		},
	}
	self:SetHouseInfo(table.dict2list(self.m_FurnitureInfos), table.dict2list(self.m_PartnerInfos))

	nethouse.C2GSOpenWorkDesk = function()
		local t = {
			desk_info = {
				{
					pos = 1,
					lock_status = 1,
					status = 1,
					talent_time = 999,
					friend_name = "???",
				},
				{
					pos = 2,
					lock_status = 1,
					status = 3,
					talent_time = 0,
					friend_name = "???",
				},
				{
					pos = 3,
					lock_status = 1,
					status = 2,
					talent_time = 0,
					friend_name = "???",
				},
				{
					pos = 4,
					lock_status = 1,
					status = 1,
					talent_time = 1000,
					friend_name = "???",
				}
			},
			talent_level = 1,
			talent_schedule = 0,
		}
		nethouse.GS2COpenWorkDesk(t)
	end
end

function CHouseCtrl.GetTaskList(self, iType)
	return data.housedata.HouseTask[iType]
end

function CHouseCtrl.GetMaxLove(self, level)
	if data.housedata.HouseLove[level] then
		return data.housedata.HouseLove[level].loveship
	else
		printc(string.format("<color=#ff0000>亲密度等级%s不存在</color>\n", level))
		return data.housedata.HouseLove[#data.housedata.HouseLove].loveship
	end
end

function CHouseCtrl.GetCurrentLoveStage(self, partnerType)
	for k,v in pairs(data.housedata.Love_Stage) do
		if self.m_PartnerInfos[self.m_OwnerPid][partnerType].love_level >= v.min_level and self.m_PartnerInfos[self.m_OwnerPid][partnerType].love_level <= v.max_level then
			return v
		end
	end
	printc("<color=#ff0000>亲密度等级不存在</color>\n")
	return data.housedata.Love_Stage[#data.housedata.Love_Stage]
end

function CHouseCtrl.GetTotalLoveLv(self)
	local iLv = 0
	if self.m_PartnerInfos[self.m_OwnerPid] then
		for k,v in pairs(self.m_PartnerInfos[self.m_OwnerPid]) do
			iLv = iLv + v.love_level
		end
	end
	return iLv
end

function CHouseCtrl.GetRandomDialogID(self)
	local odata = data.housedata.HouseDialog
	return odata[Utils.RandomInt(1, #odata)]
end

function CHouseCtrl.IsNeedGiftRedDot(self)
	if self.m_RemainGiveGiftCnt > 0 then
		local giftList = self:GetGiftList()
		for k,v in pairs(giftList) do
			if v.amount > 0 then
				return true
			end
		end
	end
	return false
end

function CHouseCtrl.IsNeedTrainRedDot(self)
	local count = 0
	if self.m_PartnerInfos[g_AttrCtrl.pid] then
		for k,v in pairs(self.m_PartnerInfos[g_AttrCtrl.pid]) do
			if v.train_type ~= 0 then
				count = count + 1
				--可领取
				local iTime = v.train_time - g_TimeCtrl:GetTimeS()
				if iTime <= 0 then
					return true
				end
			end
		end
	end
	--未满
	if count < self.m_MaxTrainCnt then
		return true
	end
	return false
end

function CHouseCtrl.IsNeedTeaArtRedDot(self)
	if self.m_WorkDeskInfos[g_AttrCtrl.pid] then
		for k,v in pairs(self.m_WorkDeskInfos[g_AttrCtrl.pid]) do
			if v.lock_status == 1 and v.pos < 4 then
				if v.status == 1 or v.status == 3 then
					-- printc("工作台可操作")
					return true
				end
			end
		end
	end
	return false
end

function CHouseCtrl.IsTouchNeedRedDot(self)
	return self.m_CurTouchCnt >= self.m_MaxTouchCnt
end

function CHouseCtrl.IsMainNeedRedDot(self)
	local needRedDot = false
	local curTime = g_TimeCtrl:GetTimeS()
	local nextCheckTime = curTime + 999999999
	--爱抚可操作
	if self:IsTouchNeedRedDot() then
		-- printc("爱抚可操作")
		needRedDot = true
	end
	--工作台可操作
	if self:IsNeedTeaArtRedDot() then
		needRedDot = true
	end
	
	if self:IsNeedGiftRedDot() then
		needRedDot = true
	end
	
	--特训可操作
	if self:IsNeedTrainRedDot() then
		needRedDot = true
	end

	return needRedDot
end

function CHouseCtrl.PlayHousePartnerAni(self, partnerType)
	local t = {sid = partnerType, amount = 1, virtual = 1025}
	table.insert(self.m_GotList, t)
	local function func()
		if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.house.open_grade then
			if #self.m_GotList > 0 then
				g_WindowTipCtrl:SetWindowAllItemRewardList(g_HouseCtrl.m_GotList)
				g_HouseCtrl.m_GotList = {}
			end
		else
			g_NotifyCtrl:FloatMsg(string.format("恭喜您，[00ff00]%s[-]将会进入宅邸", data.housedata.HousePartner[partnerType].name))
		end
	end
	local oView = CMainMenuView:GetView()
	if oView and oView:GetActive() then
		func()
	else
		CMainMenuView:SetShowCB(function ()
			func()
			CMainMenuView:ClearShowCB()
		end)
	end
end

function CHouseCtrl.IsHouseOnly(self)
	return IOTools.GetClientData("IsHouseOnly") or false
end

return CHouseCtrl