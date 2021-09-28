-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--选择规模
-------------------------------------------------------

wnd_marry_select_size = i3k_class("wnd_marry_select_size",ui.wnd_base)

function wnd_marry_select_size:ctor()
	self.isCanOk = {}
	for i = 1 ,3 do
		self.isCanOk[i] = false
	end
	self.isSelect = false
end

function wnd_marry_select_size:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.close
	self.closeBtn:onClick(self, self.closeButton)

	self.NotMarryBtn = widgets.NotMarryBtn  --再考虑下
	self.NotMarryBtn:onClick(self, self.onNotMarryBtn)
	self.okBtn = widgets.okBtn  --确定
	self.okBtn:onClick(self, self.onOkBtn)

	--婚礼规模，无论什么档次只统计上述几条信息，如果没有的条目隐藏
	--婚礼时长：%s小时（读表转换成小时显示）
	--婚礼费用：%s铜钱或%s元宝（读表）
	--个人仓库：开启个人仓库、开启%s个人仓库（5格）
	--公共仓库：开启公共仓库、开启%s公共仓库（5格）
	----夫妻技能：%s%s（形影不离1级）
	--新婚时装：读表显示时装名
	self.details = {}
	self._bgTab = {}
	for i =1 ,3 do

		--for j=1 ,6 do
		--	details[j] = {}
		--end
		self.details[i] = {}
		--if i==1 then
			--婚礼时长
			--local marryDuration = (math.floor(i3k_db_marry_rules.marryDuration /60)) .."分钟"
			--self.details[i][1] =i3k_get_string(683)..marryDuration
			--婚礼费用
			local marryUse1 = i3k_db_marry_grade[i].marryUsedMoney
			local marryUse2 = i3k_db_marry_grade[i].marryUsedWing
			local marryUse3 = i3k_db_marry_grade[i].marryUsedPorpId
			local marryUseNum3 = i3k_db_marry_grade[i].marryUsedPorpNum
			local str1 = ""
			if marryUse1~=0 then
				str1 = marryUse1.."铜钱"
			end
			local str2 = ""
			if marryUse2~=0 then
				str2 = marryUse2.."元宝"
			end
			local str3 = ""
			if marryUse3~=0 then
				str3 = marryUseNum3.."个"..g_i3k_db.i3k_db_get_other_item_cfg(marryUse3).name
			end
			local str = str1..str2..str3
			self.details[i][1] = i3k_get_string(684)..str
			--公共仓库
			local publicBag =  i3k_db_marry_grade[i].publicBag
			local publicBagNums =  i3k_db_marry_grade[i].publicBagNums
			local bagStr2 = ""
			if publicBag~=0 then
				bagStr2=string.format("开启公共仓库、开启%s格公共仓库",publicBagNums)
				self.details[i][3] = i3k_get_string(686)..bagStr2
			else
				self.details[i][3] = 0
			end


			----夫妻技能：%s%s（形影不离1级）
			local skills1Level =  i3k_db_marry_grade[i].skillsInitLevel
			local skills1 = i3k_db_marry_skills[1][skills1Level].skillsName
			local skill2 ="形影不离1级"
			local str1 = ""
			if 	skills1Level and skills1 then
				str1 = skills1..skills1Level.."级"
			end
			local skillStr = str1.."、"..skill2
			self.details[i][4] = i3k_get_string(687)..skillStr
			--新婚时装：读表显示时装名
			local marryFshionId =  i3k_db_marry_grade[i].fashionID
			if marryFshionId ~= 0 then
				marryFshionName =g_i3k_db.i3k_db_get_other_item_cfg(marryFshionId).name
				self.details[i][5] = i3k_get_string(691)..marryFshionName
			end
		--else
		--	self.details[i][1] = " "
		--	self.details[i][2] = "暂未开放"
		--end


		local scroll = string.format("bg%s_scroll",i)
		local bg_btn = string.format("bg%s_btn",i)
		self._bgTab[i] = {}
		self._bgTab[i] = {scroll =widgets[scroll], btn = widgets[bg_btn]}
		self.colcrTab = {"ffb66a4d","ffeb6a32","fff15960"}
	end

end

function wnd_marry_select_size:cheakData()
	--检查按钮的显示与否
	local state = g_i3k_game_context:getEnterProNum() --1 代表月老处 可点 --2 代表姻缘处
	if state ==1 then
		--显示上一层
		self.NotMarryBtn:hide()
		self.okBtn:hide()
	elseif state ==2 then
		local step = g_i3k_game_context:getRecordSteps() --1 ，结婚状态时间
		if step== -1 then
			self.NotMarryBtn:hide()
			self.okBtn:hide()
		end
	else
	end
