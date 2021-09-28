-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_create_kungfu = i3k_class("wnd_create_kungfu", ui.wnd_base)

local LAYER_ZCWGT3 = "ui/widgets/zcwgt3"
local LAYER_ZCWGT1 = "ui/widgets/zcwgt1"
local LAYER_ZCWGT2 = "ui/widgets/zcwgt2"
local LAYER_ZCWGT4 = "ui/widgets/zcwgt4"  -- 宗门分享
local LAYER_ZCWGT5 = "ui/widgets/zcwgt5"

local attribute_icon = {245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262}

local g_tag = 1  -- 选中参数的tag
local wudao = {} -- 5种属性悟道点的表
local pkh = {}   -- 破 控 幻
local g_skillData = {}  -- 有关自创武功的大表
local my_diySkillShare = {}  -- 分享的技能表
local lastWudao = 0 -- 用于滚动条刷新悟道值 last / total
local my_widgets = nil
local isFirst = true  -- 是否显示5个属性（6个属性）
local drawPercent = {} -- 雷达图  比例

local maxWudaoPoint = 0 -- global vars, to improve the performance of the slider
local allWudaoPoint = 0
local allWudaoFlag = false -- 是否全部投入悟道点标志
function wnd_create_kungfu:ctor()

end

function wnd_create_kungfu:configure()
	local widgets = self._layout.vars
	my_widgets = widgets
	self.model = widgets.model
	self.model:show()

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	widgets.skill_btn:onClick(self,self.onSkillBtn)
	widgets.skill_btn:stateToNormal()
	widgets.create_btn:onClick(self,self.onCreateBtn)
	widgets.create_btn:stateToPressed()
	widgets.helpBtn:onClick(self,self.onHelpBtn)
	-- 当属性为5个时候显示firstRoot,当属性为6个时候显示secondRoot
	widgets.reset_btn:onClick(self, self.onReset)
	widgets.reset_btn2:onClick(self, self.onReset)
	widgets.firstRoot:show()
	widgets.kungfuRoot:hide()
	widgets.secondRoot:hide()
	g_tag = 1
end

function wnd_create_kungfu:refresh( data,value,diySkillShare )
	self:clearData()
	if data then
		g_skillData = data
	end
	if diySkillShare then
		my_diySkillShare = diySkillShare
	end
	
	local widgets = self._layout.vars
	isFirst = not g_i3k_game_context:isUnlock_ZHUI(data)
	if isFirst then
		self:initWudao()
		self:setFirstRootData()
	else
		widgets.first_slider:hide()
		widgets.pet_desc1:hide()
		widgets.firstRoot:hide()
		widgets.secondRoot:show()
		self:initWudao2()
		self:setFirstRootData()
		if value then
			widgets.kungfuRoot:show()
			widgets.firstRoot:hide()
			widgets.secondRoot:hide()
		end
	end
	self:onShowData()
	g_i3k_game_context:LeadCheck()
end

--加载界面清空数据
function wnd_create_kungfu:clearData()
	wudao = {}
	pkh = {}
	g_skillData = {}
 	my_diySkillShare = {}
 	lastWudao = 0
	drawPercent = {}
end

function wnd_create_kungfu:onShowData()
	self:refreshWudaoSlider()
	self:refreshWudaoLabel()
	self:refreshBuyCreateCountLabel()
	self:refreshShulianduLevel()
	self:setKungfuData()
	local info = i3k_db_kungfu_args
	local id = info.modelID.actionID
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self:showModel(info.intoAction, self:modelMessage(info.dialogueID))
end



function wnd_create_kungfu:initWudao()
	local TmpDate = g_i3k_game_context:getTmpKungfuData()
	if TmpDate and next(TmpDate) then
		wudao = TmpDate.TmpWuDao
		drawPercent = TmpDate.TmpDrawPercent
	else
		for i=1,5 do
			wudao[i] = 0
			drawPercent[i] = 0
		end
	end
	
	self:initRadarGraphy()
	--self:refreshWudaoSlider() -- 刷新雷达图数据
end
function wnd_create_kungfu:initWudao2()
	local TmpDate = g_i3k_game_context:getTmpKungfuData()
	if TmpDate and next(TmpDate) then
		wudao = TmpDate.TmpWuDao
		drawPercent = TmpDate.TmpDrawPercent
	else
		for i=1,6 do
			wudao[i] = 0
			drawPercent[i] = 0
		end
	end

	self:initRadarGraphy()
	--self:refreshWudaoSlider() -- 刷新雷达图数据
	if TmpDate and next(TmpDate) then
		pkh = TmpDate.TmpPkh
	else
		for i=1,3 do
			pkh[i] = 0
		end
	end
	self:showSelectTips()
