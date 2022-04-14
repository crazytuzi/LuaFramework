AutoTipPanel = AutoTipPanel or class("AutoTipPanel",BaseItem)
local AutoTipPanel = AutoTipPanel

function AutoTipPanel:ctor(parent_node,layer)
	self.abName = "autoplay"
	self.assetName = "AutoTipPanel"
	self.layer = layer

	self.is_show_open_action = true
	--self.model = 2222222222222end:GetInstance()
	AutoTipPanel.super.Load(self)
end

function AutoTipPanel:dctor()
	if self.sche_id then
		GlobalSchedule:Stop(self.sche_id)
	end
	if self.iconSettor then
		self.iconSettor:destroy()
		self.iconSettor = nil
	end
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
	end
end

function AutoTipPanel:LoadCallBack()
	self.nodes = {
		"icon","useBtn","nameTxt","CloseBtn","bg",
	}
	self:GetChildren(self.nodes)
	self.nameTxt = GetText(self.nameTxt)
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self:AddEvent()

	self:UpdateView()
end

function AutoTipPanel:AddEvent()
	local function call_back(target,x,y)
		self:destroy()
	end
	AddClickEvent(self.CloseBtn.gameObject,call_back)

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(SettingPanel):Open(2)
		self:destroy()
	end
	AddClickEvent(self.useBtn.gameObject,call_back)

	local function ok_func( ... )
		self:destroy()
	end
	self.sche_id = GlobalSchedule:StartOnce(ok_func,15)

	local function call_back()
		self:destroy()
	end
	self.event_id = GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function AutoTipPanel:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function AutoTipPanel:UpdateView()
	local itemCfg = Config.db_item[self.data]
	local param = {}
	param["cfg"] = itemCfg
	self.iconSettor = GoodsIconSettorTwo(self.icon)
	self.iconSettor:SetIcon(param)
	self.nameTxt.text = string.format("<color=#%s>%s</color>",
			ColorUtil.GetColor(itemCfg.color),itemCfg.name)

	local x = ScreenWidth - 179
	local y = -ScreenHeight + 253
	self.itemRectTra.anchoredPosition = Vector2(x,y)
end