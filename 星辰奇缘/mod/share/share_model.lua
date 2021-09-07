-- ------------------------
-- 分享推广模块
-- hosr
-- ------------------------
ShareModel = ShareModel or BaseClass(BaseModel)

function ShareModel:__init(manager)
	self.manager = manager

	self.mainWindow = nil
	self.shopWindow = nil
	self.bindWindow = nil
	self.tipsPanel = nil

	self.listener = function() self:OnUILoad() end

	EventMgr.Instance:AddListener(event_name.mainui_loaded, self.listener)
	if self.manager:IsOpen() then
		EventMgr.Instance:AddListener(event_name.role_level_change, function() self:OnLevelUp() end)
	end
	-- self:InitSDK()

	self.needRed = false
	self.hasClipboard = false
	self:ClipboardVersionCheck()
end

function ShareModel:OnUILoad()
	EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.listener)
	if self.manager:IsOpen() then
		self:OnLevelUp()
	end
	self:InitSDK()
end

function ShareModel:OnLevelUp()
	self.needRed = false
	local key = ShareManager.Instance.shareData.apply_key
	for i,data in ipairs(DataExtension.data_reward) do
		if ShareManager.Instance.gainList[data.id] == nil and RoleManager.Instance.RoleData.lev >= data.need_lev and key ~= nil and key ~= "" then
			self.needRed = true
		end
	end
	if MainUIManager.Instance.MainUIIconView ~= nil then
		MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(8, self.needRed)
	end
end

function ShareModel:OpenMain(args)
	if self.mainWindow == nil then
		self.mainWindow = ShareMainWindow.New(self)
	end
	self.mainWindow:Open(args)
end

function ShareModel:CloseMain()
	WindowManager.Instance:CloseWindowById(WindowConfig.WinID.share_main)
end

function ShareModel:OpenShop(args)
	if self.shopWindow == nil then
		self.shopWindow = ShareShopWindow.New(self)
	end
	self.shopWindow:Open(args)
end

function ShareModel:CloseShop()
	WindowManager.Instance:CloseWindowById(WindowConfig.WinID.share_shop)
end

function ShareModel:OpenBind(args)
	if self.bindWindow == nil then
		self.bindWindow = ShareBindPanel.New(self)
	end
	self.bindWindow:Open(args)
end

function ShareModel:CloaseBind()
	WindowManager.Instance:CloseWindowById(WindowConfig.WinID.share_bind)
end

function ShareModel:OpenTipsPanel()
	if self.tipsPanel == nil then
		self.tipsPanel = ShareTipsPanel.New(self)
	end
	self.tipsPanel:Show()
end

function ShareModel:CloseTipsPanel()
	if self.tipsPanel ~= nil then
		self.tipsPanel:DeleteMe()
		self.tipsPanel = nil
	end
end

-- ---------------------------------------
-- 分享SDK触发
-- ---------------------------------------
function ShareModel:MessageCallBack(msg)
	print("分享结果 == " .. msg)
	if msg == "success" then
		print("分享结果 = 成功")
		self.manager.needSend17506 = true
		ShareManager.Instance:Send17506()
	else
		print("分享结果 = 失败")
	end
end

function ShareModel:InitSDK()
	if Application.platform ~= RuntimePlatform.IPhonePlayer then
		return
	end

	if not self:VersionCheck() then
		return
	end

	local config = {
		shareSDKAppKey = ShareEumn.SDKAppId,
		weiboAppKey = ShareEumn.WeiboAppKey,
		weiboAppSecret = ShareEumn.WeiboAppSecret,
		weiboredirectUri = ShareEumn.WeiboRedirectUri,
		wechatAppId = ShareEumn.WeChatAppId,
		wechatAppSecret = ShareEumn.WeChatAppSecret,
		qqAppId = ShareEumn.QQAppId,
		qqAppKey = ShareEumn.QQAppKey,
	}

	if self:GiftVersionCheck() then
		SdkManager.Instance.wrapper:SetShareCallback(function(msg) self:MessageCallBack(msg) end)
	end
	ctx:InitShareSDK(config)
end

-- 发到微信好友
function ShareModel:TOWeChat()
	if Application.platform ~= RuntimePlatform.IPhonePlayer then
		return
	end

	if not self:VersionCheck() then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前版本不支持分享功能，请在AppStore安装最新应用"))
		return
	end

	local info = {
		shareContent = ShareEumn.Content(),
		shareTitle = ShareEumn.Title(),
		shareUrl = ShareEumn.CallbackUrl,
		shareImagePath = ShareEumn.ImagePath,
	}
	ctx:Share(info, ShareEumn.PlatformType.WeChatFrient)

	if not self:GiftVersionCheck() then
		self.manager.needSend17506Delay = true
	end
