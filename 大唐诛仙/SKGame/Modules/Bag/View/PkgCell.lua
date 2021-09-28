-- 一个单位格子
PkgCell = BaseClass()

-- 初始一个普通物品UI (vo数据可以直接由 配置bid 重构出来)
function PkgCell:__init( root, vo, selectCallback )
	self.data = nil
	self.gid = 0 -- 格子id
	self.selectCallback = nil
	self.bgOutH = 0 -- 额外增加背景的突出大小
	self:LayoutNormalGoods(root)
	self:SetSelectCallback(selectCallback)
	self:AddSelectedLayer()
	self:SetData(vo)
end

-- 一般物品布局显示
function PkgCell:LayoutNormalGoods(root)
	self.ui = UIPackage.CreateObject("Common","GoodsItem")
	self.width = self.ui.width
	self.height = self.ui.height
	self.rare = self.ui:GetChild("bg")
	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
	self.mask = self.ui:GetChild("mask")
	self.red = self.ui:GetChild("red")
	self.leftTopLoader = self.ui:GetChild("leftTopLoader")

	self.wakanLevel = self.ui:GetChild("wakanLevel")

	self.wakanLevel.text = ""
	root:AddChild(self.ui)
end

function PkgCell:SetWakanLevel(level)
	if level ~= 0 then
		self.wakanLevel.text = "+"..level
	else
		self.wakanLevel.text = ""
	end
end

function PkgCell:SetLeftTopLoader(iconURL)
	self.leftTopLoader.url = iconURL or ""
end

function PkgCell:SetSize( w,h )
	self.width = w
	self.height = h
	if self.ui then
		self.ui:SetSize(w, h)
	end
end
function PkgCell:SetScale( x,y )
	if self.ui then
		self.ui:SetScale(x, y)
	end
end
-- 添加格子背景
function PkgCell:AddCellBg(x, y)
	if not self.bg then
		self.bgOutH = 18
		self.bg = UIPackage.CreateObject("Common" , "CustomSprite0")
		self.ui:AddChild(self.bg)
	end
	self.bg.icon = UIPackage.GetItemURL("Common" , "bg_itemcell")
	local bgW, bgH = 123, 123
	-- self.bg:SetXY(0, 0)
	self.red:SetXY(self.red.x-self.bgOutH, self.red.y+self.bgOutH+4)
	self.title:SetXY(self.title.x-self.bgOutH, self.title.y-self.bgOutH)

	self.bg:SetSize(bgW, bgH)
	self.ui:SetSize(bgW, bgH)

	self.icon:SetSize(self.width, self.height)
	self.rare:SetSize(self.width, self.height)
	-- self.title:SetSize(self.width, self.height)

	self.icon:SetXY(self.bgOutH, self.bgOutH)
	self.rare:SetXY(self.bgOutH, self.bgOutH)

	if self.selected then
		self.selected:SetXY(self.selected.x+self.bgOutH, self.selected.y+self.bgOutH)
	end

	self:SetXY(self.ui.x, self.ui.y)
	if not ToLuaIsNull(self.bg) then
		self.bg.sortingOrder = -1
	end

	self.width = bgW
	self.height = bgH
end

-- 设置位置
function PkgCell:SetXY(x, y)
	if self.ui then
		self.ui:SetXY(x, y)
	end
end
-- 设置可见
function PkgCell:SetVisible(bool)
	if self.ui then
		self.ui.visible = bool
	end
end
-- 设置可见
function PkgCell:GetX()
	if self.ui then
		return self.ui.x
	end
	return 0
end
-- 设置可见
function PkgCell:GetY()
	if self.ui then
		return self.ui.y
	end
	return 0
end

-- 显示红点
function PkgCell:ShowRed( bool )
	self.red.visible = bool
end

-- 添加增减箭头
function PkgCell:AddArrow( url, x, y )
	url = url or "Icon/Other/arrow_01"
	if not self.arrow then
		self.arrow = UIPackage.CreateObject("Common" , "CustomSprite0")
		self.ui:AddChild(self.arrow)
		self.arrow.visible = false
	end
	self.arrow.icon = url
	self.arrow:SetSize(22, 22)
	self.arrow:SetXY(self.icon.x + 10, self.icon.y + 10)
end
-- 显示箭头
function PkgCell:ShowArrow( bool )
	if self.arrow then
		self.arrow.visible = bool
	end
