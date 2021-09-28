local NoticeComponent = class("NoticeComponent", UFCCSNormalLayer)

function NoticeComponent:ctor( ... )
	self.super.ctor(self, ...)
end

function NoticeComponent:onLayerLoad( ... )
	--self:registerBtnClickEvent("copy",self.onDungeonScene)
        --self:registerBtnClickEvent("main",self.onBackMain)
        --self:registerBtnClickEvent("shop",self.onShop)
end

function NoticeComponent.create()
    return NoticeComponent.new("ui_layout/notice.json")
end

return NoticeComponent

