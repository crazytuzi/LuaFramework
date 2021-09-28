-- 主面板
EmailMainPanel = BaseClass(CommonBackGround)
function EmailMainPanel:__init()
	resMgr:AddUIAB("mail")
	self:Config()
	self:InitEvent()
end
function EmailMainPanel:Config()
	self.id = "EmailMainPanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="yj01", res1="yj00", id="0", red=false}, 
		-- {label="", res0="ys00", res1="ys01", id="1", red=true}
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("邮  件")
			if not self.mailPanel then
				self.mailPanel = MailPanel.New(self.container)
			end
			cur = self.mailPanel
		else -- 其他

		end

		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
				if self.isFinishLayout then -- 在布局完成才调用（不要让打开回调与这里一起回调）
					cur:Update() -- 更新当前面板数据（每个面板切换时更新）
				end
			end
		end
		self:SetTabarTips(id, false)
	end

	self.mailModel = EmailModel:GetInstance()
end
function EmailMainPanel:InitEvent()
	-- self.openCallback = function () end-- 打开回调
	-- self.closeCallback = function () end -- 关闭回调

	local function OnUpdateEmailList()
		if self.mailPanel then
			self.mailPanel:Update()
		end
	end
	self.handler1 = self.mailModel:AddEventListener(EmailConst.UpdateEmailList, OnUpdateEmailList)
	local function OnGetEmailData(id)
		if self.mailPanel then
			self.mailPanel:UpdateList(id, false)
		end
	end
	self.handler2 = self.mailModel:AddEventListener(EmailConst.GetEmailData, OnGetEmailData)
	local function OnDelEmail(id)
		if self.mailPanel then
			self.mailPanel:UpdateList(id, true)
		end
	end
	self.handler3 = self.mailModel:AddEventListener(EmailConst.DelEmail, OnDelEmail)
end

function EmailMainPanel:Open()
	if self:IsOpen() then
	else
		CommonBackGround.Open(self)
	end
end

-- 各个面板这里布局
function EmailMainPanel:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现 仅一次
end

function EmailMainPanel:__delete()
	self.selectPanel = nil
	if self.mailPanel then
		self.mailPanel:Destroy()
	end
	if self.mailModel then
		self.mailModel:RemoveEventListener(self.handler1)
		self.mailModel:RemoveEventListener(self.handler2)
		self.mailModel:RemoveEventListener(self.handler3)
	end
	self.mailPanel = nil
	self.mailModel = nil
end