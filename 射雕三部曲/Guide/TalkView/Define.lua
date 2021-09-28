--[[
    filename: Guide.TalkView.Define.lua
    description: TalkView常量定义
    date: 2016.05.06
    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

if not TalkView.DEF then
    local DEF = {}

    TalkView.DEF = DEF

    DEF.PIC      = 1    -- 图片
    DEF.EFFECT   = 2    -- 特效
    DEF.FIGURE   = 3    -- 骨骼
    DEF.LABEL    = 4    -- 文字
    DEF.BUTTON   = 5    -- 按钮
    DEF.CLIPPING = 6    -- 裁剪结点
    DEF.ROLE    = 88    -- 特殊角色
    DEF.LIGHT   = 89
    DEF.WINDOW  = 90    -- 视窗
    DEF.CURTAIN = 91    -- 幕布
    DEF.CC      = 100   -- 内部控件

    DEF.CLOSE = 1
    DEF.OPEN  = 2

    DEF.WIDTH  = 640
    DEF.HEIGHT = 1136
end

return DEF
