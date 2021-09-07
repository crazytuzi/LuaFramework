require("game/element_battle/element_battle_data")
require("game/element_battle/element_battle_fight_view")

ElementBattleCtrl = ElementBattleCtrl or  BaseClass(BaseController)

function ElementBattleCtrl:__init()
	if ElementBattleCtrl.Instance ~= nil then
		print_error("[ElementBattleCtrl] attempt to create singleton twice!")
		return
	end
	ElementBattleCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = ElementBattleData.New()
	self.element_fight_veiw = ElementBattleFightView.New(ViewName.ElementBattleFightView)
end

function ElementBattleCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.element_fight_veiw ~= nil then
		self.element_fight_veiw:DeleteMe()
		self.element_fight_veiw = nil
	end

	ElementBattleCtrl.Instance = nil
end

function ElementBattleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCQunXianLuanDouUserInfo, "OnQunXianLuanDouUserInfo")
	self:RegisterProtocol(SCQunXianLuanDouRankInfo, "OnQunXianLuanDouRankInfo")
	self:RegisterProtocol(SCQunXianLuanDouSideInfo, "OnQunXianLuanDouSideInfo")
	self:RegisterProtocol(SCQunxianluandouLianzhanChange, "OnQunxianluandouLianzhanChange")
	self:RegisterProtocol(SCQunXianLuanDouRewardResult, "OnQunXianLuanDouRewardResult")
end

function ElementBattleCtrl:OnQunXianLuanDouRewardResult(protocol)
	self.data:SetRewardResultInfo(protocol)
	-- 结束
	local rewards = protocol.item_list
	local score_list = {}
	score_list.num = protocol.daily_chestshop_score or 0
	local temp_list = {reward_list = {}}
	for i = 1, protocol.item_count do
		local item = rewards[i]
		if item and item.item_id > 0 then
			table.insert(temp_list.reward_list, item)
		end
	end
	TipsCtrl.Instance:OpenActivityRewardTip(temp_list, score_list)
end

function ElementBattleCtrl:OnQunXianLuanDouUserInfo(protocol) 			--三界战场 用户信息
	self.data:SetBaseInfo(protocol.data)
	local special_param = ElementBattleData.GetKillToSpecial(protocol.data.side, protocol.data.lianzhan)
	Scene.Instance:GetMainRole():SetAttr("special_param", special_param)
	self.element_fight_veiw:Flush("info")
end

function ElementBattleCtrl:OnQunXianLuanDouRankInfo(protocol) 			--三界战场 排行榜信息
	self.data:SetRankInfo(protocol.data)
	self.element_fight_veiw:Flush("rank")
	
	ActivityCtrl.Instance:GetDetailView():Flush()						-- 刷新元素战场排行界面
end

function ElementBattleCtrl:OnQunXianLuanDouSideInfo(protocol) 			--三界战场 阵营信息
	self.data:SetSideInfo(protocol.data)
	self.element_fight_veiw:Flush("info")
end

function ElementBattleCtrl:OnQunxianluandouLianzhanChange(protocol) 		--
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if nil ~= obj then
		local side = ElementBattleData.GetSpecialToSide(obj:GetVo().special_param)
		obj:SetAttr("special_param", ElementBattleData.GetKillToSpecial(side, protocol.lianzhan))
	end
end

function ElementBattleCtrl:GetData()
	return self.data
end
