--------------------------------------------------------
-- 鉴定提示  配置
--------------------------------------------------------

AuthenticateTipView = AuthenticateTipView or BaseClass(BaseView)

function AuthenticateTipView:__init()
	self.is_any_click_close = true
	self:SetModal(true)

end

function AuthenticateTipView:__delete()
end

--释放回调
function AuthenticateTipView:ReleaseCallBack()

	self.equip = nil
	self.quality_text = nil
end

--加载回调
function AuthenticateTipView:LoadCallBack(index, loaded_times)

	local path = ResPath.GetBigPainting("meiba_bg2")
	local bg = XUI.CreateImageView(0, 0, path, XUI.IS_PLIST)
	bg:setTouchEnabled(true)
	bg:setIsHittedScale(false)
	self.root_node:addChild(bg, 1)


	self.cell = BaseCell.New()
	self.cell:GetView():setPosition(-60, -90)
	self.root_node:addChild(self.cell:GetView(), 2)
	self:AddObj("cell")

	self.quality_text = XUI.CreateText(-20, 20, 100, 30, nil, "", nil, 22, COLOR3B.RED)
	self.root_node:addChild(self.quality_text, 3)

	local normal = ResPath.GetCommon("btn_close_2")
	local close_btn = XUI.CreateButton(260, 90, 0, 0, false, normal, nil, nil, XUI.IS_PLIST)
	self.root_node:addChild(close_btn, 2)

	-- 按钮监听
	XUI.AddClickEventListener(close_btn, BindTool.Bind(self.CloseHelper, self))


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function AuthenticateTipView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function AuthenticateTipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.quality_text then
		self.quality_text:setString("")
	end
	self.equip = nil
end

--显示指数回调
function AuthenticateTipView:ShowIndexCallBack(index)
	self:Flush()
end
----------视图函数----------

function AuthenticateTipView:SetData(equip)
	self.equip = equip
end

function AuthenticateTipView:OnFlush()
	self.cell:SetData(self.equip)
	local quality = self.equip and self.equip.authenticate and self.equip.authenticate.quality or 0
	local text = string.format("【%s】", Language.Authenticate.Quality[quality])
	self.quality_text:setString(text)
end

----------end----------

--------------------
