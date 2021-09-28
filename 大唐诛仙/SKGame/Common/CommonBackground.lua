-- 通用背景UI，支持的功能请看 __init下的变量
-- 注意，继承的UI面板，要重写Layout() 接口,Layout中实现UI的布局


CommonBackGround = BaseClass(BaseView)
CommonBackGround.__AssetsName = {[1] = "gold", [2] = "diamond", [3] = "stone", [4] = "bindDiamond", }
function CommonBackGround:__init()
	self.ui = UIPackage.CreateObject("Common","CustomBigGround")
	self._tabCtrl = self.ui:GetController("_tabCtrl")
	self._bg = self.ui:GetChild("bg")
	self._icon = self.ui:GetChild("icon")
	self._title = self.ui:GetChild("title")
	self._btnClose = self.ui:GetChild("close")
	self._topBg = self.ui:GetChild("topBg")
	self._topContainer = self.ui:GetChild("topContainer")

	self.openTopUI = false -- 打开顶部资产UI
	self.openResources = nil -- {1, 2, 3, 4} 打开类型[1 gold 金币,2 diamond 钻石,3 stone 宝玉,4 bindDiamond 代金卷] id 在这表中决定顺序
	self._resItems = {} -- 资产UI数列表

	self.useFade = true -- 淡出淡入效果
	self.isCenter = true -- 居中

	self._tabs = nil -- 标签内容
	self.tabBar = nil -- 标签页ui {label="oo", res0="", res1="", id="xx", red=true } -- red 红点提示 label 为文本内容， res0为默认(图标)， res1 为选中(图标) Icon/title下的
	self.defaultTabIndex = 0 -- 默认选中标签
	self.tabBarSelectCallback = nil -- 标签变化事件回调(返回 索引, id转字符型)

	self.titleName = nil -- 设置标题(文字)
	self.titleNameRes = nil -- 设置以图标形式出现标题(Icon/title路径下)

	self.showBtnClose = true -- 是否打开关闭按钮
	self.bgUrl = "bg_big0" --设置背景 bg_big0 有tab标签; bg_big1 无 tab标签 UIPackage.GetItemURL("pkName" ,"compname") uiurl ; 一般小弹窗背景

	self.isFinishLayout = false -- 是否UI布局完成

	self.container = self.ui -- 主容器(子类继承时，所有的容器)
	self.alphaBg = self.ui:GetChild("alpha")
	self.showAlphaBg = false

	--[[测试：
		self.titleName = "屌屌标题"
		self.titleNameRes = "Icon/Title/a1"
		self.showBtnClose = true
		self.openTopUI = true
		self.openResources = {1, 3, 2}
		self.tabBar = {{label=nil, res0="fb01", res1="fb00", id="366", red=true}, 
						{label="文字也可以", res0="bb01", res1="bb00", id="56"}, 
						{label="只是文字", res0="", res1="", id="100", red=true},
						{label="文字加背景", res0="bb01", res1="bb00", id="5fa6"},}
		self.defaultTabIndex = 1
		self.tabBarSelectCallback = function(idx, id) print(idx, id) end 
	--]]
end

-- 更新角色监听
function CommonBackGround:_AddEvent_() -- (是否监听全局事件打开指定视图面板)子类注册
	if not self.onRoleInitHandler then
		local function onRoleInit()
			if not self.isInited then return end
			self:_RegistRoleInit_()
		end
		self.onRoleInitHandler = GlobalDispatcher:AddEventListener(EventName.ROLE_INITED, onRoleInit)
	end
	self:_RegistRoleInit_()
end
-- 资产变化监听
function CommonBackGround:_RegistRoleInit_()
	local player = SceneModel:GetInstance():GetMainPlayer()
	if player then
		local function attrChange( k, v, old )
			if k == "gold" or k == "diamond" or k == "stone" or k == "bindDiamond" then
				self:_UpdateTopData_()
			end
		end
		player:RemoveEventListener(self.roleChange) -- 先清除
		self.roleChange = player:AddEventListener(SceneConst.OBJ_UPDATE, attrChange) --角色属性变化
	end
end
-- 移除
function CommonBackGround:_RemveRoleAssetListener_()
	local player = SceneModel:GetInstance():GetMainPlayer()
	if player then
		player:RemoveEventListener(self.roleChange) 
	end
