SceneLoader =BaseClass(LuaUI)
local this = SceneLoader
-- Automatic code generation, don't change this function (Constructor) use .New(...)
local inst = nil
this.tips = {
	"请务必注意，更换武器，都会使斗神印记消失！",
	"如果想取消已放置的注灵石，点击弹出的小背包的空白处即可。",
	"注灵属性，只有在对应部位上有装备时，才能发挥作用。",
	"通过自动匹配，可以快速帮你找到志同道合的队友。",
	"每天可以在长安城贵妃那领取悬赏任务，完成后能获得不菲的收入哦。",
	"在对战地图中和其他天人对战的时候要小心哦，失败了是可能会掉落装备的。",
	"和其他天人战斗吧，在侍魂殿中获得更高的阶位，你会获得超棒的奖励。",
	"如果累了，可以和其他天人聊聊人生，生活也不只是战斗。",
	"恶人的名字是红色，他们在死亡后会更容易掉落装备哦。",
	"听说对战地区的BOSS们虽然强大，但是也携带着更加丰富的装备和道具呢。",
	"每天登录签到可以领取丰厚奖励！",
	"加入家族，跟家族的朋友一起组队进行副本，会更轻松哦。",
	"失败了不要紧，掌握世界BOSS的特点，打造强化装备，再次挑战吧。",
	"分解装备可获得注灵石。",
	"低级物品别随便卖掉，或许可合成成高级物品。",
	"除了支线任务，每日任务和环任务也是获得经验的途径。",
	"只有穿了装备，对应槽位的注灵才会生效。",
	"同家族成员三人组队时，可获得经验加成buff。",
	"连续签到可以获得额外奖励。",
	"累计在线即能领取丰厚奖励。",
	"激活VIP可享受大量特权，还能每天领取元宝",
	"每个排行榜只显示前100名，整点刷新排行榜数据哦。",
	"周活动奖励丰富，可以点击活动面板的查看周历按钮进行查看。",
	"炫丽的特效比较多，加载有些慢，请耐心等待加载。",
	"双击主界面的药品，可以锁定或解除自动喝药",
	"羽化羽翼，可以提供大量属性，需要消耗羽毛或注灵值",
}
this.tipsTianti = "稍等片刻，战场生成中......"
this.TiantiAnimTime = 1
function SceneLoader:__init( ... )
	self.URL = "ui://37s0no48me2f5"
	self.ui = ui or self.ui or UIPackage.CreateObject("Loader", "AssetsLoader")
	self.icon = self.ui:GetChild("icon")
	self.progress = self.ui:GetChild("loaderBar")
	self.txt_title = self.progress:GetChild("txt_title") -- 下
	self.loadingTips = self.ui:GetChild("loadingTips") -- 上
	self.c1 = self.ui:GetController("c1")
	self.tiantiLeft = self.ui:GetChild("tiantiLeft")
	self.tiantiRight = self.ui:GetChild("tiantiRight")
	self.n18 = self.ui:GetChild("n18")
	self:SetTiantiShow(false)
	self:config()	
