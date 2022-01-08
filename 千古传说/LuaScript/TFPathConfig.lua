local szPath = ''
if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    szPath = "TFDebug/"
end

if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
    szPath = "../../Resource/"
end

-- local t = {
--     szPath .. "png_release/",
-- }
local t = {
    szPath .. "",
}

return t