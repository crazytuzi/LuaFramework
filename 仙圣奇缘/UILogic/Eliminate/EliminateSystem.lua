 --------------------------------------------------------------------------------------
-- 文件名: EliminateSystem.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    
-- 描  述:    
-- 应  用:  
---------------------------------------------------------------------------------------
--消除格子的维度
local nLength = 7

local dir_v = 1 --垂直放系那个计算
local dir_h = 2 --水平

EliminateSystem = class("EliminateSystem")
EliminateSystem.__index = EliminateSystem


function EliminateSystem:ctor()
	--界面的元素 消除表信息 EliminateElement
	self.tbElement = {}

	--消除的列表 EliminateNode
	self.tbElementList = {}

	--技能
	self.ElimentSkill = EliminateSkill.new()

	--当前激活的技能
	self.nActiveSkill = -1

	--当前灰调的技能
	self.nGraySkill = -1

	--每次随机消除node的下标
	self.nIndex = 0

	--缓存计算的消除节点下标
	self.tbDelTabel = {}

	--新加入的元素下标
	self.tbNewAdd = {}

	--感悟属性
	self.InspireAttribute = InspireAttribute.new()

	--感悟纪录
	self.InspireLog  = EliminateLog.new()

	--
	self.ganwuclick = true
end


function EliminateSystem:InitElementInfo(tbDate)
	cclog("感悟数据 初始化")
	cclog(tostring(tbDate).."感悟数据")

	self:InitEliminate(tbDate)

	self.InspireLog:Init()

	
--网络消息
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_INSPIRE_RESPONSE, handler(self, self.RespondInspire))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_INSPIRE_INFO_RESPONSE, handler(self, self.RespondInspireCheckData))

--界面
	g_FormMsgSystem:RegisterFormMsg(FormMsg_InspireForm_ActionOver, handler(self, self.OnMsgActionOver))
end


function EliminateSystem:InitEliminate(tbDate)
	cclog("===============EliminateSystem:InitEliminate===============beg")
	if tbDate == nil then return end

	self:ResetData()

	self:MakeElement(tbDate.box_info)
	self.ElimentSkill:InitBaseInfo(tbDate.skill_list)
	self.nActiveSkill = tbDate.skill_idx

	self:RandomEliminate()

	cclog("===============EliminateSystem:InitEliminate===============end")
end


function EliminateSystem:ResetData()
	self.tbElement = {}

	--消除的列表 EliminateNode
	self.tbElementList = {}

	--技能
	self.ElimentSkill = EliminateSkill.new()

	--当前激活的技能
	self.nActiveSkill = -1

	--当前灰调的技能
	self.nGraySkill = -1

	--每次随机消除node的下标
	self.nIndex = 0

	--缓存计算的消除节点下标
	self.tbDelTabel = {}

	--新加入的元素下标
	self.tbNewAdd = {}
end


--生成所有的元素
function EliminateSystem:MakeElement(tbBoxInfo)
	self.tbElement = {}
	for i, v in ipairs(tbBoxInfo)do

		self.tbElement[i]={}

		for j , n in ipairs(v.box_data)do

			local element = EliminateElement.new()
			element:SetElement(i, j, n)

			self.tbElement[i][j] = element
			-- table.insert(self.tbElement, element)
		end
	end

	-- echoj("MakeElement ====>", self.tbElement)
	-- Eliminate.InitEliminateList(self.tbElement, self.tbElementList)

	-- cclog("感悟数据 end")
	self:MakeEliminateList()
end


