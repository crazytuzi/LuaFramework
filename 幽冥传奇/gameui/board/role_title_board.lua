RoleTitleBoard = RoleTitleBoard or BaseClass()
local DUOBAO_TITLE_ID = 28
function RoleTitleBoard:__init()
	self.root_title_node = XUI.CreateLayout(0, 0, 0, 0)
	self.title_list_view = {}

	self.height = 50
	self.vo = nil
end

function RoleTitleBoard:__delete()
	for i = 1, 2 do
		if nil ~= self.title_list_view[i] then
			self.title_list_view[i]:DeleteMe()
		end
	end
end

function RoleTitleBoard:CreateTitleEffect(vo)
	if nil == vo then return end
	self.vo = vo
	local selected_title = self:FilterTitle(self.vo[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE])

	table.sort(selected_title, function(x,y)
			local a = TitleData.GetHeadTitleConfig(x)
			local b = TitleData.GetHeadTitleConfig(y)
			if a ~= nil and b ~= nil then
				if a.titleId ~= b.titleId then
					if a.titleId == DUOBAO_TITLE_ID then
						return true
					elseif b.titleId == DUOBAO_TITLE_ID then
						return false
					end
				end
				return a.titleId < b.titleId
			end
		end)

	-- self:EvilTitleFilter(selected_title, vo.name_color)
	for i = 1, 2 do
		if self.title_list_view[i] == nil then
			self.title_list_view[i] = Title.New()
			self.title_list_view[i]:SetScale(0.6)
			self.root_title_node:addChild(self.title_list_view[i]:GetView())
		end
		self.title_list_view[i]:SetTitleId(selected_title[i] or 0)
	end
end

-- 过滤称号
function RoleTitleBoard:FilterTitle(head_title)
	if nil == head_title then return {} end
	local title_1 = bit:_and(head_title, 0xff)
	local title_2 = bit:_rshift(bit:_and(head_title, 0xff00), 8)
	selected_title = {}
	if title_1 > 0 then
		table.insert(selected_title, title_1)
	end
	if title_2 > 0 then
		table.insert(selected_title, title_2)
	end

	return selected_title
end

-- 恶名称号过滤
function RoleTitleBoard:EvilTitleFilter(selected_title, name_color)
	local evil_title = 0 
	if name_color > EvilColorList.NAME_COLOR_RED_1 then
		if name_color == EvilColorList.NAME_COLOR_RED_2 then
			evil_title = COMMON_CONSTS.EVIL_TITLE_2
		elseif name_color == EvilColorList.NAME_COLOR_RED_3 then
			evil_title = COMMON_CONSTS.EVIL_TITLE_3
		end
	end
	if evil_title > 0 then
		local title_count = 0
		for k, v in pairs(selected_title) do
			if v > 0 then
				title_count = title_count + 1
			end
		end
		if title_count == 3 or nil == selected_title[1] or selected_title[1] == COMMON_CONSTS.EVIL_TITLE_1 or selected_title[1] == COMMON_CONSTS.EVIL_TITLE_2 then
			selected_title[1] = evil_title		
		else
			table.insert(selected_title, 1, evil_title)
		end
	end
end

function RoleTitleBoard:RemoveTitleList()
	for i = 1, 2 do
		if nil ~= self.title_list_view[i] then
			self.title_list_view[i]:RemoveAll()
		end
	end
end

function RoleTitleBoard:SetTitleListOffsetY(h)
	local offy =  self.height / 2 + h
	--人物变大后，该容器也被放大，外部传进来的高度不变。容器放大后，里面的子容器离容器0，0点位置间距表现上会被拉大
	--这种设计称号容器不合理。用下面代码可简单快速纠正这种不合理。
	offy = offy / self.root_title_node:getScale()
	offy = offy + (Scene.Instance:GetSceneLogic() and Scene.Instance:GetSceneLogic():GetObjNameBoardHeight(self.vo) or 0)
	self.title_list_view[1]:GetView():setPositionY(offy + 40)
	self.title_list_view[2]:GetView():setPositionY(offy + 90)
end

function RoleTitleBoard:GetRootNode()
	return self.root_title_node
end

function RoleTitleBoard:SetTitleVisible(is_visible)
	for i = 1, 2 do
		if self.title_list_view[i] and self.title_list_view[i].title_id ~= DUOBAO_TITLE_ID then
			self.title_list_view[i]:SetVisible(is_visible)
		end
	end
end
