-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/8/20
-- Time: 10:14
-- 文件功能：用于基础的ui控件，可以通过设置zorder来通过界面分层

CommonUI = CommonUI or BaseClass()

CommonUI.__ZOrder= 0

CommonUI.close_panel = "CommonUI_close_panel"
---------------------------------
CommonUI.close_cur_panel = "CommonUI_close_cur_panel" --关闭当前的ui
CommonUI.close_all_panel = "CommonUI_close_all_panel" --关闭所有的ui

function CommonUI:__init()

end

--[[ 统一设置层次的关系，可以做到分层的效果
--  @param target 要设置层次关系的对象
--  @param layer 要放置的层次位置
-- ]]
function CommonUI:setCommonUIZOrder(target)
    CommonUI.__ZOrder = CommonUI.__ZOrder + 1
    target:setLocalZOrder(CommonUI.__ZOrder)
end

--[[
-- 根据层次取出该层次的最大order
-- @param layer 要取出的层次位置
-- ]]
function CommonUI:getCommonUIZOrder()
    return CommonUI.__ZOrder
end

function CommonUI:open()
end

function CommonUI:__delete()

end

