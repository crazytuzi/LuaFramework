require("game/red_name/red_name_view")
require("game/red_name/red_name_data")

RedNameCtrl = RedNameCtrl or BaseClass(BaseController)
function RedNameCtrl:__init()
	if RedNameCtrl.Instance then
		print_error("[RedNameCtrl] Attemp to create a singleton twice !")
	end
	RedNameCtrl.Instance = self
	self.red_name_data = RedNameData.New()
	self.red_name_view = RedNameView.New(ViewName.RedNameView)
end

function RedNameCtrl:__delete()
	RedNameCtrl.Instance = nil
	if self.red_name_view then
		self.red_name_view:DeleteMe()
		self.red_name_view = nil
	end
	if self.red_name_data then
		self.red_name_data:DeleteMe()
		self.red_name_data = nil
	end
end
--设置是否不再显示罪恶值面板图标
function RedNameCtrl:SetNoMoreOpen(value)
	self.red_name_data:SetNoMoreOpen(value)
end

--询问玩家是否不再显示罪恶值面板图标
function RedNameCtrl:AskNoMoreOpenMessageBox()
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Common.NoMoreOpen, function()
		self:SetNoMoreOpen(true)
		ViewManager.Instance:FlushView(ViewName.Main, "red_name")
	end)
end

--获取当前罪恶值所减少的HP和攻击力
function RedNameCtrl:GetReducePercentHpAndGongji()
	local cfg = self.red_name_data:GetRedNameCfg()
	local evil = PlayerData.Instance:GetAttr("evil")
	local last_hp = 0
	local last_gongji = 0
	for k,v in pairs(cfg) do
		if evil < v.evil then 
			return last_hp, last_gongji
		end
		last_hp = v.reduce_percent_hp
		last_gongji = v.reduce_percent_gongji
	end
	return last_hp, last_gongji
end