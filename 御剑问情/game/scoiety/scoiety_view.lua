require("game/scoiety/scoiety_team_view")
require("game/scoiety/scoiety_friend_view")
require("game/scoiety/scoiety_enemy_view")
require("game/scoiety/scoiety_mail_view")
-- require("game/scoiety/write_mail_view")


ScoietyView = ScoietyView or BaseClass(BaseView)
function ScoietyView:__init()
    self.ui_config = {"uis/views/scoietyview_prefab", "ScoietyView"}
    self.play_audio = true
    self.is_async_load = false
    self.is_check_reduce_mem = true
    -- self.full_screen = true
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

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
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

	self.team_content = nil
	self.friend_content = nil
	self.enemy_content = nil
	self.mail_content = nil
end

function ScoietyView:LoadCallBack()
	self.have_mail = self:FindVariable("HaveMail")
	self.can_send_gift = self:FindVariable("CanSendGift")

	--获取UI
	self.tabteam = self:FindObj("TabTeam")
	self.tabfriend = self:FindObj("TabFriend")
	self.tabenemy = self:FindObj("TabEnemy")
	self.tabmail = self:FindObj("TabMail")

	--组队面板
	self.team_content = self:FindObj("TeamView")

	--好友面板
	self.friend_content = self:FindObj("FriendView")

	--仇人面板
	self.enemy_content = self:FindObj("EnemyView")

	--邮件面板
	self.mail_content = self:FindObj("GetMailView")

	--监听事件
	self:ListenEvent("Close",BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("ClickFriend",BindTool.Bind(self.ClickFriend, self))
	self:ListenEvent("ClickTeam",BindTool.Bind(self.ClickTeam, self))
	self:ListenEvent("ClickMail",BindTool.Bind(self.ClickMail, self))
	self:ListenEvent("ClickEnemy",BindTool.Bind(self.ClickEnemy, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Scoiety, BindTool.Bind(self.GetUiCallBack, self))

	self.red_point_list = {
		[RemindName.ScoietyFriend] = self:FindVariable("CanSendGift"),
		[RemindName.ScoietyMail] = self:FindVariable("HaveMail"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function ScoietyView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ScoietyView:HandleClose()
	self:Close()
end

function ScoietyView:ClickFriend()
	self:ShowIndex(TabIndex.society_friend)
end

function ScoietyView:ClickTeam()
	self:ShowIndex(TabIndex.society_team)
end

function ScoietyView:ClickMail()
	self:ShowIndex(TabIndex.society_mail)
end

function ScoietyView:ClickEnemy()
	self:ShowIndex(TabIndex.society_enemy)
end

function ScoietyView:CloseCallBack()
	if self.scoiety_friend_view then
		self.scoiety_friend_view:CloseFriendView()
	end

	if self.scoiety_enemy_view then
		self.scoiety_enemy_view:CloseEnemyView()
	end

	if self.scoiety_mail_view then
		self.scoiety_mail_view:CloseMailView()
	end

	-- if self.write_mail_view then
	-- 	self.write_mail_view:CloseWriteMailView()
	-- end
end

function ScoietyView:InitPanel(index)
	if index == TabIndex.society_team and not self.scoiety_team_view then
		UtilU3d.PrefabLoad("uis/views/scoietyview_prefab", "TeamContentView",
			function(obj)
				obj.transform:SetParent(self.team_content.transform, false)
				obj = U3DObject(obj)
				self.scoiety_team_view = ScoietyTeamView.New(obj)
				self.scoiety_team_view:FlushTeamView()
			end)
	elseif index == TabIndex.society_friend and not self.scoiety_friend_view then
		UtilU3d.PrefabLoad("uis/views/scoietyview_prefab", "FriendContentView",
			function(obj)
				obj.transform:SetParent(self.friend_content.transform, false)
				obj = U3DObject(obj)
				self.scoiety_friend_view = ScoietyFriendView.New(obj)
				--引导用按钮
				self.friend_lot_add = self.scoiety_friend_view.friend_lot_add
				self.scoiety_friend_view:FlushFriendView()
			end)
	elseif index == TabIndex.society_enemy and not self.scoiety_enemy_view then
		UtilU3d.PrefabLoad("uis/views/scoietyview_prefab", "EnemyContentView",
			function(obj)
				obj.transform:SetParent(self.enemy_content.transform, false)
				obj = U3DObject(obj)
				self.scoiety_enemy_view = ScoietyEnemyView.New(obj)
				self.scoiety_enemy_view:FlushEnemyView()
			end)
	elseif index == TabIndex.society_mail and not self.scoiety_mail_view then
		UtilU3d.PrefabLoad("uis/views/scoietyview_prefab", "GetMailView",
			function(obj)
				obj.transform:SetParent(self.mail_content.transform, false)
				obj = U3DObject(obj)
				self.scoiety_mail_view = ScoietyMailView.New(obj)
				self.scoiety_mail_view:FlushMailView()
			end)
	end
end

function ScoietyView:ShowIndex(index)
	if IS_ON_CROSSSERVER then
		if index ~= TabIndex.society_team then
			index = TabIndex.society_team
			BaseView.ShowIndex(self, index)
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
			return
		end
	end
	BaseView.ShowIndex(self, index)
end

function ScoietyView:ShowIndexCallBack(index)
	self:InitPanel(index)
	if index == TabIndex.society_team then
		self.tabteam.toggle.isOn = true
		if self.scoiety_team_view then
			self.scoiety_team_view:FlushTeamView()
		end
	elseif index == TabIndex.society_friend then
		self.tabfriend.toggle.isOn = true
		if self.scoiety_friend_view then
			self.scoiety_friend_view:FlushFriendView()
		end
	elseif index == TabIndex.society_enemy then
		self.tabenemy.toggle.isOn = true
		if self.scoiety_enemy_view then
			self.scoiety_enemy_view:FlushEnemyView()
		end
	elseif index == TabIndex.society_mail then
		self.tabmail.toggle.isOn = true
		if self.scoiety_mail_view then
			self.scoiety_mail_view:FlushMailView()
		end
	-- elseif index == TabIndex.write_mail then
	-- 	ScoietyData.Instance:SetSendName("")
	-- 	self.is_write = true
	-- 	self.tabmail.toggle.isOn = true
	else
		--默认选中标签
		self:ShowIndex(TabIndex.society_friend)
	end
end

function ScoietyView:OpenCallBack()

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
	for k,v in pairs(param_t) do
		if k == "team" and self.tabteam.toggle.isOn then
			if self.scoiety_team_view then
				self.scoiety_team_view:FlushTeamView()
			end
		elseif k == "wltx" then
			if not ScoietyData.Instance:GetTeamState() then
				ScoietyCtrl.Instance:ShowNearTeamView()
			end
		elseif k == "friend" and self.tabfriend.toggle.isOn then
			if self.scoiety_friend_view then
				self.scoiety_friend_view:FlushFriendView()
			end
		elseif k == "enemy" and self.tabenemy.toggle.isOn then
			if self.scoiety_enemy_view then
				self.scoiety_enemy_view:FlushEnemyView()
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
	if index == TabIndex.society_friend then
		self.tabfriend.toggle.isOn = true
	end
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