end

-- 设置 firstRoot 根下控件的数据
function wnd_create_kungfu:setFirstRootData(tag)
	if tag == nil then
		tag = g_tag
	end
	-- init global data
	maxWudaoPoint = g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,g_tag)
	allWudaoPoint = g_i3k_game_context:getAllWudaoPoint(g_skillData)

	local widgets = self._layout.vars
	widgets.model_btn:enableWithChildren()
	widgets.model_btn:onClick(self,self.onShowModel)
	-- 初始化 剩余次数 熟练度等级 进度条
	local have_count = g_i3k_game_context:getCreateKungfuLastTimes( g_skillData )
	widgets.create_count:setText("剩余次数："..have_count)
	widgets.create1_btn:onClick(self,self.onCreateKungfuBtn)
	widgets.screate_btn:onClick(self,self.onCreateKungfuBtn)
	local  Proficiency = g_i3k_game_context:getCreateKungfuProficiency(g_skillData)
	widgets.first_cur_level:setText("熟练度等级："..Proficiency)
	widgets.maxLvl:show()
	widgets.max1:hide()
	widgets.max2:hide()
	if Proficiency == #i3k_db_create_kungfu_base then
		widgets.maxLvl:hide()
		widgets.max1:show()
		widgets.max2:show()
	end
	local percent = g_i3k_game_context:getCreateKungfuLoadingBarPercent(g_skillData)
	widgets.firstLoadingBar:setPercent(percent)
	local wudao_count = g_i3k_game_context:getAllWudaoPoint(g_skillData)
	local total_wudao_count = g_i3k_game_context:getAllWudaoPoint(g_skillData)
	widgets.point_label1:setText("悟道点："..wudao_count.."/"..total_wudao_count)
	widgets.first_jian_btn:onClick(self,self.onSubBtn)
	widgets.first_jia_btn:onClick(self,self.onAddBtn)
	-- 设置secondRoot 中的内容（同时设置但是不显示）
	widgets.screate_count:setText("剩余次数："..have_count)
	widgets.screate_btn:onClick(self,self.onCreateKungfuBtn)
	widgets.second_cur_level:setText("熟练度等级："..Proficiency)
	widgets.secondloadingBar:setPercent(percent)
	widgets.point_label:setText("悟道点："..wudao_count.."/"..total_wudao_count)
	widgets.secondJia2:onClick(self,self.onAddBtn)
	widgets.secondJian2:onClick(self,self.onSubBtn)
	--设置5个属性的图片及文字
	if isFirst then
		for i = 1 , 5 do
			local tmpBtnName = "firstargsBtn"..i
			local btn = self._layout.vars[tmpBtnName]
			btn:setTag(i)
			btn:onClick(self,self.propertyBtn)
			self:setFristRootImage(i,tag)
		end
	else
		for i = 1, 6 do
			local tmpBtnName = "secondArgsBtn"..i
			local btn = self._layout.vars[tmpBtnName]
			btn:setTag(i)
			btn:onClick(self,self.propertyBtn)
			self:setFristRootImage(i,tag)
		end
	end
	for i = 1, 3 do
		local pkhBtnName = "littlebtn"..i
		local pkhBtn = self._layout.vars[pkhBtnName]
		pkhBtn:setTag(i)
		pkhBtn:onClick(self,self.onPKHBtn)
	end

	self:setFristRootImage(1,tag)
	self:refreshPKHImage()
end


