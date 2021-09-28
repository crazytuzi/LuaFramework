-- Guide.TalkView.Init.lua
-- Author: 杨科
-- Date: 2016-05-06 10:52:17
--

if not TalkView then
    TalkView = {}

    require("Guide.TalkView.Define")
    TalkView.AudioLength = require("Guide.Talk.AudioLength")
end

return TalkView
