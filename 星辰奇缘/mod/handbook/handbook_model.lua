-- -------------------------------------
-- 幻化收藏手册
-- hosr
-- -------------------------------------
HandbookModel = HandbookModel or BaseClass(BaseModel)

function HandbookModel:__init()
	self.mainWin = nil

	self.getNew = nil
	-- 按阶级分开存放数据
	self.gradeTab = nil
	-- 组合当前数量
	self.matchTab = nil
	-- 当前挑战组合id
	self.jumpMatchId = 0
	-- 客户端需求
	self.needlist = {}
end

function HandbookModel:OpenMain(args)
	if self.mainWin == nil then
		self.mainWin = HandbookMainWindow.New(self)
	end
	self.mainWin:Open(args)
end

function HandbookModel:CloseMain()
	if self.mainWin ~= nil then
		WindowManager.Instance:CloseWindow(self.mainWin)
	end
	-- self.mainWin = nil
end

-- 获得新图鉴展示
function HandbookModel:ShowGetNew(args)
	if self.getNew == nil then
		self.getNew = HandbookGetNew.New(function() self:CloseGetNew() end)
	end
	self.getNew:Show(args)
end

function HandbookModel:CloseGetNew()
	if self.getNew ~= nil then
		self.getNew:DeleteMe()
		self.getNew = nil
	end
end



function HandbookModel:OpenSelect(args)
	if self.selectPanel == nil then
		self.selectPanel = HandBookMergeSelePanel.New(self, self.mainWin)
	end
	self.selectPanel:Show(args)
end

function HandbookModel:CloseSelect()
	if self.selectPanel ~= nil then
		self.selectPanel:DeleteMe()
		self.selectPanel = nil
  end
end

-- -----------------------------------
-- 配置数据处理
-- -----------------------------------
function HandbookModel:FormatData()
	self.gradeTab = {}
	for _,v in pairs(DataHandbook.data_base) do
		if self.gradeTab[v.lev] == nil then
			self.gradeTab[v.lev] = {}
		end
		table.insert(self.gradeTab[v.lev], v)
	end
	self:FormatMatch()
end

-- 刷新已有组合数量
function HandbookModel:FormatMatch()
	self.matchTab = {}
	for id,handbook in pairs(HandbookManager.Instance.handbookTab) do
		if handbook.status == HandbookEumn.Status.Active then
			local base = DataHandbook.data_base[id]
			for _,matchId in ipairs(base.set_id) do
				if self.matchTab[matchId] == nil then
					self.matchTab[matchId] = 0
				end
				self.matchTab[matchId] = self.matchTab[matchId] + 1
			end
		end
	end
end

-- 根据阶段获取卡片数据列表
function HandbookModel:GetGradeData(grade)
	return self.gradeTab[grade]
end

function HandbookModel:InitNeedData(data)
	-- local str = PlayerPrefs.GetString("HandbookNeed")
	-- if str ~= nil and str ~= "" then
	-- 	self.needlist = BaseUtils.unserialize(str)
	-- end
	for k,v in pairs(data.need_list) do
		if v.id ~= 28607 and v ~= 28608 then
			self.needlist[v.id] = "1"
		end
	end
	EventMgr.Instance:Fire(event_name.handbook_infoupdate)
end

function HandbookModel:SetNeedId(id, isneed)
	if isneed then
		-- local name = DataItem.data_get[id].name
		-- local str = string.format(TI18N("标记成功，<color='#ffff00'>市场、背包</color>中的%s将增加<color='#00ff00'>需求</color>标记"), ColorHelper.color_item_name(DataItem.data_get[id].quality, name))
		-- NoticeManager.Instance:FloatTipsByString(str)
		self.needlist[id] = "1"
		HandbookManager:Send17110(id, 1)
	else
		-- NoticeManager.Instance:FloatTipsByString(TI18N("取消成功"))
		self.needlist[id] = "0"
		HandbookManager:Send17110(id, 0)
	end
	-- local str = BaseUtils.serialize(self.needlist)
	-- PlayerPrefs.SetString("HandbookNeed", str)
end

function HandbookModel:GetIdNeed(base_id)
	return self.needlist[base_id] == "1"
end


function HandbookModel:GetIdNeedById(id)
	if DataHandbook.data_base[id] ~= nil then
		local need = false
		for k,v in pairs(DataHandbook.data_base[id].allow_item) do
			if self.needlist[v] == "1" then
				need = true
			end
		end
		return need
	else
		return self.needlist[id] == "1"
	end
end