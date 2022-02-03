
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 720,
    height = 1280,
    autoscale = "FIXED_WIDTH", -- FIXED_HEIGHT FIXED_WIDTH SHOW_ALL NO_BORDER
    callback = function(framesize)
        local ratio = framesize.height / framesize.width
        -- if ratio <= 1.34 then
            -- return {autoscale = "SHOW_ALL"}
        -- elseif ratio <= 1.78 then
        if ratio <= 1.78 then
            return {autoscale = "FIXED_HEIGHT"}
        end
    end
}