-- 设置 kungfuRoot中的数据（滚动条）
function wnd_create_kungfu:setKungfuData()
	self._layout.vars.model_btn:disableWithChildren()
	local item_scroll = self._layout.vars.item_scroll
	local item_scroll2 = self._layout.vars.item_scroll2
	local count_label = self._layout.vars.count_label
	local count_label2 = self._layout.vars.count_label2
	if item_scroll and item_scroll2 then
		item_scroll:removeAllChildren()
		item_scroll2:removeAllChildren()
		local count = g_skillData.slot
		local tmp_data = g_skillData.diySkills
		if g_skillData.tmpDiySkill then
			table.insert(tmp_data, {g_skillData.tmpDiySkill} )
		end
		local pos = table.nums(tmp_data)
		--local node = item_scroll2:addItemAndChild(LAYER_ZCWGT3)
		--node[1].vars.count_label:setText(pos.."/"..count)
		local str = string.format("已创建：%s/%s",pos,count)
		count_label:setText(str)
		local str2 = string.format("已分享：%s/%s",#my_diySkillShare,i3k_db_kungfu_args.maxCount.count)
		count_label2:setText(str2)
		local children = nil
		if i3k_db_kungfu_slot[count + 1] then
			children = item_scroll2:addItemAndChild(LAYER_ZCWGT1, 2, pos+1)

		else
			children = item_scroll2:addItemAndChild(LAYER_ZCWGT1, 2, pos) -- 自动取消拓展位置
		end

		for k,v in ipairs(children) do
			if k<= pos then
				v.vars.kungfuRoot:show()
				v.vars.expandRoot:hide()
				v.vars.bt:setTag(k)
				v.vars.bt:onClick(self,self.onUseSkill)
				if tmp_data[k].diySkillData then
					local iconID = i3k_db_create_kungfu_score[tmp_data[k].diySkillData.gradeId].icon
					v.vars.score:setImage(i3k_db_icons[i3k_db_create_kungfu_score[tmp_data[k].diySkillData.gradeId].icon].path)
					v.vars.skill_name:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(tmp_data[k].diySkillData.gradeId))
				end
				local currentID = g_skillData.curSkillId
				if currentID == k then
					v.vars.is_use:show()
				else
					v.vars.is_use:hide()
				end
				if tmp_data[k].iconId then
					v.vars.skill_name:setText(tmp_data[k].name)
					v.vars.skill_icon:setImage(i3k_db_icons[tmp_data[k].iconId].path)
				else
					v.vars.skill_name:setText("临时存储")
					v.vars.is_use:hide()
					v.vars.score:setImage(i3k_db_icons[i3k_db_create_kungfu_score[g_skillData.tmpDiySkill.gradeId].icon].path)
					v.vars.skill_name:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(g_skillData.tmpDiySkill.gradeId))
					v.vars.bt:onClick(self,self.onChangeNameAndIcon)
				end
			else -- 需要拓展槽位
				v.vars.kungfuRoot:hide()
				v.vars.expandRoot:show()
				v.vars.expandBtn:onClick(self,self.onExpand)
			end
		end
		--------------宗门分享------------
		local sharedCount = #my_diySkillShare
		local totalShareCount = 6 -- 应该从服务器获取
		local isZhongmen = true  --false
		--local shareNode = item_scroll:addItemAndChild(LAYER_ZCWGT4)
		--shareNode[1].vars.shareLabel:setText("已分享："..sharedCount.."/"..totalShareCount)
		--shareNode[1].vars.addShareCountBtn:onClick(self,self.onAddShareCountBtn)
		--shareNode[1].vars.addShareCountBtn:setVisible(isZhongmen)

		local children2 = nil
		local shareCount = #my_diySkillShare -- 分享显示的个数
		children2 = item_scroll:addItemAndChild(LAYER_ZCWGT5, 2, shareCount)
		for k,v in ipairs(children2) do
			v.vars.bt:onClick(self,self.sharedDiySkillBtn)
			v.vars.bt:setTag(k)
			v.vars.is_use:hide()
			v.vars.skill_name:setText(my_diySkillShare[k].diySkill.skill.name)
			v.vars.skill_name:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(my_diySkillShare[k].diySkill.skill.diySkillData.gradeId))
			--v.vars.player_name:setText(my_diySkillShare[k].roleName)
			v.vars.score:setImage(i3k_db_icons[i3k_db_create_kungfu_score[my_diySkillShare[k].diySkill.skill.diySkillData.gradeId].icon].path)
			v.vars.skill_icon:setImage(i3k_db_icons[my_diySkillShare[k].diySkill.skill.iconId].path)
			-- 如果是借用的技能，显示装备
			if g_skillData.borrowDiySkill and g_skillData.borrowDiySkill.id == my_diySkillShare[k].diySkill.skill.id and
				g_skillData.borrowDiySkill.name == my_diySkillShare[k].diySkill.skill.name then
					v.vars.is_use:show()
			end
		end
	end
end