--生成删除组
function EliminateSystem:MakeEliminateList()
	self.tbDelTabel = {}
	self.tbElementList = {}
	for i, v in ipairs(self.tbElement)do

		for j, n in ipairs(v) do

			local nVaule = n:GetColor()
			--水平方向 向右遍历
			if j < 6 then
				
			
				local element1 = self:GetElementByIndex(i, j+1)
				local element2 = self:GetElementByIndex(i, j+2)
				if element1 ~= nil and element2 ~= nil and (element1:GetColor() == nVaule or element2:GetColor() == nVaule or element1:GetColor() == element2:GetColor() ) then

					local elimate = EliminateNode.new()

					elimate:PushElement(n)
					elimate:PushElement(element1)
					elimate:PushElement(element2)

					self:CheckAutoEliminate(n, element1, element2, dir_h)

					if elimate:FindEliminatePoint() then
						table.insert(self.tbElementList, elimate)
						-- cclog("水平添加 i="..i.." j="..j)
					end
					-- cclog("水平方向加入 i="..i.." j="..j)
				end
			end

			--垂直方 向下遍历
			if i < 6 then
				local element1 = self:GetElementByIndex((i+1) , j)
				local element2 = self:GetElementByIndex((i+2) , j)
				if element1 ~= nil and element2 ~= nil and (element1:GetColor() == nVaule or element2:GetColor() == nVaule or element1:GetColor() == element2:GetColor()) then

					local elimate = EliminateNode.new()

					elimate:PushElement(n)
					elimate:PushElement(element1)
					elimate:PushElement(element2)

					self:CheckAutoEliminate(n, element1, element2, dir_v)

					if elimate:FindEliminatePoint() then
						table.insert(self.tbElementList, elimate)
						-- cclog("垂直添加 i-> i="..i.." j="..j)
					end
					-- cclog("垂直方向加入 i="..i.." j="..j)
				end
			end
		end
	end

	-- echoj("===========EliminateSystem:MakeEliminateList", self.tbElementList)
	if #self.tbDelTabel ~= 0 then --有删除的元素
		self:RequestAutoEliminate()
	end
end


--检查自消除
function EliminateSystem:CheckAutoEliminate(element1, element2, element3, dir)
	if element1:GetColor() == element2:GetColor() and element1:GetColor() == element3:GetColor() and element2:GetColor() == element3:GetColor() then
		--颜色都相同的情况 再向两端找
	local dirColor = element1:GetColor()
	local xl = element1:GetPonit().x
	local yl = element1:GetPonit().y
	local xr = element3:GetPonit().x
	local yr = element3:GetPonit().y
	local tbTemp = {}
	local checkele = nil

	if dir == dir_v then
		--垂直
		for i=xl-1, 1, -1 do --上
			checkele = self:GetElementByIndex(i, yl)
			if dirColor == checkele:GetColor() then
				table.insert(tbTemp, self:GetIndex(i, yl))
			else
				break
			end
		end

		for i=xr+1, 7 do --下
			checkele = self:GetElementByIndex(i, yr)
			if dirColor == checkele:GetColor() then
				table.insert(tbTemp, self:GetIndex(i, yr))
			else
				break
			end
		end

	elseif dir == dir_h then
		--水平
		for i=yl-1, 1, -1 do --左
			checkele = self:GetElementByIndex(xl, i)
			if dirColor == checkele:GetColor() then
				table.insert(tbTemp, self:GetIndex(xl, i))
			else
				break
			end
		end

		for i=yr+1, 7 do --右
			checkele = self:GetElementByIndex(xr, i)
			if dirColor == checkele:GetColor() then
				table.insert(tbTemp, self:GetIndex(xr, i))
			else
				break
			end
		end
	end


	--不添加重复的元素到删除列表
	local function InsertTabel(nIndex)
		local brest = true
		for k, v in ipairs(self.tbDelTabel)do
			if v == nIndex then
				brest = false
			end
		end
		if brest then
			table.insert(self.tbDelTabel, nIndex)
		end
	end

	--加入到self.tbDelTabel
	InsertTabel(element1:GetIndex())
	InsertTabel(element2:GetIndex())
	InsertTabel(element3:GetIndex())

	for i, j in ipairs(tbTemp)do
		InsertTabel(j)
	end
		return true
	end
	return false
end


function EliminateSystem:CloneElement()
	return  self.tbElement
end

function EliminateSystem:GetElementRanCount()
	return #self.tbElement
end


--通过行列获取元素
function EliminateSystem:GetElementByIndex(row, ran)
	if self.tbElement[row] == nil then return nil end
	return self.tbElement[row][ran]
end


--通过下标
function EliminateSystem:GetElement(nIndex)
	local row, col = self:GetRowAndRan(nIndex)

	return self:GetElementByIndex(row, col)
end


function EliminateSystem:SwapElementColor(indexa, indexb)
	local row, col = self:GetRowAndRan(indexa)
	local elea = self:GetElementByIndex(row, col)

	row, col = self:GetRowAndRan(indexb)
	local eleb = self:GetElementByIndex(row, col)
	local ncolor = eleb:GetColor()

	eleb:SetColor(elea:GetColor())
	elea:SetColor(ncolor)
end


