-- @Author: lwj
-- @Date:   2019-01-04 19:12:07
-- @Last Modified time: 2019-01-04 19:12:09

BookSliderCut = BookSliderCut or class("BookSliderCut", BaseCloneItem)
local BookSliderCut = BookSliderCut

function BookSliderCut:ctor(parent_node, layer)
    BookSliderCut.super.Load(self)
end

function BookSliderCut:dctor()

end

function BookSliderCut:LoadCallBack()
    self.nodes = {
        "bg",
    }
    self:GetChildren(self.nodes)
    self.bg = GetImage(self.bg)
end

function BookSliderCut:SetLucency()
    SetColor(self.bg, 255, 255, 255, 0)
end