-- 设置刷新点击5个属性中一个之后图片的显示,以及其他可复用的控件
function wnd_create_kungfu:setFristRootImage(i,tag)
	local tmpBgName = nil
	local tmpWordName = nil
	local tmpBgImage = nil
	if isFirst then
		tmpBgName = "firstArgsbg"..i
		tmpWordName = "firstArgWord"..i
		tmpBgImage = "firstArgsBg"..i
	else
		tmpWordName = "secondArgsIcon"..i
		tmpBgName = "secondArgsbg"..i
		tmpBgImage = "secondArgsBg"..i
	end

	local bg = self._layout.vars[tmpBgName]
	local bgImage = self._layout.vars[tmpBgImage]
	bg:hide()
	if bgImage then
		bgImage:setImage(i3k_db_icons[1677].path)
	end
	local tmpWord = self._layout.vars[tmpWordName]
	tmpWord:setImage(i3k_db_icons[attribute_icon[i*2-1]].path)
	if i == tag then
		local tmpWord = self._layout.vars[tmpWordName]
		tmpWord:setImage(i3k_db_icons[attribute_icon[i*2]].path)
		bgImage:setImage(i3k_db_icons[1676].path)
		bg:show()
	end
	local widgets = self._layout.vars
	widgets.first_arg_icon:setImage(i3k_db_icons[attribute_icon[tag*2-1]].path)

	local useCount = 0
	local maxCount = g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,tag)
	widgets.first_arg_count:setText("【 </c>"..useCount.."</c>".."/"..maxCount.." 】</c>")  -- 当前投入的悟道点
	--滚动条
	widgets.first_slider:setPercent(useCount/maxCount * 100)
	widgets.first_slider:addEventListener(self.onFirstSlider)

	----secondRoot
	widgets.secondCount2:setText("【 </c>"..useCount.."</c>".."/"..maxCount.." 】</c>")
	widgets.itemArgsName1:setImage(i3k_db_icons[attribute_icon[tag*2-1]].path)

	widgets.secondSlider2:setPercent(useCount/maxCount * 100)
	widgets.secondSlider2:addEventListener(self.onFirstSlider)

	-- 点击追，才显示pkh
	if not isFirst then
		if tag == 6 then
			-- show
			self._layout.vars.zhuiRoot:show()
			self:showSelectTips()
		else
			--hide
			self._layout.vars.zhuiRoot:hide()
			self._layout.vars.args1Desc:hide()
			self._layout.vars.args2Desc:hide()
		end
	end
end

-- 显示或隐藏选中的破控幻描述
function wnd_create_kungfu:showSelectTips()
	local count = 0
	self._layout.vars.args1Desc:hide()
	self._layout.vars.args2Desc:hide()
	for k,v in ipairs(pkh) do
		if v == 1 then
			count = count + 1
			if count == 1 then
			--	self._layout.vars.args1Desc:setText(i3k_db_create_kungfu_args[6+k].name.."："..i3k_db_create_kungfu_args[6+k].desc)
			--	self._layout.vars.args1Desc:show()
			end
			if count == 2 then
				--self._layout.vars.args2Desc:setText(i3k_db_create_kungfu_args[6+k].name.."："..i3k_db_create_kungfu_args[6+k].desc)
				--self._layout.vars.args2Desc:show()
			end
		end
	end
end


-- 获取当前属性已经使用的悟道点
function wnd_create_kungfu:getUseCount(tag)
	return wudao[tag] or 0
end

local p = {6,5,4,2,1,3}
---------刷新界面相关----------
-- 刷新悟道点进度条
function wnd_create_kungfu:refreshWudaoSlider()
	local percent = self:getUseCount(g_tag) / g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,g_tag) *100  or 0
	self._layout.vars.first_slider:setPercent(percent)
	self._layout.vars.secondSlider2:setPercent(percent)
	local count = isFirst and 5 or 6
	if isFirst then
		drawPercent[g_tag == 1 and 1 or count - g_tag + 2] = (0.8*percent+20)/100 -- 顺时针逆时针转换
		self._layout.vars.canvas1:drawing(drawPercent)
	else
		drawPercent[p[g_tag]] =  (0.8*percent+20)/100
		self._layout.vars.canvas2:drawing(drawPercent)
	end
end
--初始化雷达图20%
function wnd_create_kungfu:initRadarGraphy()
	local count = isFirst and 5 or 6
	local TmpDate = g_i3k_game_context:getTmpKungfuData()
	if TmpDate and next(TmpDate) then
		drawPercent = TmpDate.TmpDrawPercent
	else
		for i=1,count do
			drawPercent[i] = 20/100 -- 顺时针逆时针转换
		end
	end
	if isFirst then
		self._layout.vars.canvas1:drawing(drawPercent)
	else
		self._layout.vars.canvas2:drawing(drawPercent)
	end
end

