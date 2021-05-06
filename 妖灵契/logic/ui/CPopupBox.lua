local CPopupBox = class("CPopupBox", CBox)

CPopupBox.EnumMode =
{
	SelectedMode = 1,
	NoneSelectedMode = 2
}

function CPopupBox.ctor(self, obj, mode, selectIndex, isHideTouchOut)
	CBox.ctor(self, obj)
	self.m_ButtonBg = self:NewUI(1, CSprite)
	self.m_MainBtn = self:NewUI(2, CButton, true ,false)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_MainLabel = self:NewUI(5, CLabel)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self.m_FlagIcon = self:NewUI(7, CSprite)

	self.m_Index = 1
	self.m_Mode = CPopupBox.EnumMode.SelectedMode
	self.m_SelectedSubMenu = nil
	self.m_SelectedIndex = -1
	self.m_Callback = nil
	self.m_Menus = {}
	self.m_IsOpen = false
	self.m_IsHideTouchOut =  isHideTouchOut or false
	self.m_OffsetHeight = 0
	self.m_HidePopupBoxCb = nil
	self.m_RepositionWhenOpen = false
	self.m_MainBtnCb = nil
	self.m_isAni = false

	if self.m_IsHideTouchOut == true then
		g_UITouchCtrl:TouchOutDetect(self, callback(self, "HidePopupBox"))
	end

	if mode ~= nil then
		self.m_Mode = mode
	end

	if selectIndex ~= nil then
		self.m_SelectedIndex = selectIndex	
	end

	if self.m_Mode == CPopupBox.EnumMode.NoneSelectedMode then
		local selectSpre = self.m_BoxClone:NewUI(2, CSprite)
		selectSpre:SetActive(false)
	end

	self.m_BoxClone:SetActive(false)
	self.m_TweenHeight = self.m_ButtonBg:GetComponent(classtype.TweenHeight)
	self.m_FlagIcon.Tween = self.m_FlagIcon:GetComponent(classtype.TweenRotation)
	self.m_MainBtn:AddUIEvent("click", callback(self, "ClickMainButton"))
end

--设置回调，回调函数带参以方便返回当前控件 
--example:OnValueChange(oBox)
--@param cb 回调函数
function CPopupBox.SetCallback(self, cb)
	self.m_Callback = cb
end

--设置父菜单的文本
function CPopupBox.SetMainMenu(self, sMenu)
	self.m_MainLabel:SetText(sMenu)
end

function CPopupBox.GetMenuText(self)
	return self.m_MainLabel:GetText()
end

--清空弹出列表
function CPopupBox.Clear(self, iSelectIndex)
	self.m_Index = 1
	self.m_SelectedIndex = iSelectIndex or -1
	self.m_SelectedSubMenu = nil
	self.m_BtnGrid:Clear()
	self.m_Callback = nil
	self:ResizeBg()
	self.m_ScrollView:ResetPosition()
	--如果是在动画中，清空弹出框，则先回归动画状态
	if self.m_isAni then
		self.m_TweenHeight:Toggle()
		self.m_ButtonBg:SetActive(false)
		self.m_isAni = false	
	end
end

--[[添加子菜单数据，默认选中第一个子菜单
	@param sMenu 子菜单文本
	@param dExtra 子菜单绑定的额外数据
	@param sMenuSprName 图片形式的选项
	@param isCloseMenu 点击此选项时，是否隐藏菜单]]
function CPopupBox.AddSubMenu(self, sMenu, dExtra, sMenuSprName, isHideMenu)
	local box = self.m_BoxClone:Clone(false)
	box.m_Label = box:NewUI(1, CLabel)
	box.m_Sprite = nil
	box.m_Label:SetText(sMenu)
	box.m_ExtraData = dExtra
	box.m_Index = self.m_Index

	if sMenuSprName ~= nil then
		box.m_Sprite = box:NewUI(3, CSprite)		
		box.m_Sprite:SetSpriteName(sMenuSprName)
	end
	box:SetGroup(self:GetInstanceID())
	local callback = function()
		self:ClickSubMenu(box, isHideMenu)
	end
	
	box:AddUIEvent("click", callback)
	box:SetActive(true)
	self.m_BtnGrid:AddChild(box)
	self:ResizeBg()

	--如果selectindex 有默认值，则设置默认值
	if self.m_SelectedIndex	 ~= -1 then
		if self.m_SelectedIndex == self.m_Index then
			self:SetSelectedIndex(self.m_SelectedIndex, true)
		end
	end

	self.m_Index = self.m_Index + 1
