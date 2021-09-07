-- 图标单独加载

-- 图标类型 同一种类型图标只能统一使用一种加载方式
SingleIconType = {
    Item = "Item"
    ,Honor = "Honor"
    ,MianUI = "MianUI"
    ,SkillIcon = "SkillIcon"
    ,Pet = "Pet"
    ,Other = "Other"
}

SingleIconManager = SingleIconManager or BaseClass()

function SingleIconManager:__init()
	if SingleIconManager.Instance then
		return
	end
	SingleIconManager.Instance = self
    self.pool = SingleIconPool.New()

    self.loaders = {}
end

function SingleIconManager:__delete()
    self.pool:DeleteMe()
    self.pool = nil
end

function SingleIconManager:OnTick()
	self.pool:OnTick()
end

function SingleIconManager:GetSprite(iconType, iconId, callback)
    self.pool:GetSprite(iconType, iconId, callback)
end

function SingleIconManager:DecreaseReferenceCount(iconType, iconId)
    self.pool:DecreaseReferenceCount(iconType, iconId)
end