-- 刷新悟道点 label 和 使用总数label
function wnd_create_kungfu:refreshWudaoLabel()
	local label = self._layout.vars.first_arg_count
	local count = self:getUseCount(g_tag)
	label:setText("【 </c>"..count.."</c>".."/"..g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,g_tag).." 】</c>")

	local labelTotal = self._layout.vars.point_label1
	local countUsed = g_i3k_game_context:getLastWudaoPoint(wudao,g_skillData)
	local countTotal = g_i3k_game_context:getAllWudaoPoint(g_skillData)
	labelTotal:setText("悟道点："..countUsed.."/"..countTotal)
	--secondRoot
	self._layout.vars.secondCount2:setText("【 </c>"..count.."</c>".."/"..g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,g_tag).." 】</c>")
	self._layout.vars.point_label:setText("悟道点："..countUsed.."/"..countTotal)

	local have_count = g_i3k_game_context:getCreateKungfuLastTimes(g_skillData)
	local widgets = self._layout.vars
	if countUsed ~= 0 or have_count == 0 then
		widgets.createPari:hide()
		widgets.createPari2:hide()
	else	
		widgets.createPari:show()
		widgets.createPari2:show()
	end
	if countUsed == countTotal then
		widgets.reset_btn:disableWithChildren()
		widgets.reset_btn2:disableWithChildren()
	else
		widgets.reset_btn:enableWithChildren()
		widgets.reset_btn2:enableWithChildren()
	end
end
--刷新 剩余创建武功次数
function wnd_create_kungfu:refreshBuyCreateCountLabel()
	local widgets = self._layout.vars
	local have_count = g_i3k_game_context:getCreateKungfuLastTimes(g_skillData)
	widgets.create_count:setText("剩余次数："..have_count)
end

-- 刷新熟练度等级和进度条
function wnd_create_kungfu:refreshShulianduLevel()
	local widgets = self._layout.vars
	local  Proficiency = g_i3k_game_context:getCreateKungfuProficiency(g_skillData)
	widgets.first_cur_level:setText("熟练度等级："..Proficiency)
	local percent = g_i3k_game_context:getCreateKungfuLoadingBarPercent(g_skillData)
	widgets.firstLoadingBar:setPercent(percent)
end

-- 刷新破控幻显示图标高亮
function wnd_create_kungfu:refreshPKHImage()
	for i = 1, 3 do
		local bgName = "littleBg"..i
		local bgImage = "bg_p"..i
		local iconName = "item_icon"..i
		local PKHbg = self._layout.vars[bgName]
		local pkhBg2 = self._layout.vars[bgImage]
		local wordsImage = self._layout.vars[iconName]
		if pkh[i] == 1 then
			PKHbg:setVisible(true)
			pkhBg2:setImage(i3k_db_icons[1676].path)
			wordsImage:setImage(i3k_db_icons[256+i*2].path)
		else
			PKHbg:setVisible(false)
			pkhBg2:setImage(i3k_db_icons[1677].path)
			wordsImage:setImage(i3k_db_icons[255+i*2].path)
		end
	end
	local label = self._layout.vars.count_desc
	local isUnlock2pkh = g_i3k_game_context:isUnlock2pkh(g_skillData)
	local totalCount = isUnlock2pkh and 2 or 1
	local selectCount = g_i3k_game_context:getSelectPKHCount(pkh)
	label:setText("请选择一个倾向："..selectCount.."/"..totalCount)
end

-----------------------------按钮监听器----------------------------------
-- 滚动条
function wnd_create_kungfu:onFirstSlider()
	local percent = self:getPercent()
	local refreshFlag = false
	local tag = g_tag
	local partOf = wudao[tag] or 0
	local count =  maxWudaoPoint
	if percent / 100 >=  (partOf+1)/count then
		local useCount = 0
		for k,v in pairs(wudao) do
			useCount = useCount + v
		end
		if allWudaoPoint - useCount > 0 then
			partOf = partOf + 1
			refreshFlag = true
		end
	elseif percent / 100 < partOf/count then
		partOf = partOf -1
		refreshFlag = true
	end
	self:setPercent(partOf / count *100)
	wudao[tag] = partOf
	local countUsed = 0
	for k,v in pairs(wudao) do
		countUsed = countUsed + v
	end
	local countTotal = allWudaoPoint
	my_widgets.point_label1:setText("悟道点："..(countTotal-countUsed).."/"..countTotal)
	my_widgets.point_label:setText("悟道点："..(countTotal-countUsed).."/"..countTotal)
	local Tcount = wudao[g_tag] or 1
	my_widgets.first_arg_count:setText("【 </c>"..Tcount.."</c>".."/"..maxWudaoPoint.." 】</c>")
	my_widgets.secondCount2:setText("【 </c>"..Tcount.."</c>".."/"..maxWudaoPoint.." 】</c>")

	if refreshFlag then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateKungfu,"refreshWudaoSlider")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateKungfu,"refreshWudaoLabel")
		refreshFlag = false
		if g_i3k_game_context:getIntoWudaoPoint(wudao) == g_i3k_game_context:getAllWudaoPoint(g_skillData) then
			if allWudaoFlag == false then
				allWudaoFlag = true
			else
				local text = "所有悟道点已投入"
				self:showModel(i3k_db_kungfu_args.erronAction,text)
			end
		else
			allWudaoFlag = false
		end
	end
