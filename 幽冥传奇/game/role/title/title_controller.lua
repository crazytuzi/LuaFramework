require("scripts/game/role/title/title_data")
require("scripts/game/role/title/title_new")
--------------------------------------------------------------
--角色称号
--------------------------------------------------------------
TitleCtrl = TitleCtrl or BaseClass(BaseController)
function TitleCtrl:__init()
	if TitleCtrl.Instance then
		ErrorLog("[TitleCtrl] Attemp to create a singleton twice !")
	end
	TitleCtrl.Instance = self

	self.title_data = TitleData.New()
	self.new_title_t = {}
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	RoleData.Instance:NotifyAttrChange(BindTool.Bind1(self.RoleDataChangeCallback, self))
end

function TitleCtrl:__delete()
	self.title_data:DeleteMe()
	self.title_data = nil

	for k,v in pairs(self.new_title_t) do
		v:DeleteMe()
	end
	self.new_title_t = {}
	
	TitleCtrl.Instance = nil
end

function TitleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTitle, "OnTitle")
	self:RegisterProtocol(SCAchieveAddTitle, "OnAchieveAddTitle")
	self:RegisterProtocol(SCAchieveLoseTitle, "OnAchieveLoseTitle")
	self:RegisterProtocol(SCTimeLimitTitleInfo, "OnTimeLimitTitleInfo")
end

function TitleCtrl:OnRecvMainRoleInfo()
	self.get_main_role_info_time =Status.NowTime
	TitleCtrl.SendTitleInfoReq()
end

function TitleCtrl:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_HEAD_TITLE or key == OBJ_ATTR.ACTOR_CURTITLE then
		local title_act_t = self.title_data:GetTilteActList()
		local act_flag_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURTITLE))
		local act_flag_ex_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_HEAD_TITLE))
		local n_title_act_t = {}
		-- 1 - 32
		for i = 1, 32 do
			n_title_act_t[33 - i] = act_flag_t[i]
		end
		-- 33 - 64
		for i = 1, 32 do
			n_title_act_t[32 + 33 - i] = act_flag_ex_t[i]
		end

		self.title_data:SetTilteActList(n_title_act_t)
		ViewManager.Instance:FlushView(ViewName.Role, {TabIndex.role_ls_title, TabIndex.role_yj_title})
		if Status.NowTime < self.get_main_role_info_time + 3 then
			return 
		end

		for k, v in pairs(n_title_act_t) do
			if v == 1 and (title_act_t[k] == nil or title_act_t[k] == 0) and TITLE_CLIENT_CONFIG[k] then
				local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
				local title_1 = bit:_and(head_title, 0x000000ff)
				local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
				if title_1 == 0 then
					title_1 = k
				else
					title_2 = k
				end
				
				if title_1 == 29 or title_1 == 30 or title_2 == 29 or title_2 == 30 
					or title_1 == 16 or title_2 == 16 or title_2 == 28 or title_1 == 28 then
					self.SendTitleSelectReq(title_1, title_2)
				else
					local new_title = TitleNewView.New()
					new_title:SetDataOpen(k)
					table.insert(self.new_title_t, new_title)
				end
			end
		end
	elseif key == OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE then
		self.title_data:SortTitle()
		ViewManager.Instance:FlushView(ViewName.Role, {TabIndex.role_ls_title, TabIndex.role_yj_title})
	end
end

local title_data_first_rec = true
function TitleCtrl:OnTitle(protocol)
	self.title_data:SetTitleInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Role, {TabIndex.role_ls_title, TabIndex.role_yj_title})

	if title_data_first_rec then
		GlobalEventSystem:Fire(MainRoleDataInitEventType.TITLE_DATA)
		title_data_first_rec = false
	end
end

function TitleCtrl:OnAchieveAddTitle(protocol)
	self.title_data:SetTitleOverTime(protocol.title_id, protocol.over_time)
end

function TitleCtrl:OnAchieveLoseTitle(protocol)
	self.title_data:SetTitleOverTime(protocol.title_id, -1)
end

-- 限时称号时间
function TitleCtrl:OnTimeLimitTitleInfo(protocol)
	self.title_data:SetTitleOverTime(protocol.title_id, protocol.over_time)
end

-- 称号title请求
function TitleCtrl.SendTitleReq(req_type, title1, title2)
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSTitleReq)
	-- protocol.information_id = req_type
	-- protocol.title1 = title1 or 0
	-- protocol.title2 = title2 or 0
	-- protocol:EncodeAndSend()
end

-- 请求称号信息
function TitleCtrl.SendTitleInfoReq()
	TitleCtrl.SendTitleReq(TITLE_REQ.INFO)
end

-- 选择称号
function TitleCtrl.SendTitleSelectReq(title1, title2)
	TitleCtrl.SendTitleReq(TITLE_REQ.SELECT, title1, title2)
end