end

--更新箭头
function PkgCell:UpdateArrow()
	local data = self.data
	local info = PkgModel:GetInstance():GetEquipInfoByGoodsVo(data)
	if info then
		local score, equip = PkgModel:GetInstance():CompareScore(info)
		if score ~= 0 then
			self:AddArrow(StringFormat("Icon/Other/arrow_{0}1", score>0 and 1 or 0))
			self:ShowArrow(true)
		else
			self:ShowArrow(false)
		end
	else
		self:ShowArrow(false)
	end
end

-- 添加锁定
function PkgCell:AddLock(url, w, h, x, y)
	url = url or "Icon/Other/lock"
	if not self.lock then
		self.lock = UIPackage.CreateObject("Common" , "CustomSprite0")
		self.ui:AddChild(self.lock)
		self.lock.visible = false
	end
	self.lock.icon = url
	self.lock:SetSize(w or 44, h or 44)
	self.lock:SetXY(x or (self.width-self.lock.width)*0.5, y or (self.height-self.lock.height)*0.5)
end
-- 设置锁定状态
function PkgCell:SetLock(bool)
	if self.lock then
		self.lock.visible = bool
	end
end
-- 是否锁定状态
function PkgCell:IsLock()
	return self.lock and self.lock.visible
end

-- 添加绑定
function PkgCell:AddBind(url, w, h, x, y)
	url = url or "Icon/Other/bind"
	if not self.bind then
		self.bind = UIPackage.CreateObject("Common" , "CustomSprite0")
		self.ui:AddChild(self.bind)
		self.bind.visible = false
	end
	self.bind.icon = url
	self.bind:SetSize(w or 16, h or 16)
	self.bind:SetXY(x or self.icon.x + 8, y or self.ui.height-24 - self.icon.y)
end
-- 设置绑定状态
function PkgCell:SetBind(bool)
	if self.bind then
		self.bind.visible = bool
	end
end

-- 添加选中
function PkgCell:AddSelectedLayer(url, w, h, x, y)
	url = url or "Icon/Common/grid_cell_selected"
	if not self.selected then
		self.selected = UIPackage.CreateObject("Common" , "CustomSprite0")
		self.ui:AddChild(self.selected)
		self.selected.visible = false
	end
	self.selected.icon = url
	self.selected:SetSize(w or 102, h or 102)
	self.selected:SetXY(x or -7, y or -7)
end
-- 设置选中状态
function PkgCell:SetSelected(bool)
	if self.selected then
		self.selected.visible = bool
	end
end
-- 设置回调
function PkgCell:SetSelectCallback( selectCallback )
	self.selectCallback = selectCallback
	if selectCallback then
		if not self._openClick then
			self:SetClickEngine(true)
		end
	end
end

function PkgCell:SetClickEngine(bool, isUp)
	if bool then
		self._openClick = true
		self.ui.onClick:Add(function ( e )
			self:ShowRed(false)
			if self.data then
				self.data.isNew = false
			end
			if self.selectCallback then
				self.selectCallback(self)
			end
			if self._showTips then -- 如果加了提示开关在点击回调弹出提示
				self:ShowTips(isUp)
			end
		end)
	else
		self._openClick = false
		self.ui.onClick:Clear()
	end
end
-- 设置查看其他玩家信息
function PkgCell:SetOtherInfo( otherInfo )
	self.otherInfo = otherInfo
	if otherInfo.wakanLevel then
		self:SetWakanLevel(otherInfo.wakanLevel)
	end
end
--  开启长按松开提示操作
function PkgCell:SetupPressShowTips(isPressShowTip, delay)
	self.isPressShowTip = isPressShowTip
	local key = self.ui.id
	self.tip = nil
	if isPressShowTip then
		self.ui.onTouchBegin:Add(function ()
			RenderMgr.AddInterval(function ()
				self.tip = CustomTipLayer.Show(self.data, self._useompare, self.tipsType, self.otherInfo)
			end, key, delay or 0.5, delay or 0.5)
		end)
		self.ui.onTouchEnd:Add(function ()
			RenderMgr.Realse(key)
			if self.tip and self.tip.ui then
				UIMgr.HidePopup(self.tip.ui)
				self.tip = nil
			end
		end)
	else
		self.ui.onTouchBegin:Clear()
		self.ui.onTouchEnd:Clear()
	end
