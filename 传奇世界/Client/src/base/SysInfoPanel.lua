local SysInfoPanel = class("SysInfoPanel", function() return cc.Node:create() end)

function SysInfoPanel:ctor() 
end

function SysInfoPanel:addSysInfo(text,links)
    local propInfo = ""
    if links then
      local objs = require("src/config/propOp")
      for i=1,#links do
          propInfo = "^c(" .. objs.nameColor(links[i]) ")" .. objs.name(links[i]) .. "^"
      end
    end
    TIPS( { type = 2 , str = text .. propInfo } )
end

return SysInfoPanel