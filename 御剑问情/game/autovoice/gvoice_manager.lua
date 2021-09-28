GVoiceManager = GVoiceManager or BaseClass()

function GVoiceManager:__init()
	if GVoiceManager.Instance then
		ErrorLog("[GVoiceManager]:Attempt to create singleton twice!")
	end
	GVoiceManager.Instance = self

	self.play_voice_count = 0
end

function GVoiceManager:__delete()
	GVoiceManager.Instance = nil
end

function GVoiceManager:PlayVoice(file_id, complete_call_back)
	if type(file_id) == "string" then
		AudioGVoice.StartPlay(file_id, complete_call_back)
	end
end

function GVoiceManager:StopVoice()
	AudioGVoice.StopPlay()
end

function GVoiceManager:StartRecord()
	AudioGVoice.StartRecorder()
end

function GVoiceManager:StopRecord(complete)
	local call_back = function (succ, file_id, str)
		complete(succ, file_id, str)
	end
	AudioGVoice.StopRecorder(call_back)
end

-- 是否是GVoice语音
function GVoiceManager.ParseGVoice(content)
	local is_gvoice = false
	local file_id = "-1"
	local str = ""
	local time = 0
	local role_id = 0
	local duration = 0
	if nil ~= content and "" ~= content then
		local rule = string.sub(content, 1, 6)
		if rule == "gvoice" then
			local tbl = Split(content, ";")
			file_id = tbl[2] or "-1"
			str = tbl[3] or ""
			duration = tbl[4] or 0
			role_id = tbl[5] or 0
			time = tbl[6] or 0
			if tbl[2] and tbl[3] then
				is_gvoice = true
			end
		end
	end
	return is_gvoice, file_id, str, duration, role_id, time
end