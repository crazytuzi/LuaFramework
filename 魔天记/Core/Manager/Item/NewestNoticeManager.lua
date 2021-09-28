NewestNoticeManager = {}
local _noticeConfig = nil
function NewestNoticeManager.Init()
    _noticeConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PUBLIC_NOTICE)
end

function NewestNoticeManager.GetNoticeData()
    table.sort( _noticeConfig, function (a,b)
        return a.order < b.order
    end )
   return _noticeConfig
end