end

function CPopupBox.ClickSubMenu(self, oMenu, isHideMenu)
	if self.m_BtnGrid.m_IsInitAni == true and self.m_isAni == true then
		return
	end
	self:SetSelectedIndex(oMenu.m_Index)
	if isHideMenu ~= false then
		self.m_FlagIcon.Tween:Toggle()
		self.m_IsOpen = false
		self:ShowAniToggle(self.m_IsOpen)			
		if self.m_HidePopupBoxCb then
			self.m_HidePopupBoxCb()
		end
	end
end

--设置选定的下标
function CPopupBox.SetSelectedIndex(self, iIndex, isAddMenu)
	local oMenu = self.m_BtnGrid:GetChild(iIndex)
	if not oMenu then
		print("not index .."..iIndex)
		return
	end
	print("index .."..iIndex)

	if (self.m_ButtonBg:GetActive() or isAddMenu == true) and self.m_Mode == CPopupBox.EnumMode.SelectedMode then
		oMenu:SetSelected(true)
	end

	self.m_SelectedSubMenu = oMenu
	self.m_SelectedIndex = oMenu.m_Index

	if self.m_Mode	~= CPopupBox.EnumMode.NoneSelectedMode	then
		self:SetMainMenu(oMenu.m_Label:GetText())
	end

	if self.m_Callback then
		self.m_Callback(self)
	end
end

--设置选定下标，不回调
function CPopupBox.ChangeSelectedIndex(self, iIndex)
	local oMenu = self.m_BtnGrid:GetChild(iIndex)
	if not oMenu then
		print("not index .."..iIndex)
		return
	end

	print("index .."..iIndex)
	
	if self.m_ButtonBg:GetActive() and self.m_Mode	== CPopupBox.EnumMode.SelectedMode then
		oMenu:SetSelected(true)
	end

	self.m_SelectedSubMenu = oMenu
	self.m_SelectedIndex = oMenu.m_Index
	if self.m_Mode	~= CPopupBox.EnumMode.NoneSelectedMode	then
		self:SetMainMenu(oMenu.m_Label:GetText())
	end
end

--返回选中的子菜单
--@return 子菜单
function CPopupBox.GetSelectedSubMenu(self)
	return self.m_SelectedSubMenu
end

--返回选中的子菜单下标
--@return 子菜单下标
function CPopupBox.GetSelectedIndex(self)
	return self.m_SelectedIndex
end

--返回子菜单的额外数据
--@return extradata,失败为nil
function CPopupBox.GetExtraDataFromSubMenu(self, oSubMenu)
	if oSubMenu then
		return oSubMenu.m_ExtraData
	end
	return nil
end

function CPopupBox.ResizeBg(self)
	local _,h = self.m_BtnGrid:GetCellSize()
	local _,upperH = self.m_ScrollView:GetSize()
	local iLineAmount = self.m_BtnGrid:GetMaxPerLine()
	if iLineAmount < 1 then
		iLineAmount = 1
	end
	self.m_TweenHeight.to = math.min(self.m_Index * h / iLineAmount + 15 + self.m_OffsetHeight , upperH + self.m_OffsetHeight)
end

--设置popupbox伸缩的偏移高度
function CPopupBox.SetOffsetHeight(self, height )
	height = height or 0
	self.m_OffsetHeight = height
	self:ResizeBg()
end

function CPopupBox.ClickMainButton(self)
	if self.m_BtnGrid.m_IsInitAni == true and self.m_isAni == true then
		return
	end

	self.m_IsOpen = not self.m_IsOpen
	self:ChangeSelectedIndex(self.m_SelectedIndex)
	if self.m_RepositionWhenOpen then
		self:ResetPosition()
	end
	self:ShowAniToggle(self.m_IsOpen, true)	
	
	if self.m_MainBtnCb then
		self.m_MainBtnCb(self.m_IsOpen)
	end
end

function CPopupBox.HidePopupBox(self )
	if self.m_BtnGrid.m_IsInitAni == true and self.m_isAni == true then
		return
	end

	if self.m_IsOpen and self.m_IsHideTouchOut == true then
		self.m_FlagIcon.Tween:Toggle()
		self.m_IsOpen = false
		self:ShowAniToggle(self.m_IsOpen)			
		if self.m_HidePopupBoxCb then
			self.m_HidePopupBoxCb()
		end		
	end	
end

function CPopupBox.ResetPosition(self)
	self.m_BtnGrid.m_UIGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CPopupBox.SetHidePopupBoxCb(self, cb)
	self.m_HidePopupBoxCb = cb
