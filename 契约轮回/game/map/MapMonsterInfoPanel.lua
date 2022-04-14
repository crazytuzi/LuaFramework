--
-- @Author: LaoY
-- @Date:   2018-11-29 15:09:58
--
MapMonsterInfoPanel = MapMonsterInfoPanel or class("MapMonsterInfoPanel",BasePanel)
local MapMonsterInfoPanel = MapMonsterInfoPanel

function MapMonsterInfoPanel:ctor()
	self.abName = "map"
	self.assetName = "MapMonsterInfoPanel"
	self.layer = "UI"

	self.use_background = false
	self.click_bg_close = false
	self.change_scene_close = true
end

function MapMonsterInfoPanel:dctor()
end

function MapMonsterInfoPanel:Open(monster_id,x,y)
	self.monster_id = monster_id
	if x and y then
		self.pos = {x = x,y = y}
	end
	if self.is_loaded then
		self:UpdatePos()
	end
	MapMonsterInfoPanel.super.Open(self)
end

function MapMonsterInfoPanel:LoadCallBack()
	self.nodes = {
		"bg/text_des","bg/text_lv","bg/text_def","bg"
	}
	self:GetChildren(self.nodes)
	self.text_des_component = self.text_des:GetComponent('Text')
	self.text_lv_component = self.text_lv:GetComponent('Text')
	self.text_def_component = self.text_def:GetComponent('Text')
	
	self:UpdatePos()
	self:AddEvent()
end

function MapMonsterInfoPanel:AddEvent()

end

function MapMonsterInfoPanel:UpdatePos()
	local w = GetSizeDeltaX(self.bg)
	local h = GetSizeDeltaY(self.bg)
	if self.pos then
		local offset_x = self.pos.x > 1 and -w*0.45 or w*0.45
		local offset_y = self.pos.y > 0 and -h*0.45 or h*0.45
		offset_x = offset_x*0.01
		offset_y = offset_y*0.01
		SetGlobalPosition(self.bg, self.pos.x + offset_x, self.pos.y + offset_y, 0)
	end
end

function MapMonsterInfoPanel:OpenCallBack()
	self:UpdateView()
end

function MapMonsterInfoPanel:UpdateView( )
	if not self.monster_id then
		return
	end
	local map_monster_config = DailyModel:GetInstance():GetHookConfigByid(self.monster_id)
	local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	
	local lv_str
	if map_monster_config.level < role_data.level then
		lv_str = string.format("Minimum level recommended：<color=#0cb44a>%s</color>",map_monster_config.level)
	else
		lv_str = string.format("Minimum level recommended：<color=#dd190c>%s</color>",map_monster_config.level)
	end
	self.text_lv_component.text = lv_str

	local def_str
	if map_monster_config.defend < role_data.attr.def then
		def_str = string.format("Recommended defense：<color=#0cb44a>%s</color>",map_monster_config.defend)
	else
		def_str = string.format("Recommended defense：<color=#dd190c>%s</color>",map_monster_config.defend)
	end
	self.text_def_component.text = def_str

	self.text_des_component.text = map_monster_config.des
end

function MapMonsterInfoPanel:CloseCallBack(  )

end