end
-- 减按钮
function wnd_create_kungfu:onSubBtn(sender)
	--加减悟道点，同时更新进度条
	if wudao[g_tag] == nil then
		wudao[g_tag] = 0
	else
		if wudao[g_tag] > 0  then
			wudao[g_tag] = wudao[g_tag] - 1
		end
	end
	allWudaoFlag = false
	self:refreshWudaoSlider()
	self:refreshWudaoLabel()
end
-- 加按钮
function wnd_create_kungfu:onAddBtn(sender)
	if wudao[g_tag] == nil then
		if g_i3k_game_context:getLastWudaoPoint(wudao,g_skillData) > 0 then
			wudao[g_tag] = 1
		end
	else
		if wudao[g_tag] < g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,g_tag) then
			if g_i3k_game_context:getLastWudaoPoint(wudao,g_skillData) > 0 then
				wudao[g_tag] = wudao[g_tag] + 1
			end
		end
	end
	if g_i3k_game_context:getIntoWudaoPoint(wudao) == g_i3k_game_context:getAllWudaoPoint(g_skillData) then
		if allWudaoFlag == false then
			allWudaoFlag = true
		else
			local text = "所有悟道点已投入"
			self:showModel(i3k_db_kungfu_args.erronAction,text)
		end
	else
		allWudaoFlag = false
	end
	self:refreshWudaoSlider()
	self:refreshWudaoLabel()
end

-- 5或6 种属性的监听器
function wnd_create_kungfu:propertyBtn(sender)
	local tag = sender:getTag()
	g_tag = tag
	self:showModel(i3k_db_kungfu_args.action,i3k_db_create_kungfu_args[tag].desc)
	if isFirst then
		for i=1, 5 do
			self:setFristRootImage(i,tag)
			self:refreshWudaoSlider()
			self:refreshWudaoLabel()
		end
	else
		for i=1, 6 do
			self:setFristRootImage(i,tag)
			self:refreshWudaoSlider()
			self:refreshWudaoLabel()
		end
	end
	maxWudaoPoint = g_i3k_game_context:getMaxWudaoPointAtLevel(g_skillData,g_tag)
end
-- 破 控 幻( 在一定熟练度之后可以选择2个 )
function wnd_create_kungfu:onPKHBtn(sender)
	local tag = sender:getTag()
	local isUnlock2pkh = g_i3k_game_context:isUnlock2pkh(g_skillData)
	local selectCount = g_i3k_game_context:getSelectPKHCount(pkh)
	if isUnlock2pkh == false then
		for i = 1, 3 do
			pkh[i] =( tag == i and 1 or 0 )
		end
	else
		if selectCount < 2 then
			pkh[tag] = 1
		else
			for i =1, 3 do
				pkh[i] = ( tag == i and 1 or 0 )
			end
		end
	end
	--self._layout.vars.args1Desc:setText(i3k_db_create_kungfu_args[tag + 6].desc)
	self._layout.vars.secondDesc2:setText(i3k_db_create_kungfu_args[tag + 6].desc)
	self:showModel(i3k_db_kungfu_args.action)
	self:refreshPKHImage()
	self:showSelectTips()
end

-- 创建武功
function wnd_create_kungfu:onCreateKungfuBtn(sender)
	local TmpDate = {TmpWuDao = wudao, TmpDrawPercent = drawPercent, TmpPkh = pkh}
	g_i3k_game_context:setTmpKungfuData(TmpDate)
	local times = g_i3k_game_context:getCreateKungfuLastTimes(g_skillData)
	if times == 0 then
		if  g_i3k_game_context:isCanBuyCreateKungfuTimes(g_skillData) then
			g_i3k_ui_mgr:OpenUI(eUIID_KungfuBuyCount)
			g_i3k_ui_mgr:RefreshUI(eUIID_KungfuBuyCount, g_skillData)
			return
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(263))
			return
		end
	end
	if g_skillData.tmpDiySkill then
		--若有未处理的临时技能
		local fun = (function(ok)
			if ok then
				g_i3k_ui_mgr:OpenUI(eUIID_CreateKungfuSuccess)
                g_i3k_ui_mgr:RefreshUI(eUIID_CreateKungfuSuccess,g_skillData.tmpDiySkill,nil,g_skillData,my_diySkillShare)
			end
		end)
		local desc = "您有临时创建的武功未处理，是否处理"
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		return
	end


	if g_i3k_game_context:getIntoWudaoPoint(wudao) == 0 then
		local text = "您未投入任何悟道点，无法创建武功"
		self:showModel(i3k_db_kungfu_args.erronAction, text)
		return
	end

	if g_i3k_game_context:getIntoWudaoPoint(wudao) < g_i3k_game_context:getAllWudaoPoint(g_skillData) then
		local fun = function(ok)
			if ok == false then
				i3k_sbean.createDiySkill(wudao,g_skillData,pkh,my_diySkillShare)
			end
		end
		local desc = i3k_get_string(319)
		local yesName = "继续投入"
		local noName = "仍然创建"
		g_i3k_ui_mgr:ShowCustomMessageBox2(yesName, noName, desc, fun)
	else
		i3k_sbean.createDiySkill(wudao,g_skillData,pkh,my_diySkillShare)
	end


