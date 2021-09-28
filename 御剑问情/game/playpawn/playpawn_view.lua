PlayPawnView = PlayPawnView or BaseClass(BaseView)

function PlayPawnView:__init()
	self.ui_config = {"uis/views/tips/playpawn_prefab","PlayPawn"}
	self.play_audio = false
end

function PlayPawnView:__delete()
 
end

function PlayPawnView:ReleaseCallBack()
	self.pawn_anim = nil
	self.img_animator = nil
 
 	for i=1,6 do
		self.show_crap_list[i] = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end
 
 
function PlayPawnView:LoadCallBack()
	-- 查找组件
	self.pawn_anim = self:FindObj("image_pawn_anim")
 	self.img_animator = self.pawn_anim.animator
 
 	self.show_crap_list = {}
	for i=1,6 do
		self.show_crap_list[i] = self:FindObj("crap_show_" .. i)
		self.show_crap_list[i]:SetActive(false)
	end
 			 
end
 
function PlayPawnView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.close_quest then
		GlobalTimerQuest:CancelQuest(self.close_quest)
		self.close_quest = nil
	end
end
 
function PlayPawnView:OpenCallBack()
 	self.isflag = true
	self.pawn_anim:SetActive(true)
	self.img_animator:SetBool("turn", true)
	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.PlayPawnGetScore, self),2)
	end
 	
end


function PlayPawnView:PlayPawnGetScore()
	self.time_quest = nil
	PlayPawnCtrl.Instance:SendPaoSaizi()
	-- 关闭
	if nil == self.close_quest then
		self.close_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.ClosePlayViewYanchi, self), 2)
	end
end

function PlayPawnView:OnFlush()
	for i=1,6 do
		self.show_crap_list[i]:SetActive(false)
	end
	local curr_score = PlayPawnData.Instance:GetCurrPawnScore()
	if curr_score > 0 then
		if curr_score > 6 then
			curr_score = 6
		end
		self.pawn_anim:SetActive(false)
		self.show_crap_list[curr_score]:SetActive(true)
	end

end

function PlayPawnView:ClosePlayViewYanchi()
	self.close_quest = nil
 	for i=1,6 do
		self.show_crap_list[i]:SetActive(false)
	end
	-- 请求关闭
	self:Close()
end
 
