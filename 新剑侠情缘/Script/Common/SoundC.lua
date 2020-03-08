
function Ui:LoadSoundSetting()
	self.tbSoundSetting = {};

	local tbFile = LoadTabFile("Setting/Sound.tab", "ds", nil, {"SoundID", "Sound"});
	for _, tbRow in pairs(tbFile) do
		if tbRow.SoundID > 0 and string.find(tbRow.Sound, "^Setting/") then
			self.tbSoundSetting[tbRow.SoundID] = tbRow.Sound;
		end
	end
end

Ui:LoadSoundSetting();