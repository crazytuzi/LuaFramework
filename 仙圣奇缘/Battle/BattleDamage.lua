--------------------------------------------------------------------------------------
-- 文件名:	BattleDamage.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	统计战斗中对怪物方造成的所有伤害
-- 应  用:  本例子是用类对象的方式实
---------------------------------------------------------------------------------------

BattleDamage = class("BattleDamage")
BattleDamage.__index = BattleDamage

function BattleDamage:ctor()
	self.nDamage = 0
end

function BattleDamage:resetBattleDamage()
	self.nDamage = 0
end

function BattleDamage:TotalDamage(damage)
	if damage == nil or damage < 0 then return false end

	self.nDamage = self.nDamage + damage

end

function BattleDamage:GetDamage()
	return self.nDamage
end


function BattleDamage:setBattleResultDate(tbMsg)
	self.battle_result = nil
	if tbMsg.battle_result._listener_for_children.dirty then
		self.battle_result = tbMsg.battle_result
	end

	self.small_pass_rsp = nil
	if tbMsg.small_pass_rsp._listener_for_children.dirty then
		self.small_pass_rsp = tbMsg.small_pass_rsp
	end

	self.star_box = nil
	if tbMsg.star_box._listener_for_children.dirty then
		self.star_box = tbMsg.star_box
	end
end


function BattleDamage:SendBattleResultDate()
	local bRequest = true 
	if self.battle_result then
		local msg = zone_pb.BattleResultNotify(self.battle_result)

		if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Battle") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
		--为了防止战斗胜利界面出不来，连续向服务端发两次保存
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Battle") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
		g_BattleMgr:recvBattleResult(self.battle_result)
		self.battle_result = nil
		bRequest = false
	end


	if self.small_pass_rsp then
		g_Hero:setBattleRespone(self.small_pass_rsp)
		g_EctypeListSystem:SetSingleEctypeInfo(self.small_pass_rsp)
		self.small_pass_rsp = nil
		bRequest = false
	end

	if self.star_box then
		g_EctypeListSystem:ClientRespondStarBox(self.star_box)
		self.star_box = nil
		bRequest = false
	end

	return bRequest
end


----------------------------
g_BattleDamage = BattleDamage.new()