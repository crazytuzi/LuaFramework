


local _M = {view = nil,rootValue = nil,subValues = nil,rootViews = nil,subViews = nil,spacing = nil,indent = nil,resSize2D = nil,
    selectMode = nil,selectSubCtrl = nil}
_M.__index = _M
_M.MODE_SINGLE = 1
_M.MODE_NORMAL = 0

function _M.CreateRootValue(modelView,size,funcCreate,funcClick)
    local rootValue = {}
    rootValue.modelView = modelView
    rootValue.size = size
    rootValue.funcCreate = funcCreate
    rootValue.funcClick = funcClick
    return rootValue
end

function _M.CreateSubValue(rootIndex ,modelView,size,funcCallback,funcCreateCallBack)
    local subValue = {}
    subValue.rootIndex = rootIndex
    subValue.modelView = modelView
    subValue.size = size
    subValue.funcCallback = funcCallback
    subValue.funcCreateCallBack = funcCreateCallBack
    return subValue
end 

local function createRootView(self,index,rootValue,spacing,indent)
    local view = {}
    view.root = rootValue.modelView:Clone()
    view.root.UserTag = index
    view.root.UnityObject.name = "RootView_"..index
    if (rootValue.funcCreate) then
        rootValue.funcCreate(index,view.root)
    end
    view.subCanvas = HZCanvas.New()
    view.subCanvas.UnityObject.name = "SubView_"..index
    view.subCanvas.X = indent
    local lElementRoot = view.root.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElementRoot.preferredWidth = view.root.Width
    lElementRoot.preferredHeight = view.root.Height
    local lElementSub = view.subCanvas.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElementSub.preferredHeight = 0
    view.subCanvas.Visible = false
    view.root.event_PointerClick = function()
        local visible = view.subCanvas.Visible
        visible = not visible
        view.subCanvas.Visible = visible
        if (rootValue.funcClick) then
            rootValue.funcClick(view.root,visible)
        end
        if visible == true then
            if self.lastView ~= nil and self.lastView ~= view then
                self.lastView.subCanvas.Visible = false
                if self.lastRootValue ~= nil and (self.lastRootValue.funcClick) then
                    self.lastRootValue.funcClick(self.lastView.root,false)
                end
            end
            self.lastView = view
            self.lastRootValue = rootValue
        end
    end
    return view
end

local function createSubView(self,subCanvas,rootIndex,subIndex,modelView,funcCallback,funcCreateCallback)
    local subCtrl = modelView:Clone()
    subCtrl.Enable = true
    if funcCreateCallback then
        funcCreateCallback(rootIndex,subIndex,subCtrl)
    end
    subCtrl.event_PointerClick = function()
        if funcCallback then
            funcCallback(rootIndex,subIndex,subCtrl)
        end
        if self.selectMode == self.MODE_SINGLE then
            if self.selectSubCtrl == nil then
                self.selectSubCtrl = subCtrl
            else
                if self.selectSubCtrl == subCtrl then
                    return
                end
                if self.funcCancel then
                    self.funcCancel(self.selectSubCtrl)
                end
                self.selectSubCtrl = subCtrl
            end
        end
    end
    subCanvas:AddChild(subCtrl)
    return subCtrl
end

local function setSubViews(self,isHorizontal)
    if(self.subViews == nil) then
        self.subViews = {}
    end
    for i = 1,#self.subValues,1 do
        local subValue = self.subValues[i]
        local rootIndex = subValue.rootIndex
        local rootView = self.rootViews[rootIndex]
        if(rootView == nil) then
            return false
        end
        local subCanvas = rootView.subCanvas
        if(self.subViews[rootIndex] == nil) then
            self.subViews[rootIndex] = {}
        end
        local height = 0
        local width = 0
        for j = 1,#self.subViews[rootIndex],1 do
            self.subViews[rootIndex].Visible = false
        end
        for j = 1,subValue.size,1 do
            local ctrl = nil
            if self.subViews[rootIndex][j] then
                ctrl = self.subViews[rootIndex][j]
            else
                ctrl = createSubView(self,subCanvas,rootIndex,j,subValue.modelView,subValue.funcCallback,subValue.funcCreateCallBack)
                self.subViews[rootIndex][j] = ctrl
            end
            ctrl.Visible = true
            if isHorizontal then
                ctrl.X = width
                width = width + ctrl.Width
                height = ctrl.Height
            else
                ctrl.Y = height
                height = height + ctrl.Height
                width = ctrl.Width
            end
        end
        subCanvas.Size2D = Vector2.New(width,height)
        local lElementSub = subCanvas.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
        lElementSub.preferredWidth = subCanvas.Width
        lElementSub.preferredHeight = subCanvas.Height
    end
end