end

--设置每次弹出列表时是否重置位置，不重置的话拖动会有问题
function CPopupBox.SetRepositionWhenOpen(self, status)
	self.m_RepositionWhenOpen = status
end

function CPopupBox.AddMainBtnCallBack(self, cb)
	self.m_MainBtnCb = cb
end

--弹出动画相关开始
function CPopupBox.ShowAniConfig(self)
	self.m_BtnGrid:SetRepositionLaterEnable(false)
end

function CPopupBox.SetPopupShowAni(self, isDown)
	self.m_BtnGrid.m_IsInitAni = true
	self.m_BtnGrid.drection = isDown	
	local cnt = self.m_BtnGrid:GetCount()
	local w, h = self.m_BtnGrid:GetCellSize()
	for i = 1, cnt do
		local oBox = self.m_BtnGrid:GetChild(i)
		if oBox then
			if isDown then
				oBox:SetLocalPos(Vector3.New(0, h, 0))
			else
				oBox:SetLocalPos(Vector3.New(0, -h, 0))
			end
		end
	end
end

function CPopupBox.ShowAniToggle(self, isOpen, mainBtnClick)
	--设置动画处理
	if self.m_BtnGrid.m_IsInitAni == true then
		self.m_isAni = true		
		--如果是打开菜单，按钮背景的动画先执行
		if isOpen then
			self.m_ButtonBg:SetActive(true)
			self.m_TweenHeight.duration =  0.3
			self.m_TweenHeight:Toggle()
			local wrap = function ()
				self.m_isAni = false
			end
			Utils.AddTimer(wrap, 0, self.m_TweenHeight.duration)			
		end
		--按钮移动动画
		local w, h = self.m_BtnGrid:GetCellSize()
		local cnt = self.m_BtnGrid:GetCount()
		for i = 1, cnt do
			local oBox = self.m_BtnGrid:GetChild(i)				
			if oBox then
				if oBox.m_Timer then
					Utils.DelTimer(oBox.m_Timer)
					oBox.m_Timer = nil
				end
				if isOpen then					
					local wrap = function ()
						if not Utils.IsNil(oBox) then
							if self.m_BtnGrid.drection then
								DOTween.DOLocalMove(oBox.m_Transform, Vector3.New(0, - (i - 1) * h, 0), 0.3)
							else
								DOTween.DOLocalMove(oBox.m_Transform, Vector3.New(0, (i - 1) * h, 0), 0.3)
							end														
						end
					end
					oBox.m_Timer = Utils.AddTimer(wrap, 0, (cnt - i) * 0.1)
				else
					self.m_TweenHeight.duration = 0.12
					local wrap = function ()
						if not Utils.IsNil(oBox) then		
							if i == cnt then
								self.m_TweenHeight:Toggle()
								local wrap = function ()
									if not Utils.IsNil(self.m_ButtonBg) then
										self.m_isAni = false
										self.m_ButtonBg:SetActive(false)
									end
								end
								Utils.AddTimer(wrap, 0, self.m_TweenHeight.duration)
							end
							if self.m_BtnGrid.drection then
								DOTween.DOLocalMove(oBox.m_Transform, Vector3.New(0, h, 0), 0.3)
							else
								DOTween.DOLocalMove(oBox.m_Transform, Vector3.New(0, -h, 0), 0.3)
							end													
						end
					end
					oBox.m_Timer = Utils.AddTimer(wrap, 0, i * 0.1)
				end
			end	
		end

	--没有设置动画处理
	else
		if mainBtnClick then
			return
		end
		if isOpen then
			self.m_ButtonBg:SetActive(true)
			self.m_TweenHeight:Toggle()
		else
			self.m_TweenHeight:Toggle()
			local wrap = function ()
				if not Utils.IsNil(self.m_ButtonBg) then
					self.m_ButtonBg:SetActive(false)
				end			
			end
			Utils.AddTimer(wrap, 0, self.m_TweenHeight.duration)
		end
	end
end
--弹出动画相关结束

function CPopupBox.SetMenuItemLabelSize(self, selIdx, selSize, norSize)
	for i = 1, self.m_BtnGrid:GetCount() do
		local oBox = self.m_BtnGrid:GetChild(i)
		if oBox and oBox.m_Label then
			if selIdx == i then
				oBox.m_Label:SetFontSize(selSize)
			else
				oBox.m_Label:SetFontSize(norSize)
			end
		end
	end
end

return CPopupBox