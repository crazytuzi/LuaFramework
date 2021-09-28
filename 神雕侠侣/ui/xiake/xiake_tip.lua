require "ui.dialog"

XiakeTip = {};
setmetatable(XiakeTip, Dialog);
XiakeTip.__index = XiakeTip;

local _instance;
function XiakeTip.getInstance()
end

return XiakeTip;