end
-- 主动显示提示
function PkgCell:ShowTips(isUp)
	if not self.data then return end
	self.tip = CustomTipLayer.Show(self.data, self._useompare, self.tipsType, self.otherInfo, isUp)
end

-- 设置提示类型
function PkgCell:SetTipsType(t)
	self.tipsType = t
	if not self.isPressShowTip then
		self:OpenTips(true, self._useompare)
	else
		self:OpenTips(false, self._useompare)
	end
end

-- 开启tips回调(是否有提示弹出及比较)
function PkgCell:OpenTips( bool, useompare, isUp )
	self._showTips = bool
	self._useompare = (useompare and bool)
	if bool and not self._openClick then
		self:SetClickEngine(true, isUp)
	end
end

-- 显示数量
function PkgCell:SetNum( v )
	if v == 0 or v == 1 then
		v = ""
	end
	self.title.text = tostring(v)
end

-- 显示数量2
function PkgCell:SetNum2( v )
	self.title.text = v
end

function PkgCell:SetNumFontSize(size)
	local tf = self.title.textFormat
	if tf and tf.size then
		tf.size = size or 12
	end
end

-- 显示品质或置空状态(nil表示不用底)
function PkgCell:SetRare( rare )
	if rare ~= nil then
		self.rare.url = "Icon/Common/grid_cell_"..rare
	else
		self.rare.url = nil
	end
end

-- 显示物品图标(t物品类型， 表id数据)
function PkgCell:SetIcon( t, id )
	if t ~= 0 then
		self.icon.url = GoodsVo.GetIconUrl(t, id)
	else
		self.icon.url = nil
	end
	
end

function PkgCell:SetIconUrl(url)
	self.icon.url = url
end

-- 设置隐藏图标数据(类型筛选时处理)
function PkgCell:SetHideGoods( bool )
	if bool then
		self.hideData = self.data
		self.data = nil
	else
		self.data = self.hideData
	end
	self:Update()
end

-- 设置数量显示状态
function PkgCell:SetNumVisible( bool )
	self.ui:GetChild("title").visible = bool == true
end

-- 设置颜色
function PkgCell:SetColor(color)
	if self.icon then
		self.icon.color = color
		self.rare.color = color
	end
end

-- 清空数据
function PkgCell:Clear()
	self:SetMask(false)
	self.data = nil
	self:SetNum(0)
	self:SetRare(0)
	self:SetIcon(0, 0)
	self:SetBind(false)
	self:ShowRed(false)
	self:ShowArrow(false)
end

-- 重置数据(vo数据可以直接由 配置bid 重构出来)
function PkgCell:SetData( vo )
	self.data = vo
	self:Update()
end
-- t类型(对应GoodsVo)， 表id数据 num:数量， bind 1是0非
function PkgCell:SetDataByCfg( t, id, num, bind )
	local vo = GoodsVo.New()
	vo:SetCfg(t, id, num, bind)
	self:SetData(vo)
end
function PkgCell:GetData()
	return self.data
end
-- 更新数据
function PkgCell:Update()
	local data = self.data
	if data == nil then
		self:Clear()
		return
	else
		self:SetMask(false)
		if not GoodsVo.IsRoleCareerData( data.bid ) then
			self:SetMask(true)
		end
	end
	self:SetNum(NumberGetString(data.num))
	self:SetBind(data.isBinding == 1)
	self:SetIcon(data.goodsType, data.bid)
	self:SetRare(GoodsVo.GetRare(data.goodsType, data.bid))
	
end

function PkgCell:SetEnabled(bl)
	self.ui.enabled = bl
end

function PkgCell:SetGrayed(bl)
	self.ui.grayed = bl
end

function PkgCell:GetSize()
	return self.width, self.height
end

function PkgCell:SetMask(bl)
	-- if self.mask then
	-- 	self.mask.visible = bl
	-- end
end

-- 销毁
function PkgCell:__delete()
	if self._showTips then
		if self.tip and not ToLuaIsNull(self.tip.ui) then
			UIMgr.HidePopup(self.tip.ui)
		end
	end
	self.tip = nil
	destroyUI(self.ui)
	self.ui = nil
	self.rare = nil
	self.icon = nil
	self.title = nil
	self.red = nil
	self.selected = nil
end