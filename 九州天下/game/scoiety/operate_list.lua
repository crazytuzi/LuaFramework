OperateListView = OperateListView or BaseClass(BaseView)

local HeightMax = 400						--最大高度

function OperateListView:__init()
	self.ui_config = {"uis/views/scoietyview", "ListDetail"}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.cell_height = 0
	self.list_spacing = 0
end

function OperateListView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	self.click_obj = nil

	-- 清理变量和对象
	self.panel = nil
	self.left = nil
	self.right = nil
	self.top = nil
	self.bottom = nil
	self.scroller = nil
	self.frame = nil
end

function OperateListView:LoadCallBack()
	--获取UI
	self.panel = self:FindObj("Panel")
	self.left = self:FindObj("Left")
	self.right = self:FindObj("Right")
	self.top = self:FindObj("Top")
	self.bottom = self:FindObj("Bottom")
	self.frame = self:FindObj("Frame")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("ButtonList")
	local scroller_delegate = self.scroller.list_simple_delegate

	self.cell_height = scroller_delegate:GetCellViewSize(self.scroller.scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.list_spacing = self.scroller.scroller.spacing										--间距

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local detail_cell = self.cell_list[cell]
		if detail_cell == nil then
			detail_cell = ScrollerDetailCell.New(cell.gameObject, self)
			detail_cell.list_detail_view = self
			self.cell_list[cell] = detail_cell
		end

		detail_cell:SetIndex(data_index)
		detail_cell:SetData(self.scroller_data[data_index])
	end
end

function OperateListView:CloseWindow()
	self:Close()
end

function OperateListView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.role_name = ""

	self.click_obj = nil

	if not self.root_node then
		return
	end

	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height

	self.left.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Right, 0, width)
	self.right.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, 0, height)
	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, 0, height)
	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)
	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end

	self.is_left = nil
end

function OperateListView:SetRoleName(name)
	self.role_name = name
end

function OperateListView:SetCloseCallBack(callback)
	self.close_call_back = callback
end

function OperateListView:SetIsLeft(is_left)
	self.is_left = is_left
end

function OperateListView:OpenCallBack()
	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.role_id)
	if self.frame ~= nil then
		if self.is_left then
			self.frame.transform.localPosition = Vector3(-249, 0, 0)
		else
			self.frame.transform.localPosition = Vector3(0, 0, 0)
		end
	end

	self:ChangeBlock()
	self:FlushView()
end

