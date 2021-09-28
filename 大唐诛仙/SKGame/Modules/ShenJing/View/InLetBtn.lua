InLetBtn =BaseClass(LuaUI)
function InLetBtn:__init( ... )
	self.URL = "ui://ny6nt56pez9zi"
	self.lessTime = 3600
	self:__property(...)
	self:Config()
end
local render_s = "InLetBtn_render_key"
local render_key
function InLetBtn:SetProperty(index )
	self.index = index
	local model = ShenJingModel:GetInstance()
	if index == 2 then
		self.state = model.huanjingState
		render_key = render_s..index
		self.listenerHandle2 = ShenJingModel:GetInstance():AddEventListener(ShenJingConst.HuanjingChanged, function ()
			self.lessTime = math.floor((model.huanjingEndTime-TimeTool.GetCurTime())*0.001)
			self.state = model.huanjingState
		end)
		self:SetState( false )
		RenderMgr.AddInterval(function ()
			if self.state == 1 then self:UpdateState() return end
			self.lessTime = self.lessTime - 1
			self.txtLessTime.text = TimeTool.GetTimeFormat(self.lessTime)
			if self.lessTime <= 0 then self.state = 1 end
		end, render_key, 1)
	end
end

function InLetBtn:UpdateState()
	self.txtLessTime.text = ""
	self:SetState( self.state == 1 )
end
function InLetBtn:SetState( bool )
	self.ui.grayed = not bool
	self.activited = bool
end
function InLetBtn:SetLess( time )
	self.lessTime = time
end

function InLetBtn:Config()
	self:AddEvent()
	self:Init()
end

function InLetBtn:AddEvent()
	self.ui.onClick:Clear()
	self.ui.onClick:Add(self.OnClickBtn,self)
end

function InLetBtn:Init()
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	local mainPlayerLev = mainPlayerVo.level or 0
	local openLev = ShenJingConst.OpenLev[self.index]
	if openLev == -1 then
		self.ui.visible = false
	else
		if openLev <= mainPlayerLev then
			self.NoOpenMask.visible = false
			self.Lock.visible = false
			self.LockLevel.text = StringFormat("")
			self.icon.url = ShenJingConst.btnType[self.index].iconOpen
		else
			self.NoOpenMask.visible = true
			self.Lock.visible = true
			self.LockLevel.text = StringFormat("{0}级开放" , openLev)
			self.icon.url = ShenJingConst.btnType[self.index].iconNoOpen
		end
		self.title.text = StringFormat("{0}",ShenJingConst.btnType[self.index].name)
		self.ui.visible = true
	end
end

local fullBagTip = "您的背包快满了( [COLOR=#ff0000]{0}[/COLOR]/{1} ) 请尽快清理"
function InLetBtn:OnClickBtn()
	if self.index == 1 then
		local fun = ShenJingConst.btnType[self.index].fun
		--增加进大荒塔读条
		local zdModel = ZDModel:GetInstance()
		local teamId = zdModel:GetTeamId()
		local num = zdModel:GetMemNum() or 0
		if teamId == 0 or ( teamId ~= 0 and num == 1 ) then
			local function cb()
				GlobalDispatcher:DispatchEvent(EventName.StopCollect)
				local data = { tType = "entertower", text = "大荒塔传送中", func = fun }
				GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, data)
				ShenJingController:GetInstance():CloseShenJingPanel()
			end
			local model = PkgModel:GetInstance()
			local now = #model:GetOnGrids() or 0
			local total = model.bagGrid or 0
			local msg = StringFormat(fullBagTip, now, total)
			if total - now < 8 then
				UIMgr.Win_Confirm("背包提示", msg, "进入副本", "整理背包", cb, function ()
					PkgCtrl:GetInstance():Open()
				end, true)
			else
				cb()
			end
		else
			Message:GetInstance():TipsMsg("组队状态下无法进入")
		end
	elseif self.index == 2 then --幻境
		if not self.activited then
			UIMgr.Win_FloatTip(StringFormat("幻境未开启，距离开启时间：{0}", TimeTool.GetTimeFormat(self.lessTime)))
			return
		end
		local mapId = 12101
		GlobalDispatcher:DispatchEvent(EventName.StopCollect)
		local data = { tType = "enterhj", text = "幻境传送中", args = mapId }
		GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, data)
		ShenJingController:GetInstance():CloseShenJingPanel()
	elseif self.index == 3 then --神境·仙域
		local viplevel = VipModel:GetInstance():GetPlayerVipLV()
		if viplevel > 0 then
			local mapId = 12001
			GlobalDispatcher:DispatchEvent(EventName.StopCollect)
			local data = { tType = "entersj", text = "神境·仙域传送中", args = mapId }
			GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, data)
			ShenJingController:GetInstance():CloseShenJingPanel()
		else
			Message:GetInstance():TipsMsg("VIP未激活，无法进入")
		end

	elseif self.index == 4 then --妖族入侵
		local pkgModel = PkgModel:GetInstance()
		local id = ShenJingConst.ID_QIANJIEYE
		local data = GetCfgData("item"):Get(id)
		local name = ""
		if data then
			name = data.name
		end
		if pkgModel:IsOnBagByBid(id) then
			data = PkgModel:GetInstance():GetGoodsVoByBid(id)
			local cfg = data:GetCfgData()
			if cfg.useType == 6 then --秘境
				local enterPanel1 = EnterPanel1.New()
				enterPanel1:Update(cfg)
				UIMgr.ShowCenterPopup(enterPanel1, function()  end)
			end
		else
			UIMgr.Win_FloatTip(StringFormat("您缺少进入副本的道具“{0}”", name))
		end
	elseif self.index == 5 then --古神试炼

		Message:GetInstance():TipsMsg("功能尚未开放")
	end

end

function InLetBtn:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("ShenJing","InLetBtn");

	self.button = self.ui:GetController("button")
	self.icon = self.ui:GetChild("icon")
	self.bg1 = self.ui:GetChild("bg1")
	self.NoOpenMask = self.ui:GetChild("NoOpenMask")
	self.title = self.ui:GetChild("title")
	self.Lock = self.ui:GetChild("Lock")
	self.LockLevel = self.ui:GetChild("LockLevel")
	self.txtLessTime = self.ui:GetChild("txtLessTime")
end

function InLetBtn.Create( ui, ...)
	return InLetBtn.New(ui, "#", {...})
end

function InLetBtn:__delete()
	self.button = nil
	self.icon = nil
	self.bg1 = nil
	self.NoOpenMask = nil
	self.title = nil
	self.Lock = nil
	self.LockLevel = nil
	RenderMgr.Realse(render_key)
	ShenJingModel:GetInstance():RemoveEventListener(self.listenerHandle2)
end