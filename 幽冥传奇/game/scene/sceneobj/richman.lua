RichMan = RichMan or BaseClass(Role)
function RichMan:__init()
end	

function RichMan:__delete()
end	

function RichMan:CreateBoard()
end	

function RichMan:UpdateNameBoard()
end	

function RichMan:CreateTitle()
end

function RichMan:SetHpBoardVisible(is_visible)
end

function RichMan:CreateShadow()
end

--移动完成回调
function RichMan:SetEndMoveCallBack(f)
	self.endmove_callback = f
end	

function RichMan:EndMove()
	if self.endmove_callback then
		self.endmove_callback()
	end
end	

function RichMan:DoMove(real_pos,life,logic_pos)
	self.sync_start_time = Status.NowTime
	self.sync_end_time = self.sync_start_time + life
	--print(self.sync_start_time,life,self.sync_end_time,real_pos.x,real_pos.y)
	self:CalMoveToRealXY(real_pos.x,real_pos.y,life)

	
	local totalFrame = self:GetAniTotalframeByActionType(self.action_type)
	--print("当前帧数",totalFrame)
	self.delay_per_unit = self:GetMoveActionFilterSpeed(life) / totalFrame
	self.loops = nil
	self.is_pause_last_frame = false

	if self.prev_action_type ~= self.action_type then --连续移动
		self.async_start_time = self.sync_start_time	
	end	
	self:RefreshAnimation()
end	