end
function SceneLoader:config()
	self.isOpen = true
	self.sceneCtrl = SceneController:GetInstance()
	self.progress.value = 5
	self.progress.max = 100
	self.autoGress = false
	self.parent = layerMgr:GetLoaderLayer()
	self.render = nil
	self._cameraready = true -- 摄像机完成
	self._mainPlayerEnter = false -- 主角入场
	self.ready = false -- 准备就序
	self.curDelay = os.clock()
	self:SetTips(this.tips[math.random(1, #this.tips)])
	self.loadCompleteCallback = nil --loading完成后的回调
	self.autoClose = false --不需要场景摄像头初始化完成，进度条满了，直接进入关闭流程，相当于一个纯粹的loading 调

	self.handler1=GlobalDispatcher:AddEventListener(EventName.MAIN_ROLE_ADDED, function ( data )
		self:MainRoleEnter(data)
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.CAMERA_READY, function ( data )
		self:CameraReady(data)
	end)
	
end

function SceneLoader:SetLoaderIcon()
	local strIcon = ""
	if this.isTianti then
		strIcon = "loader3"
	else
		if (math.random(1, 100000) % 2) == 0 then
			strIcon = "loader1"
		else
			strIcon = "loader"
		end
	end
	self.icon.url = StringFormat("Icons/Loader/{0}", strIcon)
end

function SceneLoader:CameraReady()
	self._cameraready = true
end

function SceneLoader:MainRoleEnter()
	self._mainPlayerEnter = true
end

function SceneLoader:OnProgress(v)
	self.progress.value = v
	if os.clock()-self.curDelay > 3 then
		self.curDelay = os.clock()
		self:SetTips(this.tips[math.random(1, #this.tips)])
	end
	if self._cameraready then
		if self.ready and (v/self.progress.max>0.8) then
			self.ready = false
			GlobalDispatcher:DispatchEvent(EventName.SCENE_LOAD_FINISH, SceneModel:GetInstance().sceneId)
		elseif self._mainPlayerEnter and (self.progress.max <= self.progress.value) then
			self:Close()
		end
	end

	if self.isAutoClose == true then
		if (self.progress.max <= self.progress.value) then
			if self.loadCompleteCallback ~= nil and type(self.loadCompleteCallback) == 'function' then
				self.loadCompleteCallback()
			end
			self:Close()
		end
	end
end
function SceneLoader:SetMax( v )
	self.progress.max = v or 100
end
function SceneLoader:SetTips( v )
	if this.isTianti then
		self.loadingTips.text = self.tipsTianti
	else
		self.loadingTips.text = v or ""
	end
end
function SceneLoader:SetTitle( v )
	self.txt_title.text = v or ""
end
function SceneLoader:SetAutoGress(b)
	self.autoGress = b
	if self.autoGress then
		RenderMgr.Remove(self.render)
		self.render = RenderMgr.Add(function ()
			local cur = math.min(self.progress.max, self.progress.value + Time.deltaTime *30)
			if cur >= self.progress.max then
				setupFuiOnceRender(self.progress, function ()
					self:Close()
				end, 90)
			end
			self:OnProgress(cur)
		end)
	end
end
function SceneLoader:SetFinishCallback( cb )
	self.cb = cb
end
function SceneLoader:Close(rm)
	if not self.isOpen  then return end
	self.isOpen = false
	self.ready = false
	self.isAutoClose = false
	self.loadCompleteCallback = nil

	if rm then
		self:RemoveFromParent()
	else
		GlobalDispatcher:DispatchEvent(EventName.SceneLoader_CLOSE)
		self:SetVisible( false )
	end
	RenderMgr.Remove(self.render)
	if this.isTianti then
		GlobalDispatcher:DispatchEvent(EventName.PLAYER_ADDED)
	end
end
function SceneLoader:Open()
	if self.parent and self.ui.parent == nil then 
		self.parent:AddChild(self.ui)
	end
	self.isOpen = true
	self:SetVisible( true )
end
function SceneLoader:__delete()
	self:Close(true)
	inst = nil
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
end
function SceneLoader:RemoveFromParent()
	if self.ui and self.ui.parent then
		self.ui:RemoveFromParent()
	end
end
function SceneLoader:SetVisible( visible )
	if self.ui ~= nil then
		self.ui.visible = visible
	end
end
function SceneLoader:GetVisible()
	if self.ui == nil then
		return false
	else
		return self.ui.visible
	end
end

function SceneLoader.SetInfo( autoGress, progress, max, title, tips )
	local loader = nil
	if inst == nil then
		loader = SceneLoader.New()
		inst = loader
	end
	loader = inst
	this.ShowProgress(true)
	if title then loader:SetTitle(title) end
	if max then loader:SetMax(max) end
	if progress then loader:OnProgress(progress) end
	if tips then loader:SetTips(tips) end

	loader:SetAutoGress(autoGress)
end
function SceneLoader.ShowProgress(v)
	if inst then
		inst.progress.visible = v
	end
end
function SceneLoader.ShowIcon(v)
	if inst then
		inst.icon.url = StringFormat("Icons/Loader/{0}", v)
	end
end
function SceneLoader.Show(bool, autoGress, progress, max, title, tips , isAutoClose , loadCompleteCallback)
	this.isTianti = SceneModel:GetInstance():IsTianti() and ( TiantiModel:GetInstance():GetPkPlayerMsg(false) ~= nil )
	if loadCompleteCallback ~= nil and type(loadCompleteCallback) == 'function' then
		inst.loadCompleteCallback = loadCompleteCallback
	end

	if isAutoClose ~= nil then
		inst.isAutoClose = isAutoClose
	end
	this.SetInfo( autoGress, progress, max, title, tips )
	inst:SetLoaderIcon()
	inst:SetTiantiShow(this.isTianti)
	if bool then
		inst._cameraready = false
		inst._mainPlayerEnter = false
		inst.ready = true
		inst:Open()
	else
		inst:Close()
	end
end
function SceneLoader.SetProgress(progress, max)
	if inst == nil then
		this.SetInfo( progress, max)
	else
		if max then
			inst:SetMax(max)
		end
		if progress then
			inst:OnProgress(progress)
		end
	end
end

function SceneLoader:SetTiantiShow(bShow)
	if not self.c1 then return end
	local tab = {self.tiantiLeft, self.tiantiRight}
	if bShow then
		self.c1.selectedIndex = 0
		self.c1.selectedIndex = 1
		local tiantiModel = TiantiModel:GetInstance()
		self:RefreshTiantiUI(self.tiantiLeft, tiantiModel:GetPkPlayerMsg(true), 1)
		self:RefreshTiantiUI(self.tiantiRight, tiantiModel:GetPkPlayerMsg(false), 2)
	else
		self.c1.selectedIndex = 0
	end
	for i = 1, #tab do
		tab[i].visible = bShow
	end
end

function SceneLoader:RefreshTiantiUI(ui, msg, idx)
	if not msg then return end
	local imgBg = ui:GetChild("imgBg")
	local imgRole = ui:GetChild("imgRole")
	local txtName = ui:GetChild("txtName")
	local txtLv = ui:GetChild("txtLv")
	local txtDuanwei = ui:GetChild("txtDuanwei")

	local careerMap = {2, 1, 3}
	local career = msg.career
	local strTab = {"zuo", "you"}
	local str = strTab[idx] .. careerMap[career]
	local urlBg = UIPackage.GetItemURL("Loader", str)
	imgBg.url = urlBg
	local urlRole = UIPackage.GetItemURL("Loader", "juese" .. careerMap[career])
	imgRole.url = urlRole
	txtName.text = msg.playerName or ""
	txtLv.text = StringFormat("Lv{0}", msg.level)
	local cfg = TiantiModel:GetInstance():GetStageCfg(msg.stage or 1)
	txtDuanwei.text = StringFormat("{0}{1}星", cfg.stageName, msg.star)
end