----------------------------------------------------
-- 描述显示
----------------------------------------------------
DescTip = DescTip or BaseClass(BaseView)

function DescTip:__init(tilte, content, ok_func, cancel_func, close_func, has_checkbox, is_show_action, is_any_click_close)
	self.ui_config = {"uis/views/tips/baptize_tips_prefab", "Baptize_Tips"}
	DescTip.Instance = self
	self.bg_btn = nil
	self.content_txt = nil
	self.content_str = nil
	self.title_txt = nil
	self.title_str = nil
end


function DescTip:__delete()
	DescTip.Instance = nil
	self.bg_btn = nil
	self.content_txt = nil
	self.content_str = nil
	self.title_txt = nil
	self.title_str = nil
end

function DescTip:OpenCallBack()
	self:Refresh()
end

function DescTip:ReleaseCallBack()
	self.content_txt = nil
	self.content_str = nil
	self.title_txt = nil
	self.title_str = nil
end

function DescTip:LoadCallBack()
	local bg = self:FindObj("bg")
	bg.button:AddClickListener(BindTool.Bind(self.OnClickCloseBtn, self))

	local colse_btn = self:FindObj("close")
	colse_btn.button:AddClickListener(BindTool.Bind(self.OnClickCloseBtn, self))

	self.title_txt = self:FindObj("title")
	self.content_txt = self:FindObj("content")
end

function DescTip:OnClickCloseBtn()
	self:Close()
end

function DescTip:Refresh()
	if nil ~= self.content_txt then
		self.content_txt.text.text = self.content_str
	end
	if nil ~= self.title_txt then
		self.title_txt.text.text = self.title_str
	end
end

-- 设置标题
function DescTip:SetTitle(str)
	if nil ~= str and "" ~= str then
		self.title_str = str
		if nil ~= self.title_txt then
			self.title_txt.text.text = self.title_str
		end
	end
end

-- 设置内容
function DescTip:SetContent(str)
	if nil ~= str and "" ~= str then
		self.content_str = str
		if nil ~= self.content_txt then
			self.content_txt.text.text = self.content_str
		end
	end
end