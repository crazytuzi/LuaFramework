--------------------------------------------------------
-- 特戒提示  配置
--------------------------------------------------------

SpecialRingTipView = SpecialRingTipView or BaseClass(BaseView)

function SpecialRingTipView:__init()
	self.texture_path_list[1] = 'res/xui/special_ring.png'
	self.is_any_click_close = true
	self:SetModal(true)
end

function SpecialRingTipView:__delete()
end

--释放回调
function SpecialRingTipView:ReleaseCallBack()
	self.fusion_lv = nil
end

--加载回调
function SpecialRingTipView:LoadCallBack(index, loaded_times)

	local path = ResPath.GetBigPainting("meiba_bg2")
	local bg = XUI.CreateImageView(0, 0, path, XUI.IS_PLIST)
	bg:setTouchEnabled(true)
	bg:setIsHittedScale(false)
	self.root_node:addChild(bg, 1)

	path = ResPath.GetCommon("bg_5")
	local bg_2 = XUI.CreateImageView(240, -50, path, XUI.IS_PLIST)
	bg_2:setTouchEnabled(true)
	bg_2:setIsHittedScale(false)
	self.root_node:addChild(bg_2, 2)

	path = ResPath.GetSpecialRing("fusion_lv_1")
	self.fusion_lv = XUI.CreateImageView(245, -30, path, XUI.IS_PLIST)
	self.fusion_lv:setTouchEnabled(true)
	self.fusion_lv:setIsHittedScale(false)
	self.root_node:addChild(self.fusion_lv, 3)

	self.cell = BaseCell.New()
	self.cell:GetView():setPosition(-60, -90)
	self.root_node:addChild(self.cell:GetView(), 2)
	self:AddObj("cell")

	local normal = ResPath.GetCommon("btn_close_2")
	local close_btn = XUI.CreateButton(260, 90, 0, 0, false, normal, nil, nil, XUI.IS_PLIST)
	self.root_node:addChild(close_btn, 2)

	-- 按钮监听
	XUI.AddClickEventListener(close_btn, BindTool.Bind(self.CloseHelper, self))
end

function SpecialRingTipView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SpecialRingTipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.equip = nil
end

--显示指数回调
function SpecialRingTipView:ShowIndexCallBack(index)
	self:Flush()
end
----------视图函数----------

function SpecialRingTipView:SetData(equip)
	self.equip = equip
end

function SpecialRingTipView:OnFlush()
	self.cell:SetData(self.equip)

	local fusion_lv = #self.equip.special_ring
	for i,v in ipairs(self.equip.special_ring) do
		if v.type == 0 then
			fusion_lv = fusion_lv - 1
		end
	end

	-- 通常fusion_lv不会为0
	if fusion_lv ~= 0 then
		self.fusion_lv:loadTexture(ResPath.GetSpecialRing("fusion_lv_" .. fusion_lv))
		self.fusion_lv:setVisible(true)
	else
		self.fusion_lv:setVisible(false)
	end
end

----------end----------

--------------------
