MilitaryRankItem = MilitaryRankItem or BaseClass(BaseCell)
function MilitaryRankItem:__init(instance, parent)
	self.parent = parent

	self.name = self:FindVariable("name")
	self.show_hl = self:FindVariable("show_hl")
	self.cur_level = self:FindVariable("CurLevel")
	self.is_active = self:FindVariable("IsActive")
	self.active=self:FindVariable("Active")
	self.can_up = self:FindVariable("CanUp")
	self.head_icon = self:FindVariable("HeadIcon")
	self.gray_icon = self:FindVariable("GrayIcon")
	self:ListenEvent("OnClick", BindTool.Bind1(self.OnClickCell, self))
end

function MilitaryRankItem:__delete()
	self.parent = nil
	self.name = nil
	self.show_hl = nil
	self.cur_level = nil
	self.is_active= nil
	self.active= nil	
	self.can_up = nil
	self.head_icon = nil
	self.gray_icon = nil
end

function MilitaryRankItem:OnFlush()
	if self.data == nil or not next(self.data) then 
		return 
	end
	self.name:SetValue(self.data.name)
	self.head_icon:SetAsset(ResPath.GetMilitaryRankImage("head_icon_" .. self.index))
	self.gray_icon:SetAsset(ResPath.GetMilitaryRankImage("gray_icon_" .. self.index))
	self.parent:FlushAllHl()
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	if self.index == #MilitaryRankData.Instance:GetLevelCfg() and cur_level >= self.index then
		self.cur_level:SetValue(true)
	else
		self.cur_level:SetValue(cur_level == self.index)
	end
	self.active:SetValue(cur_level < self.index)
	self.is_active:SetValue(true)
	local cur_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(self.index)
	if cur_cfg then
		local cur_honor = MilitaryRankData.Instance:GetCurJunGong()
		local cur_level = MilitaryRankData.Instance:GetCurLevel()
		if cur_level + 1 == self.index and cur_honor >= cur_cfg.need_jungong then
			self.can_up:SetValue(true)
		else
			self.can_up:SetValue(false)
		end
	else
		self.can_up:SetValue(false)
	end
end

function MilitaryRankItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MilitaryRankItem:OnClickCell()
	-- local show_level = MilitaryRankData.Instance:GetCurLevel() + 1
	-- if show_level < self.index then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.CanNotShow)
	-- 	return 
	-- end
	self.parent:SetSelectIndex(self.index)
	self.parent:FlushAllHl()
end

function MilitaryRankItem:FlushHl()
	local cur_index = self.parent:GetSelectIndex()
	self.show_hl:SetValue(cur_index == self.index)
end