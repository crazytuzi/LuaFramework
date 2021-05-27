require("scripts/game/redenvelopes/redenvelopes_data")
require("scripts/game/redenvelopes/redenvelopes_view")
require("scripts/game/redenvelopes/loser_view")
RedEnvelopesCtrl = RedEnvelopesCtrl or BaseClass(BaseController)

function RedEnvelopesCtrl:__init()
	if RedEnvelopesCtrl.Instance then
		ErrorLog("[RedEnvelopesCtrl]:Attempt to create singleton twice!")
	end
	RedEnvelopesCtrl.Instance = self

	self.data = RedEnvelopesData.New()
	self.redenvelopesview = RedEnvelopesView.New(ViewName.RedEnvelopes)
	self.loserview = LoserView.New(ViewName.Loser)
	self:RegisterAllProtocols()
	self:RegisterAllRemind()
end

function RedEnvelopesCtrl:__delete()
	if self.redenvelopesview ~=nil then
		self.redenvelopesview:DeleteMe()
		self.redenvelopesview = nil
	end

	if self.loserview ~=nil then
		self.loserview:DeleteMe()
		self.loserview = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

    RedEnvelopesCtrl.Instance = nil
end

function RedEnvelopesCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRedEnvelopes, "OnRedEnvelopes")
	RoleData.Instance:NotifyAttrChange(BindTool.Bind(self.OnRoleAttrChange, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.InitRedEnvelopes, self))
end

function RedEnvelopesCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.RedEnvelopes)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.Loser)
end

function RedEnvelopesCtrl:InitRedEnvelopes()
	RedEnvelopesCtrl.Instance:RedEnvelopesReq(1, 1)
	RedEnvelopesCtrl.Instance:RedEnvelopesReq(2, 1)
end

function RedEnvelopesCtrl:DataChangeCallBack()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	--天降红包图标
	if self.data:GetOpenLevel(ViewName.RedEnvelopes) > role_level or self.data:IsRedAllPickUp() then
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.RED_ENVELOPES, 0)
	else
		self.redenvelopesIcon = MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.RED_ENVELOPES, 1, function()
			self.redenvelopesview:Open()
			self.redenvelopesIcon:RemoveIconEffect()
		end)
		if nil ~= self.redenvelopesIcon then
			self.redenvelopesIcon:SetBottomPath(ResPath.GetMainui("tip_16_word"), 10)
			if self:GetRemindNum(RemindName.RedEnvelopes) and self:GetRemindNum(RemindName.RedEnvelopes) > 0 then
				local anim_size = self.redenvelopesIcon:GetContentSize()
				-- self.redenvelopesIcon:PlayIconEffect(924, anim_pos or {x = anim_size.width / 2, y = anim_size.height / 2}, nil, 0.7)
			end 
		end
		ViewManager.Instance:FlushView(ViewName.RedEnvelopes)
	end
	
	--屌丝逆袭图标
	if self.data:GetOpenLevel(ViewName.Loser) > role_level or self.data:IsLoserAllPickUp() then
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.LOSER, 0)
	else
		self.LoserIcon = MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.LOSER, 1, function()
			self.loserview:Open()
			self.LoserIcon:RemoveIconEffect()
		end)
		if self.LoserIcon and self:GetRemindNum(RemindName.Loser) and self:GetRemindNum(RemindName.Loser) > 0 then
			local anim_size = self.LoserIcon:GetContentSize()
			self.LoserIcon:PlayIconEffect(924, anim_pos or {x = anim_size.width / 2, y = anim_size.height / 2}, nil, 0.7)
		end 
		ViewManager.Instance:FlushView(ViewName.Loser)
	end
	
	RemindManager.Instance:DoRemind(RemindName.RedEnvelopes)
	RemindManager.Instance:DoRemind(RemindName.Loser)
end

function RedEnvelopesCtrl:OnRoleAttrChange(key, value, old_value)
	if old_value >= value then
		return
	end

	if key == OBJ_ATTR.CREATURE_LEVEL or OBJ_ATTR.ACTOR_BATTLE_POWER then
		self:DataChangeCallBack()
	end
end

function RedEnvelopesCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.RedEnvelopes then
		return self.data:GetRedEnvelopesRemindNum() or 0
	elseif remind_name == RemindName.Loser then
		return self.data:GetLoserRemindNum() or 0
	end
end

function RedEnvelopesCtrl:OnRedEnvelopes(protocol)
	if self.data:GetRedEnvelopesSign() == nil or self.data:GetLoserSign() == nil then
		self.data:SetSign(protocol)
		ViewManager.Instance:FlushView(ViewName.RedEnvelopes, 0, "all")
		ViewManager.Instance:FlushView(ViewName.Loser, 0, "all")
	elseif 1 == protocol.view_type then                --天降红包
		if self.data:GetRedEnvelopesSign() ~= protocol.sign then
			local act_index = self.data:GetActIndex()
			 self.data:SetSign(protocol)
			 if self.redenvelopesIcon then
				-- self.redenvelopesIcon:RemoveIconEffect()
			end
	 		ViewManager.Instance:FlushView(ViewName.RedEnvelopes, 0, "showAnim", {index = act_index})
		end
	elseif 2 == protocol.view_type then                --屌丝逆袭
		if self.data:GetLoserSign() ~= protocol.sign then
			local act_index = self.data:GetActIndex()
			 self.data:SetSign(protocol)
			 if self.LoserIcon then
				self.LoserIcon:RemoveIconEffect()
			end
	 		ViewManager.Instance:FlushView(ViewName.Loser, 0, "showAnim", {index = act_index})
		end
	end
	self:DataChangeCallBack()
end

function RedEnvelopesCtrl:RedEnvelopesReq(view_type, act_type, act_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendRedEnvelopesReq)
	protocol.view_type = view_type or 0
	protocol.type = act_type or 0
	protocol.act_index = act_index or 0
	protocol:EncodeAndSend()
end