QteType = 
{
	QTE_TYPE_INVALID = 0,
	QTE_TYPE_JILIAN = 1, 
	QTE_TYPE_GUILD_PARTY = 2,
}

QteView = QteView or BaseClass(XuiBaseView)
QteView.BUTTON_WIDTH = 104
QteView.BUTTON_GAP = 104
function QteView:__init()
	if QteView.Instance then
		ErrorLog("[QteView] Attemp to create a singleton twice !")
	end
	QteView.Instance = self
	self.background_opacity = 0
	self:SetModal(true)
	self.cur_qte_type = 0
	self.click_flag = {}
	self.click_button = {}
	self.delay_timer = nil
	self.zorder = MAX_VIEW_ZORDER
end

function QteView:__delete()
	QteView.Instance = nil
end

function QteView:SetQteData(protocol)
	self.cur_qte_type = protocol.qte_type
	local end_time = protocol.qte_loss_time
	local server_time = TimeCtrl.Instance:GetServerTime()
	if server_time > end_time then
		self:Close()
	else
		local end_callback = function()
			if self:IsOpen() then
				SysMsgCtrl.SendQTEReq(self.cur_qte_type, 0)
				self:Close()
			end
		end
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(end_callback, end_time - server_time)
	end
end

function QteView:SetCurrentQteType(qte_type)
	self.cur_qte_type = qte_type
end

function QteView:LoadCallBack()
	for i = 1, 3 do
		self.click_button[i] = XUI.CreateButton(0, 0, QteView.BUTTON_WIDTH, QteView.BUTTON_WIDTH, false, ResPath.GetScene("qte_btn"), "", "", true)
		RenderUnit.CreateEffect(3099, self.click_button[i], 0, 0.15, nil, QteView.BUTTON_WIDTH / 2, QteView.BUTTON_WIDTH / 2)
		self.root_node:addChild(self.click_button[i])
		XUI.AddClickEventListener(self.click_button[i], BindTool.Bind2(self.ClickCircle, self, i))
	end
end

function QteView:OpenCallBack()
	
end

function QteView:ShowIndexCallBack()
	self.click_flag = {}
	local pose_list = {}
	local pose_hold = {}
	math.randomseed(os.time())
	for i = 1, 3 do
		local random_func = function() end
		random_func = function()
			pose_list[i] = {}
			pose_list[i].x = math.random(-2, 2)
			pose_list[i].y = math.random(-1, 1)
			local key = pose_list[i].x .. pose_list[i].y
			if nil == pose_hold[key] then
				pose_hold[key] = key
			else
				random_func()
			end
		end
		random_func()
	end

	for i, v in ipairs(self.click_button) do
		v:setVisible(true)
		v:setPosition((QteView.BUTTON_WIDTH + QteView.BUTTON_GAP) * pose_list[i].x,  (QteView.BUTTON_WIDTH + QteView.BUTTON_GAP)* pose_list[i].y)
	end
end

function QteView:ClickCircle(i)
	self.click_flag[i] = 1
	self.click_button[i]:setVisible(false)
	local count = 0
	for k,v in pairs(self.click_flag) do
		count = count + 1
		if count == 3 then
			SysMsgCtrl.SendQTEReq(self.cur_qte_type, 1)
			self:Close()
		end
	end
end

function QteView:CloseCallBack()
	if nil ~= self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end


		