function _M:ChangeRootView(isHorizontal)
    if(self.rootViews == nil) then
        self.rootViews = {}
    end
    for i = 1,#self.rootViews,1 do
        self.rootViews[i].root.Visible = false
        self.rootViews[i].root.subCanvas = false
    end
    for i = 1,self.rootValue.size,1 do
        local view = nil
        if(i <= #self.rootViews) then
            view = self.rootViews[i]
        end
        if view == nil then
            view = createRootView(self,i,self.rootValue,self.spacing,self.indent)
            self.view:AddChild(view.root)
            self.view:AddChild(view.subCanvas)
            self.rootViews[i] = view
        end
        view.root.Visible = true
    end
    setSubViews(self,isHorizontal)
end


function _M:setValues(rootValue,subValues,isHorizontal)
    self.rootValue = rootValue
    self.subValues = subValues
    self:ChangeRootView(isHorizontal)
end

function _M:GetRootView()
    return self.rootViews
end

function _M:GetSubViews()
    return self.subViews
end

function _M:selectNode(rootIndex, subIndex ,isAuto)
    local rootView = self.rootViews[rootIndex]
    local rootRoot = nil
    local subRoot = nil
    if rootView then
        rootRoot = rootView.root
        subRoot = rootView.subCanvas
        rootView.subCanvas.Visible = true
        if (self.rootValue.funcClick) then
            self.rootValue.funcClick(rootView.root, true)
        end
        if self.lastView ~= nil and self.lastView ~= rootView then
            self.lastView.subCanvas.Visible = false
            if self.lastRootValue ~= nil and (self.lastRootValue.funcClick) then
                self.lastRootValue.funcClick(self.lastView.root,false)
            end
        end
        self.lastView = rootView
        self.lastRootValue = self.rootValue

        if subIndex then
            local ctrl = self.subViews[rootIndex][subIndex]
            if ctrl then
                local subValue = nil
                for i = 1, #self.subValues, 1 do
                    if self.subValues[i].rootIndex == rootIndex then
                        subValue = self.subValues[i]
                        break;
                    end
                end
                if subValue then
                    if subValue.funcCallback then
                        subValue.funcCallback(rootIndex, subIndex, ctrl)
                    end
                    if self.selectMode == self.MODE_SINGLE then
                        if self.selectSubCtrl == nil then
                            self.selectSubCtrl = ctrl
                        else
                            if self.selectSubCtrl ~= ctrl then
                                if self.funcCancel then
                                    self.funcCancel(self.selectSubCtrl)
                                end
                            end
                            self.selectSubCtrl = ctrl
                        end
                    end
                    
                end
            end
        end
        if isAuto then
            local rh = 0
            for i = 1,(rootIndex - 1), 1 do
                local rootView = self.rootViews[i]
                rh = rh + rootView.root.Width
                if rootView.subCanvas.Visible then
                    rh = rh + rootView.subCanvas.Width
                end
            end
            if subIndex then
                local ctrl = self.subViews[rootIndex][subIndex]
                rh = rh + (subIndex - 1)*ctrl.Width
            end
            if rh + 150 > rootView.subCanvas.Width then
                if self.scrollPan then
                    local function testYield()
                        local a = self.scrollPan.UnityObject:GetComponent("DisplayNodeBehaviour");
                        a:StartCoroutine(GameGlobal.Instance.WaitForSeconds(0.01, function()
                            self.scrollPan.Scrollable:LookAt(Vector2.New(rh ,0))
                        end ))
                    end
                    testYield()
                end
            end
        end
    end
end

function _M:setScrollPan(scroll)
    self.scrollPan = scroll
end

local function InitComponent(self,spacing,size2D,isHorizontal)
    self.view = HZCanvas.New()
    self.view.UnityObject.name = "TreeView"
    self.view.Size2D = size2D
    local layout = nil
    if isHorizontal then
        layout = self.view.UnityObject:AddComponent(typeof(UnityEngine.UI.HorizontalLayoutGroup))
    else
        layout = self.view.UnityObject:AddComponent(typeof(UnityEngine.UI.VerticalLayoutGroup))
        layout.childForceExpandHeight = false
    end
    
    layout.spacing = spacing
    local sizeFill = self.view.UnityObject:AddComponent(typeof(UnityEngine.UI.ContentSizeFitter))
    local FitMode = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize
    sizeFill.horizontalFit = FitMode
end

function _M.Create(spacing,indent,size2D,selectMode,funcCancel,isHorizontal)
    
    local ret = {}
    setmetatable(ret,_M)
    if(spacing == nil) then
        spacing = 1
    end
    ret.spacing = spacing
    ret.indent = indent
    if selectMode == nil then
        selectMode = ret.MODE_NORMAL
    end
    ret.selectMode = selectMode
    if selectMode == ret.MODE_SINGLE then
        ret.funcCancel = funcCancel
    end
    ret.resSize2D = size2D
    InitComponent(ret,spacing,size2D,isHorizontal)
    return ret    
end

return _M