end

--------------kungfuRoot下的按钮
-- 装备该技能
function wnd_create_kungfu:onUseSkill(sender)
	local tag = sender:getTag()
	local otherValue = {}
	local showType = 1
	local skillData = g_skillData.diySkills[tag]
	otherValue.isEquip = g_skillData.curSkillId == tag and true or false
	if my_diySkillShare and next(my_diySkillShare) then
		otherValue.isShare = g_i3k_game_context:isMyShareDIYSkill(my_diySkillShare,g_skillData,tag)
	end
	otherValue.sharedCount = g_i3k_game_context:getMyShareSkillCount(my_diySkillShare)

	g_i3k_ui_mgr:OpenUI(eUIID_KungfuDetail)
	-- g_i3k_ui_mgr:RefreshUI(eUIID_KungfuDetail, tag,g_skillData,1,my_diySkillShare) -- sender.tag g_skillData, showType , my_diySkillShare {}
	g_i3k_ui_mgr:RefreshUI(eUIID_KungfuDetail,skillData,showType,otherValue)
end

function wnd_create_kungfu:onExpand(sender)
	local currentID = g_skillData.slot
	local money = 0
	if i3k_db_kungfu_slot[currentID + 1] then
		money = i3k_db_kungfu_slot[currentID + 1].money
		local fun = (function(ok)
			if ok then
				if g_i3k_game_context:GetMoneyCanUse(false) < money then
					g_i3k_ui_mgr:PopupTipMessage("铜钱不足无法扩展位置")
					return
				end
				i3k_sbean.diySkill_unlock()
				g_i3k_game_context:UseMoney(money,false,AT_DIYSKILL_SLOT_UNLOCK);
			end
		end)
		local desc = string.format("扩展位置需要花费%d%s",money,"铜钱")
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
    else
        --全部拓展完成了，无法拓展了
	end
end

function wnd_create_kungfu:onChangeNameAndIcon(sender)
	g_i3k_ui_mgr:PopupTipMessage("临时武功未命名")
	g_i3k_ui_mgr:OpenUI(eUIID_CreateKungfuSuccess)
	g_i3k_ui_mgr:RefreshUI(eUIID_CreateKungfuSuccess,g_skillData.tmpDiySkill,nil,g_skillData,my_diySkillShare)
end

function wnd_create_kungfu:onAddShareCountBtn(sender)
	local desc = "升级宗门等级，可以提升可分享上限"
	g_i3k_ui_mgr:ShowMessageBox1(desc)
end

-- 宗门分享下的技能
function wnd_create_kungfu:sharedDiySkillBtn(sender)
	local tag = sender:getTag()
	local otherValue = {}
	local showType = 2
	local skillData = my_diySkillShare[tag].diySkill.skill
	otherValue.isEquip = g_skillData.curSkillId == tag and true or false
	if my_diySkillShare and next(my_diySkillShare) then
		otherValue.isShare = g_i3k_game_context:isMyShareDIYSkill(my_diySkillShare,g_skillData,tag)
	end
	otherValue.myShareSkillTimes = my_diySkillShare[tag].diySkill.takeCount
	otherValue.skillSaveTime = my_diySkillShare[tag].diySkill.shareTime
	otherValue.roleName = my_diySkillShare[tag].roleName
	otherValue.skillName = my_diySkillShare[tag].diySkill.skill.name

	-- 如果是自己分享的技能则显示取消分享
	--if my_diySkillShare[tag].serverId == i3k_game_get_server_id() then
		if my_diySkillShare[tag].roleId == g_i3k_game_context:GetRoleId() then
			otherValue.isMyShareSkill = true
		end
	--end
	-- 如果已经借用了该武功
	local borrowSkill = g_skillData.borrowDiySkill
	local playerId = my_diySkillShare[tag].roleId
	local skillId = my_diySkillShare[tag].diySkill.skill.id
	local borrowSkill = g_skillData.borrowDiySkill
	if borrowSkill and borrowSkill.id == skillId and borrowSkill.name == my_diySkillShare[tag].diySkill.skill.name then
		otherValue.isBorrowed = true
	end
	otherValue.skillId = skillId
	otherValue.playerId = playerId
	otherValue.serverId = my_diySkillShare[tag].serverId

	otherValue.shareCount = g_i3k_game_context:getMyShareSkillCount(my_diySkillShare)

	--如果我不在这个宗门中那么显示=3
	g_i3k_ui_mgr:OpenUI(eUIID_KungfuDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_KungfuDetail,skillData,showType,otherValue)
