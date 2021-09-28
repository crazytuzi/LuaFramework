local Util = require "Zeus.Logic.Util"

local CanvasMenuBase = {}
CanvasMenuBase.__index = CanvasMenuBase

function CanvasMenuBase:init(menuUI, canvas, ...)
    self.canvas = canvas
    self.canvases = {canvas, ...}
    self.menuUI = menuUI
    self.canvas.Visible = false
    self.running = false
end

function CanvasMenuBase:onEnter()
    self.running = true
    for i,v in ipairs(self.canvases) do
        v.Visible = true
    end
end

function CanvasMenuBase:onExit()
    self.running = false
    for i,v in ipairs(self.canvases) do
        v.Visible = false
    end
end

function CanvasMenuBase:onDestroy()
    self.canvas = nil
    self.canvases = nil
    self.menuUI = nil
end

return CanvasMenuBase
