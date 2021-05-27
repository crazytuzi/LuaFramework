require("scripts/game/herowing/herowing_data")
require("scripts/game/herowing/herowing_view")

HeroWingCtrl = HeroWingCtrl or BaseClass(BaseController)

function HeroWingCtrl:__init()
	if HeroWingCtrl.Instance then
		ErrorLog("[HeroWingCtrl]:Attempt to create singleton twice!")
	end
	HeroWingCtrl.Instance = self
	self.view = HeroWingView.New(ViewName.HeroWing)
	self.data = HeroWingData.New()
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	RoleData.Instance:NotifyAttrChange(BindTool.Bind1(self.RoleDataChangeCallback, self))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnPassShopDay, self))
end

function HeroWingCtrl:__delete()
    HeroWingCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	

end
function HeroWingCtrl:RegisterAllProtocols()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetHeroWingNum, self), RemindName.HeroWing)
end
function HeroWingCtrl:OnRecvMainRoleInfo()
	local n_title_act_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_HEROSWING))
	self.data:SetTilteActList(n_title_act_t)
	self.view:Flush()
	RemindManager.Instance:DoRemind(RemindName.HeroWing)
end

function HeroWingCtrl:OnPassShopDay()
	RemindManager.Instance:DoRemind(RemindName.HeroWing)
end
function HeroWingCtrl:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_HEROSWING then
		local n_title_act_t = bit:d2b(value)
		self.data:SetTilteActList(n_title_act_t)
		self.view:Flush()
		RemindManager.Instance:DoRemind(RemindName.HeroWing)
	elseif key == OBJ_ATTR.ACTOR_USING_HERO_SWING then
		self.data:ChangeDress(value)
		self.view:Flush()
	elseif key == OBJ_ATTR.ACTOR_VIP_GRADE  or key == OBJ_ATTR.CREATURE_LEVEL then	
		RemindManager.Instance:DoRemind(RemindName.HeroWing)
	end
end	
-- 请求激活英雄翅膀(返回 44 11)
function HeroWingCtrl:HeroActivateReq(hero_wing_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroWingActivateReq)
	protocol.hero_wing_id = hero_wing_id
	protocol:EncodeAndSend()
end

--(c->s)设置英雄翅膀（战神）状态(返回 44 12, 出战时还返回44 11)
function HeroWingCtrl:SetHeroStateReq(hero_wing_id, hero_wing_state)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetHeroWingStateReq)
	protocol.hero_wing_id = hero_wing_id
	protocol.hero_wing_state = hero_wing_state
	protocol:EncodeAndSend()
end
function HeroWingCtrl:GetHeroWingNum(remind_name)
	if remind_name == RemindName.HeroWing then
	  return self.data:GetHeroWingRemindNum()
	end
end








