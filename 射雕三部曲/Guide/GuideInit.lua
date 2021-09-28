--[[
    filename: Guide.GuideInit.lua
    description: 新手引导命名空间初始化
    date: 2017.02.07

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

if not Guide then
    Guide = {
        -- 管理（初始化引导表、管理引导数据）
        manager = require("Guide.GuideMgr"),

        -- 执行（执行引导、hook按钮事件）
        helper  = require("Guide.GuideHelper"),

        -- 配置（结点事件、自动hook的点击步骤、、、）
        config  = require("Guide.GuideConfig"),

        hit = function(x)
            Guide.manager:saveGuideStep(Guide.config.recordID, x, nil, true)
        end,
    }
end

return Guide
