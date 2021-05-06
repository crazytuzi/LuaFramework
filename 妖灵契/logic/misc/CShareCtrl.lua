local CShareCtrl = class("CShareCtrl", CCtrlBase)
CShareCtrl.g_Test = true
function CShareCtrl.ctor(self)
	CCtrlBase.ctor(self)

	local gameObject = UnityEngine.GameObject.Find("GameRoot/ShareSDK")
	self.m_ShareSDK = gameObject:GetComponent(classtype.ShareSDK)
	self.m_ShareManager = gameObject:GetComponent(classtype.ShareSDKManager)
	self.m_ShareManager:InitShare(self.m_ShareSDK, callback(self, "OnCallback"))

	self.m_SupportPlat = {
		[enum.Share.PlatformType.Unknown] = "",
		[enum.Share.PlatformType.WeChat] = "com.tencent.mm",
		[enum.Share.PlatformType.WeChatMoments] = "com.tencent.mm",
		[enum.Share.PlatformType.SinaWeibo] = "",
	}
end

function CShareCtrl.OnCallback(self, iShareType, iReqID, iResponseState, iPlatformType, sData)
	print("OnShareCallback:", iShareType, iReqID, iResponseState, iPlatformType, sData)
	self:OnEvent(iReqID, {type=iShareType, response=iResponseState, result=decodejson(sData)})
end

function CShareCtrl.IsSupportedPlatfromType(self, iPlatformType)
	if Utils.IsEditor() then
		if CShareCtrl.g_Test then
			return true
		end
		return false
	end
	return self.m_SupportPlat[iPlatformType] ~= nil
end

function CShareCtrl.IsClientInstalled(self, iPlatformType)
	if Utils.IsEditor() then
		if CShareCtrl.g_Test then
			return true
		end
		return false
	end
	if iPlatformType == enum.Share.PlatformType.Unknown then
		return true
	else
		return self.m_ShareSDK:IsClientValid(iPlatformType)
	end
end

function CShareCtrl.IsShowShare(self)
	if Utils.IsPC() and not Utils.IsEditor() then
		return false
	elseif Utils.IsIOS() then
		return false
	else
		return true
	end
end

function CShareCtrl.ShareImage(self, sPath, sDesc, cb, closecb)
	local function onshare(platid)
		Utils.AddTimer(function() cb(platid) end, 0, 0)
		if platid and not Utils.IsPC() then
			self:ShareContent({image_path = sPath}, platid, cb)
		end
	end
	CShareView:ShowView(function(oView)
		oView:SetShareCb(onshare)
		oView:SetCloseCb(closecb)
	end)
end


function CShareCtrl.CreateContent(self, dContent)
	local content = Share.ShareContent.New()
	if dContent.title then
		content:SetTitle(dContent.title)
	end
	if dContent.desc then
		content:SetText(dContent.desc)
	end
	if dContent.url then
		content:SetUrl(dContent.SetUrl)
		content:SetShareType(enum.Share.ContentType.Webpage)
	else
		if dContent.image_path then
			if dContent.image_path:find("^http") ~= nil then
				content:SetImageUrl(dContent.image_path)
			else
				content:SetImagePath(dContent.image_path)
			end
			content:SetShareType(enum.Share.ContentType.Image)
		end
	end
	return content
end

function CShareCtrl.ShareContent(self, dContent, iPlatformType, cb)
	local iReqID = self.m_ShareSDK:ShareContent(iPlatformType, self:CreateContent(dContent))
	print("ShareContent:", iReqID)
	-- self:AddCtrlEvent(iReqID, cb)
	return iReqID
end

function CShareCtrl.ShowPlatformList(self, dContent, cb)
	local content = self:CreateContent(dContent)
	local iReqID = self.m_ShareSDK:ShowPlatformList(self:GetPlatformArray(), content, 0, 0)
	print("ShowPlatformList:", iReqID)
	-- self:AddCtrlEvent(iReqID, cb)
	return iReqID
end

function CShareCtrl.GetPlatformArray(self)
	local array = Utils.ListToArray(table.keys(self.m_SupportPlat), classtype.Int)
	return array
end

return CShareCtrl