-- 是否屏蔽某些按钮
function OperateListView:ChangeData(role_info, data, open_type)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for i = #data, 1, -1 do
		local remove = false
		if data[i].style == "recall_post" then
			if open_type ~= ScoietyData.DetailType.CampKing then
				remove = true
			end
		elseif data[i].style == "chat" then
			-- if not ScoietyData.Instance:IsFriend(role_info.role_name) then
				-- remove = true
			-- if tonumber(role_info.is_online) == 0 then
			-- 	remove = true
			if open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			elseif open_type == ScoietyData.DetailType.RecallPost then
				remove = true
			end
		elseif data[i].style == "trade" then 											--交易
			if tonumber(role_info.is_online) == 0 then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
			--remove = true
		elseif data[i].style == "sit_mount" then
			if open_type ~= ScoietyData.DetailType.Default then
				remove = true
			elseif main_vo.multi_mount_res_id == nil or main_vo.multi_mount_res_id < 0 then
				remove = true
			else
				local role = Scene.Instance:GetObjByUId(role_info.role_id)
				if nil == role or role:IsDead() then
					remove = true
				end
			end

		elseif data[i].style == "team" then
			-- if tonumber(role_info.is_online) == 0 then
			-- 	remove = true
			if ScoietyData.Instance:GetTeamState() then
				if ScoietyData.Instance:IsTeamMember(role_info.role_id) then
					remove = true
				elseif not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
					remove = true
				elseif role_info.camp ~= main_vo.camp then
					remove = true
				end
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif role_info.camp ~= main_vo.camp then
				remove = true
			end
		elseif data[i].style == "kickout_team" then
			if not ScoietyData.Instance:GetTeamState() then
				remove = true
			elseif not ScoietyData.Instance:IsTeamMember(role_info.role_id) then
				remove = true
			elseif not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "give_leader" then
			-- if tonumber(role_info.is_online) == 0 then
			-- 	remove = true
			if not ScoietyData.Instance:GetTeamState() then
				remove = true
			elseif not ScoietyData.Instance:IsTeamMember(role_info.role_id) then
				remove = true
			elseif not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "guild_invite" then
			-- if tonumber(role_info.is_online) == 0 then
			-- 	remove = true
			if not GuildData.Instance:GetInvitePower() then
				remove = true
			elseif GuildData.Instance:GetGuildPost(role_info.role_id) > 0 then
				remove = true
			end
		elseif data[i].style == "flower" then
			-- if tonumber(role_info.is_online) == 0 then
			-- 	remove = true
			if open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "addfriend" then
			if ScoietyData.Instance:IsFriend(role_info.role_name) then
				remove = true
			elseif tonumber(role_info.is_online) == 0 then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "delete" then
			if not ScoietyData.Instance:IsFriend(role_info.role_name) then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif role_info.role_id == main_vo.lover_uid then
				remove = true
			end
		elseif data[i].style == "delenemy" then
			if open_type ~= ScoietyData.DetailType.EnemyType then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "trace" then
			-- if tonumber(role_info.is_online) == 0 then
			-- 	remove = true
			-- if open_type == ScoietyData.DetailType.CrossTeam then
			-- 	remove = true
			-- end
			remove = true
		elseif data[i].style == "kickout" then
			if open_type ~= ScoietyData.DetailType.Guild and open_type ~= ScoietyData.DetailType.GuildTuanZhang then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "change_leader_cross" then
			if open_type ~= ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "info" then
			if open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "black" then
			if open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			elseif role_info.role_id == main_vo.lover_uid then
				remove = true
			elseif ScoietyData.Instance:IsFriend(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "remove_black" then
			if not ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "mail" then
			-- if open_type == ScoietyData.DetailType.CrossTeam then
			-- 	remove = true
			-- elseif not ScoietyData.Instance:IsFriend(role_info.role_name) then
			-- 	remove = true
			-- end
			remove = true
		elseif data[i].style == "change_post" then
			if open_type ~= ScoietyData.DetailType.Guild and open_type ~= ScoietyData.DetailType.GuildTuanZhang then
				remove = true
			end
		elseif data[i].style == "transfer_hui_zhang" then
			if open_type ~= ScoietyData.DetailType.GuildTuanZhang then
				remove = true
			end
		end
		if remove then
			table.remove(data, i)
		end
	end
end

function OperateListView:SetClickObj(obj)
	self.click_obj = obj
end

function OperateListView:ChangeBlock()
	if not self.click_obj or IsNil(self.click_obj.rect) then
		return
	end
	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.click_obj.rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

	--计算高亮框的位置
	local height = self.left.rect.rect.height
	local width = self.left.rect.rect.width

	local click_rect = self.click_obj.rect.rect
	local btn_height = click_rect.height
	local btn_width = click_rect.width
	local pos_x = local_pos_tbl.x
	local pos_y = local_pos_tbl.y

	local left_width = width/2 + pos_x - btn_width/2
	local right_width = width/2 - (pos_x + btn_width/2)
	local top_height = height/2 - (pos_y + btn_height/2)
	local bottom_height = height/2 + pos_y - btn_height/2

	self.left.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Right, width - left_width, left_width)
	self.right.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, width - right_width, right_width)

	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, height - top_height, top_height)
	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, left_width, btn_width)

	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, height - bottom_height, bottom_height)
	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, left_width, btn_width)
end

--改变列表长度
function OperateListView:ChangePanelHeight(item_count)
	local panel_Width = self.panel.rect.rect.width
	local panel_height = self.cell_height * item_count + self.list_spacing * (item_count - 1) + 40			--20是listview和底框的间距和
	if panel_height > HeightMax then
		panel_height = HeightMax
	end
	self.panel.rect.sizeDelta = Vector2(panel_Width, panel_height)
end

function OperateListView:FlushView()
	local open_type = ScoietyData.Instance:GetOpenDetailType()
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	local data = TableCopy(ScoietyData.DetailData)
	if next(role_info) then
		self:ChangeData(role_info, data, open_type)
	end
	data.stranger_chat = self.stranger_chat
	local item_count = #data or 0
	self:ChangePanelHeight(item_count)
	self.scroller_data = data
	self.scroller.scroller:ReloadData(0)
end

function OperateListView:RoleInfoCallBack(role_id,protocol)
	self.stranger_chat = bit:d2b(protocol.stranger_chat)
