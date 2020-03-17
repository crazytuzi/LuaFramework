--[[
    共用接口
	chenyujia
	2016年6月7日
]]

_G.PublicUtil = {};

---提供客户端属性显示借口
---属性表为 AttrParseUtil:Parse() 函数解析过的属性表
--- addPro 传nil表示无属性加成显示
--[[控件约定
	1.主属性名字包括属性值请用一行文本显示
	2.后面加成属性 请打包成元件  上箭头可以无名字  后面文本名字为 proText
	3.这里的文本都要支持html
	4.slot请顺序插入表中 如果传入addslot 数量与baseSlot数量保持一致
]]

local getPro = function(pro, name)
	for k, v in pairs(pro) do
		if v.name == name then
			return v
		end
	end
	return
end

local s_proStr = "<font color = '%s'>%s：    </font><font color = '%s'>%s</font>"
local s_proStr1 = "<font color = '%s'>%s：</font><font color = '%s'>%s</font>"
local s_proValueStr = "<font color = '%s'>+%s</font>"
function PublicUtil:ShowProInfoForUI(basePro, baseSlot, addPro, addSlot, sysPro, bSpaceName, nameColor, valueColor, str1)
	if not baseSlot then return end

	if sysPro then
		for k, v in pairs(sysPro) do
			local bHave = false
			for k1, v1 in pairs(basePro) do
				if v1.name == v then
					bHave = true
					break
				end
			end
			if not bHave then
				table.push(basePro, {name = v, val = 0})
			end
		end
	elseif addPro then
		--- 这里避免后面加属性但是前面并没有显示的尴尬
		for k, v in pairs(addPro) do
			local bHave = false
			for k1, v1 in pairs(basePro) do
				if v1.name == v.name then
					bHave = true
					break
				end
			end
			if not bHave then
				table.push(basePro, {name = v.name, val = 0})
			end
		end
	end

	local list = {}
	--- 这里对显示进行排序
	for k, v in pairs(PublicAttrConfig.pro) do
		for k1, v1 in pairs(basePro) do
			if v == v1.name then
				table.push(list, v1)
				break
			end
		end
	end

	for k, v in pairs(baseSlot) do
		local pro = list[k]
		if pro then
			local name = bSpaceName and PublicAttrConfig.proSpaceName[pro.name] or PublicAttrConfig.proName[pro.name]
			nameColor = nameColor or PublicAttrConfig.proNameColor[pro.name] or PublicStyle.COLOR_ATTR_NAME;
			valueColor = valueColor or PublicAttrConfig.proValueColor[pro.name] or PublicStyle.COLOR_ATTR_Val;
			v.htmlText = string.format(str1 and s_proStr1 or s_proStr, nameColor, name, valueColor, pro.val)
			if addPro then
				local pro1 = getPro(addPro, pro.name)
				if pro1 then
					addSlot[k]._visible = true
					addSlot[k].proText.htmlText = string.format(s_proValueStr, valueColor, pro1.val)
				else
					addSlot[k]._visible = false
				end
			end
		else
			v.htmlText = ""
			if addSlot then
				addSlot[k]._visible = false
			end
		end
	end
end

function PublicUtil:ShowProTips(pro, nType)
	local str = ""
	local list = {}
	--- 这里对显示进行排序
	for k, v in pairs(PublicAttrConfig.pro) do
		for k1, v1 in pairs(pro) do
			if v == v1.name then
				table.push(list, v1)
				break
			end
		end
	end

	for i, v in ipairs(list) do
		str = str .. string.format(s_proStr1, "#d68637", PublicAttrConfig.proSpaceName[v.name], "#FFFFFF", v.val) .. "\n"
	end
	TipsManager:ShowBtnTips(str,nType)
end