end
-----------------------
--宗门秘籍
function wnd_create_kungfu:onSkillBtn(sender,eventType)
	local TmpDate = {TmpWuDao = wudao, TmpDrawPercent = drawPercent, TmpPkh = pkh}
	g_i3k_game_context:setTmpKungfuData(TmpDate)
	local widgets = self._layout.vars
	--widgets.person:hide()
	self.model:hide()
	widgets.titleName:setImage(g_i3k_db.i3k_db_get_icon_path(1847))
	widgets.skill_btn:stateToPressed()
	widgets.create_btn:stateToNormal()
	widgets.kungfuRoot:show()
	widgets.firstRoot:hide()
	widgets.secondRoot:hide()
	i3k_sbean.getDiySkillSync(not isFirst)--true)
	widgets.helpBtn:hide()
end
--自创武功
function wnd_create_kungfu:onCreateBtn(sender,eventType)
	local widgets = self._layout.vars
	widgets.helpBtn:show()
	--widgets.person:show()
	self.model:show()
	widgets.titleName:setImage(g_i3k_db.i3k_db_get_icon_path(1846))
	widgets.skill_btn:stateToNormal()
	widgets.create_btn:stateToPressed()
	if isFirst then
		widgets.firstRoot:show()
		widgets.kungfuRoot:hide()
		widgets.secondRoot:hide()
	else
		widgets.firstRoot:hide()
		widgets.kungfuRoot:hide()
		widgets.secondRoot:show()
	end

	for k,v in ipairs (drawPercent) do
		v = 0
	end
	self:refreshWudaoSlider() -- 清空雷达图数据
end
--关闭按钮
--[[function wnd_create_kungfu:onCloseBtn(sender,eventType)
	wudao = {}
	g_tag = 1
	g_skillData = {}
	my_diySkillShare = {}
	g_i3k_ui_mgr:CloseUI(eUIID_CreateKungfu)
end--]]

function wnd_create_kungfu:showModel(cfg1, cfg2)
	local count = table.getn(cfg1)
	for i=1, count do
		if i == count then
			self.model:pushActionList(cfg1[i],-1)
		else
			self.model:pushActionList(cfg1[i], 1)
		end
	end
	self.model:playActionList()
	if cfg2 then
		self._layout.vars.secondDesc2:setText(cfg2)
		self._layout.vars.first_arg_desc:setText(cfg2)
	end
end

function wnd_create_kungfu:modelMessage(cfg2)
	local idCount = table.getn(cfg2)
	local textId = math.random(cfg2[1],cfg2[idCount])
	local index = math.random(0, #i3k_db_dialogue[textId])
	index = index==0 and 1 or math.ceil(index)
	return i3k_db_dialogue[textId][index].txt
end

function wnd_create_kungfu:onShowModel(sender)
	local info = i3k_db_kungfu_args
	self:showModel(info.clickAction, self:modelMessage(info.clickID))

end

--帮助
function wnd_create_kungfu:onHelpBtn(sender)
	local msg = i3k_get_string(331)
	g_i3k_ui_mgr:ShowHelp(msg)
end

function wnd_create_kungfu:onReset(sender)
	g_i3k_game_context:removeTmpKungfuData()
	i3k_sbean.getDiySkillSync()
end

function wnd_create_kungfu:onHide()
	local TmpDate = {TmpWuDao = wudao, TmpDrawPercent = drawPercent, TmpPkh = pkh}
	g_i3k_game_context:setTmpKungfuData(TmpDate)
end

function wnd_create(layout)
	local wnd = wnd_create_kungfu.new();
		wnd:create(layout);
	return wnd;
end
