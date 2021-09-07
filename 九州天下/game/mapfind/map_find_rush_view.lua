MapfindRushView = MapfindRushView or BaseClass(BaseView)

function MapfindRushView:__init(  )
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {"uis/views/mapfind", "MapRushFlushView"}
	self.play_audio = true
	self:SetMaskBg(true)
end

function MapfindRushView:__delete(  )
	
end

function MapfindRushView:LoadCallBack(  )
	self.item = {}
	self.rush_item = {}
	for i=1,9 do
		self.item[i] = self:FindObj("item" .. i)
		self.rush_item[i] = MapfindRushItem.New(self.item[i])
		self.rush_item[i]:SetData(i)

	end
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickStart",BindTool.Bind(self.ClickStart,self))
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

function MapfindRushView:ClickStart()
	MapFindCtrl.Instance:BeginRush()
	MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH,MapFindData.Instance:GetSelect(),5)
	self:Close()
end

MapfindRushItem = MapfindRushItem or BaseClass(BaseRender)

function MapfindRushItem:__init(  )
	self.text = self:FindVariable("text")
	self:ListenEvent("OnToggle",BindTool.Bind(self.OnClick,self))
end

function MapfindRushItem:SetData(data)
	self.index = data
	local name = MapFindData.Instance:GetNameById(data)
	self.text:SetValue(name)
end

function MapfindRushItem:OnClick()
	MapFindData.Instance:SetSelect(self.index)
end