-- 计算战斗力
function PublicUtil:GetFigthValue(list, level)
	local value = 0
	-- local nValue = level and t_consts[210].val1 or 1
	-- level = level or MainPlayerModel.humanDetailInfo.eaLevel
	-- for k, v in pairs(list) do
	-- 	local cfgStr = AttrParseUtil:GetCfgStr(v.type)
	-- 	if cfgStr then
	-- 		local FightCfg = t_specialAttrfightC[cfgStr]
	-- 		if FightCfg then
	-- 			if FightCfg.val2 == 0 then
	-- 				value = value + v.val * FightCfg.val1
	-- 			else
	-- 				value = value + v.val * FightCfg.val1 * level * nValue
	-- 			end
	-- 		end
	-- 	end
	-- end
	for i,vo in pairs(EquipUtil.formulaList) do
		for j,attrVO in pairs(list) do
			if vo.type == attrVO.type then
				value = value + attrVO.val*vo.val;
			end
		end
	end
	return math.floor(value + 0.5)
end
-- 两个属性组 相同的属性相加
function PublicUtil:GetFightListPlus(listA, listB)
	local resultList = {};
	for k1, v1 in pairs(listA) do
		local name1 = v1.name;
		if resultList[name1] == nil then
			resultList[name1] = v1;
		else
			resultList[name1].val = resultList[name1].val + v1.val;
		end
	end
	for k2, v2 in pairs(listB) do
		local name2 = v2.name;
		if resultList[name2] == nil then
			resultList[name2] = v2;
		else
			resultList[name2].val = resultList[name2].val + v2.val;
		end
	end
	return resultList;
end

--- 获取时间
function PublicUtil:GetShowTimeStr(time)
	local hour, min, sec = CTimeFormat:sec2format(time)
	if hour < 10 then hour = 0 .. hour end
	if min < 10 then min = 0 .. min end
	if sec < 10 then sec = 0 .. sec end
	return hour .. ":" .. min .. ":" ..sec
end


local  promptSetFunc= function(mc, showTypes,value,funcID)
	local loader = mc.funPrompt
	loader.content.mcPrompt.mingRi.click = function() PublicUtil:OnBtnMingRiClick(funcID); end;
	if showTypes == OpenFunByDayConst.showMingri and value>0 then
		loader.content.mcPrompt.jiHuo._visible = false
		loader.content.mcPrompt.mingRi._visible = true
		if value==1 then
			loader.content.mcPrompt.mingRi.htmlLabel = string.format(StrConfig['funcguide006']);
			return
		end
		loader.content.mcPrompt.mingRi.htmlLabel = string.format(StrConfig['funcguide005'],value);
		return
	elseif showTypes == OpenFunByDayConst.showJihuo then
		loader.content.mcPrompt.mingRi._visible = false
		loader.content.mcPrompt.jiHuo._visible = true
		loader.content.mcPrompt.jiHuo.click = function() PublicUtil:OnBtnJiHuoClick(funcID); end;
		return
	elseif showTypes == OpenFunByDayConst.showLv then
		loader.content.mcPrompt.jiHuo._visible = false
		loader.content.mcPrompt.mingRi._visible = true
		local func = FuncManager:GetFunc(funcID);
		if not func then return; end
		local open_prama = func:GetCfg().open_prama;
		loader.content.mcPrompt.mingRi.htmlLabel = string.format(StrConfig['funcguide007'],open_prama);
		return
	end
	loader.content.mcPrompt._visible = false;	
end
--客户端请求新功能开启
function PublicUtil:OnBtnJiHuoClick(funcID)
	-- FuncOpenController:ReqFunctionOpen(funcID)
	UIOpenFunInfo:ShowInfo(funcID,OpenFunByDayConst.showJihuo)
end
--点击明日开启
function PublicUtil:OnBtnMingRiClick(funcID)
	UIOpenFunInfo:ShowInfo(funcID,OpenFunByDayConst.showMingri)
end

local numSetFunc = function(mc, showTypes, value)
	local loader = mc.redpoint
	if showTypes == RedPointConst.showExclamationPoint and value == 0 then
		loader.content.mcNum._visible = false
		return
	elseif showTypes == RedPointConst.showNum and value == 0 then
		loader.content.mcNum._visible = false
		return
	end
	loader.content.mcNum._visible = true
	loader.content.mcNum:setValue(value, showTypes)
end