function EliminateSystem:SetElementColor(row, col, nvaule)
	local element = self:GetElementByIndex(row, col)
	if element ~= nil then
		element:SetColor(nvaule)
	end
end


--直接用界面上的颜色重新更新
function EliminateSystem:RefrshElementInfo(msg)
	cclog("============EliminateSystem:RefrshElementInfo============beg")

	-- echoj("..#self.tbElement",self.tbElement)

	--重置上一次的数据
	self.tbDelTabel = {}
	self.tbNewAdd = {}
	--
	if g_Cfg.Debug == true then
		local strlog = "\n"
		for i=1, 7 do
			for j=1, 7 do
				local element = self:GetElementByIndex(i, j)
				strlog = strlog.." "..element:GetColor()
			end
			strlog = strlog.."\n"
		end
		cclog("最新的元素"..strlog)
	end


	

	-- 清空消除列表
	self:MakeEliminateList()

	if #self.tbDelTabel == 0 then 
		g_FormMsgSystem:SendFormMsg(FormMsg_InspireForm_ComparisonColor, nil)
	end
	cclog("============EliminateSystem:RefrshElementInfo============end")
end


--使用行列 来获取下标
function EliminateSystem:GetIndex(row, ran)
	if row > nLength or ran > nLength then return 0 end

	return (row-1)*nLength + ran
end


--使用下标 获取行列
function EliminateSystem:GetRowAndRan(nIndex)
	local row = 0 
	local col = 0

	row = math.ceil(nIndex/nLength, 1)

	col = nIndex - (row-1)*nLength

	return row, col
end

local random = 1
--随机查找一组可以消除的点
function EliminateSystem:RandomEliminate()
	local randbase = #self.tbElementList
	
	-- for i=1, 10000 do
	-- 	-- local index =  math.ceil(math.randomseed(tostring(os.time()):reverse():sub(1, 6))%randbase, 1)
	-- 	-- math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	-- 	math.randomseed(os.time())
	-- 	cclog("EliminateSystem:RandomEliminate rand="..math.random(1000))
	-- end

	-- for i=1, 10 do
		-- math.randomseed(os.time())
		random = os.time() + random
		math.randomseed(random)
		local randnum = math.random(10000000)
		local x = randnum%randbase
		cclog("EliminateSystem:RandomEliminate === "..randnum.." xxxxxxx="..x)
		local index =  math.max(1, randnum%randbase)
		cclog("EliminateSystem:RandomEliminate rand="..index.." num="..randbase)
	-- end

	if self.tbElementList[index] ~= nil then
		self.nIndex = index
	else
		self.nIndex = 0
	end
	
	return self.tbElementList[index]

end


-- --找出最优路径
-- function EliminateSystem:GetPriorityElimiinate()

-- end

function EliminateSystem:GetAttribute()
	return self.InspireAttribute
end


function EliminateSystem:GetRandEliminateNode()
	return self.tbElementList[self.nIndex]
end


-------------------------技能-------------------
function EliminateSystem:GetActiveSkill()
	return self.nActiveSkill
end

function EliminateSystem:SetCurSkill(nIndex)
	self.ElimentSkill:SetCurSkill(nIndex)
end


function EliminateSystem:GetCurSkillIndex()
	return self.ElimentSkill:GetCurSkill()
end


function EliminateSystem:GetSkillStateByIndex(nIndex)
	return self.ElimentSkill:GetSkillEnableByIndex(nIndex)
end


function EliminateSystem:GetDelElementCount()
	return #self.tbDelTabel
end


function EliminateSystem:GetCurSkillDelElement(nIndex)
	return self.tbDelTabel[nIndex]
end


function EliminateSystem:GetSkillChangeCount()
	return self.ElimentSkill:ChangedElementCount()
end


function EliminateSystem:GetSkillChangeByIndex(index)
	return self.ElimentSkill:ChangedElement(index)
end


function EliminateSystem:GetCurSkillType()
	return self.ElimentSkill:GetType()
end

function EliminateSystem:GetNeedTongQian()
	cclog("===============EliminateSystem:GetNeedTongQian======"..self.ElimentSkill:GetNeedTongQian())
	return self.ElimentSkill:GetNeedTongQian()
end


function EliminateSystem:GetNeedYuanBao()
	cclog("============EliminateSystem:GetNeedYuanBao========="..self.ElimentSkill:GetNeedYuanBao())
	return self.ElimentSkill:GetNeedYuanBao()
