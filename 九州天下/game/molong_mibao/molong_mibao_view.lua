require("game/molong_mibao/molong_mibao_chapter_view")
MolongMibaoView = MolongMibaoView or BaseClass(BaseView)

function MolongMibaoView:__init()
	self.def_index = 1
	self.ui_config = {"uis/views/molongmibao","MolongMibao"}
	self.play_audio = true
end

function MolongMibaoView:__delete()

end

function MolongMibaoView:LoadCallBack()
	self.chapter_view = MolongMibaoChapterView.New(self:FindObj("ChapterView"))

	self.chapter_name_t = {}
	self.chapter_red_t = {}
	self.toggle_t = {}
	for i = 1, 4 do
		self.chapter_name_t[i] = self:FindVariable("ChapteName" .. i)
		self.chapter_red_t[i] = self:FindVariable("toggle_red_" .. i)
		self.toggle_t[i] = self:FindObj("Toggle" .. i)
		self.toggle_t[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, i))
	end
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
	self.chapter_name_t = nil
	self.chapter_red_t = nil
	self.toggle_t = nil
end

function MolongMibaoView:OnToggleChange(index, isOn)
	if self.delay then return end
	if isOn then
		local i = index
		while i > 0 do
			if MolongMibaoData.Instance:GetMibaoChapterFinish(i - 2) then
				if index - i > 0 and self.toggle_t[self:GetShowIndex()] then
					self.delay = GlobalTimerQuest:AddDelayTimer(function()
						self.toggle_t[self:GetShowIndex()].toggle.isOn = true
						self.delay = nil
					end, 0)
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.MoLongMiBao.ChapterOpenLimit, MolongMibaoData.Instance:GetMibaoChapterName(i - 1)))
					return
				end
				break
			end
			i = i - 1
		end
		if index ~= self:GetShowIndex() then
			self.chapter_view:ChapterChange(index)
			self:ChangeToIndex(index)
		end
	end
end

function MolongMibaoView:OpenCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("molongmibao_remind_day", cur_day)
	end
	self.chapter_view:OpenCallBack()
	self:Flush()
end

local has_show_index = false
function MolongMibaoView:ShowIndexCallBack(index)
	if not has_show_index then
		has_show_index = true
		for i = 1, MolongMibaoData.Chapter do
			if not MolongMibaoData.Instance:GetMibaoChapterFinish(i - 1) or i == MolongMibaoData.Chapter then
				if index ~= i and index == 1 then
					index = i
				end
				break
			end
		end
	end
	if self.toggle_t[index] and not self.toggle_t[index].toggle.isOn then
		self.toggle_t[index].toggle.isOn = true
	end
end

function MolongMibaoView:CloseCallBack()
	self.toggle_t[1].toggle.isOn = true
	has_show_index = false
end

function MolongMibaoView:OnFlush(param_t)
	self.chapter_view:OnFlush()
	for k,v in pairs(self.chapter_name_t) do
		if not MolongMibaoData.Instance:GetMibaoChapterFinish(k - 2) then
			v:SetValue("????")
		else
			v:SetValue(MolongMibaoData.Instance:GetMibaoChapterName(k - 1))
		end
	end
	for k,v in pairs(self.chapter_red_t) do
		v:SetValue(MolongMibaoData.Instance:GetMibaoChapterRemind(k - 1) > 0)
	end
end