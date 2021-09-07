-- ----------------------------
-- 聊天语音数据结构
-- hosr
-- ----------------------------
VoiceData = VoiceData or BaseClass()

function VoiceData:__init()
    self.id = 0
    self.channel = MsgEumn.ChatChannel.World
    -- 缓存id
    self.cacheId = 0
    -- 语音时长
    self.time = 0
    -- 语音数据
    self.byteData = nil
    -- 翻译结果
    self.msg = TI18N("语音转换文字失败")

    self.rid = 0
    self.zone_id = 0
    self.platform = ""
end
