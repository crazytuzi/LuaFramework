require("game/scoiety/scoiety_team_view")
require("game/scoiety/scoiety_friend_view")
require("game/scoiety/scoiety_enemy_view")
require("game/scoiety/scoiety_mail_view")
require("game/scoiety/write_mail_view")


ScoietyView = ScoietyView or BaseClass(BaseView)
function ScoietyView:__init()
    self.ui_config = {"uis/views/scoietyview", "ScoietyView"}
    self.play_audio = true
    self:SetMaskBg()
    self.is_async_load = false
    self.is_check_reduce_mem = true
    -- self.full_screen = true
    self.def_index = TabIndex.society_friend
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ScoietyView:__delete()
end

function ScoietyView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Scoiety)
	end

	if self.scoiety_team_view then
		self.scoiety_team_view:DeleteMe()
		self.scoiety_team_view = nil
	end
	if self.scoiety_friend_view then
		self.scoiety_friend_view:DeleteMe()
		self.scoiety_friend_view = nil
	end
	if self.scoiety_enemy_view then
		self.scoiety_enemy_view:DeleteMe()
		self.scoiety_enemy_view = nil
	end
	if self.scoiety_mail_view then
		self.scoiety_mail_view:DeleteMe()
		self.scoiety_mail_view = nil
	end
	if self.write_mail_view then
		self.write_mail_view:DeleteMe()
		self.write_mail_view = nil
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	-- 清理变量和对象
	self.have_mail = nil
	self.can_send_gift = nil
	self.tabteam = nil
	self.tabfriend = nil
	self.tabenemy = nil
	self.tabmail = nil
	self.mail_content = nil
	self.friend_lot_add = nil
	self.red_point_list = nil
	self.write_mail_content = nil
	self.show_red_point = nil
end