end

--table中长度小于3的不计算
function EliminateSystem:CreateSkillEffect()
	self.tbDelTabel = {}
	if self.nIndex == 0 then return nil end

	self.tbDelTabel = self.ElimentSkill:GetEliminateList(self.tbElementList[self.nIndex])
	echoj("EliminateSystem:CreateSkillEffect", self.tbDelTabel)
end

------------------------------新加入的元素-------------------------------------------
function EliminateSystem:InitNewAddElement(tbMsg)
	self.tbNewAdd = {}
	local col = 0
	for k, v in ipairs(tbMsg.new_box_info)do
		col = v.col + 1

		if self.tbNewAdd[col] ~= nil then
			cclog("服务器的数据不一致 col="..col)
		end

		self.tbNewAdd[col] = {}

		for i, j in ipairs(v.data)do
				local element = NewAddElement.new()
				element:Init(col, j)

				table.insert(self.tbNewAdd[col], element)
		end
		
	end
end


function EliminateSystem:GetNewAddElement()
	cclog("EliminateSystem:GetNewAddElement", self.tbNewAdd)
	return self.tbNewAdd
end

----------------------------LOG------------------------------
function EliminateSystem:InsertElimnateLog(colorIndex, strLog)
	self.InspireLog:InsertLog(colorIndex, strLog)
	g_FormMsgSystem:SendFormMsg(FormMsg_InspireForm_InsertLog, nil)
end


function EliminateSystem:GetLogCount()
	return self.InspireLog:GetLogReverseCount()
end

function EliminateSystem:GetRevLogByIndex(nIndex)
	return self.InspireLog:GetReverseLogByIndex(nIndex)
end

function EliminateSystem:SaveEliminateLog()
	self.InspireLog:SaveRecordLog()
end
---------------------------------------------------------------------------------
--[[     MSG ]]
---------------------------------------------------------------------------------
--[[
message InspireRequest
{
	optional uint32 movefrom = 1;	// 调换格子from		值格式： row_idx*10+col_idx			idx从0开始
	optional uint32 moveto = 2;		// 调换格子to			值格式：row_idx*10+col_idx			idx从0开始
	repeated uint32 index = 3;		// 移动后的消除信息    值格式：type*100+row_idx*10+col_idx	idx从0开始
	optional INSPIRATION_SKILL_IDX use_skill_idx = 4;  //不用技能不赋值。
	optional bool is_coupons = 5;	//true表示用元宝
	repeated ChangedElement change_element = 6; //客户端用技能计算出的刷新信息。
}
]]
function EliminateSystem:RequestInspire(bYuanbao)
	if not self.ganwuclick then
		return false
	end 
	g_MsgNetWorkWarning:showWarningText(true)
	cclog("===================EliminateSystem:RequestInspire=================")
	if self.nIndex == 0 then cclog("感悟数据出错， 消息未发送 1") return end

	local msg = zone_pb.InspireRequest()
	local eliNode = self.tbElementList[self.nIndex]
	if eliNode == nil then cclog("感悟数据出错， 消息未发送 2") return end

	local nf, nt = eliNode:GetMovePoint()
	if nf == 0 or nt == 0 then cclog("感悟数据出错， 消息未发送 3") return end

	local row = -1
	local col = -1

	self:CreateSkillEffect()


	local ncolor 	= 0
	local element 	= nil
	local nres  	= 0

	for k, v in ipairs(self.tbDelTabel)do
		row, col  = self:GetRowAndRan(v)

		--后台需要产生后的坐标
		element = self.ElimentSkill:GetCloneElement(row, col)
		if element ~= nil then
			ncolor = element:GetColor()

			nres = ncolor*100+(row-1)*10+(col-1)
			table.insert(msg.index, nres)
		end
	end

	if self.ElimentSkill:GetType() ~= nil and self.ElimentSkill:GetType() > -1 then
		msg.use_skill_idx = self.ElimentSkill:GetType()
	end

	for i=1, self.ElimentSkill:ChangedElementCount()do
		local ele = self.ElimentSkill:ChangedElement(i)
		if ele ~= nil then
			local node = zone_pb.ChangedElement()
			row, col, node.type = ele:GetElementInfo() --服务器下标从0开始

			node.row_idx = row -1
			node.col_idx = col -1

			table.insert(msg.change_element, node)
		end
	end
	

	msg.is_coupons = bYuanbao
	msg.is_auto = false; --//true表示自动消除,false表示手动消除
	-- echoj(" 感悟消除========", msg)

	g_MsgMgr:sendMsg(msgid_pb.MSGID_INSPIRE_REQUEST, msg)
	--监控消息
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_INSPIRE_REQUEST)


	
	self.ganwuclick = false
