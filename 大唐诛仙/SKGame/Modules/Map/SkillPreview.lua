SkillPreview =BaseClass()

function SkillPreview:__init()
	self.previewMapping = {}
	self.curShow = nil

	self:Init()
end 

function SkillPreview:Init()
	self:LoadSkillPreview()
	self:AddEvents()
end

function SkillPreview:AddEvents()
	self.handler=GlobalDispatcher:AddEventListener(EventName.ResetSkillManagerComplete, function ( data )
		self:UpadteSkillPreview(data)
	end)
end

function SkillPreview:RemoveEvents()
	GlobalDispatcher:RemoveEventListener(self.handler)
end

function SkillPreview:UpadteSkillPreview(data)
	local oldSkillId = data.oldSkillId
	local newSkillId = data.newSkillId

	local oldPreview = self.previewMapping[oldSkillId]
	if oldPreview then
	   oldPreview:Destroy()
	   oldPreview = nil
	   self.previewMapping[oldSkillId] = nil
	end
	
	local skillVo = SkillManager.GetSkillVo(newSkillId)
	if skillVo then
		local preview = SpBase.GenerateSkillPromptBySkillVo(skillVo)
		if preview then
			preview:Init()
		end
		self.previewMapping[skillVo.un32SkillID] = preview
	else
		error("【施法表现初始化】：技能 "..newSkillId.." 不存在，初始化失败")
	end
end

function SkillPreview:LoadSkillPreview()
	local skillIDlist = SkillModel:GetInstance():GetSkillByType(2)
	for i = 1, #skillIDlist do
		local skillVo = SkillManager.GetSkillVo(skillIDlist[i])
		if skillVo then
			local preview = SpBase.GenerateSkillPromptBySkillVo(skillVo)
			if preview then
				preview:Init()
			end
			self.previewMapping[skillVo.un32SkillID] = preview
		else
			error("【施法表现初始化】：技能 "..skillIDlist[i].." 不存在，初始化失败")
		end
	end
end

function SkillPreview:IsShowing(skillId)
	if self.curShow and self.curShow:GetId() == skillId then
		return true
	else
		return false
	end
end

function SkillPreview:GetSkillPre(skillId)
	return self.previewMapping[skillId]
end

function SkillPreview:ShowSkillPre(skillId)
	if self.previewMapping[skillId] then
		local preView = self.previewMapping[skillId]
		preView:Show()
		self.curShow = preView
	else
		-- print("技能【"..skillId.."】，不存在施法表现.....")
	end
end

function SkillPreview:HideSkillPre()
	if self.curShow then
		self.curShow:Reset()
		self.curShow:Hide()
		self.curShow = nil
	end
end

function SkillPreview:Update()
	if self.curShow then
		self.curShow:Update()
	end
end

function SkillPreview:__delete()
	self:RemoveEvents()

	for key, value in pairs(self.previewMapping) do 
		value:Destroy()
	end  

	self.previewMapping = nil
	self.curShow = nil
end

