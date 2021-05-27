require("scripts/game/wangchengzhengba/imperial_city_competite_page")
require("scripts/game/wangchengzhengba/imperial_city_competite_info_page")
require("scripts/game/wangchengzhengba/imperial_city_competite_rules_page")

ImperialCityCompetiView = ImperialCityCompetiView or BaseClass(XuiBaseView)
function ImperialCityCompetiView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.imperial_city_competite
	self.texture_path_list[1] = "res/xui/wangchengzhengba.png"
	self.texture_path_list[2] = "res/xui/invest_plan.png"
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"imperial_city_competite_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"imperial_city_competite_ui_cfg", 2, {TabIndex.imperial_city_competite}},
		{"imperial_city_competite_ui_cfg", 3, {TabIndex.imperial_city_act_info}},
		{"imperial_city_competite_ui_cfg", 4, {TabIndex.imperial_city_rules}},
		
	}
	self.title_img_path = ResPath.GetWangChengZhengBa("title_bg")
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.imperial_city_competite] = ImperialCityCompetitePage.New()
	self.page_list[TabIndex.imperial_city_act_info] = ImperialCityActInfoPage.New()
	self.page_list[TabIndex.imperial_city_rules] = ImperialCityRulesPage.New()
end

function ImperialCityCompetiView:__delete()

end

function ImperialCityCompetiView:ReleaseCallBack()
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end
end

function ImperialCityCompetiView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		WangChengZhengBaCtrl.Instance:GetWCZBMsg()
	end
	if nil == self.page_list[index] then return end
	--初始化页面接口
	self.page_list[index]:InitPage(self)
end

function ImperialCityCompetiView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ImperialCityCompetiView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ImperialCityCompetiView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新相应界面
function ImperialCityCompetiView:OnFlush(flush_param_t, index)
	for k,v in pairs(flush_param_t) do
		if k == "all" then
			if nil ~= self.page_list[index] then
				--更新页面接口
				self.page_list[index]:UpdateData(flush_param_t)
			end
		end
	end
end
