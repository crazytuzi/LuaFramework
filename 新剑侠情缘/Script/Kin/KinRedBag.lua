function Kin:GetMemberRedBagId(nMemberId)
	if not self.tbRedBags then return end

	local tbBags = {}
	for _,v in ipairs(self.tbRedBags) do
		if v.tbOwner.nId==nMemberId and v.nSendTime>0 then
			table.insert(tbBags, v)
		end
	end
	if #tbBags<=0 then return end

	table.sort(tbBags, function(a,b)
		return a.nSendTime>b.nSendTime
	end)
	return tbBags[1].szId
end

function Kin:HaveUnsentRedBags()
	if not self.tbRedBags then return false end

	for _,v in ipairs(self.tbRedBags) do
		if v.tbOwner.nId==me.dwID and v.nSendTime<=0 then
			return true
		end
	end
	return false
end

function Kin:HaveCanGrabRedBags()
	if not self.tbRedBags then return false end

	for _,v in ipairs(self.tbRedBags) do
		if v.bCanGrab then
			return true
		end
	end
	return false
end

function Kin:RedBagUpdateRedPoint(bFirst)
	Ui:ClearRedPointNotify("KinRedBagNotify")
	if bFirst and self:HaveUnsentRedBags() then
		Ui:SetRedPointNotify("KinRedBagNotify")
	end

	if self:HaveCanGrabRedBags() then
		Ui:SetRedPointNotify("KinRedBagNotify")
	end
end

function Kin:OnRedBagUpdateAll(tbRedBags, nGlobalVersion)
	local bFirst = not next(self.tbRedBags or {})
	self.tbRedBags = tbRedBags
	self.nGlobalVersion = nGlobalVersion
	self:RedBagUpdateRedPoint(bFirst)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REDBAG_DATA_REFRESH)
end

function Kin:OnRedBagUpdate(tbRedBag)
	self:RedBagUpdateRedPoint(false)
	self.tbRedBagDetails = self.tbRedBagDetails or {}
	self.tbRedBagDetails[tbRedBag.szId] = tbRedBag
	UiNotify.OnNotify(UiNotify.emNOTIFY_REDBAG_SINGLE_UPDATE, tbRedBag)
end

function Kin:RefreshRedBagAll()
	local nVersion = Kin.tbRedBags and Kin.tbRedBags.nVersion or 0
	RemoteServer.DoKinRedBagReq("RedBagUpdateReq", "", nVersion, self.nGlobalVersion or 0)
end

function Kin:GetRedBagDetailById(szId)
	self.tbRedBagDetails = self.tbRedBagDetails or {}
	local tbDetail = self.tbRedBagDetails[szId]
	local bCheckUpdate = true
	if tbDetail and tbDetail.tbRecvData.nCount>=tbDetail.nMaxReceiver then
		bCheckUpdate = false
	end
	if bCheckUpdate then
		self:RefreshRedBagById(szId, tbDetail and tbDetail.nVersion or 0)
	end
	return tbDetail
end

function Kin:RefreshRedBagById(szId, nVersion)
	RemoteServer.DoKinRedBagReq("RedBagUpdateReq", szId, nVersion)
end

function Kin:RedBagSend(szId, nAddGold, nCount, nKind, szVoicePwd)
	local bOk, szErr = Kin:RedBagCheckKind(nKind, szVoicePwd)
	if not bOk then
		return false, szErr
	end
	RemoteServer.DoKinRedBagReq("RedBagSendReq", szId, nAddGold, nCount, nKind, szVoicePwd)
	return true
end

function Kin:RedBagGrab(szId)
	RemoteServer.DoKinRedBagReq("RedBagGrabReq", szId)
end

function Kin:RedBagClear()
	self.tbRedBags = nil
	self.tbRedBagDetails = nil
end

function Kin:RedBagOnNew(szId, nMulti)
	UiNotify.OnNotify(UiNotify.emNOTIFY_NEW_REDBAG, szId, nMulti)
end

function Kin:RedBagOnGain()
	Ui:SetRedPointNotify("KinRedBagNotify")
end

function Kin:RedBagOnLogin()
	self:RedBagClear()
	self:RefreshRedBagAll()
end

function Kin:RedBagUpdateCanGrab(szId, bCanGrab)
	if not self.tbRedBags then return end

	for _,tb in ipairs(self.tbRedBags) do
		if tb.szId==szId then
			tb.bCanGrab = bCanGrab
			break
		end
	end
end