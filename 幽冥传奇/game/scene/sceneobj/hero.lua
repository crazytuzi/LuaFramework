Hero = Hero or BaseClass(Role)

function Hero:__init()
	self.obj_type = SceneObjType.Hero
	self.is_show_name = false
end

function Hero:__delete()

end

function Hero:LoadInfoFromVo()
	Role.LoadInfoFromVo(self)
	self:SetIsNotMaskModel(not Scene.Instance:IsPingbiHero())
end	

function Hero:CreateBoard()
	if self.name and self.name ~= "" then
		self:SetNameBoard(HeroNameBoard.New())
		self:UpdateNameBoard()
	end
	self:SetHpBoardVisible(true)
	self:SetTitleLayerVisible(false)
end

function Hero:UpdateInnerBoardPercent()
end

function Hero:UpdateNameBoard()
	if self.name_board then
		self.name_board:SetHeroNameVo(self.vo, self.logic_pos.x, self.logic_pos.y)
	end
end

function Hero:CanClick()
	local ower_id = Scene.Instance:GetMainRole():GetObjId()
    return self.vo.owner_obj_id ~= ower_id and Role.CanClick(self)
end


function Hero:SetAttr(index, value)
	if index == OBJ_ATTR.ACTOR_PK_MODE then
		self.vo[OBJ_ATTR.ACTOR_EFFECTAPPEARANCE] = value
		self:UpdateResId()
		self:RefreshAnimation()
		return
	end	

	Role.SetAttr(self,index, value)
end	

function Hero:AppendMainAction(actionType,real_pos,life,logic_pos,action,dir)
	if actionType == ActionType.Move 
		or actionType == ActionType.Atk
		or actionType == ActionType.Spell then

		if self.action_type == ActionType.AtkWait then
			self.sync_end_time = 0	
			self.concat_action_list = {}
			self.action_type = ActionType.Unknown
		end
	end	
	Character.AppendMainAction(self,actionType,real_pos,life,logic_pos,action,dir)
end

function Hero:DoAtk(real_pos,life,dir)
	Character.DoAtk(self,real_pos,life,dir)
	if #self.main_action_list < 1 then
		self.cur_attack_wait = 1
		self:AppendConcatAction(ActionType.AtkWait,nil,self.cur_attack_wait)
	end
	
end	

function Hero:DoSpell(real_pos,life,action,dir)
	Character.DoSpell(self,real_pos,life,action,dir)
	if #self.main_action_list < 1 then
		self.cur_attack_wait = 1
		self:AppendConcatAction(ActionType.AtkWait,nil,self.cur_attack_wait)
	end
	
end	

function Hero:GetAtkSpeed()
	return Character.GetAtkSpeed(self) * 0.6
end	

function Hero:GetRealAtkSpeed(speed)
	return self:GetAtkSpeed()
end	


function Hero:SetNameLayerShow(is_show_name)
	self.is_show_name = is_show_name
	if is_show_name then
		if nil == self.name_board then
			self:CreateBoard()
		end
		self.name_board:SetVisible(true)
	elseif self.name_board then
		self.name_board:SetVisible(true)
	end
end

--取消选中
function Hero:CancelSelect()
	Role.CancelSelect(self)
	if nil ~= self.name_board  and not self.is_show_name then
		self.name_board:SetVisible(true)
	end
end

function Hero:OnClick()
	Role.OnClick(self)
	if nil ~= self.name_board then
		self.name_board:SetVisible(true)
	end
end

function Hero:UpdateZoneInfo()
	if nil == HandleGameMapHandler:GetGameMap() then
		return
	end

	local area_info = Scene.Instance:GetCurAreaInfo()
	if not area_info.attr_t[MapAreaAttribute.aaCrossMonster] then
		HandleGameMapHandler:GetGameMap():resetZoneInfo(self.old_logic_pos.x, self.old_logic_pos.y)
		HandleGameMapHandler:GetGameMap():setZoneInfo(self.logic_pos.x, self.logic_pos.y, ZoneType.DynamicNotMoveCoord)	
	end
end	

function Hero:DoDead()
	Character.DoDead(self)
end	

function Hero:GetCharMoveSpeed()
	return Character.GetCharMoveSpeed(self) - 15
end

	
function Hero:DoMove(real_pos,life,logic_pos)
	Character.DoMove(self,real_pos,life,logic_pos)
end	

function Hero:EndMove()
end	

function Hero:CheckGhost()
end