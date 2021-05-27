---------------------------------------------
-- 对称号生成的封装，支持自动识别动态还是静态
-- 图片，高度采用标准的选中框宽高度
---------------------------------------------
Title = Title or BaseClass()
function Title:__init()
	self.view = XUI.CreateLayout(0,0, 160, 70)
	self.view:setAnchorPoint(0.5, 0.5)

	self.title_word_id = 0
	self.title_id = -1
	self.is_gray = false
end

function Title:__delete()
end

function Title:GetView()
	return self.view
end

function Title:CreateTitle(title_id)
	self:SetTitleId(title_id)
end

function Title:SetTitleId(title_id)
	if self.title_id == title_id then return end

	self:RemoveAll()
	self.title_id = title_id

	if title_id >= 0 then
		self.view:setVisible(true)
		local eff_id = TitleData.GetTitleEffId(title_id)
		if eff_id ~= 0 then
			self:CreateTitleEffect(eff_id)
		end
	else
		self.view:setVisible(false)
	end
end

function Title:CreateTitleEffect(eff_id)
	if eff_id == nil or eff_id == "" then return end
	local size = self.view:getContentSize()
	local eff = RenderUnit.CreateEffect(eff_id, self.view, 10, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, size.width / 2, size.height / 2)
end

function Title:SetVisible(is_visible)
	self.view:setVisible(is_visible)
end

function Title:SetPosition(x, y)
	self.view:setPosition(x, y)
end

function Title:SetScale(scale)
	self.view:setScale(scale)
end

function Title:MakeGray(is_gray)
	self.is_gray = is_gray

	local child_list = self.view:getChildren()
	for _, node in pairs(child_list) do
		AdapterToLua:makeGray(node, is_gray)
	end
end

function Title:RemoveAll()
	self.title_id = -1
	self.view:removeAllChildren()
end

--获得当前的所得到的爬塔title的旧id，用于更换新的id
function Title:GetTitleOldId()
	if self.title_word_id == 0 then return nil 
	else
		return self.title_word_id
	end 
end
