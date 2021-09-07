SpanBattleData = SpanBattleData or BaseClass()

function SpanBattleData:__init()
	if SpanBattleData.Instance then
		print_error("[SpanBattleData] Attempt to create singleton twice!")
		return
	end
	SpanBattleData.Instance = self

	self.roytomb_cfg = nil
	self.roytomb_fb_config = nil
	
end

function SpanBattleData:__delete()
	SpanBattleData.Instance = nil
end

