DisplayMonster = DisplayMonster or BaseClass(Monster)

function DisplayMonster:__init()
	self.obj_type = SceneObjType.DisplayMonster
end

function DisplayMonster:__delete()
end

function DisplayMonster:CanClick()
    return false
end

--取消选中
function DisplayMonster:CancelSelect()
end

function DisplayMonster:OnClick()
end

function DisplayMonster:SetNameLayerShow(is_show_name)
	if nil == self.name_board then
		self:CreateBoard()
	end
	self.name_board:SetVisible(true)
end

function DisplayMonster:UpdateZoneInfo()
end	

function DisplayMonster:SetHpBoardVisible(is_visible)
end	