function ScoietyView:LoadCallBack()
	-- self.have_mail = self:FindVariable("HaveMail")
	-- self.can_send_gift = self:FindVariable("CanSendGift")
	-- self.show_red_point = self:FindVariable("Show_Red_Point")
	
	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))
	
	--获取UI
	self.tabteam = self:FindObj("TabTeam")
	self.tabfriend = self:FindObj("TabFriend")
	self.tabenemy = self:FindObj("TabEnemy")
	self.tabmail = self:FindObj("TabMail")

	--组队面板
	self.scoiety_team_view = ScoietyTeamView.New()
	local team_content = self:FindObj("TeamView")
	team_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.scoiety_team_view:SetInstance(obj)
		self.scoiety_team_view:FlushTeamView()
	end)

	--好友面板
	self.scoiety_friend_view = ScoietyFriendView.New()
	local friend_content = self:FindObj("FriendView")
	friend_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.scoiety_friend_view:SetInstance(obj)
		--引导用按钮
		self.friend_lot_add = self.scoiety_friend_view.friend_lot_add
		self.scoiety_friend_view:FlushFriendView()
	end)

	--仇人面板
	self.scoiety_enemy_view = ScoietyEnemyView.New()
	local enemy_content = self:FindObj("EnemyView")
	enemy_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.scoiety_enemy_view:SetInstance(obj)
		self.scoiety_enemy_view:FlushEnemyView()
	end)

	--邮件面板
	self.scoiety_mail_view = ScoietyMailView.New()
	self.mail_content = self:FindObj("GetMailView")
	self.mail_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.scoiety_mail_view:SetInstance(obj)
		-- self.scoiety_mail_view:Flush()
	end)

	--写邮件面板
	self.write_mail_content = self:FindObj("WriteMailView")
	self.write_mail_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.write_mail_view = WriteMailView.New(obj)
		local send_mail_name = ScoietyData.Instance:GetSendName()
		self.write_mail_view:SetFriendName(send_mail_name)
	end)

	--监听事件
	self:ListenEvent("Close",BindTool.Bind(self.HandleClose, self))
	self.tabteam.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.society_team))
	self.tabfriend.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.society_friend))
	self.tabenemy.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.society_enemy))
	self.tabmail.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.society_mail))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Scoiety, BindTool.Bind(self.GetUiCallBack, self))

	self.red_point_list = {
		[RemindName.ScoietyFriend] = self:FindVariable("CanSendGift"),
		[RemindName.ScoietyMail] = self:FindVariable("HaveMail"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:Flush()
end

function ScoietyView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ScoietyView:OnToggleChange(index, ison)
	ScoietyCtrl.Instance:MailGetListReq()
	if ison and self.show_index ~= index then
		if index == TabIndex.society_team then
			ScoietyData.Instance:SetSendName("")
			self.show_index = index
			if self.scoiety_team_view then
				self.scoiety_team_view:FlushTeamView()
			end
		elseif index == TabIndex.society_friend then
			ScoietyData.Instance:SetSendName("")
			self.show_index = index
			if self.scoiety_friend_view then
				--self.scoiety_friend_view:FlushFriendView()
				self.scoiety_friend_view:Flush()
			end
		elseif index == TabIndex.society_enemy then
			ScoietyData.Instance:SetSendName("")
			self.show_index = index
			if self.scoiety_enemy_view then
				self.scoiety_enemy_view:FlushEnemyView()
			end
		elseif index == TabIndex.society_mail then
			ScoietyData.Instance:SetSendName("")
			ScoietyData.Instance:DelMailDetail()
			self.show_index = index
			if self.scoiety_mail_view then
				self.scoiety_mail_view:Flush()
			end	
		end
	end
end

function ScoietyView:HandleClose()
	self:Close()
end

function ScoietyView:CloseCallBack()
	if self.show_index == TabIndex.write_mail then
		self.show_index = TabIndex.society_mail
	end
	if self.scoiety_friend_view then
		self.scoiety_friend_view:CloseFriendView()
	end

	if self.scoiety_enemy_view then
		self.scoiety_enemy_view:CloseEnemyView()
	end

	if self.scoiety_mail_view then
		ScoietyData.Instance:DelMailDetail()
		self.scoiety_mail_view:CloseMailView()
	end

	-- if self.write_mail_view then
	-- 	self.write_mail_view:CloseWriteMailView()
	-- end
end

function ScoietyView:ShowIndexCallBack(index)
	if index == TabIndex.society_team then
		self.tabteam.toggle.isOn = true
	elseif index == TabIndex.society_friend then
		self.tabfriend.toggle.isOn = true
	elseif index == TabIndex.society_enemy then
		self.tabenemy.toggle.isOn = true
	elseif index == TabIndex.society_mail then
		self.tabmail.toggle.isOn = true
	-- elseif index == TabIndex.write_mail then
	-- 	self.is_write = true
	-- 	self.tabmail.toggle.isOn = true
	end
	self:Flush()
end

function ScoietyView:OpenCallBack()
	-- if self.tabteam.toggle.isOn then
	-- 	self.show_index = TabIndex.society_team
	-- 	if self.scoiety_team_view then
	-- 		self.scoiety_team_view:FlushTeamView()
	-- 	end
	-- elseif self.tabfriend.toggle.isOn then
	-- 	self.show_index = TabIndex.society_friend
	-- 	-- ScoietyCtrl.Instance:FriendInfoReq()
	-- 	if self.scoiety_friend_view then
	-- 		self.scoiety_friend_view:FlushFriendView()
	-- 	end
	-- elseif self.tabenemy.toggle.isOn then
	-- 	self.show_index = TabIndex.society_enemy
	-- 	-- ScoietyCtrl.Instance:FriendInfoReq()
	-- 	if self.scoiety_enemy_view then
	-- 		self.scoiety_enemy_view:FlushEnemyView()
	-- 	end
	-- elseif self.tabmail.toggle.isOn then
	-- 	self.show_index = TabIndex.society_mail
	-- 	if self.scoiety_mail_view then
	-- 		self.scoiety_mail_view:FlushMailView()
	-- 	end
	-- end
	-- self:Flush()
	ScoietyCtrl.Instance:MailGetListReq()
end

function ScoietyView:ShowWriteMailView()
	local send_mail_name = ScoietyData.Instance:GetSendName()
	if self.mail_content then
		self.mail_content:SetActive(false)
	end
	if self.write_mail_content then
		self.write_mail_content:SetActive(true)
	end
	if self.write_mail_view then
		self.write_mail_view:SetFriendName(send_mail_name)
	end
end

function ScoietyView:ShowMailView()
	if self.mail_content then
		self.mail_content:SetActive(true)
	end
	if self.write_mail_content then
		self.write_mail_content:SetActive(false)
	end
end

function ScoietyView:FlushMailLeft()
	if self.scoiety_mail_view then
		self.scoiety_mail_view:FlushLeft()
	end
end

function ScoietyView:OnFlush(param_t)
	-- --设置邮件红点
	-- local is_all_read = ScoietyData.Instance:IsAllRead()
	-- self.show_red_point:SetValue(not is_all_read)

	for k,v in pairs(param_t) do
		if k == "all" then
			if self.tabteam.toggle.isOn then
				if self.scoiety_team_view then
					self.scoiety_team_view:Flush()
				end
			elseif self.tabfriend.toggle.isOn then
				if self.scoiety_friend_view then
					self.scoiety_friend_view:Flush()
				end
			elseif self.tabenemy.toggle.isOn then
				if self.scoiety_enemy_view then
					self.scoiety_enemy_view:Flush()
				end
			elseif self.tabmail.toggle.isOn then
				if self.scoiety_mail_view then
					--删除残留信息
					self.scoiety_mail_view:Flush()
				end
			end
		elseif k == "team" and self.tabteam.toggle.isOn then
			if self.scoiety_team_view then
				self.scoiety_team_view:Flush()
			end
		elseif k == "wltx" then
			if not ScoietyData.Instance:GetTeamState() then
				ScoietyCtrl.Instance:ShowNearTeamView()
			end
		elseif k == "friend" and self.tabfriend.toggle.isOn then
			if self.scoiety_friend_view then
				self.scoiety_friend_view:Flush()
			end
		elseif k == "enemy" and self.tabenemy.toggle.isOn then
			if self.scoiety_enemy_view then
				self.scoiety_enemy_view:Flush()
			end
		elseif self.tabmail.toggle.isOn then
			if k == "mail_left" then
				if self.scoiety_mail_view then
					self.scoiety_mail_view:FlushLeft()
				end
			elseif k == "mail_right" then
				if self.scoiety_mail_view then
					self.scoiety_mail_view:FlushRight()
				end
			end
		end
	end
end

function ScoietyView:ChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.society_team then
		self.tabteam.toggle.isOn = true
	elseif index == TabIndex.society_friend then
		self.tabfriend.toggle.isOn = true
	elseif index == TabIndex.society_enemy then
		self.tabenemy.toggle.isOn = true
	elseif index == TabIndex.society_mail then
		self.tabmail.toggle.isOn = true
	end
	self:Flush()
end

function ScoietyView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.society_friend then
			if self.tabfriend.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.ChangeToggle, self, TabIndex.society_friend)
				return self.tabfriend, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end