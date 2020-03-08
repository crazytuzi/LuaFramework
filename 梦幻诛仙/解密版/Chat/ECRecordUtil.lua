local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECRecordTip = require("Chat.ECRecordTip")
local l_instance
local ECRecordUtil = Lplus.Class("ECRecordUtil")
local def = ECRecordUtil.define
local POST_ADDRESS = "https://voice-mzxm.zloong.com/zvoice/api/upload"
def.field("table").post_records = function()
  return {}
end
def.static("=>", ECRecordUtil).Instance = function()
  if not l_instance then
    l_instance = ECRecordUtil()
    POST_ADDRESS = _NormalizeHttpURL(POST_ADDRESS)
  end
  return l_instance
end
def.static("=>", "boolean").isValid = function()
  return GameUtil.httpPostForm ~= nil
end
def.static("=>", "boolean").opusValid = function()
  return false
end
def.method("string", "table", "function").doHttpPost = function(self, _postId, data, cb)
  if _postId == "" or self.post_records[_postId] then
    warn("postId:" .. _postId .. " is already exits")
    return
  end
  if not self.post_records[_postId] then
    self.post_records[_postId] = cb
    local url = POST_ADDRESS
    local first = true
    for k, v in pairs(data) do
      if type(v) == "string" then
        if first then
          url = string.format("%s?%s=%s", url, k, v)
        else
          url = string.format("%s&%s=%s", url, k, v)
        end
        first = false
      end
    end
    GameUtil.httpPostForm(url, _postId, data, function(success, url, postId, retdata)
      local func = self.post_records[postId]
      if func then
        func(success, url, postId, retdata)
      end
      self.post_records[postId] = nil
    end)
  end
end
local audio_info = {
  amr = {
    audiotype = 1,
    samples = 8000,
    bitrate = 0
  },
  opus = {
    audiotype = 2,
    samples = 16000,
    bitrate = 12800
  }
}
def.static("=>", "number", "string", "number", "number").getAudioInfo = function()
  local key = "amr"
  if ECRecordUtil.opusValid() then
    key = "opus"
  end
  local info = audio_info[key]
  return info.audiotype, key, info.samples, info.bitrate
end
def.static("string", "=>", "number", "number").getPlayInfo = function(audioType)
  local key = audioType
  if not audio_info[key] then
    key = "amr"
  end
  local info = audio_info[key]
  return info.audiotype, info.samples
end
def.static("string", "=>", "string").checkAudioType = function(audioType)
  if audio_info[audioType] then
    return audioType
  else
    return "amr"
  end
end
return ECRecordUtil.Commit()
