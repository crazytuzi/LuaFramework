SpiritChooseModelView = SpiritChooseModelView or BaseClass(BaseView)

local SPIRIT_EXP_MODEL = {
	SIMPLE = 0,
	DIFFICULTY = 1,
	PURGATORY = 2,	
}

function SpiritChooseModelView:__init(instance)
	self.ui_config = {"uis/views/spiritview_prefab","ChooseModelView"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.select_type = nil
end

function SpiritChooseModelView:__delete()
end

function SpiritChooseModelView:ReleaseCallBack()
	self.simple_model = nil
	self.difficulty_model = nil

	self.select_type = nil
end

function SpiritChooseModelView:LoadCallBack()
	self.simple_model = self:FindObj("SimpleRender")
	self.difficulty_model = self:FindObj("DifficultyRender")

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OpenExplere", BindTool.Bind(self.OpenExplere, self))

	self:ListenEvent("ChooseSimple", BindTool.Bind2(self.ChooseSimple, self))
	self:ListenEvent("ChooseDifficulty", BindTool.Bind2(self.ChooseDifficulty, self))
	self:ListenEvent("ChoosePurgatory", BindTool.Bind2(self.ChoosePurgatory, self))
end

function SpiritChooseModelView:OpenCallBack()
end

function SpiritChooseModelView:CloseCallBack()
end

function SpiritChooseModelView:ChooseSimple()
	SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_SELECT_MODE, SPIRIT_EXP_MODEL.SIMPLE)
	self:Close()
end

function SpiritChooseModelView:ChooseDifficulty()
	SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_SELECT_MODE, SPIRIT_EXP_MODEL.DIFFICULTY)
	self:Close()
end

function SpiritChooseModelView:ChoosePurgatory()
	SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_SELECT_MODE, SPIRIT_EXP_MODEL.PURGATORY)
	self:Close()
end

function SpiritChooseModelView:OnClickModel(model_type)
	self.select_type = model_type
end

function SpiritChooseModelView:OnClickClose()
	self:Close()
end

function SpiritChooseModelView:OpenExplere()
	if self.select_type ~= nil then
		-- SpiritData.Instance:SetSpiritExpModel(self.select_type)
		-- ViewManager.Instance:Open(ViewName.SpiritExploreView, nil, "all", {choose_model = self.select_type})
		-- self:Close()
		SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_SELECT_MODE, self.select_type)
		self:Close()
	end
end

function SpiritChooseModelView:OnFlush(param_t)
end


