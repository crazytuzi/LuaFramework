-- @author 黄耀聪
-- @date 2016年7月22日

AuctionMyPanel = AuctionMyPanel or BaseClass(BasePanel)

function AuctionMyPanel:__init(model, gameObject, callback)
    self.model = model
    self.gameObject = gameObject
    self.callback = callback
    self.name = "AuctionMyPanel"
    self.mgr = AuctionManager.Instance

    self.itemlist = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.updatelistener = function(idx) self:UpdateList(idx) end

    self:InitPanel()
end

function AuctionMyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.grid ~= nil then
        self.grid:DeleteMe()
        self.grid = nil
    end
    if self.itemlist ~= nil then
        for _,v in pairs(self.itemlist) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemlist = nil
    end
    self:AssetClearAll()
end

function AuctionMyPanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.scroll = t:Find("Scroll"):GetComponent(ScrollRect)
    self.container = t:Find("Scroll/Container")
    self.cloner = t:Find("Scroll/Cloner").gameObject
    self.nothing = t:Find("Nothing").gameObject
    self.nothingBtn = t:Find("Nothing/Button"):GetComponent(Button)

    self.grid = LuaGridLayout.New(self.container, {column = 2, cellSizeX = 230, cellSizeY = 120, bordertop = 10, borderleft = 10})
    self.cloner:SetActive(false)

    self.nothingBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.auction_window, {1}) end)
end

function AuctionMyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AuctionMyPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateMyItem:AddListener(self.updatelistener)

    self.mgr:send16701()

    self:ReloadGrid()
    if self.callback ~= nil then
        self.callback()
    end
end

function AuctionMyPanel:OnHide()
    self:RemoveListeners()
    self.mgr.onUpdateMyItem:RemoveListener(self.updatelistener)
    self.model.selectIdx = nil
end

function AuctionMyPanel:RemoveListeners()
end

function AuctionMyPanel:ReloadGrid()
    self.grid:ReSet()
    local model = self.model
    local datalist = {}
    for _,v in pairs(model.mylist) do
        table.insert(datalist, v)
    end
    self.nothing:SetActive(#datalist == 0)
    for i,v in ipairs(datalist) do
        if self.itemlist[i] == nil then
            local obj = GameObject.Instantiate(self.cloner)
            self.itemlist[i] = AuctionMyItem.New(model, obj, self.callback)
        end
        self.itemlist[i]:update_my_self(v, i)
        self.grid:AddCell(self.itemlist[i].gameObject)
    end
    for i=#datalist + 1,#self.itemlist do
        self.itemlist[i]:SetActive(false)
    end
end

function AuctionMyPanel:UpdateMy(idx)
    local model = self.model
    if idx ~= nil then
        if model.mylist[idx].item ~= nil then
            model.mylist[idx].item:update_my_self(model.mylist[idx], nil)
        end
    end
end

function AuctionMyPanel:UpdateList(idx)
    if idx == nil then
        self:ReloadGrid()
    else
        if model.mylist[idx] ~= nil and model.mylist[idx].item ~= nil then
            model.mylist[idx].item:update_my_self(model.mylist[idx])
        end
    end
end


