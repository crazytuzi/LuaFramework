MapfindRushView = MapfindRushView or BaseClass(BaseView)

function MapfindRushView:__init(  )
	self.full_screen = false-- 是否是全屏界面
    self.ui_config = {"uis/views/mapfind_prefab", "MapRushFlushView"}
    self.play_audio = true
end

function MapfindRushView:__delete(  )
	
end

function MapfindRushView:LoadCallBack(  )
	self.item = {}
	self.rush_item = {}
	for i=1,8 do
		self.item[i] = self:FindObj("item" .. i)
		self.rush_item[i] = MapfindRushItem.New(self.item[i])
		self.rush_item[i]:SetData(i)

	end
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickStart",BindTool.Bind(self.ClickStart,self))
	MapFindData.Instance:ClearSelect()
end

function MapfindRushView:ReleaseCallBack()

	self.item = nil

	for k,v in pairs(self.rush_item) do
		v:DeleteMe()
	end
	self.rush_item = nil
end

function MapfindRushView:CloseWindow()
	self:Close()
end

function MapfindRushView:CloseCallBack()
end

function MapfindRushView:ClickStart()
	local nam_tab = MapFindData.Instance:GetSelect()
	if next(nam_tab) then
	    local player_had_gold = PlayerData.Instance:GetRoleVo().gold
	    if player_had_gold > MapFindData.Instance:GetMapFlushSpend() then
	    	MapFindCtrl.Instance:BeginRush()
			MapFindCtrl.Instance:ClickIsStart()
			self:Close()
	    else
	    	MapFindCtrl.Instance:EndRush()
	    	TipsCtrl.Instance:ShowLackJiFenView()
	 --       ViewManager.Instance:Open(ViewName.VipView)
	    end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.MapFind.SelectCell)
		return
	end

--	MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH,MapFindData.Instance:GetSelect(),5)
end

MapfindRushItem = MapfindRushItem or BaseClass(BaseRender)

function MapfindRushItem:__init(  )
	self.text = self:FindVariable("text")
	self:ListenEvent("OnToggle",BindTool.Bind(self.OnClick,self))
	self.item_cell = self:FindObj("ItemCell")
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.item_cell)
end

function MapfindRushItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
	end
	self.item_cell = nil
end

function MapfindRushItem:SetData(data)
	self.index = data
	local name = MapFindData.Instance:GetNameById(data)
	self.text:SetValue(name)
	local temp = MapFindData.Instance:GetMapRewardData(self.index)
	self.cell:SetData(temp.base_reward_item)
end

function MapfindRushItem:OnClick(is_on)
	MapFindData.Instance:SetSelect(self.index,is_on)
end