-- 设置添加红点提醒
PublicUtil.indexNum = 0;
-- @param mc 			加红点的父对象
-- @param showTypes 	红点的显示类型
-- @param value 		红点的显示数量
-- @param changeHeight  红点的显示高度
-- @param changeWidth   红点的显示X轴坐标
-- @param setX			设置固定位置
-- @param setY			设置固定位置
function PublicUtil:SetRedPoint(mc, showTypes, value, changeHeight,changeWidth, setX, setY)
	if not mc then 
		return
	end
	showTypes = showTypes or RedPointConst.showExclamationPoint
	value = value or 0
	local loader = mc.redpoint
	if not loader then
		local depth = mc:getNextHighestDepth();
		loader = mc:attachMovie("UILoader", "redpoint", depth)
		if setX and setY then
			loader._x = setX
			loader._y = setY
		else
			if changeWidth then
				loader._x = mc._width - 2
			else
				loader._x = mc._width
			end
			if changeHeight then
				loader._y = -(mc._height/4)
			end
		end
	end
	if loader then
		if loader.source ~= ResUtil:GetRedPoint() then
			loader.source = ResUtil:GetRedPoint();
		end
	end

	if loader.content.mcNum then
		numSetFunc(mc, showTypes, value)
	else
		loader.loaded = function()
			numSetFunc(mc, showTypes, value)
		end
	end
	return loader;
end

-- 按天数开启的功能图标提示
-- @param mc 			加提示的父对象
-- @param showTypes 	提示的显示类型
-- @param changeHeight  提示的显示高度
-- @param value 		提示的显示天数
function PublicUtil:SetFunPrompt(mc, showTypes, changeHeight,value,funcID)
	if not mc then 
		-- print("not find mc in swf")
		return
	end;
	showTypes = showTypes
	value = value or 0
	local loader = mc.funPrompt
	if not loader then
		local depth = mc:getNextHighestDepth();
		loader = mc:attachMovie("UILoader", "funPrompt", depth)
		loader._x = mc._width - 4   --changer:houxudong 调节和小红点depth冲突问题 date:2016/11/22 17:59:26
		if changeHeight then
			loader._y = -(mc._height/4)
		end
	end
	if loader then
		if loader.source ~= ResUtil:GetFunPrompt() then
			loader.source = ResUtil:GetFunPrompt();
		end
	end

	if loader.content.mcPrompt then
		promptSetFunc(mc, showTypes,value,funcID)
	else
		loader.loaded = function()
			promptSetFunc(mc, showTypes,value,funcID)
		end
	end
	return loader;
end

function PublicUtil.SetNumberValue(mc, number, bRoll, weight, index)
	local str = tostring(number)
	local size = string.len(str)

	if not mc.numSlot then
		mc.numSlot = {}
		mc.numSlot[1] = mc.num1
	end
	local posx = mc.num1._x
	local posy = mc.num1._y
	local nIndex = size
	if size < #mc.numSlot then
		nIndex = #mc.numSlot
	end
	if index and nIndex < index then
		--- 这里是特殊情况做好的
		nIndex = index
	end

	for i = 1, nIndex do
		if not mc.numSlot[i] and mc["num" ..i] then
			--特殊情况提前添加的
			mc.numSlot[i] = mc["num" ..i]
		end
		if i <= size then
			---判断不存在创建
			if not mc.numSlot[i] then
				local depth = mc:getNextHighestDepth();
				mc.numSlot[i] = mc:attachMovie("Vnewfight", "num"..i,depth)
				mc.numSlot[i]._x = posx + (weight and weight or 22)* (i- 1)
				mc.numSlot[i]._y = posy
			end
			mc.numSlot[i].fight.bStop = false
			-- mc.numSlot[i].fight._visible = true
		else
			if mc.numSlot[i] then
				if bRoll then
					if mc.numSlot[i].fight.value ~= 0 then
						mc.numSlot[i].fight.value = 0
						mc.numSlot[i].fight.bStop = true
						mc.numSlot[i].fight:play()
					else
						mc.numSlot[i].fight:gotoAndStop(1)
						-- mc.numSlot[i]._visible = false
					end
				else
					mc.numSlot[i].fight:gotoAndStop(1)
					mc.numSlot[i]._visible = false
				end
			end
		end
	end

	for i = 1, size do
		local num = tonumber(string.sub(str, i, i))
		if mc.numSlot[i].fight.value ~= num then
			mc.numSlot[i].fight.value = num
			if bRoll then
				mc.numSlot[i].fight:play()
			else
				mc.numSlot[i].fight:gotoAndStop(num == 0 and 1 or 4*num + 1)
			end
		end
		mc.numSlot[i]._visible = true
	end
