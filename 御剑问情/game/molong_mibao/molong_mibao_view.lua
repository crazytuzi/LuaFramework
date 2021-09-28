require("game/molong_mibao/molong_mibao_chapter_view")
MolongMibaoView = MolongMibaoView or BaseClass(BaseView)

function MolongMibaoView:__init()
	self.def_index = 1
	self.ui_config = {"uis/views/molongmibao_prefab","MolongMibao"}
	self.play_audio = true
end

function MolongMibaoView:__delete()

end

function MolongMibaoView:LoadCallBack()
	self.chapter_view = MolongMibaoChapterView.New(self:FindObj("ChapterView"))
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
end

function MolongMibaoView:ReleaseCallBack()
	if self.chapter_view then
		self.chapter_view:DeleteMe()
		self.chapter_view = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	-- 清理变量和对象
end

function MolongMibaoView:OpenCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("molongmibao_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	end
	self.chapter_view:OpenCallBack()
	self:Flush()
end

function MolongMibaoView:ShowIndexCallBack(index)

end

function MolongMibaoView:CloseCallBack()

end

function MolongMibaoView:OnFlush(param_t)
	self.chapter_view:Flush()
end