end

-- 更新资产UI布局
function CommonBackGround:_LayoutTop_()
	self._topBg.visible = self.openTopUI
	self._topContainer.visible = self.openTopUI
	if not self.openTopUI then return end
	self:_AddEvent_()
	local offX = 0
	local offW = 0
	if #self.openResources >= 3 then
		offX = 880/#self.openResources
	elseif #self.openResources == 2 then
		offX = 220
		offW = 220
	elseif #self.openResources == 1 then
		offX = 0
		offW = 555
	end
	for i,v in ipairs(self.openResources) do
		local item = UIPackage.CreateObject("Common" , "MoneyLabelComp")
		self._resItems[v] = item
		self._topContainer:AddChild(item)
		item:SetXY(i * offX + offW, 0)

		self._resItems[v].icon="Icon/Goods/"..CommonBackGround.__AssetsName[v]

		item:GetChild("btnAdd").onClick:Add(function ()
			local data = {id="Chongzi", v=v}
			GlobalDispatcher:DispatchEvent(EventName.OPENVIEW, data)

			if not SHENHE then 
				if data.v == 1 then
					MallController:GetInstance():OpenMallPanel(nil, 0, 3)
				elseif data.v == 2 then
					MallController:GetInstance():OpenMallPanel(1, 2)
				end
			end 
		end)
		item:GetChild("btnAdd").visible = not SHENHE
	end
	self:_UpdateTopData_()
end
-- 内置更新资产UI数据
function CommonBackGround:_UpdateTopData_()
	local player = SceneModel:GetInstance():GetMainPlayer()
	if not player then return end
	if not TableIsEmpty(self.openResources) then
		for _,v in ipairs(self.openResources) do
			local isNeedGe = true --是否需要显示个位数
			if CommonBackGround.__AssetsName[v] == "gold" then isNeedGe = false end
			self._resItems[v].title = NumberGetString2(player[CommonBackGround.__AssetsName[v]] or 0 , isNeedGe)
		end
	end
end
-- 内置布局
function CommonBackGround:_Layout()
	if self.isFinishLayout then return end
	if not self.isInited then return end
	self:UpdateBgUrl() -- 背景
	self:SetBtnClose( self.showBtnClose) -- 显示关闭
	self:SetAlphaBgShow(self.showAlphaBg)

	self:_LayoutTop_() -- 资产
	if self.titleName then self._title.text = self.titleName end -- 标题
	if self.titleNameRes then self._icon.url = self.titleNameRes end

	self:_LayoutTabBar_()


	if self.Layout then
		self:Layout()
	end
	if self.container ~= self.ui then
		self.container:AddChild(self.ui)
		self.ui = self.container
	end

	self.isFinishLayout = true
end

function CommonBackGround:SetAlphaBgShow(isShow)
	self.alphaBg.visible = isShow
end

-- 设置右侧标签
function CommonBackGround:_LayoutTabBar_()
	if not self.tabBar then return end
	self._tabs = {}
	local isSelected = false
	for i, v in ipairs(self.tabBar) do
		local bar = UIPackage.CreateObject("Common" , "RadioBtn0")
		if v.label ~= nil and v.label ~= "" then bar.title = v.label end
		if v.res0 and v.res0 ~= "" then bar:GetChild("layer0").url = "Icon/Title/"..v.res0 end
		if v.res1 and v.res1 ~= "" then bar:GetChild("layer1").url = "Icon/Title/"..v.res1 end
		bar:GetChild("red").visible = v.red == true
		bar.data = tostring(v.id or i)
		self._tabs[i] = bar
		bar.x = 1106
		bar.y = i * 98 + 40
		self.container:AddChild(bar)
		self._tabCtrl:AddPage(tostring(bar.data))
		bar.relatedController = self._tabCtrl
		bar.pageOption.id = tostring(bar.data)
		bar.pageOption.name = tostring(bar.data)
		bar.pageOption.index = i-1
		if i == 1 and self.defaultTabIndex == 0 then
			bar.selected = true
			isSelected = true
			if self.tabBarSelectCallback then
				self.tabBarSelectCallback(self._tabCtrl.selectedIndex, self._tabCtrl.selectedPage)
			end
		end
	end
	self._tabCtrl.onChanged:Add(function ()
		EffectMgr.PlaySound("731001")
		if self.tabBarSelectCallback then
			self.tabBarSelectCallback(self._tabCtrl.selectedIndex, self._tabCtrl.selectedPage)
		end
	end)
	if not isSelected then
		self._tabCtrl.selectedIndex = self.defaultTabIndex
	end
