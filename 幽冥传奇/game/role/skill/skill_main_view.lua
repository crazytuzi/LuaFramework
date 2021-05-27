------------------------------------------------------------
-- 技能 主View
------------------------------------------------------------
SkillMainView = SkillMainView or BaseClass(BaseView)

function SkillMainView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_skill")
	
	self.texture_path_list[1] = "res/xui/zhanjiang.png"
	self.texture_path_list[2] = "res/xui/role.png"
	self.texture_path_list[3] = "res/xui/wing.png"

	self.btn_info = {
		ViewDef.Skill.SkillShow,		
		ViewDef.Skill.SelectSkill,
	}

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	require("scripts/game/role/skill/skill_view").New(ViewDef.Skill.SkillShow)
	require("scripts/game/role/skill/role_selectskill_view").New(ViewDef.Skill.SelectSkill)
end


function SkillMainView:__delete()
end

function SkillMainView:ReleaseCallBack()
end

function SkillMainView:LoadCallBack(index, loaded_times)	
	-- if index == TabIndex.zhanjiang_zhanjiang then
	-- 	self:SkillMainView()
	-- elseif index == TabIndex.zhanjiang_ronghun then
	-- 	self:InitRonghunView()
	-- end

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(- 10, 0)
	self.tabbar:SetClickItemValidFunc(function(index)
		return ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end)
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, nil, name_list, true, ResPath.GetCommon("toggle_110"), 25, true)	
end

function SkillMainView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- if ZhanjiangData.Instance:IsActivatedSucc() then
	-- 	ZhanjiangCtrl.GetHeroesList()
	-- 	ZhanjiangCtrl.GetHeroExpReq()
	-- end
	-- RemindManager.Instance:DoRemind(RemindName.ZhanjiangCanEquip)
end

function SkillMainView:ShowIndexCallBack(index)	
	self:Flush(index)
end

function SkillMainView:OnFlush(param_t, index)
	-- if index == TabIndex.zhanjiang_zhanjiang then
	-- 	self:OnFlushZhanjiang(param_t)
	-- elseif index == TabIndex.zhanjiang_ronghun then
	-- 	self:OnFlushRonghun(param_t)
	-- end
end

function SkillMainView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end