end

function wnd_marry_select_size:refresh()
	self:cheakData()
	for i,v in ipairs(self._bgTab) do
		v.btn:setTag(1000+i)
		v.btn:onClick(self, self.onSelectBtn,i)
		local str  = ""
		for k,value in ipairs(self.details[i]) do
			if value~=0 then
				str = str..value.."\n"
			end
		end
		local layer = require("ui/widgets/jhhlgmt")()
		self.textLabel = layer.vars.textLabel
		self.textLabel:setText(str)
		self.textLabel:setTextColor(self.colcrTab[i])--FFFF0000
		v.scroll:addItem(layer)
	end
	self:checkDiscount()
end


-- 检查是否在打折的时间范围内
function wnd_marry_select_size:checkDiscount()
	local widgets = self._layout.vars
	local isDiscount = g_i3k_db.i3k_db_get_is_weeding_discount()
	local percents = g_i3k_db.i3k_db_get_weeding_discount()
	for i = 1, 3 do
		widgets["discountRoot"..i]:setVisible(isDiscount)
		if isDiscount then
			local per = percents[i] or 10000
			local oriMoney = i3k_db_marry_grade[i].marryUsedWing
			widgets["discount"..i]:setText(math.floor(oriMoney * per / 10000 ))
		end
	end
end

function wnd_marry_select_size:onSelectBtn(sender, index)
	for i=1, 3 do
		self._layout.anis["c_hl"..i]:stop()
	end
	self._layout.anis["c_hl"..index]:play()
	--if index~=1 then
	--	self.okBtn:disableWithChildren()
	--else
	--	self.okBtn:enableWithChildren()
	--end
	self.isSelect = true
	self:resetTabData()
	self.tag = sender:getTag() - 1000
	local data = i3k_db_marry_grade[self.tag]
	local percents = g_i3k_db.i3k_db_get_weeding_discount()
	local per = percents[self.tag] or 10000
	self.needMoney = data.marryUsedMoney
	self.needDiamond = data.marryUsedWing * per / 10000
	self.needPropId = data.marryUsedPorpId
	self.needPropNum = data.marryUsedPorpNum

	local _canUseMoney = g_i3k_game_context:GetMoneyCanUse(true)
	local _canUseDiamond = g_i3k_game_context:GetDiamondCanUse(true)
	if _canUseMoney >= self.needMoney then
		self.isCanOk[1] = true
	end
	if _canUseDiamond >= self.needDiamond then
		self.isCanOk[2] = true
	end
	if self.needPropId ~= 0 then
		local count = g_i3k_game_context:GetCommonItemCanUseCount(self.needPropId)
		self._propName = g_i3k_db.i3k_db_get_other_item_cfg(self.needPropId).name
		if count >= self.needPropNum then
			self.isCanOk[3] = true
		end
	else
		self.isCanOk[3] = true
	end
end

function wnd_marry_select_size:resetTabData()
	for i = 1 ,3 do
		self.isCanOk[i] = false
	end
end

function wnd_marry_select_size:onOkBtn(sender)
	if not self.isSelect then
		g_i3k_ui_mgr:PopupTipMessage("请选择婚礼规模")
		return
	end
	local index = 0
	for i,v in ipairs(self.isCanOk) do
		if v== false then
			if i==1 then
				g_i3k_ui_mgr:PopupTipMessage("铜钱不足，婚礼规模选择失败")
			elseif i==2 then
				g_i3k_ui_mgr:PopupTipMessage("元宝不足，婚礼规模选择失败")
			elseif i==3 then
				g_i3k_ui_mgr:PopupTipMessage(string.format("%s数量不足，婚礼规模选择失败",self._propName))
			end
			index = index +1
			break
		end
	end
	if index== 0 then
		--够规格 可以求婚
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Marry_Demande_Marriage,"setCanMarry",true ,self.tag)
		self:closeButton()
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Marry_Demande_Marriage,"setCanMarry",false,self.tag)
	end
end

function wnd_marry_select_size:onNotMarryBtn()
	self:closeButton()
end

function wnd_marry_select_size:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Select_Size)
end

function wnd_create(layout)
	local wnd = wnd_marry_select_size.new()
		wnd:create(layout)
	return wnd
end
