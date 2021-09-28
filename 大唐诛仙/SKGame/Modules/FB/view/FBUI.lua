-- 选副本主界面
FBUI = BaseClass(CommonBackGround)
function FBUI:__init( ... )
	resMgr:AddUIAB("FB")
	self.ui = UIPackage.CreateObject("FB","FBUI")
	self.list = self.ui:GetChild("List")
	self.id = "FBUI"
	self:SetTitle(FBConst.StrTitle)
	self.showBtnClose = true
	self.imgArrowUp = self.ui:GetChild("imgArrowUp")
	self.imgArrowDown = self.ui:GetChild("imgArrowDown")
	self.txtDesc = self.ui:GetChild("n12")
	--添添要取消箭头!
	self:HideArrows()
	self.txtTimes = self.ui:GetChild("txtTimes")
	self.imgFlag = self.ui:GetChild("imgFlag")

	self.tabBar = {
		{label="", res0="fb01", res1="fb00", id="0", red=false},
		{label="", res0="fb11", res1="fb10", id="1", red=false},
		{label="", res0="fb21", res1="fb20", id="2", red=false},
	}
	self.defaultTabIndex = 0
	self.selectIdx = 0
	self.tabBarSelectCallback = function(idx, id) self:TabSelectHandle(idx, id) end
	self:Config()
	self:AddEvent()
	self:Init()
end

function FBUI:Layout()
	self.ui:SetPosition(150, 115, 0)
end

function FBUI:__delete()
	self:RemoveEvent()
	self:RemoveItems()
	self.list = nil
	self.isOpen = false
end

function FBUI:Config()
	self.model = FBModel:GetInstance()
	self.isOpen = true
	self.items = {}
end

function FBUI:RemoveItems()
	if not self.items then return end
	for i,v in ipairs(self.items) do
		v:Destroy()
	end
	self.items = {}
end

function FBUI:Init()
	self:Refresh()
	FBController:GetInstance():GetOpenMapList()
end

function FBUI:Refresh()
	self:RemoveItems()
	local fblist = self.model:GetList(self.selectIdx)
	if fblist then
		for i=1,#fblist do
			local item = FBItem.New()
			item:Init(fblist[i])
			item:AddTo(self.list)
			table.insert(self.items, item)
		end
	end
	self:RefreshTimesArea()
	--self:RefreshArrows()
	self:RefreshDesc()
end

function FBUI:RefreshDesc()
	self.txtDesc.text = FBConst.EnumDesc[self.selectIdx + 1] or FBConst.EnumDesc[1]
end

-- function FBUI:RefreshArrows()
-- 	if #self.items > FBConst.CellNum and (not self.list.scrollPane.isBottomMost) then
-- 		self.imgArrowDown.visible = true
-- 	else
-- 		self.imgArrowDown.visible = false
-- 	end
-- 	if #self.items > FBConst.CellNum and (self.list.scrollPane.posY > 2) then
-- 		self.imgArrowUp.visible = true
-- 	else
-- 		self.imgArrowUp.visible = false
-- 	end
-- end

function FBUI:AddEvent()
	local function OnMsgChange()
		self:Refresh()
	end
	self._hFBListChange = self.model:AddEventListener(FBConst.E_FBListRefresh, OnMsgChange)
	-- self.list.scrollPane.onScrollEnd:Add(self.OnScrollEndHandler, self)
	-- self.list.scrollPane.onScroll:Add(self.OnScrollHandler, self)
end

function FBUI:RemoveEvent()
	if self.model then
		self.model:RemoveEventListener(self._hFBListChange)
	end
	-- if self.list then
	-- 	self.list.scrollPane.onScrollEnd:Remove(self.OnScrollEndHandler, self)
	-- 	self.list.scrollPane.onScroll:Remove(self.OnScrollHandler, self)
	-- end
end

-- function FBUI:OnScrollEndHandler()
-- 	self:RefreshArrows()
-- end

-- function FBUI:OnScrollHandler()
-- 	self:HideArrows()
-- end

function FBUI:HideArrows()
	self.imgArrowDown.visible = false
	self.imgArrowUp.visible = false
end
--右上角总次数区域
function FBUI:RefreshTimesArea()
	local total = self.model:GetTotalTimes()
	local cur = math.max( total - self.model:GetCurEnterTimes(), 0 )
	self.txtTimes.text = cur .. '/' .. total
	if cur > 0 then
		self.imgFlag.url = "ui://wetrdvlhlgaa1d"
	else
		self.imgFlag.url = "ui://wetrdvlhlgaa1c"
	end
end

function FBUI:TabSelectHandle(idx, id)
	self.selectIdx = idx
	self:Refresh()
end