end

function PublicUtil.GetString(index, ...)
	return string.format(StrConfig[index], ...)
end

-- adder:houxudong date:2016/10/25 17:23:49
-- 怪物刷新倒计时时间【通用】 
-- @param dealyNum    倒计时开始时间
-- @param type        显示类型
-- @param callBackOne 第一个回调函数
-- @param callbacktwo 第二个回调函数
function PublicUtil:OnMonsterComeTime(dealyNum,type,callBackOne,callBackTwo)
	local num = dealyNum
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			if callBackOne then
				callBackOne()
			end
		end
		if num == dealyNum then
			UITimeTopSec:Open(type,num);  --timeTopSec倒计时
			if callBackTwo then
				callBackTwo()
			end
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000)
	func()
end

--- 转换一个VIP那里属性的显示
function PublicUtil.GetVipShowPro(pro)
	local attMap = {}
	for i,vo in pairs(pro) do
		if vo.type == enAttrType.eaGongJi then
			table.push(attMap,{proKey = 'att', proValue = vo.val})
		elseif vo.type == enAttrType.eaFangYu then
			table.push(attMap,{proKey = 'def', proValue = vo.val})
		elseif vo.type == enAttrType.eaMaxHp then
			table.push(attMap,{proKey = 'hp', proValue = vo.val})
		elseif vo.type == enAttrType.eaBaoJi then
			 table.push(attMap,{proKey = 'cri', proValue = vo.val})
		 elseif vo.type == enAttrType.eaRenXing then
			 table.push(attMap,{proKey = 'defcri', proValue = vo.val})
		elseif vo.type == enAttrType.eaMingZhong then
			table.push(attMap,{proKey = 'hit', proValue = vo.val})
		elseif vo.type == enAttrType.eaShanBi then
			table.push(attMap,{proKey = 'dodge', proValue = vo.val})
		end
	end
	return attMap
end

--- 各系统vip属性加成战力获取
function PublicUtil.GetVipShowFight(pro, systemName)
	local attMap = {}
	local add = VipController:GetShowAddition(systemName)
	for k, v in pairs(PublicUtil.GetVipShowPro(pro)) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[v.proKey];
		vo.val = v.proValue*add/100;
		table.push(attMap,vo);
	end
	return PublicUtil:GetFigthValue(attMap)
end

_G.PublicStyle = {};
PublicStyle.SIZE_ATTR_NAME = "14";
PublicStyle.COLOR_ATTR_NAME = "#ea8d11";
PublicStyle.SIZE_ATTR_VAL = "14";
PublicStyle.COLOR_ATTR_Val = "#d5d0c2";
PublicStyle.htmlTemplate = "<font color='%s' size='%s'>%s</font>";

function PublicStyle:GetAttrNameStr(str, color, size)
	color = color or PublicStyle.COLOR_ATTR_NAME;
	size = size or PublicStyle.SIZE_ATTR_NAME;
	return string.format(PublicStyle.htmlTemplate, color, size, str);
end

function PublicStyle:GetAttrValStr(str, color, size)
	color = color or PublicStyle.COLOR_ATTR_Val;
	size = size or PublicStyle.SIZE_ATTR_VAL;
	return string.format(PublicStyle.htmlTemplate, color, size, str);
end
-- ==============================================h

--                   _oo0oo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  0\  =  /0
--                ___/'---'\___
--              .' \\|     |// '.
--             / \\|||  :  |||// \
--            / _||||| -:- |||||- \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |_/ |
--           \  .-\__  '-'  __/-.  /
--         ___'. .'  /--.--\  '. .'___
--      ."" '<  '.___\_<|>_/___.' >' "".
--     | | :  '_ \'/;'\ _ /';.'/ - ': | |
--     \  \ '_.   \_ __\ /__ _/   ._' /  /
--  ====='-.____'.__ \_____/ ___.-'____.-'=====
--                   '=---='

--       佛祖保佑               永无BUG

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~