end



--请求打开界面 同步一下服务器跟客户端的 数据
function EliminateSystem:RequestInspireCheckData()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_INSPIRE_INFO_REQUEST, nil)
	g_MsgNetWorkWarning:showWarningText()
end


function EliminateSystem:ResetRequestInspireDate()
	cclog("=========================感悟死局==========================")
	g_WndMgr:closeWnd("Game_GanWu")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_INSPIRE_INFO_RESET_REQUEST, nil)
	g_MsgNetWorkWarning:showWarningText()
end


--在上一轮消除后，新加的元素产生的消除
function EliminateSystem:RequestAutoEliminate()
	g_MsgNetWorkWarning:showWarningText(true)
	cclog("=============EliminateSystem:RequestAutoEliminate==============")
	echoj("self.tbDelTabel =",self.tbDelTabel)
	local msg = zone_pb.InspireRequest()
	local ncolor 	= 0
	local element 	= nil
	local nres  	= 0
	for k, v in ipairs(self.tbDelTabel)do
		local row, col  = self:GetRowAndRan(v)

		--后台需要产生后的坐标
		element = self:GetElementByIndex(row, col)
		if element ~= nil then
			ncolor = element:GetColor()

			nres = ncolor*100+(row-1)*10+(col-1)
			table.insert(msg.index, nres)
		end
	end

	self:SetCurSkill(I_S_I_AUTO_Eliminate_Logic)

	msg.is_auto = true;--//true表示自动消除,false表示手动消除	
	g_MsgMgr:sendMsg(msgid_pb.MSGID_INSPIRE_REQUEST, msg)

	--监控消息
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_INSPIRE_REQUEST)
	self.ganwuclick = false
end


function EliminateSystem:RespondInspire(tbMsg)
	cclog("============EliminateSystem:RespondInspire============")
	local msg = zone_pb.InspireResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	--更新 新添加的元素
	self:InitNewAddElement(msg)

	self.nActiveSkill = msg.create_skill_idx

	self.nGraySkill = msg.use_skill_idx

	self.InspireAttribute:UpdataAttribute(msg)
	
	if self:GetNeedYuanBao() then 
		gTalkingData:onPurchase(TDPurchase_Type.TDP_ELIMINATE_YUANBAO,1,self:GetNeedYuanBao())	
	end
	--通知界面 消除 爆炸的元素， 添加更新的元素
	g_FormMsgSystem:SendFormMsg(FormMsg_InspireForm_Eliminate, nil)
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_INSPIRE_REQUEST, msgid_pb.MSGID_INSPIRE_RESPONSE)

	
	if msg.is_auto == false then --//true表示自动消除,false表示手动消除
		cclog("================消耗感悟次数===================")
		--元宝和铜钱都消耗感悟次数
		g_Hero:incDailyNoticeByType(macro_pb.DT_GanWu)
	end
end


function EliminateSystem:RespondInspireCheckData(tbMsg)
	g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("============EliminateSystem:RespondInspireCheckData============")
	local msg = zone_pb.InspireInfoResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	self:InitEliminate(msg.inspiration)

	g_WndMgr:openWnd("Game_GanWu")
	-- g_FormMsgSystem:PostFormMsg(FormMsg_InspireForm_OpenWnd, nil)
end


--界面动画播放结束后 更新数据 如果有消除的情况 就继续消除
function EliminateSystem:OnMsgActionOver(tbMsg)
	self.ganwuclick = true
	g_MsgNetWorkWarning:closeNetWorkWarning()
	--技能重置
	self.ElimentSkill:Reset()
	self.ElimentSkill:SetCurActiveSkill(self.nGraySkill, false)
	self.ElimentSkill:SetCurActiveSkill(self.nActiveSkill, true)
	self.nActiveSkill = -1
	self.nGraySkill = -1
	--更新新的数据
	self:RefrshElementInfo(msg)
	
end

--------------------------
g_EliminateSystem = EliminateSystem.new()