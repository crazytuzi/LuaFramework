ShengXiaoSkillView = ShengXiaoSkillView or BaseClass(BaseView)

function ShengXiaoSkillView:__init()
	self.ui_config = {"uis/views/shengeview", "ShengXiaoSkill"}
	self.view_layer = UiLayer.Pop
	self.chapter = 0
end

function ShengXiaoSkillView:__delete()

end

function ShengXiaoSkillView:ReleaseCallBack()
	self.chapter = 0
	self.skill_path = nil
	self.name = nil
	self.desc = nil
	self.state = nil
	self.cap = nil
end

function ShengXiaoSkillView:LoadCallBack()
		self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
		self.skill_path = self:FindVariable("skill_path")
		self.name = self:FindVariable("name")
		self.desc = self:FindVariable("desc")
		self.state = self:FindVariable("state")
		self.cap = self:FindVariable("cap")
		self:Flush()
end

function ShengXiaoSkillView:OpenCallBack()
	self:Flush()
end

function ShengXiaoSkillView:SetChapter(chapter)
	self.chapter = chapter
	self:Open()
end

function ShengXiaoSkillView:OnFlush()
	if self.chapter > 5 then return end
	local cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.chapter)
	self.skill_path:SetAsset(ResPath.GetShengXiaoSkillIcon(self.chapter))
	local max_chapter = ShengXiaoData.Instance:GetMaxChapter()
	self.name:SetValue(cfg.skill)
	self.desc:SetValue(cfg.describe)
	local total_cap = ShengXiaoData.Instance:GetChapterTotalCap()
	self.cap:SetValue(total_cap * cfg.per_attr / 100)
	if self.chapter < max_chapter then
		self.state:SetValue(Language.ShengXiao.HasActive)
	else
		self.state:SetValue(ShengXiaoData.Instance:GetMaxChapterActive() and Language.ShengXiao.HasActive or Language.ShengXiao.NoActive)
	end
end

function ShengXiaoSkillView:CloseWindow()
	self:Close()
end