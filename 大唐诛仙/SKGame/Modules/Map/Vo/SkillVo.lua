-- 技能vo
SkillVo =BaseClass()

--模型数据配置名
SkillVo.GroupCfgName = "skill_NextSkillEffectCfg"	--组效果表格配置名

--模型数据配置名
SkillVo.ModelCfgName =
{
	BufCfg = "skill_SSkillModelBufCfg",				--buf表格配置名
	EmitCfg = "skill_SSkillModelEmitCfg",			--发射表格配置名
	MoveCfg = "skill_SSkillModelMoveCfg",		 	--移动表格配置名
	RangeCfg = "skill_SSkillModelRangeCfg",  		--范围表格配置名
	SwitchCfg = "skill_SSkillModelSwitchCfg",	 	--匹配表格配置名
	SummonCfg  = "skill_SSkillModuleSummonCfg",		--召唤表格配置名
	AccountCfg = "skill_SSkillModelAccountCfg",		--结算表格配置名
}

--modelvo作为属性时的变量名
SkillVo.ModelType =
{
	BufModel = 10,			--buf模块
	EmitModel = 2,			--发射模块
	MoveModel = 6,		 	--移动模块
	RangeModel = 3,  		--范围模块
	SwitchModel = 7,	 	--匹配模块
	SummonModel  = 4,		--召唤模块
	AccountModel = 1,		--结算模块
}

function SkillVo:__init(skillId)
	local skillCfgVo = GetCfgData( "skill_CellNewSkillCfg" ):Get(skillId)
	if skillCfgVo == nil then 
		error("SkillVo Init Fail, The SkillId Is "..skillId)
		return 
	end

	for k, v in pairs(skillCfgVo) do
		self[k] = v
	end

	self.distance = 30000

	self.dependModelList = {}
	for i = 1, #self.asSkillModelList do
		self:SetModelVoById(self.asSkillModelList[i], nil, self)
	end
end

--设置模型Vo
--@param id			 模型id
--@param modelType	  模型类型
--@param beAttributeTo	ModelVo作为属性添加到的对象
function SkillVo:SetModelVoById(id, modelType, beAttributeTo)
	local modelVo = SkillManager.GetModelVoById(id)
	if modelVo ~= nil then
 		modelVo.dependModelList = {}
 		table.insert(beAttributeTo.dependModelList, modelVo)
		for i = 1, #modelVo.asSkillModelList do
			self:SetModelVoById(modelVo.asSkillModelList[i], modelVo.eSkillModelType, modelVo)
		end
	else
		if modelType then
			error("ModelVo init fail, the modelVo is "..id..", "..modelType)
		else
			error("ModelVo init fail, the modelVo is "..id)
		end
	end
end

--获取范围模块vo
function SkillVo:GetRangeModelVo()
	return self:GetModelVoByType(self, SkillVo.ModelType.RangeModel)
end

--获取结算模块vo
function SkillVo:GetAccountModelVo()
	return self:GetModelVoByType(self, SkillVo.ModelType.AccountModel)
end

--获取model数据
--@param source	  dependModelList源
--@param modelType   模型类型
function SkillVo:GetModelVoByType(source, modelType)
	local dependModelList = source.dependModelList
	local modelVo = nil
	for i = 1, #dependModelList do
		modelVo = dependModelList[i]
		if modelVo.eSkillModelType == modelType then
			return modelVo
		end
	end
	if #source.dependModelList > 0 then
		for i = 1, #dependModelList do
			return self:GetModelVoByType(source.dependModelList[i], modelType)
		end
	end
	return nil
end
