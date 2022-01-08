VisibleRect = {}

VisibleRect.s_visibleRect = CCRectMake(0, 0, 0, 0)
VisibleRect.bIsDirty = false

function VisibleRect:lazyInit()
    if (self.s_visibleRect.size.width == 0.0 and self.s_visibleRect.size.height == 0.0) or VisibleRect.bIsDirty then
        self.s_visibleRect.origin = me.Director:getVisibleOrigin()
        self.s_visibleRect.size = me.Director:getVisibleSize()
        VisibleRect.bIsDirty = false
    end
end

function VisibleRect:getVisibleRect()
    self:lazyInit()
    return CCRectMake(self.s_visibleRect.origin.x, self.s_visibleRect.origin.y, self.s_visibleRect.size.width, self.s_visibleRect.size.height)
end

function VisibleRect:left()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x, self.s_visibleRect.origin.y+self.s_visibleRect.size.height/2)
end

function VisibleRect:right()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width, self.s_visibleRect.origin.y+self.s_visibleRect.size.height/2)
end

function VisibleRect:top()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width/2, self.s_visibleRect.origin.y+self.s_visibleRect.size.height)
end

function VisibleRect:bottom()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width/2, self.s_visibleRect.origin.y)
end

function VisibleRect:center()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width/2, self.s_visibleRect.origin.y+self.s_visibleRect.size.height/2)
end

function VisibleRect:leftTop()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x, self.s_visibleRect.origin.y+self.s_visibleRect.size.height)
end

function VisibleRect:leftCenter()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x, self.s_visibleRect.origin.y+self.s_visibleRect.size.height/2)
end

function VisibleRect:rightTop()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width, self.s_visibleRect.origin.y+self.s_visibleRect.size.height)
end

function VisibleRect:rightCenter()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width, self.s_visibleRect.origin.y+self.s_visibleRect.size.height/2)
end

function VisibleRect:leftBottom()
    self:lazyInit()
    return self.s_visibleRect.origin
end

function VisibleRect:rightBottom()
    self:lazyInit()
    return ccp(self.s_visibleRect.origin.x+self.s_visibleRect.size.width, self.s_visibleRect.origin.y)
end

return VisibleRect