end

----------------------------------------------------------------------------
--ScrollerDetailCell 		列表滚动条格子
----------------------------------------------------------------------------

ScrollerDetailCell = ScrollerDetailCell or BaseClass(BaseCell)

function ScrollerDetailCell:__init(instance, parent)
	self.parent = parent
	self.list_detail_view = nil
	self.text = self:FindVariable("Text")
	self:ListenEvent("Click",BindTool.Bind(self.OnButtonClick, self))
end

function ScrollerDetailCell:__delete()
	self.list_detail_view = nil	
	self.parent = nil
end

function ScrollerDetailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.text:SetValue(self.data.name)
end

function ScrollerDetailCell:OnButtonClick()
	self.list_detail_view:Close()
	local style = self.data.style
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	if not next(role_info) then
		return
	end
	local flag = true
	if style == "recall_post" then					-- 罢免官职
		if role_info.role_id > 0 then
			local des = string.format(Language.Camp.IsBaMianPost, role_info.role_name)
			TipsCtrl.Instance:ShowCommonAutoView(nil, des, function ()
				CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_REMOVE_OFFICER, role_info.role_id)
			end)
		end
	elseif style == "chat" then						-- 私聊
		--对方离线
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end

		local limit_level = COMMON_CONSTS.PRIVATE_CHAT_LEVEL_LIMIT
		local spid = GLOBAL_CONFIG.package_info.config.agent_id
		local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").chat_limit
		if agent_cfg ~= nil then
			for k,v in pairs(agent_cfg) do
				if v.spid == spid then
					if v["day_" .. open_day] ~= nil then
						limit_level = v["day_" .. open_day]
					else
						if v.def_day then
							limit_level = v.def_day
						end
					end

					break
				end
			end
		end

		-- 判断等级是否足够
		if GameVoManager.Instance:GetMainRoleVo().level < limit_level and PlayerData.Instance:GetTotalChongZhi() < COMMON_CONSTS.PRIVATE_CHAT_CHONGZHI then
			local level_str = PlayerData.GetLevelString(limit_level)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelSiLiao, limit_level))
			return
		end
		--拒绝好友聊天	1为拒绝聊天
		-- if self.parent.stranger_chat[32-CLIENT_SETTING_TYPE.CLIENT_SETTING_TYPE_REFUSE_SINGLE_CHAT] and self.parent.stranger_chat[32-CLIENT_SETTING_TYPE.CLIENT_SETTING_TYPE_REFUSE_SINGLE_CHAT] == 1 then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RejectChat)
		-- 	return
		-- end	
		flag = false
		local private_obj = {}
		if nil == ChatData.Instance:GetPrivateObjByRoleId(role_info.role_id) then
			private_obj = ChatData.CreatePrivateObj()
			private_obj.role_id = role_info.role_id
			private_obj.guildname = role_info.guild_name
			private_obj.username = role_info.role_name
			private_obj.sex = role_info.sex
			private_obj.camp = role_info.camp
			private_obj.prof = role_info.prof
			private_obj.avatar_key_small = role_info.avatar_key_small
			private_obj.level = role_info.level
			ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
		end
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RejectChat)
		ChatData.Instance:SetCurrentRoleId(role_info.role_id)



		-- if ViewManager.Instance:IsOpen(ViewName.Chat) then
		-- 	ChatCtrl.Instance.view:ChangeToIndex(TabIndex.chat_private)
		-- else
		-- 	ViewManager.Instance:Open(ViewName.Chat, TabIndex.chat_private)
		-- end
		if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
			ViewManager.Instance:FlushView(ViewName.ChatGuild, "new_chat", {true})
		else
			ViewManager.Instance:Open(ViewName.ChatGuild)
		end
		-- ViewManager.Instance:Close(ViewName.Chat)
	elseif style == "trade" then				-- 交易
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		-- 暂时屏蔽交易
		AvatarManager.Instance:SetAvatarKey(role_info.role_id, role_info.avatar_key_big, role_info.avatar_key_small)
		TradeCtrl.Instance:SendTradeRouteReq(role_info.role_id)

	elseif style == "info" then
		if role_info.role_id ~= 0 then
			CheckData.Instance:SetCurrentUserId(role_info.role_id)
			CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.role_id)
			ViewManager.Instance:Open(ViewName.CheckEquip)
		end
	elseif style == "mail" then					-- 发送邮件
		-- ScoietyData.Instance:SetSendName(role_info.role_name)
		-- if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
		-- 	ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.write_mail)
		-- else
		-- 	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.write_mail)
		-- end

	elseif style == "team" then					-- 组队邀请
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		if not ScoietyData.Instance:GetTeamState() then
			if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
				ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.society_team)
			else
				ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
			end
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 2
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(role_info.role_id)

	elseif style == "kickout_team" then					-- 请出队伍
		local function ok_func()
			ScoietyCtrl.Instance:KickOutOfTeamReq(role_info.role_id)
		end
		local des = string.format(Language.Society.KickOutTeam, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("kick_out_of_team", des, ok_func)

	elseif style == "give_leader" then					-- 移交队长
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		local function ok_func()
			ScoietyCtrl.Instance:ChangeTeamLeaderReq(role_info.role_id)
		end
		local des = string.format(Language.Society.ChangeLeader, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
 
	elseif style == "guild_invite" then				-- 公会邀请
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		local role_camp = GameVoManager.Instance:GetMainRoleVo().camp
		local other_role_camp = role_info.camp
		if role_camp == other_role_camp then
			GuildCtrl.Instance:SendInviteGuildReq(role_info.role_id)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Guild.DifferCamp)
		end
	elseif style == "flower" then				-- 赠送鲜花
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		FlowersCtrl.Instance:SetFriendInfo(role_info)
		ViewManager.Instance:Open(ViewName.Flowers)

	elseif style == "black" then				-- 黑名单
		local function yes_func()
			ScoietyCtrl.Instance:AddBlackReq(role_info.role_id)
		end

		local describe = string.format(Language.Society.AddBlackDes, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("society_add_black", describe, yes_func)
	elseif style == "remove_black" then			-- 移除黑名单
		local function yes_func()
			ScoietyCtrl.Instance:DeleteBlackReq(role_info.role_id)
		end
		local describe = string.format(Language.Society.DeleteBlackDes, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)

	elseif style == "addfriend" then			-- 添加好友
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		ScoietyCtrl.Instance:AddFriendReq(role_info.role_id)

	elseif style == "delete" then				-- 删除好友
		local function yes_func()
			ScoietyCtrl.Instance:DeleteFriend(role_info.role_id)
		end

		local describe = string.format(Language.Society.DelFriendDes, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)

	elseif style == "delenemy" then				-- 删除仇人
		ScoietyCtrl.Instance:EnemyDeleteReq(role_info.role_id)

	elseif style == "trace" then				-- 追踪
		if role_info.is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		--当前场景无法传送
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type ~= SceneType.Common then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end

		local function ok_func()
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local need_item_data = ShopData.Instance:GetShopItemCfg(27582)
			if not need_item_data then
				return
			end
			local item_num = ItemData.Instance:GetItemNumInBagById(27582)
			if main_vo.gold < need_item_data.gold then
				--元宝不足
				TipsCtrl.Instance:ShowLackDiamondView()
				return
			elseif item_num <= 0 then
				--材料不足，弹出购买
				local function close_call_back()
					PlayerCtrl.Instance:SendSeekRoleWhere(role_info.role_name or "")
				end
				--TipsCtrl.Instance:ShowShopView(27582, 2, close_call_back)
				local func = function(stuff_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
				end
				TipsCtrl.Instance:ShowCommonBuyView(func, 27582, nil, 1)
			else
				PlayerCtrl.Instance:SendSeekRoleWhere(role_info.role_name or "")
			end
		end

		local str = string.format(Language.Role.TraceConfirm, role_info.role_name or "")
		TipsCtrl.Instance:ShowCommonAutoView("", str, ok_func)

	elseif style == "kickout" then
		GuildCtrl.Instance:OnClickKickout(role_info.role_id,role_info.role_name)

	elseif style == "change_leader_cross" then
		KuaFuFuBenCtrl.Instance:ChangeLeader(role_info.role_name)

	elseif style == "change_post" then
		TipsCtrl.Instance:ShowTipsGuildTransferView(role_info.role_id, role_info.role_name)

	elseif style == "transfer_hui_zhang" then
		GuildCtrl.Instance:OnClickTransfer(role_info.role_id,role_info.role_name)
	elseif style == "sit_mount" then
		MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_INVITE_RIDE, role_info.role_id)
	end
	if flag then
		-- ViewManager.Instance:Close(ViewName.Chat)
	end
end