end

-- 发到微信朋友圈
function ShareModel:TOWeChatTimeline()
	if Application.platform ~= RuntimePlatform.IPhonePlayer then
		return
	end

	if not self:VersionCheck() then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前版本不支持分享功能，请在AppStore安装最新应用"))
		return
	end

	local info = {
		shareContent = ShareEumn.Content(),
		shareTitle = ShareEumn.Title(),
		shareUrl = ShareEumn.CallbackUrl,
		shareImagePath = ShareEumn.ImagePath,
	}
	ctx:Share(info, ShareEumn.PlatformType.WeChatTimeline)

	if not self:GiftVersionCheck() then
		self.manager.needSend17506Delay = true
	end
end

-- 发到qq好友
function ShareModel:TOQQ()
	if Application.platform ~= RuntimePlatform.IPhonePlayer then
		return
	end

	if not self:VersionCheck() then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前版本不支持分享功能，请在AppStore安装最新应用"))
		return
	end

	local info = {
		shareContent = ShareEumn.Content(),
		shareTitle = ShareEumn.Title(),
		shareUrl = ShareEumn.CallbackUrl,
		shareImagePath = ShareEumn.ImagePath,
	}
	ctx:Share(info, ShareEumn.PlatformType.QQFrient)

	if not self:GiftVersionCheck() then
		self.manager.needSend17506Delay = true
	end
end

-- 发到qq空间
function ShareModel:TOQQZone()
	if Application.platform ~= RuntimePlatform.IPhonePlayer then
		return
	end

	if not self:VersionCheck() then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前版本不支持分享功能，请在AppStore安装最新应用"))
		return
	end

	local info = {
		shareContent = ShareEumn.Content(),
		shareTitle = ShareEumn.Title(),
		shareUrl = ShareEumn.CallbackUrl,
		shareImagePath = ShareEumn.ImagePath,
	}
	ctx:Share(info, ShareEumn.PlatformType.QQZone)

	if not self:GiftVersionCheck() then
		self.manager.needSend17506Delay = true
	end
end

-- 发到微博
function ShareModel:TOWeibo()
	if Application.platform ~= RuntimePlatform.IPhonePlayer then
		return
	end

	if not self:VersionCheck() then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前版本不支持分享功能，请在AppStore安装最新应用"))
		return
	end

	local info = {
		shareContent = string.format("%s%s %s:%s", TI18N("#星辰奇缘#"), ShareEumn.Title(), TI18N("官网地址"), ShareEumn.OfficialWeb),
		shareTitle = ShareEumn.Content(),
		shareUrl = ShareEumn.CallbackUrl,
		shareImagePath = ShareEumn.ImagePath,
	}
	ctx:Share(info, ShareEumn.PlatformType.Weibo)

	if not self:GiftVersionCheck() then
		self.manager.needSend17506Delay = true
	end
end

function ShareModel:VersionCheck()
	if BaseUtils.GetLocation() ~= KvData.localtion_type.cn then
		return false
	end

	if Application.platform == RuntimePlatform.IPhonePlayer then
		if BaseUtils.GetPlatform() == "ios" then
			if BaseUtils.CSVersionToNum() < 20106 then
				return false
			end
			return true
		else
			if BaseUtils.CSVersionToNum() < 10501 then
				return false
			end
			return true
		end
	end
	return false
end

function ShareModel:GiftVersionCheck()
	if Application.platform == RuntimePlatform.IPhonePlayer then
		if BaseUtils.GetPlatform() == "ios" then
			if BaseUtils.CSVersionToNum() <= 20106 then
				return false
			end
			return true
		else
			if BaseUtils.CSVersionToNum() <= 10501 then
				return false
			end
			return true
		end
	end
	return false
end

function ShareModel:ClipboardVersionCheck()
	if Application.platform ~= RuntimePlatform.IPhonePlayer and Application.platform ~= RuntimePlatform.Android then
		return
	end

	local tab = getmetatable(Utils)
	for k,v in pairs(tab) do
		if tostring(k) == "CopyTextToClipboard" then
			self.hasClipboard = true
		end
	end
end