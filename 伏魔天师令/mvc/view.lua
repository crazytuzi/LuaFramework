-- local ViewManager = classGc(function(self)
--     self.__id    = 100
--     self.__views = {}
-- end)
-- function ViewManager.createViewID(self, view)
--     self.__id               = self.__id + 1
--     self.__views[self.__id] = view
--     return self.__id
-- end
-- function ViewManager.getViewByID(self, view_id)
--     return self.__views[view_id]
-- end
-- _G.ViewManager = _G.ViewManager or ViewManager()



view = classGc(function(self)
    -- print("_G.view---->>>new ",self.__cname,self)
    -- self._viewID = _G.ViewManager:createViewID(self)
end)
-- function view.getViewID(self)
--     return self._viewID
-- end
-- function view.getView(self)
--     return _G.ViewManager:getViewByID(self._viewID)
-- end
function view.destroy(self)
    if self.m_mediator~=nil then
        self.m_mediator:destroy()
    end
end