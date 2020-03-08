local AudioData = {}
AudioData.audioPathCached = nil
function AudioData.GetRoleAudio(occupationId, gender)
  if AudioData.audioPathCached == nil then
    AudioData.audioPathCached = AudioData.LoadData()
  end
  local fileIds = AudioData.audioPathCached[AudioData.GenKey(occupationId, gender)]
  local selected = math.random(1, #fileIds)
  return fileIds[selected]
end
function AudioData.LoadData()
  local LoginUtility = require("Main.Login.LoginUtility")
  local allCreateRoleCfgs = LoginUtility.GetAllCreateRoleCfgs()
  local audioPath = {}
  for k, v in pairs(allCreateRoleCfgs) do
    local occupationId = v.occupationId
    local gender = v.gender
    local key = AudioData.GenKey(occupationId, gender)
    audioPath[key] = {}
    for i, audioId in ipairs(v.audioIdList) do
      if audioId ~= 0 then
        table.insert(audioPath[key], audioId)
      end
    end
  end
  return audioPath
end
function AudioData.GenKey(occupationId, gender)
  return bit.lshift(occupationId, 2) + gender
end
function AudioData.Clear()
  AudioData.audioPathCached = nil
end
return AudioData
