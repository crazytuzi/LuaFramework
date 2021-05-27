SpriteTitleBoard = SpriteTitleBoard or BaseClass()

function SpriteTitleBoard:__init()
	self.root_title_node = XUI.CreateLayout(0, 0, 0, 0)
	self.title_list_view = {}

	self.height = 50
	self.vo = nil
end

function SpriteTitleBoard:__delete()
	for i = 1, 4 do
		if nil ~= self.title_list_view[i] then
			self.title_list_view[i]:DeleteMe()
		end
	end
end

function SpriteTitleBoard:CreateTitleEffect(vo)
	if nil == vo then return end
	self.vo = vo
	local selected_title = {}
	selected_title[1] = vo.use_jingling_titleid

	table.sort(selected_title, function(x,y)
			local a = TitleData.GetTitleConfig(x)
			local b = TitleData.GetTitleConfig(y)
			if a ~= nil and b ~= nil then
				return a.title_show_level < b.title_show_level
			end
		end)

	for i = 1, 4 do
		if self.title_list_view[i] == nil then
			self.title_list_view[i] = Title.New()
			self.root_title_node:addChild(self.title_list_view[i]:GetView())
		end
		self.title_list_view[i]:SetTitleId(selected_title[i] or 0)
	end
end

-- 过滤称号
function SpriteTitleBoard:FilterTitle(title_list)
	local selected_title = {}
	for k,v in pairs(title_list) do
		if TitleData.IsJingLingTitle(v) then
			selected_title[#selected_title + 1] = v
		end
	end

	return selected_title
end

function SpriteTitleBoard:RemoveTitleList()
	for i = 1, 4 do
		if nil ~= self.title_list_view[i] then
			self.title_list_view[i]:RemoveAll()
		end
	end
end

function SpriteTitleBoard:SetTitleListOffsetY(h)
	local offy =  self.height / 2 + h  + 30
	-- if nil ~= self.vo and self.vo.guild_id> 0 then
	-- 	offy = offy + 25
	-- end

	--人物变大后，该容器也被放大，外部传进来的高度不变。容器放大后，里面的子容器离容器0，0点位置间距表现上会被拉大
	--这种设计称号容器不合理。用下面代码可简单快速纠正这种不合理。
	offy = offy / self.root_title_node:getScale()

	self.title_list_view[1]:GetView():setPositionY(offy + 10)
	self.title_list_view[2]:GetView():setPositionY(offy + 70)
	self.title_list_view[3]:GetView():setPositionY(offy + 130)
	self.title_list_view[4]:GetView():setPositionY(offy + 190)
end

function SpriteTitleBoard:GetRootNode()
	return self.root_title_node
end

function SpriteTitleBoard:SetTitleVisible(is_visible)
	for i = 1, 4 do
		if self.title_list_view[i] then
			self.title_list_view[i]:SetVisible(is_visible)
		end
	end
end