end
-- 设置选中标签页
function CommonBackGround:SetSelectTabbar( idx )
	self._tabCtrl.selectedIndex = idx or self.defaultTabIndex
end
-- 重置标签位置
function CommonBackGround:SetTabarPos(offx, offy, visible)
	if not self.tabBar then return end
	for i, v in ipairs(self._tabs) do
		v.x = offx
		v.y = i * 93 + offy
	end
end
-- 对指定id显示红点
function CommonBackGround:SetTabarTips(id, bool)
	if not self.tabBar then return end
	for i, v in ipairs(self._tabs) do
		if v.data == tostring(id) then
			v:GetChild("red").visible = bool == true
		end
	end
end
-- 指定id显示隐藏标签
function CommonBackGround:SetTabbarVisible( id, bool )
	if not self.tabBar then return end
	ShowTabbar(self._tabs, id, bool)
end
-- 更新标题
function CommonBackGround:SetTitle(titleName, titleNameRes, x, y)
	if titleName and self.titleName ~= titleName then
		self.titleName = titleName
		self._title.text = self.titleName
	end
	if titleNameRes and self.titleNameRes ~= titleNameRes then
		self.titleNameRes = titleNameRes
		self._icon.url = self.titleNameRes
	end
	if x then self._title.x = x end
	if y then self._title.y = y end
	if x then self._icon.x = x end
	if y then self._icon.y = y end
end

function CommonBackGround:Layout()
	error("注意，继承的UI面板，要重写Layout() 接口,Layout中实现UI的布局")
end

-- 打开
function CommonBackGround:Open()
	self:_Layout()
	BaseView.Open(self)
end
-- 关闭
function CommonBackGround:Close()
	BaseView.Close(self)
end

-- 设置关闭按钮
function CommonBackGround:SetBtnClose( visible, x, y, res )
	if res ~= nil then self._btnClose.icon = res end
	if x ~= nil then self._btnClose.x = x end
	if y ~= nil then self._btnClose.y = y end
	if visible ~= nil then
		self._btnClose.visible = visible
		if visible then
			if not ToLuaIsNull(self._btnClose) then
				self._btnClose.sortingOrder = 10000
				self._btnClose.onClick:Add(function () self:Close() end)
			end
		end
	end
end
function CommonBackGround:GetBtnClose()
	return self._btnClose
end

-- 设置背景大小
function CommonBackGround:SetBgSize( w, h )
	setImgFillType( self._bg, 4 )
	self._bg:SetSize(w or 0, h or 0)
end
-- 设置背景
function CommonBackGround:UpdateBgUrl()
	if self.bgUrl == "bg_big0" or self.bgUrl == "bg_big1" then
		self._bg.url = "Icon/Common/"..self.bgUrl
		self:SetBtnClose( self.showBtnClose, 1170, 73, nil )
	else
		self._bg.url = self.bgUrl
	end
end
-- 增加装饰
function CommonBackGround:AddChouDai(x, y, zs)
	if not self.zsLayer then
		local url = "Icon/Common/"..(zs or "bg_ditu")
		self.zsLayer = UIPackage.CreateObject("Common" , "CustomSprite")
		self.zsLayer.icon = url
		self.ui:AddChild(self.zsLayer)
		self.zsLayer:SetXY(x or 74, y or 73)
		self.zsLayer:SetSize(1191,409)
		self.zsLayer.touchable = false
	end
end

-- 销毁
function CommonBackGround:__delete()
	self:_RemveRoleAssetListener_()
	GlobalDispatcher:RemoveEventListener(self.onRoleInitHandler)
	if self.tabBar then
		for _,v in pairs(self._tabs) do
			destroyUI(v)
		end
		self.tabBar = nil
	end
	self._tabs = nil
	self.isFinishLayout = false
	self.container = nil
	self.zsLayer = nil
	if not self.openTopUI then return end
	for _,v in pairs(self._resItems) do
		destroyUI(v)
	end
	self._resItems = nil
	self.openTopUI = false
	self.openResources = nil
end