--------------------------------------------------------
-- 装扮视图  配置 
--------------------------------------------------------

local FashionChildView = FashionChildView or BaseClass(SubView)

function FashionChildView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self:SetModal(true)

	if self.view_def == ViewDef.Fashion.FashionChild then
		self.btn_info = {
			ViewDef.Fashion.FashionChild.FashionResolve,
			ViewDef.Fashion.FashionChild.FashionExchange,
			ViewDef.Fashion.FashionChild.FashionPossession,
			ViewDef.Fashion.FashionChild.FashionPreview,
		}

		require("scripts/game/fashion/fashion_resolve_view").New(ViewDef.Fashion.FashionChild.FashionResolve) -- 装扮-分解
		require("scripts/game/fashion/fashion_exchange_view").New(ViewDef.Fashion.FashionChild.FashionExchange) -- 装扮-兑换
		require("scripts/game/fashion/fashion_possession_view").New(ViewDef.Fashion.FashionChild.FashionPossession) -- 装扮-拥有
		require("scripts/game/fashion/fashion_possession_view").New(ViewDef.Fashion.FashionChild.FashionPreview) -- 装扮-预览
	elseif self.view_def == ViewDef.Fashion.WuHuan then
		self.btn_info = {
			ViewDef.Fashion.WuHuan.WuHuanResolve,
			ViewDef.Fashion.WuHuan.WuHuanExchange,
			ViewDef.Fashion.WuHuan.WuHuanPossession,
			ViewDef.Fashion.WuHuan.WuHuanPreview,
		}
		require("scripts/game/fashion/fashion_resolve_view").New(ViewDef.Fashion.WuHuan.WuHuanResolve) -- 幻武-分解
		require("scripts/game/fashion/fashion_exchange_view").New(ViewDef.Fashion.WuHuan.WuHuanExchange) -- 幻武-兑换
		require("scripts/game/fashion/fashion_possession_view").New(ViewDef.Fashion.WuHuan.WuHuanPossession) -- 幻武-拥有
		require("scripts/game/fashion/fashion_possession_view").New(ViewDef.Fashion.WuHuan.WuHuanPreview) -- 幻武-预览

	elseif self.view_def == ViewDef.Fashion.ZhenQi then
		self.btn_info = {
			ViewDef.Fashion.ZhenQi.ZhenQiResolve,
			ViewDef.Fashion.ZhenQi.ZhenQiExchange,
			ViewDef.Fashion.ZhenQi.ZhenQiChild,
		}
		require("scripts/game/fashion/fashion_resolve_view").New(ViewDef.Fashion.ZhenQi.ZhenQiResolve) -- 真气-分解
		require("scripts/game/fashion/fashion_exchange_view").New(ViewDef.Fashion.ZhenQi.ZhenQiExchange) -- 真气-兑换
		require("scripts/game/fashion/fashion_zhenqi_view").New(ViewDef.Fashion.ZhenQi.ZhenQiChild) -- 真气-拥有
	elseif self.view_def == ViewDef.Fashion.Title then
		self.btn_info = {
			ViewDef.Fashion.Title.TitleCustom,
			ViewDef.Fashion.Title.TitlePossession,
			ViewDef.Fashion.Title.TitlePreview,
		}

		require("scripts/game/fashion/fashion_title_view").New(ViewDef.Fashion.Title.TitleCustom) -- 称号-定制
		require("scripts/game/fashion/fashion_title_view").New(ViewDef.Fashion.Title.TitlePossession) -- 称号-拥有
		require("scripts/game/fashion/fashion_title_view").New(ViewDef.Fashion.Title.TitlePreview) -- 称号-全部
	end
end

function FashionChildView:__delete()

end

--释放回调
function FashionChildView:ReleaseCallBack()

end

--加载回调
function FashionChildView:LoadCallBack(index, loaded_times)
	self:CreateTabbar()


	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChanged, self))
end

function FashionChildView:OpenCallBack()
	--播放声音
end

function FashionChildView:CloseCallBack(is_all)
	if self.tabbar then
		self.tabbar:GetView():setVisible(false)
	end
end

--显示指数回调
function FashionChildView:ShowIndexCallBack(index)
	for i, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(i)
		end
		local vis = ViewManager.Instance:CanOpen(v)
		self.tabbar:SetToggleVisible(i, vis)
		
		self:FlushRemind(i)
	end

	self.tabbar:GetView():setVisible(true)
end

function FashionChildView:OnFlush(param_list)

end

----------视图函数----------

function FashionChildView:CreateTabbar()
	local parent = self:GetRootNode()
	local ph = {x = 1062, y = 565, w = 10, h = 10} -- 锚点为0,0
	-- 标题文本
	local name_list = {}
	for k, v in ipairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	local is_vertical = false 		-- 按钮-垂直排列
	local path = ResPath.GetCommon("toggle_121")
	local font_size = 25 			-- 标题字体大小
	local is_txt_vertical = false	-- 文本-垂直排列
	local interval = 5 			-- 间隔
	
	local callback = BindTool.Bind(self.TabbarSelectCallBack, self)   -- 点击回调
	
	local tabbar = Tabbar.New()
	tabbar:SetSpaceInterval(interval)
	tabbar:SetAlignmentType(Tabbar.AlignmentType.Right)
	tabbar:CreateWithNameList(parent, ph.x, ph.y, callback, name_list, is_vertical, path, font_size, is_txt_vertical)
	self.tabbar = tabbar
	self:AddObj("tabbar")
end

----------end----------

function FashionChildView:TabbarSelectCallBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function FashionChildView:FlushRemind(index)
	local remind_name = self.btn_info[index].remind_name
	if remind_name then
		local remind_count = RemindManager.Instance:GetRemind(remind_name)
		self.tabbar:SetRemindByIndex(index, remind_count > 0)
	end
end

function FashionChildView:OnRemindChanged(remind_name, num)
	if self:IsOpen() and self.tabbar then
		for i, view_def in ipairs(self.btn_info) do
			if view_def.remind_name == remind_name then
				self:FlushRemind(i)
			end
		end
	end
end

--------------------

return FashionChildView
